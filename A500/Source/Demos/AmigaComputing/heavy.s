****************************************************
*         THE THIRD AMIGA COMPUTING DEMO           *
* Written by Jolyon Ralph, (c)1989 Amiga Computing *                                   *
*       Assembled with HISOFT DEVPAC v2.08         *
****************************************************      



 section me,code_c
 opt c-,o+

nlines equ 1142-1064
comp equ $ff0
go:

; bra copwobble
;  bra getline

 move.w #200,d6
flp
 move.w d6,-(sp)
 bsr copscroll
 move.w (sp)+,d6
 dbf d6,flp



 jsr mt_init

 bset #1,$bfe001		; kill the filter
 lea gfxlib,a1
 moveq #0,d0
 move.l 4.w,a6
 jsr -$228(a6) ; OpenLibrary
 tst.l d0
 beq error
 move.l d0,gfxbase
 move.l d0,A6
 move.l 38(A6),oldcopper
 

 

 jsr spritemaker

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




 move.l #scrollpath+40*15,d0
 move.w d0,pt0l
 swap d0
 move.w d0,pt0h
 swap d0
 add.l #7880,d0
 move.w d0,pt2l
 swap d0
 move.w d0,pt2h
 swap d0
 add.l #7880,d0
 move.w d0,pt4l
 swap d0
 move.w d0,pt4h

 move.l #scrollplane,d0
 move.w d0,pt1l
 swap d0
 move.w d0,pt1h
 swap d0
 add.l #8000,d0
 move.w d0,pt3l
 swap d0
 move.w d0,pt3h
 swap d0
 add.l #8000,d0
 move.w d0,pt5l
 swap d0
 move.w d0,pt5h
 
 move.l #amigalogo,d0
 move.w d0,pl0l
 swap d0
 move.w d0,pl0h
 swap d0
 add.l #3680,d0
 move.w d0,pl1l
 swap d0
 move.w d0,pl1h
 swap d0
 add.l #3680,d0
 move.w d0,pl2l
 swap d0
 move.w d0,pl2h
 swap d0
 add.l #3680,d0
 move.w d0,pl3l
 swap d0
 move.w d0,pl3h
 swap d0
 add.l #3680,d0
 move.l d0,a0
 lea colregs,a1
 moveq #15,d0
 move.w #$180,d1
colreglp
 move.w d1,(a1)+
 addq.w #2,d1
 move.w (a0)+,(a1)+
 dbf d0,colreglp
 
 
 
 

 move.w #$80,$dff096
 move.l #newcopper,$dff080
 move.w #$8080,$dff096

 move.w #$8010,$dff09a
 move.l $6c.w,old
 move.l  #new,$6c.w

WAIT: btst #6,$bfe001
 bne.s wait

 move.l old,$6c.w

 

 move.w #$0080,$dff096
 move.l OLDCOPPER,$dff080
 move.w #$8080,$dff096
 
 
ERROR: clr.l d0
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

; interupt routine goes in here
 
 
 jsr mt_music

 btst #7,$bfe001
 beq.s out
  
 moveq #29,d0
 move.l #sprite4,a1
s4ud:
 move.b 1(a1),d1
 addq.b #3,d1
 move.b d1,1(a1)
 add.l #24,a1
 dbf d0,s4ud
 
 
 moveq #44,d0
 move.l #sprite5,a1
s5ud:
 move.b 1(a1),d1
 addq.b #2,d1
 move.b d1,1(a1)
 add.l #16,a1
 dbf d0,s5ud

 moveq #59,d0
 move.l #sprite6,a1
s6ud:
 move.b 1(a1),d1
 addq.b #1,d1
 move.b d1,1(a1)
 add.l #12,a1
 dbf d0,s6ud
 
 
subout1:

 bsr.s copscroll
 bsr copwobble
 bsr blitshift
 bsr scroll2
out: movem.l (sp)+,d0-d7/a0-a6
 dc.w $4ef9
old: dc.l 0

;2c09  fffe  0182 000f 0184 0f00 0186 000f 0188 0f00 018a 000f 018c 0f00 018e 000f
; 0 1   2 3   4 5  6 7  8 9 1011 1213 1415 1617 1819 2021 2223 2425 2627 2829 3031 
;3233  3435  3637 3839 4041 4243 4445 4647 4849 5051 5253 5455 5657 5859 6061 6263

copscroll
 lea scrollclist,a0
 moveq #99,d0
lp1: move.w 38(a0),6(a0)
 move.w 42(a0),10(a0)
 move.w 46(a0),14(a0)
 move.w 50(a0),18(a0)
 move.w 54(a0),22(a0)
 move.w 58(a0),26(a0)
 move.w 62(a0),30(a0)
 add.l #32,a0
 dbf d0,lp1

 move.w ov,d5

 move.w #comp,d4
 eor.w d5,d4

 move.w d5,ov

 cmp.b #4,ctdn
 bne.s toast
 bsr getline
toast
 subq.b #1,ctdn
 bne.s rped 
rr


 move.l ctptr,a3
 move.w (a3)+,ov
 bne.s rpok
 move.l #coltab,ctptr
 bra.s rr
rpok
 bchg #0,swap
 bne.s ffgh
 eor.w #comp,ov
ffgh

 move.l a3,ctptr
 move.b #4,ctdn

rped
 move.w d5,6(a0)
 move.w d4,10(a0)
 move.w d5,14(a0)
 move.w d4,18(a0)
 move.w d5,22(a0)
 move.w d4,26(a0)
 move.w d5,30(a0)

; get next line of scroll

 

 
 


 btst #7,charbyte
 beq.s .next1
 move.w twod,6(a0)
.next1
 btst #6,charbyte
 beq.s .next2
 move.w twod,10(a0)
.next2
 btst #5,charbyte
 beq.s .next3
 move.w twod,14(a0)
.next3
 btst #4,charbyte
 beq.s .next4
 move.w twod,18(a0)
.next4
 btst #3,charbyte
 beq.s .next5
 move.w twod,22(a0)
.next5
 btst #2,charbyte
 beq.s .next6
 move.w twod,26(a0)
.next6
 btst #1,charbyte
 beq.s .next7
 move.w twod,30(a0)
.next7

; eor.w #$f00,twod

 rts


getline:

 addq.w #$2,twod
 subq.b #1,charctd
 beq.s needachar
 move.l charaddr,a5
 move.b (a5)+,charbyte
 move.l a5,charaddr
 rts
needachar
 move.w #$110,twod
 moveq #0,d2			; faster than clr.l d2
 move.l scrollptr,a5
 move.b (a5)+,d2
 bne.s notfin
 move.l #scroller,scrollptr
 bra.s needachar
notfin
 move.l a5,scrollptr
 sub.b #32,d2
 mulu #8,d2
 lea fontdata,a5
 add.l d2,a5
 move.l a5,charaddr
 move.b #0,charbyte
 move.b #8,charctd
 rts



copwobble
 lea woblogoclist,a0
 moveq #nlines,d0
cwloop 
 move.b 19(a0),7(a0)
 add.l #12,a0
 dbf d0,cwloop
sphagettiloop
 move.l wobptr,a1
 move.b (a1)+,d0
 cmp.b #$fe,d0
 bne.s valokfor
 move.l #woblist,wobptr
 bra.s sphagettiloop
valokfor
 move.l a1,wobptr
 move.b d0,7(a0)
 rts

 


 

gfxlib: dc.b "graphics.library",0 ; Yeuch! Libraries!!!!!
 EVEN
gfxbase: dc.l 0





spritemaker:
 move.l #sprite4,a0
 moveq #29,d0
 move.l #$30003500,d1
sp4lp:
 move.l d1,(a0)+
 move.l #$8700,(a0)+
 move.l #$100ef80,(a0)+
 move.l #$7fc0,(a0)+
 move.l #$1800ee00,(a0)+
 move.l #$8700,(a0)+
 add.l #$06000600,d1
 swap d1
 move.b $dff007,d2
 eor.b d2,d1
 swap d1
 
 move.l #2000,d3
 lcap:
 
 move.w $dff006,$dff180
 dbf d3,lcap
 
 dbf d0,sp4lp
 
 move.l #sprite5,a0
 moveq #44,d0
 move.l #$30003300,d1
sp5lp:
 move.l d1,(a0)+
 move.l #$8009000,(a0)+
 move.l #$7c00,(a0)+
 move.l #$9800,(a0)+
 
 
 add.l #$04000400,d1
 swap d1
 move.b $dff007,d2
 eor.b d2,d1
 swap d1
 move.l #2000,d3
 lcap2: 
 move.w $dff006,$dff180
 dbf d3,lcap2
 
 
 dbf d0,sp5lp

; dc.w $1000,$A000,$0000,$7800


 
 move.l #sprite6,a0
 moveq #59,d0
 move.l #$30003200,d1
sp6lp:
 move.l d1,(a0)+
 move.l #$1000a000,(a0)+
 move.l #$7800,(a0)+

 
 
 add.l #$03000300,d1
 swap d1
 move.b $dff007,d2
 eor.b d2,d1
 swap d1
 move.l #2000,d3
 lcap3:
 
 move.w $dff006,$dff180
 dbf d3,lcap3
 dbf d0,sp6lp

 rts


charprint:
; called with d0 containing ascii code
 lea bigfontdata,a0
 sub.b #32,d0
 cmp.b #40,d0
 bge.s plus40
 cmp.b #20,d0
 bge.s plus20
plus0
 add.l d0,d0
 add.l d0,a0
 moveq #23,d0
 lea scrollplane+145*42-2,a1
 move.l a1,a3
 move.l a0,a2
 add.l #8000,a3
 add.l #2840,a2

cpl1
 move.w (a0),(a1)
 add.l #40,a0
 add.l #42,a1
 move.w (a2),(a3)
 add.l #40,a2
 add.l #42,a3
 dbf d0,cpl1
 rts


 

plus20
 add.l #40*23,a0
 bra.s plus0

plus40
 add.l #80*23,a0
 bra.s plus0


blitwait
 btst #6,$dff002
 bne.s blitwait
 rts

blitshift
 lea scrollplane+145*42,a0
 lea scrollplane+2+145*42,a1
 bsr.s blitwait
 move.l a0,$dff054
 move.l a1,$dff050
 move.l #-1,$dff044
 clr.l $dff064
 move.w #%1101100111110000,$dff040
 clr.w $dff042
 move.w #%101000010111,$dff058
 lea scrollplane+8000+145*42,a0
 lea scrollplane+8002+145*42,a1
 bsr.s blitwait
 move.l a0,$dff054
 move.l a1,$dff050
 move.l #-1,$dff044
 clr.l $dff064
 move.w #%1101100111110000,$dff040
 clr.w $dff042
 move.w #%101000010111,$dff058

 bsr blitwait
 rts


scroll2
 
 move.b scr2ctd,d0
 subq.b #1,d0
 beq.s newlet
 move.b d0,scr2ctd
 rts
newlet
 move.b #5,scr2ctd
wwrap
 moveq #0,d0
 move.l scr2ptr,a0
 move.b (a0)+,d0
 bne.s nowrap
 move.l #scrolly2,scr2ptr
 bra.s wwrap
nowrap
 move.l a0,scr2ptr
 bra charprint


;нннннннннннннннннннннннннннннннннннннн
;н   NoisetrackerV1.0 replayroutine   н
;н Mahoney & Kaktus - HALLONSOFT 1989 н
;нннннннннннннннннннннннннннннннннннннн



mt_init:lea	mt_data,a0
	move.l	a0,a1
	add.l	#$3b8,a1
	moveq	#$7f,d0
	moveq	#0,d1
mt_loop:move.l	d1,d2
	subq.w	#1,d0
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	mt_loop
	dbf	d0,mt_lop2
	addq.b	#1,d2

	lea	mt_samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$43c,d2
	add.l	a0,d2
	move.l	d2,a2
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	#$1e,a0
	dbf	d0,mt_lop3

	or.b	#$2,$bfe001
	move.b	#$6,mt_speed
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.b	mt_songpos
	clr.b	mt_counter
	clr.w	mt_pattpos
	rts

mt_end:	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

mt_music:
	movem.l	d0-d4/a0-a3/a5-a6,-(a7)
	lea	mt_data,a0
	addq.b	#$1,mt_counter
	move.b	mt_counter,D0
	cmp.b	mt_speed,D0
	blt.s	mt_nonew
	clr.b	mt_counter
	bra	mt_getnew

mt_nonew:
	lea	mt_voice1(pc),a6
	lea	$dff0a0,a5
	bsr	mt_checkcom
	lea	mt_voice2(pc),a6
	lea	$dff0b0,a5
	bsr	mt_checkcom
	lea	mt_voice3(pc),a6
	lea	$dff0c0,a5
	bsr	mt_checkcom
	lea	mt_voice4(pc),a6
	lea	$dff0d0,a5
	bsr	mt_checkcom
	bra	mt_endr

mt_arpeggio:
	moveq	#0,d0
	move.b	mt_counter,d0
	divs	#$3,d0
	swap	d0
	cmp.w	#$0,d0
	beq.s	mt_arp2
	cmp.w	#$2,d0
	beq.s	mt_arp1

	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_arp3
mt_arp1:moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	bra.s	mt_arp3
mt_arp2:move.w	$10(a6),d2
	bra.s	mt_arp4
mt_arp3:asl.w	#1,d0
	moveq	#0,d1
	move.w	$10(a6),d1
	lea	mt_periods(pc),a0
	moveq	#$24,d7
mt_arploop:
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	mt_arp4
	addq.l	#2,a0
	dbf	d7,mt_arploop
	rts
mt_arp4:move.w	d2,$6(a5)
	rts

mt_getnew:
	lea	mt_data,a0
	move.l	a0,a3
	move.l	a0,a2
	add.l	#$c,a3
	add.l	#$3b8,a2
	add.l	#$43c,a0

	moveq	#0,d0
	move.l	d0,d1
	move.b	mt_songpos,d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_pattpos,d1
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_voice1(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0b0,a5
	lea	mt_voice2(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0c0,a5
	lea	mt_voice3(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0d0,a5
	lea	mt_voice4(pc),a6
	bsr.s	mt_playvoice
	bra	mt_setdma

mt_playvoice:
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	mt_setregs
	moveq	#0,d3
	lea	mt_samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$1,d2
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2.l),$4(a6)
	move.w	(a3,d4.l),$8(a6)
	move.w	$2(a3,d4.l),$12(a6)
	move.w	$4(a3,d4.l),d3
	tst.w	d3
	beq.s	mt_noloop
	move.l	$4(a6),d2
	asl.w	#1,d3
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$4(a3,d4.l),d0
	add.w	$6(a3,d4.l),d0
	move.w	d0,8(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
	bra.s	mt_setregs
mt_noloop:
	move.l	$4(a6),d2
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
mt_setregs:
	move.w	(a6),d0
	and.w	#$fff,d0
	beq	mt_checkcom2
	move.b	$2(a6),d0
	and.b	#$F,d0
	cmp.b	#$3,d0
	bne.s	mt_setperiod
	bsr	mt_setmyport
	bra	mt_checkcom2
mt_setperiod:
	move.w	(a6),$10(a6)
	and.w	#$fff,$10(a6)
	move.w	$14(a6),d0
	move.w	d0,$dff096
	clr.b	$1b(a6)

	move.l	$4(a6),(a5)
	move.w	$8(a6),$4(a5)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	move.w	$14(a6),d0
	or.w	d0,mt_dmacon
	bra	mt_checkcom2

mt_setdma:
	move.w	#$12c,d0
mt_wait:dbf	d0,mt_wait
	move.w	mt_dmacon,d0
	or.w	#$8000,d0
	move.w	d0,$dff096
	move.w	#$12c,d0
mt_wai2:dbf	d0,mt_wai2
	lea	$dff000,a5
	lea	mt_voice4(pc),a6
	move.l	$a(a6),$d0(a5)
	move.w	$e(a6),$d4(a5)
	lea	mt_voice3(pc),a6
	move.l	$a(a6),$c0(a5)
	move.w	$e(a6),$c4(a5)
	lea	mt_voice2(pc),a6
	move.l	$a(a6),$b0(a5)
	move.w	$e(a6),$b4(a5)
	lea	mt_voice1(pc),a6
	move.l	$a(a6),$a0(a5)
	move.w	$e(a6),$a4(a5)

	add.w	#$10,mt_pattpos
	cmp.w	#$400,mt_pattpos
	bne.s	mt_endr
mt_nex:	clr.w	mt_pattpos
	clr.b	mt_break
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	mt_songpos,d1
	cmp.b	mt_data+$3b6,d1
	bne.s	mt_endr
	clr.b	mt_songpos
mt_endr:tst.b	mt_break
	bne.s	mt_nex
	movem.l	(a7)+,d0-d4/a0-a3/a5-a6
	rts

mt_setmyport:
	move.w	(a6),d2
	and.w	#$fff,d2
	move.w	d2,$18(a6)
	move.w	$10(a6),d0
	clr.b	$16(a6)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge.s	mt_rt
	move.b	#$1,$16(a6)
	rts
mt_clrport:
	clr.w	$18(a6)
mt_rt:	rts

mt_myport:
	move.b	$3(a6),d0
	beq.s	mt_myslide
	move.b	d0,$17(a6)
	clr.b	$3(a6)
mt_myslide:
	tst.w	$18(a6)
	beq.s	mt_rt
	moveq	#0,d0
	move.b	$17(a6),d0
	tst.b	$16(a6)
	bne.s	mt_mysub
	add.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	bgt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
mt_myok:move.w	$10(a6),$6(a5)
	rts
mt_mysub:
	sub.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	blt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
	move.w	$10(a6),$6(a5)
	rts

mt_vib:	move.b	$3(a6),d0
	beq.s	mt_vi
	move.b	d0,$1a(a6)

mt_vi:	move.b	$1b(a6),d0
	lea	mt_sin(pc),a4
	lsr.w	#$2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	(a4,d0.w),d2
	move.b	$1a(a6),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#$6,d2
	move.w	$10(a6),d0
	tst.b	$1b(a6)
	bmi.s	mt_vibmin
	add.w	d2,d0
	bra.s	mt_vib2
mt_vibmin:
	sub.w	d2,d0
mt_vib2:move.w	d0,$6(a5)
	move.b	$1a(a6),d0
	lsr.w	#$2,d0
	and.w	#$3c,d0
	add.b	d0,$1b(a6)
	rts

mt_nop:	move.w	$10(a6),$6(a5)
	rts

mt_checkcom:
	move.w	$2(a6),d0
	and.w	#$fff,d0
	beq.s	mt_nop
	move.b	$2(a6),d0
	and.b	#$f,d0
	tst.b	d0
	beq	mt_arpeggio
	cmp.b	#$1,d0
	beq.s	mt_portup
	cmp.b	#$2,d0
	beq	mt_portdown
	cmp.b	#$3,d0
	beq	mt_myport
	cmp.b	#$4,d0
	beq	mt_vib
	move.w	$10(a6),$6(a5)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_volslide:
	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_voldown
	add.w	d0,$12(a6)
	cmp.w	#$40,$12(a6)
	bmi.s	mt_vol2
	move.w	#$40,$12(a6)
mt_vol2:move.w	$12(a6),$8(a5)
	rts

mt_voldown:
	moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	sub.w	d0,$12(a6)
	bpl.s	mt_vol3
	clr.w	$12(a6)
mt_vol3:move.w	$12(a6),$8(a5)
	rts

mt_portup:
	moveq	#0,d0
	move.b	$3(a6),d0
	sub.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$71,d0
	bpl.s	mt_por2
	and.w	#$f000,$10(a6)
	or.w	#$71,$10(a6)
mt_por2:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_portdown:
	clr.w	d0
	move.b	$3(a6),d0
	add.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$358,d0
	bmi.s	mt_por3
	and.w	#$f000,$10(a6)
	or.w	#$358,$10(a6)
mt_por3:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_checkcom2:
	move.b	$2(a6),d0
	and.b	#$f,d0
	cmp.b	#$e,d0
	beq.s	mt_setfilt
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_posjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_setfilt:
	rts
mt_pattbreak:
	not.b	mt_break
	rts
mt_posjmp:
	move.b	$3(a6),d0
	subq.b	#$1,d0
	move.b	d0,mt_songpos
	not.b	mt_break
	rts
mt_setvol:
	cmp.b	#$40,$3(a6)
	ble.s	mt_vol4
	move.b	#$40,$3(a6)
mt_vol4:move.b	$3(a6),$8(a5)
	rts
mt_setspeed:
	move.b	$3(a6),d0
	and.w	#$1f,d0
	beq.s	mt_rts2
	clr.b	mt_counter
	move.b	d0,mt_speed
mt_rts2:rts




mt_sin:
 dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
 dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_periods:
 dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
 dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
 dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
 dc.w $007f,$0078,$0071,$0000,$0000

mt_speed:	dc.b	$6
mt_songpos:	dc.b	$0
mt_pattpos:	dc.w	$0
mt_counter:	dc.b	$0

mt_break:	dc.b	$0
mt_dmacon:	dc.w	$0
mt_samplestarts:dcb.l	$1f,0
mt_voice1:	dcb.w	10,0
		dc.w	$1
		dcb.w	3,0
mt_voice2:	dcb.w	10,0
		dc.w	$2
		dcb.w	3,0
mt_voice3:	dcb.w	10,0
		dc.w	$4
		dcb.w	3,0
mt_voice4:	dcb.w	10,0
		dc.w	$8
		dcb.w	3,0


mt_data incbin modules/mod.heavyzing


ov dc.w 0
twod dc.w $FFF
ctptr dc.l coltab
scrollptr dc.l scroller
scr2ptr dc.l scrolly2
charaddr dc.l 0
charctd dc.b 3
ctdn: dc.b 3
scr2ctd dc.b 4
swap: dc.b 0
charbyte: dc.b %0000

 even


scroller dc.b "                       AMIGA COMPUTING      PRESENTS THE HEAVY DEMO      "
	dc.b "CODED BY JOLYON RALPH OF STATYX SOFTWARE     MUSIC BY STEVE HOGG     AMIGA LOGO BY GEORG DROSCHL FROM AUSTRIA (THANKS MATE).    "
	dc.b " THIS DEMO IS CALLED HEAVY DUE TO THE HEAVY TUNE WRITTEN BY MY FRIEND STEVE. IT WAS COMPOSED ON SOUNDTRACKER.  "
	DC.B " WELL, NOW FOR SOME TECHY INFO: THIS SCROLL USES HEAPS OF COPPER LIST. IT'S BASICALLY A 8 COLOUR PICTURE WITH COLOUR CYCLING - DIFFERNENT "
	DC.B "COLOURS CYCLED ON EACH SCANLINE! NEAT EH?    CREDIT MUST BE GIVEN TO THE ORIGINAL DISCOVERERS OF THIS TECHNIQUE - MAHONEY AND KAKTUS FROM SWEDEN. "
	DC.B " ONE OF THEM'S 16, THE OTHERS ONLY 14!!!    MAKES YOU SICK DOESN'T IT?     OH WELL, READ THE SCROLL BELOW!  ",0

scrolly2 dc.b " AMIGA COMPUTING PRESENTS THE HEAVY DEMO - CODED BY JOLYON RALPH, MUSIC BY STEVE HOGG AND AMIGA COMPUTING LOGO PAINTED "
 	  DC.B "BY GEORG DROSCHL - ONE OF OUR GOOD AUSTRIAN FRIENDS.        "
	  DC.B "MANY THANKS TO DEREK, ADAM AND JOBY OF CREATIVE THOUGHTS - YES I DID PINCH YOUR COLOUR DATA - I HOPE YOU DON'T MIND! "
	DC.B "   AND PERSONAL HELLO'S GO OUT TO    RUSS, JIM, RICHARD, KEVIN, COLIN, JOLYON M. - YES THERE IS ANOTHER ONE!!!! -    SORRY, "
	DC.B "I SHOULD HAVE MENTIONED ALL OF YOU, BUT THAT WOULD BE PRETTY BORING, JUST A LONG LIST OF NAMES.  SO TO KEEP A FEW PROMISES I'VE MADE, HERE'S "

	DC.B "A FEW CRYPTIC MESSAGES.   TO MY SISTER. ONCE AGAIN, POLAND ? ? ?    "
	DC.B "TO DEL - LOOK NO OPTIMISATIONS THIS TIME!!!!   TO GEORG AND THOMAS FROM AUSTRIA - SEE YOU AGAIN SOON. "
 	DC.B " WELL CHRISTMAS TIME IS COMING FAST, SO WATCH OUT FOR A SPECIAL YULETIDE DEMO NEXT MONTH! "   

 DC.B "     NOTE: WE ARE ALL AVAILABLE FOR COMMERCIAL PROJECTS ON THE AMIGA - IF INTERESTED PLEASE SEND A JIFFY BAG STUFFED FULL OF FIVERS TO "
	  DC.B "STATYX SOFTWARE, PO BOX 241, COULSDON, SURREY, CR3, 2EZ    "
 	  DC.B "LET US KNOW WHAT YOU REQUIRE, AND WE'LL TELL YOU WHAT WE REQUIRE IN RETURN!!!!                            "
	 
	DC.B 0

OLDCOPPER: DC.l 0
NEWCOPPER:
 dc.w $100,$5600,$102,$0,$104,$40,$108,0,$10a,2
 dc.w $92,$38,$94,$d0,$8e,$2c81,$90,$2cc1
 dc.w $1a2,$fff,$1a4,$aaa,$1a6,$666
 dc.w $1aa,$fff,$1ac,$aaa,$1ae,$666
 dc.w $1b2,$fff,$1b4,$aaa,$1b6,$666
 dc.w $1ba,$fff,$1bc,$aaa,$1be,$666
 dc.w $192,$444,$194,$777,$196,$ccc,$180,0
 dc.w	$120
sp0h: dc.w	0,$122
sp0l: dc.w	0,$124
sp1h: dc.w	0,$126
sp1l: dc.w	0,$128
sp2h: dc.w	0,$12a
sp2l: dc.w	0,$12c
sp3h: dc.w	0,$12e
sp3l: dc.w	0,$130
sp4h: dc.w	0,$132
sp4l: dc.w	0,$134
sp5h: dc.w	0,$136
sp5l: dc.w	0,$138
sp6h: dc.w	0,$13a
sp6l: dc.w	0,$13c
sp7h: dc.w	0,$13e
sp7l: dc.w	0,$e0
pt0h: dc.w	0,$e2
pt0l: dc.w	0,$e4
pt1h: dc.w	0,$e6
pt1l: dc.w	0,$e8
pt2h: dc.w	0,$ea
pt2l: dc.w	0,$ec
pt3h: dc.w	0,$ee
pt3l: dc.w	0,$f0
pt4h: dc.w	0,$f2
pt4l: dc.w	0,$f4
pt5h: dc.w	0,$f6
pt5l: dc.w	0




scrollclist
 dc.w $2c09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $3009,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $3409,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $3809,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $3b09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $3e09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $4109,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $4409,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $4709,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $4a09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $4d09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $4f09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $5109,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $5309,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $5509,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $5709,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $5909,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $5b09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $5d09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $5f09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $6109,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $6309,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $6509,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $6609,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $6709,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $6809,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $6909,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $6a09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $6b09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $6c09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $6d09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $6e09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $6f09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $7009,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $7109,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $7209,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $7309,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $7409,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $7509,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $7609,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $7709,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $7809,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $7909,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $7a09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $7b09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $7c09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $7d09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $7e09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $7f09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $8009,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $8109,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $8209,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $8309,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $8409,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $8509,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $8609,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $8709,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $8809,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $8909,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $8a09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $8b09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $8c09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $8d09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $8e09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $8f09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $9009,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $9109,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $9209,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $9309,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $9409,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $9509,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $9609,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $9709,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $9709,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $9709,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $9809,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $9909,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $9a09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $9b09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $9c09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $9d09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $9e09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $a009,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $a209,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $a409,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $a609,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $a809,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $aa09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $ac09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $ae09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $b009,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $b209,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $b409,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $b709,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $ba09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $bd09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $c009,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $c309,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $c609,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $ca09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $ce09,$fffe,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0



  dc.w $d209,$fffe,$100,$4200,$10a,0
  dc.w $e0
pl0h: dc.w	0,$e2
pl0l: dc.w	0,$e4
pl1h: dc.w	0,$e6
pl1l: dc.w	0,$e8
pl2h: dc.w	0,$ea
pl2l: dc.w	0,$ec
pl3h: dc.w	0,$ee
pl3l: dc.w	0
colregs dcb.w 32,0


woblogoclist
 dc.w $d309,$fffe,$102,$88,$180,1
 dc.w $d409,$fffe,$102,$88,$180,2
 dc.w $d509,$fffe,$102,$88,$180,3
 dc.w $d609,$fffe,$102,$88,$180,4
 dc.w $d709,$fffe,$102,$88,$180,5
 dc.w $d809,$fffe,$102,$88,$180,6
 dc.w $d909,$fffe,$102,$88,$180,5
 dc.w $da09,$fffe,$102,$88,$180,4
 dc.w $db09,$fffe,$102,$88,$180,3
 dc.w $dc09,$fffe,$102,$88,$180,2
 dc.w $dd09,$fffe,$102,$88,$180,1
 dc.w $de09,$fffe,$102,$88,$180,0
 dc.w $df09,$fffe,$102,$88,$180,0
 dc.w $e009,$fffe,$102,$88,$180,0
 dc.w $e109,$fffe,$102,$88,$180,0
 dc.w $e209,$fffe,$102,$88,$180,$100
 dc.w $e309,$fffe,$102,$88,$180,$100
 dc.w $e409,$fffe,$102,$88,$180,$200
 dc.w $e509,$fffe,$102,$88,$180,$200
 dc.w $e609,$fffe,$102,$88,$180,$300
 dc.w $e709,$fffe,$102,$88,$180,$400
 dc.w $e809,$fffe,$102,$88,$180,$510
 dc.w $e909,$fffe,$102,$88,$180,$610
 dc.w $ea09,$fffe,$102,$88,$180,$710
 dc.w $eb09,$fffe,$102,$88,$180,$820
 dc.w $ec09,$fffe,$102,$88,$180,$930
 dc.w $ed09,$fffe,$102,$88,$180,$a50
 dc.w $ee09,$fffe,$102,$88,$180,$b70
 dc.w $ef09,$fffe,$102,$88,$180,$c90
 dc.w $f009,$fffe,$102,$88,$180,$db0
 dc.w $f109,$fffe,$102,$88,$180,0
 dc.w $f209,$fffe,$102,$88,$180,0
 dc.w $f309,$fffe,$102,$88,$180,0
 dc.w $f409,$fffe,$102,$88,$180,0
 dc.w $f509,$fffe,$102,$88,$180,0
 dc.w $f609,$fffe,$102,$88,$180,0
 dc.w $f709,$fffe,$102,$88,$180,0
 dc.w $f809,$fffe,$102,$88,$180,0
 dc.w $f909,$fffe,$102,$88,$180,0
 dc.w $fa09,$fffe,$102,$88,$180,0
 dc.w $fb09,$fffe,$102,$88,$180,0
 dc.w $fc09,$fffe,$102,$88,$180,0
 dc.w $fd09,$fffe,$102,$88,$180,0
 dc.w $fe09,$fffe,$102,$88,$180,0
 dc.w $ff09,$fffe,$102,$88,$ffdf,$fffe		; pal copper enable
 dc.w $0009,$fffe,$102,$88,$180,0
 dc.w $0109,$fffe,$102,$88,$180,0
 dc.w $0209,$fffe,$102,$88,$180,0
 dc.w $309,$fffe,$102,$88,$180,0
 dc.w $409,$fffe,$102,$88,$180,$1
 dc.w $509,$fffe,$102,$88,$180,$1
 dc.w $609,$fffe,$102,$88,$180,$1
 dc.w $709,$fffe,$102,$88,$180,$1
 dc.w $809,$fffe,$102,$88,$180,$2
 dc.w $909,$fffe,$102,$88,$180,$2
 dc.w $a09,$fffe,$102,$88,$180,$2
 dc.w $b09,$fffe,$102,$88,$180,$2
 dc.w $c09,$fffe,$102,$88,$180,$2
 dc.w $d09,$fffe,$102,$88,$180,$3
 dc.w $e09,$fffe,$102,$88,$180,$3
 dc.w $f09,$fffe,$102,$88,$180,$3
 dc.w $1009,$fffe,$102,$88,$180,$3
 dc.w $1109,$fffe,$102,$88,$180,$3
 dc.w $1209,$fffe,$102,$88,$180,$3
 dc.w $1309,$fffe,$102,$88,$180,$3
 dc.w $1409,$fffe,$102,$88,$180,$3
 dc.w $1509,$fffe,$102,$88,$180,$3
 dc.w $1609,$fffe,$102,$88,$180,$4
 dc.w $1709,$fffe,$102,$88,$180,$4
 dc.w $1809,$fffe,$102,$88,$180,$4
 dc.w $1909,$fffe,$102,$88,$180,$4
 dc.w $1a09,$fffe,$102,$88,$180,$4
 dc.w $1b09,$fffe,$102,$88,$180,$4
 dc.w $1c09,$fffe,$102,$88,$180,$4
 dc.w $1d09,$fffe,$102,$88,$180,$4
 dc.w $1e09,$fffe,$102,$88,$180,$4
 dc.w $1f09,$fffe,$102,$88,$180,$4
 dc.w $2009,$fffe,$102,$88,$180,$4
 dc.w $2109,$fffe,$102,$88,$180,$4
 dc.w $2209,$fffe,$102,$88,$180,$4

 dc.w $9c,$8010
 DC.w $FFFF,$FFFE ; End copper






bigfontdata
 incbin graphics_data/font




fontdata
 incbin graphics_data/smallfont


wobptr dc.l woblist
woblist	incbin graphics_data/wobdata
	dc.b $fe
 	

 even


 
sprite0:
sprite1:
sprite2:	
sprite3: dc.w 0,0,0,0
	

sprite4:
 dc.w $34a0,$3900
 dc.w $0000,$8700,$0100,$EF80,$0000,$7FC0,$0180,$EE00,$0000,$8700
 ds.w 30*12
 
sprite5:
 ds.w 45*10 

; dc.w $0000,$8700,$0100,$EF80,$0000,$7FC0,$0180,$EE00,$0000,$8700

; dc.w $0800,$9000,$0000,$7C00,$0000,$9800

sprite6:
 ds.w 60*6
 
sprite7:
 dc.w 0,0,0,0,0,0,0,0
	
	


coltab	dc.w $ff0,$ee0,$de0,$ce0
	dc.w $be0,$ae0,$9e1,$8e2
	dc.w $7e3,$6e4,$5e5,$4e6
	dc.w $3e7,$2e8,$1e9,$0ea
	dc.w $0db,$0cc,$0bd,$0ae
	dc.w $09f,$18f,$27f,$36f
	dc.w $45f,$54f,$63f,$72f
	dc.w $81f,$90f,$a0f,$b0f
	dc.w $c0d,$d0c,$e0b,$f0a
	dc.w $f19,$f28,$f37,$f46
	dc.w $f55,$f64,$f73,$f82
	dc.w $f91,$fa0,$eb0,$dc0
	dc.w $cd0,$be0,$af0,$9f1
	dc.w $8f2,$7f3,$6f4,$5f5	
	dc.w $4f6,$3f7,$2f8,$1f9
	dc.w $0fa,$0eb,$0dc,$0cd
	dc.w $0be,$0af,$19f,$28f
	dc.w $37f,$46f,$55f,$64f
	dc.w $73f,$82f,$91f,$a0f	
	dc.w $b0e,$c0d,$d0c,$e0b
	dc.w $f0a,$f19,$f28,$f37
	dc.w $f46,$f55,$f64,$f73
	dc.w $f82,$f91,$fa0,$eb0
	dc.w $dc0,$cd0,$be0,$af0
	dc.w $9f1,$8f2,$7f3,$6f4
	dc.w $5f5,$4f6,$3f7,$2f8
	dc.w $1f9,$0fa,$0eb,$0dc
	dc.w $0cd,$0be,$0af,$19f
	dc.w $28f,$37f,$46f,$55f
	dc.w $64f,$73f,$82f,$91f
	dc.w $a0f,$b0e,$c0d,$d0c
	dc.w $e0b,$f0a,$f19,$f28
	dc.w $f37,$f46,$f55,$f64
	dc.w $f73,$f82,$f91,$fa0
	dc.w $fb0,$fc0,$fd0,$fe0
	dc.w 0

amigalogo incbin graphics_data/amigalogo3
scrollpath incbin graphics_data/grid
scrollplane dcb.b 16000,0
