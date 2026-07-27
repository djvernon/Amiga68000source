_shogStateMoving  = 1
_shogStateStunned = 2
_shogStateDying   = 3
_shogStateDead    = 4

_shogsWaitFrames  = 50*5
        
; Basic idea is you hit shoggoth with an icicle at the right of the screen to stun him
; When he's stunned, drop down the centre will drop one elder sign piece.
; When all four signs are dropped, shoggoth dies and melts downwards.
; Player can now exit this way into congratulations screen.

initShoggoth:
;    {
    LDX #0
    STX shogSignsDropped
    STX shogForceElderDraw
    STX shogX
    INX
    STX shogMoveDelta
    LDX #192
    STX shogY
    LDX #_shogStateMoving
    STX shogState
    LDX #3
.patch:
    LDA shogPatchOne,X
    STA screen40DataEx,X
    DEX
    BPL .patch
.fixedUp:       
    RTS
;    }
    

updateShoggoth:
;	bsr	simulateHitShogs	;DJV temp
	        
    ; Update any icicles
    LDA icicleDropFlag
    BEQ .doneIcicle
    JSR updateIcicle

.doneIcicle:
    LDA playerScreen
    CMP8 #45
    BNE .doNothing

;    ; Do we need to draw signs?
;    LDA shogDrawElderSigns
;    BEQ .doneElderDraw
;    LDA shogSignsDropped
;    STA numElderSigns
;    ASL8 A ; *2
;    TAX
;    DEX		;DJV bug fix (was causing elder signs to show at top of screen and also overwriting currentTileBank value)
;
;.sexyCorrineRussell:
;    LDA localElderSignPos,X
;    STA elderSignsPos,X
;    DEX
;    BPL .sexyCorrineRussell

;    LDA #0
;    STA shogDrawElderSigns ; no need now
;    LDA #1
;    STA shogForceElderDraw

.doneElderDraw:        
    LDA shogState
    CMP8 #_shogStateMoving
    BNE .notMoving    
    JMP updateMoving
        
.notMoving:
    CMP8 #_shogStateDying
    BNE .notDying
    JMP updateDying

.notDying:
    CMP8 #_shogStateStunned
    BNE .doNothing ; Only remaining state is dead, so do nothing
    JMP updateStunned

.doNothing:
    ; Do nothing
    RTS


drawShoggoth:
; NB The shoggoth is drawn using three bobs, which is not the most efficient way to do it, but avoids making changes to the bob system to handle variable bob sizes
; Set bob data
	moveq	#3-1,d3
	moveq	#BobDataSize,d5
	lea	bobDataTable+BobDataSize(pc),a2		start with bob 1

	moveq	#0,d6
	moveq	#0,d7
	move.b	shogX,d6		x
	move.b	shogY,d7		y

	move.w	#192+16,d4		shoggoth y end
	sub.w	d7,d4			shoggoth height
	ble.s	.disable

	lsl.w	#8,d4			*SCREEN_DEPTH*64
	addq.w	#(2+1),d4		Bltsize, 1 word extra width

	add.w	d6,d6			double up for Amiga screen width
;	add.w	#AMIGA_X_OFFSET,d6

	lea	shoggothSourceCols(pc),a3

.loop	move.w	(a3)+,SourceCol(a2)
	move.w	#ALIEN_ROW1,SourceRow(a2)

	move.w	d6,XCoord(a2)
	move.w	d7,YCoord(a2)
	move.w	d4,BltsizeValue(a2)

	st	EnableFlag(a2)

	tst.w	d3
	bne.s	.noFlip

	st	FlippedInX(a2)		third bob of shoggoth flipped in x
	bra.s	.nextX

.noFlip	sf	FlippedInX(a2)

.nextX	add.w	#16*2,d6		double up for Amiga screen width

	add.w	d5,a2
	dbra	d3,.loop
	rts

.disable
	sf	EnableFlag(a2)
	add.w	d5,a2
	dbra	d3,.disable
	rts

shoggothSourceCols
	dc.w	4*2,5*2,4*2


updateMoving:
    LDA shogMoveDelta
    BEQ .movingLeft
    
.movingRight:
    INC shogX
    LDA shogX
    CMP8 #(16*8)-(16*4)+1
    BNE .shogsOut
    LDA #0
    STA shogMoveDelta
;	move.b	#_shogStateDying,shogState	;DJV trainer
    JMP drawShoggoth

.movingLeft:
    DEC shogX
    BNE .shogsOut
    LDA #1
    STA shogMoveDelta
    
.shogsOut:
    JMP drawShoggoth


updateDying:
;    {
    INC shogY
    LDA shogY
    CMP8 #192+16
    BNE .okYet
    LDA #_shogStateDead
    STA shogState
        
    ; unlock the collision map here
    LDX #3
.patch:
    LDA shogPatchTwo,X
    STA screen40DataEx,X
    DEX
    BPL .patch
    
    ; now, dynamic patch of the tilemap...
;    LDA #0|_bitColour
;    STA $ab7
	move.b	#0|_bitColour,tileData+(8*11)-1
;    LDA #8
;    STA $aaf
	move.b	#8,tileData+(8*10)-1
;    LDX #0
;    STX $a57 ; a57=0
	clr.b	collData+(8*11)-1
;    INX
;    STX $aa7 ; aa7=1
	move.b	#1,tileData+(8*9)-1
;    LDA #_bitFlipped
;    STA $a4f
	move.b	#_bitFlipped,collData+(8*10)-1

    ; And redraw the tiles..
;    INX ; x=2
	moveq	#2,XREG
.sexySuzanneMizzi:
    TXA
    PHA
    LDA shogRedrawTiles,X
    JSR redrawTile
    PLA
    TAX
    DEX
    BPL .sexySuzanneMizzi
    RTS
    
.okYet: 
    JSR drawShoggoth
;    LDA #(8*11)+4
;    JSR redrawTile
;    LDA #(8*11)+5
;    JSR redrawTile
;    LDA #(8*11)+6
;    JSR redrawTile
    RTS
;    }


updateStunned:
;    {
    LDA playerPosY 
    CMP8 #192                ; if player.y == 192 (ie is on floor)...
    BNE .sexyJodieMarsh
    LDA playerPosX
    CMP8 #24                 ; and player.x >= 24...
    BCS .sexyJodieMarsh			;Changed from BCC as 68000 differs from 6502
    CMP8 #42                 ; and player.x < 42
    BCC .sexyJodieMarsh			;Changed from BCS as 68000 differs from 6502
        
.compare:                       
    LDA shogSignsDropped    ; now check 'shogSignsDropped' against 'shogSignWhenStun', if they are different, we can drop a sign.
    CMP8 shogSignWhenStun
    BNE .sexyJodieMarsh 

.dropSign:
    CLC
    ADC #1
    STA numElderSigns
    STA shogSignsDropped
    LDA #1
;DJV    STA shogDrawElderSigns ; update them
    STA	shogForceElderDraw	;DJV

    ; and remove a bit from elder inventory
    LDA playerInventory
    TAX ; save
    LSR8 A
    AND8 #$f0 
    STA t0 ; t0=new elder bits
    TXA
    AND8 #$0f
    ORA t0
    STA playerInventory
    JSR drawElderSign

    ; And play a sound
    ;LDA #LO(itemUseSound)
    ;STA notereq
    ;LDA #HI(itemUseSound)
    ;STA notereq+1
	lea	itemUseInfo,a1	; 01/06/2022 TODO test
	bsr	soundEffect

.sexyJodieMarsh:
    DEC shogWaitFrames
    BNE .stillStunned
        
    ; when shogwait=0, set state=moving
.checkForDead:
    LDA shogSignsDropped
    CMP8 #4
    BNE .notDeadYet
    LDA #_shogStateDying
    STA shogState
    JMP drawShoggoth

.notDeadYet:
    LDA #_shogStateMoving
    STA shogState

.stillStunned:        
    JMP drawShoggoth
;    }
    

updateIcicle:
;    {
    LDA icicleDropFrames
    CMP8 #40 ; first pass?
    BEQ .skipErase

	IFD	NOT_REQUIRED
    ; Erase last one with an xor
    LDA #LO(icicleSprite)
    STA t0
    LDA #HI(icicleSprite)
    STA t1
    LDA icicleDropX
    STA t2:PHA
    LDA icicleDropY
    STA t3:PHA
    LDA #1
    STA t4
    CLC
    JSR plotSprite8x8
	ENDC

    ; Have we collided with a tile?    
;    PLA:CLC:ADC #8
    move.b	icicleDropY,AREG
    addq.b	#8,AREG
    STA getTileY
;    PLA
;    STA getTileX
    move.b	icicleDropX,getTileX
    JSR getTile
    LDA collData,Y
    AND8 #_bitCollidable
    BNE .lastFrame
    LDA getTileY
    CMP8 #192+16
    BCC .lastFrame ; check end of screen		;Changed from BCS as 68000 differs from 6502


.skipErase:
    LDA icicleDropY
;    CLC
    ADC #3
    STA icicleDropY
    DEC icicleDropFrames
    BEQ .lastFrame

    ; Draw new one
	IFD	NOT_REQUIRED
    LDA #LO(icicleSprite)
    STA t0
    LDA #HI(icicleSprite)
    STA t1
    LDA icicleDropX
    STA t2
    LDA icicleDropY
    STA t3
    LDA #1
    STA t4
    CLC
    JSR plotSprite8x8
	ENDC

	moveq	#0,d4
	move.b	icicleDropX,d4
	moveq	#0,d5
	move.b	icicleDropY,d5
	lea	icicleSprite,a0
	add.w	d4,d4			double up for Amiga screen width
	moveq	#ITEMS_HEIGHT,d6	height of sprite
	moveq	#2*8,d7			use hardware sprite 2
	bsr	positionAndShowSprite
    RTS

.lastFrame:
    LDA #0
    STA icicleDropFlag

;hideIcicle
	moveq	#2*8,d7			use hardware sprite 2
	bsr	disableSprite

    LDA icicleDropY
    CMP8 #192
    BCS .noCollisionIcicle		;Changed from BCC as 68000 differs from 6502
    LDA icicleDropX
    CMP8 #58+(16*2)
    BCS .noCollisionIcicle		;Changed from BCC as 68000 differs from 6502

    ; Check for shogs collision if 
    LDA shogState
    CMP8 #_shogStateMoving
    BNE .noCollisionIcicle
    LDA shogX
    CMP8 #58
    BCC .hitShogs			;Changed from BCS as 68000 differs from 6502
    
.noCollisionIcicle:
    RTS

.hitShogs:
;DJV    LDA #(8*10)+3
;DJV    JSR redrawTile ; blank out tile prior
    LDA #16*4 ; force x pos
    STA shogX
    LDA #_shogStateStunned
    STA shogState
    LDA #_shogsWaitFrames
    STA shogWaitFrames
    LDA shogSignsDropped
    STA shogSignWhenStun ; 24/04/2013 : Take a copy of the original number of signs so we can determine if player can drop a new sign

    ;LDA #LO(shoggothHitSound)
    ;STA notereq
    ;LDA #HI(shoggothHitSound)
    ;STA notereq+1
	lea	shoggothHitInfo,a1	; 01/06/2022 TODO test
	bsr	soundEffect
    RTS

;DJV
simulateHitShogs
    LDA shogState
    CMP8 #_shogStateMoving
    BNE .done

	move.b	shogSignsDropped,d3
	cmp.b	#3,d3
	bgt.s	.done

    LDA #16*4 ; force x pos
    STA shogX
    LDA #_shogStateStunned
    STA shogState
    LDA #_shogsWaitFrames
    STA shogWaitFrames
    LDA shogSignsDropped
    STA shogSignWhenStun ; 24/04/2013 : Take a copy of the original number of signs so we can determine if player can drop a new sign
.done
    RTS
	        
	IFD	NOT_DONE_YET
.shoggothHitSound:
    EQUB 0 ; pitch
    EQUB 1 ; pitch envelope
    EQUB 1 ; vol envelope
;    }
	ENDC
