	section	test_polygon,code


* A1200 NF		-	1:41	-	990/sec
* A1200 VIPER 28Mhz '30	-	0:58	-	1724/sec
* A1200 FLAPS 66Mhz '60	-	!?!?	-	:-)


; Press right mouse button to run test


XMAX	equ	320
YMAX	equ	200
XMID	equ	XMAX/2
YMID	equ	YMAX/2




	move.l	4.w,a6
	jsr	-132(a6)		turn multitasking off


	move.l	#8*40*200,d0
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


	move.w	#$0210,bplcon0(a6)	initialise screen
	move.w	#$4881,diwstrt(a6)
	move.w	#$10c1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	moveq	#0,d0
	move.w	d0,bplcon1(a6)
	move.w	d0,bplcon2(a6)
	move.w	#7*40-8,d0
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
	move.w	#320,d2			width of eight bitplanes
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
	move.w	current.fill.colour(pc),d0
	addq.w	#4,d0
	and.w	#255*4,d0
	move.w	d0,current.fill.colour

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
	move.l	#8*40*200,d0
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
	cnop	0,4

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



	cnop	0,4

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

	cnop	0,4

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

	cnop	0,4

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

	cnop	0,4

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

	cnop	0,4

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



	cnop	0,4

next.y.smaller1
	cmp.l	a2,a3
	beq	bottom.of.polygon.flat	if pointers have overlapped

	swap	d4			set current x to next x
	move.w	(a3),d4
	swap	d4

	addq.l	#4,a3			update pointer
	bra.s	calc.end.gradient2



	cnop	0,4

next.y.smaller2
	swap	d4			set current x to previous x
	move.w	(a2),d4
	swap	d4

	bra.s	calc.start.gradient2



	cnop	0,4

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

	cnop	0,4

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

	cnop	0,4

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



	cnop	0,4

next.y.smaller3
	swap	d4			set current x to previous x
	move.w	(a2),d4
	swap	d4

	bra.s	calc.start.gradient3



	cnop	0,4

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



	cnop	0,4

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

	cnop	0,4

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



	cnop	0,4

next.y.smaller4
	swap	d4			set current x to next x
	move.w	(a3),d4
	swap	d4

	addq.l	#4,a3			update pointer
	bra.s	calc.end.gradient3



	cnop	0,4

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



	cnop	0,4

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



	cnop	0,4

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



	cnop	0,4

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



	cnop	0,4

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
	moveq	#0,d0
	move.w	(a1)+,d0		get y-start
	lea	y.table(pc),a2
	move.w	(a2,d0.w*2),d0
	add.l	d0,a0			add y offset

	move.w	(a1)+,d0		first x-start
	bpl.s	fill.colour
	rts

	cnop	0,4

fill.colour
	move.w	current.fill.colour(pc),d1
	lea	fill.colour.table(pc),a3
	move.l	(a3,d1.w),d4

	moveq	#0,d2
	lea	fill.width.table(pc),a3

fill.loop
	move.w	(a1)+,d1		next x-end
	sub.w	d0,d1
	blt.s	next.line		if x-end is less than x-start

	lea	(a0,d0.w),a2		start address of fill

	btst	d2,d0
	beq.s	even.byte

odd.byte
	move.b	d4,(a2)+

	move.l	-4(a3,d1.w*4),a6
	jmp	(a6)

even.byte
	move.l	(a3,d1.w*4),a6
	jmp	(a6)

next.line
	lea	320(a0),a0		next line
	move.w	(a1)+,d0		next x-start
	bpl.s	fill.loop
	rts

	cnop	0,4

bytes318
	move.l	d4,(a2)+
bytes314
	move.l	d4,(a2)+
bytes310
	move.l	d4,(a2)+
bytes306
	move.l	d4,(a2)+
bytes302
	move.l	d4,(a2)+
bytes298
	move.l	d4,(a2)+
bytes294
	move.l	d4,(a2)+
bytes290
	move.l	d4,(a2)+
bytes286
	move.l	d4,(a2)+
bytes282
	move.l	d4,(a2)+
bytes278
	move.l	d4,(a2)+
bytes274
	move.l	d4,(a2)+
bytes270
	move.l	d4,(a2)+
bytes266
	move.l	d4,(a2)+
bytes262
	move.l	d4,(a2)+
bytes258
	move.l	d4,(a2)+
bytes254
	move.l	d4,(a2)+
bytes250
	move.l	d4,(a2)+
bytes246
	move.l	d4,(a2)+
bytes242
	move.l	d4,(a2)+
bytes238
	move.l	d4,(a2)+
bytes234
	move.l	d4,(a2)+
bytes230
	move.l	d4,(a2)+
bytes226
	move.l	d4,(a2)+
bytes222
	move.l	d4,(a2)+
bytes218
	move.l	d4,(a2)+
bytes214
	move.l	d4,(a2)+
bytes210
	move.l	d4,(a2)+
bytes206
	move.l	d4,(a2)+
bytes202
	move.l	d4,(a2)+
bytes198
	move.l	d4,(a2)+
bytes194
	move.l	d4,(a2)+
bytes190
	move.l	d4,(a2)+
bytes186
	move.l	d4,(a2)+
bytes182
	move.l	d4,(a2)+
bytes178
	move.l	d4,(a2)+
bytes174
	move.l	d4,(a2)+
bytes170
	move.l	d4,(a2)+
bytes166
	move.l	d4,(a2)+
bytes162
	move.l	d4,(a2)+
bytes158
	move.l	d4,(a2)+
bytes154
	move.l	d4,(a2)+
bytes150
	move.l	d4,(a2)+
bytes146
	move.l	d4,(a2)+
bytes142
	move.l	d4,(a2)+
bytes138
	move.l	d4,(a2)+
bytes134
	move.l	d4,(a2)+
bytes130
	move.l	d4,(a2)+
bytes126
	move.l	d4,(a2)+
bytes122
	move.l	d4,(a2)+
bytes118
	move.l	d4,(a2)+
bytes114
	move.l	d4,(a2)+
bytes110
	move.l	d4,(a2)+
bytes106
	move.l	d4,(a2)+
bytes102
	move.l	d4,(a2)+
bytes98
	move.l	d4,(a2)+
bytes94
	move.l	d4,(a2)+
bytes90
	move.l	d4,(a2)+
bytes86
	move.l	d4,(a2)+
bytes82
	move.l	d4,(a2)+
bytes78
	move.l	d4,(a2)+
bytes74
	move.l	d4,(a2)+
bytes70
	move.l	d4,(a2)+
bytes66
	move.l	d4,(a2)+
bytes62
	move.l	d4,(a2)+
bytes58
	move.l	d4,(a2)+
bytes54
	move.l	d4,(a2)+
bytes50
	move.l	d4,(a2)+
bytes46
	move.l	d4,(a2)+
bytes42
	move.l	d4,(a2)+
bytes38
	move.l	d4,(a2)+
bytes34
	move.l	d4,(a2)+
bytes30
	move.l	d4,(a2)+
bytes26
	move.l	d4,(a2)+
bytes22
	move.l	d4,(a2)+
bytes18
	move.l	d4,(a2)+
bytes14
	move.l	d4,(a2)+
bytes10
	move.l	d4,(a2)+
bytes6
	move.l	d4,(a2)+
bytes2
	move.w	d4,(a2)+

	lea	320(a0),a0		next line
	move.w	(a1)+,d0		next x-start
	bpl	fill.loop
	rts

	cnop	0,4

bytes320
	move.l	d4,(a2)+
bytes316
	move.l	d4,(a2)+
bytes312
	move.l	d4,(a2)+
bytes308
	move.l	d4,(a2)+
bytes304
	move.l	d4,(a2)+
bytes300
	move.l	d4,(a2)+
bytes296
	move.l	d4,(a2)+
bytes292
	move.l	d4,(a2)+
bytes288
	move.l	d4,(a2)+
bytes284
	move.l	d4,(a2)+
bytes280
	move.l	d4,(a2)+
bytes276
	move.l	d4,(a2)+
bytes272
	move.l	d4,(a2)+
bytes268
	move.l	d4,(a2)+
bytes264
	move.l	d4,(a2)+
bytes260
	move.l	d4,(a2)+
bytes256
	move.l	d4,(a2)+
bytes252
	move.l	d4,(a2)+
bytes248
	move.l	d4,(a2)+
bytes244
	move.l	d4,(a2)+
bytes240
	move.l	d4,(a2)+
bytes236
	move.l	d4,(a2)+
bytes232
	move.l	d4,(a2)+
bytes228
	move.l	d4,(a2)+
bytes224
	move.l	d4,(a2)+
bytes220
	move.l	d4,(a2)+
bytes216
	move.l	d4,(a2)+
bytes212
	move.l	d4,(a2)+
bytes208
	move.l	d4,(a2)+
bytes204
	move.l	d4,(a2)+
bytes200
	move.l	d4,(a2)+
bytes196
	move.l	d4,(a2)+
bytes192
	move.l	d4,(a2)+
bytes188
	move.l	d4,(a2)+
bytes184
	move.l	d4,(a2)+
bytes180
	move.l	d4,(a2)+
bytes176
	move.l	d4,(a2)+
bytes172
	move.l	d4,(a2)+
bytes168
	move.l	d4,(a2)+
bytes164
	move.l	d4,(a2)+
bytes160
	move.l	d4,(a2)+
bytes156
	move.l	d4,(a2)+
bytes152
	move.l	d4,(a2)+
bytes148
	move.l	d4,(a2)+
bytes144
	move.l	d4,(a2)+
bytes140
	move.l	d4,(a2)+
bytes136
	move.l	d4,(a2)+
bytes132
	move.l	d4,(a2)+
bytes128
	move.l	d4,(a2)+
bytes124
	move.l	d4,(a2)+
bytes120
	move.l	d4,(a2)+
bytes116
	move.l	d4,(a2)+
bytes112
	move.l	d4,(a2)+
bytes108
	move.l	d4,(a2)+
bytes104
	move.l	d4,(a2)+
bytes100
	move.l	d4,(a2)+
bytes96
	move.l	d4,(a2)+
bytes92
	move.l	d4,(a2)+
bytes88
	move.l	d4,(a2)+
bytes84
	move.l	d4,(a2)+
bytes80
	move.l	d4,(a2)+
bytes76
	move.l	d4,(a2)+
bytes72
	move.l	d4,(a2)+
bytes68
	move.l	d4,(a2)+
bytes64
	move.l	d4,(a2)+
bytes60
	move.l	d4,(a2)+
bytes56
	move.l	d4,(a2)+
bytes52
	move.l	d4,(a2)+
bytes48
	move.l	d4,(a2)+
bytes44
	move.l	d4,(a2)+
bytes40
	move.l	d4,(a2)+
bytes36
	move.l	d4,(a2)+
bytes32
	move.l	d4,(a2)+
bytes28
	move.l	d4,(a2)+
bytes24
	move.l	d4,(a2)+
bytes20
	move.l	d4,(a2)+
bytes16
	move.l	d4,(a2)+
bytes12
	move.l	d4,(a2)+
bytes8
	move.l	d4,(a2)+
bytes4
	move.l	d4,(a2)+

	lea	320(a0),a0		next line
	move.w	(a1)+,d0		next x-start
	bpl	fill.loop
	rts

	cnop	0,4

bytes319
	move.l	d4,(a2)+
bytes315
	move.l	d4,(a2)+
bytes311
	move.l	d4,(a2)+
bytes307
	move.l	d4,(a2)+
bytes303
	move.l	d4,(a2)+
bytes299
	move.l	d4,(a2)+
bytes295
	move.l	d4,(a2)+
bytes291
	move.l	d4,(a2)+
bytes287
	move.l	d4,(a2)+
bytes283
	move.l	d4,(a2)+
bytes279
	move.l	d4,(a2)+
bytes275
	move.l	d4,(a2)+
bytes271
	move.l	d4,(a2)+
bytes267
	move.l	d4,(a2)+
bytes263
	move.l	d4,(a2)+
bytes259
	move.l	d4,(a2)+
bytes255
	move.l	d4,(a2)+
bytes251
	move.l	d4,(a2)+
bytes247
	move.l	d4,(a2)+
bytes243
	move.l	d4,(a2)+
bytes239
	move.l	d4,(a2)+
bytes235
	move.l	d4,(a2)+
bytes231
	move.l	d4,(a2)+
bytes227
	move.l	d4,(a2)+
bytes223
	move.l	d4,(a2)+
bytes219
	move.l	d4,(a2)+
bytes215
	move.l	d4,(a2)+
bytes211
	move.l	d4,(a2)+
bytes207
	move.l	d4,(a2)+
bytes203
	move.l	d4,(a2)+
bytes199
	move.l	d4,(a2)+
bytes195
	move.l	d4,(a2)+
bytes191
	move.l	d4,(a2)+
bytes187
	move.l	d4,(a2)+
bytes183
	move.l	d4,(a2)+
bytes179
	move.l	d4,(a2)+
bytes175
	move.l	d4,(a2)+
bytes171
	move.l	d4,(a2)+
bytes167
	move.l	d4,(a2)+
bytes163
	move.l	d4,(a2)+
bytes159
	move.l	d4,(a2)+
bytes155
	move.l	d4,(a2)+
bytes151
	move.l	d4,(a2)+
bytes147
	move.l	d4,(a2)+
bytes143
	move.l	d4,(a2)+
bytes139
	move.l	d4,(a2)+
bytes135
	move.l	d4,(a2)+
bytes131
	move.l	d4,(a2)+
bytes127
	move.l	d4,(a2)+
bytes123
	move.l	d4,(a2)+
bytes119
	move.l	d4,(a2)+
bytes115
	move.l	d4,(a2)+
bytes111
	move.l	d4,(a2)+
bytes107
	move.l	d4,(a2)+
bytes103
	move.l	d4,(a2)+
bytes99
	move.l	d4,(a2)+
bytes95
	move.l	d4,(a2)+
bytes91
	move.l	d4,(a2)+
bytes87
	move.l	d4,(a2)+
bytes83
	move.l	d4,(a2)+
bytes79
	move.l	d4,(a2)+
bytes75
	move.l	d4,(a2)+
bytes71
	move.l	d4,(a2)+
bytes67
	move.l	d4,(a2)+
bytes63
	move.l	d4,(a2)+
bytes59
	move.l	d4,(a2)+
bytes55
	move.l	d4,(a2)+
bytes51
	move.l	d4,(a2)+
bytes47
	move.l	d4,(a2)+
bytes43
	move.l	d4,(a2)+
bytes39
	move.l	d4,(a2)+
bytes35
	move.l	d4,(a2)+
bytes31
	move.l	d4,(a2)+
bytes27
	move.l	d4,(a2)+
bytes23
	move.l	d4,(a2)+
bytes19
	move.l	d4,(a2)+
bytes15
	move.l	d4,(a2)+
bytes11
	move.l	d4,(a2)+
bytes7
	move.l	d4,(a2)+
bytes3
	move.w	d4,(a2)+

	move.b	d4,(a2)+

	lea	320(a0),a0		next line
	move.w	(a1)+,d0		next x-start
	bpl	fill.loop
	rts

	cnop	0,4

bytes317
	move.l	d4,(a2)+
bytes313
	move.l	d4,(a2)+
bytes309
	move.l	d4,(a2)+
bytes305
	move.l	d4,(a2)+
bytes301
	move.l	d4,(a2)+
bytes297
	move.l	d4,(a2)+
bytes293
	move.l	d4,(a2)+
bytes289
	move.l	d4,(a2)+
bytes285
	move.l	d4,(a2)+
bytes281
	move.l	d4,(a2)+
bytes277
	move.l	d4,(a2)+
bytes273
	move.l	d4,(a2)+
bytes269
	move.l	d4,(a2)+
bytes265
	move.l	d4,(a2)+
bytes261
	move.l	d4,(a2)+
bytes257
	move.l	d4,(a2)+
bytes253
	move.l	d4,(a2)+
bytes249
	move.l	d4,(a2)+
bytes245
	move.l	d4,(a2)+
bytes241
	move.l	d4,(a2)+
bytes237
	move.l	d4,(a2)+
bytes233
	move.l	d4,(a2)+
bytes229
	move.l	d4,(a2)+
bytes225
	move.l	d4,(a2)+
bytes221
	move.l	d4,(a2)+
bytes217
	move.l	d4,(a2)+
bytes213
	move.l	d4,(a2)+
bytes209
	move.l	d4,(a2)+
bytes205
	move.l	d4,(a2)+
bytes201
	move.l	d4,(a2)+
bytes197
	move.l	d4,(a2)+
bytes193
	move.l	d4,(a2)+
bytes189
	move.l	d4,(a2)+
bytes185
	move.l	d4,(a2)+
bytes181
	move.l	d4,(a2)+
bytes177
	move.l	d4,(a2)+
bytes173
	move.l	d4,(a2)+
bytes169
	move.l	d4,(a2)+
bytes165
	move.l	d4,(a2)+
bytes161
	move.l	d4,(a2)+
bytes157
	move.l	d4,(a2)+
bytes153
	move.l	d4,(a2)+
bytes149
	move.l	d4,(a2)+
bytes145
	move.l	d4,(a2)+
bytes141
	move.l	d4,(a2)+
bytes137
	move.l	d4,(a2)+
bytes133
	move.l	d4,(a2)+
bytes129
	move.l	d4,(a2)+
bytes125
	move.l	d4,(a2)+
bytes121
	move.l	d4,(a2)+
bytes117
	move.l	d4,(a2)+
bytes113
	move.l	d4,(a2)+
bytes109
	move.l	d4,(a2)+
bytes105
	move.l	d4,(a2)+
bytes101
	move.l	d4,(a2)+
bytes97
	move.l	d4,(a2)+
bytes93
	move.l	d4,(a2)+
bytes89
	move.l	d4,(a2)+
bytes85
	move.l	d4,(a2)+
bytes81
	move.l	d4,(a2)+
bytes77
	move.l	d4,(a2)+
bytes73
	move.l	d4,(a2)+
bytes69
	move.l	d4,(a2)+
bytes65
	move.l	d4,(a2)+
bytes61
	move.l	d4,(a2)+
bytes57
	move.l	d4,(a2)+
bytes53
	move.l	d4,(a2)+
bytes49
	move.l	d4,(a2)+
bytes45
	move.l	d4,(a2)+
bytes41
	move.l	d4,(a2)+
bytes37
	move.l	d4,(a2)+
bytes33
	move.l	d4,(a2)+
bytes29
	move.l	d4,(a2)+
bytes25
	move.l	d4,(a2)+
bytes21
	move.l	d4,(a2)+
bytes17
	move.l	d4,(a2)+
bytes13
	move.l	d4,(a2)+
bytes9
	move.l	d4,(a2)+
bytes5
	move.l	d4,(a2)+
bytes1
	move.b	d4,(a2)+

	lea	320(a0),a0		next line
	move.w	(a1)+,d0		next x-start
	bpl	fill.loop
	rts

	cnop	0,4

	dc.l	next.line
fill.width.table
	dc.l	bytes1,bytes2,bytes3,bytes4,bytes5,bytes6,bytes7,bytes8
	dc.l	bytes9,bytes10,bytes11,bytes12,bytes13,bytes14,bytes15
	dc.l	bytes16,bytes17,bytes18,bytes19,bytes20,bytes21,bytes22
	dc.l	bytes23,bytes24,bytes25,bytes26,bytes27,bytes28,bytes29
	dc.l	bytes30,bytes31,bytes32,bytes33,bytes34,bytes35,bytes36
	dc.l	bytes37,bytes38,bytes39,bytes40,bytes41,bytes42,bytes43
	dc.l	bytes44,bytes45,bytes46,bytes47,bytes48,bytes49,bytes50
	dc.l	bytes51,bytes52,bytes53,bytes54,bytes55,bytes56,bytes57
	dc.l	bytes58,bytes59,bytes60,bytes61,bytes62,bytes63,bytes64
	dc.l	bytes65,bytes66,bytes67,bytes68,bytes69,bytes70,bytes71
	dc.l	bytes72,bytes73,bytes74,bytes75,bytes76,bytes77,bytes78
	dc.l	bytes79,bytes80,bytes81,bytes82,bytes83,bytes84,bytes85
	dc.l	bytes86,bytes87,bytes88,bytes89,bytes90,bytes91,bytes92
	dc.l	bytes93,bytes94,bytes95,bytes96,bytes97,bytes98,bytes99
	dc.l	bytes100,bytes101,bytes102,bytes103,bytes104,bytes105
	dc.l	bytes106,bytes107,bytes108,bytes109,bytes110,bytes111
	dc.l	bytes112,bytes113,bytes114,bytes115,bytes116,bytes117
	dc.l	bytes118,bytes119,bytes120,bytes121,bytes122,bytes123
	dc.l	bytes124,bytes125,bytes126,bytes127,bytes128,bytes129
	dc.l	bytes130,bytes131,bytes132,bytes133,bytes134,bytes135
	dc.l	bytes136,bytes137,bytes138,bytes139,bytes140,bytes141
	dc.l	bytes142,bytes143,bytes144,bytes145,bytes146,bytes147
	dc.l	bytes148,bytes149,bytes150,bytes151,bytes152,bytes153
	dc.l	bytes154,bytes155,bytes156,bytes157,bytes158,bytes159
	dc.l	bytes160,bytes161,bytes162,bytes163,bytes164,bytes165
	dc.l	bytes166,bytes167,bytes168,bytes169,bytes170,bytes171
	dc.l	bytes172,bytes173,bytes174,bytes175,bytes176,bytes177
	dc.l	bytes178,bytes179,bytes180,bytes181,bytes182,bytes183
	dc.l	bytes184,bytes185,bytes186,bytes187,bytes188,bytes189
	dc.l	bytes190,bytes191,bytes192,bytes193,bytes194,bytes195
	dc.l	bytes196,bytes197,bytes198,bytes199,bytes200,bytes201
	dc.l	bytes202,bytes203,bytes204,bytes205,bytes206,bytes207
	dc.l	bytes208,bytes209,bytes210,bytes211,bytes212,bytes213
	dc.l	bytes214,bytes215,bytes216,bytes217,bytes218,bytes219
	dc.l	bytes220,bytes221,bytes222,bytes223,bytes224,bytes225
	dc.l	bytes226,bytes227,bytes228,bytes229,bytes230,bytes231
	dc.l	bytes232,bytes233,bytes234,bytes235,bytes236,bytes237
	dc.l	bytes238,bytes239,bytes240,bytes241,bytes242,bytes243
	dc.l	bytes244,bytes245,bytes246,bytes247,bytes248,bytes249
	dc.l	bytes250,bytes251,bytes252,bytes253,bytes254,bytes255
	dc.l	bytes256,bytes257,bytes258,bytes259,bytes260,bytes261
	dc.l	bytes262,bytes263,bytes264,bytes265,bytes266,bytes267
	dc.l	bytes268,bytes269,bytes270,bytes271,bytes272,bytes273
	dc.l	bytes274,bytes275,bytes276,bytes277,bytes278,bytes279
	dc.l	bytes280,bytes281,bytes282,bytes283,bytes284,bytes285
	dc.l	bytes286,bytes287,bytes288,bytes289,bytes290,bytes291
	dc.l	bytes292,bytes293,bytes294,bytes295,bytes296,bytes297
	dc.l	bytes298,bytes299,bytes300,bytes301,bytes302,bytes303
	dc.l	bytes304,bytes305,bytes306,bytes307,bytes308,bytes309
	dc.l	bytes310,bytes311,bytes312,bytes313,bytes314,bytes315
	dc.l	bytes316,bytes317,bytes318,bytes319,bytes320

	cnop	0,4

fill.colour.table
	dc.l	$00000000,$01010101,$02020202,$03030303
	dc.l	$04040404,$05050505,$06060606,$07070707
	dc.l	$08080808,$09090909,$0a0a0a0a,$0b0b0b0b
	dc.l	$0c0c0c0c,$0d0d0d0d,$0e0e0e0e,$0f0f0f0f
	dc.l	$10101010,$11111111,$12121212,$13131313
	dc.l	$14141414,$15151515,$16161616,$17171717
	dc.l	$18181818,$19191919,$1a1a1a1a,$1b1b1b1b
	dc.l	$1c1c1c1c,$1d1d1d1d,$1e1e1e1e,$1f1f1f1f
	dc.l	$20202020,$21212121,$22222222,$23232323
	dc.l	$24242424,$25252525,$26262626,$27272727
	dc.l	$28282828,$29292929,$2a2a2a2a,$2b2b2b2b
	dc.l	$2c2c2c2c,$2d2d2d2d,$2e2e2e2e,$2f2f2f2f
	dc.l	$30303030,$31313131,$32323232,$33333333
	dc.l	$34343434,$35353535,$36363636,$37373737
	dc.l	$38383838,$39393939,$3a3a3a3a,$3b3b3b3b
	dc.l	$3c3c3c3c,$3d3d3d3d,$3e3e3e3e,$3f3f3f3f
	dc.l	$40404040,$41414141,$42424242,$43434343
	dc.l	$44444444,$45454545,$46464646,$47474747
	dc.l	$48484848,$49494949,$4a4a4a4a,$4b4b4b4b
	dc.l	$4c4c4c4c,$4d4d4d4d,$4e4e4e4e,$4f4f4f4f
	dc.l	$50505050,$51515151,$52525252,$53535353
	dc.l	$54545454,$55555555,$56565656,$57575757
	dc.l	$58585858,$59595959,$5a5a5a5a,$5b5b5b5b
	dc.l	$5c5c5c5c,$5d5d5d5d,$5e5e5e5e,$5f5f5f5f
	dc.l	$60606060,$61616161,$62626262,$63636363
	dc.l	$64646464,$65656565,$66666666,$67676767
	dc.l	$68686868,$69696969,$6a6a6a6a,$6b6b6b6b
	dc.l	$6c6c6c6c,$6d6d6d6d,$6e6e6e6e,$6f6f6f6f
	dc.l	$70707070,$71717171,$72727272,$73737373
	dc.l	$74747474,$75757575,$76767676,$77777777
	dc.l	$78787878,$79797979,$7a7a7a7a,$7b7b7b7b
	dc.l	$7c7c7c7c,$7d7d7d7d,$7e7e7e7e,$7f7f7f7f
	dc.l	$80808080,$81818181,$82828282,$83838383
	dc.l	$84848484,$85858585,$86868686,$87878787
	dc.l	$88888888,$89898989,$8a8a8a8a,$8b8b8b8b
	dc.l	$8c8c8c8c,$8d8d8d8d,$8e8e8e8e,$8f8f8f8f
	dc.l	$90909090,$91919191,$92929292,$93939393
	dc.l	$94949494,$95959595,$96969696,$97979797
	dc.l	$98989898,$99999999,$9a9a9a9a,$9b9b9b9b
	dc.l	$9c9c9c9c,$9d9d9d9d,$9e9e9e9e,$9f9f9f9f
	dc.l	$a0a0a0a0,$a1a1a1a1,$a2a2a2a2,$a3a3a3a3
	dc.l	$a4a4a4a4,$a5a5a5a5,$a6a6a6a6,$a7a7a7a7
	dc.l	$a8a8a8a8,$a9a9a9a9,$aaaaaaaa,$abababab
	dc.l	$acacacac,$adadadad,$aeaeaeae,$afafafaf
	dc.l	$b0b0b0b0,$b1b1b1b1,$b2b2b2b2,$b3b3b3b3
	dc.l	$b4b4b4b4,$b5b5b5b5,$b6b6b6b6,$b7b7b7b7
	dc.l	$b8b8b8b8,$b9b9b9b9,$babababa,$bbbbbbbb
	dc.l	$bcbcbcbc,$bdbdbdbd,$bebebebe,$bfbfbfbf
	dc.l	$c0c0c0c0,$c1c1c1c1,$c2c2c2c2,$c3c3c3c3
	dc.l	$c4c4c4c4,$c5c5c5c5,$c6c6c6c6,$c7c7c7c7
	dc.l	$c8c8c8c8,$c9c9c9c9,$cacacaca,$cbcbcbcb
	dc.l	$cccccccc,$cdcdcdcd,$cececece,$cfcfcfcf
	dc.l	$d0d0d0d0,$d1d1d1d1,$d2d2d2d2,$d3d3d3d3
	dc.l	$d4d4d4d4,$d5d5d5d5,$d6d6d6d6,$d7d7d7d7
	dc.l	$d8d8d8d8,$d9d9d9d9,$dadadada,$dbdbdbdb
	dc.l	$dcdcdcdc,$dddddddd,$dededede,$dfdfdfdf
	dc.l	$e0e0e0e0,$e1e1e1e1,$e2e2e2e2,$e3e3e3e3
	dc.l	$e4e4e4e4,$e5e5e5e5,$e6e6e6e6,$e7e7e7e7
	dc.l	$e8e8e8e8,$e9e9e9e9,$eaeaeaea,$ebebebeb
	dc.l	$ecececec,$edededed,$eeeeeeee,$efefefef
	dc.l	$f0f0f0f0,$f1f1f1f1,$f2f2f2f2,$f3f3f3f3
	dc.l	$f4f4f4f4,$f5f5f5f5,$f6f6f6f6,$f7f7f7f7
	dc.l	$f8f8f8f8,$f9f9f9f9,$fafafafa,$fbfbfbfb
	dc.l	$fcfcfcfc,$fdfdfdfd,$fefefefe,$ffffffff

	cnop	0,4

y.table	ds.w	200

	cnop	0,4

fill.coords
	ds.w	402	ystart + max. 200 coord pairs + word for end marker

	cnop	0,4

poly.coords	ds.w	64		space for 16 sided polygon


current.fill.colour	dc.w	0



init.copper
	moveq	#8-1,d1
	moveq	#40,d2			width of one bitplane

next.plane
	move.w	d0,6(a0)		save low word
	swap	d0
	move.w	d0,2(a0)		save high word
	swap	d0
;	add.l	d2,d0			next bitplane
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
	dc.w	bpl1pth,0		8 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0
	dc.w	bpl5pth,0
	dc.w	bpl5ptl,0
	dc.w	bpl6pth,0
	dc.w	bpl6ptl,0
	dc.w	bpl7pth,0
	dc.w	bpl7ptl,0
	dc.w	bpl8pth,0
	dc.w	bpl8ptl,0

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
bpl7pth	equ	$0f8
bpl7ptl	equ	$0fa
bpl8pth	equ	$0fc
bpl8ptl	equ	$0fe
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
