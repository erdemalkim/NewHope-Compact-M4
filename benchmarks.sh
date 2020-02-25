#!/bin/bash

printHeader() {
    echo "# $1" >> $fileName 
}

printTableHead() {
    printRow "$@"
    echo -n "| " >> $fileName
    for i in "$@"; do 
      echo -n "--- | " >> $fileName
    done
    echo "" >> $fileName
}

printRow() {
    echo -n "| " >> $fileName
    for i in "$@"; do 
      echo -n "$i | " >> $fileName
    done
    echo "" >> $fileName
}

extractValuesForSpeedAndStack() {
    if [ "$1" == "speed" ]
    then
      keygen=$(echo $result | grep -oP 'keypair(.){20}')
    else
      keygen=$(echo $result | grep -oP 'key gen(.){20}')
    fi

    keygen512=$(echo ${keygen:0:28} | grep -o '[[:digit:]]*')
    keygen768=$(echo ${keygen:28:28} | grep -o '[[:digit:]]*')
    keygen1024=$(echo ${keygen:56:28} | grep -o '[[:digit:]]*')

    local encaps=$(echo $result | grep -oP 'encaps(.){20}')
    encaps512=$(echo ${encaps:0:28} | grep -o '[[:digit:]]*')
    encaps768=$(echo ${encaps:28:28} | grep -o '[[:digit:]]*')
    encaps1024=$(echo ${encaps:56:28} | grep -o '[[:digit:]]*')

    local decaps=$(echo $result | grep -oP 'decaps(.){20}')
    decaps512=$(echo ${decaps:0:28} | grep -o '[[:digit:]]*')
    decaps768=$(echo ${decaps:28:28} | grep -o '[[:digit:]]*')
    decaps1024=$(echo ${decaps:56:28} | grep -o '[[:digit:]]*')
}

extractValuesForSize() {
    local text=$(echo $result | grep -oP 'text(.){15}')
    text512=$(echo ${text:0:20} | grep -o '[[:digit:]]*')
    text768=$(echo ${text:20:20} | grep -o '[[:digit:]]*')
    text1024=$(echo ${text:40:20} | grep -o '[[:digit:]]*')

    local data=$(echo $result | grep -oP 'data(.){15}')
    data512=$(echo ${data:0:20} | grep -o '[[:digit:]]*')
    data768=$(echo ${data:20:20} | grep -o '[[:digit:]]*')
    data1024=$(echo ${data:40:20} | grep -o '[[:digit:]]*')

    local bss=$(echo $result | grep -oP 'bss(.){15}')
    bss512=$(echo ${bss:0:20} | grep -o '[[:digit:]]*')
    bss768=$(echo ${bss:20:20} | grep -o '[[:digit:]]*')
    bss1024=$(echo ${bss:40:20} | grep -o '[[:digit:]]*')

    local total=$(echo $result | grep -oP 'total(.){15}')
    total512=$(echo ${total:0:20} | grep -o '[[:digit:]]*')
    total768=$(echo ${total:20:20} | grep -o '[[:digit:]]*')
    total1024=$(echo ${result:(-10)} | grep -o '[[:digit:]]*')
}

runBenchmark() {
    local param=$4
    param="$(tr '[:lower:]' '[:upper:]' <<< ${param:0:1})${param:1}"
    
    if [ "$4" == "size" ]
    then 
    	result=$(make FLAG1=$1 FLAG2=$2 FLAG3=$3 run$param)
    else	
    	make clean FLAG1=$1 FLAG2=$2 FLAG3=$3 $4 >/dev/null 2>&1
    	result=$(make run$param)
    fi	
}

executeBenchmark() {
    echo "${green}running $5 for $1 with $2 $3 $4 ${reset}"
    cd $1
    runBenchmark "$2" "$3" "$4" "$5"
    cd ..
    
    if [ "$5" == "speed" ] || [ "$5" == "stack" ]
    then 
      extractValuesForSpeedAndStack $5
      printRow "$6512" $7 $keygen512 $encaps512 $decaps512
      if [ ${#keygen1024} -ne 0 ] 
      then
        printRow "$6768" $7 $keygen768 $encaps768 $decaps768
        printRow "$61024" $7 $keygen1024 $encaps1024 $decaps1024
      else
        printRow "$61024" $7 $keygen768 $encaps768 $decaps768
      fi
    else
      extractValuesForSize
      printRow "$6512" $7 $text512 $data512 $bss512 $total512
      if [ ${#bss1024} -ne 0 ] 
      then
        printRow "$6768" $7 $text768 $data768 $bss768 $total768
        printRow "$61024" $7 $text1024 $data1024 $bss1024 $total1024
      else
        printRow "$61024" $7 $text768 $data768 $bss768 $total1024
      fi
    fi
}

runBenchmarkFor() {
    executeBenchmark $1 "" "" "" $2 $3 "-"
    executeBenchmark $1 "-DUSE_REPT" "" "" $2 $3 "UR"
    executeBenchmark $1 "-DOPTIMIZE_STACK" "" "" $2 $3 "OS"
    executeBenchmark $1 "-DUSE_REPT" "-DOPTIMIZE_STACK" "" $2 $3 "UR/OS"
    if [ "$1" != "newhope" ]
    then 
      executeBenchmark $1 "-DSMALL_SECRET_KEY" "" "" $2 $3 "SSC"
      executeBenchmark $1 "-DSMALL_SECRET_KEY" "-DUSE_REPT" "" $2 $3 "SSC/UR"
      executeBenchmark $1 "-DSMALL_SECRET_KEY" "-DOPTIMIZE_STACK" "" $2 $3 "SSC/OS"
      executeBenchmark $1 "-DSMALL_SECRET_KEY" "-DUSE_REPT" "-DOPTIMIZE_STACK" $2 $3 "SSC/UR/OS"
    fi
}


green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`


fileName="benchmarks.md"
touch $fileName
:> $fileName


printHeader "Speed Evaluation"
printTableHead "Scheme" "Implementation" "Key Generation [cycles]" "Encapsulation [cycles]" "Decapsulation [cycles]"

echo "${yellow}calculating speed evaluation for NewHope-Compact...${reset}"
runBenchmarkFor "nhCmpct" "speed" "NewHope-Compact"
echo "${yellow}calculating speed evaluation for Kyber...${reset}"
runBenchmarkFor "kyber" "speed" "Kyber"
echo "${yellow}calculating speed evaluation for NewHope...${reset}"
runBenchmarkFor "newhope" "speed" "NewHope"


printHeader "Memory Evaluation"
printTableHead "Scheme" "Implementation" "Key Generation [bytes]" "Encapsulation [bytes]" "Decapsulation [bytes]"

echo "${yellow}calculating memory evaluation for NewHope-Compact...${reset}"
runBenchmarkFor "nhCmpct" "stack" "NewHope-Compact"
echo "${yellow}calculating memory evaluation for Kyber...${reset}"
runBenchmarkFor "kyber" "stack" "Kyber"
echo "${yellow}calculating memory evaluation for NewHope...${reset}"
runBenchmarkFor "newhope" "stack" "NewHope"


printHeader "Size Evaluation"
printTableHead "Scheme" "Implementation" ".text [bytes]" ".data [bytes]" ".bss [bytes]" "Total [bytes]"

echo "${yellow}calculating size evaluation for NewHope-Compact...${reset}"
runBenchmarkFor "nhCmpct" "size" "NewHope-Compact"
echo "${yellow}calculating size evaluation for Kyber...${reset}"
runBenchmarkFor "kyber" "size" "Kyber"
echo "${yellow}calculating size evaluation for NewHope...${reset}"
runBenchmarkFor "newhope" "size" "NewHope"

# sort speed result
sed -n '1,3p' $fileName > result
sed -n '4,59p' $fileName > tmp
sort tmp >> result

# sort memory result
sed -n '60,62p' $fileName >> result
sed -n '63,116p' $fileName > tmp
sort tmp >> result

# sort size result
sed -n '117,119p' $fileName >> result
sed -n '120,175p' $fileName > tmp
sort tmp >> result

rm tmp
rm $fileName
mv result $fileName

echo "## Abbreviations" >> $fileName
echo "\`UR\`: USE_REPT" >> $fileName
echo "\`OS\`: OPTIMIZE_STACK" >> $fileName
echo "\`SSC\`: SMALL_SECRET_KEY" >> $fileName
echo "Default option: \`OS\`" >> $fileName
