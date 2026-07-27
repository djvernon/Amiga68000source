_numSnowFlakes		= 10 ; can drop to 8 to save cycles / mem - REMEMBER THIS IS ALSO IN MEMORY.ASM TOO

_effectNone		= $00
_effectSnow		= $10
_effectPaletteChange	= $20 ; change to red for hell
_effectPaletteChange2	= $40 ; change to magenta for catacombs area
_effectGems	        = $80 ; read inv bits, plot red/green boxes for eyes on statues
_effectDark		= $08 ; dark unless have torch

	IFND	SHOW_KINGTUT_SPRITES
SNOWFLAKES_HARDWARE_SPRITE_WORDS	equ	(_numSnowFlakes*4)+2	; (two control words + two data words) per snow flake, then two end words
	ENDC

* Performance note:-
* Current (plotPixel) version takes around 16 raster lines
* SNOWFLAKES_USE_HARDWARE_SPRITES version took around 26 raster lines

restoreScreenUnderSnowFlakes
	IFND	SNOWFLAKES_USE_HARDWARE_SPRITES
	; Get number of snowflakes plotted last frame
	move.w	flakeActiveList,d5	get previous flake active count
	beq.s	.doneRemovingOldFlakes

	subq.w	#1,d5
	move.l	flakeActiveListEnd,a5

.removeOldFlakesLoop
* restore original screen data (NB done in reverse order so that screen is restored correctly)
	move.l	-(a5),a0
	move.w	-(a5),(a0)
	move.w	-(a5),PLANE_2_OFFSET(a0)
	move.w	-(a5),PLANE_3_OFFSET(a0)
	move.w	-(a5),PLANE_4_OFFSET(a0)
	dbra	d5,.removeOldFlakesLoop

.doneRemovingOldFlakes
	ENDC
	rts


snowFlakes
	moveq	#0,d3			loop counter
	IFD	SNOWFLAKES_USE_HARDWARE_SPRITES
	lea	flakeDrawList(pc),a1

* Empty flake draw list (binary tree)
	clr.l	snowFlakeTreeRoot
	ELSE
	move.w	#AMIGA_WHITE,newColour
	moveq	#0,d5			flake active count
	ENDC

* Update flakes
	lea	flakes,a3
	lea	sinTable,a4
	IFND	SNOWFLAKES_USE_HARDWARE_SPRITES
	lea	flakeActiveList+2,a5
	ENDC
.flakeLoop
	move.w	(a3)+,d6		get x pos
	move.w	(a3),d7			get y pos
	addq.w	#1,d7			increment y
	move.b	d3,d4
	and.b	#16,d4
	beq.s	.noInc			used for a parallex
	addq.w	#1,d7
.noInc
	cmp.w	#$d0,d7			if at bottom, wrap
	bcs.s	.ok
	moveq	#$20,d7
.ok
	move.w	d7,(a3)+		store Y back
	move.w	d7,d4
	add.w	d4,d4
	add.w	(a4,d4.w),d6		load sin for this Y position, add X pos to sin value

* New - windowed snowflake effect for caves
.checkFlakeX1
	moveq	#0,d4
	move.b	snowWindow+0,d4
	add.w	d4,d4			double up for Amiga screen width
	cmp.w	d4,d6
	bcs.s	.endOfFlake
.checkFlakeY1
	moveq	#0,d4
	move.b	snowWindow+1,d4
	cmp.w	d4,d7
	bcs.s	.endOfFlake
.checkFlakeX2
	moveq	#0,d4
	move.b	snowWindow+2,d4
	add.w	d4,d4			double up for Amiga screen width
	cmp.w	d4,d6
	bcc.s	.endOfFlake
.checkFlakeY2
	moveq	#0,d4
	move.b	snowWindow+3,d4
	cmp.w	d4,d7
	bcc.s	.endOfFlake

*TODO below needed? Not sure yet (NB Y reg = Y of snow flake)
	; Go through player tiles
;	LDX playerTileList
;	BEQ doneTileCheck
;	STY tf
;.checkPlayerTile
;	LDA playerTileList,X
;	CMP tf
;	BEQ endOfFlake
;	DEX
;	BNE checkPlayerTile
;
;.doneTileCheck

	IFD	SNOWFLAKES_USE_HARDWARE_SPRITES
* Add x,y to draw list (sorted by y)
	bsr.s	addFlakeToDrawList
	lea	14(a1),a1		to next available entry in draw list
	ELSE
	addq.w	#1,d5			another active flake
	bsr	plotPixelWithSave
	ENDC

.endOfFlake
	addq.w	#2,d3
	cmp.w	#_numSnowFlakes*2,d3
	bne.s	.flakeLoop

	IFD	SNOWFLAKES_USE_HARDWARE_SPRITES
	bsr.s	outputFlakes

* Finally end each sprite by writing two zero words
	moveq	#8-1,d7
	lea	currentEndPtrs(pc),a4
	moveq	#0,d3
.zero	move.l	(a4)+,a3
	move.l	d3,(a3)
	dbra	d7,.zero
	ELSE
	move.w	d5,flakeActiveList	store new flake active count
	move.l	a5,flakeActiveListEnd
	ENDC

	IFD	DEBUG_SNOWFLAKES
	bsr.s	countHardwareSprites
	ENDC
	rts


	IFD	SNOWFLAKES_USE_HARDWARE_SPRITES
	IFD	DEBUG_SNOWFLAKES
* Count used hardware sprites
countHardwareSprites
	movem.w	d0-d2,-(sp)
	moveq	#8-1,d5
	moveq	#0,d0
	lea	currentBottomY(pc),a3
.count	tst.w	(a3)+
	beq.s	.no
	addq.w	#1,d0
.no	dbra	d5,.count

;	bsr	makeDecimal
	bsr	makeHexWord
	moveq	#0,d0
	moveq	#32,d1
;	lea	decimalText(pc),a0
	lea	hexText+3(pc),a0	only need to print final digit
	bsr	print
	movem.w	(sp)+,d0-d2
	rts
	ENDC


;
;						215f76
;						0e,88
;				215f84									215f92
;				26,41									1b,cf
;		215fbc				215fd8					215fa0				0
;		50,28				5d,80					26,b2
;	215fca				215fe6		0			215fae		0
;	5b,25				6d,6d					3a,8a
;215ff4		0							0		0
;2f,23
;
;
;
;0e	1b	26	2f	3a	50	5b	5d	6d
;

* Add flake x,y to binary tree sorted by y ascending (i.e. smallest to left, largest to right)
addFlakeToDrawList
	move.w	d6,10(a1)		store x
	move.w	d7,12(a1)		store y

	moveq	#0,d7
	move.l	d7,2(a1)
	move.l	d7,6(a1)

	move.l	snowFlakeTreeRoot(pc),d7
	beq.s	.saveRoot

.yCompare
	move.l	d7,a2
	cmp.w	12(a2),d5		y
	bgt.s	.greater

	move.l	2(a2),d7
	bne.s	.yCompare

	move.l	a1,2(a2)
	rts

.greater
	move.l	6(a2),d7
	bne.s	.yCompare

	move.l	a1,6(a2)
	rts

.saveRoot
	move.l	a1,snowFlakeTreeRoot
	rts


outputFlakes
* Uses array of 8 sprite 'current bottom y' values (initialised to 0)
* Uses array of 8 sprite 'current end ptrs' (initialise to sprite data starts)
	moveq	#8-1,d7
	lea	currentBottomY(pc),a3
	lea	currentEndPtrs(pc),a4
	moveq	#0,d3
	move.l	#sprite0,d4
	move.l	#SNOWFLAKES_HARDWARE_SPRITE_WORDS*2,d5
.init	move.w	d3,(a3)+
	move.l	d4,(a4)+
	add.l	d5,d4			next sprite (NB assumes all sprites are contiguous)
	dbra	d7,.init

* Work through draw list, adding each flake to first available hardware sprite
	move.l	snowFlakeTreeRoot(pc),d3
	beq.s	.end			if zero then no flakes to draw

.doNode	move.l	d3,a1
	move.l	a1,-(sp)
	move.l	2(a1),d3		get left pointer
	beq.s	.outputItem

	bsr.s	.doNode
	move.l	(sp),a1

.outputItem
	* Draw Flake
	move.w	10(a1),d4		get x
	move.w	12(a1),d5		get y
	bsr.s	drawFlake

	move.l	(sp)+,a1
	move.l	6(a1),d3		get right pointer
	bne.s	.doNode

.end	rts


SNOW_FLAKE_HEIGHT	equ	1

* d4.w = x, d5.w = y
drawFlake
	;movem.w	d4/d5,-(sp)	temp
* Find first sprite whose 'current bottom y' < current flake y
	moveq	#8-1,d6
	lea	currentBottomY(pc),a3
	lea	currentEndPtrs(pc),a4
.find	cmp	(a3)+,d5
	addq.w	#4,a4
	dbgt	d6,.find

	ble.s	.done
	subq.w	#4,a4		locate correct sprite end ptr
	move.l	(a4),a5

* Use flake x,y to set SPRxPOS,SPRxCTL at 'current end ptr'
	move.w	d5,d7
	add.w	#HARDWARE_X_OFFSET,d4
	add.w	#HARDWARE_Y_OFFSET,d5

	moveq	#SNOW_FLAKE_HEIGHT,d6	height of sprites
	add.w	d5,d6

	lsl.w	#8,d6
	bcc.s	.novstop8

	addq.w	#2,d6			set vstop bit 8

.novstop8
	lsl.w	#8,d5
	bcc.s	.novstart8

	addq.w	#4,d6			set vstart bit 8

.novstart8
	lsr.w	#1,d4
	bcc.s	.nohstart0

	addq.w	#1,d6			set hstart bit 0

.nohstart0
	move.b	d4,d5

	move.w	d5,(a5)+
	move.w	d6,(a5)+

* Update sprite's 'current bottom y' to be item y+1
	addq.w	#1,d7
	move.w	d7,-(a3)

* Update sprite's 'current end ptr' to be next SPRxPOS,SPRxCTL address
	addq.w	#4,a5			skip data words
	move.l	a5,(a4)

.done	;movem.w	(sp)+,d6/d7	temp
	;move.l	a1,a5
	;bsr	plotPixel
	;move.l	a5,a1
	rts


snowFlakeTreeRoot
	dc.l	flakeDrawList


flakeDrawList
	* word unused, long left ptr, long right ptr, word x, word y
	* TODO remove unused word
	ds.w	_numSnowFlakes*7


currentBottomY
	ds.w	8
currentEndPtrs
	ds.l	8
	ENDC


initialiseSnowFlakes
* Initialise flakes x,y array
	moveq	#0,d7
	IFEQ	_numSnowFlakes-10
	moveq	#(5+11)*2,d5	x (doubled up for Amiga screen width)
	ELSE
	moveq	#(5+(118/_numSnowFlakes))*2,d5	x (doubled up for Amiga screen width)
	ENDC
	lea	flakes,a5
.flakesLoop
	cmp.w	#9,d7
	beq.s	.nine
	move.w	d5,(a5)+	x

	bsr	randomizeLong
	mulu	#(210-33)+1,d3
	swap	d3
	add.w	#33,d3
	move.w	d3,(a5)+	y
	bra.s	.next

.nine	* Tenth flake has fixed position
	move.w	#38*2,(a5)+	x (doubled up for Amiga screen width)
	move.w	#33,(a5)+	y

.next
	IFEQ	_numSnowFlakes-10
	add.w	#11*2,d5		increment x (doubled up for Amiga screen width)
	ELSE
	add.w	#(118/_numSnowFlakes)*2,d5	increment x (doubled up for Amiga screen width)
	ENDC
	addq.w	#1,d7
	cmp.w	#_numSnowFlakes+1,d7
	bne.s	.flakesLoop

	IFD	SNOWFLAKES_USE_HARDWARE_SPRITES
* Initialise hardware sprite data
	moveq	#8-1,d7
	lea	spritePtrs(pc),a5
.hwSprLoop
	move.l	(a5)+,a4

	moveq	#_numSnowFlakes-1,d6
	clr.l	(a4)			zero the first control words to disable sprite initially
.sprFlakeLoop
	addq.w	#4,a4			skip control words
	move.l	#$c0000000,(a4)+	%1100000000000000 0000000000000000
	dbra	d6,.sprFlakeLoop

	dbra	d7,.hwSprLoop
	ENDC
	rts


	IFD	SNOWFLAKES_USE_HARDWARE_SPRITES
* Used for screens that don't have _effectSnow set
hideSnowFlakes
	moveq	#8-1,d7
	lea	spritePtrs(pc),a5
.hwSprLoop
	move.l	(a5)+,a4
	clr.l	(a4)			zero the first control words to disable sprite
	dbra	d7,.hwSprLoop
	rts
	ENDC


	even
flakes
	ds.w	(_numSnowFlakes+1)*2	x,y array

	IFND	SNOWFLAKES_USE_HARDWARE_SPRITES
;Format:
;0 - Number of active flakes (word)
;Followed by array of flake items (long screen address, then 'SCREEN_DEPTH' words of bitplane data)
flakeActiveList
	dc.w	0
	ds.w	(_numSnowFlakes+1)*(2+SCREEN_DEPTH)

flakeActiveListEnd
	dc.l	0
	ENDC


	IFD	SNOWFLAKES_USE_HARDWARE_SPRITES
spritePtrs
	dc.l	sprite0,sprite1,sprite2,sprite3,sprite4,sprite5,sprite6,sprite7
	ENDC

sinTable
	dc.w	0,0,0,0,1,1,1,2,2,2,2,3,3,3,4,4,4,4,5,5,5,5,6,6,6,6,7,7,7,7,8,8,8,8,8,9,9,9,9,9,9,10,10,10,10,10,10,10,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11
	dc.w	12,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,10,10,10,10,10,10,10,9,9,9,9,9,9,8,8,8,8,8,7,7,7,7,6,6,6,6,5,5,5,5,4,4,4,4,3,3,3,2,2,2,2,1,1,1,0,0,0
	dc.w	0,0,0,0,-1,-1,-1,-2,-2,-2,-2,-3,-3,-3,-4,-4,-4,-4,-5,-5,-5,-5,-6,-6,-6,-6,-7,-7,-7,-7,-8,-8,-8,-8,-8,-9,-9,-9,-9,-9,-9,-10,-10,-10,-10,-10,-10,-10,-11,-11,-11,-11,-11,-11,-11,-11,-11,-11,-11,-11,-11,-11,-11,-11
	dc.w	-12,-11,-11,-11,-11,-11,-11,-11,-11,-11,-11,-11,-11,-11,-11,-11,-11,-10,-10,-10,-10,-10,-10,-10,-9,-9,-9,-9,-9,-9,-8,-8,-8,-8,-8,-7,-7,-7,-7,-6,-6,-6,-6,-5,-5,-5,-5,-4,-4,-4,-4,-3,-3,-3,-2,-2,-2,-2,-1,-1,-1,0,0,0

;	dc.w	0,0,0,0,0,0,0,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
;	dc.w	6,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,4,4,4,4,4,4,4,4,4,4,4,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,0,0,0,0,0,0
;	dc.w	0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-2,-2,-2,-2,-2,-2,-2,-2,-3,-3,-3,-3,-3,-3,-3,-3,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5
;	dc.w	-6,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-3,-3,-3,-3,-3,-3,-3,-3,-2,-2,-2,-2,-2,-2,-2,-2,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0


	IFD	ORIGINAL_VERSION
.snowFlakes
	{
	; Get number of snowflakes plotted last frame
	LDX flakeActiveList
	BEQ doneRemovingOldFlakes

	LDY #0

	LDA #LO(flakeActiveList+1)
	STA t0
	LDA #HI(flakeActiveList+1)
	STA t1

.removeOldFlakesLoop

	; Get mask - commented out on 26/05/2010 as it didn't do much?
	; LDA (t0),Y
	; STA t5
	INY
	; Get address lo
	LDA (t0),Y
	INY
	STA t2
	; Get address hi
	LDA (t0),Y
	INY
	STA t3

	; Store mask, eg remove flake : Y reg needs saving here, zeroing, and restoring
	TYA
	PHA
	LDA #0
    TAY
	STA (t2),Y
	PLA
	TAY

	DEX
	BNE removeOldFlakesLoop

.doneRemovingOldFlakes

	LDA #0
	STA t8		  	; t8 = active flake table
	STA t9			; t9 = x,y table offset (+2 bytes each pass)

	STA flakeActiveList	; Re-initialise active list

	TAY			; Zero index register

	LDA #7
	STA t2			; t2 = colour

.flakeLoop
	LDA (flakesLO),Y
	STA ta			; Get x pos to ta
	INY
	LDA (flakesLO),Y
	STA tb			; Get y pos to tb

	STY tc			; tc = index

	INC tb			; Increment Y
	LDA #16
	AND tc
	BEQ noInc		; Used for a parallex
	INC tb
.noInc
	LDA tb
	CMP #&d0		; If at bottom, wrap
	BCC ok
	LDA #&20
.ok
	STA (flakesLO),Y	; Store Y back
	TAY
	LDA (sinTableLO),Y	; Load sin for this Y position
	CLC
	ADC ta			; Add X pos to sin value

	STA t0			; t0 => X
	STY t1			; t1 = >Y

	; New - windowed snowflake effect for caves
.checkFlakeX1
	CMP snowWindow+0
	BCC endOfFlake
.checkFlakeY1
	CPY snowWindow+1
	BCC endOfFlake
.checkFlakeX2
	CMP snowWindow+2
	BCS endOfFlake
.checkFlakeY2
	CPY snowWindow+3
	BCS endOfFlake

	; Go through player tiles
	LDX playerTileList
	BEQ doneTileCheck
	STY tf
.checkPlayerTile
	LDA playerTileList,X
	CMP tf
	BEQ endOfFlake
	DEX
	BNE checkPlayerTile

.doneTileCheck
	JSR plotPixelSet
	BCC notPlotted

	; Add y offset
	CLC
	TYA
	ADC t3
	STA t3
	LDA #0
	ADC t4
	STA t4

	; We have another snowflake!
	INC flakeActiveList

	; Store details
	LDY t8
	LDA #LO(flakeActiveList+1)
	STA t0
	LDA #HI(flakeActiveList+1)
	STA t1

	; Save mask : Either left or right pixel
	TXA
	STA (t0),Y
	INY

	; Save transformed pixel address
	LDA t3
	STA (t0),Y
	INY
	LDA t4
	STA (t0),Y
	INY

	; Update offset
	STY t8

.notPlotted

.endOfFlake
	LDY t9
	INY
	INY
	STY t9
.flakeCheckEnd
	CPY #_numSnowFlakes * 2
	BNE flakeLoop

	; We need to a) set a flag to indicate just doing one snowflake OR store 1*2 at 'flakeCheckEnd'
	;            b) increment the offset of the flake number each time it reaches bottom
	;            c) init the flake to Y=12*6
	RTS
	}
	ENDC
