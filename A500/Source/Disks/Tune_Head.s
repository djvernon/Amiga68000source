
;	Disassembly of Carrier Command boot sectors


drive.number	equ	$1f6
head.position	equ	$1f8
top.head	equ	$1fa
drive.select.status	equ	$1fc




start	clr.w	(drive.number).w	use drive 0
	st	(head.position).w	make head position invalid
	clr.w	(top.head).w		use bottom head

	bsr.s	init.drive

	move.w	#7000,delay
	moveq	#79,d0
	bsr.s	set.head.position

	move.w	#3500,delay
	moveq	#0,d0
	bsr.s	set.head.position

	moveq	#0,d0
	rts



* set the disk drive up, check it is ready to load

init.drive
	lea	$bfd100,a4
	move.l	#$55555555,d5
	move.w	(drive.number).w,d2
	moveq	#0,d3
	addq.w	#3,d2
	bset	d2,d3			set bit for chosen drive

	move.w	(top.head).w,d2		set chosen head
	beq.s	correct.head
	bset	#2,d3			select top head

correct.head
	move.b	d3,(drive.select.status).w
	move.b	#$7f,(a4)		no drive selected, motor on
	or.b	#$80,d3			motor on
	not.b	d3
	move.b	d3,(a4)			select drive and head, turn motor on,
;					outward direction, diskstep high
	move.w	#$c000,d2
drive.not.ready
	mulu	d2,d4
	mulu	d2,d4
	btst	#5,$f01(a4)		disk ready ?
	dbeq	d2,drive.not.ready	no

	bne.s	set.false		if drive not ready
	moveq	#0,d4
	rts




set.false
	moveq	#-1,d4
	rts



* set the disk drive head to the correct track

set.head.position			; d0 = track
	move.w	d0,d6			first move head to track 0
	tst.w	(head.position).w
	bpl.s	head.position.valid

	bsr.s	head.to.track0		move to track 0 if position unknown

head.position.valid
	sub.w	(head.position).w,d6
	beq.s	step.return		if head is in required position

	add.w	d6,(head.position).w	new head position
	move.w	d6,d0
	bpl.s	step.inwards

	neg.w	d0			make step amount positive

step.outwards
	move.b	(drive.select.status).w,d1
	or.b	#$80,d1			motor on, outward direction
	bra.s	step.values

step.inwards
	move.b	(drive.select.status).w,d1
	or.b	#$82,d1			motor on, inward direction

step.values
	move.b	d1,d2
	or.b	#1,d2			diskstep low
	not.b	d1
	not.b	d2

	subq.w	#1,d0			1 less for dbra

step.head
	move.b	d2,(a4)			set diskstep low  -  move head

	move.b	d1,(a4)			set diskstep back to high

	move.w	delay(pc),d3
step.delay
	dbra	d3,step.delay

	dbra	d0,step.head		step head by required amount
step.return
	rts




head.to.track0
	btst	#4,$f01(a4)		is drive at track 00 ?
	beq.s	at.track0

	moveq	#1,d0			step head by one track
	bsr.s	step.outwards
	bra.s	head.to.track0

at.track0
	clr.w	(head.position).w	head is at track 0
	rts




* turn all disk drive motors off

drives.off
	move.b	#$ff,(a4)		no drive selected, motor off
	move.b	#$bf,(a4)		drive 3 motor off
	move.b	#$df,(a4)		drive 2 motor off
	move.b	#$ef,(a4)		drive 1 motor off
	move.b	#$f7,(a4)		drive 0 motor off
	move.b	#$ff,(a4)		no drive selected, motor off
	rts

delay	dc.w	0
