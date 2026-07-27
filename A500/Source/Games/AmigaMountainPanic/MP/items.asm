
_itemHook		= (0*(4*8))
_itemGemRed		= (1*(4*8))
_itemRope		= (2*(4*8))
_itemHealth		= (3*(4*8))
_itemGemBlue	= (4*(4*8))
_itemTorch		= (5*(4*8))
_itemElderSign	= (6*(4*8))

_bitRope		= $01
_bitTorch		= $02
_bitGemRed      = $04
_bitGemBlue     = $08
_bitElderOne    = $80
_bitElderTwo    = $40
_bitElderThree  = $20
_bitElderFour   = $10

DEFITEM	MACRO	; itemID,itemX,itemY,textID,tileID
    dc.b \2	;itemX
    dc.b \3	;itemY
    dc.b \1	;itemID
    dc.b \4	;textID
    dc.b \5	;tileID
	ENDM

drawItemOnScreen:
	; Item was here; redraw it
	; Work out x/y pos from tile #...
	; Also need to check collected flag
    LDA screenDarkFlag
    BNE .out

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

	LDA #0
	STA t4
;	CLC
	moveq	#0,d3		; No flip in x
	JSR plotSprite8x8 ; might corrupt tc?
.out:        
    RTS
