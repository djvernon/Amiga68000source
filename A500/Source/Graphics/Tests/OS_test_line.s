	section	test_line,code_c
	opt	c+

	incdir	DH0:include/

	include	exec/memory.i
	include	exec/exec_lib.i
	include	intuition/intuition.i
	include	intuition/intuition_lib.i
	include	graphics/gfx.i
	include	graphics/graphics_lib.i
	include	libraries/dos.i
	include	libraries/dos_lib.i


; Press right mouse button to run test


* Open the intuition library

	moveq	#0,d0
	lea	int_name(pc),a1
	CALLEXEC OpenLibrary
	tst.l	d0
	beq	exit_false
	move.l	d0,_IntuitionBase

* Open the graphics library

	moveq	#0,d0
	lea	graf_name(pc),a1
	CALLEXEC OpenLibrary
	tst.l	d0
	beq	exit_closeint
	move.l	d0,_GfxBase

* Open the DOS library

	moveq	#0,d0
	lea	dos_name(pc),a1
	CALLEXEC OpenLibrary
	tst.l	d0
	beq	exit_closegraf
	move.l	d0,_DOSBase

* Allocate screen memory

	move.l	#4*40*200,d0
	move.l	#MEMF_CHIP!MEMF_CLEAR,d1
	CALLEXEC AllocMem
	tst.l	d0
	beq	exit_closedos
	move.l	d0,ScreenMem

* Initialize bitmap

	lea	TheBitMap(pc),a0
	moveq	#4,d0			four bitplanes
	move.l	#320,d1			width
	move.l	#200,d2			height
	CALLGRAF InitBitMap

	move.l	ScreenMem(pc),a0
	lea	TheBitMap(pc),a1
	lea	bm_Planes(a1),a1
	move.l	a0,(a1)+
	lea	40*200(a0),a0
	move.l	a0,(a1)+
	lea	40*200(a0),a0
	move.l	a0,(a1)+
	lea	40*200(a0),a0
	move.l	a0,(a1)

* Open the screen

	lea	TheNewScreen(pc),a0
	CALLINT	OpenScreen
	tst.l	d0
	beq	exit_freemem
	move.l	d0,TheScreen

* Change colours

	move.l	TheScreen(pc),a0
	lea	sc_ViewPort(a0),a0
	lea	colour.table(pc),a1
	moveq	#16,d0			sixteen colours
	CALLGRAF LoadRGB4




	move.l	TheScreen(pc),a5
	lea	sc_RastPort(a5),a5




wait.start
	btst	#2,$dff016
	bne.s	wait.start




*"""""""""""""
*" MAIN LOOP "
*"	     "
*"""""""""""""

outer.loop
	move.w	line.colour(pc),d0
	addq.w	#1,d0
	and.w	#15,d0
	move.w	d0,line.colour

	move.l	a5,a1
	CALLGRAF SetAPen

	move.w	#0,x1
	move.w	#0,y2
	move.w	#20-1,d7

inner.loop
	move.w	x1(pc),d0
	move.w	#0,d1
	move.l	a5,a1
	CALLGRAF Move
	move.w	#310,d0
	move.w	y2(pc),d1
	move.l	a5,a1
	CALLGRAF Draw

	move.w	#310,d0
	sub.w	x1(pc),d0
	move.w	#0,d1
	move.l	a5,a1
	CALLGRAF Move
	move.w	#0,d0
	move.w	y2(pc),d1
	move.l	a5,a1
	CALLGRAF Draw

	move.w	x1(pc),d0
	move.w	#190,d1
	move.l	a5,a1
	CALLGRAF Move
	move.w	#310,d0
	move.w	#190,d1
	sub.w	y2(pc),d1
	move.l	a5,a1
	CALLGRAF Draw

	move.w	#310,d0
	sub.w	x1(pc),d0
	move.w	#190,d1
	move.l	a5,a1
	CALLGRAF Move
	move.w	#0,d0
	move.w	#190,d1
	sub.w	y2(pc),d1
	move.l	a5,a1
	CALLGRAF Draw

	add.w	#16,x1
	add.w	#10,y2
	dbra	d7,inner.loop

	subq.w	#1,number
	bne	outer.loop

	bra.s	exit_test




x1	dc.w	0
y2	dc.w	0
line.colour	dc.w	0
number	dc.w	100




*""""""""""""""""
*" EXIT ROUTINE	"
*"		"
*""""""""""""""""

exit_test
	move.l	TheScreen(pc),a0
	CALLINT	CloseScreen

exit_freemem
	move.l	ScreenMem(pc),a1
	move.l	#4*40*200,d0
	CALLEXEC FreeMem

exit_closedos
	move.l	_DOSBase(pc),a1
	CALLEXEC CloseLibrary

exit_closegraf
	move.l	_GfxBase(pc),a1
	CALLEXEC CloseLibrary

exit_closeint
	move.l	_IntuitionBase(pc),a1
	CALLEXEC CloseLibrary

exit_false
	rts

* the definition of the screen

TheNewScreen	dc.w	0,0		left, top
		dc.w	320,200		width, height
		dc.w	4		depth
		dc.b	0,1		pens
		dc.w	0		viewmodes
		dc.w	CUSTOMBITMAP!CUSTOMSCREEN	type
		dc.l	0		font
		dc.l	screen_title	title
		dc.l	0		gadgets
		dc.l	TheBitMap	bitmap

TheBitMap	ds.w	1		bytes per row
		ds.w	1		rows
		ds.b	1		flags
		ds.b	1		depth
		ds.w	1		pad
		ds.l	8		plane pointers


* the variables
_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DOSBase	dc.l	0
ScreenMem	dc.l	0
TheScreen	dc.l	0

* some strings
int_name	INTNAME
graf_name	GRAFNAME
dos_name	DOSNAME

* these are C strings, so have to be null terminated
screen_title	dc.b	"Test Line",0
	even




*"""""""""""""""""
*" GRAPHICS DATA "
*"		 "
*"""""""""""""""""

colour.table
	dc.w	$000,$060,$0a0,$0e0,$400,$800,$c00,$e00
	dc.w	$004,$008,$00c,$00e,$444,$888,$ccc,$eee
