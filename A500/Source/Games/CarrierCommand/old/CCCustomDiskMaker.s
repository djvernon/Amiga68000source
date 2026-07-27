

 * Create "WinUAE 'Custom Disk' Carrier Command disk *

 * Place a WinUAE 'Custom Disk' format disk into df0:, then run this program *

;	Copied from CCbackup_A1200.s on 26/04/2019


custom	equ	$dff000

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
bpl1mod	equ	$108
bpl2mod	equ	$10A
color0	equ	$180




	lea	start(pc),a0
	move.l	a0,$80.w		into exception vector table
	trap	#0			execute our code


start	move.w	#$2700,sr		supervisor mode, no interrupts
	lea	custom,a6		base of custom chips
	move.w	#$7fff,d0
	move.w	d0,dmacon(a6)		disable all DMA
	move.w	d0,intena(a6)		disable all interrupts

	move.w	#$4200,bplcon0(a6)	4 bitplane, 320*200 display
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	move.w	#$2c81,diwstrt(a6)
	move.w	#$f4c1,diwstop(a6)
	clr.w	bplcon1(a6)		no scrolling
	moveq	#120,d0
	move.w	d0,bpl1mod(a6)		modulo = 120 bytes
	move.w	d0,bpl2mod(a6)		modulo = 120 bytes

	lea	beginning(pc),a0	source
	lea	$400.w,a1		destination
	move.w	#length/4,d0		number of longwords
copy.loop
	move.l	(a0)+,(a1)+
	dbra	d0,copy.loop
	jmp	$800.w			jump to main code




****************
*	       *
* Boot routine *
*	       *
****************

b.load.attempts	equ	$1f4
b.drive.number	equ	$1f6
b.head.position	equ	$1f8
b.top.head	equ	$1fa
b.drive.select.status	equ	$1fc


beginning
	lea	boot.start(pc),a0
	move.l	a0,$80.w		into exception vector table
	trap	#0			execute our code


boot.start
	move.w	#$2700,sr		supervisor mode, no interrupts
	lea	$77400,a7		stack pointer
	lea	custom,a6		base of custom chips
	move.w	#$7fff,d0
	move.w	d0,dmacon(a6)		disable all DMA
	move.w	d0,intena(a6)		disable all interrupts
	lea	boot.main(pc),a0	source
	lea	$76c00,a1		destination
	move.w	#256,d0			1024 bytes
copy.loop2
	move.l	(a0)+,(a1)+
	dbra	d0,copy.loop2
	jmp	$76c00			jump to main code


boot.main
	clr.w	(b.drive.number).w	use drive 0
	st	(b.head.position).w	make head position invalid
	clr.w	(b.top.head).w		use bottom head

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
	move.l	a0,cop1lch(a6)		set up new copper list
	move.w	d0,copjmp1(a6)		activate it
	move.w	#$8390,dmacon(a6)	set dmaen, bplen, copen, dsken

	move.w	#$c00,potgo(a6)		game port 0 poty to output
	btst.b	#6,$bfe001		left mouse button
	beq.s	backup
	btst.b	#2,potgor(a6)		right mouse button
	beq.s	backup


load.screen
	moveq	#2,d0			start at track 2
	moveq	#7,d1			7 tracks
	lea	$77400,a0		destination
	bsr.s	b.load
	bmi.s	load.screen
	lea	$7f100,a0
	lea	color0(a6),a1
	moveq	#7,d0
next.col
	move.l	(a0)+,(a1)+
	dbra	d0,next.col


load.game
	moveq	#9,d0			start at track 9
	moveq	#70,d1			70 tracks
	lea	$400.w,a0		destination
	bsr.s	b.load
	bmi.s	load.game
	lea	$77400,a0
	jmp	$5f3a.w




backup	moveq	#1,d0			start at track 1
	moveq	#1,d1			1 track
	lea	$400.w,a0		destination
	bsr.s	b.load
	bmi.s	backup
	jmp	$800.w




***************
* Subroutines *
***************


* load routine  -  d0 = start track, d1 = number of tracks to read
*		   a0 = destination

b.load	subq.w	#1,d1			1 less for dbra
	bmi.s	b.no.tracks

	bsr.s	b.init.drive
	bmi.s	b.load.finished

b.load.loop
	move.w	#2,(b.load.attempts).w

b.load.now
	movem.w	d0/d1,-(a7)		save track and count
	move.l	a0,-(a7)		save destination pointer

	bsr	b.set.head.position

	bsr	b.read.track
	bmi.s	b.load.bad

	move.l	a0,a5			destination pointer
	bsr	b.decode.CC.track
	bmi.s	b.load.bad

	move.l	a5,a0			new destination pointer
	addq.w	#4,a7
	movem.w	(a7)+,d0/d1		get track and count
	addq.w	#1,d0			next track
	dbra	d1,b.load.loop

b.no.tracks
	moveq	#0,d4

b.load.finished
	bsr	b.drives.off
	tst.w	d4
	rts




b.load.bad
	move.l	(a7)+,a0		destination pointer
	movem.w	(a7)+,d0/d1		get track and count
	subq.w	#1,(b.load.attempts).w
	bmi.s	b.load.finished

	bne.s	b.load.now		if zero then position head again

	st	(b.head.position).w	make head position invalid
	bra.s	b.load.now




* set the disk drive up, check it is ready to load

b.init.drive
	lea	$bfd100,a4
	move.l	#$55555555,d5
	move.w	(b.drive.number).w,d2
	moveq	#0,d3
	addq.w	#3,d2
	bset	d2,d3			set bit for chosen drive

	move.w	(b.top.head).w,d2	set chosen head
	beq.s	b.correct.head
	bset	#2,d3			select top head

b.correct.head
	move.b	d3,(b.drive.select.status).w
	move.b	#$7f,(a4)		no drive selected, motor on
	or.b	#$80,d3			motor on
	not.b	d3
	move.b	d3,(a4)			select drive and head, turn motor on,
;					outward direction, diskstep high
	move.w	#$c000,d2
b.drive.not.ready
	mulu	d2,d4
	mulu	d2,d4
	btst	#5,$f01(a4)		disk ready ?
	dbeq	d2,b.drive.not.ready	no

	bne	b.set.false		if drive not ready
	moveq	#0,d4
	rts




* set the disk drive head to the correct track

b.set.head.position			; d0 = track
	move.w	d0,d6
	tst.w	(b.head.position).w
	bpl.s	b.head.position.valid

	bsr.s	b.head.to.track0	move to track 0 if position unknown

b.head.position.valid
	sub.w	(b.head.position).w,d6
	beq.s	b.step.return		if head is in required position

	add.w	d6,(b.head.position).w	new head position
	move.w	d6,d0
	bpl.s	b.step.inwards

	neg.w	d0			make step amount positive

b.step.outwards
	move.b	(b.drive.select.status).w,d1
	or.b	#$80,d1			motor on, outward direction
	bra.s	b.step.values

b.step.inwards
	move.b	(b.drive.select.status).w,d1
	or.b	#$82,d1			motor on, inward direction

b.step.values
	move.b	d1,d2
	or.b	#1,d2			diskstep low
	not.b	d1
	not.b	d2

	subq.w	#1,d0			1 less for dbra

b.step.head
	move.b	d2,(a4)			set diskstep low  -  move head

	move.b	d1,(a4)			set diskstep back to high

	move.w	#1200,d3
b.step.delay
	mulu	d3,d4
	dbra	d3,b.step.delay

	dbra	d0,b.step.head		step head by required amount
b.step.return
	rts




b.head.to.track0
	btst	#4,$f01(a4)		is drive at track 0 ?
	beq.s	b.at.track0

	moveq	#1,d0			step head by one track
	bsr.s	b.step.outwards
	bra.s	b.head.to.track0

b.at.track0
	clr.w	(b.head.position).w	head is at track 0
	rts




* read the data from the disk drive

b.read.track
	move.w	#$4000,dsklen(a6)	DMAEN off
	move.w	#$0002,intreq(a6)	disk DMA transfer done
	move.l	#$73800,dskpth(a6)	destination
	move.w	#$6800,adkcon(a6)	zero precomp time, clear UARTBRK
	move.w	#$9500,adkcon(a6)	MFM, WORDSYNC, FAST=1 (MFM)
	move.w	#$4489,dsksync(a6)
	move.w	#5140!$8000,dsklen(a6)	DMAEN on, 5140 words of data
	move.w	#5140!$8000,dsklen(a6)	write the same value again

	moveq	#-1,d0

.loop	mulu	d0,d4
	btst	#1,intreqr+1(a6)	disk DMA transfer done ?
	dbne	d0,.loop

	beq.s	b.read.bad

	move.w	#$4000,dsklen(a6)
	moveq	#0,d4
	rts




b.read.bad
	move.w	#$4000,dsklen(a6)

b.set.false
	moveq	#-1,d4
	rts




* various routines to decode the data from the disk drive

b.decode.CC.track			; a5 = destination
	lea	$73800,a2		source
	cmp.w	#$4489,(a2)		sync value
	bne.s	b.no.sync.value

	addq.w	#2,a2			skip second sync value

b.no.sync.value
	move.l	a2,a0
	bsr.s	b.decode.longword
	move.b	(b.head.position+1).w,d1
	add.b	d1,d1
	add.b	(b.top.head+1).w,d1	track number
	cmp.b	d0,d1
	bne.s	b.set.false

	lea	8(a2),a0
	bsr.s	b.decode.longword
	move.l	d0,d7			data checksum

	lea	16(a2),a0		start of data
	move.w	#10240/4,d1		number of longwords
	bsr.s	b.calculate.checksum

	cmp.l	d0,d7
	bne.s	b.set.false		if checksums do not agree

	lea	16(a2),a0		start of data
	move.w	#5120,d0		number of output bytes
	bsr.s	b.decode.data

	moveq	#0,d4
	rts




b.calculate.checksum
	move.l	(a0)+,d0		get first longword
	subq.w	#2,d1			count

.loop	move.l	(a0)+,d2		get next longword
	eor.l	d2,d0			and attach
	dbra	d1,.loop

	and.l	d5,d0			remove invalid bits
	rts




b.decode.longword
	move.l	(a0)+,d0		get first longword
	move.l	(a0)+,d1		get second longword
	and.l	d5,d0			remove clock bits
	and.l	d5,d1			remove clock bits
	add.l	d0,d0			shift odd bits
	or.l	d1,d0			combine to give longword result
	rts




b.decode.data
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

b.drives.off
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

	ds.w	126




******************
*		 *
* Backup routine *
*		 *
******************


backup.start
	lea	$1c00.w,a7
	lea	copper2(pc),a0
	move.l	a0,cop1lch(a6)
	move.w	d0,copjmp1(a6)

	move.w	#$87d0,dmacon(a6)

	bsr	setup.screen

	lea	colours(pc),a0
	lea	color0(a6),a1
	moveq	#8-1,d0
next.colour
	move.l	(a0)+,(a1)+
	dbra	d0,next.colour

	lea	title.text(pc),a0
	bsr	text			print title


	clr.w	drive.number		use drive 0
	clr.w	top.head		use bottom head


	;bsr.s	read.bottom.side
* Copy source data to $1c00
	lea	bottomSideData,a0	source
	lea	$1c00.w,a1		destination
	move.l	#bottomSideDataLength/4,d0	number of longwords
.copy	move.l	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	.copy


	bsr	display.3.messages
	dc.w	0,4,2			blank, insert backup, continue
	bsr	wait.mouse


	bsr.s	write.bottom.side
	bsr	display.3.messages
	dc.w	0,3,2			blank, insert master, continue
	bsr	wait.mouse


	IFD	ALSO_DO_TOP
	move.w	#1,top.head		use top head


	bsr	read.top.side
	bsr	display.3.messages
	dc.w	0,4,2			blank, insert backup, continue
	bsr	wait.mouse


	bsr	write.top.side
	ENDC
	bsr	display.3.messages
	dc.w	3,5,0			backup complete, reset, blank


backup.end
	bra.s	backup.end




read.bottom.side
	bsr	display.3.messages
	dc.w	1,0,0			reading master, blank, blank

	st	head.position		make head position invalid

	moveq	#1,d0			start at track 1
	moveq	#79,d1			79 tracks
	lea	$1c00.w,a0		destination
	bsr	load
	bpl.s	bottom.side.read

	bsr	display.3.messages
	dc.w	0,1,1			blank, error reading, retry

	bsr	wait.mouse

	bra.s	read.bottom.side

bottom.side.read
	rts




write.bottom.side
	bsr	display.3.messages
	dc.w	2,0,0			writing backup, blank, blank

	lea	$400.w,a0		source
	lea	$73400,a1		destination
	bsr	make.boot.block

	bsr	init.drive
	bmi.s	bottom.side.not.written

	st	head.position		make head position invalid
	moveq	#0,d0			move head to track 0
	bsr	set.head.position

	lea	$73400,a5		source
	bsr	code.DOS.track		make boot track
	bsr	write.track
	bmi.s	bottom.side.not.written

	moveq	#1,d0			start at track 1
	moveq	#79,d1			79 tracks
	lea	$1c00.w,a0		source
	bsr	save
	bpl.s	bottom.side.written

bottom.side.not.written
	bsr	display.3.messages
	dc.w	0,2,1			blank, error writing, retry

	bsr	wait.mouse

	bra.s	write.bottom.side

bottom.side.written
	rts




read.top.side
	bsr	display.3.messages
	dc.w	1,0,0			reading master, blank, blank

	st	head.position		make head position invalid

	moveq	#0,d0			start at track 0
	moveq	#80,d1			80 tracks
	lea	$1c00.w,a0		destination
	bsr	load
	bpl.s	top.side.read

	bsr	display.3.messages
	dc.w	0,1,1			blank, error reading, retry

	bsr	wait.mouse

	bra.s	read.top.side

top.side.read
	rts




write.top.side
	bsr	display.3.messages
	dc.w	2,0,0			writing backup, blank, blank

	st	head.position		make head position invalid

	moveq	#0,d0			start at track 0
	moveq	#80,d1			80 tracks
	lea	$1c00.w,a0		source
	bsr	save
	bpl.s	top.side.written

	bsr.s	display.3.messages
	dc.w	0,2,1			blank, error writing, retry

	bsr.s	wait.mouse

	bra.s	write.top.side

top.side.written
	rts




setup.screen
	lea	$7f100,a0		end of screen area
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.w	#2000-1,d7
.loop	movem.l	d0-d3,-(a0)		clear the screen
	dbra	d7,.loop

	lea	$77478,a0		start of screen, bitplane 4

	moveq	#46-1,d5
	bsr.s	window

	moveq	#0,d0			for left border
	moveq	#0,d1			for middle
	moveq	#0,d2			for right border
	moveq	#8-1,d4
	bsr.s	print.lines

	move.w	#142-1,d5


window	bsr.s	print.full.line

	move.w	#$8000,d0		for left border
	moveq	#0,d1			for middle
	moveq	#1,d2			for right border
	move.w	d5,d4
	bsr.s	print.lines


print.full.line
	moveq	#-1,d0			for left border
	moveq	#-1,d1			for middle
	moveq	#-1,d2			for right border
	moveq	#1-1,d4			print 1 line


print.lines
	move.w	d0,(a0)+		save leftmost word

	moveq	#18-1,d3
.loop	move.w	d1,(a0)+		save middle words
	dbra	d3,.loop

	move.w	d2,(a0)+		save rightmost word

	lea	120(a0),a0		to next line of bitplane 4
	dbra	d4,print.lines
	rts




wait.mouse
	btst	#6,$bfe001
	beq.s	mouse.pressed

	btst	#2,potgor(a6)
	bne.s	wait.mouse

mouse.pressed
	rts




display.3.messages
	move.l	(a7)+,a0
	lea	value1(pc),a1
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)
	move.l	a0,-(a7)

	lea	position1.text(pc),a0
	bsr.s	text

	lea	text1.pointers(pc),a0
	move.w	value1(pc),d0
	bsr.s	select.text

	lea	position2.text(pc),a0
	bsr.s	text

	lea	text2.pointers(pc),a0
	move.w	value2(pc),d0
	bsr.s	select.text

	lea	position3.text(pc),a0
	bsr.s	text

	lea	text3.pointers(pc),a0
	move.w	value3(pc),d0
	bsr.s	select.text

	rts




select.text
	add.w	d0,d0
	move.w	(a0,d0.w),a0
	move.l	a0,-(a7)

	lea	blank.text(pc),a0
	bsr.s	text

	move.l	(a7)+,a0
;	bra.s	text



text	movem.l	d0-d7/a1-a5,-(a7)

	clr.w	d1
	clr.w	d2
	move.b	current.x(pc),d1
	move.b	current.y(pc),d2

	bsr.s	print.text

	lea	current.x(pc),a1
	move.b	d1,(a1)+
	move.b	d2,(a1)

	movem.l	(a7)+,d0-d7/a1-a5
	rts




print.text
	clr.w	d0
	move.b	(a0)+,d0		get next character

	cmp.b	#6,d0
	bls.s	less.or.equal6

	cmp.b	#13,d0
	beq.s	carriage.return

	bsr.s	print.char

	bra.s	print.text




carriage.return
	move.b	left.border.x(pc),d1	set x to left border value
	addq.w	#8,d2
	bra.s	print.text




less.or.equal6
	tst.b	d0
	beq.s	character.null

	subq.b	#1,d0
	beq.s	change.x

	subq.b	#1,d0
	beq.s	change.y

	subq.b	#1,d0
	beq.s	change.x.y

	subq.b	#1,d0
	beq.s	change.left.border

	subq.b	#1,d0
	beq.s	change.colour

skip.spaces
	move.b	(a0)+,d0
	beq.s	character.null

	cmp.b	#' ',d0
	beq.s	skip.spaces

	subq.w	#1,a0
	bra.s	print.text




change.colour
	move.b	(a0)+,d0
	bsr.s	set.colour
	bra.s	print.text




set.colour
	move.b	d0,d4
	lsr.b	#4,d4
	moveq	#4-1,d3
	lea	print.loop+7(pc),a1

.loop	lsr.b	#1,d0
	scc	d5
	lsr.b	#1,d4
	scs	d6
	eor.b	d5,d6
	move.b	d6,(a1)
	move.b	d5,4(a1)
	lea	16(a1),a1
	dbra	d3,.loop
	rts




change.left.border
	lea	left.border.x(pc),a1
	move.b	d1,(a1)			set to current x
	bra.s	print.text




change.x
	move.b	(a0)+,d1
	bra.s	print.text




change.y
	move.b	(a0)+,d2
	bra.s	print.text




change.x.y
	move.b	(a0)+,d1
	move.b	(a0)+,d2
	bra	print.text




character.null
	rts




print.char
	lea	$77400,a5		start of screen, bitplane 1
	move.w	d2,d3			y
	lsl.w	#5,d3			y*32
	move.w	d3,d5
	add.w	d3,d3			y*64
	add.w	d3,d3			y*128
	add.w	d5,d3			y*128 + y*32 = y*160
	add.w	d3,a5
	add.w	d1,a5			screen start address

	sub.w	#' ',d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0			8 bytes per character
	lea	font(pc),a4
	add.w	d0,a4			start address of character

	addq.w	#1,d1			update x position

	moveq	#8-1,d0

print.loop
	move.b	(a4)+,d6		get byte of character
	move.b	d6,d5
	or.b	#0,d5
	eor.b	#0,d5
	move.b	d5,(a5)			set bitplane 1

	lea	40(a5),a5
	move.b	d6,d5
	or.b	#0,d5
	eor.b	#0,d5
	move.b	d5,(a5)			set bitplane 2

	lea	40(a5),a5
	move.b	d6,d5
	or.b	#0,d5
	eor.b	#0,d5
	move.b	d5,(a5)			set bitplane 3

	lea	40(a5),a5
	move.b	d6,d5
	or.b	#0,d5
	eor.b	#0,d5
	move.b	d5,(a5)			set bitplane 4

	lea	40(a5),a5
	dbra	d0,print.loop		do all bytes of character
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
;;	dbeq	d2,drive.not.ready	no
	bne.s	drive.not.ready		no

;;	bne	set.false		if drive not ready
	moveq	#0,d4
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

* 30/09/2018 NB the change below isn't actually essential on an A1200, i.e the original delay loop works (instead of wait.vbl)
;;	move.w	#1200,d3
;;step.delay
;;	mulu	d3,d4
;;	dbra	d3,step.delay
	bsr	wait.vbl

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
	movem.w	d0/d1,-(a7)		save track and count
	move.l	a0,-(a7)		save destination pointer

	bsr	set.head.position	;;

	bsr.s	read.track
	bmi.s	load.bad

	move.l	a0,a5			destination pointer
	bsr	decode.CC.track
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
	movem.w	(a7)+,d0/d1		get track and count
	subq.w	#1,load.save.attempts
	bmi.s	load.finished

	bne.s	load.now		if zero then position head again

	st	head.position		make head position invalid
	bra.s	load.now




read.track
	move.w	#$4000,dsklen(a6)	DMAEN off
	move.w	#$0002,intreq(a6)	disk DMA transfer done
	move.l	#$73800,dskpth(a6)	destination
	move.w	#$6800,adkcon(a6)	zero precomp time, clear UARTBRK
	move.w	#$9500,adkcon(a6)	MFM, WORDSYNC, FAST=1 (MFM)
	move.w	#$4489,dsksync(a6)
	move.w	#5140!$8000,dsklen(a6)	DMAEN on, 5140 words of data
	move.w	#5140!$8000,dsklen(a6)	write the same value again

read.wait
	moveq	#-1,d0

.loop	mulu	d0,d4
	btst	#1,intreqr+1(a6)	disk DMA transfer done ?
;;	dbne	d0,.loop
	beq.s	.loop

;;	beq.s	read.bad

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
	movem.w	d0/d1,-(a7)		save track and count

	bsr	set.head.position

	cmp.w	#2,load.save.attempts
	bne.s	not.first.attempt	no need to code the data again

	move.l	a0,a5			source pointer
	bsr.s	code.CC.track
	move.l	a5,a0			new source pointer

not.first.attempt
	bsr.s	write.track
	bmi.s	save.bad

* 30/09/2018 NB the change below isn't actually essential on an A1200, i.e the original delay loop works (instead of wait.vbl)
;;	move.w	#16000,d0

;;save.delay
;;	move.w	#$aaaa,d1
;;	mulu	d1,d1
;;	dbra	d0,save.delay
	bsr	wait.vbl

	movem.w	(a7)+,d0-d1		get track and count
	addq.w	#1,d0			next track
	dbra	d1,save.loop

no.tracks2
	moveq	#0,d4

save.finished
	bsr	drives.off
	tst.w	d4
	rts




save.bad
	movem.w	(a7)+,d0/d1		get track and count
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
	move.l	#$73800,dskpth(a6)	source
	move.w	#$6e00,adkcon(a6)	zero precomp time, clear UARTBRK
;					clear WORDSYNC and MSBSYNC
	move.w	#$9100,adkcon(a6)	MFM, FAST=1 (MFM)
	move.w	#6560!$c000,dsklen(a6)	DMAEN on, WRITE, 6560 words of data
	move.w	#6560!$c000,dsklen(a6)	write the same value again

	bra	read.wait




code.CC.track				; a5 = source
	lea	$73800,a2		destination
	move.w	#6560/2-1,d0
	move.l	#$aaaaaaaa,d1

.loop	move.l	d1,(a2)+		save data for track gap
	dbra	d0,.loop

	lea	$73c74,a2
	move.l	#$44894489,4(a2)	two sync markers

	moveq	#-1,d0
	move.b	head.position+1,d0
	add.b	d0,d0
	add.b	top.head+1,d0		track number

	lea	8(a2),a0
	bsr	code.longword		code track information

	move.w	#5120,d0		number of bytes
	move.l	a5,a0			source
	lea	24(a2),a1		destination
	bsr	blit.code.data

	lea	24+10240(a2),a0
	bsr	correct.current.byte

	lea	24(a2),a0
	move.w	#10240/4,d1		number of longwords
	bsr	calculate.checksum

	lea	16(a2),a0
	bsr	code.longword		code data checksum

	lea	5120(a5),a5		update source pointer
	rts




decode.CC.track				; a5 = destination
	lea	$73800,a2		source
	cmp.w	#$4489,(a2)		sync value
	bne.s	no.sync.value

	addq.w	#2,a2			skip second sync value

no.sync.value
	move.l	a2,a0
	bsr	decode.longword
	move.b	head.position+1,d1
	add.b	d1,d1
	add.b	top.head+1,d1		track number
	cmp.b	d0,d1
	bne	set.false

	lea	8(a2),a0
	bsr	decode.longword
	move.l	d0,d7			data checksum

	lea	16(a2),a0		start of data
	move.w	#10240/4,d1		number of longwords
	bsr	calculate.checksum

	cmp.l	d0,d7
	bne	set.false		if checksums do not agree

	lea	16(a2),a0		start of data
	move.w	#5120,d0		number of output bytes
	bsr	decode.data

	moveq	#0,d4
	rts




code.DOS.track				; a5 = source
	lea	$73800,a2		destination
	move.w	#6560/2-1,d0
	move.l	#$aaaaaaaa,d1

.loop	move.l	d1,(a2)+		save data for track gap
	dbra	d0,.loop

	lea	$73c74,a2
	moveq	#0,d7			start at sector 0

next.sector
	moveq	#-1,d0
	move.b	head.position+1,d0
	add.b	d0,d0
	add.b	top.head+1,d0		track number
	swap	d0

	move.b	d7,d0			sector number
	lsl.w	#8,d0

	move.b	#11,d0
	sub.b	d7,d0			number of sectors before track gap

	bsr.s	code.DOS.block

	lea	1088(a2),a2		update destination pointer
	lea	512(a5),a5		update source pointer
	addq.b	#1,d7			next sector
	cmp.b	#11,d7
	bne.s	next.sector		do all 11 sectors
	rts




code.DOS.block
	move.l	#$44894489,4(a2)	two sync markers

	lea	8(a2),a0
	bsr.s	code.longword		code block information

	moveq	#4-1,d4			4 longwords

.loop	moveq	#0,d0
	bsr.s	code.longword
	dbra	d4,.loop		code unused part

	lea	8(a2),a0
	moveq	#40/4,d1		number of longwords
	bsr.s	calculate.checksum

	lea	48(a2),a0
	bsr.s	code.longword		code header checksum

	move.w	#512,d0			number of bytes
	move.l	a5,a0			source
	lea	64(a2),a1		destination
	bsr	blit.code.data

	lea	64+1024(a2),a0
	bsr.s	correct.current.byte

	lea	64(a2),a0
	move.w	#1024/4,d1		number of longwords
	bsr.s	calculate.checksum

	lea	56(a2),a0
	bsr.s	code.longword		code data checksum
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




blit.code.data				; d0 = number of bytes (modulo 32)
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
	move.w	d0,d2
	add.w	d2,d2			bytes / 32
	add.w	#16,d2			+ width of 32 bytes
	move.w	d2,bltsize(a6)

	lea	-2(a0,d0.w),a0		to end of source
	add.w	d0,d0
	lea	-2(a3,d0.w),a1		to end of destination

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
	add.w	#16,d2			do twice as many bytes
	move.w	d2,bltsize(a6)

bltfin4	btst	#6,dmaconr(a6)
	bne.s	bltfin4
	rts




make.boot.block				; a0 = source, a1 = destination
	move.l	#$444f5300,d0		'DOS',0
	move.l	d0,(a1)+		save disk identification
	move.l	a1,a2
	clr.l	(a1)+			clear checksum
	clr.l	(a1)+			clear root block pointer

	move.w	#253-1,d1

boot.checksum
	move.l	(a0)+,d2		get next longword
	add.l	d2,d0
	bcc.s	no.carry

	addq.l	#1,d0

no.carry
	move.l	d2,(a1)+		save longword
	dbra	d1,boot.checksum

	not.l	d0
	move.l	d0,(a2)			save checksum
	rts




* Wait for vertical blank
* NB When using this, ensure d3 is safe to use
wait.vbl
	move.w	#$20,intreq(a6)		no vertical blank interrupt

.loop	move.w	intreqr(a6),d3
	btst	#5,d3
	beq.s	.loop			wait for vertical blank

	move.w	#$20,intreq(a6)		no vertical blank interrupt
	rts




copper2	dc.w	bpl4pth,$0007
	dc.w	bpl4ptl,$7478
	dc.w	bpl3pth,$0007
	dc.w	bpl3ptl,$7450
	dc.w	bpl2pth,$0007
	dc.w	bpl2ptl,$7428
	dc.w	bpl1pth,$0007
	dc.w	bpl1ptl,$7400
	dc.w	$ffff,$fffe




font	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$10,$10,$10,$10,$10,$00,$10,$00
	dc.b	$28,$28,$28,$00,$00,$00,$00,$00,$00,$28,$7c,$28,$7c,$28,$00,$00
	dc.b	$10,$3c,$50,$38,$14,$78,$10,$00,$00,$62,$64,$08,$10,$26,$46,$00
	dc.b	$30,$48,$48,$32,$4c,$4c,$32,$00,$18,$08,$10,$00,$00,$00,$00,$00
	dc.b	$08,$10,$20,$20,$20,$10,$08,$00,$10,$08,$04,$04,$04,$08,$10,$00
	dc.b	$00,$54,$38,$7c,$38,$54,$00,$00,$00,$10,$10,$7c,$10,$10,$00,$00
	dc.b	$00,$00,$00,$00,$00,$18,$08,$10,$00,$00,$00,$7e,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$18,$18,$00,$02,$04,$08,$10,$20,$40,$80,$00
	dc.b	$7c,$86,$8a,$92,$a2,$c2,$7c,$00,$38,$08,$08,$08,$08,$08,$3e,$00
	dc.b	$3c,$42,$02,$3c,$40,$42,$7e,$00,$3c,$42,$02,$1c,$02,$42,$3c,$00
	dc.b	$0c,$14,$24,$44,$7e,$04,$0e,$00,$7e,$42,$40,$7c,$02,$42,$3c,$00
	dc.b	$3c,$42,$40,$7c,$42,$42,$3c,$00,$7e,$42,$04,$08,$10,$10,$10,$00
	dc.b	$3c,$42,$42,$3c,$42,$42,$3c,$00,$3c,$42,$42,$3e,$02,$42,$3c,$00
	dc.b	$00,$00,$18,$18,$00,$18,$18,$00,$00,$00,$18,$18,$00,$18,$08,$10
	dc.b	$08,$10,$20,$40,$20,$10,$08,$00,$00,$00,$7e,$00,$00,$7e,$00,$00
	dc.b	$20,$10,$08,$04,$08,$10,$20,$00,$3c,$42,$42,$0c,$10,$00,$10,$00
	dc.b	$3c,$42,$5a,$5a,$5e,$40,$3c,$00,$18,$24,$42,$42,$7e,$42,$42,$00
	dc.b	$7c,$22,$22,$3c,$22,$22,$7c,$00,$3c,$42,$40,$40,$40,$42,$3c,$00
	dc.b	$7c,$22,$22,$22,$22,$22,$7c,$00,$7e,$22,$28,$38,$28,$22,$7e,$00
	dc.b	$7e,$22,$28,$38,$28,$20,$70,$00,$3c,$42,$40,$4e,$42,$42,$3e,$00
	dc.b	$ee,$44,$44,$7c,$44,$44,$ee,$00,$38,$10,$10,$10,$10,$10,$38,$00
	dc.b	$3e,$04,$04,$04,$44,$44,$38,$00,$76,$24,$28,$30,$28,$24,$76,$00
	dc.b	$70,$20,$20,$20,$22,$22,$7e,$00,$c3,$66,$5a,$42,$42,$42,$e7,$00
	dc.b	$ce,$64,$54,$54,$4c,$44,$e6,$00,$3c,$42,$42,$42,$42,$42,$3c,$00
	dc.b	$7c,$22,$22,$3c,$20,$20,$70,$00,$3c,$42,$42,$42,$4a,$44,$3a,$00
	dc.b	$7c,$22,$22,$3c,$28,$24,$76,$00,$3c,$42,$40,$3c,$02,$42,$3c,$00
	dc.b	$7c,$54,$10,$10,$10,$10,$38,$00,$ee,$44,$44,$44,$44,$44,$3e,$00
	dc.b	$ee,$44,$44,$44,$28,$28,$10,$00,$e7,$42,$42,$42,$5a,$5a,$24,$00
	dc.b	$82,$44,$28,$10,$28,$44,$82,$00,$ee,$44,$44,$38,$10,$10,$38,$00
	dc.b	$7e,$44,$08,$10,$20,$42,$7e,$00,$3c,$20,$20,$20,$20,$20,$3c,$00
	dc.b	$00,$40,$20,$10,$08,$04,$02,$00,$3c,$04,$04,$04,$04,$04,$3c,$00
	dc.b	$10,$38,$7c,$10,$10,$10,$10,$00,$00,$00,$00,$00,$00,$00,$00,$ff
	dc.b	$30,$18,$0c,$00,$00,$00,$00,$00,$00,$00,$3e,$44,$44,$44,$3e,$00
	dc.b	$60,$20,$3c,$22,$22,$22,$7c,$00,$00,$00,$3c,$42,$40,$42,$3c,$00
	dc.b	$0c,$04,$3c,$44,$44,$44,$3e,$00,$00,$00,$3c,$46,$58,$62,$3c,$00
	dc.b	$18,$24,$20,$78,$20,$20,$70,$00,$00,$00,$3e,$44,$44,$3c,$04,$38
	dc.b	$60,$20,$3c,$22,$22,$22,$62,$00,$10,$00,$30,$10,$10,$10,$38,$00
	dc.b	$02,$00,$06,$02,$02,$42,$42,$3c,$60,$20,$24,$28,$38,$24,$62,$00
	dc.b	$30,$10,$10,$10,$10,$10,$38,$00,$00,$00,$ec,$92,$92,$92,$82,$00
	dc.b	$00,$00,$7c,$22,$22,$22,$22,$00,$00,$00,$3c,$42,$42,$42,$3c,$00
	dc.b	$00,$00,$7c,$22,$22,$3c,$20,$70,$00,$00,$3c,$48,$48,$38,$0a,$0c
	dc.b	$00,$00,$78,$24,$20,$20,$70,$00,$00,$00,$3c,$40,$3c,$02,$7c,$00
	dc.b	$20,$20,$7c,$20,$20,$22,$1c,$00,$00,$00,$66,$24,$24,$24,$1e,$00
	dc.b	$00,$00,$c6,$44,$44,$28,$10,$00,$00,$00,$c6,$54,$54,$7c,$28,$00
	dc.b	$00,$00,$44,$28,$10,$28,$44,$00,$00,$00,$66,$24,$24,$1c,$04,$38
	dc.b	$00,$00,$7e,$48,$10,$22,$7e,$00,$0e,$70,$3c,$46,$58,$62,$3c,$00
	dc.b	$70,$0e,$3c,$46,$58,$62,$3c,$00,$18,$66,$3c,$46,$58,$62,$3c,$00
	dc.b	$00,$00,$20,$54,$08,$00,$00,$00,$1c,$22,$20,$78,$20,$22,$7e,$00

left.border.x
	dc.b	0

current.x
	dc.b	0

current.y
	dc.b	0

title.text
	dc.b	5,5,3,7,8,'Realtime Amiga Backerupper'
	dc.b	3,6,24,'Remember, Piracy is illegal!',0

text1.pointers
	dc.w	blank.text-backup.start+$800
	dc.w	reading.text-backup.start+$800
	dc.w	writing.text-backup.start+$800
	dc.w	finished1.text-backup.start+$800

text2.pointers
	dc.w	blank.text-backup.start+$800
	dc.w	error1.text-backup.start+$800
	dc.w	error2.text-backup.start+$800
	dc.w	insert1.text-backup.start+$800
	dc.w	insert2.text-backup.start+$800
	dc.w	finished2.text-backup.start+$800

text3.pointers
	dc.w	blank.text-backup.start+$800
	dc.w	retry.text-backup.start+$800
	dc.w	continue.text-backup.start+$800

blank.text
	dc.b	1,1,'                                      ',0

position1.text
	dc.b	2,80,5,5,0

reading.text
	dc.b	1,10,'Reading Master Disk',0

writing.text
	dc.b	1,10,'Writing Backup Disk',0

finished1.text
	dc.b	1,13,'Backup Complete',0

position2.text
	dc.b	2,120,5,1,0

error1.text
	dc.b	1,7,'Error Reading Master Disk',0

error2.text
	dc.b	1,7,'Error Writing Backup Disk',0

insert1.text
	dc.b	1,11,'Insert Master Disk',0

insert2.text
	dc.b	1,11,'Insert Backup Disk',0

finished2.text
	dc.b	1,6,'Reset Computer To Run Game',0

position3.text
	dc.b	2,144,5,5,0

retry.text
	dc.b	1,4,'Press Mouse Button To Try Again',0

continue.text
	dc.b	1,5,'Press Mouse Button When Ready',0

colours	dc.w	$000,$e00,$0ae,$864,$286,$ca0,$a80,$00c
	dc.w	$eee,$aaa,$04c,$2a4,$060,$666,$e64,$000

value1	dc.w	0
value2	dc.w	1
value3	dc.w	2

end

length	equ	end-beginning


bottomSideData
	incbin	binary/CCTrack1	* length should be 4276
	ds.b	844		* pad to 10 sectors

	incbin	binary/CCLoadScreen	* length should be 32032
	ds.b	3808		* pad to 7*10 sectors

	incbin	binary/CCGame	* length should be 327562 ($400 - $5038a)
	ds.b	30838		* pad to 70*10 sectors
bottomSideDataEnd

bottomSideDataLength	equ	bottomSideDataEnd-bottomSideData


load.save.attempts	dc.w	0
drive.number	dc.w	0
head.position	dc.w	0
top.head	dc.w	0
drive.select.status	dc.b	0,0
