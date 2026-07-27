	section	test_polygon,code
;	opt	o+,o3-


; Press right mouse button to run test


XMAX	equ	320
YMAX	equ	200
XMID	equ	XMAX/2
YMID	equ	YMAX/2

COLOURS	equ	16




	move.l	4.w,a6
	jsr	-132(a6)		turn multitasking off


	move.l	#4*40*200,d0
	move.l	#$10002,d1		chip
	jsr	-198(a6)		AllocMem
	move.l	d0,screen.mem
	beq	exit_now


	moveq	#0,d0
	lea	graf.name(pc),a1
	jsr	-552(a6)		OpenLibrary
	move.l	d0,gfxbase
	beq	exit_freemem




*"""""""""""""""""""""""""
*" INITIALISE INTERRUPTS "
*"			 "
*"""""""""""""""""""""""""

	lea	$dff000,a6
	move.w	intenar(a6),old.ints	save system interrupt status

	move.w	#$7fff,intena(a6)	disable all interrupts




*"""""""""""""""""""""""""""""
*" INITIALISE SCREEN DISPLAY "
*"			     "
*"""""""""""""""""""""""""""""

wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait

vp.wait	move.l	vposr(a6),d0		get vertical beam position
	and.l	#$1ff00,d0
	lsr.l	#8,d0
	cmp.w	#310,d0			wait for bottom line
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


	move.l	screen.mem(pc),d0	initialise copper
	lea	copper.list,a0
	bsr	init.copper

	move.l	#copper.list,cop1lch(a6)
	move.w	d0,copjmp1(a6)


	move.w	#$8380,dmacon(a6)	DMA on




*"""""""""""""""""""""
*" CALCULATE Y-TABLE "
*"		     "
*"""""""""""""""""""""

	move.w	#200-1,d0
	moveq	#0,d1			offset starts at zero
	move.w	#160,d2			width of four bitplanes
	lea	y.table(pc),a0

y.tab.loop
	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,y.tab.loop




wait.start
	btst	#2,potgor(a6)
	bne.s	wait.start




*"""""""""""""
*" MAIN LOOP "
*"	     "
*"""""""""""""

polygon	macro
	lea	\1(pc),a1		address of coordinates
	bsr	polygon
	endm




test.loop
	move.w	fill.colour+2(pc),d0
	addq.w	#4,d0
	and.w	#15*4,d0
	move.w	d0,fill.colour+2

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




*""""""""""""""""
*" EXIT ROUTINE	"
*"		"
*""""""""""""""""

exit	lea	$dff000,a6
	move.w	old.ints(pc),d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status


	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	gfxbase(pc),a1
	move.l	38(a1),cop1lch(a6)	restore system copper

	move.w	#$87f0,dmacon(a6)	DMA on


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




*"""""""""""""""""""""""
*" THE POLYGON ROUTINE "
*"		       "
*"""""""""""""""""""""""

poly.line
	move.w	d4,(a1)+		save starting y

	tst.w	d2			smallest x
	bpl.s	poly.line1
	moveq	#0,d2			if off screen then set to 0

poly.line1
	move.w	d2,(a1)+		save starting x

	cmp.w	d6,d3			largest x
	ble.s	poly.line2
	move.w	d6,d3			if off screen then set to maximum

poly.line2
	move.w	d3,(a1)+		save ending x

	bra	fill




return2	rts




polygon	lea	poly.data(pc),a0
	move.w	(a0)+,d0		get number of sides
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d1			4 bytes per side
	subq.w	#2,d0			count
	lea	poly.coords(pc),a2	temporary space for coords
	lea	(a2,d1.w),a4
	move.w	(a0)+,d4		get offset for first coords
	move.l	(a1,d4.w),d4		get first coords
	move.w	d4,d5			y
	move.l	d4,d2
	swap	d2			x
	move.w	d2,d3			x
	move.l	a2,a3
	move.l	d4,(a2)+
	move.l	d4,(a4)+

poly.sort
	move.w	(a0)+,d6		get offset for next coords
	move.l	(a1,d6.w),d6		get next coords

	cmp.w	d6,d4
	ble.s	poly.sort1
	move.w	d6,d4			top y
	move.l	a2,a3			address of top coords
	bra.s	poly.sort2

poly.sort1
	cmp.w	d6,d5
	bge.s	poly.sort2
	move.w	d6,d5			bottom y

poly.sort2
	move.l	d6,(a2)+
	move.l	d6,(a4)+

	swap	d6
	cmp.w	d6,d2
	ble.s	poly.sort3
	move.w	d6,d2			smallest x
	bra.s	poly.sort4

poly.sort3
	cmp.w	d6,d3			largest x
	bge.s	poly.sort4
	move.w	d6,d3

poly.sort4
	dbra	d0,poly.sort

	move.w	#XMAX-1,d6
	move.w	#YMAX-1,d7

	tst.w	d3
	bmi.s	return2			quit if largest x off left

	cmp.w	d6,d2
	bgt.s	return2			quit if smallest x off right

	tst.w	d5
	bmi.s	return2			quit if bottom y off top

	cmp.w	d7,d4
	bgt.s	return2			quit if top y off bottom

	lea	fill.coords(pc),a1

	cmp.w	d4,d5
	beq	poly.line		if smallest y = largest y

	lea	(a3,d1.w),a2		address of top coords
	move.l	#65536,a4
	move.l	#-65536,a5

	tst.w	d4
	bpl	top.y.on.screen

top.y.off.screen
	move.l	-(a2),d2		get previous coords
	tst.w	d2			y
	bmi.s	top.y.off.screen	get first coords that are on screen

	move.l	4(a2),d0		get last coords that were off screen

	move.w	d0,d4			y off
	move.w	d2,d5			y on
	sub.w	d0,d5			y on - y off
	swap	d2			x on
	swap	d0			x off
	sub.w	d0,d2			x on - x off
	muls	d2,d4			(x on - x off) * y off
	divs	d5,d4		    ((x on - x off) * y off) / (y on - y off)
	sub.w	d4,d0	  x off - (((x on - x off) * y off) / (y on - y off))
	swap	d0
	clr.w	d0			new starting x * 65536

	ext.l	d2			x on - x off
	lsl.l	#8,d2			* 256
	divs	d5,d2			/ (y on - y off)
	bvs.s	gradient.overflow1
	ext.l	d2			gradient * 256
	lsl.l	#8,d2			gradient * 65536
	bra.s	adjust.starting.x

gradient.overflow1
	asr.l	#8,d2			x on - x off
	divs	d5,d2			/ (y on - y off)
	swap	d2
	clr.w	d2			gradient * 65536

adjust.starting.x
	move.l	d2,d5			gradient
	bpl.s	grad.positive1
	neg.l	d5			make positive

grad.positive1
	cmp.l	a4,d5
	bge.s	grad.greater1
	move.l	a4,d5			if less than 65536 then set to 65536

grad.greater1
	asr.l	#1,d5
	sub.l	d5,d0			adjust starting x
	add.l	a4,d0			+ 1

top.y.off.screen2
	move.l	(a3)+,d1		get current coords
	tst.w	2(a3)			y
	bmi.s	top.y.off.screen2	until first coords are on screen

	move.l	(a3),d3			get first coords that are on screen

	move.w	d1,d4			y off
	move.w	d3,d5			y on
	sub.w	d1,d5			y on - y off
	swap	d3			x on
	swap	d1			x off
	sub.w	d1,d3			x on - x off
	muls	d3,d4			(x on - x off) * y off
	divs	d5,d4		    ((x on - x off) * y off) / (y on - y off)
	sub.w	d4,d1	  x off - (((x on -  x off) * y off) / (y on - yoff))
	swap	d1
	clr.w	d1			new ending x * 65536

	ext.l	d3			x on - x off
	lsl.l	#8,d3			* 256
	divs	d5,d3			/ (y on - y off)
	bvs.s	gradient.overflow2
	ext.l	d3			gradient * 256
	lsl.l	#8,d3			gradient * 65536
	bra.s	adjust.ending.x

gradient.overflow2
	asr.l	#8,d3			x on - x off
	divs	d5,d3			/ (y on - y off)
	swap	d3
	clr.w	d3			gradient * 65536

adjust.ending.x
	move.l	d3,d5			gradient
	bpl.s	grad.positive2
	neg.l	d5			make positive

grad.positive2
	cmp.l	a4,d5
	bge.s	grad.greater2
	move.l	a4,d5			if less than 65536 then set to 65536

grad.greater2
	asr.l	#1,d5
	add.l	d5,d1			adjust ending x

	moveq	#0,d4			set starting y to 0
	move.w	d4,(a1)+		save starting y

	bra	do.poly.edges




next.y.smaller1
	cmp.l	a2,a3
	beq	bottom.of.polygon.flat	if pointers have overlapped

	swap	d4			set current x to next x
	move.w	(a3),d4
	swap	d4

	addq.l	#4,a3			update pointer
	bra.s	calc.end.gradient2




next.y.smaller2
	swap	d4			set current x to previous x
	move.w	(a2),d4
	swap	d4

	bra.s	calc.start.gradient2




top.y.on.screen
	move.w	d4,(a1)+		save starting y

calc.end.gradient
	move.l	(a3)+,d4		get current coords

calc.end.gradient2
	move.l	d4,d1
	clr.w	d1			ending x * 65536
	move.w	2(a3),d5		get next y
	sub.w	d4,d5			next y - current y
	ble.s	next.y.smaller1

	move.w	(a3),d3			get next x
	swap	d4			current x
	sub.w	d4,d3			next x - current x

	ext.l	d3			next x - current x
	lsl.l	#8,d3			* 256
	divs	d5,d3			/ (next y - current y)
	bvs.s	gradient.overflow3
	ext.l	d3			gradient * 256
	lsl.l	#8,d3			gradient * 65536
	bra.s	calc.start.gradient

gradient.overflow3
	asr.l	#8,d3			next x - current x
	divs	d5,d3			/ (next y - current y)
	swap	d3
	clr.w	d3			gradient * 65536

calc.start.gradient
	move.l	(a2),d4			get current coords

calc.start.gradient2
	move.l	d4,d0
	clr.w	d0			starting x * 65536
	move.l	-(a2),d5		get previous coords
	sub.w	d4,d5			previous y - current y
	ble.s	next.y.smaller2

	move.w	(a2),d2			get previous x
	swap	d4			current x
	sub.w	d4,d2			previous x - current x
	swap	d4			current y

	ext.l	d2			previous x - current x
	lsl.l	#8,d2			* 256
	divs	d5,d2			/ (previous y - current y)
	bvs.s	gradient.overflow4
	ext.l	d2			gradient * 256
	lsl.l	#8,d2			gradient * 65536
	bra.s	adjust.starting.ending.x

gradient.overflow4
	asr.l	#8,d2			previous x - current x
	divs	d5,d2			/ (previous y - current y)
	swap	d2
	clr.w	d2			gradient * 65536

adjust.starting.ending.x
	move.l	d2,d5			gradient
	bpl.s	grad.positive3

	cmp.l	a5,d5
	ble.s	grad.greater3
	move.l	a5,d5			if less -ve than -65536 set to -65536

grad.greater3
	asr.l	#1,d5
	add.l	d5,d0			adjust starting x
	add.l	a4,d0			+ 1

grad.positive3
	move.l	d3,d5			gradient
	bmi.s	grad.negative1

	cmp.l	a4,d5
	bge.s	grad.greater4
	move.l	a4,d5			if less than 65536 then set to 65536

grad.greater4
	asr.l	#1,d5
	add.l	d5,d1			adjust ending x

grad.negative1
	move.l	d0,d5			starting x
	bpl.s	start.x.on.screen1
	moveq	#0,d5			if off screen then set to 0

start.x.on.screen1
	swap	d1			ending x
	move.w	d1,d5
	swap	d1

	cmp.w	d6,d5
	ble.s	end.x.on.screen1
	move.w	d6,d5			if off screen then set to maximum

end.x.on.screen1
	move.l	d5,(a1)+		save starting and ending x

	addq.w	#1,d4			y + 1

adjust.starting.ending.x2
	move.l	d2,d5			gradient
	bmi.s	grad.negative2		if -ve than add it on

	cmp.l	a4,d5
	bge.s	grad.greater5
	move.l	a4,d5			if less than 65536 then set to 65536

grad.greater5
	asr.l	#1,d5
grad.negative2
	add.l	d5,d0			adjust starting x

	move.l	d3,d5			gradient
	bpl.s	grad.positive4		if +ve then add it on

	cmp.l	a5,d5
	ble.s	grad.greater6
	move.l	a5,d5			if less -ve than -65536 set to -65536

grad.greater6
	asr.l	#1,d5
	add.l	a4,d1			+ 1
grad.positive4
	add.l	d5,d1			adjust ending x




do.poly.edges
	move.w	2(a2),d5		get y value for end of starting edge

	cmp.l	a2,a3
	beq	bottom.of.polygon	if pointers have overlapped

	cmp.w	2(a3),d5
	bgt	starting.edge.longer

	beq	both.edges.equal.length

ending.edge.longer
	cmp.w	d7,d5
	bgt	bottom.is.off.screen

	sub.w	d4,d5			end y - current y
	ble.s	skip.edges1

	subq.w	#1,d5			count

edge.loop1
	move.l	d0,d4			starting x
	bpl.s	start.x.on.screen2
	moveq	#0,d4			if off screen then set to 0

start.x.on.screen2
	swap	d1			ending x
	move.w	d1,d4
	swap	d1

	cmp.w	d6,d4
	ble.s	end.x.on.screen2
	move.w	d6,d4			if off screen then set to maximum

end.x.on.screen2
	move.l	d4,(a1)+		save starting and ending x

	add.l	d2,d0
	add.l	d3,d1			add gradients to get next x values

	dbra	d5,edge.loop1

skip.edges1
	move.l	(a2),d4			get current coords

calc.start.gradient3
	move.l	d4,d0
	clr.w	d0			starting x * 65536
	move.l	-(a2),d5		get previous y
	sub.w	d4,d5			previous y - current y
	ble.s	next.y.smaller3

	move.w	(a2),d2			previous x
	swap	d4			current x
	sub.w	d4,d2			previous x - current x
	swap	d4			current y

	ext.l	d2			previous x - current x
	lsl.l	#8,d2			* 256
	divs	d5,d2			/ (previous y - current y)
	bvs.s	gradient.overflow5
	ext.l	d2			gradient * 256
	lsl.l	#8,d2			gradient * 65536
	bra.s	adjust.starting.x2

gradient.overflow5
	asr.l	#8,d2			previous x - current x
	divs	d5,d2			/ (previous y - current y)
	swap	d2
	clr.w	d2			gradient * 65536

adjust.starting.x2
	move.l	d2,d5			gradient
	bpl.s	grad.positive5

	cmp.l	a5,d5
	ble.s	grad.greater7
	move.l	a5,d5			if less -ve than -65536 set to -65536

grad.greater7
	asr.l	#1,d5
	add.l	d5,d0			adjust starting x
	add.l	a4,d0			+ 1

	bra.s	do.poly.edges




next.y.smaller3
	swap	d4			set current x to previous x
	move.w	(a2),d4
	swap	d4

	bra.s	calc.start.gradient3




grad.positive5
	move.l	d0,d5			starting x
	bpl.s	start.x.on.screen3
	moveq	#0,d5			if off screen then set to 0

start.x.on.screen3
	swap	d1			ending x
	move.w	d1,d5
	swap	d1

	cmp.w	d6,d5
	ble.s	end.x.on.screen3
	move.w	d6,d5			if off screen then set to maximum

end.x.on.screen3
	move.l	d5,(a1)+		save starting and ending x

	addq.w	#1,d4			y + 1

	add.l	d3,d1			add gradient to get next x value

	move.l	d2,d5			gradient

	cmp.l	a4,d5
	bge.s	grad.greater8
	move.l	a4,d5			if less than 65536 then set to 65536

grad.greater8
	asr.l	#1,d5
	add.l	d5,d0			adjust starting x

	bra	do.poly.edges




starting.edge.longer
	move.w	2(a3),d5		get y value for end of ending edge

	cmp.w	d7,d5
	bgt	bottom.is.off.screen

	sub.w	d4,d5			end y - current y
	ble.s	skip.edges2

	subq.w	#1,d5			count

edge.loop2
	move.l	d0,d4			starting x
	bpl.s	start.x.on.screen4
	moveq	#0,d4			if off screen then set to 0

start.x.on.screen4
	swap	d1			ending x
	move.w	d1,d4
	swap	d1

	cmp.w	d6,d4
	ble.s	end.x.on.screen4
	move.w	d6,d4			if off screen then set to maximum

end.x.on.screen4
	move.l	d4,(a1)+		save starting and ending x

	add.l	d2,d0
	add.l	d3,d1			add gradients to get next x values

	dbra	d5,edge.loop2

skip.edges2
	move.l	(a3)+,d4		get current coords

calc.end.gradient3
	move.l	d4,d1
	clr.w	d1			ending x * 65536
	move.w	2(a3),d5		get next y
	sub.w	d4,d5			next y - current y
	ble.s	next.y.smaller4

	move.w	(a3),d3			get next x
	swap	d4			current x
	sub.w	d4,d3			next x - current x
	swap	d4			current y

	ext.l	d3			next x - current x
	lsl.l	#8,d3			* 256
	divs	d5,d3			/ (next y - current y)
	bvs.s	gradient.overflow6
	ext.l	d3			gradient * 256
	lsl.l	#8,d3			gradient * 65536
	bra.s	adjust.ending.x2

gradient.overflow6
	asr.l	#8,d3			next x - current x
	divs	d5,d3			/ (next y - current y)
	swap	d3
	clr.w	d3			gradient * 65536

adjust.ending.x2
	move.l	d3,d5			gradient
	bmi.s	grad.negative3

	cmp.l	a4,d5
	bgt.s	grad.greater9
	move.l	a4,d5			if less than 65536 then set to 65536

grad.greater9
	asr.l	#1,d5
	add.l	d5,d1			adjust ending x

	bra	do.poly.edges




next.y.smaller4
	swap	d4			set current x to next x
	move.w	(a3),d4
	swap	d4

	addq.l	#4,a3			update pointer
	bra.s	calc.end.gradient3




grad.negative3
	move.l	d0,d5			starting x
	bpl.s	start.x.on.screen5
	moveq	#0,d5

start.x.on.screen5
	swap	d1			ending x
	move.w	d1,d5
	swap	d1

	cmp.w	d6,d5
	ble.s	end.x.on.screen5
	move.w	d6,d5			if off screen then set to maximum

end.x.on.screen5
	move.l	d5,(a1)+		save starting and ending x

	addq.w	#1,d4			y + 1

	add.l	d2,d0			add gradient to get next x value

	move.l	d3,d5			gradient

	cmp.l	a5,d5
	blt.s	grad.greaterA
	move.l	a5,d5			if less -ve than -65536 set to -65536

grad.greaterA
	asr.l	#1,d5
	add.l	d5,d1			adjust ending x
	add.l	a4,d1			+ 1

	bra	do.poly.edges




both.edges.equal.length
	cmp.w	d7,d5
	bgt.s	bottom.is.off.screen

	sub.w	d4,d5			end y - current y
	ble	calc.end.gradient

	subq.w	#1,d5			count

edge.loop3
	move.l	d0,d4			starting x
	bpl.s	start.x.on.screen6
	moveq	#0,d4			if off screen then set to 0

start.x.on.screen6
	swap	d1			ending x
	move.w	d1,d4
	swap	d1

	cmp.w	d6,d4
	ble.s	end.x.on.screen6
	move.w	d6,d4			if off screen then set to maximum

end.x.on.screen6
	move.l	d4,(a1)+		save starting and ending x

	add.l	d2,d0
	add.l	d3,d1			add gradients to get next x values

	dbra	d5,edge.loop3

	bra	calc.end.gradient




bottom.of.polygon.flat
	move.l	(a2),d0			get current coords

	cmp.w	d7,d0
	bgt	fill			if bottom is off screen

	clr.w	d0			starting x * 65536

	move.l	d2,d5			gradient
	bmi.s	adjust.ending.x3

	cmp.l	a4,d5
	ble.s	adjust.ending.x3

	asr.l	#1,d5
	sub.l	d5,d0			adjust starting x
	add.l	a4,d0			+ 1

adjust.ending.x3
	move.l	d3,d5			gradient
	bpl.s	save.last.x.values

	asr.l	#1,d5
	sub.l	d5,d1			adjust ending x

save.last.x.values
	move.l	d0,d5			starting x
	bpl.s	start.x.on.screen7
	moveq	#0,d5			if off screen then set to 0

start.x.on.screen7
	swap	d1			ending x
	move.w	d1,d5

	cmp.w	d6,d5
	ble.s	end.x.on.screen7
	move.w	d6,d5			if off screen then set to maximum

end.x.on.screen7
	move.l	d5,(a1)+		save starting and ending x

	bra.s	fill




bottom.is.off.screen
	sub.w	d4,d7			end y - current y = count
	blt.s	fill

edge.loop4
	move.l	d0,d5			starting x
	bpl.s	start.x.on.screen8
	moveq	#0,d5			if off screen then set to 0

start.x.on.screen8
	swap	d1			ending x
	move.w	d1,d5
	swap	d1

	cmp.w	d6,d5
	ble.s	end.x.on.screen8
	move.w	d6,d5			if off screen then set to maximum

end.x.on.screen8
	move.l	d5,(a1)+		save starting and ending x

	add.l	d2,d0
	add.l	d3,d1			add gradients to get next x values

	dbra	d7,edge.loop4

	bra.s	fill




bottom.of.polygon
	cmp.w	d7,d5
	bgt.s	bottom.is.off.screen

	sub.w	d4,d5			end y - current y
	ble.s	adjust.last.x.values

	subq.w	#1,d5			count

edge.loop5
	move.l	d0,d4			starting x
	bpl.s	start.x.on.screen9
	moveq	#0,d4			if off screen then set to 0

start.x.on.screen9
	swap	d1			ending x
	move.w	d1,d4
	swap	d1

	cmp.w	d6,d4
	ble.s	end.x.on.screen9
	move.w	d6,d4			if off screen then set to maximum

end.x.on.screen9
	move.l	d4,(a1)+		save starting and ending x

	add.l	d2,d0
	add.l	d3,d1			add gradients to get next x values

	dbra	d5,edge.loop5

adjust.last.x.values
	move.l	(a2),d0			get current coords
	move.l	d0,d1			both coords are the same

	move.l	d2,d5			gradient
	bmi.s	adjust.ending.x4

	cmp.l	a4,d5
	ble.s	adjust.ending.x4

	asr.l	#1,d5
	sub.l	d5,d0			adjust starting x
	add.l	a4,d0			+ 1

adjust.ending.x4
	move.l	d3,d5			gradient
	bpl.s	save.last.x.values2

	asr.l	#1,d5
	sub.l	d5,d1			adjust ending x

save.last.x.values2
	move.l	d0,d5			starting x
	bpl.s	start.x.on.screenA
	moveq	#0,d5			if off screen then set to 0

start.x.on.screenA
	swap	d1			ending x
	move.w	d1,d5

	cmp.w	d6,d5
	ble.s	end.x.on.screenA
	move.w	d6,d5			if off screen then set to maximum

end.x.on.screenA
	move.l	d5,(a1)+		save starting and ending x

;	bra.s	fill




*""""""""""""""""""""
*" THE FILL ROUTINE "
*"		    "
*""""""""""""""""""""

fill	st	(a1)			end-of-fill marker
	move.l	screen.mem(pc),a0
	lea	fill.coords(pc),a1
	move.w	(a1)+,d0		get y-start
	add.w	d0,d0			word offset
	lea	y.table(pc),a2
	add.w	(a2,d0.w),a0		add y offset

	move.w	(a1)+,d0		first x-start
	bpl.s	fill.colour
	rts


fill.colour
	move.w	#0,d1
	moveq	#-1,d4
	moveq	#0,d5
	move.l	fill.colour.table(pc,d1.w),a2
	jmp	(a2)


fill.colour.table
	dc.l	fill.colour0,fill.colour1,fill.colour2,fill.colour3
	dc.l	fill.colour4,fill.colour5,fill.colour6,fill.colour7
	dc.l	fill.colour8,fill.colour9,fill.colour10,fill.colour11
	dc.l	fill.colour12,fill.colour13,fill.colour14,fill.colour15


FILLCOL	MACRO	; COLOUR

* generate code specifically for each colour
*
* e.g. FILLCOL 3 generates routine fill.colour3


start.masks\1
	IFEQ	(\1)			define negative masks if colour 0
	dc.w	$0000,$8000,$c000,$e000,$f000,$f800,$fc00,$fe00
	dc.w	$ff00,$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe
	ELSE				define positive masks otherwise
	dc.w	$ffff,$7fff,$3fff,$1fff,$0fff,$07ff,$03ff,$01ff
	dc.w	$00ff,$007f,$003f,$001f,$000f,$0007,$0003,$0001
	ENDC

end.masks\1
	IFEQ	(\1)			define negative masks if colour 0
	dc.w	$7fff,$3fff,$1fff,$0fff,$07ff,$03ff,$01ff,$00ff
	dc.w	$007f,$003f,$001f,$000f,$0007,$0003,$0001,$0000
	ELSE				define positive masks otherwise
	dc.w	$8000,$c000,$e000,$f000,$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0,$fff8,$fffc,$fffe,$ffff
	ENDC


fill.colour\1
	move.w	(a1)+,d1		next x-end
	sub.w	d0,d1
	blt.s	next.line\1		if x-end is less than x-start

	moveq	#$f,d2
	and.w	d0,d2			low four bits from x-start
	sub.w	d2,d0

	lsr.w	#3,d0			x-start offset in even bytes
	lea	(a0,d0.w),a2		start address of fill - bitplane 1
	lea	40(a2),a3		bitplane 2
	lea	80(a2),a4		bitplane 3
	lea	120(a2),a5		bitplane 4

	add.w	d2,d1			correct bit position for x-end

	add.w	d2,d2
	move.w	start.masks\1(pc,d2.w),d0	get positive start mask

	moveq	#$f,d2
	and.w	d1,d2			low four bits from x-end
	sub.w	d2,d1

	add.w	d2,d2
	move.w	end.masks\1(pc,d2.w),d2	get positive end mask

	lsr.w	#2,d1			width of fill - 1, in words * 4
	beq.s	one.word.fill\1

; make instructions to set first words

	IFNE	(\1&1)
	or.w	d0,(a2)+		bitplane 1 set
	ENDC

	IFNE	(\1&2)
	or.w	d0,(a3)+		bitplane 2 set
	ENDC

	IFNE	(\1&4)
	or.w	d0,(a4)+		bitplane 3 set
	ENDC

	IFNE	(\1&8)
	or.w	d0,(a5)+		bitplane 4 set
	ENDC

	IFNE	(\1)			if not colour 0
	IFNE	(\1+1)-COLOURS		if not max. possible colour
	not.w	d0			(i.e. some bitplanes need clearing)
	ENDC
	ENDC

	IFEQ	(\1&1)
	and.w	d0,(a2)+		bitplane 1 clear
	ENDC

	IFEQ	(\1&2)
	and.w	d0,(a3)+		bitplane 2 clear
	ENDC

	IFEQ	(\1&4)
	and.w	d0,(a4)+		bitplane 3 clear
	ENDC

	IFEQ	(\1&8)
	and.w	d0,(a5)+		bitplane 4 clear
	ENDC

	move.l	fill.width.table\1-4(pc,d1.w),a6
	jmp	(a6)

one.word.fill\1
	IFNE	(\1)			if not colour 0
	and.w	d0,d2			combine positive start and end masks
	ELSE
	or.w	d0,d2			combine negative start and end masks
	ENDC

; make instructions to set last words

words2.\1
	IFNE	(\1&1)
	or.w	d2,(a2)			bitplane 1 set
	ENDC

	IFNE	(\1&2)
	or.w	d2,(a3)			bitplane 2 set
	ENDC

	IFNE	(\1&4)
	or.w	d2,(a4)			bitplane 3 set
	ENDC

	IFNE	(\1&8)
	or.w	d2,(a5)			bitplane 4 set
	ENDC

	IFNE	(\1)			if not colour 0
	IFNE	(\1+1)-COLOURS		if not max. possible colour
	not.w	d2			(i.e. some bitplanes need clearing)
	ENDC
	ENDC

	IFEQ	(\1&1)
	and.w	d2,(a2)			bitplane 1 clear
	ENDC

	IFEQ	(\1&2)
	and.w	d2,(a3)			bitplane 2 clear
	ENDC

	IFEQ	(\1&4)
	and.w	d2,(a4)			bitplane 3 clear
	ENDC

	IFEQ	(\1&8)
	and.w	d2,(a5)			bitplane 4 clear
	ENDC

next.line\1
	lea	160(a0),a0		next line
	move.w	(a1)+,d0		next x-start
	bpl.s	fill.colour\1
	rts


fill.width.table\1

* one word fill is handled above

	dc.l	words2.\1,words3.\1,words4.\1,words5.\1,words6.\1
	dc.l	words7.\1,words8.\1,words9.\1,words10.\1,words11.\1
	dc.l	words12.\1,words13.\1,words14.\1,words15.\1,words16.\1
	dc.l	words17.\1,words18.\1,words19.\1,words20.\1


words19.\1
	IFNE	(\1&1)
	move.l	d4,(a2)+
	ELSE
	move.l	d5,(a2)+
	ENDC

	IFNE	(\1&2)
	move.l	d4,(a3)+
	ELSE
	move.l	d5,(a3)+
	ENDC

	IFNE	(\1&4)
	move.l	d4,(a4)+
	ELSE
	move.l	d5,(a4)+
	ENDC

	IFNE	(\1&8)
	move.l	d4,(a5)+
	ELSE
	move.l	d5,(a5)+
	ENDC

words17.\1
	IFNE	(\1&1)
	move.l	d4,(a2)+
	ELSE
	move.l	d5,(a2)+
	ENDC

	IFNE	(\1&2)
	move.l	d4,(a3)+
	ELSE
	move.l	d5,(a3)+
	ENDC

	IFNE	(\1&4)
	move.l	d4,(a4)+
	ELSE
	move.l	d5,(a4)+
	ENDC

	IFNE	(\1&8)
	move.l	d4,(a5)+
	ELSE
	move.l	d5,(a5)+
	ENDC

words15.\1
	IFNE	(\1&1)
	move.l	d4,(a2)+
	ELSE
	move.l	d5,(a2)+
	ENDC

	IFNE	(\1&2)
	move.l	d4,(a3)+
	ELSE
	move.l	d5,(a3)+
	ENDC

	IFNE	(\1&4)
	move.l	d4,(a4)+
	ELSE
	move.l	d5,(a4)+
	ENDC

	IFNE	(\1&8)
	move.l	d4,(a5)+
	ELSE
	move.l	d5,(a5)+
	ENDC

words13.\1
	IFNE	(\1&1)
	move.l	d4,(a2)+
	ELSE
	move.l	d5,(a2)+
	ENDC

	IFNE	(\1&2)
	move.l	d4,(a3)+
	ELSE
	move.l	d5,(a3)+
	ENDC

	IFNE	(\1&4)
	move.l	d4,(a4)+
	ELSE
	move.l	d5,(a4)+
	ENDC

	IFNE	(\1&8)
	move.l	d4,(a5)+
	ELSE
	move.l	d5,(a5)+
	ENDC

words11.\1
	IFNE	(\1&1)
	move.l	d4,(a2)+
	ELSE
	move.l	d5,(a2)+
	ENDC

	IFNE	(\1&2)
	move.l	d4,(a3)+
	ELSE
	move.l	d5,(a3)+
	ENDC

	IFNE	(\1&4)
	move.l	d4,(a4)+
	ELSE
	move.l	d5,(a4)+
	ENDC

	IFNE	(\1&8)
	move.l	d4,(a5)+
	ELSE
	move.l	d5,(a5)+
	ENDC

words9.\1
	IFNE	(\1&1)
	move.l	d4,(a2)+
	ELSE
	move.l	d5,(a2)+
	ENDC

	IFNE	(\1&2)
	move.l	d4,(a3)+
	ELSE
	move.l	d5,(a3)+
	ENDC

	IFNE	(\1&4)
	move.l	d4,(a4)+
	ELSE
	move.l	d5,(a4)+
	ENDC

	IFNE	(\1&8)
	move.l	d4,(a5)+
	ELSE
	move.l	d5,(a5)+
	ENDC

words7.\1
	IFNE	(\1&1)
	move.l	d4,(a2)+
	ELSE
	move.l	d5,(a2)+
	ENDC

	IFNE	(\1&2)
	move.l	d4,(a3)+
	ELSE
	move.l	d5,(a3)+
	ENDC

	IFNE	(\1&4)
	move.l	d4,(a4)+
	ELSE
	move.l	d5,(a4)+
	ENDC

	IFNE	(\1&8)
	move.l	d4,(a5)+
	ELSE
	move.l	d5,(a5)+
	ENDC

words5.\1
	IFNE	(\1&1)
	move.l	d4,(a2)+
	ELSE
	move.l	d5,(a2)+
	ENDC

	IFNE	(\1&2)
	move.l	d4,(a3)+
	ELSE
	move.l	d5,(a3)+
	ENDC

	IFNE	(\1&4)
	move.l	d4,(a4)+
	ELSE
	move.l	d5,(a4)+
	ENDC

	IFNE	(\1&8)
	move.l	d4,(a5)+
	ELSE
	move.l	d5,(a5)+
	ENDC

words3.\1
	IFNE	(\1&1)
	move.w	d4,(a2)+
	ELSE
	move.w	d5,(a2)+
	ENDC

	IFNE	(\1&2)
	move.w	d4,(a3)+
	ELSE
	move.w	d5,(a3)+
	ENDC

	IFNE	(\1&4)
	move.w	d4,(a4)+
	ELSE
	move.w	d5,(a4)+
	ENDC

	IFNE	(\1&8)
	move.w	d4,(a5)+
	ELSE
	move.w	d5,(a5)+
	ENDC

; make instructions to set last words

	IFNE	(\1&1)
	or.w	d2,(a2)			bitplane 1 set
	ENDC

	IFNE	(\1&2)
	or.w	d2,(a3)			bitplane 2 set
	ENDC

	IFNE	(\1&4)
	or.w	d2,(a4)			bitplane 3 set
	ENDC

	IFNE	(\1&8)
	or.w	d2,(a5)			bitplane 4 set
	ENDC

	IFNE	(\1)			if not colour 0
	IFNE	(\1+1)-COLOURS		if not max. possible colour
	not.w	d2			(i.e. some bitplanes need clearing)
	ENDC
	ENDC

	IFEQ	(\1&1)
	and.w	d2,(a2)			bitplane 1 clear
	ENDC

	IFEQ	(\1&2)
	and.w	d2,(a3)			bitplane 2 clear
	ENDC

	IFEQ	(\1&4)
	and.w	d2,(a4)			bitplane 3 clear
	ENDC

	IFEQ	(\1&8)
	and.w	d2,(a5)			bitplane 4 clear
	ENDC

	lea	160(a0),a0		next line
	move.w	(a1)+,d0		next x-start
	bpl	fill.colour\1
	rts


words20.\1
	IFNE	(\1&1)
	move.l	d4,(a2)+
	ELSE
	move.l	d5,(a2)+
	ENDC

	IFNE	(\1&2)
	move.l	d4,(a3)+
	ELSE
	move.l	d5,(a3)+
	ENDC

	IFNE	(\1&4)
	move.l	d4,(a4)+
	ELSE
	move.l	d5,(a4)+
	ENDC

	IFNE	(\1&8)
	move.l	d4,(a5)+
	ELSE
	move.l	d5,(a5)+
	ENDC

words18.\1
	IFNE	(\1&1)
	move.l	d4,(a2)+
	ELSE
	move.l	d5,(a2)+
	ENDC

	IFNE	(\1&2)
	move.l	d4,(a3)+
	ELSE
	move.l	d5,(a3)+
	ENDC

	IFNE	(\1&4)
	move.l	d4,(a4)+
	ELSE
	move.l	d5,(a4)+
	ENDC

	IFNE	(\1&8)
	move.l	d4,(a5)+
	ELSE
	move.l	d5,(a5)+
	ENDC

words16.\1
	IFNE	(\1&1)
	move.l	d4,(a2)+
	ELSE
	move.l	d5,(a2)+
	ENDC

	IFNE	(\1&2)
	move.l	d4,(a3)+
	ELSE
	move.l	d5,(a3)+
	ENDC

	IFNE	(\1&4)
	move.l	d4,(a4)+
	ELSE
	move.l	d5,(a4)+
	ENDC

	IFNE	(\1&8)
	move.l	d4,(a5)+
	ELSE
	move.l	d5,(a5)+
	ENDC

words14.\1
	IFNE	(\1&1)
	move.l	d4,(a2)+
	ELSE
	move.l	d5,(a2)+
	ENDC

	IFNE	(\1&2)
	move.l	d4,(a3)+
	ELSE
	move.l	d5,(a3)+
	ENDC

	IFNE	(\1&4)
	move.l	d4,(a4)+
	ELSE
	move.l	d5,(a4)+
	ENDC

	IFNE	(\1&8)
	move.l	d4,(a5)+
	ELSE
	move.l	d5,(a5)+
	ENDC

words12.\1
	IFNE	(\1&1)
	move.l	d4,(a2)+
	ELSE
	move.l	d5,(a2)+
	ENDC

	IFNE	(\1&2)
	move.l	d4,(a3)+
	ELSE
	move.l	d5,(a3)+
	ENDC

	IFNE	(\1&4)
	move.l	d4,(a4)+
	ELSE
	move.l	d5,(a4)+
	ENDC

	IFNE	(\1&8)
	move.l	d4,(a5)+
	ELSE
	move.l	d5,(a5)+
	ENDC

words10.\1
	IFNE	(\1&1)
	move.l	d4,(a2)+
	ELSE
	move.l	d5,(a2)+
	ENDC

	IFNE	(\1&2)
	move.l	d4,(a3)+
	ELSE
	move.l	d5,(a3)+
	ENDC

	IFNE	(\1&4)
	move.l	d4,(a4)+
	ELSE
	move.l	d5,(a4)+
	ENDC

	IFNE	(\1&8)
	move.l	d4,(a5)+
	ELSE
	move.l	d5,(a5)+
	ENDC

words8.\1
	IFNE	(\1&1)
	move.l	d4,(a2)+
	ELSE
	move.l	d5,(a2)+
	ENDC

	IFNE	(\1&2)
	move.l	d4,(a3)+
	ELSE
	move.l	d5,(a3)+
	ENDC

	IFNE	(\1&4)
	move.l	d4,(a4)+
	ELSE
	move.l	d5,(a4)+
	ENDC

	IFNE	(\1&8)
	move.l	d4,(a5)+
	ELSE
	move.l	d5,(a5)+
	ENDC

words6.\1
	IFNE	(\1&1)
	move.l	d4,(a2)+
	ELSE
	move.l	d5,(a2)+
	ENDC

	IFNE	(\1&2)
	move.l	d4,(a3)+
	ELSE
	move.l	d5,(a3)+
	ENDC

	IFNE	(\1&4)
	move.l	d4,(a4)+
	ELSE
	move.l	d5,(a4)+
	ENDC

	IFNE	(\1&8)
	move.l	d4,(a5)+
	ELSE
	move.l	d5,(a5)+
	ENDC

words4.\1
	IFNE	(\1&1)
	move.l	d4,(a2)+
	ELSE
	move.l	d5,(a2)+
	ENDC

	IFNE	(\1&2)
	move.l	d4,(a3)+
	ELSE
	move.l	d5,(a3)+
	ENDC

	IFNE	(\1&4)
	move.l	d4,(a4)+
	ELSE
	move.l	d5,(a4)+
	ENDC

	IFNE	(\1&8)
	move.l	d4,(a5)+
	ELSE
	move.l	d5,(a5)+
	ENDC

; make instructions to set last words

	IFNE	(\1&1)
	or.w	d2,(a2)			bitplane 1 set
	ENDC

	IFNE	(\1&2)
	or.w	d2,(a3)			bitplane 2 set
	ENDC

	IFNE	(\1&4)
	or.w	d2,(a4)			bitplane 3 set
	ENDC

	IFNE	(\1&8)
	or.w	d2,(a5)			bitplane 4 set
	ENDC

	IFNE	(\1)			if not colour 0
	IFNE	(\1+1)-COLOURS		if not max. possible colour
	not.w	d2			(i.e. some bitplanes need clearing)
	ENDC
	ENDC

	IFEQ	(\1&1)
	and.w	d2,(a2)			bitplane 1 clear
	ENDC

	IFEQ	(\1&2)
	and.w	d2,(a3)			bitplane 2 clear
	ENDC

	IFEQ	(\1&4)
	and.w	d2,(a4)			bitplane 3 clear
	ENDC

	IFEQ	(\1&8)
	and.w	d2,(a5)			bitplane 4 clear
	ENDC

	lea	160(a0),a0		next line
	move.w	(a1)+,d0		next x-start
	bpl	fill.colour\1
	rts

	ENDM


	FILLCOL	0
	FILLCOL	1
	FILLCOL	2
	FILLCOL	3
	FILLCOL	4
	FILLCOL	5
	FILLCOL	6
	FILLCOL	7
	FILLCOL	8
	FILLCOL	9
	FILLCOL	10
	FILLCOL	11
	FILLCOL	12
	FILLCOL	13
	FILLCOL	14
	FILLCOL	15


y.table	ds.w	200


fill.coords
	ds.w	402	ystart + max. 200 coord pairs + word for end marker


poly.coords	ds.w	64		space for 16 sided polygon




init.copper
	moveq	#4-1,d1
	moveq	#40,d2			width of one bitplane

next.plane
	move.w	d0,6(a0)		save low word
	swap	d0
	move.w	d0,2(a0)		save high word
	swap	d0
	add.l	d2,d0			next bitplane
	addq.w	#8,a0			update pointer to copper list
	dbra	d1,next.plane
	rts




*"""""""""""""
*" VARIABLES "
*"	     "
*"""""""""""""

screen.mem	dc.l	0
gfxbase		dc.l	0
old.ints	dc.w	0




*"""""""""""""
*" CONSTANTS "
*"	     "
*"""""""""""""

graf.name	dc.b	'graphics.library',0
		even




*"""""""""""""""""
*" GRAPHICS DATA "
*"		 "
*"""""""""""""""""

colour.table
	dc.w	$000,$060,$0a0,$0e0,$400,$800,$c00,$e00
	dc.w	$004,$008,$00c,$00e,$444,$888,$ccc,$eee



poly.data	
	dc.w	4		number of sides for polygon
	dc.w	0,4,8,12	offsets for coordinates



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




*"""""""""""""""""""
*" THE COPPER LIST "
*"		   "
*"""""""""""""""""""
	section	copper,code_c


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




*""""""""""""""""""""""
*" HARDWARE REGISTERS "
*"		      "
*""""""""""""""""""""""

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
