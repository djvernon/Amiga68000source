
;_panelBaseAddress	= &7800
;_sanBarX		= 18
;_sanBarY		= 4+7+7
_hpBarX			= 8
_hpBarY			= 11+1+7
	
;_sanBarAddress		= _panelBaseAddress + (512*(_sanBarY DIV 8)) + (_sanBarY AND 7) + (_sanBarX*8/2)
;_hpBarAddress 		= _panelBaseAddress + (512*(_hpBarY DIV 8)) + (_hpBarY AND 7) + (_hpBarX*8/2)

;_sanLossFrameDelayLatch = 8
_hpLossFrameDelayLatch 	= 4

refillHealthBars:
	lea	fillCoords(pc),a1
	move.w	#BOTTOM_PANEL_Y+_hpBarY,(a1)+
;line 1
	moveq	#_hpBarX*2,d4		double up for Amiga screen width
	move.w	d4,(a1)+

	moveq	#0,d3
	move.b	playerEnergy(pc),d3
	add.w	d3,d3			double up because BBC Micro version filled two pixels
	add.w	d3,d3			double up for Amiga screen width
	add.w	d4,d3
	move.w	d3,(a1)+
;line 2
	move.w	d4,(a1)+
	move.w	d3,(a1)+
	move.w	#AMIGA_HP_RED*4,currentFillColour
	bra	fill


	IFD	OLD_VERSION
OLDrefillHealthBars:
;	{
	;
	; Do 50 pixels of bar (25 iterations)
;	LDX #0
;	LDY #0
	moveq	#0,d3

.barLoop:
;	LDA #168 OR (168>>1) ; 14	;NB two pixels were written
;	STA _hpBarAddress,X
;	STA _hpBarAddress+1,X
	move.w	#6,newColour
	move.w	d3,d6
	add.w	d6,d6			double up because BBC Micro version filled two pixels
	add.w	#_hpBarX,d6
	add.w	d6,d6			double up for Amiga screen width
	move.w	#BOTTOM_PANEL_Y+_hpBarY,d7
	bsr	plotPixel

	move.w	d3,d6
	add.w	d6,d6			double up because BBC Micro version filled two pixels
	add.w	#_hpBarX,d6
	add.w	d6,d6			double up for Amiga screen width
	move.w	#BOTTOM_PANEL_Y+_hpBarY+1,d7
	bsr	plotPixel

	;TODO use some sort of fill routine instead to fill 4x2 block

	;LDA #%10000010 OR (%10000010>>1) ; colour 9
	;STA _sanBarAddress,X
	;STA _sanBarAddress+1,X
        
;	TXA
;	CLC
;	ADC #8
;	TAX
;	INY
;	CPY playerEnergy
	addq.w	#1,d3
	cmp.b	playerEnergy,d3
	BNE .barLoop
	RTS
;	}
	ENDC

	
updateHPAndSan:
	LDA playerHPLoss
	BEQ .out ; Nothing to do

	DEC hpLossFrameDelay
	BNE .out

	LDA #_hpLossFrameDelayLatch
	STA hpLossFrameDelay

	DEC playerHPLoss
	BNE .jump2

	move.w	#$f00,color0+AMIGA_HP_RED*2(a6)	Restore colour used for player energy bar
        
.jump2:
	;
	; Now do the bar
	LDY playerEnergy
	BEQ .out	;handleSanLoss
	DEY
	STY playerEnergy

	; DJV just erase one segment of the energy bar
	lea	fillCoords(pc),a1
	move.w	#BOTTOM_PANEL_Y+_hpBarY,(a1)+
;line 1
	moveq	#_hpBarX*2,d4		double up for Amiga screen width

	moveq	#0,d3
	move.b	playerEnergy(pc),d3
	add.w	d3,d3			double up because BBC Micro version filled two pixels
	add.w	d3,d3			double up for Amiga screen width
	add.w	d4,d3
	move.w	d3,(a1)+
	move.w	d3,d5
	addq.w	#4,d5
	move.w	d5,(a1)+
;line 2
	move.w	d3,(a1)+
	move.w	d5,(a1)+
	move.w	#AMIGA_BLACK*4,currentFillColour
	bra	fill


	IFD	OLD_VERSION
	; Do 50 pixels of bar (25 iterations)
	LDX #0
	LDY #0
	
.barLoop:
	LDA #0
	CPY playerEnergy
	BCS pop
	LDA #168 OR (168>>1) ; 14
	
.pop:
	STA _hpBarAddress,X
	STA _hpBarAddress+1,X
	TXA
	CLC
	ADC #8
	TAX
	INY
	CPY #28
	BNE barLoop
	ENDC

	IFD	NOT_REQUIRED
IF 0        
.handleSanLoss:
	LDA playerSanLoss
	BEQ out
	
	DEC sanLossFrameDelay
	BNE out

	LDA #_sanLossFrameDelayLatch
	STA sanLossFrameDelay

	DEC playerSanLoss
	BNE jump
	
	LDA #$90 + PAL_red
	STA $fe21
.jump:
	;
	; Now do the bar
	LDY playerSanity
	BEQ out
	DEY
	STY playerSanity

	;
	; Do 50 pixels of bar (25 iterations)
	LDX #0
	LDY #0
	
.barLoop2
	LDA #0 ; black
	CPY playerSanity
	BCS pop2
	LDA #%10000010 OR (%10000010>>1)
.pop2
	STA _sanBarAddress,X
	STA _sanBarAddress+1,X
	TXA
	CLC
	ADC #8
	TAX
	INY
	CPY #28
	BNE barLoop2
ENDIF
	ENDC

.out:
	RTS

	IFD	NOT_REQUIRED
IF 0
.sanLossFrameDelay
	EQUB _sanLossFrameDelayLatch
ENDIF


PRINT "* HPAndSAn size: ",P%-refillHealthBars
	ENDC
