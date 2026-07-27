 section scx,code_c
 opt c-,o+


max equ 2


go:

 jsr start_muzak
 
 
 move.l #sprite0,d0
 move.w d0,sp0l
 swap d0
 move.w d0,sp0h
 
 move.l 4.w,a6
 jsr -132(a6)

 lea GFXLIB,a1
 MOVEQ #0,D0
 MOVE.L 4.w,a6
 JSR -$228(a6) 		; OpenLibrary
 TST D0
 BEQ ERROR
 MOVE.L D0,GFXBASE
 
 
 
 move.l #amigalogo,d0
 move.w d0,pl0l
 swap d0
 move.w d0,pl0h
 swap d0
 add.l #10240,d0
 move.w d0,pl2l
 swap d0
 move.w d0,pl2h
 swap d0
 add.l #10240,d0
 move.w d0,pl4l
 swap d0
 move.w d0,pl4h
 
 
 move.l #scrollplane,d0
 move.w d0,pl1l
 swap d0
 move.w d0,pl1h
 
 move.l #showplane,d0
 move.w d0,zl6l
 swap d0
 move.w d0,zl6h
 
 
 move.l #mountains+40*8,d0
 move.w d0,p2l0l
 swap d0
 move.w d0,p2l0h
 swap d0
 add.l #5200,d0
 move.w d0,p2l1l
 swap d0
 move.w d0,p2l1h
 swap d0
 add.l #5200,d0
 move.w d0,p2l2l
 swap d0
 move.w d0,p2l2h
 
 swap d0
 add.l #5200,d0
 move.w d0,p2l3l
 swap d0
 move.w d0,p2l3h
 swap d0
 add.l #5200,d0
 move.w d0,p2l4l
 swap d0
 move.w d0,p2l4h
 swap d0
 add.l #5200-40*8,d0
 move.l d0,a0
 lea cols2,a1
 lea cols3,a2
 moveq #31,d0
 move.w #$180,D2
ffl
 move.w d2,(a1)+
 move.w d2,(a2)+
 addq.w #2,d2
 move.w (a0)+,d3
 move.w d3,(a1)+
 lsr.w d3
 and.w #%0000011101110111,d3
 move.w d3,(a2)+
 dbra d0,ffl
 
 
 
 
 move.l #blankplane,d0
 move.w d0,pl3l
 swap d0
 move.w d0,pl3h
 
 

 MOVE.L GFXBASE,A6
 ADD.L #$32,A6
 MOVE.W #$80,$dff096
 MOVE.L (A6),OLDCOPPER
 MOVE.L #NEWCOPPER,(A6)
 MOVE.W #$8080,$dff096

 move.w #$8010,$dff09a
 move.l $6c.w,old
 move.l  #new,$6c.w

WAIT: ANDI.B #$40,$BFE001
 Bne.s wait

 move.l old,$6c.w

 
 MOVE.L GFXBASE,A6
 ADD.L #$32,A6

 MOVE.W #$0080,$dff096
 MOVE.L OLDCOPPER,(A6)
 MOVE.W #$8080,$dff096
 
 
ERROR:

 move.l 4.w,a6
 jsr -138(a6)

 moveq #0,d0
 move.w #$f,$dff096
 move.w #$0,$dff0a8
 move.w #$0,$dff0b8
 move.w #$0,$dff0c8
 move.w #$0,$dff0d8
 RTS

new: movem.l d0-d7/a0-a6,-(sp)
 and #$10,$dff01e        
 beq.s out
 move.w #$10,$dff09c

 jsr replay_muzak
 
 btst #2,$dff016
 beq.s out

 jsr scrolly

 subq.b #1,ctd
 bne.s out
 move.b #max,ctd

 bsr.s scrolltext
 bsr.s blittest
 
 subq.b #1,ct2
 bne.s out
 move.b #8,ct2
 
 bsr.s printline
 
; interupt routine goes in here
 
out: movem.l (sp)+,d0-d7/a0-a6
 dc.w $4ef9
old: dc.l 0

ctd dc.b 1,0
ct2 dc.b 1,0
	
blittest: btst #6,$dff002
	bne.s blittest
	rts

scrolltext:
 bsr.s blittest
 move.l #scrollplane,$dff054
 move.l #scrollplane+40,$dff050
 move.l #$ffffffff,$dff044
 clr.l $dff064
 move.w #%100111110000,$dff040
 clr.w $dff042
 move.w #%1011010010100,$dff058
 rts
 
 
printline
 move.l textptr,a0
 cmp.b #0,(a0)
 bne.s lineok
 move.l #text,textptr
 bra.s printline
lineok
 lea scrollplane+40*60,a1
 moveq #39,d1
.loop1
 moveq #0,d0			; clear d0 first
 move.b (a0)+,d0
 sub.b #32,d0			; space is 32 in ascii
 lsl.w #3,d0			; multiply by 8
 lea font(pc),a2		; and add to font start address
 add.l d0,a2	
 moveq #7,d2			; 8 bytes per character
 move.l a1,a3			; can scratch a3, not a1
.loop2
 move.b (a2)+,(a3)		; transfer byte
 add.l #40,a3			; point to next line
 dbra d2,.loop2
 addq.l #1,a1
 dbra d1,.loop1
 move.l a0,textptr 
 rts
 
 


textptr dc.l text

	      *0123456789012345678901234567890123456789* 
text	dc.b  "             AMIGA COMPUTING            "
	dc.b  "                                        "
	dc.b  "    Present another little demo.......  "
        dc.b  "                                        "
	dc.b  "                                        "
	dc.b  " Code by Jolyon Ralph of STATYX SOFTWARE"
	dc.b  "                                        "
	dc.b  "    Music by Kevin 'Savage' Collier     "
	dc.b  "                                        "
	dc.b  "     Mountain graphics by OZONE of      "
	dc.b  "           SHARE AND ENJOY              "          
	dc.b  "                                        "
	dc.b  "    Special thanks must go to TONY of   "
	dc.b  "                                        "
	dc.b  "          SABRE 16 COMPUTERS            "
	dc.b  "                                        "
	dc.b  " who saved the day by replacing my B2000"
	dc.b  "     in time to finish this demo.       "
	dc.b  "                                        "
	dc.b  "     So long and goodbye from me.       "
	dc.b  "                                        "
	dc.b  "                                        "
	dc.b  0

	even


*Spectrum font 8x8
* chars 32-126


font:	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$10,$10,$10,$10,$00,$10,$00
	dc.b	$00,$24,$24,$00,$00,$00,$00,$00
	dc.b	$00,$24,$7e,$24,$24,$7e,$24,$00
	dc.b	$00,$08,$3e,$28,$3e,$0a,$3e,$08
	dc.b	$00,$62,$64,$08,$10,$26,$46,$00
	dc.b	$00,$10,$28,$10,$2a,$44,$3a,$00
	dc.b	$00,$08,$10,$00,$00,$00,$00,$00
	dc.b	$04,$08,$08,$08,$08,$08,$04,$00
	dc.b	$00,$20,$10,$10,$10,$10,$20,$00
	dc.b	$00,$00,$14,$08,$3e,$08,$14,$00
	dc.b	$00,$00,$08,$08,$3e,$08,$08,$00
	dc.b	$00,$00,$00,$00,$00,$08,$08,$10
	dc.b	$00,$00,$00,$00,$3e,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$18,$18,$00
	dc.b	$00,$00,$02,$04,$08,$10,$20,$00
	dc.b	$00,$3c,$46,$4a,$52,$62,$3c,$00
	dc.b	$00,$18,$28,$08,$08,$08,$3e,$00
	dc.b	$00,$3c,$42,$02,$3c,$40,$7e,$00
	dc.b	$00,$3c,$42,$0c,$02,$42,$3c,$00
	dc.b	$00,$08,$18,$28,$48,$7e,$08,$00
	dc.b	$00,$7e,$40,$7c,$02,$42,$3c,$00
	dc.b	$00,$3c,$40,$7c,$42,$42,$3c,$00
	dc.b	$00,$7e,$02,$04,$08,$10,$10,$00
	dc.b	$00,$3c,$42,$3c,$42,$42,$3c,$00
	dc.b	$00,$3c,$42,$42,$3e,$02,$3c,$00
	dc.b	$00,$00,$10,$00,$00,$00,$10,$00
	dc.b	$00,$00,$10,$00,$00,$10,$10,$20
	dc.b	$00,$00,$04,$08,$10,$08,$04,$00
	dc.b	$00,$00,$00,$3e,$00,$3e,$00,$00
	dc.b	$00,$00,$10,$08,$04,$08,$10,$00
	dc.b	$00,$3c,$42,$04,$08,$00,$08,$00
	dc.b	$00,$3c,$4a,$56,$5e,$40,$3c,$00
	dc.b	$00,$3c,$42,$42,$7e,$42,$42,$00
	dc.b	$00,$7c,$42,$7c,$42,$42,$7c,$00
	dc.b	$00,$3c,$42,$40,$40,$42,$3c,$00
	dc.b	$00,$78,$44,$42,$42,$44,$78,$00
	dc.b	$00,$7e,$40,$7c,$40,$40,$7e,$00
	dc.b	$00,$7e,$40,$7c,$40,$40,$40,$00
	dc.b	$00,$3c,$42,$40,$4e,$42,$3c,$00
	dc.b	$00,$42,$42,$7e,$42,$42,$42,$00
	dc.b	$00,$3e,$08,$08,$08,$08,$3e,$00
	dc.b	$00,$02,$02,$02,$42,$42,$3c,$00
	dc.b	$00,$44,$48,$70,$48,$44,$42,$00
	dc.b	$00,$40,$40,$40,$40,$40,$7e,$00
	dc.b	$00,$42,$66,$5a,$42,$42,$42,$00
	dc.b	$00,$42,$62,$52,$4a,$46,$42,$00
	dc.b	$00,$3c,$42,$42,$42,$42,$3c,$00
	dc.b	$00,$7c,$42,$42,$7c,$40,$40,$00
	dc.b	$00,$3c,$42,$42,$52,$4a,$3c,$00
	dc.b	$00,$7c,$42,$42,$7c,$44,$42,$00
	dc.b	$00,$3c,$40,$3c,$02,$42,$3c,$00
	dc.b	$00,$fe,$10,$10,$10,$10,$10,$00
	dc.b	$00,$42,$42,$42,$42,$42,$3c,$00
	dc.b	$00,$42,$42,$42,$42,$24,$18,$00
	dc.b	$00,$42,$42,$42,$42,$5a,$24,$00
	dc.b	$00,$42,$24,$18,$18,$24,$42,$00
	dc.b	$00,$82,$44,$28,$10,$10,$10,$00
	dc.b	$00,$7e,$04,$08,$10,$20,$7e,$00
	dc.b	$00,$0e,$08,$08,$08,$08,$0e,$00
	dc.b	$00,$00,$40,$20,$10,$08,$04,$00
	dc.b	$00,$70,$10,$10,$10,$10,$70,$00
	dc.b	$00,$10,$38,$54,$10,$10,$10,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$ff
	dc.b	$00,$1c,$22,$78,$20,$20,$7e,$00
	dc.b	$00,$00,$38,$04,$3c,$44,$3c,$00
	dc.b	$00,$20,$20,$3c,$22,$22,$3c,$00
	dc.b	$00,$00,$1c,$20,$20,$20,$1c,$00
	dc.b	$00,$04,$04,$3c,$44,$44,$3c,$00
	dc.b	$00,$00,$38,$44,$78,$40,$3c,$00
	dc.b	$00,$0c,$10,$18,$10,$10,$10,$00
	dc.b	$00,$00,$3c,$44,$44,$3c,$04,$38
	dc.b	$00,$40,$40,$78,$44,$44,$44,$00
	dc.b	$00,$10,$00,$30,$10,$10,$38,$00
	dc.b	$00,$04,$00,$04,$04,$04,$24,$18
	dc.b	$00,$20,$28,$30,$30,$28,$24,$00
	dc.b	$00,$10,$10,$10,$10,$10,$0c,$00
	dc.b	$00,$00,$68,$54,$54,$54,$54,$00
	dc.b	$00,$00,$78,$44,$44,$44,$44,$00
	dc.b	$00,$00,$38,$44,$44,$44,$38,$00
	dc.b	$00,$00,$78,$44,$44,$78,$40,$40
	dc.b	$00,$00,$3c,$44,$44,$3c,$04,$06
	dc.b	$00,$00,$1c,$20,$20,$20,$20,$00
	dc.b	$00,$00,$38,$40,$38,$04,$78,$00
	dc.b	$00,$10,$38,$10,$10,$10,$0c,$00
	dc.b	$00,$00,$44,$44,$44,$44,$38,$00
	dc.b	$00,$00,$44,$44,$28,$28,$10,$00
	dc.b	$00,$00,$44,$54,$54,$54,$28,$00
	dc.b	$00,$00,$44,$28,$10,$28,$44,$00
	dc.b	$00,$00,$44,$44,$44,$3c,$04,$38
	dc.b	$00,$00,$7c,$08,$10,$20,$7c,$00
	dc.b	$00,$0e,$08,$30,$08,$08,$0e,$00
	dc.b	$00,$08,$08,$08,$08,$08,$08,$00
	dc.b	$00,$70,$10,$0c,$10,$10,$70,$00
	dc.b	$00,$14,$28,$00,$00,$00,$00,$00
	
	
	

OLDCOPPER: DC.L 0
NEWCOPPER:
 dc.w $100,$5600,$102,$0,$104,%1000000,$108,0,$10a,0
 dc.w $92,$38,$94,$d0,$8e,$2c81,$90,$2cc1,$e0
pl0h: dc.w	0,$e2
pl0l: dc.w	0,$e4
pl1h: dc.w	0,$e6
pl1l: dc.w	0,$e8
pl2h: dc.w	0,$ea
pl2l: dc.w	0,$ec
pl3h: dc.w	0,$ee
pl3l: dc.w	0,$f0
pl4h: dc.w	0,$f2
  
pl4l: dc.w	0,$120
SP0H DC.W 0,$122
SP0L DC.W 0,$180,$0,$182,$0,$184,$555,$186,$888
      dc.w 	$18c,$999,$18e,$777
      DC.W 	$190,$fff,$192,$111,$194,$fff,$196,$fff
      DC.W 	$1a8,$fff,$1aa,$fff,$1ac,$fff,$1ae,$fff
      DC.W 	$1b0,$fff,$1b2,$fff,$1b4,$fff,$1b6,$fff
      DC.W 	$1b8,$fff,$1ba,$fff,$1bc,$fff,$1be,$fff
    
    dc.w $2e09,$fffe,$192,$444
    dc.w $2f09,$fffe,$192,$666
  
  dc.w $3009,$fffe,$10a,-40,$192,$888
  dc.w $3109,$fffe,$10a,0,$192,$aaa
  
  
  dc.w $3209,$fffe,$10a,-40,$192,$ccc
  dc.w $3309,$fffe,$10a,0,$192,$fff
      

  dc.w $3409,$fffe,$10a,-40,$192,$ffe
  dc.w $3509,$fffe,$192,$ffd
  dc.w $3609,$fffe,$10a,0,$192,$ffc
      
  dc.w $3709,$fffe,$10a,-40,$192,$ffb
  dc.w $3809,$fffe,$192,$ffa
 
  dc.w $3909,$fffe,$10a,0,$192,$ff9
      
  dc.w $3a09,$fffe,$10a,-40,$192,$ff8
  dc.w $3b09,$fffe,$192,$fff,$192,$ff7
  dc.w $3c09,$fffe,$192,$ff6
 
  dc.w $3d09,$fffe,$10a,0,$192,$ff5
      
  dc.w $3e09,$fffe,$10a,-40,$192,$ff4
  dc.w $3f09,$fffe,$192,$ff3
  dc.w $4009,$fffe,$192,$ff2
 
  dc.w $4109,$fffe,$10a,0,$192,$ff1
  
  
  dc.w $4209,$fffe,$10a,-40,$192,$ff0
  dc.w $4309,$fffe,$192,$fe0
 
  dc.w $4409,$fffe,$10a,0,$192,$fd0
      

  dc.w $4509,$fffe,$10a,-40,$192,$fc0
  dc.w $4609,$fffe,$192,$fb0
  dc.w $4709,$fffe,$10a,0,$192,$fa0
      
  dc.w $4809,$fffe,$10a,-40,$192,$f90
  dc.w $4909,$fffe,$10a,0,$192,$f80
      
  dc.w $4a09,$fffe,$10a,-40,$192,$f70
  dc.w $4b09,$fffe,$10a,0,$192,$f60
  dc.w $4c09,$fffe,$192,$f50
  dc.w $4d09,$fffe,$192,$f40
  dc.w $4e09,$fffe,$192,$f30
  dc.w $4f09,$fffe,$192,$f20
      
  dc.w $5009,$fffe,$10a,-40,$192,$f10
  dc.w $5109,$fffe,$10a,0,$192,$f00
  
  
  dc.w $5209,$fffe,$10a,-40,$192,$f01
  dc.w $5309,$fffe,$10a,0,$192,$f02
      

  dc.w $5409,$fffe,$10a,-40,$192,$f03
  dc.w $5509,$fffe,$192,$f04

  dc.w $5609,$fffe,$10a,0,$192,$f05
      
  dc.w $5709,$fffe,$10a,-40,$192,$f06
  dc.w $5809,$fffe,$192,$f07
  dc.w $5909,$fffe,$10a,0,$192,$f08
      
  dc.w $5a09,$fffe,$10a,-40,$192,$f09
  dc.w $5b09,$fffe,$192,$f0a
  dc.w $5c09,$fffe,$192,$f0b
  dc.w $5d09,$fffe,$10a,0,$192,$f0c
      
  dc.w $5e09,$fffe,$10a,-40,$192,$f0d
  dc.w $5f09,$fffe,$192,$f0e
  dc.w $6009,$fffe,$192,$f0f
  dc.w $6109,$fffe,$10a,0,$192,$e0f
  
  
  dc.w $6209,$fffe,$10a,-40,$192,$d0f
  dc.w $6309,$fffe,$192,$c0f
  dc.w $6409,$fffe,$10a,0,$192,$a0f
       

  dc.w $6509,$fffe,$10a,-40,$192,$90f
  dc.w $6609,$fffe,$192,$80f
  
  dc.w $6709,$fffe,$10a,0,$192,$70f
      
  dc.w $6809,$fffe,$10a,-40,$192,$60f
  dc.w $6909,$fffe,$10a,0,$192,$50f
      
  dc.w $6a09,$fffe,$10a,-40,$192,$40f
  dc.w $6b09,$fffe,$10a,0,$192,$30f

 dc.w $8c09,$fffe,$192,$108
 dc.w $8d09,$fffe,$192,$6
 dc.w $8e09,$fffe,$192,$4
 
 dc.w $8f09,$fffe,$100,0
cols2 dcb.l 32
  
  dc.w $9009,$fffe,$100,$6200
  
   dc.w $e0
p2l0h: dc.w	0,$e2
p2l0l: dc.w	0,$e4
p2l1h: dc.w	0,$e6
p2l1l: dc.w	0,$e8
p2l2h: dc.w	0,$ea
p2l2l: dc.w	0,$ec
p2l3h: dc.w	0,$ee
p2l3l: dc.w	0,$f0
p2l4h: dc.w	0,$f2
p2l4l: dc.w 0,$f4
zl6h   dc.w 0,$f6
zl6l   dc.w 0
      
 dc.w $ff09,$fffe,$108,-120,$10a,-120
cols3 dcb.l 32
 
 dc.w $2b09,$fffe
 dc.w $9c,$8010,$ffff,$fffe		; End copper

gfxlib: dc.b "graphics.library",0	; Yeuch! Libraries!!!!!
	even
gfxbase: dc.l 0

amigalogo: incbin graphics_data/amigalogo2

scrollplane: dcb.b 8000,0

blankplane: dcb.b 10240,0

mountains: incbin graphics_data/mountains

sinscroll:
; first blit clear the scrolly

	lea showplane+35*40,a0		; visible bitplane
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
	lea scplane2,a0
	lea showplane+35*40-2,a1

sloop3:

	bsr getsinval

blitready2
	btst #6,$dff002
	bne.s blitready2

	move.l a0,$dff050
	move.l a2,$dff054
	move.l #$f000f000,$dff044
	move.w #40,$dff064
	move.w #38,$dff066
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
	move.w #38,$dff066
	move.w #38,$dff062
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
	move.w #38,$dff066
	move.w #38,$dff062
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
	move.w #38,$dff066
	move.w #38,$dff062
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


	mulu #20,d1

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
	move.l #scplane2,a0
	move.l #scplane2+2,a1
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
	beq.s mfc
	move.b d0,countdown
iuo:	rts
	

countdown:
	dc.b 4,0


sinpt: 	dc.l sintabend		


 	dc.b 255
sintab:
	dc.b $3C,$3F,$42,$46,$49,$4C,$50,$53,$56,$59
	dc.b $5C,$5F,$61,$64,$67,$6B,$6F
	dc.b $72,$75,$76
	dc.b $77,$75,$72,$6F,$6B
	dc.b $67,$64,$61,$5F,$5C,$59,$56,$53,$50
	dc.b $4C,$49,$46,$42,$3F,$3C,$38,$35,$31,$2E
	dc.b $2B,$27,$24,$21,$1E,$1B,$18,$16,$13,$10
	dc.b $E,$C,$A,$8,$6,$5,$4,$2,$1,$1
	dc.b $0,$0,$0,$0,$0,$0,$1,$1,$2,$4
	dc.b $5,$6,$8,$A,$C,$E,$10,$13,$16,$18
	dc.b $1B,$1E,$21,$24,$27,$2B,$2E,$31,$35

sintabend:
 dc.b $38,255


pause: 	dc.b 0
 	even


mfc:	move.b #4,countdown
	clr.w scplane2+40
	clr.w scplane2+82
	move.l #scplane2+124,a1
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
	move.l #fnt,a0
	mulu #640,d1
	add.l d0,d0
	add.l d0,a0
	add.l d1,a0

	rts



SPRITE0 DC.W 0,0


mesptr: dc.l message
message:
      ;12345678901234567890
 dc.b "HOLY ZARQUON SINGING FISH! "
 dc.b " IT'S AMIGA COMPUTING DEMO NUMBER TWO!!!!    LOOK ABOVE FOR THE CREDITS, "
 DC.B " SPECIAL MESSAGES COMING UP.........   HI TO RUSS, DEL, JIM, KEVIN, RICHARD, "
 DC.B "JOBY, ADAM, TIM AND EVERYONE ELSE.     "
 dc.b " NOTE - THIS SCROLLY USES THE EXTRA HALF BRITE MODE, IF YOU HAVE AN OLD "
 DC.B "AMIGA 1000 (PRE-RELEASE MODEL) YOU WILL NOT BE ABLE TO SEE THIS SCROLLER, "
 DC.B "SO THERE!   FOR THE 99.9999 PERCENT OF YOU WHO CAN READ IT, COUNT YOURSELVES LUCKY. "
 DC.B "    BYE BYE!!!!   SEE YOU NEXT DEMO. "
 dc.b 255
	even

showplane: 	ds.b 6000
scplane2: 	ds.b 2500
fnt:		incbin graphics_data/sinefont2




*** END OF MY CODE ***


** THIS IS THE PLAY ROUTINE FOR THE MUSIC - WRITTEN BY TIP OF TNM **

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
	lea	voi1(pc),a4
	rts
next1:	cmp.l	#datach1,a6
	bne.s	next2
	lea	voi2(pc),a4
	rts
next2:	cmp.l	#datach2,a6
	bne.s	next3
	lea	voi3(pc),a4
	rts
next3:	lea	voi4(pc),a4
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
data:		incbin	modules/mod.timdemo





;EQUATES for HARDWARE REGISTERS


; NOTE: For more information about these hardware registers, read
; either the 'Amiga Hardware Reference Manual' by Addison Wesley or
; the 'Amiga System Programmers Guide' by Abacus, both of which
; document them fully.

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
