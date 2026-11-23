# Apple II 6502 Assembly Playground Makefile
#
# Usage:
#   make build PROG=hello        Assemble & link src/hello/hello.s (or src/hello.s) -> build/hello.bin
#   make disk  PROG=hello        Put build/hello.bin onto disks/mydisk.dsk as HELLO
#   make run   PROG=hello        Build, copy to disk, and launch Linapple
#   make emu                     Launch Linapple with Master.dsk (D1) & mydisk.dsk (D2)
#   make catalog                 List files on disks/mydisk.dsk
#   make reset-disk              Recreate a blank disks/mydisk.dsk
#   make clean                   Remove build artifacts

PROG      ?= hello
ADDR      ?= 0x6000
DOS_NAME  := $(shell echo "$(PROG)" | tr '[:lower:]' '[:upper:]')

# Support both src/<prog>/<prog>.s (including multiple .s files) and src/<prog>.s
ifneq ($(wildcard src/$(PROG)/*.s),)
  SRCS    ?= $(wildcard src/$(PROG)/*.s)
else
  SRCS    ?= src/$(PROG).s
endif

CA65      := ./tools/ca65
LD65      := ./tools/ld65
AC        := java -jar ./tools/ac.jar
LINAPPLE  := ./tools/linapple

BOOT_DISK := disks/Master.dsk
WORK_DISK := disks/mydisk.dsk
BUILD_DIR := build/$(PROG)
OBJS      := $(patsubst %.s,$(BUILD_DIR)/%.o,$(notdir $(SRCS)))
BIN       := build/$(PROG).bin

vpath %.s $(sort $(dir $(SRCS)))

.PHONY: all build disk run emu catalog reset-disk clean

all: disk

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.o: %.s | $(BUILD_DIR)
	$(CA65) $< -o $@

$(BIN): $(OBJS) raw.cfg
	$(LD65) -C raw.cfg $(OBJS) -o $@

build: $(BIN)

disk: $(BIN)
	@test -f $(WORK_DISK) || $(AC) -dos140 $(WORK_DISK)
	-$(AC) -d $(WORK_DISK) $(DOS_NAME) 2>/dev/null || true
	$(AC) -p $(WORK_DISK) $(DOS_NAME) B $(ADDR) < $(BIN)
	$(AC) -l $(WORK_DISK)

emu:
	$(LINAPPLE) --d1 $(BOOT_DISK) --d2 $(WORK_DISK) --autoboot

run: disk emu

catalog:
	$(AC) -l $(WORK_DISK)

reset-disk:
	rm -f $(WORK_DISK)
	$(AC) -dos140 $(WORK_DISK)

clean:
	rm -rf build
