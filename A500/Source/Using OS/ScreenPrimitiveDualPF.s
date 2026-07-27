	section	ScreenPrimitive,code
	opt	c+,a+


	include DH0:Devpac/System2.gs


;gb_ActiView	equ	34		; not defined in system.gs


SCREEN_WIDTH	equ	320
SCREEN_HEIGHT	equ	256
SCREEN_DEPTH	equ	3


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

	move.l	#2*SCREEN_WIDTH/8*SCREEN_HEIGHT*SCREEN_DEPTH,d0
	move.l	#MEMF_CHIP!MEMF_CLEAR,d1
	CALLEXEC AllocMem
	move.l	d0,screen.memory
	beq	exit.close.dos

* Save current View to restore later

	move.l	_GfxBase(pc),a0
	move.l	gb_ActiView(a0),old.view

* Initialise View

	lea	v(pc),a1
	CALLGRAF InitView

	lea	v(pc),a1
	move.l	#vp,v_ViewPort(a1)

* Initialise ColorMap

	moveq	#1<<(SCREEN_DEPTH*2),d0	number of colour entries
	CALLGRAF GetColorMap
	move.l	d0,cm
	beq	exit.free.mem

	lea	colour.table(pc),a0
	move.l	d0,a1
	move.l	cm_ColorTable(a1),a1
	REPT	(1<<(SCREEN_DEPTH*2))-1
	move.w	(a0)+,(a1)+
	ENDR
	move.w	(a0),(a1)

* Initialise ViewPort

	lea	vp(pc),a0
	CALLGRAF InitVPort

	lea	vp(pc),a1
	move.l	cm(pc),vp_ColorMap(a1)
	move.w	#SCREEN_WIDTH,vp_DWidth(a1)
	move.w	#SCREEN_HEIGHT,vp_DHeight(a1)
	move.l	#ri1,vp_RasInfo(a1)
	move.w	#V_DUALPF!V_PFBA,vp_Modes(a1)

* Initialise RasInfo 1

	lea	ri1(pc),a1
	move.l	#ri2,ri_Next(a1)
	move.l	#bm1,ri_BitMap(a1)

* Initialise RasInfo 2

	lea	ri2(pc),a1
	move.l	#bm2,ri_BitMap(a1)

* Initialise BitMap 1

	lea	bm1(pc),a0
	moveq	#SCREEN_DEPTH,d0
	move.l	#SCREEN_WIDTH,d1
	move.l	#SCREEN_HEIGHT,d2
	CALLGRAF InitBitMap

	move.l	screen.memory(pc),a0
	lea	bm1(pc),a1
	lea	bm_Planes(a1),a1
	REPT	SCREEN_DEPTH-1
	move.l	a0,(a1)+
	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT(a0),a0
	ENDR
	move.l	a0,(a1)

* Initialise BitMap 2

	lea	bm2(pc),a0
	moveq	#SCREEN_DEPTH,d0
	move.l	#SCREEN_WIDTH,d1
	move.l	#SCREEN_HEIGHT,d2
	CALLGRAF InitBitMap

	move.l	screen.memory(pc),a0
	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT*SCREEN_DEPTH(a0),a0
	lea	bm2(pc),a1
	lea	bm_Planes(a1),a1
	REPT	SCREEN_DEPTH-1
	move.l	a0,(a1)+
	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT(a0),a0
	ENDR
	move.l	a0,(a1)

* Construct intermediate Copper list for ViewPort

	lea	v(pc),a0
	lea	vp(pc),a1
	CALLGRAF MakeVPort

* Merge all Copper lists together into a single list

	lea	v(pc),a1
	CALLGRAF MrgCop

* Load the new View

	lea	v(pc),a1
	CALLGRAF LoadView

* Fill BitMap 1 with pattern

	move.w	#SCREEN_HEIGHT*SCREEN_DEPTH-1,d0
	move.l	screen.memory(pc),a0
fill1
	REPT	SCREEN_WIDTH/16
	move.w	#$ff00,(a0)+
	ENDR
	dbra	d0,fill1

* Fill BitMap 2 with pattern

	move.w	#(SCREEN_HEIGHT/16)*SCREEN_DEPTH-1,d0
	move.l	screen.memory(pc),a0
	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT*SCREEN_DEPTH(a0),a0
fill2
	moveq	#8-1,d7
.loop
	REPT	SCREEN_WIDTH/16
	move.w	#$ffff,(a0)+
	ENDR
	dbra	d7,.loop

	lea	(SCREEN_WIDTH/8)*8(a0),a0
	dbra	d0,fill2

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

	move.l	old.view(pc),a1
	CALLGRAF LoadView

	move.l	cm(pc),a0
	CALLGRAF FreeColorMap

	lea	vp(pc),a0
	CALLGRAF FreeVPortCopLists

	lea	v(pc),a0
	move.l	v_LOFCprList(a0),a0
	CALLGRAF FreeCprList

exit.free.mem
	move.l	screen.memory(pc),a1
	move.l	#2*SCREEN_WIDTH/8*SCREEN_HEIGHT*SCREEN_DEPTH,d0
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

old.view	dc.l	0
screen.memory	dc.l	0
cm		dc.l	0


*"""""""""""""
*" CONSTANTS "
*"	     "
*"""""""""""""

intuition.name	INTNAME
graphics.name	GRAFNAME
DOS.name	DOSNAME
	even


*""""""""""""""
*" STRUCTURES "
*"	      "
*""""""""""""""

v	ds.b	v_SIZEOF
vp	ds.b	vp_SIZEOF
ri1	ds.b	ri_SIZEOF
ri2	ds.b	ri_SIZEOF
bm1	ds.b	bm_SIZEOF
bm2	ds.b	bm_SIZEOF


*"""""""""""""""""
*" GRAPHICS DATA "
*"		 "
*"""""""""""""""""

colour.table
	dc.w	$000,$fff,$111,$eee,$222,$ddd,$333,$cc0
	dc.w	$444,$bbb,$555,$aaa,$666,$999,$777,$0cc
