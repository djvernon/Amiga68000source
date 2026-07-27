

 * Create trackdisk compatible Carrier Command disk *

 * Place an AmigaDOS format disk into df0:, then run this program *


 * Bottom side - Loading screen + game, using all 11 sectors per track *

 * Top side - Music, only 10 sectors per track used *

 * Game load/save - also fixed to use 10 sectors per track *

 * Keyboard handshake fixed for emulators, program protection disabled *


	section	createcc,code_c


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


* Find current task structure

	move.l	4.w,a6
	sub.l	a1,a1
	jsr	-294(a6)		FindTask
	move.l	d0,_ReadReply+$10	SigTask

* Add reply port

	lea	_ReadReply,a1
	jsr	-354(a6)		AddPort

* Open Disk device

	lea	_DiskIO,a1
	move.l	#0,d0			DF0:
	clr.l	d1			no flags
	lea	TrackDiskDevice,a0
	jsr	-444(a6)		OpenDevice
	tst.l	d0
	bne	error

* Write music data

	moveq	#1-1,d7		80 tracks
	lea	$60000,a2
	move.l	#10*512,d3		only first 10 sectors of track
	move.l	#(79*22+11)*512,d4	start at track 0, top side
write.music
	bsr	write.to.disk
	add.l	d3,a2
	add.l	#22*512,d4		next track on same side
	dbra	d7,write.music

* Turn drive motor off

	move.l	4.w,a6
	lea	_DiskIO,a1
	move	#9,28(a1)		turn motor off
	move.l	#0,36(a1)
	jsr	-456(a6)		DoIO

* Remove reply port

	lea	_ReadReply,a1
	jsr	-360(a6)		RemPort

* Close Disk device

	lea	_DiskIO,a1
	jsr	-450(a6)		CloseDevice

error
	rts

TrackDiskDevice	dc.b	'trackdisk.device',0
	even

_DiskIO	dcb.l	20,0
_ReadReply	dcb.l	8,0


****************
*	       *
* Subroutines *
*	       *
****************

modify.game
* disable program protection
*
* information :-
* language selection & program protection routine at $ca36 to $cbb0, sets $229c.b and
* $229e.w non-zero.  main loop checks these values and decrements stack pointer if either
* is zero, which eventually overwrites program code and crashes the program
	move.l	#$4e714e71,$6052+game-$200	* don't decrement sp
	move.w	#$4e75,$ca40+game-$200		* rts at start of protection routine

* modify level 2 interrupt handler to use a software handshake loop
* (because emulators don't generate CIA-A interrupt when SP is set to output)
	move.l	#handshakesize/2,d0
	lea	handshake,a0
	lea	$1a8c8+game-$200,a1
hcopy	move.w	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	hcopy

* modify load routines to read AmigaDOS format disks
* first 10 sectors of track are used, to give the same 5120 bytes per track
* as the original version
*
* modify read.track ($74ec) to read 6560 words
* memory usage is ok because write.track uses the same start and length
	move.w	#6560!$8000,$7514+game-$200
	move.w	#6560!$8000,$751a+game-$200

* $200 to $400 appear to be available, unused by Carrier Command

* install new decode.DOS.track at $200 to decode first 10 AmigaDOS sectors
* replace all calls to original routine ($7662)
	move.l	#g.decode.DOS.track.size/2,d0
	lea	g.decode.DOS.track,a0
	lea	$200+game-$200,a1
dcopy	move.w	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	dcopy

	move.l	call.new.decode(pc),d0
	move.l	d0,$74ba+game-$200
	move.l	d0,$782c+game-$200
	move.l	d0,$789c+game-$200

* modify save routines to write AmigaDOS format disks
* first 10 sectors of track are used, to give the same 5120 bytes per track
* as the original version
*
* write.track ($75aa) already writes 6560 words
* note that it always sets the precomp to 00 in ADKCON, which doesn't give
* problems with the emulators, but may do with a real Amiga (kickstart 1.3
* sets the value to 00 for tracks 0-40 and 01 for tracks 41-79)
*
* install new code.DOS.track at $300 to populate first 10 AmigaDOS sectors
* replace all calls to original routine ($75ea)
	move.l	#g.code.DOS.size/2,d0
	lea	g.code.DOS.track,a0
	lea	$300+game-$200,a1
ccopy	move.w	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	ccopy

	move.l	call.new.code(pc),d0
	move.l	d0,$756a+game-$200
	rts


call.new.decode
	jsr	$200.w
call.new.code
	jsr	$300.w


handshake
	bset #6,$e00(a5)
	moveq #54,d0
.loop	dbra d0,.loop
	bclr #6,$e00(a5)
	nop
	nop
	nop
	nop
	nop
	nop
	nop
handshakesize	equ	*-handshake


code.boot.block				* a0 = start
	move.l	#$444f5300,d0		'DOS',0
	move.l	d0,(a0)+		save disk identification
	move.l	a0,a2
	clr.l	(a0)+			clear checksum
	clr.l	(a0)+			clear root block pointer

	move.w	#253-1,d1

boot.checksum
	move.l	(a0)+,d2		get next longword
	add.l	d2,d0
	bcc.s	no.carry

	addq.l	#1,d0

no.carry
	dbra	d1,boot.checksum

	not.l	d0
	move.l	d0,(a2)			save checksum
	rts


write.to.disk				* a2 = source, d3 = byte length, d4 = byte offset
	lea	_DiskIO,a1
	move.l	#_ReadReply,14(a1)	set reply port
	move	#2,28(a1)		Read
	move.l	a2,40(a1)		source
	move.l	d3,36(a1)		length
	move.l	d4,44(a1)		offset

	movem.l	d3/d4/a2,-(sp)
	move.l	4.w,a6
	jsr	-456(a6)		DoIO
;	move.l	_DiskIO+32,d6		actual bytes written
	movem.l	(sp)+,d3/d4/a2
	rts


****************
*	       *
* Boot routine *
*	       *
****************

boot.blocks
	dc.l	0		disk type, e.g. DOS
	dc.l	0		checksum
	dc.l	0		root block number

boot.block.code
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
	clr.w	(drive.number).w	use drive 0
	st	(head.position).w	make head position invalid
	clr.w	(top.head).w		use bottom head

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

	move.w	#$c00,potgo(a6)		game port 0 poty to output
;	btst.b	#6,$bfe001		left mouse button
;	beq.s	backup
;	btst.b	#2,potgor(a6)		right mouse button
;	beq.s	backup


load.screen
	moveq	#1,d0			start at track 1
	moveq	#6,d1			6 tracks
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
	moveq	#7,d0			start at track 7
	moveq	#59,d1			59 tracks
	lea	$200.w,a0		destination - NOTE: now $200
	bsr.s	b.load
	bmi.s	load.game
	lea	$77400,a0
	jmp	$5f3a.w




;backup	moveq	#1,d0			start at track 1
;	moveq	#1,d1			1 track
;	lea	$400.w,a0		destination
;	bsr.s	b.load
;	bmi.s	backup
;	jmp	$800.w




* load routine  -  d0 = start track, d1 = number of tracks to read
*		   a0 = destination

b.load	subq.w	#1,d1			1 less for dbra
	bmi.s	b.no.tracks

	bsr.s	b.init.drive
	bmi.s	b.load.finished

b.load.loop
	move.w	#2,(load.attempts).w

b.load.now
	movem.w	d0/d1,-(a7)		save track and count
	move.l	a0,-(a7)		save destination pointer

	bsr	b.set.head.position

	bsr	b.read.track
	bmi.s	b.load.bad

	move.l	a0,a5			destination pointer
	bsr	b.decode.DOS.track
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
	subq.w	#1,(load.attempts).w
	bmi.s	b.load.finished

	bne.s	b.load.now		if zero then position head again

	st	(head.position).w	make head position invalid
	bra.s	b.load.now




* set the disk drive up, check it is ready to load

b.init.drive
	lea	$bfd100,a4
	move.l	#$55555555,d5
	move.w	(drive.number).w,d2
	moveq	#0,d3
	addq.w	#3,d2
	bset	d2,d3			set bit for chosen drive

	move.w	(top.head).w,d2		set chosen head
	beq.s	b.correct.head
	bset	#2,d3			select top head

b.correct.head
	move.b	d3,(drive.select.status).w
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
	tst.w	(head.position).w
	bpl.s	b.head.position.valid

	bsr.s	b.head.to.track0	move to track 0 if position unknown

b.head.position.valid
	sub.w	(head.position).w,d6
	beq.s	b.step.return		if head is in required position

	add.w	d6,(head.position).w	new head position
	move.w	d6,d0
	bpl.s	b.step.inwards

	neg.w	d0			make step amount positive

b.step.outwards
	move.b	(drive.select.status).w,d1
	or.b	#$80,d1			motor on, outward direction
	bra.s	b.step.values

b.step.inwards
	move.b	(drive.select.status).w,d1
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
	clr.w	(head.position).w	head is at track 0
	rts




* read the data from the disk drive
*
* reads 6560 words instead of the original 5140, to get the whole DOS track
* reads into $73800 - $76b40 which is ok because boot routine starts at $76c00

b.read.track
	move.w	#$4000,dsklen(a6)	DMAEN off
	move.w	#$0002,intreq(a6)	disk DMA transfer done
	move.l	#$73800,dskpth(a6)	destination
	move.w	#$6800,adkcon(a6)	zero precomp time, clear UARTBRK
	move.w	#$9500,adkcon(a6)	MFM, WORDSYNC, FAST=1 (MFM)
	move.w	#$4489,dsksync(a6)
	move.w	#6560!$8000,dsklen(a6)	DMAEN on, 6560 words of data
	move.w	#6560!$8000,dsklen(a6)	write the same value again

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

b.decode.DOS.track			* a5 = destination, 11*512 bytes written
	move.l	a5,a3
	moveq	#11-1,d7
	lea	$73800,a2		source

b.skip.sync
	cmp.w	#$4489,(a2)		sync value
	bne.s	b.decode.block
	addq.w	#2,a2			skip sync value

b.decode.block
	lea	40(a2),a0
	bsr	b.decode.longword
	move.l	d0,d6			header checksum

	move.l	a2,a0
	moveq	#40/4,d1		number of longwords
	bsr.s	b.calculate.checksum

	cmp.l	d0,d6
	bne.s	b.set.false		if checksums do not agree

	move.l	a2,a0
	bsr.s	b.decode.longword
	move.w	d0,d3
	swap	d0
	moveq	#-1,d1			for DOS format identification
	move.b	(head.position+1).w,d1
	add.b	d1,d1
	add.b	(top.head+1).w,d1	track number
	cmp.w	d0,d1			check for $ff TN
	bne.s	b.set.false

* sector number not validated
* sectors before track gap not validated

	lea	48(a2),a0
	bsr.s	b.decode.longword
	move.l	d0,d6			data checksum

	lea	56(a2),a0		start of data
	move.w	#1024/4,d1		number of longwords
	bsr.s	b.calculate.checksum

	cmp.l	d0,d6
	bne.s	b.set.false		if checksums do not agree

* use sector number to calculate destination
	move.w	d3,d1
	clr.b	d1
	add.w	d1,d1			gives sector number * 512
	lea	(a3,d1.w),a5

	lea	56(a2),a0		start of data
	move.w	#512,d0			number of output bytes
	bsr.s	b.decode.block.data

	cmp.b	#1,d3			check sectors before track gap
	beq.s	b.skip.gap

* point to start of next block, after sync markers
* (assumes there are always two sync markers)
	lea	64+1024(a2),a2
	dbra	d7,b.decode.block
	bra.s	b.decode.done

* if sectors before gap = 1 then search past next sync marker
* (there may be one or two sync markers)
*
* actually don't need to do this if last sector
b.skip.gap
	lea	56+1024(a2),a2		end of block
.skip	cmp.w	#$4489,(a2)+		sync value
	bne.s	.skip
	dbra	d7,b.skip.sync

b.decode.done
	lea	11*512(a3),a5		output end address
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




b.decode.block.data
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
boot.blocks.end	equ	*-boot.blocks

	ds.b	1024-boot.blocks.end	* pad


********************
*		   *
* Boot routine end *
*		   *
********************




*****************************
*			    *
* Replacement game routines *
*			    *
*****************************

;g.drive.number	equ	$23d0
g.head.position	equ	$23d2
g.top.head	equ	$23d4
;g.load.save.attempts	equ	$23d6
;g.drive.select.status	equ	$23d8


;g.init.drive	equ	$73b2
* routines used :-
g.calculate.checksum	equ	$76b6
g.decode.longword	equ	$76c8
g.decode.block.data	equ	$76d6
g.code.longword		equ	$76f2
g.correct.current.byte	equ	$76fc
g.blit.code.data	equ	$773c


* routine used by game to decode first 10 sectors of AmigaDOS track
* replacement for $7662
*
* extra registers used (not preserved) - d3/d6/a3

g.decode.DOS.track			* a5 = destination, 10*512 bytes written
	move.l	a5,a3
	moveq	#11-1,d7
	lea	$74900,a2		source

g.skip.sync
	cmp.w	#$4489,(a2)		sync value
	bne.s	g.decode.block
	addq.w	#2,a2			skip sync value

g.decode.block
	lea	40(a2),a0
	jsr	(g.decode.longword).w
	move.l	d0,d6			header checksum

	move.l	a2,a0
	moveq	#40,d1			number of bytes
	jsr	(g.calculate.checksum).w

	cmp.l	d0,d6
	bne.s	g.set.false		if checksums do not agree

	move.l	a2,a0
	jsr	(g.decode.longword).w
	move.w	d0,d3
	swap	d0
	moveq	#-1,d1			for DOS format identification
	move.b	(g.head.position+1).w,d1
	add.b	d1,d1
	add.b	(g.top.head+1).w,d1	track number
	cmp.w	d0,d1			check for $ff TN
	bne.s	g.set.false

* sector number not validated
* sectors before track gap not validated

	move.w	d3,d1			ignore last sector
	lsr.w	#8,d1
	cmp.b	#10,d1
	beq.s	g.block.output

	lea	48(a2),a0
	jsr	(g.decode.longword).w
	move.l	d0,d6			data checksum

	lea	56(a2),a0		start of data
	move.w	#1024,d1		number of bytes
	jsr	(g.calculate.checksum).w

	cmp.l	d0,d6
	bne.s	g.set.false		if checksums do not agree

* use sector number to calculate destination
	move.w	d3,d1
	clr.b	d1
	add.w	d1,d1			gives sector number * 512
	lea	(a3,d1.w),a5

	lea	56(a2),a0		start of data
	move.w	#512,d0			number of output bytes
	jsr	(g.decode.block.data).w

g.block.output
	cmp.b	#1,d3			check sectors before track gap
	beq.s	g.skip.gap

* point to start of next block, after sync markers
* (assumes there are always two sync markers)
	lea	64+1024(a2),a2
	dbra	d7,g.decode.block
	bra.s	g.decode.done

* if sectors before gap = 1 then search past next sync marker
* (there may be one or two sync markers)
* maybe shouldn't do this if last sector
g.skip.gap
	lea	56+1024(a2),a2		end of block
.skip	cmp.w	#$4489,(a2)+		sync value
	bne.s	.skip
	dbra	d7,g.skip.sync

g.decode.done
	lea	10*512(a3),a5		output end address
	moveq	#0,d4
	rts       

g.set.false
	moveq	#-1,d4
	rts
g.decode.DOS.track.size	equ	*-g.decode.DOS.track



* routine used by game to code AmigaDOS track
* only first 10 sectors are populated with data, 11th sector is blank
* replacement for $75ea
*
* extra registers used (not preserved) - d4/d7

g.code.DOS.track			* a5 = source, 10*512 bytes read
	lea	$74900,a2		destination
	move.w	#6560/2-1,d0
	move.l	#$aaaaaaaa,d1

.loop	move.l	d1,(a2)+		save data for track gap
	dbra	d0,.loop

	lea	$74d74,a2
	moveq	#0,d7			start at sector 0

g.next.sector
	moveq	#-1,d0
	move.b	(g.head.position+1).w,d0
	add.b	d0,d0
	add.b	(g.top.head+1).w,d0	track number
	swap	d0

	move.b	d7,d0			sector number
	lsl.w	#8,d0

	move.b	#11,d0
	sub.b	d7,d0			number of sectors before track gap

	bsr.s	g.code.DOS.block

	lea	1088(a2),a2		update destination pointer
	lea	512(a5),a5		update source pointer
	addq.b	#1,d7			next sector
	cmp.b	#11,d7
	bne.s	g.next.sector		do all 11 sectors

	lea	-512(a5),a5		correct source pointer
	rts




g.code.DOS.block
	move.l	#$44894489,4(a2)	two sync markers

	lea	8(a2),a0
	jsr	(g.code.longword).w	code block information

	moveq	#4-1,d4			4 longwords

.loop	moveq	#0,d0
	jsr	(g.code.longword).w
	dbra	d4,.loop		code unused part

	lea	8(a2),a0
	moveq	#40,d1			number of bytes
	jsr	(g.calculate.checksum).w

	lea	48(a2),a0
	jsr	(g.code.longword).w	code header checksum

	cmp.b	#10,d7			NOTE: leave last sector blank
	beq.s	g.data.coded

	move.w	#512,d0			number of bytes
	move.l	a5,a0			source
	lea	64(a2),a1		destination
	jsr	(g.blit.code.data).w

g.data.coded
	lea	64+1024(a2),a0
	jsr	(g.correct.current.byte).w

	lea	64(a2),a0
	move.w	#1024,d1		number of bytes
	jsr	(g.calculate.checksum).w

	lea	56(a2),a0
	jsr	(g.code.longword).w	code data checksum
	rts
g.code.DOS.size	equ	*-g.code.DOS.track


*********************************
*				*
* Replacement game routines end *
*				*
*********************************




* data taken from original Carrier Command disk

game	ds.b	$200		* extra space for new routines
	incbin	binary/CCGame		* length should be 327562 ($400 - $5038a)
	ds.b	4726-$200	* pad to 59*11 sectors

loadscreen
	incbin	binary/CCLoadScreen	* length should be 32032
	ds.b	1760		* pad to 6*11 sectors

music	incbin	binary/CCMusic		* length should be 409600
				* no padding required


* memory locations for loaded data
*
*             original version:-               fixed version:-
*             start   length(bytes)  end       start   length(bytes)  end
*
* loadscreen  $77400  7*5120         $80000    $77400  6*5632         $7f800
* (actual length required - 32032 - four bitplane display plus 16 colour values)
*
* game        $400    70*5120        $57c00    $200    59*5632        $51400
* (only up to $5038a actually needed because load screen is transferred there)
* ($4b720 to $57c00 loaded from disk is all zero anyway)
*
* no extra memory is overwritten


* other Carrier Command notes
*
* $749a - load routine, $7544 - save routine
* $77da - load/play music
*
* saved games occupy 16 tracks, starting from tracks 0/20/40/60 on disk
*
* $1bfd0 - random() ?
*
* st $87d - indicates key is down
* st $229c - indicates key between '1' and '3' pressed (for program protection)
* $22a6 - language specific ptr, $22aa - language (0-2)
* $22a4 - attempts to enter correct word, $22a2 - random word number (0-63)
*
* $1232.b - stores key pressed (ascii)
* $78c - word array of raw keys pressed ($0101 = pressed, $0001 = released)
*
* $c376 - print text
* $1a3fa - swap screens
* $1a778 - wait for key press, return in d0
