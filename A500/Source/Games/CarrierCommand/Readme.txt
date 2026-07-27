All binaries and disassemblies were from an original Amiga Carrier Command disk.

CCgame_start.s (which includes CCgame_main.s) and CCADFdisk_maker.s have been
tested with the WinUAE Amiga emulator, running HiSoft Devpac Amiga 3.04.

(There may be one compile error, due to an odd address at line 6680 in CCgame_main.s, but this
 can be ignored by ticking Devpac's assembler option "No Even Indirection Checking".  The game
 still runs and it then modifies this address before the instruction is executed).

CCbackup.s and CCboot.s have been tested with a real Amiga 500.


WinUAE memory requirements
--------------------------
CCgame_start.s - requires 512KB Chip RAM and 2MB Fast/Slow RAM

CCADFdisk_maker.s - requires 1MB Chip RAM and 1MB Fast/Slow RAM (or alternatively 2MB Chip RAM)
