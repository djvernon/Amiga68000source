
ROPE_SPEED	equ	2

_ropeStateOff 		= 0
_ropeStateFiring 	= 1
_ropeStateAttaching	= 2
_ropeStateAttached 	= 4

_ropeLengthBasic	= 20

fastPlotRope
;	{
;DJV	move.b	#1,theByte2
;	LDX ropeData
	move.w	ropeData,d3
	BEQ .plotRopeOut
;	DEX
;	TXA
;	ASL A
;	TAX
;	LDY #0
	move.w	d3,d7
	add.w	d7,d7
	move.w	d7,d6
	add.w	d6,d6
	add.w	d6,d7		i.e. multiply by 6, as ropeData pixel item size is 6 bytes
	lea	ropeData+2,a3
	add.w	d7,a3
	move.l	screen1(pc),a1

	lea	plotTable(pc),a2
	move.w	#AMIGA_YELLOW*4,d5
	move.l	(a2,d5.w),a2	get address of pixel plot routine

.plotRopeLoop
;	LDA ropeData+1,X
;	STA t0
;	LDA ropeData+2,X
;	STA t1
;	LDA #&0f		two yellow pixels
;	STA (t0),Y
;	DEX
;	DEX
;	BPL plotRopeLoop
	move.w	-(a3),d6	positive pixel mask
	move.l	-(a3),d5	offset of word containing pixel
	lea	(a1,d5.l),a0
;	bsr	plotPixelQuick
	move.w	d6,d7
	not.w	d7			make negative mask
	jsr	(a2)
	subq.w	#1,d3
	bne.s	.plotRopeLoop	TODO optimise to dbra

	; New - fast plot of base
;	lea	SCREEN_WIDTH/8*SCREEN_DEPTH(a0),a0	to next line
;	jsr	(a2)		plot four yellow pixels

	lea	SCREEN_WIDTH/8*SCREEN_DEPTH(a0),a0	to next line
	lea	plotTable(pc),a3
	move.w	#AMIGA_RED*4,d5
	move.l	(a3,d5.w),a3	get address of pixel plot routine
	jsr	(a3)		plot four red pixels

	moveq	#8-1,d5
.loop	lea	SCREEN_WIDTH/8*SCREEN_DEPTH(a0),a0	to next line
	jsr	(a2)		plot four yellow pixels
	dbra	d5,.loop

.plotRopeOut
	RTS
;	}


fastEraseRope
;	{
	LDX ropeTileList
	BEQ .eraseRopeOut
	; Go through the rope's tiles, redrawing each
	DEX
        
.eraseRopeLoop:
	LDA ropeTileList+1,X
	TAY
	STX tf
	; First, OR out of coll map
	LDA collData,Y
	AND8 #_bitRope^$FF
	STA collData,Y
	; Now redraw the tile and item if necessary
    TYA
    LDX #$ff
    CPX itemTile
    BEQ .noTile ; x=0 on noTile entry due to the inx

    CMP8 itemTile
    BNE .noTile
    INX ; x=0

.noTile:
    INX
    STX itemRedrawFlag
	JSR redrawTile
    LDA itemRedrawFlag
    BEQ .noItem
    JSR drawItemOnScreen
        
.noItem:        
	LDX tf
	DEX
	BPL .eraseRopeLoop
        
.eraseRopeOut:
	moveq	#0,AREG
	move.w	AREG,ropeData
	move.b	AREG,ropeTileList
	RTS
;	}


updateRope
	bsr	updateRopeMain

* Check harpoon visibility and disable hardware sprite if necessary
	tst.b	ropeHarpoonShown
	beq.s	hideHarpoon
	rts

hideHarpoon
	moveq	#0*8,d7			use hardware sprite 0
	bra	disableSprite

hideAttachEffect
	moveq	#1*8,d7			use hardware sprite 1
	bra	disableSprite


updateRopeMain
********
	IFD	DEBUG_SPRITES
	moveq	#0,d4
	move.b	playerPosX,d4
	add.w	d4,d4			double up for Amiga screen width
	sub.w	#20,d4

	moveq	#0,d5
	move.b	playerPosY,d5
	sub.w	#20,d5

	moveq	#ITEMS_HEIGHT,d6	height of sprite

	btst	#0,playerFlags
	bne.s	.notFlipped
	lea	harpoonSpriteFlippedInX,a0
	bra.s	.posSprite
.notFlipped
	lea	harpoonSprite,a0
.posSprite
	moveq	#0*8,d7			use hardware sprite 0
	bsr	positionAndShowSprite
	ENDC
********
;	{
	LDA playerState
	CMP8 #_playerStateFiringRope
	BEQ .okToContinue
	CMP8 #_playerStateNormal
	BNE .noRope
        
.okToContinue
	LDA ropeState
	CMP8 #_ropeStateFiring
	BEQ .firingSkip
	CMP8 #_ropeStateAttaching
	BEQ .attachEffectSkip
	LDA playerInventory
	AND8 #_bitRope
	BEQ .noRope
	LDA playerUsingItem
	CMP8 #_itemRope
	BNE .noRope
	JMP .checkForFireKey
        
.noRope:
	RTS

	; Attach rope effect - just waits for 5 frames ATM
.attachEffectSkip
	LDA ropeAttachFrames
	CMP8 #5
	BEQ .attachEffectSkip3
	; remove old pixel
;	LDA ropePosX
;	STA t0
;	LDA ropePosY
;	STA t1
;	DEC t1
;	LDA #7
;	STA t2

	IFND	ATTACH_EFFECT_USE_HARDWARE_SPRITES
	moveq	#0,d6
	moveq	#0,d7
	move.b	ropePosX,d6
	move.b	ropePosY,d7
	subq.w	#1,d7
	add.w	d6,d6			double up for Amiga screen width
	move.w	#AMIGA_BLACK,newColour	;TODO check colour (0 is black) and also compare with BBC Micro version of attach effect
	move.w	d6,d3			save for next plot
	move.w	d7,a4			save for next plot
	JSR plotPixel
	
	move.w	d3,d6			restore
	move.w	a4,d7			restore
;	INC t0:INC t0
;	INC t1:INC t1
	addq.w	#2*2,d6			// DJV doubled for Amiga
	addq.w	#2,d7
	JSR plotPixel
	ENDC

.attachEffectSkip3
	DEC ropeAttachFrames
	BEQ .attachEffectSkip2
;	LDA ropePosX
;	STA t0
;	LDA ropePosY
;	STA t1
;	LDA #7
;	STA t2

	IFND	ATTACH_EFFECT_USE_HARDWARE_SPRITES
	moveq	#0,d6
	moveq	#0,d7
	move.b	ropePosX,d6
	move.b	ropePosY,d7
	add.w	d6,d6			double up for Amiga screen width
	move.w	#AMIGA_WHITE,newColour
	move.w	d6,d3			save for next plot
	move.w	d7,a4			save for next plot
	JSR plotPixel

	move.w	d3,d6			restore
	move.w	a4,d7			restore
;	INC t0:INC t0
;	INC t1:INC t1
	addq.w	#2*2,d6			// DJV doubled for Amiga
	addq.w	#2,d7
	JSR plotPixel
	
	ELSE
	moveq	#0,d4
	move.b	ropePosX,d4
	moveq	#0,d5
	move.b	ropePosY,d5
	lea	attachEffectSprite,a0
	add.w	d4,d4			double up for Amiga screen width
	moveq	#3,d6			height of sprite
	moveq	#1*8,d7			use hardware sprite 1
	bsr	positionAndShowSprite
;	st	ropeAttachEffectShown
	ENDC

	INC ropePosY
.return	RTS

.attachEffectSkip2
	LDA #_ropeStateAttached
	STA ropeState
	LDA #_playerStateNormal
	STA playerState
	; Store the tile in which the rope base is drawn
	LDA ropeOrgPosX
	;SEC
	;SBC #4
	STA getTileX
	LDA ropeOrgPosY
	STA getTileY
	JSR getTile
	STY ropeTile
;	RTS
;	sf	ropeAttachEffectShown
	bra	hideAttachEffect

;.tempRopeDelay
;	dc.w	0

.firingSkip
	; Firing - so update it
;********
;	move.w	.tempRopeDelay(pc),d3
;	beq.s	.tempDelaySet
;	subq.w	#1,d3
;	move.w	d3,.tempRopeDelay
;	rts
;
;.tempDelaySet
;	move.w	#25,d3
;	move.w	d3,.tempRopeDelay
********
	LDA ropeCounter
	CMP8 currentRopeLength
	BEQ .norem

	; Remove old harpoon
	sf	ropeHarpoonShown

.norem
	LDA ropeOrgDir
	AND8 #1
	BNE .norem2
	; going left ( ie = 0, so decrement x of rope )
;	DEC ropePosX
;	DEC ropePosX
	subq.b	#ROPE_SPEED,ropePosX
	JMP .norem3
.norem2
	; going right ( ie = 1, so increment x of rope )
;	INC ropePosX
;	INC ropePosX
	addq.b	#ROPE_SPEED,ropePosX
.norem3
;	DEC ropePosY
;	DEC ropePosY
	subq.b	#ROPE_SPEED,ropePosY
	
	LDA ropePosX
	STA getTileX
	LDA ropePosY
	STA getTileY
	
	; check screen extents ; this depends on ropeOrgPos ** TODO
	LDA ropeOrgDir
	BNE .ropeCheckExtentsRight
.ropeCheckExtentsLeft
	LDA ropePosX
	CMP8 #8
	BCC .daveSkip			;Changed from BCS as 68000 differs from 6502
	JMP .cancelThisRopeFire
.daveSkip
	JMP .doneExtentChecking
.ropeCheckExtentsRight
	LDA ropePosX
	CMP8 #128-4
	BCS .doneExtentChecking		;Changed from BCC as 68000 differs from 6502
	JMP .cancelThisRopeFire

.doneExtentChecking
	; Check height
	LDA ropePosY
	CMP8 #32
	BCC .reallyDoneExtentCheck	;Changed from BCS as 68000 differs from 6502
	JMP .cancelThisRopeFire
.reallyDoneExtentCheck

	; Check collision map to see if we have an attachable tile : MIGHT HAVE TO ALSO SET ROPE BIT IN THIS TILE
	JSR getTile
	LDA collData,Y
	;TAX
	AND8 #_bitHookable
	BEQ .noSetRope
	;TXA
	LDA playerScreen ; only do icicle drop in hell, bit of a bodge :/ screens 41-45
	CMP8 #41
	BCS .contAliSky			;Changed from BCC as 68000 differs from 6502
	CMP8 #46
	BCC .contAliSky			;Changed from BCS as 68000 differs from 6502
	CMP8 #42
	BEQ .contAliSky

;	LDA &FE44
;	AND #1
	bsr	randomizeLong
	and.b	#1,d3
    BEQ .contAliSky
	
	move.b	d3,icicleDropFlag ; drop an icicle
    LDA #40
    STA icicleDropFrames
    LDA ropePosX
    ;SEC
    ;SBC #2
    STA icicleDropX
    LDA ropePosY
    SBC #8
    STA icicleDropY
     
.contAliSky:
	JMP .setRope
        
.noSetRope:
;	LDA #_bitRope
;	ORA collData,Y
;	STA collData,Y
	lea	collData,a0
	add.w	YREG,a0
	or.b	#_bitRope,(a0)

	; Store this tile index into our list if a) the list is empty or b) the list's last entry is different to this tile
	TYA
	LDX ropeTileList
	BEQ .addToList
	CMP8 ropeTileList,X
	BEQ .doneAdd
        
.addToList:
	STA ropeTileList+1,X
	INX
	STX ropeTileList
        
.doneAdd:
;	LDA ropePosX
;	STA t0
;	LDA ropePosY
;	STA t1
;	LDA #3
;	STA t2
	moveq	#0,d6
	moveq	#0,d7
	move.b	ropePosX,d6
	move.b	ropePosY,d7
;	move.b	d6,theByte2
;	move.b	d7,theByte3
	add.w	d6,d6			double up for Amiga screen width
	move.w	#AMIGA_YELLOW,newColour
	JSR plotPixel
	tst.l	d5
	bmi.s	.donePixel

;	; Add Y register in to get correct transformed pixel address
;	CLC
;	TYA
;	ADC t3
;	STA t3
;	LDA #0
;	ADC t4
;	STA t4

;DJV original ropeData was a byte array length, followed by the array of 16-bit screen addresses (i.e. taken from t3,t4 pairs) of the pixels
;	; Save this address??
;	LDA ropeData
;	ASL A
;	TAY
;	LDA t3
;	STA ropeData+1,Y
;	LDA t4
;	STA ropeData+2,Y
	move.w	ropeData,d7
	add.w	d7,d7
	move.w	d7,d6
	add.w	d6,d6
	add.w	d6,d7		i.e. multiply by 6, as ropeData pixel item size is 6 bytes
	lea	ropeData+2,a3
	add.w	d7,a3
	move.w	.quadPixelMasks(pc,d4.w),d6	positive mask
	move.l	d5,(a3)+	save offset of word containing pixel
	move.w	d6,(a3)		save positive pixel mask

	; We have a new item in the list: Increment counter
;	INC ropeData ; TODO: Play the game and watch the memory on this - currently 96 bytes which seems a shitload, hmm 48 dots, maybe..
	addq.w	#1,ropeData

.donePixel
	; Increment length
	INC ropeLength		;DJV possibly this isn't needed

	; Keep going?
	DEC ropeCounter
	BEQ .cancelThisRopeFire

	; Only plot harpoon if needed
	IFD	OLD_SOFTWARE_METHOD
	moveq	#0,d6		;_itemHook
	moveq	#ITEMS_ROW,d7

	move.b	ropePosX,d4
	move.b	ropePosY,d5
	subq.b	#7,d5
	moveq	#0,d3		; No flip in x
	tst.b	ropeOrgDir
	bne.s	.notFlipped1
	
	moveq	#1,d6		;_itemHook is now in column 1 because the tileBitmapFlippedInX data is flipped using a 32 pixel column width
	subq.b	#6,d4
	moveq	#1,d3		; Flip in x
.notFlipped1
	move.b	d4,t2
	move.b	d5,t3
	LDA #1
	STA t4
	JSR plotSprite8x8

	ELSE

	moveq	#0,d4
	move.b	ropePosX,d4

	moveq	#0,d5
	move.b	ropePosY,d5
	subq.b	#7,d5

	tst.b	ropeOrgDir
	bne.s	.notFlipped1
	subq.b	#6,d4
	lea	harpoonSpriteFlippedInX,a0
	bra.s	.posSprite
.notFlipped1
	lea	harpoonSprite,a0
.posSprite
	add.w	d4,d4			double up for Amiga screen width
	moveq	#ITEMS_HEIGHT,d6	height of sprite
	moveq	#0*8,d7			use hardware sprite 0
	bsr	positionAndShowSprite
	st	ropeHarpoonShown
	ENDC
	RTS
	;JMP ropeOut
	
.quadPixelMasks
	dc.w	$f000,$f000,$f000,$f000,$0f00,$0f00,$0f00,$0f00
	dc.w	$00f0,$00f0,$00f0,$00f0,$000f,$000f,$000f,$000f

.cancelThisRopeFire
	JSR fastEraseRope
	
	LDA #_ropeStateOff
	STA ropeState

	LDA #_playerStateNormal
	STA playerState

	RTS

.setRope
	;; Set rope state to fixed
	LDA #_ropeStateAttaching
	STA ropeState
	LDA #5
	STA ropeAttachFrames

	; Play a sound
	;LDA #LO(ropeAttachSound):STA notereq+0
	;LDA #HI(ropeAttachSound):STA notereq+1  ; always store MSB last
	lea	ropeAttachSoundInfo,a1
	bsr	soundEffect
	RTS
	
.checkForFireKey:
	LDA #_keyFire
;	BIT keyFlags
	and.b	keyFlags,AREG
	BEQ ropeOut
	
	; If player pos=0, can only fire rope if facing right.
	LDA playerPosX
	BNE .nextStep
	LDA playerFlags
	AND8 #_playerFlagsDirection
	BEQ ropeOut
	BNE okToFire ; was a jmp
	
.nextStep:
	; If player pos=108, can only fire rope if facing left
	CMP8 #$6C
	BCS okToFire			;Changed from BCC as 68000 differs from 6502
	LDA playerFlags
	AND8 #_playerFlagsDirection
	BNE ropeOut
	
okToFire:
;.okToFire:
	; Check state = 2 and erase old rope if needed.  Remember to erase from collision map.
	LDA ropeState
	CMP8 #_ropeStateAttached
	BNE beginRope

	; Erase rope base - Just redraw the rope tiles
	LDA ropeTile
	PHA
	JSR redrawTile
	PLA
	; Redraw this tile+1
	CLC
	ADC #1
	JSR redrawTile

	; Then erase actual rope
	; JSR eraseRope
	JSR fastEraseRope

	; Start a new rope off
beginRope
;.beginRope
	LDA #_playerStateFiringRope
	STA playerState

	; Initialise rope length and store into table
	moveq	#0,AREG
	move.b	AREG,ropeLength
	move.w	AREG,ropeData
	move.b	AREG,ropeTileList

	LDA currentRopeLength
	STA ropeCounter

	; Start rope at PlayerX+8, PlayerY+8
	LDA playerPosX
	CLC
	ADC #8
	STA ropePosX
	STA ropeOrgPosX
	LDA playerPosY
	CLC
	ADC #8
	STA ropePosY
	STA ropeOrgPosY

	; Set state to firing
	LDA #_ropeStateFiring
	STA ropeState
	
	; Save direction of rope; can use previous '1' as it is same as the define
	AND8 playerFlags
	STA ropeOrgDir

	IFD	NOT_USED
    ; Play a sound
    ; LDA #LO(ropeFireSound):STA notereq+2
    ; LDA #HI(ropeFireSound):STA notereq+3
	ENDC
	
ropeOut
;.ropeOut
	RTS

	IFD	NOT_USED
.ropeFireSound:
    ;EQUB 20,0,7
	}
	ENDC
