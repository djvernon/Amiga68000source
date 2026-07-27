effectGems
.gemEntry:
	; First, see if we need to do anything
	LDA playerGems
	CMP8 #(_bitGemRed|_bitGemBlue)
	BNE .notDoneYet
;    LDA #0
;	STA &a56 ; patch collision	;(clearing byte $56 of collData)
	clr.b	collData+(8*10)+6	clear for tile at x=6,y=10, to allow player to walk past blue statue once gems have been placed in its eyes
	JMP .drawGems
	
.notDoneYet:
    LDA playerPosY
    CMP8 #192
    BNE .drawGems
    LDA playerPosX
    CMP8 #16*5
    BCS .drawGems          ; Player must be at x>80 y=192 for us to consider gem use	;Changed from BCC as 68000 differs from 6502
	LDA keyFlags
	AND8 #_keyFire
	BEQ .checkDebounce
	STA wasPressedFlagGems
	RTS

.checkDebounce:
	LDA wasPressedFlagGems
	BEQ .drawGems

.actionHit:
	LDA #0
	STA wasPressedFlagGems

	LDA playerUsingItem
	CMP8 #_itemGemRed
	BNE .checkGemBlue
	LDA #_bitGemRed
    JMP .checksDone
	
.checkGemBlue:
	CMP8 #_itemGemBlue
	BNE .drawGems
	LDA #_bitGemBlue

.checksDone:
	TAX
	eor.b #$ff,AREG
	AND8 playerInventory
	STA playerInventory
    TXA
	ORA playerGems
	STA playerGems

	; We have placed a gem - set player's item to rope
.placedGem:
	LDA #_itemRope
	STA playerUsingItem
	JSR drawItem

    ; And play a sound
    ;LDA #LO(itemUseSound)
    ;STA notereq
    ;LDA #HI(itemUseSound)
    ;STA notereq+1
	lea	itemUseInfo,a1	; 01/06/2022 TODO test
	bsr	soundEffect

.drawGems:
	LDA #_bitGemRed
;	BIT playerGems
	and.b	playerGems,AREG
	BEQ .nextGem

;DJV $6fd0-$4800 = $27d0 = 10192 = 19*512 + 58*8.  Therefore x = 58*2 = 116, y = 32+19*8 = 184

.redGem:
;	LDA #&12 		; red/blue
;	STA &6fd0-(8*3)+3	;DJV x = 116-3*2 = 110, y = 184+3 = 187
;	STA &6fd0-(8*3)+4	;DJV x = 116-3*2 = 110, y = 184+4 = 188
	move.w	#AMIGA_RED,newColour
	move.w	#110*2,d6		double up for Amiga screen width
	move.w	#187,d7
	JSR plotPixel
	move.w	#110*2,d6		double up for Amiga screen width
	move.w	#188,d7
	JSR plotPixel
;DJV blue pixels don't have to be re-plotted for Amiga version as we don't touch them

;	LDA #&21		; blue/red
;	STA &6fd0-(8*3)+3-8	;DJV x = 116-4*2 = 108, y = 184+3 = 187
;	STA &6fd0-(8*3)+4-8	;DJV x = 116-4*2 = 108, y = 184+4 = 188
;DJV blue pixels don't have to be re-plotted for Amiga version as we don't touch them
	move.w	#109*2,d6		double up for Amiga screen width
	move.w	#187,d7
	JSR plotPixel
	move.w	#109*2,d6		double up for Amiga screen width
	move.w	#188,d7
	JSR plotPixel
	
.nextGem:
	LDA #_bitGemBlue
;	BIT playerGems
	and.b	playerGems,AREG
	BEQ .gemsOut

.blueGem:
;	LDA #&38  		; cyan/blue
;	STA &6fd0-(8*1)+3	;DJV x = 116-1*2 = 114, y = 184+3 = 187
;	STA &6fd0-(8*1)+4	;DJV x = 116-1*2 = 114, y = 184+4 = 188
	move.w	#AMIGA_CYAN,newColour
	move.w	#114*2,d6		double up for Amiga screen width
	move.w	#187,d7
	JSR plotPixel
	move.w	#114*2,d6		double up for Amiga screen width
	move.w	#188,d7
	JSR plotPixel
;DJV blue pixels don't have to be re-plotted for Amiga version as we don't touch them

;	LDA #&34		; blue/cyan
;	STA &6fd0-(8*1)+3-8	;DJV x = 116-2*2 = 112, y = 184+3 = 187
;	STA &6fd0-(8*1)+4-8	;DJV x = 116-2*2 = 112, y = 184+3 = 188
;DJV blue pixels don't have to be re-plotted for Amiga version as we don't touch them
	move.w	#113*2,d6		double up for Amiga screen width
	move.w	#187,d7
	JSR plotPixel
	move.w	#113*2,d6		double up for Amiga screen width
	move.w	#188,d7
	JSR plotPixel
	
.gemsOut:
	RTS

;PRINT "* Gems size: ", P%-effectGems
