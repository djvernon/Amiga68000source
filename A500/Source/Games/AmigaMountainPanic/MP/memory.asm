	IFD	NOT_REQUIRED
ORG &0

.LZPOS              EQUW &9e ; 2 ZeroPage temporaries
.bitstr	            EQUB &fb ; 1 temporary (does not need to be ZP)
.irqTmp             EQUB 0
	ENDC
runLenCnt          dc.b	0
joystickEnabledFlag dc.b	0 ; 27/10/2013 - Flag to use the joystick
snowWindow         ds.b	4   ; Actual x1,y1,x2,y2 values of the window : default is 0,0,128,192
packedTileTable    ds.b	6
itemExtra          dc.b	0   ; used for elder sign and OR'd directly into playerInventory
itemTile		    dc.b	0
itemID			    dc.b	0
itemX			    dc.b	0
itemY			    dc.b	0
numAliens		    dc.b	0
currentAlien       dc.b	0	 ; current alien we are updating
alien1			    ds.b	6+2  ; 3 * alien work data
alien2			    ds.b	6+2
alien3			    ds.b	6+2
	IFD	NOT_REQUIRED
.spriteBitMasks		SKIP 2
	ENDC       
; PLAYER
playerPosX         dc.b	0	; 0
playerPosY         dc.b	0 	; 1
playerFlags 		dc.b	0	; 2 Player Direction (left/right)
playerScreen 		dc.b	0	; 3 Screen player is currently on
playerState 		dc.b	0	; 4
playerInventory 	dc.b	0	; 6 One bit for each item
playerUsingItem 	dc.b	0	; 7 Item ID currently using
currentRopeLength	dc.b	0  ; 8 Rope length (20, 30, 50)
keyFlags           dc.b	0	; 9 Current state of keys
playerGems         dc.b	0  ; a temp gems
playerOldState		dc.b	0  ; b
playerEnergy		dc.b	0  ; c
playerWalkSfxFlag	dc.b	0  ; d
playerCollFlag		dc.b	0
playerHPLoss		dc.b	0  ; f LOAD THIS WITH # OF FRAMES TO FLASH HP LOSS.
	        
; ROPE
ropeState 		dc.b	0	; 0 = off, 1 = firing, 2 = set, 4...
ropeLength 		dc.b	0	; rope's length
ropePosX 		dc.b	0
ropePosY 		dc.b	0
ropeOrgPosX 		dc.b	0
ropeOrgPosY 		dc.b	0
ropeOrgDir 		dc.b	0
ropeCounter 		dc.b	0	; Set up to be 30 or 40 depending on rope length
ropeAttachFrames 	dc.b	0
ropeTile		dc.b	0
ropeHarpoonShown	dc.b	0
;ropeAttachEffectShown	dc.b	0
screenDarkFlag		dc.b	0
playerTileList		dc.b	0
			ds.b	4

; TEMP WORK REGISTERS
t0                 dc.b	0
t1                 dc.b	0
t2                 dc.b	0
t3                 dc.b	0
t4                 dc.b	0
t5                 dc.b	0
t6                 dc.b	0
t7                 dc.b	0
t8                 dc.b	0
	IFD	NOT_REQUIRED
.t9                 SKIP 1
	ENDC
ta                 dc.b	0
tb                 dc.b	0
tc                 dc.b	0
;td                 dc.b	0
te                 dc.b	0
tf                 dc.b	0

; VARIOUS LOOKUP TABLES
;.curScreenLO 		SKIP 1	; Current screen pointer LO
;.curScreenHI 		SKIP 1	; Current screen pointer HI
curScreen	dc.l	0	; Current screen pointer
	IFD	NOT_REQUIRED
.sinTableLO 		SKIP 1	; Sin table LO			\ 
.sinTableHI 		SKIP 1	; Sin table HI			  ---- These can both just be variables
.flakesLO 		    SKIP 1	; Flakes position LO		/
.flakesHI		    SKIP 1	; Flakes position HI
	ENDC
shogSignWhenStun   dc.b	0
	IFD	NOT_REQUIRED
.lookup128LO		SKIP 1
.lookup128HI		SKIP 1
.irqCounter		    SKIP 1
	ENDC
getTileX		    dc.b	0
getTileY		    dc.b	0
getTileWork		dc.b	0
	IFD	NOT_REQUIRED
.joyTemp		    SKIP 1
.joyTemp2		    SKIP 1
.maskTable		    SKIP 4
.maskTableInverted	SKIP 4
;.scanLineOffset		SKIP 8 ; 0,8,16,24,32,40,48,56
	ENDC
hpLossFrameDelay
	dc.b	_hpLossFrameDelayLatch
	IFD	NOT_REQUIRED

; 7 spare
	SKIP 7

; SOUND WORKSPACE
.soundtemp			EQUB 0
.notereq			EQUW 0, 0, 0, 0		; addresses of note request sound blocks for each channel

.pitch				EQUB 0				; pitch channel 0
.volume				EQUB 0				; volume channel 0
					EQUB 0				; pitch channel 1
					EQUB 0				; volume channel 1
					EQUB 0				; pitch channel 2
					EQUB 0				; volume channel 2
					EQUB 0				; pitch channel 3
					EQUB 0				; volume channel 3					

.pitchenv			EQUB 0				; pitch envelope channel 0
.volenv				EQUB 0				; volume envelope channel 0
					EQUB 0				; pitch envelope channel 1
					EQUB 0				; volume envelope channel 1
					EQUB 0				; pitch envelope channel 2
					EQUB 0				; volume envelope channel 2
					EQUB 0				; pitch envelope channel 3
					EQUB 0				; volume envelope channel 3
			
.pitchenvindex		EQUB 0				; pitch envelope index channel 0
.volenvstage		EQUB 0				; volume envelope stage channel 0
					EQUB 0				; pitch envelope index channel 1
					EQUB 0				; volume envelope stage channel 1
					EQUB 0				; pitch envelope index channel 2
					EQUB 0				; volume envelope stage channel 2
					EQUB 0				; pitch envelope index channel 3
					EQUB 0				; volume envelope stage channel 3

PRINT "* Sound workspace (zp):", P%-soundtemp
	
; DYNAMIC TEXT
	ENDC
dynTextFrames      dc.b	0
dynTextString      dc.b	0
dynTextTileIndex   dc.b	0

 ; SPARE       
lastDrawnPlayerItem dc.b	0
animFlag            dc.b	0
redrawPlayerFlag    dc.b	0
        
; SHOGGOTH
shogX dc.b	0
shogY dc.b	0 ; 192?
shogMoveDelta dc.b	0
shogState dc.b	0 ; moving/stuck by sign/been hit(waiting)/running off (smashes exit block)
shogWaitFrames dc.b	0 ; waiting frames
;DJV	shogDrawElderSigns dc.b	0 ; do we need to draw elder signs?
shogForceElderDraw dc.b	0
shogSignsDropped dc.b	0

; ICICLE DROP IN HELL        
icicleDropFlag	dc.b	0              ; load with 1 to drop an icicle
icicleDropX	dc.b	0                 ; icicle dropping x pos
icicleDropY	dc.b	0                 ; icicle dropping y pos
icicleDropFrames	dc.b	0

titleScreenNumber	dc.b	0
titleScreenTextOne	dc.b	0
titleScreenTextTwo	dc.b	0
titleScreenTextThree	dc.b	0

	IFD	NOT_REQUIRED
.spriteWorkZP SKIP 2
	ENDC
animWorkZP dc.b	0
	IFD	NOT_REQUIRED
.tileWorkZP SKIP 1
	ENDC
itemRedrawFlag dc.b	0

numElderSigns dc.b	0 ; max 4
elderSignsPos ds.b	2*4 ; x,y co-ords for 4 elders

currentTileBank dc.b	0
	IFD	NOT_REQUIRED
.unpackTable SKIP 32
.colours SKIP 18
        
PRINT "* Zero page ends at ", ~P%-1, "Spare block (zp): ", &FC-sexyEricaPreston
	
.sexyEricaPreston:
SKIPTO &FC
                    SKIP 1 ; OS irq
	ENDC

animDelay:
        dc.b	0
wasPressedFlagGems:
	    dc.b	0
wasPressedFlagInventory:
        dc.b	0
        
	IFD	NOT_REQUIRED
ORG &100
.start:        
.stackStart:
        SKIP 33
.stackEnd:

timerlength = 76*8*26

.irq:
	LDA &FE4D:AND #&10:BNE irqadc
	LDA &FE4D:AND #&02:BNE irqvsync
	
.irqtimer:
	LDA #&40:STA &FE4D
	
	; 'force' vsync here
	INC irqCounter
	LDA &FC
	RTI
.irqadc
	; clear irq
	LDA #&10
	STA &FE4D

	; get channel
.getADCChannel
	LDA &FEC0
	AND #3
	BEQ channel1ADC
	
.channel2ADC
	LDA &FEC1
	STA joyTemp2
.chan2Out
	LDA &FC
	RTI

	; channel 1 - left/right channel
.channel1ADC
	LDA &FEC1
	EOR #&FF
	STA joyTemp
	; chain in channel 2 read
	LDA #1
.channel1ADCa
	STA &fec0
	LDA &FC
	RTI
	
.irqvsync
	STA &FE4D
	LDA #LO(timerlength):STA &FE44
	LDA #HI(timerlength):STA &FE45
	
	; Cycle the bottom cols if player is experiencing HP/SAN loss
	TXA
	PHA
	TYA
	PHA

	JSR updatesound

	LDA #0
	STA irqTmp
	LDA playerHPLoss
	BEQ noSanLoss
	INC irqTmp
	LDX #0
        
.noSanLoss:
	LDA irqTmp
	BEQ irqOut

.palChangeLoop:
	DEC irqCounters,X
	BNE irqLoopEnd
	
	; Dropped to 0 - reprogram palette
	LDA irqIndices,X
	EOR #1
	STA irqIndices,X

	TAY
	LDA irqColours,Y
	STA $fe21

	; And reload latch
	LDA #5
	STA irqCounters,X

.irqLoopEnd:
	;LDX #0
	DEC irqTmp
	BNE palChangeLoop

.irqOut:
	PLA
	TAY
	PLA
	TAX
	LDA &FC
	RTI

	; Indices into tables for HP/SAN
.irqIndices:
	EQUB 0
	;EQUB 3
	
.irqColours:
	EQUB &e0 + PAL_red
	EQUB &e0 + PAL_white
	;EQUB &90 + PAL_white
	;EQUB &90 + PAL_red
	
.irqCounters:
	EQUB 5
	;EQUB 5
	ENDC

	; This little table maps playerstates to base animation pointers.
	; Notice that on X>=4, no animation is performed, i.e. firing rope or falling.
playerAnimDrawTable
	dc.b	0,2,4,2,6,1

	IFD	NOT_REQUIRED
.textPixelTable:
	EQUB &00,&2a,&55,&3c

INCLUDE "inventory.asm"
	ENDC
shogPatchOne:
	dc.b	8|_bitFlipped
	dc.b	0
	dc.b	1
	dc.b	8|_bitCollidable
shogPatchTwo:
	dc.b	1|_bitCollidable
	dc.b	1
	dc.b	8|_bitFlipped
	dc.b	0
	IFD	NOT_REQUIRED
.enemyDataPtrs:
	EQUB 0,alien1,alien2,alien3
.colSound:
    EQUB 255
    EQUB 1
    EQUB 1
        
; pitch, pitch envelop, volume envelope
.itemUseSound:
    EQUB 80
    EQUB 0
    EQUB 1

.ropeAttachSound:
EQUB 238  ; pitch
EQUB 0    ; pitch envelope
EQUB 4    ; volume envelope

PRINT "* Spare block (after $100 stack, irq, inventory):", &204-P%
	
SKIPTO &204
        EQUW irq
	ENDC

congratulationsScreen:
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b $81,$f0,10
	dc.b $81,$f0,0
	dc.b $81,$f0,2
	dc.b $99,2,5,5|_bitFlipped,2
	dc.b $99,2,6,6|_bitFlipped,2
	dc.b $FF,$f0,11


	even
gameOverText:
	LDX #0
	LDY #23
;	LDA #LO((&4000+(512*13))+96-16)	;DJV row=13, column=80/32=2 (plus adjustment)
;	STA t2
;	LDA #HI((&4000+(512*13))+96-16)
;	STA t3
	moveq	#2+16/2,d4		+16/2 to centre on double width Amiga screen
	move.w	#13*8,d5
	JSR drawStringWithOSFont

	LDX #0
	LDY #22
;	LDA #LO((&4000+(512*14))+96-16)	;DJV row=14, column=80/32=2 (plus adjustment)
;	STA t2
;	LDA #HI((&4000+(512*14))+96-16)
;	STA t3
	moveq	#2+16/2,d4		+16/2 to centre on double width Amiga screen
	move.w	#14*8,d5
	JSR drawStringWithOSFont

	LDX #0
	LDY #23
;	LDA #LO((&4000+(512*15))+96-16)	;DJV row=15, column=80/32=2 (plus adjustment)
;	STA t2
;	LDA #HI((&4000+(512*15))+96-16)
;	STA t3
	moveq	#2+16/2,d4		+16/2 to centre on double width Amiga screen
	move.w	#15*8,d5
	JSR drawStringWithOSFont
	RTS

localElderSignPos:
	dc.b	48,208
	dc.b	48+8,208
	dc.b	48,208+8
	dc.b	48+8,208+8
	
	IFD	NOT_REQUIRED
PRINT "* Spare block ($206 - $257), probs congratulations page code: ",&258-P%

SKIPTO &258
        EQUB 2
	
.itemSprites:
        INCBIN "BIN/BBCITMS.DAT" ; 224 bytes.. so a little spare (32 bytes...)

.tileAddressTable:		; 96 * 2 = 192 bytes of tile lookup
	FOR i,0,11,1
	  FOR j,0,7,1
	    EQUW &4800+(i*1024)+(j*64)
	  NEXT
	NEXT
        
;SKIPTO &4C0
.lookup128:			; 128* lookup data (0..31 * 128)
	FOR n,0,31,1
	  EQUB LO(n*128)
	  EQUB HI(n*128)
	NEXT

INCLUDE "snowflakes.asm"
	ENDC

	even
playerStateJumpTables
	dc.l	updatePlayerNormal
	dc.l	updatePlayerLadder
	dc.l	updatePlayerClimbingRope
	dc.l	updatePlayerClimbingScene
	dc.l	updatePlayerFiringRope
	dc.l	updatePlayerFalling

	IFD	NOT_REQUIRED
.alienPointerTable:
	EQUB alien1
	EQUB alien2
	EQUB alien3
	ENDC

shogRedrawTiles:
	dc.b	(8*9)-1
	dc.b	(8*10)-1
	dc.b	(8*11)-1

	IFD	NOT_REQUIRED
PRINT "* Spare block (post snowflakes, pre Y lookup):", &500-P%
	
SKIPTO &500
.spriteYLookup:
	FOR i,0,255,1
	  EQUB LO(&4000+((i DIV 8)*512)+(i AND 7))
	NEXT

	FOR i,0,255,1
	  EQUB HI(&4000+((i DIV 8)*512)+(i AND 7))
	NEXT

PRINT "Sanity: ",~P%
;SKIPTO &700
.unpackedTileXSprites:
	INCBIN "BIN/BBCTLEX.DAT"

SKIPTO &900
.sinTable:
FOR n, 0, 255
	EQUB (SIN(n/128*PI)) * 6
NEXT

SKIPTO &A00
	ENDC
collData			; 96 bytes of collision data
	ds.b	12*8
tileData:			; 96 bytes of tile data
	ds.b	12*8

	IFD	NOT_REQUIRED
.flakes:    		; 64 bytes spare here.
FOR n, 0, 10
   IF (n <> 9)
     EQUB 5+(n+1)*11      ; x
   ELSE
     EQUB (38)
   ENDIF

   IF (n <> 9)
     EQUB RND(210-33)+33  ; y
   ELSE
     EQUB 33
   ENDIF
NEXT
        ENDC
	IFD	NOT_REQUIRED
flakeActiveList:		; needed = 1+(2*12)=37          = &AD8
	ds.b	1+(2*12)
	ENDC

	IFD	NOT_REQUIRED
; Rope Data Format
; 0 - Number of rope elements (max 40 here, eg 1+(40*3) = 121)
; Element data:
;               (n+1) : Transformed pixel address LO
;  		        (n+2) : Transformed pixel address HI
;               (n+3) : Mask of this pixel (used when redrawing rope)
	
SKIPTO &B00
	ENDC

	even
ropeData:
	IFD	ORIGINAL_VERSION
; Rope Data Format
; 0 - Number of tiles used by rope
; Element data:
;               (n+1) : Tile index
	ds.b	88
	ENDC
; Rope Data Format:
;0 - Number of pixels used by rope (word)
;Followed by array of pixel items (long screen offset, word pixel mask)
	dc.w	0
	ds.w	(2+1)*50	; Enough for rope length of 50

ropeTileList:
	ds.b	16

	even
stringTable:
;{        
	dc.l .s1
	dc.l .s2
	dc.l .s3
	dc.l .s4
	dc.l .s5
	dc.l .s6
	dc.l .s7
	dc.l .s8
	dc.l .s9
	dc.l .s10
	dc.l .s11
	dc.l .s12
	dc.l .s13
	dc.l .s14
	dc.l .s15
	dc.l .s16
	dc.l .s17
	dc.l .s18
    dc.l .s19
    dc.l .s20
    dc.l .s21
    dc.l .s22
    dc.l .s23
    dc.l .s24
    dc.l .s25
    dc.l .s26
    dc.l .s27
    dc.l .sAmiga

	IFD	NOT_REQUIRED
MAPCHAR '0','9',16
MAPCHAR 'A','Z',33
MAPCHAR 'a','z',33+26+6
MAPCHAR '(',8
MAPCHAR ')',9
MAPCHAR '+',11
MAPCHAR '!',1
MAPCHAR '-',13
MAPCHAR '/',15
	ENDC

.s1:
	dc.b "MOUNTAIN PANIC",0
.s2:
	dc.b " Press fire",0
.s3:
	dc.b "Base Camp",0
.s4:
	dc.b "Waste Land",0
.s5:
	dc.b "Cave Mouth",0
.s6:
	dc.b "In The Cave",0
.s7:
	dc.b "Catacombs",0
.s8:
	dc.b "Under The Camp",0
.s9:
	dc.b "A Strange Cave",0
.s10:
	dc.b "(c) 2013",0
.s11:
	dc.b "Retro Software",0
.s12:
	dc.b "The Gate",0
.s13:
	dc.b "Poor Lake",0
.s14:
	dc.b "Poor Gedney",0
.s15:
	dc.b "The East Tower",0
.s16:
	dc.b "The West Tower",0
.s17:
	dc.b "The Abyss",0
.s18:
    dc.b "A Final Vision",0
.s19:
	dc.b "Rope",0
.s20:
    dc.b "Rope +",0
.s21:
    dc.b "Gem",0
.s22:
    dc.b "Lamp",0
.s23:
    dc.b " Game over ",0
.s24:
    dc.b "           ",0
.s25:
    dc.b "Game complete!",0
.s26:
    dc.b "Amazing!",0
.s27:
    dc.b "Ration",0
.sAmiga
	dc.b "Amiga version",0

	IFD	NOT_REQUIRED
MAPCHAR '0','9','0'
MAPCHAR 'A','Z','A'
MAPCHAR 'a','z','a'
MAPCHAR '(','('
MAPCHAR ')',')'
MAPCHAR '+','+'
MAPCHAR '!','!'
MAPCHAR '-','-'
MAPCHAR '/','/'
	ENDC
;}

	IFD	NOT_REQUIRED
\ *******************************************************************
\ *  Sound frequency table
\ *******************************************************************
	
.freqlo
	FOR n, 0, 47
		EQUB LO(INT(1016 / 2^(n/48) + 0.5))
	NEXT

IF HI(freqlo)<>HI(freqlo+47)
	PRINT "Warning: freqlo table crosses page boundary"
ENDIF
	ENDC

itemTable:
        dc.b _itemRope, _bitRope
        dc.b _itemTorch, _bitTorch
        dc.b _itemGemRed, _bitGemRed
        dc.b _itemGemBlue, _bitGemBlue
        dc.b 0

	IFD	NOT_REQUIRED
PRINT "* Spare after text,sound frequency and item lookup:",&D00-P%        
	
.pageD:
SKIPTO &D00
        RTI
	
INCLUDE "text.asm"

.icicleSprite:
        INCBIN "BIN/BBCITMS2.DAT"
	ENDC

elderSignPositions:
	dc.b	80,237
	dc.b	88,237
	dc.b	80,245
	dc.b	88,245

	IFD	NOT_REQUIRED
PRINT "* Spare block (page D, after RTI and text PUT SPRITE HERE FOR ICICLE):", &E00-P%

SKIPTO &e00
.unpackedTileSprites:

SKIPTO &1200
.tileSpritesPacked:
        INCBIN "BIN/BBCTLE1.PAK"
.tileSpritesPacked2:
        INCBIN "BIN/BBCTLE2.PAK"
.tileSpritesPacked3:
        
.alienData:
.enemyData:
	INCBIN "BIN/BBCALN.DAT"
	INCBIN "BIN/BBCALN2.DAT"
.shoggothData:
    INCBIN "BIN/BBCSHOG.DAT"
        
GUARD &7fff
	ENDC
