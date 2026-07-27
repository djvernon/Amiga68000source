	section	3D_Editor,code
	opt	o+




* Open the DOS library

	moveq	#0,d0
	lea	dosname(pc),a1
	move.l	4.w,a6
	jsr	-552(a6)		OpenLibrary
	move.l	d0,_DOSBase
	beq	exit_now




* Open console window

	move.l	#console,d1
	move.l	#1005,d2		MODE_OLDFILE
	move.l	_DOSBase(pc),a6
	jsr	-30(a6)			Open
	move.l	d0,ConsoleHandle
	beq	exit_closedos




* Print some text

	move.l	ConsoleHandle(pc),d1
	move.l	#console.text,d2
	move.l	#console.textlen,d3
	move.l	_DOSBase(pc),a6
	jsr	-48(a6)			Write




* Open second console window

	move.l	#console2,d1
	move.l	#1005,d2		MODE_OLDFILE
	move.l	_DOSBase(pc),a6
	jsr	-30(a6)			Open
	move.l	d0,Console2Handle
	beq.s	exit_closeconsole




* Print some text

	move.l	Console2Handle(pc),d1
	move.l	#console2.text,d2
	move.l	#console2.textlen,d3
	move.l	_DOSBase(pc),a6
	jsr	-48(a6)			Write




* Read from the keyboard

	move.l	ConsoleHandle(pc),d1
	move.l	#keybuffer,d2
	moveq	#80,d3
	move.l	_DOSBase(pc),a6
	jsr	-42(a6)			Read




* Stop for a while

	moveq	#50,d1
	move.l	_DOSBase(pc),a6
	jsr	-198(a6)		Delay




* Write text back out

	move.l	ConsoleHandle(pc),d1
	move.l	#keybuffer,d2
	moveq	#80,d3
	move.l	_DOSBase(pc),a6
	jsr	-48(a6)			Write




* Stop for a while

	moveq	#50,d1
	move.l	_DOSBase(pc),a6
	jsr	-198(a6)		Delay




exit_closeconsole2
	move.l	Console2Handle(pc),d1
	move.l	_DOSBase(pc),a6
	jsr	-36(a6)			Close




exit_closeconsole
	move.l	ConsoleHandle(pc),d1
	move.l	_DOSBase(pc),a6
	jsr	-36(a6)			Close




exit_closedos
	move.l	_DOSBase(pc),a1
	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary




exit_now
	moveq	#0,d0
	rts




;"""""""""""""""
;" SUBROUTINES "
;"	       "
;"""""""""""""""




;""""""""""""""""""
;" ERROR HANDLING "
;"		  "
;""""""""""""""""""




;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

_DOSBase	dc.l	0
ConsoleHandle	dc.l	0
Console2Handle	dc.l	0

keybuffer	ds.b	80




;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

dosname	dc.b	'dos.library',0
	even

console	dc.b	'CON:0/0/192/112/CO-ORDINATES',0
	even

console.text
	dc.b	'NO.   X     Y     Z  ',10,10
	dc.b	'  1 00000 00000 00000',10
	dc.b	'  2 00000 00000 00000',10
	dc.b	'  3 00000 00000 00000',10
	dc.b	'  4 00000 00000 00000',10
	dc.b	'  5 00000 00000 00000',10
	dc.b	'  6 00000 00000 00000',10
	dc.b	'  7 00000 00000 00000',10
	dc.b	'  8 00000 00000 00000',10
	dc.b	'  9 00000 00000 00000',10,0
	even
console.textlen	equ	*-console.text

console2
	dc.b	'CON:190/0/312/112/OBJECT COMPONENTS',0
	even

console2.text
	dc.b	'TYPE    NO. COLOUR POINTS USED      ',10,10
	dc.b	'VECTOR    1    6    1, 2            ',10
	dc.b	'POLYGON   2    3    1, 2, 3, 4      ',10,0
	even
console2.textlen	equ	*-console2.text
