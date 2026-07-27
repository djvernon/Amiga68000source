	opt	c+,d+

	incdir	DH0:include/

	include	exec/exec_lib.i
	include	intuition/intuition.i
	include	intuition/intuition_lib.i
	include	libraries/dos.i
	include libraries/dos_lib.i
	include	graphics/text.i

* Open the intuition library

	moveq	#0,d0	
	lea	int_name(pc),a1
	CALLEXEC OpenLibrary
	tst.l	d0
	beq	exit_false		
	move.l	d0,_IntuitionBase	

* Open the DOS library

	moveq	#0,d0
	lea	dosname(pc),a1
	CALLEXEC OpenLibrary
	tst.l	d0
	beq	exit_closeint		
	move.l	d0,_DOSBase

* Open the screen

	lea	TheNewScreen(pc),a0
	CALLINT	OpenScreen		
	tst.l	d0
	beq	exit_closeall		
	move.l	d0,TheScreen

* Scroll
	move.b	#85,d5
	move.l	_IntuitionBase,a6
move	move.l	TheScreen(pc),a0
	moveq	#-3,d1
	jsr	-162(a6)	MoveScreen
	dbra	d5,move

* Delay
	move.b	#250,d1
	CALLDOS	Delay

* various exit routines that do tidying up

	move.l	TheScreen(pc),a0
	CALLINT CloseScreen

exit_closeall
	move.l	_DOSBase(pc),a1
	CALLEXEC CloseLibrary

exit_closeint
	move.l	_IntuitionBase(pc),a1
	CALLEXEC CloseLibrary

exit_false
	rts

* the definition of the screen

TheNewScreen	dc.w	0,258		left, top
		dc.w	320,200		width, height
		dc.w	2		depth
		dc.b	0,1		pens
		dc.w	0		viewmodes
		dc.w	CUSTOMSCREEN	type
		dc.l	MyFont		font
		dc.l	screen_title	title
		dc.l	0		gadgets
		dc.l	0		bitmap

* my font definition
MyFont	dc.l	font_name
	dc.w	TOPAZ_SIXTY
	dc.b	FS_NORMAL
	dc.b	FPF_ROMFONT

* the variables
_IntuitionBase	dc.l	0	
_DOSBase	dc.l	0
TheScreen		dc.l	0

* some strings
int_name	INTNAME
dosname		DOSNAME

* these are C strings, so have to be null terminated
screen_title	dc.b	"Dan's Screen",0
font_name	dc.b	"topaz.font",0
