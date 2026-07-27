# Amiga68000source
Amiga programs written in 68000 assembly language

A varied collection of Amiga 68000 sources written from 1989 onwards.
Includes demos, disk access, games (or parts of) and graphical effects, including texture mapping.
Some were written by me and some by others.

In particular there are source for:-
1. All AmigaComputing magazine demos (Zowee, Picture-This, Heavy, Right-Button and Xmas).
2. Disk access, mainly taken from Carrier Command's backup program.
3. 3D objects and worlds
4. Blitter object drawing.
5. Texture mapping.
6. Amiga Mountain Panic game.
7. Beast scroll (from Shadow of the Beast).
8. Program to make Carrier Command and Super Hang-On bootable disks.
9. Interphase 3D sources.
10. Stunt Car Racer source.


# Building
Most programs will build with HiSoft Devpac 3 (apart from AmigaMountainPanic - see section below).
An archive of HiSoft Devpac 3.18 disks is included ("Devpac318.lha").


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
