
;	Read all 160 tracks from DOS disk in drive 0
;	Order tracks are read:-
;		Bottom side, outer to inner, tracks 0,2, ... 158
;		Top side, outer to inner, tracks 1,3, ... 159
;
;	Track details are written starting at location $60000
;	Following details are written per sector:-
;		long - info (byte $ff, byte track, byte sector, byte sectors to gap)
;		4 zero bytes

;	Based on disassembly of Carrier Command boot sectors


load.attempts	equ	$1f4
drive.number	equ	$1f6
head.position	equ	$1f8
top.head	equ	$1fa
drive.select.status	equ	$1fc

custom	equ	$dff000

potgor	equ   $016
intreqr	equ   $01E
dskpth	equ   $020
dsklen	equ   $024
potgo	equ   $034
dsksync	equ   $07E
cop1lc	equ   $080
copjmp1	equ   $088
diwstrt	equ   $08E
diwstop	equ   $090
ddfstrt	equ   $092
ddfstop	equ   $094
dmacon	equ   $096
intena	equ   $09A
intreq	equ   $09C
adkcon	equ   $09E
bpl1pth	equ   $0E0
bpl1ptl	equ   $0E2
bpl2pth	equ   $0E4
bpl2ptl	equ   $0E6
bpl3pth	equ   $0E8
bpl3ptl	equ   $0EA
bpl4pth	equ   $0EC
bpl4ptl	equ   $0EE
bplcon0	equ   $100
bplcon1	equ   $102
bpl1mod	equ   $108
bpl2mod	equ   $10A
color0	equ   $180


	lea	start(pc),a0
	move.l	a0,$80			into exception vector table
	trap	#0			execute our code


start	move.w	#$2700,sr		supervisor mode, no interrupts
	lea	$77400,a7		stack pointer
	lea	custom,a6		base of custom chips
	move.w	#$7fff,d0
	move.w	d0,dmacon(a6)		disable all DMA
	move.w	d0,intena(a6)		disable all interrupts
	lea	main(pc),a0		source
	lea	$76c00,a1		destination
	move.w	#256,d0			1024 bytes
copy.loop
	move.l	(a0)+,(a1)+
	dbra	d0,copy.loop
	jmp	$76c00			jump to main code


main	clr.w	(drive.number).w	use drive 0
	st	(head.position).w	make head position invalid

	moveq	#0,d0
	moveq	#7,d1			clear 8 longwords - 16 colours
	lea	color0(a6),a0
clear.loop
	move.l	d0,(a0)+		clear 2 colours
	dbra	d1,clear.loop

	move.w	#$4200,bplcon0(a6)	4 bitplane, 320*200 display
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	move.w	#$2c81,diwstrt(a6)
	move.w	#$f4c1,diwstop(a6)
	clr.w	bplcon1(a6)		no scrolling
	moveq	#120,d0
	move.w	d0,bpl1mod(a6)		modulo = 120 bytes
	move.w	d0,bpl2mod(a6)		modulo = 120 bytes
	lea	copper(pc),a0
	move.l	a0,cop1lc(a6)		set up new copper list
	move.w	d0,copjmp1(a6)		activate it
	move.w	#$8390,dmacon(a6)	set dmaen, bplen, copen, dsken

;	move.w	#$c00,potgo(a6)		game port 0 poty to output
;	btst.b	#6,$bfe001		left mouse button
;	beq.s	backup
;	btst.b	#2,potgor(a6)		right mouse button
;	beq.s	backup


;load.screen
;	moveq	#2,d0			start at track 2
;	moveq	#7,d1			7 tracks
;	lea	$77400,a0
;	bsr.s	load
;	bmi.s	load.screen
;	lea	$7f100,a0
;	lea	color0(a6),a1
;	moveq	#7,d0
;next.col	move.l	(a0)+,(a1)+
;	dbra	d0,next.col


	lea	$60000,a0

read.bottom.side
	clr.w	(top.head).w		use bottom head
	moveq	#0,d0			start at cylinder 0
	moveq	#80,d1			80 tracks
	bsr.s	load
	bmi.s	read.bottom.side

read.top.side
	move.w	#1,(top.head).w		use top head
	moveq	#0,d0			start at cylinder 0
	moveq	#80,d1			80 tracks
	bsr.s	load
	bmi.s	read.top.side

end	nop
	bra	end




;backup	moveq	#1,d0			start at track 1
;	moveq	#1,d1			1 track
;	lea	$400.w,a0
;	bsr.s	load
;	bmi.s	backup
;	jmp	$800.w




***************
* Subroutines *
***************


* load routine  -  d0 = start track, d1 = number of tracks to read

load	subq.w	#1,d1			1 less for dbra
	bmi.s	no.tracks

	bsr.s	init.drive
	bmi.s	load.finished

load.loop
	move.w	#2,(load.attempts).w

load.now
	movem.w	d0/d1,-(a7)		save track and count
	move.l	a0,-(a7)		save destination pointer

	bsr	set.head.position
	bsr	read.data
	bmi.s	load.bad

	move.l	a0,a5			destination pointer
	bsr	decode.DOS.data
	bmi.s	load.bad

	move.l	a5,a0			new destination pointer
	addq.w	#4,a7
	movem.w	(a7)+,d0/d1		get track and count
	addq.w	#1,d0			next track
	dbra	d1,load.loop

no.tracks
	moveq	#0,d4

load.finished
	bsr	drives.off
	tst.w	d4
	rts




load.bad
	move.l	(a7)+,a0		destination pointer
	movem.w	(a7)+,d0/d1
	subq.w	#1,(load.attempts).w
	bmi.s	load.finished

	bne.s	load.now		if zero then position head again

	st	(head.position).w	make head position invalid
	bra.s	load.now




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

	bne	set.false		if drive not ready
	moveq	#0,d4
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

	move.w	#1200,d3
step.delay
	mulu	d3,d4
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




* read the data from the disk drive

read.data
	move.w	#$4000,dsklen(a6)	DMAEN off
	move.w	#$0002,intreq(a6)	disk DMA transfer done
	move.l	#$73800,dskpth(a6)	destination
	move.w	#$6800,adkcon(a6)	zero precomp time, clear UARTBRK
	move.w	#$9500,adkcon(a6)	MFM, WORDSYNC, FAST=1 (MFM)
	move.w	#$4489,dsksync(a6)
	move.w	#6560!$8000,dsklen(a6)	DMAEN on, 6560 words of data
	move.w	#6560!$8000,dsklen(a6)	write the same value again

	moveq	#-1,d0

read.wait
	mulu	d0,d4
	btst	#1,intreqr+1(a6)	disk DMA transfer done ?
	dbne	d0,read.wait

	beq.s	read.bad

	move.w	#$4000,dsklen(a6)
	moveq	#0,d4
	rts




read.bad
	move.w	#$4000,dsklen(a6)

set.false
	moveq	#-1,d4
	rts




* various routines to decode the data from the disk drive

decode.DOS.data				; a5 = destination
	moveq	#11-1,d7
	lea	$73800,a2		source

skip.sync
	cmp.w	#$4489,(a2)		sync value
	bne.s	decode.block
	addq.w	#2,a2			skip sync value

decode.block
	lea	40(a2),a0
	bsr	decode.block.header	header checksum
	move.l	d0,d6

	move.l	a2,a0
	moveq	#40/4,d1		number of longwords
	bsr.s	calc.checksum

	cmp.l	d0,d6
	bne.s	set.false		if checksums do not agree

	move.l	a2,a0
	bsr.s	decode.block.header
	move.l	d0,(a5)+	dvinfo
	move.w	d0,d3
	swap	d0
	moveq	#-1,d1			for DOS format identification
	move.b	(head.position+1).w,d1
	add.b	d1,d1
	add.b	(top.head+1).w,d1	track number
	cmp.w	d0,d1				check for $ff TN
	bne.s	set.false

* sector number not validated
* sectors before track gap not validated

	lea	48(a2),a0
	bsr.s	decode.block.header
	move.l	d0,d6			data checksum

	lea	56(a2),a0		start of data
	move.w	#1024/4,d1		number of longwords
	bsr.s	calc.checksum

	cmp.l	d0,d6
	bne.s	set.false		if checksums do not agree

* use sector number to calculate destination

	lea	56(a2),a0		start of data
	move.w	#512,d0		number of output bytes
;	bsr.s	decode.block.data

	cmp.b	#1,d3			check sectors before track gap
	beq.s	skip.gap

* point to start of next block, after sync markers
* (assumes there are always two sync markers)
	lea	64+1024(a2),a2
	dbra	d7,decode.block
	bra.s	decode.done

* if sectors before gap = 1 then search past next sync marker
* (there may be one or two sync markers)
* maybe shouldn't do this if last sector
skip.gap
	lea	56+1024(a2),a2		end of block
.skip	cmp.w	#$4489,(a2)+		sync value
	bne.s	.skip
	dbra	d7,skip.sync

decode.done
	lea	4(a5),a5	dvinfo zero bytes
	moveq	#0,d4
	rts       




calc.checksum
	move.l	(a0)+,d0		get first longword
	subq.w	#2,d1			count

.loop	move.l	(a0)+,d2		get next longword
	eor.l	d2,d0			and attach
	dbra	d1,.loop

	and.l	d5,d0			remove invalid bits
	rts




decode.block.header
	move.l	(a0)+,d0		get first longword
	move.l	(a0)+,d1		get second longword
	and.l	d5,d0			remove clock bits
	and.l	d5,d1			remove clock bits
	add.l	d0,d0			shift odd bits
	or.l	d1,d0			combine to give longword result
	rts




decode.block.data
	lea	(a0,d0.w),a1
	lsr.w	#2,d0			number of output longwords
	subq.w	#1,d0			count

.loop	move.l	(a0)+,d1		get first longword
	move.l	(a1)+,d2		get second longword
	and.l	d5,d1			remove clock bits
	and.l	d5,d2			remove clock bits
	add.l	d1,d1			shift odd bits
	or.l	d2,d1			combine to give longword result
	move.l	d1,(a5)+		save longword
	dbra	d0,.loop
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




****************************************
* The copper list for the title screen *
****************************************

copper	dc.w	bpl4pth,$0007
	dc.w	bpl4ptl,$7478
	dc.w	bpl3pth,$0007
	dc.w	bpl3ptl,$7450
	dc.w	bpl2pth,$0007
	dc.w	bpl2ptl,$7428
	dc.w	bpl1pth,$0007
	dc.w	bpl1ptl,$7400
	dc.w	$ffff,$fffe
