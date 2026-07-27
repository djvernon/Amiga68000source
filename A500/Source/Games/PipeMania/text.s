
			*** SOFTWARE TEXT SCALING ***

start	move.l	4,a6
	move.l	#96036,d0
	move.l	#$10002,d1	chip + clear
	jsr	-198(a6)	AllocMem
	move.l	d0,memory

	addq.l	#1,d0
	bclr	#0,d0
	move.l	d0,a0
	move.l	a0,coplist

	lea	36(a0),a0
	move.l	a0,cscreen
	lea	32000(a0),a0
	move.l	a0,pscreen
	lea	32000(a0),a0
	move.l	a0,background

	move.l	4,a6
	lea	grafname,a1
	moveq	#0,d0
	jsr	-552(a6)	openlibrary
	move.l	d0,a1
	move.l	38(a1),old
	move.l	4,a6
	jsr	-414(a6)	closelibrary

	bsr	clss
	bsr	waitframe

	lea	$dff180,a0	color0
	lea	$dff144,a1	spr0data
	moveq	#0,d0
	moveq	#15,d1
nextclc	move.l	d0,(a0)+
	move.w	d0,(a1)+
	dbf	d1,nextclc

	move.w	#$20,$dff09a	disable vert. blank interrupt
	move.w	#$4200,$dff100	4 bitplane display
	move.w	#0,$dff102	no scroll value
	move.w	#$38,$dff092	ddfstrt
	move.w	#$d0,$dff094	ddfstop
	move.w	#$3a81,$dff08e	diwstrt
	move.w	#$02c1,$dff090	diwstop
	move.w	#120,$dff108	bpl1mod
	move.w	#120,$dff10a	bpl2mod
	move.w	#$20,$dff096	disable sprite DMA
	bsr	showtitles

	move.w	#$c020,$dff09a	enable vert. blank interrupt
	move.w	#$8220,$dff096	enable sprite DMA

	move.l	old,$dff080	restore copper list
	move.w	d0,$dff088

	move.l	4,a6
	move.l	memory,a1
	move.l	#96036,d0
	jsr	-210(a6)	FreeMem
	rts


waitframe
	lea	$dff006,a0	vhposr
wfr2	btst	#0,$dff005	msb of vertical position
	beq.s	wfr2
wfr1	cmpi.b	#2,(a0)
	bcs.s	wfr1
	move.l	cscreen,d0
	move.l	pscreen,cscreen
	move.l	d0,pscreen

	move.l	coplist,a0
	moveq	#3,d1
	move.w	#$e0,d2		bpl1pth
bploop	move.w	d2,(a0)+
	swap	d0
	move.w	d0,(a0)+
	addq.w	#2,d2
	move.w	d2,(a0)+
	swap	d0
	move.w	d0,(a0)+
	addq.w	#2,d2
	addi.l	#40,d0
	dbf	d1,bploop
	move.l	#$fffffffe,(a0)+	end copper

	move.l	coplist,$dff080		set new copper list
	move.w	d0,$dff088
	rts


clss	move.w	#124,d7
	move.l	#32000,d6
	bra.s	title1
titleclsblk
	move.w	#50,d7
	move.l	#13056,d6
title1	move.l	cscreen,a0
	add.l	d6,a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	sub.l	a1,a1
clss1	movem.l	d0-d6/a1,-(a0)
	movem.l	d0-d6/a1,-(a0)
	movem.l	d0-d6/a1,-(a0)
	movem.l	d0-d6/a1,-(a0)
	movem.l	d0-d6/a1,-(a0)
	movem.l	d0-d6/a1,-(a0)
	movem.l	d0-d6/a1,-(a0)
	movem.l	d0-d6/a1,-(a0)
	dbf	d7,clss1
	rts


showtitles
	bsr	clss
	bsr	waitframe
	bsr	clss
	bsr	waitframe
	movem.l	palnew,d0-d7
	movem.l	d0-d7,$dff180
	bsr	allogo
	rts


palnew	dc.w	$000,$eee,$ccc,$aaa,$888,$666,$444,$222
	dc.w	$00a,$e8a,$e68,$e46,$fff,$c00,$a00,$800

lmasks	dc.w	$ffff,$7fff,$3fff,$1fff,$fff,$7ff,$3ff,$1ff
	dc.w	$ff,$7f,$3f,$1f,$f,7,3,1
rmasks	dc.w	0,$8000,$c000,$e000,$f000,$f800,$fc00,$fe00
	dc.w	$ff00,$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff

T	equ	0
H	equ	30
E	equ	62
A	equ	110
S	equ	140
M	equ	198
B	equ	228
L	equ	262
Y	equ	282
I	equ	308
N	equ	320


text	dc.w	-45,T
	dc.w	-38,H
	dc.w	-32,E
	dc.w	-24,A
	dc.w	-18,S
	dc.w	-12,S
	dc.w	-6,E
	dc.w	0,M
	dc.w	9,B
	dc.w	15,L
	dc.w	18,Y
	dc.w	26,L
	dc.w	32,I
	dc.w	35,N
	dc.w	41,E
	dc.w	$8000

letterT	dc.w	$ff7e,0,$50,$ffda,0,$2e,$40,$ffb4,$50
	dc.w	$ff7e,$20,0,$ffb4,$130,$76

letterH	dc.w	$ff7e,0,0,$ffda,$130,$ff7e,$30,0,$ffda
	dc.w	$130,$ff7e,0,$90,4,$30,$76

letterE	dc.w	$ff7e,$30,$e0,$ffda,$130,$2e,0,$ffb4,0
	dc.w	$2e,$30,$ffb4,$50,$ff7e,0,$90,4,$20
	dc.w	$ff7e,$20,$70,$ffda,$c0,$76

letterA	dc.w	$ff7e,0,$130,$ffda,0,$2e,$30
	dc.w	$ffb4,$130,$ff7e,0,$90,4,$30,$76

letterS	dc.w	$ff7e,0,$e0,$ffda,$130,$2e,$30,$ffb4,$c0
	dc.w	$ff7e,$20,$b0,$ffda,$a0,$ff7e,$10,$90,$ffda
	dc.w	$80,$ff7e,0,$70,$ffda,0,$2e,$30,$ffb4,$50,$76

letterM	dc.w	$ff7e,0,$130,$ffda,0,$2e,$60,$ffb4,$130
	dc.w	$ff7e,$30,0,$ffb4,$130,$76

letterB	dc.w	$ff7e,0,$130,$ffda,0,$2e,$30,$ffb4
	dc.w	$130,4,0,$ff7e,0,$90,4,$30,$76

letterL	dc.w	$ff7e,0,0,$ffda,$130,$2e,$30,$ffb4,$e0,$76

letterY	dc.w	$ff7e,0,0,$ffda,$90,4,$30,$ff7e,$30,0,$ffda,$130,$76

letterI	dc.w	$ff7e,0,0,$ffda,$130,$76

letterN	dc.w	$ff7e,0,$130,$ffda,0,$2e,$30,$ffb4,$130,$76


copybkgnd
	move.l	background,a1
	move.l	cscreen,a2
	move.w	#199,d7
copyloop
	movem.l	(a1)+,d0-d5/a3-a6
	movem.l	d0-d5/a3-a6,(a2)
	movem.l	(a1)+,d0-d5/a3-a6
	movem.l	d0-d5/a3-a6,40(a2)
	movem.l	(a1)+,d0-d5/a3-a6
	movem.l	d0-d5/a3-a6,80(a2)
	movem.l	(a1)+,d0-d5/a3-a6
	movem.l	d0-d5/a3-a6,120(a2)
	lea	160(a2),a2
	dbf	d7,copyloop
	rts


doletters
	lea	text,a0
dltrs	move.l	a0,-(a7)
	move.w	d6,-(a7)
	bsr	doletter
	move.w	(a7)+,d6
	move.l	(a7)+,a0
	addq.l	#4,a0
	cmpi.w	#$8000,(a0)
	bne.s	dltrs
	rts


doletter
	cmp.w	#$1000,d6
	blt.s	dltr
	move.w	#$1000,d6
dltr	move.l	#$1000000,d7
	divu	d6,d7
	move.w	(a0),d0
	asl.w	#4,d0
	muls	d7,d0
	swap	d0
	addi.w	#160,d0
	move.w	d0,a4
	move.w	#-$200,d0
	muls	d7,d0
	swap	d0
	addi.w	#210,d0
	move.w	d0,a5
	move.w	2(a0),a0	get letter offset
	add.l	#letterT,a0
letter	move.w	d7,d6
	rol.w	#3,d6
	andi.w	#7,d6
	bra.s	m1


do.moveto
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	mulu	d7,d0
	mulu	d7,d1
	swap	d0
	swap	d1
	add.w	a4,d0
	add.w	a5,d1

m1	move.w	(a0)+,d4
	jmp	cmd(pc,d4.w)

do.vto	move.w	(a0)+,d3
	mulu	d7,d3
	swap	d3
	add.w	a5,d3
	move.w	d0,-(a7)
	move.w	d3,-(a7)
	move.w	d0,d2
	sub.w	d6,d0
	add.w	d6,d2
	cmp.w	d1,d3
	bge.s	vto1
	exg	d1,d3
vto1	add.w	d6,d1
	sub.w	d6,d3
	bra	v1

do.vto2	move.w	(a0)+,d3
	mulu	d7,d3
	swap	d3
	add.w	a5,d3
	move.w	d0,-(a7)
	move.w	d3,-(a7)
	move.w	d0,d2
	sub.w	d6,d0
	add.w	d6,d2
	cmp.w	d1,d3
	blt.s	vto21
	add.w	d6,d1
	add.w	d6,d3
	bra.s	v1
vto21	exg	d1,d3
	sub.w	d6,d1
	sub.w	d6,d3
	bra	v1

do.vto12
	move.w	(a0)+,d3
	mulu	d7,d3
	swap	d3
	add.w	a5,d3
	move.w	d0,-(a7)
	move.w	d3,-(a7)
	move.w	d0,d2
	sub.w	d6,d0
	add.w	d6,d2
	cmp.w	d1,d3
	bge.s	vto121
	exg	d1,d3
vto121	sub.w	d6,d1
	add.w	d6,d3

v1	bsr	rectangle
	move.w	(a7)+,d1
	move.w	(a7)+,d0
	move.w	(a0)+,d4

cmd	jmp	cmd(pc,d4.w)

do.hto	move.w	(a0)+,d2
	mulu	d7,d2
	swap	d2
	add.w	a4,d2
	move.w	d1,-(a7)
	move.w	d2,-(a7)
	move.w	d1,d3
	sub.w	d6,d1
	add.w	d6,d3
	cmp.w	d0,d2
	bge.s	hto1
	exg	d0,d2
hto1	add.w	d6,d0
	sub.w	d6,d2

h1	bsr	rectangle
	move.w	(a7)+,d0
	move.w	(a7)+,d1
	move.w	(a0)+,d4
	jmp	cmd(pc,d4.w)

do.hto2	move.w	(a0)+,d2
	mulu	d7,d2
	swap	d2
	add.w	a4,d2
	move.w	d1,-(a7)
	move.w	d2,-(a7)
	move.w	d1,d3
	sub.w	d6,d1
	add.w	d6,d3
	cmp.w	d0,d2
	blt.s	hto21
	add.w	d6,d0
	add.w	d6,d2
	bra	h1
hto21	exg	d0,d2
	sub.w	d6,d0
	sub.w	d6,d2
	bra	h1

do.hto12
	move.w	(a0)+,d2
	mulu	d7,d2
	swap	d2
	add.w	a4,d2
	move.w	d1,-(a7)
	move.w	d2,-(a7)
	move.w	d1,d3
	sub.w	d6,d1
	add.w	d6,d3
	cmp.w	d0,d2
	bge.s	hto121
	exg	d0,d2
hto121	sub.w	d6,d0
	add.w	d6,d2
	bra	h1

do.ret	rts


rectangle
	tst.w	d0
	bpl.s	rect1
	clr.w	d0
rect1	tst.w	d1
	bpl.s	rect2
	clr.w	d1
rect2	cmp.w	#320,d2
	blt.s	rect3
	move.w	#319,d2
rect3	cmp.w	#200,d3
	blt.s	rect4
	move.w	#199,d3
rect4	sub.w	d0,d2
	bmi.s	do.ret
	sub.w	d1,d3
	bmi.s	do.ret
	move.l	cscreen,a2
	move.w	d1,a1
	add.w	d1,d1
	add.w	d1,d1
	add.w	a1,d1
	lsl.w	#5,d1
	add.w	d1,a2
	moveq	#$f,d1
	and.w	d0,d1
	sub.w	d1,d0
	add.w	d1,d2
	lsr.w	#3,d0
	add.w	d0,a2
	lea	lmasks(pc),a1
	add.w	d1,d1
	move.w	(a1,d1.w),d0
	moveq	#$f,d1
	and.w	d2,d1
	sub.w	d1,d2
	beq	thinrect
	swap	d0
	add.w	d1,d1
	move.w	34(a1,d1.w),d0
	move.l	d0,d1
	not.l	d1
rectlp	and.l	d1,40(a2)
	or.l	d0,80(a2)
	or.l	d0,120(a2)
	and.l	d1,(a2)+
	lea	156(a2),a2
	dbf	d3,rectlp
	rts

thinrect
	add.w	d1,d1
	and.w	34(a1,d1.w),d0
	move.w	d0,d1
	not.w	d1
thinlp	and.w	d1,40(a2)
	or.w	d0,80(a2)
	or.w	d0,120(a2)
	and.w	d1,(a2)+
	lea	158(a2),a2
	dbf	d3,thinlp
	rts


allogo	move.w	#$240,d6		bring in the text
shrink	move.w	d6,-(a7)
	bsr	copybkgnd
	bsr	doletters
	bsr	waitframe
	move.w	(a7)+,d6
	addi.w	#$40,d6
	cmp.w	#$1000,d6
	bne.s	shrink

	move.w	#$1000,d6	remove the text
expand	move.w	d6,-(a7)
	bsr	copybkgnd
	bsr	doletters
	bsr	waitframe
	move.w	(a7)+,d6
	subi.w	#$40,d6
	cmp.w	#$240,d6
	bne.s	expand
	rts


coplist	dc.l	0
cscreen	dc.l	0
pscreen	dc.l	0
background	dc.l	0
old	dc.l	0
memory	dc.l	0

grafname	dc.b	"graphics.library",0
	even
