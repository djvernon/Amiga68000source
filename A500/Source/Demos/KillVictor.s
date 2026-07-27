	section	KillVictor,code_c




blitwait	macro
\@	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	\@
	endm




	move.l	4.w,a6
	jsr	-132(a6)		Forbid


	move.l	#(3*268+4*200+2*3*269)*64,d0
	move.l	#$10002,d1		clear chip
	jsr	-198(a6)		AllocMem
	move.l	d0,screen.mem
	beq	exit_now

	move.l	d0,lines.bitplane1
	add.l	#(200+268)*64,d0
	move.l	d0,lines.bitplane2
	add.l	#(200+268)*64,d0
	move.l	d0,lines.bitplane3
	add.l	#(200+268)*64,d0
	move.l	d0,screen1
	add.l	#3*269*64,d0
	move.l	d0,screen2


	moveq	#0,d0
	lea	graf.name(pc),a1
	jsr	-552(a6)		OpenLibrary
	move.l	d0,gfxbase
	beq	exit_freemem

	move.l	d0,a6
	jsr	-456(a6)		OwnBlitter




;"""""""""""""""""""""""""
;" INITIALISE INTERRUPTS "
;"			 "
;"""""""""""""""""""""""""

	lea	$dff000,a6
	move.w	intenar(a6),old.ints	save system interrupt status

	move.w	#$7fff,intena(a6)	disable all interrupts

	move.l	$6c.w,old.level3
	move.l	#set.next.frame,$6c.w

	move.w	#$c010,intena(a6)	enable copper interrupts




;"""""""""""""""""""""""""""""
;" INITIALISE SCREEN DISPLAY "
;"			     "
;"""""""""""""""""""""""""""""

vp.wait	move.l	vposr(a6),d0		get vertical beam position
	and.l	#$1ff00,d0
	lsr.l	#8,d0
	cmp.w	#310,d0			wait for bottom line
	bne.s	vp.wait			before disabling sprite DMA

	move.w	#$03ff,dmacon(a6)	DMA off


	move.w	#$3200,bplcon0(a6)	initialise screen
	move.w	#$2671,diwstrt(a6)
	move.w	#$32d1,diwstop(a6)
	move.w	#$30,ddfstrt(a6)
	move.w	#$d8,ddfstop(a6)
	moveq	#0,d0
	move.w	d0,bplcon1(a6)
	move.w	d0,bplcon2(a6)
	moveq	#20,d0
	move.w	d0,bpl1mod(a6)
	move.w	d0,bpl2mod(a6)


	move.l	screen2(pc),d0		initialise copper
	bsr	set.copper

	move.l	#copper.list,cop1lch(a6)
	move.w	d0,copjmp1(a6)


	move.w	#$87c0,dmacon(a6)	DMA on




;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

loop	sf	next.frame
vbl	tst.b	next.frame
	beq.s	vbl

	bsr	calculate.largest.fill.windows1

	move.w	#$0010,intena(a6)	disable copper interrupts
	move.l	#fill.bitplane1,$6c.w
	move.w	#$8040,intena(a6)	enable blitter interrupts
	move.w	#$8040,intreq(a6)	request a blitter interrupt

	bsr	update.object
	bsr	calculate.sin.cos
	bsr	rotate.perspective
	bsr	surface.elimination
	bsr	lines.to.correct.bitplanes

* ensure last blitter fill operation has begun before
* the blitter is used to draw lines for the new shape

wait.for.last.fill
	cmp.l	#set.next.frame,$6c.w
	bne.s	wait.for.last.fill

	bsr	draw.new.lines

	bsr	update.screens

	btst	#6,$bfe001
	bne.s	loop




;""""""""""""""""
;" EXIT ROUTINE	"
;"		"
;""""""""""""""""

	blitwait

	move.w	#$7fff,intena(a6)	disable all interrupts

	move.l	old.level3(pc),$6c.w

	move.w	old.ints(pc),d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status


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
	move.l	#(3*268+4*200+2*3*269)*64,d0
	move.l	screen.mem(pc),a1
	jsr	-210(a6)		FreeMem

exit_now
	jsr	-138(a6)		Permit

	moveq	#0,d0
	rts




;""""""""""""""""""""""
;" LEVEL 3 INTERRUPTS "
;"		      "
;""""""""""""""""""""""

fill.bitplane1
	movem.l	d0-d2/a0-a1,-(sp)
	move.l	#fill.bitplane2,$6c.w
	move.w	#$0040,intreq(a6)	acknowledge blitter interrupt
	tst.w	minimum.x.bitplane1
	bmi.s	no.fill

	move.l	screen1(pc),a1
	lea	64(a1),a1
	move.l	lines.bitplane1(pc),a0
	move.w	minimum.y.bitplane1,d0
	moveq	#0,d1
	move.w	maximum.y.bitplane1,d1
	move.w	d1,d2
	sub.w	d0,d2			height of fill
	bmi.s	no.fill
	addq.w	#1,d2			height + 1

	lsl.l	#6,d1			max. y * bytes per line
	move.w	maximum.x.bitplane1,d0
	lsr.w	#3,d0
	bclr	#0,d0			max. x in even bytes
	ext.l	d0
	add.l	d0,d1
	add.l	d1,a0			source start address
	add.l	d1,a1			destination start address

	move.w	minimum.x.bitplane1,d1
	lsr.w	#3,d1
	bclr	#0,d1
	sub.w	d1,d0
	addq.w	#2,d0			width of fill in bytes

	move.w	d0,d1
	lsr.w	#1,d1			width of fill in words
	lsl.w	#6,d2			height into correct position
	add.w	d1,d2			+ width

	neg.w	d0
	add.w	#64,d0			bytes per line
	move.w	d0,bltamod(a6)
	move.w	d0,bltdmod(a6)
	move.l	#$9f00012,bltcon0(a6)
	move.l	a0,bltapth(a6)
	move.l	a1,bltdpth(a6)
	move.w	d2,bltsize(a6)
	movem.l	(sp)+,d0-d2/a0-a1
	rte

no.fill	move.w	#$8040,intreq(a6)	request next interrupt because
	movem.l	(sp)+,d0-d2/a0-a1	blitter isn't being used this time
	rte


fill.bitplane2
	movem.l	d0-d2/a0-a1,-(sp)
	move.l	#fill.bitplane3,$6c.w
	move.w	#$0040,intreq(a6)	acknowledge blitter interrupt
	tst.w	minimum.x.bitplane2
	bmi.s	no.fill

	move.l	screen1(pc),a1
	lea	64*(269+1)(a1),a1
	move.l	lines.bitplane2(pc),a0
	move.w	minimum.y.bitplane2,d0
	moveq	#0,d1
	move.w	maximum.y.bitplane2,d1
	move.w	d1,d2
	sub.w	d0,d2
	bmi.s	no.fill
	addq.w	#1,d2

	lsl.l	#6,d1
	move.w	maximum.x.bitplane2,d0
	lsr.w	#3,d0
	bclr	#0,d0
	ext.l	d0
	add.l	d0,d1
	add.l	d1,a0
	add.l	d1,a1

	move.w	minimum.x.bitplane2,d1
	lsr.w	#3,d1
	bclr	#0,d1
	sub.w	d1,d0
	addq.w	#2,d0

	move.w	d0,d1
	lsr.w	#1,d1
	lsl.w	#6,d2
	add.w	d1,d2

	neg.w	d0
	add.w	#64,d0
	move.w	d0,bltamod(a6)
	move.w	d0,bltdmod(a6)
	move.l	#$9f00012,bltcon0(a6)
	move.l	a0,bltapth(a6)
	move.l	a1,bltdpth(a6)
	move.w	d2,bltsize(a6)
	movem.l	(sp)+,d0-d2/a0-a1
	rte


fill.bitplane3
	movem.l	d0-d2/a0-a1,-(sp)
	move.l	#set.next.frame,$6c.w
	move.w	#$0040,intreq(a6)	acknowledge blitter interrupt
	move.w	#$0040,intena(a6)	disable blitter interrupts
	move.w	#$8010,intena(a6)	enable copper interrupts
	tst.w	minimum.x.bitplane3
	bmi.s	no.fill2

	move.l	screen1(pc),a1
	add.l	#64*(2*269+1),a1
	move.l	lines.bitplane3(pc),a0
	move.w	minimum.y.bitplane3,d0
	moveq	#0,d1
	move.w	maximum.y.bitplane3,d1
	move.w	d1,d2
	sub.w	d0,d2
	bmi.s	no.fill2
	addq.w	#1,d2

	lsl.l	#6,d1
	move.w	maximum.x.bitplane3,d0
	lsr.w	#3,d0
	bclr	#0,d0
	ext.l	d0
	add.l	d0,d1
	add.l	d1,a0
	add.l	d1,a1

	move.w	minimum.x.bitplane3,d1
	lsr.w	#3,d1
	bclr	#0,d1
	sub.w	d1,d0
	addq.w	#2,d0

	move.w	d0,d1
	lsr.w	#1,d1
	lsl.w	#6,d2
	add.w	d1,d2

	neg.w	d0
	add.w	#64,d0
	move.w	d0,bltamod(a6)
	move.w	d0,bltdmod(a6)
	move.l	#$9f00012,bltcon0(a6)
	move.l	a0,bltapth(a6)
	move.l	a1,bltdpth(a6)
	move.w	d2,bltsize(a6)

no.fill2
	movem.l	(sp)+,d0-d2/a0-a1
	rte


set.next.frame
	move.w	#$0010,intreq(a6)	acknowledge copper interrupt
	st	next.frame
	rte



;"""""""""""""""
;" SUBROUTINES "
;"	       "
;"""""""""""""""

calculate.largest.fill.windows1
	movem.w	old.min.max.bitplane1,d0-d3
	movem.w	oldest.min.max.bitplane1,d4-d7
	movem.w	d0-d3,oldest.min.max.bitplane1
	movem.w	minimum.x.bitplane1,d0-d3
	movem.w	d0-d3,old.min.max.bitplane1

	cmp.w	d0,d4
	bls.s	min.x.ok1
	move.w	d0,d4

min.x.ok1
	cmp.w	d1,d5
	bls.s	min.y.ok1
	move.w	d1,d5

min.y.ok1
	cmp.w	d2,d6
	bcc.s	max.x.ok1
	move.w	d2,d6

max.x.ok1
	cmp.w	d3,d7
	bcc.s	max.y.ok1
	move.w	d3,d7

max.y.ok1
	movem.w	d4-d7,minimum.x.bitplane1

calculate.largest.fill.windows2
	movem.w	old.min.max.bitplane2,d0-d3
	movem.w	oldest.min.max.bitplane2,d4-d7
	movem.w	d0-d3,oldest.min.max.bitplane2
	movem.w	minimum.x.bitplane2,d0-d3
	movem.w	d0-d3,old.min.max.bitplane2

	cmp.w	d0,d4
	bls.s	min.x.ok2
	move.w	d0,d4

min.x.ok2
	cmp.w	d1,d5
	bls.s	min.y.ok2
	move.w	d1,d5

min.y.ok2
	cmp.w	d2,d6
	bcc.s	max.x.ok2
	move.w	d2,d6

max.x.ok2
	cmp.w	d3,d7
	bcc.s	max.y.ok2
	move.w	d3,d7

max.y.ok2
	movem.w	d4-d7,minimum.x.bitplane2

calculate.largest.fill.windows3
	movem.w	old.min.max.bitplane3,d0-d3
	movem.w	oldest.min.max.bitplane3,d4-d7
	movem.w	d0-d3,oldest.min.max.bitplane3
	movem.w	minimum.x.bitplane3,d0-d3
	movem.w	d0-d3,old.min.max.bitplane3

	cmp.w	d0,d4
	bls.s	min.x.ok3
	move.w	d0,d4

min.x.ok3
	cmp.w	d1,d5
	bls.s	min.y.ok3
	move.w	d1,d5

min.y.ok3
	cmp.w	d2,d6
	bcc.s	max.x.ok3
	move.w	d2,d6

max.x.ok3
	cmp.w	d3,d7
	bcc.s	max.y.ok3
	move.w	d3,d7

max.y.ok3
	movem.w	d4-d7,minimum.x.bitplane3
	rts


update.count	dc.w	0
update.routine	dc.l	0


update.object
	tst.w	update.count
	beq.s	get.new

count.down
	subq.w	#1,update.count
	move.l	update.routine,a0
	jmp	(a0)


get.new	move.l	update.pointer,a0
	move.w	(a0)+,update.count
	bne.s	get.routine

get.colour
	move.l	(a0)+,d0
	beq.s	update.reset

	move.l	d0,colour+2
	move.l	a0,update.pointer

	bsr	set.colours
	bra.s	get.new

update.reset
	move.l	#update.list,update.pointer
	bra.s	get.new


get.routine
	move.l	(a0)+,update.routine
	move.l	a0,update.pointer

	subq.w	#1,update.count
	bne.s	count.down

	move.l	update.routine,a0
	jsr	(a0)
	bra.s	get.new


update.pointer	dc.l	update.list

update.list
	dc.w	0			change colour
	dc.l	colour.masks

	dc.w	1			do this then do next in list
	dc.l	next.object

	dc.w	1
	dc.l	x.step.clear

	dc.w	1
	dc.l	y.step.clear

	dc.w	1
	dc.l	z.step.clear

	dc.w	1
	dc.l	x.angle.clear

	dc.w	1
	dc.l	y.angle.clear

	dc.w	1
	dc.l	z.angle.clear

	dc.w	17			do routine this many times
	dc.l	y.step.up

	dc.w	$407
	dc.l	object.fine.nearer

	dc.w	7
	dc.l	object.further

	dc.w	7
	dc.l	x.step.up

	dc.w	$198
	dc.l	return

	dc.w	7
	dc.l	y.step.down

	dc.w	$8d
	dc.l	object.further

	dc.w	1
	dc.l	x.step.clear

	dc.w	1
	dc.l	x.angle.clear

	dc.w	0
	dc.l	colour.masks+12

	dc.w	1
	dc.l	next.object

	dc.w	$61
	dc.l	object.nearer

	dc.w	$ce
	dc.l	return

	dc.w	$dd
	dc.l	object.fine.further

	dc.w	11
	dc.l	x.step.up

	dc.w	$f1
	dc.l	return

	dc.w	$77
	dc.l	object.further

	dc.w	1
	dc.l	next.object

	dc.w	1
	dc.l	x.step.clear

	dc.w	1
	dc.l	x.angle.clear

	dc.w	1
	dc.l	y.step.clear

	dc.w	1
	dc.l	y.angle.clear

	dc.w	1
	dc.l	x.angle.90

	dc.w	0
	dc.l	colour.masks+36

	dc.w	14
	dc.l	x.step.up

	dc.w	$c9
	dc.l	object.nearer

	dc.w	$e0
	dc.l	return

	dc.w	3
	dc.l	y.step.up

	dc.w	1
	dc.l	x.step.clear

	dc.w	$8d
	dc.l	object.further

	dc.w	1
	dc.l	x.angle.90

	dc.w	$8d
	dc.l	object.nearer

	dc.w	6
	dc.l	x.step.up

	dc.w	6
	dc.l	y.step.up

	dc.w	16
	dc.l	z.step.up

	dc.w	$143
	dc.l	return

	dc.w	$c9
	dc.l	object.further

	dc.w	0
	dc.l	colour.masks+12

	dc.w	1
	dc.l	next.object

	dc.w	1
	dc.l	x.step.clear

	dc.w	1
	dc.l	y.step.clear

	dc.w	1
	dc.l	z.step.clear

	dc.w	1
	dc.l	y.angle.clear

	dc.w	1
	dc.l	z.angle.clear

	dc.w	1
	dc.l	x.angle.270

	dc.w	11
	dc.l	y.step.up

	dc.w	$8d
	dc.l	object.nearer

	dc.w	$da
	dc.l	return

	dc.w	4
	dc.l	x.step.up

	dc.w	21
	dc.l	object.fine.further

	dc.w	5
	dc.l	x.step.up

	dc.w	5
	dc.l	z.step.up

	dc.w	$1f9
	dc.l	return

	dc.w	$8d
	dc.l	object.further

	dc.w	0
	dc.l	colour.masks+60

	dc.w	1
	dc.l	next.object

	dc.w	1
	dc.l	x.step.clear

	dc.w	1
	dc.l	z.step.clear

	dc.w	1
	dc.l	y.step.clear

	dc.w	1
	dc.l	x.angle.set

	dc.w	1
	dc.l	z.angle.clear

	dc.w	1
	dc.l	y.angle.clear

	dc.w	11
	dc.l	y.step.up

	dc.w	$79
	dc.l	object.nearer

	dc.w	$1fb
	dc.l	return

	dc.w	$c9
	dc.l	object.further

	dc.w	0
	dc.l	colour.masks+48

	dc.w	1
	dc.l	next.object

	dc.w	1
	dc.l	x.step.clear

	dc.w	1
	dc.l	y.step.clear

	dc.w	1
	dc.l	z.step.clear

	dc.w	1
	dc.l	x.angle.clear

	dc.w	1
	dc.l	y.angle.clear

	dc.w	1
	dc.l	z.angle.clear

	dc.w	8
	dc.l	x.step.up

	dc.w	$79
	dc.l	object.nearer

	dc.w	$d3
	dc.l	return

	dc.w	1
	dc.l	x.step.clear

	dc.w	1
	dc.l	y.step.up

	dc.w	$78
	dc.l	object.further

	dc.w	10
	dc.l	y.step.up

	dc.w	0
	dc.l	colour.masks

	dc.w	1
	dc.l	next.object

	dc.w	$79
	dc.l	object.nearer

	dc.w	$9a
	dc.l	return

	dc.w	11
	dc.l	object.fine.further

	dc.w	5
	dc.l	y.step.up

	dc.w	6
	dc.l	z.step.up

	dc.w	$191
	dc.l	return

	dc.w	$79
	dc.l	object.further

	dc.w	1
	dc.l	x.step.clear

	dc.w	1
	dc.l	y.step.clear

	dc.w	1
	dc.l	z.step.clear

	dc.w	1
	dc.l	x.angle.clear

	dc.w	1
	dc.l	y.angle.clear

	dc.w	1
	dc.l	z.angle.clear

	dc.w	0
	dc.l	colour.masks

	dc.w	1
	dc.l	next.object

	dc.w	7
	dc.l	x.step.up

	dc.w	$6a
	dc.l	object.nearer

	dc.w	$198
	dc.l	return

	dc.w	15
	dc.l	object.fine.further

	dc.w	9
	dc.l	y.step.up

	dc.w	9
	dc.l	z.step.up

	dc.w	$259
	dc.l	return

	dc.w	$79
	dc.l	object.further

	dc.w	0
	dc.l	colour.masks+84

	dc.w	1
	dc.l	next.object

	dc.w	$79
	dc.l	object.nearer

	dc.w	$25a
	dc.l	return

	dc.w	$c9
	dc.l	object.further

	dc.w	0
	dc.l	0


x.step.up
	addq.w	#2,x.step+2
	rts

y.step.up
	addq.w	#2,y.step+2
	rts

z.step.up
	addq.w	#2,z.step+2
	rts


x.step.down
	subq.w	#2,x.step+2
	rts

y.step.down
	subq.w	#2,y.step+2
	rts

z.step.down
	subq.w	#2,z.step+2
	rts


x.step.clear
	clr.w	x.step+2
	rts

y.step.clear
	clr.w	y.step+2
	rts

z.step.clear
	clr.w	z.step+2
	rts


x.angle.clear
	clr.w	x.angle+2
	rts

y.angle.clear
	clr.w	y.angle+2
	rts

z.angle.clear
	clr.w	z.angle+2
	rts


x.angle.90
	move.w	#512,x.angle+2
	rts

x.angle.270
	move.w	#1536,x.angle+2
	rts

x.angle.set
	move.w	#304,x.angle+2
	rts


object.further
	add.w	#256,z.offset+2
check1	cmp.w	#$7a00,z.offset+2
	bls.s	not.too.far
	move.w	#$7a00,z.offset+2
not.too.far
	bra	set.colours


object.nearer
	sub.w	#256,z.offset+2
check2	cmp.w	#$d80,z.offset+2
	bcc.s	not.too.near
	move.w	#$d80,z.offset+2
not.too.near
	bra	set.colours


object.fine.further
	add.w	#16,z.offset+2
	bra.s	check1


object.fine.nearer
	sub.w	#32,z.offset+2
	bra.s	check2


return	rts


next.object
	move.l	objects.ptr,a0
	cmp.l	#objects.end,a0
	bne.s	set.object

	move.l	#objects,objects.ptr
	bra.s	next.object

set.object
	lea	object.surfaces(pc),a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)
	move.l	a0,objects.ptr
	rts


objects.ptr	dc.l	objects

objects	dc.l	object1.surfaces,object1.lines,object1.coords
	dc.l	object9.surfaces,object9.lines,object9.coords
	dc.l	object7.surfaces,object7.lines,object7.coords
	dc.l	object6.surfaces,object6.lines,object6.coords
	dc.l	object5.surfaces,object5.lines,object5.coords
	dc.l	object4.surfaces,object4.lines,object4.coords
	dc.l	object3.surfaces,object3.lines,object3.coords
	dc.l	object8.surfaces,object8.lines,object8.coords
	dc.l	object2.surfaces,object2.lines,object2.coords
objects.end


brightness.table
	dc.w	$fff,$ddd,$bbb,$999,$777,$ddd
	dc.w	$fff,$ddd,$bbb,$999,$777,$ddd
	dc.w	$fff,$ddd,$bbb,$999,$777,$ddd
	dc.w	$eee,$ccc,$aaa,$999,$777,$ccc
	dc.w	$eee,$ccc,$aaa,$999,$777,$ccc
	dc.w	$ddd,$bbb,$999,$888,$666,$bbb
	dc.w	$ddd,$bbb,$999,$888,$666,$bbb
	dc.w	$ccc,$aaa,$999,$888,$666,$aaa
	dc.w	$bbb,$aaa,$888,$777,$555,$aaa
	dc.w	$aaa,$999,$777,$666,$555,$999
	dc.w	$999,$888,$777,$666,$444,$888
	dc.w	$888,$777,$666,$555,$444,$777
	dc.w	$777,$777,$555,$555,$333,$777
	dc.w	$666,$666,$555,$444,$333,$666
	dc.w	$555,$555,$444,$333,$222,$555
	dc.w	$444,$444,$333,$222,$222,$444


set.colours
	lea	brightness.table(pc),a0
	move.w	z.offset+2,d0
	rol.w	#5,d0
	and.w	#$f,d0
	muls	#12,d0
	add.w	d0,a0
	lea	copper.colours+2(pc),a1

colour	move.l	#colour.masks,a2

	move.w	(a0)+,d0
	and.w	(a2)+,d0
	move.w	d0,(a1)
	addq.w	#4,a1

	move.w	(a0)+,d0
	and.w	(a2)+,d0
	move.w	d0,(a1)
	addq.w	#4,a1

	move.w	(a0)+,d0
	and.w	(a2)+,d0
	move.w	d0,(a1)
	addq.w	#4,a1

	move.w	(a0)+,d0
	and.w	(a2)+,d0
	move.w	d0,(a1)
	addq.w	#4,a1

	move.w	(a0)+,d0
	and.w	(a2)+,d0
	move.w	d0,(a1)
	addq.w	#4,a1

	move.w	(a0),d0
	and.w	(a2),d0
	move.w	d0,(a1)
	rts


colour.masks
	dc.w	$00f,$00f,$00f,$00f,$00f,$f00		blue
	dc.w	$ff0,$ff0,$ff0,$ff0,$ff0,$f00		yellow
	dc.w	$fff,$fff,$fff,$fff,$fff,$f00		white
	dc.w	$0f0,$0f0,$0f0,$0f0,$0f0,$f00		green
	dc.w	$f00,$f00,$f00,$f00,$f00,$f00		red
	dc.w	$0ff,$0ff,$0ff,$0ff,$0ff,$f00		light blue
	dc.w	$f0f,$f0f,$f0f,$f0f,$f0f,$f00		purple
	dc.w	$0ff,$f0f,$ff0,$00f,$0f0,$f00		various


calculate.sin.cos
x.step	add.w	#0,x.angle+2
y.step	add.w	#0,y.angle+2
z.step	add.w	#0,z.angle+2
	lea	sin.table(pc),a0
	move.w	#$8000,d0		to correct table values

z.angle	move.w	#0,d3
	and.w	#$7fe,d3
	move.w	(a0,d3.w),d4
	add.w	#512,d3
	and.w	#$7fe,d3
	move.w	(a0,d3.w),d5
	add.w	d0,d4
	add.w	d0,d5
	move.w	d4,sin.z+2
	move.w	d5,cos.z+2

y.angle	move.w	#0,d3
	and.w	#$7fe,d3
	move.w	(a0,d3.w),d4
	add.w	#512,d3
	and.w	#$7fe,d3
	move.w	(a0,d3.w),d5
	add.w	d0,d4
	add.w	d0,d5
	move.w	d4,sin.y+2
	move.w	d5,cos.y+2

x.angle	move.w	#0,d3
	and.w	#$7fe,d3
	move.w	(a0,d3.w),d4
	add.w	#512,d3
	and.w	#$7fe,d3
	move.w	(a0,d3.w),d5
	add.w	d0,d4
	add.w	d0,d5
	move.w	d4,sin.x+2
	move.w	d5,cos.x+2
	rts


rotate.perspective
	move.l	object.coords(pc),a0
	lea	screen.coords(pc),a1
	move.w	(a0)+,d7

next.coord
	movem.w	(a0)+,d0-d2

sin.z	move.w	#0,d4
cos.z	move.w	#0,d5
	move.w	d0,d3
	move.w	d1,d6
	muls	d5,d0
	muls	d4,d6
	sub.l	d6,d0
	lsl.l	#1,d0
	swap	d0
	muls	d4,d3
	muls	d5,d1
	add.l	d3,d1
	lsl.l	#1,d1
	swap	d1

sin.y	move.w	#0,d4
cos.y	move.w	#0,d5
	move.w	d0,d3
	move.w	d2,d6
	muls	d5,d0
	muls	d4,d6
	sub.l	d6,d0
	lsl.l	#1,d0
	swap	d0
	muls	d3,d4
	muls	d5,d2
	add.l	d4,d2
	lsl.l	#1,d2
	swap	d2

sin.x	move.w	#0,d4
cos.x	move.w	#0,d5
	move.w	d1,d3
	move.w	d2,d6
	muls	d5,d1
	muls	d4,d6
	sub.l	d6,d1
	lsl.l	#1,d1
	swap	d1
	muls	d3,d4
	muls	d5,d2
	add.l	d4,d2
	lsl.l	#1,d2
	swap	d2

z.offset
	add.w	#$7a00,d2
	ext.l	d0
	ext.l	d1
	asl.l	#8,d0
	asl.l	#8,d1
	asl.l	#5,d0
	asl.l	#5,d1
	divs	d2,d0
	divs	d2,d1
	add.w	#(80+352/2)*16,d0	centre x on screen
	add.w	#(200+268/2)*16,d1	centre y on screen
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	dbra	d7,next.coord
	rts



surface.elimination
	move.l	object.surfaces,a0
	lea	screen.coords(pc),a1
	move.w	(a0)+,d7		get number of surfaces

next.surface
	move.w	8(a0),d0		offset for x1, y1
	movem.w	(a1,d0.w),d1-d2		x1, y1

	move.w	10(a0),d0		offset for x2, y2
	movem.w	(a1,d0.w),d3-d4		x2, y2

	move.w	12(a0),d0		offset for x3, y3
	movem.w	(a1,d0.w),d5-d6		x3, y3

	sub.w	d1,d3			x2-x1
	sub.w	d2,d4			y2-y1
	sub.w	d1,d5			x3-x1
	sub.w	d2,d6			y3-y1
	muls	d3,d6			(x2-x1)*(y3-y1)
	muls	d4,d5			(y2-y1)*(x3-x1)
	sub.l	d6,d5			(y2-y1)*(x3-x1) - (x2-x1)*(y3-y1)
	bmi.s	surface.is.hidden

surface.is.visible
	and.w	#$7fff,(a0)
	add.w	#14,a0
	dbra	d7,next.surface
	rts

surface.is.hidden
	or.w	#$8000,(a0)
	add.w	#14,a0
	dbra	d7,next.surface
	rts


lines.to.correct.bitplanes
	move.l	object.surfaces,a0
	lea	bitplane1.line.flags,a1
	lea	bitplane2.line.flags,a2
	lea	bitplane3.line.flags,a3
	move.w	(a0)+,d7		get number of surfaces

next.surface1
	move.w	(a0)+,d6		get colour for surface
	bmi.s	not.in.bitplane3

	movem.w	(a0),d0-d2		get three line numbers for surface
	lsr.w	#1,d6
	bcc.s	not.in.bitplane1
	not.w	(a1,d0.w)
	not.w	(a1,d1.w)
	not.w	(a1,d2.w)

not.in.bitplane1
	lsr.w	#1,d6
	bcc.s	not.in.bitplane2
	not.w	(a2,d0.w)
	not.w	(a2,d1.w)
	not.w	(a2,d2.w)

not.in.bitplane2
	lsr.w	#1,d6
	bcc.s	not.in.bitplane3
	not.w	(a3,d0.w)
	not.w	(a3,d1.w)
	not.w	(a3,d2.w)

not.in.bitplane3
	add.w	#12,a0
	dbra	d7,next.surface1
	rts


draw.new.lines
	blitwait

	moveq	#-1,d1
	move.l	d1,bltafwm(a6)
	move.w	#64,bltcmod(a6)
	move.w	d1,bltbdat(a6)
	move.w	#$8000,bltadat(a6)

	move.w	d1,minimum.x.bitplane1	initialise minimum values
	move.w	d1,minimum.y.bitplane1
	move.w	d1,minimum.x.bitplane2
	move.w	d1,minimum.y.bitplane2
	move.w	d1,minimum.x.bitplane3
	move.w	d1,minimum.y.bitplane3

	moveq	#0,d1
	move.w	d1,maximum.x.bitplane1	initialise maximum values
	move.w	d1,maximum.y.bitplane1
	move.w	d1,maximum.x.bitplane2
	move.w	d1,maximum.y.bitplane2
	move.w	d1,maximum.x.bitplane3
	move.w	d1,maximum.y.bitplane3

	lea	screen.coords(pc),a4
	move.l	lines.bitplane1,a5
	lea	old.line.values1,a0
	move.l	end.ptr1,d5
	cmp.l	a0,d5
	beq.s	no.bitplane1.old.lines

clear.bitplane1.old.lines
	bsr	clear.old.line
	cmp.l	a0,d5
	bne.s	clear.bitplane1.old.lines

no.bitplane1.old.lines
	lea	bitplane1.line.flags,a0
	lea	old.line.values1,a2
	move.l	object.lines,a3		line data
	move.w	(a3)+,d5		number of lines

next.bitplane1.line
	tst.w	(a0)+
	beq.s	no.bitplane1.line

	clr.w	-2(a0)			clear line flag

	move.w	(a3),d6			offset for x1, y1
	movem.w	(a4,d6.w),d0-d1		x1, y1

	move.w	2(a3),d6		offset for x2, y2
	movem.w	(a4,d6.w),d2-d3		x2, y2

	asr.w	#4,d0
	asr.w	#4,d1
	asr.w	#4,d2
	asr.w	#4,d3

	cmp.w	d1,d3
	bhi.s	going.upwards1
	exg	d0,d2
	exg	d1,d3

going.upwards1
	cmp.w	minimum.x.bitplane1,d0
	bcc.s	x1.not.minimum1
	move.w	d0,minimum.x.bitplane1

x1.not.minimum1
	cmp.w	minimum.x.bitplane1,d2
	bcc.s	x2.not.minimum1
	move.w	d2,minimum.x.bitplane1

x2.not.minimum1
	cmp.w	maximum.x.bitplane1,d0
	bls.s	x1.not.maximum1
	move.w	d0,maximum.x.bitplane1

x1.not.maximum1
	cmp.w	maximum.x.bitplane1,d2
	bls.s	x2.not.maximum1
	move.w	d2,maximum.x.bitplane1

x2.not.maximum1
	cmp.w	minimum.y.bitplane1,d1
	bcc.s	y1.not.minimum1
	move.w	d1,minimum.y.bitplane1

y1.not.minimum1
	cmp.w	maximum.y.bitplane1,d3
	bls.s	y2.not.maximum1
	move.w	d3,maximum.y.bitplane1

y2.not.maximum1
	bsr	draw.line

no.bitplane1.line
	addq.w	#4,a3
	dbra	d5,next.bitplane1.line

	move.l	a2,end.ptr1

	move.l	lines.bitplane2,a5
	lea	old.line.values2,a0
	move.l	end.ptr2,d5
	cmp.l	a0,d5
	beq.s	no.bitplane2.old.lines

clear.bitplane2.old.lines
	bsr	clear.old.line
	cmp.l	a0,d5
	bne.s	clear.bitplane2.old.lines

no.bitplane2.old.lines
	lea	bitplane2.line.flags,a0
	lea	old.line.values2,a2
	move.l	object.lines,a3		line data
	move.w	(a3)+,d5		number of lines

next.bitplane2.line
	tst.w	(a0)+
	beq.s	no.bitplane2.line

	clr.w	-2(a0)			clear line flag

	move.w	(a3),d6			offset for x1, y1
	movem.w	(a4,d6.w),d0-d1		x1, y1

	move.w	2(a3),d6		offset for x2, y2
	movem.w	(a4,d6.w),d2-d3		x2, y2

	asr.w	#4,d0
	asr.w	#4,d1
	asr.w	#4,d2
	asr.w	#4,d3

	cmp.w	d1,d3
	bhi.s	going.upwards2
	exg	d0,d2
	exg	d1,d3

going.upwards2
	cmp.w	minimum.x.bitplane2,d0
	bcc.s	x1.not.minimum2
	move.w	d0,minimum.x.bitplane2

x1.not.minimum2
	cmp.w	minimum.x.bitplane2,d2
	bcc.s	x2.not.minimum2
	move.w	d2,minimum.x.bitplane2

x2.not.minimum2
	cmp.w	maximum.x.bitplane2,d0
	bls.s	x1.not.maximum2
	move.w	d0,maximum.x.bitplane2

x1.not.maximum2
	cmp.w	maximum.x.bitplane2,d2
	bls.s	x2.not.maximum2
	move.w	d2,maximum.x.bitplane2

x2.not.maximum2
	cmp.w	minimum.y.bitplane2,d1
	bcc.s	y1.not.minimum2
	move.w	d1,minimum.y.bitplane2

y1.not.minimum2
	cmp.w	maximum.y.bitplane2,d3
	bls.s	y2.not.maximum2
	move.w	d3,maximum.y.bitplane2

y2.not.maximum2
	bsr	draw.line

no.bitplane2.line
	addq.w	#4,a3
	dbra	d5,next.bitplane2.line

	move.l	a2,end.ptr2

	move.l	lines.bitplane3,a5
	lea	old.line.values3,a0
	move.l	end.ptr3,d5
	cmp.l	a0,d5
	beq.s	no.bitplane3.old.lines

clear.bitplane3.old.lines
	bsr	clear.old.line
	cmp.l	a0,d5
	bne.s	clear.bitplane3.old.lines

no.bitplane3.old.lines
	lea	bitplane3.line.flags,a0
	lea	old.line.values3,a2
	move.l	object.lines,a3		line data
	move.w	(a3)+,d5		number of lines

next.bitplane3.line
	tst.w	(a0)+
	beq.s	no.bitplane3.line

	clr.w	-2(a0)			clear line flag

	move.w	(a3),d6			offset for x1, y1
	movem.w	(a4,d6.w),d0-d1		x1, y1

	move.w	2(a3),d6		offset for x2, y2
	movem.w	(a4,d6.w),d2-d3		x2, y2

	asr.w	#4,d0
	asr.w	#4,d1
	asr.w	#4,d2
	asr.w	#4,d3

	cmp.w	d1,d3
	bhi.s	going.upwards3
	exg	d0,d2
	exg	d1,d3

going.upwards3
	cmp.w	minimum.x.bitplane3,d0
	bcc.s	x1.not.minimum3
	move.w	d0,minimum.x.bitplane3

x1.not.minimum3
	cmp.w	minimum.x.bitplane3,d2
	bcc.s	x2.not.minimum3
	move.w	d2,minimum.x.bitplane3

x2.not.minimum3
	cmp.w	maximum.x.bitplane3,d0
	bls.s	x1.not.maximum3
	move.w	d0,maximum.x.bitplane3

x1.not.maximum3
	cmp.w	maximum.x.bitplane3,d2
	bls.s	x2.not.maximum3
	move.w	d2,maximum.x.bitplane3

x2.not.maximum3
	cmp.w	minimum.y.bitplane3,d1
	bcc.s	y1.not.minimum3
	move.w	d1,minimum.y.bitplane3

y1.not.minimum3
	cmp.w	maximum.y.bitplane3,d3
	bls.s	y2.not.maximum3
	move.w	d3,maximum.y.bitplane3

y2.not.maximum3
	bsr.s	draw.line

no.bitplane3.line
	addq.w	#4,a3
	dbra	d5,next.bitplane3.line

	move.l	a2,end.ptr3

	cmp.w	#200,minimum.y.bitplane1
	bcc.s	minimum.y.ok1
	move.w	#200,minimum.y.bitplane1
minimum.y.ok1
	cmp.w	#468,maximum.y.bitplane1
	bls.s	maximum.y.ok1
	move.w	#468,maximum.y.bitplane1

maximum.y.ok1
	cmp.w	#200,minimum.y.bitplane2
	bcc.s	minimum.y.ok2
	move.w	#200,minimum.y.bitplane2
minimum.y.ok2
	cmp.w	#468,maximum.y.bitplane2
	bls.s	maximum.y.ok2
	move.w	#468,maximum.y.bitplane2

maximum.y.ok2
	cmp.w	#200,minimum.y.bitplane3
	bcc.s	minimum.y.ok3
	move.w	#200,minimum.y.bitplane3
minimum.y.ok3
	cmp.w	#468,maximum.y.bitplane3
	bls.s	maximum.y.ok3
	move.w	#468,maximum.y.bitplane3

maximum.y.ok3
	rts



draw.line

; draw line using blitter
;
; d2, d3 = x1, y1
; d0, d1 = x2, y2

	sub.w	d3,d1			y2-y1

	ext.l	d3
	lsl.l	#6,d3			calculate y offset

	moveq	#$f,d4
	and.w	d2,d4			low four bits from x-start

	sub.w	d2,d0			x2-x1
	blt.s	x2.less.than.x1

	tst.w	d1
	blt.s	y2.less.than.y1

	cmp.w	d0,d1
	bge.s	dy.greater.than.dx

	moveq	#%10011,d7
	bra.s	octant.set

dy.greater.than.dx
	moveq	#%00011,d7
	exg	d0,d1			larger delta to d0
	bra.s	octant.set

y2.less.than.y1
	neg.w	d1			make delta-y positive
	cmp.w	d0,d1
	bge.s	dy.greater.than.dx.2

	moveq	#%11011,d7
	bra.s	octant.set

dy.greater.than.dx.2
	moveq	#%00111,d7
	exg	d0,d1			larger delta to d0
	bra.s	octant.set

x2.less.than.x1
	neg.w	d0			make delta-x positive
	tst.w	d1
	blt.s	y2.less.than.y1.2

	cmp.w	d0,d1
	bge.s	dy.greater.than.dx.3

	moveq	#%10111,d7
	bra.s	octant.set

dy.greater.than.dx.3
	moveq	#%01011,d7
	exg	d0,d1			larger delta to d0
	bra.s	octant.set

y2.less.than.y1.2
	neg.w	d1			make delta-y positive
	cmp.w	d0,d1
	bge.s	dy.greater.than.dx.4

	moveq	#%11111,d7
	bra.s	octant.set

dy.greater.than.dx.4
	moveq	#%01111,d7
	exg	d0,d1			larger delta to d0

octant.set
	add.w	d1,d1			2 Sdelta
	asr.w	#3,d2			x-start offset in bytes
	ext.l	d2
	add.l	d2,d3			add y offset

	move.w	d1,d2			2 Sdelta
	sub.w	d0,d2			2 Sdelta - Ldelta
	bge.s	no.sign

	or.w	#%1000000,d7		set SIGN flag

no.sign	blitwait

	move.w	d2,bltapth+2(a6)	2 Sdelta - Ldelta
	move.w	d2,(a2)+
	move.w	d1,bltbmod(a6)		2 Sdelta
	sub.w	d0,d2
	move.w	d2,bltamod(a6)		2 Sdelta - 2 Ldelta
	move.w	d1,(a2)+
	move.w	d2,(a2)+

	asl.w	#6,d0			line length into correct position
	add.w	#$42,d0			length + 1, width = 2

	move.w	d4,d1
	swap	d4
	asr.l	#4,d4
	or.w	#$b4a,d4
	swap	d7
	move.w	d4,d7
	swap	d7
	add.l	a5,d3			start address of line
	move.l	d7,bltcon0(a6)
	move.l	d3,bltcpth(a6)		start address of line
	move.l	d3,bltdpth(a6)		start address of line

	move.l	d3,a1
	not.b	d1
	bchg	d1,(a1)
	move.w	d0,bltsize(a6)		start blitter

	and.l	#$ff00ffff,d7		clear minterms
	move.l	d7,(a2)+
	move.l	d3,(a2)+
	move.w	d0,(a2)+
	rts


clear.old.line
	blitwait

	move.w	(a0)+,bltapth+2(a6)
	move.w	(a0)+,bltbmod(a6)
	move.w	(a0)+,bltamod(a6)
	move.l	(a0)+,bltcon0(a6)
	move.l	(a0)+,a3
	move.l	a3,bltcpth(a6)
	move.l	a3,bltdpth(a6)
	move.w	(a0)+,bltsize(a6)
	rts




old.min.max.bitplane1		dc.w	0,0,0,0
oldest.min.max.bitplane1	dc.w	-1,0,0,0

old.min.max.bitplane2		dc.w	0,0,0,0
oldest.min.max.bitplane2	dc.w	-1,0,0,0

old.min.max.bitplane3		dc.w	0,0,0,0
oldest.min.max.bitplane3	dc.w	-1,0,0,0

minimum.x.bitplane1	dc.w	-1
minimum.y.bitplane1	dc.w	0
maximum.x.bitplane1	dc.w	0
maximum.y.bitplane1	dc.w	0

minimum.x.bitplane2	dc.w	-1
minimum.y.bitplane2	dc.w	0
maximum.x.bitplane2	dc.w	0
maximum.y.bitplane2	dc.w	0

minimum.x.bitplane3	dc.w	-1
minimum.y.bitplane3	dc.w	0
maximum.x.bitplane3	dc.w	0
maximum.y.bitplane3	dc.w	0

bitplane1.line.flags	ds.w	64
bitplane2.line.flags	ds.w	64
bitplane3.line.flags	ds.w	64

end.ptr1	dc.l	old.line.values1
end.ptr2	dc.l	old.line.values2
end.ptr3	dc.l	old.line.values3

old.line.values1	ds.w	300
old.line.values2	ds.w	300
old.line.values3	ds.w	300

object.surfaces	dc.l	0
object.lines	dc.l	0
object.coords	dc.l	0

screen.coords	ds.w	300


object1.surfaces
	dc.w	$000b,$0001,$0000,$0002,$0008,$0000,$0004,$0008
	dc.w	$0001,$0008,$0004,$0006,$0008,$000c,$0000,$0002
	dc.w	$0004,$000a,$000c,$0008,$0018,$000c,$0002,$000c
	dc.w	$0010,$000e,$0018,$001c,$000c,$0001,$0012,$0010
	dc.w	$001e,$0018,$0014,$001c,$0001,$001a,$0020,$001e
	dc.w	$0014,$0010,$001c,$0002,$0016,$0018,$001a,$0014
	dc.w	$0004,$0010,$0002,$0000,$0018,$001c,$0004,$0000
	dc.w	$0010,$0004,$0012,$0014,$0016,$0004,$0014,$0018
	dc.w	$0004,$0002,$000a,$0014,$0004,$0018,$0008,$0004
	dc.w	$001c,$0020,$0022,$0000,$001c,$0010,$0004,$0022
	dc.w	$000e,$0006,$0000,$000c,$001c

object1.lines
	dc.w	$0011,$0000,$0004
	dc.w	$0004,$0008,$0008,$000c,$000c,$0000,$0000,$0008
	dc.w	$0008,$0018,$000c,$0018,$000c,$001c,$0018,$001c
	dc.w	$0014,$0018,$0004,$0018,$0004,$0014,$0004,$0010
	dc.w	$0014,$0010,$0000,$0010,$0014,$001c,$0010,$001c
	dc.w	$0000,$001c

object1.coords
	dc.w	$0007,$03c0,$03c0,$03c0,$fc40,$03c0
	dc.w	$03c0,$fc40,$fc40,$03c0,$03c0,$fc40,$03c0,$03c0
	dc.w	$03c0,$fc40,$fc40,$03c0,$fc40,$fc40,$fc40,$fc40
	dc.w	$03c0,$fc40,$fc40


object2.surfaces
	dc.w	$0013,$0001,$0000,$0002,$0004
	dc.w	$0014,$0004,$0000,$0003,$0006,$0008,$0000,$0014
	dc.w	$0008,$0004,$0001,$000a,$000c,$0006,$0014,$000c
	dc.w	$0008,$0003,$000e,$0010,$000a,$0014,$0010,$000c
	dc.w	$0004,$0004,$0014,$000e,$0014,$0000,$0010,$0002
	dc.w	$0016,$0018,$001a,$002c,$001c,$0018,$0005,$001c
	dc.w	$001e,$0016,$002c,$0020,$001c,$0004,$0020,$0022
	dc.w	$001c,$002c,$0024,$0020,$0002,$0024,$0026,$0020
	dc.w	$002c,$0028,$0024,$0004,$001a,$002a,$0024,$002c
	dc.w	$0018,$0028,$0002,$002c,$000c,$002e,$0018,$0008
	dc.w	$000c,$0001,$0030,$002c,$0018,$001c,$0008,$0018
	dc.w	$0002,$0032,$0008,$0030,$001c,$0004,$0008,$0001
	dc.w	$0034,$0032,$001e,$0020,$0004,$001c,$0002,$0036
	dc.w	$0002,$0034,$0020,$0000,$0004,$0001,$0038,$0036
	dc.w	$0022,$0024,$0000,$0020,$0002,$003a,$0014,$0038
	dc.w	$0024,$0010,$0000,$0001,$0028,$003a,$0026,$0028
	dc.w	$0010,$0024,$0002,$0012,$0010,$0028,$0028,$000c
	dc.w	$0010,$0001,$002e,$0012,$002a,$0018,$000c,$0028

object2.lines
	dc.w	$001d,$0014,$0004,$0004,$0000,$0000,$0014,$0014
	dc.w	$0008,$0008,$0004,$0014,$000c,$000c,$0008,$0014
	dc.w	$0010,$0010,$000c,$0028,$000c,$0000,$0010,$002c
	dc.w	$001c,$001c,$0018,$0018,$002c,$0020,$002c,$001c
	dc.w	$0020,$0024,$002c,$0020,$0024,$0028,$002c,$0024
	dc.w	$0028,$0010,$0028,$0018,$0028,$0018,$0008,$000c
	dc.w	$0018,$001c,$0008,$001c,$0004,$0020,$0004,$0020
	dc.w	$0000,$0024,$0000,$0024,$0010

object2.coords
	dc.w	$000b,$0000,$0280
	dc.w	$0140,$0260,$00c0,$0140,$0170,$fe00,$0140,$fe90
	dc.w	$fe00,$0140,$fda0,$00c0,$0140,$0000,$0000,$0280
	dc.w	$0000,$fd80,$fec0,$0260,$ff40,$fec0,$0170,$0200
	dc.w	$fec0,$fe90,$0200,$fec0,$fda0,$ff40,$fec0,$0000
	dc.w	$0000,$fd80


object3.surfaces
	dc.w	$0017,$0001,$0000,$0002,$0004,$0000
	dc.w	$0008,$0004,$0001,$0002,$0006,$0008,$0004,$0008
	dc.w	$000c,$0002,$000a,$000c,$0000,$0000,$0018,$0008
	dc.w	$0002,$0008,$000e,$0010,$0004,$000c,$001c,$0002
	dc.w	$0004,$0012,$0014,$0000,$0004,$0010,$0002,$0016
	dc.w	$0018,$0012,$0004,$0014,$0010,$0003,$0014,$001a
	dc.w	$000a,$0000,$0010,$0018,$0003,$0010,$001c,$0016
	dc.w	$0004,$001c,$0014,$0003,$000c,$001e,$0020,$0008
	dc.w	$0018,$0028,$0003,$0022,$0024,$001e,$0018,$0020
	dc.w	$0028,$0003,$0026,$0028,$000e,$000c,$002c,$001c
	dc.w	$0003,$0028,$002a,$002c,$001c,$002c,$0024,$0002
	dc.w	$002e,$001a,$0030,$0030,$0018,$0010,$0002,$0032
	dc.w	$0022,$002e,$0030,$0020,$0018,$0002,$001c,$0034
	dc.w	$0036,$0014,$001c,$0034,$0002,$002c,$0038,$0034
	dc.w	$001c,$0024,$0034,$0004,$0024,$0032,$003a,$0028
	dc.w	$0020,$0030,$0006,$003c,$003a,$003e,$002c,$0028
	dc.w	$0030,$0006,$003e,$0040,$0042,$002c,$0030,$0034
	dc.w	$0004,$002a,$0042,$0038,$0024,$002c,$0034,$0002
	dc.w	$0020,$003c,$0044,$0008,$0028,$002c,$0002,$0006
	dc.w	$0044,$0026,$000c,$0008,$002c,$0001,$0040,$0030
	dc.w	$0046,$0034,$0030,$0010,$0001,$0046,$0018,$0036
	dc.w	$0034,$0010,$0014

object3.lines
	dc.w	$0023,$0000,$0008,$0004,$0008
	dc.w	$0000,$0004,$0008,$000c,$0004,$000c,$0000,$0018
	dc.w	$0008,$0018,$000c,$001c,$0004,$001c,$0004,$0010
	dc.w	$0000,$0010,$0004,$0014,$0010,$0014,$0010,$0018
	dc.w	$0014,$001c,$0018,$0028,$0008,$0028,$0018,$0020
	dc.w	$0020,$0028,$000c,$002c,$001c,$002c,$0024,$002c
	dc.w	$001c,$0024,$0018,$0030,$0010,$0030,$0020,$0030
	dc.w	$001c,$0034,$0014,$0034,$0024,$0034,$0028,$0030
	dc.w	$0028,$002c,$002c,$0030,$0030,$0034,$002c,$0034
	dc.w	$0008,$002c,$0010,$0034

object3.coords
	dc.w	$000d,$fce0,$fe20,$0000
	dc.w	$fce0,$01e0,$0000,$0000,$fe20,$00f0,$0000,$01e0
	dc.w	$00f0,$0000,$fe20,$ff10,$0000,$01e0,$ff10,$02d0
	dc.w	$fce0,$0000,$02d0,$0320,$0000,$03c0,$fce0,$0000
	dc.w	$03c0,$0320,$0000,$03c0,$fe20,$00f0,$03c0,$01e0
	dc.w	$00f0,$03c0,$fe20,$ff10,$03c0,$01e0,$ff10


object4.surfaces
	dc.w	$000d
	dc.w	$0002,$0000,$0014,$001c,$0000,$0010,$0004,$0002
	dc.w	$0006,$0008,$000a,$0008,$000c,$0014,$0004,$000c
	dc.w	$000e,$0000,$0000,$0018,$0010,$0004,$0010,$000a
	dc.w	$0012,$0018,$0008,$0014,$0004,$0014,$0016,$0018
	dc.w	$0004,$0010,$001c,$0004,$001a,$0008,$0020,$001c
	dc.w	$0014,$000c,$0002,$0010,$000c,$001e,$0008,$0018
	dc.w	$0000,$0002,$0018,$0020,$0022,$0004,$001c,$000c
	dc.w	$0002,$000e,$0024,$0026,$0010,$0018,$0020,$0001
	dc.w	$0012,$0028,$0024,$0018,$0014,$0020,$0002,$001a
	dc.w	$0002,$0028,$0014,$001c,$0020,$0003,$0026,$0002
	dc.w	$0016,$0010,$0020,$001c,$0006,$001e,$001c,$0004
	dc.w	$0008,$0000,$0004,$0006,$0006,$0004,$0022,$000c
	dc.w	$0008,$0004

object4.lines
	dc.w	$0014,$0000,$0010,$001c,$0020,$0004
	dc.w	$0008,$0008,$000c,$000c,$0014,$0008,$0014,$0000
	dc.w	$0018,$0010,$0018,$0008,$0018,$0014,$0018,$0004
	dc.w	$0010,$0010,$001c,$0004,$001c,$0014,$001c,$0000
	dc.w	$0004,$0000,$0008,$000c,$001c,$0004,$000c,$0018
	dc.w	$0020,$0010,$0020,$0014,$0020

object4.coords
	dc.w	$0008,$fc40,$fe20
	dc.w	$01e0,$fc40,$01e0,$01e0,$fc40,$fe20,$fe20,$fc40
	dc.w	$01e0,$fe20,$0320,$0000,$0140,$0320,$0000,$fec0
	dc.w	$0320,$fec0,$0000,$0320,$0140,$0000,$03c0,$0000
	dc.w	$0050


object5.surfaces
	dc.w	$000d,$0001,$0000,$0002,$0004,$0000,$0004
	dc.w	$0008,$0002,$0020,$0022,$0002,$0004,$0010,$0008
	dc.w	$0002,$0022,$0018,$001a,$0008,$0010,$0018,$0003
	dc.w	$0018,$0016,$0026,$0018,$0010,$0014,$0004,$000a
	dc.w	$001a,$0012,$001c,$0008,$0018,$0003,$000c,$0010
	dc.w	$000e,$000c,$001c,$0020,$0002,$0006,$0004,$0008
	dc.w	$000c,$0000,$0008,$0002,$0008,$000a,$000c,$000c
	dc.w	$0008,$001c,$0004,$0006,$000e,$0024,$0000,$000c
	dc.w	$0020,$0004,$0028,$0016,$0020,$0004,$0014,$0010
	dc.w	$0002,$0024,$001e,$0000,$0000,$0020,$0004,$0002
	dc.w	$001e,$001c,$0028,$0004,$0020,$0014,$0006,$0010
	dc.w	$0014,$001c,$0020,$001c,$0014,$0006,$0012,$0026
	dc.w	$0014,$001c,$0018,$0014

object5.lines
	dc.w	$0014,$0000,$0004,$0004
	dc.w	$0008,$0000,$0008,$0000,$000c,$0008,$000c,$0008
	dc.w	$001c,$000c,$001c,$000c,$0020,$001c,$0020,$0018
	dc.w	$001c,$0014,$001c,$0010,$0014,$0010,$0018,$0008
	dc.w	$0018,$0014,$0020,$0004,$0020,$0004,$0010,$0008
	dc.w	$0010,$0000,$0020,$0014,$0018,$0004,$0014

object5.coords
	dc.w	$0008
	dc.w	$fec0,$fc40,$0000,$0140,$fc40,$0000,$0000,$0000
	dc.w	$0140,$fc40,$fec0,$0000,$03c0,$fec0,$0000,$0280
	dc.w	$0320,$0000,$0140,$0320,$0140,$fec0,$0320,$0140
	dc.w	$fd80,$0320,$0000


object6.surfaces
	dc.w	$000b,$0002,$0002,$0006,$001c
	dc.w	$0000,$0004,$0014,$0002,$001c,$0014,$000a,$0000
	dc.w	$0014,$0010,$0001,$0004,$0018,$0006,$0004,$000c
	dc.w	$0014,$0001,$000a,$0010,$000e,$0000,$0010,$0008
	dc.w	$0004,$0010,$0020,$0012,$0008,$0010,$0018,$0004
	dc.w	$0018,$001a,$0022,$0014,$000c,$001c,$0006,$0014
	dc.w	$0022,$0000,$0010,$0014,$001c,$0006,$0000,$0016
	dc.w	$0020,$0010,$001c,$0018,$0002,$000e,$0012,$000c
	dc.w	$0000,$0008,$0018,$0002,$0008,$001a,$0004,$0004
	dc.w	$001c,$000c,$0003,$000c,$0016,$001e,$0000,$0018
	dc.w	$001c,$0003,$001e,$0008,$0002,$0000,$001c,$0004

object6.lines
	dc.w	$0011,$0010,$001c,$0000,$0004,$0004,$000c,$0004
	dc.w	$0014,$0004,$001c,$0000,$0010,$0000,$0018,$0000
	dc.w	$0008,$0008,$0010,$0008,$0018,$0010,$0014,$0018
	dc.w	$001c,$000c,$0014,$000c,$001c,$0000,$0014,$0000
	dc.w	$001c,$0010,$0018,$0014,$001c

object6.coords
	dc.w	$0007,$ff10,$fc40
	dc.w	$0000,$00f0,$fc40,$0000,$fc40,$0320,$0000,$03c0
	dc.w	$0320,$0000,$fe70,$03c0,$0190,$0190,$03c0,$0190
	dc.w	$fe70,$03c0,$fe70,$0190,$03c0,$fe70


object7.surfaces
	dc.w	$0007,$0001
	dc.w	$0000,$0002,$0004,$0000,$0004,$0010,$0002,$0012
	dc.w	$0014,$0000,$0000,$0014,$0004,$0002,$0004,$0008
	dc.w	$0006,$0000,$0010,$0008,$0002,$000a,$000c,$0002
	dc.w	$0004,$000c,$0010,$0004,$0014,$0010,$000a,$0004
	dc.w	$0014,$000c,$0004,$0006,$000e,$0012,$0000,$0008
	dc.w	$0014,$0006,$0008,$0016,$000e,$0008,$0010,$0014
	dc.w	$0006,$000c,$0010,$0016,$0010,$000c,$0014

object7.lines
	dc.w	$000b
	dc.w	$0000,$0004,$0004,$0010,$0000,$0010,$0000,$0008
	dc.w	$0008,$0010,$0004,$000c,$000c,$0010,$0008,$0014
	dc.w	$000c,$0014,$0000,$0014,$0004,$0014,$0010,$0014

object7.coords
	dc.w	$0005,$fe20,$fd80,$0000,$01e0,$fd80,$0000,$fc40
	dc.w	$0280,$0000,$03c0,$0280,$0000,$0000,$02d0,$0140
	dc.w	$0000,$02d0,$fec0


object8.surfaces
	dc.w	$001b,$0001,$0000,$0002,$0004
	dc.w	$0000,$0004,$0008,$0001,$0004,$0006,$0008,$0000
	dc.w	$0008,$000c,$0002,$0006,$000a,$000c,$000c,$0008
	dc.w	$0014,$0002,$0002,$000e,$0010,$0008,$0004,$0018
	dc.w	$0003,$0010,$0012,$000a,$0008,$0018,$0014,$0004
	dc.w	$0014,$0016,$000e,$0004,$001c,$0018,$0004,$000c
	dc.w	$0018,$001a,$000c,$0014,$0010,$0002,$0018,$001c
	dc.w	$001e,$0010,$0014,$0028,$0003,$0020,$0022,$001c
	dc.w	$0014,$0024,$0028,$0001,$0012,$0024,$0020,$0014
	dc.w	$0018,$0024,$0003,$0026,$0028,$0024,$0018,$0020
	dc.w	$0024,$0002,$0016,$002a,$0026,$0018,$001c,$0020
	dc.w	$0004,$001e,$002c,$0052,$0010,$0028,$002c,$0006
	dc.w	$0022,$002e,$0030,$0028,$0024,$0030,$0006,$0030
	dc.w	$0032,$002c,$0028,$0030,$002c,$0006,$0028,$0034
	dc.w	$0036,$0024,$0020,$0034,$0006,$0036,$0038,$002e
	dc.w	$0024,$0034,$0030,$0004,$002a,$003a,$0034,$0020
	dc.w	$001c,$0034,$0004,$0008,$003c,$003e,$0000,$000c
	dc.w	$003c,$0004,$003e,$0040,$0000,$0000,$003c,$0004
	dc.w	$0003,$003c,$001a,$0042,$003c,$000c,$0010,$0002
	dc.w	$0042,$0044,$0046,$003c,$0010,$0038,$0003,$0040
	dc.w	$0048,$0014,$0004,$003c,$001c,$0002,$0048,$0046
	dc.w	$004a,$001c,$003c,$0038,$0001,$004a,$004c,$003a
	dc.w	$001c,$0038,$0034,$0002,$004c,$004e,$0038,$0034
	dc.w	$0038,$0030,$0002,$004e,$0050,$0032,$0030,$0038
	dc.w	$002c,$0001,$0050,$0044,$0052,$002c,$0038,$0010

object8.lines
	dc.w	$0029,$0000,$0004,$0004,$0008,$0000,$0008,$0008
	dc.w	$000c,$0000,$000c,$0008,$0014,$000c,$0014,$0004
	dc.w	$0018,$0008,$0018,$0014,$0018,$0004,$001c,$0018
	dc.w	$001c,$0010,$0014,$000c,$0010,$0014,$0028,$0010
	dc.w	$0028,$0014,$0024,$0024,$0028,$0018,$0024,$0018
	dc.w	$0020,$0020,$0024,$001c,$0020,$0028,$002c,$0024
	dc.w	$0030,$0028,$0030,$002c,$0030,$0020,$0034,$0024
	dc.w	$0034,$0030,$0034,$001c,$0034,$000c,$003c,$0000
	dc.w	$003c,$0004,$003c,$0010,$003c,$0010,$0038,$0038
	dc.w	$003c,$001c,$003c,$001c,$0038,$0034,$0038,$0030
	dc.w	$0038,$002c,$0038,$0010,$002c

object8.coords
	dc.w	$000f,$0000,$fc40
	dc.w	$0000,$01e0,$fe20,$0000,$0000,$fec0,$0100,$fe20
	dc.w	$fe20,$0000,$fce0,$00a0,$0000,$ff10,$0140,$0190
	dc.w	$00f0,$0140,$0190,$0320,$00a0,$0000,$0280,$0320
	dc.w	$00d0,$0000,$03c0,$00f0,$fd80,$0320,$00d0,$fd80
	dc.w	$0320,$ff30,$0000,$03c0,$ff10,$0280,$0320,$ff30
	dc.w	$0000,$00f0,$fe70,$0000,$fe20,$ff00


object9.surfaces
	dc.w	$001e,$0001
	dc.w	$0000,$0002,$0004,$0000,$0004,$0008,$0001,$0004
	dc.w	$0006,$0008,$0000,$0008,$001c,$0001,$0006,$000a
	dc.w	$000c,$001c,$0008,$000c,$0001,$000c,$000e,$0010
	dc.w	$001c,$000c,$0018,$0001,$000e,$0012,$0014,$0018
	dc.w	$000c,$0010,$0001,$0014,$0016,$0018,$0018,$0010
	dc.w	$0014,$0002,$0008,$001a,$001c,$0000,$001c,$0020
	dc.w	$0002,$001a,$001e,$0020,$0020,$001c,$0034,$0004
	dc.w	$001e,$0010,$0022,$0034,$001c,$0018,$0004,$0022
	dc.w	$0024,$0026,$0034,$0018,$0030,$0002,$0024,$0018
	dc.w	$0028,$0030,$0018,$0014,$0004,$0028,$0016,$002a
	dc.w	$0030,$0014,$0010,$0004,$002a,$002c,$002e,$0030
	dc.w	$0010,$002c,$0002,$0012,$0030,$002c,$0010,$000c
	dc.w	$002c,$0004,$000a,$0032,$0030,$000c,$0008,$002c
	dc.w	$0004,$0034,$0036,$0032,$0008,$0028,$002c,$0002
	dc.w	$0002,$0038,$0034,$0008,$0004,$0028,$0002,$003a
	dc.w	$003c,$0038,$0004,$0024,$0028,$0004,$0000,$003e
	dc.w	$003a,$0004,$0000,$0024,$0004,$001c,$0040,$003e
	dc.w	$0000,$0020,$0024,$0003,$0040,$0042,$003c,$0024
	dc.w	$0020,$0028,$0003,$0020,$0044,$0042,$0020,$0034
	dc.w	$0028,$0002,$0044,$0046,$0036,$0028,$0034,$002c
	dc.w	$0002,$0026,$002e,$0046,$0034,$0030,$002c,$0004
	dc.w	$0048,$004a,$004c,$0038,$003c,$0040,$0004,$004c
	dc.w	$004e,$0050,$0038,$0040,$0044,$0004,$0052,$0054
	dc.w	$0056,$0048,$004c,$0050,$0004,$0056,$0058,$005a
	dc.w	$0048,$0050,$0054,$0004,$005c,$005e,$0060,$0058
	dc.w	$005c,$0060,$0004,$0062,$0064,$0066,$0070,$0064
	dc.w	$0068,$0004,$0066,$0068,$006a,$0070,$0068,$006c

object9.lines
	dc.w	$0035,$0000,$0004,$0004,$0008,$0000,$0008,$0008
	dc.w	$001c,$0000,$001c,$0008,$000c,$000c,$001c,$000c
	dc.w	$0018,$0018,$001c,$000c,$0010,$0010,$0018,$0010
	dc.w	$0014,$0014,$0018,$001c,$0020,$0000,$0020,$001c
	dc.w	$0034,$0020,$0034,$0018,$0034,$0018,$0030,$0030
	dc.w	$0034,$0014,$0030,$0010,$0030,$0010,$002c,$002c
	dc.w	$0030,$000c,$002c,$0008,$002c,$0008,$0028,$0028
	dc.w	$002c,$0004,$0028,$0004,$0024,$0024,$0028,$0000
	dc.w	$0024,$0020,$0024,$0020,$0028,$0028,$0034,$002c
	dc.w	$0034,$0038,$003c,$003c,$0040,$0038,$0040,$0040
	dc.w	$0044,$0038,$0044,$0048,$004c,$004c,$0050,$0048
	dc.w	$0050,$0050,$0054,$0048,$0054,$0058,$005c,$005c
	dc.w	$0060,$0058,$0060,$0064,$0070,$0064,$0068,$0068
	dc.w	$0070,$0068,$006c,$006c,$0070

object9.coords
	dc.w	$001c,$fd80,$fc40
	dc.w	$03c0,$0280,$fc40,$03c0,$03c0,$fd80,$03c0,$03c0
	dc.w	$0280,$03c0,$01e0,$0460,$03c0,$fe20,$0460,$03c0
	dc.w	$fc40,$0280,$03c0,$fc40,$fd80,$03c0,$fd80,$fc40
	dc.w	$fe20,$0280,$fc40,$fe20,$03c0,$fd80,$fce0,$03c0
	dc.w	$0280,$fce0,$fc40,$0280,$fce0,$fc40,$fd80,$fce0
	dc.w	$fd80,$fd80,$03c0,$ff10,$fd80,$03c0,$ff10,$ff10
	dc.w	$03c0,$fd80,$ff10,$03c0,$00f0,$fd80,$03c0,$0280
	dc.w	$fd80,$03c0,$0280,$ff10,$03c0,$00f0,$ff10,$03c0
	dc.w	$0000,$fec0,$03c0,$00c0,$0140,$03c0,$ff40,$0140
	dc.w	$03c0,$fe20,$0190,$03c0,$01e0,$0190,$03c0,$01e0
	dc.w	$02d0,$03c0,$fe20,$02d0,$03c0


sin.table
	dc.w	$8000,$80c9,$8192,$825b,$8324,$83ed,$84b6,$857e
	dc.w	$8647,$8710,$87d9,$88a1,$896a,$8a32,$8afb,$8bc3
	dc.w	$8c8b,$8d53,$8e1b,$8ee3,$8fab,$9072,$9139,$9201
	dc.w	$92c7,$938e,$9455,$951b,$95e1,$96a7,$976d,$9833
	dc.w	$98f8,$99bd,$9a82,$9b47,$9c0b,$9ccf,$9d93,$9e56
	dc.w	$9f19,$9fdc,$a09f,$a161,$a223,$a2e5,$a3a6,$a467
	dc.w	$a527,$a5e8,$a6a7,$a767,$a826,$a8e5,$a9a3,$aa61
	dc.w	$ab1f,$abdc,$ac98,$ad55,$ae10,$aecc,$af87,$b041
	dc.w	$b0fb,$b1b5,$b26e,$b326,$b3de,$b496,$b54d,$b603
	dc.w	$b6b9,$b76f,$b824,$b8d8,$b98c,$ba3f,$baf2,$bba4
	dc.w	$bc56,$bd07,$bdb7,$be67,$bf17,$bfc5,$c073,$c121
	dc.w	$c1cd,$c279,$c325,$c3d0,$c47a,$c524,$c5cc,$c675
	dc.w	$c71c,$c7c3,$c869,$c90f,$c9b3,$ca57,$cafb,$cb9d
	dc.w	$cc3f,$cce0,$cd81,$ce20,$cebf,$cf5d,$cffb,$d097
	dc.w	$d133,$d1ce,$d268,$d302,$d39a,$d432,$d4c9,$d55f
	dc.w	$d5f5,$d689,$d71d,$d7b0,$d842,$d8d3,$d964,$d9f3
	dc.w	$da82,$db0f,$db9c,$dc28,$dcb3,$dd3d,$ddc7,$de4f
	dc.w	$ded7,$df5d,$dfe3,$e068,$e0eb,$e16e,$e1f0,$e271
	dc.w	$e2f1,$e370,$e3ee,$e46b,$e4e8,$e563,$e5dd,$e656
	dc.w	$e6cf,$e746,$e7bc,$e831,$e8a6,$e919,$e98b,$e9fc
	dc.w	$ea6d,$eadc,$eb4a,$ebb7,$ec23,$ec8e,$ecf8,$ed61
	dc.w	$edc9,$ee30,$ee96,$eefa,$ef5e,$efc1,$f022,$f083
	dc.w	$f0e2,$f140,$f19d,$f1f9,$f254,$f2ae,$f307,$f35e
	dc.w	$f3b5,$f40a,$f45f,$f4b2,$f504,$f555,$f5a5,$f5f3
	dc.w	$f641,$f68d,$f6d8,$f722,$f76b,$f7b3,$f7fa,$f83f
	dc.w	$f884,$f8c7,$f909,$f94a,$f989,$f9c8,$fa05,$fa41
	dc.w	$fa7c,$fab6,$faee,$fb26,$fb5c,$fb91,$fbc5,$fbf8
	dc.w	$fc29,$fc59,$fc88,$fcb6,$fce3,$fd0e,$fd39,$fd62
	dc.w	$fd89,$fdb0,$fdd5,$fdfa,$fe1d,$fe3e,$fe5f,$fe7e
	dc.w	$fe9c,$feb9,$fed5,$feef,$ff09,$ff21,$ff37,$ff4d
	dc.w	$ff61,$ff74,$ff86,$ff97,$ffa6,$ffb4,$ffc1,$ffcd
	dc.w	$ffd8,$ffe1,$ffe9,$fff0,$fff5,$fff9,$fffd,$fffe
	dc.w	$ffff,$fffe,$fffd,$fff9,$fff5,$fff0,$ffe9,$ffe1
	dc.w	$ffd8,$ffcd,$ffc1,$ffb4,$ffa6,$ff97,$ff86,$ff74
	dc.w	$ff61,$ff4d,$ff37,$ff21,$ff09,$feef,$fed5,$feb9
	dc.w	$fe9c,$fe7e,$fe5f,$fe3e,$fe1d,$fdfa,$fdd5,$fdb0
	dc.w	$fd89,$fd62,$fd39,$fd0e,$fce3,$fcb6,$fc88,$fc59
	dc.w	$fc29,$fbf8,$fbc5,$fb91,$fb5c,$fb26,$faee,$fab6
	dc.w	$fa7c,$fa41,$fa05,$f9c8,$f989,$f94a,$f909,$f8c7
	dc.w	$f884,$f83f,$f7fa,$f7b3,$f76b,$f722,$f6d8,$f68d
	dc.w	$f641,$f5f3,$f5a5,$f555,$f504,$f4b2,$f45f,$f40a
	dc.w	$f3b5,$f35e,$f307,$f2ae,$f254,$f1f9,$f19d,$f140
	dc.w	$f0e2,$f083,$f022,$efc1,$ef5e,$eefa,$ee96,$ee30
	dc.w	$edc9,$ed61,$ecf8,$ec8e,$ec23,$ebb7,$eb4a,$eadc
	dc.w	$ea6d,$e9fc,$e98b,$e919,$e8a6,$e831,$e7bc,$e746
	dc.w	$e6cf,$e656,$e5dd,$e563,$e4e8,$e46b,$e3ee,$e370
	dc.w	$e2f1,$e271,$e1f0,$e16e,$e0eb,$e068,$dfe3,$df5d
	dc.w	$ded7,$de4f,$ddc7,$dd3d,$dcb3,$dc28,$db9c,$db0f
	dc.w	$da82,$d9f3,$d964,$d8d3,$d842,$d7b0,$d71d,$d689
	dc.w	$d5f5,$d55f,$d4c9,$d432,$d39a,$d302,$d268,$d1ce
	dc.w	$d133,$d097,$cffb,$cf5d,$cebf,$ce20,$cd81,$cce0
	dc.w	$cc3f,$cb9d,$cafb,$ca57,$c9b3,$c90f,$c869,$c7c3
	dc.w	$c71c,$c675,$c5cc,$c524,$c47a,$c3d0,$c325,$c27a
	dc.w	$c1cd,$c121,$c073,$bfc5,$bf17,$be67,$bdb7,$bd07
	dc.w	$bc56,$bba4,$baf2,$ba3f,$b98c,$b8d8,$b824,$b76f
	dc.w	$b6b9,$b603,$b54d,$b496,$b3de,$b326,$b26e,$b1b5
	dc.w	$b0fb,$b041,$af87,$aecc,$ae10,$ad55,$ac98,$abdc
	dc.w	$ab1f,$aa61,$a9a3,$a8e5,$a826,$a767,$a6a7,$a5e8
	dc.w	$a527,$a467,$a3a6,$a2e5,$a223,$a161,$a09f,$9fdc
	dc.w	$9f19,$9e56,$9d93,$9ccf,$9c0b,$9b47,$9a82,$99bd
	dc.w	$98f8,$9833,$976d,$96a7,$95e1,$951b,$9455,$938e
	dc.w	$92c7,$9201,$9139,$9072,$8fab,$8ee3,$8e1b,$8d53
	dc.w	$8c8b,$8bc3,$8afb,$8a32,$896a,$88a1,$87d9,$8710
	dc.w	$8647,$857e,$84b6,$83ed,$8324,$825b,$8192,$80c9
	dc.w	$7fff,$7f36,$7e6d,$7da4,$7cdb,$7c12,$7b49,$7a81
	dc.w	$79b8,$78ef,$7826,$775e,$7695,$75cd,$7504,$743c
	dc.w	$7374,$72ac,$71e4,$711c,$7054,$6f8d,$6ec6,$6dfe
	dc.w	$6d38,$6c71,$6baa,$6ae4,$6a1e,$6958,$6892,$67cc
	dc.w	$6707,$6642,$657d,$64b8,$63f4,$6330,$626c,$61a9
	dc.w	$60e6,$6023,$5f60,$5e9e,$5ddc,$5d1a,$5c59,$5b98
	dc.w	$5ad8,$5a17,$5958,$5898,$57d9,$571a,$565c,$559e
	dc.w	$54e0,$5423,$5367,$52aa,$51ef,$5133,$5078,$4fbe
	dc.w	$4f04,$4e4a,$4d91,$4cd9,$4c21,$4b69,$4ab2,$49fc
	dc.w	$4946,$4890,$47db,$4727,$4673,$45c0,$450d,$445b
	dc.w	$43a9,$42f8,$4248,$4198,$40e8,$403a,$3f8c,$3ede
	dc.w	$3e32,$3d85,$3cda,$3c2f,$3b85,$3adb,$3a33,$398a
	dc.w	$38e3,$383c,$3796,$36f0,$364c,$35a8,$3504,$3462
	dc.w	$33c0,$331f,$327e,$31df,$3140,$30a2,$3004,$2f68
	dc.w	$2ecc,$2e31,$2d97,$2cfd,$2c65,$2bcd,$2b36,$2aa0
	dc.w	$2a0a,$2976,$28e2,$284f,$27bd,$272c,$269b,$260c
	dc.w	$257d,$24f0,$2463,$23d7,$234c,$22c2,$2238,$21b0
	dc.w	$2128,$20a2,$201c,$1f97,$1f14,$1e91,$1e0f,$1d8e
	dc.w	$1d0e,$1c8f,$1c11,$1b94,$1b17,$1a9c,$1a22,$19a9
	dc.w	$1930,$18b9,$1843,$17ce,$1759,$16e6,$1674,$1603
	dc.w	$1592,$1523,$14b5,$1448,$13dc,$1371,$1307,$129e
	dc.w	$1236,$11cf,$1169,$1105,$10a1,$103e,$0fdd,$0f7c
	dc.w	$0f1d,$0ebf,$0e62,$0e06,$0dab,$0d51,$0cf8,$0ca1
	dc.w	$0c4a,$0bf5,$0ba0,$0b4d,$0afb,$0aaa,$0a5a,$0a0c
	dc.w	$09be,$0972,$0927,$08dd,$0894,$084c,$0805,$07c0
	dc.w	$077b,$0738,$06f6,$06b5,$0676,$0637,$05fa,$05be
	dc.w	$0583,$0549,$0511,$04d9,$04a3,$046e,$043a,$0407
	dc.w	$03d6,$03a6,$0377,$0349,$031c,$02f1,$02c6,$029d
	dc.w	$0276,$024f,$022a,$0205,$01e2,$01c1,$01a0,$0181
	dc.w	$0163,$0146,$012a,$0110,$00f6,$00de,$00c8,$00b2
	dc.w	$009e,$008b,$0079,$0068,$0059,$004b,$003e,$0032
	dc.w	$0027,$001e,$0016,$000f,$000a,$0006,$0002,$0001
	dc.w	$0000,$0001,$0002,$0006,$000a,$000f,$0016,$001e
	dc.w	$0027,$0032,$003e,$004b,$0059,$0068,$0079,$008b
	dc.w	$009e,$00b2,$00c8,$00de,$00f6,$0110,$012a,$0146
	dc.w	$0163,$0181,$01a0,$01c1,$01e2,$0205,$022a,$024f
	dc.w	$0276,$029d,$02c6,$02f1,$031c,$0349,$0377,$03a6
	dc.w	$03d6,$0407,$043a,$046e,$04a3,$04d9,$0511,$0549
	dc.w	$0583,$05be,$05fa,$0637,$0676,$06b5,$06f6,$0738
	dc.w	$077b,$07c0,$0805,$084c,$0894,$08dd,$0927,$0972
	dc.w	$09be,$0a0c,$0a5a,$0aaa,$0afb,$0b4d,$0ba0,$0bf5
	dc.w	$0c4a,$0ca1,$0cf8,$0d51,$0dab,$0e06,$0e62,$0ebf
	dc.w	$0f1d,$0f7c,$0fdd,$103e,$10a1,$1105,$1169,$11cf
	dc.w	$1236,$129e,$1307,$1371,$13dc,$1448,$14b5,$1523
	dc.w	$1592,$1603,$1674,$16e6,$1759,$17ce,$1843,$18b9
	dc.w	$1930,$19a9,$1a22,$1a9c,$1b17,$1b94,$1c11,$1c8f
	dc.w	$1d0e,$1d8e,$1e0f,$1e91,$1f14,$1f97,$201c,$20a2
	dc.w	$2128,$21b0,$2238,$22c2,$234c,$23d7,$2463,$24f0
	dc.w	$257d,$260c,$269b,$272c,$27bd,$284f,$28e2,$2976
	dc.w	$2a0a,$2aa0,$2b36,$2bcd,$2c65,$2cfd,$2d97,$2e31
	dc.w	$2ecc,$2f68,$3004,$30a2,$3140,$31df,$327e,$331f
	dc.w	$33c0,$3462,$3504,$35a8,$364c,$36f0,$3796,$383c
	dc.w	$38e3,$398a,$3a33,$3adb,$3b85,$3c2f,$3cda,$3d86
	dc.w	$3e32,$3ede,$3f8c,$403a,$40e8,$4198,$4248,$42f8
	dc.w	$43a9,$445b,$450d,$45c0,$4673,$4727,$47db,$4890
	dc.w	$4946,$49fc,$4ab2,$4b69,$4c21,$4cd9,$4d91,$4e4a
	dc.w	$4f04,$4fbe,$5078,$5133,$51ef,$52aa,$5367,$5423
	dc.w	$54e0,$559e,$565c,$571a,$57d9,$5898,$5958,$5a17
	dc.w	$5ad8,$5b98,$5c59,$5d1a,$5ddc,$5e9e,$5f60,$6023
	dc.w	$60e6,$61a9,$626c,$6330,$63f4,$64b8,$657d,$6642
	dc.w	$6707,$67cc,$6892,$6958,$6a1e,$6ae4,$6baa,$6c71
	dc.w	$6d38,$6dfe,$6ec6,$6f8d,$7054,$711c,$71e4,$72ac
	dc.w	$7374,$743c,$7504,$75cd,$7695,$775e,$7826,$78ef
	dc.w	$79b8,$7a81,$7b49,$7c12,$7cdb,$7da4,$7e6d,$7f36




print	move.l	screen.mem(pc),a1	d0 = x, d1 = y
	mulu	#3*44,d1		a0 = text ending with 0
	add.l	d1,a1
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
	move.b	d1,44(a2)		bitplane 2
	move.b	d1,88(a2)		bitplane 3

	lea	3*44(a2),a2		next screen line
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




make.hex
	lea	hex.text(pc),a0		d0.l = number
	lea	hex.digits(pc),a1
	moveq	#0,d1

make.hex.loop
	rol.l	#4,d0
	move.w	d0,d2
	and.w	#$f,d2
	move.b	(a1,d2.w),(a0,d1.w)
	addq.w	#1,d1
	cmp.w	#8,d1
	bne.s	make.hex.loop
	rts



hex.digits
	dc.b	'0123456789ABCDEF'



hex.text
	ds.b	9
	even




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
	move.l	screen1(pc),d0		show screen1
	move.l	screen2(pc),screen1	fill screen2
	move.l	d0,screen2

set.copper
	add.l	#201*64+10,d0
	lea	copper.list(pc),a0
	moveq	#3-1,d1
	move.l	#64*269,d2		size of one bitplane

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

copper.list
	dc.w	bpl1pth,0		3 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0

	dc.w	$180,0
copper.colours
	dc.w	$182,0
	dc.w	$184,0
	dc.w	$186,0
	dc.w	$188,0
	dc.w	$18a,0
	dc.w	$18c,0

	dc.w	$18e,0

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$3201,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe




;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

screen.mem	dc.l	0
lines.bitplane1	dc.l	0
lines.bitplane2	dc.l	0
lines.bitplane3	dc.l	0
screen1	dc.l	0
screen2	dc.l	0

gfxbase		dc.l	0
old.ints	dc.w	0
old.level3	dc.l	0
next.frame	dc.b	0,0




;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

graf.name	dc.b	'graphics.library',0
		even




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
