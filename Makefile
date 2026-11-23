# Apple II 6502 Assembly Playground Makefile
#
# Usage:
#   make build PROG=hello        Assemble & link src/hello.s -> build/hello.bin
#   make disk  PROG=hello        Put build/hello.bin onto disks/mydisk.dsk as HELLO
#   make run   PROG=hello        Build, copy to disk, and launch Linapple
#   make emu                     Launch Linapple with Master.dsk (D1) & mydisk.dsk (D2)
#   make catalog                 List files on disks/mydisk.dsk
#   make reset-disk              Recreate a blank disks/mydisk.dsk
#   make clean                   Remove build artifacts

PROG      ?= hello
SRC       ?= src/$(PROG).s
ADDR      ?= 0x6000
DOS_NAME  := $(shell echo "$(PROG)" | tr '[:lower:]' '[:upper:]')

CA65      := ./tools/ca65
LD65      := ./tools/ld65
AC        := java -jar ./tools/ac.jar
LINAPPLE  := ./tools/linapple

BOOT_DISK := disks/Master.dsk
WORK_DISK := disks/mydisk.dsk
BUILD_DIR := build
OBJ       := $(BUILD_DIR)/$(PROG).o
BIN       := $(BUILD_DIR)/$(PROG).bin

.PHONY: all build disk run emu catalog reset-disk clean

all: disk

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(OBJ): $(SRC) | $(BUILD_DIR)
	$(CA65) $< -o $@

$(BIN): $(OBJ) raw.cfg
	$(LD65) -C raw.cfg $(OBJ) -o $@

build: $(BIN)

disk: $(BIN)
	@test -f $(WORK_DISK) || $(AC) -dos140 $(WORK_DISK)
	-$(AC) -d $(WORK_DISK) $(DOS_NAME) 2>/dev/null
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
	rm -rf $(BUILD_DIR)
