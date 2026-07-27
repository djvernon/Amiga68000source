	section Test,code_c


; Test code and decode of MFM disk data (e.g. for one track)


TRACK_LEN	equ	6560


;DEBUG	equ	1


	move.l	4.w,a6
	moveq	#0,d0
	lea	graf.name(pc),a1
	jsr	-552(a6)		OpenLibrary
	move.l	d0,gfxbase
	beq	exit_now


*"""""""""""""""""""""
*" CALL MAIN PROGRAM "
*"		     "
*"""""""""""""""""""""

;	move.l	#$55555555,d5		mask
;;	move.l	#$00000002,d0
;	move.l	trackData,d0
;	lea	testBuf,a0
;	bsr	code.longword


	bsr	ownBlitter

	move.l	#$55555555,d5		mask
	lea	custom,a6

;	move.l	#$417C1956,trackData
;	move.l	#$3127205A,trackData+4
;	move.l	#$31232033,trackData+8
	move.w	#2,currentTrack
	lea	trackData,a5		source pointer
	bsr.s	code.SHO.track

	bsr	disownBlitter


	move.w	#2,currentTrack
	lea	diskBuffer,a0
	lea	SHO_TRACK_OFFSET(a0),a0
	bsr	decodeTrack


*""""""""""""""""
*" EXIT ROUTINE	"
*"		"
*""""""""""""""""

	move.l	gfxbase(pc),a1
	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary

exit_now
	moveq	#0,d0
	rts


*"""""""""""""
*" VARIABLES "
*"	     "
*"""""""""""""

gfxbase	dc.l	0


*"""""""""""""
*" CONSTANTS "
*"	     "
*"""""""""""""

graf.name	dc.b	'graphics.library',0
	even


SHO_TRACK_DATA_SIZE	equ	(512*11)
SOURCE_BYTES	equ	(2+2+SHO_TRACK_DATA_SIZE+4)	; Word zero, word track number, 11 sectors, long checksum

SHO_TRACK_OFFSET	equ	1140		; Offset to prepared raw data (after first section of gap data)


code.SHO.track				; a5 = source
; 1. Prepare the track data for encoding
; Save the four bytes before and after the source track data, as the header and trailer will be placed here for encoding
; (This is much quicker than having to copy the entire source track data to another buffer with space either side)
	move.l	-4(a5),-(sp)
	lea	SHO_TRACK_DATA_SIZE(a5),a1
	move.l	(a1),-(sp)

; Save header (zero word and track number word)
	clr.w	-4(a5)			zero word
	move.w	currentTrack,-2(a5)	track number

; Save trailer (checksum)
	lea	-2(a5),a1
	move.w	#(SHO_TRACK_DATA_SIZE/4),d1
	bsr	calculate.SHO.checksum
	lea	SHO_TRACK_DATA_SIZE(a5),a1
	move.l	d0,(a1)

; Encrypt the data (excluding header but including trailer)
	move.l	a5,a1
	move.w	#((SHO_TRACK_DATA_SIZE+4)/4),d1
	bsr	encrypt.SHO.data

; 2. Prepare the track raw (encoded) data
; Fill beginning of track raw buffer with $AAAAAAAA
; (This is an optimisation: just filling the first gap section rather than the whole raw buffer (as most of it will be overwritten below anyway)
	lea	trackDataRaw,a2		destination
	move.w	#((SHO_TRACK_OFFSET+4)/4)-1,d0	NB doing one extra long as the sync markers start at offset 4
	move.l	#$aaaaaaaa,d1

.gap1	move.l	d1,(a2)+		save data for track gap (before data)
	dbra	d0,.gap1

	lea	trackDataRaw+SHO_TRACK_OFFSET,a2
	move.l	#$44894489,4(a2)	two sync markers

;$AAAAAAAA (Clock bit corrected to $2AAAAAAA)
	move.l	#$2aaaaaaa,8(a2)

;Eight unknown bytes (possibly with invalid clock bits)
	move.l	#$aaaaaaaa,12(a2)	TODO try as 0 or other invalid bits
	move.l	#$aaaaaaaa,16(a2)	TODO try as 0 or other invalid bits

;$AAAAAAAA
	move.l	#$aaaaaaaa,20(a2)

;$44894489 - two sync markers.
	move.l	#$44894489,24(a2)	two sync markers

;$AAAA (Clock bit corrected to $2AAA)
	move.w	#$2AAA,28(a2)

; Use blitter to encode the track data
	move.w	#SOURCE_BYTES,d0	number of bytes
	lea	-4(a5),a0		source, including header
	lea	30(a2),a1		destination
	bsr	blit.code.SHO.data

; Fill remainder of track raw buffer with $AAAAAAAA
	lea	30+(SOURCE_BYTES*2)(a2),a2
	move.l	a2,a0			save address for byte correction later
	move.w	#(((TRACK_LEN*2)-SHO_TRACK_OFFSET-30-(SOURCE_BYTES*2))/4),d0	NB doing one extra long as the remaining bytes may not be a longword multiple
	move.l	#$aaaaaaaa,d1

.gap2	move.l	d1,(a2)+		save data for track gap (after data)
	dbra	d0,.gap2

; No need to correct first byte of encoded data, as it follows the $2aaa above

; Correct the byte following the encoded data
;	lea	30+(SOURCE_BYTES*2)(a2),a0
	bsr	correct.current.byte

; Restore the four bytes before and after the source track data
	lea	SHO_TRACK_DATA_SIZE(a5),a1
	move.l	(sp)+,(a1)
	move.l	(sp)+,-4(a5)

	lea	SHO_TRACK_DATA_SIZE(a5),a5	update source pointer
	rts


calculate.SHO.checksum
	subq.w	#1,d1			count
	moveq	#0,d0
	move.w	(a1)+,d0		start with track number
.loop	add.l	(a1)+,d0
	dbra	d1,.loop
	rts


encrypt.SHO.data
	subq.w	#1,d1			count
	move.l	#$12345678,d0
.encrypt
	move.l	(a1),d7
	eor.l	d0,(a1)+
	move.l	d7,d0
	dbra	d1,.encrypt
	rts


ownBlitter
	move.l	gfxbase,a6
	IFND	DEBUG
	jsr	-456(a6)		OwnBlitter
	ENDC
	rts


disownBlitter
	move.l	gfxbase,a6
	IFND	DEBUG
	jsr	-462(a6)		DisownBlitter
	ENDC
	rts


decodeTrack
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

	addq.w	#8,a0		DJV instead skip past the eight bytes

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

	move.l	a0,-(sp)
	bsr	ownBlitter
	move.l	(sp)+,a0

	move.w	#$8440,$dff096
	bsr	blit.wait
	clr.l	$dff060
	clr.l	$dff064
	move.l	#$ffffffff,$dff044
	move.w	#$5555,$dff070
	lea	L728ae,a1
	move.l	a1,$dff054
	move.l	a0,$dff050
	adda.w	#5640+2,a0		The +2 is to account for the shift right 15 below
	move.l	a0,$dff04c
	move.l	#$de4f000,$dff040	USE A,B,D	D = A.C + B.notC	B shifted right 15 positions
	move.w	#$b044,$dff058		705*64+4 -> 705*4*2 = 5640 bytes
	bsr	blit.wait

	bsr	disownBlitter
	lea	L728ae,a1

	tst.w	(a1)+
	bne.s	L7252c
	tst.w	topSide
	bne.s	L724fe

; Bottom side of disk: Decrypt the data
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
	move.w	(a1)+,d0	track number
L72506
	add.l	(a1)+,d0
	dbra	d1,L72506
	cmp.l	(a1),d0
	beq.s	L72514
	moveq	#-$4,d0		; #$fffffffc
	bra.s	L7252e


L72514
	move.w	currentTrack(pc),d1
	lea	L728b0,a1
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
;	move.w	currentTrack(pc),d1
;	btst	#$0,d2
;	bne.s	L7253e
L72538
;	st	currentTrack
L7253e
	rts


blit.wait
;L72612
	btst	#$6,$dff002
	bne.s	blit.wait
	rts


currentTrack
;L726a6
	dc.w	$ffff
topSide
;L726ac
	dc.w	$0000


L728ae
	ds.w	1
L728b0
	ds.w	1
diskBuffer
trackDataRaw
;	incbin	DiskData/rawTracks/Track2/Track2RA1.bin
;	ds.w	TRACK_LEN
	ds.w	15360/2		; Should only need 6560 words


	dc.w	0,0		Extra space required before sector data, to store zero word and track number word
; Track sector data to be MFM coded
trackData
	incbin	DiskData/Track2/SHOTRACK2.BIN
;checksum
	dc.l	0		Extra space required after sector data, to store checksum


*""""""""""""""""""
*" CC SUBROUTINES "
*"		  "
*""""""""""""""""""

	IFD	NOT_USED
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
	ENDC




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




; NB This is now hard-coded for 5640 source bytes, i.e. bltsize height = 141 and width = 20 (141*20*2 = 5140 bytes)
blit.code.SHO.data			; d0.w = number of bytes
	cmp.w	#5640,d0
	bne	.done
	move.l	a1,a3			; a0 = source, a1 = destination
	moveq	#-1,d1

* Set bltsize value
	move.w	#(141*64)+20,d2

.bltfin	btst	#6,dmaconr(a6)
	bne.s	.bltfin

	move.l	d1,bltafwm(a6)
	moveq	#0,d1
	move.l	d1,bltbmod(a6)
	move.w	d1,bltdmod(a6)
	move.w	d5,bltcdat(a6)

* Duplicate even bits
	lea	-2(a0,d0.w),a4		to end word of source
	lea	-2(a3,d0.w),a1		to end word of first half of destination

	move.l	a4,bltbpth(a6)
	move.l	a4,bltapth(a6)
	move.l	a1,bltdpth(a6)
	move.l	#$0de41002,bltcon0(a6)	USE A,B,D	D = A.C + B.notC
;					B shifted left one position (DESC)
	move.w	d2,bltsize(a6)

	lea	2(a1),a1		to first word of second half of destination

.bltfin2
	btst	#6,dmaconr(a6)
	bne.s	.bltfin2

* Duplicate odd bits
	move.l	a0,bltbpth(a6)		source
	move.l	a0,bltapth(a6)		source
	move.l	a1,bltdpth(a6)		destination
	move.w	#$1de4,bltcon0(a6)	USE A,B,D	D = A.C + B.notC
;					A shifted right one position
	move.w	d1,bltcon1(a6)
	move.w	d2,bltsize(a6)

.bltfin3
	btst	#6,dmaconr(a6)
	bne.s	.bltfin3

* Set clock bits
	move.l	a3,bltbpth(a6)
	move.l	a3,bltapth(a6)
	move.l	a3,bltdpth(a6)
	move.w	#$1d89,bltcon0(a6)	USE A,B,D    D = B.C + notA.notB.notC
;					A shifted right one position
	move.w	d1,bltcon1(a6)
	add.w	#20,d2			do twice as many bytes
	move.w	d2,bltsize(a6)

.bltfin4
	btst	#6,dmaconr(a6)
	bne.s	.bltfin4
.done	rts




;	dc.l	$aaaaaaaa
;testBuf
;	dc.l	0,0
;	dc.l	0


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
