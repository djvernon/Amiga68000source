	section saveTrackRaw,code_c


; Read track raw (i.e. don't decode) and write data to file


TRACK_NUMBER	equ	2

TRACK_LEN	equ	6560


	move.l	4.w,a6
	IFND	DEBUG
	jsr	-132(a6)		Forbid
	ENDC


*"""""""""""""""""""""""""
*" INITIALISE INTERRUPTS "
*"			 "
*"""""""""""""""""""""""""

	IFND	DEBUG
	lea	custom,a6
	move.w	intenar(a6),old.ints	save system interrupt status

	move.w	#$7fff,intena(a6)	disable all interrupts

;	move.l	$64.w,old.level1
;	move.l	$68.w,old.level2
;	move.l	$6c.w,old.level3
;	move.l	$70.w,old.level4
;	move.l	$74.w,old.level5
;	move.l	$78.w,old.level6
;	move.l	$7c.w,old.level7
;	move.l	#new.level1,$64.w
;	move.l	#new.level2,$68.w
;	move.l	#new.level3,$6c.w
;	move.l	#new.level4,$70.w
;	move.l	#new.level5,$74.w
;	move.l	#new.level6,$78.w
;	move.l	#new.level7,$7c.w

;	move.w	#$e839,intena(a6)	enable interrupts


	move.l	$14.w,old.dbz		division-by-zero exception handler
	move.l	#rte.ins,$14.w		set to rte instruction
	ENDC


*"""""""""""""""""""""
*" CALL MAIN PROGRAM "
*"		     "
*"""""""""""""""""""""

	bsr	read_track_raw


*""""""""""""""""
*" EXIT ROUTINE	"
*"		"
*""""""""""""""""

	bsr	waitvbl			wait for disk activity to finish
	bsr	waitvbl

	IFND	DEBUG
	lea	custom,a6
wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait


	move.w	#$7fff,intena(a6)	disable all interrupts

;	move.l	old.level1(pc),$64.w
;	move.l	old.level2(pc),$68.w
;	move.l	old.level3(pc),$6c.w
;	move.l	old.level4(pc),$70.w
;	move.l	old.level5(pc),$74.w
;	move.l	old.level6(pc),$78.w
;	move.l	old.level7(pc),$7c.w

	move.w	old.ints(pc),d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status

	move.l	old.dbz(pc),$14.w	restore division-by-zero handler


;	move.w	#$03ff,dmacon(a6)	DMA off
	ENDC

;	move.l	gfxbase(pc),a1
;	IFND	DEBUG
;	move.l	38(a1),cop1lch(a6)	restore system copper

;	move.w	#$87f0,dmacon(a6)	DMA on
;	ENDC


exit_now
	move.l	4.w,a6
	IFND	DEBUG
	jsr	-138(a6)		Permit
	ENDC

	bsr	save_track_raw

	moveq	#0,d0
	rts


rte.ins	rte


*"""""""""""""
*" VARIABLES "
*"	     "
*"""""""""""""

old.ints	dc.w	0
;old.level1	dc.l	0
;old.level2	dc.l	0
;old.level3	dc.l	0
;old.level4	dc.l	0
;old.level5	dc.l	0
;old.level6	dc.l	0
;old.level7	dc.l	0
old.dbz		dc.l	0

DOSBase	dc.l	0
StdOutHandle	dc.l	0
OutFileName	dc.l	0
OutFileHandle	dc.l	0
OutFileMem	dc.l	0
OutFileLen	dc.l	0


*"""""""""""""
*" CONSTANTS "
*"	     "
*"""""""""""""

dosname	dc.b	'dos.library',0
	even

TrackRawFileName	dc.b	"dh0:TrackRaw.bin",0
	even
;TrackFileName	dc.b	"dh0:SHOTrack.bin",0
;	even


;"""""""""""""""""""""
;" OTHER SUBROUTINES "
;"		     "
;"""""""""""""""""""""

initDrive
;L7205c
	clr.w	$dff024			DSKLEN
	move.b	#$7d,$bfd100
	move.b	#$75,$bfd100		motor on, select drive 0 (i.e. bit 3 clear), bottom head (i.e. bit 2 set), inward direction (i.e. bit 1 clear)
	move.w	#$4489,$dff07e
	move.w	#$8400,$dff09e		WORDSYNC
	move.w	#$8100,$dff09e		MFM
	move.w	#$8010,$dff096		enable disk DMA (TODO NB with DMAEN also set, otherwise no DMA is enabled)
;    MOVE.W    #$8210,$00DFF096		enable disk DMA (NB with DMAEN also set, otherwise no DMA is enabled)
	move.w	#$2,$dff09c		no DSKBLK interrupt
	rts


TRACK	equr	d1


read_track_raw
	bsr	initDrive
	bsr	stepDriveBackAndForth
	st	currentTrack
;	lea	L726ae(pc),a0		destination
	moveq	#TRACK_NUMBER,TRACK
;	moveq	#0,START_SECTOR
;	moveq	#1,NUM_SECTORS

;L722f8
	moveq	#$3,d2			number of retries
L722fa
	lea	currentTrack(pc),a1
	cmp.w	(a1),d1
	beq	L7230e
	bsr	moveHeadToTrack
;	bsr	printCurrentTrack	DJV debug
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
	btst	#$4,$bfdd00		INDEX
	beq.s	L72348
	move.w	#TRACK_LEN!$8000,$dff024	DSKLEN
	move.w	#TRACK_LEN!$8000,$dff024
L7236e
	move.w	$dff01e,d0
	btst	#$1,d0
	bne.s	L72396
	btst	#$4,$bfdd00
	beq.s	L7236e
	clr.w	$dff024
	move.w	#$2,$dff09c
	bra	L7252c

;track now read
L72396
	clr.w	$dff024
	move.w	#$2,$dff09c


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


currentTrack
;L726a6
	dc.w	$ffff
;destAddr
;L726a8
;	dc.w	$0000,$0000
topSide
;L726ac
	dc.w	$0000


save_track_raw
	move.l	#TrackRawFileName,OutFileName
	move.l	#trackDataRaw,OutFileMem
	move.l	#TRACK_LEN*2,OutFileLen
	bra	save_memory



save_memory
* Open the DOS library

	moveq	#0,d0
	lea	dosname(pc),a1
	move.l	4.w,a6
	jsr	-552(a6)		OpenLibrary
	move.l	d0,DOSBase
	beq	return_now

* Get standard output handle

	move.l	DOSBase(pc),a6
	jsr	-60(a6)			Output
	move.l	d0,StdOutHandle

* Open output file

	move.l	OutFileName(pc),d1
	move.l	#1006,d2		MODE_NEWFILE
	move.l	DOSBase(pc),a6
	jsr	-30(a6)			Open
	move.l	d0,OutFileHandle
;	beq	error6
	beq	closedos

* Write memory to file

	move.l	OutFileHandle(pc),d1
	move.l	OutFileMem(pc),d2
	move.l	OutFileLen(pc),d3	Length
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
;	tst.l	d0
;	bmi	error7

* Close output file

	move.l	OutFileHandle(pc),d1
	move.l	DOSBase(pc),a6
	jsr	-36(a6)			Close

closedos
	move.l	DOSBase(pc),a1
	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary

return_now
	rts


diskBuffer
trackDataRaw
	ds.w	TRACK_LEN



*""""""""""""""""""""""
*" HARDWARE REGISTERS "
*"		      "
*""""""""""""""""""""""

custom	equ	$dff000
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
aud0lch	equ	$0a0
aud0len	equ	$0a4
aud0per	equ	$0a6
aud0vol	equ	$0a8
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
color0	equ	$180
color1	equ	$182
color2	equ	$184
color4	equ	$188
color8	equ	$190
color16	equ	$1a0

CIAA	equ	$bfe001
CIAB	equ	$bfd000
TBLO	equ	$600			CIA equates
TBHI	equ	$700
KEY	equ	$c00
ICR	equ	$d00
CRA	equ	$e00
CRB	equ	$f00

;$bfe001 bits
RDY	equ	5
TK0	equ	4
CHNG	equ	2
