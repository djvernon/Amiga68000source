 	OPT c-,o+,o3-
	SECTION AmigaComputing,code_c

barlen		equ 9		 	; height of blue bar sections	 
upbig		equ 26			; speed of equalizer 
upsmall 	equ 16			; moving up (centre and sides)
downvalue 	equ 1 			; speed of equalizer down
barht		equ 60			; height of equalizer

go:

	jsr START_MUZAK			; initialise music

	bset #1,$bfe001			; turn off low pass filter
					; on recent A500/B2000's
	move.l #sprite0,d0
	move.w d0,sp0l
	swap d0
	move.w d0,sp0h
	
	move.l #sprite1,d0
	move.w d0,sp1l
	swap d0
	move.w d0,sp1h
	
	move.l #sprite2,d0
	move.w d0,sp2l
	swap d0
	move.w d0,sp2h
	
	move.l #sprite3,d0
	move.w d0,sp3l
	swap d0
	move.w d0,sp3h
	
	move.l #sprite4,d0
	move.w d0,sp4l
	swap d0
	move.w d0,sp4h
	
	move.l #sprite5,d0
	move.w d0,sp5l
	swap d0
	move.w d0,sp5h
	
	move.l #sprite6,d0
	move.w d0,sp6l
	swap d0
	move.w d0,sp6h
	
	move.l #sprite7,d0
	move.w d0,sp7l
	swap d0
	move.w d0,sp7h
	
	move.l 4.w,a6			; Get EXECBASE
	jsr -132(a6)			; FORBID() - Turn off
					; multitasking
	

	lea $dff000,a5			; Keep base address of hardware registers
					; in A5. This speeds up our code
					; because we can access them all relative
					; to A5, eg $dff180 is 180(a5)
	
	move.l #showplane,d0
	move.w d0,p2l1l
 	move.w d0,p2l2l
	swap d0
	move.w d0,p2l1h
	move.w d0,p2l2h
	
	move.l #showplane2,d0
	move.w d0,p3l1l
	swap d0
	move.w d0,p3l1h
	

	move.l #panel,d0		; get address of panel bitmap
	move.w d0,p4l1l			; store low word in copperlist
	swap d0				; swap upper and lower words
	move.w d0,p4l1h			; store high word in copper list
	swap d0
	add.l #800,d0			; size of plane for logo
	move.w d0,p4l2l
	swap d0
	move.w d0,p4l2h
	swap d0
	add.l #800,d0
	move.w d0,p4l3l
	swap d0
	move.w d0,p4l3h
	swap d0
	add.l #800,d0
	move.w d0,p4l4l
	swap d0
	move.w d0,p4l4h
	swap d0
	add.l #800,d0			; now d0 points to the
					; colour table stored at the
					; end of the graphics data
					; it is missing off the first
					; colour which is not needed

teis
 	move.l d0,a0			
	lea copcols2(pc),a1		; blue stripes 	
	move.w #col0,d1			; =$180  First colour register
	moveq #15,d0			; 15 colours (ignoring col0)
cmovel  move.w d1,(a1)+			; move in col reg
	addq.w #2,d1			; update to next register
	move.w (a0)+,(a1)+		; read colour and move in
	dbra d0,cmovel 					

				
	move.l #plane1,d0		; get address of bitmap
	move.w d0,pl1l			; store low word in copperlist
	swap d0				; swap upper and lower words
	move.w d0,pl1h			; store high word in copper list
	swap d0
	add.l #4400,d0			; size of plane for logo
	move.w d0,pl2l
	swap d0
	move.w d0,pl2h
	swap d0
	add.l #4400,d0
	move.w d0,pl3l
	swap d0
	move.w d0,pl3h
	swap d0
	add.l #4400,d0
	move.w d0,pl4l
	swap d0
	move.w d0,pl4h
	swap d0
	add.l #4402,d0			; now d0 points to the
					; colour table stored at the
					; end of the graphics data
					; it is missing off the first
					; colour which is not needed


 	move.l d0,a0			
	lea coltab(pc),a1		; blue stripes 	
	lea redtable(pc),a2		; red-yellow part of tick
	lea bluetable(pc),a3		; blue-green part of tick
	move.w #col1,d1			; =$180  First colour register
	moveq #14,d0			; 15 colours (ignoring col0)
cmovelp move.w d1,(a1)+			; move in col reg
	addq.w #2,d1			; update to next register
	move.w (a0)+,(a1)+		; read colour and move in
	dbra d0,cmovelp 					

	LEA copcols(pc),a0		; build copper list with 68000
	MOVE.L #$2c09fffe,d1		; copper wait instruction
	MOVE.W #col0,d2			; $dff182 = colour 1 address 
	MOVEQ #96,d0			; loop 100 times (always
	clr.b d3			; 1 less in a DBRA loop)
coploop MOVE.L d1,(a0)+
	MOVE.W d2,(a0)+
	CLR.W (a0)+
	
	
	
	
	
	
	move.w #col2,(a0)+
	move.w (a2)+,(a0)+
	move.w #col3,(a0)+
	move.w (a3)+,(a0)+


	ADD.L #$01000000,d1		; update copper move

	DBRA d0,coploop			; branch until finished					

	lea coltab2(pc),a1		; point to copper table 2
	lea spritecols(pc),a0		; sprite colour data
	move.w #col16,d1		; =$1A0  16th colour register
	moveq #15,d0			; 16 colours 
cmovelp2
	move.w d1,(a1)+			; move in col reg
	addq.w #2,d1			; update to next register
	move.w (a0)+,(a1)+		; read colour and move in
	dbra d0,cmovelp2 					


 	LEA GFXLIB(PC),a1		; Point to 'graphics.library'
 	MOVEQ #0,D0			; Doesn't matter which version
 	
 	MOVE.L 4.w,a6			; You can use CALLEXEC OpenLibrary
 	JSR -$228(a6) ; OpenLibrary	; here if you use Include files.
 	TST D0
 	BEQ.s ERROR			; If not enough mem for library,exit 
 	MOVE.L D0,GFXBASE		;  Store library address
 
 	MOVE.L D0,A6
 	MOVE.W #$80,dmacon(a5)		; Turn off copper whilst changing it
 	MOVE.L $32(A6),WBCOPPER	 	; Store old (WBench) copper address
 	MOVE.L #OURCOPPER,$32(A6)	; Point to new copper list (our own)
 	MOVE.W #$8080,dmacon(a5)         	; re-enable copper

 	MOVE.W #$8010,intena(a5)		
 	MOVE.L $6c.w,old
 	MOVE.L #LEV3,$6c.w		; This sets up a level 3 interrupt


WAIT: 	BTST #6,$BFE001			; This waits for the left
 	BNE.s wait			; mouse button to be pressed

					; This is the EXIT ROUTINE
				
 	MOVE.L old,$6c.w		; Restore system interrupts
	 
 	MOVE.L GFXBASE,A6
 	MOVE.W #$80,dmacon(a5)
 	MOVE.L WBCOPPER,$32(A6)		; Restore old copperlist
 	MOVE.W #$8080,dmacon(a5)	
 
 
 

	move.l GFXBASE,a1
	move.l 4.w,a6
	jsr -414(a6)			; Close graphics library
	
ERROR:	move.l 4.w,a6			; Get EXECBASE
	jsr -138(a6)			; PERMIT() - Turn on
					; multitasking
 	MOVE.W #$f,dmacon(a5)		; Turn off all sound channels
 	move.w #$8020,dmacon(a5)	; turn on sprites (if off)
 	CLR.W aud0vol(a5)
 	CLR.W aud1vol(a5)
 	CLR.W aud2vol(a5)
 	CLR.W aud3vol(a5)
 	MOVEQ #0,d0			; Clear D0 before exit 
 	RTS				; Return to AmigaDOS



LEV3: 	MOVEM.L d0-d7/a0-a6,-(sp)	; Save all registers to the stack
	AND #$10,intreqr(a5)       	; Check if interrupt is from Copper 
	BEQ.s out
	MOVE.W #$10,intreq(a5)		; Clear the interrupt flag
	
; interupt routine goes in here
	btst #2,$dff016	
	beq.s pausedemo
	
	bsr bouncething
	BSR scrolly			; do scroll
 	BSR changecop			; Call copper change routine
	bsr movelogo			
	bsr equalizer
	bsr blitclear
	bsr.s equalizer2
	
pausedemo JSR REPLAY_MUZAK
	

out: 	MOVEM.L (sp)+,d0-d7/a0-a6	; Restore the registers

	DC.W $4ef9			
old: 	DC.L 0				


***********SPECTRUM ANALYZER (EQUALIQUIZER) ROUTINE**************
***********========================================**************

eqsub:	move.w (a0),d0
	bne.s eqsub2
	rts

eqsub2	clr.w (a0)
	lea notetable,a1
	moveq #0,d1
nomatch	move.w (a1)+,d2			; this works out the position
	cmp.w d2,d0			; along the equalizer for the
	bgt.s match			; bar by using the note table
	addq.b #1,d1			; in the music play routine
	bra.s nomatch
match	;move.w d1,testpt2
	lea eqtab(pc),a1
	add.l d1,a1
	add.b #upbig,(a1)
	add.b #upsmall,-1(a1)
	add.b #upsmall,1(a1)
	
noplus	move.b (a1),d0
	cmp.b #barht,d0
	bls.s less50
	move.b #barht,(a1)
less50	move.b -1(a1),d0
	cmp.b #barht-2,d0
	bls.s less41
	move.b #barht-2,-1(a1)
less41	move.b 1(a1),d0
	cmp.b #barht-2,d0
	bls.s less42
	move.b #barht-2,1(a1)
less42	
	rts




equalizer2
	
	lea eq1p,a0
	bsr.s eqsub
	lea eq2p,a0
	bsr.s eqsub
	lea eq3p,a0
	bsr.s eqsub
	lea eq4p,a0
	bsr.s eqsub
blitfin2:
	btst #6,$dff002		
	bne.s blitfin2		; wait till blitter ready

	moveq #39,d0		; 40 segments	
	
	lea eqtab(pc),a1	; table
	lea showplane2,a2	; picture
mainlp	moveq #0,d1
	move.b (a1),d1		; get byte
	cmp.b #10,d1		; is it in the noise range?
	bgt.s nonoise		
				; this puts noise in the equalizer hehehe
				; EQUALIQUIZER MK.2
				; Get 'AMAZING TUNES 1' to see Mk 1!!!
_back	move.l noiseptr,a3	
	move.b (a3)+,d3								
	cmp.b #255,d3	
	bne.s noiseok
	move.l #noisetable,noiseptr
	bra.s _back
noiseok	add.b d3,d1		; noise element
	move.l a3,noiseptr
nonoise	move.l d1,d4		;
	neg.w d1
	add.w #barht+6,d1	; subtract from 40
	mulu #40,d1		; multiply by 40
	
	
fillbar	
	move.b #$fe,0(a2,d1)	; splat on equalizer
	add.w #40,d1
	dbra d4,fillbar
	
	
	move.b (a1),d3
;	cmp.b #0,d3
	;beq iszero
	subq.b #downvalue,(a1)
	bpl.s izok		; hasn't gone below zero
	move.b #0,(a1)
izok	addq.l #1,a2
	addq.l #1,a1
	dbf d0,mainlp
	

	rts



	
blitclear:
	lea showplane2,a0		; visible bitplane
blitfin:
	btst #6,$dff002		
	bne.s blitfin			; wait till blitter ready

	move.l a0,$dff054		; source address
	move.l a0,$dff050		; destination address
	clr.l $dff044			; no FWM/LWM (see hardware manual)
	clr.l $dff064			; no MODULO (see hardware manual)

	move.w #%100000000,$dff040 	; Enable DMA channel D, nothing
					; else, no minterms active. 
	clr.w $dff042			; nothing set in BLTCON1
	move.w #%1011010010100,$dff058	; Window size = 20 words wide
;		 |     ||    |		                90 lines deep
;		 Bin(90)|    |
;		        Bin(20)

equalizer
	move.b eq1,d0
	cmp.b #0,eq1
	beq.s ffg
	subq.b #1,eq1
ffg	add.b d0,d0
	add.b d0,d0
	add.b d0,d0

	add.b #11,d0
	move.b d0,equbar1b+1
	
	sub.b #10,d0
	move.b d0,equbar1a+1
	move.b d0,equbar1c+1
	
	move.b eq2,d0
	cmp.b #0,eq2
	beq.s ffg2
	subq.b #1,eq2
ffg2	add.b d0,d0
	add.b d0,d0
	add.b d0,d0

	add.b #11,d0
	move.b d0,equbar2b+1
	
	sub.b #10,d0
	move.b d0,equbar2a+1
	move.b d0,equbar2c+1
	
	move.b eq3,d0
	cmp.b #0,eq3
	beq.s ffg3
	subq.b #1,eq3
ffg3	add.b d0,d0
	add.b d0,d0
	add.b d0,d0

	add.b #11,d0
	move.b d0,equbar3b+1
	
	sub.b #10,d0
	move.b d0,equbar3a+1
	move.b d0,equbar3c+1
	
	move.b eq4,d0
	cmp.b #0,eq4
	beq.s ffg4
	subq.b #1,eq4
ffg4	add.b d0,d0
	add.b d0,d0
	add.b d0,d0
	add.b d0,d0
	add.b #11,d0
	move.b d0,equbar4b+1
	sub.b #10,d0
	move.b d0,equbar4a+1
	move.b d0,equbar4c+1
	rts
movelogo
	moveq #0,d0			; quicker than CLR.L d0
	move.l d0,d1
	move.l sinpt2,a0
lpbk	move.b (a0)+,d0 
	cmp.b #255,d0
	bne.s mlok

	move.l #sintab2,a0
	bra.s lpbk
mlok 	move.l a0,sinpt2
	move.w d0,d1
	lsr.b #4,d0			; quicker than DIVU #16	
	add.w d0,d0
	neg.w d0			; need negative value for modulo
	move.w d0,horiz_coarse1		; BPL1MOD & BPL2MOD = $108 & $10a
	move.w d0,horiz_coarse2
	move.w d1,d0
	and.w #$f,d0
	and.w #$f,d1
	lsl.w #4,d0			; quicker than MULU #16
	eor.w d1,d0			; to set both odd and even offsets
	move.w d0,horiz_smooth		; BPLCON1 = $102	
	rts

logopos	  dc.w 0
WBCOPPER: DC.L 0			; Old copper address saved here
flag	dc.w 0
flag2	dc.w 0

bouncething
	moveq #0,d0			; quicker than CLR.L d0
	move.l d0,d1
	move.l sbounceptr,a0
lpbk2	move.b (a0)+,d0 
	cmp.b #255,d0
	bne.s btok
	move.l #spritebounce,a0

	move.b flag2,d2
	cmp.b #1,d2
	bne.s lpbk2
	move.b #0,flag2 
	eor.w #$00ff,spritepri
	bra.s lpbk2
btok 	move.l a0,sbounceptr
    	move.b d0,sprite0
    	move.b d0,sprite1
    	move.b d0,sprite2
    	move.b d0,sprite3
    	move.b d0,sprite4
    	move.b d0,sprite5
    	move.b d0,sprite6
    	move.b d0,sprite7
    	add.b #64,d0
    	move.b d0,sprite0+2
    	move.b d0,sprite1+2
    	move.b d0,sprite2+2
    	move.b d0,sprite3+2
    	move.b d0,sprite4+2
    	move.b d0,sprite5+2
    	move.b d0,sprite6+2
    	move.b d0,sprite7+2
    	
    	move.b sprhordir,d0
    	move.b sprhorpos,d1
    	add.b d0,d1
    	cmp.b #$c0,d1
    	bne.s notc0
    	move.b #-1,sprhordir
notc0	cmp.b #$40,d1
	bne.s not40
	move.b #1,flag2
	move.b #1,sprhordir
not40	move.b d1,sprhorpos
    	move.b d1,sprite0+1
    	move.b d1,sprite1+1
    	addq.b #8,d1
    	move.b d1,sprite2+1
    	move.b d1,sprite3+1
    	addq.b #8,d1
    	move.b d1,sprite4+1
    	move.b d1,sprite5+1
    	addq.b #8,d1
    	move.b d1,sprite6+1
    	move.b d1,sprite7+1
    	
    	rts
    	
changecop:
	bchg #0,flag
	bne.s ccrts

	LEA copcols(PC),a0
	MOVEQ #96,d0			; 100 lines
	MOVE.L barptr,a1		; start of list
	move.l a1,temptr		; updates temporary pointer
	clr.b d1
ccloop	move.b (a1)+,7(a0)		; update colour
	lea 16(a0),a0			; faster than add.l #16,a0
 	addq.b #1,d1		
 	cmp.b #barlen,d1		; end of sub-bar?
 	bne.s ccdbra
	MOVE.L temptr,a1
	addq.l #1,a1
	cmp.l #barend,temptr
	bne.s ccd2
	
	lea bardata(pc),a1

ccd2	move.l a1,temptr
	clr.b d1
ccdbra  dbra d0,ccloop
	addq.l #1,barptr
	move.l barptr,d0
	cmp.l #barend,d0		; have we got to the bottom
	bne.s ccrts			; of the bar list. If so,
	move.l #bardata,barptr		; reset to start of list	
ccrts	rts				; return to interrupt


sinscroll:
; first blit clear the scrolly

	lea showplane,a0		; visible bitplane
blitready:
	btst #6,$dff002		
	bne.s blitready			; wait till blitter ready

	move.l a0,$dff054		; source address
	move.l a0,$dff050		; destination address
	clr.l $dff044			; no FWM/LWM (see hardware manual)
	clr.l $dff064			; no MODULO (see hardware manual)

	move.w #%100000000,$dff040 	; Enable DMA channel D, nothing
					; else, no minterms active. 
	clr.w $dff042			; nothing set in BLTCON1
	move.w #%111100010101,$dff058	; Window size = 21 words wide
					; 60 lines deep


	move.l sinpt,a3
	subq.l #1,a3
	move.b (a3),d0
	cmp.b #255,d0
	bne.s notendofsine
	lea sintabend(pc),a3
notendofsine:
	move.l a3,sinpt

	moveq #19,d0
	lea scrollplane,a0
	lea showplane,a1

sloop3:

	bsr getsinval

blitready2
	btst #6,$dff002
	bne.s blitready2

	move.l a0,$dff050
	move.l a2,$dff054
	move.l #$f000f000,$dff044
	move.w #40,$dff064
	move.w #40,$dff066
	move.w #%0000100111110000,$dff040
	clr.w $dff042
	move.w #%100000000001,$dff058

	bsr getsinval

zonk2:
	btst #6,$dff002
	bne.s zonk2

	move.l a0,$dff050
	move.l a2,$dff054
	move.l a2,$dff04c
	move.l #$f000f00,$dff044
	move.w #40,$dff064
	move.w #40,$dff066
	move.w #40,$dff062
	move.w #%0000110111111100,$dff040
 	clr.w $dff042
	move.w #%100000000001,$dff058

	bsr getsinval
zonk3:
	btst #6,$dff002
	bne.s zonk3

	move.l a0,$dff050
	move.l a2,$dff054
	move.l a2,$dff04c
	move.l #$f000f0,$dff044
	move.w #40,$dff064
	move.w #40,$dff066
	move.w #40,$dff062
	move.w #%0000110111111100,$dff040
	clr.w $dff042
	move.w #%100000000001,$dff058

	bsr.s getsinval
zonk4:
	btst #6,$dff002
	bne.s zonk4
	move.l a0,$dff050
	move.l a2,$dff054
	move.l a2,$dff04c
	move.l #$f000f,$dff044
	move.w #40,$dff064
	move.w #40,$dff066
	move.w #40,$dff062
	move.w #%0000110111111100,$dff040
	clr.w $dff042
	move.w #%100000000001,$dff058



	addq.l #2,a0
LOAD	addq.l #2,a1
	dbra d0,sloop3
	rts

getsinval:
	moveq #0,d1
	move.b (a3)+,d1
	move.b (a3),d2
	cmp.b #255,d2
	bne.s okyar
	move.l #sintab,a3
okyar:

	lsr.b #1,d1

	bclr #0,d1


	mulu #21,d1

	move.l a1,a2
	add.l d1,a2

	rts
scrolly: 
	move.b pause,d0
	cmp.b #0,d0
	beq.s gopast
	subq.b #1,d0
	move.b d0,pause
	bra.s gopast2
gopast:
	move.l #scrollplane,a0
	move.l #scrollplane+2,a1
blitready3:
	btst #6,$dff002
	bne.s blitready3
	move.l a0,$dff054
	move.l a1,$dff050
	move.l #-1,$dff044
	clr.l $dff064
	move.w #%1100100111110000,$dff040
	clr.w $dff042
	move.w #%101000010111,$dff058
gopast2:
	bsr sinscroll
	move.b pause,d0
	cmp.b #0,d0
	bne.s iuo

	move.b countdown,d0
	subq.b #1,d0
	cmp.b #0,d0
	beq mfc
	move.b d0,countdown
iuo:
	rts
	
countdown:
	dc.b 4,0


sinpt: 	dc.l sintabend		
sinpt2: dc.l sintab2

eqtab	ds.b 40


 	dc.b 255
sintab:

	dc.b $3C,$3F,$42,$46,$49,$4C,$50,$53,$56,$59
	dc.b $5C,$5F,$61,$64,$67,$69,$6B,$6D,$6F,$71
	dc.b $72,$73,$75,$76,$76,$77,$77,$77,$77,$77
	dc.b $77,$76,$76,$75,$73,$72,$71,$6F,$6D,$6B
	dc.b $69,$67,$64,$61,$5F,$5C,$59,$56,$53,$50
	dc.b $4C,$49,$46,$42,$3F,$3C,$38,$35,$31,$2E
	dc.b $2B,$27,$24,$21,$1E,$1B,$18,$16,$13,$10
	dc.b $E,$C,$A,$8,$6,$5,$4,$2,$1,$1
	dc.b $0,$0,$0,$0,$0,$0,$1,$1,$2,$4
	dc.b $5,$6,$8,$A,$C,$E,$10,$13,$16,$18
	dc.b $1B,$1E,$21,$24,$27,$2B,$2E,$31,$35

sintabend:
 dc.b $38,255

noisetable dc.b 2,0,0,2,0,2,0,0,2,0,4,2,0,2,4,0,0,2,2,0,2,2,4,2,0,0,2,255


sintab2:

 dc.b $2D,$31,$34,$38,$3B,$3E,$41,$45,$47,$4A,$4D,$4F,$51,$53,$55,$57
 dc.b $58,$59,$59,$5A,$5A,$5A,$59,$59,$58,$57,$55,$53,$51,$4F,$4D,$4A
 dc.b $47,$45,$41,$3E,$3B,$38,$34,$31,$2D,$29,$26,$22,$1F,$1C,$19,$15
 dc.b $13,$10,$D,$B,$9,$7,$5,$3,$2,$1,$1,$0,$0,$0,$1,$1,$2,$3,$5,$7,$9
 dc.b $B,$D,$10,$13,$15,$19,$1C,$1F,$22,$26,$29,$ff

pause: 	dc.b 0
sinmodulo:
	dc.b 0

 	even
noiseptr dc.l noisetable
mfc:
	move.b #4,countdown
	clr.w scrollplane+40
	clr.w scrollplane+82
	move.l #scrollplane+124,a1
	bsr.s charaddress

	moveq #15,d0
zonkin:
	move.w (a0),(a1)
	lea 40(a0),a0
	lea 42(a1),a1
	dbf d0,zonkin

	rts
CHARADDRESS:
	move.l mesptr,a0
	moveq #0,d0
	move.l d0,d1
	move.l d0,d2
	move.b (a0)+,d0
	cmp.b #$0a,d0
	bne.s wizy
	move.b #32,d0
wizy:
	cmp.b #255,d0
	bne.s wazy
	move.l #message,a0
	move.b #32,d0
wazy:
	cmp.b #254,d0
	bne.s wozy
	move.b #32,d0
	move.b #$60,pause
wozy:
	move.l a0,mesptr

	sub.b #32,d0 
 	moveq #0,d1
 	divu #20,d0  		; 20 chars on each line
 	move.b d0,d1 
 	clr.w d0
 	swap d0  
	move.l #font,a0
	mulu #640,d1
	add.l d0,d0
	add.l d0,a0
	add.l d1,a0

	rts


 even
mesptr: dc.l message
message:
      ;12345678901234567890
 dc.b "      HI GUYZ       ",254
 dc.b " THIS DEMO WAS PROGRAMMED ESPECIALLY FOR "
 dc.b "   AMIGA COMPUTING  ",254,"ALL CODE AND GRAPHICS BY"
 dc.b "    JOLYON RALPH    ",254
 dc.b " OF STATYX SOFTWARE ",254," THE MUSIC IS BY "
 dc.b "    KEVIN COLLIER   ",254
 dc.b "................................. ERM "
 dc.b "........................... HELLO MUM ............................... "
 dc.b " ERM ..................................... "
 dc.b "QUESTION ..... WHAT'S WHITE, WOOLY, HAS FOUR LEGS AND IS FOUND IN " 
 dc.b "GREATER MANCHESTER ..... ANSWER ..... A LOST SHEEP ..... HEHE"
 dc.b "HEHEHEHEHEHEHEHEHEHEHEHEHEHEHEHEHE " 
 dc.b "............................ ERM ............................ "
 dc.b "WATCH VERY CLOSELY ..... "
 dc.b "DON'T TAKE YOUR EYES OF THIS MESSAGE ..... YOU ARE FEELING SLEEPY "
 dc.b "..... YOU ARE FEELING SLEEPY ..... YOU ARE DEEPLY RELAXED AND "
 dc.b "FEELING VERY VERY HEAVY ..... "
 dc.b "YOUR LEFT FOOT IS PERFECTLY RELAXED ..... IT IS HEAVY AND RELAXED "
 dc.b "AND WARM .............. THE WHOLE OF YOUR LEFT LEG IS NOW HEAVY "
 dc.b "AND DEEPLY RELAXED ..... IT FEELS PART OF THE CHAIR IT IS SO "
 dc.b "RELAXED ................ NOW YOUR RIGHT LEG IS DEEPLY RELAXED "
 dc.b "..... IT IS PERFECTLY HEAVY ..... YOU ARE GOING TO SLEEP ..... "
 dc.b "YOUR BODY IS DEEPLY HEAVY "
 dc.b "AND PERFECTLY NUMB ..... IT IS VERY RELAXED ..... YOUR HEAD IS "
 dc.b "DEEPLY PERFECT AND HEAVLY SLEEPY ..... YOUR RIGHT EAR IS "
 dc.b "PERFECTLY RELAXED AND WARM ..... YOUR LEFT EAR IS DEEPLY RELAXED "
 dc.b "AND ITCHY ..... YOUR NOSE IS PERFECTLY RELAXED ................ "
 dc.b "YOUR LEFT EAR IS STILL DEEPLY RELAXED AND ITCHY ..... YOUR LEFT "
 dc.b "FOOT IS HEAVILY RELAXED AND ALSO ITCHY ............... RELAX "
 dc.b ".............. RELAX ALL YOUR MUSCLES ............ YOUR LEFT FOOT "
 dc.b " IS NOT AT ALL ITCHY .............. NOR IS "
 dc.b "YOUR NOSE ................ RELAX ................ ISN'T IT "
 dc.b "AMAZING HOW AN ITCH JUST DISSAPEARS ........... YOU ARE NOW IN A "
 dc.b "STATE OF DEEP, RELAXED, PERFECTLY HEAVY HYPNOSIS ..... YOU ARE "
 dc.b "AWARE ONLY OF MY VOICE ..... NOW GET UP AND FETCH YOUR JACKET "
 dc.b ".......... YOU ARE PERFECTLY RELAXED AND WARM .......... NOW SIT DOWN AGAIN "
 dc.b "............... GOOD .............. YOU FEEL VERY SLEEPY ............... NOW " 
 dc.b "TAKE OUT YOUR CHEQUE BOOK AND PEN AND WRITE A CHECK FOR a29.95 "
 dc.b "MADE OUT TO AMIGA COMPUTING AND DON'T FORGET TO POST IT TOMORROW "
 dc.b "TO SUBSCRIPTION DEPT. ",254
 dc.b "   DATABASE DIRECT,   ",254
 dc.b "  FREEPOST, L65 3ED   ",254
 dc.b "................ GOOD ...... YOU WILL FORGET ALL THAT I HAVE TOLD YOU EXCEPT "
 dc.b "TO POST THAT CHEQUE ...... YOU ARE FEELING SLEEPY ...... YOU ARE "
 dc.b "FEELING SLEEPY ..... YOU ARE DRIFTING INTO A DEEP SLEEP ..... A "
 dc.b "PERFECTLY DEEP AND RELAXING SLEEP ........................... "
 dc.b "HEHEHEHEHEHEHEHEHEHEHE ..................................... "

 dc.b 255
	even


OURCOPPER:
 	DC.W 	bplcon0,$4200	
; $4200 sets up a 4 bitplane lo-res non-interlace screen
; NOTE: You can change this anywhere in the copperlist, eg to have a
; 1 bitplane lo-res screen at the top, a 3 bitplane med-res screen in
; the middle and a 6 bitplane Hold and Modify interlace picture at 
; the bottom.
 
 	
 
	DC.W 	bplcon2
spritepri	dc.w $0
; $0 for sprite priority - sprites go behind bitplanes

 	DC.W	ddfstrt,$38			
; $38 = normal, non-overscan screen area

	DC.W 	ddfstop,$d0
; $d0 = normal, non-overscan screen area

 	DC.W 	diwstrt,$2c81
; $2c81 = normal start for NTSC/PAL screen 	
 
 	DC.W 	diwstop,$2cc1
; $2cc1 = normal stop for PAL screen ($f4c1=NTSC)

	dc.w 	col0,$0	; set col0 to black
	
coltab:	DS.W	30
; 30 words space for colour table  (not including col0)
; this is for colours 1 to 15

coltab2: ds.w 	32
; 32 words space for sprite colour table (16 cols)

	DC.W 	bpl1mod
horiz_coarse1 dc.w	0		
; $0 for even-planes Modulo - no bitmap off screen	

	DC.W 	bpl2mod
horiz_coarse2 dc.w 0			
; $0 for odd-planes Modulo - no bitmap off screen
	
	DC.W 	bplcon1			
	
horiz_smooth dc.w 0
	dc.w dmacon,$8020
  	
 	DC.W 	bpl1pth
pl1h: 	DC.W	0,bpl1ptl
pl1l: 	DC.W	0,bpl2pth
pl2h: 	DC.W	0,bpl2ptl
pl2l: 	DC.W	0,bpl3pth
pl3h: 	DC.W	0,bpl3ptl
pl3l: 	DC.W	0,bpl4pth
pl4h: 	DC.W	0,bpl4ptl
pl4l: 	DC.W	0,spr0pth
sp0h: 	dc.w 	0,spr0ptl
sp0l: 	dc.w	0,spr1pth
sp1h:	dc.w 	0,spr1ptl
sp1l: 	dc.w 	0,spr2pth
sp2h: 	dc.w 	0,spr2ptl
sp2l: 	dc.w 	0,spr3pth
sp3h:	dc.w	0,spr3ptl
sp3l: 	dc.w 	0,spr4pth
sp4h: 	dc.w 	0,spr4ptl
sp4l: 	dc.w	0,spr5pth
sp5h:	dc.w 	0,spr5ptl
sp5l: 	dc.w 	0,spr6pth
sp6h: 	dc.w 	0,spr6ptl
sp6l: 	dc.w 	0,spr7pth
sp7h:	dc.w	0,spr7ptl
sp7l: 	dc.w 	0


	DC.W $2D09,$FFFE
	DC.W 	bpl1mod,0			
; $0 for even-planes Modulo - no bitmap off screen	

	DC.W 	bpl2mod,0			
; $0 for odd-planes Modulo - no bitmap off screen

; start positons for bitplanes
  
copcols: DS.L 388		; space for 100 lines of the
				; following format
				; CWAIT (AA,09): CMOVE (BB,$180)
				; CMOVE (CC,$184): CMOVE (DD,$186)
				; for the copper colour scheme
				
  	dc.w col0,$0		; end with black
  	dc.w $9009,$fffe	; CWAIT ($90,$09)
  	dc.w col0,$223		; fade colour to grey
  		
 	dc.w dmacon,$20
	dc.w spr0pos,0
	dc.w spr1pos,0
	dc.w spr2pos,0
	dc.w spr3pos,0
	dc.w spr4pos,0
	dc.w spr5pos,0
 	dc.w spr6pos,0
	dc.w spr7pos,0
	
	dc.w spr0ctl,0
	dc.w spr1ctl,0
	dc.w spr2ctl,0
	dc.w spr3ctl,0
	dc.w spr4ctl,0
	dc.w spr5ctl,0
 	dc.w spr6ctl,0
	dc.w spr7ctl,0
	
	dc.w spr0datb,0
	dc.w spr0data,0
	
	dc.w	spr0pth
s2p0h: 	dc.w 	0,spr0ptl
s2p0l: 	dc.w	0
	dc.w dmacon,$8020
	
  	dc.w $9109,$fffe	; CWAIT ($91,$09)
  	dc.w col0,$445	; lighter grey
 	dc.w $9209,$fffe	; CWAIT ($92,$09)
  	dc.w col0,$667		; light grey
  	dc.w $9309,$fffe	
  	dc.w col0,$445
  	dc.w $9409,$fffe
  	dc.w col0,$223
  	
  	dc.w bplcon1,$0
  	dc.w bplcon0,$2200
 	dc.w bpl1mod,2
 	dc.w bpl2mod,2
 	dc.w diwstrt,$2c86
  	
 	dc.w $9609,$fffe	
  
  	dc.w col0,$000
  	dc.w col1,$00f
  	dc.w col2,$000
  	dc.w col3,$00f
 	
 	DC.W 	bpl1pth
p2l1h: 	DC.W	0,bpl1ptl
p2l1l: 	DC.W	0

	
	;dc.w spr0pos,$60
	;dc.w spr0datb,$ffff
	;dc.w spr0data,$8001
	

  	dc.w $9709,$fffe,bplcon1,$0,col0,$100,col1,$1f,col3,$1f
  	
 	DC.W 	bpl2pth
p2l2h: 	DC.W	0,bpl2ptl
p2l2l: 	DC.W	0

  	dc.w $9809,$fffe,bplcon1,$10
  	dc.w $9909,$fffe
  	dc.w $9a09,$fffe,bplcon1,$21,col0,$201,col1,$2f,col3,$2f
  	dc.w $9b09,$fffe
  	dc.w $9c09,$fffe
  	dc.w $9d09,$fffe,bplcon1,$32,col0,$301,col1,$3f,col3,$3f
  	dc.w $9e09,$fffe
  	dc.w $9f09,$fffe
  	dc.w $a009,$fffe
  	dc.w $a109,$fffe,bplcon1,$43,col0,$501,col1,$5f,col3,$5f
  	dc.w $a209,$fffe
  	dc.w $a309,$fffe
  	dc.w $a409,$fffe
  	dc.w $a509,$fffe,bplcon1,$54,col0,$701,col1,$7f,col3,$7f
  	dc.w $a609,$fffe
  	dc.w $a709,$fffe
  	dc.w $a809,$fffe
  	dc.w col0,$80
equbar1a	dc.w $a821,$fffe
	dc.w $180,$880,$180,$800,col0,$901,col1,$9f,col3,$9f
		
  	dc.w $a909,$fffe,bplcon1,$65
  	
  	
	dc.w $180,$f0
equbar1b	dc.w $a921,$fffe
	dc.w col0,$ff0,col0,$f00,col0,$901
		
  	dc.w $aa09,$fffe
  	dc.w col0,$80
equbar1c	dc.w $aa21,$fffe
	dc.w col0,$880,col0,$800,col0,$901
	dc.w $ab09,$fffe
  	dc.w $ac09,$fffe
  	
	dc.w $180,$80
equbar2a	dc.w $ac21,$fffe
	dc.w col0,$880,col0,$800,col0,$b01,col1,$bf,col3,$bf

  	dc.w $ad09,$fffe,bplcon1,$76
 	dc.w col0,$f0
equbar2b	dc.w $ad21,$fffe
	dc.w col0,$ff0,col0,$f00,col0,$b01
		
 
  	dc.w $ae09,$fffe
 	dc.w col0,$80
equbar2c	dc.w $ae21,$fffe
	dc.w col0,$880,col0,$800,col0,$d01
		
 
 	dc.w $af09,$fffe
  	dc.w $b009,$fffe
  
	dc.w $180,$80
equbar3a	dc.w $b021,$fffe
	dc.w $180,$880,$180,$800,$180,$d01
	
  	dc.w $b109,$fffe
  	
  	
	dc.w $180,$f0
equbar3b	dc.w $b121,$fffe
	dc.w $180,$ff0,$180,$f00,$180,$d01
	
	dc.w $b209,$fffe
  	
	dc.w $180,$80
equbar3c	dc.w $b221,$fffe
	dc.w $180,$880,$180,$800,$180,$b01
	
	dc.w $b309,$fffe
  	dc.w $b409,$fffe,bplcon1,$65
  
	dc.w $180,$80
equbar4a	dc.w $b421,$fffe
	dc.w $180,$880,$180,$800,$180,$b01,col1,$9f,col3,$9f
	dc.w $b509,$fffe
	
	dc.w $180,$f0
equbar4b	dc.w $b521,$fffe
	dc.w $180,$ff0,$180,$f00,$180,$901
	
  	
  	dc.w $b609,$fffe
  	
	dc.w $180,$80
equbar4c	dc.w $b621,$fffe
	dc.w $180,$880,$180,$800,$180,$901
	
  	dc.w $b709,$fffe
  	dc.w $b809,$fffe,bplcon1,$54,col0,$701,col1,$7f,col3,$7f
  	dc.w $b909,$fffe
  	dc.w $ba09,$fffe
  	dc.w $bb09,$fffe
  	dc.w $bc09,$fffe,bplcon1,$43,col0,$501,col1,$5f,col3,$5f
  	dc.w $bd09,$fffe
  	dc.w $be09,$fffe
 	dc.w $bf09,$fffe
  	dc.w $c009,$fffe,bplcon1,$32,col0,$301,col1,$3f,col3,$3f
  	dc.w $c109,$fffe
  	dc.w $c209,$fffe
  	dc.w $c309,$fffe,bplcon1,$21,col0,$101,col1,$1f,col3,$1f
  	dc.w $c409,$fffe
  	dc.w $c509,$fffe
  	dc.w $c609,$fffe,bplcon1,$10,col0,$000,col1,$f,col1,$f
  	dc.w $c709,$fffe	
  	dc.w $c809,$fffe
  	dc.w $ca09,$fffe,bplcon0,$1200
  	dc.w bpl1mod,0,bpl2mod,0		; 1bitplane
  	DC.W 	bpl1pth
p3l1h: 	DC.W	0,bpl1ptl
p3l1l: 	DC.W	0
 	DC.W	diwstrt,$2c81
 	
 	dc.w col0,$223
 	
 	dc.w $cc09,$fffe	
  	dc.w col0,$445
  	dc.w $cd09,$fffe	
  	dc.w col0,$667
  	dc.w $ce09,$fffe
  	dc.w col0,$445
  	dc.w $cf09,$fffe
  	dc.w col0,$223
 	
	dc.w $d009,$fffe,col1,$400,col0,$0
	dc.w $d109,$fffe,col1,$800
	
	dc.w $d309,$fffe,col1,$c00
	dc.w $d509,$fffe,col1,$f00
		; the spectrum
		; analyzer colours
							

	dc.w $dc09,$fffe,col1,$f10
	dc.w $dd09,$fffe,col1,$f20
		
	dc.w $de09,$fffe,col1,$f30
	dc.w $df09,$fffe,col1,$f40
	dc.w $e009,$fffe,col1,$f50
	dc.w $e109,$fffe,col1,$f60
	dc.w $e209,$fffe,col1,$f70
	dc.w $e309,$fffe,col1,$f80
	
	dc.w $e409,$fffe,col1,$f90
	dc.w $e509,$fffe,col1,$fa0
	dc.w $e609,$fffe,col1,$fb0
	dc.w $e709,$fffe,col1,$fc0
	dc.w $e809,$fffe,col1,$fd0
	dc.w $e909,$fffe,col1,$fe0
	
	dc.w $ea09,$fffe,col1,$ff0
	dc.w $eb09,$fffe,col1,$ef0
	dc.w $ec09,$fffe,col1,$df0
	dc.w $ed09,$fffe,col1,$cf0
	dc.w $ee09,$fffe,col1,$bf0
	dc.w $ef09,$fffe,col1,$af0
	
	dc.w $f009,$fffe,col1,$9f0
	dc.w $f109,$fffe,col1,$8f0
	dc.w $f209,$fffe,col1,$7f0
	dc.w $f309,$fffe,col1,$6f0
	dc.w $f409,$fffe,col1,$5f0
	dc.w $f509,$fffe,col1,$4f0

  	dc.w $ff09,$fffe,$ffdd,$fffe	; this allows use of
  					; copper in PAL area
  	dc.w $0d09,$fffe
copcols2
	ds.w 32			; space for 16 colours
 	dc.w $0e09,$fffe,bplcon0,$4200,bplcon1,$0			
 	DC.W 	bpl1pth
p4l1h: 	DC.W	0,bpl1ptl
p4l1l: 	DC.W	0,bpl2pth
p4l2h: 	DC.W	0,bpl2ptl
p4l2l: 	DC.W	0,bpl3pth
p4l3h: 	DC.W	0,bpl3ptl
p4l3l: 	DC.W	0,bpl4pth
p4l4h: 	DC.W	0,bpl4ptl
p4l4l: 	DC.W	0
	dc.w $2109,$fffe,bplcon0,$0200	; turn off bitplane

  	DC.W intreq,$8010	; Generate a LEVEL 3 Interrupt
  	DC.W $FFFF,$FFFE	; CWAIT ($ff,$ff) = end copper
				
  	
  	
bardata: ;data list for the blue copper effect
 DC.B 0,1,2,3,4,5,6,7,8,9,10,11,12,13,13,14,14,15,15,15
 DC.B 14,14,13,13,12,11,10,9,8,7,6,5,4,3,2,1
 ds.b 20

barend
 DC.B 0,1,2,3,4,5,6,7,8,9,10,11,12,13,13,14,14,15,15,15
 DC.B 14,14,13,13,12,11,10,9,8,7,6,5,4,3,2,1
	
	dc.b 255
	

		EVEN	
			
temptr: 	dc.l 0
barptr: 	DC.L bardata
sprhordir: 	dc.b -1
sprhorpos: 	dc.b $c0	
	
gfxbase: 	DC.L 0

gfxlib: DC.B "graphics.library",0 

	even

redtable: 		; table containing colours for tick in logo

 ds.w 8
 dc.w $F00,$F00,$F00,$F00,$F10,$F10,$F10,$F10,$F20,$F20,$F20,$F20,$F20
 dc.w $F30,$F30,$F30,$F30,$F40,$F40,$F40,$F40,$F40,$F50,$F50,$F50,$F50
 dc.w $F60,$F60,$F60,$F60,$F60,$F70,$F70,$F70,$F70,$F80,$F80,$F80,$F80
 dc.w $F80,$F90,$F90,$F90,$F90,$FA0,$FA0,$FA0,$FA0,$FA0,$FB0,$FB0,$FB0
 dc.w $FB0,$FC0,$FC0,$FC0,$FC0,$FC0,$FD0,$FD0,$FD0,$FD0,$FE0,$FE0,$FE0
 dc.w $FE0,$FE0,$FF0,$FF0,$FF0,$FF0,$FF0
 ds.w 16

bluetable:		; this is the colours for the blue-green part 

 ds.w 48
 dc.w $F,$1e,$1e,$20d,$2d,$3c,$3c,$4b,$4b,$5a,$5a,$69,$69,$78,$78,$87,$87
 dc.w $96,$96,$A5,$A5,$B4,$b4,$C3,$C3,$D2,$D2,$E1,$E1,$F0,$F0,$F0
 ds.w 16
 
spritecols
 dc.w 0,$558,$1,$12,$23,3,$310,$850,$640,$740,$a72,$850,$a71,$d93,$fc5,$530
; 16 colours for sprite

sprite0
 dc.w $30c0,$7000		; sprite 0
 dc.w $7DE0,$0FF8
 dc.w $3EF3,$09F8
 dc.w $0F62,$04FD
 dc.w $018B,$037E
 dc.w $68DF,$49BC
 dc.w $7E65,$36DE
 dc.w $56AB,$24DE
 dc.w $4693,$7E2F
 dc.w $69C9,$6F17
 dc.w $0EC9,$0F8F
 dc.w $67E5,$1FD7
 dc.w $3FF0,$4DEF
 dc.w $07AE,$7F47
 dc.w $72DB,$0F6E
 dc.w $7E77,$06F3
 dc.w $7D7D,$6017
 dc.w $7FFB,$7FED
 dc.w $41DC,$3E75
 dc.w $5FAB,$3234
 dc.w $49F2,$3602
 dc.w $7FFC,$7FF4
 dc.w $7FFE,$7FFE
 dc.w $7FE4,$7FFC
 dc.w $3FF0,$7FFE
 dc.w $7C40,$03BE
 dc.w $3E0C,$41F3
 dc.w $7FCA,$7FFB
 dc.w $7FEB,$7F77
 dc.w $3FAB,$7FF7
 dc.w $7E09,$01FF
 dc.w $7E9B,$217D
 dc.w $7FEF,$7FED
 dc.w $7FF3,$201D
 dc.w $3E17,$41E7
 dc.w $7FC2,$3FB4
 dc.w $7F8F,$007C
 dc.w $7FF7,$07EC
 dc.w $7FC4,$073F
 dc.w $7E01,$01FF
 dc.w $7904,$06FB
 dc.w $3C82,$437D
 dc.w $7FFC,$7DE7
 dc.w $7FF0,$7F3F
 dc.w $1964,$669B
 dc.w $7FFE,$0001
 dc.w $57E0,$285F
 dc.w $7FE0,$7FFF
 dc.w $1300,$6CFF
 dc.w $0002,$7FFF
 dc.w $6208,$1DF7
 dc.w $7FFF,$0000
 dc.w $13E4,$6C1B
 dc.w $7FF9,$7FC7
 dc.w $3FFC,$7FE3
 dc.w $68F8,$1747
 dc.w $7FFF,$7FFF
 dc.w $7FC7,$7FC5
 dc.w $7FFC,$0003
 dc.w $7EDE,$0121
 dc.w $6FFF,$7C62
 dc.w $423F,$7FD6
 dc.w $7FFD,$0002
 dc.w $7E7F,$0180
 dc.w $3F3F,$40C0
 dc.w $0000,$0000
 
sprite1
 dc.w $30c0,$7080
 dc.w $71FF,$01E0
 dc.w $36FF,$40F0
 dc.w $0B7A,$7000
 dc.w $408D,$7C38
 dc.w $785F,$3604
 dc.w $7E27,$0908
 dc.w $57AB,$0F06
 dc.w $4793,$47C5
 dc.w $69C9,$79E3
 dc.w $0EE1,$7E72
 dc.w $6761,$0678
 dc.w $33B0,$0119
 dc.w $00AC,$001C
 dc.w $709B,$0006
 dc.w $0716,$781E
 dc.w $62ED,$7D03
 dc.w $7FF3,$7C22
 dc.w $419C,$0017
 dc.w $4DC1,$000B
 dc.w $49FE,$0001
 dc.w $7FF9,$1E02
 dc.w $7FF9,$7FC8
 dc.w $7FFE,$7FE5
 dc.w $7FFD,$3FF1
 dc.w $7C40,$0001
 dc.w $7E0C,$001C
 dc.w $7FDE,$0024
 dc.w $7F7B,$60CD
 dc.w $7FBE,$3008
 dc.w $7E1D,$000B
 dc.w $5E9F,$000B
 dc.w $7FFF,$4037
 dc.w $2017,$7FFB
 dc.w $7E17,$000F
 dc.w $404F,$000A
 dc.w $7F8F,$000E
 dc.w $07EF,$7813
 dc.w $073E,$78C0
 dc.w $7E00,$0000
 dc.w $7904,$0000
 dc.w $7C82,$0000
 dc.w $7DE7,$721C
 dc.w $7F3F,$7EF0
 dc.w $1964,$0000
 dc.w $7FFE,$0000
 dc.w $57A0,$0000
 dc.w $7FFF,$7FE0
 dc.w $6CFF,$1300
 dc.w $7FFF,$0002
 dc.w $6208,$0000
 dc.w $7FFF,$0000
 dc.w $13E4,$0000
 dc.w $7FC1,$71BF
 dc.w $7FE0,$38DF
 dc.w $68B8,$0000
 dc.w $7FFF,$0000
 dc.w $7FC5,$7FFF
 dc.w $7FFC,$0000
 dc.w $7EDE,$0000
 dc.w $7C62,$6FFF
 dc.w $7FD6,$423F
 dc.w $7FFD,$0000
 dc.w $7E7F,$0000
 dc.w $7F3F,$0000
 dc.w $0000,$0000
 
sprite2
 dc.w $30c8,$7000
 dc.w $69D8,$F1E0
 dc.w $793B,$752B
 dc.w $7D5A,$180B
 dc.w $AD5C,$305C
 dc.w $B5A8,$7AA6
 dc.w $ACAE,$6FA8
 dc.w $CCC4,$2FFE
 dc.w $EC8C,$8BFE
 dc.w $58A0,$BFF7
 dc.w $F020,$D707
 dc.w $B390,$D03F
 dc.w $DE90,$CD37
 dc.w $6800,$FBA7
 dc.w $8806,$FB9F
 dc.w $8440,$F1CF
 dc.w $A000,$701F
 dc.w $081F,$881F
 dc.w $8A00,$8AFF
 dc.w $499E,$8F9E
 dc.w $0784,$0787
 dc.w $8118,$2F1F
 dc.w $D81C,$9FDC
 dc.w $1FC3,$3BDF
 dc.w $2FFB,$67FB
 dc.w $4C7D,$CFFF
 dc.w $88ED,$8DFD
 dc.w $A853,$BFDB
 dc.w $9857,$9BBF
 dc.w $65E3,$FA13
 dc.w $143B,$87EB
 dc.w $0FE6,$8476
 dc.w $0FE5,$84ED
 dc.w $8FED,$002D
 dc.w $8FCD,$C05D
 dc.w $0FDF,$405F
 dc.w $87DE,$C07F
 dc.w $83F8,$C13F
 dc.w $81E2,$E13F
 dc.w $C1FC,$601D
 dc.w $C1F7,$B017
 dc.w $41E5,$D027
 dc.w $01E0,$D01F
 dc.w $1180,$D967
 dc.w $7121,$8DE5
 dc.w $11E0,$F3E7
 dc.w $0073,$F977
 dc.w $3E3F,$FEBF
 dc.w $010E,$FD4F
 dc.w $40CF,$FFEF
 dc.w $002E,$FFAF
 dc.w $E11F,$1F7F
 dc.w $0177,$FE77
 dc.w $C1EF,$3FFF
 dc.w $E5FA,$9E7A
 dc.w $046A,$FE7A
 dc.w $047C,$267C
 dc.w $F873,$3A71
 dc.w $371F,$CF1F
 dc.w $75DF,$8FDD
 dc.w $FFCE,$F5CE
 dc.w $FD63,$7FE3
 dc.w $C5FF,$3FFD
 dc.w $F476,$0EF2
 dc.w $FA3B,$0779
 dc.w $0000,$0000
 
sprite3
 dc.w $30c8,$7080
 dc.w $EFF8,$61C7
 dc.w $FB33,$31E4
 dc.w $9612,$71E6
 dc.w $FE7E,$019F
 dc.w $B4D2,$0109
 dc.w $A8D8,$100F
 dc.w $E8DE,$1005
 dc.w $6CFE,$100D
 dc.w $58F8,$0008
 dc.w $B04C,$88F8
 dc.w $B374,$0CC0
 dc.w $FEFC,$0448
 dc.w $486E,$C458
 dc.w $8806,$4460
 dc.w $0840,$6E70
 dc.w $A81D,$6FE0
 dc.w $781F,$77FE
 dc.w $FAFF,$7700
 dc.w $6F9F,$F9FD
 dc.w $D787,$FFFB
 dc.w $D09F,$F067
 dc.w $E02F,$4003
 dc.w $5BC3,$8CE0
 dc.w $BFFB,$1C37
 dc.w $7FFF,$3C59
 dc.w $DA3F,$700B
 dc.w $E43B,$4017
 dc.w $7A6F,$0442
 dc.w $65F3,$000E
 dc.w $7FEB,$F836
 dc.w $7C77,$FBE9
 dc.w $7CF7,$FBFA
 dc.w $783F,$FFD2
 dc.w $B86F,$7FF7
 dc.w $BC7F,$7FEB
 dc.w $BE5F,$7FF2
 dc.w $BF3D,$7FE8
 dc.w $9F3F,$7FE2
 dc.w $DE1D,$3FF2
 dc.w $0E1F,$7FF8
 dc.w $6E3F,$5FF9
 dc.w $EE3F,$1FE0
 dc.w $F707,$1FF8
 dc.w $63FF,$1F1B
 dc.w $1DFF,$0798
 dc.w $06F7,$038B
 dc.w $FF7F,$39C7
 dc.w $FBBF,$00F6
 dc.w $FCDF,$4031
 dc.w $007F,$001E
 dc.w $E1DF,$0007
 dc.w $00FF,$015F
 dc.w $3DE8,$C090
 dc.w $9C75,$E5C0
 dc.w $0465,$0590
 dc.w $DC77,$FD84
 dc.w $397C,$FD82
 dc.w $3618,$06E8
 dc.w $7650,$0422
 dc.w $F541,$FE30
 dc.w $7DEC,$E010
 dc.w $C570,$0140
 dc.w $F7F9,$0150
 dc.w $FBFC,$00A8
 dc.w $0000,$0000
 
sprite4
 dc.w $30d0,$7000
 dc.w $3789,$37B5
 dc.w $02D3,$FEEB
 dc.w $0033,$CA43
 dc.w $0036,$CC06
 dc.w $026F,$4A07
 dc.w $83FC,$CFED
 dc.w $719E,$FFBF
 dc.w $712C,$F98B
 dc.w $77CD,$FFCA
 dc.w $442D,$4FAE
 dc.w $424A,$4F8C
 dc.w $01DB,$055C
 dc.w $305D,$34D9
 dc.w $B31A,$B5F4
 dc.w $B3CD,$B5F9
 dc.w $8388,$B7AC
 dc.w $8387,$FFAF
 dc.w $0005,$FFFD
 dc.w $C408,$BC0C
 dc.w $023A,$7A3D
 dc.w $1C3D,$E3FE
 dc.w $0800,$0FF9
 dc.w $E032,$FB82
 dc.w $D873,$FE66
 dc.w $140F,$FFE7
 dc.w $C717,$3BAF
 dc.w $1A37,$D9D9
 dc.w $681B,$4DFB
 dc.w $77A4,$405F
 dc.w $7E06,$3786
 dc.w $7F82,$3BDA
 dc.w $5FC2,$77DE
 dc.w $2FE3,$5EF1
 dc.w $FBE1,$ED7F
 dc.w $E863,$BB1A
 dc.w $B8C0,$F330
 dc.w $1C00,$FFE0
 dc.w $0251,$DB90
 dc.w $2543,$FD40
 dc.w $A273,$BC31
 dc.w $E3D7,$E653
 dc.w $85E7,$8067
 dc.w $90CF,$8347
 dc.w $BC78,$A89C
 dc.w $0EFD,$F61D
 dc.w $28FE,$F0BF
 dc.w $F0DA,$F8E9
 dc.w $089B,$CCD9
 dc.w $E8F0,$ECF9
 dc.w $D964,$F9E9
 dc.w $F9CA,$FBFD
 dc.w $EFF8,$FFDF
 dc.w $FD60,$FDF7
 dc.w $EE40,$A867
 dc.w $EE60,$F2E7
 dc.w $CA21,$8822
 dc.w $B159,$015A
 dc.w $FB63,$E367
 dc.w $8679,$0877
 dc.w $EF4A,$E347
 dc.w $E663,$E86E
 dc.w $E66B,$C067
 dc.w $A7ED,$01E7
 dc.w $53F6,$00F3
 dc.w $0000,$0000
 
sprite5
 dc.w $30d0,$7080
 dc.w $078D,$CBC3
 dc.w $7ADB,$0187
 dc.w $FC3B,$0187
 dc.w $CC36,$33CF
 dc.w $3277,$858E
 dc.w $C3FC,$B22E
 dc.w $C9BE,$415C
 dc.w $C928,$475C
 dc.w $FFF9,$423C
 dc.w $7FED,$C05C
 dc.w $4F6B,$F238
 dc.w $359B,$CB30
 dc.w $781F,$B338
 dc.w $C91A,$0221
 dc.w $C9DD,$03F2
 dc.w $FBA8,$0077
 dc.w $BFAF,$0078
 dc.w $FFFD,$001A
 dc.w $BC0C,$47F3
 dc.w $FE3F,$FDC6
 dc.w $FC03,$FC03
 dc.w $F807,$F001
 dc.w $E3BB,$047E
 dc.w $DFFE,$F9BD
 dc.w $FFEF,$4019
 dc.w $785F,$C41F
 dc.w $FC07,$1A06
 dc.w $7414,$F220
 dc.w $7FA4,$F802
 dc.w $3787,$EE79
 dc.w $3BFF,$EFBD
 dc.w $77FF,$DFFD
 dc.w $7EFD,$AFDE
 dc.w $FD7F,$F39E
 dc.w $FFFE,$57FD
 dc.w $FFFC,$8FFF
 dc.w $BFF8,$13FF
 dc.w $FBD8,$25FF
 dc.w $F540,$5ABF
 dc.w $F431,$1FEF
 dc.w $FE53,$9FEF
 dc.w $8667,$FFDE
 dc.w $B347,$FDFE
 dc.w $FD9E,$5F79
 dc.w $FE1B,$0DF9
 dc.w $F0BE,$0FFA
 dc.w $F8F4,$F7D3
 dc.w $CCF9,$37BE
 dc.w $ECF0,$D7BE
 dc.w $F964,$DF9E
 dc.w $FBCE,$FEB2
 dc.w $EFFA,$F0F0
 dc.w $0173,$03A8
 dc.w $1047,$41B8
 dc.w $0367,$13D8
 dc.w $3421,$41FF
 dc.w $4F59,$90F7
 dc.w $076B,$02F8
 dc.w $707D,$89FA
 dc.w $134E,$02F9
 dc.w $106B,$09F3
 dc.w $586F,$61FA
 dc.w $59FF,$807C
 dc.w $ACFF,$403E
 dc.w $0000,$0000
 
sprite6
 dc.w $30d8,$7000
 dc.w $D980,$E7BF
 dc.w $9BC0,$E3BF
 dc.w $B7FF,$C387
 dc.w $6F2B,$87CC
 dc.w $67E0,$8408
 dc.w $4DA4,$8E37
 dc.w $3F4F,$9C68
 dc.w $BAD7,$3C58
 dc.w $75AF,$28E0
 dc.w $7F90,$612B
 dc.w $7A4F,$713F
 dc.w $A62C,$80EF
 dc.w $018F,$0070
 dc.w $001C,$04EF
 dc.w $0138,$4247
 dc.w $28CF,$A13F
 dc.w $18C3,$DA47
 dc.w $9D00,$E8DF
 dc.w $16C8,$D737
 dc.w $0BFF,$C880
 dc.w $89FF,$4A40
 dc.w $1FCF,$B8EF
 dc.w $21AF,$07AF
 dc.w $7AFF,$D950
 dc.w $B39F,$FF70
 dc.w $DC0F,$C9B8
 dc.w $E9BF,$FFE8
 dc.w $E13F,$B97F
 dc.w $70BF,$EEC0
 dc.w $18DF,$37E0
 dc.w $3C6F,$06F0
 dc.w $1DFF,$577F
 dc.w $83F0,$DFFF
 dc.w $D03F,$41C0
 dc.w $623F,$6DC0
 dc.w $461F,$75E0
 dc.w $0060,$35DF
 dc.w $9000,$5FFF
 dc.w $F7FF,$E818
 dc.w $DFDB,$E024
 dc.w $0623,$07FF
 dc.w $0FE0,$0FFF
 dc.w $4380,$439F
 dc.w $06FF,$7900
 dc.w $7C03,$8000
 dc.w $2F27,$D0D8
 dc.w $FFCC,$FF9F
 dc.w $DFC3,$DE7F
 dc.w $6FE1,$EF3F
 dc.w $FFC3,$03BC
 dc.w $FFFF,$0000
 dc.w $1FBF,$E040
 dc.w $C624,$FFFF
 dc.w $E312,$FFFF
 dc.w $8DF3,$73FC
 dc.w $8760,$FFFF
 dc.w $FF1F,$EFFF
 dc.w $BFFF,$C000
 dc.w $8307,$C4F8
 dc.w $FFFF,$D300
 dc.w $7FFF,$FFC0
 dc.w $9F00,$FCFF
 dc.w $F808,$07F7
 dc.w $FC04,$83FB
 dc.w $0000,$0000
 
sprite7
 dc.w $30d8,$7080
 dc.w $D9A0,$81C0
 dc.w $9FC0,$8380
 dc.w $BFFF,$0387
 dc.w $7F3C,$070B
 dc.w $77E8,$0E17
 dc.w $6DF7,$1C2C
 dc.w $7FEF,$1C58
 dc.w $FBDF,$3070
 dc.w $F7AF,$10F0
 dc.w $FF93,$11E4
 dc.w $7E4F,$81CF
 dc.w $BE2C,$63BC
 dc.w $19BF,$E700
 dc.w $3950,$C600
 dc.w $3138,$8E80
 dc.w $5A8F,$8D14
 dc.w $3DC7,$C078
 dc.w $DE9F,$5160
 dc.w $5C48,$E080
 dc.w $CF7F,$F000
 dc.w $CDBF,$B000
 dc.w $BBCF,$C33C
 dc.w $A1AF,$FE7F
 dc.w $7EAF,$2000
 dc.w $B78F,$8280
 dc.w $FFC7,$D440
 dc.w $FDE8,$62B7
 dc.w $7F7F,$66BF
 dc.w $3CFF,$3300
 dc.w $1EDF,$D900
 dc.w $FEEF,$FD00
 dc.w $DFFF,$EDC0
 dc.w $CBFF,$7770
 dc.w $723F,$DD00
 dc.w $7E3F,$F200
 dc.w $5E1F,$EE00
 dc.w $41DF,$8E60
 dc.w $3FFF,$C000
 dc.w $D7E7,$8000
 dc.w $DFDB,$8000
 dc.w $87FF,$7E23
 dc.w $8FFF,$7FE0
 dc.w $C39F,$7FE0
 dc.w $86FF,$0000
 dc.w $7FFF,$0000
 dc.w $2F27,$0000
 dc.w $FFBF,$01EC
 dc.w $DE7F,$7FC3
 dc.w $6F3F,$3FE1
 dc.w $FC43,$0000
 dc.w $FFFF,$0000
 dc.w $1FBF,$0000
 dc.w $FFFF,$C624
 dc.w $FFFF,$6312
 dc.w $0C03,$8000
 dc.w $FFFF,$0760
 dc.w $EFFF,$3B1F
 dc.w $BFFF,$0000
 dc.w $BB07,$8000
 dc.w $D300,$FFFF
 dc.w $7FC0,$803F
 dc.w $8300,$8000
 dc.w $F808,$8000
 dc.w $FC04,$4000
 dc.w $0000,$0000
 
 
sbounceptr dc.l spritebounce 
spritebounce
 dc.b $96,$90,$8B,$85,$80,$7B,$75,$70,$6B,$66,$61,$5C,$58,$53,$4F,$4B,$47
 dc.b $44,$40,$3D,$3A,$38,$35,$33,$31,$30,$2E,$2D,$2D,$2C,$2C,$2C,$2D,$2D
 dc.b $2E,$30,$31,$33,$35,$38,$3A,$3D,$40,$44,$47,$4B,$4F,$53,$58,$5C,$61
 dc.b $66,$6B,$70,$75,$7B,$80,$85,$8B,$90,$ff

 	
 	
plane1: 	incbin graphics_data/amigalogo
showplane: 	ds.b 3000
scrollplane: 	ds.b 2500
font: 		incbin graphics_data/sinefont
showplane2: 	ds.b 4000
panel		incbin graphics_data/panel

eq1 dc.b 0
eq2 dc.b 0
eq3 dc.b 0
eq4 dc.b 0
eq1p dc.w 381
eq2p dc.w 381
eq3p dc.w 381
eq4p dc.w 381


start_muzak:
	move.l	#data,muzakoffset	;** get offset

init0:	move.l	muzakoffset,a0		;** get highest used pattern
	add.l	#472,a0
	move.l	#$80,d0
	clr.l	d1
init1:	move.l	d1,d2
	subq.w	#1,d0
init2:	move.b	(a0)+,d1
	cmp.b	d2,d1
	bgt.s	init1
	dbf	d0,init2
	addq.b	#1,d2

init3:	move.l	muzakoffset,a0		;** calc samplepointers
	lea	pointers(pc),a1
	lsl.l	#8,d2
	lsl.l	#2,d2
	add.l	#600,d2
	add.l	a0,d2
	moveq	#14,d0
init4:	move.l	d2,(a1)+
	clr.l	d1
	move.w	42(a0),d1
	lsl.l	#1,d1
	add.l	d1,d2
	add.l	#30,a0
	dbf	d0,init4

init5:	clr.w	$dff0a8			;** clear used values
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.w	timpos
	clr.l	trkpos
	clr.l	patpos

init6:	move.l	muzakoffset,a0		;** initialize timer irq
	move.b	470(a0),numpat+1	;number of patterns
	rts

stop_muzak:
	move.l	lev3save+2,$6c.w
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

lev3interrupt:
	bsr.s	replay_muzak
lev3save:
	jmp	0.l

replay_muzak:
	movem.l	d0-d7/a0-a6,-(a7)
	addq.w	#1,timpos
speed:	cmp.w	#6,timpos
	beq.w	replaystep

chaneleffects:				;** seek effects
	lea	datach0(pc),a6
	tst.b	3(a6)
	beq.s	ceff1
	lea	$dff0a0,a5
	bsr.s	ceff5
ceff1:	lea	datach1(pc),a6
	tst.b	3(a6)
	beq.s	ceff2
	lea	$dff0b0,a5
	bsr.s	ceff5
ceff2:	lea	datach2(pc),a6
	tst.b	3(a6)
	beq.s	ceff3
	lea	$dff0c0,a5
	bsr.s	ceff5
ceff3:	lea	datach3(pc),a6
	tst.b	3(a6)
	beq.s	ceff4
	lea	$dff0d0,a5
	bsr.s	ceff5
ceff4:	movem.l	(a7)+,d0-d7/a0-a6
	rts

ceff5:	move.b	2(a6),d0		;room for some more
	and.b	#$f,d0			;implementations below
	tst.b	d0
	beq.s	arpreggiato
	cmp.b	#1,d0
	beq.w	pitchup
	cmp.b	#2,d0
	beq.w	pitchdown
	cmp.b	#12,d0
	beq.w	setvol
	cmp.b	#14,d0
	beq.w	setfilt
	cmp.b	#15,d0
	beq.w	setspeed
	rts

arpreggiato:				;** spread by time
	cmp.w	#1,timpos
	beq.s	arp1
	cmp.w	#2,timpos
	beq.s	arp2
	cmp.w	#3,timpos
	beq.s	arp3
	cmp.w	#4,timpos
	beq.s	arp1
	cmp.w	#5,timpos
	beq.s	arp2
	rts

arp1:	clr.l	d0			;** get higher note-values
	move.b	3(a6),d0		;   or play original
	lsr.b	#4,d0
	bra.s	arp4
arp2:	clr.l	d0
	move.b	3(a6),d0
	and.b	#$f,d0
	bra.s	arp4
arp3:	move.w	16(a6),d2
	bra.s	arp6
arp4:	lsl.w	#1,d0
	clr.l	d1
	move.w	16(a6),d1
	lea	notetable,a0
arp5:	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	beq.s	arp6
	addq.l	#2,a0
	bra.s	arp5
arp6:	move.w	d2,6(a5)
	rts

pitchdown:
	bsr.s	newrou
	clr.l	d0
	move.b	3(a6),d0
	and.b	#$f,d0
	add.w	d0,(a4)
	cmp.w	#$358,(a4)
	bmi.s	ok1
	move.w	#$358,(a4)
ok1:	move.w	(a4),6(a5)
	rts

pitchup:bsr.s	newrou
	clr.l	d0
	move.b	3(a6),d0
	and.b	#$f,d0
	sub.w	d0,(a4)
	cmp.w	#$71,(a4)
	bpl.s	ok2
	move.w	#$71,(a4)
ok2:	move.w	(a4),6(a5)
	rts

setvol:	move.b	3(a6),8(a5)
	rts

setfilt:move.b	3(a6),d0
	and.b	#1,d0
	lsl.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

setspeed:
	clr.l	d0
	move.b	3(a6),d0
	and.b	#$f,d0
	move.w	d0,speed+2
	rts

newrou:	cmp.l	#datach0,a6
	bne.s	next1
	move.b #$1c,eq1
	move.w (a6),eq1p
	lea	voi1(pc),a4
	rts
next1:	cmp.l	#datach1,a6
	bne.s	next2
	move.b #$1c,eq2
	move.w (a6),eq2p
	lea	voi2(pc),a4
	rts
next2:	cmp.l	#datach2,a6
	bne.s	next3
	move.b #$1c,eq3
	move.w (a6),eq3p
	lea	voi3(pc),a4
	rts
next3:	lea	voi4(pc),a4
	move.b #$1c,eq4
	move.w (a6),eq4p
	rts

replaystep:				;** work next pattern-step
	clr.w	timpos
	move.l	muzakoffset,a0
	move.l	a0,a3
	add.l	#12,a3			;ptr to soundprefs
	move.l	a0,a2
	add.l	#472,a2			;ptr to pattern-table
	add.l	#600,a0			;ptr to first pattern
	clr.l	d1
	move.l	trkpos,d0		;get ptr to current pattern
	move.b	(a2,d0),d1
	lsl.l	#8,d1
	lsl.l	#2,d1
	add.l	patpos,d1		;get ptr to current step
	clr.w	enbits
	lea	$dff0a0,a5		;chanel 0
	lea	datach0(pc),a6
	bsr.w	chanelhandler
	lea	$dff0b0,a5		;chanel 1
	lea	datach1(pc),a6
	bsr.w	chanelhandler
	lea	$dff0c0,a5		;chanel 2
	lea	datach2(pc),a6
	bsr.w	chanelhandler
	lea	$dff0d0,a5		;chanel 3
	lea	datach3(pc),a6
	bsr.w	chanelhandler
	move.w	#400,d0			;** wait a while and set len
rep1:	dbf	d0,rep1			;   of oneshot to 1 word
	move.w	#$8000,d0
	or.w	enbits,d0
	move.w	d0,$dff096
	cmp.w	#1,datach0+14
	bne.s	rep2
	clr.w	datach0+14
	move.w	#1,$dff0a4
rep2:	cmp.w	#1,datach1+14
	bne.s	rep3
	clr.w	datach1+14
	move.w	#1,$dff0b4
rep3:	cmp.w	#1,datach2+14
	bne.s	rep4
	clr.w	datach2+14
	move.w	#1,$dff0c4
rep4:	cmp.w	#1,datach3+14
	bne.s	rep5
	clr.w	datach3+14
	move.w	#1,$dff0d4

rep5:	add.l	#16,patpos		;next step
	cmp.l	#64*16,patpos		;pattern finished ?
	bne.s	rep6
	clr.l	patpos
	addq.l	#1,trkpos		;next pattern in table
	clr.l	d0
	move.w	numpat,d0
	cmp.l	trkpos,d0		;song finished ?
	bne.s	rep6
	clr.l	trkpos
rep6:	movem.l	(a7)+,d0-d7/a0-a6
	rts

chanelhandler:
	move.l	(a0,d1.l),(a6)		;get period & action-word
	addq.l	#4,d1			;point to next chanel
	clr.l	d2
	move.b	2(a6),d2		;get nibble for soundnumber
	lsr.b	#4,d2
	beq.s	chan2			;no soundchange !
	move.l	d2,d4			;** calc ptr to sample
	lsl.l	#2,d2
	mulu	#30,d4
	lea	pointers-4(pc),a1
	move.l	(a1,d2.l),4(a6)		;store sample-address
	move.w	(a3,d4.l),8(a6)		;store sample-len in words
	move.w	2(a3,d4.l),18(a6)	;store sample-volume

	move.l	d0,-(a7)
	move.b	2(a6),d0
	and.b	#$f,d0
	cmp.b	#$c,d0
	bne.s	ok3
	move.b	3(a6),8(a5)
	bra.s	ok4
ok3:	move.w	2(a3,d4.l),8(a5)	;change chanel-volume
ok4:	move.l	(a7)+,d0

	clr.l	d3
	move.w	4(a3,d4),d3		;** calc repeatstart
	add.l	4(a6),d3
	move.l	d3,10(a6)		;store repeatstart
	move.w	6(a3,d4),14(a6)		;store repeatlength
	cmp.w	#1,14(a6)
	beq.s	chan2			;no sustainsound !
	move.l	10(a6),4(a6)		;repstart  = sndstart
	move.w	6(a3,d4),8(a6)		;replength = sndlength
chan2:	tst.w	(a6)
	beq.s	chan4			;no new note set !
	move.w	22(a6),$dff096		;clear dma
	tst.w	14(a6)
	bne.s	chan3			;no oneshot-sample
	move.w	#1,14(a6)		;allow resume (later)
chan3:	bsr.w	newrou
	move.w	(a6),(a4)
	move.w	(a6),16(a6)		;save note for effect
	move.l	4(a6),(a5)		;set samplestart
	move.w	8(a6),4(a5)		;set samplelength
	move.w	(a6),6(a5)		;set period
	move.w	22(a6),d0
	or.w	d0,enbits		;store dma-bit
	move.w	18(a6),20(a6)		;volume trigger
chan4:	rts

datach0:	dcb.w	11,0
		dc.w	1
datach1:	dcb.w	11,0
		dc.w	2
datach2:	dcb.w	11,0
		dc.w	4
datach3:	dcb.w	11,0
		dc.w	8
voi1:		dc.w	0
voi2:		dc.w	0
voi3:		dc.w	0
voi4:		dc.w	0
pointers:	dcb.l	15,0
notetable:	dc.w	856,808,762,720,678,640,604,570
		dc.w	538,508,480,453,428,404,381,360
		dc.w	339,320,302,285,269,254,240,226  
		dc.w	214,202,190,180,170,160,151,143
		dc.w	135,127,120,113,000
muzakoffset:	dc.l	0
trkpos:		dc.l	0
patpos:		dc.l	0
numpat:		dc.w	0
enbits:		dc.w	0
timpos:		dc.w	0
data:		incbin	modules/mod.zowee


bltddat	EQU   $000
dmaconr	EQU   $002
vposr	EQU   $004
vhposr	EQU   $006
dskdatr	EQU   $008
joy0dat	EQU   $00A
joy1dat	EQU   $00C
clxdat	EQU   $00E

adkconr	EQU   $010
pot0dat	EQU   $012
pot1dat	EQU   $014
potinp	EQU   $016
serdatr	EQU   $018
dskbytr	EQU   $01A
intenar	EQU   $01C
intreqr	EQU   $01E

dskpt	EQU   $020
dsklen	EQU   $024
dskdat	EQU   $026
refptr	EQU   $028
vposw	EQU   $02A
vhposw	EQU   $02C
copcon	EQU   $02E
serdat	EQU   $030
serper	EQU   $032
potgo	EQU   $034
joytest	EQU   $036
strequ	EQU   $038
strvbl	EQU   $03A
strhor	EQU   $03C
strlong	EQU   $03E

bltcon0	EQU   $040
bltcon1	EQU   $042
bltafwm	EQU   $044
bltalwm	EQU   $046
bltcpth	EQU   $048
bltcptl EQU   $04A
bltbpth	EQU   $04C
bltbptl EQU   $04E
bltapth	EQU   $050
bltaptl EQU   $052
bltdpth	EQU   $054
bltdptl EQU   $056
bltsize	EQU   $058

bltcmod	EQU   $060
bltbmod	EQU   $062
bltamod	EQU   $064
bltdmod	EQU   $066

bltcdat	EQU   $070
bltbdat	EQU   $072
bltadat	EQU   $074

dsksync	EQU   $07E

cop1lc	EQU   $080
cop2lc	EQU   $084
copjmp1	EQU   $088
copjmp2	EQU   $08A
copins	EQU   $08C
diwstrt	EQU   $08E
diwstop	EQU   $090
ddfstrt	EQU   $092
ddfstop	EQU   $094
dmacon	EQU   $096
clxcon	EQU   $098
intena	EQU   $09A
intreq	EQU   $09C
adkcon	EQU   $09E


aud0vol	EQU   $0A8
aud1vol EQU   $0B8
aud2vol	EQU   $0C8
aud3vol	EQU   $0D8

bpl1pth	EQU   $0E0
bpl1ptl	EQU   $0E2
bpl2pth	EQU   $0E4
bpl2ptl	EQU   $0E6
bpl3pth	EQU   $0E8
bpl3ptl	EQU   $0EA
bpl4pth	EQU   $0EC
bpl4ptl	EQU   $0EE
bpl5pth	EQU   $0F0
bpl5ptl	EQU   $0F2
bpl6pth	EQU   $0F4
bpl6ptl	EQU   $0F6

bplcon0	EQU   $100
bplcon1	EQU   $102
bplcon2	EQU   $104
bpl1mod	EQU   $108
bpl2mod	EQU   $10A

bpldat	EQU   $110

spr0pth	EQU   $120
spr0ptl EQU   $122
spr1pth EQU   $124
spr1ptl EQU   $126
spr2pth	EQU   $128
spr2ptl EQU   $12A
spr3pth EQU   $12C
spr3ptl EQU   $12E
spr4pth	EQU   $130
spr4ptl EQU   $132
spr5pth EQU   $134
spr5ptl EQU   $136
spr6pth	EQU   $138
spr6ptl EQU   $13A
spr7pth EQU   $13C
spr7ptl EQU   $13E

spr0pos	EQU   $140
spr1pos	EQU   $148
spr2pos EQU   $150
spr3pos EQU   $158
spr4pos EQU   $160
spr5pos EQU   $168
spr6pos EQU   $170
spr7pos EQU   $178

spr0ctl	EQU   $142
spr1ctl	EQU   $14A
spr2ctl EQU   $152
spr3ctl EQU   $15A
spr4ctl EQU   $162
spr5ctl EQU   $16A
spr6ctl EQU   $172
spr7ctl EQU   $17A

spr0data EQU  $144
spr1data EQU  $14c
spr2data EQU  $154
spr3data EQU  $15c
spr4data EQU  $164
spr5data EQU  $16c
spr6data EQU  $174
spr7data EQU  $17c


spr0datb EQU  $146
spr1datb EQU  $14e
spr2datb EQU  $156
spr3datb EQU  $15e
spr4datb EQU  $166
spr5datb EQU  $16e
spr6datb EQU  $176
spr7datb EQU  $17e

col0	EQU   $180
col1 	EQU   $182
col2	EQU   $184
col3    EQU   $186
col8	EQU   $190
col16   EQU   $1A0
