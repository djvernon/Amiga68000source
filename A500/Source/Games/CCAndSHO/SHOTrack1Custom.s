
* Customised Super Hang-On loader code, destined for track 1 *
* NB The Super Hang-On boot routine loads this code to address $72000 onwards

;	Steps to create SHOLoader binary:-
;	1) Assemble this source file to disk (with Debug Symbols: None, Processor: 68000)
;	2) Use HxD to remove the first 32 bytes and last 4 bytes (AmigaDOS executable headers / end)


	org	$72000


;USE_COPY_PROTECTION	equ	1
USE_INDEX_SIGNAL	equ	1

TRACK_LEN	equ	5656


L72000
	lea	$72016,a6
	bra	L720d8


initDrive
;L7205c
	clr.w	$dff024			DSKLEN
	move.b	#$7d,$bfd100
	move.b	#$75,$bfd100		motor on, select drive 0 (i.e. bit 3 clear), bottom head (i.e. bit 2 set), inward direction (i.e. bit 1 clear)
	move.w	#$4489,$dff07e
	move.w	#$8400,$dff09e		WORDSYNC
	move.w	#$8100,$dff09e		MFM
;	move.w	#$8010,$dff096		enable disk DMA (NB assumes DMAEN is already set, otherwise no DMA is enabled)
	move.w	#$8210,$dff096		enable disk DMA (NB with DMAEN also set, otherwise no DMA is enabled on A1200 e.g. when running from Devpac)
	move.w	#$2,$dff09c		no DSKBLK interrupt
	rts


TRACK	equr	d1
START_SECTOR	equr	d2
NUM_SECTORS	equr	d3

SECTORS_PER_TRACK	equ	11


readTrack2Sector0
;L7209c
	bsr	initDrive
	bsr	stepDriveBackAndForth
	st	currentTrack
	lea	L726ae(pc),a0		destination
	moveq	#2,TRACK		track 2
	moveq	#0,START_SECTOR
	moveq	#1,NUM_SECTORS
	bsr	readSectorsFromTrack
	tst.l	d0
	bpl.s	L720be
	rts


L720be
	lea	L726ae(pc),a0
	lea	L7269e(pc),a1
	moveq	#$7,d7
L720c8
	cmpm.b	(a0)+,(a1)+
	bne.s	L720d4
	dbra	d7,L720c8
	moveq	#$0,d0
	rts


L720d4
	moveq	#-$21,d0		; #$ffffffdf
	rts


;* starts with a6 = #$72016
L720d8
	lea	-$16(a6),a6
	lea	$180,a7
	bsr	readTrack2Sector0
	tst.l	d0
	bmi	L7268a
	lea	$300,a0
	move.l	#'SLOG',d0
	bsr	L72228
	move.l	a6,-(a7)
	jsr	$300
	movea.l	(a7)+,a6
	lea	$60000,a0
	move.l	#'MUSC',d0
	bsr	L72228
	move.l	a6,-(a7)
	jsr	$300
	movea.l	(a7)+,a6
	lea	$20000,a0
	move.l	#'LDSC',d0
	bsr	L72228
	lea	$20000,a0
	lea	$50000,a1
	move.l	(a0)+,d2
	add.l	a0,d2
L72140
	moveq	#$0,d0
	move.b	(a0)+,d0
	bmi.s	L7214e
L72146
	move.b	(a0)+,(a1)+
	dbra	d0,L72146
	bra.s	L7215a


L7214e
	neg.b	d0
	bmi.s	L7215a
	move.b	(a0)+,d1
L72154
	move.b	d1,(a1)+
	dbra	d0,L72154
L7215a
	cmp.l	a0,d2
	bhi.s	L72140

	move.l	#loadScreenCopper,$dff080
	bsr	waitvbl
	move.w	#$5200,$dff100
	clr.w	$dff102
	move.w	#$24,$dff104
	move.w	#$30,$dff092
	move.w	#$d8,$dff094
	move.w	#$2471,$dff08e
	move.w	#$46d1,$dff090
	move.w	#$b0,$dff108
	move.w	#$b0,$dff10a
	lea	L7264a(pc),a0
	lea	$dff180,a1
	moveq	#$f,d0
L721be
	move.l	(a0)+,(a1)+
	dbra	d0,L721be
	move.l	a6,-(a7)
	jsr	$60000
	movea.l	(a7)+,a6
	lea	$300,a0
	move.l	#'GAME',d0
	bsr	L72228
	move.l	$180,d0
	beq.s	L7221e			skip loading into extra RAM
	move.w	#$1,topSide		select top side of disk
	st	currentTrack
	movea.l	d0,a0
	moveq	#$1,d1
L721f8
	moveq	#0,START_SECTOR
	moveq	#SECTORS_PER_TRACK,NUM_SECTORS
	move.w	d1,-(a7)
	bsr	readSectorsFromTrack
	move.w	(a7)+,d1
	tst.l	d0
	bne	L72216
	movea.l	a1,a0
	addq.w	#1,TRACK
	cmp.w	#$4f,TRACK
	bls.s	L721f8
	bra.s	L7221e


L72216
	movea.l	$180,a0
	clr.l	(a0)
L7221e
	bsr	drivesOff


;WIP 31/07/2019
;* activate cheat
	move.b	#$4e,$119c
	move.b	#$71,$119d
	move.b	#$60,$119e
;End WIP 31/07/2019

	IFND	USE_COPY_PROTECTION
	lea	skipSecondRead(pc),a1
	move.l	(a1)+,$57d8		jmp	$5848.w
	move.w	(a1)+,$5862		addq.w	#8,a0
	move.l	(a1)+,$5864		jmp	$5896.w
;	ELSE
;* Test replace 'bhi	L593e' with NOPs
;	move.w	#$4e71,$5892
;	move.w	#$4e71,$5894
	ENDC

; Fix save of high score tables (on A1200 at least)
	move.w	#$6e00,$5c64		ADKCON value with WORDSYNC clear (original didn't clear it)
	;move.w	#$9100,$5c6c		Can also change PRECOMP from 140ns to zero, but isn't essential
	jmp	$300

skipSecondRead
	jmp	$5848.w
skipProtection
	addq.w	#8,a0
	jmp	$5896.w


L72228
	move.l	a0,destAddr
	movea.l	(a7),a0
L72230
	clr.w	(a6)+			; Think this is deliberately wiping earlier code
	cmpa.l	a6,a0
	bne.s	L72230
	lea	L726b6(pc),a0
	moveq	#$3e,d7
L7223c
	tst.b	(a0)
	beq	L7224c
	cmp.l	(a0)+,d0
	beq.s	L72250
	addq.w	#4,a0
	dbra	d7,L7223c
L7224c
	moveq	#-$22,d0		; #$ffffffde
	rts


L72250
	moveq	#$0,TRACK
	moveq	#$0,START_SECTOR
	move.b	(a0)+,TRACK
	move.b	(a0)+,START_SECTOR
	moveq	#$0,d7
	move.w	(a0),d7			; Total number of sectors
	movea.l	destAddr(pc),a0
	move.w	#11,d3			; Sectors per track
	sub.w	START_SECTOR,d3
	bra.s	L7226c


L72268
	movea.l	a1,a0
	moveq	#11,d3			; Sectors per track
L7226c
	cmp.w	d3,d7
	bcc.s	L72272
	move.w	d7,d3
L72272
	movem.w	d1-d3/d7,-(a7)
	bsr	readSectorsFromTrack
	movem.w	(a7)+,d1-d3/d7
	tst.l	d0
	bmi.s	L7228e
	moveq	#$0,d2
	addq.w	#1,d1
	sub.w	d3,d7
	bhi.s	L72268
	moveq	#$0,d0
	rts


L7228e
	bsr	stepDriveBackAndForth
	bra.s	L72272


drivesOff
;L72294
	clr.w	$dff024
	move.b	#$7d,$bfd100
	move.b	#$fd,$bfd100
	move.b	#$f5,$bfd100
	move.b	#$fd,$bfd100
	move.w	#$10,$dff096
	rts


;* read sectors from current track
readSectorsFromTrack
;L722c4
	cmp.w	currentTrack(pc),TRACK
	beq.s	trackRead
	movem.l	d1-d3/a0,-(a7)
	bsr	readTrack
	movem.l	(a7)+,d1-d3/a0
	tst.l	d0
	bpl.s	trackRead
	rts


trackRead
;L722dc
	lea	diskBuffer(pc),a1
	mulu.w	#$200,START_SECTOR
	adda.w	START_SECTOR,a1
	mulu.w	#$200,d3
	bra.s	L722ee


copySectors
;L722ec
	move.b	(a1)+,(a0)+
L722ee
	dbra	d3,copySectors
	movea.l	a0,a1
	moveq	#$0,d0
	rts


readTrack
;L722f8
	moveq	#$3,d2			number of retries
L722fa
	lea	currentTrack(pc),a1
	cmp.w	(a1),d1
	beq	L7230e
	bsr	moveHeadToTrack
	tst.l	d0
	bmi	L7252a
L7230e
	move.w	#$4489,$dff07e
	move.w	#$8500,$dff09e
	lea	diskBuffer(pc),a0
	move.l	a0,$dff020
	tst.w	topSide
	beq.s	L72338
	move.b	#$71,$bfd100		select top head (i.e. bit 2 clear)
L72338
	btst	#RDY,$bfe001
	bne.s	L72338
	tst.b	$bfdd00
L72348
	btst	#RDY,$bfe001
	bne	L72528

	IFD	USE_INDEX_SIGNAL
	btst	#$4,$bfdd00		INDEX
	beq.s	L72348
	ENDC

	move.w	#TRACK_LEN!$8000,$dff024	DSKLEN
	move.w	#TRACK_LEN!$8000,$dff024
L7236e
	move.w	$dff01e,d0
	btst	#$1,d0
	bne.s	L72396

	IFD	USE_INDEX_SIGNAL
	btst	#$4,$bfdd00
	beq.s	L7236e
	clr.w	$dff024
	move.w	#$2,$dff09c
	bra	L7252c
	ELSE
	bra.s	L7236e
	ENDC

;track now read
L72396
	clr.w	$dff024
	move.w	#$2,$dff09c

	IFD	USE_COPY_PROTECTION
; Now read second copy (just 18 words this time)
;	lea	LEnd+$24cc(pc),a1		;L754e0
;	move.l	a1,$dff020
;	tst.b	$bfdd00
;L723b4
;	btst	#RDY,$bfe001
;	bne	L72528
;	btst	#$4,$bfdd00		INDEX
;	beq.s	L723b4
;	move.w	#$8012,$dff024		DSKLEN
;	move.w	#$8012,$dff024		18 words
;L723da
;	move.w	$dff01e,d0
;	btst	#$1,d0
;	bne.s	L72402
;	btst	#$4,$bfdd00
;	beq.s	L723da
;	clr.w	$dff024
;	move.w	#$2,$dff09c
;	bra	L7252c

;first 18 words of track now read
;L72402
;	clr.w	$dff024
;	move.w	#$2,$dff09c
	ENDC

; Check the markers bytes in the track data
	moveq	#$9,d0
L72412
	cmpi.w	#$4489,(a0)+
	bne.s	L72420
	cmpi.l	#$2aaaaaaa,(a0)
	beq.s	L72428
L72420
	dbra	d0,L72412
	bra	L7252c
L72428
	addq.w	#4,a0

	IFD	USE_COPY_PROTECTION
; Check the markers bytes in the second copy of track data
;	moveq	#$9,d0
;L7242c
;	cmpi.w	#$4489,(a1)+
;	bne.s	L7243a
;	cmpi.l	#$2aaaaaaa,(a1)
;	beq.s	L72442
;L7243a
;	dbra	d0,L7242c
;	bra	L7252c

;L72442
;	addq.w	#4,a1
	ENDC


	IFD	USE_COPY_PROTECTION
; Compare the next eight bytes from both reads
; Check there are not more than three matching bytes
;	moveq	#$7,d1
;L72446
;	cmpm.b	(a0)+,(a1)+
;	seq	d0
;	swap	d1
;	sub.b	d0,d1
;	swap	d1
;	dbra	d1,L72446
;	swap	d1
;	cmp.b	#$3,d1
;	bhi	L7252c

	ELSE
	addq.w	#8,a0		DJV instead skip past the eight bytes
	ENDC

	addq.w	#4,a0
	move.w	#$4489,d0
	moveq	#$4,d1
L72466
	cmp.w	(a0)+,d0
	beq.s	L72472
	dbra	d1,L72466
	bra	L7252c


L72472
	cmp.w	(a0),d0
	bne.s	L72478
	addq.w	#2,a0
L72478
	cmpi.w	#$2aaa,(a0)+
	bne	L7252c
	move.w	#$8440,$dff096
	bsr	blit.wait
	clr.l	$dff060
	clr.l	$dff064
	move.l	#$ffffffff,$dff044
	move.w	#$5555,$dff070
	lea	L728ae(pc),a1
	move.l	a1,$dff054
	move.l	a0,$dff050
	adda.w	#5642,a0
	move.l	a0,$dff04c
	move.l	#$de4f000,$dff040	USE A,B,D	D = A.C + B.notC	B shifted right one position
	move.w	#$b044,$dff058		705*64+4 -> 705*4*2 = 5640 bytes
	bsr	blit.wait
	tst.w	(a1)+
	bne.s	L7252c
	tst.w	topSide
	bne.s	L724fe

; Bottom side of disk: Decode the data
	pea	(a1)
	addq.w	#2,a1
	move.w	#$580,d1
	move.l	#$12345678,d0
L724f4
	eor.l	d0,(a1)
	move.l	(a1)+,d0
	dbra	d1,L724f4
	movea.l	(a7)+,a1
L724fe
	move.w	#$57f,d1
	moveq	#$0,d0
	move.w	(a1)+,d0
L72506
	add.l	(a1)+,d0
	dbra	d1,L72506
	cmp.l	(a1),d0
	beq.s	L72514
	moveq	#-$4,d0		; #$fffffffc
	bra.s	L7252e


L72514
	move.w	currentTrack(pc),d1
	lea	L728b0(pc),a1
	cmp.w	(a1),d1
	beq.s	L72524
	moveq	#-$6,d0		; #$fffffffa
	bra.s	L72538


L72524
	moveq	#$0,d0
	rts


L72528
	moveq	#-$2,d0		; #$fffffffe
L7252a
	rts


L7252c
	moveq	#-$7,d0		; #$fffffff9
L7252e
	move.w	currentTrack(pc),d1
	btst	#$0,d2
	bne.s	L7253e
L72538
	st	currentTrack
L7253e
	dbra	d2,L722fa
	rts


;move disk head to required track
;d1 = required track
moveHeadToTrack
;L72544
	tst.w	(a1)
	bpl.s	L7255e		when track number known
	bsr	waitvbl
toTrack0
;L7254c
	btst	#TK0,$bfe001	is head at track 0 ?
	beq.s	atTrack0
	bsr	stepOutwards2
	bra.s	toTrack0


atTrack0
;L7255c
	clr.w	(a1)
L7255e
	cmp.b	$1(a1),d1
	bne.s	moveHead
	clr.b	(a1)
	moveq	#$0,d0
	rts


moveHead
;L7256a
	bsr	waitvbl
	move.w	(a1),d0
	move.w	d1,(a1)
	sub.w	d0,d1
	bhi.s	L72590
	neg.w	d1
	bne.s	L72584
	moveq	#$0,d0
	rts


L7257e
	bsr	stepOutwards
	bmi.s	L72598
L72584
	dbra	d1,L7257e
	rts


L7258a
	bsr	stepInwards
	bmi.s	L72598
L72590
	dbra	d1,L7258a
	rts


L72596
	moveq	#-$e,d0		; #$fffffff2
L72598
	rts


* just steps drive back and forth one track, ending up in its original position
stepDriveBackAndForth
;L7259a
	bsr	waitvbl
	btst	#TK0,$bfe001	is head at track 0 ?
	beq.s	L725ac
	bsr.s	stepOutwards2
	bra.s	stepInwards2


;* at track 0
L725ac
	bsr.s	stepInwards2
	bra.s	stepOutwards2


stepInwards
;L725b0
	btst	#CHNG,$bfe001
	beq.s	L72596
stepInwards2
;L725ba
	move.b	#$74,$bfd100
	move.b	#$75,$bfd100
	bsr	waitvbl
	moveq	#$0,d0
	rts


stepOutwards
;L725d2
	btst	#CHNG,$bfe001
	beq.s	L72596
stepOutwards2
;L725dc
	move.b	#$76,$bfd100
	move.b	#$77,$bfd100
	bsr	waitvbl
	moveq	#$0,d0
	rts


waitvbl
;L725f4
	move.w	#$20,$dff09c
L725fc
	move.w	$dff01e,d0
	btst	#$5,d0
	beq.s	L725fc
	move.w	#$20,$dff09c
	rts


blit.wait
;L72612
	btst	#$6,$dff002
	bne.s	blit.wait
	rts


loadScreenCopper
;L7261e
	dc.w	$f0e0,$0005,$f0e2,$0000,$f0e4,$0005,$f0e6,$002c,$f0e8,$0005,$f0ea,$0058,$f0ec,$0005,$f0ee,$0084
	dc.w	$f0f0,$0005,$f0f2,$00b0,$ffff,$fffe
L7264a
	dc.w	$0000,$0500,$0222,$0333,$0444,$0888,$0666,$0a30,$0f80,$0bbb,$0660,$0880,$0cb0,$0f55,$0f33,$0700
	dc.w	$0ff0,$0e00,$0a00,$0fff,$04a0,$0490,$0480,$0330,$0acf,$08bf,$069f,$028f,$006f,$004f,$002f,$000f


L7268a
	lea	L7268a(pc),a0
L7268e
	clr.w	(a6)+
	cmpa.l	a6,a0
	bne.s	L7268e
	movea.l	$0,a0
	reset
	jmp	(a0)


L7269e
	dc.w	$5348,$4f2e,$626f,$6f74		;'SHO.boot'

currentTrack
;L726a6
	dc.w	$ffff
destAddr
;L726a8
	dc.l	0
topSide
;L726ac
	dc.w	0
L726ae
	ds.w	4
L726b6
	ds.w	252
L728ae
	ds.w	1
L728b0
	ds.w	1
diskBuffer
;L728b2
	ds.w	945
LEnd
;$73014


;$bfe001 bits
RDY	equ	5
TK0	equ	4
CHNG	equ	2
