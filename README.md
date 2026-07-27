# Amiga68000source
Amiga programs written in 68000 assembly language

Most programs will build with HiSoft Devpac 3 (apart from AmigaMountainPanic - see section below)


# Running / exiting programs
Use left mouse button to exit most programs.

NB: For StuntCarRacer1200.fast.s, run "SetPatch" before running this (to correct the bitplane alignment).


# Build errors
For any source files that give build errors due to unrecognised CALLEXEX/CALLDOS/DOSNAME/etc. macros, these can usually be fixed by adding this line before any code (e.g. insert at line 4):-

	include DH0:Devpac/System2.gs

(Obviously make sure your System2.gs exists at the above path / amend if necessary.)


NB: Disks/SCSICommand.s won't build, even with System2.gs, due to missing include "scsidisk.i".  I've not managed to find the correct version of it.


# Intentionally won't run
Disks/3D_example.s is intended to be built and written to custom Amiga floppy disk, so will crash if run directly (e.g. from Devpac).


# A500/Games/AmigaMountainPanic
"Mountain Panic" is a game for the BBC Micro, which was written by Dave Footitt.
This is my attempt at an Amiga port of this game.
It was developed using "WinUAEDemoToolChain_4" on a PC (using Visual Studio), rather than with Devpac on an Amiga.
An archive of "WinUAEDemoToolChain_4" has therefore also been included.
After extracting this archive, open \WinUAEDemoToolChain_4\VisualStudio\MP.sln in Visual Studio 2026.
Then select Build Solution and the executable "MP" should be created under \WinUAEDemoToolChain_4\DH0\
