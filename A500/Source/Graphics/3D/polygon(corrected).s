;"""""""""""""""""""""""
;" THE POLYGON ROUTINE "
;"		       "
;"""""""""""""""""""""""

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




polygon	move.w	(a0)+,d0		get number of sides
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
	sub.w	d4,d1	  x off - (((x on - x off) * y off) / (y on - y off))
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
	bmi.s	grad.negative2		if -ve then add it on

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




(Taken from 3D.s, then line number 173 corrected)
