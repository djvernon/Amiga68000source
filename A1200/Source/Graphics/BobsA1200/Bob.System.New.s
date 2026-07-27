	section Code,Code_c

	opt	c-

	include DH0:Devpac/Equates.gs


WaitBlit	macro
\@	btst	#6,dmaconr(a6)
	bne.s	\@
	endm

	bsr	make.copper.lists
	bsr	calc.y.tab

	move.l	4.w,a6
	jsr	-132(a6)		turn off multitasking

	lea	$dff000,a6
	move.w	intenar(a6),ints	save system interrupt status
	move.w	#$3fef,intena(a6)
	move.w	#$c010,intena(a6)	enable copper interrupt

vpwait	move.l	vposr(a6),d0		get vertical beam position
	and.l	#$1ff00,d0
	lsr.l	#8,d0
	cmp.w	#312,d0			wait for bottom line
	bne.s	vpwait			before disabling sprite DMA

	move.w	#$07ff,dmacon(a6)	DMA off

	move.l	$14.w,olddbz		division-by-zero exception handler
	move.l	#rteins,$14.w		set to rte instruction

*
* SETUP COLOURS
*
	lea	coltab(pc),a0		initialise colours
	lea	$dff180,a1
	moveq	#8-1,d0
nextcol	move.l	(a0)+,(a1)+
	dbra	d0,nextcol

*
* SET SCREEN SIZE ETC
*
	move.w	#$4200,bplcon0(a6)	initialise screen
	move.w	#$2c81,diwstrt(a6)
	move.w	#$f4c1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$b0,ddfstop(a6)
	move.w	#0,bplcon1(a6)
	move.w	#0,bplcon2(a6)
	move.w	#40*3,bpl1mod(a6)
	move.w	#40*3,bpl2mod(a6)
	move.w	#3,$1fc(a6)

*
* SET THE NEW COPPER LOCATION
*
	move.l	4.w,a6
	lea	grafname(pc),a1
	moveq	#0,d0
	jsr	-552(a6)		openlibrary
	tst.l	d0
	beq	end
	move.l	d0,gfxbase
	move.l	d0,a6
	jsr	-456(a6)		ownblitter

	move.l	gfxbase(pc),a1
	move.l	38(a1),oldcopper

	lea	$dff000,a6
	move.l	#copper.list.2,cop1lch(a6)
	move.w	d0,copjmp1(a6)
	move.w	#$87c0,dmacon(a6)	DMA on (bitplane, copper, blitter)



*
* INITIALISE LEVEL 3 INTERRUPT
*

	move.l	$6c.w,old
	move.l	#level3,$6c.w


*****************************************
*		MAIN LOOP		*
*****************************************

	bsr	Is.this.your.first.time.screen1
	bsr	Is.this.your.first.time.screen2
loop
	clr.w	nextframe
wait	tst.w	nextframe
	beq.s	wait

	move.w	#$000,color0(a6)
	bsr	Restore.All.Screen

	bsr	Move.Bobs

	bsr	Save.All.Screen

	bsr	Blit.Bobs

	bsr	Double.Buffer
	move.w	#$00f,color0(a6)

	btst	#6,$bfe001
	bne.s	loop

*
* EXIT ROUTINE
*

	WaitBlit

	move.l	old(pc),$6c.w

	move.l	oldcopper(pc),cop1lch(a6)

	move.w	#$8030,dmacon(a6)	DMA on (sprite, disk)
	move.w	ints(pc),d0
	ori.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status

	move.l	olddbz(pc),$14.w   restore division-by-zero exception handler

	move.l	gfxbase(pc),a6
	jsr	-462(a6)		disownblitter
	move.l	gfxbase(pc),a1
	move.l	4.w,a6
	jsr	-414(a6)		closelibrary

end	move.l	4.w,a6
	jsr	-138(a6)		turn on multitasking

	moveq	#0,d0
	rts



*********************
* LEVEL 3 INTERRUPT *
*********************


level3	move.w	#$10,intreq(a6)
	move.w	#1,nextframe
rteins	rte



*********************
*
* BOB MOVEMENT UPDATE
*

Move.Bobs
	lea	Bob.Movement.Table(pc),a0
	lea	Bob.Data.Table(pc),a1
	move.w	#Number.Of.Bobs-1,d7

Next.Move
	tst.w	(a1)
	beq.s	Update.Pointers

	tst.w	(a0)
	blt.s	Left.Movement
	beq.s	Do.Up
Right.Movement
	move.w	(a0),d6
	add.w	d6,XCoord(a1)
	cmp.w	#319-32,XCoord(a1)
	blt.s	Do.Up
	neg.w	(a0)
	bra.s	Do.Up

Left.Movement
	move.w	(a0),d6
	add.w	d6,XCoord(a1)
	cmp.w	#0,XCoord(a1)
	bgt.s	Do.Up
	neg.w	(a0)

Do.Up
	tst.w	2(a0)
	bgt.s	Down.Movement
	beq.s	Update.Pointers
Up.Movement
	move.w	2(a0),d6
	add.w	d6,YCoord(a1)
	cmp.w	#0,YCoord(a1)
	bgt.s	Update.Pointers
	neg.w	2(a0)
	bra.s	Update.Pointers

Down.Movement
	move.w	2(a0),d6
	add.w	d6,YCoord(a1)
	cmp.w	#199-32,YCoord(a1)
	blt.s	Update.Pointers
	neg.w	2(a0)

Update.Pointers
	addq.w	#4,a0
	add.w	#Size,a1
	dbra	d7,Next.Move
	rts


***********************************
*
* SAVE ALL GRAPHICS UNDERNEATH BOBS
*

	cnop	0,4

Save.All.Screen
	move.l	Screen2(pc),a5
	move.l	-4(a5),a4		Save Area Table

	lea	Bob.Data.Table(pc),a2
	lea	Y.Table(pc),a3

	moveq	#Number.Of.Bobs-1,d7
	moveq	#Size,d6
	move.w	#4*32*64+3,d4
	moveq	#-1,d1

	WaitBlit

	move.l	d1,bltafwm(a6)
	move.w	#0,bltdmod(a6)
	move.w	#40-6,bltamod(a6)
	move.l	#$9f00000,bltcon0(a6)

Next.Save
	move.l	XCoord(a2),d0
	move.w	d0,d1
	swap	d0
	lsr.w	#3,d0
	add.w	(a3,d1.w*2),d0
	lea	(a5,d0.w),a0

	move.l	(a4)+,d1
	move.l	a0,(a4)+

	WaitBlit

	move.l	a0,bltapth(a6)
	move.l	d1,bltdpth(a6)
	move.w	d4,bltsize(a6)

	add.w	d6,a2
	dbra	d7,Next.Save

	rts


*******************************************

Is.this.your.first.time.screen1

	move.l	screen1(pc),a5
	bra	Start.It

Is.this.your.first.time.screen2

	move.l	screen2(pc),a5

Start.It
	move.l	-4(a5),a4		Save Area Table
	moveq	#Size,d6

	WaitBlit

	moveq	#-1,d1
	move.l	d1,bltafwm(a6)
	move.w	#0,bltdmod(a6)
	move.w	#40-6,bltamod(a6)
	move.l	#$9f00000,bltcon0(a6)

	lea	Bob.Data.Table(pc),a2
	lea	Y.Table(pc),a3

	moveq	#Number.Of.Bobs-1,d7

Next.Save3
	WaitBlit

	move.w	XCoord(a2),d0
	move.w	YCoord(a2),d1
	lsr.w	#3,d0
	add.w	d1,d1
	add.w	(a3,d1.w),d0

	move.l	a5,a0
	add.w	d0,a0

	move.l	(a4)+,a1
	move.l	a0,(a4)+

	move.l	a0,bltapth(a6)
	move.l	a1,bltdpth(a6)
	move.w	#4*32*64+3,bltsize(a6)		bltsize

	add.w	d6,a2
	dbra	d7,Next.Save3

	rts


**************************************
*
* RESTORE ALL GRAPHICS UNDERNEATH BOBS
*

	cnop	0,4

Restore.All.Screen
	move.l	Screen2(pc),a5
	move.l	-4(a5),a4		Save Area Table

	lea	Bob.Data.Table(pc),a2

	moveq	#Number.Of.Bobs-1,d7
	moveq	#Size,d6
	move.w	#4*32*64+3,d4
	moveq	#-1,d1

	WaitBlit

	move.l	d1,bltafwm(a6)
	move.w	#0,bltamod(a6)
	move.w	#40-6,bltdmod(a6)
	move.l	#$9f00000,bltcon0(a6)

Next.Restore
	move.l	(a4)+,d2
	move.l	(a4)+,d3

	WaitBlit

	move.l	d2,bltapth(a6)
	move.l	d3,bltdpth(a6)
	move.w	d4,bltsize(a6)

	add.w	d6,a2
	dbra	d7,Next.Restore
	
	rts


***************************************
*
* ROUTINE TO BLIT ALL BOBS IN THE TABLE
*
*


	cnop	0,4

Blit.Bobs
	move.l	Screen2(pc),a5

	lea	Bob.Data.Table(pc),a3
	lea	Y.Table(pc),a2

	moveq	#Number.Of.Bobs-1,d7
	moveq	#Size,d6
	move.w	#4*32*64+3,d4
	move.w	#$fca,d2

	WaitBlit

	move.l	#$ffff0000,bltafwm(a6)	mask off last word
	moveq	#40-6,d0
	move.w	d0,bltamod(a6)
	move.w	d0,bltbmod(a6)
	move.w	d0,bltcmod(a6)
	move.w	d0,bltdmod(a6)

Next.Bob.From.List
	tst.w	(a3)
	beq.s	Skip.This.Bob

	move.l	XCoord(a3),d0
	move.w	d0,d1
	swap	d0
	moveq	#$f,d5
	and.w	d0,d5
	lsr.w	#3,d0
	add.w	(a2,d1.w*2),d0
	lea	(a5,d0.w),a0

	ror.w	#4,d5

	WaitBlit

	move.w	d5,bltcon1(a6)
	or.w	d2,d5			(a and b) or ((not a) and c)
	move.w	d5,bltcon0(a6)		Use A,B,C,D ; LFx : D = A.B + a.C

	move.l	Mask(a3),bltapth(a6)		bob mask
	move.l	Graphic(a3),bltbpth(a6)		bob data
	move.l	a0,bltcpth(a6)		screen -- source
	move.l	a0,bltdpth(a6)		screen -- destination
	move.w	d4,bltsize(a6)

Skip.This.Bob
	add.w	d6,a3
	dbra	d7,Next.Bob.From.List

	rts


****************************************


calc.y.tab
	move.w	#200-1,d0
	moveq	#0,d1
	move.w	#40*4,d2
	lea	y.table(pc),a0

.loop	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,.loop
	rts


****************************************


	include	Print.s
	include	Decimal.s
	include	Frames.s


Double.Buffer
	move.l	screen2(pc),a0
	move.l	screen1(pc),screen2
	move.l	a0,screen1

	move.l	-8(a0),cop1lch(a6)	set new copper list address
	rts


*
* MAKE COPPERLISTS
*

make.copper.lists
	move.l	screen1(pc),d0
	lea	copper.list.1(pc),a0
	bsr	init.copper

	move.l	screen2(pc),d0
	lea	copper.list.2(pc),a0

init.copper
	moveq	#4-1,d1
next.plane
	move.w	d0,6(a0)		save low word
	swap	d0
	move.w	d0,2(a0)		save high word
	swap	d0
	addi.l	#40,d0			next bitplane
	addq.w	#8,a0			update pointer to copper list
	dbra	d1,next.plane
	rts




;""""""""""""""""""""""""""""""""""""""""
;	" THE COPPER LIST "
;	"                 "
;	"""""""""""""""""""

copper.list.1
	dc.w	bpl1pth			4 bitplane display
	dc.w	0,bpl1ptl
	dc.w	0,bpl2pth
	dc.w	0,bpl2ptl
	dc.w	0,bpl3pth
	dc.w	0,bpl3ptl
	dc.w	0,bpl4pth
	dc.w	0,bpl4ptl
	dc.w	0

;	dc.w	$fe81,$fffe
	dc.w	$fe01,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe		END


copper.list.2
	dc.w	bpl1pth			4 bitplane display
	dc.w	0,bpl1ptl
	dc.w	0,bpl2pth
	dc.w	0,bpl2ptl
	dc.w	0,bpl3pth
	dc.w	0,bpl3ptl
	dc.w	0,bpl4pth
	dc.w	0,bpl4ptl
	dc.w	0

;	dc.w	$fe81,$fffe
	dc.w	$fe01,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe		END


*************
* VARIABLES *
*************


Screen1		dc.l	Bitmap1
Screen2		dc.l	Bitmap2

olddbz		dc.l	0
oldcopper	dc.l	0
gfxbase		dc.l	0
ints		dc.w	0
old		dc.l	0
nextframe	dc.w	0


grafname	dc.b	'graphics.library',0
		even

*
* GRAPHICS DATA
*

coltab	
	dc.w	$000,$fff,$e52,$fa2,$531,$752,$973,$b94
	dc.w	$db5,$ff3,$335,$557,$779,$79b,$bbd,$eee


	rsreset
EnableFlag	rs.w	1
Graphic		rs.l	1
Mask		rs.l	1
XCoord		rs.w	1
YCoord		rs.w	1
Size		rs.w	0


Bob.Data.Table
	dc.w	-1			Negative = Show Bob
	dc.l	Graphics+8		Data
	dc.l	Graphics+160*32+8	Mask
	dc.w	190			X
	dc.w	90			Y

	dc.w	-1
	dc.l	Graphics+12
	dc.l	Graphics+160*32+12
	dc.w	180
	dc.w	40

	dc.w	-1
	dc.l	Graphics+12
	dc.l	Graphics+160*32+12
	dc.w	60
	dc.w	12

	dc.w	-1
	dc.l	Graphics+12
	dc.l	Graphics+160*32+12
	dc.w	230
	dc.w	90

	dc.w	-1
	dc.l	Graphics+12
	dc.l	Graphics+160*32+12
	dc.w	60
	dc.w	112

	dc.w	-1
	dc.l	Graphics+16
	dc.l	Graphics+160*32+16
	dc.w	18
	dc.w	44

	dc.w	-1
	dc.l	Graphics+4
	dc.l	Graphics+160*32+4
	dc.w	160
	dc.w	12

	dc.w	-1
	dc.l	Graphics+16
	dc.l	Graphics+160*32+16
	dc.w	186
	dc.w	144

	dc.w	-1
	dc.l	Graphics+36
	dc.l	Graphics+160*32+36
	dc.w	10
	dc.w	122

	dc.w	-1
	dc.l	Graphics+8
	dc.l	Graphics+160*32+8
	dc.w	170
	dc.w	90

	dc.w	-1
	dc.l	Graphics+8
	dc.l	Graphics+160*32+8
	dc.w	10
	dc.w	90

	dc.w	-1
	dc.l	Graphics+12
	dc.l	Graphics+160*32+12
	dc.w	180
	dc.w	140

	dc.w	-1
	dc.l	Graphics+12
	dc.l	Graphics+160*32+12
	dc.w	20
	dc.w	112

	dc.w	-1
	dc.l	Graphics+12
	dc.l	Graphics+160*32+12
	dc.w	10
	dc.w	90

	dc.w	-1
	dc.l	Graphics+12
	dc.l	Graphics+160*32+12
	dc.w	132
	dc.w	112

	dc.w	-1
	dc.l	Graphics+16
	dc.l	Graphics+160*32+16
	dc.w	18
	dc.w	144

	dc.w	-1
	dc.l	Graphics+4
	dc.l	Graphics+160*32+4
	dc.w	60
	dc.w	92

	dc.w	-1
	dc.l	Graphics+16
	dc.l	Graphics+160*32+16
	dc.w	86
	dc.w	44

	dc.w	-1
	dc.l	Graphics+36
	dc.l	Graphics+160*32+36
	dc.w	190
	dc.w	12

	dc.w	-1
	dc.l	Graphics+36
	dc.l	Graphics+160*32+36
	dc.w	190
	dc.w	12

	dc.w	-1
	dc.l	Graphics+36
	dc.l	Graphics+160*32+36
	dc.w	145
	dc.w	86


Number.Of.Bobs	equ	20

Bob.Movement.Table
	dc.w	2,1
	dc.w	-2,-2
	dc.w	2,-2
	dc.w	-2,2
	dc.w	1,-2
	dc.w	-2,-1
	dc.w	2,-2
	dc.w	-2,-1
	dc.w	2,-2
	dc.w	2,1
	dc.w	2,1
	dc.w	-2,-2
	dc.w	2,-2
	dc.w	-2,2
	dc.w	1,-2
	dc.w	-2,-1
	dc.w	2,-2
	dc.w	-2,-1
	dc.w	2,-2
	dc.w	1,-1
	dc.w	2,-2


y.table	ds.w	200


SaveAreaATable
	dc.l	Saved.Area1A
	dc.l	0
	dc.l	Saved.Area2A
	dc.l	0
	dc.l	Saved.Area3A
	dc.l	0
	dc.l	Saved.Area4A
	dc.l	0
	dc.l	Saved.Area5A
	dc.l	0
	dc.l	Saved.Area6A
	dc.l	0
	dc.l	Saved.Area7A
	dc.l	0
	dc.l	Saved.Area8A
	dc.l	0
	dc.l	Saved.Area9A
	dc.l	0
	dc.l	Saved.Area10A
	dc.l	0
	dc.l	Saved.Area11A
	dc.l	0
	dc.l	Saved.Area12A
	dc.l	0
	dc.l	Saved.Area13A
	dc.l	0
	dc.l	Saved.Area14A
	dc.l	0
	dc.l	Saved.Area15A
	dc.l	0
	dc.l	Saved.Area16A
	dc.l	0
	dc.l	Saved.Area17A
	dc.l	0
	dc.l	Saved.Area18A
	dc.l	0
	dc.l	Saved.Area19A
	dc.l	0
	dc.l	Saved.Area20A
	dc.l	0
	dc.l	Saved.Area21A
	dc.l	0


SaveAreaBTable
	dc.l	Saved.Area1B
	dc.l	0
	dc.l	Saved.Area2B
	dc.l	0
	dc.l	Saved.Area3B
	dc.l	0
	dc.l	Saved.Area4B
	dc.l	0
	dc.l	Saved.Area5B
	dc.l	0
	dc.l	Saved.Area6B
	dc.l	0
	dc.l	Saved.Area7B
	dc.l	0
	dc.l	Saved.Area8B
	dc.l	0
	dc.l	Saved.Area9B
	dc.l	0
	dc.l	Saved.Area10B
	dc.l	0
	dc.l	Saved.Area11B
	dc.l	0
	dc.l	Saved.Area12B
	dc.l	0
	dc.l	Saved.Area13B
	dc.l	0
	dc.l	Saved.Area14B
	dc.l	0
	dc.l	Saved.Area15B
	dc.l	0
	dc.l	Saved.Area16B
	dc.l	0
	dc.l	Saved.Area17B
	dc.l	0
	dc.l	Saved.Area18B
	dc.l	0
	dc.l	Saved.Area19B
	dc.l	0
	dc.l	Saved.Area20B
	dc.l	0
	dc.l	Saved.Area21B
	dc.l	0


Saved.Area1A	ds.b	32*6*4		32 lines * 3 words * 4 bitplanes
Saved.Area1B	ds.b	32*6*4		32 lines * 3 words * 4 bitplanes
Saved.Area2A	ds.b	32*6*4
Saved.Area2B	ds.b	32*6*4
Saved.Area3A	ds.b	32*6*4
Saved.Area3B	ds.b	32*6*4
Saved.Area4A	ds.b	32*6*4
Saved.Area4B	ds.b	32*6*4
Saved.Area5A	ds.b	32*6*4
Saved.Area5B	ds.b	32*6*4
Saved.Area6A	ds.b	32*6*4
Saved.Area6B	ds.b	32*6*4
Saved.Area7A	ds.b	32*6*4
Saved.Area7B	ds.b	32*6*4
Saved.Area8A	ds.b	32*6*4
Saved.Area8B	ds.b	32*6*4
Saved.Area9A	ds.b	32*6*4
Saved.Area9B	ds.b	32*6*4
Saved.Area10A	ds.b	32*6*4		32 lines * 3 words * 4 bitplanes
Saved.Area10B	ds.b	32*6*4		32 lines * 3 words * 4 bitplanes
Saved.Area11A	ds.b	32*6*4		32 lines * 3 words * 4 bitplanes
Saved.Area11B	ds.b	32*6*4		32 lines * 3 words * 4 bitplanes
Saved.Area12A	ds.b	32*6*4
Saved.Area12B	ds.b	32*6*4
Saved.Area13A	ds.b	32*6*4
Saved.Area13B	ds.b	32*6*4
Saved.Area14A	ds.b	32*6*4
Saved.Area14B	ds.b	32*6*4
Saved.Area15A	ds.b	32*6*4
Saved.Area15B	ds.b	32*6*4
Saved.Area16A	ds.b	32*6*4
Saved.Area16B	ds.b	32*6*4
Saved.Area17A	ds.b	32*6*4
Saved.Area17B	ds.b	32*6*4
Saved.Area18A	ds.b	32*6*4
Saved.Area18B	ds.b	32*6*4
Saved.Area19A	ds.b	32*6*4
Saved.Area19B	ds.b	32*6*4
Saved.Area20A	ds.b	32*6*4
Saved.Area20B	ds.b	32*6*4
Saved.Area21A	ds.b	32*6*4
Saved.Area21B	ds.b	32*6*4

Graphics	incbin	explosion.bin


	section	bm1,data_c

	dc.l	copper.list.1,SaveAreaATable

Bitmap1	incbin	beach.bin


	section	bm2,data_c

	dc.l	copper.list.2,SaveAreaBTable

Bitmap2	incbin	beach.bin



