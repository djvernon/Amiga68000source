	section	Screen,code
	opt	c+,a+


	include DH0:Devpac/System2.gs


SCREEN_WIDTH	equ	320
SCREEN_HEIGHT	equ	256
SCREEN_DEPTH	equ	4


* Open the intuition library

	moveq	#0,d0
	lea	intuition.name(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_IntuitionBase
	beq	exit.false

* Open the graphics library

	moveq	#0,d0
	lea	graphics.name(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_GfxBase
	beq	exit.close.int

* Open the DOS library

	moveq	#0,d0
	lea	DOS.name(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_DOSBase
	beq	exit.close.graf

* Allocate screen memory

	move.l	#SCREEN_WIDTH/8*SCREEN_HEIGHT*SCREEN_DEPTH,d0
	move.l	#MEMF_CHIP!MEMF_CLEAR,d1
	CALLEXEC AllocMem
	move.l	d0,screen.memory
	beq	exit.close.dos

* Initialize bitmap

	lea	the.bitmap(pc),a0
	moveq	#SCREEN_DEPTH,d0
	move.l	#SCREEN_WIDTH,d1
	move.l	#SCREEN_HEIGHT,d2
	CALLGRAF InitBitMap

	move.l	screen.memory(pc),a0
	lea	the.bitmap(pc),a1
	lea	bm_Planes(a1),a1
	REPT	SCREEN_DEPTH-1
	move.l	a0,(a1)+
	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT(a0),a0
	ENDR
	move.l	a0,(a1)

* Open the screen

	lea	the.new.screen(pc),a0
	CALLINT	OpenScreen
	move.l	d0,the.screen
	beq	exit.free.mem

* Change colours

	move.l	the.screen(pc),a0
	lea	sc_ViewPort(a0),a0
	lea	colour.table(pc),a1
	moveq	#1<<SCREEN_DEPTH,d0	number of colours
	CALLGRAF LoadRGB4


*"""""""""""""
*" MAIN LOOP "
*"	     "
*"""""""""""""

main	moveq	#10,d1
	CALLDOS	Delay

	btst	#6,$bfe001.l
	bne.s	main


*""""""""""""""""
*" EXIT ROUTINE	"
*"		"
*""""""""""""""""

exit.close.screen
	move.l	the.screen(pc),a0
	CALLINT	CloseScreen

exit.free.mem
	move.l	screen.memory(pc),a1
	move.l	#SCREEN_WIDTH/8*SCREEN_HEIGHT*SCREEN_DEPTH,d0
	CALLEXEC FreeMem

exit.close.dos
	move.l	_DOSBase(pc),a1
	CALLEXEC CloseLibrary

exit.close.graf
	move.l	_GfxBase(pc),a1
	CALLEXEC CloseLibrary

exit.close.int
	move.l	_IntuitionBase(pc),a1
	CALLEXEC CloseLibrary

exit.false
	moveq	#0,d0
	rts


*"""""""""""""""
*" SUBROUTINES "
*"	       "
*"""""""""""""""


*"""""""""""""
*" VARIABLES "
*"	     "
*"""""""""""""

_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DOSBase	dc.l	0

screen.memory	dc.l	0
the.screen	dc.l	0


*"""""""""""""
*" CONSTANTS "
*"	     "
*"""""""""""""

intuition.name	INTNAME
graphics.name	GRAFNAME
DOS.name	DOSNAME

screen.title	dc.b	'Dan''s Screen',0
	even


*""""""""""""""""""""""""
*" INTUITION STRUCTURES "
*"			"
*""""""""""""""""""""""""

the.new.screen	dc.w	0,0		left, top
		dc.w	SCREEN_WIDTH,SCREEN_HEIGHT
		dc.w	SCREEN_DEPTH
		dc.b	0,1		pens
		dc.w	0		viewmodes
		dc.w	CUSTOMBITMAP!CUSTOMSCREEN	type
		dc.l	0		font
		dc.l	screen.title	title
		dc.l	0		gadgets
		dc.l	the.bitmap	bitmap

the.bitmap	ds.w	1		bytes per row
		ds.w	1		rows
		ds.b	1		flags
		ds.b	1		depth
		ds.w	1		pad
		ds.l	8		plane pointers


*"""""""""""""""""
*" GRAPHICS DATA "
*"		 "
*"""""""""""""""""

colour.table
	dc.w	$000,$fff,$111,$eee,$222,$ddd,$333,$ccc
	dc.w	$444,$bbb,$555,$aaa,$666,$999,$777,$888
