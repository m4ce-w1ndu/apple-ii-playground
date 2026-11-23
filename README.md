# Apple II Assembly Playground

A lightweight, self-contained 6502 assembly playground for the Apple IIe using `ca65`/`ld65`, AppleCommander, and [Linapple](https://github.com/linappleii/linapple).

## Directory Layout

```text
apple-ii-playground/
├── src/            # Your 6502 assembly source files (*.s)
├── build/          # Generated object (*.o) and raw binary (*.bin) files
├── disks/
│   ├── Master.dsk  # Bootable DOS 3.3 master disk (Drive 1)
│   └── mydisk.dsk  # Blank DOS 3.3 work disk for your programs (Drive 2, gitignored)
├── tools/          # Local toolchain binaries (gitignored: ca65, ld65, ac.jar, linapple)
├── raw.cfg         # ld65 linker configuration (raw binary loaded at $6000)
└── Makefile        # Build, disk injection, and emulator targets
```

## Prerequisites & Toolchain (`tools/`)

The `Makefile` expects the following binaries inside `tools/` (gitignored):

- `tools/ca65` and `tools/ld65` — from the [cc65](https://github.com/cc65/cc65) 6502 cross-assembler suite
- `tools/ac.jar` — [AppleCommander](https://github.com/AppleCommander/AppleCommander/releases) CLI (`AppleCommander-ac-*.jar`) + a Java Runtime (`java`)
- `tools/linapple` — `linapple` binary (or symlink to your local build)

## Workflow

1. Create a 6502 assembly program in `src/` (for example `src/hello.s`, targeting `.org $6000`).
2. Assemble, inject onto `disks/mydisk.dsk`, and boot Linapple:
   ```bash
   make run PROG=hello
   ```
3. Once DOS 3.3 boots to the `]` prompt, your work disk is already mounted in **Drive 2**:
   ```text
   CATALOG,D2
   BRUN HELLO,D2
   ```
   *(Or press `F3` to mount `disks/mydisk.dsk` in Drive 1 and run `CATALOG` / `BRUN HELLO`.)*

### Makefile Targets

| Command | Description |
| :--- | :--- |
| `make build PROG=<name>` | Assemble `src/<name>.s` and link into `build/<name>.bin` |
| `make disk PROG=<name>` | Build and copy `<name>.bin` onto `disks/mydisk.dsk` at `$6000` (override with `ADDR=0x...`) |
| `make run PROG=<name>` | Build, update work disk, and launch Linapple with Drive 1 & Drive 2 mounted |
| `make emu` | Launch Linapple without rebuilding |
| `make catalog` | List files currently on `disks/mydisk.dsk` |
| `make reset-disk` | Recreate a fresh blank `disks/mydisk.dsk` |
| `make clean` | Remove the `build/` directory |

## Apple II Quick Reference

- **Safe User RAM:** `$0800`–`$95FF` (`raw.cfg` loads binaries at `$6000`, clear of BASIC and DOS 3.3)
- **Safe Zero Page Scratch:** `$06`–`$09`, `$FA`–`$FE`
- **High-Bit ASCII:** Set bit 7 (`ora #$80`) for normal white-on-black text
- **Common ROM Routines & Soft Switches:**
  - `HOME` (`$FC58`) — Clear 40-column text screen and home cursor
  - `COUT` (`$FDED`) — Print character in `A`
  - `RDKEY` (`$FD0C`) — Wait for keypress, return ASCII (high bit set) in `A`
  - `PRBYTE` (`$FDDA`) — Print `A` as two hex digits
  - `CROUT` (`$FD8E`) — Print carriage return
  - `SPEAKER` (`$C030`) — Toggle speaker click (`lda $C030`)

## Linapple Shortcuts

- `F2` — Cold Reset
- `Ctrl + F2` — Warm Reset
- `F3` / `F4` — Insert disk image into Drive 1 / Drive 2
- `F6` — Toggle Fullscreen
- `F9` — Cycle video modes
- `F10` — Quit
