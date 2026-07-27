	section	load_sw,code_f

	move.l	#main,$80.w
	trap	#0

main	lea	$80000,sp
	move.w	#$7fff,$dff09a
	move.w	#$7fff,$dff096

	lea	copper(pc),a0
	lea	$2da.w,a1
	move.w	#15-1,d0
copy	move.l	(a0)+,(a1)+
	dbra	d0,copy

	bsr	init.drive
	bsr	set.screen

	moveq	#2,d0
	bsr	position.head

	lea	$20000,a0
	moveq	#6,d0
	bsr	read.data
	bsr	set.colours

	lea	$3ffe0,sp
	moveq	#10,d0
	bsr	position.head

	lea	$3ffe0,a0
	moveq	#46,d0
	bsr	read.data

	move.b	#$fd,$bfd100
	move.b	#$e7,$bfd100
	jmp	$68408

copper	dc.w	$100,$4200,$102,0
	dc.w	$92,$38,$94,$d0
	dc.w	$8e,$2c81,$90,$f4c1
	dc.w	$e0,2,$e2,0
	dc.w	$e4,2,$e6,8000
	dc.w	$e8,2,$ea,16000
	dc.w	$ec,2,$ee,24000
	dc.w	$ffff,$fffe

init.drive
	lea	$dff000,a4
	clr.w	$8000
	move.b	#$79,$bfd100
	move.b	#$73,$bfd100
	bsr	delay
not.track0
	btst	#4,$bfe001
	beq.s	at.track

	bclr	#0,$bfd100
	bset	#0,$bfd100
	bsr	delay
	bra.s	not.track0

position.head
	lea	$dff000,a4
	move.w	$8000,d1
	move.w	d0,$8000
	sub.w	d1,d0
	asr.w	#1,d0
	beq.s	at.track
	bmi.s	outwards

	bclr	#1,$bfd100
step	bclr	#0,$bfd100
	bset	#0,$bfd100
	bsr.s	delay
	subq.w	#1,d0
	bne.s	step

at.track
	bset	#2,$bfd100
	btst	#0,$8001
	bne.s	side.ok

	bclr	#2,$bfd100
side.ok	rts

outwards
	neg.w	d0
	bset	#1,$bfd100
	bra.s	step

read.data
	lea	$dff000,a4
	move.b	#$79,$bfd100
	move.b	#$73,$bfd100
	movem.l	d0/d7/a0,-(sp)
	subq.w	#1,d0
	move.w	#$8210,$96(a4)
	bsr.s	delay
.loop	bsr.s	read
	bsr	next.track
	dbra	d0,.loop

	bsr.s	drive.off
	movem.l	(sp)+,d0/d7/a0
	move.w	#$0010,$96(a4)
	rts

delay	move.w	#$1000,d7
.delay	dbra	d7,.delay
	rts

read	move.w	#$0002,$9c(a4)
	move.l	#$8004,$20(a4)
	move.w	#$4489,$7e(a4)
	move.w	#$7f00,$9e(a4)
	move.w	#$8500,$9e(a4)
	move.w	#$4000,$24(a4)
	move.w	#$9616,$24(a4)
	move.w	#$9616,$24(a4)
read.wait
	move.w	$1e(a4),d1
	btst	#1,d1
	beq.s	read.wait

	move.w	#$4000,$24(a4)
	move.l	a0,-(sp)
	bsr.s	decode.data
	beq.s	read.done

	move.l	(sp)+,a0
	bra.s	read

read.done
	addq.w	#4,sp
	rts

drive.off
	bsr.s	delay
	bsr.s	drive.wait
	move.b	#$f9,$bfd100
	move.b	#$f1,$bfd100
	bsr.s	delay
	rts

drive.wait
	btst	#5,$bfe001
	bne.s	drive.wait
	rts

decode.data
	move.l	#$8004,a1
	cmp.l	#$55555555,2(a1)
	beq.s	found.start
	subq.w	#2,a1
	cmp.l	#$55555555,2(a1)
	beq.s	found.start
	rts

found.start
	addq.w	#6,a1
	moveq	#0,d3
	move.w	#1408-1,d4
.decode	move.l	(a1)+,d1
	move.l	(a1)+,d2
	and.l	#$55555555,d1
	and.l	#$55555555,d2
	add.l	d1,d1
	or.l	d1,d2
	move.l	d2,(a0)+
	add.l	d2,d3
	dbra	d4,.decode

	move.l	(a1)+,d1
	move.l	(a1)+,d2
	and.l	#$55555555,d1
	and.l	#$55555555,d2
	add.l	d1,d1
	or.l	d1,d2
	cmp.l	d2,d3
	rts

next.track
	bset	#2,$bfd100
	bchg	#0,$8001
	bne.s	side.ok2

	bclr	#2,$bfd100
	addq.w	#2,$8000
	bclr	#1,$bfd100
	bclr	#0,$bfd100
	bset	#0,$bfd100
	bsr	delay
side.ok2
	rts

set.colours
	movem.l	$20000+32000,d0-d7
	movem.l	d0-d7,$180(a4)
	move.w	#$8380,$96(a4)
	rts

set.screen
	lea	$dff000,a0
	move.l	#$2da,$80(a0)
	move.w	d0,$88(a0)
	lea	$180(a0),a0
	moveq	#8-1,d0
	move.l	#$00200020,d1
colours	move.l	d1,(a0)+
	dbra	d0,colours
	rts
