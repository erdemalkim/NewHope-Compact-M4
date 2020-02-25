OPENCM3DIR  = ./libopencm3
OPENCM3NAME = opencm3_stm32f4
OPENCM3FILE = $(OPENCM3DIR)/lib/lib$(OPENCM3NAME).a
LDSCRIPT    = ldscripts/stm32f405x6.ld

PREFIX     ?= arm-none-eabi
CC          = $(PREFIX)-gcc
LD          = $(PREFIX)-gcc
OBJCOPY     = $(PREFIX)-objcopy
SIZE        = $(PREFIX)-size
MKDIR       = mkdir -p

ARCH_FLAGS  = -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -flto
DEFINES     = -DSTM32F4

FLAG1 ?=
FLAG2 ?=
FLAG3 ?=
FLAG4 ?=

CFLAGS     += -O3 \
              -Wall -Wextra -Wimplicit-function-declaration \
              -Wredundant-decls -Wmissing-prototypes -Wstrict-prototypes \
              -Wundef -Wshadow \
              -I$(OPENCM3DIR)/include \
              -fno-common $(ARCH_FLAGS) -MD $(DEFINES) $(FLAG1) $(FLAG2) $(FLAG3) $(FLAG4)

LDFLAGS    += --static -Wl,--start-group -lc -lgcc -lnosys -Wl,--end-group \
              -T$(LDSCRIPT) -nostartfiles -Wl,--gc-sections \
               $(ARCH_FLAGS) -L$(OPENCM3DIR)/lib -lm -l$(OPENCM3NAME)

COMMONPATH = common
TESTPATH   = test
BINPATH    = bin
ELFPATH    = elf
OBJPATH    = obj
IMPLEMENTATION_PATH=.

COMMONINCLUDES = -I$(COMMONPATH) -I$(IMPLEMENTATION_PATH)

COMMONSOURCES          = $(COMMONPATH)/randombytes.c $(COMMONPATH)/fips202.c $(COMMONPATH)/keccakf1600.S $(COMMONPATH)/hal-stm32f4.c
IMPLEMENTATION_SOURCES = $(wildcard $(IMPLEMENTATION_PATH)/*.c) $(wildcard $(IMPLEMENTATION_PATH)/*.S)
IMPLEMENTATION_HEADERS = $(IMPLEMENTATION_PATH)/*.h


.PHONY: clean all test speed stack hashing
all:     test speed stack hashing

test:    $(BINPATH)/kyber512_test.bin \
		     $(BINPATH)/kyber768_test.bin \
		     $(BINPATH)/kyber1024_test.bin

speed:   $(BINPATH)/kyber512_speed.bin \
		     $(BINPATH)/kyber768_speed.bin \
		     $(BINPATH)/kyber1024_speed.bin

stack:   $(BINPATH)/kyber512_stack.bin \
		     $(BINPATH)/kyber768_stack.bin \
		     $(BINPATH)/kyber1024_stack.bin

hashing: $(BINPATH)/kyber512_hashing.bin \
		     $(BINPATH)/kyber768_hashing.bin \
		     $(BINPATH)/kyber1024_hashing.bin

$(BINPATH)/%.bin: $(ELFPATH)/%.elf
	$(MKDIR) $(BINPATH)
	$(SIZE) $(ELFPATH)/$(*).elf
	$(OBJCOPY) -S -Obinary $(ELFPATH)/$(*).elf $(BINPATH)/$(*).bin


$(ELFPATH)/%.elf: $(TESTPATH)/test.c $(TESTPATH)/speed.c $(TESTPATH)/stack.c $(OPENCM3FILE) \
	$(COMMONSOURCES) $(IMPLEMENTATION_SOURCES) $(IMPLEMENTATION_HEADERS) $(OPENCM3FILE)
	$(MKDIR) $(ELFPATH)
	$(CC) -o $@ $(CFLAGS) -DKYBER_P=$(shell echo $@ | grep -o '[[:digit:]]*') \
	$(TESTPATH)/$(shell echo $@ | grep -o -P '(?<=_).*(?=.elf)').c \
	$(COMMONSOURCES) $(IMPLEMENTATION_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

$(ELFPATH)/%_hashing.elf: $(TESTPATH)/hashing.c $(OPENCM3FILE) \
	$(COMMONSOURCES) $(IMPLEMENTATION_SOURCES) $(IMPLEMENTATION_HEADERS) $(OPENCM3FILE)
	$(MKDIR) $(ELFPATH)
	$(CC) -o $@ $(CFLAGS) -DKYBER_P=$(shell echo $@ | grep -o '[[:digit:]]*') \
	-DPROFILE_HASHING $(TESTPATH)/hashing.c \
	$(COMMONSOURCES) $(IMPLEMENTATION_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)


obj/%.o: $(IMPLEMENTATION_PATH)/%.c $(IMPLEMENTATION_HEADERS)
	mkdir -p obj
	$(CC) -o $@ -c $(CFLAGS) -I$(IMPLEMENTATION_PATH) $(COMMONINCLUDES) $<

obj/%.o: $(IMPLEMENTATION_PATH)/%.S $(IMPLEMENTATION_HEADERS)
	mkdir -p obj
	$(CC) -o $@ -c $(CFLAGS) -I$(IMPLEMENTATION_PATH) $(COMMONINCLUDES) $<


$(OPENCM3FILE):
	@if [ -z $(shell ls -A $(OPENCM3DIR)) ] ; then \
		printf "######## ERROR ########\n"; \
		printf "\tlibopencm3 is not initialized.\n"; \
		printf "\tPlease run (in the root directory):\n"; \
		printf "\t$$ git submodule init\n"; \
		printf "\t$$ git submodule update\n"; \
		printf "\tbefore running make.\n"; \
		printf "######## ERROR ########\n"; \
		exit 1; \
		fi
	make -C $(OPENCM3DIR)


runAll:	runTest	runSpeed runStack runHashing runSize

runTest:
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/kyber512_test.bin
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/kyber768_test.bin
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/kyber1024_test.bin

runSpeed:
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/kyber512_speed.bin
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/kyber768_speed.bin
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/kyber1024_speed.bin

runStack:
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/kyber512_stack.bin
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/kyber768_stack.bin
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/kyber1024_stack.bin

runHashing:
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/kyber512_hashing.bin
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/kyber768_hashing.bin
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/kyber1024_hashing.bin

runSize:
	python3 $(TESTPATH)/size.py Kyber512 -DKYBER_P=512 $(FLAG1) $(FLAG2) $(FLAG3)
	python3 $(TESTPATH)/size.py Kyber768 -DKYBER_P=768 $(FLAG1) $(FLAG2) $(FLAG3)
	python3 $(TESTPATH)/size.py Kyber1024 -DKYBER_P=1024 $(FLAG1) $(FLAG2) $(FLAG3)

clean:
	-rm -rf $(BINPATH)
	-rm -rf $(ELFPATH)
