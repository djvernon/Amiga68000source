_bitNull		= $00
_bitClimbable 		= $80
_bitCollidable 		= $40
_bitFlipped 		= $20
_bitHookable		= $10

;_bitRope		= $01
_bitColour		= $80
	
_tileFlagsMask		= $F0
_invTileFlagsMask	= $0F

	; *getTileX -> Hit x
	; *getTileY -> Hit y
	;
	; On exit - A corrupted
	;           X is preserved
	;	    Y is index into map table

getTile
; TODO optimise, as used frequently
	;{
	; Take 32 off the Y value to account for the top panel
	LDA getTileX
	LSR8 A	; /2
	LSR8 A	; /4
	LSR8 A	; /8
	LSR8 A	; /16
	STA getTileWork	; work = (Hx/16)

	LDA getTileY
	SEC
	SBC #32

	LSR8 A	; y = ((y/16) * 8) compressed to 1 LSR and AND
	AND8 #$F8
	
	CLC
	ADC getTileWork
	TAY
	RTS
	;}

	; A - Tile index to draw
redrawTile:
;	{
	; Save
	TAX
	; Set screen address for this tile (into t2,t3)
;	ASL A
;	TAY
;	LDA tileAddressTable,Y
;	STA t2
;	LDA tileAddressTable+1,Y
;	STA t3
	moveq	#0,d4
	move.b	AREG,d4
	move.w	d4,d5
	and.w	#7,d4		; tile index & 7 = x
	lsr.w	#3,d5
	addq.w	#2,d5		; (tile index / 8) + 32/16 = y (also see getTile above)

	; This bit set if just a colour
	LDA tileData,X
	TAY
	AND8 #_bitColour
	BEQ .normalTile
	;LDY #3 ; debug-plot redrawn tile as red, with above line commented out

.tileIsColour:
	TYA
	AND8 #$0f
	STA t0
	LDA #0
	STA t1
	JMP plotTileDirect	;DJV was fastColourPlotDirect16x16

.normalTile:
	; Get flipped flag
	LDA collData,X
	AND8 #_bitFlipped
	BEQ .notFlipped
;DJV	BRA	.flippedInY

	; The only tile currently flipped in y is 0.
	; Also see player.asm and screen.asm
	TYA
	AND8 #_invTileFlagsMask
	BEQ .flippedInY
	CMP8 #8
	BEQ .flippedInY

.flippedInX:	
	LDA #$80
	PHA
	BNE .flipDone ; was jmp

.flippedInY:
	LDA #$40
	PHA
	BNE .flipDone ; was jmp
	
.notFlipped:
    ; 01/07/2013 - A is already 0
	; LDA #$00 
	PHA
	
.flipDone:
	TYA
	CMP8 #8
	BCS .notAnXTile		;Changed from BCC as 68000 differs from 6502
	; take off the 8 so it's a proper index into extra tileset
	;SEC
	;SBC #8
	AND8 #7
	TAY
;	LDA #LO(unpackedTileXSprites)
;	STA tileBaseLoadLO+1
;	LDA #HI(unpackedTileXSprites)
;	STA tileBaseLoadHI+1
	moveq	#0,d6
	move.b	AREG,d6
	moveq	#TILEX_ROW,d7
	jmp	.piss
	
.notAnXTile:
;	LDA #LO(unpackedTileSprites)
;	STA tileBaseLoadLO+1
;	LDA #HI(unpackedTileSprites)
;	STA tileBaseLoadHI+1
	moveq	#0,d6
	move.b	AREG,d6
	tst.b	currentTileBank
	bne.s	.bank2
.bank1	moveq	#TILE_BANK1_ROW,d7
	bra.s	.piss
.bank2	moveq	#TILE_BANK2_ROW,d7
	
.piss:
;	; Get tile index back
;	TYA
;	; *2 
;	ASL A
;	TAX
;	LDA lookup128,X
;	STA t0
;	LDA lookup128+1,X
;	STA t1
	
;	; Now add this 128* to the base sprite pointer
;	CLC
;.tileBaseLoadLO:
;	LDA #LO(unpackedTileSprites)
;	ADC t0
;	STA t0
;.tileBaseLoadHI:
;	LDA #HI(unpackedTileSprites)
;	ADC t1
;	STA t1
	
;	;; t0,t1 => sprite ptr (if t1 == 0 then use t0's as colour)
;	;; t2,t3 => screen address
	;; Pull the flipped flags off the stack and or them in.
	PLA
;	ORA t1
	ORA #1		; DJV set non-zero to request a tile plot (not just a colour)
	STA t1
	JMP plotTileDirect ; was JSR
	;RTS
;	}
