	section	Analyser,code_c
	opt	o+,o3-


OTHER_COLOURS	equ	0


	move.l	4.w,a6
	jsr	-132(a6)		Forbid


	move.l	#40*200,d0
	move.l	#$10002,d1		clear chip
	jsr	-198(a6)		AllocMem
	tst.l	d0
	beq	exit_now
	move.l	d0,screen.mem


	moveq	#0,d0
	lea	graf.name(pc),a1
	jsr	-552(a6)		OpenLibrary
	tst.l	d0
	beq	exit_freemem

	move.l	d0,gfxbase
	move.l	d0,a6
	jsr	-456(a6)		OwnBlitter




;"""""""""""""""""""""""""
;" INITIALISE INTERRUPTS "
;"			 "
;"""""""""""""""""""""""""

	lea	$dff000,a6
	move.w	intenar(a6),old.ints	save system interrupt status

	move.w	#$7fff,intena(a6)	disable all interrupts

	move.l	$6c.w,old.level3
	move.l	#new.level3,$6c.w

	move.w	#$c010,intena(a6)	enable copper interrupt


	move.l	$14.w,old.dbz		division-by-zero exception handler
	move.l	#rte.ins,$14.w		set to rte instruction




;"""""""""""""""""""""""""""""
;" INITIALISE SCREEN DISPLAY "
;"			     "
;"""""""""""""""""""""""""""""

vp.wait	move.l	vposr(a6),d0		get vertical beam position
	and.l	#$1ff00,d0
	lsr.l	#8,d0
	cmp.w	#312,d0			wait for bottom line
	bne.s	vp.wait			before disabling sprite DMA

	move.w	#$03ff,dmacon(a6)	DMA off


	move.w	#$1200,bplcon0(a6)	initialise screen
	move.w	#$4881,diwstrt(a6)
	move.w	#$10c1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$b0,ddfstop(a6)
	moveq	#0,d0
	move.w	d0,bplcon1(a6)
	move.w	d0,bplcon2(a6)
	move.w	d0,bpl1mod(a6)
;	move.w	d0,bpl2mod(a6)
	move.w	d0,color0(a6)


	move.l	screen.mem(pc),d0	initialise copper
	lea	copper.list(pc),a0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	move.l	#copper.list,cop1lch(a6)
	move.w	d0,copjmp1(a6)


	move.w	#$87c0,dmacon(a6)	DMA on
	bset	#1,$bfe001




	bsr	mt_init




;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

loop	bsr	clear
	bsr	analyser
	bsr	mt_music

	sf	next.frame
vbl	tst.b	next.frame
	beq.s	vbl

	btst	#6,$bfe001
	bne.s	loop




;""""""""""""""""
;" EXIT ROUTINE	"
;"		"
;""""""""""""""""

wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait


	move.w	#$7fff,intena(a6)	disable all interrupts

	move.l	old.level3(pc),$6c.w

	move.w	old.ints(pc),d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status


	move.l	old.dbz(pc),$14.w	restore division-by-zero handler


	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	gfxbase(pc),a0
	move.l	38(a0),cop1lch(a6)	restore system copper

	move.w	#$87f0,dmacon(a6)	DMA on


	move.l	a0,a6
	jsr	-462(a6)		DisownBlitter

	move.l	a6,a1
	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary

exit_freemem
	move.l	#40*200,d0
	move.l	screen.mem(pc),a1
	jsr	-210(a6)		FreeMem

exit_now
	jsr	-138(a6)		Permit

	moveq	#0,d0
	rts




;"""""""""""""""""""""
;" LEVEL 3 INTERRUPT "
;"		     "
;"""""""""""""""""""""

new.level3
;	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$10,intreq(a6)

	st	next.frame

;	movem.l	(sp)+,d0-d7/a0-a6
rte.ins	rte




;"""""""""""""""
;" SUBROUTINES "
;"	       "
;"""""""""""""""

up.sides	equ	16
up.centre	equ	26
down.value	equ	1
max.bar.height	equ	60



clear	move.l	screen.mem(pc),a0
	lea	40*(200-max.bar.height-1)(a0),a0

bltfin	btst	#6,dmaconr(a6)
	bne.s	bltfin

	move.w	#0,bltdmod(a6)
	move.l	#$1000000,bltcon0(a6)	USE D
	move.l	a0,bltdpth(a6)
	move.w	#(max.bar.height+1)*64+20,bltsize(a6)
	rts



	dc.w	0
freq.table
	ds.b	40



channel.frequency
	move.w	(a0),d0
	bne.s	get.frequency
	rts


get.frequency
	clr.w	(a0)
	moveq	#0,d1
	lea	mt_periods(pc),a1

frequency.search
	move.w	(a1)+,d2		this works out the position
	cmp.w	d2,d0			along the equalizer for the
	bgt.s	frequency.found		bar by using the period table
;					in the music play routine
	addq.w	#1,d1
	bra.s	frequency.search

frequency.found
	lea	freq.table(pc,d1.w),a1
	moveq	#up.sides,d1
	add.b	d1,-1(a1)		----
	add.b	#up.centre,(a1)		------
	add.b	d1,1(a1)		----

	moveq	#max.bar.height-2,d1
	moveq	#max.bar.height,d2

	move.b	-1(a1),d0
	cmp.b	d1,d0
	ble.s	less1
	move.b	d1,-1(a1)

less1	move.b	(a1),d0
	cmp.b	d2,d0
	ble.s	less2
	move.b	d2,(a1)

less2	move.b	1(a1),d0
	cmp.b	d1,d0
	ble.s	less3
	move.b	d1,1(a1)

less3	rts




analyser
	lea	freq1(pc),a0
	bsr.s	channel.frequency

	lea	freq2(pc),a0
	bsr.s	channel.frequency

	lea	freq3(pc),a0
	bsr.s	channel.frequency

	lea	freq4(pc),a0
	bsr.s	channel.frequency

bltfin2	btst	#6,dmaconr(a6)
	bne.s	bltfin2

	moveq	#40-1,d0		40 bars
	moveq	#%11111110,d1		bar pattern
	moveq	#40,d2			bytes per line
	moveq	#10,d3			noise range limit
	moveq	#max.bar.height,d4
	moveq	#down.value,d5
	lea	freq.table(pc),a1
	move.l	screen.mem(pc),a2
	lea	40*(200-max.bar.height-1)(a2),a2

analyser.loop
	moveq	#0,d6
	move.b	(a1),d6			get bar height
	cmp.b	d3,d6			is it in the noise range ?
	bgt.s	no.noise

get.noise
	move.l	noise.ptr(pc),a3	get next noise value
	move.b	(a3)+,d7
	bpl.s	not.noise.end

	lea	noise.table(pc),a3
	move.b	(a3)+,d7

not.noise.end
	move.l	a3,noise.ptr
	add.b	d7,d6			add noise element

no.noise
	move.w	d6,d7
	neg.w	d6
	add.w	d4,d6
	mulu	d2,d6			start offset

fill.bar
	move.b	d1,(a2,d6.w)
	add.w	d2,d6
	dbra	d7,fill.bar

	sub.b	d5,(a1)
	bpl.s	not.below.zero

	clr.b	(a1)			set bar to zero

not.below.zero
	addq.l	#1,a1			next bar
	addq.l	#1,a2			next screen column

	dbra	d0,analyser.loop
	rts



noise.ptr
	dc.l	noise.table

noise.table
	dc.b	2,0,0,2,0,2,0,0,2,0,4,2,0,2,4,0,0,2,2,0,2,2,4,2,0,0,2,$ff



freq1	dc.w	0
freq2	dc.w	0
freq3	dc.w	0
freq4	dc.w	0



; now plays 15 or 31 instrument modules

INSTRUMENTS	equ	31

	IFEQ	INSTRUMENTS-15
SKIP	equ	0
	ELSE
SKIP	equ	4			skip 'M.K.' text
	ENDC

mt_init	lea	mt_data(pc),a0
	lea	20+INSTRUMENTS*30+2(a0),a1
	moveq	#127,d0
	moveq	#0,d1
mt_loop	move.l	d1,d2
	subq.w	#1,d0
mt_lop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	mt_loop
	dbra	d0,mt_lop2
	addq.b	#1,d2

	lea	mt_samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#20+INSTRUMENTS*30+2+128+SKIP,d2
	add.l	a0,d2
	move.l	d2,a2
	moveq	#INSTRUMENTS-1,d0
mt_lop3	clr.l	(a2)
	move.l	a2,(a1)+
	move.w	20+22(a0),d1
	add.w	d1,d1
	add.w	d1,a2
	lea	30(a0),a0
	dbra	d0,mt_lop3

	move.b	#6,mt_speed
	move.w	#0,$dff0a8
	move.w	#0,$dff0b8
	move.w	#0,$dff0c8
	move.w	#0,$dff0d8
	clr.b	mt_songpos
	clr.b	mt_counter
	clr.w	mt_pattpos
	rts

mt_end	move.w	#0,$dff0a8
	move.w	#0,$dff0b8
	move.w	#0,$dff0c8
	move.w	#0,$dff0d8
	move.w	#$f,$dff096
	rts

mt_music
	movem.l	d0-d4/a0-a3/a5-a6,-(sp)
	addq.b	#1,mt_counter
	move.b	mt_counter(pc),d0
	cmp.b	mt_speed(pc),d0
	blt.s	mt_nonew
	clr.b	mt_counter
	bra	mt_getnew

mt_nonew
	lea	mt_voice1(pc),a6
	lea	$dff0a0,a5
	bsr.s	mt_checkcom

	lea	mt_voice2(pc),a6
	lea	$dff0b0,a5
	bsr.s	mt_checkcom

	lea	mt_voice3(pc),a6
	lea	$dff0c0,a5
	bsr.s	mt_checkcom

	lea	mt_voice4(pc),a6
	lea	$dff0d0,a5
	bsr.s	mt_checkcom
	bra	mt_endr2

mt_nop	move.w	16(a6),6(a5)
	rts

mt_checkcom
	move.w	2(a6),d0
	and.w	#$fff,d0
	beq.s	mt_nop
	move.b	2(a6),d0
	and.b	#$f,d0
	beq	mt_arpeggio
	cmp.b	#1,d0
	beq.s	mt_portup
	cmp.b	#2,d0
	beq.s	mt_portdown
	cmp.b	#3,d0
	beq	mt_toneport
	cmp.b	#4,d0
	beq	mt_vib
	move.w	16(a6),6(a5)
	cmp.b	#10,d0
	beq.s	mt_volslide
	rts

mt_portup
	moveq	#0,d0
	move.b	3(a6),d0
	sub.w	d0,16(a6)
	cmp.w	#113,16(a6)
	bpl.s	mt_por2
	move.w	#113,16(a6)
mt_por2	move.w	16(a6),6(a5)
	rts

mt_portdown
	moveq	#0,d0
	move.b	3(a6),d0
	add.w	d0,16(a6)
	cmp.w	#856,16(a6)
	bmi.s	mt_por3
	move.w	#856,16(a6)
mt_por3	move.w	16(a6),6(a5)
	rts

mt_volslide
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	beq.s	mt_voldown

	add.w	d0,18(a6)
	cmp.w	#64,18(a6)
	bmi.s	mt_vol2
	move.w	#64,18(a6)
mt_vol2	move.w	18(a6),8(a5)
	rts

mt_voldown
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$f,d0
	sub.w	d0,18(a6)
	bpl.s	mt_vol3
	clr.w	18(a6)
mt_vol3	move.w	18(a6),8(a5)
	rts

mt_arpeggio
	moveq	#0,d0
	move.b	mt_counter(pc),d0
	divu	#3,d0
	swap	d0
	tst.w	d0
	beq.s	mt_arp2
	cmp.w	#2,d0
	beq.s	mt_arp1

	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_arp3

mt_arp1	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$f,d0
	bra.s	mt_arp3

mt_arp2	move.w	16(a6),d2
	bra.s	mt_arp4

mt_arp3	add.w	d0,d0
	move.w	16(a6),d1
	lea	mt_periods(pc),a0
	moveq	#36,d7
mt_arploop
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	mt_arp4
	addq.l	#2,a0
	bra.s	mt_arploop
	rts

mt_arp4	move.w	d2,6(a5)
	rts

mt_settoneport
	clr.b	22(a6)
	move.w	(a6),d2
	and.w	#$fff,d2
	move.w	d2,24(a6)
	move.w	16(a6),d0
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge.s	mt_rts

	move.b	#1,22(a6)
	rts

mt_clrport
	clr.w	24(a6)
mt_rts	rts

mt_toneport
	move.b	3(a6),d0
	beq.s	mt_myslide
	move.b	d0,23(a6)
	clr.b	3(a6)
mt_myslide
	tst.w	24(a6)
	beq.s	mt_rts

	moveq	#0,d0
	move.b	23(a6),d0
	tst.b	22(a6)
	bne.s	mt_mysub

	add.w	d0,16(a6)
	move.w	24(a6),d0
	cmp.w	16(a6),d0
	bgt.s	mt_myok

	move.w	24(a6),16(a6)
	clr.w	24(a6)

mt_myok	move.w	16(a6),6(a5)
	rts

mt_mysub
	sub.w	d0,16(a6)
	move.w	24(a6),d0
	cmp.w	16(a6),d0
	blt.s	mt_myok

	move.w	24(a6),16(a6)
	clr.w	24(a6)

	move.w	16(a6),6(a5)
	rts

mt_vib	move.b	3(a6),d0
	beq.s	mt_vi
	move.b	d0,26(a6)

mt_vi	move.b	27(a6),d0
	lea	mt_sin(pc),a4
	lsr.w	#2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	(a4,d0.w),d2
	move.b	26(a6),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#6,d2
	move.w	16(a6),d0
	tst.b	27(a6)
	bmi.s	mt_vibmin

	add.w	d2,d0
	bra.s	mt_vib2

mt_vibmin
	sub.w	d2,d0

mt_vib2	move.w	d0,6(a5)

	move.b	26(a6),d0
	lsr.w	#2,d0
	and.w	#$3c,d0
	add.b	d0,27(a6)
	rts

mt_getnew
	lea	mt_data(pc),a0
	lea	20+22-30(a0),a3
	lea	20+INSTRUMENTS*30+2(a0),a2
	lea	20+INSTRUMENTS*30+2+128+SKIP(a0),a0

	moveq	#0,d0
	move.l	d0,d1
	move.b	mt_songpos(pc),d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_pattpos(pc),d1
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

mt_playvoice
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	2(a6),d2
	lsr.b	#4,d2

	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	beq.s	mt_setregs

	moveq	#0,d3
	lea	mt_samplestarts(pc),a1
	move.l	d2,d4
	asl.l	#2,d2
	mulu	#30,d4
	move.l	-4(a1,d2.l),4(a6)
	move.w	(a3,d4.l),8(a6)
	move.w	2(a3,d4.l),18(a6)
	move.w	4(a3,d4.l),d3
	beq.s	mt_noloop

	move.l	4(a6),d2
	asl.w	#1,d3
	add.l	d3,d2
	move.l	d2,10(a6)
	move.w	4(a3,d4.l),d0
	add.w	6(a3,d4.l),d0
	move.w	d0,8(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
	bra.s	mt_setregs

mt_noloop
	move.l	4(a6),10(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)

mt_setregs
	move.w	(a6),d0
	and.w	#$fff,d0
	beq	mt_checkcom2

	move.b	2(a6),d0
	and.b	#$f,d0
	cmp.b	#3,d0
	bne.s	mt_setperiod

	bsr	mt_settoneport
	bra	mt_checkcom2

mt_setperiod
	move.w	(a6),16(a6)
	move.w	20(a6),$dff096
	clr.b	27(a6)

	move.l	4(a6),(a5)
	move.w	8(a6),4(a5)
	move.w	(a6),6(a5)
	move.w	20(a6),d0
	or.w	d0,mt_dmacon
	bra	mt_checkcom2

mt_setdma
	move.w	#700,d0
mt_wait	dbra	d0,mt_wait

	move.w	mt_dmacon(pc),d0
	or.w	#$8000,d0
	move.w	d0,$dff096

	move.w	#300,d0
mt_wai2	dbra	d0,mt_wai2

	lea	$dff000,a5
	lea	mt_voice4(pc),a6
	move.l	10(a6),aud3lch(a5)
	move.w	14(a6),aud3len(a5)
	move.w	(a6),freq4

	lea	mt_voice3(pc),a6
	move.l	10(a6),aud2lch(a5)
	move.w	14(a6),aud2len(a5)
	move.w	(a6),freq3

	lea	mt_voice2(pc),a6
	move.l	10(a6),aud1lch(a5)
	move.w	14(a6),aud1len(a5)
	move.w	(a6),freq2

	lea	mt_voice1(pc),a6
	move.l	10(a6),aud0lch(a5)
	move.w	14(a6),aud0len(a5)
	move.w	(a6),freq1

	add.w	#16,mt_pattpos
	cmp.w	#1024,mt_pattpos
	bne.s	mt_endr

mt_nex	clr.w	mt_pattpos
	clr.b	mt_break
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	mt_songpos(pc),d1
	cmp.b	mt_data+20+INSTRUMENTS*30(pc),d1
	bne.s	mt_endr
	clr.b	mt_songpos

mt_endr	tst.b	mt_break
	bne.s	mt_nex
mt_endr2
	movem.l	(sp)+,d0-d4/a0-a3/a5-a6
	rts

mt_checkcom2
	move.b	2(a6),d0
	and.b	#$f,d0
	cmp.b	#14,d0
	beq.s	mt_setfilt
	cmp.b	#13,d0
	beq.s	mt_pattbreak
	cmp.b	#11,d0
	beq.s	mt_posjmp
	cmp.b	#12,d0
	beq.s	mt_setvol
	cmp.b	#15,d0
	beq.s	mt_setspeed
	rts

mt_setfilt
	move.b	3(a6),d0
	and.b	#1,d0
	add.b	d0,d0
	and.b	#%11111101,$bfe001
	or.b	d0,$bfe001
	rts

mt_pattbreak
	not.b	mt_break
	rts

mt_posjmp
	move.b	3(a6),d0
	subq.b	#1,d0
	move.b	d0,mt_songpos
	not.b	mt_break
	rts

mt_setvol
	cmp.b	#64,3(a6)
	ble.s	mt_vol4
	move.b	#64,3(a6)
mt_vol4	move.b	3(a6),8(a5)
	rts

mt_setspeed
	move.b	3(a6),d0
	and.b	#$1f,d0
	beq.s	mt_rts2
	move.b	d0,mt_speed
mt_rts2	rts




mt_sin	dc.b	$00,$18,$31,$4a,$61,$78,$8d,$a1
	dc.b	$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
	dc.b	$ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5
	dc.b	$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_periods
	dc.w	856,808,762,720,678,640,604,570
	dc.w	538,508,480,453,428,404,381,360
	dc.w	339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143
	dc.w	135,127,120,113,000

mt_speed	dc.b	0
mt_songpos	dc.b	0
mt_pattpos	dc.w	0
mt_counter	dc.b	0

mt_break	dc.b	0
mt_dmacon	dc.w	0
mt_samplestarts	ds.l	INSTRUMENTS

mt_voice1
	dc.l	0			period and control words
	dc.l	0			sample address
	dc.w	0			sample length (in words)
	dc.l	0			repeat address
	dc.w	0			repeat length (in words)
	dc.w	0			sample period
	dc.w	0			sample volume
	dc.w	1			DMA bit
	dc.b	0			portamento up/down flag
	dc.b	0			portamento amount
	dc.w	0			portamento sample period
	dc.b	0			vibrato amount
	dc.b	0			vibrato position

mt_voice2
	ds.w	10
	dc.w	2
	ds.w	3

mt_voice3
	ds.w	10
	dc.w	4
	ds.w	3

mt_voice4
	ds.w	10
	dc.w	8
	ds.w	3




;"""""""""""""""""""
;" THE COPPER LIST "
;"		   "
;"""""""""""""""""""

copper.list
	dc.w	bpl1pth,0		1 bitplane display
	dc.w	bpl1ptl,0

	dc.w	$4801,$ff00
	dc.w	color0,$000

	IFEQ	OTHER_COLOURS

	dc.w	$d301,$ff00,color1,$000
	dc.w	$d401,$ff00,color1,$111
	dc.w	$d501,$ff00,color1,$222
	dc.w	$d601,$ff00,color1,$333
	dc.w	$d701,$ff00,color1,$444
	dc.w	$d801,$ff00,color1,$555
	dc.w	$d901,$ff00,color1,$666
	dc.w	$da01,$ff00,color1,$777
	dc.w	$db01,$ff00,color1,$888
	dc.w	$dc01,$ff00,color1,$999
	dc.w	$dd01,$ff00,color1,$aaa
	dc.w	$de01,$ff00,color1,$bbb
	dc.w	$df01,$ff00,color1,$ccc
	dc.w	$e001,$ff00,color1,$ddd
	dc.w	$e101,$ff00,color1,$eee
	dc.w	$e201,$ff00,color1,$fff
	dc.w	$e301,$ff00,color1,$ffe
	dc.w	$e401,$ff00,color1,$ffd
	dc.w	$e501,$ff00,color1,$ffc
	dc.w	$e601,$ff00,color1,$ffb
	dc.w	$e701,$ff00,color1,$ffa
	dc.w	$e801,$ff00,color1,$ff9
	dc.w	$e901,$ff00,color1,$ff8
	dc.w	$ea01,$ff00,color1,$ff7
	dc.w	$eb01,$ff00,color1,$ff6
	dc.w	$ec01,$ff00,color1,$ff5
	dc.w	$ed01,$ff00,color1,$ff4
	dc.w	$ee01,$ff00,color1,$ff3
	dc.w	$ef01,$ff00,color1,$ff2
	dc.w	$f001,$ff00,color1,$ff1
	dc.w	$f101,$ff00,color1,$ff0
	dc.w	$f201,$ff00,color1,$fe0
	dc.w	$f301,$ff00,color1,$fd0
	dc.w	$f401,$ff00,color1,$fc0
	dc.w	$f501,$ff00,color1,$fb0
	dc.w	$f601,$ff00,color1,$fa0
	dc.w	$f701,$ff00,color1,$f90
	dc.w	$f801,$ff00,color1,$f80
	dc.w	$f901,$ff00,color1,$f70
	dc.w	$fa01,$ff00,color1,$f60
	dc.w	$fb01,$ff00,color1,$f50
	dc.w	$fc01,$ff00,color1,$f40
	dc.w	$fd01,$ff00,color1,$f30
	dc.w	$fe01,$ff00,color1,$f20
	dc.w	$ff01,$ff00,color1,$f10
	dc.w	$ffe1,$fffe		PAL enable
	dc.w	$0001,$ff00,color1,$f00

	dc.w	$1001,$ff00
	dc.w	color0,$008

	ELSE

	dc.w	$d301,$ff00,color1,$000
	dc.w	$d401,$ff00,color1,$111
	dc.w	$d501,$ff00,color1,$222
	dc.w	$d601,$ff00,color1,$333
	dc.w	$d701,$ff00,color1,$444
	dc.w	$d801,$ff00,color1,$555
	dc.w	$d901,$ff00,color1,$666
	dc.w	$da01,$ff00,color1,$777
	dc.w	$db01,$ff00,color1,$888
	dc.w	$dc01,$ff00,color1,$999
	dc.w	$dd01,$ff00,color1,$aaa
	dc.w	$de01,$ff00,color1,$bbb
	dc.w	$df01,$ff00,color1,$ccc
	dc.w	$e001,$ff00,color1,$ddd
	dc.w	$e101,$ff00,color1,$eee
	dc.w	$e201,$ff00,color1,$fff
	dc.w	$e301,$ff00,color1,$eff
	dc.w	$e401,$ff00,color1,$dff
	dc.w	$e501,$ff00,color1,$cff
	dc.w	$e601,$ff00,color1,$bff
	dc.w	$e701,$ff00,color1,$aff
	dc.w	$e801,$ff00,color1,$9ff
	dc.w	$e901,$ff00,color1,$8ff
	dc.w	$ea01,$ff00,color1,$7ff
	dc.w	$eb01,$ff00,color1,$6ff
	dc.w	$ec01,$ff00,color1,$5ff
	dc.w	$ed01,$ff00,color1,$4ff
	dc.w	$ee01,$ff00,color1,$3ff
	dc.w	$ef01,$ff00,color1,$2ff
	dc.w	$f001,$ff00,color1,$1ff
	dc.w	$f101,$ff00,color1,$0ff
	dc.w	$f201,$ff00,color1,$0ef
	dc.w	$f301,$ff00,color1,$0df
	dc.w	$f401,$ff00,color1,$0cf
	dc.w	$f501,$ff00,color1,$0bf
	dc.w	$f601,$ff00,color1,$0af
	dc.w	$f701,$ff00,color1,$09f
	dc.w	$f801,$ff00,color1,$08f
	dc.w	$f901,$ff00,color1,$07f
	dc.w	$fa01,$ff00,color1,$06f
	dc.w	$fb01,$ff00,color1,$05f
	dc.w	$fc01,$ff00,color1,$04f
	dc.w	$fd01,$ff00,color1,$03f
	dc.w	$fe01,$ff00,color1,$02f
	dc.w	$ff01,$ff00,color1,$01f
	dc.w	$ffe1,$fffe		PAL enable
	dc.w	$0001,$ff00,color1,$00f

	dc.w	$1001,$ff00
	dc.w	color0,$800

	ENDC

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe




;""""""""""""""""""""""
;" HARDWARE REGISTERS "
;"		      "
;""""""""""""""""""""""

dmaconr	equ	$002
vposr	equ	$004
vhposr	equ	$006
joy0dat	equ	$00a
joy1dat	equ	$00c
clxdat	equ	$00e
adkconr	equ	$010
pot0dat	equ	$012
pot1dat	equ	$014
potgor	equ	$016
serdatr	equ	$018
dskbytr	equ	$01a
intenar	equ	$01c
intreqr	equ	$01e
dskpth	equ	$020
dsklen	equ	$024
copcon	equ	$02e
serdat	equ	$030
serper	equ	$032
potgo	equ	$034
joytest	equ	$036
bltcon0	equ	$040
bltcon1	equ	$042
bltafwm	equ	$044
bltalwm	equ	$046
bltcpth	equ	$048
bltbpth	equ	$04c
bltapth	equ	$050
bltdpth	equ	$054
bltsize	equ	$058
bltcmod	equ	$060
bltbmod	equ	$062
bltamod	equ	$064
bltdmod	equ	$066
bltcdat	equ	$070
bltbdat	equ	$072
bltadat	equ	$074
dsksync	equ	$07e
cop1lch	equ	$080
cop2lch	equ	$084
copjmp1	equ	$088
copjmp2	equ	$08a
diwstrt	equ	$08e
diwstop	equ	$090
ddfstrt	equ	$092
ddfstop	equ	$094
dmacon	equ	$096
clxcon	equ	$098
intena	equ	$09a
intreq	equ	$09c
adkcon	equ	$09e
aud0lch	equ	$0a0
aud0len	equ	$0a4
aud0per	equ	$0a6
aud0vol	equ	$0a8
aud1lch	equ	$0b0
aud1len	equ	$0b4
aud1per	equ	$0b6
aud1vol	equ	$0b8
aud2lch	equ	$0c0
aud2len	equ	$0c4
aud2per	equ	$0c6
aud2vol	equ	$0c8
aud3lch	equ	$0d0
aud3len	equ	$0d4
aud3per	equ	$0d6
aud3vol	equ	$0d8
bpl1pth	equ	$0e0
bpl1ptl	equ	$0e2
bpl2pth	equ	$0e4
bpl2ptl	equ	$0e6
bpl3pth	equ	$0e8
bpl3ptl	equ	$0ea
bpl4pth	equ	$0ec
bpl4ptl	equ	$0ee
bpl5pth	equ	$0f0
bpl5ptl	equ	$0f2
bpl6pth	equ	$0f4
bpl6ptl	equ	$0f6
bplcon0	equ	$100
bplcon1	equ	$102
bplcon2	equ	$104
bpl1mod	equ	$108
bpl2mod	equ	$10a
spr0pth	equ	$120
spr0ptl	equ	$122
spr1pth	equ	$124
spr1ptl	equ	$126
spr2pth	equ	$128
spr2ptl	equ	$12a
spr3pth	equ	$12c
spr3ptl	equ	$12e
spr4pth	equ	$130
spr4ptl	equ	$132
spr5pth	equ	$134
spr5ptl	equ	$136
spr6pth	equ	$138
spr6ptl	equ	$13a
spr7pth	equ	$13c
spr7ptl	equ	$13e
spr0pos	equ	$140
spr1pos	equ	$148
spr2pos	equ	$150
spr3pos	equ	$158
spr4pos	equ	$160
spr5pos	equ	$168
spr6pos	equ	$170
spr7pos	equ	$178
spr0ctl	equ	$142
spr1ctl	equ	$14a
spr2ctl	equ	$152
spr3ctl	equ	$15a
spr4ctl	equ	$162
spr5ctl	equ	$16a
spr6ctl	equ	$172
spr7ctl	equ	$17a
spr0data equ	$144
spr1data equ	$14c
spr2data equ	$154
spr3data equ	$15c
spr4data equ	$164
spr5data equ	$16c
spr6data equ	$174
spr7data equ	$17c
spr0datb equ	$146
spr1datb equ	$14e
spr2datb equ	$156
spr3datb equ	$15e
spr4datb equ	$166
spr5datb equ	$16e
spr6datb equ	$176
spr7datb equ	$17e
color0	equ	$180
color1	equ	$182
color2	equ	$184
color4	equ	$188
color8	equ	$190
color16	equ	$1a0




;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

screen.mem	dc.l	0

gfxbase		dc.l	0
old.ints	dc.w	0
old.level3	dc.l	0
old.dbz		dc.l	0
next.frame	dc.b	0,0




;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

graf.name	dc.b	'graphics.library',0
		even




;""""""""""""""
;" MUSIC DATA "
;"	      "
;""""""""""""""

mt_data	incbin	DH0:Music/Modules/MOD.heavyzing
