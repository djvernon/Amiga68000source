	section	SGII_Circles,code
	opt	c+


	include	DH0:Devpac/System2.gs

SCREEN_WIDTH	equ	320
SCREEN_HEIGHT	equ	205
SCREEN_DEPTH	equ	4


	CALLEXEC Forbid

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
	lea	SCREEN_WIDTH/8*SCREEN_HEIGHT-8(a0),a0

; minus 8 because SGII has 8192 bytes per bitplane, for some reason

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

circle	macro
	move.w	#\1,d0
	move.w	#\2,d1
	move.w	#\3,d2
	move.w	#\4,d3
	bsr	filled.circle
	endm


	move.l	screen.memory,TAB.416a8

	lea	$dff000,a6
	move.w	intenar(a6),old.ints	save system interrupt status
	move.w	#$7fff,intena(a6)	disable all interrupts

	move.l	sp,saved.sp
	move.l	#main,$80.w
	trap	#0

main	circle	22,4,166,77
	circle	21,5,166,77
	circle	20,6,166,77
	circle	19,1,166,77
	circle	18,3,166,77

	circle	3,6,128,78
	circle	3,4,128,78

	circle	4,14,137,79
	circle	4,12,137,79

	circle	14,8,80,116
	circle	14,9,79,116

	circle	180,10,-255,3128
	circle	180,10,-183,2604

	lea	6(sp),sp
	and.w	#$dfff,sr
	move.l	saved.sp,sp

	lea	$dff000,a6
	move.w	old.ints(pc),d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status

loop	moveq	#10,d1
	CALLDOS	Delay

	btst	#6,$bfe001.l
	bne.s	loop


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
	CALLEXEC Permit
	moveq	#0,d0
	rts


*"""""""""""""
*" VARIABLES "
*"	     "
*"""""""""""""

_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DOSBase	dc.l	0

screen.memory	dc.l	0
the.screen	dc.l	0
saved.sp	dc.l	0
old.ints	dc.w	0


*"""""""""""""
*" CONSTANTS "
*"	     "
*"""""""""""""

intuition.name	INTNAME
graphics.name	GRAFNAME
DOS.name	DOSNAME

screen.title	dc.b	'StargliderII Circles',0
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
	dc.w	$000,$f03,$aaf,$db2,$601,$902,$c02,$223
	dc.w	$88c,$669,$446,$048,$06a,$07d,$08f,$000


*"""""""""""""""
*" SUBROUTINES "
*"	       "
*"""""""""""""""

W.1002	dc.w	$8001


* Disassembly of $6324 - $64ec

return	rts

filled.circle
	lea	DAT.41848,a0
	move.w	d3,d4
	add.w	d0,d4
	cmp.w	#30,d4
	blt.s	return

	move.w	d3,d4
	sub.w	d0,d4
	cmp.w	#128,d4
	bgt.s	return

	move.w	d2,d4
	add.w	d0,d4
	cmp.w	#16,d4
	ble.s	return

	move.w	d2,d4
	sub.w	d0,d4
	cmp.w	#303,d4
	bgt.s	return

	move.l	a0,a1
	move.w	d1,(a1)+
	sub.w	d0,d3
	move.w	d3,(a1)+
	cmp.w	#2000,d0
	ble.s	circ1
	move.w	#2000,d0

circ1	moveq	#1,d6
	sub.w	d0,d6
	moveq	#1,d7
	moveq	#1,d3
	move.w	d0,d5
	moveq	#0,d4
	add.w	d0,d0
	sub.w	d0,d3
	add.w	d0,d0
	move.l	a1,a2
	ext.l	d0
	add.l	d0,a2
	move.l	a2,a3
	move.l	a3,a4
	add.l	d0,a4
	move.w	#$ffff,(a4)
	move.l	a4,a6

circ2	tst.w	d6
	bge.s	circ5
	addq.w	#1,d4
	addq.w	#2,d7
	addq.w	#2,d3
	add.w	d7,d6
	move.w	d5,d1
	neg.w	d1
	add.w	d2,d1
	cmp.w	#16,d1
	bgt.s	circ3
	move.w	#16,d1

circ3	move.w	d5,a5
	add.w	d2,a5
	cmp.w	#303,a5
	blt.s	circ4
	move.w	#303,a5

circ4	move.w	a5,-(a2)
	move.w	d1,-(a2)
	move.w	d1,(a3)+
	move.w	a5,(a3)+
	cmp.w	d5,d4
	blt.s	circ2
	bra.s	circA

circ5	move.w	d4,d1
	neg.w	d1
	add.w	d2,d1
	cmp.w	#16,d1
	bgt.s	circ6
	move.w	#16,d1

circ6	move.w	d4,a5
	add.w	d2,a5
	cmp.w	#303,a5
	blt.s	circ7
	move.w	#303,a5

circ7	move.w	d1,(a1)+
	move.w	a5,(a1)+
	move.w	a5,-(a4)
	move.w	d1,-(a4)
	addq.w	#1,d4
	subq.w	#1,d5
	addq.w	#2,d7
	addq.w	#4,d3
	add.w	d3,d6
	move.w	d5,d1
	neg.w	d1
	add.w	d2,d1
	cmp.w	#16,d1
	bgt.s	circ8
	move.w	#16,d1

circ8	move.w	d5,a5
	add.w	d2,a5
	cmp.w	#303,a5
	blt.s	circ9
	move.w	#303,a5

circ9	move.w	a5,-(a2)
	move.w	d1,-(a2)
	move.w	d1,(a3)+
	move.w	a5,(a3)+
	cmp.w	d5,d4
	blt	circ2

circA	move.l	(a0),d3
	lsr.w	#1,d0
	cmp.w	#16,d2
	blt.s	circD
	cmp.w	#303,d2
	bgt	circF

circB	move.w	d3,d4
	sub.w	#30,d4
	bge.s	circC
	neg.w	d4
	add.w	d4,d4
	add.w	d4,d4
	move.l	a0,a1
	lea	-4(a1,d4.w),a0
	swap	d3
	move.w	d3,(a0)
	swap	d3
	move.w	#30,2(a0)
	cmp.l	a0,a6
	ble	return

circC	cmp.w	#128,d3
	bgt	return
	move.w	d3,d4
	add.w	d0,d4
	sub.w	#128,d4
	ble	circ11
	add.w	d4,d4
	add.w	d4,d4
	sub.w	d4,a6
	move.w	#$ffff,(a6)
	bra	circ11

circD	lea	2(a0),a1
	move.w	#16,d6

circE	addq.w	#4,a1
	addq.w	#1,d3
	subq.w	#2,d0
	subq.w	#4,a6
	cmp.w	(a1),d6
	bgt.s	circE
	subq.w	#1,d3
	subq.w	#6,a1
	addq.w	#2,d0
	move.l	d3,(a1)
	move.l	a1,a0
	addq.w	#4,a6
	move.w	#$ffff,(a6)
	bra	circB

circF	move.l	a0,a1
	move.w	#303,d6

circ10	addq.w	#4,a1
	addq.w	#1,d3
	subq.w	#4,a6
	subq.w	#2,d0
	cmp.w	(a1),d6
	blt.s	circ10
	subq.w	#1,d3
	subq.w	#4,a1
	addq.w	#2,d0
	move.l	d3,(a1)
	move.l	a1,a0
	addq.w	#4,a6
	move.w	#$ffff,(a6)
	bra	circB

circ11	move.b	#16,B.e103
	move.l	a0,L.6524
	lea	L.6524,a2
	move.b	#13,B.e102
	clr.b	B.e103
	bra	circ12


L.6524	dc.l	0,-1


circ12	jmp	R.3dd12


B.e102	dc.b	0
B.e103	dc.b	0


R.3d9d8	rts


R.3d9da	ds.w	408


* Disassembly of $3dd0a - $41848

R.3dd0a	move.l	usp,a2
	bra	l000004


R.3dd10	rts


R.3dd12	tst.w	W.1002			fill routine
	bpl	l00006e
	move.b	#5,B.e103
	moveq	#0,d6
	moveq	#-1,d7
	moveq	#40,d0
	moveq	#32,d1

l000004	move.l	(a2)+,d3
	bmi	R.3dd10
	move.l	d3,a0
	move.l	a2,usp
	move.w	(a0)+,d3
	bmi	l00003a
	add.w	d3,d3
	move.w	TAB.3dd8e(pc,d3.w),d3
	lea	TAB.3dd8e(pc,d3.w),a2
	move.w	(a0)+,d2
	add.w	d2,d2
	lea	TAB.416b8(pc),a3
	move.l	TAB.416a8,a1
	add.w	(a3,d2.w),a1
	move.w	(a0)+,d2
	bmi	R.3dd0a

l000005	move.w	(a0)+,d3
	cmp.w	d2,d3
	bhi.s	l000006
	exg	d2,d3

l000006	moveq	#0,d5
	moveq	#$1f,d4
	sub.w	d3,d4
	bset	d4,d5
	subq.l	#1,d5
	move.w	d2,d4
	and.w	#$1f,d4
	sub.w	d4,d2
	add.w	d4,d4
	add.w	d4,d4
	move.l	TAB.3ddae(pc,d4.w),d4
	sub.w	d2,d3
	lsr.w	#3,d2
	move.l	a1,a3
	add.w	d2,a3
	add.w	d0,a1
	sub.w	d1,d3
	jmp	(a2)


TAB.3dd8e
	dc.w	$0160,$0208,$02b0,$0358,$0400,$04a8,$0550,$05f8
	dc.w	$06a0,$0748,$07f0,$0898,$0940,$09e8,$0a90,$0b38


TAB.3ddae
	dc.l	$00000000,$80000000,$c0000000,$e0000000
	dc.l	$f0000000,$f8000000,$fc000000,$fe000000
	dc.l	$ff000000,$ff800000,$ffc00000,$ffe00000
	dc.l	$fff00000,$fff80000,$fffc0000,$fffe0000
	dc.l	$ffff0000,$ffff8000,$ffffc000,$ffffe000
	dc.l	$fffff000,$fffff800,$fffffc00,$fffffe00
	dc.l	$ffffff00,$ffffff80,$ffffffc0,$ffffffe0
	dc.l	$fffffff0,$fffffff8,$fffffffc,$fffffffe


TAB.3de2e
	dc.l	$7fffffff,$3fffffff,$1fffffff,$0fffffff
	dc.l	$07ffffff,$03ffffff,$01ffffff,$00ffffff
	dc.l	$007fffff,$003fffff,$001fffff,$000fffff
	dc.l	$0007ffff,$0003ffff,$0001ffff,$0000ffff
	dc.l	$00007fff,$00003fff,$00001fff,$00000fff
	dc.l	$000007ff,$000003ff,$000001ff,$000000ff
	dc.l	$0000007f,$0000003f,$0000001f,$0000000f
	dc.l	$00000007,$00000003,$00000001,$00000000


TAB.3deae
	dc.w	$0000,$8000,$c000,$e000,$f000,$f800,$fc00,$fe00
	dc.w	$ff00,$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe


TAB.3dece
	dc.w	$7fff,$3fff,$1fff,$0fff,$07ff,$03ff,$01ff,$00ff
	dc.w	$007f,$003f,$001f,$000f,$0007,$0003,$0001,$0000


	bpl.s	l00000c
	or.l	d4,d5
	and.l	d5,(a3)
	and.l	d5,$2000(a3)
	and.l	d5,$4000(a3)
	and.l	d5,$6000(a3)
	not.l	d5
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a

l00000c	lea	$2000(a3),a4
	lea	$2000(a4),a5
	lea	$2000(a5),a6
	and.l	d4,(a3)+
	and.l	d4,(a4)+
	and.l	d4,(a5)+
	and.l	d4,(a6)+
	not.l	d4
	sub.w	d1,d3
	bmi.s	l00000d
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l00000d
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l00000d
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l00000d
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l00000d
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l00000d
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l00000d
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l00000d
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+

l00000d	and.l	d5,(a3)+
	and.l	d5,(a4)+
	and.l	d5,(a5)+
	and.l	d5,(a6)+
	not.l	d5
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a


	bpl.s	l00000e
	or.l	d4,d5
	and.l	d5,$2000(a3)
	and.l	d5,$4000(a3)
	and.l	d5,$6000(a3)
	not.l	d5
	or.l	d5,(a3)
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a

l00000e	lea	$2000(a3),a4
	lea	$2000(a4),a5
	lea	$2000(a5),a6
	and.l	d4,(a4)+
	and.l	d4,(a5)+
	and.l	d4,(a6)+
	not.l	d4
	or.l	d4,(a3)+
	sub.w	d1,d3
	bmi.s	l00000f
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l00000f
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l00000f
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l00000f
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l00000f
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l00000f
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l00000f
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l00000f
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+

l00000f	and.l	d5,(a4)+
	and.l	d5,(a5)+
	and.l	d5,(a6)+
	not.l	d5
	or.l	d5,(a3)+
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a


	bpl.s	l000010
	or.l	d4,d5
	and.l	d5,(a3)
	and.l	d5,$4000(a3)
	and.l	d5,$6000(a3)
	not.l	d5
	or.l	d5,$2000(a3)
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a

l000010	lea	$2000(a3),a4
	lea	$2000(a4),a5
	lea	$2000(a5),a6
	and.l	d4,(a3)+
	and.l	d4,(a5)+
	and.l	d4,(a6)+
	not.l	d4
	or.l	d4,(a4)+
	sub.w	d1,d3
	bmi.s	l000011
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000011
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000011
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000011
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000011
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000011
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000011
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000011
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+

l000011	and.l	d5,(a3)+
	and.l	d5,(a5)+
	and.l	d5,(a6)+
	not.l	d5
	or.l	d5,(a4)+
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a


	bpl.s	l000012
	or.l	d4,d5
	and.l	d5,$4000(a3)
	and.l	d5,$6000(a3)
	not.l	d5
	or.l	d5,(a3)
	or.l	d5,$2000(a3)
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a

l000012	lea	$2000(a3),a4
	lea	$2000(a4),a5
	lea	$2000(a5),a6
	and.l	d4,(a5)+
	and.l	d4,(a6)+
	not.l	d4
	or.l	d4,(a3)+
	or.l	d4,(a4)+
	sub.w	d1,d3
	bmi.s	l000013
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000013
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000013
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000013
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000013
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000013
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000013
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000013
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d6,(a6)+

l000013	and.l	d5,(a5)+
	and.l	d5,(a6)+
	not.l	d5
	or.l	d5,(a3)+
	or.l	d5,(a4)+
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a


	bpl.s	l000014
	or.l	d4,d5
	and.l	d5,(a3)
	and.l	d5,$2000(a3)
	and.l	d5,$6000(a3)
	not.l	d5
	or.l	d5,$4000(a3)
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a

l000014	lea	$2000(a3),a4
	lea	$2000(a4),a5
	lea	$2000(a5),a6
	and.l	d4,(a3)+
	and.l	d4,(a4)+
	and.l	d4,(a6)+
	not.l	d4
	or.l	d4,(a5)+
	sub.w	d1,d3
	bmi.s	l000015
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000015
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000015
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000015
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000015
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000015
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000015
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000015
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+

l000015	and.l	d5,(a3)+
	and.l	d5,(a4)+
	and.l	d5,(a6)+
	not.l	d5
	or.l	d5,(a5)+
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a


	bpl.s	l000016
	or.l	d4,d5
	and.l	d5,$2000(a3)
	and.l	d5,$6000(a3)
	not.l	d5
	or.l	d5,(a3)
	or.l	d5,$4000(a3)
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a

l000016	lea	$2000(a3),a4
	lea	$2000(a4),a5
	lea	$2000(a5),a6
	and.l	d4,(a4)+
	and.l	d4,(a6)+
	not.l	d4
	or.l	d4,(a3)+
	or.l	d4,(a5)+
	sub.w	d1,d3
	bmi.s	l000017
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000017
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000017
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000017
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000017
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000017
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000017
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000017
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+

l000017	and.l	d5,(a4)+
	and.l	d5,(a6)+
	not.l	d5
	or.l	d5,(a3)+
	or.l	d5,(a5)+
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a


	bpl.s	l000018
	or.l	d4,d5
	and.l	d5,(a3)
	and.l	d5,$6000(a3)
	not.l	d5
	or.l	d5,$2000(a3)
	or.l	d5,$4000(a3)
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a

l000018	lea	$2000(a3),a4
	lea	$2000(a4),a5
	lea	$2000(a5),a6
	and.l	d4,(a3)+
	and.l	d4,(a6)+
	not.l	d4
	or.l	d4,(a4)+
	or.l	d4,(a5)+
	sub.w	d1,d3
	bmi.s	l000019
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000019
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000019
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000019
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000019
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000019
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000019
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l000019
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+

l000019	and.l	d5,(a3)+
	and.l	d5,(a6)+
	not.l	d5
	or.l	d5,(a4)+
	or.l	d5,(a5)+
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a


	bpl.s	l00001a
	or.l	d4,d5
	and.l	d5,$6000(a3)
	not.l	d5
	or.l	d5,(a3)
	or.l	d5,$2000(a3)
	or.l	d5,$4000(a3)
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a

l00001a	lea	$2000(a3),a4
	lea	$2000(a4),a5
	lea	$2000(a5),a6
	and.l	d4,(a6)+
	not.l	d4
	or.l	d4,(a3)+
	or.l	d4,(a4)+
	or.l	d4,(a5)+
	sub.w	d1,d3
	bmi.s	l00001b
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l00001b
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l00001b
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l00001b
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l00001b
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l00001b
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l00001b
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+
	sub.w	d1,d3
	bmi.s	l00001b
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d6,(a6)+

l00001b	and.l	d5,(a6)+
	not.l	d5
	or.l	d5,(a3)+
	or.l	d5,(a4)+
	or.l	d5,(a5)+
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a


	bpl.s	l00001c
	or.l	d4,d5
	and.l	d5,(a3)
	and.l	d5,$2000(a3)
	and.l	d5,$4000(a3)
	not.l	d5
	or.l	d5,$6000(a3)
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a

l00001c	lea	$2000(a3),a4
	lea	$2000(a4),a5
	lea	$2000(a5),a6
	and.l	d4,(a3)+
	and.l	d4,(a4)+
	and.l	d4,(a5)+
	not.l	d4
	or.l	d4,(a6)+
	sub.w	d1,d3
	bmi.s	l00001d
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l00001d
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l00001d
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l00001d
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l00001d
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l00001d
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l00001d
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l00001d
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+

l00001d	and.l	d5,(a3)+
	and.l	d5,(a4)+
	and.l	d5,(a5)+
	not.l	d5
	or.l	d5,(a6)+
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a


	bpl.s	l00001e
	or.l	d4,d5
	and.l	d5,$2000(a3)
	and.l	d5,$4000(a3)
	not.l	d5
	or.l	d5,(a3)
	or.l	d5,$6000(a3)
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a

l00001e	lea	$2000(a3),a4
	lea	$2000(a4),a5
	lea	$2000(a5),a6
	and.l	d4,(a4)+
	and.l	d4,(a5)+
	not.l	d4
	or.l	d4,(a3)+
	or.l	d4,(a6)+
	sub.w	d1,d3
	bmi.s	l00001f
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l00001f
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l00001f
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l00001f
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l00001f
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l00001f
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l00001f
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l00001f
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+

l00001f	and.l	d5,(a4)+
	and.l	d5,(a5)+
	not.l	d5
	or.l	d5,(a3)+
	or.l	d5,(a6)+
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a


	bpl.s	l000020
	or.l	d4,d5
	and.l	d5,(a3)
	and.l	d5,$4000(a3)
	not.l	d5
	or.l	d5,$2000(a3)
	or.l	d5,$6000(a3)
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a

l000020	lea	$2000(a3),a4
	lea	$2000(a4),a5
	lea	$2000(a5),a6
	and.l	d4,(a3)+
	and.l	d4,(a5)+
	not.l	d4
	or.l	d4,(a4)+
	or.l	d4,(a6)+
	sub.w	d1,d3
	bmi.s	l000021
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000021
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000021
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000021
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000021
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000021
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000021
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000021
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+

l000021	and.l	d5,(a3)+
	and.l	d5,(a5)+
	not.l	d5
	or.l	d5,(a4)+
	or.l	d5,(a6)+
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a


	bpl.s	l000022
	or.l	d4,d5
	and.l	d5,$4000(a3)
	not.l	d5
	or.l	d5,(a3)
	or.l	d5,$2000(a3)
	or.l	d5,$6000(a3)
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a

l000022	lea	$2000(a3),a4
	lea	$2000(a4),a5
	lea	$2000(a5),a6
	and.l	d4,(a5)+
	not.l	d4
	or.l	d4,(a3)+
	or.l	d4,(a4)+
	or.l	d4,(a6)+
	sub.w	d1,d3
	bmi.s	l000023
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000023
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000023
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000023
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000023
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000023
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000023
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000023
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d6,(a5)+
	move.l	d7,(a6)+

l000023	and.l	d5,(a5)+
	not.l	d5
	or.l	d5,(a3)+
	or.l	d5,(a4)+
	or.l	d5,(a6)+
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a


	bpl.s	l000024
	or.l	d4,d5
	and.l	d5,(a3)
	and.l	d5,$2000(a3)
	not.l	d5
	or.l	d5,$4000(a3)
	or.l	d5,$6000(a3)
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a

l000024	lea	$2000(a3),a4
	lea	$2000(a4),a5
	lea	$2000(a5),a6
	and.l	d4,(a3)+
	and.l	d4,(a4)+
	not.l	d4
	or.l	d4,(a5)+
	or.l	d4,(a6)+
	sub.w	d1,d3
	bmi.s	l000025
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000025
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000025
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000025
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000025
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000025
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000025
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000025
	move.l	d6,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+

l000025	and.l	d5,(a3)+
	and.l	d5,(a4)+
	not.l	d5
	or.l	d5,(a5)+
	or.l	d5,(a6)+
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a


	bpl.s	l000026
	or.l	d4,d5
	and.l	d5,$2000(a3)
	not.l	d5
	or.l	d5,(a3)
	or.l	d5,$4000(a3)
	or.l	d5,$6000(a3)
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a

l000026	lea	$2000(a3),a4
	lea	$2000(a4),a5
	lea	$2000(a5),a6
	and.l	d4,(a4)+
	not.l	d4
	or.l	d4,(a3)+
	or.l	d4,(a5)+
	or.l	d4,(a6)+
	sub.w	d1,d3
	bmi.s	l000027
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000027
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000027
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000027
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000027
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000027
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000027
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000027
	move.l	d7,(a3)+
	move.l	d6,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+

l000027	and.l	d5,(a4)+
	not.l	d5
	or.l	d5,(a3)+
	or.l	d5,(a5)+
	or.l	d5,(a6)+
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a


	bpl.s	l000028
	or.l	d4,d5
	and.l	d5,(a3)
	not.l	d5
	or.l	d5,$2000(a3)
	or.l	d5,$4000(a3)
	or.l	d5,$6000(a3)
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a

l000028	lea	$2000(a3),a4
	lea	$2000(a4),a5
	lea	$2000(a5),a6
	and.l	d4,(a3)+
	not.l	d4
	or.l	d4,(a4)+
	or.l	d4,(a5)+
	or.l	d4,(a6)+
	sub.w	d1,d3
	bmi.s	l000029
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000029
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000029
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000029
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000029
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000029
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000029
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l000029
	move.l	d6,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+

l000029	and.l	d5,(a3)+
	not.l	d5
	or.l	d5,(a4)+
	or.l	d5,(a5)+
	or.l	d5,(a6)+
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a


	bpl.s	l00002a
	or.l	d4,d5
	not.l	d5
	or.l	d5,(a3)
	or.l	d5,$2000(a3)
	or.l	d5,$4000(a3)
	or.l	d5,$6000(a3)
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a

l00002a	lea	$2000(a3),a4
	lea	$2000(a4),a5
	lea	$2000(a5),a6
	not.l	d4
	or.l	d4,(a3)+
	or.l	d4,(a4)+
	or.l	d4,(a5)+
	or.l	d4,(a6)+
	sub.w	d1,d3
	bmi.s	l00002b
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l00002b
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l00002b
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l00002b
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l00002b
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l00002b
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l00002b
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+
	sub.w	d1,d3
	bmi.s	l00002b
	move.l	d7,(a3)+
	move.l	d7,(a4)+
	move.l	d7,(a5)+
	move.l	d7,(a6)+

l00002b	not.l	d5
	or.l	d5,(a3)+
	or.l	d5,(a4)+
	or.l	d5,(a5)+
	or.l	d5,(a6)+
	move.w	(a0)+,d2
	bpl	l000005
	bra	R.3dd0a


R.3e96e	lea	TAB.416b8(pc),a0
	moveq	#99,d0
	moveq	#0,d2
	tst.w	W.1002
	bpl	l000035
	moveq	#40,d1

l00002c	move.w	d2,(a0)+
	add.w	d1,d2
	move.w	d2,(a0)+
	add.w	d1,d2
	dbra	d0,l00002c
	lea	TAB.3ffba(pc),a2
	lea	TAB.3ddae(pc),a0
	moveq	#0,d0

l00002d	lea	TAB.3de2e(pc),a1
	moveq	#0,d1

l00002e	cmp.w	d0,d1
	bmi.s	l00002f
	move.l	(a0,d0.w),d3
	or.l	(a1,d1.w),d3
	bra.s	l000030

l00002f	move.l	(a0,d1.w),d3
	or.l	(a1,d0.w),d3

l000030	move.l	d3,(a2)+
	addq.w	#4,d1
	cmp.w	#128,d1
	bne.s	l00002e
	addq.w	#4,d0
	cmp.w	#128,d0
	bne.s	l00002d
	lea	TAB.40fba(pc),a2
	lea	TAB.3deae(pc),a0
	moveq	#0,d0

l000031	lea	TAB.3dece(pc),a1
	moveq	#0,d1

l000032	cmp.w	d0,d1
	bmi.s	l000033
	move.w	(a0,d0.w),d3
	or.w	(a1,d1.w),d3
	bra.s	l000034

l000033	move.w	(a0,d1.w),d3
	or.w	(a1,d0.w),d3

l000034	move.w	d3,(a2)+
	addq.w	#2,d1
	cmp.w	#32,d1
	bne.s	l000032
	addq.w	#2,d0
	cmp.w	#32,d0
	bne.s	l000031
	rts

l000035	lea	TAB.3ffba(pc),a2
	lea	TAB.3deae(pc),a0
	moveq	#0,d0

l000036	lea	TAB.3dece(pc),a1
	moveq	#0,d1

l000037	cmp.w	d0,d1
	bmi.s	l000038
	move.w	(a0,d0.w),d3
	or.w	(a1,d1.w),d3
	bra.s	l000039

l000038	move.w	(a0,d1.w),d3
	or.w	(a1,d0.w),d3

l000039	not.w	d3
	move.w	d3,(a2)+
	move.w	d3,(a2)+
	addq.w	#2,d1
	cmp.w	#32,d1
	bne.s	l000037
	addq.w	#2,d0
	cmp.w	#32,d0
	bne.s	l000036
	rts

l00003a	neg.w	d3
	cmp.w	#16,d3
	blt	l00005c
	and.w	#$f,d3
	add.w	d3,d3
	move.w	TAB.3ea92(pc,d3.w),a5
	move.w	(a0)+,d2
	add.w	d2,d2
	lea	TAB.416b8(pc),a1
	move.l	TAB.416a8,a3
	add.w	(a1,d2.w),a3
	lea	TAB.3ffba(pc),a2
	moveq	#$1f,d4
	move.w	(a0)+,d2
	bmi	R.3dd0a
	move.w	(a0)+,d3
	cmp.w	d2,d3
	bmi.s	l00003b
	move.w	d2,d5
	and.w	d4,d2
	sub.w	d2,d5
	lsr.w	#3,d5
	add.w	d5,a3
	jmp	TAB.3ea92(pc,a5.w)

l00003b	move.w	d3,d5
	and.w	d4,d3
	sub.w	d3,d5
	lsr.w	#3,d5
	add.w	d5,a3
	jmp	TAB.3ea92(pc,a5.w)


TAB.3ea92
	dc.w	$0020,$004e,$007c,$00aa,$00d8,$0106,$0134,$0162
	dc.w	$0190,$01be,$01ec,$021a,$0248,$0276,$02a4,$02d2


	bra.s	R.3eab6

l00003d	move.w	(a0)+,d3

R.3eab6	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#5,d2
	add.w	d2,d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a2,d3.w),d5
	and.l	d5,(a3)
	and.l	d5,$2000(a3)
	and.l	d5,$4000(a3)
	and.l	d5,$6000(a3)
	not.l	d5
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l00003d
	bra	R.3dd0a


	bra.s	l00003f

l00003e	move.w	(a0)+,d3

l00003f	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#5,d2
	add.w	d2,d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a2,d3.w),d5
	and.l	d5,$2000(a3)
	and.l	d5,$4000(a3)
	and.l	d5,$6000(a3)
	not.l	d5
	or.l	d5,(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l00003e
	bra	R.3dd0a


	bra.s	l000041

l000040	move.w	(a0)+,d3

l000041	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#5,d2
	add.w	d2,d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a2,d3.w),d5
	and.l	d5,(a3)
	and.l	d5,$4000(a3)
	and.l	d5,$6000(a3)
	not.l	d5
	or.l	d5,$2000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l000040
	bra	R.3dd0a


	bra.s	l000043

l000042	move.w	(a0)+,d3

l000043	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#5,d2
	add.w	d2,d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a2,d3.w),d5
	and.l	d5,$4000(a3)
	and.l	d5,$6000(a3)
	not.l	d5
	or.l	d5,(a3)
	or.l	d5,$2000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l000042
	bra	R.3dd0a


	bra.s	l000045

l000044	move.w	(a0)+,d3

l000045	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#5,d2
	add.w	d2,d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a2,d3.w),d5
	and.l	d5,(a3)
	and.l	d5,$2000(a3)
	and.l	d5,$6000(a3)
	not.l	d5
	or.l	d5,$4000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l000044
	bra	R.3dd0a


	bra.s	l000047

l000046	move.w	(a0)+,d3

l000047	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#5,d2
	add.w	d2,d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a2,d3.w),d5
	and.l	d5,$2000(a3)
	and.l	d5,$6000(a3)
	not.l	d5
	or.l	d5,(a3)
	or.l	d5,$4000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l000046
	bra	R.3dd0a


	bra.s	l000049

l000048	move.w	(a0)+,d3

l000049	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#5,d2
	add.w	d2,d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a2,d3.w),d5
	and.l	d5,(a3)
	and.l	d5,$6000(a3)
	not.l	d5
	or.l	d5,$2000(a3)
	or.l	d5,$4000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l000048
	bra	R.3dd0a


	bra.s	l00004b

l00004a	move.w	(a0)+,d3

l00004b	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#5,d2
	add.w	d2,d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a2,d3.w),d5
	and.l	d5,$6000(a3)
	not.l	d5
	or.l	d5,(a3)
	or.l	d5,$2000(a3)
	or.l	d5,$4000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l00004a
	bra	R.3dd0a


	bra.s	l00004d

l00004c	move.w	(a0)+,d3

l00004d	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#5,d2
	add.w	d2,d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a2,d3.w),d5
	and.l	d5,(a3)
	and.l	d5,$2000(a3)
	and.l	d5,$4000(a3)
	not.l	d5
	or.l	d5,$6000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l00004c
	bra	R.3dd0a


	bra.s	l00004f

l00004e	move.w	(a0)+,d3

l00004f	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#5,d2
	add.w	d2,d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a2,d3.w),d5
	and.l	d5,$2000(a3)
	and.l	d5,$4000(a3)
	not.l	d5
	or.l	d5,(a3)
	or.l	d5,$6000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l00004e
	bra	R.3dd0a


	bra.s	l000051

l000050	move.w	(a0)+,d3

l000051	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#5,d2
	add.w	d2,d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a2,d3.w),d5
	and.l	d5,(a3)
	and.l	d5,$4000(a3)
	not.l	d5
	or.l	d5,$2000(a3)
	or.l	d5,$6000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l000050
	bra	R.3dd0a


	bra.s	l000053

l000052	move.w	(a0)+,d3

l000053	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#5,d2
	add.w	d2,d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a2,d3.w),d5
	and.l	d5,$4000(a3)
	not.l	d5
	or.l	d5,(a3)
	or.l	d5,$2000(a3)
	or.l	d5,$6000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l000052
	bra	R.3dd0a


	bra.s	l000055

l000054	move.w	(a0)+,d3

l000055	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#5,d2
	add.w	d2,d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a2,d3.w),d5
	and.l	d5,(a3)
	and.l	d5,$2000(a3)
	not.l	d5
	or.l	d5,$4000(a3)
	or.l	d5,$6000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l000054
	bra	R.3dd0a


	bra.s	l000057

l000056	move.w	(a0)+,d3

l000057	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#5,d2
	add.w	d2,d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a2,d3.w),d5
	and.l	d5,$2000(a3)
	not.l	d5
	or.l	d5,(a3)
	or.l	d5,$4000(a3)
	or.l	d5,$6000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l000056
	bra	R.3dd0a


	bra.s	l000059

l000058	move.w	(a0)+,d3

l000059	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#5,d2
	add.w	d2,d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a2,d3.w),d5
	and.l	d5,(a3)
	not.l	d5
	or.l	d5,$2000(a3)
	or.l	d5,$4000(a3)
	or.l	d5,$6000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l000058
	bra	R.3dd0a


	bra.s	l00005b

l00005a	move.w	(a0)+,d3

l00005b	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#5,d2
	add.w	d2,d3
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a2,d3.w),d5
	not.l	d5
	or.l	d5,(a3)
	or.l	d5,$2000(a3)
	or.l	d5,$4000(a3)
	or.l	d5,$6000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l00005a
	bra	R.3dd0a


l00005c	add.w	d3,d3
	move.w	TAB.3edc4(pc,d3.w),a5
	move.w	(a0)+,d2
	add.w	d2,d2
	lea	TAB.416b8(pc),a1
	move.l	TAB.416a8,a3
	add.w	(a1,d2.w),a3
	move.w	(a0)+,d2
	bmi	R.3dd0a
	moveq	#$f,d4
	move.w	d2,d5
	and.w	d4,d2
	sub.w	d2,d5
	lsr.w	#3,d5
	add.w	d5,a3
	lea	TAB.40fba(pc),a2
	jmp	TAB.3edc4(pc,a5.w)


TAB.3edc4
	dc.w	$0020,$004a,$0074,$009e,$00c8,$00f2,$011c,$0146
	dc.w	$0170,$019a,$01c4,$01ee,$0218,$0242,$026c,$0296


l00005e	move.w	(a0)+,d3
	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#4,d2
	add.w	d2,d3
	add.w	d3,d3
	move.w	(a2,d3.w),d5
	and.w	d5,(a3)
	and.w	d5,$2000(a3)
	and.w	d5,$4000(a3)
	and.w	d5,$6000(a3)
	not.w	d5
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l00005e
	bra	R.3dd0a


l00005f	move.w	(a0)+,d3
	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#4,d2
	add.w	d2,d3
	add.w	d3,d3
	move.w	(a2,d3.w),d5
	and.w	d5,$2000(a3)
	and.w	d5,$4000(a3)
	and.w	d5,$6000(a3)
	not.w	d5
	or.w	d5,(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l00005f
	bra	R.3dd0a


l000060	move.w	(a0)+,d3
	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#4,d2
	add.w	d2,d3
	add.w	d3,d3
	move.w	(a2,d3.w),d5
	and.w	d5,(a3)
	and.w	d5,$4000(a3)
	and.w	d5,$6000(a3)
	not.w	d5
	or.w	d5,$2000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l000060
	bra	R.3dd0a


l000061	move.w	(a0)+,d3
	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#4,d2
	add.w	d2,d3
	add.w	d3,d3
	move.w	(a2,d3.w),d5
	and.w	d5,$4000(a3)
	and.w	d5,$6000(a3)
	not.w	d5
	or.w	d5,(a3)
	or.w	d5,$2000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l000061
	bra	R.3dd0a


l000062	move.w	(a0)+,d3
	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#4,d2
	add.w	d2,d3
	add.w	d3,d3
	move.w	(a2,d3.w),d5
	and.w	d5,(a3)
	and.w	d5,$2000(a3)
	and.w	d5,$6000(a3)
	not.w	d5
	or.w	d5,$4000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l000062
	bra	R.3dd0a


l000063	move.w	(a0)+,d3
	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#4,d2
	add.w	d2,d3
	add.w	d3,d3
	move.w	(a2,d3.w),d5
	and.w	d5,$2000(a3)
	and.w	d5,$6000(a3)
	not.w	d5
	or.w	d5,(a3)
	or.w	d5,$4000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l000063
	bra	R.3dd0a


l000064	move.w	(a0)+,d3
	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#4,d2
	add.w	d2,d3
	add.w	d3,d3
	move.w	(a2,d3.w),d5
	and.w	d5,(a3)
	and.w	d5,$6000(a3)
	not.w	d5
	or.w	d5,$2000(a3)
	or.w	d5,$4000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l000064
	bra	R.3dd0a


l000065	move.w	(a0)+,d3
	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#4,d2
	add.w	d2,d3
	add.w	d3,d3
	move.w	(a2,d3.w),d5
	and.w	d5,$6000(a3)
	not.w	d5
	or.w	d5,(a3)
	or.w	d5,$2000(a3)
	or.w	d5,$4000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l000065
	bra	R.3dd0a


l000066	move.w	(a0)+,d3
	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#4,d2
	add.w	d2,d3
	add.w	d3,d3
	move.w	(a2,d3.w),d5
	and.w	d5,(a3)
	and.w	d5,$2000(a3)
	and.w	d5,$4000(a3)
	not.w	d5
	or.w	d5,$6000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l000066
	bra	R.3dd0a


l000067	move.w	(a0)+,d3
	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#4,d2
	add.w	d2,d3
	add.w	d3,d3
	move.w	(a2,d3.w),d5
	and.w	d5,$2000(a3)
	and.w	d5,$4000(a3)
	not.w	d5
	or.w	d5,(a3)
	or.w	d5,$6000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l000067
	bra	R.3dd0a


l000068	move.w	(a0)+,d3
	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#4,d2
	add.w	d2,d3
	add.w	d3,d3
	move.w	(a2,d3.w),d5
	and.w	d5,(a3)
	and.w	d5,$4000(a3)
	not.w	d5
	or.w	d5,$2000(a3)
	or.w	d5,$6000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l000068
	bra	R.3dd0a


l000069	move.w	(a0)+,d3
	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#4,d2
	add.w	d2,d3
	add.w	d3,d3
	move.w	(a2,d3.w),d5
	and.w	d5,$4000(a3)
	not.w	d5
	or.w	d5,(a3)
	or.w	d5,$2000(a3)
	or.w	d5,$6000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l000069
	bra	R.3dd0a


l00006a	move.w	(a0)+,d3
	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#4,d2
	add.w	d2,d3
	add.w	d3,d3
	move.w	(a2,d3.w),d5
	and.w	d5,(a3)
	and.w	d5,$2000(a3)
	not.w	d5
	or.w	d5,$4000(a3)
	or.w	d5,$6000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l00006a
	bra	R.3dd0a


l00006b	move.w	(a0)+,d3
	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#4,d2
	add.w	d2,d3
	add.w	d3,d3
	move.w	(a2,d3.w),d5
	and.w	d5,$2000(a3)
	not.w	d5
	or.w	d5,(a3)
	or.w	d5,$4000(a3)
	or.w	d5,$6000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l00006b
	bra	R.3dd0a


l00006c	move.w	(a0)+,d3
	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#4,d2
	add.w	d2,d3
	add.w	d3,d3
	move.w	(a2,d3.w),d5
	and.w	d5,(a3)
	not.w	d5
	or.w	d5,$2000(a3)
	or.w	d5,$4000(a3)
	or.w	d5,$6000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l00006c
	bra	R.3dd0a


l00006d	move.w	(a0)+,d3
	and.w	d4,d2
	and.w	d4,d3
	lsl.w	#4,d2
	add.w	d2,d3
	add.w	d3,d3
	move.w	(a2,d3.w),d5
	not.w	d5
	or.w	d5,(a3)
	or.w	d5,$2000(a3)
	or.w	d5,$4000(a3)
	or.w	d5,$6000(a3)
	add.w	d0,a3
	move.w	(a0)+,d2
	bpl.s	l00006d
	bra	R.3dd0a


l00006e	btst	#1,B.416a5
	bne	l00009d

	move.l	TAB.416a8,a4
	move.l	#$ffff0000,a3
	move.l	#$ffff,d1
	moveq	#$f,d0
	moveq	#0,d5
	moveq	#-1,d7
	move.w	#160,a5

l00006f	move.l	(a2)+,d2
	bmi	R.3d9d8

l000070	move.l	d2,a0
	move.w	(a0)+,d2
	bpl.s	l000071
	neg.w	d2
	cmp.w	#16,d2
	blt	l000098
	and.w	d0,d2

l000071	add.w	d2,d2
	move.w	TAB.3f112(pc,d2.w),d2
	lea	TAB.3f112(pc,d2.w),a6
	lea	TAB.416b8(pc),a1
	move.w	(a0)+,d2
	add.w	d2,d2
	move.w	(a1,d2.w),d2
	move.l	a4,a1
	add.w	d2,a1
	move.w	(a0)+,d2
	bmi.s	l00006f

l000072	move.w	(a0)+,d3
	move.l	a1,usp
	cmp.w	d2,d3
	bgt.s	l000073
	exg	d2,d3

l000073	move.w	d2,d4
	and.w	d0,d4
	add.w	d4,d4
	add.w	d4,d4
	move.l	TAB.3f172(pc,d4.w),d4
	move.w	d3,d6
	and.w	d0,d6
	add.w	d6,d6
	add.w	d6,d6
	move.l	TAB.3f132(pc,d6.w),d6
	lsr.w	#1,d2
	and.w	#$fff8,d2
	add.w	d2,a1
	lsr.w	#1,d3
	sub.w	d2,d3
	jmp	(a6)


TAB.3f112
	dc.w	$00a0,$0170,$0246,$0322,$03f2,$04ce,$05b0,$068c
	dc.w	$0762,$083e,$091a,$09fc,$0ad8,$0bae,$0c8a,$0d66


TAB.3f132
	dc.l	$80008000,$c000c000,$e000e000,$f000f000
	dc.l	$f800f800,$fc00fc00,$fe00fe00,$ff00ff00
	dc.l	$ff80ff80,$ffc0ffc0,$ffe0ffe0,$fff0fff0
	dc.l	$fff8fff8,$fffcfffc,$fffefffe,$ffffffff


TAB.3f172
	dc.l	$ffffffff,$7fff7fff,$3fff3fff,$1fff1fff
	dc.l	$0fff0fff,$07ff07ff,$03ff03ff,$01ff01ff
	dc.l	$00ff00ff,$007f007f,$003f003f,$001f001f
	dc.l	$000f000f,$00070007,$00030003,$00010001


R.3f1b2	subq.w	#8,d3
	bpl.s	l000077
	and.l	d4,d6
	not.l	d6
	and.l	d6,(a1)+
	and.l	d6,(a1)
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


l000077	not.l	d4
	and.l	d4,(a1)+
	and.l	d4,(a1)+
	subq.w	#8,d3
	bmi	l000078
	move.l	d5,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi	l000078
	move.l	d5,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l000078
	move.l	d5,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l000078
	move.l	d5,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l000078
	move.l	d5,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l000078
	move.l	d5,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l000078
	move.l	d5,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l000078
	move.l	d5,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l000078
	move.l	d5,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l000078
	move.l	d5,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l000078
	move.l	d5,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l000078
	move.l	d5,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l000078
	move.l	d5,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l000078
	move.l	d5,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l000078
	move.l	d5,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l000078
	move.l	d5,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l000078
	move.l	d5,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l000078
	move.l	d5,(a1)+
	move.l	d5,(a1)+

l000078	not.l	d6
	and.l	d6,(a1)+
	and.l	d6,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


	subq.w	#8,d3
	bpl.s	l000079
	and.l	d6,d4
	or.w	d4,(a1)+
	not.l	d4
	and.w	d4,(a1)+
	and.l	d4,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


l000079	or.w	d4,(a1)+
	not.l	d4
	and.w	d4,(a1)+
	and.l	d4,(a1)+
	subq.w	#8,d3
	bmi	l00007a
	move.l	a3,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi	l00007a
	move.l	a3,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007a
	move.l	a3,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007a
	move.l	a3,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007a
	move.l	a3,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007a
	move.l	a3,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007a
	move.l	a3,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007a
	move.l	a3,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007a
	move.l	a3,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007a
	move.l	a3,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007a
	move.l	a3,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007a
	move.l	a3,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007a
	move.l	a3,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007a
	move.l	a3,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007a
	move.l	a3,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007a
	move.l	a3,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007a
	move.l	a3,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007a
	move.l	a3,(a1)+
	move.l	d5,(a1)+

l00007a	or.w	d6,(a1)+
	not.l	d6
	and.w	d6,(a1)+
	and.l	d6,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


	subq.w	#8,d3
	bpl.s	l00007b
	and.l	d6,d4
	move.w	d4,d2
	not.l	d4
	and.w	d4,(a1)+
	or.w	d2,(a1)+
	and.l	d4,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


l00007b	move.w	d4,d2
	not.l	d4
	and.w	d4,(a1)+
	or.w	d2,(a1)+
	and.l	d4,(a1)+
	subq.w	#8,d3
	bmi	l00007c
	move.l	d1,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi	l00007c
	move.l	d1,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007c
	move.l	d1,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007c
	move.l	d1,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007c
	move.l	d1,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007c
	move.l	d1,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007c
	move.l	d1,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007c
	move.l	d1,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007c
	move.l	d1,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007c
	move.l	d1,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007c
	move.l	d1,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007c
	move.l	d1,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007c
	move.l	d1,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007c
	move.l	d1,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007c
	move.l	d1,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007c
	move.l	d1,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007c
	move.l	d1,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007c
	move.l	d1,(a1)+
	move.l	d5,(a1)+

l00007c	move.w	d6,d2
	not.l	d6
	and.w	d6,(a1)+
	or.w	d2,(a1)+
	and.l	d6,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


	subq.w	#8,d3
	bpl.s	l00007d
	and.l	d6,d4
	or.l	d4,(a1)+
	not.l	d4
	and.l	d4,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


l00007d	or.l	d4,(a1)+
	not.l	d4
	and.l	d4,(a1)+
	subq.w	#8,d3
	bmi	l00007e
	move.l	d7,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi	l00007e
	move.l	d7,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007e
	move.l	d7,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007e
	move.l	d7,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007e
	move.l	d7,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007e
	move.l	d7,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007e
	move.l	d7,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007e
	move.l	d7,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007e
	move.l	d7,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007e
	move.l	d7,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007e
	move.l	d7,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007e
	move.l	d7,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007e
	move.l	d7,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007e
	move.l	d7,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007e
	move.l	d7,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007e
	move.l	d7,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007e
	move.l	d7,(a1)+
	move.l	d5,(a1)+
	subq.w	#8,d3
	bmi.s	l00007e
	move.l	d7,(a1)+
	move.l	d5,(a1)+

l00007e	or.l	d6,(a1)+
	not.l	d6
	and.l	d6,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


	subq.w	#8,d3
	bpl.s	l00007f
	and.l	d6,d4
	move.w	d4,d2
	not.l	d4
	and.l	d4,(a1)+
	or.w	d2,(a1)+
	and.w	d4,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


l00007f	move.w	d4,d2
	not.l	d4
	and.l	d4,(a1)+
	or.w	d2,(a1)+
	and.w	d4,(a1)+
	subq.w	#8,d3
	bmi	l000080
	move.l	d5,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi	l000080
	move.l	d5,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000080
	move.l	d5,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000080
	move.l	d5,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000080
	move.l	d5,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000080
	move.l	d5,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000080
	move.l	d5,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000080
	move.l	d5,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000080
	move.l	d5,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000080
	move.l	d5,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000080
	move.l	d5,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000080
	move.l	d5,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000080
	move.l	d5,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000080
	move.l	d5,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000080
	move.l	d5,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000080
	move.l	d5,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000080
	move.l	d5,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000080
	move.l	d5,(a1)+
	move.l	a3,(a1)+

l000080	move.w	d6,d2
	not.l	d6
	and.l	d6,(a1)+
	or.w	d2,(a1)+
	and.w	d6,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


	subq.w	#8,d3
	bpl.s	l000081
	and.l	d6,d4
	move.w	d4,d2
	not.w	d4
	or.w	d2,(a1)+
	and.w	d4,(a1)+
	or.w	d2,(a1)+
	and.w	d4,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


l000081	move.w	d4,d2
	not.w	d4
	or.w	d2,(a1)+
	and.w	d4,(a1)+
	or.w	d2,(a1)+
	and.w	d4,(a1)+
	subq.w	#8,d3
	bmi	l000082
	move.l	a3,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi	l000082
	move.l	a3,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000082
	move.l	a3,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000082
	move.l	a3,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000082
	move.l	a3,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000082
	move.l	a3,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000082
	move.l	a3,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000082
	move.l	a3,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000082
	move.l	a3,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000082
	move.l	a3,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000082
	move.l	a3,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000082
	move.l	a3,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000082
	move.l	a3,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000082
	move.l	a3,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000082
	move.l	a3,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000082
	move.l	a3,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000082
	move.l	a3,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000082
	move.l	a3,(a1)+
	move.l	a3,(a1)+

l000082	move.w	d6,d2
	not.w	d6
	or.w	d2,(a1)+
	and.w	d6,(a1)+
	or.w	d2,(a1)+
	and.w	d6,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


	subq.w	#8,d3
	bpl.s	l000083
	and.l	d6,d4
	move.l	d4,d2
	not.w	d4
	and.w	d4,(a1)+
	or.l	d2,(a1)+
	and.w	d4,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


l000083	move.l	d4,d2
	not.w	d4
	and.w	d4,(a1)+
	or.l	d2,(a1)+
	and.w	d4,(a1)+
	subq.w	#8,d3
	bmi	l000084
	move.l	d1,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi	l000084
	move.l	d1,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000084
	move.l	d1,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000084
	move.l	d1,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000084
	move.l	d1,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000084
	move.l	d1,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000084
	move.l	d1,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000084
	move.l	d1,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000084
	move.l	d1,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000084
	move.l	d1,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000084
	move.l	d1,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000084
	move.l	d1,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000084
	move.l	d1,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000084
	move.l	d1,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000084
	move.l	d1,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000084
	move.l	d1,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000084
	move.l	d1,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000084
	move.l	d1,(a1)+
	move.l	a3,(a1)+

l000084	move.l	d6,d2
	not.w	d6
	and.w	d6,(a1)+
	or.l	d2,(a1)+
	and.w	d6,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


	subq.w	#8,d3
	bpl.s	l000085
	and.l	d6,d4
	or.l	d4,(a1)+
	or.w	d4,(a1)+
	not.w	d4
	and.w	d4,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


l000085	or.l	d4,(a1)+
	or.w	d4,(a1)+
	not.w	d4
	and.w	d4,(a1)+
	subq.w	#8,d3
	bmi	l000086
	move.l	d7,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi	l000086
	move.l	d7,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000086
	move.l	d7,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000086
	move.l	d7,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000086
	move.l	d7,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000086
	move.l	d7,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000086
	move.l	d7,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000086
	move.l	d7,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000086
	move.l	d7,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000086
	move.l	d7,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000086
	move.l	d7,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000086
	move.l	d7,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000086
	move.l	d7,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000086
	move.l	d7,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000086
	move.l	d7,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000086
	move.l	d7,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000086
	move.l	d7,(a1)+
	move.l	a3,(a1)+
	subq.w	#8,d3
	bmi.s	l000086
	move.l	d7,(a1)+
	move.l	a3,(a1)+

l000086	or.l	d6,(a1)+
	or.w	d6,(a1)+
	not.w	d6
	and.w	d6,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


	subq.w	#8,d3
	bpl.s	l000087
	and.l	d6,d4
	move.w	d4,d2
	not.l	d4
	and.l	d4,(a1)+
	and.w	d4,(a1)+
	or.w	d2,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


l000087	move.w	d4,d2
	not.l	d4
	and.l	d4,(a1)+
	and.w	d4,(a1)+
	or.w	d2,(a1)+
	subq.w	#8,d3
	bmi	l000088
	move.l	d5,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi	l000088
	move.l	d5,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l000088
	move.l	d5,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l000088
	move.l	d5,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l000088
	move.l	d5,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l000088
	move.l	d5,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l000088
	move.l	d5,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l000088
	move.l	d5,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l000088
	move.l	d5,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l000088
	move.l	d5,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l000088
	move.l	d5,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l000088
	move.l	d5,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l000088
	move.l	d5,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l000088
	move.l	d5,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l000088
	move.l	d5,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l000088
	move.l	d5,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l000088
	move.l	d5,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l000088
	move.l	d5,(a1)+
	move.l	d1,(a1)+

l000088	move.w	d6,d2
	not.l	d6
	and.l	d6,(a1)+
	and.w	d6,(a1)+
	or.w	d2,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


	subq.w	#8,d3
	bpl.s	l000089
	and.l	d6,d4
	move.w	d4,d2
	not.l	d4
	or.w	d2,(a1)+
	and.l	d4,(a1)+
	or.w	d2,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


l000089	move.w	d4,d2
	not.l	d4
	or.w	d2,(a1)+
	and.l	d4,(a1)+
	or.w	d2,(a1)+
	subq.w	#8,d3
	bmi	l00008a
	move.l	a3,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi	l00008a
	move.l	a3,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008a
	move.l	a3,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008a
	move.l	a3,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008a
	move.l	a3,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008a
	move.l	a3,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008a
	move.l	a3,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008a
	move.l	a3,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008a
	move.l	a3,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008a
	move.l	a3,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008a
	move.l	a3,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008a
	move.l	a3,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008a
	move.l	a3,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008a
	move.l	a3,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008a
	move.l	a3,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008a
	move.l	a3,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008a
	move.l	a3,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008a
	move.l	a3,(a1)+
	move.l	d1,(a1)+

l00008a	move.w	d6,d2
	not.l	d6
	or.w	d2,(a1)+
	and.l	d6,(a1)+
	or.w	d2,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


	subq.w	#8,d3
	bpl.s	l00008b
	and.l	d6,d4
	move.w	d4,d2
	not.w	d4
	and.w	d4,(a1)+
	or.w	d2,(a1)+
	and.w	d4,(a1)+
	or.w	d2,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


l00008b	move.w	d4,d2
	not.w	d4
	and.w	d4,(a1)+
	or.w	d2,(a1)+
	and.w	d4,(a1)+
	or.w	d2,(a1)+
	subq.w	#8,d3
	bmi	l00008c
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi	l00008c
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008c
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008c
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008c
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008c
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008c
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008c
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008c
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008c
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008c
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008c
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008c
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008c
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008c
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008c
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008c
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008c
	move.l	d1,(a1)+
	move.l	d1,(a1)+

l00008c	move.w	d6,d2
	not.w	d6
	and.w	d6,(a1)+
	or.w	d2,(a1)+
	and.w	d6,(a1)+
	or.w	d2,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


	subq.w	#8,d3
	bpl.s	l00008d
	and.l	d6,d4
	move.l	d4,d2
	not.w	d4
	or.l	d2,(a1)+
	and.w	d4,(a1)+
	or.w	d2,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


l00008d	move.l	d4,d2
	not.w	d4
	or.l	d2,(a1)+
	and.w	d4,(a1)+
	or.w	d2,(a1)+
	subq.w	#8,d3
	bmi	l00008e
	move.l	d7,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi	l00008e
	move.l	d7,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008e
	move.l	d7,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008e
	move.l	d7,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008e
	move.l	d7,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008e
	move.l	d7,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008e
	move.l	d7,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008e
	move.l	d7,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008e
	move.l	d7,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008e
	move.l	d7,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008e
	move.l	d7,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008e
	move.l	d7,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008e
	move.l	d7,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008e
	move.l	d7,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008e
	move.l	d7,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008e
	move.l	d7,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008e
	move.l	d7,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d3
	bmi.s	l00008e
	move.l	d7,(a1)+
	move.l	d1,(a1)+

l00008e	move.l	d6,d2
	not.w	d6
	or.l	d2,(a1)+
	and.w	d6,(a1)+
	or.w	d2,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


	subq.w	#8,d3
	bpl.s	l00008f
	and.l	d6,d4
	move.l	d4,d2
	not.l	d4
	and.l	d4,(a1)+
	or.l	d2,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


l00008f	move.l	d4,d2
	not.l	d4
	and.l	d4,(a1)+
	or.l	d2,(a1)+
	subq.w	#8,d3
	bmi	l000090
	move.l	d5,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi	l000090
	move.l	d5,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000090
	move.l	d5,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000090
	move.l	d5,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000090
	move.l	d5,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000090
	move.l	d5,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000090
	move.l	d5,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000090
	move.l	d5,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000090
	move.l	d5,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000090
	move.l	d5,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000090
	move.l	d5,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000090
	move.l	d5,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000090
	move.l	d5,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000090
	move.l	d5,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000090
	move.l	d5,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000090
	move.l	d5,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000090
	move.l	d5,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000090
	move.l	d5,(a1)+
	move.l	d7,(a1)+

l000090	move.l	d6,d2
	not.l	d6
	and.l	d6,(a1)+
	or.l	d2,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


	subq.w	#8,d3
	bpl.s	l000091
	and.l	d6,d4
	move.l	d4,d2
	not.w	d4
	or.w	d2,(a1)+
	and.w	d4,(a1)+
	or.l	d2,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


l000091	move.l	d4,d2
	not.w	d4
	or.w	d2,(a1)+
	and.w	d4,(a1)+
	or.l	d2,(a1)+
	subq.w	#8,d3
	bmi	l000092
	move.l	a3,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi	l000092
	move.l	a3,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000092
	move.l	a3,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000092
	move.l	a3,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000092
	move.l	a3,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000092
	move.l	a3,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000092
	move.l	a3,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000092
	move.l	a3,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000092
	move.l	a3,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000092
	move.l	a3,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000092
	move.l	a3,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000092
	move.l	a3,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000092
	move.l	a3,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000092
	move.l	a3,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000092
	move.l	a3,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000092
	move.l	a3,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000092
	move.l	a3,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000092
	move.l	a3,(a1)+
	move.l	d7,(a1)+

l000092	move.l	d6,d2
	not.w	d6
	or.w	d2,(a1)+
	and.w	d6,(a1)+
	or.l	d2,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


	subq.w	#8,d3
	bpl.s	l000093
	and.l	d6,d4
	move.l	d4,d2
	not.w	d4
	and.w	d4,(a1)+
	or.l	d2,(a1)+
	or.w	d2,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


l000093	move.l	d4,d2
	not.l	d4
	and.w	d4,(a1)+
	or.l	d2,(a1)+
	or.w	d2,(a1)+
	subq.w	#8,d3
	bmi	l000094
	move.l	d1,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi	l000094
	move.l	d1,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000094
	move.l	d1,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000094
	move.l	d1,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000094
	move.l	d1,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000094
	move.l	d1,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000094
	move.l	d1,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000094
	move.l	d1,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000094
	move.l	d1,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000094
	move.l	d1,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000094
	move.l	d1,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000094
	move.l	d1,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000094
	move.l	d1,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000094
	move.l	d1,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000094
	move.l	d1,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000094
	move.l	d1,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000094
	move.l	d1,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000094
	move.l	d1,(a1)+
	move.l	d7,(a1)+

l000094	move.l	d6,d2
	not.w	d6
	and.w	d6,(a1)+
	or.l	d2,(a1)+
	or.w	d2,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


	subq.w	#8,d3
	bpl.s	l000095
	and.l	d6,d4
	or.l	d4,(a1)+
	or.l	d4,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


l000095	or.l	d4,(a1)+
	or.l	d4,(a1)+
	subq.w	#8,d3
	bmi	l000096
	move.l	d7,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi	l000096
	move.l	d7,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000096
	move.l	d7,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000096
	move.l	d7,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000096
	move.l	d7,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000096
	move.l	d7,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000096
	move.l	d7,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000096
	move.l	d7,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000096
	move.l	d7,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000096
	move.l	d7,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000096
	move.l	d7,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000096
	move.l	d7,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000096
	move.l	d7,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000096
	move.l	d7,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000096
	move.l	d7,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000096
	move.l	d7,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000096
	move.l	d7,(a1)+
	move.l	d7,(a1)+
	subq.w	#8,d3
	bmi.s	l000096
	move.l	d7,(a1)+
	move.l	d7,(a1)+

l000096	or.l	d6,(a1)+
	or.l	d6,(a1)+
	move.l	usp,a1
	add.w	a5,a1
	move.w	(a0)+,d2
	bpl	l000072
	move.l	(a2)+,d2
	bpl	l000070
	rts


TAB.3ff42
	dc.w	$1278,$128e,$12a6,$12c0,$12d6,$12f0,$130c,$1326
	dc.w	$133e,$1358,$1372,$138e,$13a8,$13c0,$13da,$13f4


l000098	move.w	#152,d6
	add.w	d2,d2
	move.w	TAB.3ff42(pc,d2.w),d2
	lea	TAB.3ff42(pc,d2.w),a6
	lea	TAB.416b8(pc),a1
	move.w	(a0)+,d2
	add.w	d2,d2
	move.w	(a1,d2.w),d2
	move.l	a4,a1
	add.w	d2,a1
	move.w	(a0)+,d2
	bmi	l00006f
	move.w	(a0)+,d3
	move.w	d2,d4
	and.w	d0,d4
	and.w	d0,d3
	lsl.w	#4,d4
	add.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	move.l	TAB.3ffba(pc,d4.w),d4
	lsr.w	#1,d2
	and.w	#$fff8,d2
	add.w	d2,a1
	jmp	(a6)

l000099	move.w	(a0)+,d3
	move.w	d2,d4
	and.w	d0,d4
	and.w	d0,d3
	lsl.w	#4,d4
	add.w	d3,d4
	add.w	d4,d4
	add.w	d4,d4
	move.l	TAB.3ffba(pc,d4.w),d4
	jmp	(a6)


TAB.3ffba
	dc.l	$7fffffff,$3fffffff,$1fffffff,$0fffffff
	dc.l	$07ffffff,$03ffffff,$01ffffff,$00ffffff
	dc.l	$007fffff,$003fffff,$001fffff,$000fffff
	dc.l	$0007ffff,$0003ffff,$0001ffff,$0000ffff
	dc.l	$00007fff,$00003fff,$00001fff,$00000fff
	dc.l	$000007ff,$000003ff,$000001ff,$000000ff
	dc.l	$0000007f,$0000003f,$0000001f,$0000000f
	dc.l	$00000007,$00000003,$00000001,$00000000

	dc.l	$3fffffff,$bfffffff,$9fffffff,$8fffffff
	dc.l	$87ffffff,$83ffffff,$81ffffff,$80ffffff
	dc.l	$807fffff,$803fffff,$801fffff,$800fffff
	dc.l	$8007ffff,$8003ffff,$8001ffff,$8000ffff
	dc.l	$80007fff,$80003fff,$80001fff,$80000fff
	dc.l	$800007ff,$800003ff,$800001ff,$800000ff
	dc.l	$8000007f,$8000003f,$8000001f,$8000000f
	dc.l	$80000007,$80000003,$80000001,$80000000

	dc.l	$1fffffff,$9fffffff,$dfffffff,$cfffffff
	dc.l	$c7ffffff,$c3ffffff,$c1ffffff,$c0ffffff
	dc.l	$c07fffff,$c03fffff,$c01fffff,$c00fffff
	dc.l	$c007ffff,$c003ffff,$c001ffff,$c000ffff
	dc.l	$c0007fff,$c0003fff,$c0001fff,$c0000fff
	dc.l	$c00007ff,$c00003ff,$c00001ff,$c00000ff
	dc.l	$c000007f,$c000003f,$c000001f,$c000000f
	dc.l	$c0000007,$c0000003,$c0000001,$c0000000

	dc.l	$0fffffff,$8fffffff,$cfffffff,$efffffff
	dc.l	$e7ffffff,$e3ffffff,$e1ffffff,$e0ffffff
	dc.l	$e07fffff,$e03fffff,$e01fffff,$e00fffff
	dc.l	$e007ffff,$e003ffff,$e001ffff,$e000ffff
	dc.l	$e0007fff,$e0003fff,$e0001fff,$e0000fff
	dc.l	$e00007ff,$e00003ff,$e00001ff,$e00000ff
	dc.l	$e000007f,$e000003f,$e000001f,$e000000f
	dc.l	$e0000007,$e0000003,$e0000001,$e0000000

	dc.l	$07ffffff,$87ffffff,$c7ffffff,$e7ffffff
	dc.l	$f7ffffff,$f3ffffff,$f1ffffff,$f0ffffff
	dc.l	$f07fffff,$f03fffff,$f01fffff,$f00fffff
	dc.l	$f007ffff,$f003ffff,$f001ffff,$f000ffff
	dc.l	$f0007fff,$f0003fff,$f0001fff,$f0000fff
	dc.l	$f00007ff,$f00003ff,$f00001ff,$f00000ff
	dc.l	$f000007f,$f000003f,$f000001f,$f000000f
	dc.l	$f0000007,$f0000003,$f0000001,$f0000000

	dc.l	$03ffffff,$83ffffff,$c3ffffff,$e3ffffff
	dc.l	$f3ffffff,$fbffffff,$f9ffffff,$f8ffffff
	dc.l	$f87fffff,$f83fffff,$f81fffff,$f80fffff
	dc.l	$f807ffff,$f803ffff,$f801ffff,$f800ffff
	dc.l	$f8007fff,$f8003fff,$f8001fff,$f8000fff
	dc.l	$f80007ff,$f80003ff,$f80001ff,$f80000ff
	dc.l	$f800007f,$f800003f,$f800001f,$f800000f
	dc.l	$f8000007,$f8000003,$f8000001,$f8000000

	dc.l	$01ffffff,$81ffffff,$c1ffffff,$e1ffffff
	dc.l	$f1ffffff,$f9ffffff,$fdffffff,$fcffffff
	dc.l	$fc7fffff,$fc3fffff,$fc1fffff,$fc0fffff
	dc.l	$fc07ffff,$fc03ffff,$fc01ffff,$fc00ffff
	dc.l	$fc007fff,$fc003fff,$fc001fff,$fc000fff
	dc.l	$fc0007ff,$fc0003ff,$fc0001ff,$fc0000ff
	dc.l	$fc00007f,$fc00003f,$fc00001f,$fc00000f
	dc.l	$fc000007,$fc000003,$fc000001,$fc000000

	dc.l	$00ffffff,$80ffffff,$c0ffffff,$e0ffffff
	dc.l	$f0ffffff,$f8ffffff,$fcffffff,$feffffff
	dc.l	$fe7fffff,$fe3fffff,$fe1fffff,$fe0fffff
	dc.l	$fe07ffff,$fe03ffff,$fe01ffff,$fe00ffff
	dc.l	$fe007fff,$fe003fff,$fe001fff,$fe000fff
	dc.l	$fe0007ff,$fe0003ff,$fe0001ff,$fe0000ff
	dc.l	$fe00007f,$fe00003f,$fe00001f,$fe00000f
	dc.l	$fe000007,$fe000003,$fe000001,$fe000000

	dc.l	$007fffff,$807fffff,$c07fffff,$e07fffff
	dc.l	$f07fffff,$f87fffff,$fc7fffff,$fe7fffff
	dc.l	$ff7fffff,$ff3fffff,$ff1fffff,$ff0fffff
	dc.l	$ff07ffff,$ff03ffff,$ff01ffff,$ff00ffff
	dc.l	$ff007fff,$ff003fff,$ff001fff,$ff000fff
	dc.l	$ff0007ff,$ff0003ff,$ff0001ff,$ff0000ff
	dc.l	$ff00007f,$ff00003f,$ff00001f,$ff00000f
	dc.l	$ff000007,$ff000003,$ff000001,$ff000000

	dc.l	$003fffff,$803fffff,$c03fffff,$e03fffff
	dc.l	$f03fffff,$f83fffff,$fc3fffff,$fe3fffff
	dc.l	$ff3fffff,$ffbfffff,$ff9fffff,$ff8fffff
	dc.l	$ff87ffff,$ff83ffff,$ff81ffff,$ff80ffff
	dc.l	$ff807fff,$ff803fff,$ff801fff,$ff800fff
	dc.l	$ff8007ff,$ff8003ff,$ff8001ff,$ff8000ff
	dc.l	$ff80007f,$ff80003f,$ff80001f,$ff80000f
	dc.l	$ff800007,$ff800003,$ff800001,$ff800000

	dc.l	$001fffff,$801fffff,$c01fffff,$e01fffff
	dc.l	$f01fffff,$f81fffff,$fc1fffff,$fe1fffff
	dc.l	$ff1fffff,$ff9fffff,$ffdfffff,$ffcfffff
	dc.l	$ffc7ffff,$ffc3ffff,$ffc1ffff,$ffc0ffff
	dc.l	$ffc07fff,$ffc03fff,$ffc01fff,$ffc00fff
	dc.l	$ffc007ff,$ffc003ff,$ffc001ff,$ffc000ff
	dc.l	$ffc0007f,$ffc0003f,$ffc0001f,$ffc0000f
	dc.l	$ffc00007,$ffc00003,$ffc00001,$ffc00000

	dc.l	$000fffff,$800fffff,$c00fffff,$e00fffff
	dc.l	$f00fffff,$f80fffff,$fc0fffff,$fe0fffff
	dc.l	$ff0fffff,$ff8fffff,$ffcfffff,$ffefffff
	dc.l	$ffe7ffff,$ffe3ffff,$ffe1ffff,$ffe0ffff
	dc.l	$ffe07fff,$ffe03fff,$ffe01fff,$ffe00fff
	dc.l	$ffe007ff,$ffe003ff,$ffe001ff,$ffe000ff
	dc.l	$ffe0007f,$ffe0003f,$ffe0001f,$ffe0000f
	dc.l	$ffe00007,$ffe00003,$ffe00001,$ffe00000

	dc.l	$0007ffff,$8007ffff,$c007ffff,$e007ffff
	dc.l	$f007ffff,$f807ffff,$fc07ffff,$fe07ffff
	dc.l	$ff07ffff,$ff87ffff,$ffc7ffff,$ffe7ffff
	dc.l	$fff7ffff,$fff3ffff,$fff1ffff,$fff0ffff
	dc.l	$fff07fff,$fff03fff,$fff01fff,$fff00fff
	dc.l	$fff007ff,$fff003ff,$fff001ff,$fff000ff
	dc.l	$fff0007f,$fff0003f,$fff0001f,$fff0000f
	dc.l	$fff00007,$fff00003,$fff00001,$fff00000

	dc.l	$0003ffff,$8003ffff,$c003ffff,$e003ffff
	dc.l	$f003ffff,$f803ffff,$fc03ffff,$fe03ffff
	dc.l	$ff03ffff,$ff83ffff,$ffc3ffff,$ffe3ffff
	dc.l	$fff3ffff,$fffbffff,$fff9ffff,$fff8ffff
	dc.l	$fff87fff,$fff83fff,$fff81fff,$fff80fff
	dc.l	$fff807ff,$fff803ff,$fff801ff,$fff800ff
	dc.l	$fff8007f,$fff8003f,$fff8001f,$fff8000f
	dc.l	$fff80007,$fff80003,$fff80001,$fff80000

	dc.l	$0001ffff,$8001ffff,$c001ffff,$e001ffff
	dc.l	$f001ffff,$f801ffff,$fc01ffff,$fe01ffff
	dc.l	$ff01ffff,$ff81ffff,$ffc1ffff,$ffe1ffff
	dc.l	$fff1ffff,$fff9ffff,$fffdffff,$fffcffff
	dc.l	$fffc7fff,$fffc3fff,$fffc1fff,$fffc0fff
	dc.l	$fffc07ff,$fffc03ff,$fffc01ff,$fffc00ff
	dc.l	$fffc007f,$fffc003f,$fffc001f,$fffc000f
	dc.l	$fffc0007,$fffc0003,$fffc0001,$fffc0000

	dc.l	$0000ffff,$8000ffff,$c000ffff,$e000ffff
	dc.l	$f000ffff,$f800ffff,$fc00ffff,$fe00ffff
	dc.l	$ff00ffff,$ff80ffff,$ffc0ffff,$ffe0ffff
	dc.l	$fff0ffff,$fff8ffff,$fffcffff,$fffeffff
	dc.l	$fffe7fff,$fffe3fff,$fffe1fff,$fffe0fff
	dc.l	$fffe07ff,$fffe03ff,$fffe01ff,$fffe00ff
	dc.l	$fffe007f,$fffe003f,$fffe001f,$fffe000f
	dc.l	$fffe0007,$fffe0003,$fffe0001,$fffe0000

	dc.l	$00007fff,$80007fff,$c0007fff,$e0007fff
	dc.l	$f0007fff,$f8007fff,$fc007fff,$fe007fff
	dc.l	$ff007fff,$ff807fff,$ffc07fff,$ffe07fff
	dc.l	$fff07fff,$fff87fff,$fffc7fff,$fffe7fff
	dc.l	$ffff7fff,$ffff3fff,$ffff1fff,$ffff0fff
	dc.l	$ffff07ff,$ffff03ff,$ffff01ff,$ffff00ff
	dc.l	$ffff007f,$ffff003f,$ffff001f,$ffff000f
	dc.l	$ffff0007,$ffff0003,$ffff0001,$ffff0000

	dc.l	$00003fff,$80003fff,$c0003fff,$e0003fff
	dc.l	$f0003fff,$f8003fff,$fc003fff,$fe003fff
	dc.l	$ff003fff,$ff803fff,$ffc03fff,$ffe03fff
	dc.l	$fff03fff,$fff83fff,$fffc3fff,$fffe3fff
	dc.l	$ffff3fff,$ffffbfff,$ffff9fff,$ffff8fff
	dc.l	$ffff87ff,$ffff83ff,$ffff81ff,$ffff80ff
	dc.l	$ffff807f,$ffff803f,$ffff801f,$ffff800f
	dc.l	$ffff8007,$ffff8003,$ffff8001,$ffff8000

	dc.l	$00001fff,$80001fff,$c0001fff,$e0001fff
	dc.l	$f0001fff,$f8001fff,$fc001fff,$fe001fff
	dc.l	$ff001fff,$ff801fff,$ffc01fff,$ffe01fff
	dc.l	$fff01fff,$fff81fff,$fffc1fff,$fffe1fff
	dc.l	$ffff1fff,$ffff9fff,$ffffdfff,$ffffcfff
	dc.l	$ffffc7ff,$ffffc3ff,$ffffc1ff,$ffffc0ff
	dc.l	$ffffc07f,$ffffc03f,$ffffc01f,$ffffc00f
	dc.l	$ffffc007,$ffffc003,$ffffc001,$ffffc000

	dc.l	$00000fff,$80000fff,$c0000fff,$e0000fff
	dc.l	$f0000fff,$f8000fff,$fc000fff,$fe000fff
	dc.l	$ff000fff,$ff800fff,$ffc00fff,$ffe00fff
	dc.l	$fff00fff,$fff80fff,$fffc0fff,$fffe0fff
	dc.l	$ffff0fff,$ffff8fff,$ffffcfff,$ffffefff
	dc.l	$ffffe7ff,$ffffe3ff,$ffffe1ff,$ffffe0ff
	dc.l	$ffffe07f,$ffffe03f,$ffffe01f,$ffffe00f
	dc.l	$ffffe007,$ffffe003,$ffffe001,$ffffe000

	dc.l	$000007ff,$800007ff,$c00007ff,$e00007ff
	dc.l	$f00007ff,$f80007ff,$fc0007ff,$fe0007ff
	dc.l	$ff0007ff,$ff8007ff,$ffc007ff,$ffe007ff
	dc.l	$fff007ff,$fff807ff,$fffc07ff,$fffe07ff
	dc.l	$ffff07ff,$ffff87ff,$ffffc7ff,$ffffe7ff
	dc.l	$fffff7ff,$fffff3ff,$fffff1ff,$fffff0ff
	dc.l	$fffff07f,$fffff03f,$fffff01f,$fffff00f
	dc.l	$fffff007,$fffff003,$fffff001,$fffff000

	dc.l	$000003ff,$800003ff,$c00003ff,$e00003ff
	dc.l	$f00003ff,$f80003ff,$fc0003ff,$fe0003ff
	dc.l	$ff0003ff,$ff8003ff,$ffc003ff,$ffe003ff
	dc.l	$fff003ff,$fff803ff,$fffc03ff,$fffe03ff
	dc.l	$ffff03ff,$ffff83ff,$ffffc3ff,$ffffe3ff
	dc.l	$fffff3ff,$fffffbff,$fffff9ff,$fffff8ff
	dc.l	$fffff87f,$fffff83f,$fffff81f,$fffff80f
	dc.l	$fffff807,$fffff803,$fffff801,$fffff800

	dc.l	$000001ff,$800001ff,$c00001ff,$e00001ff
	dc.l	$f00001ff,$f80001ff,$fc0001ff,$fe0001ff
	dc.l	$ff0001ff,$ff8001ff,$ffc001ff,$ffe001ff
	dc.l	$fff001ff,$fff801ff,$fffc01ff,$fffe01ff
	dc.l	$ffff01ff,$ffff81ff,$ffffc1ff,$ffffe1ff
	dc.l	$fffff1ff,$fffff9ff,$fffffdff,$fffffcff
	dc.l	$fffffc7f,$fffffc3f,$fffffc1f,$fffffc0f
	dc.l	$fffffc07,$fffffc03,$fffffc01,$fffffc00

	dc.l	$000000ff,$800000ff,$c00000ff,$e00000ff
	dc.l	$f00000ff,$f80000ff,$fc0000ff,$fe0000ff
	dc.l	$ff0000ff,$ff8000ff,$ffc000ff,$ffe000ff
	dc.l	$fff000ff,$fff800ff,$fffc00ff,$fffe00ff
	dc.l	$ffff00ff,$ffff80ff,$ffffc0ff,$ffffe0ff
	dc.l	$fffff0ff,$fffff8ff,$fffffcff,$fffffeff
	dc.l	$fffffe7f,$fffffe3f,$fffffe1f,$fffffe0f
	dc.l	$fffffe07,$fffffe03,$fffffe01,$fffffe00

	dc.l	$0000007f,$8000007f,$c000007f,$e000007f
	dc.l	$f000007f,$f800007f,$fc00007f,$fe00007f
	dc.l	$ff00007f,$ff80007f,$ffc0007f,$ffe0007f
	dc.l	$fff0007f,$fff8007f,$fffc007f,$fffe007f
	dc.l	$ffff007f,$ffff807f,$ffffc07f,$ffffe07f
	dc.l	$fffff07f,$fffff87f,$fffffc7f,$fffffe7f
	dc.l	$ffffff7f,$ffffff3f,$ffffff1f,$ffffff0f
	dc.l	$ffffff07,$ffffff03,$ffffff01,$ffffff00

	dc.l	$0000003f,$8000003f,$c000003f,$e000003f
	dc.l	$f000003f,$f800003f,$fc00003f,$fe00003f
	dc.l	$ff00003f,$ff80003f,$ffc0003f,$ffe0003f
	dc.l	$fff0003f,$fff8003f,$fffc003f,$fffe003f
	dc.l	$ffff003f,$ffff803f,$ffffc03f,$ffffe03f
	dc.l	$fffff03f,$fffff83f,$fffffc3f,$fffffe3f
	dc.l	$ffffff3f,$ffffffbf,$ffffff9f,$ffffff8f
	dc.l	$ffffff87,$ffffff83,$ffffff81,$ffffff80

	dc.l	$0000001f,$8000001f,$c000001f,$e000001f
	dc.l	$f000001f,$f800001f,$fc00001f,$fe00001f
	dc.l	$ff00001f,$ff80001f,$ffc0001f,$ffe0001f
	dc.l	$fff0001f,$fff8001f,$fffc001f,$fffe001f
	dc.l	$ffff001f,$ffff801f,$ffffc01f,$ffffe01f
	dc.l	$fffff01f,$fffff81f,$fffffc1f,$fffffe1f
	dc.l	$ffffff1f,$ffffff9f,$ffffffdf,$ffffffcf
	dc.l	$ffffffc7,$ffffffc3,$ffffffc1,$ffffffc0

	dc.l	$0000000f,$8000000f,$c000000f,$e000000f
	dc.l	$f000000f,$f800000f,$fc00000f,$fe00000f
	dc.l	$ff00000f,$ff80000f,$ffc0000f,$ffe0000f
	dc.l	$fff0000f,$fff8000f,$fffc000f,$fffe000f
	dc.l	$ffff000f,$ffff800f,$ffffc00f,$ffffe00f
	dc.l	$fffff00f,$fffff80f,$fffffc0f,$fffffe0f
	dc.l	$ffffff0f,$ffffff8f,$ffffffcf,$ffffffef
	dc.l	$ffffffe7,$ffffffe3,$ffffffe1,$ffffffe0

	dc.l	$00000007,$80000007,$c0000007,$e0000007
	dc.l	$f0000007,$f8000007,$fc000007,$fe000007
	dc.l	$ff000007,$ff800007,$ffc00007,$ffe00007
	dc.l	$fff00007,$fff80007,$fffc0007,$fffe0007
	dc.l	$ffff0007,$ffff8007,$ffffc007,$ffffe007
	dc.l	$fffff007,$fffff807,$fffffc07,$fffffe07
	dc.l	$ffffff07,$ffffff87,$ffffffc7,$ffffffe7
	dc.l	$fffffff7,$fffffff3,$fffffff1,$fffffff0

	dc.l	$00000003,$80000003,$c0000003,$e0000003
	dc.l	$f0000003,$f8000003,$fc000003,$fe000003
	dc.l	$ff000003,$ff800003,$ffc00003,$ffe00003
	dc.l	$fff00003,$fff80003,$fffc0003,$fffe0003
	dc.l	$ffff0003,$ffff8003,$ffffc003,$ffffe003
	dc.l	$fffff003,$fffff803,$fffffc03,$fffffe03
	dc.l	$ffffff03,$ffffff83,$ffffffc3,$ffffffe3
	dc.l	$fffffff3,$fffffffb,$fffffff9,$fffffff8

	dc.l	$00000001,$80000001,$c0000001,$e0000001
	dc.l	$f0000001,$f8000001,$fc000001,$fe000001
	dc.l	$ff000001,$ff800001,$ffc00001,$ffe00001
	dc.l	$fff00001,$fff80001,$fffc0001,$fffe0001
	dc.l	$ffff0001,$ffff8001,$ffffc001,$ffffe001
	dc.l	$fffff001,$fffff801,$fffffc01,$fffffe01
	dc.l	$ffffff01,$ffffff81,$ffffffc1,$ffffffe1
	dc.l	$fffffff1,$fffffff9,$fffffffd,$fffffffc

	dc.l	$00000000,$80000000,$c0000000,$e0000000
	dc.l	$f0000000,$f8000000,$fc000000,$fe000000
	dc.l	$ff000000,$ff800000,$ffc00000,$ffe00000
	dc.l	$fff00000,$fff80000,$fffc0000,$fffe0000
	dc.l	$ffff0000,$ffff8000,$ffffc000,$ffffe000
	dc.l	$fffff000,$fffff800,$fffffc00,$fffffe00
	dc.l	$ffffff00,$ffffff80,$ffffffc0,$ffffffe0
	dc.l	$fffffff0,$fffffff8,$fffffffc,$fffffffe


TAB.40fba
	dc.w	$7fff,$3fff,$1fff,$0fff,$07ff,$03ff,$01ff,$00ff
	dc.w	$007f,$003f,$001f,$000f,$0007,$0003,$0001,$0000

	dc.w	$3fff,$bfff,$9fff,$8fff,$87ff,$83ff,$81ff,$80ff
	dc.w	$807f,$803f,$801f,$800f,$8007,$8003,$8001,$8000

	dc.w	$1fff,$9fff,$dfff,$cfff,$c7ff,$c3ff,$c1ff,$c0ff
	dc.w	$c07f,$c03f,$c01f,$c00f,$c007,$c003,$c001,$c000

	dc.w	$0fff,$8fff,$cfff,$efff,$e7ff,$e3ff,$e1ff,$e0ff
	dc.w	$e07f,$e03f,$e01f,$e00f,$e007,$e003,$e001,$e000

	dc.w	$07ff,$87ff,$c7ff,$e7ff,$f7ff,$f3ff,$f1ff,$f0ff
	dc.w	$f07f,$f03f,$f01f,$f00f,$f007,$f003,$f001,$f000

	dc.w	$03ff,$83ff,$c3ff,$e3ff,$f3ff,$fbff,$f9ff,$f8ff
	dc.w	$f87f,$f83f,$f81f,$f80f,$f807,$f803,$f801,$f800

	dc.w	$01ff,$81ff,$c1ff,$e1ff,$f1ff,$f9ff,$fdff,$fcff
	dc.w	$fc7f,$fc3f,$fc1f,$fc0f,$fc07,$fc03,$fc01,$fc00

	dc.w	$00ff,$80ff,$c0ff,$e0ff,$f0ff,$f8ff,$fcff,$feff
	dc.w	$fe7f,$fe3f,$fe1f,$fe0f,$fe07,$fe03,$fe01,$fe00

	dc.w	$007f,$807f,$c07f,$e07f,$f07f,$f87f,$fc7f,$fe7f
	dc.w	$ff7f,$ff3f,$ff1f,$ff0f,$ff07,$ff03,$ff01,$ff00

	dc.w	$003f,$803f,$c03f,$e03f,$f03f,$f83f,$fc3f,$fe3f
	dc.w	$ff3f,$ffbf,$ff9f,$ff8f,$ff87,$ff83,$ff81,$ff80

	dc.w	$001f,$801f,$c01f,$e01f,$f01f,$f81f,$fc1f,$fe1f
	dc.w	$ff1f,$ff9f,$ffdf,$ffcf,$ffc7,$ffc3,$ffc1,$ffc0

	dc.w	$000f,$800f,$c00f,$e00f,$f00f,$f80f,$fc0f,$fe0f
	dc.w	$ff0f,$ff8f,$ffcf,$ffef,$ffe7,$ffe3,$ffe1,$ffe0

	dc.w	$0007,$8007,$c007,$e007,$f007,$f807,$fc07,$fe07
	dc.w	$ff07,$ff87,$ffc7,$ffe7,$fff7,$fff3,$fff1,$fff0

	dc.w	$0003,$8003,$c003,$e003,$f003,$f803,$fc03,$fe03
	dc.w	$ff03,$ff83,$ffc3,$ffe3,$fff3,$fffb,$fff9,$fff8

	dc.w	$0001,$8001,$c001,$e001,$f001,$f801,$fc01,$fe01
	dc.w	$ff01,$ff81,$ffc1,$ffe1,$fff1,$fff9,$fffd,$fffc

	dc.w	$0000,$8000,$c000,$e000,$f000,$f800,$fc00,$fe00
	dc.w	$ff00,$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe


	not.l	d4
	and.l	d4,(a1)+
	and.l	d4,(a1)+
	add.w	d6,a1
	move.w	(a0)+,d2
	bpl	l000099
	move.l	(a2)+,d2
	bpl	l000070
	rts


	or.w	d4,(a1)+
	not.l	d4
	and.w	d4,(a1)+
	and.l	d4,(a1)+
	add.w	d6,a1
	move.w	(a0)+,d2
	bpl	l000099
	move.l	(a2)+,d2
	bpl	l000070
	rts


	move.w	d4,d2
	not.l	d4
	and.w	d4,(a1)+
	or.w	d2,(a1)+
	and.l	d4,(a1)+
	add.w	d6,a1
	move.w	(a0)+,d2
	bpl	l000099
	move.l	(a2)+,d2
	bpl	l000070
	rts


	or.l	d4,(a1)+
	not.l	d4
	and.l	d4,(a1)+
	add.w	d6,a1
	move.w	(a0)+,d2
	bpl	l000099
	move.l	(a2)+,d2
	bpl	l000070
	rts


	move.w	d4,d2
	not.l	d4
	and.l	d4,(a1)+
	or.w	d2,(a1)+
	and.w	d4,(a1)+
	add.w	d6,a1
	move.w	(a0)+,d2
	bpl	l000099
	move.l	(a2)+,d2
	bpl	l000070
	rts


	move.w	d4,d2
	not.w	d4
	or.w	d2,(a1)+
	and.w	d4,(a1)+
	or.w	d2,(a1)+
	and.w	d4,(a1)+
	add.w	d6,a1
	move.w	(a0)+,d2
	bpl	l000099
	move.l	(a2)+,d2
	bpl	l000070
	rts


	move.l	d4,d2
	not.w	d4
	and.w	d4,(a1)+
	or.l	d2,(a1)+
	and.w	d4,(a1)+
	add.w	d6,a1
	move.w	(a0)+,d2
	bpl	l000099
	move.l	(a2)+,d2
	bpl	l000070
	rts


	or.l	d4,(a1)+
	or.w	d4,(a1)+
	not.w	d4
	and.w	d4,(a1)+
	add.w	d6,a1
	move.w	(a0)+,d2
	bpl	l000099
	move.l	(a2)+,d2
	bpl	l000070
	rts


	move.w	d4,d2
	not.l	d4
	and.l	d4,(a1)+
	and.w	d4,(a1)+
	or.w	d2,(a1)+
	add.w	d6,a1
	move.w	(a0)+,d2
	bpl	l000099
	move.l	(a2)+,d2
	bpl	l000070
	rts


	move.w	d4,d2
	not.l	d4
	or.w	d2,(a1)+
	and.l	d4,(a1)+
	or.w	d2,(a1)+
	add.w	d6,a1
	move.w	(a0)+,d2
	bpl	l000099
	move.l	(a2)+,d2
	bpl	l000070
	rts


	move.w	d4,d2
	not.w	d4
	and.w	d4,(a1)+
	or.w	d2,(a1)+
	and.w	d4,(a1)+
	or.w	d2,(a1)+
	add.w	d6,a1
	move.w	(a0)+,d2
	bpl	l000099
	move.l	(a2)+,d2
	bpl	l000070
	rts


	move.l	d4,d2
	not.w	d4
	or.l	d2,(a1)+
	and.w	d4,(a1)+
	or.w	d2,(a1)+
	add.w	d6,a1
	move.w	(a0)+,d2
	bpl	l000099
	move.l	(a2)+,d2
	bpl	l000070
	rts


	move.l	d4,d2
	not.l	d4
	and.l	d4,(a1)+
	or.l	d2,(a1)+
	add.w	d6,a1
	move.w	(a0)+,d2
	bpl	l000099
	move.l	(a2)+,d2
	bpl	l000070
	rts


	move.l	d4,d2
	not.w	d4
	or.w	d2,(a1)+
	and.w	d4,(a1)+
	or.l	d2,(a1)+
	add.w	d6,a1
	move.w	(a0)+,d2
	bpl	l000099
	move.l	(a2)+,d2
	bpl	l000070
	rts


	move.l	d4,d2
	not.w	d4
	and.w	d4,(a1)+
	or.l	d2,(a1)+
	or.w	d2,(a1)+
	add.w	d6,a1
	move.w	(a0)+,d2
	bpl	l000099
	move.l	(a2)+,d2
	bpl	l000070
	rts


	or.l	d4,(a1)+
	or.l	d4,(a1)+
	add.w	d6,a1
	move.w	(a0)+,d2
	bpl	l000099
	move.l	(a2)+,d2
	bpl	l000070
	rts


l00009c	move.l	TAB.416a8,a0
	add.w	#28684,a0
	move.l	#$33333333,(a0)
	move.l	#$33333333,4(a0)
	move.l	#$22222222,80(a0)
	move.l	#$22222222,84(a0)
	move.l	#$0,160(a0)
	move.l	#$0,164(a0)
	move.l	#$55555555,240(a0)
	move.l	#$55555555,244(a0)
	rts


l00009d	lea	TAB.415be(pc),a1
	move.w	#16,a3
	lea	TAB.416b8(pc),a5

l00009e	move.l	(a2)+,d0
	bmi.s	l00009c

l00009f	move.l	d0,a0
	move.w	(a0)+,d0
	bpl.s	l0000a0
	neg.w	d0
	and.w	#$f,d0

l0000a0	lsl.w	#3,d0
	move.l	(a1,d0.w),d7
	move.l	4(a1,d0.w),d6
	move.w	(a0)+,d1
	add.w	d1,d1
	move.l	TAB.416a8,a6
	add.w	(a5,d1.w),a6
	move.w	(a0)+,d2
	bmi.s	l00009e

l0000a1	move.w	(a0)+,d3
	move.l	a6,usp
	cmp.w	d2,d3
	bgt.s	l0000a2
	exg	d2,d3

l0000a2	moveq	#0,d5
	moveq	#$1f,d4
	sub.w	d3,d4
	add.w	d4,d4
	bset	d4,d5
	subq.l	#1,d5
	move.w	d2,d4
	and.w	#$f,d4
	sub.w	d4,d2
	add.w	d4,d4
	add.w	d4,d4
	move.l	TAB.4146e(pc,d4.w),d4
	sub.w	d2,d3
	lsr.w	#2,d2
	add.w	d2,a6
	lea	80(a6),a4
	sub.w	a3,d3
	bpl	l0000a4
	or.l	d4,d5
	and.l	d5,(a6)
	and.l	d5,(a4)
	not.l	d5
	move.l	d5,d4
	and.l	d6,d5
	and.l	d7,d4
	or.l	d5,(a4)
	or.l	d4,(a6)
	move.l	usp,a6
	add.w	#160,a6
	move.w	(a0)+,d2
	bpl.s	l0000a1
	move.l	(a2)+,d0
	bpl	l00009f
	move.l	TAB.416a8,a0
	add.w	#28684,a0
	move.l	#$33333333,(a0)
	move.l	#$33333333,4(a0)
	move.l	#$22222222,80(a0)
	move.l	#$22222222,84(a0)
	move.l	#$0,160(a0)
	move.l	#$0,164(a0)
	move.l	#$55555555,240(a0)
	move.l	#$55555555,244(a0)
	rts


TAB.4146e
	dc.l	$00000000,$c0000000,$f0000000,$fc000000
	dc.l	$ff000000,$ffc00000,$fff00000,$fffc0000
	dc.l	$ffff0000,$ffffc000,$fffff000,$fffffc00
	dc.l	$ffffff00,$ffffffc0,$fffffff0,$fffffffc


l0000a4	and.l	d4,(a6)
	and.l	d4,(a4)
	not.l	d4
	move.l	d4,d1
	and.l	d7,d4
	and.l	d6,d1
	or.l	d4,(a6)+
	or.l	d1,(a4)+
	sub.w	a3,d3
	bmi	l0000a5
	move.l	d6,(a4)+
	move.l	d7,(a6)+
	sub.w	a3,d3
	bmi	l0000a5
	move.l	d6,(a4)+
	move.l	d7,(a6)+
	sub.w	a3,d3
	bmi.s	l0000a5
	move.l	d6,(a4)+
	move.l	d7,(a6)+
	sub.w	a3,d3
	bmi.s	l0000a5
	move.l	d6,(a4)+
	move.l	d7,(a6)+
	sub.w	a3,d3
	bmi.s	l0000a5
	move.l	d6,(a4)+
	move.l	d7,(a6)+
	sub.w	a3,d3
	bmi.s	l0000a5
	move.l	d6,(a4)+
	move.l	d7,(a6)+
	sub.w	a3,d3
	bmi.s	l0000a5
	move.l	d6,(a4)+
	move.l	d7,(a6)+
	sub.w	a3,d3
	bmi.s	l0000a5
	move.l	d6,(a4)+
	move.l	d7,(a6)+
	sub.w	a3,d3
	bmi.s	l0000a5
	move.l	d6,(a4)+
	move.l	d7,(a6)+
	sub.w	a3,d3
	bmi.s	l0000a5
	move.l	d6,(a4)+
	move.l	d7,(a6)+
	sub.w	a3,d3
	bmi.s	l0000a5
	move.l	d6,(a4)+
	move.l	d7,(a6)+
	sub.w	a3,d3
	bmi.s	l0000a5
	move.l	d6,(a4)+
	move.l	d7,(a6)+
	sub.w	a3,d3
	bmi.s	l0000a5
	move.l	d6,(a4)+
	move.l	d7,(a6)+
	sub.w	a3,d3
	bmi.s	l0000a5
	move.l	d6,(a4)+
	move.l	d7,(a6)+
	sub.w	a3,d3
	bmi.s	l0000a5
	move.l	d6,(a4)+
	move.l	d7,(a6)+
	sub.w	a3,d3
	bmi.s	l0000a5
	move.l	d6,(a4)+
	move.l	d7,(a6)+
	sub.w	a3,d3
	bmi.s	l0000a5
	move.l	d6,(a4)+
	move.l	d7,(a6)+
	sub.w	a3,d3
	bmi.s	l0000a5
	move.l	d6,(a4)+
	move.l	d7,(a6)+

l0000a5	and.l	d5,(a6)
	and.l	d5,(a4)
	not.l	d5
	move.l	d5,d1
	and.l	d7,d5
	and.l	d6,d1
	or.l	d5,(a6)+
	or.l	d1,(a4)+
	move.l	usp,a6
	add.w	#160,a6
	move.w	(a0)+,d2
	bpl	l0000a1
	move.l	(a2)+,d0
	bpl	l00009f
	move.l	TAB.416a8,a0
	add.w	#28684,a0
	move.l	#$33333333,(a0)
	move.l	#$33333333,4(a0)
	move.l	#$22222222,80(a0)
	move.l	#$22222222,84(a0)
	move.l	#$0,160(a0)
	move.l	#$0,164(a0)
	move.l	#$55555555,240(a0)
	move.l	#$55555555,244(a0)
	rts


TAB.415be
	dc.l	$00000000,$00000000,$55555555,$ffffffff
	dc.l	$ffffffff,$aaaaaaaa,$ffffffff,$ffffffff
	dc.l	$00000000,$aaaaaaaa,$ffffffff,$00000000
	dc.l	$55555555,$55555555,$55555555,$00000000
	dc.l	$aaaaaaaa,$ffffffff,$ffffffff,$55555555
	dc.l	$55555555,$aaaaaaaa,$00000000,$55555555
	dc.l	$aaaaaaaa,$00000000,$00000000,$ffffffff
	dc.l	$aaaaaaaa,$55555555,$ffffffff,$ffffffff


l0000a7	move.l	4(sp),a0
	move.l	8(sp),a1

l0000a8	cmp.l	a1,a0
	bgt.s	l0000ac
	move.l	(a1),a5
	move.w	(a5),d0
	move.l	a0,a6
	move.l	a1,a3

l0000a9	move.l	(a6)+,a5
	cmp.w	(a5),d0
	bcs.s	l0000a9
	sub.l	#$4,a6

l0000aa	move.l	-(a3),a5
	cmp.w	(a5),d0
	bhi.s	l0000aa
	cmp.l	a3,a6
	bgt.s	l0000ab
	move.l	(a6),d1
	move.l	(a3),(a6)
	move.l	d1,(a3)
	bra.s	l0000a9

l0000ab	move.l	(a6),d1
	move.l	(a1),(a6)
	move.l	d1,(a1)
	move.l	a1,-(sp)
	pea.l	4(a6)
	lea	-4(a6),a1
	bsr	l0000a8
	bsr	l0000a7
	add.l	#8,sp
l0000ac	rts


TAB.41690
	dc.w	$00ca,$00cc,$006c,$006f,$0000,$0000,$0000,$0000,$0000,$0000

	dc.b	0
B.416a5	dc.b	0,0,8


TAB.416a8
	dc.l	$00070000,$0007a000,$0007c000,$0007e000


TAB.416b8
	dc.w	$0000,$0028,$0050,$0078,$00a0,$00c8,$00f0,$0118
	dc.w	$0140,$0168,$0190,$01b8,$01e0,$0208,$0230,$0258
	dc.w	$0280,$02a8,$02d0,$02f8,$0320,$0348,$0370,$0398
	dc.w	$03c0,$03e8,$0410,$0438,$0460,$0488,$04b0,$04d8
	dc.w	$0500,$0528,$0550,$0578,$05a0,$05c8,$05f0,$0618
	dc.w	$0640,$0668,$0690,$06b8,$06e0,$0708,$0730,$0758
	dc.w	$0780,$07a8,$07d0,$07f8,$0820,$0848,$0870,$0898
	dc.w	$08c0,$08e8,$0910,$0938,$0960,$0988,$09b0,$09d8
	dc.w	$0a00,$0a28,$0a50,$0a78,$0aa0,$0ac8,$0af0,$0b18
	dc.w	$0b40,$0b68,$0b90,$0bb8,$0be0,$0c08,$0c30,$0c58
	dc.w	$0c80,$0ca8,$0cd0,$0cf8,$0d20,$0d48,$0d70,$0d98
	dc.w	$0dc0,$0de8,$0e10,$0e38,$0e60,$0e88,$0eb0,$0ed8
	dc.w	$0f00,$0f28,$0f50,$0f78,$0fa0,$0fc8,$0ff0,$1018
	dc.w	$1040,$1068,$1090,$10b8,$10e0,$1108,$1130,$1158
	dc.w	$1180,$11a8,$11d0,$11f8,$1220,$1248,$1270,$1298
	dc.w	$12c0,$12e8,$1310,$1338,$1360,$1388,$13b0,$13d8
	dc.w	$1400,$1428,$1450,$1478,$14a0,$14c8,$14f0,$1518
	dc.w	$1540,$1568,$1590,$15b8,$15e0,$1608,$1630,$1658
	dc.w	$1680,$16a8,$16d0,$16f8,$1720,$1748,$1770,$1798
	dc.w	$17c0,$17e8,$1810,$1838,$1860,$1888,$18b0,$18d8
	dc.w	$1900,$1928,$1950,$1978,$19a0,$19c8,$19f0,$1a18
	dc.w	$1a40,$1a68,$1a90,$1ab8,$1ae0,$1b08,$1b30,$1b58
	dc.w	$1b80,$1ba8,$1bd0,$1bf8,$1c20,$1c48,$1c70,$1c98
	dc.w	$1cc0,$1ce8,$1d10,$1d38,$1d60,$1d88,$1db0,$1dd8
	dc.w	$1e00,$1e28,$1e50,$1e78,$1ea0,$1ec8,$1ef0,$1f18


DAT.41848	ds.w	500


;""""""""""""""""""""""
;" HARDWARE REGISTERS "
;"		      "
;""""""""""""""""""""""

dmaconr	equ	$002
vposr	equ	$004
vhposr	equ	$006
joy0dat	equ	$00a
joy1dat	equ	$00c
clxdat	equ	$00e
adkconr	equ	$010
pot0dat	equ	$012
pot1dat	equ	$014
potgor	equ	$016
serdatr	equ	$018
dskbytr	equ	$01a
intenar	equ	$01c
intreqr	equ	$01e
dskpth	equ	$020
dsklen	equ	$024
copcon	equ	$02e
serdat	equ	$030
serper	equ	$032
potgo	equ	$034
joytest	equ	$036
bltcon0	equ	$040
bltcon1	equ	$042
bltafwm	equ	$044
bltalwm	equ	$046
bltcpth	equ	$048
bltbpth	equ	$04c
bltapth	equ	$050
bltdpth	equ	$054
bltsize	equ	$058
bltcmod	equ	$060
bltbmod	equ	$062
bltamod	equ	$064
bltdmod	equ	$066
bltcdat	equ	$070
bltbdat	equ	$072
bltadat	equ	$074
dsksync	equ	$07e
cop1lch	equ	$080
cop2lch	equ	$084
copjmp1	equ	$088
copjmp2	equ	$08a
diwstrt	equ	$08e
diwstop	equ	$090
ddfstrt	equ	$092
ddfstop	equ	$094
dmacon	equ	$096
clxcon	equ	$098
intena	equ	$09a
intreq	equ	$09c
adkcon	equ	$09e
aud0vol	equ	$0a8
aud1vol	equ	$0b8
aud2vol	equ	$0c8
aud3vol	equ	$0d8
bpl1pth	equ	$0e0
bpl1ptl	equ	$0e2
bpl2pth	equ	$0e4
bpl2ptl	equ	$0e6
bpl3pth	equ	$0e8
bpl3ptl	equ	$0ea
bpl4pth	equ	$0ec
bpl4ptl	equ	$0ee
bpl5pth	equ	$0f0
bpl5ptl	equ	$0f2
bpl6pth	equ	$0f4
bpl6ptl	equ	$0f6
bplcon0	equ	$100
bplcon1	equ	$102
bplcon2	equ	$104
bpl1mod	equ	$108
bpl2mod	equ	$10a
spr0pth	equ	$120
spr0ptl	equ	$122
spr1pth	equ	$124
spr1ptl	equ	$126
spr2pth	equ	$128
spr2ptl	equ	$12a
spr3pth	equ	$12c
spr3ptl	equ	$12e
spr4pth	equ	$130
spr4ptl	equ	$132
spr5pth	equ	$134
spr5ptl	equ	$136
spr6pth	equ	$138
spr6ptl	equ	$13a
spr7pth	equ	$13c
spr7ptl	equ	$13e
spr0pos	equ	$140
spr1pos	equ	$148
spr2pos	equ	$150
spr3pos	equ	$158
spr4pos	equ	$160
spr5pos	equ	$168
spr6pos	equ	$170
spr7pos	equ	$178
spr0ctl	equ	$142
spr1ctl	equ	$14a
spr2ctl	equ	$152
spr3ctl	equ	$15a
spr4ctl	equ	$162
spr5ctl	equ	$16a
spr6ctl	equ	$172
spr7ctl	equ	$17a
spr0data equ	$144
spr1data equ	$14c
spr2data equ	$154
spr3data equ	$15c
spr4data equ	$164
spr5data equ	$16c
spr6data equ	$174
spr7data equ	$17c
spr0datb equ	$146
spr1datb equ	$14e
spr2datb equ	$156
spr3datb equ	$15e
spr4datb equ	$166
spr5datb equ	$16e
spr6datb equ	$176
spr7datb equ	$17e
color0	equ	$180
color1	equ	$182
color2	equ	$184
color4	equ	$188
color8	equ	$190
color16	equ	$1a0

