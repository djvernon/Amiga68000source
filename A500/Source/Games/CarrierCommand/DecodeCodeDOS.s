	section test,code_c




	move.l	4.w,a6
	moveq	#0,d0
	lea	graf.name,a1
	jsr	-552(a6)		OpenLibrary
	move.l	d0,gfxbase
	beq	exit


* read track 0, bottom side, from Carrier Command trackdisk compatible disk
* decode the track to give 11*512 bytes
	bsr	read.DOS.track0

* code the track up again, to a new loaction, for comparison with the original
	bsr	code.track.again


	move.l	gfxbase(pc),a1
	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary

exit	moveq	#0,d0
	rts




*****************************
*			    *
* Subroutines *
*			    *
*****************************

read.DOS.track0
	clr.w	(g.drive.number)	use drive 0
	st	(g.head.position)	make head position invalid
	clr.w	(g.top.head)		use bottom head

	move.l	4.w,a6
	jsr	-132(a6)		Forbid

	lea	$dff000,a6
	move.w	#$8390,dmacon(a6)	set dmaen, bplen, copen, dsken

.loop	moveq	#0,d0			start at track 0
	moveq	#1,d1			1 track
	lea	decoded.data,a0		destination
	bsr.s	g.load
	bmi.s	.loop

	move.l	4.w,a6
	jsr	-138(a6)		Permit
	rts




code.track.again
	move.l	4.w,a6
	jsr	-132(a6)		Forbid

	move.l	gfxbase(pc),a6
	jsr	-456(a6)		OwnBlitter

	lea	$dff000,a6
	move.w	#$8240,dmacon(a6)	set dmaen, blten

	lea	decoded.data,a5
	bsr	g.code.DOS.track		* to new.coded.data

	move.l	gfxbase(pc),a6
	jsr	-462(a6)		DisownBlitter

	move.l	4.w,a6
	jsr	-138(a6)		Permit
	rts




* load routine  -  d0 = start track, d1 = number of tracks to read
*		   a0 = destination

g.load	subq.w	#1,d1			1 less for dbra
	bmi.s	g.no.tracks

	bsr.s	g.init.drive
	bmi.s	g.load.finished

g.load.loop
	move.w	#2,(g.load.save.attempts)

g.load.now
	movem.w	d0/d1,-(a7)		save track and count
	move.l	a0,-(a7)		save destination pointer

	bsr	g.set.head.position

	bsr	g.read.track
	bmi.s	g.load.bad

	move.l	a0,a5			destination pointer
	bsr	g.decode.DOS.track
	bmi.s	g.load.bad

	move.l	a5,a0			new destination pointer
	addq.w	#4,a7
	movem.w	(a7)+,d0/d1		get track and count
	addq.w	#1,d0			next track
	dbra	d1,g.load.loop

g.no.tracks
	moveq	#0,d4

g.load.finished
	bsr	g.drives.off
	tst.w	d4
	rts




g.load.bad
	move.l	(a7)+,a0		destination pointer
	movem.w	(a7)+,d0/d1		get track and count
	subq.w	#1,(g.load.save.attempts)
	bmi.s	g.load.finished

	bne.s	g.load.now		if zero then position head again

	st	(g.head.position)	make head position invalid
	bra.s	g.load.now




* set the disk drive up, check it is ready to load

g.init.drive
	lea	$bfd100,a4
	move.l	#$55555555,d5
	move.w	(g.drive.number),d2
	moveq	#0,d3
	addq.w	#3,d2
	bset	d2,d3			set bit for chosen drive

	move.w	(g.top.head),d2		set chosen head
	beq.s	g.correct.head
	bset	#2,d3			select top head

g.correct.head
	move.b	d3,(g.drive.select.status)
	move.b	#$7f,(a4)		no drive selected, motor on
	or.b	#$80,d3			motor on
	not.b	d3
	move.b	d3,(a4)			select drive and head, turn motor on,
;					outward direction, diskstep high
	move.w	#$c000,d2
g.drive.not.ready
	mulu	d2,d4
	mulu	d2,d4
	btst	#5,$f01(a4)		disk ready ?
	dbeq	d2,g.drive.not.ready	no

	bne	g.set.false		if drive not ready
	moveq	#0,d4
	rts




* set the disk drive head to the correct track

g.set.head.position			; d0 = track
	move.w	d0,d6
	tst.w	(g.head.position)
	bpl.s	g.head.position.valid

	bsr.s	g.head.to.track0	move to track 0 if position unknown

g.head.position.valid
	sub.w	(g.head.position),d6
	beq.s	g.step.return		if head is in required position

	add.w	d6,(g.head.position)	new head position
	move.w	d6,d0
	bpl.s	g.step.inwards

	neg.w	d0			make step amount positive

g.step.outwards
	move.b	(g.drive.select.status),d1
	or.b	#$80,d1			motor on, outward direction
	bra.s	g.step.values

g.step.inwards
	move.b	(g.drive.select.status),d1
	or.b	#$82,d1			motor on, inward direction

g.step.values
	move.b	d1,d2
	or.b	#1,d2			diskstep low
	not.b	d1
	not.b	d2

	subq.w	#1,d0			1 less for dbra

g.step.head
	move.b	d2,(a4)			set diskstep low  -  move head

	move.b	d1,(a4)			set diskstep back to high

	move.w	#1200,d3
g.step.delay
	mulu	d3,d4
	dbra	d3,g.step.delay

	dbra	d0,g.step.head		step head by required amount
g.step.return
	rts




g.head.to.track0
	btst	#4,$f01(a4)		is drive at track 0 ?
	beq.s	g.at.track0

	moveq	#1,d0			step head by one track
	bsr.s	g.step.outwards
	bra.s	g.head.to.track0

g.at.track0
	clr.w	(g.head.position)	head is at track 0
	rts




* read the data from the disk drive
*
* reads 6560 words instead of the original 5140, to get the whole DOS track
* reads into $73800 - $76b40 which is ok because boot routine starts at $76c00

g.read.track
	move.w	#$4000,dsklen(a6)	DMAEN off
	move.w	#$0002,intreq(a6)	disk DMA transfer done
	move.l	#read.coded.data,dskpth(a6)	destination
	move.w	#$6800,adkcon(a6)	zero precomp time, clear UARTBRK
	move.w	#$9500,adkcon(a6)	MFM, WORDSYNC, FAST=1 (MFM)
	move.w	#$4489,dsksync(a6)
	move.w	#6560!$8000,dsklen(a6)	DMAEN on, 6560 words of data
	move.w	#6560!$8000,dsklen(a6)	write the same value again

	moveq	#-1,d0

.loop	mulu	d0,d4
	btst	#1,intreqr+1(a6)	disk DMA transfer done ?
	dbne	d0,.loop

	beq.s	g.read.bad

	move.w	#$4000,dsklen(a6)
	moveq	#0,d4
	rts




g.read.bad
	move.w	#$4000,dsklen(a6)

g.set.false
	moveq	#-1,d4
	rts




* various routines to decode the data from the disk drive

g.decode.DOS.track			* a5 = destination, 11*512 bytes written
	move.l	a5,a3
	moveq	#11-1,d7
	lea	read.coded.data,a2		source

g.skip.sync
	cmp.w	#$4489,(a2)		sync value
	bne.s	g.decode.block
	addq.w	#2,a2			skip sync value

g.decode.block
	lea	40(a2),a0
	bsr	g.decode.longword
	move.l	d0,d6			header checksum

	move.l	a2,a0
	moveq	#40,d1		number of bytes
	bsr.s	g.calculate.checksum

	cmp.l	d0,d6
	bne.s	g.set.false		if checksums do not agree

	move.l	a2,a0
	bsr.s	g.decode.longword
	move.w	d0,d3
	swap	d0
	moveq	#-1,d1			for DOS format identification
	move.b	(g.head.position+1),d1
	add.b	d1,d1
	add.b	(g.top.head+1),d1	track number
	cmp.w	d0,d1			check for $ff TN
	bne.s	g.set.false

* sector number not validated
* sectors before track gap not validated

	lea	48(a2),a0
	bsr.s	g.decode.longword
	move.l	d0,d6			data checksum

	lea	56(a2),a0		start of data
	move.w	#1024,d1		number of bytes
	bsr.s	g.calculate.checksum

	cmp.l	d0,d6
	bne.s	g.set.false		if checksums do not agree

* use sector number to calculate destination
	move.w	d3,d1
	clr.b	d1
	add.w	d1,d1			gives sector number * 512
	lea	(a3,d1.w),a5

	lea	56(a2),a0		start of data
	move.w	#512,d0			number of output bytes
	bsr.s	g.decode.block.data

	cmp.b	#1,d3			check sectors before track gap
	beq.s	g.skip.gap

* point to start of next block, after sync markers
* (assumes there are always two sync markers)
	lea	64+1024(a2),a2
	dbra	d7,g.decode.block
	bra.s	g.decode.done

* if sectors before gap = 1 then search past next sync marker
* (there may be one or two sync markers)
*
* actually don't need to do this if last sector
g.skip.gap
	lea	56+1024(a2),a2		end of block
.skip	cmp.w	#$4489,(a2)+		sync value
	bne.s	.skip
	dbra	d7,g.skip.sync

g.decode.done
	lea	11*512(a3),a5		output end address
	moveq	#0,d4
	rts       




g.calculate.checksum
	lsr.w	#2,d1
	move.l	(a0)+,d0		get first longword
	subq.w	#2,d1			count

.loop	move.l	(a0)+,d2		get next longword
	eor.l	d2,d0			and attach
	dbra	d1,.loop

	and.l	d5,d0			remove invalid bits
	rts




g.decode.longword
	move.l	(a0)+,d0		get first longword
	move.l	(a0)+,d1		get second longword
	and.l	d5,d0			remove clock bits
	and.l	d5,d1			remove clock bits
	add.l	d0,d0			shift odd bits
	or.l	d1,d0			combine to give longword result
	rts




g.decode.block.data
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

g.drives.off
	move.b	#$ff,(a4)		no drive selected, motor off
	move.b	#$bf,(a4)		drive 3 motor off
	move.b	#$df,(a4)		drive 2 motor off
	move.b	#$ef,(a4)		drive 1 motor off
	move.b	#$f7,(a4)		drive 0 motor off
	move.b	#$ff,(a4)		no drive selected, motor off
	rts




*****************************
*			    *
* Replacement game routines *
*			    *
*****************************

;g.init.drive	equ	$73b2
* routines used :-
;g.calculate.checksum	equ	$76b6
;g.decode.longword	equ	$76c8
;g.decode.block.data	equ	$76d6
;g.code.longword		equ	$76f2
;g.correct.current.byte	equ	$76fc
;g.blit.code.data	equ	$773c


* routine used by game to decode first 10 sectors of AmigaDOS track
* replacement for $7662
*
* extra registers used (not preserved) - d3/d6/a3

g.decode.DOS.track10			* a5 = destination, 10*512 bytes written
	move.l	a5,a3
	moveq	#11-1,d7
	lea	read.coded.data,a2		source

g.skip.sync10
	cmp.w	#$4489,(a2)		sync value
	bne.s	g.decode.block10
	addq.w	#2,a2			skip sync value

g.decode.block10
	lea	40(a2),a0
	jsr	(g.decode.longword)
	move.l	d0,d6			header checksum

	move.l	a2,a0
	moveq	#40,d1			number of bytes
	jsr	(g.calculate.checksum)

	cmp.l	d0,d6
	bne	g.set.false10		if checksums do not agree

	move.l	a2,a0
	jsr	(g.decode.longword)
	move.w	d0,d3
	swap	d0
	moveq	#-1,d1			for DOS format identification
	move.b	(g.head.position+1),d1
	add.b	d1,d1
	add.b	(g.top.head+1),d1	track number
	cmp.w	d0,d1			check for $ff TN
	bne.s	g.set.false10

* sector number not validated
* sectors before track gap not validated

	move.w	d3,d1			ignore last sector
	lsr.w	#8,d1
	cmp.b	#10,d1
	beq.s	g.block.output10

	lea	48(a2),a0
	jsr	(g.decode.longword)
	move.l	d0,d6			data checksum

	lea	56(a2),a0		start of data
	move.w	#1024,d1		number of bytes
	jsr	(g.calculate.checksum)

	cmp.l	d0,d6
	bne.s	g.set.false10		if checksums do not agree

* use sector number to calculate destination
	move.w	d3,d1
	clr.b	d1
	add.w	d1,d1			gives sector number * 512
	lea	(a3,d1.w),a5

	lea	56(a2),a0		start of data
	move.w	#512,d0			number of output bytes
	jsr	(g.decode.block.data)

g.block.output10
	cmp.b	#1,d3			check sectors before track gap
	beq.s	g.skip.gap10

* point to start of next block, after sync markers
* (assumes there are always two sync markers)
	lea	64+1024(a2),a2
	dbra	d7,g.decode.block10
	bra.s	g.decode.done10

* if sectors before gap = 1 then search past next sync marker
* (there may be one or two sync markers)
* maybe shouldn't do this if last sector
g.skip.gap10
	lea	56+1024(a2),a2		end of block
.skip	cmp.w	#$4489,(a2)+		sync value
	bne.s	.skip
	dbra	d7,g.skip.sync10

g.decode.done10
	lea	10*512(a3),a5		output end address
	moveq	#0,d4
	rts       

g.set.false10
	moveq	#-1,d4
	rts
;g.decode.DOS.track.size	equ	*-g.decode.DOS.track



* routine used by game to code AmigaDOS track
* only first 10 sectors are populated with data, 11th sector is blank
* replacement for $75ea
*
* extra registers used (not preserved) - d4/d7

g.code.DOS.track			* a5 = source, 10*512 bytes read
	lea	new.coded.data,a2		destination
	move.w	#6560/2-1,d0
	move.l	#$aaaaaaaa,d1

.loop	move.l	d1,(a2)+		save data for track gap
	dbra	d0,.loop

	lea	new.coded.data+1140,a2
	moveq	#0,d7			start at sector 0

g.next.sector
	moveq	#-1,d0
	move.b	(g.head.position+1),d0
	add.b	d0,d0
	add.b	(g.top.head+1),d0	track number
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
	jsr	(g.code.longword)	code block information

	moveq	#4-1,d4			4 longwords

.loop	moveq	#0,d0
	jsr	(g.code.longword)
	dbra	d4,.loop		code unused part

	lea	8(a2),a0
	moveq	#40,d1			number of bytes
	jsr	(g.calculate.checksum)

	lea	48(a2),a0
	jsr	(g.code.longword)	code header checksum

	cmp.b	#10,d7			NOTE: leave last sector blank
	beq.s	g.data.coded

	move.w	#512,d0			number of bytes
	move.l	a5,a0			source
	lea	64(a2),a1		destination
	jsr	(g.blit.code.data)

g.data.coded
	lea	64+1024(a2),a0
	jsr	(g.correct.current.byte)

	lea	64(a2),a0
	move.w	#1024,d1		number of bytes
	jsr	(g.calculate.checksum)

	lea	56(a2),a0
	jsr	(g.code.longword)	code data checksum
	rts
;g.code.DOS.size	equ	*-g.code.DOS.track


*********************************
*				*
* Replacement game routines end *
*				*
*********************************



g.code.longword				; d0 = longword
	move.l	d0,d3
	lsr.l	#1,d0
	bsr.s	g.code.bits		code odd bits

	move.l	d3,d0
	bsr.s	g.code.bits		code even bits

g.correct.current.byte
	move.b	(a0),d0			get next byte
	bclr	#7,d0			reset clock bit

	btst	#6,d0
	bne.s	g.byte.correct

	btst	#0,-1(a0)
	bne.s	g.byte.correct

	bset	#7,d0			set clock bit if adjacent bits clear

g.byte.correct
	move.b	d0,(a0)			save byte
	rts




g.code.bits
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
	beq.s	g.bits.ok			if previous byte ended with a 0 bit

	bclr	#31,d0			reset first bit

g.bits.ok
	move.l	d0,(a0)+		save longword result
	rts




g.blit.code.data				; d0 = number of bytes (modulo 32)
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




;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

gfxbase		dc.l	0

g.drive.number	dc.w	0	* was $23d0
g.head.position	dc.w	0	* was $23d2
g.top.head	dc.w	0	* was $23d4
g.load.save.attempts	dc.w	0	* was $23d6
g.drive.select.status	dc.w	0	* was $23d8


decoded.data	ds.b	11*512

read.coded.data	ds.w	6560
			ds.w	16		safety margin

new.coded.data	ds.w	6560
			ds.w	16		safety margin




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
