	lea	alert.text1+4(pc),a0
	cmp.w	#'om',(a0)
stop	bne.s	stop

	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#9,28(a1)
	clr.l	36(a1)			turn motor off
	jsr	-456(a6)		DoIO

	cmp.w	#8,62(a6)		top word of MaxLocMem
	bne.s	not.half.meg.chip

	tst.l	78(a6)			MaxExtMem
	beq.s	l000005

not.half.meg.chip
	bsr.s	alert.box1
	beq.s	l000005			if right button pressed

	move.l	4.w,a0
	lea	$fc0000,a5
	move.w	#8700,d0

search	cmp.w	(a5)+,d0
	bne.s	search

	sub.l	a4,a4
	subq.l	#2,a5
	lea	$676.w,a6
	moveq	#4,d0
	swap	d0
	move.l	d0,sp			$40000
	add.l	d0,d0			$80000
	move.l	d0,a3
	bsr	DMA.ints.off
	jmp	-30(a0)

alert.box1
	move.l	4.w,a6
	lea	intname(pc),a1
	jsr	-408(a6)		OldOpenLibrary
	move.l	d0,a6

	moveq	#0,d0			alert number - recoverable alert
	lea	alert.text1(pc),a0	string
	moveq	#98,d1			height
	jsr	-90(a6)			DisplayAlert
	tst.l	d0			test boolean return code
	rts

l000005	move.l	4.w,a6
	moveq	#0,d0
	lea	disk.res.name(pc),a1
	jsr	-498(a6)		OpenResource
	move.l	d0,a6

	moveq	#1,d0
	jsr	-30(a6)
	beq.s	alert.box2

standard.boot.code
	movem.l	(sp)+,d0-d7/a0-a6
	lea	dosname(pc),a1
	jsr	-96(a6)			FindResident
	move.l	d0,a0
	move.l	22(a0),a0
	moveq	#0,d0
	rts

dosname	dc.b	'dos.library',0

disk.res.name
	dc.b	'disk.resource',0

alert.box2
	move.l	4.w,a6
	lea	intname(pc),a1
	jsr	-408(a6)		OldOpenLibrary
	move.l	d0,a6

	moveq	#0,d0
	lea	alert.text2(pc),a0
	moveq	#98,d1
	jsr	-90(a6)
	tst.l	d0
	beq.s	standard.boot.code

	move.l	4.w,a6
	jsr	-150(a6)		SuperState
	lea	$7f000,a1
	lea	cool.capture.code(pc),a0
	move.l	a1,46(a6)		CoolCapture

	moveq	#31,d0
copy.code
	move.l	(a0)+,(a1)+
	dbra	d0,copy.code

	bsr.s	calc.checksum
	jmp	$fc0002

cool.capture.code
	clr.l	46(a6)			clear CoolCapture vector
	lea	init.resident.code(pc),a0
	move.l	-100(a6),76(a0)		store old InitResident address
	move.l	a0,-100(a6)		save new InitResident address

calc.checksum
	lea	34(a6),a0
	clr.w	d0
	moveq	#23,d1
calc	add.w	(a0)+,d0
	dbra	d1,calc
	not.w	d0
	move.w	d0,(a0)
	rts

init.resident.code
	cmp.l	#'disk',26(a1)
	bne.s	l000017

	cmp.l	#'.res',30(a1)
	bne.s	l000017

	movem.l	d0-d7/a0/a2-a5,-(sp)
	lea	intname(pc),a0
	move.l	a0,d0
	move.w	#255,d2

l000015	move.w	(a1)+,d1
	cmp.w	#5,d1
	bne.s	l000016
	addq.w	#1,d1
l000016	move.w	d1,(a0)+
	dbra	d2,l000015

	move.l	-490(a1),a2
	sub.l	a1,a2
	add.l	a0,a2
	move.l	a2,-490(a0)
	move.l	d0,a1
	movem.l	(sp)+,d0-d7/a0/a2-a5
	move.l	l000017+2(pc),-100(a6)	restore old InitResident address
l000017	jmp	0

intname	dc.b	'intuition.library',0

alert.text1
	dc.w	40			x
	dc.b	24			y
	dc.b	'Computerbrains Cracking Service C.C.S. proudly presents  ',0
	dc.b	99			continuation byte

	dc.w	216
	dc.b	40
	dc.b	'CCS-BOOT V2.0',0
	dc.b	99

	dc.w	120
	dc.b	56
	dc.b	'- You have EXTRA MEMORY installed -',0
	dc.b	99

	dc.w	40
	dc.b	72
	dc.b	'Do you want to turn it off?',0
	dc.b	99

	dc.w	16
	dc.b	88
	dc.b	'YES',0
	dc.b	99

	dc.w	608
	dc.b	88
	dc.b	'NO',0
	dc.w	0

alert.text2
	dc.w	40
	dc.b	24
	dc.b	'Computerbrains Cracking Service C.C.S. proudly presents  ',0
	dc.b	99

	dc.w	216
	dc.b	40
	dc.b	'CCS-BOOT V2.0',0
	dc.b	99

	dc.w	120
	dc.b	56
	dc.b	'- You have EXTRA DRIVES installed -',0
	dc.b	99

	dc.w	40
	dc.b	72
	dc.b	'Do you want to turn it off?',0
	dc.b	99

	dc.w	16
	dc.b	88
	dc.b	'YES',0
	dc.b	99

	dc.w	608
	dc.b	88
	dc.b	'NO',0
	dc.w	0

DMA.ints.off
	lea	$dff096,a1
	move.l	#$7fff7fff,d0
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	rts

	dc.b	'This routine was programmed in 100% by PHS of CCS himself !',0
