updateDynamicText:
    LDX dynTextFrames
    BEQ .dynTextOut

    CPX #50
    BNE .inProgress

.setup:
    LDX #0
    LDA dynTextTileIndex
;    ASL A
;    TAY
;    LDA tileAddressTable,Y
;    STA t2
;    LDA tileAddressTable+1,Y
;    STA t3
	moveq	#0,d4
	move.b	AREG,d4
	move.w	d4,d5
	and.w	#7,d4		; tile index & 7 = x
	sub.w	d4,d5
	add.w	d4,d4
	add.w	d4,d4		(NB column width is 32 pixels)

;	lsr.w	#3,d5
;	addq.w	#2,d5		; (tile index / 8) + 32/16 = row number (also see getTile)
	add.w	d5,d5
	add.w	#32,d5		; ((tile index / 8) * 16) + 32 = y (NB column height is 16 pixels)

    LDY dynTextString
    JSR drawStringWithOSFont

.inProgress:
    DEC dynTextFrames
    BNE .dynTextOut

    LDA #2 ; do 3 tiles
    STA tf
    LDA dynTextTileIndex
    STA te

.removeText:
    LDA te
    JSR redrawTile
    INC te
    DEC tf
    BPL .removeText

.dynTextOut:
    RTS
