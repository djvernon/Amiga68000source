mapData:
	; Effect flags:
	;		1 Snow
	;       2 Room is dark unless have lamp
	;		3 Colour cycling takes place
	;       4 Shoggoth

	; Screen 0 : Title page
	dc.b $00 		 ; High nibble: Tile set number | Low nibble: Index into string table
	dc.b 0			 ; Index into screen table and flip bit (7bits index + 1 flip bit)
	dc.b _effectSnow	 ; FX Flag (5) | ITEM COLLECTED BIT | [1..0] : Number aliens present   *** NEW REWORK
	dc.b 0,0,0,0		 ; Exit screens NSEW
	dc.b 0			 ; Use one of these bits to restore the item bits on a game over *** NEW REWORK : xxxxx %011 <- high nibble+1: san lose(max25), 1 bit spare, 1 bit for sanloss, 1 for item!

	; Screen 1 : Base camp
	dc.b $02 		 ; High nibble: Tile set number | Low nibble: Index into string table
	dc.b 1			 ; Index into screen table and flip bit (7bits index + 1 flip bit)
	dc.b _effectSnow ; Snow, no items
	dc.b 0,0,2,40    ; Exit screens NSEW
	dc.b 0           ; Use one of these bits to restore the item bits on a game over *** NEW REWORK

	; Screen 2 : Wasteland
	dc.b $03		 ; Index into string table
	dc.b 2			 ; Index into screen table and flip bit (7bits index + 1 flip bit)
	dc.b _effectSnow|0	 ; FX Flag (5)
	dc.b 0,0,3,1		 ; Exit screens NSEW
	dc.b 0		 ; Use one of these bits to restore the item bits on a game over *** NEW REWORK

	; Screen 3 : Wasteland
	dc.b $03		 ; Index into string table
	dc.b 2			 ; Index into screen table and flip bit (7bits index + 1 flip bit)
	dc.b _effectSnow|1	 ; FX Flag (5) 
	dc.b 0,0,4,2		 ; Exit screens NSEW
	dc.b 0			 ; Use one of these bits to restore the item bits on a game over *** NEW REWORK

	; Screen 4 : Wasteland with ladder
	dc.b $03
	dc.b 3
	dc.b _effectSnow|0
	dc.b 0,0,5,3
	dc.b $00

	; Screen 5 : Cave mouth
	dc.b 4			 ; Index into string table
	dc.b 4			 ; Index into screen table and flip bit (7bits index + 1 flip bit)
	dc.b _effectSnow|0	 ; FX Flag (5) 
	dc.b 0,12,6,4		 ; Exit screens NSEW
	dc.b 0			 ; Spare byte

	; Screen 6 : Right of cave mouth
	dc.b $03
	dc.b 5
	dc.b _effectSnow|0
	dc.b 0,0,7,5
	dc.b 0

	; Screen 7 : Right of cave mouth w/ ladder
	dc.b $03
	dc.b 6
	dc.b _effectSnow|0
	dc.b 8,0,9,6
	dc.b 0

	; Screen 8 : Above 6
	dc.b $03
	dc.b 7
	dc.b _effectSnow|0
	dc.b 0,7,11,10
	dc.b 0

	; Screen 9 : The clearing
	dc.b $03
	dc.b 8
	dc.b _effectSnow|0
	dc.b 0,15,22,7
	dc.b 0

	; Screen 10 : Cave to left
	dc.b 8
	dc.b 9
	dc.b 0|SCREEN_FLAGS_ITEM_PRESENT|1
	dc.b 0,0,8,0
	dc.b $01 		; item

	; Screen 11 : Cave to right
	dc.b 8
	dc.b 10
	dc.b 0|SCREEN_FLAGS_ITEM_PRESENT|2
	dc.b 0,0,0,8
	dc.b $01 ; item

	; Screen 12 : In the cave
	dc.b $25
	dc.b 11
	dc.b _effectSnow|1
	dc.b 0,20,13,16
	dc.b %110 ; sanity + no item

	; Screen 13 : Right of "In the cave"
	dc.b $25
	dc.b 12
	dc.b 1
	dc.b 0,0,15,12
	dc.b 0

	; Screen 14 : east tower entrance
	dc.b $20|14
	dc.b 19
	dc.b _effectSnow|1
	dc.b 0,0,23,15
	dc.b 0

	; Screen 15 : Poor Lake
	dc.b $20|12
	dc.b 13
	dc.b _effectSnow|SCREEN_FLAGS_ITEM_PRESENT
	dc.b 9,0,14,13
	dc.b 1

	; Screen 16 : Left of "In the cave"
	dc.b $25
	dc.b 14
	dc.b 0|2
	dc.b 0,0,12,17
	dc.b 0

	; Screen 17 : Left again
	dc.b $25
	dc.b 15
	dc.b 1|SCREEN_FLAGS_ITEM_PRESENT
	dc.b 0,0,16,18
	dc.b 1

	; Screen 18 : Left yet again
	dc.b $25
	dc.b 14
	dc.b 0|2
	dc.b 0,0,17,19
	dc.b 0

	; Screen 19 : Under base camp
	dc.b $20|7
	dc.b 16
	dc.b 0|1
	dc.b 0,0,18,25
	dc.b 0

	; Screen 20 : 2 Down from cave mouth
	dc.b $25
	dc.b 17
	dc.b 0|SCREEN_FLAGS_ITEM_PRESENT
	dc.b 12,0,0,21
	dc.b 1

	; Screen 21 : Left of 20
	dc.b $25
	dc.b 18
	dc.b 0|SCREEN_FLAGS_ITEM_PRESENT
	dc.b 0,0,20,0
	dc.b $01

	; Screen 22 : Above east tower entrance
	dc.b $20|14
	dc.b 20
	dc.b _effectSnow|0
	dc.b 46,14,0,9
	dc.b 0

	; Screen 23 : East tower base
	dc.b $20|14
	dc.b 21
	dc.b 0|1
	dc.b 27,28,29,14
	dc.b 0
	
	; Screen 24 : Poor Gedney
	dc.b $00|13
	dc.b 22
	dc.b _effectSnow|1|SCREEN_FLAGS_ITEM_PRESENT
	dc.b 0,0,0,48
	dc.b %111 ; sanity + item

	; Screen 25 : Left of 'under the camp'
	dc.b $20|7
	dc.b 23
	dc.b 0|2
	dc.b 0,31,19,0
	dc.b 0

	; Screen 26 : Top of east tower
	dc.b $20|14
	dc.b 24
	dc.b _effectSnow|1|SCREEN_FLAGS_ITEM_PRESENT
	dc.b 0,27,0,46
	dc.b 1

	; Screen 27 : East tower midrif
	dc.b $20|14
	dc.b 25
	dc.b 0
	dc.b 26,23,0,0
	dc.b 0

	; Screen 28 : Gate to hell
	dc.b $20|11
	dc.b 26
	dc.b _effectGems
	dc.b 23,0,41,0
	dc.b 0

	; Screen 29 : East of east Tower
	dc.b $20|14
	dc.b 27
	dc.b _effectSnow|0
	dc.b 0,0,30,23
	dc.b 0

	; Screen 30 : Wasteland east
	dc.b $0|3
	dc.b 2
	dc.b _effectSnow|0
	dc.b 0,0,48,29
	dc.b 0

	; Screen 31 : Bottom left of under camp quadrant
	dc.b $20|7
	dc.b 28
	dc.b _effectPaletteChange2|SCREEN_FLAGS_ITEM_PRESENT|2
	dc.b 25,34,32,0
	dc.b %111 ; sanity+item

	; Screen 32 : Bottom right of under camp quadrant
	dc.b $20|7
	dc.b 29
	dc.b _effectPaletteChange2|2|SCREEN_FLAGS_ITEM_PRESENT
	dc.b 0,33,0,31
	dc.b 1 ; item

	; Screen 33 : Catacombs one
	dc.b $20|6
	dc.b 30
	dc.b _effectPaletteChange2|_effectDark|1
	dc.b 32,0,0,34
	dc.b %110 ; sanity

	; Screen 34 : Catacombs two
	dc.b $20|6
	dc.b 31
	dc.b _effectPaletteChange2|_effectDark|1|SCREEN_FLAGS_ITEM_PRESENT
	dc.b 0,47,33,35
	dc.b $01

	; Screen 35 : West tower base
	dc.b $20|15
	dc.b 32
	dc.b 0|2
	dc.b 36,0,34,0
	dc.b 0

	; Screen 36 : West tower middle #1
	dc.b $20|15
	dc.b 33
	dc.b 0
	dc.b 37,35,0,0
	dc.b 0

	; Screen 37 : West tower middle #2
	dc.b $20|15
	dc.b 33
	dc.b 0|1
	dc.b 38,36,0,0
	dc.b 0

	; Screen 38 : West tower top
	dc.b $20|15
	dc.b 34
	dc.b _effectSnow|SCREEN_FLAGS_ITEM_PRESENT
	dc.b 0,37,39,0
	dc.b 1 ; item

	; Screen 39 : Out of west tower (left of base camp)
	dc.b $20|$03
	dc.b 35
	dc.b _effectSnow
	dc.b 0,0,40,38 ; Exit back to base camp
	dc.b 0

	; Screen 40 : Wasteland to base camp
	dc.b $00|$03
	dc.b 2
	dc.b _effectSnow
	dc.b 0,0,1,39
	dc.b 0

	; Screen 41 : Hell #1
	dc.b $20|16
	dc.b 36
	dc.b _effectPaletteChange|0
	dc.b 0,44,42,28
	dc.b $0

	; Screen 42 : Hell #2
	dc.b $20|16
	dc.b 37
	dc.b _effectPaletteChange|SCREEN_FLAGS_ITEM_PRESENT|1
	dc.b 0,0,0,41
	dc.b $01

	; Screen 43 : Shoggoth #1
	dc.b $20|16
	dc.b 38
	dc.b _effectPaletteChange|1
	dc.b 0,0,44,0
	dc.b $00
	
	; Screen 44 : Shoggoth #2 (Drop in here from hell #1)
	dc.b $20|16
	dc.b 39
	dc.b _effectPaletteChange|0
	dc.b 0,0,45,43
	dc.b %110 ; sanity
	
	; Screen 45 : Shoggoth #3 (END GAME)
	dc.b $20|17
	dc.b 40
	dc.b _effectPaletteChange|0
	dc.b 0,0,49,44
	dc.b $00

	IFD REMOVED
	; Screen 46 : Secret room #1 (REMOVED)
	dc.b $20|8
	dc.b 41
	dc.b _effectPaletteChange|0
	dc.b 15,0,43,0
	dc.b $00
	ENDC
	
	; Screen 47 (Now 46) : Just left of east tower top
	dc.b $20|14
	dc.b 42
	dc.b _effectSnow
	dc.b 0,22,26,0
	dc.b $00

	IFD REMOVED
	; Screen 48 : Secret room #2 (REMOVED)
	dc.b $20|8
	dc.b 43
	dc.b _effectPaletteChange2|0
	dc.b 0,0,0,33
	dc.b 0
	ENDC

	; Screen 49 (Now 47): Catacombs extra #1
	dc.b $20|6
	dc.b 44
	dc.b _effectPaletteChange2|_effectDark
	dc.b 34,0,0,0
	dc.b 0

	; Screen 50 (Now 48) : Wasteland to Gedney #2
	dc.b $00|3
	dc.b 2
	dc.b _effectSnow|0
	dc.b 0,0,24,30
	dc.b 0

    ; Screen 51 (Now 49) : Congratulations
    dc.b $20|0
    dc.b 45
    dc.b _effectSnow|0
    dc.b 0,0,0,0
    dc.b 0

	even	
screenTable:
	dc.l screen1Data ; title, uses same screen = 0
	dc.l screen1Data
	dc.l screen2Data
	dc.l screen3Data
	dc.l screen4Data
	dc.l screen5Data
	dc.l screen6Data
	dc.l screen7Data
	dc.l screen8Data
	dc.l screen9Data
	dc.l screen10Data
	dc.l screen11Data
	dc.l screen12Data
	dc.l screen13Data
	dc.l screen14Data
	dc.l screen15Data
	dc.l screen16Data
	dc.l screen17Data
	dc.l screen18Data
	dc.l screen19Data
	dc.l screen20Data
	dc.l screen21Data
	dc.l screen22Data
	dc.l screen23Data
	dc.l screen24Data
	dc.l screen25Data
	dc.l screen26Data
	dc.l screen27Data
	dc.l screen28Data
	dc.l screen29Data
	dc.l screen30Data
	dc.l screen31Data
	dc.l screen32Data
	dc.l screen33Data
	dc.l screen34Data
	dc.l screen35Data
	dc.l screen36Data
	dc.l screen37Data
	dc.l screen38Data
	dc.l screen39Data
	dc.l screen40Data
	dc.l 0 ;screen41Data
	dc.l screen42Data
	dc.l 0 ;screen43Data
	dc.l screen44Data
    dc.l congratulationsScreen ; currently 45

	IFD	NOT_REQUIRED
IF FALSE	
	; Title screen
.titleScreenData
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b $03,1,1|_bitFlipped
	dc.b $07,10,3,3|_bitFlipped
	dc.b $FF,$f0,2
ENDIF
	ENDC

	; Base camp
screen1Data
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b $60, 1, _bitFlipped|1
	dc.b $62, 3, _bitFlipped|3,7
    dc.b $FF, $F0, _bitCollidable|2 ; New tile packing

	; Wasteland
screen2Data
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b $FF,$f0,_bitCollidable|2

	; Alien data 1 here
	dc.b 16*5		; x
	dc.b 16*12		; y
	dc.b %00110001		; Flags ( %1111, movetype, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $80		; anim frame flag ($80) and sprite id (0=snowball,1=penguin,2=elder)
	dc.b 0			; current counter
	dc.b 24			; max counter

	; Wasteland 3rd screen - snow and ladder
screen3Data
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b $1f,_bitCollidable|2,_bitClimbable|2,$f0,_bitCollidable|2
	dc.b $1f,5,_bitClimbable|4,$f0,5
	dc.b $1f,5,_bitClimbable|4,5,6,5
	dc.b $1f,5,_bitClimbable|4,$f0,5
	dc.b $1f,5,_bitClimbable|4,5,5,6
	dc.b $1f,5,_bitClimbable|4,$f0,5
	dc.b $1f,5,_bitClimbable|4,$f0,5
	dc.b $1f,5,_bitClimbable|4,$f0,5
	dc.b $FF,$f0,_bitCollidable|2


	; Cave mouth
screen4Data
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b $FF,_bitCollidable|9,_bitCollidable|9|_bitFlipped, $f0,_bitCollidable|2 ; new tile packing
	dc.b $3f,$f0,5
	dc.b $3f,$f0,5
	dc.b $3f,$f3,_bitHookable|9,$f3,_bitHookable|5
	dc.b $07,_bitHookable|9,5,5
	dc.b $03,9|_bitHookable, 5
	dc.b $01,_bitCollidable|6
	dc.b $09,2|_bitCollidable,_bitCollidable|5
	dc.b $F9,$f4,_bitCollidable|2,_bitCollidable|5,_bitCollidable|5

	; Right of cave mouth
screen5Data
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b $FF,$f0,2|_bitCollidable
	dc.b $FF,$f0,5
	dc.b $FF,$f0,5
	dc.b $FF,5,6,$f6,5
	dc.b $FF,$f0,5
	dc.b $FF,$f4,5,6,$f3,5
	dc.b $FF,$f0,5
	dc.b $FF,$f0,5
	dc.b $FF,$f0,5

	; Right of cave mouth, with ladder up etc
screen6Data
	dc.b $10,_bitClimbable|0
	dc.b $10,_bitClimbable|0
	dc.b $10,_bitClimbable|0
	dc.b $FF,$f5,_bitCollidable|2,_bitClimbable|_bitCollidable|2,_bitCollidable|2,_bitCollidable|2
	dc.b $FF,$f5,5,_bitClimbable|4,5,5
	dc.b $FF,$f5,5,_bitClimbable|4,5,5
	dc.b $FF,5,6,$f3,5,_bitClimbable|4,5,5
	dc.b $FF,$f3,5,6,5,_bitClimbable|4,5,5
	dc.b $FF,$f5,5,_bitClimbable|4,5,5
	dc.b $FF,$f4,5,_bitCollidable|5,_bitClimbable|4,5,5
	dc.b $FF,$f5,5,$f0,_bitCollidable|2
	dc.b $FF,$f0,5

	; Above ladder
screen7Data
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b $FF,$f3,_bitCollidable|9,_bitCollidable|_bitClimbable|0,$f0,_bitCollidable|9

	; Right of screen 6 : clearing
screen8Data
	dc.b $00
	dc.b $18,_bitHookable|9,_bitHookable|9
	dc.b $0
	dc.b $80,_bitHookable|_bitCollidable|9
	dc.b 0
	dc.b 7,_bitHookable|_bitCollidable|9,_bitClimbable|_bitCollidable|0,_bitHookable|_bitCollidable|9
	dc.b 2,_bitClimbable|0
	dc.b 2,_bitClimbable|0
	dc.b 2,_bitClimbable|0
	dc.b $12,_bitCollidable|2,_bitClimbable|0
	dc.b $f2,$f3,_bitCollidable|2, _bitCollidable|5, _bitClimbable|0
	dc.b $f2,6,$f3,5,_bitClimbable|0

	; Outside - cave left (contains food and snowball)
screen9Data
	dc.b $ff,_bitCollidable|6,$f0,_bitHookable|9
	dc.b $80,_bitCollidable|5
	dc.b $80,_bitCollidable|5
	dc.b $80,_bitCollidable|6
	dc.b $80,_bitCollidable|6|_bitFlipped
	dc.b $80,_bitCollidable|5
	dc.b $f8,_bitCollidable|_bitHookable|5,$f0,_bitCollidable|_bitHookable|9
	dc.b $80,_bitCollidable|5
	dc.b $80,_bitCollidable|6
	dc.b $80,_bitCollidable|5
	dc.b $c0,_bitCollidable|5,_bitCollidable|2
	dc.b $FF,_bitCollidable|5,_bitCollidable|6,$f0,_bitCollidable|2

	; Item one
	dc.b (16*1)+4
	dc.b (16*7)+8
	dc.b _itemElderSign|8 ; not sure about this placement.
	dc.b 0,0

	; Alien one
	dc.b 32			; x
	dc.b 16*12		; y
	dc.b $81		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $80		; anim frame + sprite type
	dc.b 32			; min x
	dc.b 16*7		; max x

	; Outside - cave right (contains rope)
screen10Data
	dc.b $ff,$f7,_bitHookable|9,_bitHookable|6
	dc.b $01,_bitCollidable|6
	dc.b $01,_bitCollidable|5
	dc.b $7f,_bitHookable|_bitCollidable|9,_bitHookable|_bitCollidable|9,_bitClimbable|0,$f3,_bitCollidable|_bitHookable|9,_bitCollidable|5
	dc.b $11,_bitClimbable|0,_bitCollidable|5
	dc.b $11,_bitClimbable|0,_bitCollidable|6
	dc.b $11,_bitClimbable|0,_bitCollidable|5
	dc.b $3f,$f3,_bitHookable|_bitCollidable|9,_bitClimbable|0,_bitHookable|_bitCollidable|9,_bitCollidable|5
	dc.b $05,_bitClimbable|0,_bitCollidable|5
	dc.b $05,_bitClimbable|0,_bitCollidable|5
	dc.b $07,_bitClimbable|0,_bitCollidable|2, _bitCollidable|_bitFlipped|6 
	dc.b $FF,$f6,_bitCollidable|2,_bitCollidable|5,_bitCollidable|5

    DEFITEM _itemRope,16*6+4,(16*4)+8,18,5+8
        
	; Alien data 1 here
	dc.b 32			; org x
	dc.b 16*4		; org y
	dc.b %11000001	; Flags ( %1111, move type, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b %10000000	; anim frame flag ($80) and sprite id (0=snowball,1=penguin,2=elder)
	dc.b 16			; current counter
	dc.b 16*5		; max counter

	dc.b 16*2		; x
	dc.b 16*12		; y
	dc.b %00110001		; Flags ( %1111, movetype, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $80		; anim frame flag ($80) and sprite id (0=snowball,1=penguin,2=elder)
	dc.b 0			; current counter
	dc.b 16			; max counter
        
	; In the cave
screen11Data
	dc.b $F1,$f0,_bitHookable|9
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $bf,1|_bitCollidable,_bitClimbable|3,_bitCollidable|_bitFlipped|1,$f3,_bitCollidable|11, _bitCollidable|1
	dc.b $bf,1|_bitCollidable, _bitClimbable|3,$f0,_bitCollidable|1
	dc.b $bf,9,_bitClimbable|3,$f0,_bitCollidable|1
	dc.b $3f,_bitClimbable|3,$f0,_bitHookable|9
	dc.b $20,_bitClimbable|3
	dc.b $20,_bitClimbable|3
	dc.b $FF,$f6,_bitCollidable|1,_bitCollidable|_bitClimbable|3,_bitCollidable|1

	; Alien data here
	dc.b 48			; x
	dc.b 16*12		; y
	dc.b %11000001		; flags
	dc.b $81		; anim frame+sprite type.  here 1 for a penguin.
	dc.b 48			; min x
	dc.b 16*7		; max x

	; Right of in the cave
screen12Data
	dc.b $Ff,$f0,_bitHookable|9
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $e0,_bitCollidable|1,_bitCollidable|1,_bitClimbable|3
	dc.b $e0,_bitCollidable|1,_bitCollidable|1,_bitClimbable|3
	dc.b $e0,_bitFlipped|9, _bitCollidable|1, _bitClimbable|3
	dc.b $7f,_bitHookable|_bitFlipped|9,$f2,_bitCollidable|1,_bitClimbable|3,$f0,_bitCollidable|1
	dc.b $3F,_bitHookable|_bitFlipped|9, _bitHookable|_bitFlipped|9,_bitClimbable|3,$f0,_bitHookable|9
	dc.b $08,3|_bitClimbable
	dc.b $FF,$f0,_bitCollidable|1
	
	; Alien data 1 here
	dc.b 16*3		; x
	dc.b 16*9		; y
	dc.b %01000001	; flags ( %1111, move type, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $81		; anim frame + sprite type
	dc.b 0		; min x
	dc.b 30		; max x
	
	; Right(2) of in the cave : contains first note : "Poor Lake"
screen13Data
	dc.b $F2,$f4,_bitHookable|9,_bitClimbable|3
	dc.b $02,_bitClimbable|3
	dc.b $02,_bitClimbable|3
	dc.b $0f,$f0,_bitCollidable|11;,_bitCollidable|11,_bitCollidable|11,_bitCollidable|11
	dc.b $0f,_bitHookable|_bitCollidable|9, _bitHookable|_bitCollidable|9, _bitCollidable|1, _bitCollidable|1
	dc.b $03,_bitCollidable|1, _bitCollidable|1
	dc.b $03,_bitCollidable|1, _bitCollidable|1
	dc.b $03,_bitCollidable|1, _bitCollidable|1
	dc.b $Fb,_bitCollidable|1,_bitClimbable|3,_bitCollidable|1,_bitCollidable|1, _bitClimbable|3,8|_bitFlipped,_bitCollidable|1
	dc.b $F9,9|_bitHookable, 3|_bitClimbable,_bitCollidable|1,8|_bitFlipped,_bitClimbable|3,_bitCollidable|1
	dc.b $6b,_bitClimbable|3,_bitCollidable|1,_bitClimbable|3,10,_bitCollidable|1
	dc.b $FF,$f0,_bitCollidable|1
	
    DEFITEM _itemHealth,16*5+4,(16*12)+8,26,(12*6)+4

	; Left of in the cave; this is this repeated twice
screen14Data
	dc.b $ff,$f0,_bitHookable|9
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $ff,$f3,_bitCollidable|8|_bitFlipped,_bitCollidable|1,_bitCollidable|1,$f0,_bitCollidable|_bitFlipped|8
	dc.b $18,_bitCollidable|1,_bitCollidable|1
	dc.b $18,_bitCollidable|1,_bitCollidable|1
	dc.b $18,_bitHookable|9,_bitHookable|9
	dc.b $00
	dc.b $00
	dc.b $FF,$f0,_bitCollidable|1

	; 2 penguins - one on top, one on bottom
	dc.b 16*3		; org x
	dc.b 16*12		; org y
	dc.b %11000001		; Flags ( %1111, move type, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $81		; anim frame + sprite type
	dc.b 0			; min x
	dc.b 16*7		; max x

	dc.b 16*4		; org x
	dc.b 16*6		; org y
	dc.b %11010001		; Flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $81		; anim frame + sprite type
	dc.b 0			; min x
	dc.b 16*7		; max x

	; Left of in the cave (2)
screen15Data
	dc.b $ff,$f0,_bitHookable|9
	dc.b $0
	dc.b $0
	dc.b $00
	dc.b $10, _bitCollidable|0
	dc.b $9f, _bitCollidable|_bitFlipped|8,_bitHookable|2,_bitCollidable|1,$f0,_bitCollidable|8|_bitFlipped
	dc.b $18, 2,0
	dc.b $18, 2,2
	dc.b $18, 2,2
	dc.b $18, 2,2
	dc.b $18, _bitFlipped|0, _bitFlipped|0
	dc.b $FF,$f0, _bitCollidable|1

	dc.b (16*5)-8
	dc.b (16*7)-8
	dc.b _itemGemRed
	dc.b 20 ; text id
	dc.b 4+(8*3) ; tile id

	; Alien data
	dc.b 16+8		; x
	dc.b 16*12		; y
	dc.b %00110001		; Flags (movetype,altering x,altering y,sign bit) and anim delay in bottom nibble
	dc.b $80		; anim frame
	dc.b 0			; current counter
	dc.b 24	

	; Under base camp - first contact with elder things
screen16Data
	dc.b $ff,$f0,_bitHookable|9
	dc.b $00
	dc.b $00
	dc.b $0c,_bitCollidable|8,_bitCollidable|8
	dc.b $1c,_bitCollidable|8,_bitHookable|9,9|_bitHookable
	dc.b $93,_bitCollidable|1, _bitHookable|9,_bitClimbable|3,_bitCollidable|1
	dc.b $83,9,_bitClimbable|3,1|_bitCollidable
	dc.b $07,$f0,_bitCollidable|1
	dc.b $17,_bitCollidable|0,_bitCollidable|0,_bitHookable|9,_bitCollidable|0
	dc.b $55,_bitCollidable|0,$f0,2
	dc.b $55,$f0,_bitFlipped|0
	dc.b $FF,$f0,_bitCollidable|1

	; Alien data : Elder thing on platform?
	dc.b 0		; x
	dc.b 16*9		; y
	dc.b $01		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $82		; anim frame + sprite type
	dc.b 0			; current counter
	dc.b 32			; max counter

	; 2 down from cave mouth
screen17Data
	dc.b $ff,$f6,_bitHookable|9,_bitClimbable|3,1
	dc.b $03,_bitClimbable|3,_bitCollidable|1
	dc.b $03,_bitClimbable|3,_bitCollidable|1
	dc.b $03,_bitClimbable|3,_bitCollidable|1
	dc.b $7f,_bitCollidable|_bitClimbable|3,$f4,_bitCollidable|8|_bitFlipped,$f2,1|_bitCollidable
	dc.b $43,_bitClimbable|3,_bitFlipped|_bitHookable|9,_bitCollidable|1
	dc.b $41,_bitClimbable|3,_bitCollidable|1
	dc.b $41,_bitClimbable|3,_bitCollidable|1
	dc.b $41,_bitClimbable|3,_bitCollidable|1
	dc.b $41,_bitClimbable|3,_bitCollidable|1
	dc.b $43,_bitClimbable|3,_bitCollidable|8,_bitCollidable|1
	dc.b $FF,$f0,_bitCollidable|1

    DEFITEM _itemHealth,16*5+4,(16*12)+8,26,(12*6)+4

	; Left of 2 down from cave mouth
screen18Data
	dc.b $ff,$f3,_bitCollidable|1,$f0,_bitHookable|9
	dc.b $e0,_bitCollidable|1,1,9
	dc.b $c0,_bitCollidable|1,9
	dc.b $80,_bitCollidable|1
	dc.b $c0,_bitCollidable|1,_bitCollidable|1
	dc.b $c0,_bitCollidable|1,_bitHookable|_bitCollidable|9
	dc.b $80,_bitCollidable|1
	dc.b $80,_bitCollidable|1
	dc.b $80,_bitCollidable|1
	dc.b $80,_bitCollidable|1
	dc.b $c0,_bitCollidable|1,_bitCollidable|8
	dc.b $FF,$f0,_bitCollidable|1

	; Item - elder sign piece
	dc.b 18 		; x
	dc.b 80+6		; y
	dc.b _itemElderSign|4
	dc.b 0,0

	; Right of 'poor lake', entrance to east tower
screen19Data
	dc.b $1,_bitCollidable|1
	dc.b $1,_bitCollidable|1
	dc.b $1,_bitCollidable|1
	dc.b $c1,_bitCollidable|11,_bitClimbable|3,_bitCollidable|1
	dc.b $c1,_bitCollidable|1,_bitClimbable|3,_bitCollidable|1
	dc.b $c1,_bitCollidable|1,_bitClimbable|3,_bitCollidable|1
	dc.b $c1,_bitCollidable|1,_bitClimbable|3,_bitCollidable|1
	dc.b $c3,_bitCollidable|1,_bitClimbable|3,_bitCollidable|11, _bitCollidable|1
	dc.b $c3,_bitCollidable|1,_bitClimbable|3,$f0,_bitHookable|_bitCollidable|9
	dc.b $c0,_bitCollidable|1,_bitClimbable|3
	dc.b $c0,_bitCollidable|1,_bitClimbable|3
	dc.b $FF,_bitCollidable|1,$f0,_bitCollidable|11

	; Alien data here
	dc.b 16*5		; org x
	dc.b 16*12		; org y
	dc.b %00110001          ; flags (movetype, altering x, altering y, sign bit; anim delay)
	dc.b $80		; anim frame + sprite type
	dc.b 0		; cur counter
	dc.b 16		; max  counter

	; Above east tower entrance
screen20Data
	dc.b $03,_bitClimbable|3,_bitCollidable|1
	dc.b $07,_bitHookable|_bitCollidable|9,_bitHookable|_bitCollidable|9,_bitCollidable|1
	dc.b $21,_bitHookable|9,_bitCollidable|1
	dc.b $81,_bitHookable|9,_bitCollidable|1
	dc.b $01,_bitCollidable|1
	dc.b $c1,_bitCollidable|9,_bitCollidable|9|_bitFlipped,_bitCollidable|1
	dc.b $29,_bitCollidable|9,_bitCollidable|9,_bitCollidable|1
	dc.b $01,_bitCollidable|1
	dc.b $01,_bitCollidable|1
	dc.b $01,_bitCollidable|1
	dc.b $01,_bitCollidable|1
	dc.b $01,_bitCollidable|1

	; East tower base
screen21Data
	dc.b $F5,_bitCollidable|1,$f3,2,_bitClimbable|3,_bitCollidable|1
	dc.b $f5,_bitCollidable|1,$f3,0|_bitFlipped,_bitClimbable|3,_bitCollidable|1
	dc.b $f7,_bitCollidable|1,$f5,1|_bitCollidable,_bitCollidable|1
	dc.b $f7,_bitCollidable|1,$f5,8|_bitFlipped|_bitHookable,_bitCollidable|1
	dc.b $81,_bitCollidable|1,_bitCollidable|1
	dc.b $81,_bitCollidable|1,_bitCollidable|1
	dc.b $81,_bitCollidable|1,_bitCollidable|1
	dc.b %10111101,1,$f4,_bitHookable|_bitCollidable|9, 1
	dc.b $81,_bitHookable|9,_bitHookable|9
	dc.b $00
	dc.b $00
	dc.b $e7,$f3,_bitCollidable|1,_bitClimbable|3,_bitCollidable|1,_bitCollidable|1

	dc.b 16*3		; x
	dc.b 16*6		; y
	dc.b %01000001	; Flags ( %1111, movetype, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $82		; anim frame + sprite type
	dc.b 0			; current counter
	dc.b 18
	
	; Poor Gedney : Contains torch
screen22Data
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b $08,10
	dc.b $38,$f0,_bitHookable|_bitCollidable|9
	dc.b $03, 1, _bitFlipped|1
	dc.b $03, 3, _bitFlipped|3
	dc.b $FF,$f0,_bitCollidable|2

	; Item - torch
	dc.b 18+(16*2)
	dc.b 80+6+(16*4)
	dc.b _itemTorch
	dc.b 21
	dc.b 3+(8*6)

	; alien
	dc.b 32			; org x
	dc.b 16*12		; org y
	dc.b %11000001	; Flags ( %1111, movetype, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $80		; anim frame
	dc.b 16			; min X
	dc.b 16*5		; max X
	
	; Left of 'under the camp'
screen23Data
	dc.b $ff,1,$f0,_bitHookable|9
	dc.b $80,_bitCollidable|1
	dc.b $80,_bitCollidable|1
	dc.b $80,_bitCollidable|1
	dc.b $8C,_bitCollidable|1,9|_bitHookable|_bitCollidable, 9|_bitHookable|_bitCollidable
	dc.b $c3,_bitCollidable|1,$f0,0|_bitCollidable
	dc.b $c3,_bitCollidable|1,2|_bitHookable,2,2
	dc.b $c3,_bitCollidable|1,2|_bitHookable,2,2
	dc.b $c3,_bitCollidable|1,0|_bitFlipped,2,2
	dc.b $e3,_bitCollidable|1,_bitCollidable|1,_bitCollidable|11,2,2 
	dc.b $e3,$f3,_bitCollidable|1,0|_bitFlipped,0|_bitFlipped
	dc.b $fF,$f4,_bitCollidable|1, _bitClimbable|3,$f0,_bitCollidable|1

	; Item data here
	; dc.b 16*4		; x
	; dc.b (16*5)+8		; y
	; dc.b 3*(4*8)		; item id

	; Alien data : Elder thing on platform?
	dc.b 32			; x
	dc.b 16*9		; y
	dc.b $01		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $82		; anim frame + sprite type
	dc.b 0			; current counter
	dc.b 24

	dc.b 64+16		; x
	dc.b 16*8		; y
	dc.b $11		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $82		; anim frame + sprite type
	dc.b 0			; current counter
	dc.b 24
	
	; East Tower top
screen24Data
	dc.b $0
	dc.b 0
	dc.b $81,_bitCollidable|11,_bitCollidable|11
	dc.b $ff,_bitCollidable|1,_bitCollidable|11,_bitCollidable|11,_bitClimbable|3,$f3,_bitCollidable|11,_bitCollidable|1
	dc.b $ff,$f3,1,_bitClimbable|3,$f0,1
	dc.b $ff,9|_bitFlipped,1,1,_bitClimbable|3,$f3,1,9
	dc.b $6e,$f0,1
	dc.b $6e,1,_bitHookable|_bitFlipped|9,_bitHookable|9,_bitFlipped|_bitHookable|9,1
	dc.b $42,_bitCollidable|1,_bitCollidable|1
	dc.b $c3,_bitCollidable|11,_bitCollidable|1, _bitCollidable|1,_bitCollidable|11
	dc.b $c3,$f0,_bitCollidable|1
	dc.b $ff,$f5,1|_bitCollidable, 3|_bitClimbable,1,1

	dc.b (16*2)+2
	dc.b $c0+8
	dc.b _itemElderSign|2
	dc.b 0,0

	dc.b 32			; x
	dc.b 16*10		; y
	dc.b %01000001		; flags
	dc.b $82		; anim frame+sprite type.  here 1 for a penguin.
	dc.b 0			; min x
	dc.b 24  		; max x

	; East Tower middle
screen25Data
	dc.b $ff,$f4,_bitCollidable|1,9|_bitHookable,3|_bitClimbable,_bitHookable|_bitFlipped|9,_bitCollidable|1
	dc.b $85,_bitCollidable|1,_bitClimbable|3,_bitCollidable|1
	dc.b $85,_bitCollidable|1,_bitClimbable|3,_bitCollidable|1
	dc.b $bf,$f0,_bitCollidable|1
	dc.b $a7,_bitCollidable|1,_bitHookable|0,_bitHookable|0,8|_bitFlipped,1
	dc.b $a5,_bitCollidable|1,_bitHookable|2,_bitHookable|2,1
	dc.b $a5,_bitCollidable|1,2,2,1
	dc.b $e5,_bitCollidable|1,_bitCollidable|8,_bitFlipped|0,_bitFlipped|0,1
	dc.b $ed,$f0,_bitCollidable|1
	dc.b $85,_bitCollidable|1,8|_bitHookable|_bitFlipped,_bitCollidable|1
	dc.b $f1,_bitCollidable|1,$f3,4,_bitCollidable|1
	dc.b $f7,_bitCollidable|1,$f3,_bitCollidable|0,_bitClimbable|3,_bitCollidable|1,_bitCollidable|1

	IFD	NOT_REQUIRED
IF FALSE        
	; Alien data : Elder thing on platform?
	dc.b 16			; x
	dc.b 16*9		; y
	dc.b $81		; Top nibble - flags ( %1111, elder, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $80		; anim frame
	dc.b 0			; current counter
	dc.b 40

	dc.b 16			; x
	dc.b 16*4		; y
	dc.b $81		; Top nibble - flags ( %1111, elder, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $80		; anim frame
	dc.b 0			; current counter
	dc.b 24
ENDIF        
	ENDC
		
	; Gate to hell
screen26Data
	dc.b $85,1|_bitCollidable,_bitClimbable|3,1
	dc.b $FD,1|_bitCollidable,$f4,4,_bitClimbable|3,1
	dc.b $FD,1|_bitCollidable,$f4,8|_bitFlipped|_bitCollidable|_bitHookable,_bitClimbable|3, 1
	dc.b $85,1|_bitCollidable,_bitClimbable|3,1
	dc.b $85,1|_bitCollidable,_bitClimbable|3,1
	dc.b $95,_bitCollidable|1,10,_bitClimbable|3,_bitCollidable|1
	dc.b $ff,_bitCollidable|1,_bitClimbable|3,$f0,_bitCollidable|1
	dc.b $ff,_bitCollidable|1,_bitClimbable|3,$f0,1|_bitCollidable
	dc.b $ff,_bitCollidable|1,_bitClimbable|3,$f0,8|_bitFlipped|_bitHookable;,$f2,8|_bitFlipped
	dc.b $C3,_bitCollidable|1,_bitClimbable|3,_bitHookable|5,_bitHookable|_bitFlipped|5
	dc.b $C3,_bitCollidable|1,_bitClimbable|3,_bitCollidable|6,_bitFlipped|6
	dc.b $FF,$f0,_bitCollidable|1

	; East of east tower
screen27Data
	dc.b $80,_bitCollidable|1
	dc.b $80,_bitCollidable|1
	dc.b $80,_bitCollidable|1
	dc.b $80,_bitCollidable|1
	dc.b $80,_bitCollidable|1
	dc.b $80,_bitCollidable|1
	dc.b $80,_bitCollidable|1
	dc.b $c0,_bitCollidable|1,_bitCollidable|11
	dc.b $c0,_bitHookable|_bitFlipped|9,_bitHookable|_bitCollidable|9
	dc.b $00
	dc.b $00
	dc.b $FF,$f0,_bitCollidable|11

	; Bottom left corner of 'under camp' quadrant
screen28Data
	dc.b $88,_bitCollidable|1,_bitClimbable|3
	dc.b $89,_bitCollidable|1,_bitClimbable|3,_bitCollidable|8
	dc.b $ff,_bitCollidable|1,_bitClimbable|3,$f0,_bitCollidable|1
	dc.b $ff,_bitCollidable|1,_bitClimbable|3,$f0, _bitHookable|_bitFlipped|8
	dc.b $c0,_bitCollidable|1,_bitClimbable|3
	dc.b $c0,_bitCollidable|1,_bitClimbable|3
	dc.b $c0,_bitCollidable|1,_bitClimbable|3
	dc.b $fb,$f0,_bitCollidable|1
	dc.b $fb,$f0,_bitCollidable|1
	dc.b $81,_bitCollidable|1,_bitCollidable|0
	dc.b $9d,_bitCollidable|1,8|_bitCollidable,4,4,2
	dc.b $9d,_bitCollidable|1,$f3,_bitCollidable|0,2

	; another rope
	dc.b 16*6+4
	dc.b (16*3)+8
	dc.b _itemRope
	dc.b 19 ; text id
	dc.b 5 ; tile id

	dc.b 32			; x
	dc.b 16*8		; y
	dc.b %11000001		; Top nibble - flags ( %1111, movetype, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $82		; anim frame + sprite type
	dc.b 32			; min
	dc.b 32+16*2		; max
	
	dc.b 64+16		; x
	dc.b (16*10)+6 		; y
	dc.b %00110001		; Top nibble - flags ( %1111, movetype, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $80		; anim frame + sprite type
	dc.b 0			; min
	dc.b 36
	
	; Bottom right corner of 'under camp' quadrant
screen29Data
	dc.b $0
	dc.b $01,_bitCollidable|8
	dc.b $3f,$f0,_bitCollidable|1
	dc.b $3c,$f0,_bitHookable|_bitCollidable|_bitFlipped|8
	dc.b $0
	dc.b $0
	dc.b $03,_bitCollidable|_bitFlipped|8,_bitClimbable|3
	dc.b $c1,_bitCollidable|1,_bitCollidable|1,_bitClimbable|3
	dc.b $c1,_bitCollidable|1,_bitCollidable|1,_bitClimbable|3
	dc.b $41,0,_bitClimbable|3
	dc.b $41,2,_bitClimbable|3
	dc.b $4f,2,_bitClimbable|3,$f0, _bitCollidable|1

		; Item - Food
    DEFITEM _itemHealth,16*6+4,(16*3)+8,26,(8-3)
	
	; alien 1
	dc.b 48-16		; x
	dc.b 16*9		; y
	dc.b $01		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $82		; anim frame + sprite type
	dc.b 0			; current counter
	dc.b 32

	dc.b 48-16+32		; org x
	dc.b 192		; org y
	dc.b %11010001		; Flags ( %1111, move type, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b %10000010		; anim frame + sprite type
	dc.b 48-16		; min x
	dc.b 16*6		; max x

	
	; Catacombs - one - big san loss here
screen30Data
	dc.b $49,2,_bitClimbable|3,_bitCollidable|1
	dc.b $e9,10,0|_bitFlipped,10,_bitClimbable|3,_bitCollidable|1
	dc.b $f9,_bitHookable|_bitCollidable|_bitFlipped|8,$f0,_bitCollidable|1
	dc.b $01,1
	dc.b $03,10,_bitCollidable|1
	dc.b $6f,$f0,_bitCollidable|1
	dc.b $7b,$f4,_bitCollidable|1,_bitHookable|_bitFlipped|8, _bitCollidable|1
	dc.b $01,_bitCollidable|1
	dc.b $f9,$f4,_bitCollidable|1,_bitClimbable|3,_bitCollidable|1
	dc.b $09,3|_bitClimbable, _bitCollidable|1
	dc.b $0f,3|_bitClimbable, 10,4,1|_bitCollidable
	dc.b $ff,$f0,_bitCollidable|1

	dc.b 0			; x
	dc.b 96			; y
	dc.b %11000001		; Flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $82		; anim frame + sprite type
	dc.b 0			; min x
	dc.b 16*5		; max x

	; Catacombs - two - more san loss here?
screen31Data
	dc.b $9d,_bitCollidable|1,_bitFlipped|0,8,_bitFlipped|0,2
	dc.b $9d,_bitCollidable|1,$f3,10,_bitFlipped|0
	dc.b $bf,_bitCollidable|1,_bitClimbable|3,$f0,_bitCollidable|1
	dc.b $e0,1|_bitCollidable,4,_bitClimbable|3
	dc.b $fe,1|_bitCollidable|_bitHookable,8|_bitFlipped|_bitHookable|_bitCollidable,8|_bitFlipped|_bitHookable|_bitCollidable,1|_bitFlipped|_bitCollidable|_bitHookable,1|_bitCollidable,1|_bitCollidable ,3|_bitClimbable
	dc.b $82,1,3|_bitClimbable
	dc.b $82,1,3|_bitClimbable
	dc.b $aa,1,4,4,3|_bitClimbable
	dc.b $bf,$f0,_bitCollidable|1
	dc.b $30,_bitHookable|_bitFlipped|8,_bitCollidable|1
	dc.b $1C,_bitCollidable|1,4,10
	dc.b $ff,_bitCollidable|1,_bitCollidable|1,_bitClimbable|3,$f3,1|_bitCollidable, 3|_bitClimbable,_bitCollidable|1

	dc.b (16*3)+4 		; x
	dc.b 192-(16*3)+7	; y
	dc.b _itemElderSign|1
	dc.b 0,0

	dc.b 16			; x
	dc.b 16*7+8		; y
	dc.b $01		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $82		; anim frame + sprite type
	dc.b 0			; current counter
	dc.b 30
	
	; West tower base
screen32Data
	dc.b $C3,_bitCollidable|1,_bitClimbable|3,3|_bitClimbable,_bitCollidable|1
	dc.b $f3,$f0,_bitCollidable|1
	dc.b $f3,_bitCollidable|1,$f3,_bitCollidable|_bitHookable|9,_bitHookable|9,_bitCollidable|1
	dc.b $81,_bitCollidable|1,_bitCollidable|1
	dc.b $85,_bitCollidable|1,8|_bitCollidable,_bitCollidable|1
	dc.b $cd,_bitCollidable|1,_bitHookable|_bitCollidable|9, _bitCollidable|_bitHookable|9, 0,_bitCollidable|1
	dc.b $85,_bitCollidable|1,2,_bitCollidable|1
	dc.b $85,_bitCollidable|1,2,_bitCollidable|1
	dc.b $b7,_bitCollidable|1,_bitHookable|_bitCollidable|9,_bitCollidable|_bitHookable|9,2,_bitFlipped|_bitCollidable|_bitHookable|9,_bitCollidable|1
	dc.b $84,_bitCollidable|1,2
	dc.b $84,_bitCollidable|1,_bitFlipped|0
	dc.b $ff,$f0,_bitCollidable|1

	dc.b 16			; x
	dc.b 96			; y
	dc.b $01		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $82		; anim frame + sprite type
	dc.b 0			; current counter
	dc.b 24

	dc.b 16			; x
	dc.b 192		; y
	dc.b $01		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $81		; anim frame + sprite type
	dc.b 0			; current counter
	dc.b 22
	
	; West tower middle (need two of these)
screen33Data
	dc.b $c3,_bitCollidable|1,_bitClimbable|3,_bitClimbable|3,_bitCollidable|1
	dc.b $C3,_bitCollidable|1,_bitClimbable|3,_bitClimbable|3,_bitCollidable|1
	dc.b $ff,_bitCollidable|1,8|_bitFlipped|_bitCollidable,3|_bitClimbable
	dc.b     $f2,8|_bitCollidable|_bitFlipped
	dc.b     3|_bitClimbable,8|_bitFlipped|_bitCollidable,1|_bitCollidable
	dc.b $a5,_bitCollidable|1,3|_bitClimbable,3|_bitClimbable,1|_bitCollidable
	dc.b $a5,_bitCollidable|1,3|_bitClimbable,3|_bitClimbable,1|_bitCollidable
	dc.b $a5,_bitCollidable|1,3|_bitClimbable,3|_bitClimbable,1|_bitCollidable
	dc.b $a5,_bitCollidable|1,3|_bitClimbable,3|_bitClimbable,1|_bitCollidable
	dc.b $a5,_bitCollidable|1,3|_bitClimbable,3|_bitClimbable,1|_bitCollidable
	dc.b $a5,_bitCollidable|1,3|_bitClimbable,3|_bitClimbable,1|_bitCollidable
	dc.b $a5,_bitCollidable|1,3|_bitClimbable,3|_bitClimbable,1|_bitCollidable
	dc.b $a5,_bitCollidable|1,3|_bitClimbable,3|_bitClimbable,1|_bitCollidable
	dc.b $ff,_bitCollidable|1,_bitClimbable|3,$f4,1|_bitCollidable,3|_bitClimbable,1|_bitCollidable

	IFD	NOT_REQUIRED
IF FALSE	
	dc.b 16*6		; x
	dc.b 192+16;-(16*5)	; y
	dc.b $31		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $80		; anim frame + sprite type
	dc.b 0			; current counter
	dc.b 46
ENDIF
	ENDC

	dc.b 16*2		; x
	dc.b 16*3	        ; y
	dc.b $41		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $80		; anim frame + sprite type
	dc.b 0			; current counter
	dc.b 40-16
	
	; West tower top
screen34Data
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $a0,$f0,_bitCollidable|11
	dc.b $e0,_bitCollidable|1,_bitCollidable|11,_bitCollidable|1
	dc.b $ec,$f3,_bitCollidable|1,$f0,11|_bitCollidable
	dc.b $ec,1|_bitCollidable,1|_bitCollidable, 8|_bitCollidable|_bitFlipped,9|_bitHookable|_bitCollidable,9|_bitHookable|_bitCollidable|_bitFlipped
	dc.b $C3,_bitCollidable|1,_bitCollidable|_bitFlipped|8,_bitCollidable|11, _bitCollidable|11
	dc.b $83,$f0,_bitCollidable|1
	dc.b $8f,_bitCollidable|1,$f2,_bitCollidable|8,_bitCollidable|1,_bitCollidable|1
	dc.b $89,$f0,_bitCollidable|1
	dc.b $ff,_bitCollidable|1,_bitClimbable|3,$f4,_bitCollidable|1,3|_bitClimbable,1|_bitCollidable

	; Item one
	dc.b (16*5)+4
	dc.b (16*12)+8
	dc.b _itemGemBlue
	dc.b 20 ; text id
	dc.b 4+(8*8) ; tile id

	; In between west tower and base camp
screen35Data
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $c0,11|_bitCollidable, 11|_bitCollidable
	dc.b $c0,1|_bitCollidable, 9|_bitHookable|_bitCollidable
	dc.b $80,1|_bitCollidable
	dc.b $80,1|_bitCollidable
	dc.b $ff,_bitCollidable|1,$f0,_bitCollidable|11

	; Hell #1
screen36Data
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $3c,$f0,1|_bitCollidable
	dc.b $3c,$f0,7|_bitHookable|_bitCollidable
	dc.b $00
	dc.b $00
	dc.b $24,10,10
	dc.b $66,_bitCollidable|8,_bitCollidable|1,_bitCollidable|1,_bitCollidable|8
	dc.b $e7,$f0,_bitCollidable|1
	
	; Hell #2 : Contains LAST piece of rope, and maybe elder sign.
screen37Data
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $81,8|_bitCollidable,8|_bitCollidable
	dc.b $c3,$f0,1|_bitCollidable
	dc.b $c3,$f3,7|_bitHookable|_bitCollidable,1|_bitCollidable
	dc.b $01,1|_bitCollidable
	dc.b $01,1|_bitCollidable
	dc.b $7d,$f5,8|_bitFlipped|_bitCollidable|_bitHookable, 1|_bitCollidable
	dc.b $01,1|_bitCollidable
	dc.b $ff,$f0,_bitCollidable|1

	dc.b 16*6+4
	dc.b (16*6)+8
	dc.b _itemRope
	dc.b 19
	dc.b 5+(8*3)

	dc.b 16	  	; x
	dc.b 16*10		; y
	dc.b $01		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $82		; anim frame + sprite type
	dc.b 0			; current counter
	dc.b 24+8
	
	; Shoggoth #1
screen38Data
	dc.b $ff,1,1,$f0,8|_bitFlipped|_bitHookable
	dc.b $c0,1|_bitHookable|_bitCollidable,7|_bitHookable
	dc.b $80,1|_bitCollidable
	dc.b $80,1|_bitCollidable
	dc.b $83,$f0,1|_bitCollidable
	dc.b $82,1|_bitCollidable, 7|_bitHookable|_bitCollidable
	dc.b $80,1|_bitCollidable
	dc.b $80,1|_bitCollidable
	dc.b $80,1|_bitCollidable
	dc.b $80,1|_bitCollidable
	dc.b $c0,1|_bitCollidable,8|_bitCollidable
	dc.b $ff,$f0,_bitCollidable|1

    ; Elder thing at bottom
	dc.b 32			; x
	dc.b 16*12		; y
	dc.b $41		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	dc.b $82		; anim frame + sprite type
	dc.b 0          ; counter
	dc.b 40
	
	; Shoggoth #2
screen39Data
	dc.b $e7,$f0,1|_bitCollidable
	dc.b $27,8|_bitFlipped,$f0,1|_bitCollidable
	dc.b $07,$f0,1|_bitCollidable
	dc.b $07,1|_bitCollidable,$f0,8|_bitFlipped
	dc.b $fc,$f0,1|_bitCollidable
	dc.b $fc,8|_bitFlipped, 8|_bitFlipped, 7|_bitHookable, 7|_bitHookable,$f0,8|_bitFlipped
	dc.b $00
	dc.b $07,3|_bitClimbable,$f0,1|_bitCollidable
	dc.b $06,3|_bitClimbable,8|_bitFlipped
	dc.b $04,3|_bitClimbable
	dc.b $06,3|_bitClimbable,8|_bitCollidable
	dc.b $ff,$f0,_bitCollidable|1
	
	; Shoggoth #3 (END)
screen40Data
	dc.b $ff,$f0,1
	dc.b $ff,$f0,1
	dc.b $ff,$f0,1|_bitCollidable
	dc.b $ff,$f2,7|_bitHookable,8|_bitCollidable|_bitFlipped,$f4,7|_bitHookable,8|_bitFlipped|_bitCollidable
	dc.b $00
	dc.b $00
	dc.b $01,8|_bitCollidable
	dc.b $dd,$f0,_bitCollidable|1
	dc.b $dd,$f5,7|_bitHookable|_bitCollidable
screen40DataEx: ; patch
	dc.b	8|_bitFlipped|_bitCollidable
	dc.b	0 ; swap these two lines
	dc.b	$01,$08|_bitCollidable

	dc.b $ff,$f3,_bitCollidable|1,8|_bitCollidable,$f0,1|_bitCollidable

	; Secret screen #1
	IFD	NOT_REQUIRED
IF FALSE        
screen41Data
	dc.b $02,_bitClimbable|3
	dc.b $02,_bitClimbable|3
	dc.b $02,_bitClimbable|3
	dc.b $02,_bitClimbable|3
	dc.b $02,_bitClimbable|3
	dc.b $02,_bitClimbable|3
	dc.b $06,_bitCollidable|8,_bitClimbable|3
	dc.b $07,$f0,_bitCollidable|1
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
ENDIF        
	ENDC

	; Just west of east tower top
screen42Data
	dc.b $0
	dc.b $0
	dc.b $03,_bitClimbable|3,_bitCollidable|11
	dc.b $03,_bitClimbable|3,_bitCollidable|1
	dc.b $03,_bitClimbable|3,_bitCollidable|1
	dc.b $03,_bitClimbable|3,_bitCollidable|1
	dc.b $03,_bitClimbable|3,_bitCollidable|1
	dc.b $03,_bitClimbable|3,_bitCollidable|1
	dc.b $03,_bitClimbable|3,_bitCollidable|1
	dc.b $03,_bitClimbable|3,_bitCollidable|1
	dc.b $03,_bitClimbable|3,_bitCollidable|1
	dc.b $03,_bitClimbable|3,_bitCollidable|1

	IFD	NOT_REQUIRED
IF FALSE        
screen43Data
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $f0,$f0,_bitCollidable|1
	dc.b $10,_bitCollidable|1
	dc.b $10,_bitCollidable|1
	dc.b $30,_bitCollidable|8,_bitCollidable|1
	dc.b $f0,$f0,1|_bitCollidable
ENDIF
	ENDC
	
screen44Data:
	dc.b $22,3|_bitClimbable,3|_bitClimbable
	dc.b $22,3|_bitClimbable,3|_bitClimbable
	dc.b $63,8|_bitCollidable, 3|_bitClimbable,3|_bitClimbable,8|_bitCollidable
	dc.b $7f,$f0,_bitCollidable|1
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00
	dc.b $00

; These values are per screen and copied into the zp 'snowwindow' memory on a screen change
snowWindowValueTable
			dc.b	12,15,26,38	; in the cave, poor lake, east tower, west tower
			dc.b	0
snowWindowValues	
			dc.b	16*4, 16*0, 16*7, 16*7  	; In the cave
			dc.b	16*4, 16*0, 16*8, 16*5  	; Poor lake
			dc.b	0, 16*0, 16*8, 16*5 	; Top of east tower
			dc.b	0, 0, 128, (16*8)-8	; Top of west tower
	