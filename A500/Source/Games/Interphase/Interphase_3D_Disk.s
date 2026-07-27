	section	Interphase_3D,code_c
	opt	o+,o3-


XMAX	equ	320
YMAX	equ	200
XMID	equ	XMAX/2
YMID	equ	YMAX/2


start	bset	#1,$bfe001	low pass filter off

	move.l	4,a6
	move.l	#96000,d0	3*4*40*200
	move.l	#$10002,d1	clear chip
	jsr	-198(a6)	AllocMem
	move.l	d0,screenmem

	move.l	d0,screen1
	add.l	#32000,d0
	move.l	d0,screen2
	add.l	#32000,d0
	move.l	d0,screen3

	move.l	4,a6
	jsr	-132(a6)	turn off multitasking

	lea	$dff000,a5
	move.w	intenar(a5),ints	save system interrupt status
	move.w	#$3fdf,intena(a5)
	move.w	#$c020,intena(a5)	enable vertical blanking interrupt
	move.w	#$03ff,dmacon(a5)	DMA off

	move.l	$14,olddbz	division-by-zero exception handler
	move.l	#rteins,$14	set to rte instruction

	move.l	screen3,d0	set up bitplanes
	move.w	d0,bp1l
	swap	d0
	move.w	d0,bp1h
	swap	d0
	add.l	#40,d0

	move.w	d0,bp2l
	swap	d0
	move.w	d0,bp2h
	swap	d0
	add.l	#40,d0

	move.w	d0,bp3l
	swap	d0
	move.w	d0,bp3h
	swap	d0
	add.l	#40,d0

	move.w	d0,bp4l
	swap	d0
	move.w	d0,bp4h

	lea	coltab,a0		initialise colours
	lea	$dff180,a1
	moveq	#15,d0
nextcol	move.w	(a0)+,(a1)+
	dbra	d0,nextcol

	move.w	#$4200,bplcon0(a5)	initialise screen
	move.w	#$2c81,diwstrt(a5)
	move.w	#$f4c1,diwstop(a5)
	move.w	#$38,ddfstrt(a5)
	move.w	#$d0,ddfstop(a5)
	move.w	#0,bplcon1(a5)
	move.w	#0,bplcon2(a5)
	move.w	#120,bpl1mod(a5)
	move.w	#120,bpl2mod(a5)


;""""""""""""""""""""""""""""""""""""""""""""
;	SET THE NEW COPPER LOCATION

	move.l	4,a6
	lea	grafname(pc),a1
	moveq	#0,d0
	jsr	-552(a6)	openlibrary
	tst.l	d0
	beq	end
	move.l	d0,gfxbase
	move.l	d0,a6
	jsr	-456(a6)	ownblitter

	move.l	gfxbase,a1
	move.l	38(a1),oldcopper

	move.l	#new,cop1lc(a5)
	clr.w	copjmp1(a5)
	move.w	#$83c0,dmacon(a5)	DMA on (bitplane, copper, blitter)


;"""""""""""""""""""""
;" CALCULATE Y-TABLE "
;"		     "
;"""""""""""""""""""""

	move.l	#199,d0		count
	moveq	#0,d1		offset starts at zero
	move.w	#160,d2		bytes per line = 160
	lea	ytable,a0
ytab	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,ytab


;""""""""""""""""""""""""""""""""
;" INITIALISE LEVEL 3 INTERRUPT "
;"				"
;""""""""""""""""""""""""""""""""

	move.l	$6c,old
	move.l	#level3,$6c


;""""""""""""""""""
;" ANIMATION LOOP "
;"		  "
;""""""""""""""""""

loop	bsr	clear
	movem.w	zangle,d0-d2
	lea	dataA,a2
	bsr	sincos
	lea	shape.dat,a0	address of object data
	clr.w	flag1
	clr.b	flag3
	bsr	main
	bsr	setscreen
	tst.b	leftbn
	beq.s	loop

	move.l	old,$6c

	lea	$dff000,a5
	move.l	oldcopper,cop1lc(a5)
	clr.w	copjmp1(a5)

	move.l	olddbz,$14	restore division-by-zero exception handler

	move.l	gfxbase,a6
	jsr	-462(a6)	disownblitter
	move.l	gfxbase,a1
	move.l	4,a6
	jsr	-414(a6)	closelibrary

	move.w	#$8030,dmacon(a5)	DMA on (sprite, disk)
	move.w	ints,d0
	ori.w	#$c000,d0	set SET and INTEN bits
	move.w	d0,intena(a5)	restore system interrupt status

end	move.l	4,a6
	jsr	-138(a6)	turn on multitasking

	move.l	4,a6
	move.l	screenmem,a1
	move.l	#96000,d0	3*4*40*200
	jsr	-210(a6)	FreeMem

	bclr	#1,$bfe001	low pass filter on
	moveq	#0,d0
	rts


;"""""""""""""""""""""
;" LEVEL 3 INTERRUPT "
;"		     "
;"""""""""""""""""""""

level3	movem.l	d0-d1/a0/a5,-(sp)
	lea	$dff000,a5
	move.w	#$20,intreq(a5)

	lea	mousedat,a0
	moveq	#0,d0
	btst	#6,$bfe001	left mouse button
	bne.s	notleft
	moveq	#2,d0		left button is pressed

notleft	btst	#2,potgor(a5)	right mouse button
	bne.s	notright
	ori.w	#1,d0		right button is pressed

notright
	move.b	d0,(a0)+	save mouse button status

	move.b	$b(a5),d0	x mouse movement
	move.b	d0,-(sp)
	sub.b	oldmousex,d0
	move.b	(sp)+,oldmousex
	move.b	d0,(a0)+	save mouse x

	move.b	$a(a5),d0	y mouse movement
	move.b	d0,-(sp)
	sub.b	oldmousey,d0
	move.b	(sp)+,oldmousey
	move.b	d0,(a0)+	save mouse y

	lea	mousedat,a0
	bsr.s	getangles
	movem.l	(sp)+,d0-d1/a0/a5
rteins	rte

getangles
	clr.w	leftbn		clear left and right button flags
	btst	#1,(a0)		left button
	sne	leftbn		set if left button was pressed
	btst	#0,(a0)		right button
	sne	rightbn		set if right button was pressed
	bne.s	rightpr

	move.b	1(a0),d0	mouse x
	ext.w	d0
	add.w	d0,d0		double the movement
	add.w	d0,zangle	update z angle
	andi.w	#$7fe,zangle

	move.b	2(a0),d0	mouse y
	ext.w	d0
	add.w	d0,d0		double the movement
	add.w	d0,xangle	update x angle
	andi.w	#$7fe,xangle
	rts

rightpr	move.b	1(a0),d0	mouse x
	ext.w	d0
	add.w	d0,d0		double the movement
	add.w	d0,yangle	update y angle
	andi.w	#$7fe,yangle

	move.b	2(a0),d0	mousey
	ext.w	d0
	add.w	d0,dataD	update z distance
	rts


;""""""""""""""""""""""""""""""""""""""""
;" SUBROUTINES TO PRODUCE THE 3D OBJECT "
;"					"
;""""""""""""""""""""""""""""""""""""""""

clear	lea	$dff000,a5
clr	btst	#6,dmaconr(a5)
	bne.s	clr
	clr.w	bltdmod(a5)
	move.l	#$1000000,bltcon0(a5)	USE D
	move.l	screen1,bltdpth(a5)
	move.w	#YMAX*4*64+20,bltsize(a5)	width = 20 words
	rts


;""""""""""""""""
;" LINE ROUTINE "
;"		"
;""""""""""""""""

setline	lsl.w	#3,d0			; set colour for lines
	lea	colmasks(pc,d0.w),a5
	move.l	a5,linecol
	rts

colmasks
	dc.w	$0000,$0000,$0000,$0000
	dc.w	$ffff,$0000,$0000,$0000
	dc.w	$0000,$ffff,$0000,$0000
	dc.w	$ffff,$ffff,$0000,$0000
	dc.w	$0000,$0000,$ffff,$0000
	dc.w	$ffff,$0000,$ffff,$0000
	dc.w	$0000,$ffff,$ffff,$0000
	dc.w	$ffff,$ffff,$ffff,$0000
	dc.w	$0000,$0000,$0000,$ffff
	dc.w	$ffff,$0000,$0000,$ffff
	dc.w	$0000,$ffff,$0000,$ffff
	dc.w	$ffff,$ffff,$0000,$ffff
	dc.w	$0000,$0000,$ffff,$ffff
	dc.w	$ffff,$0000,$ffff,$ffff
	dc.w	$0000,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff


line	lea	$dff000,a5
	cmp.w	d2,d0
	bcs.s	x2gx1
	exg	d0,d2
	exg	d1,d3

x2gx1	sub.w	d0,d2
	sub.w	d1,d3
	add.w	d1,d1
	lea	ytable,a1
	move.w	(a1,d1.w),d1
	moveq	#$f,d4
	and.w	d0,d4
	sub.w	d4,d0
	lsr.w	#3,d0
	add.w	d0,d1
	move.l	screen1,a1
	add.w	d1,a1
	ror.w	#4,d4
	ori.w	#$bca,d4
	swap	d4
	tst.w	d3
	bmi.s	y1gy2
	cmp.w	d2,d3
	blt.s	dxgdy
	exg	d2,d3
	move.w	#1,d4
	bra.s	dlsize

dxgdy	move.w	#$11,d4
	bra.s	dlsize

y1gy2	neg.w	d3
	cmp.w	d2,d3
	blt.s	dxgdy2
	exg	d2,d3
	move.w	#5,d4
	bra.s	dlsize

dxgdy2	move.w	#$19,d4

dlsize	move.w	d2,d1
	addq.w	#1,d1
	lsl.w	#6,d1
	addq.w	#2,d1

	move.l	linecol,a2

	add.w	d3,d3
	move.w	d3,d0
	sub.w	d2,d0
	bpl.s	nosign
	ori.b	#$40,d4

nosign	add.w	d2,d2

bltfin	btst	#6,dmaconr(a5)
	bne.s	bltfin
	move.w	d3,bltbmod(a5)
	sub.w	d2,d3
	move.w	d3,bltamod(a5)
	move.w	#$8000,bltadat(a5)
	moveq	#-1,d3
	move.l	d3,bltafwm(a5)
	move.w	#160,d3
	move.w	d3,bltcmod(a5)
	move.w	d3,bltdmod(a5)

	moveq	#3,d2
	move.w	(a2)+,d3
	bra.s	dlstart

dlloop	lea	40(a1),a1
	move.w	(a2)+,d3

bltfin2	btst	#6,dmaconr(a5)
	bne.s	bltfin2

dlstart	move.l	a1,bltcpth(a5)
	move.l	a1,bltdpth(a5)
	move.w	d0,bltaptl(a5)
	move.l	d4,bltcon0(a5)
	move.w	d3,bltbdat(a5)
	move.w	d1,bltsize(a5)
	dbra	d2,dlloop
	rts

linecol	dc.l	0


;""""""""""""""""""""""""""""""""""""""""
;	" THE FILL ROUTINE "
;	"		   "
;	""""""""""""""""""""

fill	st	(a3)		end-of-fill marker
	lea	$dff000,a5
	lea	coords,a3
	move.l	screen1,a1
	lea	ytable,a2
	move.w	(a3)+,d1	get y-start
	add.w	d1,d1
	add.w	(a2,d1.w),a1	add y offset
	moveq	#0,d0
	move.b	colour1,d0
	cmp.b	colour2,d0
	bne	fill2
	lsr.w	#2,d0
	move.l	table(pc,d0.w),a4
	move.w	(a3)+,d2	first x-start
	bpl.s	fillit
	rts

table	dc.l	b7,b6,b15,b5,b9,b14,b11,b4
	dc.l	b8,b16,b13,b12,b1,b10,b2,b3

first	dc.w	$ffff,$7fff,$3fff,$1fff,$fff,$7ff,$3ff,$1ff
	dc.w	$ff,$7f,$3f,$1f,$f,$7,$3,$1

fillit	move.w	(a3)+,d3	next x-end
	sub.w	d2,d3
	blt.s	nextline
	moveq	#$f,d4
	and.w	d2,d4		low four bits from x start
	sub.w	d4,d2		x-start offset in multiples of 16
	lsr.w	#3,d2		x-start offset in even bytes
	lea	(a1,d2.w),a2	start of fill
	add.w	d4,d3
	add.w	d4,d4
	move.w	first(pc,d4.w),d2
	swap	d2
	moveq	#$f,d4
	and.w	d3,d4
	add.w	d4,d4
	move.w	last(pc,d4.w),d2
	lsr.w	#4,d3
	addq.w	#1,d3
	moveq	#40,d4
	sub.w	d3,d4
	sub.w	d3,d4
	or.w	#$100,d3	height = 4
bltfin3	btst	#6,dmaconr(a5)	wait until blitter ready
	bne.s	bltfin3
	move.l	d2,bltafwm(a5)		first and last word masks
	move.w	#$ffff,bltadat(a5)	mask for all planes
	move.w	d4,bltcmod(a5)
	move.w	d4,bltbmod(a5)
	move.w	d4,bltdmod(a5)
	move.l	a4,bltbpth(a5)		masks for each plane
	move.l	a2,bltcpth(a5)		start address
	move.l	a2,bltdpth(a5)		start address
	move.l	#$7ca0000,bltcon0(a5)	USE B,C,D ; LFx: $CA
	move.w	d3,bltsize(a5)
nextline
	lea	160(a1),a1	next line
	move.w	(a3)+,d2	next x-start
	bpl.s	fillit
	rts

last	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff

fill2	moveq	#0,d4
	move.b	colour2,d4
	btst	#1,d1
	beq.s	noswap
	exg	d0,d4
noswap	movem.l	masks(pc,d0.w),d2-d3
	movem.l	masks(pc,d4.w),d0-d1
	move.l	d2,d5
	move.l	d3,d6
	add.l	d5,d5
	add.l	d6,d6
	or.l	d0,d5
	or.l	d1,d6
	add.l	d0,d0
	add.l	d1,d1
	or.l	d2,d0
	or.l	d3,d1
	move.w	(a3)+,d2
	bpl	fillit2
	rts

masks	dc.w	$0000,$0000,$0000,$0000
	dc.w	$5555,$0000,$0000,$0000
	dc.w	$0000,$5555,$0000,$0000
	dc.w	$5555,$5555,$0000,$0000
	dc.w	$0000,$0000,$5555,$0000
	dc.w	$5555,$0000,$5555,$0000
	dc.w	$0000,$5555,$5555,$0000
	dc.w	$5555,$5555,$5555,$0000
	dc.w	$0000,$0000,$0000,$5555
	dc.w	$5555,$0000,$0000,$5555
	dc.w	$0000,$5555,$0000,$5555
	dc.w	$5555,$5555,$0000,$5555
	dc.w	$0000,$0000,$5555,$5555
	dc.w	$5555,$0000,$5555,$5555
	dc.w	$0000,$5555,$5555,$5555
	dc.w	$5555,$5555,$5555,$5555

first2	dc.w	$ffff,$7fff,$3fff,$1fff,$fff,$7ff,$3ff,$1ff
	dc.w	$ff,$7f,$3f,$1f,$f,$7,$3,$1

last2	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff

fillit2	move.w	(a3)+,d3	next x-end
	sub.w	d2,d3
	blt	nextline2
	moveq	#$f,d4
	and.w	d2,d4		low four bits from x start
	sub.w	d4,d2		x-start offset in multiples of 16
	lsr.w	#3,d2		x-start offset in even bytes
	lea	(a1,d2.w),a2	start of fill
	add.w	d4,d3
	add.w	d4,d4
	move.w	first2(pc,d4.w),d2
	swap	d2
	moveq	#$f,d4
	and.w	d3,d4
	add.w	d4,d4
	move.w	last2(pc,d4.w),d2
	lsr.w	#4,d3
	addq.w	#1,d3
	moveq	#40,d4
	sub.w	d3,d4
	sub.w	d3,d4
	or.w	#$40,d3		height = 1
	swap	d0
bltfin4	btst	#6,dmaconr(a5)	wait until blitter ready
	bne.s	bltfin4
	move.l	d2,bltafwm(a5)		first and last word masks
	move.w	#$ffff,bltadat(a5)	mask for all planes
	move.w	d0,bltbdat(a5)		mask for current plane
	move.w	d4,bltcmod(a5)
	move.w	d4,bltdmod(a5)
	move.l	a2,bltcpth(a5)		start address
	move.l	a2,bltdpth(a5)		start address
	move.l	#$3ca0000,bltcon0(a5)	USE C,D ; LFx: $CA
	move.w	d3,bltsize(a5)
	swap	d0
bltfin5	btst	#6,dmaconr(a5)	wait until blitter ready
	bne.s	bltfin5
	move.w	d0,bltbdat(a5)	mask for current plane
	move.w	d3,bltsize(a5)
	swap	d1
bltfin6	btst	#6,dmaconr(a5)	wait until blitter ready
	bne.s	bltfin6
	move.w	d1,bltbdat(a5)	mask for current plane
	move.w	d3,bltsize(a5)
	swap	d1
bltfin7	btst	#6,dmaconr(a5)	wait until blitter ready
	bne.s	bltfin7
	move.w	d1,bltbdat(a5)	mask for current plane
	move.w	d3,bltsize(a5)
nextline2
	lea	160(a1),a1
	exg	d0,d5
	exg	d1,d6
	move.w	(a3)+,d2
	bpl	fillit2
	rts

ytable	ds.w	200

coords	ds.w	402	ystart + max. 200 coord pairs + word for end marker

b1	dcb.w	20,0
b2	dcb.w	20,0
b3	dcb.w	20,$ffff
b4	dcb.w	20,$ffff
b5	dcb.w	20,$ffff
b6	dcb.w	20,$ffff
b7	dcb.w	20,0
b8	dcb.w	20,0
b9	dcb.w	20,0
	dcb.w	20,0
b10	dcb.w	20,$ffff
b11	dcb.w	20,0
b12	dcb.w	20,$ffff
	dcb.w	20,$ffff
b13	dcb.w	20,0
b14	dcb.w	20,$ffff
b15	dcb.w	20,0
b16	dcb.w	20,$ffff
	dcb.w	20,0
	dcb.w	20,0
	dcb.w	20,$ffff


mn1	move.b	flag2(pc),d0		start of main 3d program
	bne	main
	rts

mn2	movem.l	dataC(pc),d0-d2
	movem.l	d0-d2,-(a7)
	movem.w	(a0)+,d0-d2
	lea	dataA(pc),a2
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5
	muls	(a2)+,d0
	muls	(a2)+,d4
	muls	(a2)+,d5
	add.l	d4,d0
	add.l	d5,d0
	move.w	d3,d6
	move.w	d1,d4
	move.w	d2,d5
	muls	(a2)+,d3
	muls	(a2)+,d1
	muls	(a2)+,d5
	add.l	d3,d1
	add.l	d5,d1
	muls	(a2)+,d6
	muls	(a2)+,d4
	muls	(a2)+,d2
	add.l	d6,d2
	add.l	d4,d2
	add.l	(a2)+,d0
	add.l	(a2)+,d1
	add.l	(a2)+,d2
	movem.l	d0-d2,dataC
	pea	2(a0)
	add.w	(a0),a0
	bsr	main
	move.l	(a7)+,a0
	movem.l	(a7)+,d0-d2
	movem.l	d0-d2,dataC
	bra	main

mn3	movem.l	dataC(pc),d0-d2
	movem.l	d0-d2,-(a7)
	move.w	(a0)+,d0
	lea	dataE(pc),a6
	movem.w	-4(a6,d0.w),d0-d2
	swap	d0
	swap	d1
	swap	d2
	clr.w	d0
	clr.w	d1
	clr.w	d2
	movem.l	d0-d2,dataC
	pea	2(a0)
	add.w	(a0),a0
	bsr	main
	move.l	(a7)+,a0
	movem.l	(a7)+,d0-d2
	movem.l	d0-d2,dataC
	bra	main

mn4	movem.w	(a0)+,d0-d2
	lea	data1(pc),a2
	bsr	sincos
	lea	dataA(pc),a2
	moveq	#2,d7
mn5	movem.w	(a2),d0-d2
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5
	muls	data1(pc),d3
	muls	data2(pc),d4
	muls	data3(pc),d5
	add.l	d4,d3
	add.l	d5,d3
	add.l	d3,d3
	swap	d3
	move.w	d3,(a2)+
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5
	muls	data4(pc),d3
	muls	data5(pc),d4
	muls	data6(pc),d5
	add.l	d4,d3
	add.l	d5,d3
	add.l	d3,d3
	swap	d3
	move.w	d3,(a2)+
	muls	data7(pc),d0
	muls	data8(pc),d1
	muls	data9(pc),d2
	add.l	d1,d0
	add.l	d2,d0
	add.l	d0,d0
	swap	d0
	move.w	d0,(a2)+
	dbf	d7,mn5
	bra	main

mn6	move.l	(a0)+,a1		; Not used
	jsr	(a1)
	bra	main

mn7	lea	dataE(pc),a6
	movem.w	(a0)+,d0-d2/a2
	movem.w	-4(a6,d0.w),d0/d3-d4
	movem.w	-4(a6,d2.w),d2/d5-d6
	sub.w	-4(a6,d1.w),d0
	sub.w	-4(a6,d1.w),d2
	sub.w	-2(a6,d1.w),d3
	sub.w	-2(a6,d1.w),d5
	sub.w	(a6,d1.w),d4
	sub.w	(a6,d1.w),d6
	move.w	d3,d7
	muls	d2,d7
	move.l	d7,a3
	move.w	d0,d7
	muls	d5,d7
	sub.l	a3,d7
	asr.l	#8,d7
	muls	(a6,d1.w),d7
	muls	d6,d0
	muls	d4,d2
	sub.l	d0,d2
	asr.l	#8,d2
	muls	-2(a6,d1.w),d2
	add.l	d2,d7
	muls	d6,d3
	muls	d4,d5
	sub.l	d5,d3
	asr.l	#8,d3
	muls	-4(a6,d1.w),d3
	add.l	d3,d7
	bmi	main
	add.w	a2,a0
	bra	main

mn8	lea	dataE(pc),a6		; Not used
	movem.w	(a0)+,d0-d1/d6/a2
	movem.w	-4(a6,d1.w),d3-d5
	movem.w	-4(a6,d0.w),d0-d2
	sub.w	d3,d0
	sub.w	d4,d1
	sub.w	d5,d2
	movem.w	-4(a6,d6.w),d3-d5
	muls	d3,d0
	muls	d4,d1
	muls	d5,d2
	add.l	d1,d0
	add.l	d2,d0
	bmi	main
	add.w	a2,a0
	bra	main

mn9	move.b	flag1(pc),d0
	beq	mn16
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	bsr	mn33
	bra	main

mnA	lea	dataE(pc),a2		; Not used
	bra.s	mnC

mnB	lea	dataA(pc),a2
mnC	move.w	(a0)+,d7
	lea	dataE(pc),a6
	add.w	(a0)+,a6
mnD	movem.w	(a0)+,d0-d2
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5
	muls	(a2)+,d0
	muls	(a2)+,d4
	muls	(a2)+,d5
	add.l	d4,d0
	add.l	d5,d0
	move.w	d3,d6
	move.w	d1,d4
	move.w	d2,d5
	muls	(a2)+,d3
	muls	(a2)+,d1
	muls	(a2)+,d5
	add.l	d3,d1
	add.l	d5,d1
	muls	(a2)+,d6
	muls	(a2)+,d4
	muls	(a2)+,d2
	add.l	d6,d2
	add.l	d4,d2
	add.l	(a2)+,d0
	add.l	(a2)+,d1
	add.l	(a2)+,d2
	lea	-30(a2),a2
	swap	d0
	swap	d1
	swap	d2
	move.w	d0,(a6)+
	move.w	d1,(a6)+
	move.w	d2,(a6)+
	cmp.w	#128,d2
	blt.s	mnE
	st	flag2
	swap	d0
	swap	d1
	asr.l	#8,d0
	asr.l	#8,d1
	divs	d2,d0
	divs	d2,d1
	add.w	#XMID,d0
	add.w	#YMID,d1
	move.w	d0,(a6)+
	move.w	d1,(a6)+
	dbf	d7,mnD
	bra.s	main

mnE	st	flag1
	addq.l	#4,a6
	dbf	d7,mnD
	bra.s	main

mnF	lea	dataE(pc),a2		; Not used
	bra.s	mn10

	lea	dataA(pc),a2
mn10	move.w	(a0)+,d7
	lea	dataE(pc),a6
	add.w	(a0)+,a6
mn11	movem.w	(a0)+,d0-d2
	move.w	d0,d3
	move.w	d1,d4
	move.w	d2,d5
	muls	(a2)+,d0
	muls	(a2)+,d4
	muls	(a2)+,d5
	add.l	d4,d0
	add.l	d5,d0
	move.w	d3,d6
	move.w	d1,d4
	move.w	d2,d5
	muls	(a2)+,d3
	muls	(a2)+,d1
	muls	(a2)+,d5
	add.l	d3,d1
	add.l	d5,d1
	muls	(a2)+,d6
	muls	(a2)+,d4
	muls	(a2)+,d2
	add.l	d6,d2
	add.l	d4,d2
	add.l	(a2)+,d0
	add.l	(a2)+,d1
	add.l	(a2)+,d2
	bmi.s	mn12
	lea	-30(a2),a2
	asr.l	#8,d0
	asr.l	#8,d1
	swap	d2
	divs	d2,d0
	divs	d2,d1
	add.w	#XMID,d0
	add.w	#YMID,d1
	move.w	d2,(a6)+
	move.w	d0,(a6)+
	move.w	d1,(a6)+
	dbf	d7,mn11

main	move.w	(a0)+,d0
	jmp	mn17(pc,d0.w)
	pea	2(a0)
	add.w	(a0),a0
	bsr.s	main
	move.l	(a7)+,a0
	move.b	flag3(pc),d0
	bmi.s	mn13
	move.w	(a0)+,d0
	jmp	mn17(pc,d0.w)
mn12	st	flag3
mn13	rts

mn14	add.w	(a0),a0
	move.w	(a0)+,d0
	jmp	mn17(pc,d0.w)
	bsr	poly17
	move.w	(a0)+,d0
	jmp	mn17(pc,d0.w)
	move.b	flag1(pc),d0
	beq.s	mn15
	bsr	poly5
	move.w	(a0)+,d0
	jmp	mn17(pc,d0.w)
mn15	bsr	poly17
	move.l	(a0)+,d0
	jmp	mn17(pc,d0.w)
	move.w	(a0)+,colour1
	move.w	(a0)+,d0
	jmp	mn17(pc,d0.w)
	move.w	(a0)+,d0
	bsr	setline
	move.w	(a0)+,d0
	jmp	mn17(pc,d0.w)
mn16	move.w	(a0)+,d0
	move.w	(a0)+,d1
	bsr	mn37
	move.w	(a0)+,d0
mn17	jmp	mn17(pc,d0.w)
	lea	dataE(pc),a6
	move.w	(a0)+,d0
	movem.w	(a6,d0.w),d0-d2
	move.l	(a0)+,d7
	divs	d0,d7
	bsr	circle
	move.w	(a0)+,d0
	jmp	mn17(pc,d0.w)
	lea	dataE(pc),a6
	movem.w	(a0)+,d0-d1/d3
	move.w	(a6,d0.w),d0
	cmp.w	(a6,d1.w),d0
	bge.s	mn19
mn18	add.w	d3,a0
mn19	move.w	(a0)+,d0
	jmp	mn17(pc,d0.w)
	lea	dataE(pc),a6
	movem.w	(a0)+,d0-d3
	movem.w	2(a6,d0.w),d0/d4
	movem.w	2(a6,d2.w),d2/d5
	move.l	2(a6,d1.w),d1
	sub.w	d1,d4
	sub.w	d1,d5
	swap	d1
	sub.w	d1,d0
	sub.w	d1,d2
	muls	d2,d4
	muls	d0,d5
	sub.l	d4,d5
	bmi.s	mn1A
	add.w	d3,a0
mn1A	move.w	(a0)+,d0
	jmp	mn17(pc,d0.w)
	movem.w	(a0)+,d0-d2
	lea	dataB(pc),a1
	muls	(a1)+,d0
	muls	(a1)+,d1
	muls	(a1)+,d2
	add.l	d1,d0
	add.l	d2,d0
	neg.l	d0
	bpl.s	mn1B
	moveq	#0,d0
mn1B	swap	d0
	rol.w	#6,d0
	and.w	#$f,d0
	move.w	dataD(pc),d1
	bpl.s	mn1C
	moveq	#0,d1
mn1C	lsr.w	#8,d1
	lsr.w	#3,d1
	sub.w	d1,d0
	bpl.s	mn1D
	moveq	#0,d0
mn1D	add.w	(a0)+,d0
	add.w	d0,d0
	move.w	mn21(pc,d0.w),colour1
	bra	main

mn1E	move.l	(a0)+,$438		; Not used
	move.w	#$ff,colour1
	bra	main

	moveq	#$f,d0			; Not used
	move.w	dataD(pc),d1
	bpl.s	mn1F
	moveq	#0,d1
mn1F	lsr.w	#8,d1
	sub.w	d1,d0
	bpl.s	mn20
	moveq	#0,d0
mn20	add.w	(a0)+,d0
	add.w	d0,d0
	move.w	mn21(pc,d0.w),colour1
	bra	main

mn21	dc.w	$6000,$c0c0,$c0c0,$6800,$6860,$6860,$d0d0,$7000
	dc.w	$7060,$7068,$7800,$7860,$7868,$e0e0,$7870,$f0f0
	dc.w	$4000,$8080,$8080,$4800,$4840,$4840,$9090,$5000
	dc.w	$5040,$5048,$5800,$5840,$5848,$a0a0,$5850,$b0b0
	dc.w	$2000,$4040,$4040,$2800,$2820,$2820,$5050,$3000
	dc.w	$3020,$3028,$3800,$3820,$3828,$6060,$3830,$7070
	dc.w	$0008,$0008,$1010,$1010,$0010,$0010,$0810,$0810
	dc.w	$0018,$2020,$0818,$0818,$1018,$1018,$3030,$3030

mn22	move.w	(a0)+,d0
	move.w	(a0)+,d3
	cmp.w	dataD(pc),d0
	bgt	main
	bra	mn18

mn23	move.w	(a0)+,d1
	move.w	(a0)+,d0
	lea	dataE(pc),a6
	movem.w	-4(a6,d0.w),d5-d7
	movem.w	-4(a6,d1.w),d0-d2
	sub.w	d0,d5
	sub.w	d1,d6
	sub.w	d2,d7
	bpl.s	mn24
	neg.w	d7
mn24	bsr	mn27
	bra	main

mn25	lea	dataE(pc),a6
	move.w	(a0)+,d0
	move.l	(a0)+,d7
	move.w	(a6,d0.w),d6
	cmp.w	#128,d6
	blt	main
	divu	d6,d7
	movem.w	2(a6,d0.w),d0-d1
	move.w	mn2B(pc),d3
	move.w	mn29(pc),d2
	mulu	d7,d2
	divu	d3,d2
	mulu	d7,d3
	divu	mn2C(pc),d3
	move.l	mn2D(pc),d4
	bsr	ellipse
	bra	main

mn26	lea	dataE(pc),a6
	move.w	(a0)+,a1
	move.l	(a0)+,d6
	move.w	(a0)+,a2
	move.l	(a0)+,d7
	divu	(a6,a1.w),d6
	divu	(a6,a2.w),d7
	movem.w	2(a6,a1.w),d0-d1
	movem.w	2(a6,a2.w),d2-d3
	sub.w	d2,d0
	sub.w	d3,d1
	move.w	d0,d4
	move.w	d1,d5
	muls	d0,d0
	muls	d1,d1
	add.l	d1,d0
	bsr	mnsub1
	addq.w	#1,d2
	lea	mn2E(pc),a3
	move.w	d4,d0
	move.w	d5,d1
	muls	d6,d0
	muls	d6,d1
	divs	d2,d0
	divs	d2,d1
	move.w	2(a6,a1.w),d3
	add.w	d1,d3
	move.w	d3,(a3)+
	move.w	4(a6,a1.w),d3
	sub.w	d0,d3
	move.w	d3,(a3)+
	move.w	2(a6,a1.w),d3
	sub.w	d1,d3
	move.w	d3,(a3)+
	move.w	4(a6,a1.w),d3
	add.w	d0,d3
	move.w	d3,(a3)+
	muls	d7,d4
	muls	d7,d5
	divs	d2,d4
	divs	d2,d5
	move.w	2(a6,a2.w),d3
	sub.w	d5,d3
	move.w	d3,(a3)+
	move.w	4(a6,a2.w),d3
	add.w	d4,d3
	move.w	d3,(a3)+
	move.w	2(a6,a2.w),d3
	add.w	d5,d3
	move.w	d3,(a3)+
	move.w	4(a6,a2.w),d3
	sub.w	d4,d3
	move.w	d3,(a3)+
	move.l	a0,-(a7)
	lea	mn2F(pc),a0
	lea	mn2E(pc),a6
	bsr	poly18
	move.l	(a7)+,a0
	bra	main

mn27	movem.w	d5-d7,mn28
	move.w	d5,d4
	neg.w	d4
	muls	d6,d4
	muls	d5,d5
	muls	d6,d6
	muls	d7,d7
	add.l	d5,d6
	add.l	d7,d5
	add.l	d6,d7
	move.l	d6,mn2A
	move.l	d5,d0
	bsr	mnsub1
	move.w	d2,mn2B
	move.l	d7,d0
	bsr	mnsub1
	move.w	d2,mn2C
	move.l	d4,d0
	move.l	d5,d1
	bsr	mnsub2
	move.l	d2,mn2D
	rts

mn28	dc.w	0,0
mn29	dc.w	0
mn2A	dc.w	0,0
mn2B	dc.w	0
mn2C	dc.w	0
mn2D	dc.w	0,0
mn2E	dc.w	0,0,0,0,0,0,0,0
mn2F	dc.w	4,$fffe,2,6,10
	

mn30	addq.l	#6,a0			; Not used
	bra	main

mn31	lea	dataE(pc),a6
	move.w	(a0)+,a5
	movem.w	-4(a6,a5.w),d5-d7
	cmp.w	#128,d7
	blt.s	mn30
	muls	d5,d5
	muls	d6,d6
	muls	d7,d7
	add.l	d7,d5
	move.l	d5,d0
	bsr	mnsub1
	add.l	d6,d5
	move.l	d5,d0
	move.w	d2,d6
	bsr	mnsub1
	move.w	d2,d7
	movem.w	-4(a6,a5.w),d0-d2
	move.w	(a0)+,d3
	sub.w	-4(a6,d3.w),d0
	sub.w	-2(a6,d3.w),d1
	sub.w	(a6,d3.w),d2
	move.w	d0,d5
	muls	(a6,a5.w),d5
	move.w	d2,d4
	muls	-4(a6,a5.w),d4
	sub.l	d4,d5
	divs	d6,d5
	muls	-4(a6,a5.w),d0
	muls	(a6,a5.w),d2
	move.l	d0,d3
	add.l	d2,d3
	divs	d6,d3
	muls	-2(a6,a5.w),d3
	muls	d1,d6
	sub.l	d3,d6
	divs	d7,d6
	muls	-2(a6,a5.w),d1
	add.l	d1,d0
	add.l	d2,d0
	divs	d7,d0
	move.w	d0,d7
	bpl.s	mn32
	neg.w	d7
mn32	bsr	mn27
	move.l	(a0)+,d7
	divu	(a6,a5.w),d7
	movem.w	2(a6,a5.w),d0-d1
	move.w	mn2B(pc),d3
	move.w	mn29(pc),d2
	mulu	d7,d2
	divu	d3,d2
	mulu	d7,d3
	divu	mn2C(pc),d3
	move.l	mn2D(pc),d4
	bsr	ellipse
	bra	main

mn33	lea	dataE(pc),a6
	cmp.w	#128,(a6,d0.w)
	bge.s	mn35
	cmp.w	#128,(a6,d1.w)
	bge.s	mn36
mn34	rts

mn35	cmp.w	#128,(a6,d1.w)
	bge.s	mn38
	exg	d0,d1
mn36	bsr	poly1
	bvs.s	mn34
	movem.w	2(a6,d1.w),d0-d1
	bsr.s	mn39
	bpl	line
	rts

mn37	lea	dataE(pc),a6
mn38	movem.w	2(a6,d1.w),d2-d3
	movem.w	2(a6,d0.w),d0-d1
	bsr.s	mn39
	bpl	line
	rts

mn39	move.w	#YMAX-1,a2
	move.w	#XMAX-1,d6
	tst.w	d0
	bpl.s	mn3C
	tst.w	d2
	bmi.s	mn3B
	move.w	d2,d4
	sub.w	d0,d4
	move.w	d3,d5
	sub.w	d1,d5
	muls	d0,d5
	divs	d4,d5
	sub.w	d5,d1
	moveq	#0,d0
	bra.s	mn3D

mn3A	moveq	#-1,d0
mn3B	rts

mn3C	cmp.w	d6,d0
	ble.s	mn3D
	cmp.w	d6,d2
	bgt.s	mn3A
	move.w	d2,d4
	sub.w	d0,d4
	move.w	d3,d5
	sub.w	d1,d5
	sub.w	d6,d0
	muls	d0,d5
	divs	d4,d5
	sub.w	d5,d1
	move.w	d6,d0
mn3D	tst.w	d1
	bpl.s	mn40
	tst.w	d3
	bmi.s	mn3E
	move.w	d2,d4
	sub.w	d0,d4
	move.w	d3,d5
	sub.w	d1,d5
	muls	d1,d4
	divs	d5,d4
	moveq	#0,d1
	sub.w	d4,d0
	bmi.s	mn3E
	cmp.w	d6,d0
	ble.s	mn41
mn3E	moveq	#-1,d0
mn3F	rts

mn40	cmp.w	a2,d1
	ble.s	mn41
	cmp.w	a2,d3
	bgt.s	mn3E
	move.w	d2,d4
	sub.w	d0,d4
	move.w	d3,d5
	sub.w	d1,d5
	sub.w	a2,d1
	muls	d1,d4
	divs	d5,d4
	sub.w	d4,d0
	bmi.s	mn3F
	cmp.w	d6,d0
	bgt.s	mn3E
	move.w	a2,d1
mn41	tst.w	d2
	bpl.s	mn42
	move.w	d0,d4
	sub.w	d2,d4
	move.w	d1,d5
	sub.w	d3,d5
	muls	d2,d5
	divs	d4,d5
	sub.w	d5,d3
	moveq	#0,d2
	bra.s	mn43

mn42	cmp.w	d6,d2
	ble.s	mn43
	move.w	d0,d4
	sub.w	d2,d4
	move.w	d1,d5
	sub.w	d3,d5
	sub.w	d6,d2
	muls	d2,d5
	divs	d4,d5
	sub.w	d5,d3
	move.w	d6,d2
mn43	tst.w	d3
	bpl.s	mn46
	move.w	d0,d4
	sub.w	d2,d4
	move.w	d1,d5
	sub.w	d3,d5
	muls	d3,d4
	divs	d5,d4
	moveq	#0,d3
	sub.w	d4,d2
	bmi.s	mn45
	cmp.w	d6,d2
	ble.s	mn47
mn44	moveq	#-1,d0
mn45	rts

mn46	cmp.w	a2,d3
	ble.s	mn47
	move.w	d0,d4
	sub.w	d2,d4
	move.w	d1,d5
	sub.w	d3,d5
	sub.w	a2,d3
	muls	d3,d4
	divs	d5,d4
	sub.w	d4,d2
	bmi.s	mn45
	cmp.w	d6,d2
	bgt.s	mn44
	move.w	a2,d3
mn47	moveq	#0,d6
return	rts


;""""""""""""""""""""""""""""""""""""""""
;	" THE CIRCLE ROUTINE "
;	"		     "
;	""""""""""""""""""""""

circle	move.w	d1,d5
	add.w	d7,d5
	bmi.s	return
	move.w	d1,d5
	sub.w	d7,d5
	cmp.w	#XMAX,d5
	bge.s	return
	move.w	d2,d5
	sub.w	d7,d5
	cmp.w	#YMAX,d5
	bge.s	return
	move.w	d2,d5
	add.w	d7,d5
	bmi.s	return
	cmp.w	#YMAX-1,d5
	ble.s	circ1
	move.w	#YMAX-1,d5
circ1	lea	coords(pc),a3
	tst.w	d2
	bpl.s	circ2
	move.w	d7,d0
	move.w	d2,d7
	muls	d0,d0
	muls	d2,d2
	sub.l	d2,d0
	bsr	circ10
	swap	d2
	add.w	d7,d2
	neg.w	d2
	add.w	d7,d7
	subq.w	#1,d7
	clr.w	(a3)+
	bra.s	circA

circ2	sub.w	d7,d2
	bpl.s	circ3
	move.w	d7,d0
	add.w	d2,d7
	move.w	d7,d2
	muls	d0,d0
	muls	d2,d2
	sub.l	d2,d0
	bsr	circ10
	swap	d2
	add.w	d7,d2
	neg.w	d2
	clr.w	(a3)+
	bra.s	circ4

circ3	move.w	d2,(a3)+
	sub.w	d2,d5
	moveq	#0,d4
	move.w	d7,d2
	neg.w	d2
circ4	add.w	d7,d7
	subq.w	#1,d7
circ5	move.w	d4,d0
	add.w	d0,d0
	addq.w	#1,d0
	add.w	d0,d2
	bgt.s	circ7
circ6	addq.w	#1,d4
	addq.w	#2,d0
	add.w	d0,d2
	ble.s	circ6

circ7	sub.w	d0,d2
	move.w	d1,d3
	sub.w	d4,d3
	bpl.s	circ8
	moveq	#0,d3
circ8	swap	d3
	move.w	d1,d3
	add.w	d4,d3
	cmp.w	#XMAX-1,d3
	ble.s	circ9
	move.w	#XMAX-1,d3
circ9	move.l	d3,(a3)+
	sub.w	d7,d2
	subq.w	#2,d7
	dbmi	d5,circ5
	subq.w	#1,d5
	bmi.s	circF

circA	tst.w	d2
	ble.s	circC
	moveq	#-1,d0
	sub.w	d4,d0
	sub.w	d4,d0
circB	addq.w	#2,d0
	add.w	d0,d2
	dble	d4,circB
	subq.w	#1,d4
circC	move.w	d1,d3
	sub.w	d4,d3
	bpl.s	circD
	moveq	#0,d3
circD	swap	d3
	move.w	d1,d3
	add.w	d4,d3
	bmi.s	circF
	cmp.w	#XMAX-1,d3
	ble.s	circE
	move.w	#XMAX-1,d3
circE	move.l	d3,(a3)+
	sub.w	d7,d2
	subq.w	#2,d7
	dbf	d5,circA
circF	bra	fill

circ10	moveq	#$f,d3
	move.l	#$40000000,d4
	move.l	d0,d2
	clr.w	d2
	swap	d2
circ11	swap	d4
	sub.l	d4,d2
	bcc.s	circ12
	add.l	d4,d2
	swap	d4
	add.w	d4,d4
	add.w	d0,d0
	addx.l	d2,d2
	add.w	d0,d0
	addx.l	d2,d2
	dbf	d3,circ11
	rts

circ12	swap	d4
	add.w	d4,d4
	addq.w	#1,d4
	add.w	d0,d0
	addx.l	d2,d2
	add.w	d0,d0
	addx.l	d2,d2
	dbf	d3,circ11
return2	rts


;""""""""""""""""""""""""""""""""""""""""
;	" THE ELLIPSE ROUTINE "
;	"		      "
;	"""""""""""""""""""""""

ellipse	move.w	d1,d7
	add.w	d3,d7
	bmi.s	return2
	move.w	d1,d7
	sub.w	d3,d7
	cmp.w	#YMAX,d7
	bge.s	return2
	move.w	d3,d5
	mulu	d5,d5
	move.l	d5,a2
	add.l	d5,d5
	move.w	d5,d6
	mulu	d2,d6
	swap	d5
	mulu	d2,d5
	swap	d5
	clr.w	d5
	add.l	d5,d6
	add.l	a2,d6
	move.l	d6,a5
	add.l	a2,a2
	move.w	d2,d5
	mulu	d5,d5
	neg.l	d5
	move.l	d5,a6
	add.l	d5,d5
	neg.l	d5
	move.l	d5,a1
	move.l	#$8000,d5
	moveq	#0,d7
	lea	coords(pc),a3
	tst.w	d1
	bpl.s	ell2
	clr.w	(a3)+
	move.w	d1,d6
	not.w	d6
	bsr	ell1F
	add.w	d1,d3
	cmp.w	#YMAX-1,d3
	ble.s	ell1
	move.w	#YMAX-1,d3
ell1	bsr	ell12
	bra	fill

ell2	cmp.w	#YMAX-1,d1
	ble.s	ell4
	move.w	d1,d6
	sub.w	#YMAX,d6
	bsr	ell1F
	sub.w	d3,d1
	bpl.s	ell3
	moveq	#0,d1
ell3	move.w	d1,(a3)+
	move.w	#YMAX,d3
	sub.w	d1,d3
	move.w	d3,d1
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,a3
	move.l	a3,a4
	bsr	ell1D
	bra	fill

ell4	move.w	d1,d6
	sub.w	d3,d6
	bpl.s	ell5
	moveq	#0,d6
ell5	move.w	d6,(a3)+
	add.w	d1,d3
	cmp.w	#YMAX-1,d3
	ble.s	ell6
	move.w	#YMAX-1,d3
ell6	sub.w	d1,d3
	sub.w	d6,d1
	move.w	d1,d6
	add.w	d6,d6
	add.w	d6,d6
	add.w	d6,a3
	move.l	a3,a4
	move.w	d0,d6
	sub.w	d2,d6
	bpl.s	ell7
	moveq	#0,d6
ell7	move.w	d6,(a3)+
	move.w	d0,d6
	add.w	d2,d6
	cmp.w	#XMAX-1,d6
	ble.s	ell8
	move.w	#XMAX-1,d6
ell8	move.w	d6,(a3)+
	cmp.w	d1,d3
	ble.s	ell9
	sub.w	d1,d3
	bsr.s	ell11
	bsr	ell17
	bra	fill

ell9	exg	d1,d3
	sub.w	d1,d3
	bsr.s	ell11
	bsr	ell1D
	bra	fill

ellA	add.l	d4,d5
	add.l	a1,a6
	add.l	a6,d7
	ble.s	ellC
ellB	subq.w	#1,d2
	sub.l	a2,a5
	sub.l	a5,d7
	bgt.s	ellB
ellC	swap	d5
	move.w	d0,d6
	add.w	d5,d6
	sub.w	d2,d6
	bpl.s	ellD
	moveq	#0,d6
ellD	move.w	d6,(a3)+
	move.w	d0,d6
	add.w	d5,d6
	add.w	d2,d6
	cmp.w	#XMAX-1,d6
	ble.s	ellE
	move.w	#XMAX-1,d6
ellE	move.w	d6,(a3)+
	move.w	d0,d6
	sub.w	d5,d6
	add.w	d2,d6
	cmp.w	#XMAX-1,d6
	ble.s	ellF
	move.w	#XMAX-1,d6
ellF	move.w	d6,-(a4)
	move.w	d0,d6
	sub.w	d5,d6
	sub.w	d2,d6
	bpl.s	ell10
	moveq	#0,d6
ell10	move.w	d6,-(a4)
	swap.w	d5
ell11	dbf	d1,ellA
	rts

ell12	add.l	d4,d5
	add.l	a1,a6
	add.l	a6,d7
	ble.s	ell14
ell13	subq.w	#1,d2
	sub.l	a2,a5
	sub.l	a5,d7
	bgt.s	ell13
ell14	swap	d5
	move.w	d0,d6
	add.w	d5,d6
	sub.w	d2,d6
	bpl.s	ell15
	moveq	#0,d6
ell15	move.w	d6,(a3)+
	move.w	d0,d6
	add.w	d5,d6
	add.w	d2,d6
	cmp.w	#XMAX-1,d6
	ble.s	ell16
	move.w	#XMAX-1,d6
ell16	move.w	d6,(a3)+
	swap	d5
ell17	dbf	d3,ell12
	rts

ell18	add.l	d4,d5
	add.l	a1,a6
	add.l	a6,d7
	ble.s	ell1A
ell19	subq.w	#1,d2
	sub.l	a2,a5
	sub.l	a5,d7
	bgt.s	ell19
ell1A	swap	d5
	move.w	d0,d6
	sub.w	d5,d6
	add.w	d2,d6
	cmp.w	#XMAX-1,d6
	ble.s	ell1B
	move.w	#XMAX-1,d6
ell1B	move.w	d6,-(a4)
	move.w	d0,d6
	sub.w	d5,d6
	sub.w	d2,d6
	bpl.s	ell1C
	moveq	#0,d6
ell1C	move.w	d6,-(a4)
	swap	d5
ell1D	dbf	d3,ell18
	rts

ell1E	add.l	d4,d5
	add.l	a1,a6
	add.l	a6,d7
ell1F	dbf	d6,ell1E
	rts


;""""""""""""""""""""""""""""""""""""""""
;	" THE POLYGON ROUTINE "
;	"		      "
;	"""""""""""""""""""""""

poly1	move.l	-4(a6,d0.w),d4
	move.l	-4(a6,d1.w),d2
	move.w	(a6,d0.w),d5
	move.w	d5,d0
	sub.w	(a6,d1.w),d5
	sub.w	#128,d0
	move.w	d2,d3
	sub.w	d4,d3
	muls	d0,d3
	divs	d5,d3
	add.w	d4,d3
	swap	d4
	swap	d2
	sub.w	d4,d2
	muls	d0,d2
	divs	d5,d2
	add.w	d4,d2
	add.w	d2,d2
	bvs.s	poly2
	add.w	d3,d3
	bvs.s	poly2
	add.w	#XMID,d2
	bvs.s	poly2
	add.w	#YMID,d3
poly2	rts

poly3	move.l	-4(a6,d1.w),d4
	move.l	-4(a6,d0.w),d2
	move.w	(a6,d1.w),d5
	move.w	d5,d3
	sub.w	(a6,d0.w),d5
	sub.w	#128,d3
	move.w	d3,d0
	move.w	d2,d3
	sub.w	d4,d3
	muls	d0,d3
	divs	d5,d3
	add.w	d4,d3
	swap	d4
	swap	d2
	sub.w	d4,d2
	muls	d0,d2
	divs	d5,d2
	add.w	d4,d2
	add.w	d2,d2
	bvs.s	poly4
	add.w	d3,d3
	bvs.s	poly4
	add.w	#XMID,d2
	bvs.s	poly4
	add.w	#YMID,d3
poly4	rts

poly5	move.w	(a0)+,d7
	subq.w	#1,d7
	lea	dataE(pc),a6
	lea	flag4(pc),a1
	moveq	#0,d6
	move.w	(a0)+,d1
	cmp.w	#128,(a6,d1.w)
	bge.s	poly8
poly6	move.w	d1,d0
	move.w	(a0)+,d1
	cmp.w	#128,(a6,d1.w)
	dbge	d7,poly6
	blt.s	poly9
	bsr	poly1
	bvs.s	poly7
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	addq.w	#1,d6
	dbf	d7,poly8
	bra.s	poly9

poly7	add.w	d7,d7
	add.w	d7,a0
	rts

poly8	move.l	2(a6,d1.w),(a1)+
	addq.w	#1,d6
	move.w	d1,d0
	move.w	(a0)+,d1
	cmp.w	#128,(a6,d1.w)
	dblt	d7,poly8
	bge.s	poly9
	bsr	poly3
	bvs.s	poly7
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	addq.w	#1,d6
	dbf	d7,poly6
poly9	move.w	d6,d7
	beq.s	polyF
	add.w	d6,d6
	add.w	d6,d6
	subq.w	#2,d7
	lea	flag4(pc),a1
	lea	(a1,d6.w),a5
	move.l	a1,a2
	move.l	(a1)+,d3
	move.w	d3,d4
	move.l	d3,d0
	swap	d0
	move.w	d0,d1
	move.l	d3,(a5)+
polyA	move.l	(a1)+,d2
	move.l	d2,(a5)+
	cmp.w	d2,d3
	ble.s	polyB
	move.l	d2,d3
	lea	-4(a1),a2
polyB	cmp.w	d2,d4
	bge.s	polyC
	move.w	d2,d4
polyC	swap	d2
	cmp.w	d2,d0
	ble.s	polyD
	move.w	d2,d0
polyD	cmp.w	d2,d1
	bge.s	polyE
	move.w	d2,d1
polyE	dbf	d7,polyA
	tst.w	d1
	bmi.s	polyF
	cmp.w	#XMAX,d0
	blt	poly1E
polyF	rts

poly10	lea	coords(pc),a3
	move.w	d3,(a3)+
	lsr.w	#2,d6
	subq.w	#2,d6
	lea	flag4(pc),a1
	move.l	(a1)+,d0
	move.l	d0,d1
poly11	move.l	(a1)+,d2
	cmp.l	d2,d0
	ble.s	poly12
	move.l	d2,d0
poly12	cmp.l	d2,d1
	bge.s	poly13
	move.l	d2,d1
poly13	dbf	d6,poly11
	move.l	d0,d2
	bpl.s	poly14
	moveq	#0,d2
poly14	swap	d1
	move.w	d1,d2
	cmp.w	#XMAX-1,d2
	ble.s	poly15
	move.w	#XMAX-1,d2
poly15	move.l	d2,(a3)+
	bra	fill

poly16	rts

poly17	lea	dataE(pc),a6
poly18	move.w	(a0)+,d6
	move.w	d6,d7
	add.w	d6,d6
	add.w	d6,d6
	subq.w	#2,d7
	lea	flag4(pc),a1
	lea	(a1,d6.w),a5
	move.w	(a0)+,d3
	move.l	2(a6,d3.w),d3
	move.w	d3,d4
	move.l	d3,d0
	swap	d0
	move.w	d0,d1
	move.l	a1,a2
	move.l	d3,(a1)+
	move.l	d3,(a5)+
poly19	move.w	(a0)+,d2
	move.l	2(a6,d2.w),d2
	cmp.w	d2,d3
	ble.s	poly1A
	move.l	d2,d3
	move.l	a1,a2
poly1A	cmp.w	d2,d4
	bge.s	poly1B
	move.w	d2,d4
poly1B	move.l	d2,(a1)+
	move.l	d2,(a5)+
	swap	d2
	cmp.w	d2,d0
	ble.s	poly1C
	move.w	d2,d0
poly1C	cmp.w	d2,d1
	bge.s	poly1D
	move.w	d2,d1
poly1D	dbf	d7,poly19
	tst.w	d1
	bmi.s	poly16
	cmp.w	#XMAX,d0
	bge.s	poly16
poly1E	tst.w	d4
	bmi.s	poly16
	cmp.w	#YMAX-1,d3
	bgt.s	poly16
	cmp.w	d3,d4
	beq	poly10
	lea	(a2,d6.w),a1
	lea	coords(pc),a3
	move.w	#XMAX-1,d0
	move.w	#YMAX-1,d6
	move.l	#$10000,a4
	move.l	#$ffff0000,a5
	tst.w	d3
	bpl.s	poly25
poly1F	move.l	-(a1),d4
	tst.w	d4
	bmi.s	poly1F
	move.l	4(a1),d1
	move.w	d1,d3
	sub.w	d1,d4
	move.w	d4,d7
	swap	d4
	swap	d1
	sub.w	d1,d4
	muls	d4,d3
	divs	d7,d3
	sub.w	d3,d1
	swap	d1
	clr.w	d1
	bsr	poly5B
	move.l	d4,d7
	bpl.s	poly20
	neg.l	d7
poly20	cmp.l	a4,d7
	bge.s	poly21
	move.l	a5,d7
poly21	asr.l	#1,d7
	sub.l	d7,d1
poly22	move.l	(a2)+,d2
	tst.w	2(a2)
	bmi.s	poly22
	move.l	(a2),d5
	move.w	d2,d3
	sub.w	d2,d5
	move.w	d5,d7
	swap	d5
	swap	d2
	sub.w	d2,d5
	muls	d5,d3
	divs	d7,d3
	sub.w	d3,d2
	swap	d2
	clr.w	d2
	bsr	poly61
	move.l	d5,d7
	bpl.s	poly23
	neg.l	d7
poly23	cmp.l	a4,d7
	bge.s	poly24
	move.l	a4,d7
poly24	asr.l	#1,d7
	add.l	d7,d2
	clr.w	d3
	move.w	d3,(a3)+
	bra.s	poly31

poly25	move.w	d3,(a3)+
poly26	bsr	poly5F
	cmp.l	a1,a2
	bge	poly49
	bsr	poly59
	cmp.l	a1,a2
	move.l	d4,d7
	bpl.s	poly28
	cmp.l	a5,d7
	blt.s	poly27
	move.l	a4,d7
poly27	asr.l	#1,d7
	add.l	d7,d1
poly28	move.l	d5,d7
	bmi.s	poly2A
	cmp.l	a4,d7
	bgt.s	poly29
	move.l	a4,d7
poly29	asr.l	#1,d7
	add.l	d7,d2
poly2A	move.l	d1,d7
	bpl.s	poly2B
	moveq	#0,d7
poly2B	swap	d2
	move.w	d2,d7
	swap	d2
	cmp.w	d0,d7
	ble.s	poly2C
	move.w	d0,d7
poly2C	move.l	d7,(a3)+
	addq.w	#1,d3
	move.l	d4,d7
	bmi.s	poly2E
	cmp.l	a4,d7
	bgt.s	poly2D
	move.l	a4,d7
poly2D	asr.l	#1,d7
poly2E	add.l	d7,d1
	move.l	d5,d7
	bpl.s	poly30
	cmp.l	a5,d7
	blt.s	poly2F
	move.l	a4,d7
poly2F	asr.l	#1,d7
poly30	add.l	d7,d2
poly31	move.w	2(a1),d7
	cmp.l	a1,a2
	bge	poly4A
	cmp.w	2(a2),d7
	bgt.s	poly3B
	beq	poly45
	cmp.w	d6,d7
	bgt	poly54
	sub.w	d3,d7
	ble.s	poly35
	subq.w	#1,d7
poly32	move.l	d1,d3
	bpl.s	poly33
	moveq	#0,d3
poly33	swap	d2
	move.w	d2,d3
	swap	d2
	cmp.w	d0,d3
	ble.s	poly34
	move.w	d0,d3
poly34	move.l	d3,(a3)+
	add.l	d4,d1
	add.l	d5,d2
	dbf	d7,poly32
poly35	bsr	poly59
	move.l	d4,d7
	bpl.s	poly37
	cmp.l	a5,d7
	blt.s	poly36
	move.l	a4,d7
poly36	asr.l	#1,d7
	add.l	d7,d1
	bra.s	poly31

poly37	move.l	d1,d7
	bpl.s	poly38
	moveq	#0,d7
poly38	swap	d2
	move.w	d2,d7
	swap	d2
	cmp.w	d0,d7
	ble.s	poly39
	move.w	d0,d7
poly39	move.l	d7,(a3)+
	addq.w	#1,d3
	move.l	d4,d7
	cmp.l	a4,d7
	bgt.s	poly3A
	move.l	a4,d7
poly3A	asr.l	#1,d7
	add.l	d7,d1
	add.l	d5,d2
	bra.s	poly31

poly3B	move.w	2(a2),d7
	cmp.w	d6,d7
	bgt	poly54
	sub.w	d3,d7
	ble.s	poly3F
	subq.w	#1,d7
poly3C	move.l	d1,d3
	bpl.s	poly3D
	moveq	#0,d3
poly3D	swap	d2
	move.w	d2,d3
	swap	d2
	cmp.w	d0,d3
	ble.s	poly3E
	move.w	d0,d3
poly3E	move.l	d3,(a3)+
	add.l	d4,d1
	add.l	d5,d2
	dbf	d7,poly3C
poly3F	bsr	poly5F
	move.l	d5,d7
	bmi.s	poly41
	cmp.l	a4,d7
	bgt.s	poly40
	move.l	a4,d7
poly40	asr.l	#1,d7
	add.l	d7,d2
	bra	poly31

poly41	move.l	d1,d7
	bpl.s	poly42
	moveq	#0,d7
poly42	swap	d2
	move.w	d2,d7
	swap	d2
	cmp.w	d0,d7
	ble.s	poly43
	move.w	d0,d7
poly43	move.l	d7,(a3)+
	addq.w	#1,d3
	move.l	d5,d7
	cmp.l	a5,d7
	blt.s	poly44
	move.l	a4,d7
poly44	asr.l	#1,d7
	add.l	d7,d2
	add.l	d4,d1
	bra	poly31

poly45	cmp.w	d6,d7
	bgt	poly54
	sub.w	d3,d7
	ble	poly26
	subq.w	#1,d7
poly46	move.l	d1,d3
	bpl.s	poly47
	moveq	#0,d3
poly47	swap	d2
	move.w	d2,d3
	swap	d2
	cmp.w	d0,d3
	ble.s	poly48
	move.w	d0,d3
poly48	move.l	d3,(a3)+
	add.l	d4,d1
	add.l	d5,d2
	dbf	d7,poly46
	bra	poly26

poly49	move.l	(a1),d1
	clr.w	d1
	move.w	2(a1),d7
	cmp.w	d6,d7
	bgt	fill
	bra.s	poly4F
	move.w	2(a1),d7
poly4A	cmp.w	d6,d7
	bgt.s	poly54
	sub.w	d3,d7
	blt	fill
	bra.s	poly4E

poly4B	move.l	d1,d3
	bpl.s	poly4C
	moveq	#0,d3
poly4C	swap	d2
	move.w	d2,d3
	swap	d2
	cmp.w	d0,d3
	ble.s	poly4D
	move.w	d0,d3
poly4D	move.l	d3,(a3)+
	add.l	d4,d1
	add.l	d5,d2
poly4E	dbf	d7,poly4B
	move.l	(a1),d1
	move.l	d1,d2
poly4F	move.l	d4,d7
	bmi.s	poly50
	cmp.l	a4,d7
	blt.s	poly50
	asr.l	#1,d7
	sub.l	d7,d1
poly50	move.l	d5,d7
	bpl.s	poly51
	asr.l	#1,d7
	sub.l	d7,d2
poly51	move.l	d1,d3
	bpl.s	poly52
	moveq	#0,d3
poly52	swap	d2
	move.w	d2,d3
	swap	d2
	cmp.w	d0,d3
	ble.s	poly53
	move.w	d0,d3
poly53	move.l	d3,(a3)+
	bra	fill

poly54	move.w	d6,d7
	sub.w	d3,d7
	blt	fill
poly55	move.l	d1,d3
	bpl.s	poly56
	moveq	#0,d3
poly56	swap	d2
	move.w	d2,d3
	swap	d2
	cmp.w	d0,d3
	ble.s	poly57
	move.w	d0,d3
poly57	move.l	d3,(a3)+
	add.l	d4,d1
	add.l	d5,d2
	dbf	d7,poly55
	bra	fill

poly58	cmp.l	a1,a2
	bge.s	poly5D
	swap	d3
	move.w	(a1),d3
	swap	d3
	bra.s	poly5A

poly59	move.l	(a1),d3
poly5A	move.l	d3,d1
	clr.w	d1
	move.l	-(a1),d7
	sub.w	d3,d7
	ble.s	poly58
	move.l	d7,d4
	swap	d4
	swap	d3
	sub.w	d3,d4
	swap	d3
poly5B	ext.l	d4
	lsl.l	#8,d4
	divs	d7,d4
	bvs.s	poly5C
	ext.l	d4
	lsl.l	#8,d4
	rts

poly5C	asr.l	#8,d4
	divs	d7,d4
	swap	d4
	clr.w	d4
poly5D	rts

poly5E	cmp.l	a1,a2
	bge.s	poly5D
	swap	d3
	move.w	(a2),d3
	swap	d3
	addq.l	#4,a2
	bra.s	poly60

poly5F	move.l	(a2)+,d3
poly60	move.l	d3,d2
	clr.w	d2
	move.w	2(a2),d7
	sub.w	d3,d7
	ble.s	poly5E
	move.w	(a2),d5
	swap	d3
	sub.w	d3,d5
	swap	d3
poly61	ext.l	d5
	lsl.l	#8,d5
	divs	d7,d5
	bvs.s	poly62
	ext.l	d5
	lsl.l	#8,d5
	rts

poly62	asr.l	#8,d5
	divs	d7,d5
	swap	d5
	clr.w	d5
	rts


sincos	lea	18(a2),a2
	lea	cosine,a3
	move.w	(a3,d0.w),d3
	move.w	(a3,d1.w),d4
	move.w	(a3,d2.w),d5
	lea	sine,a3
	move.w	(a3,d0.w),d0
	move.w	(a3,d1.w),d1
	move.w	(a3,d2.w),d2
	move.w	d4,d6
	muls	d5,d6
	add.l	d6,d6
	swap	d6
	move.w	d6,-(a2)
	neg.w	d1
	move.w	d1,-(a2)
	neg.w	d1
	move.w	d4,d6
	muls	d2,d6
	add.l	d6,d6
	swap	d6
	neg.w	d6
	move.w	d6,-(a2)
	move.w	d1,d6
	muls	d5,d6
	add.l	d6,d6
	swap	d6
	move.w	d6,a3
	muls	d3,d6
	move.w	d0,d7
	muls	d2,d7
	sub.l	d7,d6
	add.l	d6,d6
	swap	d6
	move.w	d6,-(a2)
	move.w	d3,d6
	muls	d4,d6
	add.l	d6,d6
	swap	d6
	move.w	d6,-(a2)
	muls	d2,d1
	add.l	d1,d1
	swap	d1
	move.w	d1,d6
	muls	d3,d6
	move.w	d0,d7
	muls	d5,d7
	add.l	d7,d6
	add.l	d6,d6
	swap	d6
	neg.w	d6
	move.w	d6,-(a2)
	move.w	a3,d6
	muls	d0,d6
	muls	d3,d2
	add.l	d2,d6
	add.l	d6,d6
	swap	d6
	move.w	d6,-(a2)
	muls	d0,d4
	add.l	d4,d4
	swap	d4
	move.w	d4,-(a2)
	muls	d0,d1
	muls	d5,d3
	sub.l	d1,d3
	add.l	d3,d3
	swap	d3
	move.w	d3,-(a2)
	rts


mnsub1	moveq	#$f,d3
	move.l	#$40000000,d2
	move.l	d0,d1
	clr.w	d1
	swap	d1
mnsub11	swap	d2
	sub.l	d2,d1
	bcc.s	mnsub12
	add.l	d2,d1
	swap	d2
	add.w	d2,d2
	add.w	d0,d0
	addx.l	d1,d1
	add.w	d0,d0
	addx.l	d1,d1
	dbf	d3,mnsub11
	rts

mnsub12	swap	d2
	add.w	d2,d2
	addq.w	#1,d2
	add.w	d0,d0
	addx.l	d1,d1
	add.w	d0,d0
	addx.l	d1,d1
	dbf	d3,mnsub11
	rts


mnsub21	moveq	#0,d2
	rts

mnsub2	tst.l	d1
	beq.s	mnsub21
	bmi.s	mnsub23
	tst.l	d0
	bpl.s	mnsub24
	neg.l	d0
mnsub22	bsr.s	mnsub24
	neg.l	d2
	rts

mnsub23	neg.l	d1
	tst.l	d0
	bpl.s	mnsub22
	neg.l	d0
mnsub24	move.l	#$fffeffff,d2
	cmp.l	d1,d0
	bcs.s	mnsub26
mnsub25	add.l	d1,d1
	ror.l	#1,d2
	cmp.l	d1,d0
	bcc.s	mnsub25
mnsub26	add.l	d0,d0
	sub.l	d1,d0
	bcc.s	mnsub27
	add.l	d1,d0
mnsub27	addx.l	d2,d2
	bcs.s	mnsub26
	not.l	d2
	rts


flag1	dc.b	0
flag2	dc.b	0
flag3	dc.b	0,0
flag4	dcb.w	64,0	

colour1	dc.b	0
colour2	dc.b	0
data1	dc.w	0
data2	dc.w	0
data3	dc.w	0
data4	dc.w	0
data5	dc.w	0
data6	dc.w	0
data7	dc.w	0
data8	dc.w	0
data9	dc.w	0
dataA	dc.w	0,0,0,0,0,0
dataB	dc.w	0,0,0
dataC	dc.l	0,0
dataD	dc.l	$6000000	; z distance
dataE	dcb.w	420,0


setscreen
	move.l	screen1,d0
	move.l	screen2,screen1
	move.l	screen3,screen2
	move.l	d0,screen3

	lea	new(pc),a0
	moveq	#3,d1
nextpl	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40,d0		next bitplane
	addq.w	#8,a0		update pointer to copper list
	dbra	d1,nextpl
	rts


;""""""""""""""""""""""""""""""""""""""""
;	" THE COPPER LIST "
;	"                 "
;	"""""""""""""""""""

new	dc.w	bpl1pth		4 bitplane display
bp1h	dc.w	0,bpl1ptl
bp1l	dc.w	0,bpl2pth
bp2h	dc.w	0,bpl2ptl
bp2l	dc.w	0,bpl3pth
bp3h	dc.w	0,bpl3ptl
bp3l	dc.w	0,bpl4pth
bp4h	dc.w	0,bpl4ptl
bp4l	dc.w	0

	dc.w	$ffff,$fffe	END


;""""""""""""""""""""""
;" Hardware registers "
;"		      "
;""""""""""""""""""""""

bltddat	equ	$000
dmaconr	equ	$002
vposr	equ	$004
vhposr	equ	$006
dskdatr	equ	$008
joy0dat	equ	$00A
joy1dat	equ	$00C
clxdat	equ	$00E
adkconr	equ	$010
pot0dat	equ	$012
pot1dat	equ	$014
potgor	equ	$016
serdatr	equ	$018
dskbytr	equ	$01A
intenar	equ	$01C
intreqr	equ	$01E
dskpt	equ	$020
dsklen	equ	$024
dskdat	equ	$026
refptr	equ	$028
vposw	equ	$02A
vhposw	equ	$02C
copcon	equ	$02E
serdat	equ	$030
serper	equ	$032
potgo	equ	$034
joytest	equ	$036
strequ	equ	$038
strvbl	equ	$03A
strhor	equ	$03C
strlong	equ	$03E
bltcon0	equ	$040
bltcon1	equ	$042
bltafwm	equ	$044
bltalwm	equ	$046
bltcpth	equ	$048
bltcptl	equ	$04A
bltbpth	equ	$04C
bltbptl	equ	$04E
bltapth	equ	$050
bltaptl	equ	$052
bltdpth	equ	$054
bltdptl	equ	$056
bltsize	equ	$058
bltcmod	equ	$060
bltbmod	equ	$062
bltamod	equ	$064
bltdmod	equ	$066
bltcdat	equ	$070
bltbdat	equ	$072
bltadat	equ	$074
dsksync	equ	$07E
cop1lc	equ	$080
cop2lc	equ	$084
copjmp1	equ	$088
copjmp2	equ	$08A
copins	equ	$08C
diwstrt	equ	$08E
diwstop	equ	$090
ddfstrt	equ	$092
ddfstop	equ	$094
dmacon	equ	$096
clxcon	equ	$098
intena	equ	$09A
intreq	equ	$09C
adkcon	equ	$09E
aud0vol	equ	$0A8
aud1vol	equ	$0B8
aud2vol	equ	$0C8
aud3vol	equ	$0D8
bpl1pth	equ	$0E0
bpl1ptl	equ	$0E2
bpl2pth	equ	$0E4
bpl2ptl	equ	$0E6
bpl3pth	equ	$0E8
bpl3ptl	equ	$0EA
bpl4pth	equ	$0EC
bpl4ptl	equ	$0EE
bpl5pth	equ	$0F0
bpl5ptl	equ	$0F2
bpl6pth	equ	$0F4
bpl6ptl	equ	$0F6
bplcon0	equ	$100
bplcon1	equ	$102
bplcon2	equ	$104
bpl1mod	equ	$108
bpl2mod	equ	$10A
bpldat	equ	$110
spr0pth	equ	$120
spr0ptl	equ	$122
spr1pth	equ	$124
spr1ptl	equ	$126
spr2pth	equ	$128
spr2ptl	equ	$12A
spr3pth	equ	$12C
spr3ptl	equ	$12E
spr4pth	equ	$130
spr4ptl	equ	$132
spr5pth	equ	$134
spr5ptl	equ	$136
spr6pth	equ	$138
spr6ptl	equ	$13A
spr7pth	equ	$13C
spr7ptl	equ	$13E
spr0pos	equ	$140
spr1pos	equ	$148
spr2pos	equ	$150
spr3pos	equ	$158
spr4pos	equ	$160
spr5pos	equ	$168
spr6pos	equ	$170
spr7pos	equ	$178
spr0ctl	equ	$142
spr1ctl	equ	$14A
spr2ctl	equ	$152
spr3ctl	equ	$15A
spr4ctl	equ	$162
spr5ctl	equ	$16A
spr6ctl	equ	$172
spr7ctl	equ	$17A
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
color16	equ	$1A0


;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

screenmem	dc.l	0
screen1		dc.l	0
screen2		dc.l	0
screen3		dc.l	0
olddbz		dc.l	0
oldcopper	dc.l	0
gfxbase		dc.l	0
ints		dc.w	0
old		dc.l	0
mousedat	dc.b	0,0,0
	even
oldmousex	dc.b	0
oldmousey	dc.b	0
leftbn		dc.b	0
rightbn		dc.b	0
zangle		dc.w	0
xangle		dc.w	0
yangle		dc.w	0


;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

grafname	dc.b	'graphics.library',0
		even

sine	dc.w	$0000,$00c9,$0192,$025b,$0324,$03ed,$04b6,$057e,$0647
	dc.w	$0710,$07d9,$08a1,$096a,$0a32,$0afb,$0bc3,$0c8b,$0d53
	dc.w	$0e1b,$0ee3,$0fab,$1072,$1139,$1200,$12c7,$138e,$1455
	dc.w	$151b,$15e1,$16a7,$176d,$1833,$18f8,$19bd,$1a82,$1b46
	dc.w	$1c0b,$1ccf,$1d93,$1e56,$1f19,$1fdc,$209f,$2161,$2223
	dc.w	$22e4,$23a6,$2467,$2527,$25e7,$26a7,$2767,$2826,$28e5
	dc.w	$29a3,$2a61,$2b1e,$2bdb,$2c98,$2d54,$2e10,$2ecc,$2f86
	dc.w	$3041,$30fb,$31b4,$326d,$3326,$33de,$3496,$354d,$3603
	dc.w	$36b9,$376f,$3824,$38d8,$398c,$3a3f,$3af2,$3ba4,$3c56
	dc.w	$3d07,$3db7,$3e67,$3f16,$3fc5,$4073,$4120,$41cd,$4279
	dc.w	$4325,$43d0,$447a,$4523,$45cc,$4674,$471c,$47c3,$4869
	dc.w	$490e,$49b3,$4a57,$4afa,$4b9d,$4c3f,$4ce0,$4d80,$4e20
	dc.w	$4ebf,$4f5d,$4ffa,$5097,$5133,$51ce,$5268,$5301,$539a
	dc.w	$5432,$54c9,$555f,$55f4,$5689,$571d,$57b0,$5842,$58d3
	dc.w	$5963,$59f3,$5a81,$5b0f,$5b9c,$5c28,$5cb3,$5d3d,$5dc6
	dc.w	$5e4f,$5ed6,$5f5d,$5fe2,$6067,$60eb,$616e,$61f0,$6271
	dc.w	$62f1,$6370,$63ee,$646b,$64e7,$6562,$65dd,$6656,$66ce
	dc.w	$6745,$67bc,$6831,$68a5,$6919,$698b,$69fc,$6a6c,$6adb
	dc.w	$6b4a,$6bb7,$6c23,$6c8e,$6cf8,$6d61,$6dc9,$6e30,$6e95
	dc.w	$6efa,$6f5e,$6fc0,$7022,$7082,$70e1,$7140,$719d,$71f9
	dc.w	$7254,$72ae,$7306,$735e,$73b5,$740a,$745e,$74b1,$7503
	dc.w	$7554,$75a4,$75f3,$7640,$768d,$76d8,$7722,$776b,$77b3
	dc.w	$77f9,$783f,$7883,$78c6,$7908,$7949,$7989,$79c7,$7a04
	dc.w	$7a41,$7a7c,$7ab5,$7aee,$7b25,$7b5c,$7b91,$7bc4,$7bf7
	dc.w	$7c29,$7c59,$7c88,$7cb6,$7ce2,$7d0e,$7d38,$7d61,$7d89
	dc.w	$7db0,$7dd5,$7df9,$7e1c,$7e3e,$7e5e,$7e7e,$7e9c,$7eb9
	dc.w	$7ed4,$7eef,$7f08,$7f20,$7f37,$7f4c,$7f61,$7f74,$7f86
	dc.w	$7f96,$7fa6,$7fb4,$7fc1,$7fcd,$7fd7,$7fe0,$7fe8,$7fef
	dc.w	$7ff5,$7ff9,$7ffc,$7ffe
cosine	dc.w	$7fff,$7ffe,$7ffc,$7ff9,$7ff5,$7fef,$7fe8,$7fe0,$7fd7
	dc.w	$7fcd,$7fc1,$7fb4,$7fa6,$7f96,$7f86,$7f74,$7f61,$7f4c
	dc.w	$7f37,$7f20,$7f08,$7eef,$7ed4,$7eb9,$7e9c,$7e7e,$7e5e
	dc.w	$7e3e,$7e1c,$7df9,$7dd5,$7db0,$7d89,$7d61,$7d38,$7d0e
	dc.w	$7ce2,$7cb6,$7c88,$7c59,$7c29,$7bf7,$7bc4,$7b91,$7b5c
	dc.w	$7b25,$7aee,$7ab5,$7a7c,$7a41,$7a04,$79c7,$7989,$7949
	dc.w	$7908,$78c6,$7883,$783f,$77f9,$77b3,$776b,$7722,$76d8
	dc.w	$768d,$7640,$75f3,$75a4,$7554,$7503,$74b1,$745e,$740a
	dc.w	$73b5,$735e,$7306,$72ae,$7254,$71f9,$719d,$7140,$70e1
	dc.w	$7082,$7022,$6fc0,$6f5e,$6efa,$6e95,$6e30,$6dc9,$6d61
	dc.w	$6cf8,$6c8e,$6c23,$6bb7,$6b4a,$6adb,$6a6c,$69fc,$698b
	dc.w	$6919,$68a5,$6831,$67bc,$6745,$66ce,$6656,$65dd,$6562
	dc.w	$64e7,$646b,$63ee,$6370,$62f1,$6271,$61f0,$616e,$60eb
	dc.w	$6067,$5fe2,$5f5d,$5ed6,$5e4f,$5dc6,$5d3d,$5cb3,$5c28
	dc.w	$5b9c,$5b0f,$5a81,$59f3,$5963,$58d3,$5842,$57b0,$571d
	dc.w	$5689,$55f4,$555f,$54c9,$5432,$539a,$5301,$5268,$51ce
	dc.w	$5133,$5097,$4ffa,$4f5d,$4ebf,$4e20,$4d80,$4ce0,$4c3f
	dc.w	$4b9d,$4afa,$4a57,$49b3,$490e,$4869,$47c3,$471c,$4674
	dc.w	$45cc,$4523,$447a,$43d0,$4325,$4279,$41cd,$4120,$4073
	dc.w	$3fc5,$3f16,$3e67,$3db7,$3d07,$3c56,$3ba4,$3af2,$3a3f
	dc.w	$398c,$38d8,$3824,$376f,$36b9,$3603,$354d,$3496,$33de
	dc.w	$3326,$326d,$31b4,$30fb,$3041,$2f86,$2ecc,$2e10,$2d54
	dc.w	$2c98,$2bdb,$2b1e,$2a61,$29a3,$28e5,$2826,$2767,$26a7
	dc.w	$25e7,$2527,$2467,$23a6,$22e4,$2223,$2161,$209f,$1fdc
	dc.w	$1f19,$1e56,$1d93,$1ccf,$1c0b,$1b46,$1a82,$19bd,$18f8
	dc.w	$1833,$176d,$16a7,$15e1,$151b,$1455,$138e,$12c7,$1200
	dc.w	$1139,$1072,$0fab,$0ee3,$0e1b,$0d53,$0c8b,$0bc3,$0afb
	dc.w	$0a32,$096a,$08a1,$07d9,$0710,$0647,$057e,$04b6,$03ed
	dc.w	$0324,$025b,$0192,$00c9,$0000,$ff37,$fe6e,$fda5,$fcdc
	dc.w	$fc13,$fb4a,$fa82,$f9b9,$f8f0,$f827,$f75f,$f696,$f5ce
	dc.w	$f505,$f43d,$f375,$f2ad,$f1e5,$f11d,$f055,$ef8e,$eec7
	dc.w	$ee00,$ed39,$ec72,$ebab,$eae5,$ea1f,$e959,$e893,$e7cd
	dc.w	$e708,$e643,$e57e,$e4ba,$e3f5,$e331,$e26d,$e1aa,$e0e7
	dc.w	$e024,$df61,$de9f,$dddd,$dd1c,$dc5a,$db99,$dad9,$da19
	dc.w	$d959,$d899,$d7da,$d71b,$d65d,$d59f,$d4e2,$d425,$d368
	dc.w	$d2ac,$d1f0,$d134,$d07a,$cfbf,$cf05,$ce4c,$cd93,$ccda
	dc.w	$cc22,$cb6a,$cab3,$c9fd,$c947,$c891,$c7dc,$c728,$c674
	dc.w	$c5c1,$c50e,$c45c,$c3aa,$c2f9,$c249,$c199,$c0ea,$c03b
	dc.w	$bf8d,$bee0,$be33,$bd87,$bcdb,$bc30,$bb86,$badd,$ba34
	dc.w	$b98c,$b8e4,$b83d,$b797,$b6f2,$b64d,$b5a9,$b506,$b463
	dc.w	$b3c1,$b320,$b280,$b1e0,$b141,$b0a3,$b006,$af69,$aecd
	dc.w	$ae32,$ad98,$acff,$ac66,$abce,$ab37,$aaa1,$aa0c,$a977
	dc.w	$a8e3,$a850,$a7be,$a72d,$a69d,$a60d,$a57f,$a4f1,$a464
	dc.w	$a3d8,$a34d,$a2c3,$a23a,$a1b1,$a12a,$a0a3,$a01e,$9f99
	dc.w	$9f15,$9e92,$9e10,$9d8f,$9d0f,$9c90,$9c12,$9b95,$9b19
	dc.w	$9a9e,$9a23,$99aa,$9932,$98bb,$9844,$97cf,$975b,$96e7
	dc.w	$9675,$9604,$9594,$9525,$94b6,$9449,$93dd,$9372,$9308
	dc.w	$929f,$9237,$91d0,$916b,$9106,$90a2,$9040,$8fde,$8f7e
	dc.w	$8f1f,$8ec0,$8e63,$8e07,$8dac,$8d52,$8cfa,$8ca2,$8c4b
	dc.w	$8bf6,$8ba2,$8b4f,$8afd,$8aac,$8a5c,$8a0d,$89c0,$8973
	dc.w	$8928,$88de,$8895,$884d,$8807,$87c1,$877d,$873a,$86f8
	dc.w	$86b7,$8677,$8639,$85fc,$85bf,$8584,$854b,$8512,$84db
	dc.w	$84a4,$846f,$843c,$8409,$83d7,$83a7,$8378,$834a,$831e
	dc.w	$82f2,$82c8,$829f,$8277,$8250,$822b,$8207,$81e4,$81c2
	dc.w	$81a2,$8182,$8164,$8147,$812c,$8111,$80f8,$80e0,$80c9
	dc.w	$80b4,$809f,$808c,$807a,$806a,$805a,$804c,$803f,$8033
	dc.w	$8029,$8020,$8018,$8011,$800b,$8007,$8004,$8002,$8001
	dc.w	$8002,$8004,$8007,$800b,$8011,$8018,$8020,$8029,$8033
	dc.w	$803f,$804c,$805a,$806a,$807a,$808c,$809f,$80b4,$80c9
	dc.w	$80e0,$80f8,$8111,$812c,$8147,$8164,$8182,$81a2,$81c2
	dc.w	$81e4,$8207,$822b,$8250,$8277,$829f,$82c8,$82f2,$831e
	dc.w	$834a,$8378,$83a7,$83d7,$8409,$843c,$846f,$84a4,$84db
	dc.w	$8512,$854b,$8584,$85bf,$85fc,$8639,$8677,$86b7,$86f8
	dc.w	$873a,$877d,$87c1,$8807,$884d,$8895,$88de,$8928,$8973
	dc.w	$89c0,$8a0d,$8a5c,$8aac,$8afd,$8b4f,$8ba2,$8bf6,$8c4b
	dc.w	$8ca2,$8cfa,$8d52,$8dac,$8e07,$8e63,$8ec0,$8f1f,$8f7e
	dc.w	$8fde,$9040,$90a2,$9106,$916b,$91d0,$9237,$929f,$9308
	dc.w	$9372,$93dd,$9449,$94b6,$9525,$9594,$9604,$9675,$96e7
	dc.w	$975b,$97cf,$9844,$98bb,$9932,$99aa,$9a23,$9a9e,$9b19
	dc.w	$9b95,$9c12,$9c90,$9d0f,$9d8f,$9e10,$9e92,$9f15,$9f99
	dc.w	$a01e,$a0a3,$a12a,$a1b1,$a23a,$a2c3,$a34d,$a3d8,$a464
	dc.w	$a4f1,$a57f,$a60d,$a69d,$a72d,$a7be,$a850,$a8e3,$a977
	dc.w	$aa0c,$aaa1,$ab37,$abce,$ac66,$acff,$ad98,$ae32,$aecd
	dc.w	$af69,$b006,$b0a3,$b141,$b1e0,$b280,$b320,$b3c1,$b463
	dc.w	$b506,$b5a9,$b64d,$b6f2,$b797,$b83d,$b8e4,$b98c,$ba34
	dc.w	$badd,$bb86,$bc30,$bcdb,$bd87,$be33,$bee0,$bf8d,$c03b
	dc.w	$c0ea,$c199,$c249,$c2f9,$c3aa,$c45c,$c50e,$c5c1,$c674
	dc.w	$c728,$c7dc,$c891,$c947,$c9fd,$cab3,$cb6a,$cc22,$ccda
	dc.w	$cd93,$ce4c,$cf05,$cfbf,$d07a,$d134,$d1f0,$d2ac,$d368
	dc.w	$d425,$d4e2,$d59f,$d65d,$d71b,$d7da,$d899,$d959,$da19
	dc.w	$dad9,$db99,$dc5a,$dd1c,$dddd,$de9f,$df61,$e024,$e0e7
	dc.w	$e1aa,$e26d,$e331,$e3f5,$e4ba,$e57e,$e643,$e708,$e7cd
	dc.w	$e893,$e959,$ea1f,$eae5,$ebab,$ec72,$ed39,$ee00,$eec7
	dc.w	$ef8e,$f055,$f11d,$f1e5,$f2ad,$f375,$f43d,$f505,$f5ce
	dc.w	$f696,$f75f,$f827,$f8f0,$f9b9,$fa82,$fb4a,$fc13,$fcdc
	dc.w	$fda5,$fe6e,$ff37,$0000,$00c9,$0192,$025b,$0324,$03ed
	dc.w	$04b6,$057e,$0647,$0710,$07d9,$08a1,$096a,$0a32,$0afb
	dc.w	$0bc3,$0c8b,$0d53,$0e1b,$0ee3,$0fab,$1072,$1139,$1200
	dc.w	$12c7,$138e,$1455,$151b,$15e1,$16a7,$176d,$1833,$18f8
	dc.w	$19bd,$1a82,$1b46,$1c0b,$1ccf,$1d93,$1e56,$1f19,$1fdc
	dc.w	$209f,$2161,$2223,$22e4,$23a6,$2467,$2527,$25e7,$26a7
	dc.w	$2767,$2826,$28e5,$29a3,$2a61,$2b1e,$2bdb,$2c98,$2d54
	dc.w	$2e10,$2ecc,$2f86,$3041,$30fb,$31b4,$326d,$3326,$33de
	dc.w	$3496,$354d,$3603,$36b9,$376f,$3824,$38d8,$398c,$3a3f
	dc.w	$3af2,$3ba4,$3c56,$3d07,$3db7,$3e67,$3f16,$3fc5,$4073
	dc.w	$4120,$41cd,$4279,$4325,$43d0,$447a,$4523,$45cc,$4674
	dc.w	$471c,$47c3,$4869,$490e,$49b3,$4a57,$4afa,$4b9d,$4c3f
	dc.w	$4ce0,$4d80,$4e20,$4ebf,$4f5d,$4ffa,$5097,$5133,$51ce
	dc.w	$5268,$5301,$539a,$5432,$54c9,$555f,$55f4,$5689,$571d
	dc.w	$57b0,$5842,$58d3,$5963,$59f3,$5a81,$5b0f,$5b9c,$5c28
	dc.w	$5cb3,$5d3d,$5dc6,$5e4f,$5ed6,$5f5d,$5fe2,$6067,$60eb
	dc.w	$616e,$61f0,$6271,$62f1,$6370,$63ee,$646b,$64e7,$6562
	dc.w	$65dd,$6656,$66ce,$6745,$67bc,$6831,$68a5,$6919,$698b
	dc.w	$69fc,$6a6c,$6adb,$6b4a,$6bb7,$6c23,$6c8e,$6cf8,$6d61
	dc.w	$6dc9,$6e30,$6e95,$6efa,$6f5e,$6fc0,$7022,$7082,$70e1
	dc.w	$7140,$719d,$71f9,$7254,$72ae,$7306,$735e,$73b5,$740a
	dc.w	$745e,$74b1,$7503,$7554,$75a4,$75f3,$7640,$768d,$76d8
	dc.w	$7722,$776b,$77b3,$77f9,$783f,$7883,$78c6,$7908,$7949
	dc.w	$7989,$79c7,$7a04,$7a41,$7a7c,$7ab5,$7aee,$7b25,$7b5c
	dc.w	$7b91,$7bc4,$7bf7,$7c29,$7c59,$7c88,$7cb6,$7ce2,$7d0e
	dc.w	$7d38,$7d61,$7d89,$7db0,$7dd5,$7df9,$7e1c,$7e3e,$7e5e
	dc.w	$7e7e,$7e9c,$7eb9,$7ed4,$7eef,$7f08,$7f20,$7f37,$7f4c
	dc.w	$7f61,$7f74,$7f86,$7f96,$7fa6,$7fb4,$7fc1,$7fcd,$7fd7
	dc.w	$7fe0,$7fe8,$7fef,$7ff5,$7ff9,$7ffc,$7ffe


;"""""""""""""""""
;" GRAPHICS DATA "
;"		 "
;"""""""""""""""""

coltab	dc.w	$000,$060,$0a0,$0e0,$400,$800,$c00,$e00
	dc.w	$004,$008,$00c,$00e,$444,$888,$ccc,$eee

shape.dat	incbin	Disk.bin
