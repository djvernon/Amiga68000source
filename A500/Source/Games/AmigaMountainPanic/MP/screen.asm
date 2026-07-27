_screenChangeLeft	= 1
_screenChangeRight	= 2
_screenChangeDown	= 3
_screenChangeUp		= 4

	IFD	NOT_DONE_YET
.soundEerie:
EQUB 160    ; pitch
EQUB 1     ; pitch envelope
EQUB 6     ; volume envelope
	ENDC
		
drawScreen:
;	{
	; Drawn 0 snowflakes this frame
	LDA #0
	IFND	SNOWFLAKES_USE_HARDWARE_SPRITES
	clr.w	flakeActiveList
	ENDC
	sf	ropeHarpoonShown	;DJV
;	sf	ropeAttachEffectShown	;DJV
	bsr	hideHarpoon		;DJV
	bsr	hideAttachEffect	;DJV

    TAX
    LDA #1
;DJV    STA shogDrawElderSigns
    STA shogForceElderDraw	;DJV
        
    LDA playerScreen
    CMP8 #45 ; on shoggoth don't touch
    BEQ .screen45
    STX numElderSigns ; eldersigns=0
    bra.s	.nextCheck	;DJV

;DJV for screen 45 set all elder sign positions now
.screen45
	lea	localElderSignPos,a0
	lea	elderSignsPos,a1
	moveq	#8-1,d7
.copy	move.b	(a0)+,(a1)+
	dbra	d7,.copy
	bra.s	.noSigns

.nextCheck:
    CMP8 #41
    BNE .noSigns

    LDA #4
    STA numElderSigns
    LDY #16*6+8+8+3
    LDA #(16*3)-3
.solange:        
    STA elderSignsPos,X
    STY elderSignsPos+1,X
    CLC
    ADC #10
    INX
    INX
    CPX #8
    BNE .solange

.noSigns:        
    LDX #$ff
.checkWindowLoop:
	INX
	LDA snowWindowValueTable,X
	BEQ .checkWindowLoopOut
	CMP8 playerScreen
	BNE .checkWindowLoop
	;BEQ foundMatch
	;INX
	;JMP checkWindowLoop
        
.foundMatch:
	; JSR setupSnowFlakesForScreen
	; X is offset into table
;.setupSnowFlakesForScreen
	;{
	TXA
	; Times index by 4 to get the value
	ASL8 A
	ASL8 A
	TAX
	LDY #0
.setupSnowLoop
	LDA snowWindowValues,X
	STA snowWindow,Y
	INX
	INY
	CPY #4
	BNE .setupSnowLoop
	;RTS
	;}
	JMP .doneSnowWindow
        
.checkWindowLoopOut:
	; Setup default window
	LDA #0
	STA snowWindow
	STA snowWindow+1
	LDA #16*8
	STA snowWindow+2
	LDA #16*13
	STA snowWindow+3

.doneSnowWindow:
	; No tiles to do
	LDA #0
	STA playerTileList

	; No rope
	STA ropeState
	
	; Unpack counter offset
	STA ta

	; tb,tc => 8 bytes of screen data
;	LDX playerScreen
;	; DEX
;	STX tb
;	TAX	; LDX #0
;	STX tc
	moveq	#0,d7
	move.b	playerScreen,d7

	; tb,tc = (screenIndex-1)*8 gives us the offset
;	ASL8 tb
;	ROL tc
;	ASL8 tb
;	ROL tc
;	ASL8 tb
;	ROL tc
	lsl.w	#3,d7

	; Add onto tb,tc the map address to give address of current screen
;	CLC
;	LDA #LO(mapData)
;	ADC tb
;	STA tb
;	STA curScreenLO
;	LDA #HI(mapData)
;	ADC tc
;	STA tc
;	STA curScreenHI
	lea	mapData,a5
	add.w	d7,a5
	move.l	a5,curScreen

	; Use Y as an index register into the 8 bytes of screen data
	LDY #0

	; Load tilepage index and string index
	LDA (a5),Y	;LDA (tb),Y
	PHA

	; Top nibble is index into tileset table (1,2,4..)
	AND8 #$e0
	LSR8 A
	LSR8 A
	LSR8 A
	LSR8 A
    STA currentTileBank
	TAX

	IFD	NOT_REQUIRED
	CLC
	LDA packedTileTable,X
	ADC #LO(tileSpritesPacked+2)
	STA loadPackedTileSetLO+1
	
	LDA packedTileTable+1,X
	ADC #HI(tileSpritesPacked+2)
	STA loadPackedTileSetHI+1

.unpackTileSet:
	CLC
.loadPackedTileSetHI:
	LDX #0
.loadPackedTileSetLO:
	LDY #0

	JSR unpack	;TODO just curious how this knows to unpack to .unpackedTileSprites ?
IF 0
	BCC handlePalette
	BRK ; tile unpack failed
ENDIF        
	ENDC

    ; Handle palette.
.handlePalette:
	LDY #2
	LDA (a5),Y	;LDA (tb),Y
    TAX
	AND8 #(_effectPaletteChange|_effectPaletteChange2)
	BEQ .palGreen
	
	CMP8 #_effectPaletteChange
	BNE .palMagenta
	
.palRed:
;	LDA #&80 + (1 EOR 7)		Change colour 8
;	STA &FE21
	move.w	#$f00,color8(a6)
	JMP .okSolange
	
.palMagenta:
;	LDA #&80 + (5 EOR 7)		Change colour 8
;	STA &FE21
	move.w	#$f0f,color8(a6)
	JMP .okSolange
	
.palGreen:
;	LDA #&80 + (2 EOR 7)		Change colour 8
;	STA &FE21
	move.w	#$0f0,color8(a6)
	
.okSolange:
    ; Check dark flag - if so, turn all colours off.  Need to do this before we re-program
    TXA
    LDX #0
    AND8 #_effectDark
    BEQ .litScreen
    LDA playerInventory
    AND8 #_bitTorch
    BNE .litScreen
    INX
        
.litScreen:
    STX screenDarkFlag
        
	; Restore A,Y and mask off top nibble, leaving screen string index.
	PLA
	AND8 #$1f
	TAX

	; Plot text

	; Clear row 1, characters 1 to 14 (i.e. words 1 to 14) using blitter
	move.l	screen1(pc),a2
	lea	yTable(pc),a3
	moveq	#(1*8)*4,d7
	add.l	(a3,d7.w),a2		to row 1
	addq.w	#2,a2			to character 1
	moveq	#(SCREEN_WIDTH/8)-(14*2),d6
	waitBlit
	move.w	d6,bltdmod(a6)
	move.l	#$1000000,bltcon0(a6)	USE D
	move.l	a2,bltdpth(a6)
	move.w	#(8*SCREEN_DEPTH)*64+14,bltsize(a6)
	waitBlit

	TXA
	TAY

	LDX #1 ; centre flag
	moveq	#1*2,d4			double up for Amiga screen width
	moveq	#8-1,d5
	JSR drawStringWithOSFont
	LDY #0

	; Get the screen index
	INY
	LDA (a5),Y	;LDA (tb),Y
	
	; Mask off flip bit
	AND8 #$7F

	; *2 for table index
	ASL8 A
	TAX

;	; (t4,t5) -> Screen data
;	LDA screenTable,X
;	STA t4
;	INX
;	LDA screenTable,X
;	STA t5
	lea	screenTable,a4
	move.w	XREG,d3
	add.w	d3,d3
	move.l	(a4,d3.w),a4

	; Do 12 rows
	LDA #12
	STA tf

	; Index into lookup table
	LDY #0
;	STY td
	; Byte offset
	STY tc
	STY tb

* DJV
* tb = collData / tileData index
* tc = screenData index
.outerRowLoop
	; t6 = Tile present byte
	LDY tc
	LDA (a4),Y	;LDA (t4),Y
	STA t6

	; 8 tiles to do in this row
	LDA #8
	STA te

    ; Initialise run-length
    LDA #0
    STA t7
    STA runLenCnt

.innerRowLoop

	; Set up screen RAM pointers for this tile
;	LDY td
;	LDA tileAddressTable,Y
;	STA t2
;	INY
;	LDA tileAddressTable,Y
;	STA t3
;	INY
;	STY td
	;DJV t2,t3 were the screen dest address
	;DJV the tile positions incremented horizontally then vertically

	LDA t6
	
	; Bit set - there is a tile here
	AND8 #$80
	BNE .tilePresent

	; Plot black
	LDA #$00
	;STA t0
	STA t1

	; Update collision map
	LDY tb
	STA collData,Y
        
	; Set high bit to say this is a colour
	ORA #_bitColour
	STA tileData,Y
	INY
	STY tb

	; CLC=&18
	; LDA #&18
	; STA drawTile
	JMP .drawTile
	
.tilePresent:
    ; 17/02/2012:
    ; Are we run-lengthing?
    LDA runLenCnt	;t7
    BEQ .noRunLength
        
    ; If so, make t7 is our tile - and jump
    DEC runLenCnt
    BEQ .noRunLength
    LDA t7
    TAX
    JMP .properTile
    
	; Else load pointer with sprite tile data
.noRunLength:        
	LDY tc
	INY
	LDA (a4),Y	;LDA (t4),Y
	STY tc
	
	; X register is original data byte
	TAX

    ; 17/02/2012:
	; See if this tile has all high bits set.  If so, it means ALL tiles which follow on this row
    ; are a copy of the following byte, so we store that byte to t7.
	AND8 #$f0
	CMP8 #$f0
	BNE .properTile

.tileIsRunLength:
    ; Special case
    TXA
    AND8 #$f ; a = count of run length.  If 0, rest of row.
    BNE .noInc
    CMP8 #$e
    BNE .beyonce
        jmp .skipTile
.beyonce:    
    LDA #255 ; 0=do rest of row
        
.noInc:
    STA runLenCnt ; zp

    ; Load another byte. This is then used for the rest of the row.
    INY
    LDA (a4),Y	;LDA (t4),Y
    STY tc
    STA t7 ; store to runlength temp
    TAX ; and transfer to X ready for render

.properTile:
	TXA
	; Update collision map
	AND8 #_tileFlagsMask
	LDY tb
	STA collData,Y
	
	TXA
	
	; See if this tile is flipped
	AND8 #_bitFlipped
	BEQ .notFlipped
	
	; The only tile flipped in Y currently is the pillar bottom (at index 0).  May in the future include spikes and generics.
	TXA
	AND8 #_invTileFlagsMask
	BEQ .flippedInY
	CMP8 #8
	BEQ .flippedInY

.flippedInX:
	LDA #$80
	PHA
	;JMP flipSet
	bne .flipSet
	
.flippedInY:
	LDA #$40
	PHA
	;JMP flipSet
	bne .flipSet
	
.notFlipped:
	;LDA #$00 ; already 0
	PHA
	
.flipSet:
	TXA
	
	; Mask off tilebits
	AND8 #_invTileFlagsMask

	; If tile# is >=8, subtract 8 and point to the generic tile pool.
	CMP8 #8
	BCS .notAnXTile		;Changed from BCC as 68000 differs from 6502
	;SEC
	;SBC #8
	; Store before -8
	STA tileData,Y
	AND8 #7

	; Modify base pointers below
;	LDX #LO(unpackedTileXSprites)
;	STX tileBaseLoadLO+1
;	LDX #HI(unpackedTileXSprites)
;	STX tileBaseLoadHI+1
	moveq	#0,d6
	move.b	AREG,d6
	moveq	#TILEX_ROW,d7

	JMP .skipSol2

.notAnXTile:
	; Modify base pointers below
;	LDX #LO(unpackedTileSprites)
;	STX tileBaseLoadLO+1
;	LDX #HI(unpackedTileSprites)
;	STX tileBaseLoadHI+1
	moveq	#0,d6
	move.b	AREG,d6
	tst.b	currentTileBank
	bne.s	.bank2
.bank1	moveq	#TILE_BANK1_ROW,d7
	bra.s	.skipSol
.bank2	moveq	#TILE_BANK2_ROW,d7

.skipSol:
	; Y is still set OK from above
	STA tileData,Y
	
.skipSol2:
;	STA t0

	INY
	STY tb

;	LDA #0
;	STA t1

	; * 128 - Get this from the table now - needs whacking up to 16*128 (0-15) entries...
	;
;	ASL8 t0:ROL t1
;	ASL8 t0:ROL t1
;	ASL8 t0:ROL t1
;	ASL8 t0:ROL t1
;	ASL8 t0:ROL t1
;	ASL8 t0:ROL t1
;	ASL8 t0:ROL t1

;	CLC
;.tileBaseLoadLO:
;	LDA #LO(unpackedTileSprites)
;	ADC t0
;	STA t0
;.tileBaseLoadHI:
;	LDA #HI(unpackedTileSprites)
;	ADC t1
;	STA t1

	; Pull flipped flags off stack and or them in
	PLA
;	ORA t1
	ORA #1		; DJV set non-zero to request a tile plot (not just a colour)
	STA t1

.drawTile:
* d6 = source column number (NB column width is 32 pixels)
* d7 = source row number (NB row height is 16 pixels)
* d4 = dest column number (NB column width is 32 pixels)
* d5 = dest row number (NB column height is 16 pixels)
;	moveq	#8,d6	;DEBUG
;	sub.b	te,d6	;DEBUG

;	moveq	#12,d7	;DEBUG
;	sub.b	tf,d7	;DEBUG

;DJV row = 12-tf, column = 8-te
	moveq	#8,d4
	sub.b	te,d4
	moveq	#12,d5
	sub.b	tf,d5
	addq.b	#PANEL_ROWS,d5
	IFND	STEALTH_MODE
 	JSR plotTileDirect
	ENDC
	
.skipTile:
	ROL8 t6
	DEC te

	BEQ .doneRow
	JMP .innerRowLoop

.doneRow:
	; Increment new byte pointer
	INC tc

	; Have we done all rows
	DEC tf
	BEQ .sanLoss
	JMP .outerRowLoop

.sanLoss:  ; just play the sound
	LDY #7
	LDA (a5),Y	;LDA (curScreenLO),Y
	AND8 #%100
	BEQ .doItems ; anything to do?

    ; yes - clear flag and play note

    LDA #%11111011
    AND8 (a5),Y	;AND8 (curScreenLO),Y
    STA (a5),Y	;STA (curScreenLO),Y
        
	;LDA #LO(soundEerie):STA notereq+0 ; yes - play sound
	;LDA #HI(soundEerie):STA notereq+1
	lea	soundEerieInfo,a1
	bsr	soundEffect

.doItems:

;	; r4,r5 -> te,tf as they are trashed by plotSprite8x8
;	LDA t4
;	STA te
;	LDA t5
;	STA tf

	; Check for items
	LDY #2
	LDA (a5),Y;	LDA (curScreenLO),Y
	AND8 #SCREEN_FLAGS_ITEM_PRESENT
	BEQ .exitNoItems

	; We have items
	LDY tc

	; x pos of item
	LDA (a4),Y	;LDA (t4),Y
	STA getTileX
	STA itemX
	INY

	; y pos of item
	LDA (a4),Y	;LDA (t4),Y
	STA getTileY
	STA itemY
	JSR getTile

	; set up item tile
	STY itemTile
	
	LDY tc
	INY
	INY

	; item ID ; lower nibble contains 'extra' bits for elder sign
	LDA (a4),Y	;LDA (t4),Y
    TAX
    AND8 #$f0
	STA itemID
    TXA
    ;ASL8 A:ASL8 A:ASL8 A:ASL8 A
    asl.b	#4,AREG
    STA itemExtra
        
	INY

	; load item text block
	LDA (a4),Y	;LDA (t4),Y
	STA dynTextString
	INY
	LDA (a4),Y	;LDA (t4),Y
	STA dynTextTileIndex
	INY

	; Store back - needed for aliens
	STY tc

	;TODO remove duplicate code (this section looks very similar to drawItemOnScreen in items.asm)
    LDA screenDarkFlag
    BNE .drawItemFinished ; don't draw item on dark screen

	; t0/t1 -> Sprite data
	CLC
;	LDA #LO(itemSprites)
;	ADC itemID
;	STA t0
;	LDA #HI(itemSprites)
;	ADC #0
;	STA t1
* Convert BBC Micro value back to item number
	moveq	#0,d6
	move.b	itemID,d6
	lsr.w	#5,d6
	moveq	#ITEMS_ROW,d7

	; t2/t3 -> x,y
	LDA itemX
	STA t2
	LDA itemY
	STA t3

	; Plot item
;	CLC
	moveq	#0,d3		; No flip in x
	IFND	STEALTH_MODE
	JSR plotSprite8x8
	ENDC
        
.drawItemFinished:        
	JMP .handleAliens

.exitNoItems:
	LDA #$FF
	STA itemTile

	; If there originally was an item, skip the item pointer
	LDY #7
	LDA (a5),Y	;LDA (curScreenLO),Y
	AND8 #1
	BEQ .handleAliens
	;LDA tc:CLC:ADC #5:STA tc
	add.b	#5,tc
        
	IFD	NOT_REQUIRED
IF FALSE
    LDY tc
	INY
	INY
	INY
	INY
	INY
	STY tc
ENDIF
	ENDC

.handleAliens:
	JSR initialiseEnemiesForScreen
	RTS
;	}
