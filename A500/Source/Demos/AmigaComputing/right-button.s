 section amigacomputing,code_c
 opt c-,o+,o3-



go:

 bset #1,$bfe001

 lea GFXLIB,a1
 MOVEQ #0,D0
 MOVE.L 4.w,a6
 JSR -$228(a6)		; OpenLibrary
 TST.L D0
 BEQ ERROR
 MOVE.L D0,GFXBASE

 bsr mt_init
 
; move.l 4.w,a6
; jsr -132(a6)

 move.l #showplane2,d0
 move.w d0,eq0l
 swap d0
 move.w d0,eq0h 
 move.l #amigalogo,d0
 move.w d0,pl0l
 swap d0
 move.w d0,pl0h
 swap d0
 add.l #3840,d0
 move.w d0,pl1l
 swap d0
 move.w d0,pl1h
 swap d0
 add.l #3840,d0
 move.w d0,pl2l
 swap d0
 move.w d0,pl2h
 swap d0
 add.l #3840,d0
 move.w d0,pl3l
 swap d0
 move.w d0,pl3h

 SWAP D0
 ADD.L #3840,D0
 MOVE.l d0,a0
 lea cols,a1
 moveq #15,d1
 move.w #$180,d2
tt 
 move.w d2,(a1)+
 addq.w #$2,d2
 move.w (a0)+,(a1)+
 dbra d1,tt
 
 


 MOVE.L GFXBASE,A6
 ADD.L #$32,A6
 MOVE.W #$80,$dff096
 MOVE.L (A6),OLDCOPPER
 MOVE.L #NEWCOPPER,(A6)
 MOVE.W #$8080,$dff096

 move.w #$8010,$dff09a
 move.l $6c.w,old
 move.l  #new,$6c.w

 move.w #%001111000010,$dff098		; mask for collision
; 	  ||||||||||||			
;	  ||||||000010 = Colour 2	(red)
;	  001111       = Bitplanes 1 to 4 enabled


WAIT: btst #6,$BFE001
 Bne.s wait

 move.l old,$6c.w

 
 MOVE.L GFXBASE,A6
 ADD.L #$32,A6

 MOVE.W #$0080,$dff096
 MOVE.L OLDCOPPER,(A6)
 MOVE.W #$8080,$dff096
 
 
 
ERROR: 

; move.l 4.w,a6
; jsr -138(a6)

 moveq #0,d0
 move.w #$f,$dff096
 clr.w $dff0a8
 clr.w $dff0b8
 clr.w $dff0c8
 clr.w $dff0d8
 RTS








new:

 movem.l d0-d7/a0-a6,-(sp)
 and #$10,$dff01e        
 beq out
 move.w #$10,$dff09c

; interupt routine goes in here

 bsr mt_music
 btst #7,$bfe001
 beq out
 bsr blitclear
 bsr equalizer2

 cmp.b #0,counter
 bne.s notzero

 move.w $dff00e,d0

 move.b #1,counter
 move.w #%001111000100,$dff098		; mask for collision next time
; 	  ||||||||||||			
;	  ||||||000100 = Colour 4	(red)
;	  001111       = Bitplanes 1 to 4 enabled


 cmp.w #$8023,d0 	(value for a hit)
 bne out
 btst #2,$dff016	; is the right button pressed?
 bne out
 ; now restart song....


 clr.l	mt_partnrplay
 clr.l	mt_partnote
 clr.l	mt_partpoint


 bra.s out



notzero:

 cmp.b #1,counter
 bne.s notone

 move.w $dff00e,d0

 move.b #2,counter
 move.w #%001111000011,$dff098		

 cmp.w #$8023,d0 	(value for a hit)
 bne.s out
 btst #2,$dff016	; is the right button pressed?
 bne.s out

 ; now change cols
 
 lea coppercols+6,a0
 moveq #45,d0
copchglp
 eor.w #$fff,(a0)
 addq.l #8,a0
 dbra d0,copchglp



 bra.s out



notone: 
 
 move.w $dff00e,d0

 move.b #0,counter
 move.w #%001111000010,$dff098

 cmp.w #$8023,d0 	(value for a hit)
 bne.s out
 btst #2,$dff016	; is the right button pressed?
 bne.s out
 ; now toggle filter
 bchg #1,$bfe001



out: movem.l (sp)+,d0-d7/a0-a6


 dc.w $4ef9
old: dc.l 0

counter dc.w 0

OLDCOPPER: DC.L 0
NEWCOPPER:
 dc.w $100,0,$180,0,$4309,$fffe
 dc.w $100,$1200,$102,$0,$104,%100100,$108,0,$10a,0
 dc.w $92,$38,$94,$d0,$8e,$2c81,$90,$2cc1

	dc.w $e0
eq0h: dc.w 0,$e2
eq0l: dc.w 0,$182,0

coppercols
 dc.w $4409,$fffe,$182,$f00
 dc.w $4609,$fffe,$182,$f10
 dc.w $4809,$fffe,$182,$f20
 dc.w $4a09,$fffe,$182,$f30
 dc.w $4c09,$fffe,$182,$f40
 dc.w $4e09,$fffe,$182,$f50
 dc.w $5009,$fffe,$182,$f60
 dc.w $5209,$fffe,$182,$f70
 dc.w $5409,$fffe,$182,$f80
 dc.w $5609,$fffe,$182,$f90
 dc.w $5809,$fffe,$182,$fa0
 dc.w $5a09,$fffe,$182,$fb0
 dc.w $5c09,$fffe,$182,$fc0
 dc.w $5e09,$fffe,$182,$fd0
 dc.w $6009,$fffe,$182,$fe0
 dc.w $6209,$fffe,$182,$ff0
 dc.w $6409,$fffe,$182,$ef0
 dc.w $6609,$fffe,$182,$df0
 dc.w $6809,$fffe,$182,$cf0
 dc.w $6a09,$fffe,$182,$bf0
 dc.w $6c09,$fffe,$182,$af0
 dc.w $6e09,$fffe,$182,$9f0
 dc.w $7009,$fffe,$182,$8f0
 dc.w $7209,$fffe,$182,$7f0
 dc.w $7409,$fffe,$182,$6f0
 dc.w $7609,$fffe,$182,$5f0
 dc.w $7809,$fffe,$182,$4f0
 dc.w $7a09,$fffe,$182,$3f0
 dc.w $7c09,$fffe,$182,$2f0
 dc.w $7e09,$fffe,$182,$1f0
 dc.w $8009,$fffe,$182,$0f0
 dc.w $8209,$fffe,$182,$f1
 dc.w $8409,$fffe,$182,$f2
 dc.w $8609,$fffe,$182,$f3
 dc.w $8809,$fffe,$182,$f4
 dc.w $8a09,$fffe,$182,$f5
 dc.w $8c09,$fffe,$182,$f6
 dc.w $8e09,$fffe,$182,$f7
 dc.w $9009,$fffe,$182,$f8
 dc.w $9209,$fffe,$182,$f9
 dc.w $9409,$fffe,$182,$fa
 dc.w $9609,$fffe,$182,$fb
 dc.w $9809,$fffe,$182,$fc
 dc.w $9a09,$fffe,$182,$fd
 dc.w $9c09,$fffe,$182,$fe
 dc.w $9e09,$fffe,$182,$ff
	dc.w $9f09,$fffe
	dc.w $100,$4200,$e0
pl0h: dc.w	0,$e2
pl0l: dc.w	0,$e4
pl1h: dc.w	0,$e6
pl1l: dc.w	0,$e8
pl2h: dc.w	0,$ea
pl2l: dc.w	0,$ec
pl3h: dc.w	0,$ee
pl3l: dc.w	0

COLS DCB.W 32,0

 dc.w $9c,$8010
  dc.w $ff09,$fffe,$100,0

  DC.W $FFFF,$FFFE		; End copper

gfxlib: dc.b "graphics.library",0 ; Yeuch! Libraries!!!!!
 EVEN
gfxbase: dc.l 0

amigalogo: incbin graphics_data/amigalogo4



upbig equ 25
upsmall equ 12
downvalue equ 1
barht equ 80
winheight equ 165

***********SPECTRUM ANALYZER (EQUALIQUIZER) ROUTINE**************
***********========================================**************


; yes, this was in the first demo!

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
	
	lea eqtab(pc),a1 	; table
	lea showplane2,a2	; picture
mainlp	moveq #0,d1
	move.b (a1),d1		; get byte
	move.l d1,d4		;
	neg.w d1
	add.w #barht/2+6,d1		; subtract from bar height
	mulu #80,d1		; multiply by 80
	
	
fillbar	
	move.b #%11111110,0(a2,d1)	; splat on equalizer
	add.w #80,d1
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
	move.w #20+64*winheight,$dff058	



	rts
	
eq1 dc.b 0
eq2 dc.b 0
eq3 dc.b 0
eq4 dc.b 0
eq1p dc.w 381
eq2p dc.w 381
eq3p dc.w 381
eq4p dc.w 381
eqtab dcb.w 40



mt_init:lea	mt_data,a0
	add.l	#$03b8,a0
	moveq	#$7f,d0
	moveq	#0,d1
mt_init1:
	move.l	d1,d2
	subq.w	#1,d0
mt_init2:
	move.b	(a0)+,d1
	cmp.b	d2,d1
	bgt.s	mt_init1
	dbf	d0,mt_init2
	addq.b	#1,d2

mt_init3:
	lea	mt_data,a0
	lea	mt_sample1(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$438,d2
	add.l	a0,d2
	moveq	#$1e,d0
mt_init4:
	move.l	d2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,d2
	add.l	#$1e,a0
	dbf	d0,mt_init4

	lea	mt_sample1(PC),a0
	moveq	#0,d0
mt_clear:
	move.l	(a0,d0.w),a1
	clr.l	(a1)
	addq.w	#4,d0
	cmp.w	#$7c,d0
	bne.s	mt_clear

	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.l	mt_partnrplay
	clr.l	mt_partnote
	clr.l	mt_partpoint

	move.b	mt_data+$3b6,mt_maxpart+1
	rts

; call 'mt_end' to switch the sound off

mt_end:	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

; the playroutine - call this every frame

mt_music:
	addq.w	#1,mt_counter
mt_cool:cmp.w	#6,mt_counter
	bne.s	mt_notsix
	clr.w	mt_counter
	bra	mt_rout2

mt_notsix:
	lea	mt_aud1temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp1
	lea	$dff0a0,a5		
	bsr.s	mt_arprout
mt_arp1:lea	mt_aud2temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp2
	lea	$dff0b0,a5
	bsr.s	mt_arprout
mt_arp2:lea	mt_aud3temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp3
	lea	$dff0c0,a5
	bsr.s	mt_arprout
mt_arp3:lea	mt_aud4temp(PC),a6
	tst.b	3(a6)
	beq.s	mt_arp4
	lea	$dff0d0,a5
	bra.s	mt_arprout
mt_arp4:rts

mt_arprout:
	move.b	2(a6),d0
	and.b	#$0f,d0
	tst.b	d0
	beq	mt_arpegrt
	cmp.b	#$01,d0
	beq.s	mt_portup
	cmp.b	#$02,d0
	beq.s	mt_portdwn
	cmp.b	#$0a,d0
	beq.s	mt_volslide
	rts

mt_portup:
	moveq	#0,d0
	move.b	3(a6),d0
	sub.w	d0,22(a6)
	cmp.w	#$71,22(a6)
	bpl.s	mt_ok1
	move.w	#$71,22(a6)
mt_ok1:	move.w	22(a6),6(a5)
	rts

mt_portdwn:
	moveq	#0,d0
	move.b	3(a6),d0
	add.w	d0,22(a6)
	cmp.w	#$538,22(a6)
	bmi.s	mt_ok2
	move.w	#$538,22(a6)
mt_ok2:	move.w	22(a6),6(a5)
	rts

mt_volslide:
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_voldwn
	add.w	d0,18(a6)
	cmp.w	#64,18(a6)
	bmi.s	mt_ok3
	move.w	#64,18(a6)
mt_ok3:	move.w	18(a6),8(a5)
	rts
mt_voldwn:
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	sub.w	d0,18(a6)
	bpl.s	mt_ok4
	clr.w	18(a6)
mt_ok4:	move.w	18(a6),8(a5)
	rts

mt_arpegrt:
	move.w	mt_counter(PC),d0
	cmp.w	#1,d0
	beq.s	mt_loop2
	cmp.w	#2,d0
	beq.s	mt_loop3
	cmp.w	#3,d0
	beq.s	mt_loop4
	cmp.w	#4,d0
	beq.s	mt_loop2
	cmp.w	#5,d0
	beq.s	mt_loop3
	rts

mt_loop2:
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_cont
mt_loop3:
	moveq	#$00,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	bra.s	mt_cont
mt_loop4:
	move.w	16(a6),d2
	bra.s	mt_endpart
mt_cont:
	add.w	d0,d0
	moveq	#0,d1
	move.w	16(a6),d1
	and.w	#$fff,d1
	lea	mt_arpeggio(PC),a0
mt_loop5:
	move.w	(a0,d0),d2
	cmp.w	(a0),d1
	beq.s	mt_endpart
	addq.l	#2,a0
	bra.s	mt_loop5
mt_endpart:
	move.w	d2,6(a5)
	rts

mt_rout2:
	lea	mt_data,a0
	move.l	a0,a3
	add.l	#$0c,a3
	move.l	a0,a2
	add.l	#$3b8,a2
	add.l	#$43c,a0
	move.l	mt_partnrplay(PC),d0
	moveq	#0,d1
	move.b	(a2,d0),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.l	mt_partnote(PC),d1
	move.l	d1,mt_partpoint
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_aud1temp(PC),a6
	bsr	mt_playit
	lea	$dff0b0,a5
	lea	mt_aud2temp(PC),a6
	bsr	mt_playit
	lea	$dff0c0,a5
	lea	mt_aud3temp(PC),a6
	bsr	mt_playit
	lea	$dff0d0,a5
	lea	mt_aud4temp(PC),a6
	bsr	mt_playit
	move.w	#$01f4,d0
mt_rls:	dbf	d0,mt_rls

	move.w	#$8000,d0
	or.w	mt_dmacon,d0
	move.w	d0,$dff096

	lea	mt_aud4temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice3
	move.l	10(a6),$dff0d0

	move.b #$1c,eq4
	move.w (a6),eq4p

	move.w	#1,$dff0d4
mt_voice3:
	lea	mt_aud3temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice2
	move.l	10(a6),$dff0c0

	move.b #$1c,eq3
	move.w (a6),eq3p

	move.w	#1,$dff0c4
mt_voice2:
	lea	mt_aud2temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice1
	move.l	10(a6),$dff0b0

	move.b #$1c,eq2
	move.w (a6),eq2p

	move.w	#1,$dff0b4
mt_voice1:
	lea	mt_aud1temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice0
	move.l	10(a6),$dff0a0

	move.b #$1c,eq1
	move.w (a6),eq1p

	move.w	#1,$dff0a4
mt_voice0:
	move.l	mt_partnote(PC),d0
	add.l	#$10,d0
	move.l	d0,mt_partnote
	cmp.l	#$400,d0
	bne.s	mt_stop
mt_higher:
	clr.l	mt_partnote
	addq.l	#1,mt_partnrplay
	moveq	#0,d0
	move.w	mt_maxpart(PC),d0
	move.l	mt_partnrplay(PC),d1
	cmp.l	d0,d1
	bne.s	mt_stop
	clr.l	mt_partnrplay
;	st	Pflag
mt_stop:tst.w	mt_status
	beq.s	mt_stop2
	clr.w	mt_status
	bra.s	mt_higher
mt_stop2:
	rts

mt_playit:
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2

	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	mt_nosamplechange

	moveq	#0,d3
	lea	mt_samples(PC),a1
	move.l	d2,d4
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2),4(a6)
	move.w	(a3,d4.l),8(a6)
	move.w	2(a3,d4.l),18(a6)
	move.w	4(a3,d4.l),d3
	tst.w	d3
	beq.s	mt_displace
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,4(a6)
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),8(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
	bra.s	mt_nosamplechange

mt_displace:
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
mt_nosamplechange:
	move.w	(a6),d0
	and.w	#$fff,d0
	tst.w	d0
	beq.s	mt_retrout
	move.w	(a6),16(a6)
	move.w	20(a6),$dff096
	move.l	4(a6),(a5)
	move.w	8(a6),4(a5)
	move.w	(a6),d0
	and.w	#$fff,d0
	move.w	d0,6(a5)
	move.w	20(a6),d0
	or.w	d0,mt_dmacon

mt_retrout:
	tst.w	(a6)
	beq.s	mt_nonewper
	move.w	(a6),22(a6)

mt_nonewper:
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#$0b,d0
	beq.s	mt_posjmp
	cmp.b	#$0c,d0
	beq.s	mt_setvol
	cmp.b	#$0d,d0
	beq.s	mt_break
	cmp.b	#$0e,d0
	beq.s	mt_setfil
	cmp.b	#$0f,d0
	beq.s	mt_setspeed
	rts

mt_posjmp:
	not.w	mt_status
	moveq	#0,d0
	move.b	3(a6),d0
	subq.b	#1,d0
	move.l	d0,mt_partnrplay
	rts

mt_setvol:
	move.b	3(a6),8(a5)
	rts

mt_break:
	not.w	mt_status
	rts

mt_setfil:
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#1,d0
	rol.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

mt_setspeed:
	move.b	3(a6),d0
	and.b	#$0f,d0
	beq.s	mt_back
	clr.w	mt_counter
	move.b	d0,mt_cool+3
mt_back:rts

mt_aud1temp:
	dcb.w	10,0
	dc.w	1
	dcb.w	2,0
mt_aud2temp:
	dcb.w	10,0
	dc.w	2
	dcb.w	2,0
mt_aud3temp:
	dcb.w	10,0
	dc.w	4
	dcb.w	2,0
mt_aud4temp:
	dcb.w	10,0
	dc.w	8
	dcb.w	2,0

mt_partnote:	dc.l	0
mt_partnrplay:	dc.l	0
mt_counter:	dc.w	0
mt_partpoint:	dc.l	0
mt_samples:	dc.l	0
mt_sample1:	dcb.l	31,0
mt_maxpart:	dc.w	0
mt_dmacon:	dc.w	0
mt_status:	dc.w	0

mt_arpeggio:
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c
	dc.w $023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d
	dc.w $0168,$0153,$0140,$012e,$011d,$010d,$00fe,$00f0
	dc.w $00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097
	dc.w $008f,$0087,$007f,$0078,$0071,$0000,$0000,$0000


notetable:	dc.w	856,808,762,720,678,640,604,570
		dc.w	538,508,480,453,428,404,381,360
		dc.w	339,320,302,285,269,254,240,226  
		dc.w	214,202,190,180,170,160,151,143
		dc.w	135,127,120,113,000




mt_data:	incbin	modules/MOD.aussiefoot





showplane2 dcb.b 8000,0

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
