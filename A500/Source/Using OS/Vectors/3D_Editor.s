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
	beq.s	exit_closedos




* Print some text

	move.l	ConsoleHandle(pc),d1
	move.l	#message,d2
	move.l	#messagelen,d3
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

keybuffer	ds.b	80




;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

dosname	dc.b	'dos.library',0
	even

console	dc.b	'CON:0/120/640/80/INPUT WINDOW',0
	even

message	dc.b	'Type in your message (up to 80 chars.) and press RETURN',10,10,0
	even
messagelen	equ	*-message
