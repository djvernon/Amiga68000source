	section	FileSplitter,code
	opt	c+,a+


	include	DH0:Devpac/System2.gs


FILE_SIZE	equ	1895857
WORK_SIZE	equ	200000


* Open the DOS library

	moveq	#0,d0
	lea	DOS.name(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_DOSBase
	beq	exit.false

* Allocate work memory

	move.l	#WORK_SIZE,d0
	moveq	#MEMF_PUBLIC,d1
	CALLEXEC AllocMem
	move.l	d0,work.memory
	beq	exit.close.dos

* Open input file

	move.l	#input.file,d1
	move.l	#MODE_OLDFILE,d2
	CALLDOS	Open
	move.l	d0,input.handle
	beq	exit.free.work.mem

* Open first output file

	move.l	#output.file1,d1
	move.l	#MODE_NEWFILE,d2
	CALLDOS	Open
	move.l	d0,output.handle
	beq	exit.close.input.file

* Copy 1000000 bytes from input file to first output file

	moveq	#1000000/WORK_SIZE-1,d7

make.file1
	move.l	input.handle(pc),d1
	move.l	work.memory(pc),d2
	move.l	#WORK_SIZE,d3
	CALLDOS	Read
	tst.l	d0
	beq	exit.close.output.file

	move.l	output.handle(pc),d1
	move.l	work.memory(pc),d2
	move.l	#WORK_SIZE,d3
	CALLDOS	Write

	dbra	d7,make.file1

* Close first output file

	move.l	output.handle(pc),d1
	CALLDOS	Close

* Open second output file

	move.l	#output.file2,d1
	move.l	#MODE_NEWFILE,d2
	CALLDOS	Open
	move.l	d0,output.handle
	beq.s	exit.close.input.file

* Copy 895857 bytes from input file to second output file

	moveq	#895857/WORK_SIZE-1,d7

make.file2
	move.l	input.handle(pc),d1
	move.l	work.memory(pc),d2
	move.l	#WORK_SIZE,d3
	CALLDOS	Read
	tst.l	d0
	beq.s	exit.close.output.file

	move.l	output.handle(pc),d1
	move.l	work.memory(pc),d2
	move.l	#WORK_SIZE,d3
	CALLDOS	Write

	dbra	d7,make.file2

	move.l	input.handle(pc),d1
	move.l	work.memory(pc),d2
	move.l	#95857,d3
	CALLDOS	Read
	tst.l	d0
	beq.s	exit.close.output.file

	move.l	output.handle(pc),d1
	move.l	work.memory(pc),d2
	move.l	#95857,d3
	CALLDOS	Write

exit.close.output.file
	move.l	output.handle(pc),d1
	CALLDOS	Close

exit.close.input.file
	move.l	input.handle(pc),d1
	CALLDOS	Close

exit.free.work.mem
	move.l	work.memory(pc),a1
	move.l	#WORK_SIZE,d0
	CALLEXEC FreeMem

exit.close.dos
	move.l	_DOSBase(pc),a1
	CALLEXEC CloseLibrary

exit.false
	moveq	#0,d0
	rts


*"""""""""""""
*" VARIABLES "
*"	     "
*"""""""""""""

_DOSBase	dc.l	0

work.memory	dc.l	0
input.handle	dc.l	0
output.handle	dc.l	0


*"""""""""""""
*" CONSTANTS "
*"	     "
*"""""""""""""

DOS.name	DOSNAME

input.file	dc.b	'dh0:Frontier/FrontierDemo.dsm',0
output.file1	dc.b	'dh0:Frontier/FrontierDemo.dsm1',0
output.file2	dc.b	'dh0:Frontier/FrontierDemo.dsm2',0
	even
