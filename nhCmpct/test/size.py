#!/usr/bin/env python3
import os
import re
import sys
import subprocess

def build_objects():
    for source_file in os.listdir('.'):
        if re.compile(r'.*\.(c|S)$').match(source_file) == None:
            continue
        object_file = 'obj/' + source_file[:-1] + 'o'
        command = [f'make',f'-s']
        argNo = 1
        arguments = sys.argv[2:]	
        for eachArg in arguments:
                command.append(f'FLAG'+str(argNo)+'='+eachArg)
                argNo = argNo+1
        command.append(object_file)
        subprocess.check_call(command)

glob = f'obj/*.o'
remove = ["rm", "-rf", "obj"]

build_objects()
output = subprocess.check_output(
            'arm-none-eabi-size -t ' + glob,
            shell=True,
            stderr=subprocess.DEVNULL,
            universal_newlines=True)
sizes512 = output.splitlines()[-1].split('\t')
subprocess.check_call(remove)

print("==========================")
print(sys.argv[1])
fsizes = (f'.text bytes:\n{sizes512[0].strip()}\n'
          f'.data bytes:\n{sizes512[1].strip()}\n'
          f'.bss bytes:\n{sizes512[2].strip()}\n'
          f'.total bytes:\n{sizes512[3].strip()}\n')
print(fsizes)
