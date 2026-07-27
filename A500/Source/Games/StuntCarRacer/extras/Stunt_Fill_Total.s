	section	test_polygon,code_c




XMAX	equ	320
YMAX	equ	200




start	move.l	4.w,a6
	jsr	-132(a6)		turn multitasking off


	move.l	#4*40*200,d0
	move.l	#$10002,d1		chip
	jsr	-198(a6)		AllocMem
	tst.l	d0
	beq	exit_now
	move.l	d0,screen.mem


	moveq	#0,d0
	lea	graf.name(pc),a1
	jsr	-552(a6)		OpenLibrary
	tst.l	d0
	beq	exit_freemem

	move.l	d0,gfxbase
;	move.l	d0,a6
;	jsr	-456(a6)		OwnBlitter




;"""""""""""""""""""""""""
;" INITIALISE INTERRUPTS "
;"			 "
;"""""""""""""""""""""""""

	lea	$dff000,a6
	move.w	intenar(a6),old.ints	save system interrupt status

	move.w	#$7fff,intena(a6)	disable all interrupts


	move.l	$14.w,old.dbz		division-by-zero exception handler
	move.l	#rte.ins,$14.w		set to rte instruction




;"""""""""""""""""""""""""""""
;" INITIALISE SCREEN DISPLAY "
;"			     "
;"""""""""""""""""""""""""""""

wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait

vp.wait	move.l	vposr(a6),d0		get vertical beam position
	and.l	#$1ff00,d0
	lsr.l	#8,d0
	cmp.w	#312,d0			wait for bottom line
	bne.s	vp.wait			before disabling sprite DMA

	move.w	#$03ff,dmacon(a6)	DMA off


	lea	colour.table(pc),a0	initialise colours
	lea	color0(a6),a1
	moveq	#8-1,d0

set.colours
	move.l	(a0)+,(a1)+
	dbra	d0,set.colours


	move.w	#$4200,bplcon0(a6)	initialise screen
	move.w	#$4881,diwstrt(a6)
	move.w	#$10c1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	moveq	#0,d0
	move.w	d0,bplcon1(a6)
	move.w	d0,bplcon2(a6)
	move.w	d0,bpl1mod(a6)
	move.w	d0,bpl2mod(a6)


	move.l	screen.mem(pc),d0	initialise copper
	lea	copper.list(pc),a0
	bsr	init.copper

	move.l	#copper.list,cop1lch(a6)
	move.w	d0,copjmp1(a6)


	move.w	#$8380,dmacon(a6)	DMA on




;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

polygon	macro
	lea	\1(pc),a1		address of coordinates
	bsr	make.polygon
	endm




test.loop
	move.b	fill.colour(pc),d0
	addq.b	#1,d0
	and.b	#15,d0
	move.b	d0,fill.colour
	move.l	#edge.space,edge.space.ptr

	polygon	poly1
	polygon	poly2
	polygon	poly3
	polygon	poly4
	polygon	poly5
	polygon	poly6
	polygon	poly7
	polygon	poly8
	polygon	poly9
	polygon	poly10
	polygon	poly11
	polygon	poly12
	polygon	poly13
	polygon	poly14
	polygon	poly15
	polygon	poly16
	polygon	poly17
	polygon	poly18
	polygon	poly19
	polygon	poly20
	polygon	poly21
	polygon	poly22
	polygon	poly23
	polygon	poly24
	polygon	poly25

	subq.w	#1,number
	bne	test.loop

	bra.s	exit




number	dc.w	100




;""""""""""""""""
;" EXIT ROUTINE	"
;"		"
;""""""""""""""""

exit	lea	$dff000,a6
	move.w	old.ints(pc),d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status


	move.l	old.dbz(pc),$14.w	restore division-by-zero handler


	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	gfxbase(pc),a0
	move.l	38(a0),cop1lch(a6)	restore system copper

	move.w	#$87f0,dmacon(a6)	DMA on


	move.l	a0,a6
;	jsr	-462(a6)		DisownBlitter

	move.l	a6,a1
	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary

exit_freemem
	move.l	#4*40*200,d0
	move.l	screen.mem(pc),a1
	jsr	-210(a6)		FreeMem

exit_now
	jsr	-138(a6)		turn multitasking on

	moveq	#0,d0
	rts




rte.ins	rte




;"""""""""""""""""""""""
;" THE POLYGON ROUTINE "
;"		       "
;"""""""""""""""""""""""

edge.space
	ds.w	4500
end.edge.space
	ds.w	500


fill.colour	dc.b	0
daft.flag	dc.b	0
standard.clip.flag	dc.b	0,0
x.values	ds.w	4
y.values	ds.w	4
edge.space.ptr	dc.l	0
road.section.offset	dc.w	0
fp.y	dc.w	0
section.data
	ds.l	4




make.polygon
	move.w	(a1)+,x.values
	move.w	(a1)+,y.values
	move.w	(a1)+,x.values+2
	move.w	(a1)+,y.values+2
	move.w	(a1)+,x.values+4
	move.w	(a1)+,y.values+4
	move.w	(a1)+,x.values+6
	move.w	(a1)+,y.values+6

	move.w	#0,road.section.offset
	move.w	#0,d1
	move.w	#2,d2
	jsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	move.w	#2,d1
	move.w	#4,d2
	jsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	move.w	#4,d1
	move.w	#6,d2
	jsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	move.w	#6,d1
	move.w	#0,d2
	jsr	clip.line.make.edge

	move.b	#$80,daft.flag
	move.w	#0,road.section.offset
	move.l	#section.data,a4
	move.w	road.section.offset,d3
	move.l	(a4,d3.w),d0
	move.l	d0,d4
	and.l	#$ffffff,d0
	beq	polygon.done

	move.l	d0,a0
	move.l	4(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq	polygon.done

	move.l	d0,a1
	move.l	8(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq	polygon.done

	move.l	d0,a2
	move.l	12(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq	polygon.done

	move.l	d0,a3
	and.l	#$f000000,d4
	bne	polygon.done

	move.b	fill.colour(pc),d0
	move.b	d0,d6
	asl.b	#4,d6
	addq.b	#2,d6
	move.b	d6,word.col+3

	clr.l	d6
	clr.l	d7
	lsr.b	#1,d0
	bcc	mask1.setA
	not.w	d6
mask1.setA
	swap	d6
	lsr.b	#1,d0
	bcc	mask2.setA
	not.w	d6
mask2.setA
	lsr.b	#1,d0
	bcc	mask3.setA
	not.w	d7
mask3.setA
	swap	d7
	lsr.b	#1,d0
	bcc	mask4.setA
	not.w	d7
mask4.setA
	jsr	simple.poly.fill

polygon.done
	move.b	#0,daft.flag
	rts


fill.word
	move.w	d4,d2
	not.w	d2
word.col
	bra	col0

col0	and.w	d2,(a4)+
	and.w	d2,7998(a4)
	and.w	d2,15998(a4)
	and.w	d2,23998(a4)
	rts

col1	or.w	d4,(a4)+
	and.w	d2,7998(a4)
	and.w	d2,15998(a4)
	and.w	d2,23998(a4)
	rts

col2	and.w	d2,(a4)+
	or.w	d4,7998(a4)
	and.w	d2,15998(a4)
	and.w	d2,23998(a4)
	rts

col3	or.w	d4,(a4)+
	or.w	d4,7998(a4)
	and.w	d2,15998(a4)
	and.w	d2,23998(a4)
	rts

col4	and.w	d2,(a4)+
	and.w	d2,7998(a4)
	or.w	d4,15998(a4)
	and.w	d2,23998(a4)
	rts

col5	or.w	d4,(a4)+
	and.w	d2,7998(a4)
	or.w	d4,15998(a4)
	and.w	d2,23998(a4)
	rts

col6	and.w	d2,(a4)+
	or.w	d4,7998(a4)
	or.w	d4,15998(a4)
	and.w	d2,23998(a4)
	rts

col7	or.w	d4,(a4)+
	or.w	d4,7998(a4)
	or.w	d4,15998(a4)
	and.w	d2,23998(a4)
	rts

col8	and.w	d2,(a4)+
	and.w	d2,7998(a4)
	and.w	d2,15998(a4)
	or.w	d4,23998(a4)
	rts

col9	or.w	d4,(a4)+
	and.w	d2,7998(a4)
	and.w	d2,15998(a4)
	or.w	d4,23998(a4)
	rts

col10	and.w	d2,(a4)+
	or.w	d4,7998(a4)
	and.w	d2,15998(a4)
	or.w	d4,23998(a4)
	rts

col11	or.w	d4,(a4)+
	or.w	d4,7998(a4)
	and.w	d2,15998(a4)
	or.w	d4,23998(a4)
	rts

col12	and.w	d2,(a4)+
	and.w	d2,7998(a4)
	or.w	d4,15998(a4)
	or.w	d4,23998(a4)
	rts

col13	or.w	d4,(a4)+
	and.w	d2,7998(a4)
	or.w	d4,15998(a4)
	or.w	d4,23998(a4)
	rts

col14	and.w	d2,(a4)+
	or.w	d4,7998(a4)
	or.w	d4,15998(a4)
	or.w	d4,23998(a4)
	rts

col15	or.w	d4,(a4)+
	or.w	d4,7998(a4)
	or.w	d4,15998(a4)
	or.w	d4,23998(a4)
	rts


simple.poly.fill
	move.w	(a2),d2
	move.w	(a0),d0
	cmp.w	(a3),d0
	bne	spf2

	cmp.w	(a1),d2
	bne	spf4

	cmp.w	d2,d0
	bge	spf4

spf1	exg	a2,a0
	exg	a3,a1
	bra	spf4

spf2	blt	spf3

	cmp.w	(a1),d2
	beq	spf1

	exg	d0,a0
	move.l	a1,a0
	move.l	a2,a1
	move.l	a3,a2
	move.l	d0,a3
	bra	spf4

spf3	cmp.w	(a1),d2
	beq	spf1

	exg	d0,a3
	move.l	a2,a3
	move.l	a1,a2
	move.l	a0,a1
	move.l	d0,a0

spf4	move.b	#2,simple.poly.count
simple.poly.fill2
	move.l	#start.masks,a5
	move.w	(a0)+,d1
	move.w	(a3)+,d0
	cmp.w	d1,d0
	bne	spfe

	addq.l	#6,a0
	addq.l	#6,a3
	move.w	d1,fp.y
	subq.w	#1,d1
	bmi	spfe

	move.l	screen.mem,a6
	clr.l	d0
	move.w	d1,d0
	asl.w	#2,d0
	add.w	d1,d0
	asl.w	#3,d0
	add.l	d0,a6

spf5	move.w	(a0)+,d4
	bpl	spf6

	subq.b	#1,simple.poly.count
	bmi	spfe

	move.l	a1,a0
	move.l	a2,a1
	move.w	(a0)+,d0
	cmp.w	fp.y,d0
	bne	spfe

	addq.l	#6,a0
	move.w	(a0)+,d4
	bpl	spf6

	subq.b	#1,simple.poly.count
	bmi	spfe

	move.l	a1,a0
	move.w	(a0)+,d0
	cmp.w	fp.y,d0
	bne	spfe

	addq.l	#6,a0
	move.w	(a0)+,d4
	bmi	spfe

spf6	move.w	(a3)+,d5
	bpl	spf7

	subq.b	#1,simple.poly.count
	bmi	spfe

	move.l	a2,a3
	move.l	a1,a2
	move.w	(a3)+,d0
	cmp.w	fp.y,d0
	bne	spfe

	addq.l	#6,a3
	move.w	(a3)+,d5
	bpl	spf7

	subq.b	#1,simple.poly.count
	bmi	spfe

	move.l	a2,a3
	move.w	(a3)+,d0
	cmp.w	fp.y,d0
	bne	spfe

	addq.l	#6,a3
	move.w	(a3)+,d5
	bmi	spfe

spf7	cmp.w	d4,d5
	bgt	spf8
	beq	spfd

	tst.b	daft.flag
	bpl	spfd
	bra	spfe

spf8	move.w	d4,d1
	and.w	#$fff0,d1
	lsr.w	#3,d1
	lea	(a6,d1.w),a4
	move.w	d4,d3
	move.w	d5,d1
	lsr.w	#4,d3
	lsr.w	#4,d1
	sub.w	d3,d1
	bne	spf9

	and.w	#$f,d4
	asl.w	#2,d4
	move.w	(a5,d4.w),d4

	and.w	#$f,d5
	asl.w	#2,d5
	move.w	64(a5,d5.w),d5
	and.w	d5,d4
	jsr	fill.word
	bra	spfd

spf9	subq.b	#1,d1
	and.w	#$f,d4
	beq	spfa

	asl.w	#2,d4
	move.w	(a5,d4.w),d4
	jsr	fill.word
	subq.w	#1,d1
	bmi	spfc

spfa	move.l	d6,d2
	move.l	d7,d3
	swap	d2
	swap	d3

spfb	move.w	d2,(a4)+
	move.w	d6,7998(a4)
	move.w	d3,15998(a4)
	move.w	d7,23998(a4)
	dbra	d1,spfb

spfc	and.w	#$f,d5
	beq	spfd

	asl.w	#2,d5
	move.w	64(a5,d5.w),d4
	jsr	fill.word

spfd	subq.w	#1,fp.y
	sub.l	#40,a6
	cmp.l	screen.mem,a6
	bge	spf5

spfe	clr.l	d1
	clr.l	d2
	rts


start.masks
	dc.w	$ffff,$ffff,$7fff,$7fff,$3fff,$3fff,$1fff,$1fff
	dc.w	$0fff,$0fff,$07ff,$07ff,$03ff,$03ff,$01ff,$01ff
	dc.w	$00ff,$00ff,$007f,$007f,$003f,$003f,$001f,$001f
	dc.w	$000f,$000f,$0007,$0007,$0003,$0003,$0001,$0001

end.masks
	dc.w	$0000,$0000,$8000,$8000,$c000,$c000,$e000,$e000
	dc.w	$f000,$f000,$f800,$f800,$fc00,$fc00,$fe00,$fe00
	dc.w	$ff00,$ff00,$ff80,$ff80,$ffc0,$ffc0,$ffe0,$ffe0
	dc.w	$fff0,$fff0,$fff8,$fff8,$fffc,$fffc,$fffe,$fffe


simple.poly.count	dc.b	0,0
straight.edge.count	dc.w	0
straight.edge.value	dc.w	0
y.saved	dc.w	0

clip.line.make.edge
	move.l	#section.data,a1
	move.w	#0,y.saved
	move.w	#-1,straight.edge.count
	move.w	road.section.offset,d0
	move.l	edge.space.ptr,a0
	cmp.l	#end.edge.space,a0
	blt	clme1

	tst.b	standard.clip.flag
	bmi	clme1

	move.l	#$80000000,(a1,d0.w)
	clr.w	d1
	clr.w	d2
	rts

clme1	move.l	a0,(a1,d0.w)
	move.l	a0,a2
	add.l	#8,a0
	move.l	#x.values,a4
	move.l	#y.values,a5
	move.w	(a4,d1.w),d4
	move.w	(a4,d2.w),d6
	move.w	(a5,d1.w),d5
	move.w	(a5,d2.w),d7
	cmp.w	d7,d5
	bge	clme2

	exg	d7,d5
	exg	d6,d4
	or.b	#$40,(a1,d0.w)

clme2	move.w	#0,d0
	move.w	d0,d3
	cmp.w	#XMAX,d4
	bcs	clme4
	tst.w	d4
	bpl	clme3
	bset	#3,d0
	bra	clme4

clme3	bset	#2,d0
clme4	cmp.w	#XMAX,d6
	bcs	clme6
	tst.w	d6
	bpl	clme5
	bset	#3,d3
	bra	clme6

clme5	bset	#2,d3
clme6	cmp.w	#YMAX,d5
	bcs	clme8
	tst.w	d5
	bpl	clme7
	bset	#1,d0
	bra	clme8

clme7	bset	#0,d0
clme8	cmp.w	#YMAX,d7
	bcs	clmea
	tst.w	d7
	bpl	clme9
	bset	#1,d3
	bra	clmea

clme9	bset	#0,d3
clmea	move.b	d0,d1
	move.b	d3,d2
	swap	d0
	move.b	d1,d0
	or.b	d2,d0
	and.b	#$f,d0
	beq	clme55

	move.b	d1,d0
	and.b	d2,d0
	and.b	#$f,d0
	beq	clmeb

	jsr	edge.off.screen
	clr.w	d1
	clr.w	d2
	rts

clmeb	swap	d0
	btst	#1,d1
	beq	clme12
	bclr	#7,d1
	move.w	d6,d0
	sub.w	d4,d0
	bpl	clmec
	bset	#7,d1
	neg.w	d0

clmec	move.w	d7,d3
	sub.w	d5,d3
	bpl	clmed
	bchg	#7,d1
	neg.w	d3

clmed	neg.w	d5
	cmp.w	d0,d3
	blt	clmee
	beq	clme10
	swap	d0
	clr.w	d0
	divu	d3,d0
	mulu	d0,d5
	swap	d5
	bra	clme10

clmee	cmp.w	d3,d5
	blt	clmef
	move.w	d0,d5
	bra	clme10

clmef	swap	d5
	clr.w	d5
	divu	d3,d5
	mulu	d0,d5
	swap	d5

clme10	tst.b	d1
	bpl	clme11
	neg.w	d5

clme11	add.w	d5,d4
	move.w	#0,d5
	bra	clme19

clme12	btst	#0,d1
	beq	clme1d
	bclr	#7,d1
	move.w	d6,d0
	sub.w	d4,d0
	bpl	clme13
	bset	#7,d1
	neg.w	d0

clme13	move.w	d7,d3
	sub.w	d5,d3
	bpl	clme14
	bchg	#7,d1
	neg.w	d3

clme14	sub.w	#YMAX,d5
	cmp.w	d0,d3
	blt	clme15
	beq	clme17
	swap	d0
	clr.w	d0
	divu	d3,d0
	mulu	d0,d5
	swap	d5
	bra	clme17

clme15	cmp.w	d3,d5
	blt	clme16
	move.w	d0,d5
	bra	clme17

clme16	swap	d5
	clr.w	d5
	divu	d3,d5
	mulu	d0,d5
	swap	d5

clme17	tst.b	d1
	bmi	clme18
	neg.w	d5

clme18	add.w	d5,d4
	move.w	#YMAX,d5

clme19	and.b	#$f0,d1
	cmp.w	#XMAX,d4
	bcs	clme1b
	tst.w	d4
	bpl	clme1a
	bset	#3,d1
	bra	clme1b

clme1a	bset	#2,d1

clme1b	swap	d0
	move.b	d1,d0
	or.b	d2,d0
	and.b	#$f,d0
	beq	clme55

	move.b	d1,d0
	and.b	d2,d0
	and.b	#$f,d0
	beq	clme1c

	jsr	edge.off.screen
	clr.w	d1
	clr.w	d2
	rts

clme1c	swap	d0
clme1d	btst	#1,d2
	beq	clme24
	bclr	#7,d1
	move.w	d6,d0
	sub.w	d4,d0
	bpl	clme1e
	bset	#7,d1
	neg.w	d0

clme1e	move.w	d7,d3
	sub.w	d5,d3
	bpl	clme1f
	bchg	#7,d1
	neg.w	d3

clme1f	neg.w	d7
	cmp.w	d0,d3
	blt	clme20
	beq	clme22
	swap	d0
	clr.w	d0
	divu	d3,d0
	mulu	d0,d7
	swap	d7
	bra	clme22

clme20	cmp.w	d3,d7
	blt	clme21
	move.w	d0,d7
	bra	clme22

clme21	swap	d7
	clr.w	d7
	divu	d3,d7
	mulu	d0,d7
	swap	d7

clme22	tst.b	d1
	bpl	clme23
	neg.w	d7

clme23	add.w	d7,d6
	move.w	#0,d7
	bra	clme2b

clme24	btst	#0,d2
	beq	clme2f
	bclr	#7,d1
	move.w	d6,d0
	sub.w	d4,d0
	bpl	clme25
	bset	#7,d1
	neg.w	d0

clme25	move.w	d7,d3
	sub.w	d5,d3
	bpl	clme26
	bchg	#7,d1
	neg.w	d3

clme26	sub.w	#YMAX,d7
	cmp.w	d0,d3
	blt	clme27
	beq	clme29
	swap	d0
	clr.w	d0
	divu	d3,d0
	mulu	d0,d7
	swap	d7
	bra	clme29

clme27	cmp.w	d3,d7
	blt	clme28
	move.w	d0,d7
	bra	clme29

clme28	swap	d7
	clr.w	d7
	divu	d3,d7
	mulu	d0,d7
	swap	d7

clme29	tst.b	d1
	bmi	clme2a
	neg.w	d7

clme2a	add.w	d7,d6
	move.w	#YMAX,d7

clme2b	and.b	#$f0,d2
	cmp.w	#XMAX,d6
	bcs	clme2d
	tst.w	d6
	bpl	clme2c
	bset	#3,d2
	bra	clme2d

clme2c	bset	#2,d2

clme2d	swap	d0
	move.b	d1,d0
	or.b	d2,d0
	and.b	#$f,d0
	beq	clme55

	move.b	d1,d0
	and.b	d2,d0
	and.b	#$f,d0
	beq	clme2e

	jsr	edge.off.screen
	clr.w	d1
	clr.w	d2
	rts

clme2e	swap	d0
clme2f	move.w	d5,(a2)
	move.w	d7,2(a2)
	subq.b	#1,y.saved
	btst	#3,d1
	beq	clme3a
	move.w	d5,-(sp)
	bclr	#7,d1
	move.w	d6,d0
	sub.w	d4,d0
	bpl	clme30
	bset	#7,d1
	neg.w	d0

clme30	move.w	d7,d3
	sub.w	d5,d3
	bpl	clme31
	bchg	#7,d1
	neg.w	d3

clme31	neg.w	d4
	cmp.w	d3,d0
	blt	clme32
	beq	clme34
	swap	d3
	clr.w	d3
	divu	d0,d3
	mulu	d3,d4
	swap	d4
	bra	clme34

clme32	cmp.w	d0,d4
	blt	clme33
	move.w	d3,d4
	bra	clme34

clme33	swap	d4
	clr.w	d4
	divu	d0,d4
	mulu	d3,d4
	swap	d4

clme34	tst.b	d1
	bpl	clme35
	neg.w	d4

clme35	add.w	d4,d5
	move.w	#0,d4
	move.w	(sp)+,d3
	tst.b	standard.clip.flag
	bpl	clme36
	move.w	d5,d3
	move.w	d5,(a2)

clme36	sub.w	d5,d3
	bmi	clme39
	bra	clme38

clme37	move.w	#0,(a0)+
clme38	dbra	d3,clme37
clme39	bra	clme44

clme3a	btst	#2,d1
	beq	clme44
	move.w	d5,-(sp)
	bclr	#7,d1
	move.w	d6,d0
	sub.w	d4,d0
	bpl	clme3b
	bset	#7,d1
	neg.w	d0

clme3b	move.w	d7,d3
	sub.w	d5,d3
	bpl	clme3c
	bchg	#7,d1
	neg.w	d3

clme3c	sub.w	#XMAX,d4
	cmp.w	d3,d0
	blt	clme3d
	beq	clme3f
	swap	d3
	clr.w	d3
	divu	d0,d3
	mulu	d3,d4
	swap	d4
	bra	clme3f

clme3d	cmp.w	d0,d4
	blt	clme3e
	move.w	d3,d4
	bra	clme3f

clme3e	swap	d4
	clr.w	d4
	divu	d0,d4
	mulu	d3,d4
	swap	d4

clme3f	tst.b	d1
	bmi	clme40
	neg.w	d4

clme40	add.w	d4,d5
	move.w	#XMAX,d4
	move.w	(sp)+,d3
	tst.b	standard.clip.flag
	bpl	clme41
	move.w	d5,d3
	move.w	d5,(a2)

clme41	sub.w	d5,d3
	bmi	clme44
	bra	clme43

clme42	move.w	#XMAX,(a0)+
clme43	dbra	d3,clme42

clme44	btst	#3,d2
	beq	clme4d
	move.w	d7,-(sp)
	bclr	#7,d1
	move.w	d6,d0
	sub.w	d4,d0
	bpl	clme45
	bset	#7,d1
	neg.w	d0

clme45	move.w	d7,d3
	sub.w	d5,d3
	bpl	clme46
	bchg	#7,d1
	neg.w	d3

clme46	neg.w	d6
	cmp.w	d3,d0
	blt	clme47
	beq	clme49
	swap	d3
	clr.w	d3
	divu	d0,d3
	mulu	d3,d6
	swap	d6
	bra	clme49

clme47	cmp.w	d0,d6
	blt	clme48
	move.w	d3,d6
	bra	clme49

clme48	swap	d6
	clr.w	d6
	divu	d0,d6
	mulu	d3,d6
	swap	d6

clme49	tst.b	d1
	bpl	clme4a
	neg.w	d6

clme4a	add.w	d6,d7
	move.w	#0,d6
	move.w	d7,d3
	sub.w	(sp)+,d3
	subq.w	#1,d3
	tst.b	standard.clip.flag
	bpl	clme4b
	move.w	d7,2(a2)
	bra	clme4c

clme4b	move.w	d3,straight.edge.count
	move.w	#0,straight.edge.value
clme4c	bra	clme55

clme4d	btst	#2,d2
	beq	clme55
	move.w	d7,-(sp)
	bclr	#7,d1
	move.w	d6,d0
	sub.w	d4,d0
	bpl	clme4e
	bset	#7,d1
	neg.w	d0

clme4e	move.w	d7,d3
	sub.w	d5,d3
	bpl	clme4f
	bchg	#7,d1
	neg.w	d3

clme4f	sub.w	#XMAX,d6
	cmp.w	d3,d0
	blt	clme50
	beq	clme52
	swap	d3
	clr.w	d3
	divu	d0,d3
	mulu	d3,d6
	swap	d6
	bra	clme52

clme50	cmp.w	d0,d6
	blt	clme51
	move.w	d3,d6
	bra	clme52

clme51	swap	d6
	clr.w	d6
	divu	d0,d6
	mulu	d3,d6
	swap	d6

clme52	tst.b	d1
	bmi	clme53
	neg.w	d6

clme53	add.w	d6,d7
	move.w	#XMAX,d6
	move.w	d7,d3
	sub.w	(sp)+,d3
	subq.w	#1,d3
	tst.b	standard.clip.flag
	bpl	clme54
	move.w	d7,2(a2)
	bra	clme55

clme54	move.w	d3,straight.edge.count
	move.w	#XMAX,straight.edge.value

clme55	move.w	d5,d2
	sub.w	d7,d2
	move.w	d4,d1
	sub.w	d6,d1
	bpl	clme61
	neg.w	d1
	cmp.w	d2,d1
	blt	clme5b
	tst.w	y.saved
	bmi	clme56
	move.w	d5,(a2)
	move.w	d7,2(a2)

clme56	move.w	d4,4(a2)
	move.w	d6,6(a2)
	move.w	d1,d3
	lsr.w	#1,d3
	not.w	d3
	bra	clme58

clme57	addq.w	#1,d4
	add.w	d2,d3
	bcc	clme58
	sub.w	d1,d3
	subq.w	#1,d5
	move.w	d4,(a0)+

clme58	cmp.w	d6,d4
	bne	clme57
	move.w	straight.edge.count,d0
	bmi	clme5a

clme59	move.w	straight.edge.value,(a0)+
	dbra	d0,clme59

clme5a	move.w	#$8000,(a0)+
	move.l	a0,edge.space.ptr
	clr.w	d1
	clr.w	d2
	rts

clme5b	tst.w	y.saved
	bmi	clme5c
	move.w	d5,(a2)
	move.w	d7,2(a2)

clme5c	move.w	d4,4(a2)
	move.w	d6,6(a2)
	move.w	d2,d3
	lsr.w	#1,d3
	not.w	d3
	bra	clme5e

clme5d	subq.w	#1,d5
	move.w	d4,(a0)+
	add.w	d1,d3
	bcc	clme5e
	sub.w	d2,d3
	addq.w	#1,d4

clme5e	cmp.w	d7,d5
	bne	clme5d
	move.w	straight.edge.count,d0
	bmi	clme60

clme5f	move.w	straight.edge.value,(a0)+
	dbra	d0,clme5f

clme60	move.w	#$8000,(a0)+
	move.l	a0,edge.space.ptr
	clr.w	d1
	clr.w	d2
	rts

clme61	cmp.w	d2,d1
	blt	clme67
	tst.w	y.saved
	bmi	clme62
	move.w	d5,(a2)
	move.w	d7,2(a2)

clme62	move.w	d4,4(a2)
	move.w	d6,6(a2)
	move.w	d1,d3
	lsr.w	#1,d3
	not.w	d3
	bra	clme64

clme63	subq.w	#1,d4
	add.w	d2,d3
	bcc	clme64
	sub.w	d1,d3
	subq.w	#1,d5
	move.w	d4,(a0)+

clme64	cmp.w	d6,d4
	bne	clme63
	move.w	straight.edge.count,d0
	bmi	clme66

clme65	move.w	straight.edge.value,(a0)+
	dbra	d0,clme65

clme66	move.w	#$8000,(a0)+
	move.l	a0,edge.space.ptr
	clr.w	d1
	clr.w	d2
	rts

clme67	tst.w	y.saved
	bmi	clme68
	move.w	d5,(a2)
	move.w	d7,2(a2)

clme68	move.w	d4,4(a2)
	move.w	d6,6(a2)
	move.w	d2,d3
	lsr.w	#1,d3
	not.w	d3
	bra	clme6a

clme69	subq.w	#1,d5
	move.w	d4,(a0)+
	add.w	d1,d3
	bcc	clme6a
	sub.w	d2,d3
	subq.w	#1,d4

clme6a	cmp.w	d7,d5
	bne	clme69
	move.w	straight.edge.count,d0
	bmi	clme6c

clme6b	move.w	straight.edge.value,(a0)+
	dbra	d0,clme6b

clme6c	move.w	#$8000,(a0)+
	move.l	a0,edge.space.ptr
	clr.w	d1
	clr.w	d2
	rts


edge.off.screen
	move.w	road.section.offset,d3
	or.b	#$80,d0
	or.b	d0,(a1,d3.w)
	tst.w	d4
	bpl	eos1
	move.w	#0,d4

eos1	cmp.w	#XMAX,d4
	blt	eos2
	move.w	#XMAX,d4

eos2	tst.w	d6
	bpl	eos3
	move.w	#0,d6

eos3	cmp.w	#XMAX,d6
	blt	eos4
	move.w	#XMAX,d6

eos4	lsr.b	#1,d0
	bcc	eos5
	move.w	#YMAX,(a2)
	move.w	#YMAX,2(a2)
	move.w	d4,4(a2)
	move.w	d6,6(a2)
	move.w	#$8000,(a0)+
	move.l	a0,edge.space.ptr
	rts

eos5	lsr.b	#1,d0
	bcc	eos6
	move.l	#0,(a2)
	move.w	d4,4(a2)
	move.w	d6,6(a2)
	move.w	#$8000,(a0)+
	move.l	a0,edge.space.ptr
	rts

eos6	cmp.w	d7,d5
	bge	eos7
	exg	d7,d5

eos7	lsr.b	#1,d0
	bcc	eosf
	tst.w	d5
	bpl	eos8
	move.w	#0,d5

eos8	cmp.w	#YMAX,d5
	bcs	eos9
	move.w	#YMAX,d5

eos9	move.w	d5,(a2)
	tst.w	d7
	bpl	eosa
	move.w	#0,d7

eosa	cmp.w	#YMAX,d7
	bcs	eosb
	move.w	#YMAX,d7

eosb	move.w	d7,2(a2)
	move.w	d4,4(a2)
	move.w	d6,6(a2)
	move.w	#XMAX,d3
	sub.w	d7,d5
	bpl	eosd
	bra	eose

eosc	move.w	d3,(a0)+
eosd	dbra	d5,eosc
eose	move.w	#$8000,(a0)+
	move.l	a0,edge.space.ptr
	rts

eosf	lsr.b	#1,d0
	bcc	eos17
	tst.w	d5
	bpl	eos10
	move.w	#0,d5

eos10	cmp.w	#YMAX,d5
	bcs	eos11
	move.w	#YMAX,d5

eos11	move.w	d5,(a2)
	tst.w	d7
	bpl	eos12
	move.w	#0,d7

eos12	cmp.w	#YMAX,d7
	bcs	eos13
	move.w	#YMAX,d7

eos13	move.w	d7,2(a2)
	move.w	d4,4(a2)
	move.w	d6,6(a2)
	move.w	#0,d3
	sub.w	d7,d5
	bpl	eos15
	bra	eos16

eos14	move.w	d3,(a0)+
eos15	dbra	d5,eos14
eos16	move.w	#$8000,(a0)+
	move.l	a0,edge.space.ptr
	rts
eos17	rts




init.copper
	moveq	#4-1,d1
	move.l	#40*200,d2		size of one bitplane

next.plane
	move.w	d0,6(a0)		save low word
	swap	d0
	move.w	d0,2(a0)		save high word
	swap	d0
	add.l	d2,d0			next bitplane
	addq.w	#8,a0			update pointer to copper list
	dbra	d1,next.plane
	rts




;"""""""""""""""""""
;" THE COPPER LIST "
;"		   "
;"""""""""""""""""""

copper.list
	dc.w	bpl1pth,0		4 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

	dc.w	$ffff,$fffe




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




;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

screen.mem	dc.l	0

gfxbase		dc.l	0
old.ints	dc.w	0
old.dbz		dc.l	0




;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

graf.name	dc.b	'graphics.library',0
		even




;"""""""""""""""""
;" GRAPHICS DATA "
;"		 "
;"""""""""""""""""

colour.table
	dc.w	$000,$060,$0a0,$0e0,$400,$800,$c00,$e00
	dc.w	$004,$008,$00c,$00e,$444,$888,$ccc,$eee



poly1	dc.w	27,4		coordinates must go clockwise
	dc.w	55,9
	dc.w	51,20
	dc.w	21,25

poly2	dc.w	64,26
	dc.w	83,2
	dc.w	98,3
	dc.w	96,26

poly3	dc.w	156,22
	dc.w	115,17
	dc.w	132,3
	dc.w	149,4

poly4	dc.w	201,21
	dc.w	216,62
	dc.w	183,39
	dc.w	181,21

poly5	dc.w	169,104
	dc.w	205,104
	dc.w	215,119
	dc.w	169,112

poly6	dc.w	144,184
	dc.w	125,157
	dc.w	162,156
	dc.w	170,179

poly7	dc.w	127,112
	dc.w	61,127
	dc.w	51,78
	dc.w	155,71

poly8	dc.w	175,190
	dc.w	277,108
	dc.w	254,186
	dc.w	197,194

poly9	dc.w	318,52
	dc.w	313,162
	dc.w	286,134
	dc.w	292,107

poly10	dc.w	63,155
	dc.w	111,152
	dc.w	131,180
	dc.w	67,175

poly11	dc.w	7,119
	dc.w	27,124
	dc.w	20,135
	dc.w	12,135

poly12	dc.w	137,53
	dc.w	38,68
	dc.w	78,41
	dc.w	116,45

poly13	dc.w	146,151
	dc.w	113,144
	dc.w	153,106
	dc.w	189,139

poly14	dc.w	231,61
	dc.w	240,110
	dc.w	205,76
	dc.w	215,68

poly15	dc.w	314,6
	dc.w	182,16
	dc.w	174,7
	dc.w	212,2

poly16	dc.w	7,196
	dc.w	5,150
	dc.w	31,138
	dc.w	60,175

poly17	dc.w	172,32
	dc.w	170,47
	dc.w	134,43
	dc.w	105,37

poly18	dc.w	39,48
	dc.w	10,47
	dc.w	40,32
	dc.w	57,43

poly19	dc.w	259,108
	dc.w	224,36
	dc.w	308,18
	dc.w	295,91

poly20	dc.w	180,199
	dc.w	49,194
	dc.w	74,184
	dc.w	94,181

poly21	dc.w	6,71
	dc.w	22,65
	dc.w	44,94
	dc.w	2,109

poly22	dc.w	314,182
	dc.w	315,197
	dc.w	263,194
	dc.w	277,135

poly23	dc.w	155,97
	dc.w	166,62
	dc.w	181,54
	dc.w	212,97

poly24	dc.w	101,147
	dc.w	67,147
	dc.w	45,141
	dc.w	109,130

poly25	dc.w	189,169
	dc.w	177,149
	dc.w	235,116
	dc.w	212,155
