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

FLTO        = -flto
ARCH_FLAGS  = -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16
DEFINES     = -DSTM32F4

EXTRA_FLAGS ?=

CFLAGS     += -O3 \
              -Wall -Wextra -Wimplicit-function-declaration \
              -Wredundant-decls -Wmissing-prototypes -Wstrict-prototypes \
              -Wundef -Wshadow \
              -I$(OPENCM3DIR)/include \
              -fno-common $(ARCH_FLAGS) -MD $(DEFINES) $(EXTRA_FLAGS)

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

test:    $(BINPATH)/nhCmpct512_test.bin \
		     $(BINPATH)/nhCmpct768_test.bin \
		     $(BINPATH)/nhCmpct1024_test.bin

speed:   $(BINPATH)/nhCmpct512_speed.bin \
		     $(BINPATH)/nhCmpct768_speed.bin \
		     $(BINPATH)/nhCmpct1024_speed.bin

stack:   $(BINPATH)/nhCmpct512_stack.bin \
		     $(BINPATH)/nhCmpct768_stack.bin \
		     $(BINPATH)/nhCmpct1024_stack.bin

hashing: $(BINPATH)/nhCmpct512_hashing.bin \
		     $(BINPATH)/nhCmpct768_hashing.bin \
		     $(BINPATH)/nhCmpct1024_hashing.bin

$(BINPATH)/%.bin: $(ELFPATH)/%.elf
	$(MKDIR) $(BINPATH)
	$(SIZE) $(ELFPATH)/$(*).elf
	$(OBJCOPY) -S -Obinary $(ELFPATH)/$(*).elf $(BINPATH)/$(*).bin


$(ELFPATH)/%.elf: $(TESTPATH)/test.c $(TESTPATH)/speed.c $(TESTPATH)/stack.c \
	$(COMMONSOURCES) $(IMPLEMENTATION_SOURCES) $(IMPLEMENTATION_HEADERS) $(OPENCM3FILE)
	$(MKDIR) $(ELFPATH)
	$(CC) -o $@ $(CFLAGS) $(FLTO) -DNEWHOPE_N=$(shell echo $@ | grep -o '[[:digit:]]*') \
	$(TESTPATH)/$(shell echo $@ | grep -o -P '(?<=_).*(?=.elf)').c \
	$(COMMONSOURCES) $(IMPLEMENTATION_SOURCES) $(COMMONINCLUDES) $(LDFLAGS) $(FLTO)

$(ELFPATH)/%_hashing.elf: $(TESTPATH)/hashing.c \
	$(COMMONSOURCES) $(IMPLEMENTATION_SOURCES) $(IMPLEMENTATION_HEADERS) $(OPENCM3FILE)
	$(MKDIR) $(ELFPATH)
	$(CC) -o $@ $(CFLAGS) $(FLTO) -DNEWHOPE_N=$(shell echo $@ | grep -o '[[:digit:]]*') \
	-DPROFILE_HASHING $(TESTPATH)/hashing.c \
	$(COMMONSOURCES) $(IMPLEMENTATION_SOURCES) $(COMMONINCLUDES) $(LDFLAGS) $(FLTO)


$(OBJPATH)/%.o: $(IMPLEMENTATION_PATH)/%.c $(IMPLEMENTATION_HEADERS)
	$(MKDIR) $(OBJPATH)
	$(CC) -o $@ -c $(CFLAGS) -I$(IMPLEMENTATION_PATH) $(COMMONINCLUDES) $<

$(OBJPATH)/%.o: $(IMPLEMENTATION_PATH)/%.S $(IMPLEMENTATION_HEADERS)
	$(MKDIR) $(OBJPATH)
	$(CC) -o $@ -c $(CFLAGS) -I$(IMPLEMENTATION_PATH) $(COMMONINCLUDES) $<


runAll:	runTest	runSpeed runStack runHashing runSize

runTest:
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/nhCmpct512_test.bin
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/nhCmpct768_test.bin
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/nhCmpct1024_test.bin

runSpeed:
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/nhCmpct512_speed.bin
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/nhCmpct768_speed.bin
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/nhCmpct1024_speed.bin

runStack:
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/nhCmpct512_stack.bin
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/nhCmpct768_stack.bin
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/nhCmpct1024_stack.bin

runHashing:
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/nhCmpct512_hashing.bin
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/nhCmpct768_hashing.bin
	python3 $(TESTPATH)/read_guest.py $(BINPATH)/nhCmpct1024_hashing.bin

runSize:
	python3 size.py

clean:
	-rm -rf $(BINPATH)
	-rm -rf $(ELFPATH)
