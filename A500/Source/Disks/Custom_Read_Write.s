	section	ReadWrite,code_c
	opt	o+




* Print 'Insert Destination Disk, Press Mouse Button When Ready'

	bsr.s	wait.mouse


write.bottom.side

* Print 'Writing Destination Disk'

	clr.w	drive.number		use drive 0
	clr.w	top.head		use bottom head

	moveq	#1,d0			start at track 1
	moveq	#3,d1			3 tracks
	lea	program.data(pc),a0	source
	bsr	save
	bpl.s	bottom.side.written


bottom.side.not.written

* Print 'Error Writing Destination Disk, Press Mouse Button To Try Again'

	bsr.s	wait.mouse

	bra.s	write.bottom.side


bottom.side.written

* Print 'Process Complete, Reset Computer To Load Program'

make.disk.end
	bra.s	make.disk.end




wait.mouse
	btst	#6,$bfe001
	beq.s	mouse.pressed

	btst	#2,potgor(a6)
	bne.s	wait.mouse

mouse.pressed
	rts




* Disk load and save routines


init.drive
	lea	$bfd100,a4
	move.l	#$55555555,d5
	move.w	drive.number,d2
	moveq	#0,d3
	addq.w	#3,d2
	bset	d2,d3			set bit for chosen drive

	move.w	top.head,d2		set chosen head
	beq.s	correct.head
	bset	#2,d3			select top head

correct.head
	move.b	d3,drive.select.status
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




set.head.position			; d0 = track
	move.w	d0,d6
	tst.w	head.position
	bpl.s	head.position.valid

	bsr.s	head.to.track0		move to track 0 if position unknown

head.position.valid
	sub.w	head.position,d6
	beq.s	step.return		if head is in required position

	add.w	d6,head.position	new head position
	move.w	d6,d0
	bpl.s	step.inwards

	neg.w	d0			make step amount positive

step.outwards
	move.b	drive.select.status,d1
	or.b	#$80,d1			motor on, outward direction
	bra.s	step.values

step.inwards
	move.b	drive.select.status,d1
	or.b	#$82,d1			motor on, inward direction

step.values
	move.b	d1,d2
	or.b	#1,d2			diskstep low
	not.b	d1
	not.b	d2

	subq.w	#1,d0			1 less for dbra

step.head
	move.b	d2,(a4)			set diskstep low - move head

	move.b	d1,(a4)			set diskstep back to high

	move.w	#1200,d3
step.delay
	mulu	d3,d4
	dbra	d3,step.delay

	dbra	d0,step.head		step head by required amount
step.return
	rts




head.to.track0
	btst	#4,$f01(a4)		is drive at track 0 ?
	beq.s	at.track0

	moveq	#1,d0			step head by one track
	bsr.s	step.outwards
	bra.s	head.to.track0

at.track0
	clr.w	head.position		head is at track 0
	rts




* load routine  -  d0 = start track, d1 = number of tracks to read
*		   a0 = destination

load	subq.w	#1,d1			1 less for dbra
	bmi.s	no.tracks

	bsr	init.drive
	bmi.s	load.finished

load.loop
	move.w	#2,load.save.attempts

load.now
	movem.w	d0/d1,-(sp)		save track and count
	move.l	a0,-(sp)		save destination pointer

	bsr	set.head.position

	bsr.s	read.track
	bmi.s	load.bad

	move.l	a0,a5			destination pointer
	bsr	decode.custom.track
	bmi.s	load.bad

	move.l	a5,a0			new destination pointer
	addq.w	#4,sp
	movem.w	(sp)+,d0/d1		get track and count
	addq.w	#1,d0			next track
	dbra	d1,load.loop

no.tracks
	moveq	#0,d4

load.finished
	bsr	drives.off
	tst.w	d4
	rts




load.bad
	move.l	(sp)+,a0		destination pointer
	movem.w	(sp)+,d0/d1		get track and count
	subq.w	#1,load.save.attempts
	bmi.s	load.finished

	bne.s	load.now		if zero then position head again

	st	head.position		make head position invalid
	bra.s	load.now




read.track
	move.w	#$4000,dsklen(a6)	DMAEN off
	move.w	#$0002,intreq(a6)	disk DMA transfer done
	move.l	#track.data,dskpth(a6)	destination
	move.w	#$6800,adkcon(a6)	zero precomp time, clear UARTBRK
	move.w	#$9500,adkcon(a6)	MFM, WORDSYNC, FAST=1 (MFM)
	move.w	#$4489,dsksync(a6)
	move.w	#6020!$8000,dsklen(a6)	DMAEN on, 6020 words of data
	move.w	#6020!$8000,dsklen(a6)	write the same value again

read.wait
	moveq	#-1,d0

.loop	mulu	d0,d4
	btst	#1,intreqr+1(a6)	disk DMA transfer done ?
	dbne	d0,.loop

	beq.s	read.bad

	move.w	#$4000,dsklen(a6)
	moveq	#0,d4
	rts




read.bad
	move.w	#$4000,dsklen(a6)

set.false
	moveq	#-1,d4
	rts




* save routine  -  d0 = start track, d1 = number of tracks to write
*		   a0 = source

save	subq.w	#1,d1			1 less for dbra
	bmi.s	no.tracks2

	bsr	init.drive
	bmi.s	save.finished

	st	head.position		make head position invalid

save.loop
	move.w	#2,load.save.attempts

save.now
	movem.w	d0/d1,-(sp)		save track and count

	bsr	set.head.position

	cmp.w	#2,load.save.attempts
	bne.s	not.first.attempt	no need to code the data again

	move.l	a0,a5			source pointer
	bsr.s	code.custom.track
	move.l	a5,a0			new source pointer

not.first.attempt
	bsr.s	write.track
	bmi.s	save.bad

	move.w	#16000,d0

save.delay
	move.w	#$aaaa,d1
	mulu	d1,d1
	dbra	d0,save.delay

	movem.w	(sp)+,d0-d1		get track and count
	addq.w	#1,d0			next track
	dbra	d1,save.loop

no.tracks2
	moveq	#0,d4

save.finished
	bsr	drives.off
	tst.w	d4
	rts




save.bad
	movem.w	(sp)+,d0/d1		get track and count
	subq.w	#1,load.save.attempts
	bmi.s	save.finished

	bne.s	save.now		if zero then position head again

	st	head.position		make head position invalid
	bra.s	save.now




write.track
	btst	#3,$f01(a4)
	beq.s	set.false		if disk is write protected

	btst	#5,$f01(a4)
	bne.s	set.false		if drive is not ready

	move.w	#$4000,dsklen(a6)	DMAEN off
	move.w	#$0002,intreq(a6)	disk DMA transfer done
	move.l	#track.data,dskpth(a6)	source
	move.w	#$6e00,adkcon(a6)	zero precomp time, clear UARTBRK
;					clear WORDSYNC and MSBSYNC
	move.w	#$9100,adkcon(a6)	MFM, FAST=1 (MFM)
	move.w	#6560!$c000,dsklen(a6)	DMAEN on, WRITE, 6560 words of data
	move.w	#6560!$c000,dsklen(a6)	write the same value again

	bra	read.wait




code.custom.track			; a5 = source
	lea	track.data(pc),a2	destination
	move.w	#6560/2-1,d0
	move.l	#$aaaaaaaa,d1

.loop	move.l	d1,(a2)+		save data for track gap
	dbra	d0,.loop

	lea	track.data+1080(pc),a2
	move.l	#$44894489,4(a2)	two sync markers

	moveq	#-1,d0
	move.b	head.position+1,d0
	add.b	d0,d0
	add.b	top.head+1,d0		track number

	lea	8(a2),a0
	bsr	code.longword		code track information

	move.l	a5,a0			source
	lea	24(a2),a1		destination
	bsr	blit.code.6000.bytes

	lea	24+12000(a2),a0
	bsr	correct.current.byte

	lea	24(a2),a0
	move.w	#12000/4,d1		number of longwords
	bsr.s	calculate.checksum

	lea	16(a2),a0
	bsr	code.longword		code data checksum

	lea	6000(a5),a5		update source pointer
	rts




decode.custom.track			; a5 = destination
	lea	track.data,a2		source
	cmp.w	#$4489,(a2)		sync value
	bne.s	no.sync.value

	addq.w	#2,a2			skip second sync value

no.sync.value
	move.l	a2,a0
	bsr.s	decode.longword
	move.b	head.position+1,d1
	add.b	d1,d1
	add.b	top.head+1,d1		track number
	cmp.b	d0,d1
	bne	set.false

	lea	8(a2),a0
	bsr.s	decode.longword
	move.l	d0,d7			data checksum

	lea	16(a2),a0		start of data
	move.w	#12000/4,d1		number of longwords
	bsr.s	calculate.checksum

	cmp.l	d0,d7
	bne	set.false		if checksums do not agree

	lea	16(a2),a0		start of data
	move.w	#6000,d0		number of output bytes
	bsr.s	decode.data

	moveq	#0,d4
	rts




calculate.checksum
	move.l	(a0)+,d0		get first longword
	subq.w	#2,d1			count

.loop	move.l	(a0)+,d2		get next longword
	eor.l	d2,d0			and attach
	dbra	d1,.loop

	and.l	d5,d0			remove invalid bits
	rts




decode.longword
	move.l	(a0)+,d0		get first longword
	move.l	(a0)+,d1		get second longword
	and.l	d5,d0			remove clock bits
	and.l	d5,d1			remove clock bits
	add.l	d0,d0			shift odd bits
	or.l	d1,d0			combine to give longword result
	rts




decode.data
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




code.longword				; d0 = longword
	move.l	d0,d3
	lsr.l	#1,d0
	bsr.s	code.bits		code odd bits

	move.l	d3,d0
	bsr.s	code.bits		code even bits

correct.current.byte
	move.b	(a0),d0			get next byte
	bclr	#7,d0			reset clock bit

	btst	#6,d0
	bne.s	byte.correct

	btst	#0,-1(a0)
	bne.s	byte.correct

	bset	#7,d0			set clock bit if adjacent bits clear

byte.correct
	move.b	d0,(a0)			save byte
	rts




code.bits
	and.l	d5,d0			remove unwanted bits
	move.l	d0,d2
	eor.l	d5,d2			determine clock bits
	move.l	d2,d1
	add.l	d2,d2			shift left once
	lsr.l	#1,d1			shift right once
	bset	#31,d1			set first bit
	and.l	d2,d1			determine clock bits
	or.l	d1,d0			set clock bits
	btst	#0,-1(a0)
	beq.s	bits.ok			if previous byte ended with a 0 bit

	bclr	#31,d0			reset first bit

bits.ok	move.l	d0,(a0)+		save longword result
	rts




blit.code.6000.bytes			; codes 6000 bytes into 12000 bytes
	move.l	a1,a3			; a0 = source, a1 = destination
	moveq	#-1,d1

bltfin	btst	#6,dmaconr(a6)
	bne.s	bltfin

	move.l	d1,bltafwm(a6)
	moveq	#0,d1
	move.l	d1,bltbmod(a6)
	move.w	d1,bltdmod(a6)
	move.w	d5,bltcdat(a6)
	move.l	a0,bltbpth(a6)		source
	move.l	a0,bltapth(a6)		source
	move.l	a3,bltdpth(a6)		destination
	move.w	#$1de4,bltcon0(a6)	USE A,B,D	D = A.C + B.notC
;					A shifted right one position
	move.w	d1,bltcon1(a6)
	move.w	#(6000/60)*64+30,d2	width of 60 bytes
	move.w	d2,bltsize(a6)

	lea	6000-2(a0),a0		to end of source
	lea	12000-2(a3),a1		to end of destination

bltfin2	btst	#6,dmaconr(a6)
	bne.s	bltfin2

	move.l	a0,bltbpth(a6)
	move.l	a0,bltapth(a6)
	move.l	a1,bltdpth(a6)
	move.l	#$0de41002,bltcon0(a6)	USE A,B,D	D = A.C + B.notC
;					B shifted left one position (DESC)
	move.w	d2,bltsize(a6)

bltfin3	btst	#6,dmaconr(a6)
	bne.s	bltfin3

	move.l	a3,bltbpth(a6)
	move.l	a3,bltapth(a6)
	move.l	a3,bltdpth(a6)
	move.w	#$1d89,bltcon0(a6)	USE A,B,D    D = B.C + notA.notB.notC
;					A shifted right one position
	move.w	d1,bltcon1(a6)
	add.w	#30,d2			do twice as many bytes
	move.w	d2,bltsize(a6)

bltfin4	btst	#6,dmaconr(a6)
	bne.s	bltfin4
	rts




* turn all disk drive motors off

drives.off
	move.b	#$ff,(a4)
	move.b	#$bf,(a4)
	move.b	#$df,(a4)
	move.b	#$ef,(a4)
	move.b	#$f7,(a4)
	move.b	#$ff,(a4)
	rts




program.data	;incbin	ram:x		data to be written to disk

track.data	ds.w	6560

load.save.attempts	dc.w	0
drive.number	dc.w	0
head.position	dc.w	0
top.head	dc.w	0
drive.select.status	dc.b	0,0




dmaconr	equ	$002
potgor	equ	$016
intreqr	equ	$01E
dskpth	equ	$020
dsklen	equ	$024
potgo	equ	$034
bltcon0	equ	$040
bltcon1	equ	$042
bltafwm	equ	$044
bltalwm	equ	$046
bltcpth	equ	$048
bltcptl	equ	$04A
bltbpth	equ	$04C
bltbptl	equ	$04E
bltapth	equ	$050
bltaptl	equ	$052
bltdpth	equ	$054
bltdptl	equ	$056
bltsize	equ	$058
bltcmod	equ	$060
bltbmod	equ	$062
bltamod	equ	$064
bltdmod	equ	$066
bltcdat	equ	$070
bltbdat	equ	$072
bltadat	equ	$074
dsksync	equ	$07E
cop1lch	equ	$080
copjmp1	equ	$088
diwstrt	equ	$08E
diwstop	equ	$090
ddfstrt	equ	$092
ddfstop	equ	$094
dmacon	equ	$096
intena	equ	$09A
intreq	equ	$09C
adkcon	equ	$09E
bpl1pth	equ	$0E0
bpl1ptl	equ	$0E2
bpl2pth	equ	$0E4
bpl2ptl	equ	$0E6
bpl3pth	equ	$0E8
bpl3ptl	equ	$0EA
bpl4pth	equ	$0EC
bpl4ptl	equ	$0EE
bplcon0	equ	$100
bplcon1	equ	$102
bplcon2	equ	$104
bpl1mod	equ	$108
bpl2mod	equ	$10A
color0	equ	$180
