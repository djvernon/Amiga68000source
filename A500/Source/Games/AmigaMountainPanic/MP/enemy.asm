
ENEMY_SPEED	equ	1

NUM_BYTES_PER_ALIEN_JORDANS_WONDERFUL_TITS = 8
NUM_BYTES_PER_ALIEN = 6
	IFD	NOT_REQUIRED
ENEMY_COLLISIONS = FALSE
	ENDC

;; Alien data stored thus:
;;
;; x			: Start X
;; y			: Start Y
;; flags		: 1 (Movement type)
;; , 1 Altering X, 1 Altering Y, 1 Sign bit.  %1111 animation delay.
;; animFrame & spriteTyee   : Anim frame (always set to ensure immediate animation) + sprite type (0 snowball,1 penguin,2 elder)
;; counter		: Current counter
;; max counter	: Max counter before sign bit reverses.
        
	IFD	NOT_REQUIRED
MACRO DEFENEMY enemyType,startX,startY,moveType,alterX,alterY,signBit,currentCounter,maxCounter
    EQUB startX
    EQUB startY
    EQUB moveType<<7 OR alterX<<6 OR alterY<<5 OR signBit<<4 OR %0001 ; Delay always starts ready to go
    EQUB $80 OR enemyType ; 0=snowballs,1=penguin,2=elder
    EQUB currentCounter
    EQUB maxCounter
ENDMACRO        
	ENDC

; tc contains offset into screen data
initialiseEnemiesForScreen:
;	{
* DJV disable all enemy Amiga bobs first (including shoggoth)
	lea	bobDataTable+BobDataSize(pc),a2
	sf	EnableFlag(a2)
	lea	BobDataSize(a2),a2
	sf	EnableFlag(a2)
	lea	BobDataSize(a2),a2
	sf	EnableFlag(a2)

	LDY #2
	LDA (a5),Y	;LDA (curScreenLO),Y
	
	 ; Bottom 2 bits contain # enemies (0..3)
	AND8 #$3
	BEQ .exitNoAliens

	CMP8 #1
	BNE .mustBeTwo
	BEQ .mustOut
	
.mustBeTwo:
	LDA #2
	
.mustOut:
	STA numAliens
	STA t8

	; Initialise alien we are currently working with
	LDA #0
	STA currentAlien

	; Copy to zeropage workspaces
;	LDA #LO(alien1)
	lea	alien1(pc),a3

	LDY	tc		;DJV
	add.w	YREG,a4		;DJV
	
.copyAliens:
	LDX #0

;	STA t6
;	STX t7 			; eh?!
;	STX td

.copyLoop:
;	LDY tc
;	LDA (te),Y
;	STA t0
;	INY
;	STY tc
;	LDY td
;	STA (t6),Y
;	INC td
	move.b	(a4)+,(a3)+
	INX
	CPX #NUM_BYTES_PER_ALIEN
	BNE .copyLoop

	; Initialise work-bytes
;	INY
;	LDA #0
;	STA (t6),Y
;	INY
;	STA (t6),Y
	clr.b	(a3)+
	clr.b	(a3)+

	; Ensure we skip the 2 work bytes
;	LDA t6
;	CLC
;	ADC #NUM_BYTES_PER_ALIEN_JORDANS_WONDERFUL_TITS
	
	DEC t8
	BNE .copyAliens
        
.exit:
	RTS
	
.exitNoAliens:
	; LDA #0 ; DCF A is already 0
	STA numAliens
	RTS
;	}


frameTable:
	* Source column, source row
	dc.w	0*2,ALIEN_ROW1	; penguinFrameOne
	dc.w	1*2,ALIEN_ROW1	; penguinFrameTwo
	dc.w	2*2,ALIEN_ROW1	; elderThingFrameOne
	dc.w	3*2,ALIEN_ROW1	; elderThingFrameTwo
	dc.w	0,ALIEN_ROW2	; snowBall

updateEnemies:
;	{
	LDA numAliens
;	move.b	AREG,theByte1
	BEQ .sexyJackyJoy
	;RTS
	
.aliensPresent:
	; Get the alien we're updating.
;	LDX currentAlien
;
;	; Get lo-byte based on that table,X
;	LDA alienPointerTable,X
;	STA te
	moveq	#0,d3
	move.b	currentAlien(pc),d3
;	move.b	d3,theByte2
	lsl.w	#3,d3				NB this assumes alien structures are 8 bytes long and contiguous
	lea	alien1(pc),a3
	add.w	d3,a3

;	; Initialise high-byte of enemy pointer
;	LDA #0
;	STA tf

	; Do the update
	JSR updateEnemy

	; Increment enemy number for next frame
	LDX currentAlien
	INX
	CPX numAliens
	BNE .moreAliensToUpdate
	LDX #0
	
.moreAliensToUpdate:
	STX currentAlien
        
.sexyJackyJoy:
	RTS
;	}
	

* a3 = enemy pointer
updateEnemy:
;	{
;	LDY #2
;	LDA (te),Y
	move.b	2(a3),AREG
	AND8 #$80
	BEQ .classicMovement
	JSR updateEnemyMagicMushroomStyle
	JMP .updateOut
	
.classicMovement:
	JSR updateEnemyClassicStyle

.updateOut:
    LDA screenDarkFlag
    BNE .doneAliens
	JSR drawEnemy
        
.doneAliens:
	RTS
;	}


* a3 = enemy pointer
updateEnemyMagicMushroomStyle:
;	{
	JSR updateEnemyAnimation
	
;	LDY #2
;	LDA (te),Y ; get current sign bit, 0 = increasing x
	move.b	2(a3),AREG
;	LDY #0
	AND8 #$10
	BEQ .positive
	
.negative:
;	LDA (te),Y
;	SEC
;	SBC #ENEMY_SPEED
;	STA (te),Y
	subq.b	#ENEMY_SPEED,(a3)
	JMP .doneMovement
	
.positive:
;	LDA (te),Y
;	CLC
;	ADC #ENEMY_SPEED
;	STA (te),Y
	addq.b	#ENEMY_SPEED,(a3)

	; Done movement; change direction if x==startX or x==endX
.doneMovement:
;	LDY #0
;	LDA (te),Y ; a=x pos
;	LDY #4
;	CMP (te),Y ; 
	move.b	(a3),d3
	cmp.b	4(a3),d3
	BEQ .flip   ; if a==min flip
;	LDY #5
;	CMP (te),Y ; if a==max flip
	cmp.b	5(a3),d3
	BEQ .flip

	; Otherwise, been a while since we flipped, so maybe flip
.notAtLimits:
;	LDY #7
;	LDA (te),Y
;	CLC
;	ADC #1 ; frames since change++
	move.b	7(a3),d3
	addq.b	#1,d3
;	CMP #10 ; if (framesSinceChange==framesToChange)
	cmp.b	#10,d3
	BEQ .changeDirection
;	STA (te),Y
	move.b	d3,7(a3)
	RTS
	
.changeDirection:
	; Re-init counter
;	LDA #0
;	STA (te),Y
	clr.b	7(a3)
;	LDA #16*2

	; Flip on rnd(3)==0
;	LDA &FE44
;	AND #%11
	bsr	randomizeLong
	and.b	#%11,d3
	BEQ .flip
	RTS

	; Flip sign bit
.flip:
;	LDY #2
;	LDA (te),Y
;	EOR #%00010000
;	STA (te),Y
	eor.b	#$10,2(a3)
	RTS
;	}


* a3 = enemy pointer
updateEnemyAnimation:
;	{
* DJV on Amiga the enemy routines are called every frame (vs. every other on the BBC Micro),
* so to compensate we now only update the animation every other time (this avoids the
* alternative of having to double the anim delay)
	eor.b	#$40,3(a3)		Using bit 6 which was spare
	move.b	3(a3),d3
	and.b	#$40,d3
	beq.s	.animDone

	; decrement anim delay first
;	LDY #2
;	LDA (te),Y
	move.b	2(a3),AREG
	TAX
	AND8 #$f0
	STA animWorkZP ; save flags
	TXA
	AND8 #$0f
	SEC
	SBC #1
	TAX
	ORA animWorkZP
;	STA (te),Y
	move.b	AREG,2(a3)

	CPX #0
	BNE .animDone

	; re-init anim delay
;	LDA (te),Y
;	ORA #&08
;	STA (te),Y
	or.b	#$08,2(a3)

	; See which type of alien it is, flip frame if necessary
;	LDY #3
;	LDA (te),Y
	move.b	3(a3),AREG
	move.b	AREG,d3
	AND8 #%11
	BEQ .snowBall

	; ...else flip frame
;	LDA (te),Y
;	EOR #&80
;	STA (te),Y
	move.b	d3,AREG
	eor.b	#$80,AREG
	move.b	AREG,3(a3)
	move.b	AREG,d3

	AND8 #$80
	BEQ .frameTwo
	
.frameOne
;	LDY #3
;	LDA (te),Y
	move.b	d3,AREG
	AND8 #%11
	CMP8 #1
	BEQ .penguinFrameOne
	JMP .elderThingFrameOne
	
.snowBall
;	LDA #8
;	LDY #6
;	STA (te),Y
	move.b	#8,6(a3)
	;JMP animDone
	rts
	
.penguinFrameOne
;	LDA #0
;	LDY #6
;	STA (te),Y
	move.b	#0,6(a3)
	;JMP animDone
	rts

.elderThingFrameOne
;	LDA #4
;	LDY #6
;	STA (te),Y
	move.b	#4,6(a3)
	;JMP animDone
	rts

.frameTwo
;	LDY #3
;	LDA (te),Y
	move.b	d3,AREG
	AND8 #%11
	CMP8 #2
	BEQ .elderThingFrameTwo

.penguinFrameTwo
;	LDA #2
;	LDY #6
;	STA (te),Y
	move.b	#2,6(a3)
	;JMP animDone
	rts
	
.elderThingFrameTwo
;	LDA #6
;	LDY #6
;	STA (te),Y
	move.b	#6,6(a3)
	
.animDone:
	RTS
;	}
	

* a3 = enemy pointer
updateEnemyClassicStyle
;	{
	JSR updateEnemyAnimation
	
	; Update alien position
;	LDY #2
;	LDA (te),Y
	move.b	2(a3),AREG
	TAX 			; new
	AND8 #$10
	BNE .skipper
	TXA
	moveq	#0,d3	;LDY #0
	AND8 #$20		; check for y delta
	BEQ .doX
	moveq	#1,d3	;INY			; Instead of LDY #1, saves a byte
.doX
;	LDA (te),Y
;	CLC
;	ADC #ENEMY_SPEED
;	STA (te),Y		; alien.x += 2
	addq.b	#ENEMY_SPEED,(a3,d3.w)
	JMP .pop
	
.skipper
	TXA
	moveq	#0,d3	;LDY #0
	AND8 #$20
	BEQ .doX2
	moveq	#1,d3	;INY			; Instead of LDY #1, saves a byte
.doX2
;	LDA (te),Y		; else..
;	SEC
;	SBC #ENEMY_SPEED
;	STA (te),Y		; alien.x -= 2
	subq.b	#ENEMY_SPEED,(a3,d3.w)

.pop
* DJV on Amiga the enemy routines are called every frame (vs. every other on the BBC Micro),
* so to compensate we now only check the counter every other time (this avoids the
* alternative of having to double the max. counter value)
	move.b	(a3,d3.w),d4
	and.b	#1,d4
	bne.s	.earlyOut

;	LDY #4
;	LDA (te),Y
;	CLC
;	ADC #1
;	STA (te),Y		; current counter++
	addq.b	#1,4(a3)

;	STA td			; td = current counter
;	LDY #5
;	LDA (te),Y		; A = max counter
;	CMP td
	move.b	4(a3),d3
	cmp.b	5(a3),d3
	BNE .earlyOut		; if ne, quit
	
;	LDA #0
;	LDY #4
;	STA (te),Y		; .. else set counter=0
	clr.b	4(a3)

;	LDY #2
;	LDA (te),Y
;	EOR #&10
;	STA (te),Y		; .. and flip the sign
	eor.b	#$10,2(a3)

.earlyOut
	RTS
;	}


* a3 = enemy pointer
	; t0 - Low of sprite
	; t1 - High of sprite
drawEnemy
	; Get offset into table
;	LDY #6
;	LDA (te),Y
;	TAY
;	TAX ; save index for snowball, all a bodge really
;	LDA frameTable,Y
;	STA t0
;	LDA frameTable+1,Y
;	STA t1
		
;	LDY #0
;	LDA (te),Y		; x (+0)
;	STA t2
;	INY
;	LDA (te),Y		; y (+1)
;	STA t3

	move.b	currentAlien(pc),d3
	bne.s	.checkBob2
	lea	bobDataTable+BobDataSize(pc),a2		currentAlien 0 - use bob 1
	bra.s	.gotBob

.checkBob2
	cmp.b	#1,d3
	bne.s	.checkBob3
	lea	bobDataTable+(BobDataSize*2)(pc),a2	currentAlien 1 - use bob 2
	bra.s	.gotBob

.checkBob3
	move.w	#$f00,color0(a6)			currentAlien 2 or more - not supported so flag this by changing screen background colour
	rts

.gotBob	lea	frameTable(pc),a4
	moveq	#0,d4
	move.b	6(a3),d4
	;DJV 6(a3) has value 0,2,4,6,8 to identify sprite data, address originally placed in t0,t1
	add.w	d4,d4
	add.w	d4,a4
	move.w	(a4)+,SourceCol(a2)
	move.w	(a4),SourceRow(a2)

	moveq	#0,d6
	moveq	#0,d7
	move.b	(a3)+,d6		x
	move.b	(a3)+,d7		y
	add.w	d6,d6			double up for Amiga screen width
;	add.w	#AMIGA_X_OFFSET,d6
	move.w	d6,XCoord(a2)
	move.w	d7,YCoord(a2)
	move.w	#(16*SCREEN_DEPTH)*64+(2+1),BltsizeValue(a2)

	st	EnableFlag(a2)

	cmp.b	#8*2,d4 ; no flip on snowball
	BEQ .nocarry
;	INY
;	LDA (te),Y 		; sign (+2)
	move.b	(a3),d3
	and.b	#$10,d3
	BEQ .nocarry
;	CLC
	sf	FlippedInX(a2)
	bra.s	.done
.nocarry
;	SEC
	st	FlippedInX(a2)
.done
;	JSR plotSprite16x16
	RTS
