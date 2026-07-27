	section	Far_Road,code_c




XMAX	equ	256
YMAX	equ	128




line	macro
	move.w	#\1,d0
	move.w	#\2,d1
	move.w	#\3,d2
	move.w	#\4,d3
	bsr	draw.line
	endm




start	move.l	4.w,a6
	jsr	-132(a6)		Forbid


	move.l	#2*4*40*200,d0
	move.l	#$10002,d1		clear chip
	jsr	-198(a6)		AllocMem
	tst.l	d0
	beq	exit_now
	move.l	d0,screen.mem


	move.l	d0,screen1
	add.l	#4*40*200,d0
	move.l	d0,screen2


	moveq	#0,d0
	lea	graf.name(pc),a1
	jsr	-552(a6)		OpenLibrary
	tst.l	d0
	beq	exit_freemem

	move.l	d0,gfxbase
	move.l	d0,a6
	jsr	-456(a6)		OwnBlitter




;"""""""""""""""""""""""""
;" INITIALISE INTERRUPTS "
;"			 "
;"""""""""""""""""""""""""

	lea	$dff000,a6
	move.w	intenar(a6),old.ints	save system interrupt status

	move.w	#$7fff,intena(a6)	disable all interrupts

	move.b	#%00010111,$bfed01	set CIA-A ICR

	move.l	$68.w,old.level2
	move.l	$6c.w,old.level3
	move.l	#new.level2,$68.w
	move.l	#new.level3,$6c.w

	move.w	#$c018,intena(a6)	enable copper and level2 interrupts


	move.l	$14.w,old.dbz		division-by-zero exception handler
	move.l	#rte.ins,$14.w		set to rte instruction




;"""""""""""""""""""""""""""""
;" INITIALISE SCREEN DISPLAY "
;"			     "
;"""""""""""""""""""""""""""""

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
	moveq	#3*40,d0
	move.w	d0,bpl1mod(a6)
	move.w	d0,bpl2mod(a6)


	bsr	make.copper.lists	initialise copper

	move.l	copper2(pc),cop1lch(a6)
	move.w	d0,copjmp1(a6)


	move.w	#$87c0,dmacon(a6)	DMA on




;"""""""""""""""""""""
;" CALCULATE Y-TABLE "
;"		     "
;"""""""""""""""""""""

	move.w	#200-1,d0
	moveq	#0,d1			offset starts at zero
	move.w	#4*40,d2		width of four bitplanes
	lea	y.table(pc),a0

y.tab.loop
	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,y.tab.loop




	bsr	draw.borders




	move.b	#11,player.map.z
	move.b	#0,player.map.x

	move.w	#$c000,W.1bc30

	move.b	#250,B.1bb2e
	move.b	#252,B.1bb32

	move.b	#193,B.1bb23
	move.b	#1,B.1bb27

	move.w	#632,W.1bbfa

	move.b	#2,clip.flag

;	move.w	#95,x.values
;	move.w	#120,x.values+2
;	move.w	#53,y.values
;	move.w	#53,y.values+2
;	move.w	#$500,DAT.1be70
;	move.w	#$500,DAT.1be70+2

;	move.w	#0,x.values+120
;	move.w	#120,x.values+122
;	move.w	#0,y.values+120
;	move.w	#65,y.values+122
;	move.w	#$8000,DAT.1be70+120
;	move.w	#$200,DAT.1be70+122




;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

loop	bsr	frames.per.sec

	bsr	make.z.sin.cos

	move.b	saved.current.road.section(pc),current.road.section
	move.w	#$ff7e,W.660fc
	move.w	#$ffe0,W.660fe
	moveq	#0,d1
	moveq	#0,d2
	bsr	make.far.track.coords
;	bsr	plot.far.track.coords
	bsr	draw.far.track.edges

;	moveq	#0,d0
;	move.b	raw.key.code(pc),d0
;	bsr	make.hexw
;	move.w	#12,d0
;	move.w	#178,d1
;	lea	hex.textw(pc),a0
;	bsr	print

	bsr	keyboard.requests

	bsr	update.screens

	sf	next.frame
vbl	tst.b	next.frame
	beq.s	vbl

	bsr	clear.window

	btst	#6,$bfe001
	bne	loop




;""""""""""""""""
;" EXIT ROUTINE	"
;"		"
;""""""""""""""""

	lea	$dff000,a6

wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait


	move.w	#$7fff,intena(a6)	disable all interrupts

	move.b	#%10011010,$bfed01	restore CIA-A ICR

	move.l	old.level2(pc),$68.w
	move.l	old.level3(pc),$6c.w

	move.w	old.ints(pc),d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status


	move.l	old.dbz(pc),$14.w	restore division-by-zero handler


	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	gfxbase(pc),a0
	move.l	38(a0),cop1lch(a6)	restore system copper

	move.w	#$87f0,dmacon(a6)	DMA on


	move.l	a0,a6
	jsr	-462(a6)		DisownBlitter

	move.l	a6,a1
	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary

exit_freemem
	move.l	#2*4*40*200,d0
	move.l	screen.mem(pc),a1
	jsr	-210(a6)		FreeMem

exit_now
	jsr	-138(a6)		Permit

	moveq	#0,d0
	rts




;"""""""""""""""""""""
;" LEVEL 2 INTERRUPT "
;"		     "
;"""""""""""""""""""""

new.level2
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	move.w	#$8,intreq+$dff000

	lea	$bfe001,a0

	btst	#3,$d00(a0)		read CIA-A ICR
	beq.s	end.level2		if key not pressed

	move.b	$c00(a0),d0		get raw key code
	not.b	d0
	ror.b	#1,d0
	move.b	d0,raw.key.code

	bset	#6,$e00(a0)		set SP to output

	moveq	#54,d0

hand.shake
	dbra	d0,hand.shake		output handshake pulse

	bclr	#6,$e00(a0)		set SP back to input

end.level2
	move.l	(sp)+,a0
	move.l	(sp)+,d0
rte.ins	rte




;"""""""""""""""""""""
;" LEVEL 3 INTERRUPT "
;"		     "
;"""""""""""""""""""""

new.level3
;	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$10,intreq+$dff000

	st	next.frame

;	movem.l	(sp)+,d0-d7/a0-a6
	rte




;"""""""""""""""
;" SUBROUTINES "
;"	       "
;"""""""""""""""

keyboard.requests
	move.b	raw.key.code(pc),d0
	beq	keys.checked

check.z	cmp.b	#$31,d0
	bne.s	check.x

	add.w	#256,z.angle
	bra	keys.checked

check.x	cmp.b	#$32,d0
	bne.s	check.a

	sub.w	#256,z.angle
	bra	keys.checked

check.a	cmp.b	#$20,d0
	bne.s	check.s

	addq.b	#1,saved.current.road.section
	bra	keys.checked

check.s	cmp.b	#$21,d0
	bne.s	check.up

	subq.b	#1,saved.current.road.section
	bra	keys.checked

check.up
	cmp.b	#$4c,d0
	bne.s	check.down

	addq.b	#1,player.map.z
	bra	keys.checked

check.down
	cmp.b	#$4d,d0
	bne.s	check.right

	subq.b	#1,player.map.z
	bra	keys.checked

check.right
	cmp.b	#$4e,d0
	bne.s	check.left

	addq.b	#1,player.map.x
	bra	keys.checked

check.left
	cmp.b	#$4f,d0
	bne.s	check.del

	subq.b	#1,player.map.x
	bra	keys.checked

check.del
	cmp.b	#$46,d0
	bne.s	check.help

	add.w	#$4000,W.1bc30
	bra	keys.checked

check.help
	cmp.b	#$5f,d0
	bne.s	check.9

	sub.w	#$4000,W.1bc30
	bra	keys.checked

check.9	cmp.b	#$09,d0
	bne.s	check.0

	addq.b	#1,B.1bb2e
	bra	keys.checked

check.0	cmp.b	#$0a,d0
	bne.s	check.o

	subq.b	#1,B.1bb2e
	bra	keys.checked

check.o	cmp.b	#$18,d0
	bne.s	check.p

	addq.b	#1,B.1bb32
	bra	keys.checked

check.p	cmp.b	#$19,d0
	bne.s	check.l

	subq.b	#1,B.1bb32
	bra	keys.checked

check.l	cmp.b	#$28,d0
	bne.s	check.semi

	addq.b	#1,B.1bb23
	bra	keys.checked

check.semi
	cmp.b	#$29,d0
	bne.s	check.stop

	subq.b	#1,B.1bb23
	bra	keys.checked

check.stop
	cmp.b	#$39,d0
	bne.s	check.slash

	addq.b	#1,B.1bb27
	bra.s	keys.checked

check.slash
	cmp.b	#$3a,d0
	bne.s	check.5

	subq.b	#1,B.1bb27
	bra.s	keys.checked

check.5	cmp.b	#$05,d0
	bne.s	check.6

	addq.w	#8,W.1bc2e
	bra.s	keys.checked

check.6	cmp.b	#$06,d0
	bne.s	check.t

	subq.w	#8,W.1bc2e
	bra.s	keys.checked

check.t	cmp.b	#$14,d0
	bne.s	check.y

	addq.w	#8,x.amount
	bra.s	keys.checked

check.y	cmp.b	#$15,d0
	bne.s	check.g

	subq.w	#8,x.amount
	bra.s	keys.checked

check.g	cmp.b	#$24,d0
	bne.s	check.h

	addq.w	#8,W.1bbfa
	bra.s	keys.checked

check.h	cmp.b	#$25,d0
	bne.s	check.b

	subq.w	#8,W.1bbfa
	bra.s	keys.checked

check.b	cmp.b	#$35,d0
	bne.s	check.n

	addq.w	#8,W.1bc36
	bra.s	keys.checked

check.n	cmp.b	#$36,d0
	bne.s	keys.checked

	subq.w	#8,W.1bc36

keys.checked
	rts




clear.window
	lea	$dff000,a6
	move.l	#$1000000,bltcon0(a6)
	move.l	screen1(pc),a3
	lea	36*4*40+4(a3),a3
	move.l	a3,bltdpth(a6)
	move.w	#8,bltdmod(a6)
	move.w	#128*4*64+16,bltsize(a6)

wait2	btst	#6,dmaconr(a6)
	bne.s	wait2
	rts




road.visible.range.table
	dcb.b	44,120
	dcb.b	36,0

road.section.z.offset	dc.w	0
road.section.x.offset	dc.w	0


make.far.track.coords
	clr.w	d0
	move.b	current.road.section,d0
	move.l	#far.section.ptrs,a0
	asl.w	#2,d0
	move.l	(a0,d0.w),a6
	move.w	#4,d1

mftc1	move.w	(a6)+,d0
	move.l	#far.section.flags,a0
	move.w	d0,(a0,d1.w)
	move.w	d0,current.far.section.flag
	move.b	d0,current.road.section

	jsr	fetch.x.z.position

	move.b	road.section.z.offset,d0
	ext.w	d0
	move.b	B.1bb2e,d4
	asl.w	#8,d4
	move.b	B.1bb23,d4
	asr.w	#1,d4
	asl.w	#2,d0
	asl.w	#8,d0
	add.w	d0,d4
	move.w	d4,road.section.z.offset

	move.b	road.section.x.offset,d0
	ext.w	d0
	move.b	B.1bb32,d4
	asl.w	#8,d4
	move.b	B.1bb27,d4
	asr.w	#1,d4
	asl.w	#2,d0
	asl.w	#8,d0
	add.w	d0,d4
	move.w	d4,road.section.x.offset

mftc2	tst.b	W.1bc30
	bmi	mftc4

	btst	#6,W.1bc30
	bne	mftc3

	move.w	(a6)+,d0
	move.w	(a6)+,d3
	bra	mftc6

mftc3	move.w	(a6)+,d3
	move.w	#$800,d0
	sub.w	(a6)+,d0
	bra	mftc6

mftc4	btst	#6,W.1bc30
	bne	mftc5

	move.w	#$800,d0
	sub.w	(a6)+,d0
	move.w	#$800,d3
	sub.w	(a6)+,d3
	bra	mftc6

mftc5	move.w	#$800,d3
	sub.w	(a6)+,d3
	move.w	(a6)+,d0

mftc6	asr.w	#1,d0
	asr.w	#1,d3
	add.w	road.section.z.offset,d0
	add.w	road.section.x.offset,d3
	jsr	dsFs21

	move.w	(a6)+,d0
	move.l	a6,-(sp)
	move.l	#DAT.1be70,a6
	move.w	d0,(a6,d1.w)
	sub.w	W.1bbfa,d0
	neg.w	d0
	asr.w	#3,d0
	move.w	W.1bc36,d3
	jsr	dsFs31

	move.l	#x.values,a4
	move.w	(a4,d1.w),d0
	btst	#1,d1
	bne	mftc8

	move.w	W.660fc,d3
	move.w	d0,W.660fc
	cmp.w	d3,d0
	blt	mftca
	bne	mftc7

	tst.b	clip.flag
	bne	mftca

mftc7	btst	#7,current.far.section.flag
	bne	mftca
	bra	mftcb

mftc8	move.w	W.660fe,d3
	move.w	d0,W.660fe
	cmp.w	d3,d0
	bgt	mftca
	bne	mftc9

	tst.b	clip.flag
	bne	mftca

mftc9	btst	#6,current.far.section.flag
	beq	mftcb

mftca	move.w	#512,120(a6,d1.w)
	move.w	(a4,d1.w),120(a4,d1.w)
	move.w	W.1bbfa,d0
	sub.w	#512,d0
	asr.w	#3,d0
	add.b	#120,d1
	move.w	W.1bc36,d3
	jsr	dsFs31
	jsr	z.rotate
	sub.b	#120,d1
	bra	mftcc

mftcb	move.w	#$8000,120(a6,d1.w)

mftcc	jsr	z.rotate
	move.l	(sp)+,a6
	cmp.l	end.far.sections.ptr,a6
	blt	mftcd
	move.l	#far.section0,a6

mftcd	addq.b	#2,d1
	btst	#1,d1
	bne	mftc2

	move.b	current.road.section,d2
	move.l	#road.visible.range.table,a0
	cmp.b	(a0,d2.w),d1
	bge	mftcf

	move.l	#x.values,a4
	cmp.w	#256,-4(a4,d1.w)
	bcs	mftc1

	cmp.w	#256,-2(a4,d1.w)
	bcs	mftc1

	move.l	#DAT.1be70,a0
	tst.w	116(a0,d1.w)
	bmi	mftce

	cmp.w	#256,116(a4,d1.w)
	bcs	mftc1
	bra	mftcf

mftce	tst.w	118(a0,d1.w)
	bmi	mftcf

	cmp.w	#256,118(a4,d1.w)
	bcs	mftc1

mftcf	move.b	d1,max.far.coord
	rts


max.far.coord	dc.b	0,0
W.660fc	dc.w	0
W.660fe	dc.w	0
current.far.section.flag	dc.w	0
end.far.sections.ptr	dc.l	end.far.sections




plot.far.track.coords
	move.l	#x.values,a4
	move.l	#y.values,a5
	move.l	#DAT.1be70,a6
	move.w	#4,d3

pftc	move.w	(a4,d3.w),d0		plot top coord
	move.w	(a5,d3.w),d1
	move.w	#3,new.colour
	tst.w	(a6,d3.w)
	bpl.s	top.coord.ok
	move.w	#12,new.colour
top.coord.ok
	bsr	plot.pixel

	move.w	120(a4,d3.w),d0		plot bottom coord
	move.w	120(a5,d3.w),d1
	move.w	#15,new.colour
	tst.w	120(a6,d3.w)
	bpl.s	bottom.coord.ok
	move.w	#14,new.colour
bottom.coord.ok
	bsr	plot.pixel

	addq.w	#2,d3
	cmp.b	max.far.coord(pc),d3
	blt.s	pftc
	rts




draw.far.track.edges
	move.l	screen1(pc),-(sp)
	add.l	#36*4*40+4,screen1
	move.l	#x.values,a4
	move.l	#y.values,a5
	move.l	#DAT.1be70,a6
	move.w	#4,d4

dfte	tst.w	(a6,d4.w)
	bmi.s	not.seen

	tst.w	2(a6,d4.w)
	bmi.s	not.seen

	move.w	#3,d0
	bsr	set.line.colour

	move.w	(a4,d4.w),d0
	move.w	(a5,d4.w),d1
	move.w	2(a4,d4.w),d2
	move.w	2(a5,d4.w),d3

	movem.l	d4/a4-a6,-(sp)
	lea	$dff000,a6
	bsr	clip.line
	movem.l	(sp)+,d4/a4-a6

not.seen
	tst.w	2(a6,d4.w)
	bmi.s	not.seen2

	tst.w	122(a6,d4.w)
	bmi.s	not.seen2

	move.w	#15,d0
	bsr	set.line.colour

	move.w	2(a4,d4.w),d0
	move.w	2(a5,d4.w),d1
	move.w	122(a4,d4.w),d2
	move.w	122(a5,d4.w),d3

	movem.l	d4/a4-a6,-(sp)
	lea	$dff000,a6
	bsr	clip.line
	movem.l	(sp)+,d4/a4-a6

not.seen2
	addq.w	#4,d4
	cmp.b	max.far.coord(pc),d4
	blt.s	dfte

	move.l	(sp)+,screen1
	rts




make.far.track.edges
	;move.b	#0,pit.far.done
	move.l	#DAT.1be70,a6
	move.b	#0,d2
	move.b	#4,d1

mfte1	;cmp.w	#47*32,road.section.offset
	bcc	mfte11

	;move.b	d1,B.1bbe4
	;move.b	d2,B.1bc14
	tst.w	(a6,d2.w)
	bmi	mfte2

	tst.w	(a6,d1.w)
	bmi	mfte2

	move.b	d2,d2
	add.b	#0,d2
	add.b	#0,d1
	;jsr	clip.line.make.edge
	;move.b	B.1bbe4,d1
	;move.b	B.1bc14,d2
	bra	mfte3

mfte2	;move.w	road.section.offset,d0
	;move.l	#section.data,a1
	move.l	#$80000000,(a1,d0.w)

mfte3	;add.w	#4,road.section.offset
	tst.w	2(a6,d2.w)
	bmi	mfte4

	tst.w	2(a6,d1.w)
	bmi	mfte4

	move.b	d2,d2
	add.b	#2,d2
	add.b	#2,d1
	;jsr	clip.line.make.edge
	;move.b	B.1bbe4,d1
	;move.b	B.1bc14,d2
	bra	mfte5

mfte4	;move.w	road.section.offset,d0
	;move.l	#section.data,a1
	move.l	#$80000000,(a1,d0.w)

mfte5	;add.w	#4,road.section.offset
	tst.w	120(a6,d2.w)
	bmi	mfte6

	tst.w	120(a6,d1.w)
	bmi	mfte6

	move.b	d2,d2
	add.b	#120,d2
	add.b	#120,d1
	;jsr	clip.line.make.edge
	;move.b	B.1bbe4,d1
	;move.b	B.1bc14,d2
	bra	mfte7

mfte6	;move.w	road.section.offset,d0
	;move.l	#section.data,a1
	move.l	#$80000000,(a1,d0.w)

mfte7	;add.w	#4,road.section.offset
	tst.w	122(a6,d2.w)
	bmi	mfte8

	tst.w	122(a6,d1.w)
	bmi	mfte8

	move.b	d2,d2
	add.b	#122,d2
	add.b	#122,d1
	;jsr	clip.line.make.edge
	;move.b	B.1bbe4,d1
	;move.b	B.1bc14,d2
	bra	mfte9

mfte8	;move.w	road.section.offset,d0
	;move.l	#section.data,a1
	move.l	#$80000000,(a1,d0.w)

mfte9	;add.w	#4,road.section.offset
	tst.w	120(a6,d1.w)
	bmi	mftea

	tst.w	(a6,d1.w)
	bmi	mftea

	move.b	d1,d2
	add.b	#120,d2
	add.b	#0,d1
	;jsr	clip.line.make.edge
	;move.b	B.1bbe4,d1
	;move.b	B.1bc14,d2
	bra	mfteb

mftea	;move.w	road.section.offset,d0
	;move.l	#section.data,a1
	move.l	#$80000000,0(a1,d0.w)

mfteb	;add.w	#4,road.section.offset
	tst.w	2(a6,d1.w)
	bmi	mftec

	tst.w	122(a6,d1.w)
	bmi	mftec

	move.b	d1,d2
	add.b	#2,d2
	add.b	#122,d1
	;jsr	clip.line.make.edge
	;move.b	B.1bbe4,d1
	;move.b	B.1bc14,d2
	bra	mfted

mftec	;move.w	road.section.offset,d0
	;move.l	#section.data,a1
	move.l	#$80000000,(a1,d0.w)

mfted	;add.w	#4,road.section.offset
	tst.w	(a6,d1.w)
	bmi	mftee

	tst.w	2(a6,d1.w)
	bmi	mftee

	move.b	d1,d2
	add.b	#0,d2
	add.b	#2,d1
	;jsr	clip.line.make.edge
	;move.b	B.1bbe4,d1
	;move.b	B.1bc14,d2
	bra	mftef

mftee	;move.w	road.section.offset,d0
	;move.l	#section.data,a1
	move.l	#$80000000,(a1,d0.w)

mftef	;add.w	#4,road.section.offset
	;move.l	#section.data,a0
	;move.w	road.section.offset,d3
	move.l	#far.section.flags,a3
	;move.w	(a3,d1.w),road.height.value+2
	;move.b	road.height.value+3,d0
	move.b	d0,(a0,d3.w)		copy colour flag

	;move.b	road.height.value+2,2(a0,d3.w)	copy pit / start line flag
	;tst.b	pit.far.done
	bne	mfte10

	;cmp.b	pit.indicator,d0
	bne	mfte10

	move.w	d3,d0
	addq.w	#4,d0
	;jsr	pit.routine1
	;move.b	#$80,pit.far.done

mfte10	;addq.w	#4,road.section.offset
	move.b	d1,d2
	addq.b	#4,d1
	cmp.b	max.far.coord,d1
	blt	mfte1
mfte11	rts




fetch.x.z.position
	move.l	#road.section.x.z.positions,a1
	and.w	#$ff,d0
	move.b	(a1,d0.w),d3
	lsr.b	#4,d3
	move.b	(a1,d0.w),d0
	and.b	#$f,d0
	sub.b	player.map.z,d0
	sub.b	player.map.x,d3
	tst.b	W.1bc30
	bmi	fxzp1

	btst	#6,W.1bc30
	beq	fxzp3

	exg	d0,d3
	neg.b	d0
	jmp	fxzp3

fxzp1	btst	#6,W.1bc30
	bne	fxzp2

	neg.b	d0
	neg.b	d3
	jmp	fxzp3

fxzp2	exg	d0,d3
	neg.b	d3

fxzp3	move.b	d0,road.section.z.offset
	move.b	d3,road.section.x.offset

	asl.b	#3,d0
	add.b	B.1bb2e,d0
	move.b	d0,B.1bb22

	asl.b	#3,d3
	add.b	B.1bb32,d3
	move.b	d3,B.1bb26
	rts




dw.subF.sub2
;	move.w	sin.x,d0
;	move.w	corner.values.offset-1,d3
;	tst.b	B.1bb8f
;	bpl	dsFs21

	asr.w	#1,d0
	asr.w	#1,d3
	move.w	d3,W.1bc36

	add.b	#49,W.1bc36
	asr.w	#1,d3
	add.w	#$4900,d3
	jsr	dw.sub9.sub3

	sub.w	W.1bc2e,d0
	asr.w	#3,d0
	move.l	#x.values,a0
	move.w	d0,(a0,d1.w)
	rts

dsFs21	jsr	dw.sub9.sub3
	sub.w	W.1bc2e,d0
	asr.w	#3,d0
	move.l	#x.values,a0
	move.w	d0,(a0,d1.w)

	jsr	dw.sub9.sub4
	move.w	d0,W.1bc36
	rts




dw.subF.sub3
	move.l	#DAT.1be70,a0
	move.w	(a0,d1.w),d0
	sub.w	W.1bbfa,d0
	neg.w	d0
	asr.w	#2,d0
	move.w	W.1bc36,d3
;	tst.b	B.1bb8f
;	bpl	dsFs31

	move.w	#19483,d4
	muls	d4,d0
	asl.l	#1,d0
	swap	d0

dsFs31	jsr	dw.sub9.sub3
	sub.w	x.amount,d0
	asr.w	#3,d0
	move.l	#y.values,a0
	move.w	d0,(a0,d1.w)
	rts




z.rotate0
	move.l	#DAT.1be70,a0
	tst.w	(a0,d1.w)
	bmi	zr.end
z.rotate
	move.l	#sin.cos.values,a3
	move.l	#x.values,a5
	move.l	#y.values,a4
z.rotate1
	move.w	(a5,d1.w),d5
	move.w	(a4,d1.w),d4

	move.w	34(a3),d0
	muls	d5,d0
	asl.l	#1,d0
	swap	d0
	move.w	32(a3),d3
	muls	d4,d3
	asl.l	#1,d3
	swap	d3
	add.w	d3,d0
	asr.w	#2,d0
	add.w	#128,d0
	move.w	d0,(a5,d1.w)

	move.w	34(a3),d0
	muls	d4,d0
	asl.l	#1,d0
	swap	d0
	move.w	32(a3),d3
	muls	d5,d3
	asl.l	#1,d3
	swap	d3
	sub.w	d3,d0
	asr.w	#2,d0
	add.w	#64,d0
	move.w	d0,(a4,d1.w)
zr.end	rts




dw.sub9.sub3
	move.l	#TAB.1cc46,a0
	move.w	d0,d4
	bpl	ds9s31
	neg.w	d0

ds9s31	move.w	d3,d5
	bpl	ds9s32
	neg.w	d3

ds9s32	cmp.w	d0,d3
	bne	ds9s33

	move.w	#$ffff,d7
	move.w	#$2000,d0
	bra	ds9s37

ds9s33	bgt	ds9s36

	swap	d3
	clr.w	d3
	divu	d0,d3
	move.w	d3,d7
	lsr.w	#4,d3
	and.b	#$fe,d3
	move.w	(a0,d3.w),d0
	move.w	d4,d3
	eor.w	d5,d3
	bmi	ds9s34
	neg.w	d0

ds9s34	move.w	#$4000,d3
	tst.w	d4
	bpl	ds9s35
	move.w	#$c000,d3

ds9s35	add.w	d3,d0
	rts

ds9s36	swap	d0
	clr.w	d0
	divu	d3,d0
	move.w	d0,d7
	lsr.w	#4,d0
	and.b	#$fe,d0
	move.w	(a0,d0.w),d0

ds9s37	move.w	d4,d3
	eor.w	d5,d3
	bpl	ds9s38
	neg.w	d0

ds9s38	tst.w	d5
	bpl	ds9s39
	add.w	#$8000,d0
ds9s39	rts




dw.sub9.sub4
	move.l	#TAB.1dc46,a0
	tst.w	d4
	bpl	ds9s41
	neg.w	d4

ds9s41	tst.w	d5
	bpl	ds9s42
	neg.w	d5

ds9s42	cmp.w	d4,d5
	bge	ds9s43
	exg	d4,d5

ds9s43	lsr.w	#4,d7
	and.b	#$fe,d7
	move.w	(a0,d7.w),d0
	mulu	d4,d0
	swap	d0
	add.w	d5,d0
	rts




make.z.sin.cos
	move.l	#sin.cos.values,a5
	move.w	z.angle,d0
	jsr	get.cos
	move.w	d0,34(a5)

	move.w	z.angle,d0
	jsr	get.sin
	move.w	d0,32(a5)
	rts




get.sin	move.w	#0,d5
	bra	get.sin.cos
get.cos	move.w	#$4000,d5
get.sin.cos
	move.l	#sin.table,a0
	move.w	d0,d3
	and.w	#$3fff,d3
	move.w	d0,d6
	and.w	#$4000,d6
	eor.w	d5,d6
	bne	gsc1
	eor.w	#$3fff,d3
	addq.w	#1,d3
gsc1	ror.w	#5,d3
	move.w	d3,d4
	and.w	#$3fe,d4
	move.w	(a0,d4.w),d6
	sub.w	2(a0,d4.w),d6
	ror.w	#1,d3
	and.w	#$fc00,d3
	mulu	d3,d6
	swap	d6
	move.w	(a0,d4.w),d7
	sub.w	d6,d7
	lsr.w	#1,d7
	move.w	d0,d3
	and.w	d5,d3
	asl.w	#1,d3
	eor.w	d3,d0
	bpl	gsc2
	neg.w	d7
gsc2	move.w	d7,d0
	rts




plot.pixel				; d0 = x, d1 = y
	tst.w	d0			; d0-d2 and a0-a1 trashed
	bmi.s	end.plot.pixel
	cmp.w	#XMAX,d0
	bcc.s	end.plot.pixel
	tst.w	d1
	bmi.s	end.plot.pixel
	cmp.w	#YMAX,d1
	bcc.s	end.plot.pixel

	move.w	new.colour(pc),d2
	cmp.w	old.colour(pc),d2
	beq.s	plot2

	move.w	d2,old.colour
	lsl.w	#4,d2			16 bytes of instructions
	lea	plot.ins(pc,d2.w),a0
	lea	plot3(pc),a1
	move.l	(a0)+,(a1)+		copy instructions
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0),(a1)

plot2	move.l	screen1(pc),a0
	lea	36*4*40+4(a0),a0
	lea	y.table(pc),a1
	add.w	d1,d1
	add.w	(a1,d1.w),a0		address of line containing pixel
	moveq	#$f,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#3,d0
	add.w	d0,a0			address of word containing pixel
	add.w	d1,d1
	move.w	pixel.masks(pc,d1.w),d0	positive mask
	move.w	d0,d1
	not.w	d1			make negative mask

plot3	and.w	d1,0(a0)		plane1
	and.w	d1,40(a0)		plane2
	and.w	d1,80(a0)		plane3
	and.w	d1,120(a0)		plane4
end.plot.pixel
	rts



new.colour	dc.w	0
old.colour	dc.w	0



pixel.masks
	dc.w	$8000,$4000,$2000,$1000,$0800,$0400,$0200,$0100
	dc.w	$0080,$0040,$0020,$0010,$0008,$0004,$0002,$0001



plot.ins
	and.w	d1,0(a0)
	and.w	d1,40(a0)
	and.w	d1,80(a0)
	and.w	d1,120(a0)

	or.w	d0,0(a0)
	and.w	d1,40(a0)
	and.w	d1,80(a0)
	and.w	d1,120(a0)

	and.w	d1,0(a0)
	or.w	d0,40(a0)
	and.w	d1,80(a0)
	and.w	d1,120(a0)

	or.w	d0,0(a0)
	or.w	d0,40(a0)
	and.w	d1,80(a0)
	and.w	d1,120(a0)

	and.w	d1,0(a0)
	and.w	d1,40(a0)
	or.w	d0,80(a0)
	and.w	d1,120(a0)

	or.w	d0,0(a0)
	and.w	d1,40(a0)
	or.w	d0,80(a0)
	and.w	d1,120(a0)

	and.w	d1,0(a0)
	or.w	d0,40(a0)
	or.w	d0,80(a0)
	and.w	d1,120(a0)

	or.w	d0,0(a0)
	or.w	d0,40(a0)
	or.w	d0,80(a0)
	and.w	d1,120(a0)

	and.w	d1,0(a0)
	and.w	d1,40(a0)
	and.w	d1,80(a0)
	or.w	d0,120(a0)

	or.w	d0,0(a0)
	and.w	d1,40(a0)
	and.w	d1,80(a0)
	or.w	d0,120(a0)

	and.w	d1,0(a0)
	or.w	d0,40(a0)
	and.w	d1,80(a0)
	or.w	d0,120(a0)

	or.w	d0,0(a0)
	or.w	d0,40(a0)
	and.w	d1,80(a0)
	or.w	d0,120(a0)

	and.w	d1,0(a0)
	and.w	d1,40(a0)
	or.w	d0,80(a0)
	or.w	d0,120(a0)

	or.w	d0,0(a0)
	and.w	d1,40(a0)
	or.w	d0,80(a0)
	or.w	d0,120(a0)

	and.w	d1,0(a0)
	or.w	d0,40(a0)
	or.w	d0,80(a0)
	or.w	d0,120(a0)

	or.w	d0,0(a0)
	or.w	d0,40(a0)
	or.w	d0,80(a0)
	or.w	d0,120(a0)



set.line.colour
	lea	line.colour.masks(pc),a1
	lsl.w	#3,d0
	add.w	d0,a1
	move.l	a1,dl.col+2
	rts



line.colour.masks
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




; d0 = x1, d1 = y1, d2 = x2, d3 = y2

clip.line
	move.w	#XMAX-1,d6
	move.w	#YMAX-1,d7

	tst.w	d0			x1
	bpl.s	x1.not.off.left

; x1 is off left of screen

	tst.w	d2			x2
	bmi.s	end.clip.line		if line is off left of screen

; clip line to left edge, giving a new value for y1

	move.w	d2,d4			x2
	sub.w	d0,d4			x2-x1
	move.w	d3,d5			y2
	sub.w	d1,d5			y2-y1
	muls	d0,d5			x1 * (y2-y1)
	divs	d4,d5			(x1 * (y2-y1)) / (x2-x1)
	sub.w	d5,d1			y1 - ((x1 * (y2-y1)) / (x2-x1))
	moveq	#0,d0			x1 = 0
	bra.s	x1.clipped

end.clip.line
	rts




x1.not.off.left
	cmp.w	d6,d0			x1
	ble.s	x1.clipped

; x1 is off right of screen

	cmp.w	d6,d2			x2
	bgt.s	end.clip.line		if line is off right of screen

; clip line to right edge, giving a new value for y1

	move.w	d2,d4			x2
	sub.w	d0,d4			x2-x1
	move.w	d3,d5			y2
	sub.w	d1,d5			y2-y1
	sub.w	d6,d0			x1-max
	muls	d0,d5			(x1-max) * (y2-y1)
	divs	d4,d5			((x1-max) * (y2-y1)) / (x2-x1)
	sub.w	d5,d1			y1 - (((x1-max) * (y2-y1)) / (x2-x1))
	move.w	d6,d0			x1 = max




x1.clipped
	tst.w	d1			y1
	bpl.s	y1.not.off.top

; y1 is off top of screen

	tst.w	d3			y2
	bmi.s	end.clip.line		if line is off top of screen

; clip line to top edge, giving a new value for x1

	move.w	d2,d4			x2
	sub.w	d0,d4			x2-x1
	move.w	d3,d5			y2
	sub.w	d1,d5			y2-y2
	muls	d1,d4			y1 * (x2-x1)
	divs	d5,d4			(y1 * (x2-x1)) / (y2-y1)
	sub.w	d4,d0			x1 - ((y1 * (x2-x1)) / (y2-y1))
	bmi.s	end.clip.line2		if new x1 is off left of screen

	moveq	#0,d1			y1 = 0

	cmp.w	d6,d0
	ble.s	y1.clipped		if new x1 is not off right of screen

end.clip.line2
	rts




y1.not.off.top
	cmp.w	d7,d1			y1
	ble.s	y1.clipped

; y1 is off bottom of screen

	cmp.w	d7,d3			y2
	bgt.s	end.clip.line2		if line is off bottom of screen

; clip line to bottom edge, giving a new value for x1

	move.w	d2,d4			x2
	sub.w	d0,d4			x2-x1
	move.w	d3,d5			y2
	sub.w	d1,d5			y2-y1
	sub.w	d7,d1			y1-max
	muls	d1,d4			(y1-max) * (x2-x1)
	divs	d5,d4			((y1-max) * (x2-x1)) / (y2-y1)
	sub.w	d4,d0			x1 - (((y1-max) * (x2-x1)) / (y2-y1))
	bmi.s	end.clip.line2		if new x1 is off left of screen

	cmp.w	d6,d0
	bgt.s	end.clip.line2		if new x1 is off right of screen

	move.w	d7,d1			y1 = max




y1.clipped
	tst.w	d2			x2
	bpl.s	x2.not.off.left

; x2 is off left of screen

; clip line to left edge, giving a new value for y2

	move.w	d0,d4			x1
	sub.w	d2,d4			x1-x2
	move.w	d1,d5			y1
	sub.w	d3,d5			y1-y2
	muls	d2,d5			x2 * (y1-y2)
	divs	d4,d5			(x2 * (y1-y2)) / (x1-x2)
	sub.w	d5,d3			y2 - ((x2 * (y1-y2)) / (x1-x2))
	moveq	#0,d2			x2 = 0
	bra.s	x2.clipped




x2.not.off.left
	cmp.w	d6,d2			x2
	ble.s	x2.clipped

; x2 is off right of screen

; clip line to right edge, giving a new value for y2

	move.w	d0,d4			x1
	sub.w	d2,d4			x1-x2
	move.w	d1,d5			y1
	sub.w	d3,d5			y1-y2
	sub.w	d6,d2			x2-max
	muls	d2,d5			(x2-max) * (y1-y2)
	divs	d4,d5			((x2-max) * (y1-y2)) / (x1-x2)
	sub.w	d5,d3			y2 - (((x2-max) * (y1-y2)) / (x1-x2))
	move.w	d6,d2			x2 = max




x2.clipped
	tst.w	d3			y2
	bpl.s	y2.not.off.top

; y2 is off top of screen

; clip line to top edge, giving a new value for x2

	move.w	d0,d4			x1
	sub.w	d2,d4			x1-x2
	move.w	d1,d5			y1
	sub.w	d3,d5			y1-y2
	muls	d3,d4			y2 * (x1-x2)
	divs	d5,d4			(y2 * (x1-x2)) / (y1-y2)
	sub.w	d4,d2			x2 - ((y2 * (x1-x2)) / (y1-y2))
	bmi.s	end.clip.line3		if new x2 is off left of screen

	moveq	#0,d3			y2 = 0

	cmp.w	d6,d2
	ble.s	draw.line		if new x1 is not off right of screen

end.clip.line3
	rts




y2.not.off.top
	cmp.w	d7,d3			y2
	ble.s	draw.line

; y2 is off bottom of screen

; clip line to bottom edge, giving a new value for x2

	move.w	d0,d4			x1
	sub.w	d2,d4			x1-x2
	move.w	d1,d5			y1
	sub.w	d3,d5			y1-y2
	sub.w	d7,d3			y2-max
	muls	d3,d4			(y2-max) * (x1-x2)
	divs	d5,d4			((y2-max) * (x1-x2)) / (y1-y2)
	sub.w	d4,d2			x2 - (((y2-max) * (x1-x2)) / (y1-y2))
	bmi.s	end.clip.line3		if new x2 is off left of screen

	cmp.w	d6,d2
	bgt.s	end.clip.line3		if new x2 is off right of screen

	move.w	d7,d3			y2 = max




draw.line				; draw line using blitter
	cmp.w	d2,d0
	ble.s	x1.less.than.x2

	exg	d0,d2			ensure line is going left-to-right
	exg	d1,d3

x1.less.than.x2
	sub.w	d0,d2			x2-x1
	sub.w	d1,d3			y2-y1

	moveq	#$f,d4
	and.w	d0,d4			low four bits from x-start

	sub.w	d4,d0			x-start offset in multiples of 16
	lsr.w	#3,d0			x-start offset in even bytes

	add.w	d1,d1			word offset
	lea	y.table(pc),a1
	add.w	(a1,d1.w),d0		add y offset

	move.l	screen1(pc),a1
	add.w	d0,a1			start address of line

	ror.w	#4,d4			low four bits from x-start
	or.w	#$bca,d4		USE A,C,D	D = A.B + notA.C
	swap	d4

	tst.w	d3			delta-y
	bmi.s	y2.less.than.y1

	cmp.w	d2,d3
	blt.s	dy.less.than.dx

	exg	d2,d3			larger delta into d2
	move.w	#%00001,d4
	bra.s	dl.size

dy.less.than.dx
	move.w	#%10001,d4
	bra.s	dl.size


y2.less.than.y1
	neg.w	d3			make delta-y positive

	cmp.w	d2,d3
	blt.s	dy.less.than.dx2

	exg	d2,d3			larger delta into d2
	move.w	#%00101,d4
	bra.s	dl.size

dy.less.than.dx2
	move.w	#%11001,d4


dl.size	move.w	d2,d1			larger delta is line length
	addq.w	#1,d1			+ 1 to prevent length of zero
	lsl.w	#6,d1			into correct position
	addq.w	#2,d1			+ width of two

	add.w	d3,d3			2 Sdelta
	move.w	d3,d0
	sub.w	d2,d0			2 Sdelta - Ldelta
	bge.s	no.sign

	or.w	#%1000000,d4		set SIGN flag

no.sign	add.w	d2,d2			2 Ldelta

dl.col	move.l	#line.colour.masks,a2
	moveq	#40,d5			width of one bitplane

bltfin	btst	#6,dmaconr(a6)
	bne.s	bltfin

	move.w	d3,bltbmod(a6)		2 Sdelta
	sub.w	d2,d3			2 Sdelta - 2 Ldelta
	move.w	d3,bltamod(a6)		2 Sdelta - 2 Ldelta
	move.w	#$8000,bltadat(a6)
	moveq	#-1,d3
	move.l	d3,bltafwm(a6)
	move.w	#4*40,d3		total width of bitplanes
	move.w	d3,bltcmod(a6)
	move.w	d3,bltdmod(a6)

	moveq	#4-1,d2
	move.w	(a2)+,d3		get first line mask
	bra.s	dl.start


dl.loop	add.l	d5,a1
	move.w	(a2)+,d3		get next line mask

bltfin2	btst	#6,dmaconr(a6)
	bne.s	bltfin2

dl.start
	move.l	a1,bltcpth(a6)		start address of line
	move.l	a1,bltdpth(a6)		start address of line
	move.w	d0,bltapth+2(a6)	2 Sdelta - Ldelta
	move.l	d4,bltcon0(a6)
	move.w	d3,bltbdat(a6)		set line mask
	move.w	d1,bltsize(a6)		start blitter

	dbra	d2,dl.loop		do all bitplanes
	rts




draw.borders
	move.w	#7,d0
	bsr	set.line.colour

	line	31,35,31,164
	line	31,164,288,164
	line	288,164,288,35
	line	288,35,31,35

	line	0,0,0,199
	line	0,199,319,199
	line	319,199,319,0
	line	319,0,0,0

	move.l	screen1(pc),-(sp)
	move.l	screen2(pc),screen1
	line	31,35,31,164
	line	31,164,288,164
	line	288,164,288,35
	line	288,35,31,35

	line	0,0,0,199
	line	0,199,319,199
	line	319,199,319,0
	line	319,0,0,0
	move.l	(sp)+,screen1
	rts




y.table	ds.w	200




print	move.l	screen1(pc),a1		d0 = x, d1 = y
	add.w	d1,d1			a0 = text ending with 0
	lea	y.table(pc),a2
	add.w	(a2,d1.w),d0
	add.w	d0,a1			screen start address

print.loop
	move.b	(a0)+,d0		get next character
	beq.s	end.print

	sub.b	#32,d0			ASCII value for space
	ext.w	d0
	lsl.w	#3,d0			8 bytes per character of font
	lea	font(pc,d0.w),a3	source start address

	moveq	#8-1,d0			count-1
	move.l	a1,a2

char.loop
	move.b	(a3)+,d1
	move.b	d1,(a2)			copy byte of character, bitplane 1
	move.b	d1,40(a2)		bitplane 2
	move.b	d1,80(a2)		bitplane 3
	move.b	d1,120(a2)		bitplane 4

	lea	160(a2),a2		next screen line
	dbra	d0,char.loop

	addq.l	#1,a1			next column
	bra.s	print.loop

end.print
	rts



; Spectrum font, characters 32-126, each 8*8 pixels

font	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$10,$10,$10,$10,$00,$10,$00
	dc.b	$00,$24,$24,$00,$00,$00,$00,$00
	dc.b	$00,$24,$7e,$24,$24,$7e,$24,$00
	dc.b	$00,$08,$3e,$28,$3e,$0a,$3e,$08
	dc.b	$00,$62,$64,$08,$10,$26,$46,$00
	dc.b	$00,$10,$28,$10,$2a,$44,$3a,$00
	dc.b	$00,$08,$10,$00,$00,$00,$00,$00
	dc.b	$00,$04,$08,$08,$08,$08,$04,$00
	dc.b	$00,$20,$10,$10,$10,$10,$20,$00
	dc.b	$00,$00,$14,$08,$3e,$08,$14,$00
	dc.b	$00,$00,$08,$08,$3e,$08,$08,$00
	dc.b	$00,$00,$00,$00,$00,$08,$08,$10
	dc.b	$00,$00,$00,$00,$3e,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$18,$18,$00
	dc.b	$00,$00,$02,$04,$08,$10,$20,$00
	dc.b	$00,$3c,$46,$4a,$52,$62,$3c,$00
	dc.b	$00,$18,$28,$08,$08,$08,$3e,$00
	dc.b	$00,$3c,$42,$02,$3c,$40,$7e,$00
	dc.b	$00,$3c,$42,$0c,$02,$42,$3c,$00
	dc.b	$00,$08,$18,$28,$48,$7e,$08,$00
	dc.b	$00,$7e,$40,$7c,$02,$42,$3c,$00
	dc.b	$00,$3c,$40,$7c,$42,$42,$3c,$00
	dc.b	$00,$7e,$02,$04,$08,$10,$10,$00
	dc.b	$00,$3c,$42,$3c,$42,$42,$3c,$00
	dc.b	$00,$3c,$42,$42,$3e,$02,$3c,$00
	dc.b	$00,$00,$10,$00,$00,$00,$10,$00
	dc.b	$00,$00,$10,$00,$00,$10,$10,$20
	dc.b	$00,$00,$04,$08,$10,$08,$04,$00
	dc.b	$00,$00,$00,$3e,$00,$3e,$00,$00
	dc.b	$00,$00,$10,$08,$04,$08,$10,$00
	dc.b	$00,$3c,$42,$04,$08,$00,$08,$00
	dc.b	$00,$3c,$4a,$56,$5e,$40,$3c,$00
	dc.b	$00,$3c,$42,$42,$7e,$42,$42,$00
	dc.b	$00,$7c,$42,$7c,$42,$42,$7c,$00
	dc.b	$00,$3c,$42,$40,$40,$42,$3c,$00
	dc.b	$00,$78,$44,$42,$42,$44,$78,$00
	dc.b	$00,$7e,$40,$7c,$40,$40,$7e,$00
	dc.b	$00,$7e,$40,$7c,$40,$40,$40,$00
	dc.b	$00,$3c,$42,$40,$4e,$42,$3c,$00
	dc.b	$00,$42,$42,$7e,$42,$42,$42,$00
	dc.b	$00,$3e,$08,$08,$08,$08,$3e,$00
	dc.b	$00,$02,$02,$02,$42,$42,$3c,$00
	dc.b	$00,$44,$48,$70,$48,$44,$42,$00
	dc.b	$00,$40,$40,$40,$40,$40,$7e,$00
	dc.b	$00,$42,$66,$5a,$42,$42,$42,$00
	dc.b	$00,$42,$62,$52,$4a,$46,$42,$00
	dc.b	$00,$3c,$42,$42,$42,$42,$3c,$00
	dc.b	$00,$7c,$42,$42,$7c,$40,$40,$00
	dc.b	$00,$3c,$42,$42,$52,$4a,$3c,$00
	dc.b	$00,$7c,$42,$42,$7c,$44,$42,$00
	dc.b	$00,$3c,$40,$3c,$02,$42,$3c,$00
	dc.b	$00,$fe,$10,$10,$10,$10,$10,$00
	dc.b	$00,$42,$42,$42,$42,$42,$3c,$00
	dc.b	$00,$42,$42,$42,$42,$24,$18,$00
	dc.b	$00,$42,$42,$42,$42,$5a,$24,$00
	dc.b	$00,$42,$24,$18,$18,$24,$42,$00
	dc.b	$00,$82,$44,$28,$10,$10,$10,$00
	dc.b	$00,$7e,$04,$08,$10,$20,$7e,$00
	dc.b	$00,$0e,$08,$08,$08,$08,$0e,$00
	dc.b	$00,$00,$40,$20,$10,$08,$04,$00
	dc.b	$00,$70,$10,$10,$10,$10,$70,$00
	dc.b	$00,$10,$38,$54,$10,$10,$10,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$ff
	dc.b	$00,$1c,$22,$78,$20,$20,$7e,$00
	dc.b	$00,$00,$38,$04,$3c,$44,$3c,$00
	dc.b	$00,$20,$20,$3c,$22,$22,$3c,$00
	dc.b	$00,$00,$1c,$20,$20,$20,$1c,$00
	dc.b	$00,$04,$04,$3c,$44,$44,$3c,$00
	dc.b	$00,$00,$38,$44,$78,$40,$3c,$00
	dc.b	$00,$0c,$10,$18,$10,$10,$10,$00
	dc.b	$00,$00,$3c,$44,$44,$3c,$04,$38
	dc.b	$00,$40,$40,$78,$44,$44,$44,$00
	dc.b	$00,$10,$00,$30,$10,$10,$38,$00
	dc.b	$00,$04,$00,$04,$04,$04,$24,$18
	dc.b	$00,$20,$28,$30,$30,$28,$24,$00
	dc.b	$00,$10,$10,$10,$10,$10,$0c,$00
	dc.b	$00,$00,$68,$54,$54,$54,$54,$00
	dc.b	$00,$00,$78,$44,$44,$44,$44,$00
	dc.b	$00,$00,$38,$44,$44,$44,$38,$00
	dc.b	$00,$00,$78,$44,$44,$78,$40,$40
	dc.b	$00,$00,$3c,$44,$44,$3c,$04,$06
	dc.b	$00,$00,$1c,$20,$20,$20,$20,$00
	dc.b	$00,$00,$38,$40,$38,$04,$78,$00
	dc.b	$00,$10,$38,$10,$10,$10,$0c,$00
	dc.b	$00,$00,$44,$44,$44,$44,$38,$00
	dc.b	$00,$00,$44,$44,$28,$28,$10,$00
	dc.b	$00,$00,$44,$54,$54,$54,$28,$00
	dc.b	$00,$00,$44,$28,$10,$28,$44,$00
	dc.b	$00,$00,$44,$44,$44,$3c,$04,$38
	dc.b	$00,$00,$7c,$08,$10,$20,$7c,$00
	dc.b	$00,$0e,$08,$30,$08,$08,$0e,$00
	dc.b	$00,$08,$08,$08,$08,$08,$08,$00
	dc.b	$00,$70,$10,$0c,$10,$10,$70,$00
	dc.b	$00,$14,$28,$00,$00,$00,$00,$00




make.hexw
	lea	hex.textw(pc),a0	d0.w = number
	lea	hex.digits(pc),a1
	moveq	#0,d1

make.hexw.loop
	rol.w	#4,d0
	move.w	d0,d2
	and.w	#$f,d2
	move.b	(a1,d2.w),(a0,d1.w)
	addq.w	#1,d1
	cmp.w	#4,d1
	bne.s	make.hexw.loop
	rts



make.hexl
	lea	hex.textl(pc),a0	d0.l = number
	lea	hex.digits(pc),a1
	moveq	#0,d1

make.hexl.loop
	rol.l	#4,d0
	move.w	d0,d2
	and.w	#$f,d2
	move.b	(a1,d2.w),(a0,d1.w)
	addq.w	#1,d1
	cmp.w	#8,d1
	bne.s	make.hexl.loop
	rts



hex.digits
	dc.b	'0123456789ABCDEF'



hex.textw
	ds.b	5

hex.textl
	ds.b	9




make.decimal
	and.l	#$ffff,d0		d0.w = number (0-65535)
	move.w	#10000,d1		start with 10000's
	lea	decimal.text(pc),a0
	moveq	#0,d4			miss off leading zeros

make.dec.loop
	move.l	d0,d2
	divu	d1,d2			calculate digit

	bne.s	save.digit		if digit is not zero then save it
	tst.b	d4			if flag is zero
	bne.s	save.digit
	move.b	#' ',(a0)+		then miss this zero digit
	bra.s	next.position

save.digit
	moveq	#1,d4			don't miss off any more zeros
	move.b	d2,d3
	add.b	#48,d3			offset for ASCII digits
	move.b	d3,(a0)+		save decimal digit

	mulu	d1,d2			move digit back to correct place
	sub.l	d2,d0			remove from original number

next.position
	ext.l	d1
	divu	#10,d1			next decimal position
	cmp.w	#1,d1			have we reached units ?
	bne.s	make.dec.loop		loop back if not

	add.b	#48,d0			offset for ASCII digits
	move.b	d0,(a0)			save units
	rts



decimal.text
	ds.b	6




frames.per.sec			; using horiz. sync. pulse counter in CIA-B
				; it is a 24-bit counter
	move.b	$bfda00,d0		get counter into latch
	move.b	$bfd900,d0		bits 8-15 of counter
	lsl.w	#8,d0			into correct position
	move.b	$bfd800,d0		bits 0-7 of counter

	move.w	d0,d1
	sub.w	old.counter(pc),d1	get counter difference
	move.w	d0,old.counter		save for next time

	move.l	#156250,d0		pulses per second * 10
	divu	d1,d0			frames per second * 10

	bsr.s	make.decimal

	lea	decimal.text+4(pc),a0
	lea	frames.text+7(pc),a1
	move.b	(a0),(a1)
	move.b	#'.',-(a1)		insert decimal point
	move.w	-(a0),-(a1)

	lea	frames.text(pc),a0
	moveq	#16,d0			x
	moveq	#6,d1			y
	bra	print



old.counter
	dc.w	0



frames.text
	dc.b	'F/S     ',0
	even




update.screens
	move.l	screen1(pc),d0
	move.l	screen2(pc),screen1
	move.l	d0,screen2

	move.l	copper1(pc),d0
	move.l	copper2(pc),copper1
	move.l	d0,copper2

	move.l	d0,cop1lch+$dff000	set new copper list address
	rts




make.copper.lists
	move.l	screen1(pc),d0
	move.l	copper1(pc),a0
	bsr.s	init.copper

	move.l	screen2(pc),d0
	move.l	copper2(pc),a0
;	bra.s	init.copper




init.copper
	moveq	#4-1,d1
	moveq	#40,d2			width of one bitplane

next.plane
	move.w	d0,6(a0)		save low word
	swap	d0
	move.w	d0,2(a0)		save high word
	swap	d0
	add.l	d2,d0			next bitplane
	addq.l	#8,a0			update pointer to copper list
	dbra	d1,next.plane
	rts




;"""""""""""""""""""
;" THE COPPER LIST "
;"		   "
;"""""""""""""""""""

copper.list1
	dc.w	bpl1pth,0		4 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$1001,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe




copper.list2
	dc.w	bpl1pth,0		4 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$1001,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe




;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

screen.mem	dc.l	0
screen1	dc.l	0
screen2	dc.l	0
copper1	dc.l	copper.list1
copper2	dc.l	copper.list2

gfxbase		dc.l	0
old.ints	dc.w	0
old.level2	dc.l	0
old.level3	dc.l	0
old.dbz		dc.l	0
next.frame	dc.b	0
raw.key.code	dc.b	0

saved.current.road.section	dc.b	18

current.road.section	dc.b	0
player.map.z	dc.b	0
player.map.x	dc.b	0
W.1bc30	dc.w	0
B.1bb22	dc.b	0
B.1bb23	dc.b	0
B.1bb26	dc.b	0
B.1bb27	dc.b	0
B.1bb2e	dc.b	0
B.1bb32	dc.b	0
W.1bc2e	dc.w	0
x.amount	dc.w	0
W.1bbfa	dc.w	0
W.1bc36	dc.w	0
clip.flag	dc.b	0,0
z.angle	dc.w	0

DAT.1be70	ds.w	160
x.values	ds.w	160
y.values	ds.w	160
sin.cos.values	ds.w	36
		ds.w	4




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
	dc.w	$000,$997,$bb9,$ff0,$9b3,$577,$5bf,$59f
	dc.w	$357,$500,$733,$955,$d99,$775,$bbb,$fff


road.section.x.z.positions

; Top nibble	= X position
; Bottom nibble	= Z position

	dc.b	$cf,$bf,$af,$9f,$8f,$7f,$6f,$5f
	dc.b	$4f,$3f,$2f,$1f,$0e,$0d,$0c,$0b
	dc.b	$0a,$09,$08,$07,$06,$05,$04,$03
	dc.b	$02,$01,$10,$20,$31,$42,$53,$64
	dc.b	$75,$86,$97,$a8,$b9,$ca,$db,$ec
	dc.b	$fd,$fe,$ef,$df,$60,$50,$40,$30
	dc.b	$20,$10,$01,$02,$03,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00


TAB.1cc46
	dc.w	$0000,$0005,$000a,$000f,$0014,$0019,$001f,$0024
	dc.w	$0029,$002e,$0033,$0038,$003d,$0042,$0047,$004c
	dc.w	$0051,$0057,$005c,$0061,$0066,$006b,$0070,$0075
	dc.w	$007a,$007f,$0084,$008a,$008f,$0094,$0099,$009e
	dc.w	$00a3,$00a8,$00ad,$00b2,$00b7,$00bc,$00c2,$00c7
	dc.w	$00cc,$00d1,$00d6,$00db,$00e0,$00e5,$00ea,$00ef
	dc.w	$00f4,$00fa,$00ff,$0104,$0109,$010e,$0113,$0118
	dc.w	$011d,$0122,$0127,$012c,$0131,$0137,$013c,$0141
	dc.w	$0146,$014b,$0150,$0155,$015a,$015f,$0164,$0169
	dc.w	$016f,$0174,$0179,$017e,$0183,$0188,$018d,$0192
	dc.w	$0197,$019c,$01a1,$01a6,$01ac,$01b1,$01b6,$01bb
	dc.w	$01c0,$01c5,$01ca,$01cf,$01d4,$01d9,$01de,$01e3
	dc.w	$01e9,$01ee,$01f3,$01f8,$01fd,$0202,$0207,$020c
	dc.w	$0211,$0216,$021b,$0220,$0226,$022b,$0230,$0235
	dc.w	$023a,$023f,$0244,$0249,$024e,$0253,$0258,$025d
	dc.w	$0262,$0268,$026d,$0272,$0277,$027c,$0281,$0286
	dc.w	$028b,$0290,$0295,$029a,$029f,$02a4,$02a9,$02af
	dc.w	$02b4,$02b9,$02be,$02c3,$02c8,$02cd,$02d2,$02d7
	dc.w	$02dc,$02e1,$02e6,$02eb,$02f0,$02f6,$02fb,$0300
	dc.w	$0305,$030a,$030f,$0314,$0319,$031e,$0323,$0328
	dc.w	$032d,$0332,$0337,$033c,$0341,$0347,$034c,$0351
	dc.w	$0356,$035b,$0360,$0365,$036a,$036f,$0374,$0379
	dc.w	$037e,$0383,$0388,$038d,$0392,$0397,$039c,$03a2
	dc.w	$03a7,$03ac,$03b1,$03b6,$03bb,$03c0,$03c5,$03ca
	dc.w	$03cf,$03d4,$03d9,$03de,$03e3,$03e8,$03ed,$03f2
	dc.w	$03f7,$03fc,$0401,$0407,$040c,$0411,$0416,$041b
	dc.w	$0420,$0425,$042a,$042f,$0434,$0439,$043e,$0443
	dc.w	$0448,$044d,$0452,$0457,$045c,$0461,$0466,$046b
	dc.w	$0470,$0475,$047a,$047f,$0484,$0489,$048e,$0494
	dc.w	$0499,$049e,$04a3,$04a8,$04ad,$04b2,$04b7,$04bc
	dc.w	$04c1,$04c6,$04cb,$04d0,$04d5,$04da,$04df,$04e4
	dc.w	$04e9,$04ee,$04f3,$04f8,$04fd,$0502,$0507,$050c
	dc.w	$0511,$0516,$051b,$0520,$0525,$052a,$052f,$0534
	dc.w	$0539,$053e,$0543,$0548,$054d,$0552,$0557,$055c
	dc.w	$0561,$0566,$056b,$0570,$0575,$057a,$057f,$0584
	dc.w	$0589,$058e,$0593,$0598,$059d,$05a2,$05a7,$05ac
	dc.w	$05b1,$05b6,$05bb,$05c0,$05c5,$05ca,$05cf,$05d4
	dc.w	$05d9,$05de,$05e3,$05e8,$05ed,$05f2,$05f7,$05fc
	dc.w	$0601,$0606,$060b,$0610,$0615,$061a,$061f,$0624
	dc.w	$0629,$062e,$0633,$0638,$063d,$0642,$0647,$064c
	dc.w	$0651,$0656,$065b,$0660,$0665,$066a,$066e,$0673
	dc.w	$0678,$067d,$0682,$0687,$068c,$0691,$0696,$069b
	dc.w	$06a0,$06a5,$06aa,$06af,$06b4,$06b9,$06be,$06c3
	dc.w	$06c8,$06cd,$06d2,$06d7,$06dc,$06e1,$06e5,$06ea
	dc.w	$06ef,$06f4,$06f9,$06fe,$0703,$0708,$070d,$0712
	dc.w	$0717,$071c,$0721,$0726,$072b,$0730,$0735,$0739
	dc.w	$073e,$0743,$0748,$074d,$0752,$0757,$075c,$0761
	dc.w	$0766,$076b,$0770,$0775,$077a,$077e,$0783,$0788
	dc.w	$078d,$0792,$0797,$079c,$07a1,$07a6,$07ab,$07b0
	dc.w	$07b5,$07b9,$07be,$07c3,$07c8,$07cd,$07d2,$07d7
	dc.w	$07dc,$07e1,$07e6,$07eb,$07ef,$07f4,$07f9,$07fe
	dc.w	$0803,$0808,$080d,$0812,$0817,$081c,$0820,$0825
	dc.w	$082a,$082f,$0834,$0839,$083e,$0843,$0848,$084c
	dc.w	$0851,$0856,$085b,$0860,$0865,$086a,$086f,$0873
	dc.w	$0878,$087d,$0882,$0887,$088c,$0891,$0896,$089a
	dc.w	$089f,$08a4,$08a9,$08ae,$08b3,$08b8,$08bd,$08c1
	dc.w	$08c6,$08cb,$08d0,$08d5,$08da,$08df,$08e3,$08e8
	dc.w	$08ed,$08f2,$08f7,$08fc,$0901,$0905,$090a,$090f
	dc.w	$0914,$0919,$091e,$0922,$0927,$092c,$0931,$0936
	dc.w	$093b,$093f,$0944,$0949,$094e,$0953,$0958,$095c
	dc.w	$0961,$0966,$096b,$0970,$0975,$0979,$097e,$0983
	dc.w	$0988,$098d,$0992,$0996,$099b,$09a0,$09a5,$09aa
	dc.w	$09ae,$09b3,$09b8,$09bd,$09c2,$09c6,$09cb,$09d0
	dc.w	$09d5,$09da,$09de,$09e3,$09e8,$09ed,$09f2,$09f6
	dc.w	$09fb,$0a00,$0a05,$0a0a,$0a0e,$0a13,$0a18,$0a1d
	dc.w	$0a22,$0a26,$0a2b,$0a30,$0a35,$0a39,$0a3e,$0a43
	dc.w	$0a48,$0a4d,$0a51,$0a56,$0a5b,$0a60,$0a64,$0a69
	dc.w	$0a6e,$0a73,$0a77,$0a7c,$0a81,$0a86,$0a8b,$0a8f
	dc.w	$0a94,$0a99,$0a9e,$0aa2,$0aa7,$0aac,$0ab1,$0ab5
	dc.w	$0aba,$0abf,$0ac4,$0ac8,$0acd,$0ad2,$0ad7,$0adb
	dc.w	$0ae0,$0ae5,$0ae9,$0aee,$0af3,$0af8,$0afc,$0b01
	dc.w	$0b06,$0b0b,$0b0f,$0b14,$0b19,$0b1e,$0b22,$0b27
	dc.w	$0b2c,$0b30,$0b35,$0b3a,$0b3f,$0b43,$0b48,$0b4d
	dc.w	$0b51,$0b56,$0b5b,$0b60,$0b64,$0b69,$0b6e,$0b72
	dc.w	$0b77,$0b7c,$0b80,$0b85,$0b8a,$0b8f,$0b93,$0b98
	dc.w	$0b9d,$0ba1,$0ba6,$0bab,$0baf,$0bb4,$0bb9,$0bbd
	dc.w	$0bc2,$0bc7,$0bcb,$0bd0,$0bd5,$0bd9,$0bde,$0be3
	dc.w	$0be7,$0bec,$0bf1,$0bf5,$0bfa,$0bff,$0c03,$0c08
	dc.w	$0c0d,$0c11,$0c16,$0c1b,$0c1f,$0c24,$0c29,$0c2d
	dc.w	$0c32,$0c37,$0c3b,$0c40,$0c45,$0c49,$0c4e,$0c53
	dc.w	$0c57,$0c5c,$0c60,$0c65,$0c6a,$0c6e,$0c73,$0c78
	dc.w	$0c7c,$0c81,$0c86,$0c8a,$0c8f,$0c93,$0c98,$0c9d
	dc.w	$0ca1,$0ca6,$0cab,$0caf,$0cb4,$0cb8,$0cbd,$0cc2
	dc.w	$0cc6,$0ccb,$0ccf,$0cd4,$0cd9,$0cdd,$0ce2,$0ce6
	dc.w	$0ceb,$0cf0,$0cf4,$0cf9,$0cfd,$0d02,$0d07,$0d0b
	dc.w	$0d10,$0d14,$0d19,$0d1e,$0d22,$0d27,$0d2b,$0d30
	dc.w	$0d34,$0d39,$0d3e,$0d42,$0d47,$0d4b,$0d50,$0d54
	dc.w	$0d59,$0d5e,$0d62,$0d67,$0d6b,$0d70,$0d74,$0d79
	dc.w	$0d7d,$0d82,$0d87,$0d8b,$0d90,$0d94,$0d99,$0d9d
	dc.w	$0da2,$0da6,$0dab,$0daf,$0db4,$0db9,$0dbd,$0dc2
	dc.w	$0dc6,$0dcb,$0dcf,$0dd4,$0dd8,$0ddd,$0de1,$0de6
	dc.w	$0dea,$0def,$0df3,$0df8,$0dfc,$0e01,$0e05,$0e0a
	dc.w	$0e0f,$0e13,$0e18,$0e1c,$0e21,$0e25,$0e2a,$0e2e
	dc.w	$0e33,$0e37,$0e3c,$0e40,$0e45,$0e49,$0e4e,$0e52
	dc.w	$0e56,$0e5b,$0e5f,$0e64,$0e68,$0e6d,$0e71,$0e76
	dc.w	$0e7a,$0e7f,$0e83,$0e88,$0e8c,$0e91,$0e95,$0e9a
	dc.w	$0e9e,$0ea3,$0ea7,$0eac,$0eb0,$0eb4,$0eb9,$0ebd
	dc.w	$0ec2,$0ec6,$0ecb,$0ecf,$0ed4,$0ed8,$0edc,$0ee1
	dc.w	$0ee5,$0eea,$0eee,$0ef3,$0ef7,$0efc,$0f00,$0f04
	dc.w	$0f09,$0f0d,$0f12,$0f16,$0f1b,$0f1f,$0f23,$0f28
	dc.w	$0f2c,$0f31,$0f35,$0f3a,$0f3e,$0f42,$0f47,$0f4b
	dc.w	$0f50,$0f54,$0f58,$0f5d,$0f61,$0f66,$0f6a,$0f6e
	dc.w	$0f73,$0f77,$0f7c,$0f80,$0f84,$0f89,$0f8d,$0f91
	dc.w	$0f96,$0f9a,$0f9f,$0fa3,$0fa7,$0fac,$0fb0,$0fb5
	dc.w	$0fb9,$0fbd,$0fc2,$0fc6,$0fca,$0fcf,$0fd3,$0fd7
	dc.w	$0fdc,$0fe0,$0fe5,$0fe9,$0fed,$0ff2,$0ff6,$0ffa
	dc.w	$0fff,$1003,$1007,$100c,$1010,$1014,$1019,$101d
	dc.w	$1021,$1026,$102a,$102e,$1033,$1037,$103b,$1040
	dc.w	$1044,$1048,$104d,$1051,$1055,$105a,$105e,$1062
	dc.w	$1067,$106b,$106f,$1073,$1078,$107c,$1080,$1085
	dc.w	$1089,$108d,$1092,$1096,$109a,$109e,$10a3,$10a7
	dc.w	$10ab,$10b0,$10b4,$10b8,$10bc,$10c1,$10c5,$10c9
	dc.w	$10ce,$10d2,$10d6,$10da,$10df,$10e3,$10e7,$10eb
	dc.w	$10f0,$10f4,$10f8,$10fd,$1101,$1105,$1109,$110e
	dc.w	$1112,$1116,$111a,$111f,$1123,$1127,$112b,$1130
	dc.w	$1134,$1138,$113c,$1140,$1145,$1149,$114d,$1151
	dc.w	$1156,$115a,$115e,$1162,$1166,$116b,$116f,$1173
	dc.w	$1177,$117c,$1180,$1184,$1188,$118c,$1191,$1195
	dc.w	$1199,$119d,$11a1,$11a6,$11aa,$11ae,$11b2,$11b6
	dc.w	$11bb,$11bf,$11c3,$11c7,$11cb,$11cf,$11d4,$11d8
	dc.w	$11dc,$11e0,$11e4,$11e9,$11ed,$11f1,$11f5,$11f9
	dc.w	$11fd,$1202,$1206,$120a,$120e,$1212,$1216,$121a
	dc.w	$121f,$1223,$1227,$122b,$122f,$1233,$1237,$123c
	dc.w	$1240,$1244,$1248,$124c,$1250,$1254,$1259,$125d
	dc.w	$1261,$1265,$1269,$126d,$1271,$1275,$127a,$127e
	dc.w	$1282,$1286,$128a,$128e,$1292,$1296,$129a,$129f
	dc.w	$12a3,$12a7,$12ab,$12af,$12b3,$12b7,$12bb,$12bf
	dc.w	$12c3,$12c7,$12cc,$12d0,$12d4,$12d8,$12dc,$12e0
	dc.w	$12e4,$12e8,$12ec,$12f0,$12f4,$12f8,$12fc,$1301
	dc.w	$1305,$1309,$130d,$1311,$1315,$1319,$131d,$1321
	dc.w	$1325,$1329,$132d,$1331,$1335,$1339,$133d,$1341
	dc.w	$1345,$1349,$134d,$1351,$1355,$135a,$135e,$1362
	dc.w	$1366,$136a,$136e,$1372,$1376,$137a,$137e,$1382
	dc.w	$1386,$138a,$138e,$1392,$1396,$139a,$139e,$13a2
	dc.w	$13a6,$13aa,$13ae,$13b2,$13b6,$13ba,$13be,$13c2
	dc.w	$13c6,$13ca,$13ce,$13d2,$13d6,$13da,$13de,$13e2
	dc.w	$13e6,$13e9,$13ed,$13f1,$13f5,$13f9,$13fd,$1401
	dc.w	$1405,$1409,$140d,$1411,$1415,$1419,$141d,$1421
	dc.w	$1425,$1429,$142d,$1431,$1435,$1439,$143d,$1440
	dc.w	$1444,$1448,$144c,$1450,$1454,$1458,$145c,$1460
	dc.w	$1464,$1468,$146c,$1470,$1473,$1477,$147b,$147f
	dc.w	$1483,$1487,$148b,$148f,$1493,$1497,$149b,$149e
	dc.w	$14a2,$14a6,$14aa,$14ae,$14b2,$14b6,$14ba,$14be
	dc.w	$14c1,$14c5,$14c9,$14cd,$14d1,$14d5,$14d9,$14dd
	dc.w	$14e0,$14e4,$14e8,$14ec,$14f0,$14f4,$14f8,$14fb
	dc.w	$14ff,$1503,$1507,$150b,$150f,$1513,$1516,$151a
	dc.w	$151e,$1522,$1526,$152a,$152d,$1531,$1535,$1539
	dc.w	$153d,$1541,$1544,$1548,$154c,$1550,$1554,$1558
	dc.w	$155b,$155f,$1563,$1567,$156b,$156e,$1572,$1576
	dc.w	$157a,$157e,$1581,$1585,$1589,$158d,$1591,$1594
	dc.w	$1598,$159c,$15a0,$15a4,$15a7,$15ab,$15af,$15b3
	dc.w	$15b7,$15ba,$15be,$15c2,$15c6,$15c9,$15cd,$15d1
	dc.w	$15d5,$15d8,$15dc,$15e0,$15e4,$15e8,$15eb,$15ef
	dc.w	$15f3,$15f7,$15fa,$15fe,$1602,$1606,$1609,$160d
	dc.w	$1611,$1614,$1618,$161c,$1620,$1623,$1627,$162b
	dc.w	$162f,$1632,$1636,$163a,$163e,$1641,$1645,$1649
	dc.w	$164c,$1650,$1654,$1658,$165b,$165f,$1663,$1666
	dc.w	$166a,$166e,$1671,$1675,$1679,$167d,$1680,$1684
	dc.w	$1688,$168b,$168f,$1693,$1696,$169a,$169e,$16a1
	dc.w	$16a5,$16a9,$16ac,$16b0,$16b4,$16b7,$16bb,$16bf
	dc.w	$16c2,$16c6,$16ca,$16cd,$16d1,$16d5,$16d8,$16dc
	dc.w	$16e0,$16e3,$16e7,$16eb,$16ee,$16f2,$16f6,$16f9
	dc.w	$16fd,$1700,$1704,$1708,$170b,$170f,$1713,$1716
	dc.w	$171a,$171d,$1721,$1725,$1728,$172c,$1730,$1733
	dc.w	$1737,$173a,$173e,$1742,$1745,$1749,$174c,$1750
	dc.w	$1754,$1757,$175b,$175e,$1762,$1766,$1769,$176d
	dc.w	$1770,$1774,$1778,$177b,$177f,$1782,$1786,$1789
	dc.w	$178d,$1791,$1794,$1798,$179b,$179f,$17a2,$17a6
	dc.w	$17aa,$17ad,$17b1,$17b4,$17b8,$17bb,$17bf,$17c2
	dc.w	$17c6,$17c9,$17cd,$17d1,$17d4,$17d8,$17db,$17df
	dc.w	$17e2,$17e6,$17e9,$17ed,$17f0,$17f4,$17f7,$17fb
	dc.w	$17fe,$1802,$1806,$1809,$180d,$1810,$1814,$1817
	dc.w	$181b,$181e,$1822,$1825,$1829,$182c,$1830,$1833
	dc.w	$1837,$183a,$183e,$1841,$1845,$1848,$184c,$184f
	dc.w	$1853,$1856,$185a,$185d,$1860,$1864,$1867,$186b
	dc.w	$186e,$1872,$1875,$1879,$187c,$1880,$1883,$1887
	dc.w	$188a,$188e,$1891,$1894,$1898,$189b,$189f,$18a2
	dc.w	$18a6,$18a9,$18ad,$18b0,$18b3,$18b7,$18ba,$18be
	dc.w	$18c1,$18c5,$18c8,$18cc,$18cf,$18d2,$18d6,$18d9
	dc.w	$18dd,$18e0,$18e3,$18e7,$18ea,$18ee,$18f1,$18f5
	dc.w	$18f8,$18fb,$18ff,$1902,$1906,$1909,$190c,$1910
	dc.w	$1913,$1917,$191a,$191d,$1921,$1924,$1928,$192b
	dc.w	$192e,$1932,$1935,$1938,$193c,$193f,$1943,$1946
	dc.w	$1949,$194d,$1950,$1953,$1957,$195a,$195d,$1961
	dc.w	$1964,$1968,$196b,$196e,$1972,$1975,$1978,$197c
	dc.w	$197f,$1982,$1986,$1989,$198c,$1990,$1993,$1996
	dc.w	$199a,$199d,$19a0,$19a4,$19a7,$19aa,$19ae,$19b1
	dc.w	$19b4,$19b8,$19bb,$19be,$19c2,$19c5,$19c8,$19cc
	dc.w	$19cf,$19d2,$19d5,$19d9,$19dc,$19df,$19e3,$19e6
	dc.w	$19e9,$19ed,$19f0,$19f3,$19f6,$19fa,$19fd,$1a00
	dc.w	$1a04,$1a07,$1a0a,$1a0d,$1a11,$1a14,$1a17,$1a1b
	dc.w	$1a1e,$1a21,$1a24,$1a28,$1a2b,$1a2e,$1a31,$1a35
	dc.w	$1a38,$1a3b,$1a3e,$1a42,$1a45,$1a48,$1a4b,$1a4f
	dc.w	$1a52,$1a55,$1a58,$1a5c,$1a5f,$1a62,$1a65,$1a69
	dc.w	$1a6c,$1a6f,$1a72,$1a76,$1a79,$1a7c,$1a7f,$1a83
	dc.w	$1a86,$1a89,$1a8c,$1a8f,$1a93,$1a96,$1a99,$1a9c
	dc.w	$1a9f,$1aa3,$1aa6,$1aa9,$1aac,$1ab0,$1ab3,$1ab6
	dc.w	$1ab9,$1abc,$1ac0,$1ac3,$1ac6,$1ac9,$1acc,$1acf
	dc.w	$1ad3,$1ad6,$1ad9,$1adc,$1adf,$1ae3,$1ae6,$1ae9
	dc.w	$1aec,$1aef,$1af2,$1af6,$1af9,$1afc,$1aff,$1b02
	dc.w	$1b05,$1b09,$1b0c,$1b0f,$1b12,$1b15,$1b18,$1b1c
	dc.w	$1b1f,$1b22,$1b25,$1b28,$1b2b,$1b2e,$1b32,$1b35
	dc.w	$1b38,$1b3b,$1b3e,$1b41,$1b44,$1b48,$1b4b,$1b4e
	dc.w	$1b51,$1b54,$1b57,$1b5a,$1b5d,$1b61,$1b64,$1b67
	dc.w	$1b6a,$1b6d,$1b70,$1b73,$1b76,$1b79,$1b7d,$1b80
	dc.w	$1b83,$1b86,$1b89,$1b8c,$1b8f,$1b92,$1b95,$1b98
	dc.w	$1b9c,$1b9f,$1ba2,$1ba5,$1ba8,$1bab,$1bae,$1bb1
	dc.w	$1bb4,$1bb7,$1bba,$1bbd,$1bc1,$1bc4,$1bc7,$1bca
	dc.w	$1bcd,$1bd0,$1bd3,$1bd6,$1bd9,$1bdc,$1bdf,$1be2
	dc.w	$1be5,$1be8,$1beb,$1bee,$1bf2,$1bf5,$1bf8,$1bfb
	dc.w	$1bfe,$1c01,$1c04,$1c07,$1c0a,$1c0d,$1c10,$1c13
	dc.w	$1c16,$1c19,$1c1c,$1c1f,$1c22,$1c25,$1c28,$1c2b
	dc.w	$1c2e,$1c31,$1c34,$1c37,$1c3a,$1c3d,$1c40,$1c43
	dc.w	$1c46,$1c49,$1c4c,$1c4f,$1c52,$1c55,$1c58,$1c5b
	dc.w	$1c5e,$1c61,$1c64,$1c67,$1c6a,$1c6d,$1c70,$1c73
	dc.w	$1c76,$1c79,$1c7c,$1c7f,$1c82,$1c85,$1c88,$1c8b
	dc.w	$1c8e,$1c91,$1c94,$1c97,$1c9a,$1c9d,$1ca0,$1ca3
	dc.w	$1ca6,$1ca9,$1cac,$1caf,$1cb2,$1cb5,$1cb8,$1cbb
	dc.w	$1cbe,$1cc1,$1cc3,$1cc6,$1cc9,$1ccc,$1ccf,$1cd2
	dc.w	$1cd5,$1cd8,$1cdb,$1cde,$1ce1,$1ce4,$1ce7,$1cea
	dc.w	$1ced,$1cf0,$1cf3,$1cf5,$1cf8,$1cfb,$1cfe,$1d01
	dc.w	$1d04,$1d07,$1d0a,$1d0d,$1d10,$1d13,$1d16,$1d18
	dc.w	$1d1b,$1d1e,$1d21,$1d24,$1d27,$1d2a,$1d2d,$1d30
	dc.w	$1d33,$1d35,$1d38,$1d3b,$1d3e,$1d41,$1d44,$1d47
	dc.w	$1d4a,$1d4d,$1d4f,$1d52,$1d55,$1d58,$1d5b,$1d5e
	dc.w	$1d61,$1d64,$1d66,$1d69,$1d6c,$1d6f,$1d72,$1d75
	dc.w	$1d78,$1d7b,$1d7d,$1d80,$1d83,$1d86,$1d89,$1d8c
	dc.w	$1d8e,$1d91,$1d94,$1d97,$1d9a,$1d9d,$1da0,$1da2
	dc.w	$1da5,$1da8,$1dab,$1dae,$1db1,$1db3,$1db6,$1db9
	dc.w	$1dbc,$1dbf,$1dc2,$1dc4,$1dc7,$1dca,$1dcd,$1dd0
	dc.w	$1dd3,$1dd5,$1dd8,$1ddb,$1dde,$1de1,$1de3,$1de6
	dc.w	$1de9,$1dec,$1def,$1df1,$1df4,$1df7,$1dfa,$1dfd
	dc.w	$1dff,$1e02,$1e05,$1e08,$1e0b,$1e0d,$1e10,$1e13
	dc.w	$1e16,$1e19,$1e1b,$1e1e,$1e21,$1e24,$1e26,$1e29
	dc.w	$1e2c,$1e2f,$1e32,$1e34,$1e37,$1e3a,$1e3d,$1e3f
	dc.w	$1e42,$1e45,$1e48,$1e4a,$1e4d,$1e50,$1e53,$1e55
	dc.w	$1e58,$1e5b,$1e5e,$1e60,$1e63,$1e66,$1e69,$1e6b
	dc.w	$1e6e,$1e71,$1e74,$1e76,$1e79,$1e7c,$1e7f,$1e81
	dc.w	$1e84,$1e87,$1e8a,$1e8c,$1e8f,$1e92,$1e94,$1e97
	dc.w	$1e9a,$1e9d,$1e9f,$1ea2,$1ea5,$1ea8,$1eaa,$1ead
	dc.w	$1eb0,$1eb2,$1eb5,$1eb8,$1eba,$1ebd,$1ec0,$1ec3
	dc.w	$1ec5,$1ec8,$1ecb,$1ecd,$1ed0,$1ed3,$1ed5,$1ed8
	dc.w	$1edb,$1ede,$1ee0,$1ee3,$1ee6,$1ee8,$1eeb,$1eee
	dc.w	$1ef0,$1ef3,$1ef6,$1ef8,$1efb,$1efe,$1f00,$1f03
	dc.w	$1f06,$1f08,$1f0b,$1f0e,$1f10,$1f13,$1f16,$1f18
	dc.w	$1f1b,$1f1e,$1f20,$1f23,$1f26,$1f28,$1f2b,$1f2e
	dc.w	$1f30,$1f33,$1f36,$1f38,$1f3b,$1f3d,$1f40,$1f43
	dc.w	$1f45,$1f48,$1f4b,$1f4d,$1f50,$1f53,$1f55,$1f58
	dc.w	$1f5a,$1f5d,$1f60,$1f62,$1f65,$1f68,$1f6a,$1f6d
	dc.w	$1f6f,$1f72,$1f75,$1f77,$1f7a,$1f7c,$1f7f,$1f82
	dc.w	$1f84,$1f87,$1f8a,$1f8c,$1f8f,$1f91,$1f94,$1f97
	dc.w	$1f99,$1f9c,$1f9e,$1fa1,$1fa4,$1fa6,$1fa9,$1fab
	dc.w	$1fae,$1fb0,$1fb3,$1fb6,$1fb8,$1fbb,$1fbd,$1fc0
	dc.w	$1fc3,$1fc5,$1fc8,$1fca,$1fcd,$1fcf,$1fd2,$1fd5
	dc.w	$1fd7,$1fda,$1fdc,$1fdf,$1fe1,$1fe4,$1fe6,$1fe9
	dc.w	$1fec,$1fee,$1ff1,$1ff3,$1ff6,$1ff8,$1ffb,$1ffd


TAB.1dc46
	dc.w	$0000,$0010,$0020,$0030,$0040,$0050,$0060,$0070
	dc.w	$0080,$0090,$00a0,$00b0,$00c0,$00d0,$00e0,$00f0
	dc.w	$0100,$0110,$0120,$0130,$0140,$0150,$0160,$0170
	dc.w	$0180,$0190,$01a0,$01b0,$01c0,$01d0,$01e0,$01f0
	dc.w	$0200,$0210,$0220,$0230,$0240,$0250,$0260,$0270
	dc.w	$0280,$0290,$02a0,$02b0,$02c0,$02d0,$02e0,$02f0
	dc.w	$0300,$0310,$0320,$0330,$0340,$0350,$0360,$0370
	dc.w	$0380,$0390,$03a0,$03b0,$03c0,$03d0,$03e0,$03f0
	dc.w	$0400,$0410,$0420,$0430,$0440,$0450,$0460,$0470
	dc.w	$0480,$0490,$04a0,$04b0,$04c0,$04d0,$04e0,$04f0
	dc.w	$0500,$050f,$051f,$052f,$053f,$054f,$055f,$056f
	dc.w	$057f,$058f,$059f,$05af,$05bf,$05cf,$05df,$05ef
	dc.w	$05ff,$060f,$061f,$062f,$063f,$064f,$065f,$066f
	dc.w	$067f,$068f,$069f,$06af,$06bf,$06cf,$06df,$06ef
	dc.w	$06ff,$070f,$071f,$072f,$073f,$074e,$075e,$076e
	dc.w	$077e,$078e,$079e,$07ae,$07be,$07ce,$07de,$07ee
	dc.w	$07fe,$080e,$081e,$082e,$083e,$084e,$085e,$086e
	dc.w	$087e,$088e,$089d,$08ad,$08bd,$08cd,$08dd,$08ed
	dc.w	$08fd,$090d,$091d,$092d,$093d,$094d,$095d,$096d
	dc.w	$097d,$098d,$099d,$09ac,$09bc,$09cc,$09dc,$09ec
	dc.w	$09fc,$0a0c,$0a1c,$0a2c,$0a3c,$0a4c,$0a5c,$0a6c
	dc.w	$0a7b,$0a8b,$0a9b,$0aab,$0abb,$0acb,$0adb,$0aeb
	dc.w	$0afb,$0b0b,$0b1b,$0b2b,$0b3a,$0b4a,$0b5a,$0b6a
	dc.w	$0b7a,$0b8a,$0b9a,$0baa,$0bba,$0bca,$0bd9,$0be9
	dc.w	$0bf9,$0c09,$0c19,$0c29,$0c39,$0c49,$0c59,$0c69
	dc.w	$0c78,$0c88,$0c98,$0ca8,$0cb8,$0cc8,$0cd8,$0ce8
	dc.w	$0cf7,$0d07,$0d17,$0d27,$0d37,$0d47,$0d57,$0d67
	dc.w	$0d76,$0d86,$0d96,$0da6,$0db6,$0dc6,$0dd6,$0de5
	dc.w	$0df5,$0e05,$0e15,$0e25,$0e35,$0e45,$0e54,$0e64
	dc.w	$0e74,$0e84,$0e94,$0ea4,$0eb4,$0ec3,$0ed3,$0ee3
	dc.w	$0ef3,$0f03,$0f13,$0f22,$0f32,$0f42,$0f52,$0f62
	dc.w	$0f72,$0f81,$0f91,$0fa1,$0fb1,$0fc1,$0fd0,$0fe0
	dc.w	$0ff0,$1000,$1010,$1020,$102f,$103f,$104f,$105f
	dc.w	$106f,$107e,$108e,$109e,$10ae,$10be,$10cd,$10dd
	dc.w	$10ed,$10fd,$110d,$111c,$112c,$113c,$114c,$115b
	dc.w	$116b,$117b,$118b,$119b,$11aa,$11ba,$11ca,$11da
	dc.w	$11e9,$11f9,$1209,$1219,$1228,$1238,$1248,$1258
	dc.w	$1268,$1277,$1287,$1297,$12a7,$12b6,$12c6,$12d6
	dc.w	$12e5,$12f5,$1305,$1315,$1324,$1334,$1344,$1354
	dc.w	$1363,$1373,$1383,$1393,$13a2,$13b2,$13c2,$13d1
	dc.w	$13e1,$13f1,$1401,$1410,$1420,$1430,$143f,$144f
	dc.w	$145f,$146e,$147e,$148e,$149e,$14ad,$14bd,$14cd
	dc.w	$14dc,$14ec,$14fc,$150b,$151b,$152b,$153a,$154a
	dc.w	$155a,$1569,$1579,$1589,$1598,$15a8,$15b8,$15c7
	dc.w	$15d7,$15e7,$15f6,$1606,$1616,$1625,$1635,$1645
	dc.w	$1654,$1664,$1673,$1683,$1693,$16a2,$16b2,$16c2
	dc.w	$16d1,$16e1,$16f0,$1700,$1710,$171f,$172f,$173f
	dc.w	$174e,$175e,$176d,$177d,$178d,$179c,$17ac,$17bb
	dc.w	$17cb,$17db,$17ea,$17fa,$1809,$1819,$1828,$1838
	dc.w	$1848,$1857,$1867,$1876,$1886,$1895,$18a5,$18b5
	dc.w	$18c4,$18d4,$18e3,$18f3,$1902,$1912,$1921,$1931
	dc.w	$1940,$1950,$1960,$196f,$197f,$198e,$199e,$19ad
	dc.w	$19bd,$19cc,$19dc,$19eb,$19fb,$1a0a,$1a1a,$1a29
	dc.w	$1a39,$1a48,$1a58,$1a67,$1a77,$1a86,$1a96,$1aa5
	dc.w	$1ab5,$1ac4,$1ad4,$1ae3,$1af3,$1b02,$1b12,$1b21
	dc.w	$1b31,$1b40,$1b50,$1b5f,$1b6e,$1b7e,$1b8d,$1b9d
	dc.w	$1bac,$1bbc,$1bcb,$1bdb,$1bea,$1bf9,$1c09,$1c18
	dc.w	$1c28,$1c37,$1c47,$1c56,$1c65,$1c75,$1c84,$1c94
	dc.w	$1ca3,$1cb3,$1cc2,$1cd1,$1ce1,$1cf0,$1d00,$1d0f
	dc.w	$1d1e,$1d2e,$1d3d,$1d4c,$1d5c,$1d6b,$1d7b,$1d8a
	dc.w	$1d99,$1da9,$1db8,$1dc7,$1dd7,$1de6,$1df6,$1e05
	dc.w	$1e14,$1e24,$1e33,$1e42,$1e52,$1e61,$1e70,$1e80
	dc.w	$1e8f,$1e9e,$1eae,$1ebd,$1ecc,$1edc,$1eeb,$1efa
	dc.w	$1f09,$1f19,$1f28,$1f37,$1f47,$1f56,$1f65,$1f75
	dc.w	$1f84,$1f93,$1fa2,$1fb2,$1fc1,$1fd0,$1fe0,$1fef
	dc.w	$1ffe,$200d,$201d,$202c,$203b,$204a,$205a,$2069
	dc.w	$2078,$2087,$2097,$20a6,$20b5,$20c4,$20d4,$20e3
	dc.w	$20f2,$2101,$2110,$2120,$212f,$213e,$214d,$215c
	dc.w	$216c,$217b,$218a,$2199,$21a8,$21b8,$21c7,$21d6
	dc.w	$21e5,$21f4,$2204,$2213,$2222,$2231,$2240,$224f
	dc.w	$225f,$226e,$227d,$228c,$229b,$22aa,$22b9,$22c9
	dc.w	$22d8,$22e7,$22f6,$2305,$2314,$2323,$2332,$2342
	dc.w	$2351,$2360,$236f,$237e,$238d,$239c,$23ab,$23ba
	dc.w	$23c9,$23d8,$23e8,$23f7,$2406,$2415,$2424,$2433
	dc.w	$2442,$2451,$2460,$246f,$247e,$248d,$249c,$24ab
	dc.w	$24ba,$24c9,$24d8,$24e8,$24f7,$2506,$2515,$2524
	dc.w	$2533,$2542,$2551,$2560,$256f,$257e,$258d,$259c
	dc.w	$25ab,$25ba,$25c9,$25d8,$25e7,$25f6,$2605,$2613
	dc.w	$2622,$2631,$2640,$264f,$265e,$266d,$267c,$268b
	dc.w	$269a,$26a9,$26b8,$26c7,$26d6,$26e5,$26f4,$2703
	dc.w	$2712,$2720,$272f,$273e,$274d,$275c,$276b,$277a
	dc.w	$2789,$2798,$27a7,$27b5,$27c4,$27d3,$27e2,$27f1
	dc.w	$2800,$280f,$281d,$282c,$283b,$284a,$2859,$2868
	dc.w	$2877,$2885,$2894,$28a3,$28b2,$28c1,$28d0,$28de
	dc.w	$28ed,$28fc,$290b,$291a,$2928,$2937,$2946,$2955
	dc.w	$2964,$2972,$2981,$2990,$299f,$29ae,$29bc,$29cb
	dc.w	$29da,$29e9,$29f7,$2a06,$2a15,$2a24,$2a32,$2a41
	dc.w	$2a50,$2a5f,$2a6d,$2a7c,$2a8b,$2a99,$2aa8,$2ab7
	dc.w	$2ac6,$2ad4,$2ae3,$2af2,$2b00,$2b0f,$2b1e,$2b2c
	dc.w	$2b3b,$2b4a,$2b58,$2b67,$2b76,$2b84,$2b93,$2ba2
	dc.w	$2bb0,$2bbf,$2bce,$2bdc,$2beb,$2bfa,$2c08,$2c17
	dc.w	$2c26,$2c34,$2c43,$2c51,$2c60,$2c6f,$2c7d,$2c8c
	dc.w	$2c9b,$2ca9,$2cb8,$2cc6,$2cd5,$2ce3,$2cf2,$2d01
	dc.w	$2d0f,$2d1e,$2d2c,$2d3b,$2d49,$2d58,$2d67,$2d75
	dc.w	$2d84,$2d92,$2da1,$2daf,$2dbe,$2dcc,$2ddb,$2de9
	dc.w	$2df8,$2e06,$2e15,$2e23,$2e32,$2e40,$2e4f,$2e5d
	dc.w	$2e6c,$2e7a,$2e89,$2e97,$2ea6,$2eb4,$2ec3,$2ed1
	dc.w	$2ee0,$2eee,$2efd,$2f0b,$2f1a,$2f28,$2f36,$2f45
	dc.w	$2f53,$2f62,$2f70,$2f7f,$2f8d,$2f9b,$2faa,$2fb8
	dc.w	$2fc7,$2fd5,$2fe3,$2ff2,$3000,$300f,$301d,$302b
	dc.w	$303a,$3048,$3057,$3065,$3073,$3082,$3090,$309e
	dc.w	$30ad,$30bb,$30c9,$30d8,$30e6,$30f4,$3103,$3111
	dc.w	$311f,$312e,$313c,$314a,$3159,$3167,$3175,$3183
	dc.w	$3192,$31a0,$31ae,$31bd,$31cb,$31d9,$31e7,$31f6
	dc.w	$3204,$3212,$3220,$322f,$323d,$324b,$3259,$3268
	dc.w	$3276,$3284,$3292,$32a0,$32af,$32bd,$32cb,$32d9
	dc.w	$32e8,$32f6,$3304,$3312,$3320,$332e,$333d,$334b
	dc.w	$3359,$3367,$3375,$3383,$3392,$33a0,$33ae,$33bc
	dc.w	$33ca,$33d8,$33e6,$33f5,$3403,$3411,$341f,$342d
	dc.w	$343b,$3449,$3457,$3466,$3474,$3482,$3490,$349e
	dc.w	$34ac,$34ba,$34c8,$34d6,$34e4,$34f2,$3500,$350e
	dc.w	$351c,$352b,$3539,$3547,$3555,$3563,$3571,$357f
	dc.w	$358d,$359b,$35a9,$35b7,$35c5,$35d3,$35e1,$35ef
	dc.w	$35fd,$360b,$3619,$3627,$3635,$3643,$3651,$365f
	dc.w	$366d,$367a,$3688,$3696,$36a4,$36b2,$36c0,$36ce
	dc.w	$36dc,$36ea,$36f8,$3706,$3714,$3722,$3730,$373d
	dc.w	$374b,$3759,$3767,$3775,$3783,$3791,$379f,$37ac
	dc.w	$37ba,$37c8,$37d6,$37e4,$37f2,$3800,$380d,$381b
	dc.w	$3829,$3837,$3845,$3853,$3860,$386e,$387c,$388a
	dc.w	$3898,$38a5,$38b3,$38c1,$38cf,$38dd,$38ea,$38f8
	dc.w	$3906,$3914,$3921,$392f,$393d,$394b,$3958,$3966
	dc.w	$3974,$3982,$398f,$399d,$39ab,$39b9,$39c6,$39d4
	dc.w	$39e2,$39ef,$39fd,$3a0b,$3a18,$3a26,$3a34,$3a42
	dc.w	$3a4f,$3a5d,$3a6b,$3a78,$3a86,$3a94,$3aa1,$3aaf
	dc.w	$3abc,$3aca,$3ad8,$3ae5,$3af3,$3b01,$3b0e,$3b1c
	dc.w	$3b29,$3b37,$3b45,$3b52,$3b60,$3b6d,$3b7b,$3b89
	dc.w	$3b96,$3ba4,$3bb1,$3bbf,$3bcd,$3bda,$3be8,$3bf5
	dc.w	$3c03,$3c10,$3c1e,$3c2b,$3c39,$3c46,$3c54,$3c61
	dc.w	$3c6f,$3c7c,$3c8a,$3c97,$3ca5,$3cb2,$3cc0,$3ccd
	dc.w	$3cdb,$3ce8,$3cf6,$3d03,$3d11,$3d1e,$3d2c,$3d39
	dc.w	$3d47,$3d54,$3d62,$3d6f,$3d7c,$3d8a,$3d97,$3da5
	dc.w	$3db2,$3dc0,$3dcd,$3dda,$3de8,$3df5,$3e03,$3e10
	dc.w	$3e1d,$3e2b,$3e38,$3e45,$3e53,$3e60,$3e6e,$3e7b
	dc.w	$3e88,$3e96,$3ea3,$3eb0,$3ebe,$3ecb,$3ed8,$3ee6
	dc.w	$3ef3,$3f00,$3f0e,$3f1b,$3f28,$3f35,$3f43,$3f50
	dc.w	$3f5d,$3f6b,$3f78,$3f85,$3f92,$3fa0,$3fad,$3fba
	dc.w	$3fc7,$3fd5,$3fe2,$3fef,$3ffc,$400a,$4017,$4024
	dc.w	$4031,$403f,$404c,$4059,$4066,$4073,$4081,$408e
	dc.w	$409b,$40a8,$40b5,$40c3,$40d0,$40dd,$40ea,$40f7
	dc.w	$4104,$4112,$411f,$412c,$4139,$4146,$4153,$4160
	dc.w	$416d,$417b,$4188,$4195,$41a2,$41af,$41bc,$41c9
	dc.w	$41d6,$41e3,$41f0,$41fe,$420b,$4218,$4225,$4232
	dc.w	$423f,$424c,$4259,$4266,$4273,$4280,$428d,$429a
	dc.w	$42a7,$42b4,$42c1,$42ce,$42db,$42e8,$42f5,$4302
	dc.w	$430f,$431c,$4329,$4336,$4343,$4350,$435d,$436a
	dc.w	$4377,$4384,$4391,$439e,$43ab,$43b8,$43c5,$43d2
	dc.w	$43df,$43eb,$43f8,$4405,$4412,$441f,$442c,$4439
	dc.w	$4446,$4453,$4460,$446c,$4479,$4486,$4493,$44a0
	dc.w	$44ad,$44ba,$44c6,$44d3,$44e0,$44ed,$44fa,$4507
	dc.w	$4513,$4520,$452d,$453a,$4547,$4553,$4560,$456d
	dc.w	$457a,$4587,$4593,$45a0,$45ad,$45ba,$45c7,$45d3
	dc.w	$45e0,$45ed,$45fa,$4606,$4613,$4620,$462c,$4639
	dc.w	$4646,$4653,$465f,$466c,$4679,$4685,$4692,$469f
	dc.w	$46ac,$46b8,$46c5,$46d2,$46de,$46eb,$46f8,$4704
	dc.w	$4711,$471e,$472a,$4737,$4744,$4750,$475d,$4769
	dc.w	$4776,$4783,$478f,$479c,$47a8,$47b5,$47c2,$47ce
	dc.w	$47db,$47e7,$47f4,$4801,$480d,$481a,$4826,$4833
	dc.w	$483f,$484c,$4859,$4865,$4872,$487e,$488b,$4897
	dc.w	$48a4,$48b0,$48bd,$48c9,$48d6,$48e2,$48ef,$48fb
	dc.w	$4908,$4914,$4921,$492d,$493a,$4946,$4953,$495f
	dc.w	$496b,$4978,$4984,$4991,$499d,$49aa,$49b6,$49c3
	dc.w	$49cf,$49db,$49e8,$49f4,$4a01,$4a0d,$4a19,$4a26
	dc.w	$4a32,$4a3f,$4a4b,$4a57,$4a64,$4a70,$4a7c,$4a89
	dc.w	$4a95,$4aa1,$4aae,$4aba,$4ac6,$4ad3,$4adf,$4aeb
	dc.w	$4af8,$4b04,$4b10,$4b1d,$4b29,$4b35,$4b42,$4b4e
	dc.w	$4b5a,$4b66,$4b73,$4b7f,$4b8b,$4b98,$4ba4,$4bb0
	dc.w	$4bbc,$4bc9,$4bd5,$4be1,$4bed,$4bfa,$4c06,$4c12
	dc.w	$4c1e,$4c2a,$4c37,$4c43,$4c4f,$4c5b,$4c67,$4c74
	dc.w	$4c80,$4c8c,$4c98,$4ca4,$4cb0,$4cbd,$4cc9,$4cd5
	dc.w	$4ce1,$4ced,$4cf9,$4d06,$4d12,$4d1e,$4d2a,$4d36
	dc.w	$4d42,$4d4e,$4d5a,$4d66,$4d73,$4d7f,$4d8b,$4d97
	dc.w	$4da3,$4daf,$4dbb,$4dc7,$4dd3,$4ddf,$4deb,$4df7
	dc.w	$4e03,$4e0f,$4e1c,$4e28,$4e34,$4e40,$4e4c,$4e58
	dc.w	$4e64,$4e70,$4e7c,$4e88,$4e94,$4ea0,$4eac,$4eb8
	dc.w	$4ec4,$4ed0,$4edc,$4ee8,$4ef4,$4f00,$4f0b,$4f17
	dc.w	$4f23,$4f2f,$4f3b,$4f47,$4f53,$4f5f,$4f6b,$4f77
	dc.w	$4f83,$4f8f,$4f9b,$4fa7,$4fb2,$4fbe,$4fca,$4fd6
	dc.w	$4fe2,$4fee,$4ffa,$5006,$5011,$501d,$5029,$5035
	dc.w	$5041,$504d,$5059,$5064,$5070,$507c,$5088,$5094
	dc.w	$50a0,$50ab,$50b7,$50c3,$50cf,$50db,$50e6,$50f2
	dc.w	$50fe,$510a,$5115,$5121,$512d,$5139,$5144,$5150
	dc.w	$515c,$5168,$5173,$517f,$518b,$5197,$51a2,$51ae
	dc.w	$51ba,$51c5,$51d1,$51dd,$51e9,$51f4,$5200,$520c
	dc.w	$5217,$5223,$522f,$523a,$5246,$5252,$525d,$5269
	dc.w	$5275,$5280,$528c,$5298,$52a3,$52af,$52ba,$52c6
	dc.w	$52d2,$52dd,$52e9,$52f4,$5300,$530c,$5317,$5323
	dc.w	$532e,$533a,$5346,$5351,$535d,$5368,$5374,$537f
	dc.w	$538b,$5396,$53a2,$53ae,$53b9,$53c5,$53d0,$53dc
	dc.w	$53e7,$53f3,$53fe,$540a,$5415,$5421,$542c,$5438
	dc.w	$5443,$544f,$545a,$5465,$5471,$547c,$5488,$5493
	dc.w	$549f,$54aa,$54b6,$54c1,$54cd,$54d8,$54e3,$54ef
	dc.w	$54fa,$5506,$5511,$551c,$5528,$5533,$553f,$554a
	dc.w	$5555,$5561,$556c,$5577,$5583,$558e,$559a,$55a5
	dc.w	$55b0,$55bc,$55c7,$55d2,$55de,$55e9,$55f4,$5600
	dc.w	$560b,$5616,$5621,$562d,$5638,$5643,$564f,$565a
	dc.w	$5665,$5670,$567c,$5687,$5692,$569e,$56a9,$56b4
	dc.w	$56bf,$56cb,$56d6,$56e1,$56ec,$56f7,$5703,$570e
	dc.w	$5719,$5724,$5730,$573b,$5746,$5751,$575c,$5768
	dc.w	$5773,$577e,$5789,$5794,$579f,$57ab,$57b6,$57c1
	dc.w	$57cc,$57d7,$57e2,$57ed,$57f9,$5804,$580f,$581a
	dc.w	$5825,$5830,$583b,$5846,$5851,$585d,$5868,$5873
	dc.w	$587e,$5889,$5894,$589f,$58aa,$58b5,$58c0,$58cb
	dc.w	$58d6,$58e1,$58ec,$58f7,$5902,$590e,$5919,$5924
	dc.w	$592f,$593a,$5945,$5950,$595b,$5966,$5971,$597c
	dc.w	$5987,$5992,$599d,$59a8,$59b2,$59bd,$59c8,$59d3
	dc.w	$59de,$59e9,$59f4,$59ff,$5a0a,$5a15,$5a20,$5a2b
	dc.w	$5a36,$5a41,$5a4c,$5a57,$5a61,$5a6c,$5a77,$5a82
	dc.w	$5a8d,$5a98,$5aa3,$5aae,$5ab9,$5ac3,$5ace,$5ad9
	dc.w	$5ae4,$5aef,$5afa,$5b04,$5b0f,$5b1a,$5b25,$5b30
	dc.w	$5b3b,$5b45,$5b50,$5b5b,$5b66,$5b71,$5b7b,$5b86
	dc.w	$5b91,$5b9c,$5ba7,$5bb1,$5bbc,$5bc7,$5bd2,$5bdc
	dc.w	$5be7,$5bf2,$5bfd,$5c07,$5c12,$5c1d,$5c28,$5c32
	dc.w	$5c3d,$5c48,$5c53,$5c5d,$5c68,$5c73,$5c7d,$5c88
	dc.w	$5c93,$5c9e,$5ca8,$5cb3,$5cbe,$5cc8,$5cd3,$5cde
	dc.w	$5ce8,$5cf3,$5cfe,$5d08,$5d13,$5d1d,$5d28,$5d33
	dc.w	$5d3d,$5d48,$5d53,$5d5d,$5d68,$5d72,$5d7d,$5d88
	dc.w	$5d92,$5d9d,$5da7,$5db2,$5dbd,$5dc7,$5dd2,$5ddc
	dc.w	$5de7,$5df1,$5dfc,$5e07,$5e11,$5e1c,$5e26,$5e31
	dc.w	$5e3b,$5e46,$5e50,$5e5b,$5e65,$5e70,$5e7a,$5e85
	dc.w	$5e8f,$5e9a,$5ea4,$5eaf,$5eb9,$5ec4,$5ece,$5ed9
	dc.w	$5ee3,$5eee,$5ef8,$5f03,$5f0d,$5f18,$5f22,$5f2c
	dc.w	$5f37,$5f41,$5f4c,$5f56,$5f61,$5f6b,$5f75,$5f80
	dc.w	$5f8a,$5f95,$5f9f,$5fa9,$5fb4,$5fbe,$5fc9,$5fd3
	dc.w	$5fdd,$5fe8,$5ff2,$5ffc,$6007,$6011,$601b,$6026
	dc.w	$6030,$603b,$6045,$604f,$605a,$6064,$606e,$6078
	dc.w	$6083,$608d,$6097,$60a2,$60ac,$60b6,$60c1,$60cb
	dc.w	$60d5,$60df,$60ea,$60f4,$60fe,$6108,$6113,$611d
	dc.w	$6127,$6131,$613c,$6146,$6150,$615a,$6165,$616f
	dc.w	$6179,$6183,$618e,$6198,$61a2,$61ac,$61b6,$61c1
	dc.w	$61cb,$61d5,$61df,$61e9,$61f3,$61fe,$6208,$6212
	dc.w	$621c,$6226,$6230,$623a,$6245,$624f,$6259,$6263
	dc.w	$626d,$6277,$6281,$628c,$6296,$62a0,$62aa,$62b4
	dc.w	$62be,$62c8,$62d2,$62dc,$62e6,$62f0,$62fa,$6305
	dc.w	$630f,$6319,$6323,$632d,$6337,$6341,$634b,$6355
	dc.w	$635f,$6369,$6373,$637d,$6387,$6391,$639b,$63a5
	dc.w	$63af,$63b9,$63c3,$63cd,$63d7,$63e1,$63eb,$63f5
	dc.w	$63ff,$6409,$6413,$641d,$6427,$6431,$643b,$6445
	dc.w	$644f,$6459,$6462,$646c,$6476,$6480,$648a,$6494
	dc.w	$649e,$64a8,$64b2,$64bc,$64c6,$64cf,$64d9,$64e3
	dc.w	$64ed,$64f7,$6501,$650b,$6515,$651e,$6528,$6532
	dc.w	$653c,$6546,$6550,$655a,$6563,$656d,$6577,$6581
	dc.w	$658b,$6595,$659e,$65a8,$65b2,$65bc,$65c6,$65cf
	dc.w	$65d9,$65e3,$65ed,$65f6,$6600,$660a,$6614,$661e
	dc.w	$6627,$6631,$663b,$6645,$664e,$6658,$6662,$666b
	dc.w	$6675,$667f,$6689,$6692,$669c,$66a6,$66b0,$66b9
	dc.w	$66c3,$66cd,$66d6,$66e0,$66ea,$66f3,$66fd,$6707
	dc.w	$6710,$671a,$6724,$672d,$6737,$6741,$674a,$6754
	dc.w	$675e,$6767,$6771,$677a,$6784,$678e,$6797,$67a1
	dc.w	$67ab,$67b4,$67be,$67c7,$67d1,$67db,$67e4,$67ee
	dc.w	$67f7,$6801,$680a,$6814,$681e,$6827,$6831,$683a
	dc.w	$6844,$684d,$6857,$6860,$686a,$6874,$687d,$6887
	dc.w	$6890,$689a,$68a3,$68ad,$68b6,$68c0,$68c9,$68d3
	dc.w	$68dc,$68e6,$68ef,$68f9,$6902,$690c,$6915,$691e
	dc.w	$6928,$6931,$693b,$6944,$694e,$6957,$6961,$696a
	dc.w	$6973,$697d,$6986,$6990,$6999,$69a3,$69ac,$69b5
	dc.w	$69bf,$69c8,$69d2,$69db,$69e4,$69ee,$69f7,$6a01



far.section.ptrs
	dc.l	far.section0,far.section1,far.section2,far.section3
	dc.l	far.section4,far.section5,far.section6,far.section7
	dc.l	far.section8,far.section9,far.section10,far.section11
	dc.l	far.section12,far.section13,far.section14,far.section15
	dc.l	far.section16,far.section17,far.section18,far.section19
	dc.l	far.section20,far.section21,far.section22,far.section23
	dc.l	far.section24,far.section25,far.section26,far.section27
	dc.l	far.section28,far.section29,far.section30,far.section31
	dc.l	far.section32,far.section33,far.section34,far.section35
	dc.l	far.section36,far.section37,far.section38,far.section39
	dc.l	far.section40,far.section41,far.section42,far.section43
	ds.l	36


far.section.flags
	ds.w	64


far.section0
	dc.w	0,$04c0,$0200,$0660,$0340,$0200,$0660
	dc.w	0!$2000,$04c0,$0100,$0280,$0340,$0100,$0280
	dc.w	0,$04c0,$0000,$0280,$0340,$0000,$0280

far.section1
	dc.w	1,$04c0,$0500,$0280,$0340,$0500,$0280
	dc.w	1!$2000,$04c0,$0400,$0780,$0340,$0400,$0780
	dc.w	1,$04c0,$0000,$0780,$0340,$0000,$0780

far.section2
	dc.w	2,$04c0,$0000,$0a60,$0340,$0000,$0a60

far.section3
	dc.w	3,$04c0,$0000,$1260,$0340,$0000,$1260

far.section4
	dc.w	4,$04c0,$0000,$1a60,$0340,$0000,$1a60

far.section5
	dc.w	5,$04c0,$0200,$1d40,$0340,$0200,$1d40
	dc.w	5,$04c0,$0000,$1d40,$0340,$0000,$1d40

far.section6
	dc.w	6,$04c0,$0000,$1d40,$0340,$0000,$1d40

far.section7
	dc.w	7,$04c0,$0000,$1d40,$0340,$0000,$1d40

far.section8
	dc.w	8,$04c0,$0100,$1d20,$0340,$0100,$1d20

far.section9
	dc.w	9,$04c0,$0000,$19a0,$0340,$0000,$19a0

far.section10
	dc.w	10!$4000,$04c0,$0000,$17a0,$0340,$0000,$13a0

far.section11
	dc.w	11,$0104,$fefd,$1380,$fff5,$000c,$0ec0

far.section12
	dc.w	12,$011c,$034d,$0f60,$00fb,$04cb,$0ae0

far.section13
	dc.w	13,$0000,$0340,$08a0,$0000,$04c0,$08a0

far.section14
	dc.w	14,$0000,$0340,$0560,$0000,$04c0,$0560

far.section15
	dc.w	15!$0100,$0000,$0340,$0500,$0000,$04c0,$0500

far.section16
	dc.w	16,$0000,$0340,$0500,$0000,$04c0,$0500

far.section17
	dc.w	17,$0000,$0340,$0500,$0000,$04c0,$0500

far.section18
	dc.w	18,$0000,$0340,$0500,$0000,$04c0,$0500

far.section19
	dc.w	19,$0000,$0340,$0500,$0000,$04c0,$0500

far.section20
	dc.w	20,$0000,$0340,$0500,$0000,$04c0,$0500

far.section21
	dc.w	21,$0000,$0340,$0500,$0000,$04c0,$0500

far.section22
	dc.w	22,$0000,$0340,$0500,$0000,$04c0,$0500

far.section23
	dc.w	23,$0000,$0340,$0500,$0000,$04c0,$0500

far.section24
	dc.w	24,$0000,$0340,$0700,$0000,$04c0,$0300

far.section25
	dc.w	25,$fefd,$06fc,$0760,$000c,$080b,$02a0

far.section26
	dc.w	26,$0340,$0800,$0760,$04c0,$0800,$02a0

far.section27
	dc.w	27,$059c,$069a,$0740,$06c5,$05a6,$02c0

far.section28
	dc.w	28,$0779,$0888,$0500,$0888,$0779,$0500

far.section29
	dc.w	29,$0778,$0887,$0500,$0887,$0778,$0500

far.section30
	dc.w	30,$0778,$0887,$0500,$0887,$0778,$0500

far.section31
	dc.w	31,$0778,$0887,$0500,$0887,$0778,$0500

far.section32
	dc.w	32,$0778,$0887,$0aa0,$0887,$0778,$0aa0

far.section33
	dc.w	33,$048f,$059f,$0f00,$059f,$048f,$0f00
	dc.w	33,$0778,$0887,$0500,$0887,$0778,$0500

far.section34
	dc.w	34,$0778,$0887,$0500,$0887,$0778,$0500

far.section35
	dc.w	35!$2000,$0032,$0141,$0c80,$0141,$0032,$0c80
	dc.w	35,$0778,$0887,$0640,$0887,$0778,$0640

far.section36
	dc.w	36,$0778,$0887,$0500,$0887,$0778,$0500

far.section37
	dc.w	37,$0778,$0887,$0500,$0887,$0778,$0500

far.section38
	dc.w	38,$0778,$0887,$0500,$0887,$0778,$0500

far.section39
	dc.w	39!$4000,$08a4,$09b3,$0700,$09b3,$08a4,$0300

far.section40
	dc.w	40,$0800,$04bf,$0760,$0800,$033f,$02a0

far.section41
	dc.w	41,$0903,$0104,$0760,$07f4,$fff5,$02a0

far.section42
	dc.w	42,$04b3,$011c,$0740,$0335,$00fb,$02c0

far.section43
	dc.w	43,$04c0,$0000,$0500,$0340,$0000,$0500

end.far.sections
	ds.w	243



sin.table
	dc.w	$ffff,$fffe,$fffb,$fff4,$ffec,$ffe1,$ffd3,$ffc3
	dc.w	$ffb1,$ff9c,$ff84,$ff6a,$ff4e,$ff2f,$ff0e,$feea
	dc.w	$fec4,$fe9b,$fe70,$fe43,$fe13,$fde0,$fdab,$fd74
	dc.w	$fd3a,$fcfe,$fcbf,$fc7e,$fc3b,$fbf5,$fbac,$fb61
	dc.w	$fb14,$fac5,$fa73,$fa1e,$f9c7,$f96e,$f912,$f8b4
	dc.w	$f853,$f7f1,$f78b,$f724,$f6ba,$f64d,$f5de,$f56d
	dc.w	$f4fa,$f484,$f40b,$f391,$f314,$f294,$f213,$f18f
	dc.w	$f109,$f080,$eff5,$ef68,$eed8,$ee46,$edb2,$ed1c
	dc.w	$ec83,$ebe8,$eb4b,$eaab,$ea09,$e965,$e8bf,$e816
	dc.w	$e76b,$e6be,$e60f,$e55e,$e4aa,$e3f4,$e33c,$e282
	dc.w	$e1c5,$e106,$e046,$df83,$debe,$ddf6,$dd2d,$dc61
	dc.w	$db94,$dac4,$d9f2,$d91e,$d848,$d770,$d695,$d5b9
	dc.w	$d4db,$d3fa,$d318,$d233,$d14d,$d064,$cf7a,$ce8d
	dc.w	$cd9f,$ccae,$cbbb,$cac7,$c9d1,$c8d8,$c7de,$c6e2
	dc.w	$c5e4,$c4e3,$c3e2,$c2de,$c1d8,$c0d0,$bfc7,$bebc
	dc.w	$bdae,$bca0,$bb8f,$ba7c,$b968,$b852,$b73a,$b620
	dc.w	$b504,$b3e7,$b2c8,$b1a8,$b085,$af61,$ae3b,$ad14
	dc.w	$abeb,$aac0,$a994,$a866,$a736,$a605,$a4d2,$a39d
	dc.w	$a267,$a12f,$9ff6,$9ebc,$9d7f,$9c42,$9b02,$99c2
	dc.w	$987f,$973c,$95f6,$94b0,$9368,$921e,$90d3,$8f87
	dc.w	$8e39,$8cea,$8b9a,$8a48,$88f5,$87a1,$864b,$84f4
	dc.w	$839c,$8242,$80e7,$7f8b,$7e2e,$7cd0,$7b70,$7a0f
	dc.w	$78ad,$774a,$75e5,$7480,$7319,$71b1,$7049,$6edf
	dc.w	$6d74,$6c08,$6a9b,$692d,$67bd,$664d,$64dc,$636a
	dc.w	$61f7,$6083,$5f0e,$5d98,$5c22,$5aaa,$5931,$57b8
	dc.w	$563e,$54c3,$5347,$51ca,$504d,$4ecf,$4d50,$4bd0
	dc.w	$4a50,$48ce,$474d,$45ca,$4447,$42c3,$413e,$3fb9
	dc.w	$3e33,$3cad,$3b26,$399f,$3817,$368e,$3505,$337b
	dc.w	$31f1,$3066,$2edb,$2d50,$2bc4,$2a37,$28aa,$271d
	dc.w	$2590,$2402,$2273,$20e5,$1f56,$1dc7,$1c37,$1aa7
	dc.w	$1917,$1787,$15f6,$1466,$12d5,$1144,$0fb2,$0e21
	dc.w	$0c8f,$0afe,$096c,$07da,$0648,$04b6,$0324,$0192
	dc.w	$0000,$0000




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
