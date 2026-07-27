****************
* Bob system
****************

	rsreset
SourceCol	rs.w	1		; NB column width is 16 pixels
SourceRow	rs.w	1		; NB row height is 16 pixels
XCoord		rs.w	1		; NB Amiga co-ordinate i.e. already doubled up for Amiga screen width
YCoord		rs.w	1
BltsizeValue	rs.w	1
EnableFlag	rs.b	1
FlippedInX	rs.b	1
BobDataSize	rs.w	0


; NB bob width hard-coded to 32, bob height hard-coded to 16
NUMBER_OF_BOBS	equ	4		; One for player, then two for aliens or three for shoggoth


bobDataTable
	dc.w	0
	dc.w	0
	dc.w	0			X
	dc.w	0			Y
	dc.w	(16*SCREEN_DEPTH)*64+(2+1)	Bltsize, 1 word extra width
	dc.b	0			Set = show bob
	dc.b	0			Set = flip in x

	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	(16*SCREEN_DEPTH)*64+(2+1)	Bltsize, 1 word extra width
	dc.b	0
	dc.b	0

	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	(16*SCREEN_DEPTH)*64+(2+1)	Bltsize, 1 word extra width
	dc.b	0
	dc.b	0

	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	(16*SCREEN_DEPTH)*64+(2+1)	Bltsize, 1 word extra width
	dc.b	0
	dc.b	0


saveAreaATable
	dc.l	savedArea1A
	dc.l	0
	dc.l	savedArea2A
	dc.l	0
	dc.l	savedArea3A
	dc.l	0
	dc.l	savedArea4A
	dc.l	0

	IFD	NOT_USED
saveAreaBTable
	dc.l	savedArea1B
	dc.l	0
	dc.l	savedArea2B
	dc.l	0
	dc.l	savedArea3B
	dc.l	0
	dc.l	savedArea4B
	dc.l	0
	ENDC


***********************************
*
* SAVE ALL GRAPHICS UNDERNEATH BOBS
*

;	cnop	0,4

saveScreenUnderBobs
	move.l	screen1(pc),a2
	lea	saveAreaATable(pc),a4

	lea	bobDataTable(pc),a5
	lea	yTable(pc),a3

	moveq	#NUMBER_OF_BOBS-1,d7
;	move.w	#(16*SCREEN_DEPTH)*64+(2+1),d6	1 word extra width
	moveq	#BobDataSize,d5
	moveq	#-1,d4
	moveq	#-2,d3

	waitBlit

	move.l	d4,bltafwm(a6)
	move.w	#(SCREEN_WIDTH/8)-(4+2),bltamod(a6)
	move.w	#0,bltdmod(a6)
	move.l	#$9f00000,bltcon0(a6)

.nextSave
	move.l	XCoord(a5),d4
	add.w	d4,d4
	add.w	d4,d4
	move.l	a2,a1
	add.l	(a3,d4.w),a1

	swap	d4
	lsr.w	#3,d4
	and.w	d3,d4		(Blitter actually ignores the least significant bit of the address anyway)
	add.w	d4,a1

	move.l	(a4)+,d4
	move.l	a1,(a4)+

	waitBlit

	move.l	a1,bltapth(a6)
	move.l	d4,bltdpth(a6)
	move.w	BltsizeValue(a5),bltsize(a6)

	add.w	d5,a5
	dbra	d7,.nextSave
	rts


**************************************
*
* RESTORE ALL GRAPHICS UNDERNEATH BOBS
*

;	cnop	0,4

restoreScreenUnderBobs
	lea	saveAreaATable(pc),a4

	lea	bobDataTable(pc),a5

	moveq	#NUMBER_OF_BOBS-1,d7
;	move.w	#(16*SCREEN_DEPTH)*64+(2+1),d6	1 word extra width
	moveq	#BobDataSize,d5
	moveq	#-1,d4

	waitBlit

	move.l	d4,bltafwm(a6)
	move.w	#0,bltamod(a6)
	move.w	#(SCREEN_WIDTH/8)-(4+2),bltdmod(a6)
	move.l	#$9f00000,bltcon0(a6)

.nextRestore
	move.l	(a4)+,d4
	move.l	(a4)+,d3

	waitBlit

	move.l	d4,bltapth(a6)
	move.l	d3,bltdpth(a6)
	move.w	BltsizeValue(a5),bltsize(a6)

	add.w	d5,a5
	dbra	d7,.nextRestore
	rts


***************************************
*
* ROUTINE TO BLIT ALL BOBS IN THE TABLE
*
* Bob routine for 16x16 masked bob (i.e. player)
* NB for Amiga this is actually now 32x16 because of the horizontal doubling
*

drawAllBobs
	move.l	screen1(pc),a5
	lea	bobDataTable(pc),a4
	lea	yTable(pc),a3

	moveq	#NUMBER_OF_BOBS-1,d7
;	move.w	#(16*SCREEN_DEPTH)*64+(2+1),d6	1 word extra width
	moveq	#BobDataSize,d5
	moveq	#(BITMAP_WIDTH/8)-(4+2),d4
	moveq	#(SCREEN_WIDTH/8)-(4+2),d3

	waitBlit

* When doing multiple blits, the following only need setting once
	move.l	#$ffff0000,bltafwm(a6)		mask off last word
	move.w	d4,bltamod(a6)
	move.w	d4,bltbmod(a6)
	move.w	d3,bltcmod(a6)
	move.w	d3,bltdmod(a6)

.nextBob
	tst.b	EnableFlag(a4)
	beq.s	.bobDone

* Set source and mask address
	tst.b	FlippedInX(a4)
	bne.s	.flippedInX

	lea	tileBitmap+32,a0	NB skip colour data
	lea	tileBitmapMasks,a1
	bra.s	.setSource

.flippedInX
	lea	tileBitmapFlippedInX+32,a0	NB skip colour data
	lea	tileBitmapMasksFlippedInX,a1

.setSource
	move.w	SourceRow(a4),d3	source row number
	mulu	#16*BITMAP_WIDTH/8*SCREEN_DEPTH,d3	(NB row height is 16 pixels)
	move.w	SourceCol(a4),d4	source column number
	add.w	d4,d4			(NB column width is 16 pixels)
	add.w	d4,d3
	add.l	d3,a0
	add.l	d3,a1

* Set destination address
	move.l	XCoord(a4),d4
;	move.w	YCoord(a4),dy
	add.w	d4,d4
	add.w	d4,d4
	move.l	a5,a2
	add.l	(a3,d4.w),a2

	swap	d4
	moveq	#$f,d3
	and.w	d4,d3
	sub.w	d3,d4			(Blitter actually ignores the least significant bit of the address anyway)
	lsr.w	#3,d4			x in bytes
	add.w	d4,a2

	ror.w	#4,d3			shift distance

;* Set mask address
;	move.l	a0,a1
;	add.l	#tileBitmapMasks-(tileBitmap+32),a1

	waitBlit

* When doing multiple blits, the following need setting per blit
	move.w	d3,bltcon1(a6)
	or.w	#$fca,d3		USE A,B,C,D ; LFx : D = A.B + a.C
	move.w	d3,bltcon0(a6)

	move.l	a1,bltapth(a6)		bob mask
	move.l	a0,bltbpth(a6)		bob data
	move.l	a2,bltcpth(a6)		screen -- source
	move.l	a2,bltdpth(a6)		screen -- destination
	move.w	BltsizeValue(a4),bltsize(a6)
.bobDone
	add.w	d5,a4
	dbra	d7,.nextBob
	rts


	IFD	ORIGINAL_VERSION
NEW_SPRITE_ROUTINE = TRUE

	; Sprite routine for 16x16 2 pixel aligned sprite where colour 15 is transparent (ie player)

	; t0 -> lo sprite ptr
	; t1 -> hi sprite ptr
	; t2 -> x
	; t3 -> y

	; C set if flip in X is needed

IF NEW_SPRITE_ROUTINE = FALSE
	
ENABLE_FLIP_SPRITE = FALSE
	
.plotSprite16x16Trans
	{
.start
IF ENABLE_FLIP_SPRITE
	LDA #0
	ADC #0
	STA ta
ENDIF
	
	; Calculate base character block to t4,t5
.calcBase
	LDA t3
	LSR A
	LSR A
	AND #&FE
	TAX

	LDA t2
	AND #&FE
	ASL A
	ASL A

	STA t4:tay
	TXA
	ADC #&40
	STA t5

	LDA t3
	AND #7

	CLC
	ADC t4
	STA t4

	; Y = y offset within block
	; TAY
	
	; t2,t3 now available, so use these for org base block
	LDA t5
	STA t3
	
	;LDX t4
	STY t2

;.offsetLoop
;	INX
;	DEY
;p;	BNE offsetLoop

;	STX t4

	; 16 rows
	LDA #16
	STA t8

	; 16 pixels per row (/2 = 8 (2 pixels per byte))
	LDA #8
	STA tb 

	LDY #0
	STY t6
	STY t7
	
.doRow
	;;  Get 2 sprite pixels and flip in X if required
IF ENABLE_FLIP_SPRITE
	LDA ta
	BEQ notFlipped
	
.flippedInX
	
	; invert the index into the row
	LDA t6
	EOR #7
	TAY
	; Get this pixel to Y
	LDA (t0),Y
	TAY
	; mask out interleave pixels
	AND #&55 
	; rotate left this pixel	
	ASL A 
	STA t9
	; get pixel again
	TYA
	; mask out interleave pixels
	AND #&AA
	; rotate right this pixel	
	LSR A 
	ORA t9
	JMP pixelOut1
ENDIF


.notFlipped
	; Get data offset to Y, and increment offset
	LDY t6
	INC t6
	
	; Load 2 sprite pixels
	LDA (t0),Y

	; If both pixels transparent, do nothing
	CMP #&FF
	BNE pixelOut1

	; new
	LDY t7
	JMP moveAlong

.pixelOut1
	; Save the 2 pixels
	STA tc

	; X is offset into masktable, so starts at 0 (eg plot neither)
	LDX #0

	; Save in Y for now
	TAY

.doRight
	AND #(&55)
	CMP #&55
	BEQ doLeft ; right is transparent (ie %1111)
	
	; plot this pixel
	INX

.doLeft
	; Restore from Y
	TYA
	AND #(&AA)
	CMP #&AA
	BEQ leftDone ; left is transparent (ie %1111)
	
	; plot this pixel
	INX
	INX

.leftDone
	
.pixelOut
	; dataOffset++
	; INC t6

	; Store them on screen
	; Get scanline offset to Y
	LDY t7
	
	; ldx tb ; 3 
	; ldy scanTableOffset-1,X ; 4 = 7 cycles

	; Get stored 2 pixels
	LDA tc

	; Mask appropriately
	AND maskTable,X ; 4 cycles
	STA tc ; 3 cycles
	LDA (t4),Y ; 5 cycles
	AND maskTableInverted,X ; 4 cycles
	ORA tc ; 3 cycles
	STA (t4),Y ; 6 cycles

	; Add 8 to get to the next 2 pixels
.moveAlong
	tya ; 2
	;lda t7 ; 3
	clc ; 2
	adc #8 ; 2
	sta t7 ; 3 = 10 cycles

	; Done a row?
	DEC tb
	BNE doRow

	; Add 1 to address : c is clear from above
	lda t4
	adc #1
	sta t4
	and #7
	;INC t4
	;LDA t4
	;AND #7
	BNE noRowBreak

	; Load base block and add 512 to get to next row
.rowBreak
	LDA t2
	STA t4
	CLC
	LDA t3
	ADC #2
	STA t5
	STA t3 ; also write back to baseblock

.noRowBreak
	; Re-initialise scanline offset
	LDA #0
	STA t7
	
	; Re-initialise scanline loopcount
	LDA #8
	STA tb

	; Done all rows?
	DEC t8
	BNE doRow
	
	RTS

	}
ENDIF

IF NEW_SPRITE_ROUTINE = TRUE
	; New player sprite routine

	; t0 -> lo sprite pointer
	; t1 -> hi sprite pointer
	; t2 -> x
	; t3 -> y

	; Uses t4-tc

.plotSprite16x16TransNew
	{
	; First, calculate X*8 (*4 in reality as 2 pixels per byte) and store in t4 / t5
	LDA t2
	STA t4
	LDA #0
	STA t5
	
	; Initialise sprite data offset to 0 and store in t7
	STA t7
	
	ASL t4
	ROL t5
	ASL t4
	ROL t5

	; Initialise current Y position to t6
	LDA t3
	STA t6

	; Row counter
	LDA #16
	STA ta

.nextRow:
	; Get starting scanline address of this Y
	LDY t6
	LDA &500,Y ; lo table
	STA t8
	LDA &600,Y ; hi table
	STA t9

	; Add the X*8, and t8/t9 now points to video ram address for 0,0
	CLC
	LDA t8
	ADC t4
	STA t8
	LDA t9
	ADC t5
	STA t9

	; Initialise X pixel offset from this 0,0 address
	LDA #0
	STA tc

	; Clear carry here as nothing will set it in the innerloop
	CLC

.doRow:
	; Get 2 sprite pixels and increment pointer
	LDY t7
	LDA (t0),Y
	INY
	STY t7

	; If both transparent, do nothing.  Y will never be zero so this is safe.
	BEQ donePixelPlot

	; X is index into masktable
	LDX #0

.doRight:
	BIT spriteBitMasks ; 0x55
	BEQ doLeft
	INX

.doLeft:
	BIT spriteBitMasks+1 ; 0xAA
	BEQ maskPixels
	INX
	INX
	CPX #3
	BNE maskPixels
	; New opt - if x is now 3, then don't bother doing the masking
	CLC
	LDY tc
	STA (t8),Y
	TYA
	ADC #8
	STA tc
	CMP #64
	BNE doRow
	
.maskPixels:
	; Load pixel offset (This is incremented by 8 below)
	LDY tc
	
	; A = pixel AND mask
	AND maskTable,X ; 4 cycles
	STA tb ; 3 cycles

	; A = framebuffer pixel AND mask OR (original)
	LDA (t8),Y ; 5 cycles

	AND maskTableInverted,X ; 4 cycles
	ORA tb ; 3 cycles

	; Store back to framebuffer
	STA (t8),Y ; 6 cycles

.donePixelPlot:
	
	; Add 8 to get to next pixel, and see if we've done a row
	LDA tc
	CLC
	ADC #8
	STA tc
	CMP #64
	BNE doRow

	; Increment Y scanline position
	INC t6

	; Have we done all rows?
	DEC ta
	BNE nextRow
	
.end:
	RTS
	}

	; New player sprite routine flipped

	; t0 -> lo sprite pointer
	; t1 -> hi sprite pointer
	; t2 -> x
	; t3 -> y

	; Uses t4-tc
	

.plotSprite16x16TransFlippedNew
	{
.start
	; First, calculate X*8 (*4 in reality as 2 pixels per byte) and store in t4 / t5
	LDA t2
	STA t4
	LDA #0
	STA t5
	
	ASL t4
	ROL t5
	ASL t4
	ROL t5

	; Initialise current Y position to t6
	LDA t3
	STA t6

	; Initialise sprite data offset to 0 and store in t7
	LDA #0
	STA t7

	; Row counter
	LDA #16
	STA ta

	; Clear carry here as nothing will set it in main loop
	CLC

.nextRow
	; Get starting scanline address of this Y
	LDY t6
	LDA &500,Y ; lo table
	STA t8
	LDA &600,Y ; hi table
	STA t9

	; Add the X*8, and t8/t9 now points to video ram address for 0,0
	CLC
	LDA t8
	ADC t4
	STA t8
	LDA t9
	ADC t5
	STA t9

	; Initialise X pixel offset from this 0,0 address
	LDA #0
	STA tc

.doRow
	; Get 2 sprite pixels and increment pointer
	LDA t7
	EOR #7
	TAY
	LDA (t0),Y
	INC t7

	; If both transparent, do nothing.  Y will never be zero so this is safe.
	; CMP #&FF
	BEQ donePixelPlot

	; Save A ready for the AND
	TAY

	AND #&55
	ASL A
	STA td
	TYA
	AND #&AA
	LSR A
	ORA td

	TAY

	; X is index into masktable
	LDX #0

.doRight
	BIT spriteBitMasks
	;AND #&55
	;CMP #&55
	BEQ doLeft
	INX

.doLeft:
	BIT spriteBitMasks+1
	BEQ maskPixels
	INX
	INX
	
	; New opt - if x is now 3, then don't bother doing the masking
	CPX #3
	BNE maskPixels
	CLC
	LDY tc
	STA (t8),Y
	TYA
	ADC #8
	STA tc
	CMP #64
	BNE doRow
	
	
.maskPixels:

	; Load pixel offset (This is incremented by 8 below)
	LDY tc

	; Do the plotting
	AND maskTable,X ; 4 cycles
	STA tb ; 3 cycles
	LDA (t8),Y ; 5 cycles
	AND maskTableInverted,X ; 4 cycles
	ORA tb ; 3 cycles
	STA (t8),Y ; 6 cycles

.donePixelPlot:

	; Add 8 to get to next pixel, and see if we've done a row
	LDA tc
	CLC
	ADC #8
	STA tc

	CMP #64
	BNE doRow

	; Increment Y index
	INC t6

	; Have we done all rows?
	DEC ta
	BNE nextRow
	
.end
	
	RTS
	}

ENDIF

	; Sprite routine for 16x16 none-masked 2 pixel aligned sprite
	
	; t0 -> lo sprite ptr
	; t1 -> hi sprite ptr
	; t2 -> x
	; t3 -> y

	; C set if flip in X is needed

	; t0,t1 Preserved
	; {t2-ta} trashed
	

.plotSprite16x16
	{
.start:
	LDA #0
	ADC #0
	STA ta
	
.calcBase:
	; Calculate base character block to t4,t5
	LDA t3
	LSR A
	LSR A
	AND #&FE
	TAX

	LDA t2
	AND #&FE
	ASL A
	ASL A

	STA t4
	TXA
	ADC #&40
	STA t5

	; Y = y offset within block
	LDA t3
	AND #7
	TAY

	; t2,t3 now available, so use these for org base block
	LDA t4
	STA t2
	LDA t5
	STA t3

.offsetLoop:
	INC t4
	DEY
	BNE offsetLoop

	; 16 rows
	LDA #16
	STA t8

	LDX #8

	LDY #0
	STY t6
	STY t7
	
.doRow:
	;;  Get 2 sprite pixels and flip in X if required
	LDA ta
	AND #1
	BEQ notFlipped
	
.flippedInX:
	; invert the index into the row
	LDA t6
	EOR #7
	TAY
	; Get this pixel to Y
	LDA (t0),Y
	TAY
	; mask out interleave pixels
	AND #&55 
	; rotate left this pixel	
	ASL A 
	STA t9
	; get pixel again
	TYA
	; mask out interleave pixels
	AND #&AA
	; rotate right this pixel	
	LSR A 
	ORA t9
	JMP pixelOut

.notFlipped:
	LDY t6
	LDA (t0),Y
	
.pixelOut:
	INC t6

	; Store them on screen
	LDY t7
	
	;EOR (t4),Y
	STA (t4),Y

	; Add 8 to get to the next 2 pixels
	LDA t7
	CLC
	ADC #8
	STA t7

	; Change to DEX, removes CPX
	DEX
	BNE doRow

	; Add 1 to address
	INC t4
	LDA t4
	AND #7
	BNE noRowBreak

	; Load base block and add 512
	LDA t2
	STA t4
	CLC
	LDA t3
	ADC #2
	STA t5
	STA t3

.noRowBreak:
	LDY #0
	STY t7
	
	LDX #8
	
	DEC t8
	BNE doRow
	
	RTS
	}
	ENDC

* Sprite routine for 8x8 non-masked 2 pixel aligned sprite (eg harpoon, items..)
* NB for Amiga this is actually now 16x8 because of the horizontal doubling
*
* d6.w = source column number (NB column width is 16 pixels)
* d7.w = source row number (NB row height is 16 pixels)
* t2 -> dest x
* t3 -> dest y
*NOT_REQUIRED;; t4 -> xor flag (1 to xor)
* d3.b set if flipping X

;DOCOPYBLIT	equ	1
	
	IFD	DOCOPYBLIT
copyBlit16x8
	ELSE
maskBlit16x8
	ENDC
	moveq	#$f,d5
	and.w	d6,d5
	sub.w	d5,d6			(Blitter actually ignores the least significant bit of the address anyway)
	lsr.w	#3,d6			x in bytes
	add.w	d6,a2

	ror.w	#4,d5			shift distance

;	IFND	DOCOPYBLIT
;* Set mask address
;	move.l	a0,a1
;	add.l	#tileBitmapMasks-(tileBitmap+32),a1
;	ENDC

	waitBlit

* When doing multiple blits, the following only need setting once
	move.l	#$ffff0000,bltafwm(a6)		mask off last word
	moveq	#(BITMAP_WIDTH/8)-(2+2),d6
	move.w	d6,bltamod(a6)
	IFND	DOCOPYBLIT
	move.w	d6,bltbmod(a6)
	ENDC
	moveq	#(SCREEN_WIDTH/8)-(2+2),d6
	IFND	DOCOPYBLIT
	move.w	d6,bltcmod(a6)
	ENDC
	move.w	d6,bltdmod(a6)

* When doing multiple blits, the following need setting per blit
	move.w	d5,bltcon1(a6)
	IFD	DOCOPYBLIT
	or.w	#$9f0,d5		USE A,D ; LFx : D = A
	ELSE
	or.w	#$fca,d5		USE A,B,C,D ; LFx : D = A.B + a.C
	ENDC
	move.w	d5,bltcon0(a6)

	IFD	DOCOPYBLIT
	move.l	a0,bltapth(a6)		bob data
	ELSE
	move.l	a1,bltapth(a6)		bob mask
	move.l	a0,bltbpth(a6)		bob data
	move.l	a2,bltcpth(a6)		screen -- source
	ENDC
	move.l	a2,bltdpth(a6)		screen -- destination
	move.w	#(8*SCREEN_DEPTH)*64+(1+1),bltsize(a6)		1 word extra width
	rts


plotSprite8x8
* Set source and mask address
	tst.b	d3
	bne.s	.flippedInX

	lea	tileBitmap+32,a0	NB skip colour data
	lea	tileBitmapMasks,a1	(only required for blits above)
	bra.s	.setSource

.flippedInX
	lea	tileBitmapFlippedInX+32,a0	NB skip colour data
	lea	tileBitmapMasksFlippedInX,a1	(only required for blits above)

.setSource
	mulu	#16*BITMAP_WIDTH/8*SCREEN_DEPTH,d7
	add.w	d6,d6
	add.w	d6,d7
	add.l	d7,a0
	add.l	d7,a1

* Set destination address
	moveq	#0,d6
	moveq	#0,d7
	move.b	t2,d6
	move.b	t3,d7

	add.w	d6,d6			double up for Amiga screen width
;	add.w	#AMIGA_X_OFFSET,d6

	move.l	screen1(pc),a2
	lea	yTable(pc),a3
	add.w	d7,d7
	add.w	d7,d7
	add.l	(a3,d7.w),a2

* Use blitter instead when not byte aligned
	moveq	#7,d5
	and.w	d6,d5
	IFD	DOCOPYBLIT
	bne.s	copyBlit16x8
	ELSE
	bne.s	maskBlit16x8
	ENDC

	lsr.w	#3,d6			x in bytes
	add.w	d6,a2

	moveq	#(8*SCREEN_DEPTH)-1,d7

.nextLine

.nextWord
;	move.w	(a0),(a2)
; NB copying bytes not words, because not always word aligned
	move.b	(a0),(a2)
	move.b	1(a0),1(a2)

	lea	(BITMAP_WIDTH/8)(a0),a0		to next bitmap plane (interleaved)
	lea	(SCREEN_WIDTH/8)(a2),a2		to next screen plane (interleaved)
	dbra	d7,.nextLine
	rts


	IFD	ORIGINAL_VERSION
	;; t0 -> sprite lo
	;; t1 -> sprite hi
	;; t2 -> x
	;; t3 -> y
	;; t4 -> xor flag (1 to xor)

	;; C set if flipping X

	; t0,t1 Preserved
	; {t2-ta} trashed

.plotSprite8x8:
	{
.start:
	; Save C flag to ta
	LDA #0
	ADC #0
	STA ta

    ; Check for colour
    LDA t1
    BNE normalSprite

.colourSprite:
    LDA #2
    STA ta
    LDA t0 ; this colour should be stored somewhere (or not - might only need black?)
    JMP noRasterOp
        
.normalSprite:
	; Put correct raster op code in based on t4 value
	LDA t4
	BEQ noRasterOp
	LDA #&51
	STA rasterOp
	LDA #t4
	STA rasterOp+1
	JMP doneRasterOp
        
.noRasterOp:
	LDA #&EA
	STA rasterOp
	STA rasterOp+1
        
.doneRasterOp:
.calcBase:
	; Calculate base character block to t4,t5
	LDA t3
	LSR A
	LSR A
	AND #&FE
	TAX

	LDA t2
	AND #&FE
	ASL A
	ASL A

	STA t4
	TXA
	ADC #&40
	STA t5

	; Y = y offset within block
	LDA t3
	AND #7
	TAY

	; t2,t3 now available, so use these for org base block
	LDA t4
	STA t2
	LDA t5
	STA t3

.offsetLoop:
	INC t4
	DEY
	BNE offsetLoop

	; 8 rows
	LDA #8
	STA t8

	LDX #4

	LDY #0
	STY t6
	STY t7

.doRow:
	; Get 2 sprite pixels and flip in X if required
    LDA #2
    BIT ta
    BNE spriteIsColour
    LDA #1
	BIT ta
	BEQ notFlipped
        
.flippedInX:
	; invert the index into the row
	LDA t6
	EOR #3
	TAY
	; Get this pixel to Y
	LDA (t0),Y
	TAY
	; mask out interleave pixels
	AND #&55 
	; rotate left this pixel	
	ASL A 
	STA t9
	; get pixel again
	TYA
	; mask out interleave pixels
	AND #&AA
	; rotate right this pixel	
	LSR A 
	ORA t9
	JMP pixelOut

.spriteIsColour:
    LDA #0
    JMP pixelOut
        
.notFlipped:
	LDY t6
	LDA (t0),Y
        
.pixelOut:
	INC t6

	; Store them on screen
	LDY t7
        
.rasterOp:
	EOR (t4),Y
	STA (t4),Y

	; Add 8 to get to the next 2 pixels
	LDA t7
	CLC
	ADC #8
	STA t7

	DEX
	BNE doRow
	
	; Add 1 to address
	INC t4
	LDA t4
	AND #7
	BNE noRowBreak

	; Load base block and add 512
	LDA t2
	STA t4
	CLC
	LDA t3
	ADC #2
	STA t5
	STA t3

.noRowBreak
	LDY #0 ; flip in x, was 0
	STY t7
	LDX #4
	
	DEC t8
	BNE doRow
	
	RTS
	}

.fastPlotSpriteDirect16x16
	{
.start
	LDX #2
.setup
	LDY #63
.loop
	LDA (t0),Y
	STA (t2),Y
	DEY
	BPL loop
.nextRow
	CLC
	LDA t3
	ADC #2
	STA t3
	;CLC // will be clear
	LDA t0
	ADC #64
	STA t0
	BCC ok
	INC t1
.ok
	DEX
	BNE setup
	RTS
	}

.plotTileFlippedX:
	{
	; Mask off flags
	LDA t1
	AND #$40 - 1
	STA t1
	
	LDX #2
	
.flippedSprite:
	LDY #63
	
.flippedSpriteLoop:
	LDA (t0),Y
	
.flip:
	; Change to zp
	STA spriteWorkZP
	TYA
	PHA
	; EOR 63 + EOR 7
	EOR #56
	TAY
	LDA spriteWorkZP
	; mask out interleave pixels 
	AND #&55 
	; rotate left this pixel	
	ASL A 
	STA spriteWorkZP+1
	; get pixel again
	LDA spriteWorkZP
	; mask out interleave pixels
	AND #&AA
	; rotate right this pixel	
	LSR A
	ORA spriteWorkZP+1
	STA (t2),Y
	PLA
	TAY
	DEY
	BPL flippedSpriteLoop
	
.nextRow:
	CLC
	LDA t3
	ADC #2
	STA t3
	LDA t0
	ADC #64
	STA t0
	BCC noCarry
	INC t1
	
.noCarry:
	DEX
	BNE flippedSprite
	RTS
	}

.fastColourPlotDirect16x16
	{
.start
	LDX #2
.setup
	LDY #63
	LDA t0
.loop
	STA (t2),Y
	DEY
	BPL loop
.nextRow
	CLC
	LDA t3
	ADC #2
	STA t3
	DEX
	BNE setup
	RTS
	}
	ENDC

* NB for Amiga this is actually now 32x16 because of the horizontal doubling
*
* d6.w = source column number (NB column width is 32 pixels)
* d7.w = source row number (NB row height is 16 pixels)
* d4.w = dest column number (NB column width is 32 pixels)
* d5.w = dest row number (NB column height is 16 pixels)
*
* High bit of t1 set -> flip in X
*TODO Second to high bit of t1 set -> flip in Y

* d4.l = bitmap data (uses same for each bitplane so can therefore currently only output colours 0 and 15)
fastColourPlotDirect16x16
.nextLine
;.nextLong
	move.l	d4,(a2)
	lea	(SCREEN_WIDTH/8)(a2),a2		to next screen plane (interleaved)
	dbra	d5,.nextLine
	rts

plotTileDirect
	* set destination address
	add.w	d4,d4
	add.w	d4,d4			double up for Amiga screen width
;	add.w	#AMIGA_X_OFFSET/8,d4

	move.l	screen1(pc),a2
	add.w	d4,a2
	lea	yTable(pc),a3
	lsl.w	#6,d5			* column height of 16, then * 4 for longword lookup
	add.l	(a3,d5.w),a2

	moveq	#(16*SCREEN_DEPTH)-1,d5

	; First, check for colour
	tst.b	screenDarkFlag
	beq.s	.litScreen
	moveq	#0,d4
	bra.s	fastColourPlotDirect16x16
        
.litScreen
	moveq	#0,d4
	move.b	t1,d4
	and.b	#%111111,d4
	beq.s	fastColourPlotDirect16x16

	* set source address
	lea	tileBitmap+32,a0	NB skip colour data
	mulu	#16*BITMAP_WIDTH/8*SCREEN_DEPTH,d7
	add.l	d7,a0
	add.w	d6,d6
	add.w	d6,d6
	add.w	d6,a0

	move.b	t1,d6
	and.b	#$80,d6
	bne.s	.plotTileFlippedX

	move.b	t1,d6
	and.b	#$40,d6
	bne.s	.plotTileFlippedY

.nextLine
;.nextLong
	move.l	(a0),(a2)
	lea	(BITMAP_WIDTH/8)(a0),a0		to next bitmap plane (interleaved)
	lea	(SCREEN_WIDTH/8)(a2),a2		to next screen plane (interleaved)
	dbra	d5,.nextLine
	rts

.plotTileFlippedX
.nextLineFlippedX
;.nextLongFlippedX
	moveq	#0,d4
	move.l	(a0),d7

	REPT	32
	lsr.l	#1,d7
	addx.l	d4,d4
	ENDR

	move.l	d4,(a2)
	lea	(BITMAP_WIDTH/8)(a0),a0		to next bitmap plane (interleaved)
	lea	(SCREEN_WIDTH/8)(a2),a2		to next screen plane (interleaved)
	dbra	d5,.nextLineFlippedX
	rts

.plotTileFlippedY
	lea	BITMAP_WIDTH/8*((16-1)*SCREEN_DEPTH)(a0),a0	to last line of bitmap data
	moveq	#16-1,d5
.nextLineFlippedY
	moveq	#SCREEN_DEPTH-1,d4
.nextLongFlippedY
	move.l	(a0),(a2)
	lea	(BITMAP_WIDTH/8)(a0),a0		to next bitmap plane (interleaved)
	lea	(SCREEN_WIDTH/8)(a2),a2		to next screen plane (interleaved)
	dbra	d4,.nextLongFlippedY

	lea	-(BITMAP_WIDTH/8*2*SCREEN_DEPTH)(a0),a0	to previous bitmap line (interleaved)
	dbra	d5,.nextLineFlippedY
	rts


	IFD	ORIGINAL_VERSION
	;; t0,t1 => sprite ptr (if t1 == 0 then use t0's as colour)
	;; t2,t3 => screen address.
	;;
	;; High bit of address set -> flip in X
	;; Second to high bit of address set -> flip in Y
	;; Both of these are OK, since 0x8000 and 0x4000 are never used ingame.
.plotTileDirect:
	{
	; First, check for colour
    LDA screenDarkFlag
    BEQ litScreen
    LDA #0
    STA t0
    JMP fastColourPlotDirect16x16
        
.litScreen:   
	LDA t1
	AND #%111111
	BEQ fastColourPlotDirect16x16

	; Check X flag
	LDA #$80
	BIT t1
	BNE plotTileFlippedX

	; Check Y flag
	LDA #$40
	BIT t1
	BNE plotTileFlippedY
	
	; Both flags 0, normal tile
	JMP fastPlotSpriteDirect16x16
	}

.plotTileFlippedY:
	{
	; Mask off flags
	LDA t1
	AND #$40 - 1
	STA t1

	LDA t3
	CLC
	ADC #2
	STA t3

	LDA #2
	STA tileWorkZP
	
.setup:
	LDY #63
	;LDX #63

.plotBlock:
	LDA (t0),Y
	;PHA
	TAX
	TYA
	EOR #7
	TAY
	;PLA
	TXA
	STA (t2),Y
	TYA
	EOR #7
	TAY
	DEY
	;CPY #64
	BPL plotBlock
	;BNE plotBlock
	;DEX
	;BPL plotBlock

	CLC
	LDA t0
	ADC #64
	STA t0
	BCC noCarry1
	INC t1
	;CLC
	
.noCarry1:
	LDA t3
	SEC
	SBC #2
	STA t3

	DEC tileWorkZP
	BNE setup
	
	RTS
	}
	ENDC
