	section	StuntCar,code_c
	opt	a+


MIN.FRAMES	equ	1


	move.l	4.w,a6
	jsr	-132(a6)		Forbid

	move.l	#2*4*40*200,d0
	move.l	#$10002,d1		clear chip
	jsr	-198(a6)		AllocMem
	move.l	d0,screen.mem
	beq	exit_now

	move.l	d0,screen1
	add.l	#4*40*200,d0
	move.l	d0,screen2

	moveq	#0,d0
	lea	graf.name(pc),a1
	jsr	-552(a6)		OpenLibrary
	move.l	d0,gfxbase
	beq	exit_freemem


;"""""""""""""""""""""""""
;" INITIALISE INTERRUPTS "
;"			 "
;"""""""""""""""""""""""""

	lea	$dff000.l,a6
	move.w	intenar(a6),old.ints	save system interrupt status

	move.w	#$7fff,intena(a6)	disable all interrupts

	move.l	$6c.w,old.level3
	move.l	$70.w,old.level4
	move.l	#new.level3,$6c.w
	move.l	#new.level4,$70.w

	move.w	#$c030,intena(a6)	enable copper and vertb interrupt


;"""""""""""""""""""""""""""""
;" INITIALISE SCREEN DISPLAY "
;"			     "
;"""""""""""""""""""""""""""""

	move.w	#$07ff,dmacon(a6)	DMA off

	move.w	#$4200,bplcon0(a6)	initialise screen
	move.w	#$3c81,diwstrt(a6)
	move.w	#$04c1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	moveq	#0,d0
	move.w	d0,bplcon1(a6)
	move.w	#%100100,bplcon2(a6)
	move.w	d0,bpl1mod(a6)
	move.w	d0,bpl2mod(a6)

	move.l	(screen2).l,visible.screen
	jsr	(set.copper.list).l	initialise copper

	move.l	#copper.list,cop1lch(a6)
	move.w	d0,copjmp1(a6)

	move.w	#$8380,dmacon(a6)	DMA on
	move.w	#$00ff,adkcon(a6)


;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

	move.l	(screen2).l,a0
	lea	16*40+4(a0),a0
	move.l	a0,current.scene

	move.b	#$b,B.5eb79
	move.l	#$3adf2a96,random.seed
	move.b	#$48,B.63ce0
	move.b	#$48,B.63ce0+1
	move.b	#6,B.63ce2
	move.l	#far.section0+714,L.66102

	moveq	#0,d0
	moveq	#0,d1
	jsr	(race.and.practise).l


;""""""""""""""""
;" EXIT ROUTINE	"
;"		"
;""""""""""""""""

	lea	$dff000.l,a6
	move.w	#$7fff,intena(a6)	disable all interrupts

	move.l	old.level3(pc),$6c.w
	move.l	old.level4(pc),$70.w

	move.w	old.ints(pc),d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status

	move.w	#$07ff,dmacon(a6)	DMA off

	move.l	gfxbase(pc),a1
	move.l	38(a1),cop1lch(a6)	restore system copper

	move.w	#$87f0,dmacon(a6)	DMA on

	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary

exit_freemem
	move.l	#2*4*40*200,d0
	move.l	(screen.mem).l,a1
	jsr	-210(a6)		FreeMem

exit_now
	jsr	-138(a6)		Permit

	moveq	#0,d0
	rts


;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

gfxbase		dc.l	0
old.ints	dc.w	0
old.level3	dc.l	0
old.level4	dc.l	0
next.frame	dc.b	0,0


;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

graf.name	dc.b	'graphics.library',0
		even


;"""""""""""""""
;" SUBROUTINES "
;"	       "
;"""""""""""""""

frames.per.sec
	move.b	$bfda00.l,d1
	move.b	$bfd900.l,d1
	lsl.w	#8,d1
	move.b	$bfd800.l,d1

	move.w	d1,d0
	sub.w	old.pulses(pc),d0
	move.w	d1,old.pulses

	move.l	#156250,d1
	divu	d0,d1
	and.l	#$ffff,d1

	move.b	#$80,second.screen
	move.b	#21,print.column
	move.b	#18,print.row
	move.b	#0,print.fine.x
	move.b	#0,print.fine.y
	move.b	#'0',d2
	lea	(print.character).l,a1

	moveq	#100,d4
	move.l	d1,d3
	divu	d4,d3
	move.b	d3,d0
	add.b	d2,d0
	jsr	(a1)
	mulu	d4,d3
	sub.l	d3,d1

	moveq	#10,d4
	move.l	d1,d3
	divu	d4,d3
	move.b	d3,d0
	add.b	d2,d0
	jsr	(a1)
	mulu	d4,d3
	sub.l	d3,d1

	move.b	#'.',d0
	jsr	(a1)

	move.b	d1,d0
	add.b	d2,d0
	jsr	(a1)

	move.b	#0,second.screen
	rts


old.pulses
	dc.w	0


;"""""""""""""""""""
;" STUNT CAR RACER "
;"		   "
;"""""""""""""""""""

edge.space
	ds.w	4500
end.edge.space
	ds.w	500


;"""""""""""""""""""
;" THE COPPER LIST "
;"		   "
;"""""""""""""""""""

copper.list
	dc.w	bpl1pth,0
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

colour0	dc.w	$180,0
	dc.w	$182,0
	dc.w	$184,0
	dc.w	$186,0
	dc.w	$188,0
	dc.w	$18a,0
	dc.w	$18c,0
	dc.w	$18e,0
	dc.w	$190,0
	dc.w	$192,0
	dc.w	$194,0
	dc.w	$196,0
	dc.w	$198,0
	dc.w	$19a,0
	dc.w	$19c,0
	dc.w	$19e,0

colour16
	dc.w	$1a0,0
	dc.w	$1a2,0
	dc.w	$1a4,0
	dc.w	$1a6,0
	dc.w	$1a8,0
	dc.w	$1aa,0
	dc.w	$1ac,0
	dc.w	$1ae,0
	dc.w	$1b0,0
	dc.w	$1b2,0
	dc.w	$1b4,0
	dc.w	$1b6,0
	dc.w	$1b8,0
	dc.w	$1ba,0
	dc.w	$1bc,0
	dc.w	$1be,0

sprite0	dc.w	spr0pth,0
	dc.w	spr0ptl,0
	dc.w	spr1pth,0
	dc.w	spr1ptl,0
	dc.w	spr2pth,0
	dc.w	spr2ptl,0
	dc.w	spr3pth,0
	dc.w	spr3ptl,0
	dc.w	spr4pth,0
	dc.w	spr4ptl,0
	dc.w	spr5pth,0
	dc.w	spr5ptl,0
	dc.w	spr6pth,0
	dc.w	spr6ptl,0
	dc.w	spr7pth,0
	dc.w	spr7ptl,0

	dc.w	$fa01,$ff00
	dc.w	intreq,$8010
	dc.w	$ffff,$fffe


st.colours
	ds.w	16
st.dest.colours
	ds.w	16


key.array	ds.w	64


;""""""""""""""
;" INTERRUPTS "
;"	      "
;""""""""""""""

new.level3
	btst	#4,intreqr+1+$dff000.l
	beq.s	test.vertb
	bsr	copper.interrupt
	move.w	#$10,intreq+$dff000

test.vertb
	btst	#5,intreqr+1+$dff000.l
	beq.s	end.level3
	bsr.s	vertb.interrupt
	move.w	#$20,intreq+$dff000
	rte

end.level3
	move.w	#$40,intreq+$dff000
	rte


new.level4
	btst	#7,intreqr+1+$dff000.l
	beq.s	test.aud1
	bsr	aud0.interrupt
	move.w	#$80,intreq+$dff000

test.aud1
	btst	#0,intreqr+$dff000.l
	beq.s	test.aud2
	bsr	aud1.interrupt
	move.w	#$100,intreq+$dff000

test.aud2
	btst	#1,intreqr+$dff000.l
	beq.s	test.aud3
	bsr	aud2.interrupt
	move.w	#$200,intreq+$dff000

test.aud3
	btst	#2,intreqr+$dff000.l
	beq.s	end.level4
	bsr.s	aud3.interrupt
	move.w	#$400,intreq+$dff000

end.level4
	rte


vertb.interrupt
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	d1
	clr.w	d2
	jsr	(frames.wheels.engine).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts


copper.interrupt
	tst.b	show.new.screen
	beq.s	ci2

	movem.l	d0-d7/a0-a6,-(sp)
	bsr	set.copper.list
	clr.b	show.new.screen

	tst.b	adjust.sprites
	beq.s	ci1

	clr.b	adjust.sprites
ci1	movem.l	(sp)+,d0-d7/a0-a6
ci2	rts


B.f256	dc.b	0
B.f257	dc.b	0


aud0.interrupt
	move.w	W.f472,aud0per+$dff000
	rts

aud1.interrupt
	movem.l	d0/a0,-(sp)
	move.w	#4,d0
	bra.s	aud.interrupt

aud2.interrupt
	movem.l	d0/a0,-(sp)
	move.w	#8,d0
	bra.s	aud.interrupt

aud3.interrupt
	movem.l	d0/a0,-(sp)
	move.w	#12,d0

aud.interrupt
	lea	channel.bits,a0
	lea	(a0,d0.w),a0
	move.w	dmaconr+$dff000.l,d0
	and.w	2(a0),d0
	bne.s	ai2

	move.w	2(a0),d0
	and.w	W.f3ee,d0
	bne.s	ai3

	move.w	2(a0),d0
	asl.w	#7,d0
	move.w	d0,intena+$dff000
	bra.s	ai3

ai2	addq.w	#1,(a0)
	cmp.w	#2,(a0)
	blt.s	ai3

	move.w	2(a0),d0
	move.w	d0,dmacon+$dff000
	asl.w	#7,d0
	move.w	d0,intena+$dff000

ai3	movem.l	(sp)+,d0/a0
	rts


channel.bits
	dc.w	0,1
	dc.w	0,2
	dc.w	0,4
	dc.w	0,8

B.f360	dc.b	0,0

sound.effect
	movem.l	d0/d3-d4/a0-a1,-(sp)
	and.w	#7,d0
	asl.w	#4,d0
	lea	effect.table,a0
	lea	(a0,d0.w),a0
	move.w	12(a0),d0
	asl.w	#2,d0
	lea	channel.bits,a1
	move.w	2(a1,d0.w),d3
	move.w	d3,d4
	asl.w	#7,d4
	move.w	d4,intena+$dff000
	move.w	d3,dmacon+$dff000
	move.w	#0,(a1,d0.w)
	asl.w	#2,d0
	lea	$dff000.l,a1
	lea	(a1,d0.w),a1
	move.l	(a0),aud0lch(a1)
	move.l	4(a0),d0
	lsr.l	#1,d0
	move.w	d0,aud0len(a1)
	move.w	10(a0),aud0vol(a1)
	move.w	8(a0),aud0per(a1)
	move.w	d3,W.f3ee
	bset	#15,d3
	move.w	d4,intreq+$dff000
	bset	#15,d4
	move.w	d4,intena+$dff000
	move.w	d3,dmacon+$dff000
	clr.w	W.f3ee
	movem.l	(sp)+,d0/d3-d4/a0-a1
	rts


W.f3ee	dc.w	0


sound.off
	move.w	#$f,dmacon+$dff000
	move.w	#$780,intena+$dff000
	rts


W.f472	dc.w	0


engine.pitch.table
;	address, length (in words)

	dc.l	tick.over,1586
	dc.l	engine.pitch2,793
	dc.l	engine.pitch3,396
	dc.l	engine.pitch4,198
	dc.l	engine.pitch5,99
	dc.l	engine.pitch6,49
	dc.l	engine.pitch7,24
	dc.l	engine.pitch8,12
	dc.l	0


chime	;incbin	StuntCarRacer/sound_data/chime.bin
wreck	incbin	StuntCarRacer/sound_data/wreck.bin
hit.car	incbin	StuntCarRacer/sound_data/hit.car.bin
grounded	incbin	StuntCarRacer/sound_data/grounded.bin
creak	;incbin	StuntCarRacer/sound_data/creak.bin
smash	;incbin	StuntCarRacer/sound_data/smash.bin
off.road	;incbin	StuntCarRacer/sound_data/off.road.bin
tick.over	incbin	StuntCarRacer/sound_data/tick.over.bin
engine.pitch2	incbin	StuntCarRacer/sound_data/engine.pitch2.bin
engine.pitch3	incbin	StuntCarRacer/sound_data/engine.pitch3.bin
engine.pitch4	incbin	StuntCarRacer/sound_data/engine.pitch4.bin
engine.pitch5	incbin	StuntCarRacer/sound_data/engine.pitch5.bin
engine.pitch6	incbin	StuntCarRacer/sound_data/engine.pitch6.bin
engine.pitch7	incbin	StuntCarRacer/sound_data/engine.pitch7.bin
engine.pitch8	incbin	StuntCarRacer/sound_data/engine.pitch8.bin


effect.table
;	address, length (in bytes)
;	period, volume, channel no.

	dc.l	chime,2436
	dc.w	150,30,1,0

	dc.l	wreck,9032
	dc.w	194,64,1,0

	dc.l	hit.car,8014
	dc.w	238,56,1,0

	dc.l	grounded,3108
	dc.w	400,28,1,0

	dc.l	creak,5170
	dc.w	238,28,2,0

	dc.l	smash,8430
	dc.w	280,64,3,0

	dc.l	off.road,7120
	dc.w	470,64,1,0

	dc.l	tick.over,3172
	dc.w	300,48,0,0


read.joystick
	movem.l	d3-d4/a0,-(sp)
	clr.b	d4
	move.w	joy1dat+$dff000.l,d0
	move.w	d0,d3
	lsr.w	#1,d3
	eor.w	d0,d3
	btst	#8,d3
	beq.s	not.forward
	bset	#0,d4
not.forward
	btst	#0,d3
	beq.s	not.back
	bset	#1,d4
not.back
	btst	#9,d0
	beq.s	not.left
	bset	#2,d4
not.left
	btst	#1,d0
	beq.s	not.right
	bset	#3,d4
not.right
	lea	$bfe001.l,a0
	and.b	#$7f,$200(a0)
	btst	#7,(a0)
	bne.s	not.fire
	bset	#4,d4
not.fire
	eor.b	#$ff,d4
	move.b	d4,joystick.state
	movem.l	(sp)+,d3-d4/a0
	rts


set.current.scene
	move.l	screen2,d3
	add.l	#16*40+4,d3
	move.l	d3,current.scene
	move.l	screen1,visible.screen
	move.b	#$80,show.new.screen
	rts


set.copper.list
	movem.l	d3-d4,-(sp)
	move.l	visible.screen,d0
	move.l	#copper.list,a0
	move.w	#4-1,d4

.loop	move.l	d0,d3
	swap	d3
	move.w	d3,2(a0)
	move.w	d0,6(a0)
	addq.l	#8,a0
	add.l	#8000,d0
	dbra	d4,.loop
	movem.l	(sp)+,d3-d4
	rts


visible.screen	dc.l	0
show.new.screen	dc.b	0,0

joystick.state	dc.b	0,0


copy.st.dest.colours
	move.l	#st.dest.colours,a0
	move.w	#16-1,d0
.copy	move.w	(a1)+,(a0)+
	dbra	d0,.copy
	rts


set.amiga.colours
	move.l	#st.colours,a1
	move.l	#colour0+2,a0
	move.w	#16-1,d4

set.blue
	move.w	(a1)+,d3
	asl.w	#1,d3

	move.b	d3,d0
	and.b	#$f,d0
	beq.s	set.green
	or.b	#1,d3

set.green
	move.b	d3,d0
	and.b	#$f0,d0
	beq.s	set.red
	or.b	#$10,d3

set.red	move.w	d3,d0
	and.w	#$f00,d0
	beq.s	set.copper.colour
	or.w	#$100,d3

set.copper.colour
	move.w	d3,(a0)+
	addq.l	#2,a0
	dbra	d4,set.blue
	rts


road.aerial.map
	dc.b $ff,$19,$18,$17,$16,$15,$14,$13,$12,$11,$10,$0f,$0e,$0d,$0c,$ff
	dc.b $1a,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$0b
	dc.b $1b,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$0a
	dc.b $ff,$1c,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$09
	dc.b $ff,$ff,$1d,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$08
	dc.b $ff,$ff,$ff,$1e,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$07
	dc.b $ff,$ff,$ff,$ff,$1f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$06
	dc.b $ff,$ff,$ff,$ff,$ff,$20,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$05
	dc.b $ff,$ff,$ff,$ff,$ff,$ff,$21,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$04
	dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$22,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$03
	dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$23,$ff,$ff,$ff,$ff,$ff,$ff,$02
	dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$24,$ff,$ff,$ff,$ff,$ff,$01
	dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$25,$ff,$ff,$ff,$ff,$00
	dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$26,$ff,$ff,$ff,$2b
	dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$27,$ff,$ff,$2a
	dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$28,$29,$ff


TAB.1c380
	ds.w	32
TAB.1c3c0
	ds.w	32
TAB.1c400
	ds.w	32
TAB.1c440
	ds.w	32
	ds.w	32


near.left.road.section.IDs
	dc.b	$6a,$6b,$24,$50,$50,$25,$00,$00
	dc.b	$19,$63,$04,$65,$68,$64,$69,$17
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$03,$16,$00,$19,$04,$00,$00,$00
	dc.b	$28,$29,$00,$2a,$2b,$00,$00,$09
	dc.b	$16,$00,$1b,$04,$0c,$03,$00,$00
	dc.b	$04,$17,$1a,$03,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00


near.right.road.section.IDs
	dc.b	$6a,$6b,$24,$50,$50,$25,$00,$00
	dc.b	$19,$63,$64,$66,$e7,$04,$69,$17
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$04,$17,$80,$18,$03,$80,$00,$80
	dc.b	$28,$a9,$00,$aa,$2b,$80,$00,$8a
	dc.b	$17,$00,$9a,$03,$0b,$04,$00,$00
	dc.b	$03,$16,$9b,$04,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00


near.road.section.bytes
	dc.b	$cf,$bf,$af,$9f,$8f,$7f,$6f,$5f
	dc.b	$4f,$3f,$2f,$1f,$0e,$0d,$0c,$0b
	dc.b	$0a,$09,$08,$07,$06,$05,$04,$03
	dc.b	$02,$01,$10,$20,$31,$42,$53,$64
	dc.b	$75,$86,$97,$a8,$b9,$ca,$db,$ec
	dc.b	$fd,$fe,$ef,$df,$60,$50,$40,$30
	dc.b	$20,$10,$01,$02,$03,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00


near.road.section.bytes2

; Bottom four bits are the offset number for the road.section.words table

	dc.b	$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0
	dc.b	$a0,$a0,$80,$86,$57,$c0,$e0,$e0
	dc.b	$e0,$e0,$e0,$e0,$e0,$e0,$e0,$e0
	dc.b	$c0,$c6,$b7,$01,$94,$2a,$2a,$2a
	dc.b	$2a,$2a,$2a,$2a,$2a,$2a,$2a,$04
	dc.b	$d3,$66,$17,$80,$11,$80,$a0,$a0
	dc.b	$80,$87,$d6,$40,$60,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00


near.left.road.section.words
	dc.w	$0280,$0280,$0780,$0a60,$1260,$1a60,$1d40,$1d40
	dc.w	$1ce0,$1920,$17a0,$1380,$0ea0,$0660,$0560,$0500
	dc.w	$0500,$0500,$0500,$0500,$0500,$0500,$0500,$0500
	dc.w	$0500,$0700,$0760,$0700,$0500,$0500,$0500,$0500
	dc.w	$0500,$0500,$0500,$0500,$0500,$0500,$0500,$0500
	dc.w	$0700,$0760,$0700,$0500,$0320,$0340,$0540,$0540
	dc.w	$0340,$02e0,$02e0,$0340,$0540,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000


near.right.road.section.words
	dc.w	$0280,$0280,$0780,$0a60,$1260,$1a60,$1d40,$1d40
	dc.w	$1ce0,$1920,$1160,$0ec0,$0aa0,$08a0,$0560,$0500
	dc.w	$0500,$0500,$0500,$0500,$0500,$0500,$0500,$0500
	dc.w	$0300,$02a0,$02a0,$02a0,$0300,$0500,$0500,$0500
	dc.w	$0500,$0500,$0500,$0500,$0500,$0500,$0500,$0300
	dc.w	$02a0,$02a0,$02a0,$0300,$0740,$0540,$0540,$0540
	dc.w	$0540,$0740,$0740,$0540,$0540,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000


opponent.appear.values
	dc.w	$0000,$0100,$0200,$0300,$0400,$0500,$0600,$0700
	dc.w	$0800,$0900,$0a00,$0b00,$0c20,$0d40,$0e40,$0f40
	dc.w	$1040,$1140,$1240,$1340,$1440,$1540,$1640,$1740
	dc.w	$1840,$1940,$1a60,$1b80,$1c80,$1e20,$1f80,$20e0
	dc.w	$2240,$23a0,$2500,$2660,$27c0,$2920,$2a80,$2be0
	dc.w	$2d80,$2e80,$2fa0,$30c0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000


	ds.w	32
DAT.1c8e8
	ds.w	16
DAT.1c908
	ds.w	12
DAT.1c920
	ds.w	12
DAT.1c938
	ds.w	12


	dc.w	0


opponent.acceleration.values
	dc.b	$76,$6c,$62,$58,$7a,$7a,$70,$66
	dc.b	$5c,$52,$48,$48,$48,$7a,$7a,$7a
	dc.b	$7a,$7a,$7a,$7a,$70,$66,$5c,$52
	dc.b	$48,$48,$48,$48,$78,$6e,$64,$5a
	dc.b	$50,$46,$7a,$70,$66,$5c,$52,$48
	dc.b	$48,$48,$48,$7c,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00


	dc.b	$7f,$5a,$4c,$55,$1b,$1b,$1b,$1b,$1b,$1b,$1b,$1b
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11

	dc.b	0
B.1c9cf	dc.b	10
B.1c9d0	dc.b	0,0

	dc.b	$ad,$a5,$7d,$92,$89,$5f,$58,$5c,$58,$4d,$23,$2b
	dc.b	2,0,0,2,0,0,1,1,0,2,0,0
	dc.b	2,0,0,0,2,0,0,2,0,2,0,0
	dc.b	2,2,0,2,2,0,2,2,0,2,2,0
	dc.b	6,0,0,4,2,0,2,4,0,6,0,0
	dc.b	0,1,2,3,4,5,7,6,8,9,11,10

number.of.road.sections	dc.b	44
B.1ca1b	dc.b	15
B.1ca1c	dc.b	15,37
W.1ca1e	dc.w	$31c0
nitro.reserve	dc.b	87,8
B.1ca22	dc.b	$80,0
	dc.b	0,9
	dc.b	9,9
	dc.b	11
B.1ca29	dc.b	9
	dc.b	6,5
B.1ca2c	dc.b	34
B.1ca2d	dc.b	47
	dc.b	2
B.1ca2f	dc.b	2
	dc.w	0
B.1ca32	dc.b	10
B.1ca33	dc.b	0
	dc.b	$80,2
DAT.1ca36
	dcb.b	12,$a


sin.table
	dc.w	$ffff,$fffe,$fffb,$fff4,$ffec,$ffe1,$ffd3,$ffc3
	dc.w	$ffb1,$ff9c,$ff84,$ff6a,$ff4e,$ff2f,$ff0e,$feea
	dc.w	$fec4,$fe9b,$fe70,$fe43,$fe13,$fde0,$fdab,$fd74
	dc.w	$fd3a,$fcfe,$fcbf,$fc7e,$fc3b,$fbf5,$fbac,$fb61
	dc.w	$fb14,$fac5,$fa73,$fa1e,$f9c7,$f96e,$f912,$f8b4
	dc.w	$f853,$f7f1,$f78b,$f724,$f6ba,$f64d,$f5de,$f56d
	dc.w	$f4fa,$f484,$f40b,$f391,$f314,$f294,$f213,$f18f
	dc.w	$f109,$f080,$eff5,$ef68,$eed8,$ee46,$edb2,$ed1c
	dc.w	$ec83,$ebe8,$eb4b,$eaab,$ea09,$e965,$e8bf,$e816
	dc.w	$e76b,$e6be,$e60f,$e55e,$e4aa,$e3f4,$e33c,$e282
	dc.w	$e1c5,$e106,$e046,$df83,$debe,$ddf6,$dd2d,$dc61
	dc.w	$db94,$dac4,$d9f2,$d91e,$d848,$d770,$d695,$d5b9
	dc.w	$d4db,$d3fa,$d318,$d233,$d14d,$d064,$cf7a,$ce8d
	dc.w	$cd9f,$ccae,$cbbb,$cac7,$c9d1,$c8d8,$c7de,$c6e2
	dc.w	$c5e4,$c4e3,$c3e2,$c2de,$c1d8,$c0d0,$bfc7,$bebc
	dc.w	$bdae,$bca0,$bb8f,$ba7c,$b968,$b852,$b73a,$b620
	dc.w	$b504,$b3e7,$b2c8,$b1a8,$b085,$af61,$ae3b,$ad14
	dc.w	$abeb,$aac0,$a994,$a866,$a736,$a605,$a4d2,$a39d
	dc.w	$a267,$a12f,$9ff6,$9ebc,$9d7f,$9c42,$9b02,$99c2
	dc.w	$987f,$973c,$95f6,$94b0,$9368,$921e,$90d3,$8f87
	dc.w	$8e39,$8cea,$8b9a,$8a48,$88f5,$87a1,$864b,$84f4
	dc.w	$839c,$8242,$80e7,$7f8b,$7e2e,$7cd0,$7b70,$7a0f
	dc.w	$78ad,$774a,$75e5,$7480,$7319,$71b1,$7049,$6edf
	dc.w	$6d74,$6c08,$6a9b,$692d,$67bd,$664d,$64dc,$636a
	dc.w	$61f7,$6083,$5f0e,$5d98,$5c22,$5aaa,$5931,$57b8
	dc.w	$563e,$54c3,$5347,$51ca,$504d,$4ecf,$4d50,$4bd0
	dc.w	$4a50,$48ce,$474d,$45ca,$4447,$42c3,$413e,$3fb9
	dc.w	$3e33,$3cad,$3b26,$399f,$3817,$368e,$3505,$337b
	dc.w	$31f1,$3066,$2edb,$2d50,$2bc4,$2a37,$28aa,$271d
	dc.w	$2590,$2402,$2273,$20e5,$1f56,$1dc7,$1c37,$1aa7
	dc.w	$1917,$1787,$15f6,$1466,$12d5,$1144,$0fb2,$0e21
	dc.w	$0c8f,$0afe,$096c,$07da,$0648,$04b6,$0324,$0192
	dc.w	$0000,$0000


TAB.1cc46
	dc.w	$0000,$0005,$000a,$000f,$0014,$0019,$001f,$0024
	dc.w	$0029,$002e,$0033,$0038,$003d,$0042,$0047,$004c
	dc.w	$0051,$0057,$005c,$0061,$0066,$006b,$0070,$0075
	dc.w	$007a,$007f,$0084,$008a,$008f,$0094,$0099,$009e
	dc.w	$00a3,$00a8,$00ad,$00b2,$00b7,$00bc,$00c2,$00c7
	dc.w	$00cc,$00d1,$00d6,$00db,$00e0,$00e5,$00ea,$00ef
	dc.w	$00f4,$00fa,$00ff,$0104,$0109,$010e,$0113,$0118
	dc.w	$011d,$0122,$0127,$012c,$0131,$0137,$013c,$0141
	dc.w	$0146,$014b,$0150,$0155,$015a,$015f,$0164,$0169
	dc.w	$016f,$0174,$0179,$017e,$0183,$0188,$018d,$0192
	dc.w	$0197,$019c,$01a1,$01a6,$01ac,$01b1,$01b6,$01bb
	dc.w	$01c0,$01c5,$01ca,$01cf,$01d4,$01d9,$01de,$01e3
	dc.w	$01e9,$01ee,$01f3,$01f8,$01fd,$0202,$0207,$020c
	dc.w	$0211,$0216,$021b,$0220,$0226,$022b,$0230,$0235
	dc.w	$023a,$023f,$0244,$0249,$024e,$0253,$0258,$025d
	dc.w	$0262,$0268,$026d,$0272,$0277,$027c,$0281,$0286
	dc.w	$028b,$0290,$0295,$029a,$029f,$02a4,$02a9,$02af
	dc.w	$02b4,$02b9,$02be,$02c3,$02c8,$02cd,$02d2,$02d7
	dc.w	$02dc,$02e1,$02e6,$02eb,$02f0,$02f6,$02fb,$0300
	dc.w	$0305,$030a,$030f,$0314,$0319,$031e,$0323,$0328
	dc.w	$032d,$0332,$0337,$033c,$0341,$0347,$034c,$0351
	dc.w	$0356,$035b,$0360,$0365,$036a,$036f,$0374,$0379
	dc.w	$037e,$0383,$0388,$038d,$0392,$0397,$039c,$03a2
	dc.w	$03a7,$03ac,$03b1,$03b6,$03bb,$03c0,$03c5,$03ca
	dc.w	$03cf,$03d4,$03d9,$03de,$03e3,$03e8,$03ed,$03f2
	dc.w	$03f7,$03fc,$0401,$0407,$040c,$0411,$0416,$041b
	dc.w	$0420,$0425,$042a,$042f,$0434,$0439,$043e,$0443
	dc.w	$0448,$044d,$0452,$0457,$045c,$0461,$0466,$046b
	dc.w	$0470,$0475,$047a,$047f,$0484,$0489,$048e,$0494
	dc.w	$0499,$049e,$04a3,$04a8,$04ad,$04b2,$04b7,$04bc
	dc.w	$04c1,$04c6,$04cb,$04d0,$04d5,$04da,$04df,$04e4
	dc.w	$04e9,$04ee,$04f3,$04f8,$04fd,$0502,$0507,$050c
	dc.w	$0511,$0516,$051b,$0520,$0525,$052a,$052f,$0534
	dc.w	$0539,$053e,$0543,$0548,$054d,$0552,$0557,$055c
	dc.w	$0561,$0566,$056b,$0570,$0575,$057a,$057f,$0584
	dc.w	$0589,$058e,$0593,$0598,$059d,$05a2,$05a7,$05ac
	dc.w	$05b1,$05b6,$05bb,$05c0,$05c5,$05ca,$05cf,$05d4
	dc.w	$05d9,$05de,$05e3,$05e8,$05ed,$05f2,$05f7,$05fc
	dc.w	$0601,$0606,$060b,$0610,$0615,$061a,$061f,$0624
	dc.w	$0629,$062e,$0633,$0638,$063d,$0642,$0647,$064c
	dc.w	$0651,$0656,$065b,$0660,$0665,$066a,$066e,$0673
	dc.w	$0678,$067d,$0682,$0687,$068c,$0691,$0696,$069b
	dc.w	$06a0,$06a5,$06aa,$06af,$06b4,$06b9,$06be,$06c3
	dc.w	$06c8,$06cd,$06d2,$06d7,$06dc,$06e1,$06e5,$06ea
	dc.w	$06ef,$06f4,$06f9,$06fe,$0703,$0708,$070d,$0712
	dc.w	$0717,$071c,$0721,$0726,$072b,$0730,$0735,$0739
	dc.w	$073e,$0743,$0748,$074d,$0752,$0757,$075c,$0761
	dc.w	$0766,$076b,$0770,$0775,$077a,$077e,$0783,$0788
	dc.w	$078d,$0792,$0797,$079c,$07a1,$07a6,$07ab,$07b0
	dc.w	$07b5,$07b9,$07be,$07c3,$07c8,$07cd,$07d2,$07d7
	dc.w	$07dc,$07e1,$07e6,$07eb,$07ef,$07f4,$07f9,$07fe
	dc.w	$0803,$0808,$080d,$0812,$0817,$081c,$0820,$0825
	dc.w	$082a,$082f,$0834,$0839,$083e,$0843,$0848,$084c
	dc.w	$0851,$0856,$085b,$0860,$0865,$086a,$086f,$0873
	dc.w	$0878,$087d,$0882,$0887,$088c,$0891,$0896,$089a
	dc.w	$089f,$08a4,$08a9,$08ae,$08b3,$08b8,$08bd,$08c1
	dc.w	$08c6,$08cb,$08d0,$08d5,$08da,$08df,$08e3,$08e8
	dc.w	$08ed,$08f2,$08f7,$08fc,$0901,$0905,$090a,$090f
	dc.w	$0914,$0919,$091e,$0922,$0927,$092c,$0931,$0936
	dc.w	$093b,$093f,$0944,$0949,$094e,$0953,$0958,$095c
	dc.w	$0961,$0966,$096b,$0970,$0975,$0979,$097e,$0983
	dc.w	$0988,$098d,$0992,$0996,$099b,$09a0,$09a5,$09aa
	dc.w	$09ae,$09b3,$09b8,$09bd,$09c2,$09c6,$09cb,$09d0
	dc.w	$09d5,$09da,$09de,$09e3,$09e8,$09ed,$09f2,$09f6
	dc.w	$09fb,$0a00,$0a05,$0a0a,$0a0e,$0a13,$0a18,$0a1d
	dc.w	$0a22,$0a26,$0a2b,$0a30,$0a35,$0a39,$0a3e,$0a43
	dc.w	$0a48,$0a4d,$0a51,$0a56,$0a5b,$0a60,$0a64,$0a69
	dc.w	$0a6e,$0a73,$0a77,$0a7c,$0a81,$0a86,$0a8b,$0a8f
	dc.w	$0a94,$0a99,$0a9e,$0aa2,$0aa7,$0aac,$0ab1,$0ab5
	dc.w	$0aba,$0abf,$0ac4,$0ac8,$0acd,$0ad2,$0ad7,$0adb
	dc.w	$0ae0,$0ae5,$0ae9,$0aee,$0af3,$0af8,$0afc,$0b01
	dc.w	$0b06,$0b0b,$0b0f,$0b14,$0b19,$0b1e,$0b22,$0b27
	dc.w	$0b2c,$0b30,$0b35,$0b3a,$0b3f,$0b43,$0b48,$0b4d
	dc.w	$0b51,$0b56,$0b5b,$0b60,$0b64,$0b69,$0b6e,$0b72
	dc.w	$0b77,$0b7c,$0b80,$0b85,$0b8a,$0b8f,$0b93,$0b98
	dc.w	$0b9d,$0ba1,$0ba6,$0bab,$0baf,$0bb4,$0bb9,$0bbd
	dc.w	$0bc2,$0bc7,$0bcb,$0bd0,$0bd5,$0bd9,$0bde,$0be3
	dc.w	$0be7,$0bec,$0bf1,$0bf5,$0bfa,$0bff,$0c03,$0c08
	dc.w	$0c0d,$0c11,$0c16,$0c1b,$0c1f,$0c24,$0c29,$0c2d
	dc.w	$0c32,$0c37,$0c3b,$0c40,$0c45,$0c49,$0c4e,$0c53
	dc.w	$0c57,$0c5c,$0c60,$0c65,$0c6a,$0c6e,$0c73,$0c78
	dc.w	$0c7c,$0c81,$0c86,$0c8a,$0c8f,$0c93,$0c98,$0c9d
	dc.w	$0ca1,$0ca6,$0cab,$0caf,$0cb4,$0cb8,$0cbd,$0cc2
	dc.w	$0cc6,$0ccb,$0ccf,$0cd4,$0cd9,$0cdd,$0ce2,$0ce6
	dc.w	$0ceb,$0cf0,$0cf4,$0cf9,$0cfd,$0d02,$0d07,$0d0b
	dc.w	$0d10,$0d14,$0d19,$0d1e,$0d22,$0d27,$0d2b,$0d30
	dc.w	$0d34,$0d39,$0d3e,$0d42,$0d47,$0d4b,$0d50,$0d54
	dc.w	$0d59,$0d5e,$0d62,$0d67,$0d6b,$0d70,$0d74,$0d79
	dc.w	$0d7d,$0d82,$0d87,$0d8b,$0d90,$0d94,$0d99,$0d9d
	dc.w	$0da2,$0da6,$0dab,$0daf,$0db4,$0db9,$0dbd,$0dc2
	dc.w	$0dc6,$0dcb,$0dcf,$0dd4,$0dd8,$0ddd,$0de1,$0de6
	dc.w	$0dea,$0def,$0df3,$0df8,$0dfc,$0e01,$0e05,$0e0a
	dc.w	$0e0f,$0e13,$0e18,$0e1c,$0e21,$0e25,$0e2a,$0e2e
	dc.w	$0e33,$0e37,$0e3c,$0e40,$0e45,$0e49,$0e4e,$0e52
	dc.w	$0e56,$0e5b,$0e5f,$0e64,$0e68,$0e6d,$0e71,$0e76
	dc.w	$0e7a,$0e7f,$0e83,$0e88,$0e8c,$0e91,$0e95,$0e9a
	dc.w	$0e9e,$0ea3,$0ea7,$0eac,$0eb0,$0eb4,$0eb9,$0ebd
	dc.w	$0ec2,$0ec6,$0ecb,$0ecf,$0ed4,$0ed8,$0edc,$0ee1
	dc.w	$0ee5,$0eea,$0eee,$0ef3,$0ef7,$0efc,$0f00,$0f04
	dc.w	$0f09,$0f0d,$0f12,$0f16,$0f1b,$0f1f,$0f23,$0f28
	dc.w	$0f2c,$0f31,$0f35,$0f3a,$0f3e,$0f42,$0f47,$0f4b
	dc.w	$0f50,$0f54,$0f58,$0f5d,$0f61,$0f66,$0f6a,$0f6e
	dc.w	$0f73,$0f77,$0f7c,$0f80,$0f84,$0f89,$0f8d,$0f91
	dc.w	$0f96,$0f9a,$0f9f,$0fa3,$0fa7,$0fac,$0fb0,$0fb5
	dc.w	$0fb9,$0fbd,$0fc2,$0fc6,$0fca,$0fcf,$0fd3,$0fd7
	dc.w	$0fdc,$0fe0,$0fe5,$0fe9,$0fed,$0ff2,$0ff6,$0ffa
	dc.w	$0fff,$1003,$1007,$100c,$1010,$1014,$1019,$101d
	dc.w	$1021,$1026,$102a,$102e,$1033,$1037,$103b,$1040
	dc.w	$1044,$1048,$104d,$1051,$1055,$105a,$105e,$1062
	dc.w	$1067,$106b,$106f,$1073,$1078,$107c,$1080,$1085
	dc.w	$1089,$108d,$1092,$1096,$109a,$109e,$10a3,$10a7
	dc.w	$10ab,$10b0,$10b4,$10b8,$10bc,$10c1,$10c5,$10c9
	dc.w	$10ce,$10d2,$10d6,$10da,$10df,$10e3,$10e7,$10eb
	dc.w	$10f0,$10f4,$10f8,$10fd,$1101,$1105,$1109,$110e
	dc.w	$1112,$1116,$111a,$111f,$1123,$1127,$112b,$1130
	dc.w	$1134,$1138,$113c,$1140,$1145,$1149,$114d,$1151
	dc.w	$1156,$115a,$115e,$1162,$1166,$116b,$116f,$1173
	dc.w	$1177,$117c,$1180,$1184,$1188,$118c,$1191,$1195
	dc.w	$1199,$119d,$11a1,$11a6,$11aa,$11ae,$11b2,$11b6
	dc.w	$11bb,$11bf,$11c3,$11c7,$11cb,$11cf,$11d4,$11d8
	dc.w	$11dc,$11e0,$11e4,$11e9,$11ed,$11f1,$11f5,$11f9
	dc.w	$11fd,$1202,$1206,$120a,$120e,$1212,$1216,$121a
	dc.w	$121f,$1223,$1227,$122b,$122f,$1233,$1237,$123c
	dc.w	$1240,$1244,$1248,$124c,$1250,$1254,$1259,$125d
	dc.w	$1261,$1265,$1269,$126d,$1271,$1275,$127a,$127e
	dc.w	$1282,$1286,$128a,$128e,$1292,$1296,$129a,$129f
	dc.w	$12a3,$12a7,$12ab,$12af,$12b3,$12b7,$12bb,$12bf
	dc.w	$12c3,$12c7,$12cc,$12d0,$12d4,$12d8,$12dc,$12e0
	dc.w	$12e4,$12e8,$12ec,$12f0,$12f4,$12f8,$12fc,$1301
	dc.w	$1305,$1309,$130d,$1311,$1315,$1319,$131d,$1321
	dc.w	$1325,$1329,$132d,$1331,$1335,$1339,$133d,$1341
	dc.w	$1345,$1349,$134d,$1351,$1355,$135a,$135e,$1362
	dc.w	$1366,$136a,$136e,$1372,$1376,$137a,$137e,$1382
	dc.w	$1386,$138a,$138e,$1392,$1396,$139a,$139e,$13a2
	dc.w	$13a6,$13aa,$13ae,$13b2,$13b6,$13ba,$13be,$13c2
	dc.w	$13c6,$13ca,$13ce,$13d2,$13d6,$13da,$13de,$13e2
	dc.w	$13e6,$13e9,$13ed,$13f1,$13f5,$13f9,$13fd,$1401
	dc.w	$1405,$1409,$140d,$1411,$1415,$1419,$141d,$1421
	dc.w	$1425,$1429,$142d,$1431,$1435,$1439,$143d,$1440
	dc.w	$1444,$1448,$144c,$1450,$1454,$1458,$145c,$1460
	dc.w	$1464,$1468,$146c,$1470,$1473,$1477,$147b,$147f
	dc.w	$1483,$1487,$148b,$148f,$1493,$1497,$149b,$149e
	dc.w	$14a2,$14a6,$14aa,$14ae,$14b2,$14b6,$14ba,$14be
	dc.w	$14c1,$14c5,$14c9,$14cd,$14d1,$14d5,$14d9,$14dd
	dc.w	$14e0,$14e4,$14e8,$14ec,$14f0,$14f4,$14f8,$14fb
	dc.w	$14ff,$1503,$1507,$150b,$150f,$1513,$1516,$151a
	dc.w	$151e,$1522,$1526,$152a,$152d,$1531,$1535,$1539
	dc.w	$153d,$1541,$1544,$1548,$154c,$1550,$1554,$1558
	dc.w	$155b,$155f,$1563,$1567,$156b,$156e,$1572,$1576
	dc.w	$157a,$157e,$1581,$1585,$1589,$158d,$1591,$1594
	dc.w	$1598,$159c,$15a0,$15a4,$15a7,$15ab,$15af,$15b3
	dc.w	$15b7,$15ba,$15be,$15c2,$15c6,$15c9,$15cd,$15d1
	dc.w	$15d5,$15d8,$15dc,$15e0,$15e4,$15e8,$15eb,$15ef
	dc.w	$15f3,$15f7,$15fa,$15fe,$1602,$1606,$1609,$160d
	dc.w	$1611,$1614,$1618,$161c,$1620,$1623,$1627,$162b
	dc.w	$162f,$1632,$1636,$163a,$163e,$1641,$1645,$1649
	dc.w	$164c,$1650,$1654,$1658,$165b,$165f,$1663,$1666
	dc.w	$166a,$166e,$1671,$1675,$1679,$167d,$1680,$1684
	dc.w	$1688,$168b,$168f,$1693,$1696,$169a,$169e,$16a1
	dc.w	$16a5,$16a9,$16ac,$16b0,$16b4,$16b7,$16bb,$16bf
	dc.w	$16c2,$16c6,$16ca,$16cd,$16d1,$16d5,$16d8,$16dc
	dc.w	$16e0,$16e3,$16e7,$16eb,$16ee,$16f2,$16f6,$16f9
	dc.w	$16fd,$1700,$1704,$1708,$170b,$170f,$1713,$1716
	dc.w	$171a,$171d,$1721,$1725,$1728,$172c,$1730,$1733
	dc.w	$1737,$173a,$173e,$1742,$1745,$1749,$174c,$1750
	dc.w	$1754,$1757,$175b,$175e,$1762,$1766,$1769,$176d
	dc.w	$1770,$1774,$1778,$177b,$177f,$1782,$1786,$1789
	dc.w	$178d,$1791,$1794,$1798,$179b,$179f,$17a2,$17a6
	dc.w	$17aa,$17ad,$17b1,$17b4,$17b8,$17bb,$17bf,$17c2
	dc.w	$17c6,$17c9,$17cd,$17d1,$17d4,$17d8,$17db,$17df
	dc.w	$17e2,$17e6,$17e9,$17ed,$17f0,$17f4,$17f7,$17fb
	dc.w	$17fe,$1802,$1806,$1809,$180d,$1810,$1814,$1817
	dc.w	$181b,$181e,$1822,$1825,$1829,$182c,$1830,$1833
	dc.w	$1837,$183a,$183e,$1841,$1845,$1848,$184c,$184f
	dc.w	$1853,$1856,$185a,$185d,$1860,$1864,$1867,$186b
	dc.w	$186e,$1872,$1875,$1879,$187c,$1880,$1883,$1887
	dc.w	$188a,$188e,$1891,$1894,$1898,$189b,$189f,$18a2
	dc.w	$18a6,$18a9,$18ad,$18b0,$18b3,$18b7,$18ba,$18be
	dc.w	$18c1,$18c5,$18c8,$18cc,$18cf,$18d2,$18d6,$18d9
	dc.w	$18dd,$18e0,$18e3,$18e7,$18ea,$18ee,$18f1,$18f5
	dc.w	$18f8,$18fb,$18ff,$1902,$1906,$1909,$190c,$1910
	dc.w	$1913,$1917,$191a,$191d,$1921,$1924,$1928,$192b
	dc.w	$192e,$1932,$1935,$1938,$193c,$193f,$1943,$1946
	dc.w	$1949,$194d,$1950,$1953,$1957,$195a,$195d,$1961
	dc.w	$1964,$1968,$196b,$196e,$1972,$1975,$1978,$197c
	dc.w	$197f,$1982,$1986,$1989,$198c,$1990,$1993,$1996
	dc.w	$199a,$199d,$19a0,$19a4,$19a7,$19aa,$19ae,$19b1
	dc.w	$19b4,$19b8,$19bb,$19be,$19c2,$19c5,$19c8,$19cc
	dc.w	$19cf,$19d2,$19d5,$19d9,$19dc,$19df,$19e3,$19e6
	dc.w	$19e9,$19ed,$19f0,$19f3,$19f6,$19fa,$19fd,$1a00
	dc.w	$1a04,$1a07,$1a0a,$1a0d,$1a11,$1a14,$1a17,$1a1b
	dc.w	$1a1e,$1a21,$1a24,$1a28,$1a2b,$1a2e,$1a31,$1a35
	dc.w	$1a38,$1a3b,$1a3e,$1a42,$1a45,$1a48,$1a4b,$1a4f
	dc.w	$1a52,$1a55,$1a58,$1a5c,$1a5f,$1a62,$1a65,$1a69
	dc.w	$1a6c,$1a6f,$1a72,$1a76,$1a79,$1a7c,$1a7f,$1a83
	dc.w	$1a86,$1a89,$1a8c,$1a8f,$1a93,$1a96,$1a99,$1a9c
	dc.w	$1a9f,$1aa3,$1aa6,$1aa9,$1aac,$1ab0,$1ab3,$1ab6
	dc.w	$1ab9,$1abc,$1ac0,$1ac3,$1ac6,$1ac9,$1acc,$1acf
	dc.w	$1ad3,$1ad6,$1ad9,$1adc,$1adf,$1ae3,$1ae6,$1ae9
	dc.w	$1aec,$1aef,$1af2,$1af6,$1af9,$1afc,$1aff,$1b02
	dc.w	$1b05,$1b09,$1b0c,$1b0f,$1b12,$1b15,$1b18,$1b1c
	dc.w	$1b1f,$1b22,$1b25,$1b28,$1b2b,$1b2e,$1b32,$1b35
	dc.w	$1b38,$1b3b,$1b3e,$1b41,$1b44,$1b48,$1b4b,$1b4e
	dc.w	$1b51,$1b54,$1b57,$1b5a,$1b5d,$1b61,$1b64,$1b67
	dc.w	$1b6a,$1b6d,$1b70,$1b73,$1b76,$1b79,$1b7d,$1b80
	dc.w	$1b83,$1b86,$1b89,$1b8c,$1b8f,$1b92,$1b95,$1b98
	dc.w	$1b9c,$1b9f,$1ba2,$1ba5,$1ba8,$1bab,$1bae,$1bb1
	dc.w	$1bb4,$1bb7,$1bba,$1bbd,$1bc1,$1bc4,$1bc7,$1bca
	dc.w	$1bcd,$1bd0,$1bd3,$1bd6,$1bd9,$1bdc,$1bdf,$1be2
	dc.w	$1be5,$1be8,$1beb,$1bee,$1bf2,$1bf5,$1bf8,$1bfb
	dc.w	$1bfe,$1c01,$1c04,$1c07,$1c0a,$1c0d,$1c10,$1c13
	dc.w	$1c16,$1c19,$1c1c,$1c1f,$1c22,$1c25,$1c28,$1c2b
	dc.w	$1c2e,$1c31,$1c34,$1c37,$1c3a,$1c3d,$1c40,$1c43
	dc.w	$1c46,$1c49,$1c4c,$1c4f,$1c52,$1c55,$1c58,$1c5b
	dc.w	$1c5e,$1c61,$1c64,$1c67,$1c6a,$1c6d,$1c70,$1c73
	dc.w	$1c76,$1c79,$1c7c,$1c7f,$1c82,$1c85,$1c88,$1c8b
	dc.w	$1c8e,$1c91,$1c94,$1c97,$1c9a,$1c9d,$1ca0,$1ca3
	dc.w	$1ca6,$1ca9,$1cac,$1caf,$1cb2,$1cb5,$1cb8,$1cbb
	dc.w	$1cbe,$1cc1,$1cc3,$1cc6,$1cc9,$1ccc,$1ccf,$1cd2
	dc.w	$1cd5,$1cd8,$1cdb,$1cde,$1ce1,$1ce4,$1ce7,$1cea
	dc.w	$1ced,$1cf0,$1cf3,$1cf5,$1cf8,$1cfb,$1cfe,$1d01
	dc.w	$1d04,$1d07,$1d0a,$1d0d,$1d10,$1d13,$1d16,$1d18
	dc.w	$1d1b,$1d1e,$1d21,$1d24,$1d27,$1d2a,$1d2d,$1d30
	dc.w	$1d33,$1d35,$1d38,$1d3b,$1d3e,$1d41,$1d44,$1d47
	dc.w	$1d4a,$1d4d,$1d4f,$1d52,$1d55,$1d58,$1d5b,$1d5e
	dc.w	$1d61,$1d64,$1d66,$1d69,$1d6c,$1d6f,$1d72,$1d75
	dc.w	$1d78,$1d7b,$1d7d,$1d80,$1d83,$1d86,$1d89,$1d8c
	dc.w	$1d8e,$1d91,$1d94,$1d97,$1d9a,$1d9d,$1da0,$1da2
	dc.w	$1da5,$1da8,$1dab,$1dae,$1db1,$1db3,$1db6,$1db9
	dc.w	$1dbc,$1dbf,$1dc2,$1dc4,$1dc7,$1dca,$1dcd,$1dd0
	dc.w	$1dd3,$1dd5,$1dd8,$1ddb,$1dde,$1de1,$1de3,$1de6
	dc.w	$1de9,$1dec,$1def,$1df1,$1df4,$1df7,$1dfa,$1dfd
	dc.w	$1dff,$1e02,$1e05,$1e08,$1e0b,$1e0d,$1e10,$1e13
	dc.w	$1e16,$1e19,$1e1b,$1e1e,$1e21,$1e24,$1e26,$1e29
	dc.w	$1e2c,$1e2f,$1e32,$1e34,$1e37,$1e3a,$1e3d,$1e3f
	dc.w	$1e42,$1e45,$1e48,$1e4a,$1e4d,$1e50,$1e53,$1e55
	dc.w	$1e58,$1e5b,$1e5e,$1e60,$1e63,$1e66,$1e69,$1e6b
	dc.w	$1e6e,$1e71,$1e74,$1e76,$1e79,$1e7c,$1e7f,$1e81
	dc.w	$1e84,$1e87,$1e8a,$1e8c,$1e8f,$1e92,$1e94,$1e97
	dc.w	$1e9a,$1e9d,$1e9f,$1ea2,$1ea5,$1ea8,$1eaa,$1ead
	dc.w	$1eb0,$1eb2,$1eb5,$1eb8,$1eba,$1ebd,$1ec0,$1ec3
	dc.w	$1ec5,$1ec8,$1ecb,$1ecd,$1ed0,$1ed3,$1ed5,$1ed8
	dc.w	$1edb,$1ede,$1ee0,$1ee3,$1ee6,$1ee8,$1eeb,$1eee
	dc.w	$1ef0,$1ef3,$1ef6,$1ef8,$1efb,$1efe,$1f00,$1f03
	dc.w	$1f06,$1f08,$1f0b,$1f0e,$1f10,$1f13,$1f16,$1f18
	dc.w	$1f1b,$1f1e,$1f20,$1f23,$1f26,$1f28,$1f2b,$1f2e
	dc.w	$1f30,$1f33,$1f36,$1f38,$1f3b,$1f3d,$1f40,$1f43
	dc.w	$1f45,$1f48,$1f4b,$1f4d,$1f50,$1f53,$1f55,$1f58
	dc.w	$1f5a,$1f5d,$1f60,$1f62,$1f65,$1f68,$1f6a,$1f6d
	dc.w	$1f6f,$1f72,$1f75,$1f77,$1f7a,$1f7c,$1f7f,$1f82
	dc.w	$1f84,$1f87,$1f8a,$1f8c,$1f8f,$1f91,$1f94,$1f97
	dc.w	$1f99,$1f9c,$1f9e,$1fa1,$1fa4,$1fa6,$1fa9,$1fab
	dc.w	$1fae,$1fb0,$1fb3,$1fb6,$1fb8,$1fbb,$1fbd,$1fc0
	dc.w	$1fc3,$1fc5,$1fc8,$1fca,$1fcd,$1fcf,$1fd2,$1fd5
	dc.w	$1fd7,$1fda,$1fdc,$1fdf,$1fe1,$1fe4,$1fe6,$1fe9
	dc.w	$1fec,$1fee,$1ff1,$1ff3,$1ff6,$1ff8,$1ffb,$1ffd


TAB.1dc46
	dc.w	$0000,$0010,$0020,$0030,$0040,$0050,$0060,$0070
	dc.w	$0080,$0090,$00a0,$00b0,$00c0,$00d0,$00e0,$00f0
	dc.w	$0100,$0110,$0120,$0130,$0140,$0150,$0160,$0170
	dc.w	$0180,$0190,$01a0,$01b0,$01c0,$01d0,$01e0,$01f0
	dc.w	$0200,$0210,$0220,$0230,$0240,$0250,$0260,$0270
	dc.w	$0280,$0290,$02a0,$02b0,$02c0,$02d0,$02e0,$02f0
	dc.w	$0300,$0310,$0320,$0330,$0340,$0350,$0360,$0370
	dc.w	$0380,$0390,$03a0,$03b0,$03c0,$03d0,$03e0,$03f0
	dc.w	$0400,$0410,$0420,$0430,$0440,$0450,$0460,$0470
	dc.w	$0480,$0490,$04a0,$04b0,$04c0,$04d0,$04e0,$04f0
	dc.w	$0500,$050f,$051f,$052f,$053f,$054f,$055f,$056f
	dc.w	$057f,$058f,$059f,$05af,$05bf,$05cf,$05df,$05ef
	dc.w	$05ff,$060f,$061f,$062f,$063f,$064f,$065f,$066f
	dc.w	$067f,$068f,$069f,$06af,$06bf,$06cf,$06df,$06ef
	dc.w	$06ff,$070f,$071f,$072f,$073f,$074e,$075e,$076e
	dc.w	$077e,$078e,$079e,$07ae,$07be,$07ce,$07de,$07ee
	dc.w	$07fe,$080e,$081e,$082e,$083e,$084e,$085e,$086e
	dc.w	$087e,$088e,$089d,$08ad,$08bd,$08cd,$08dd,$08ed
	dc.w	$08fd,$090d,$091d,$092d,$093d,$094d,$095d,$096d
	dc.w	$097d,$098d,$099d,$09ac,$09bc,$09cc,$09dc,$09ec
	dc.w	$09fc,$0a0c,$0a1c,$0a2c,$0a3c,$0a4c,$0a5c,$0a6c
	dc.w	$0a7b,$0a8b,$0a9b,$0aab,$0abb,$0acb,$0adb,$0aeb
	dc.w	$0afb,$0b0b,$0b1b,$0b2b,$0b3a,$0b4a,$0b5a,$0b6a
	dc.w	$0b7a,$0b8a,$0b9a,$0baa,$0bba,$0bca,$0bd9,$0be9
	dc.w	$0bf9,$0c09,$0c19,$0c29,$0c39,$0c49,$0c59,$0c69
	dc.w	$0c78,$0c88,$0c98,$0ca8,$0cb8,$0cc8,$0cd8,$0ce8
	dc.w	$0cf7,$0d07,$0d17,$0d27,$0d37,$0d47,$0d57,$0d67
	dc.w	$0d76,$0d86,$0d96,$0da6,$0db6,$0dc6,$0dd6,$0de5
	dc.w	$0df5,$0e05,$0e15,$0e25,$0e35,$0e45,$0e54,$0e64
	dc.w	$0e74,$0e84,$0e94,$0ea4,$0eb4,$0ec3,$0ed3,$0ee3
	dc.w	$0ef3,$0f03,$0f13,$0f22,$0f32,$0f42,$0f52,$0f62
	dc.w	$0f72,$0f81,$0f91,$0fa1,$0fb1,$0fc1,$0fd0,$0fe0
	dc.w	$0ff0,$1000,$1010,$1020,$102f,$103f,$104f,$105f
	dc.w	$106f,$107e,$108e,$109e,$10ae,$10be,$10cd,$10dd
	dc.w	$10ed,$10fd,$110d,$111c,$112c,$113c,$114c,$115b
	dc.w	$116b,$117b,$118b,$119b,$11aa,$11ba,$11ca,$11da
	dc.w	$11e9,$11f9,$1209,$1219,$1228,$1238,$1248,$1258
	dc.w	$1268,$1277,$1287,$1297,$12a7,$12b6,$12c6,$12d6
	dc.w	$12e5,$12f5,$1305,$1315,$1324,$1334,$1344,$1354
	dc.w	$1363,$1373,$1383,$1393,$13a2,$13b2,$13c2,$13d1
	dc.w	$13e1,$13f1,$1401,$1410,$1420,$1430,$143f,$144f
	dc.w	$145f,$146e,$147e,$148e,$149e,$14ad,$14bd,$14cd
	dc.w	$14dc,$14ec,$14fc,$150b,$151b,$152b,$153a,$154a
	dc.w	$155a,$1569,$1579,$1589,$1598,$15a8,$15b8,$15c7
	dc.w	$15d7,$15e7,$15f6,$1606,$1616,$1625,$1635,$1645
	dc.w	$1654,$1664,$1673,$1683,$1693,$16a2,$16b2,$16c2
	dc.w	$16d1,$16e1,$16f0,$1700,$1710,$171f,$172f,$173f
	dc.w	$174e,$175e,$176d,$177d,$178d,$179c,$17ac,$17bb
	dc.w	$17cb,$17db,$17ea,$17fa,$1809,$1819,$1828,$1838
	dc.w	$1848,$1857,$1867,$1876,$1886,$1895,$18a5,$18b5
	dc.w	$18c4,$18d4,$18e3,$18f3,$1902,$1912,$1921,$1931
	dc.w	$1940,$1950,$1960,$196f,$197f,$198e,$199e,$19ad
	dc.w	$19bd,$19cc,$19dc,$19eb,$19fb,$1a0a,$1a1a,$1a29
	dc.w	$1a39,$1a48,$1a58,$1a67,$1a77,$1a86,$1a96,$1aa5
	dc.w	$1ab5,$1ac4,$1ad4,$1ae3,$1af3,$1b02,$1b12,$1b21
	dc.w	$1b31,$1b40,$1b50,$1b5f,$1b6e,$1b7e,$1b8d,$1b9d
	dc.w	$1bac,$1bbc,$1bcb,$1bdb,$1bea,$1bf9,$1c09,$1c18
	dc.w	$1c28,$1c37,$1c47,$1c56,$1c65,$1c75,$1c84,$1c94
	dc.w	$1ca3,$1cb3,$1cc2,$1cd1,$1ce1,$1cf0,$1d00,$1d0f
	dc.w	$1d1e,$1d2e,$1d3d,$1d4c,$1d5c,$1d6b,$1d7b,$1d8a
	dc.w	$1d99,$1da9,$1db8,$1dc7,$1dd7,$1de6,$1df6,$1e05
	dc.w	$1e14,$1e24,$1e33,$1e42,$1e52,$1e61,$1e70,$1e80
	dc.w	$1e8f,$1e9e,$1eae,$1ebd,$1ecc,$1edc,$1eeb,$1efa
	dc.w	$1f09,$1f19,$1f28,$1f37,$1f47,$1f56,$1f65,$1f75
	dc.w	$1f84,$1f93,$1fa2,$1fb2,$1fc1,$1fd0,$1fe0,$1fef
	dc.w	$1ffe,$200d,$201d,$202c,$203b,$204a,$205a,$2069
	dc.w	$2078,$2087,$2097,$20a6,$20b5,$20c4,$20d4,$20e3
	dc.w	$20f2,$2101,$2110,$2120,$212f,$213e,$214d,$215c
	dc.w	$216c,$217b,$218a,$2199,$21a8,$21b8,$21c7,$21d6
	dc.w	$21e5,$21f4,$2204,$2213,$2222,$2231,$2240,$224f
	dc.w	$225f,$226e,$227d,$228c,$229b,$22aa,$22b9,$22c9
	dc.w	$22d8,$22e7,$22f6,$2305,$2314,$2323,$2332,$2342
	dc.w	$2351,$2360,$236f,$237e,$238d,$239c,$23ab,$23ba
	dc.w	$23c9,$23d8,$23e8,$23f7,$2406,$2415,$2424,$2433
	dc.w	$2442,$2451,$2460,$246f,$247e,$248d,$249c,$24ab
	dc.w	$24ba,$24c9,$24d8,$24e8,$24f7,$2506,$2515,$2524
	dc.w	$2533,$2542,$2551,$2560,$256f,$257e,$258d,$259c
	dc.w	$25ab,$25ba,$25c9,$25d8,$25e7,$25f6,$2605,$2613
	dc.w	$2622,$2631,$2640,$264f,$265e,$266d,$267c,$268b
	dc.w	$269a,$26a9,$26b8,$26c7,$26d6,$26e5,$26f4,$2703
	dc.w	$2712,$2720,$272f,$273e,$274d,$275c,$276b,$277a
	dc.w	$2789,$2798,$27a7,$27b5,$27c4,$27d3,$27e2,$27f1
	dc.w	$2800,$280f,$281d,$282c,$283b,$284a,$2859,$2868
	dc.w	$2877,$2885,$2894,$28a3,$28b2,$28c1,$28d0,$28de
	dc.w	$28ed,$28fc,$290b,$291a,$2928,$2937,$2946,$2955
	dc.w	$2964,$2972,$2981,$2990,$299f,$29ae,$29bc,$29cb
	dc.w	$29da,$29e9,$29f7,$2a06,$2a15,$2a24,$2a32,$2a41
	dc.w	$2a50,$2a5f,$2a6d,$2a7c,$2a8b,$2a99,$2aa8,$2ab7
	dc.w	$2ac6,$2ad4,$2ae3,$2af2,$2b00,$2b0f,$2b1e,$2b2c
	dc.w	$2b3b,$2b4a,$2b58,$2b67,$2b76,$2b84,$2b93,$2ba2
	dc.w	$2bb0,$2bbf,$2bce,$2bdc,$2beb,$2bfa,$2c08,$2c17
	dc.w	$2c26,$2c34,$2c43,$2c51,$2c60,$2c6f,$2c7d,$2c8c
	dc.w	$2c9b,$2ca9,$2cb8,$2cc6,$2cd5,$2ce3,$2cf2,$2d01
	dc.w	$2d0f,$2d1e,$2d2c,$2d3b,$2d49,$2d58,$2d67,$2d75
	dc.w	$2d84,$2d92,$2da1,$2daf,$2dbe,$2dcc,$2ddb,$2de9
	dc.w	$2df8,$2e06,$2e15,$2e23,$2e32,$2e40,$2e4f,$2e5d
	dc.w	$2e6c,$2e7a,$2e89,$2e97,$2ea6,$2eb4,$2ec3,$2ed1
	dc.w	$2ee0,$2eee,$2efd,$2f0b,$2f1a,$2f28,$2f36,$2f45
	dc.w	$2f53,$2f62,$2f70,$2f7f,$2f8d,$2f9b,$2faa,$2fb8
	dc.w	$2fc7,$2fd5,$2fe3,$2ff2,$3000,$300f,$301d,$302b
	dc.w	$303a,$3048,$3057,$3065,$3073,$3082,$3090,$309e
	dc.w	$30ad,$30bb,$30c9,$30d8,$30e6,$30f4,$3103,$3111
	dc.w	$311f,$312e,$313c,$314a,$3159,$3167,$3175,$3183
	dc.w	$3192,$31a0,$31ae,$31bd,$31cb,$31d9,$31e7,$31f6
	dc.w	$3204,$3212,$3220,$322f,$323d,$324b,$3259,$3268
	dc.w	$3276,$3284,$3292,$32a0,$32af,$32bd,$32cb,$32d9
	dc.w	$32e8,$32f6,$3304,$3312,$3320,$332e,$333d,$334b
	dc.w	$3359,$3367,$3375,$3383,$3392,$33a0,$33ae,$33bc
	dc.w	$33ca,$33d8,$33e6,$33f5,$3403,$3411,$341f,$342d
	dc.w	$343b,$3449,$3457,$3466,$3474,$3482,$3490,$349e
	dc.w	$34ac,$34ba,$34c8,$34d6,$34e4,$34f2,$3500,$350e
	dc.w	$351c,$352b,$3539,$3547,$3555,$3563,$3571,$357f
	dc.w	$358d,$359b,$35a9,$35b7,$35c5,$35d3,$35e1,$35ef
	dc.w	$35fd,$360b,$3619,$3627,$3635,$3643,$3651,$365f
	dc.w	$366d,$367a,$3688,$3696,$36a4,$36b2,$36c0,$36ce
	dc.w	$36dc,$36ea,$36f8,$3706,$3714,$3722,$3730,$373d
	dc.w	$374b,$3759,$3767,$3775,$3783,$3791,$379f,$37ac
	dc.w	$37ba,$37c8,$37d6,$37e4,$37f2,$3800,$380d,$381b
	dc.w	$3829,$3837,$3845,$3853,$3860,$386e,$387c,$388a
	dc.w	$3898,$38a5,$38b3,$38c1,$38cf,$38dd,$38ea,$38f8
	dc.w	$3906,$3914,$3921,$392f,$393d,$394b,$3958,$3966
	dc.w	$3974,$3982,$398f,$399d,$39ab,$39b9,$39c6,$39d4
	dc.w	$39e2,$39ef,$39fd,$3a0b,$3a18,$3a26,$3a34,$3a42
	dc.w	$3a4f,$3a5d,$3a6b,$3a78,$3a86,$3a94,$3aa1,$3aaf
	dc.w	$3abc,$3aca,$3ad8,$3ae5,$3af3,$3b01,$3b0e,$3b1c
	dc.w	$3b29,$3b37,$3b45,$3b52,$3b60,$3b6d,$3b7b,$3b89
	dc.w	$3b96,$3ba4,$3bb1,$3bbf,$3bcd,$3bda,$3be8,$3bf5
	dc.w	$3c03,$3c10,$3c1e,$3c2b,$3c39,$3c46,$3c54,$3c61
	dc.w	$3c6f,$3c7c,$3c8a,$3c97,$3ca5,$3cb2,$3cc0,$3ccd
	dc.w	$3cdb,$3ce8,$3cf6,$3d03,$3d11,$3d1e,$3d2c,$3d39
	dc.w	$3d47,$3d54,$3d62,$3d6f,$3d7c,$3d8a,$3d97,$3da5
	dc.w	$3db2,$3dc0,$3dcd,$3dda,$3de8,$3df5,$3e03,$3e10
	dc.w	$3e1d,$3e2b,$3e38,$3e45,$3e53,$3e60,$3e6e,$3e7b
	dc.w	$3e88,$3e96,$3ea3,$3eb0,$3ebe,$3ecb,$3ed8,$3ee6
	dc.w	$3ef3,$3f00,$3f0e,$3f1b,$3f28,$3f35,$3f43,$3f50
	dc.w	$3f5d,$3f6b,$3f78,$3f85,$3f92,$3fa0,$3fad,$3fba
	dc.w	$3fc7,$3fd5,$3fe2,$3fef,$3ffc,$400a,$4017,$4024
	dc.w	$4031,$403f,$404c,$4059,$4066,$4073,$4081,$408e
	dc.w	$409b,$40a8,$40b5,$40c3,$40d0,$40dd,$40ea,$40f7
	dc.w	$4104,$4112,$411f,$412c,$4139,$4146,$4153,$4160
	dc.w	$416d,$417b,$4188,$4195,$41a2,$41af,$41bc,$41c9
	dc.w	$41d6,$41e3,$41f0,$41fe,$420b,$4218,$4225,$4232
	dc.w	$423f,$424c,$4259,$4266,$4273,$4280,$428d,$429a
	dc.w	$42a7,$42b4,$42c1,$42ce,$42db,$42e8,$42f5,$4302
	dc.w	$430f,$431c,$4329,$4336,$4343,$4350,$435d,$436a
	dc.w	$4377,$4384,$4391,$439e,$43ab,$43b8,$43c5,$43d2
	dc.w	$43df,$43eb,$43f8,$4405,$4412,$441f,$442c,$4439
	dc.w	$4446,$4453,$4460,$446c,$4479,$4486,$4493,$44a0
	dc.w	$44ad,$44ba,$44c6,$44d3,$44e0,$44ed,$44fa,$4507
	dc.w	$4513,$4520,$452d,$453a,$4547,$4553,$4560,$456d
	dc.w	$457a,$4587,$4593,$45a0,$45ad,$45ba,$45c7,$45d3
	dc.w	$45e0,$45ed,$45fa,$4606,$4613,$4620,$462c,$4639
	dc.w	$4646,$4653,$465f,$466c,$4679,$4685,$4692,$469f
	dc.w	$46ac,$46b8,$46c5,$46d2,$46de,$46eb,$46f8,$4704
	dc.w	$4711,$471e,$472a,$4737,$4744,$4750,$475d,$4769
	dc.w	$4776,$4783,$478f,$479c,$47a8,$47b5,$47c2,$47ce
	dc.w	$47db,$47e7,$47f4,$4801,$480d,$481a,$4826,$4833
	dc.w	$483f,$484c,$4859,$4865,$4872,$487e,$488b,$4897
	dc.w	$48a4,$48b0,$48bd,$48c9,$48d6,$48e2,$48ef,$48fb
	dc.w	$4908,$4914,$4921,$492d,$493a,$4946,$4953,$495f
	dc.w	$496b,$4978,$4984,$4991,$499d,$49aa,$49b6,$49c3
	dc.w	$49cf,$49db,$49e8,$49f4,$4a01,$4a0d,$4a19,$4a26
	dc.w	$4a32,$4a3f,$4a4b,$4a57,$4a64,$4a70,$4a7c,$4a89
	dc.w	$4a95,$4aa1,$4aae,$4aba,$4ac6,$4ad3,$4adf,$4aeb
	dc.w	$4af8,$4b04,$4b10,$4b1d,$4b29,$4b35,$4b42,$4b4e
	dc.w	$4b5a,$4b66,$4b73,$4b7f,$4b8b,$4b98,$4ba4,$4bb0
	dc.w	$4bbc,$4bc9,$4bd5,$4be1,$4bed,$4bfa,$4c06,$4c12
	dc.w	$4c1e,$4c2a,$4c37,$4c43,$4c4f,$4c5b,$4c67,$4c74
	dc.w	$4c80,$4c8c,$4c98,$4ca4,$4cb0,$4cbd,$4cc9,$4cd5
	dc.w	$4ce1,$4ced,$4cf9,$4d06,$4d12,$4d1e,$4d2a,$4d36
	dc.w	$4d42,$4d4e,$4d5a,$4d66,$4d73,$4d7f,$4d8b,$4d97
	dc.w	$4da3,$4daf,$4dbb,$4dc7,$4dd3,$4ddf,$4deb,$4df7
	dc.w	$4e03,$4e0f,$4e1c,$4e28,$4e34,$4e40,$4e4c,$4e58
	dc.w	$4e64,$4e70,$4e7c,$4e88,$4e94,$4ea0,$4eac,$4eb8
	dc.w	$4ec4,$4ed0,$4edc,$4ee8,$4ef4,$4f00,$4f0b,$4f17
	dc.w	$4f23,$4f2f,$4f3b,$4f47,$4f53,$4f5f,$4f6b,$4f77
	dc.w	$4f83,$4f8f,$4f9b,$4fa7,$4fb2,$4fbe,$4fca,$4fd6
	dc.w	$4fe2,$4fee,$4ffa,$5006,$5011,$501d,$5029,$5035
	dc.w	$5041,$504d,$5059,$5064,$5070,$507c,$5088,$5094
	dc.w	$50a0,$50ab,$50b7,$50c3,$50cf,$50db,$50e6,$50f2
	dc.w	$50fe,$510a,$5115,$5121,$512d,$5139,$5144,$5150
	dc.w	$515c,$5168,$5173,$517f,$518b,$5197,$51a2,$51ae
	dc.w	$51ba,$51c5,$51d1,$51dd,$51e9,$51f4,$5200,$520c
	dc.w	$5217,$5223,$522f,$523a,$5246,$5252,$525d,$5269
	dc.w	$5275,$5280,$528c,$5298,$52a3,$52af,$52ba,$52c6
	dc.w	$52d2,$52dd,$52e9,$52f4,$5300,$530c,$5317,$5323
	dc.w	$532e,$533a,$5346,$5351,$535d,$5368,$5374,$537f
	dc.w	$538b,$5396,$53a2,$53ae,$53b9,$53c5,$53d0,$53dc
	dc.w	$53e7,$53f3,$53fe,$540a,$5415,$5421,$542c,$5438
	dc.w	$5443,$544f,$545a,$5465,$5471,$547c,$5488,$5493
	dc.w	$549f,$54aa,$54b6,$54c1,$54cd,$54d8,$54e3,$54ef
	dc.w	$54fa,$5506,$5511,$551c,$5528,$5533,$553f,$554a
	dc.w	$5555,$5561,$556c,$5577,$5583,$558e,$559a,$55a5
	dc.w	$55b0,$55bc,$55c7,$55d2,$55de,$55e9,$55f4,$5600
	dc.w	$560b,$5616,$5621,$562d,$5638,$5643,$564f,$565a
	dc.w	$5665,$5670,$567c,$5687,$5692,$569e,$56a9,$56b4
	dc.w	$56bf,$56cb,$56d6,$56e1,$56ec,$56f7,$5703,$570e
	dc.w	$5719,$5724,$5730,$573b,$5746,$5751,$575c,$5768
	dc.w	$5773,$577e,$5789,$5794,$579f,$57ab,$57b6,$57c1
	dc.w	$57cc,$57d7,$57e2,$57ed,$57f9,$5804,$580f,$581a
	dc.w	$5825,$5830,$583b,$5846,$5851,$585d,$5868,$5873
	dc.w	$587e,$5889,$5894,$589f,$58aa,$58b5,$58c0,$58cb
	dc.w	$58d6,$58e1,$58ec,$58f7,$5902,$590e,$5919,$5924
	dc.w	$592f,$593a,$5945,$5950,$595b,$5966,$5971,$597c
	dc.w	$5987,$5992,$599d,$59a8,$59b2,$59bd,$59c8,$59d3
	dc.w	$59de,$59e9,$59f4,$59ff,$5a0a,$5a15,$5a20,$5a2b
	dc.w	$5a36,$5a41,$5a4c,$5a57,$5a61,$5a6c,$5a77,$5a82
	dc.w	$5a8d,$5a98,$5aa3,$5aae,$5ab9,$5ac3,$5ace,$5ad9
	dc.w	$5ae4,$5aef,$5afa,$5b04,$5b0f,$5b1a,$5b25,$5b30
	dc.w	$5b3b,$5b45,$5b50,$5b5b,$5b66,$5b71,$5b7b,$5b86
	dc.w	$5b91,$5b9c,$5ba7,$5bb1,$5bbc,$5bc7,$5bd2,$5bdc
	dc.w	$5be7,$5bf2,$5bfd,$5c07,$5c12,$5c1d,$5c28,$5c32
	dc.w	$5c3d,$5c48,$5c53,$5c5d,$5c68,$5c73,$5c7d,$5c88
	dc.w	$5c93,$5c9e,$5ca8,$5cb3,$5cbe,$5cc8,$5cd3,$5cde
	dc.w	$5ce8,$5cf3,$5cfe,$5d08,$5d13,$5d1d,$5d28,$5d33
	dc.w	$5d3d,$5d48,$5d53,$5d5d,$5d68,$5d72,$5d7d,$5d88
	dc.w	$5d92,$5d9d,$5da7,$5db2,$5dbd,$5dc7,$5dd2,$5ddc
	dc.w	$5de7,$5df1,$5dfc,$5e07,$5e11,$5e1c,$5e26,$5e31
	dc.w	$5e3b,$5e46,$5e50,$5e5b,$5e65,$5e70,$5e7a,$5e85
	dc.w	$5e8f,$5e9a,$5ea4,$5eaf,$5eb9,$5ec4,$5ece,$5ed9
	dc.w	$5ee3,$5eee,$5ef8,$5f03,$5f0d,$5f18,$5f22,$5f2c
	dc.w	$5f37,$5f41,$5f4c,$5f56,$5f61,$5f6b,$5f75,$5f80
	dc.w	$5f8a,$5f95,$5f9f,$5fa9,$5fb4,$5fbe,$5fc9,$5fd3
	dc.w	$5fdd,$5fe8,$5ff2,$5ffc,$6007,$6011,$601b,$6026
	dc.w	$6030,$603b,$6045,$604f,$605a,$6064,$606e,$6078
	dc.w	$6083,$608d,$6097,$60a2,$60ac,$60b6,$60c1,$60cb
	dc.w	$60d5,$60df,$60ea,$60f4,$60fe,$6108,$6113,$611d
	dc.w	$6127,$6131,$613c,$6146,$6150,$615a,$6165,$616f
	dc.w	$6179,$6183,$618e,$6198,$61a2,$61ac,$61b6,$61c1
	dc.w	$61cb,$61d5,$61df,$61e9,$61f3,$61fe,$6208,$6212
	dc.w	$621c,$6226,$6230,$623a,$6245,$624f,$6259,$6263
	dc.w	$626d,$6277,$6281,$628c,$6296,$62a0,$62aa,$62b4
	dc.w	$62be,$62c8,$62d2,$62dc,$62e6,$62f0,$62fa,$6305
	dc.w	$630f,$6319,$6323,$632d,$6337,$6341,$634b,$6355
	dc.w	$635f,$6369,$6373,$637d,$6387,$6391,$639b,$63a5
	dc.w	$63af,$63b9,$63c3,$63cd,$63d7,$63e1,$63eb,$63f5
	dc.w	$63ff,$6409,$6413,$641d,$6427,$6431,$643b,$6445
	dc.w	$644f,$6459,$6462,$646c,$6476,$6480,$648a,$6494
	dc.w	$649e,$64a8,$64b2,$64bc,$64c6,$64cf,$64d9,$64e3
	dc.w	$64ed,$64f7,$6501,$650b,$6515,$651e,$6528,$6532
	dc.w	$653c,$6546,$6550,$655a,$6563,$656d,$6577,$6581
	dc.w	$658b,$6595,$659e,$65a8,$65b2,$65bc,$65c6,$65cf
	dc.w	$65d9,$65e3,$65ed,$65f6,$6600,$660a,$6614,$661e
	dc.w	$6627,$6631,$663b,$6645,$664e,$6658,$6662,$666b
	dc.w	$6675,$667f,$6689,$6692,$669c,$66a6,$66b0,$66b9
	dc.w	$66c3,$66cd,$66d6,$66e0,$66ea,$66f3,$66fd,$6707
	dc.w	$6710,$671a,$6724,$672d,$6737,$6741,$674a,$6754
	dc.w	$675e,$6767,$6771,$677a,$6784,$678e,$6797,$67a1
	dc.w	$67ab,$67b4,$67be,$67c7,$67d1,$67db,$67e4,$67ee
	dc.w	$67f7,$6801,$680a,$6814,$681e,$6827,$6831,$683a
	dc.w	$6844,$684d,$6857,$6860,$686a,$6874,$687d,$6887
	dc.w	$6890,$689a,$68a3,$68ad,$68b6,$68c0,$68c9,$68d3
	dc.w	$68dc,$68e6,$68ef,$68f9,$6902,$690c,$6915,$691e
	dc.w	$6928,$6931,$693b,$6944,$694e,$6957,$6961,$696a
	dc.w	$6973,$697d,$6986,$6990,$6999,$69a3,$69ac,$69b5
	dc.w	$69bf,$69c8,$69d2,$69db,$69e4,$69ee,$69f7,$6a01


sin.cos.offsets
	dc.b	22,20,2
	dc.b	24,15,4
	dc.b	23,21,3
	dc.b	22,24,23
	dc.b	20,15,21
	dc.b	2,4,3
	dc.b	17,16,18
	dc.b	17


	ds.w	151


TAB.1ed8a
	dc.b	34,32,98,32,62,4,48,20,74,16,8,0


	ds.w	154


collision1.table
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$fe,$fe
	dc.b	$fe,$fe,$fd,$fd,$fd,$fd,$fc,$fc
	dc.b	$fb,$fb,$fb,$fa,$fa,$f9,$f9,$f8
	dc.b	$f8,$f7,$f7,$f6,$f6,$f5,$f4,$f4
	dc.b	$f3,$f3,$f2,$f1,$f0,$f0,$ef,$ee
	dc.b	$ed,$ec,$ec,$eb,$ea,$e9,$e8,$e7
	dc.b	$e6,$e5,$e4,$e3,$e2,$e1,$e0,$df
	dc.b	$de,$dd,$db,$da,$d9,$d8,$d6,$d5
	dc.b	$d4,$d2,$d1,$cf,$ce,$cc,$cb,$c9
	dc.b	$c8,$c6,$c5,$c3,$c1,$bf,$be,$bc
	dc.b	$ba,$b8,$b6,$b4,$b2,$b0,$ae,$ac
	dc.b	$a9,$a7,$a5,$a2,$a0,$9d,$9b,$98
	dc.b	$95,$92,$8f,$8c,$89,$86,$83,$7f
	dc.b	$7c,$78,$74,$70,$6c,$68,$63,$5e
	dc.b	$59,$53,$4d,$47,$3f,$37,$2d,$20


TAB.1ef4a
	dc.b	27,27,27,27,27,26,26,26,25,25,25,24,23,23,22,21
	dc.b	20,19,18,17,15,14,11,9,7,7,7,7,7,7,7,7


	ds.w	12


road.section.words
	dc.w	$50b2,$a3b2,$a9ff,$feb2,$59b3,$20da,$d8b3,$3bb4
	dc.w	$0a46,$2e20,$9eb4,$a980,$852e,$60a5,$30c9,$8190

; These first 16 words are used to give offsets into this table.  They are
; stored in low byte, high byte order so they are rotated by 8 bit positions
; to give a high byte, low byte word.  This word then has $b100 subtracted
; from it to give an offset into the table.
;
; The resulting words are as follows :-
;
;	$0150,$01a3,$0000,$01fe,$0259,$0000,$02d8,$033b
;	$0000,$0000,$039e,$0000,$0000,$0000,$0000,$0000
;
; Some values have been replaced by zeros because the actual values are
; bollocks and are not used by the program (for any of the tracks). The only
; values used by the program are words 0, 1, 3, 4, 6, 7 and 10.

	dc.w	$0db5,$1bb5,$24b5,$36b5,$44b5,$52b5,$5cb5,$66b5
	dc.w	$6fb5,$78b5,$86b5,$94b5,$9db5,$a6b5,$b2b5,$cab5
	dc.w	$d3b5,$ebb5,$f7b5,$01b6,$0ab6,$14b6,$1db6,$27b6
	dc.w	$31b6,$3ab6,$43b6,$4db6,$57b6,$60b6,$69b6,$72b6
	dc.w	$7bb6,$84b6,$90b6,$99b6,$a2b6,$abb6,$b7b6,$c0b6
	dc.w	$c9b6,$d5b6,$e1b6,$edb6,$f9b6,$02b7,$0bb7,$14b7
	dc.w	$1db7,$26b7,$32b7,$3eb7,$4cb7,$56b7,$5fb7,$68b7
	dc.w	$7ab7,$83b7,$8cb7,$95b7,$9eb7,$a7b7,$b0b7,$b9b7
	dc.w	$c3b7,$ccb7,$d6b7,$e8b7,$f1b7,$fab7,$03b8,$0cb8
	dc.w	$16b8,$1fb8,$28b8,$31b8,$3ab8,$46b8,$4fb8,$58b8
	dc.w	$70b8,$a720,$7eb8,$87b8,$90b8,$9eb8,$acb8,$b5b8
	dc.w	$bfb8,$c9b8,$d5b8,$deb8,$e7b8,$f0b8,$fab8,$03b9
	dc.w	$15b9,$27b9,$39b9,$4bb9,$54b9,$60b9,$6ab9,$74b9
	dc.w	$7eb9,$88b9,$91b9,$9ab9,$a3b9,$acb9,$b5b9,$beb9
	dc.w	$cab9,$d4b9,$e0b9,$f8b9,$04ba,$0dba,$1fba,$28ba
	dc.w	$a320,$7da3,$31ba,$aa20,$3aba,$44ba,$4eba,$58ba
	dc.w	$62ba,$deba,$6fbb,$00bc,$8ebc,$1fbd,$f4bd,$82be
	dc.w	$f5a7,$4c00,$a54c,$b2a3
	dc.w	$0017,$4163,$6375,$7261

TAB.1f0c2
	dc.w	$0080,$20c0,$0073,$80c0,$a959,$0002,$a95e,$854b

	dc.w	$0400,$4003,$1200,$ab80,$8001,$2040,$0300,$00c0
	dc.w	$0400,$0040,$0300,$01c0,$0400,$0140,$0300,$02c0
	dc.w	$0400,$0240,$0300,$03c0,$0400,$0340,$0300,$04c0
	dc.w	$0400,$0440,$0300,$05c0,$0400,$0540,$0300,$06c0
	dc.w	$0400,$0640,$0300,$07c0,$0400,$0740,$0300,$08c0
	dc.w	$0400,$080c,$80a8,$0d00,$0000,$ff80,$680a,$8712
	dc.w	$00ab,$8780,$013e,$4003,$0000,$c004,$0000,$4c03
	dc.w	$0501,$ca04,$df00,$7303,$0702,$eb04,$bc01,$b203
	dc.w	$0503,$2205,$9502,$0a04,$fb03,$6d05,$6803,$7a04
	dc.w	$e704,$cd05,$3204,$0005,$c805,$4006,$f204,$9c05
	dc.w	$9a06,$c506,$a605,$4c06,$5b07,$5b07,$4c06,$0cc0
	dc.w	$57fa,$0000,$0001,$80e8,$0887,$1203,$ab87,$8001
	dc.w	$3e3f,$0300,$00bf,$0400,$0035,$03df,$00b3,$0405
	dc.w	$0114,$03bc,$018c,$0407,$02dd,$0295,$024d,$0405
	dc.w	$0392,$0268,$03f5,$03fb,$0332,$0232,$0485,$03e7
	dc.w	$04bf,$01f2,$04ff,$02c8,$053a,$01a6,$0563,$029a
	dc.w	$06a4,$004c,$06b3,$015b,$0708,$4040,$ff00,$2080
	dc.w	$b51c,$00ab,$8080,$0120,$78ff,$8700,$8700,$78ff
	dc.w	$2c00,$3c01,$3c01,$2c00,$e100,$f001,$f001,$e100
	dc.w	$9601,$a502,$a502,$9601,$4a02,$5a03,$5a03,$4a02
	dc.w	$ff02,$0e04,$0e04,$ff02,$b303,$c304,$c304,$b303
	dc.w	$6804,$7705,$7705,$6804,$1d05,$2c06,$2c06,$1d05
	dc.w	$d105,$e106,$e106,$d105,$8606,$9507,$9507,$8606
	dc.w	$3a07,$4a08,$4a08,$3a07,$ef07,$ff08,$ff08,$ef07
	dc.w	$a408,$b309,$b309,$a408,$0c80,$0010,$0000,$00ff
	dc.w	$90c0,$0c7a,$1400,$ab7a,$8001,$3240,$0300,$00c0
	dc.w	$0400,$004c,$031c,$01ca,$04fb,$0071,$0336,$02eb
	dc.w	$04f4,$01af,$034c,$0322,$05e9,$0204,$045c,$046d
	dc.w	$05d9,$0371,$0463,$05cd,$05c1,$04f5,$0460,$0641
	dc.w	$06a0,$058e,$0550,$07c8,$0673,$063b,$0632,$0861
	dc.w	$073b,$07fc,$0603,$090b,$08f4,$070c,$c000,$f800
	dc.w	$0000,$0190,$400b,$7a14,$03ab,$7a80,$0132,$4003
	dc.w	$0000,$c004,$0000,$3503,$fb00,$b304,$1c01,$1403
	dc.w	$f401,$8e04,$3602,$dd02,$e902,$5004,$4c03,$9202
	dc.w	$d903,$fb03,$5c04,$3202,$c104,$8e03,$6305,$be01
	dc.w	$a005,$0a03,$6006,$3701,$7306,$7102,$5007,$9e00
	dc.w	$3b07,$c401,$3208,$f4ff,$f407,$0301,$0309,$0840
	dc.w	$40ff,$0020,$7cb0,$1800,$ab7c,$8001,$2078,$ff87
	dc.w	$0087,$0078,$ff32,$0041,$0141,$0132,$00ec,$00fc
	dc.w	$01fc,$01ec,$00a6,$01b6,$02b6,$02a6,$0160,$0270
	dc.w	$0370,$0360,$021b,$032a,$042a,$041b,$03d5,$03e4
	dc.w	$04e4,$04d5,$038f,$049f,$059f,$058f,$0449,$0559
	dc.w	$0659,$0649,$0503,$0613,$0713,$0703,$06be,$06cd
	dc.w	$07cd,$07be,$0678,$0787,$0887,$0878,$0700,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$6061,$0344
	dc.w	$2628,$2a2c,$0000,$0200,$0400,$0600,$0800,$0a00
	dc.w	$0c00,$0e00,$1000,$0020,$4060,$0121,$4161,$0202
	dc.w	$0202,$0202,$0261,$4121,$0160,$4020,$0000,$0000
	dc.w	$0000,$0060,$2151,$0222,$4262,$0313,$0020,$4070
	dc.w	$2141,$6102,$2232,$0002,$0406,$e729,$ca4b,$2c46
	dc.w	$9655,$8524,$33b2,$2100,$0000,$0000,$0010,$2040
	dc.w	$6001,$2141,$6102,$0202,$0202,$0271,$6141,$2101
	dc.w	$6040,$2000,$0010,$1010,$1010,$1090,$8010,$0000
	dc.w	$0000,$0000,$8090,$0001,$0203,$0405,$0607,$0809
	dc.w	$0a0b,$1b80,$1c80,$1d80,$1e80,$1f80,$2080,$a180
	dc.w	$8000,$0000,$0000,$0000,$0000,$4e1d,$db0a,$a836
	dc.w	$3422,$0000,$009b,$2019,$e018,$a017,$6016,$2014
	dc.w	$e013,$a012,$6011,$200f,$e00e,$a048,$2726,$3544
	dc.w	$6313,$4271,$2150,$0013,$0362,$4222,$0251,$21e0
	dc.w	$8005,$0585,$0000,$8505,$0505,$3222,$0261,$4121
	dc.w	$7040,$a080,$0040,$0141,$0242,$0333,$6300,$2030
	dc.w	$3030,$3030,$3030,$3030,$1000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$90b0,$3030,$3030,$3030
	dc.w	$30a0,$8000,$0000,$0000,$0000,$0090,$b030,$3030
	dc.w	$3030,$3030,$30a0,$8000,$2142,$53e4,$65e6,$5748
	dc.w	$0060,$4192,$62a3,$6314,$4400,$2040,$d060,$60d0
	dc.w	$4020,$0463,$b303,$4282,$3160,$00a6,$8000,$0000
	dc.w	$0000,$8035,$4787,$4675,$2544,$6303,$2241,$6000
	dc.w	$0827,$36c5,$4443,$3221,$0050,$5050,$50c0,$3020
	dc.w	$1000,$0000,$1030,$6011,$5122,$7200,$6041,$a2d2
	dc.w	$62f2,$7272,$7272,$7222,$b232,$a212,$f131,$6000
	dc.w	$0a68,$4726,$0563,$4221,$0000,$1030,$6021,$7142
	dc.w	$1363,$3405,$5555,$2676,$4718,$6839,$8a00,$0000
	dc.w	$0000,$c776,$2655,$0534,$6313,$4271,$2121,$6030
	dc.w	$1000,$0000,$0000,$0000,$008a,$8000,$0000,$0000
	dc.w	$804c,$0041,$0344,$0647,$094a,$0c70,$5030,$1000
	dc.w	$1030,$5070,$aa80,$0000,$0000,$0080,$2a59,$4939
	dc.w	$a963,$6363,$6347,$0000,$0010,$3050,$0131,$7142
	dc.w	$2314,$6262,$62d2,$42a2,$0261,$b101,$4000,$0040
	dc.w	$0141,$0242,$0343,$0464,$4526,$0767,$0010,$2030
	dc.w	$4040,$4040,$4040,$0000,$0000,$0010,$3060,$218d
	dc.w	$8000,$0000,$0000,$0000,$0000,$0000,$8000,$9c80
	dc.w	$1c80,$9c80,$8000,$0000,$0000,$0000,$1020,$4060
	dc.w	$0131,$7100,$1030,$7031,$71b2,$5262,$0000,$0010
	dc.w	$3060,$2102,$0300,$1030,$6021,$7162,$5344,$0070
	dc.w	$6152,$4334,$2516,$0700,$0000,$0000,$0000,$802e
	dc.w	$0001,$f152,$a363,$9434,$5400,$30d0,$7011,$a131
	dc.w	$4141,$4140,$1000,$0000,$1040,$1161,$4040,$4040
	dc.w	$4040,$3020,$1000,$9ac0,$8000,$0000,$0000,$0000
	dc.w	$0000,$0000,$8000,$0c80,$2403,$0221,$6030,$1000
	dc.w	$0047,$4665,$2505,$0515,$3575,$80e6,$1645,$7424
	dc.w	$5323,$1346,$2514,$1322,$4170,$3000,$0001,$1233
	dc.w	$5475,$1738,$597a,$0271,$d121,$6030,$1000,$0000
	dc.w	$0010,$3060,$21d1,$7102,$0040,$8131,$d161,$f171
	dc.w	$7122,$6121,$6030,$1000,$0000,$0060,$4122,$0363
	dc.w	$4425,$0666,$4728,$0000,$1030,$6021,$7152,$4324
	dc.w	$45e6,$8021,$4263,$0526,$2860,$27c0,$2740,$26e0
	dc.w	$26a0,$2680,$2680,$26a0,$26e0,$2720,$a760,$0000
	dc.w	$0001,$0203,$0405,$0607,$0868,$492a,$0b6b,$0070
	dc.w	$5132,$1373,$5435,$0600,$5031,$1272,$5334,$1506
	dc.w	$0060,$4122,$0373,$6465,$6667,$6869,$6a6b,$0060
	dc.w	$4122,$0353,$2464,$2565,$2666,$2767,$0081,$61a2
	dc.w	$4252,$5252,$5200,$4172,$1435,$5677,$193a,$5b00
	dc.w	$2142,$6305,$2647,$681a,$5b64,$1443,$7222,$5101
	dc.w	$4020,$1000,$0005,$0505,$1525,$45e5,$0000,$2212
	dc.w	$f151,$3111,$6030,$0000,$5031,$2223,$3455,$7618
	dc.w	$0021,$4263,$0526,$4768,$797a,$5271,$2160,$3010
	dc.w	$0000,$0000,$0000,$2000,$4000,$6032,$0000,$6000
	dc.w	$4000,$2000,$0000,$0000,$2000,$4000,$6032,$0000
	dc.w	$6000,$4000,$2000,$0000,$0000,$2000,$4000,$6032
	dc.w	$0000,$6000,$4000,$2000,$0000,$0000,$2000,$4000
	dc.w	$6032,$0000,$6000,$4000,$2000,$0063,$43a3,$f242
	dc.w	$0241,$0140,$2847,$6606,$2544,$6303,$2241,$6000
	dc.w	$1473,$4303,$4202,$4101,$4000,$7414,$4303,$4202
	dc.w	$4101,$4000,$1453,$1352,$1251,$1150,$a080,$7434
	dc.w	$7333,$7232,$7131,$e080,$2362,$2261,$2170,$4020
	dc.w	$0042,$4252,$7213,$43f3,$8000,$0000,$0080,$8505
	dc.w	$0505,$050c,$5947,$5504,$5241,$5000,$0010,$3050
	dc.w	$e050,$3010,$0000,$0000,$0080,$0000,$0000,$0404
	dc.w	$0404,$0404,$73e3,$3352,$4100,$4404,$4303,$4202
	dc.w	$4101,$4000,$4141,$4141,$4141,$31a1,$01e0,$3000
	dc.w	$18c0,$1680,$1440,$1200,$0fc0,$0d80,$0b40,$0900
	dc.w	$06c0,$0480,$0240,$0000,$7e4c,$1a08,$1644,$1302
	dc.w	$1140,$1000,$6030,$1000,$0010,$3060,$2113,$0010
	dc.w	$a00e,$400b,$e009,$8007,$2004,$c002,$6000,$0000
	dc.w	$e818,$4776,$2655,$0534,$0000,$0010,$3060,$2171
	dc.w	$4200,$2142,$6305,$2647,$680a,$0060,$3171,$3272
	dc.w	$3373,$3474,$0020,$5011,$5112,$5213,$5314,$0040
	dc.w	$0141,$0242,$0343,$94f4,$0040,$0141,$0242,$0343
	dc.w	$f394,$2c0f,$0f25,$0005,$a0cf,$6a9f,$6b24,$5050
	dc.w	$2500,$0019,$6380,$2f04,$6486,$1f65,$6657,$0e68
	dc.w	$67c0,$0d64,$04e0,$0c69,$9f17,$0000,$0000,$0000
	dc.w	$0000,$cc02,$c601,$1617,$b710,$0001,$2019,$1894
	dc.w	$3104,$032a,$4200,$2a53,$002a,$6400,$2a75,$282a
	dc.w	$8629,$2a97,$002a,$a82a,$2ab9,$2b2a,$ca00,$2adb
	dc.w	$0004,$ec09,$0ad3,$fd16,$1766,$fe00,$17ef,$1b1a
	dc.w	$8ddf,$0605,$222f,$0202,$2146,$0358,$0122,$382a
	dc.w	$2a0e,$000f,$a0cf,$009f,$3b3c,$3c25,$1348,$4900
	dc.w	$3280,$2f04,$6486,$1f65,$6657,$0e68,$67c0,$0d64
	dc.w	$04e0,$0c69,$9f2e,$2f2e,$2f2e,$2f2e,$2f38,$c002
	dc.w	$4c03,$c601,$7c7d,$9710,$7f7e,$0020,$034c,$2030
	dc.w	$339f,$3315,$1e1f,$6464,$6464,$5e0c,$d006,$e016
	dc.w	$17d7,$f11b,$1a4d,$f260,$f300,$9f00,$4900,$5a6b
	dc.w	$0000,$4800,$4cfd,$46fe,$1617,$17ef,$1b1a,$8ddf
	dc.w	$0709,$3034,$0809,$03d4,$083f,$0fbe,$11bd,$13bb
	dc.w	$15ba,$2cf3,$1e42,$1011,$1213,$1415,$162f,$0535
	dc.w	$2e2e,$1340,$0560,$043a,$8f7a,$1c1d,$1e1f,$2227
	dc.w	$434d,$0d47,$0e17,$1696,$1f1a,$1b0c,$2f20,$3f00
	dc.w	$9f48,$0039,$0048,$4948,$0038,$00df,$034c,$07ef
	dc.w	$7d7c,$56fe,$7e7f,$c0fd,$4c03,$e0fc,$336f,$4a71
	dc.w	$1f64,$645e,$cdf5,$c7f4,$1716,$16e3,$1a1b,$8cd3
	dc.w	$a0c3,$301f,$4b8c,$a381,$930b,$0c14,$8204,$0384
	dc.w	$710a,$0911,$600c,$0b8c,$50a0,$4000,$1f00,$8d20
	dc.w	$8710,$1716,$d601,$1a1b,$4c02,$6003,$0006,$0529
	dc.w	$3106,$0100,$5201,$4d1b,$4c25,$4f28,$4d34,$5c26
	dc.w	$2c01,$0118,$8007,$a0c0,$003f,$0000,$0080,$806d
	dc.w	$6e4f,$6e6d,$6d6e,$6e6d,$6d6e,$a030,$008d,$2087
	dc.w	$1017,$16d6,$011a,$1b4c,$0260,$0377,$9f29,$0000
	dc.w	$7640,$2900,$0045,$4d0d,$470e,$1716,$b61f,$0003
	dc.w	$2f18,$1954,$3e03,$04ea,$4d31,$ea5c,$0dea,$6b0d
	dc.w	$ea7a,$8eea,$8900,$ea98,$00ea,$a700,$eab6,$90ea
	dc.w	$c511,$ead4,$59c4,$e30a,$0951,$f217,$16e7,$f100
	dc.w	$16e0,$1a1b,$8cd0,$0a09,$2b29,$0508,$20d6,$0e4e
	dc.w	$0f4b,$134b,$1446,$1011,$1516,$2021,$2223,$280f
	dc.w	$0f23,$406a,$aabd,$71aa,$ac21,$aa9b,$64aa,$8acf
	dc.w	$aa79,$00aa,$6800,$aa57,$00aa,$466f,$aa35,$f2aa
	dc.w	$2473,$8413,$090a,$5302,$1617,$e601,$0097,$101b
	dc.w	$1a0d,$2020,$3024,$0040,$5033,$0150,$5253,$9461
	dc.w	$3350,$2a72,$4c04,$8355,$5491,$9453,$5200,$a450
	dc.w	$3320,$b44c,$1f25,$0cd4,$06e4,$1617,$d7f5,$1b1a
	dc.w	$4df6,$60f7,$4d5f,$477a,$4e7a,$564c,$fd46,$fe16
	dc.w	$1737,$ef00,$81df,$1918,$14ce,$0403,$0708,$2b28
	dc.w	$0601,$03d8,$1554,$1836,$20c2,$0042,$27c9,$204e
	dc.w	$2a2a,$04a0,$11a0,$cc00,$7f38,$3333,$2c00,$0032
	dc.w	$804c,$0464,$863c,$6566,$572b,$6867,$c02a,$6404
	dc.w	$e029,$2b3f,$2035,$5cc0,$252d,$0dc6,$2457,$4797
	dc.w	$335d,$5800,$430d,$2d20,$531c,$3f1d,$3f00,$0093
	dc.w	$6d6e,$2f6d,$6e6e,$6d20,$c332,$00d3,$6404,$07e3
	dc.w	$6665,$76f2,$70e7,$f170,$16e0,$6768,$80d0,$0464
	dc.w	$a0c0,$709f,$7070,$70c2,$0064,$642b,$008d,$2087
	dc.w	$1017,$16d6,$011a,$1b4c,$0260,$0300,$9f00,$35df
	dc.w	$e000,$e1e2,$2b38,$400d,$034c,$470e,$7d7c,$961f
	dc.w	$7e7f,$002f,$4c03,$203f,$339f,$3333,$151e,$1f22
	dc.w	$4464,$5e0d,$df07,$ef17,$1676,$fe00,$e7fd,$0016
	dc.w	$ec1a,$1b8c,$dc04,$0448,$4809,$0703,$6206,$5507
	dc.w	$5014,$433d,$e441,$d82d,$5a2e,$502f,$c604,$0d26
	dc.w	$3334,$3536,$341d,$1d04,$4006,$203f,$009f,$003b
	dc.w	$254d,$3e26,$6464,$2b0d,$df07,$ef17,$1656,$fe1a
	dc.w	$1bcc,$fde0,$fc00,$5f00,$0000,$0000,$cdf6,$c3f5
	dc.w	$1716,$34e4,$00aa,$d300,$aac2,$00a4,$b100,$11a0
	dc.w	$1819,$8c90,$a080,$005f,$0000,$0000,$008d,$2087
	dc.w	$1017,$16d6,$011a,$1b4c,$0260,$0300,$9f3a,$7a36
	dc.w	$00b7,$003d,$2743,$4d0d,$470e,$1716,$961f,$1a1b
	dc.w	$0c2f,$0606,$2c2a,$060e,$27d3,$28ce,$02d3,$1755
	dc.w	$1652,$1552,$1e1f,$2021,$2225,$2627,$2829,$2a2b
	dc.w	$2c2d,$4e00,$0025,$0005,$a0cf,$389f,$0182,$8282
	dc.w	$8282,$074a,$008c,$2f86,$1f16,$1757,$0e1b,$1acd
	dc.w	$0de0,$0c19,$9f08,$0ff5,$f5f5,$f56c,$745c,$c002
	dc.w	$2d0d,$c601,$5747,$9710,$5d58,$0020,$0d2d,$2030
	dc.w	$1c9f,$1d1e,$1f22,$2727,$2743,$3800,$d04c,$0306
	dc.w	$e005,$06f7,$f134,$66f2,$4117,$e312,$1480,$d364
	dc.w	$04a0,$c370,$7f4b,$3533,$3333,$3333,$8043,$034c
	dc.w	$8733,$0605,$f624,$3467,$2500,$9636,$1a1b,$0c46
	dc.w	$2056,$007f,$235b,$7070,$7070,$7000,$d604,$6406
	dc.w	$e665,$66d7,$f768,$6740,$f864,$0460,$f92b,$3f00
	dc.w	$0000,$4cfd,$46fe,$1617,$17ef,$1b1a,$8ddf,$0303
	dc.w	$5059,$0700,$062a,$0729,$0e36,$1a54,$1b4a,$4d52
	dc.w	$4c5a,$fe04,$bdff,$0484,$0b85,$0c20,$7798,$4ca3
	dc.w	$8ba5,$2638,$e90f,$8526,$a41b,$840a,$2097,$8ac9
	dc.w	$2cd0,$3e4c,$95b6,$2054,$b3a5,$2618,$69f4,$854b
	dc.w	$a905,$854c,$2000,$a5a5,$2a85,$37a5,$2b85,$3820
	dc.w	$e9b4,$a526,$8527,$1869,$f985,$4ba9,$0585,$4c20
	dc.w	$5f9a,$f0ad,$bdf5,$0430,$04b0,$a690,$b490,$a2b0
	dc.w	$b04c,$968b,$0022,$e320,$7661,$0707,$0707,$0707
	dc.w	$0707,$413a,$3e41,$4851,$484f,$0000,$0000,$0000
	dc.w	$0000,$4841,$4548,$4f58,$4f56,$0703,$0303,$0303
	dc.w	$0703,$6657,$5759,$5969,$6264,$0703,$0303,$0301
	dc.w	$0303,$6155,$5356,$585b,$5a62


league.values
	dc.b	$48,$00,$f0,$00,$ec,$00,$10,$60,$5b,$00,$00
	dc.b	$54,$0c,$40,$01,$3a,$01,$0c,$6e,$69,$01,$00


font7	dc.b	$00,$00,$00,$00,$00,$00,$00,$00		chars. 32 to 126
	dc.b	$95,$95,$95,$95,$aa,$ea,$ea,$ea
	dc.b	$15,$15,$15,$15,$15,$6a,$6a,$6a
	dc.b	$75,$c3,$00,$00,$00,$00,$80,$80
	dc.b	$40,$40,$c0,$00,$00,$80,$80,$80
	dc.b	$55,$55,$55,$55,$55,$aa,$aa,$aa
	dc.b	$55,$55,$55,$55,$55,$aa,$aa,$aa
	dc.b	$bd,$ff,$c3,$c0,$c3,$f3,$bf,$bf
	dc.b	$00,$00,$c0,$c0,$c0,$c0,$40,$40
	dc.b	$ff,$80,$80,$80,$80,$80,$80,$80
	dc.b	$80,$80,$80,$80,$80,$80,$80,$ff
	dc.b	$08,$08,$08,$7f,$08,$08,$08,$00
	dc.b	$01,$01,$01,$01,$01,$01,$01,$ff
	dc.b	$00,$00,$00,$7e,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$00,$10,$00
	dc.b	$00,$02,$04,$08,$10,$20,$40,$00
	dc.b	$00,$3c,$42,$42,$42,$42,$3c,$00
	dc.b	$00,$10,$30,$10,$10,$10,$38,$00
	dc.b	$00,$3c,$42,$0c,$30,$40,$7e,$00
	dc.b	$00,$7e,$04,$0c,$02,$42,$3c,$00
	dc.b	$00,$04,$0c,$14,$24,$7e,$04,$00
	dc.b	$00,$7e,$40,$7c,$02,$02,$7c,$00
	dc.b	$00,$3c,$40,$7c,$42,$42,$3c,$00
	dc.b	$00,$7e,$04,$08,$10,$20,$20,$00
	dc.b	$00,$3c,$42,$3c,$42,$42,$3c,$00
	dc.b	$00,$3c,$42,$3c,$04,$08,$10,$00
	dc.b	$00,$00,$10,$00,$00,$10,$00,$00
	dc.b	$00,$00,$10,$00,$00,$10,$20,$00
	dc.b	$18,$18,$18,$18,$18,$00,$18,$00
	dc.b	$00,$00,$7e,$00,$7e,$00,$00,$00
	dc.b	$30,$18,$0c,$06,$0c,$18,$30,$00
	dc.b	$00,$38,$44,$04,$08,$10,$00,$10
	dc.b	$3c,$66,$6e,$6a,$6e,$60,$3c,$00
	dc.b	$00,$3c,$42,$42,$7e,$42,$42,$00
	dc.b	$00,$78,$44,$7c,$42,$42,$7c,$00
	dc.b	$00,$3c,$42,$40,$40,$42,$3c,$00
	dc.b	$00,$7c,$42,$42,$42,$42,$7c,$00
	dc.b	$00,$7e,$40,$78,$40,$40,$7e,$00
	dc.b	$00,$7e,$40,$78,$40,$40,$40,$00
	dc.b	$00,$3c,$42,$40,$4e,$42,$3e,$00
	dc.b	$00,$42,$42,$7e,$42,$42,$42,$00
	dc.b	$00,$38,$10,$10,$10,$10,$38,$00
	dc.b	$00,$04,$04,$04,$04,$44,$38,$00
	dc.b	$00,$44,$48,$70,$48,$44,$42,$00
	dc.b	$00,$20,$20,$20,$20,$20,$3e,$00
	dc.b	$00,$42,$66,$5a,$42,$42,$42,$00
	dc.b	$00,$42,$62,$52,$4a,$46,$42,$00
	dc.b	$00,$3c,$42,$42,$42,$42,$3c,$00
	dc.b	$00,$7c,$42,$7c,$40,$40,$40,$00
	dc.b	$00,$3c,$42,$42,$42,$42,$3c,$06
	dc.b	$00,$7c,$42,$7c,$48,$44,$42,$00
	dc.b	$00,$3e,$40,$3c,$02,$02,$7c,$00
	dc.b	$00,$7c,$10,$10,$10,$10,$10,$00
	dc.b	$00,$42,$42,$42,$42,$42,$3e,$00
	dc.b	$00,$42,$42,$42,$42,$24,$18,$00
	dc.b	$00,$42,$42,$42,$5a,$66,$42,$00
	dc.b	$00,$42,$24,$18,$18,$24,$42,$00
	dc.b	$00,$44,$44,$28,$10,$10,$10,$00
	dc.b	$00,$7e,$04,$08,$10,$20,$7e,$00
	dc.b	$01,$00,$00,$00,$00,$00,$00,$ff
	dc.b	$80,$00,$00,$00,$00,$00,$00,$ff
	dc.b	$00,$00,$00,$ff,$00,$00,$00,$01
	dc.b	$00,$00,$00,$ff,$00,$00,$00,$80
	dc.b	$00,$00,$00,$00,$00,$00,$7e,$00
	dc.b	$00,$00,$00,$ff,$00,$00,$00,$ff
	dc.b	$00,$00,$3c,$02,$3e,$42,$3e,$00
	dc.b	$00,$40,$7c,$42,$42,$42,$7c,$00
	dc.b	$00,$00,$3e,$40,$40,$40,$3e,$00
	dc.b	$00,$02,$3e,$42,$42,$42,$3e,$00
	dc.b	$00,$00,$3c,$42,$7e,$40,$3c,$00
	dc.b	$00,$1c,$22,$20,$78,$20,$20,$00
	dc.b	$00,$00,$3e,$42,$42,$3e,$02,$3c
	dc.b	$00,$40,$40,$7c,$42,$42,$42,$00
	dc.b	$10,$00,$30,$10,$10,$10,$38,$00
	dc.b	$00,$08,$00,$08,$08,$08,$48,$30
	dc.b	$00,$20,$20,$24,$38,$24,$22,$00
	dc.b	$00,$30,$10,$10,$10,$10,$38,$00
	dc.b	$00,$00,$24,$5a,$5a,$42,$42,$00
	dc.b	$00,$00,$7c,$42,$42,$42,$42,$00
	dc.b	$00,$00,$3c,$42,$42,$42,$3c,$00
	dc.b	$00,$00,$7c,$42,$42,$7c,$40,$40
	dc.b	$00,$00,$3e,$42,$42,$3e,$02,$02
	dc.b	$00,$00,$5c,$62,$40,$40,$40,$00
	dc.b	$00,$00,$3e,$60,$3c,$06,$7c,$00
	dc.b	$00,$20,$7c,$20,$20,$24,$18,$00
	dc.b	$00,$00,$42,$42,$42,$42,$3e,$00
	dc.b	$00,$00,$42,$42,$42,$24,$18,$00
	dc.b	$00,$00,$42,$42,$5a,$5a,$24,$00
	dc.b	$00,$00,$42,$24,$18,$24,$42,$00
	dc.b	$00,$00,$42,$42,$42,$3e,$02,$3c
	dc.b	$00,$00,$7e,$04,$18,$20,$7e,$00
	dc.b	$00,$00,$00,$ff,$00,$00,$00,$81
	dc.b	$81,$81,$81,$81,$81,$81,$81,$81
	dc.b	$81,$00,$00,$00,$00,$00,$00,$81
	dc.b	$ff,$00,$00,$00,$00,$00,$00,$ff


car.colours
	dc.w	$000,$443,$554,$770,$451,$233,$257,$247
	dc.w	$123,$200,$311,$422,$644,$332,$555,$777


test.for.quit
	tst.b	B.57c3c
	bne.s	tfq1
	bra	test.key

tfq1	tst.b	d0
	beq.s	tfq2

	move.b	#0,d0
	rts

tfq2	move.b	#$ff,d0
	rts


B.57c3c	dc.b	0,0

	dc.b	0
B.57c5b	dc.b	0

	dc.b	0
B.57c61	dc.b	0
	dc.b	0
B.57c63	dc.b	0

	dc.b	0
opponent.draw.flag	dc.b	0


set.opponent.draw.flag
	move.b	#0,opponent.draw.flag
	tst.b	B.57c3c
	beq.s	sodf2

	move.w	W.1bbec,d0
	bpl.s	sodf3

	neg.w	d0
	cmp.w	#60,d0
	blt.s	sodf2
	move.b	#$80,opponent.draw.flag

sodf1	move.w	W.1bc12,d0
	bmi.s	sodf2
	add.w	#32,W.1bc12
sodf2	rts

sodf3	sub.w	#256,d0
	cmp.w	#60,d0
	blt.s	sodf2

	move.b	#1,opponent.draw.flag
	bra.s	sodf1


coll1.sub2.sub3
	tst.b	B.57c3c
	beq.s	coll1.sub2.sub31

	tst.b	B.1bbc4
	bpl.s	coll1.sub2.sub31

	move.b	B.1bbe0,d0
	bpl.s	coll1.sub2.sub31

	asl.b	#1,d0
	move.b	player.road.section,d3
	cmp.b	opponents.road.section,d3
	bne.s	coll1.sub2.sub31

	move.b	swing.from.left.or.right,d3
	eor.b	d3,d0
	bmi.s	coll1.sub2.sub31
	eor.b	#$80,swing.from.left.or.right

coll1.sub2.sub31
	rts


print.sub1
	and.w	#$7f,d0
	move.l	#$272c2,a0

ps11	cmp.b	#32,d0
	blt.s	ps12

	sub.b	#32,d0
	lea	3840(a0),a0
	bra.s	ps11

ps12	move.w	#6,d3
	mulu	d3,d0
	move.w	d0,d3
	lsr.w	#4,d3
	and.w	#$f,d0
	bra.s	ps14

ps13	addq.l	#8,a0
ps14	dbra	d3,ps13
	move.b	d0,B.5924b
	rts


print.sub2
	move.w	#5,d5
	move.b	B.5924b,d0
	eor.b	#$f,d0
	and.l	#$f,d0
	move.w	(a0),d4
	moveq	#0,d7

ps21	btst	d0,d4
	beq.s	ps22
	bset	#0,d7

ps22	asl.b	#1,d7
	subq.b	#1,d0
	bpl.s	ps23

	move.w	8(a0),d4
	move.b	#15,d0
ps23	dbra	d5,ps21

	asl.b	#1,d7
	lea	160(a0),a0
	rts

font.narrow	dc.b	0
B.5924b	dc.b	0
L.5924c	dc.l	0


decrunch
	move.l	a1,a2
	move.w	#200-1,d6
d.line	move.w	#4-1,d5
d.bitplane
	move.l	a2,a1
	lea	8000(a2),a2
	moveq	#40,d3
d.byte	moveq	#0,d0
	move.b	(a0)+,d0
	bmi.s	next.byte.n.times

next.n.bytes.literally
	sub.b	d0,d3
	subq.b	#1,d3
.loop	move.b	(a0)+,(a1)+
	dbra	d0,.loop
	bra.s	check.byte.count

next.byte.n.times
	neg.b	d0
	bmi.s	d.byte
	sub.b	d0,d3
	subq.b	#1,d3
	move.b	(a0)+,d4
.loop	move.b	d4,(a1)+
	dbra	d0,.loop

check.byte.count
	tst.b	d3
	bne.s	d.byte
	dbra	d5,d.bitplane
	lea	40-32000(a2),a2
	dbra	d6,d.line
	rts


print.character
	movem.l	d0-d5/a0-a1,-(sp)
	bsr.s	pc1
	movem.l	(sp)+,d0-d5/a0-a1
	rts

pc1	tst.b	set.print.pos
	beq.s	check.print.cmd

	addq.b	#1,print.cmd
	move.b	print.cmd,d3
	cmp.b	#2,d3
	beq.s	set.print.row

	move.b	d0,print.column
	rts

set.print.row
	move.b	d0,print.row
	move.b	#0,set.print.pos
	rts

check.print.cmd
	cmp.b	#31,d0
	bne.s	check.print.char

	move.b	d0,set.print.pos
	move.b	#0,print.cmd
	rts

check.print.char
	cmp.b	#$7f,d0
	bcs.s	ascii.char
	bne.s	not.delete

	subq.b	#1,print.column
	move.b	or.with.screen,copy.or.with.screen
	move.b	#0,or.with.screen
	move.b	#$20,d0			SPACE
	bsr.s	pc1
	move.b	copy.or.with.screen,or.with.screen
	subq.b	#1,print.column
not.delete
	rts

ascii.char
	sub.b	#$20,d0
	move.b	print.column,d3
	and.w	#$ff,d3
	move.w	d3,d4
	asl.w	#3,d3
	sub.w	d4,d3
	tst.b	font.narrow
	beq.s	times7
	sub.w	d4,d3

times7	move.b	print.fine.x,d4
	and.w	#$ff,d4
	add.w	d4,d3
	move.w	d3,d4
	lsr.w	#4,d4
	move.b	d4,print.word
	move.b	d3,d4
	and.b	#$f,d4
	move.b	d4,print.shift
	and.l	#$ff,d0
	tst.b	font.narrow
	beq.s	standard.font
	bsr	print.sub1
	bra.s	print.dest

standard.font
	asl.l	#3,d0
	move.l	#font7,a0
	add.l	d0,a0

print.dest
	move.b	print.row,d0
	asl.b	#3,d0
	add.b	print.fine.y,d0
	and.l	#$ff,d0
	move.l	d0,d4
	asl.l	#2,d4
	add.l	d4,d0
	asl.l	#3,d0
	move.l	screen.mem,a1
	lea	32000(a1),a1
	tst.b	second.screen
	bpl.s	print.scr.set
	move.l	screen2,a1

print.scr.set
	tst.b	font.narrow
	beq.s	standard.font2
	move.l	L.5924c,a1

standard.font2
	add.l	d0,a1
	move.b	print.word,d3
	and.l	#$ff,d3
	asl.l	#1,d3
	add.l	d3,a1
	cmp.b	#$41,B.5d724
	bne.s	print.count
	tst.b	font.narrow
	bne.s	print.count
	lea	-8*40(a1),a1

print.count
	move.b	#8,d2

print.byte
	tst.b	font.narrow
	beq.s	standard.font3
	bsr	print.sub2
	move.l	#%11111100000000000,d5
	bra.s	print.first.word

standard.font3
	move.b	(a0)+,d7
	and.l	#$ff,d7
	move.l	#%11111110000000000,d5

print.first.word
	asl.l	#8,d7
	asl.l	#1,d7
	move.b	print.shift,d3
	eor.b	#$f,d3
	and.l	#$f,d3
	asl.l	d3,d7
	asl.l	d3,d5

	move.l	d7,d6
	swap	d7
	move.w	d7,d6

	move.l	d5,d4
	swap	d5
	move.w	d5,d4

	move.l	bground.masks,d3
	and.l	d4,d3
	not.l	d4
	move.w	(a1),d0
	swap	d0
	move.w	8000(a1),d0
	tst.b	or.with.screen
	bmi.s	no.or1
	and.l	d4,d0
	or.l	d3,d0

no.or1	move.l	text.masks,d3
	and.l	d6,d3
	not.l	d6
	and.l	d6,d0
	or.l	d3,d0
	move.w	d0,8000(a1)
	swap	d0
	move.w	d0,(a1)
	tst.b	second.screen
	bmi.s	not.scr2
	move.w	d0,-32000(a1)
	swap	d0
	move.w	d0,-24000(a1)

not.scr2
	lea	16000(a1),a1
	not.l	d4
	not.l	d6
	move.l	bground.masks+4,d3
	and.l	d4,d3
	not.l	d4
	move.w	(a1),d0
	swap	d0
	move.w	8000(a1),d0
	tst.b	or.with.screen
	bmi.s	no.or2
	and.l	d4,d0
	or.l	d3,d0

no.or2	move.l	text.masks+4,d3
	and.l	d6,d3
	not.l	d6
	and.l	d6,d0
	or.l	d3,d0
	move.w	d0,8000(a1)
	swap	d0
	move.w	d0,(a1)
	tst.b	second.screen
	bmi.s	print.second.word
	move.w	d0,-32000(a1)
	swap	d0
	move.w	d0,-24000(a1)

print.second.word
	lea	2-16000(a1),a1

	move.l	d7,d6
	swap	d7
	move.w	d7,d6

	move.l	d5,d4
	swap	d5
	move.w	d5,d4

	move.l	bground.masks,d3
	and.l	d4,d3
	not.l	d4
	move.w	(a1),d0
	swap	d0
	move.w	8000(a1),d0
	tst.b	or.with.screen
	bmi.s	no.or3
	and.l	d4,d0
	or.l	d3,d0

no.or3	move.l	text.masks,d3
	and.l	d6,d3
	not.l	d6
	and.l	d6,d0
	or.l	d3,d0
	move.w	d0,8000(a1)
	swap	d0
	move.w	d0,(a1)
	tst.b	second.screen
	bmi.s	no.scr22
	move.w	d0,-32000(a1)
	swap	d0
	move.w	d0,-24000(a1)

no.scr22
	lea	16000(a1),a1
	not.l	d4
	not.l	d6
	move.l	bground.masks+4,d3
	and.l	d4,d3
	not.l	d4
	move.w	(a1),d0
	swap	d0
	move.w	8000(a1),d0
	tst.b	or.with.screen
	bmi.s	no.or4
	and.l	d4,d0
	or.l	d3,d0

no.or4	move.l	text.masks+4,d3
	and.l	d6,d3
	not.l	d6
	and.l	d6,d0
	or.l	d3,d0
	move.w	d0,8000(a1)
	swap	d0
	move.w	d0,(a1)
	tst.b	second.screen
	bmi.s	print.next
	move.w	d0,-32000(a1)
	swap	d0
	move.w	d0,-24000(a1)

print.next
	lea	40-2-16000(a1),a1
	subq.b	#1,d2
	bne	print.byte

	move.b	print.column,d0
	addq.b	#1,d0
	cmp.b	#45,d0
	bcs.s	column.ok
	move.b	#0,d0
column.ok
	move.b	d0,print.column
	rts


set.text.masks
	bsr	make.masks
	move.l	d6,text.masks
	move.l	d7,text.masks+4
	rts


set.bground.masks
	bsr	make.masks
	move.l	d6,bground.masks
	move.l	d7,bground.masks+4
	rts


bground.masks	ds.w	4
text.masks	ds.w	4
print.column	dc.b	0
print.row	dc.b	0
print.word	dc.b	0
print.shift	dc.b	0
copy.or.with.screen	dc.b	0
set.print.pos	dc.b	0
print.cmd	dc.b	0,0


rotate.opponent
	move.l	#DAT.1bd8e,a0
	move.w	(a0,d2.w),sin.x
	move.w	32(a0,d2.w),corner.values.offset-1
	bsr	dw.subF.sub2
	bsr	dw.subF.sub3

	move.l	#x.values,a0
	move.w	(a0,d1.w),d0
	add.w	#36,d1
	move.w	d0,(a0,d1.w)
	bsr	dw.subF.sub3
	bsr	z.rotate0

	sub.w	#36,d1
	and.w	#$ff,d1
	bra	z.rotate0


make.opponent
	move.w	DAT.1be70+244,d0
	move.w	W.1bd86,d3
	add.w	#80,d3
	cmp.w	d3,d0
	bge.s	mo1
	move.w	d0,d3

mo1	move.w	d3,DAT.1be70+280
	move.w	DAT.1be70+248,d0
	move.w	W.1bd88,d3
	add.w	#80,d3
	cmp.w	d3,d0
	bge.s	mo2
	move.w	d0,d3

mo2	move.w	d3,DAT.1be70+284
	move.w	W.1bd88,d4
	sub.w	W.1bd86,d4
	asr.w	#1,d4
	move.w	W.1bd8a,d5
	sub.w	d4,d5
	move.w	DAT.1be70+246,d0
	move.w	d5,d3
	add.w	#80,d3
	cmp.w	d3,d0
	bge.s	mo3
	move.w	d0,d3

mo3	move.w	d3,DAT.1be70+282
	move.w	W.1bd8a,d5
	add.w	d4,d5
	move.w	DAT.1be70+250,d0
	move.w	d5,d3
	add.w	#80,d3
	cmp.w	d3,d0
	bge.s	mo4
	move.w	d0,d3

mo4	move.w	d3,DAT.1be70+286
	move.b	#10,d2
	move.b	#244,d1
	bsr	rotate.opponent

	move.b	#14,d2
	move.b	#248,d1
	bsr	rotate.opponent

	move.b	#16,d2
	move.b	#246,d1
	bsr	rotate.opponent

	move.b	#20,d2
	move.b	#250,d1
	bsr	rotate.opponent

	move.b	#244,d1
	bsr	rotate.opponent2
	bsr	opponents.back

	move.w	W.1bc66,d0
	move.w	W.1bc6a,d3
	subq.w	#1,d3
	sub.w	d0,x.values+280
	sub.w	d0,x.values+284
	sub.w	d3,y.values+280
	sub.w	d3,y.values+284
	move.b	#246,d1
	bsr	rotate.opponent2
	bsr	opponents.sides

	move.w	W.1bc66,d0
	move.w	W.1bc6a,d3
	sub.w	d0,x.values+282
	sub.w	d0,x.values+286
	sub.w	d3,y.values+282
	sub.w	d3,y.values+286
	bsr.s	opponents.shadow
	rts


opponents.shadow
	move.w	#47*32,d0
	add.w	#128,d0
	move.w	d0,road.section.offset
	move.w	#280,d1
	move.w	#284,d2
	bsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	move.w	#280,d1
	move.w	#282,d2
	bsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	move.w	#282,d1
	move.w	#286,d2
	bsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	move.w	#284,d1
	move.w	#286,d2
	bsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	rts


opponent.fatten
	move.w	W.1bc64,d0
	bpl.s	ofn1
	neg.w	d0

ofn1	lsr.w	#1,d0
	move.w	d0,W.1bc6c

	lsr.w	#1,d0
	move.w	d0,W.1bc74

	lsr.w	#1,d0
	move.w	d0,W.1bc7c

	tst.w	W.1bc64
	bpl.s	ofn2

	neg.w	W.1bc6c
	neg.w	W.1bc74
	neg.w	W.1bc7c

ofn2	move.w	W.1bc66,d0
	bpl.s	ofn3
	neg.w	d0

ofn3	lsr.w	#1,d0
	move.w	d0,W.1bc6e

	lsr.w	#1,d0
	move.w	d0,W.1bc76

	lsr.w	#1,d0
	move.w	d0,W.1bc7e

	tst.w	W.1bc66
	bpl.s	ofn4

	neg.w	W.1bc6e
	neg.w	W.1bc76
	neg.w	W.1bc7e

ofn4	move.w	W.1bc68,d0
	bpl.s	ofn5
	neg.w	d0

ofn5	lsr.w	#1,d0
	move.w	d0,W.1bc70

	lsr.w	#1,d0
	move.w	d0,W.1bc78

	lsr.w	#1,d0
	move.w	d0,W.1bc80

	tst.w	W.1bc68
	bpl.s	ofn6

	neg.w	W.1bc70
	neg.w	W.1bc78
	neg.w	W.1bc80

ofn6	move.w	W.1bc6a,d0
	bpl.s	ofn7
	neg.w	d0

ofn7	lsr.w	#1,d0
	move.w	d0,W.1bc72

	lsr.w	#1,d0
	move.w	d0,W.1bc7a

	lsr.w	#1,d0
	move.w	d0,W.1bc82

	tst.w	W.1bc6a
	bpl.s	ofn8

	neg.w	W.1bc72
	neg.w	W.1bc7a
	neg.w	W.1bc82
ofn8	rts


opponents.back
	move.w	#47*32,d0
	add.w	#64,d0
	move.w	d0,road.section.offset
	bsr	opponents.left.wheel
	bsr	opponents.right.wheel

	move.w	#47*32,d0
	add.w	#16,d0
	move.w	d0,road.section.offset

	move.w	W.1bc6c,d0
	sub.w	W.1bc6e,d0
	move.w	d0,x.values+270

	move.w	W.1bc70,d0
	sub.w	W.1bc72,d0
	move.w	d0,y.values+270

	move.w	W.1bc6c,d0
	neg.w	d0
	sub.w	W.1bc6e,d0
	move.w	d0,x.values+264

	move.w	W.1bc70,d0
	neg.w	d0
	sub.w	W.1bc72,d0
	move.w	d0,y.values+264

	move.w	W.1bc66,d0
	add.w	W.1bc74,d0
	add.w	W.1bc7c,d0
	move.w	d0,x.values+268

	move.w	W.1bc6a,d0
	add.w	W.1bc78,d0
	add.w	W.1bc80,d0
	move.w	d0,y.values+268

	move.w	W.1bc66,d0
	sub.w	W.1bc74,d0
	sub.w	W.1bc7c,d0
	move.w	d0,x.values+266

	move.w	W.1bc6a,d0
	sub.w	W.1bc78,d0
	sub.w	W.1bc80,d0
	move.w	d0,y.values+266

	move.w	W.1bc84,d0
	move.w	W.1bc86,d3

	add.w	d0,x.values+264
	add.w	d3,y.values+264

	add.w	d0,x.values+266
	add.w	d3,y.values+266

	add.w	d0,x.values+268
	add.w	d3,y.values+268

	add.w	d0,x.values+270
	add.w	d3,y.values+270

	addq.w	#1,x.values+268
	addq.w	#1,x.values+270
	addq.w	#1,y.values+264
	addq.w	#1,y.values+270
	move.w	#264,d1
	move.w	#266,d2
	bsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	move.w	#266,d1
	move.w	#268,d2
	bsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	move.w	#268,d1
	move.w	#270,d2
	bsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	move.w	#270,d1
	move.w	#264,d2
	bsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	rts


opponents.sides
	move.w	W.1bc6c,d0
	move.w	d0,x.values+276

	sub.w	W.1bc6e,d0
	move.w	d0,x.values+278
	move.w	W.1bc70,d0

	move.w	d0,y.values+276
	sub.w	W.1bc72,d0
	move.w	d0,y.values+278

	move.w	W.1bc6c,d0
	neg.w	d0
	move.w	d0,x.values+274

	sub.w	W.1bc6e,d0
	move.w	d0,x.values+272

	move.w	W.1bc70,d0
	neg.w	d0
	move.w	d0,y.values+274

	sub.w	W.1bc72,d0
	move.w	d0,y.values+272

	move.w	W.1bc84,d0
	move.w	W.1bc86,d3

	add.w	d0,x.values+272
	add.w	d3,y.values+272

	add.w	d0,x.values+274
	add.w	d3,y.values+274

	add.w	d0,x.values+276
	add.w	d3,y.values+276

	add.w	d0,x.values+278
	add.w	d3,y.values+278

	addq.w	#1,x.values+276
	addq.w	#1,x.values+278
	addq.w	#1,y.values+272
	addq.w	#1,y.values+278

	move.w	#47*32,d0
	add.w	#32,d0
	move.w	d0,road.section.offset
	move.w	#272,d1
	move.w	#274,d2
	bsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	move.w	#274,d1
	move.w	#276,d2
	bsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	move.w	#276,d1
	move.w	#278,d2
	bsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	move.w	#278,d1
	move.w	#272,d2
	bsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	move.w	#264,d1
	move.w	#272,d2
	bsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	move.w	#270,d1
	move.w	#278,d2
	bsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	move.w	#266,d1
	move.w	#274,d2
	bsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	move.w	#268,d1
	move.w	#276,d2
	bsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	move.w	#47*32,d0
	add.w	#96,d0
	move.w	d0,road.section.offset
	bsr.s	opponents.left.wheel
	bsr.s	opponents.right.wheel
	rts


opponents.left.wheel
	move.w	W.1bc64,d0
	neg.w	d0
	move.w	d0,W.1bc88

	move.w	W.1bc68,d0
	neg.w	d0
	move.w	d0,W.1bc8a
	bra.s	opponents.wheel

opponents.right.wheel
	move.w	W.1bc64,d0
	sub.w	W.1bc6c,d0
	move.w	d0,W.1bc88

	move.w	W.1bc68,d0
	sub.w	W.1bc70,d0
	move.w	d0,W.1bc8a

opponents.wheel
	move.w	W.1bc88,d0
	move.w	d0,x.values+258

	add.w	W.1bc6c,d0
	move.w	d0,x.values+260

	move.w	W.1bc8a,d0
	move.w	d0,y.values+258

	add.w	W.1bc70,d0
	move.w	d0,y.values+260

	move.w	W.1bc88,d0
	sub.w	W.1bc66,d0
	move.w	d0,x.values+256

	add.w	W.1bc6c,d0
	move.w	d0,x.values+262

	move.w	W.1bc8a,d0
	sub.w	W.1bc6a,d0
	move.w	d0,y.values+256

	add.w	W.1bc70,d0
	move.w	d0,y.values+262

	move.w	W.1bc84,d0
	move.w	W.1bc86,d3

	add.w	d0,x.values+256
	add.w	d3,y.values+256

	add.w	d0,x.values+258
	add.w	d3,y.values+258

	add.w	d0,x.values+260
	add.w	d3,y.values+260

	add.w	d0,x.values+262
	add.w	d3,y.values+262

	addq.w	#1,x.values+260
	addq.w	#1,x.values+262
	addq.w	#1,y.values+256
	addq.w	#1,y.values+262
	move.w	#256,d1
	move.w	#258,d2
	bsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	move.w	#258,d1
	move.w	#260,d2
	bsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	move.w	#260,d1
	move.w	#262,d2
	bsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	move.w	#262,d1
	move.w	#256,d2
	bsr	clip.line.make.edge

	addq.w	#4,road.section.offset
	rts


rotate.opponent2
	move.l	#x.values,a4
	move.l	#y.values,a5
	move.w	4(a4,d1.w),d4
	sub.w	(a4,d1.w),d4
	asr.w	#1,d4
	move.w	4(a5,d1.w),d5
	sub.w	(a5,d1.w),d5
	asr.w	#1,d5
	move.w	d4,d0
	bpl.s	ro21
	neg.w	d0

ro21	cmp.w	#255,d0
	bcs.s	ro22
	move.w	#255,d0

ro22	move.w	d0,W.1bc6a
	move.w	d5,d0
	bpl.s	ro23
	neg.w	d0

ro23	cmp.w	#255,d0
	bcs.s	ro24
	move.w	#255,d0

ro24	move.w	d0,W.1bc68
	move.w	W.1bc6a,W.1bc64

	tst.w	d4
	bpl.s	ro25

	neg.w	W.1bc64
	bra.s	ro26

ro25	neg.w	W.1bc6a
ro26	move.w	W.1bc68,W.1bc66

	tst.w	d5
	bpl.s	ro27

	neg.w	W.1bc66
	neg.w	W.1bc68

ro27	asr.w	(W.1bc66).l
	asr.w	(W.1bc6a).l
	move.w	(a4,d1.w),d0
	add.w	d4,d0
	move.w	d0,W.1bc84

	move.w	(a5,d1.w),d0
	add.w	d5,d0
	move.w	d0,W.1bc86
	bra	opponent.fatten


dw.sub5	move.w	#64,d0
	bsr	ds57a
	move.w	d0,W.1bb12
	move.b	d1,W.1bb40

	bsr	fetch.near.section.stuff
	move.w	d1,d0
	bsr	dw.sub9.sub
	move.w	W.1bc30,d0
	sub.w	top.two.bits,d0
	move.w	d0,W.1bbf2

	move.w	near.left.offset,d0
	rol.w	#8,d0
	sub.w	#$b100,d0
	and.l	#$ffff,d0
	add.l	#road.section.words,d0
	move.l	d0,a4
	move.w	near.right.offset,d0
	rol.w	#8,d0
	sub.w	#$b100,d0
	and.l	#$ffff,d0
	add.l	#road.section.words,d0
	move.l	d0,a5
	move.b	W.1bb12,d1
	asl.w	#1,d1
	bsr	hit6
	move.w	d0,W.1bc02

	addq.b	#1,d1
	bsr	hit6
	move.w	d0,W.1bc04

	addq.b	#1,d1
	bsr	hit6
	move.w	d0,W.1bc06

	addq.b	#1,d1
	bsr	hit6
	move.w	d0,W.1bc08

	addq.b	#1,d1
	cmp.b	near.section.byte2,d1
	bcs	ds51

	bsr	to.next.road.section
	bsr	fetch.near.section.stuff
	move.w	near.left.offset,d0
	rol.w	#8,d0
	sub.w	#$b100,d0
	and.l	#$ffff,d0
	add.l	#road.section.words,d0
	move.l	d0,a4
	move.w	near.right.offset,d0
	rol.w	#8,d0
	sub.w	#$b100,d0
	and.l	#$ffff,d0
	add.l	#road.section.words,d0
	move.l	d0,a5
	move.w	#2,d1
	bsr	hit6
	move.w	d0,W.1bc0a

	addq.b	#1,d1
	bsr	hit6
	move.w	d0,W.1bc0c

	addq.b	#1,d1
	bsr	to.previous.road.section
	bsr	fetch.near.section.stuff
	move.w	near.left.offset,d0
	rol.w	#8,d0
	sub.w	#$b100,d0
	and.l	#$ffff,d0
	add.l	#road.section.words,d0
	move.l	d0,a4
	move.w	near.right.offset,d0
	rol.w	#8,d0
	sub.w	#$b100,d0
	and.l	#$ffff,d0
	add.l	#road.section.words,d0
	move.l	d0,a5
	bra.s	ds52

ds51	bsr	hit6
	move.w	d0,W.1bc0a

	addq.b	#1,d1
	bsr	hit6
	move.w	d0,W.1bc0c

	addq.b	#1,d1
ds52	move.b	W.1bb12,d0
	bsr	dw.sub5.sub

	move.w	#8,d2
	move.w	#0,d1
	bsr	dw.sub5.sub1

	move.w	#12,d2
	move.w	#2,d1
	bsr	dw.sub5.sub1

	bclr	#7,B.1bbe6
	move.l	#W.1bd66,a0
	move.l	#TAB.1ef4a,a3
	move.w	(a0),d0
	sub.w	2(a0),d0
	bpl.s	ds53
	neg.w	d0

ds53	asr.w	#4,d0
	move.b	(a3,d0.w),B.1bb43
	move.b	W.1bb12+1,W.1bc40+1

	move.w	W.1bbec,d0
	clr.w	d3
	move.b	B.1bb43,d3
	sub.w	d3,d0
	move.w	d0,W.1bc4c

	move.w	#0,d1
	bsr	dw.sub5.sub3

	move.w	#10,d2
	move.w	#8,d1
	move.w	W.1bc4c,d0
	bsr	ds5s11

	move.w	W.1bbec,d0
	clr.w	d3
	move.b	B.1bb43,d3
	add.w	d3,d0
	move.w	d0,W.1bc4c

	move.w	#2,d1
	bsr	dw.sub5.sub3

	move.w	#14,d2
	move.w	#8,d1
	move.w	W.1bc4c,d0
	bsr	ds5s11

	move.w	W.1bc02,d0
	sub.w	W.1bc06,d0
	bpl.s	ds54
	neg.w	d0

ds54	cmp.w	#20,d0
	blt.s	ds55
	move.b	#$80,B.1bbba

ds55	bsr.s	dw.sub5.sub2
	move.w	W.1bc02,d0
	sub.w	W.1bc06,d0
	bpl.s	ds56
	neg.w	d0

ds56	cmp.w	#20,d0
	blt.s	ds57
	move.b	#$80,B.1bbba

ds57	move.w	#255,d0

ds57a	move.b	opponents.road.section,d1
	move.b	d1,current.road.section

	move.w	W.1bb0c,d3
	sub.w	d3,d0
	neg.w	d0
	bpl.s	ds58

	move.w	d0,-(sp)
	bsr	to.previous.road.section
	bsr	fetch.near.section.stuff
	move.w	(sp)+,d3
	move.b	half.near.section.byte2.minus1,d0
	asl.w	#8,d0
	add.w	d3,d0

ds58	move.w	d0,W.1bc24
	move.b	d1,B.1bba6
	rts


dw.sub5.sub3
	bsr	hit8
	move.l	road.height.value,d0
	asr.l	#3,d0
	move.l	#W.1bd86,a0
	move.w	d0,(a0,d1.w)
	rts


dw.sub5.sub2
	move.l	#DAT.1bd8e,a0
	move.w	14(a0),d0
	sub.w	10(a0),d0
	move.w	d0,B.1bb2c

	asr.w	#1,d0
	add.w	d0,B.1bb2c

	move.w	46(a0),d0
	sub.w	42(a0),d0
	move.w	d0,B.1bb2a

	asr.w	#1,d0
	add.w	d0,B.1bb2a

	move.w	10(a0),d0
	sub.w	B.1bb2a,d0
	move.w	d0,16(a0)

	move.w	42(a0),d0
	add.w	B.1bb2c,d0
	move.w	d0,48(a0)

	move.w	14(a0),d0
	sub.w	B.1bb2a,d0
	move.w	d0,20(a0)

	move.w	46(a0),d0
	add.w	B.1bb2c,d0
	move.w	d0,52(a0)

	move.b	W.1bb12+1,d0
	add.b	#128,d0
	bcc.s	ds5s22

	move.w	W.1bc06,W.1bc02
	move.w	W.1bc08,W.1bc04
	move.w	W.1bc0a,W.1bc06
	move.w	W.1bc0c,W.1bc08

ds5s22	move.b	d0,W.1bc40+1
	move.b	W.1bbec+1,W.1bc4c+1
	move.w	#4,d1
	bra	dw.sub5.sub3


dw.sub5.sub1.sub
	move.l	#DAT.1bd8e,a0
	move.w	4(a0,d1.w),d0
	sub.w	(a0,d1.w),d0
	move.w	W.5a54e,d3
	muls	d3,d0
	asr.l	#8,d0
	tst.b	B.1bbe6
	bpl.s	dw.sub5.sub1.sub.sub

	addq.b	#4,d1
	bsr.s	dw.sub5.sub1.sub.sub

	subq.b	#4,d1
	rts


W.5a54e	dc.w	0


dw.sub5.sub1.sub.sub
	add.w	(a0,d1.w),d0
	move.w	d0,(a0,d2.w)
	rts


dw.sub5.sub1
	move.b	W.1bb12+1,d0
	move.l	#B.1bbbe,a0
	add.b	(a0,d1.w),d0
	roxr.b	#1,d3
	move.b	d3,B.1bbe6

	and.w	#255,d0
ds5s11	move.w	d0,W.5a54e

	bsr.s	dw.sub5.sub1.sub
	add.b	#32,d2
	add.b	#32,d1
	bra.s	dw.sub5.sub1.sub


dw.subG.sub.sub
	move.l	#DAT.1bd8e,a0
	move.w	(a0,d2.w),sin.x
	move.w	32(a0,d2.w),corner.values.offset-1
	bsr	dw.subF.sub2
	bsr	dw.subF.sub3
	bra	z.rotate0


dw.sub5.sub
	move.b	d0,d2
	move.w	near.offset3,d0
	rol.w	#8,d0
	sub.w	#$b100,d0
	and.l	#$ffff,d0
	add.l	#road.section.words,d0
	move.l	d0,a3
	move.b	(a3),d0
	addq.b	#7,d0
	move.b	d0,B.1bb91

	tst.b	banked.road.alternating.flag
	bne.s	dws5s2

	asl.b	#3,d2
	add.b	B.1bb91,d2
	move.b	#0,d1

dws5s1	bsr.s	dw.sub5.sub.sub
	addq.b	#2,d1
	cmp.b	#8,d1
	bne.s	dws5s1
	rts

dws5s2	move.b	half.near.section.byte2.minus1,d0
	sub.b	d2,d0
	subq.b	#1,d0
	asl.b	#3,d0
	add.b	B.1bb91,d0
	move.b	d0,d2
	move.b	#6,d1

dws5s3	bsr.s	dw.sub5.sub.sub
	subq.b	#2,d1
	bpl.s	dws5s3
	rts


dw.sub5.sub.sub
	bsr	dw.sub9.sub2
	move.l	#DAT.1bd8e,a1
	move.w	sin.x,(a1,d1.w)

	move.l	#DAT.1bd8e+32,a1
	move.w	corner.values.offset-1,(a1,d1.w)
	rts


collision1.sub2
	move.b	dnr.flag,d1
	beq.s	coll1.sub24

	cmp.b	#230,d1
	bcs.s	coll1.sub23

	bsr	coll1.sub2.sub3
	move.b	#44,d0
	tst.b	swing.from.left.or.right
	bpl.s	coll1.sub21
	move.b	#212,d0

coll1.sub21
	move.b	d0,W.1bc00
	move.b	#0,W.1bc00+1

coll1.sub22
	subq.b	#1,dnr.flag
	rts

coll1.sub23
	cmp.b	#229,d1
	bne.s	coll1.sub25

	move.b	#0,d0
	bsr	coll1.sub2.sub2

	move.b	#3,d0
	bsr	coll1.sub2.sub1
	bpl.s	coll1.sub22
coll1.sub24
	rts

coll1.sub25
	cmp.b	#228,d1
	bne.s	coll1.sub2a

	move.b	#4,d0
	bsr	coll1.sub2.sub1

	move.b	#$ff,d0
	bsr	coll1.sub2.sub2
	bne.s	coll1.sub29

	bsr	randomize.long
	and.b	#$1f,d0
	add.b	#160,d0
	move.b	#44,d2
	tst.b	B.1bbc4
	bpl.s	coll1.sub26
	move.b	#60,d2

coll1.sub26
	tst.b	B.1ca22
	bmi.s	coll1.sub27
	move.b	#140,d0

coll1.sub27
	move.b	d0,dnr.flag
	tst.b	B.1bb74
	beq.s	coll1.sub28
	move.b	#50,B.1bb74

coll1.sub28
	move.b	#4,d0
	bra	coll1.sub2.sub4

coll1.sub29
	rts

coll1.sub2a
	move.b	#0,d0
	bsr	coll1.sub2.sub2

	move.b	#2,d0
	bsr.s	coll1.sub2.sub1

	tst.b	unlimited.nitro
	bmi.s	coll1.sub2b

	subq.b	#1,dnr.flag
	bne.s	coll1.sub2b
	addq.b	#1,dnr.flag

coll1.sub2b
	move.b	B.1bbc4,d0
	bne.s	coll1.sub2c
	tst.b	dnr.flag
	bpl.s	coll1.sub2d
	rts

coll1.sub2c
	move.b	nitro.flag,d0
	bne.s	coll1.sub2e

coll1.sub2d
	move.b	#0,d0
	move.b	d0,dnr.flag
	move.b	d0,B.1bb9c
	move.b	d0,B.1bb8e
	move.b	#$80,d0
	move.b	d0,B.1bbc4
coll1.sub2e
	rts


coll1.sub2.sub1
	asl.w	#8,d0
	move.w	W.1bcd0,d3
	sub.w	W.1bc60,d3
	sub.w	d0,d3
	move.w	d3,d0
	asr.w	#3,d0
	sub.w	#256,d0
	bpl.s	coll1.sub2.sub11

	cmp.w	#-512,d0
	bcc.s	coll1.sub2.sub11
	move.w	#-512,d0

coll1.sub2.sub11
	sub.w	d0,W.1bd42
	lsr.w	#8,d3
	move.b	d3,d0
	addq.b	#2,d0
	rts


coll1.sub2.sub2
	move.b	#16,d4
	tst.b	swing.from.left.or.right
	bpl.s	coll1.sub2.sub21

	neg.b	d0
	move.b	#$f0,d4

coll1.sub2.sub21
	asl.w	#8,d0
	move.b	#238,d2
	beq.s	coll1.sub2.sub22

	muls	d2,d0
	asr.l	#8,d0

coll1.sub2.sub22
	move.w	clip.value,d3
	asl.w	#5,d3
	move.b	W.1bc00,d7
	cmp.b	d4,d7
	beq.s	coll1.sub2.sub23
	add.w	d0,W.1bc00

coll1.sub2.sub23
	move.w	W.1bc00,d0
	sub.w	d3,d0
	move.w	d0,z.angle
	move.w	#0,d0
	move.w	d0,W.1bd26
	move.b	W.1bc00,d0
	cmp.b	d4,d0
	rts


init.data3.sub
	move.w	#8,d1
	move.w	#4,d2
	move.l	#player.x,a3

id3s1	move.l	#sin.cos.values,a2
	move.w	(a2,d2.w),d0
	cmp.b	#8,d1
	bne.s	id3s2
	neg.w	d0

id3s2	move.b	swing.from.left.or.right,B.1bbbb
	move.b	#160,road.height.value+2

	move.b	road.height.value+2,d3
	and.w	#$ff,d3
	tst.b	B.1bbbb
	bpl.s	id3s3
	neg.w	d3

id3s3	asl.w	#7,d3
	muls	d3,d0
	asl.l	#1,d0
	swap	d0
	ext.l	d0
	asl.l	#6,d0
	add.l	d0,(a3,d1.w)
	move.b	#6,d2
	subq.b	#8,d1
	bpl.s	id3s1
	rts


update.engine.pitch
	move.b	off.ground.value,d0
	bne.s	uep1

	move.w	#0,d0
	move.b	player.input,d0
	and.b	#3,d0
	beq.s	uep2

	move.w	#$9000,d0
	bne.s	uep2

uep1	move.w	steering.values+4,d0
	and.w	#$fff0,d0
	bpl.s	uep2
	neg.w	d0

uep2	add.w	#$580,d0
	lsr.w	#3,d0
	move.w	W.1bc34,d3
	cmp.w	#192,d3
	bge.s	uep3

	move.w	#2,d0
	bra.s	uep4

uep3	sub.w	d3,d0
	asr.w	#3,d0

uep4	move.w	d0,W.1bbf4
	move.b	W.1bbf4,d0
	bmi.s	uep5
	beq.s	uep9

	move.b	#0,W.1bbf4+1
	move.b	#1,d0
	bra.s	uep8

uep5	move.b	off.ground.value,d2
	beq.s	uep6

	cmp.b	#$ff,d0
	beq.s	uep9

	move.b	#0,W.1bbf4+1
	move.b	#$ff,d0
	bra.s	uep8

uep6	cmp.b	#$ff,d0
	bne.s	uep7

	move.b	W.1bbf4+1,d0
	cmp.b	#$e0,d0
	bcc.s	uep9

uep7	move.b	#$e0,W.1bbf4+1
	move.b	#$ff,d0
uep8	move.b	d0,W.1bbf4

uep9	bsr	randomize.long
	and.b	#$f,d0
	move.b	#0,B.5b646
	rts


B.5b646	dc.b	0,0


delay	move.b	#20,d0
	move.b	d0,road.height.value+2

delay1	subq.b	#1,road.height.value+3
	bne.s	delay1

	subq.b	#1,road.height.value+2
	bne.s	delay1

	subq.b	#1,d2
	bne.s	delay
	rts


dw.sub4.sub1
	move.b	B.1bb44,d0
	beq	ds4s1f

	tst.b	B.57c3c
	bne	ds4s1f

	move.b	#0,d1
	move.b	d1,B.1bbbe
	move.b	d1,B.1bbbf
	move.b	d1,B.1bbbd
	move.b	B.1bbc0,d0
	beq.s	ds4s1c

	tst.b	unlimited.nitro
	bmi.s	ds4s1a
	subq.b	#1,B.1bbc0

ds4s1a	add.b	B.1bbc2,d0
	and.b	#$f,d0
	move.b	d0,d2
	move.l	#TAB.5be34,a2
	move.b	(a2,d2.w),d0
	bpl.s	ds4s1b

	neg.b	d0
	addq.b	#1,d1

ds4s1b	move.l	#B.1bbbe,a1
	move.b	d0,(a1,d1.w)
	addq.b	#5,d2
	and.b	#$f,d2
	move.l	#TAB.5be34,a2
	move.b	(a2,d2.w),d0
	move.b	d0,B.1bbbd
	bra.s	ds4s1e

ds4s1c	move.b	opponents.road.section,d2
	move.l	#opponent.acceleration.values,a0
	tst.b	(a0,d2.w)
	bmi.s	ds4s1e

	tst.b	B.1bbb8
	bmi.s	ds4s1e

	tst.b	near.section.byte1
	bmi.s	ds4s1e

	move.b	#8,d2
	tst.b	B.1bb9d
	bpl.s	ds4s1e

	btst	#6,B.1bb9d
	beq.s	ds4s1d
	move.b	#16,d2

ds4s1d	move.b	d2,B.1bbc2

	bsr	randomize.long
	and.b	#$1f,d0
	move.b	d0,road.height.value+3

	move.b	B.1ca29,d0
	cmp.b	road.height.value+3,d0
	blt.s	ds4s1e

	move.b	#16,d0
	move.b	d0,B.1bbc0

ds4s1e	move.b	banked.road.alternating.flag,d0
	lsr.b	#1,d0
	move.b	near.section.byte1,d3
	eor.b	d3,d0
	move.b	d0,B.1bb9d
ds4s1f	rts


TAB.5be34
	dc.b	$20,$50,$60,$70,$70,$60,$50,$20
	dc.b	$e0,$b0,$a0,$90,$90,$a0,$b0,$e0


dw.sub9	move.b	current.road.section,d1
	bsr	fetch.near.section.stuff
	move.w	near.offset3,d0
	rol.w	#8,d0
	sub.w	#$b100,d0
	and.l	#$ffff,d0
	add.l	#road.section.words,d0
	move.l	d0,a5
	move.w	d1,d0
	bsr	dw.sub9.sub

	move.w	W.1bc30,d0
	sub.w	top.two.bits,d0
	move.w	d0,W.1bbf2

	tst.b	near.section.byte1
	bmi	ds93

	btst	#6,near.section.byte1
	bne.s	ds92

	bsr	dw.sub9.sub1
	move.b	3(a5),d3
	asl.w	#8,d3
	move.b	2(a5),d3
	move.w	sin.x,d0
	sub.w	d3,d0
	move.w	d0,W.1bc5e
	move.w	corner.values.offset-1,W.1bb10
	move.w	top.two.bits,y.corner.angle
	rts

ds92	bsr	dw.sub9.sub1
	move.b	#181,road.height.value+2

	move.w	sin.x,d0
	sub.w	corner.values.offset-1,d0
	move.b	road.height.value+2,d3
	asl.w	#7,d3
	bclr	#15,d3
	muls	d3,d0
	asl.l	#1,d0
	swap	d0
	move.b	3(a5),d3
	asl.w	#8,d3
	move.b	2(a5),d3
	sub.w	d3,d0
	move.w	d0,W.1bc5e

	move.b	7(a5),road.height.value+2

	move.w	sin.x,d0
	add.w	corner.values.offset-1,d0
	move.b	road.height.value+2,d3
	asl.w	#7,d3
	bclr	#15,d3
	muls	d3,d0
	asl.l	#1,d0
	swap	d0
	move.w	d0,W.1bb10

	move.b	5(a5),d3
	asl.w	#8,d3
	move.b	4(a5),d3
	add.w	top.two.bits,d3
	move.w	d3,y.corner.angle
	rts

ds93	move.b	#2,d2
	bsr	dw.sub9.sub2

	move.w	sin.x,d0
	move.w	corner.values.offset-1,d3
	bsr	dw.sub9.sub3

	move.w	d0,-(sp)
	bsr	dw.sub9.sub4
	move.w	d0,W.1bc36

	move.w	(sp)+,d0
	add.w	W.1bc30,d0
	bpl.s	ds94

	add.w	#$8000,d0
	bra.s	ds95

ds94	sub.w	#$8000,d0

ds95	move.w	d0,W.1bc1c

	add.w	#$4000,d0
	sub.w	near.section.flag.byte3,d0
	move.w	d0,y.corner.angle

	move.b	near.section.byte1,d4
	and.b	#3,d4
	neg.b	d4
	addq.b	#1,d4
	move.b	7(a5),d3
	asl.w	#8,d3
	move.b	6(a5),d3
	asl.w	#6,d3
	move.w	W.1bc1c,d0
	sub.w	d3,d0
	sub.w	top.two.bits,d0
	bpl.s	ds96
	neg.w	d0

ds96	move.b	8(a5),road.height.value+2

	move.b	road.height.value+2,d3
	asl.w	#7,d3
	bclr	#15,d3
	muls	d3,d0
	asl.l	#1,d0
	swap	d0
	tst.b	d4
	bpl.s	ds97

	neg.b	d4
	and.l	#7,d4
	asl.w	d4,d0
	bra.s	ds98

ds97	and.l	#7,d4
	lsr.w	d4,d0

ds98	move.w	d0,W.1bb10

	lsr.w	#7,d0
	addq.b	#2,d0
	cmp.b	near.section.byte2,d0
	blt.s	ds9c

	move.b	bottom.four.bits,d0
	cmp.b	#1,d0
	beq.s	ds99

	cmp.b	#3,d0
	bne.s	ds9c

ds99	move.b	current.road.section,road.height.value+1
	tst.b	banked.road.alternating.flag
	beq.s	ds9a

	bsr	to.previous.road.section
	bra.s	ds9aa

ds9a	bsr	to.next.road.section

ds9aa	move.l	#near.road.section.bytes2,a1
	move.b	(a1,d1.w),d0
	and.b	#$f,d0
	cmp.b	#4,d0
	bne.s	ds9b
	bra	dw.sub9

ds9b	move.b	road.height.value+1,current.road.section

ds9c	bsr	dw.sub9.sub5

	move.b	10(a5),d3
	asl.w	#8,d3
	move.b	9(a5),d3
	sub.w	W.1bc36,d3
	tst.b	near.section.flag.byte3
	bpl.s	ds9d
	neg.w	d3

ds9d	move.w	d3,W.1bc5e
	rts


hit6	move.b	d1,d2
	tst.b	current.near.left.road.section.ID
	bpl.s	hit6.2

	bclr	#0,d2
	btst	#0,d1
	bne.s	hit6.1

	move.b	1(a4,d2.w),d3
	move.b	(a4,d2.w),d0
	and.b	#$7f,d0
	asl.w	#8,d0
	or.b	d3,d0
	add.w	near.left.word,d0
	bra.s	hit6.4

hit6.1	move.b	1(a5,d2.w),d3
	move.b	(a5,d2.w),d0
	and.b	#$7f,d0
	asl.w	#8,d0
	or.b	d3,d0
	add.w	near.right.word,d0
	bra.s	hit6.4

hit6.2	lsr.b	#1,d2
	bcs.s	hit6.3

	move.b	(a4,d2.w),d0
	move.b	d0,d3
	asl.b	#1,d0
	and.w	#$e0,d0
	and.b	#$f,d3
	asl.w	#8,d3
	or.w	d3,d0
	add.w	near.left.word,d0
	bra.s	hit6.4

hit6.3	move.b	(a5,d2.w),d0
	move.b	d0,d3
	asl.b	#1,d0
	and.w	#$e0,d0
	and.b	#$f,d3
	asl.w	#8,d3
	or.w	d3,d0
	add.w	near.right.word,d0

hit6.4	asr.w	#5,d0
	rts


dw.subB	move.w	W.1bb10,d0
	move.b	half.near.section.byte2.minus1,d4
	asl.w	#8,d4
	tst.b	banked.road.alternating.flag
	bpl.s	dsB1

	sub.w	d4,d0
	neg.w	d0

dsB1	move.w	d0,W.1bb0a

	add.w	#64,d0
	move.w	d0,W.1bb0e

	cmp.w	d4,d0
	blt.s	dsB2

	move.b	#$80,W.1bb0e
	move.w	#0,d0

dsB2	lsr.w	#8,d0
	addq.b	#1,d0
	asl.b	#1,d0
	move.b	d0,B.1bbe5

	asl.b	#1,d0
	move.b	d0,B.1bb60

	move.b	banked.road.alternating.flag,d0
	bpl.s	dsB3

	move.w	d4,d0
	sub.w	W.1bb10,d0
	lsr.w	#8,d0
	bra.s	dsB4

dsB3	move.b	W.1bb10,d0

dsB4	move.b	#32,d3
	sub.b	d0,d3
	tst.b	W.1bb0e
	bpl.s	dsB5

	add.b	half.near.section.byte2.minus1,d3

dsB5	move.b	d3,B.1bb58
	and.w	#255,d3
	move.w	d3,W.1bc26
	rts


hit1	move.b	player.road.section,d1
	move.b	d1,current.road.section
	bsr	fetch.near.section.stuff
	move.b	#0,at.side.flag
	move.b	#4,d1

hit1.1	move.b	d1,corner.values.offset
	move.b	player.road.section,d0
	cmp.b	current.road.section,d0
	beq.s	hit1.2

	move.b	d0,d1
	move.b	d1,current.road.section
	bsr	fetch.near.section.stuff
	move.b	corner.values.offset,d1

hit1.2	move.b	near.section.byte4,road.height.value+2
	move.l	#corner.value1,a1
	move.w	(a1,d1.w),d0
	asr.w	#4,d0
	add.w	W.1bc5e,d0
	cmp.w	#384,d0
	bcs.s	hit1.4

	bset	#7,B.1bb65
	move.w	d0,W.1bc22
	bmi.s	hit1.3

	move.b	#$ff,d0
	bra.s	hit1.6

hit1.3	move.b	#0,d0
	bra.s	hit1.6

hit1.4	tst.w	d0
	bpl.s	hit1.5
	neg.w	d0

hit1.5	move.b	road.height.value+2,d3
	asl.w	#7,d3
	bclr	#15,d3
	muls	d3,d0
	asl.l	#1,d0
	swap	d0
	cmp.w	#256,d0
	blt.s	hit1.6
	move.b	#$ff,d0			didn't have the # infront

hit1.6	move.b	d0,W.1bc4c+1
	tst.b	banked.road.alternating.flag
	bpl.s	hit1.7
	eor.b	#$ff,d0

hit1.7	cmp.b	#4,d1
	bne.s	hit1.8
	move.b	d0,B.1bba1

hit1.8	move.b	near.section.byte5,road.height.value+2
	move.l	#corner.value4,a1
	move.w	(a1,d1.w),d0
	asr.w	#3,d0
	move.b	road.height.value+2,d3
	asl.w	#7,d3
	bclr	#15,d3
	muls	d3,d0
	asl.l	#1,d0
	swap	d0
	add.w	W.1bb10,d0
	move.w	d0,W.1bc40
	move.b	W.1bc40,d0
	asl.b	#1,d0
	move.b	d0,B.1bba3
	bmi.s	hit1.9

	cmp.b	near.section.byte2.minus2,d0
	blt.s	hit1.a

hit1.9	bsr	hit3

hit1.a	move.w	near.left.offset,d0
	rol.w	#8,d0
	sub.w	#$b100,d0
	and.l	#$ffff,d0
	add.l	#road.section.words,d0
	move.l	d0,a4

	move.w	near.right.offset,d0
	rol.w	#8,d0
	sub.w	#$b100,d0
	and.l	#$ffff,d0
	add.l	#road.section.words,d0
	move.l	d0,a5

	tst.b	banked.road.alternating.flag
	bmi.s	hit1.d

	move.b	B.1bba3,d1
	bsr	hit6
	move.w	d0,W.1bc02

	addq.b	#1,d1
	bsr	hit6
	move.w	d0,W.1bc04

	addq.b	#1,d1
	bsr	hit6
	move.w	d0,W.1bc06

	addq.b	#1,d1
	bsr	hit6
	move.w	d0,W.1bc08

	addq.b	#1,d1
	bra.s	hit1.c

hit1.d	move.b	near.section.byte2,d1
	sub.b	B.1bba3,d1
	subq.b	#4,d1
	bsr	hit6
	move.w	d0,W.1bc08

	addq.b	#1,d1
	bsr	hit6
	move.w	d0,W.1bc06

	addq.b	#1,d1
	bsr	hit6
	move.w	d0,W.1bc04

	addq.b	#1,d1
	bsr	hit6
	move.w	d0,W.1bc02
	addq.b	#1,d1

hit1.c	move.b	corner.values.offset,d1
	bsr	hit7
	subq.b	#2,d1
	bpl	hit1.1
	rts


dw.sub9.sub1
	tst.b	W.1bbf2
	bmi.s	ds9s12

	btst	#6,W.1bbf2
	bne.s	ds9s11

	move.w	#0,d0
	sub.w	B.1bb22,d0
	move.w	d0,sin.x

	move.w	#0,d0
	sub.w	B.1bb26,d0
	move.w	d0,corner.values.offset-1
	rts

ds9s11	move.w	#0,d0
	sub.w	B.1bb26,d0
	move.w	d0,sin.x

	move.w	#2048,d0
	add.w	B.1bb22,d0
	move.w	d0,corner.values.offset-1
	rts

ds9s12	btst	#6,W.1bbf2
	bne.s	ds9s13

	move.w	#2048,d0
	add.w	B.1bb22,d0
	move.w	d0,sin.x

	move.w	#2048,d0
	add.w	B.1bb26,d0
	move.w	d0,corner.values.offset-1
	rts

ds9s13	move.w	#2048,d0
	add.w	B.1bb26,d0
	move.w	d0,sin.x

	move.w	#0,d0
	sub.w	B.1bb22,d0
	move.w	d0,corner.values.offset-1
	rts


hit3	move.b	W.1bc40,d0
	move.b	banked.road.alternating.flag,d3
	eor.b	d3,d0
	bpl.s	hit3.1

	bsr.s	to.previous.road.section
	bsr	fetch.near.section.stuff
	move.b	banked.road.alternating.flag,d0
	bpl.s	hit3.3
	bmi.s	hit3.2

hit3.1	bsr.s	to.next.road.section
	bsr	fetch.near.section.stuff
	tst.b	banked.road.alternating.flag
	bmi.s	hit3.3

hit3.2	move.b	#0,B.1bba3
	tst.b	W.1bc40
	bpl.s	hit3.6
	bmi.s	hit3.4

hit3.3	move.b	near.section.byte2,d0
	subq.b	#4,d0
	move.b	d0,B.1bba3
	tst.b	W.1bc40
	bmi.s	hit3.6

hit3.4	neg.b	W.1bc40+1
	bne.s	hit3.5
	move.b	#$ff,W.1bc40+1

hit3.5	neg.b	W.1bc4c+1
	bne.s	hit3.6
	move.b	#$ff,W.1bc4c+1
hit3.6	rts


to.next.road.section
	move.b	current.road.section,d1
	addq.b	#1,d1
	cmp.b	number.of.road.sections,d1
	blt.s	tnrs
	move.b	#0,d1

tnrs	move.b	d1,current.road.section
	rts


to.previous.road.section
	move.b	current.road.section,d1
	subq.b	#1,d1
	bpl.s	tprs
	move.b	number.of.road.sections,d1
	subq.b	#1,d1

tprs	move.b	d1,current.road.section
	rts


hit8	move.b	W.1bc4c+1,d3
	and.w	#$ff,d3
	move.w	W.1bc04,d0
	sub.w	W.1bc02,d0
	muls	d3,d0
	move.w	W.1bc02,d4
	ext.l	d4
	asl.l	#8,d4
	add.l	d4,d0
	move.l	d0,d5
	move.w	W.1bc08,d0
	sub.w	W.1bc06,d0
	muls	d3,d0
	move.w	W.1bc06,d4
	ext.l	d4
	asl.l	#8,d4
	add.l	d4,d0
	move.b	W.1bc40+1,d3
	and.w	#$ff,d3
	sub.l	d5,d0
	move.l	d0,d4
	bpl.s	hit8.1
	neg.l	d4

hit8.1	cmp.l	#$8000,d4
	blt.s	hit8.4
	asr.l	#3,d0
	tst.w	d0
	bpl.s	hit8.2
	neg.w	d0
	mulu	d3,d0
	move.b	#0,d0
	neg.l	d0
	bra.s	hit8.3

hit8.2	mulu	d3,d0

hit8.3	asl.l	#3,d0
	bra.s	hit8.6

hit8.4	tst.w	d0
	bpl.s	hit8.5
	neg.w	d0
	mulu	d3,d0
	move.b	#0,d0
	neg.l	d0
	bra.s	hit8.6

hit8.5	mulu	d3,d0

hit8.6	asr.l	#8,d0
	add.l	d5,d0
	move.l	d0,road.height.value
	rts


hit7	bsr	hit8
	asl.b	#1,d1
	move.l	#L.1bca4,a3
	bclr	#7,B.1bb65
	beq.s	hit7.1
	bsr	hit9

hit7.1	move.b	W.1bd5c,d0
	cmp.b	#10,d0
	blt.s	hit7.3

hit7.2	move.l	#L.1bca4,a0
	move.l	road.height.value,(a3,d1.w)
	lsr.b	#1,d1
	rts

hit7.3	move.b	x.angle,d0
	bpl.s	hit7.4
	neg.b	d0

hit7.4	cmp.b	#5,d0
	bgt.s	hit7.2
	move.l	(a3,d1.w),d0
	add.l	road.height.value,d0
	roxr.l	#1,d0
	move.l	d0,(a3,d1.w)
	lsr.b	#1,d1
	rts


dw.sub9.sub5
	move.w	sin.x,d0
	bsr	square.it
	move.l	d0,d4

	move.w	corner.values.offset-1,d0
	bsr	square.it
	add.l	d0,d4

	move.w	W.1bc36,d0
	bsr	square.it
	move.b	bottom.four.bits,d2
	move.l	#TAB.5c6b8,a0
	move.b	(a0,d2.w),road.height.value+2

	sub.l	d0,d4
	lsr.l	#8,d4
	move.w	d4,d0
	move.b	road.height.value+2,d3
	asl.w	#7,d3
	bclr	#15,d3
	muls	d3,d0
	asl.l	#1,d0
	swap	d0
	asr.w	#4,d0
	add.w	d0,W.1bc36
	rts


TAB.5c6b8
	dc.b	0,$d4,$80,$d4,0,0,$ab,$ab,$40,$40,0,0


dw.sub9.sub2
	move.w	near.offset3,d0
	rol.w	#8,d0
	sub.w	#$b100,d0
	and.l	#$ffff,d0
	add.l	#road.section.words,d0
	move.l	d0,a5
	tst.b	W.1bbf2
	bmi.s	ds9s22

	btst	#6,W.1bbf2
	bne.s	ds9s21

	move.b	1(a5,d2.w),d3
	asl.w	#8,d3
	move.b	(a5,d2.w),d3
	addq.b	#2,d2
	move.w	B.1bb22,sin.x

	add.w	d3,sin.x
	move.b	1(a5,d2.w),d3
	asl.w	#8,d3
	move.b	(a5,d2.w),d3
	addq.b	#2,d2
	move.w	B.1bb26,corner.values.offset-1
	add.w	d3,corner.values.offset-1
	rts

ds9s21	move.b	1(a5,d2.w),d3
	asl.w	#8,d3
	move.b	(a5,d2.w),d3
	addq.b	#2,d2
	move.w	B.1bb26,corner.values.offset-1
	add.w	d3,corner.values.offset-1

	move.b	1(a5,d2.w),d3
	asl.w	#8,d3
	move.b	(a5,d2.w),d3
	addq.b	#2,d2
	move.w	B.1bb22,sin.x
	sub.w	d3,sin.x
	add.w	#2048,sin.x
	rts

ds9s22	btst	#6,W.1bbf2
	bne.s	ds9s23

	move.b	1(a5,d2.w),d3
	asl.w	#8,d3
	move.b	(a5,d2.w),d3
	addq.b	#2,d2
	move.w	B.1bb22,sin.x
	sub.w	d3,sin.x
	add.w	#2048,sin.x

	move.b	1(a5,d2.w),d3
	asl.w	#8,d3
	move.b	(a5,d2.w),d3
	addq.b	#2,d2
	move.w	B.1bb26,corner.values.offset-1
	sub.w	d3,corner.values.offset-1
	add.w	#2048,corner.values.offset-1
	rts

ds9s23	move.b	1(a5,d2.w),d3
	asl.w	#8,d3
	move.b	(a5,d2.w),d3
	addq.b	#2,d2
	move.w	B.1bb26,corner.values.offset-1
	sub.w	d3,corner.values.offset-1
	add.w	#2048,corner.values.offset-1

	move.b	1(a5,d2.w),d3
	asl.w	#8,d3
	move.b	(a5,d2.w),d3
	addq.b	#2,d2
	move.w	B.1bb22,sin.x
	add.w	d3,sin.x
	rts


hit9	move.w	W.1bc22,d0
	bmi.s	hit9.1
	move.w	#384,d0
	sub.w	W.1bc22,d0
	bpl.s	hit9.2

hit9.1	neg.w	d0

hit9.2	cmp.w	#48,d0
	bgt.s	hit9.4
	and.l	#$ff,d0
	asl.l	#4,d0
	move.l	road.height.value,d3
	sub.l	d0,d3
	sub.l	#$100,d3
	cmp.l	#$1000,d3
	blt.s	hit9.4
	move.l	d3,road.height.value
	move.b	W.1bc22,d3
	move.b	banked.road.alternating.flag,d0
	eor.b	d3,d0
	and.b	#128,d0
	bmi.s	hit9.3
	move.b	#64,d0

hit9.3	move.b	d0,B.1bbda
	rts

hit9.4	move.l	#$1000,road.height.value
	move.b	at.side.flag,d0
	lsr.b	#1,d0
	bset	#7,d0
	move.b	d0,at.side.flag
	rts


race.and.practise
	tst.b	B.57c3c
	beq	rap1

rap1	move.b	#0,B.57c5b
	move.b	#0,B.57c63
	bsr	initialise.data

	move.l	#car.colours,a1
	bsr	copy.st.dest.colours

	move.b	#14,d0
	bsr	set.bground.masks
	move.b	#0,d0
	bsr	set.text.masks

	move.b	#9,d3
	move.b	#10,d0
	tst.b	B.1c9d0
	beq.s	rap2

	move.b	#0,d3
	move.b	#8,d0

rap2	move.b	d3,side.lines.colour
	move.b	d0,sides.colour

	bsr	print.boost.text

	move.b	B.1ca1b,d1
	move.b	d1,opponents.road.section

	move.b	#4,W.1bb0c
	move.b	#76,W.1bbec+1
	bsr	initialise.data2

	move.b	B.1ca1b,d1
	cmp.b	#$40,B.57c3c
	bne.s	rap3
	move.b	#$80,swing.from.left.or.right

rap3	bsr	initialise.data3+4
	bsr	update.wheel.positions
	bsr	init.table
	bsr	draw.world
	jsr	(frames.per.sec).l

	subq.b	#1,B.1bbac
	bsr	update.screens
	bsr	car.movement
	bsr	draw.world

	subq.b	#1,B.1bbac
	bsr	display.speed.bar
	jsr	(frames.per.sec).l
	bsr	update.screens

	move.b	#$80,d0
	move.b	d0,B.1bb72
	move.b	d0,B.5d724

	move.b	#3,d2
	bsr	delay
	bsr	fade.screen.in

	move.w	#$8020,W.69ede
	bsr	start.engine.sound

race.loop
	subq.b	#1,B.1bbac
	bsr	car.control
	bsr	car.movement
	bsr	update.engine.pitch
	bsr	draw.world
	bsr	display.speed.bar
	jsr	(frames.per.sec).l

	move.b	B.1bb6f,d0
	and.b	B.1bbc8,d0
	bpl	rapa

	tst.b	B.1bbcc
	bne	rapa

	tst.b	B.57c3c
	beq.s	rap5

	tst.b	B.1bb76
	bne.s	rapa

rap5	tst.b	dnr.flag
	bne.s	rap6

	move.b	off.ground.value,d0
	beq.s	rapa

rap6	tst.b	B.1bbaf
	bne.s	rap8

	move.b	B.57c3c,d0
	beq.s	rap7

	move.b	#0,B.1bbb4
	cmp.b	B.1bbe2,d0
	bne.s	rap8

rap7	move.b	#11,d2
	move.b	#192,B.1bbb4

rap8	move.b	#60,d2
	move.b	#4,d0

	move.w	#-8,W.1bbf4
	move.b	#0,W.1bc62
	cmp.b	#69,B.1bb73
	bne.s	rap9

	move.b	B.1c9cf,d2
	beq	rap9

rap9	bsr	update.screens
	move.b	#$80,B.1bb63
	move.b	#$80,B.57c5b
	jsr	(sound.off).l
	bra.s	rapf

rapa	bsr	update.screens
	move.b	dnr.flag,d0
	bne.s	rapd

	move.b	B.1bb9c,d2
	bpl.s	rapd

	move.b	off.ground.value,d0
	beq.s	rapd

	move.b	W.1bcd0,d0
	bmi.s	rapb

	cmp.b	#2,d0
	bge.s	rapc

rapb	move.b	d2,B.1bb75

rapc	subq.b	#1,W.1bb40+1
	bpl.s	rapd

	addq.b	#1,W.1bb40+1
	move.b	B.1bb6c,d0
	bne.s	rapd

	jsr	(sound.off).l
	move.b	B.1bb9b,d1
	bra	rap3

rapd	tst.b	dnr.flag
	bne.s	rape

	tst.b	B.1bb9c
	bmi	race.loop

	tst.b	off.ground.value
	beq	race.loop

rape	btst	#6,$bfe001.l		temporary quit routine
	bne	race.loop
rapf	rts


B.5d724	dc.b	0,0


initialise.data
	move.l	#W.1baf8,a0
.clear	move.b	#0,(a0)+
	cmp.l	#DAT.1bdd0,a0
	bne.s	.clear

	move.l	#league.values,a0
	move.l	#W.1baf8,a1
	move.b	B.1c9d0,d1
	move.b	#0,d2
.copy	move.b	(a0,d1.w),(a1,d2.w)
	addq.b	#1,d1
	addq.b	#1,d2
	cmp.b	#11,d2
	bne.s	.copy

	move.w	#127,W.1bc20
	move.b	#186,B.1bbdd

	move.b	#2,d1
.set	move.b	#9,d0
	move.l	#DAT.1c908,a1
	move.b	d0,(a1,d1.w)
	subq.b	#1,d1
	bpl.s	.set

	move.b	B.5eb79,d1
	add.b	#12,d1
	bsr	clear.three.bytes

	tst.b	B.57c3c
	beq.s	id1

	move.b	B.1ca29,d1
	add.b	#12,d1
	bsr	clear.three.bytes

id1	bsr	make.sin.cos
	move.w	#1024,x.amount
	move.w	#$ff00,W.1bc56
	jsr	(sound.off).l

	move.b	#4,B.1bb99
	bsr	set.random.values
	move.b	#$3b,random.long+3

	move.b	B.1ca2c,d1
	tst.b	B.1c9d0
	beq.s	id2
	move.b	B.1ca2d,d1

id2	move.b	#0,d0
	move.b	#1,d3
	and.b	#$f,ccr
.add	abcd.b	d3,d0
	subq.b	#1,d1
	bne.s	.add

	move.b	d0,nitro.reserve
	move.b	d0,nitro.max.units
	move.b	B.1c9cf,B.1bbb5

	move.l	#key.array,a0
	move.w	#128-1,d0
.clear.key
	move.b	#0,(a0,d0.w)
	dbra	d0,.clear.key

	move.l	#edge.space,a0
	move.w	#10000-1,d3
	move.b	#0,d0
.clear	move.b	d0,(a0)+
	dbra	d3,.clear

	bsr	set.sprite.colours

	move.b	#62,d1
	move.l	#DAT.1be70,a1
	move.l	#DAT.1bdd0,a2
.set	move.w	#$8000,120(a1,d1.w)
	move.b	#$80,(a2,d1.w)
	subq.b	#2,d1
	bpl.s	.set
	rts


init.damage.bar
	tst.b	B.5eb76
	beq.s	idb

	move.b	B.5eb79,d1
	move.l	#DAT.1ca36,a0
	move.b	(a0,d1.w),B.1c9cf
idb	bra	init.damage.bar2


car.control
	bsr	get.player.input
	move.b	off.ground.value,d0
	beq.s	left.right.done

	move.b	dnr.flag,d0
	bne.s	left.right.done

	move.b	player.input,d0
	and.b	#$c,d0
	beq.s	left.right.done

	cmp.b	#4,d0
	beq.s	car.right

	move.b	#15,d0
	bne.s	left.right.done

car.right
	move.b	#-15,d0

left.right.done
	move.b	d0,left.right.value

	move.b	player.input,d0
	and.b	#$10,d0
	eor.b	#$10,d0
	move.b	d0,nitro.flag

	move.b	#0,d2
	move.b	#0,d1
	move.b	steering.values+4,d0
	bmi.s	jc3

	cmp.b	#120,d0
	bcc.s	save.accelerate.value

jc3	move.b	dnr.flag,d0
	bne.s	save.accelerate.value

	move.b	L.1bca0+2,d0
	bne.s	save.accelerate.value

	move.b	player.input,d0
	and.b	#3,d0
	cmp.b	#1,d0
	beq.s	car.accelerate
	bgt.s	car.brake

	move.b	accelerating,d0
	bpl.s	save.accelerate.value

car.accelerate
	move.b	engine.power,d1
	move.b	engine.power+1,d2
	move.b	#$80,d0
	bne.s	save.accel.flag

car.brake
	move.b	#$10,d1
	move.b	#$ff,d2			$ff10 for braking
	move.b	#0,d0
save.accel.flag
	move.b	d0,accelerating

save.accelerate.value
	move.b	d1,car.acceleration+1
	move.b	d2,car.acceleration
	bsr	nitro.power
	rts


start.engine.sound
	move.b	#7,d0			tick over
	jsr	(sound.effect).l
	bsr	update.engine.pitch
	rts


which.screen
	dc.b	0,0


update.screens
	tst.b	frame.count
	bne.s	update.screens

	eor.b	#1,which.screen
	move.b	which.screen,d0
	addq.b	#5,d0
	move.b	#MIN.FRAMES,frame.count

	move.l	screen.mem,d0
	move.l	d0,d3
	move.b	B.1bbc8,d4
	eor.b	#$80,d4
	move.b	d4,B.1bbc8
	bpl.s	uscr2

	move.b	#$80,B.1bcc8
	add.l	#32000,d0
	bra.s	uscr3

uscr2	move.b	#0,B.1bcc8
	add.l	#32000,d3

uscr3	move.l	d0,screen1
	move.l	d3,screen2
	bra	set.current.scene


print.dec.digit
	addq.b	#1,print.fine.x
ascii.digit
	add.b	#'0',d0
	bra	print.character


clear.three.bytes
	move.b	#0,d0
	move.l	#DAT.1c920,a1
	move.b	d0,(a1,d1.w)
	move.l	#DAT.1c938,a1
	move.b	d0,(a1,d1.w)
	move.l	#DAT.1c908,a1
	move.b	d0,(a1,d1.w)
	rts


copy.stop.watch
	move.b	d2,B.1bb8c
	move.b	#17,d0			stop watch bright
	cmp.b	#7,d2
	beq.s	copy.stop.watch.bright
	move.b	#18,d0			stop watch dull

copy.stop.watch.bright
	bra.s	copy.watch.or.flag

copy.chequered.flag
	move.b	#11,d2
	bsr	calculate.if.winning
	bpl.s	copy.chequered.flag.dull
	move.b	#7,d2

copy.chequered.flag.dull
	move.b	d2,opponent.infront.behind.value
	move.b	#15,d0			chequered flag bright
	cmp.b	#7,d2
	beq.s	copy.watch.or.flag
	move.b	#16,d0			chequered flag dull

copy.watch.or.flag
	move.w	d2,-(sp)
	move.l	screen2,-(sp)
	move.l	screen.mem,screen2
	move.w	d0,-(sp)
	bsr	copy.graphic
	move.w	(sp)+,d0

	move.l	screen2,d3
	add.l	#32000,d3
	move.l	d3,screen2
	bsr	copy.graphic

	move.l	(sp)+,screen2
	move.w	(sp)+,d2
	rts


display.speed.bar
	move.w	steering.values+4,d0
	sub.w	#$1100,d0
	bpl.s	dsb1
	move.w	#0,d0

dsb1	move.w	#$b700,d3
	mulu	d3,d0
	swap	d0
	lsr.w	#7,d0
	cmp.w	#128,d0
	blt.s	dsb2
	sub.w	#128,d0
dsb2	move.w	d0,W.1bc18

	sub.w	W.1bc20,d0
	bne.s	dsb3
	bra	dsb7

dsb3	move.l	screen.mem,a6
	lea	174*40+12(a6),a6
	move.w	W.1bc20,d4
	move.w	W.1bc18,d5
	addq.w	#1,d4
	addq.w	#1,d5
	tst.w	d0
	bmi.s	dsb4

	move.b	#3,d0
	bra.s	dsb5

dsb4	move.b	#0,d0
	exg	d4,d5

dsb5	bsr	make.masks

	move.l	#start.masks,a5
	bsr	fill.horizontal.line
	move.l	a6,a0
	lea	32000(a0),a0
	move.w	#7,d3

dsb6	move.w	(a6),40(a6)
	move.w	8000(a6),8040(a6)
	move.w	16000(a6),16040(a6)
	move.w	24000(a6),24040(a6)

	move.w	(a6),(a0)
	move.w	8000(a6),8000(a0)
	move.w	16000(a6),16000(a0)
	move.w	24000(a6),24000(a0)

	move.w	(a6),40(a0)
	move.w	8000(a6),8040(a0)
	move.w	16000(a6),16040(a0)
	move.w	24000(a6),24040(a0)

	addq.l	#2,a6
	addq.l	#2,a0
	dbra	d3,dsb6

dsb7	move.w	W.1bc18,W.1bc20
	rts


print.boost.text
	move.b	#2,print.fine.y
	move.b	#4,print.fine.x

	move.b	#31,d0
	bsr	print.character
	move.b	#8,d0			column 8
	bsr	print.character
	move.b	#22,d0			row 22
	bsr	print.character

	move.b	#'B',d0
	bsr	print.character

	move.b	#0,print.fine.x
	move.b	#0,print.fine.y
	rts


coll1.sub2.sub4
	move.b	#$80,B.1bb8e
	move.b	d2,B.5e65b
	move.b	d0,B.5e65a
	rts


race.prompts
	tst.b	B.1bb8e
	bmi.s	rp2
rp1	rts

rp2	move.b	B.1bb6c,d0
	beq.s	rp4
	bmi.s	rp3

	cmp.b	#3,d0
	bge.s	rp4

rp3	cmp.b	#60,B.5e65b
	bne.s	rp1

rp4	tst.b	B.1bba4
	bmi.s	rp1

	move.b	#$80,or.with.screen
	move.b	#$80,second.screen
	move.b	#0,d0
	tst.b	B.1bb88
	beq.s	rp5
	move.b	#15,d0

rp5	bsr	set.text.masks
	move.b	B.5e65a,B.1bb90

	move.b	B.5e65b,d2
	move.b	d1,-(sp)
	move.b	#4,print.row
	move.b	#19,print.column
	move.b	#3,print.fine.x
	move.b	#0,print.fine.y
	cmp.b	#2,B.5e65a
	bne.s	rp6
	move.b	#5,print.fine.y

rp6	move.l	#race.prompt.text,a2
	move.b	(a2,d2.w),d1
	cmp.b	#'!',d1
	bne.s	rp7

	move.b	#19,print.column
	move.b	#5,print.row
	move.b	#3,print.fine.x
	move.b	#2,print.fine.y

rp7	addq.b	#1,d2
	move.b	#3,d0
	move.b	d0,B.1bb48

rp8	move.l	#race.prompt.text,a2
	move.b	(a2,d2.w),d0
	cmp.b	#'<',d0
	bne.s	rp9

	addq.b	#4,print.fine.x
	bra.s	rpa

rp9	bsr	print.character
	addq.b	#1,print.fine.x

rpa	addq.b	#1,d2
	addq.b	#1,d1
	subq.b	#1,B.1bb48
	bne.s	rp8

	subq.b	#1,B.1bb90
	bne.s	rp6

	move.b	(sp)+,d1
	move.b	#0,or.with.screen
	move.b	#0,second.screen
	move.b	#0,print.fine.x
	move.b	#0,print.fine.y
	move.b	#0,d0
	bsr	set.text.masks
	rts


B.5e65a	dc.b	0
B.5e65b	dc.b	0


race.prompt.text
	dc.b	3,'<WRCECK'
	dc.b	3,' RACCE !< WaON aT  '
	dc.b	3,' RACCE ! LOaST '
	dc.b	3,' DRCOP !<STaART'
	dc.b	3,'<PRCESS! FIaRE '
	dc.b	3,'PAUCSED'
	dc.b	3,' LACPS ! OVaER '
	dc.b	3,'DEFCINE! KEaYS '
	dc.b	3,'<STCEER! LEaFT '
	dc.b	3,'<STCEER!<RIaGHT'
	dc.b	3,'<AHCEAD!+BOaOST'
	dc.b	3,' BACCK !+BOaOST'
	dc.b	3,' BACCK !   a   '
	dc.b	3,'VERCIFY! KEaYS '
	dc.b	3,'<FACULT!<FOaUND<T'
	dc.b	6,26


wheel.frame.number
	move.b	B.1bbdb,d0
	tst.w	steering.values+4
	bpl.s	wfn1

	subq.b	#1,d0
	bpl.s	wfn2
	move.b	#2,d0
	bra.s	wfn2

wfn1	addq.b	#1,d0
	cmp.b	#3,d0
	bcs.s	wfn2
	move.b	#0,d0

wfn2	move.b	d0,B.1bbdb
	rts


update.wheel.positions
	move.b	#0,d1
	move.w	#48,d3
	move.l	#graphic.info,a2

uwp1	move.l	#W.1bd14,a0
	move.w	(a0,d1.w),d0
	add.w	#256,d0
	bpl.s	uwp2
	move.w	#0,d0

uwp2	cmp.w	#2048,d0
	bcs.s	uwp3
	move.w	#2047,d0

uwp3	lsr.w	#3,d0
	not.b	d0
	asl.w	#1,d0
	move.l	#sin.table,a1
	move.w	(a1,d0.w),d0
	rol.w	#5,d0
	and.b	#$1f,d0
	not.b	d0
	add.b	B.1bbdd,d0
	move.b	B.1bbda,d4
	asl.w	#1,d4
	move.b	d4,B.1bbda

	btst	#8,d4
	bne.s	uwp4

	cmp.b	#186,d0
	bcs.s	uwp5

uwp4	move.b	#185,d0

uwp5	cmp.b	#151,d0
	bcc.s	uwp6
	move.b	#151,d0

uwp6	sub.b	#50,d0
	and.w	#$ff,d0
	move.l	a2,a4
	lea	37*16(a4),a4
	cmp.w	#126,d0
	bge.s	uwp7
	lea	6*16(a4),a4

uwp7	move.w	#158,d5
	sub.w	d0,d5
	move.w	#2,d4

uwp8	move.w	d0,10(a2,d3.w)
	move.w	d0,10(a4,d3.w)
	move.w	d5,6(a2,d3.w)
	add.w	#16,d3
	dbra	d4,uwp8

	move.w	#0,d3
	addq.b	#2,d1
	cmp.b	#4,d1
	blt	uwp1

	move.b	#$80,adjust.sprites
	rts


B.5eb76	dc.b	0,0
	dc.b	0
B.5eb79	dc.b	0


screen.mem	dc.l	0
screen1	dc.l	0
screen2	dc.l	0
current.scene	dc.l	0


W.1baf8	dc.w	0
engine.power	dc.w	0
B.1bafc	dc.b	0
B.1bafd	dc.b	0
nitro.unit.value	dc.b	0,0
	dc.b	0
B.1bb01	dc.b	0
	dc.b	0,0
B.1bb04	dc.b	0,0,0
B.1bb07	dc.b	0,0,0
W.1bb0a	dc.w	0
W.1bb0c	dc.w	0
W.1bb0e	dc.w	0
W.1bb10	dc.w	0
W.1bb12	dc.w	0
	dc.w	0
	dc.w	0
road.height.value	dc.l	0
player.road.section	dc.b	0
opponents.road.section	dc.b	0
	dc.w	0
B.1bb20	dc.b	0
B.1bb21	dc.b	0
B.1bb22	dc.b	0
B.1bb23	dc.b	0
	dc.w	0
B.1bb26	dc.b	0
B.1bb27	dc.b	0
	dc.w	0
B.1bb2a	dc.b	0
B.1bb2b	dc.b	0
B.1bb2c	dc.b	0
B.1bb2d	dc.b	0
B.1bb2e	dc.b	0,0
	dc.w	0
B.1bb32	dc.b	0,0
W.1bb34	dc.w	0
W.1bb36	dc.w	0
daft.flag	dc.b	0,0
	dc.w	0
B.1bb3c	dc.b	0
nitro.unit	dc.b	0
	dc.w	0
W.1bb40	dc.w	0
	dc.b	0
B.1bb43	dc.b	0
B.1bb44	dc.b	0
B.1bb45	dc.b	0
cars.collided	dc.b	0
player.input	dc.b	0
B.1bb48	dc.b	0,0
B.1bb4a	dc.b	0,0
	dc.b	0
near.section.byte1	dc.b	0
	dc.b	0
B.1bb4f	dc.b	0
B.1bb50	dc.b	0
B.1bb51	dc.b	0
	dc.w	0
B.1bb54	dc.b	0,0
B.1bb56	dc.b	0,0
B.1bb58	dc.b	0
near.section.byte2.doubled	dc.b	0
near.section.byte2.minus2.doubled	dc.b	0,0
B.1bb5c	dc.b	0
B.1bb5d	dc.b	0
	dc.w	0
B.1bb60	dc.b	0
section.flags2	dc.b	0
nitro.activated	dc.b	0
B.1bb63	dc.b	0
B.1bb64	dc.b	0
B.1bb65	dc.b	0
use.lines.colour	dc.b	0
B.1bb67	dc.b	0
unused.flag	dc.b	0
B.1bb69	dc.b	0
half.near.section.byte2.minus1	dc.b	0,0
B.1bb6c	dc.b	0
print.fine.x	dc.b	0
print.fine.y	dc.b	0
B.1bb6f	dc.b	0
nitro.flag	dc.b	0,0
B.1bb72	dc.b	0
B.1bb73	dc.b	0
B.1bb74	dc.b	0
B.1bb75	dc.b	0
B.1bb76	dc.b	0
standard.clip.flag	dc.b	0
	dc.b	0
current.near.left.road.section.ID	dc.b	0
B.1bb7a	dc.b	0
near.section.byte4	dc.b	0
B.1bb7c	dc.b	0
B.1bb7d	dc.b	0
off.ground.value	dc.b	0
B.1bb7f	dc.b	0
	dc.w	0
	dc.w	0
	dc.b	0
current.road.section	dc.b	0
bottom.four.bits	dc.b	0,0
B.1bb88	dc.b	0,0
	dc.w	0
B.1bb8c	dc.b	0,0
B.1bb8e	dc.b	0
B.1bb8f	dc.b	0
B.1bb90	dc.b	0
B.1bb91	dc.b	0
	dc.b	0
B.1bb93	dc.b	0
	dc.b	0
nitro.max.units	dc.b	0
	dc.b	0
near.section.byte2	dc.b	0
near.section.byte2.minus2	dc.b	0
B.1bb99	dc.b	0
at.side.flag	dc.b	0
B.1bb9b	dc.b	0
B.1bb9c	dc.b	0
B.1bb9d	dc.b	0
B.1bb9e	dc.b	0
B.1bb9f	dc.b	0
	dc.b	0
B.1bba1	dc.b	0
	dc.b	0
B.1bba3	dc.b	0
B.1bba4	dc.b	0,0
B.1bba6	dc.b	0
B.1bba7	dc.b	0
accelerating	dc.b	0,0
	dc.b	0
B.1bbab	dc.b	0
B.1bbac	dc.b	0
B.1bbad	dc.b	0
B.1bbae	dc.b	0
B.1bbaf	dc.b	0
	dc.w	0
	dc.w	0
B.1bbb4	dc.b	0
B.1bbb5	dc.b	0
	dc.w	0
B.1bbb8	dc.b	0
B.1bbb9	dc.b	0
B.1bbba	dc.b	0
B.1bbbb	dc.b	0
second.screen	dc.b	0
B.1bbbd	dc.b	0
B.1bbbe	dc.b	0
B.1bbbf	dc.b	0
B.1bbc0	dc.b	0
B.1bbc1	dc.b	0
B.1bbc2	dc.b	0
B.1bbc3	dc.b	0
B.1bbc4	dc.b	0
B.1bbc5	dc.b	0
left.right.value	dc.b	0
B.1bbc7	dc.b	0
B.1bbc8	dc.b	0,0
	dc.w	0
B.1bbcc	dc.b	0
unlimited.nitro	dc.b	0
	dc.w	0
	dc.b	0
clip.flag	dc.b	0
drs.flag	dc.b	0
or.with.screen	dc.b	0
near.section.byte6	dc.b	0
B.1bbd5	dc.b	0
B.1bbd6	dc.b	0
B.1bbd7	dc.b	0
	dc.b	0
near.section.byte5	dc.b	0
B.1bbda	dc.b	0
B.1bbdb	dc.b	0
two.or.zero	dc.b	0
B.1bbdd	dc.b	0
opponent.infront.behind.value	dc.b	0
dnr.flag	dc.b	0
B.1bbe0	dc.b	0
swing.from.left.or.right	dc.b	0
B.1bbe2	dc.b	0
B.1bbe3	dc.b	0
B.1bbe4	dc.b	0
B.1bbe5	dc.b	0
B.1bbe6	dc.b	0,0
B.1bbe8	dc.b	0
B.1bbe9	dc.b	0
B.1bbea	dc.b	0
B.1bbeb	dc.b	0
W.1bbec	dc.w	0
W.1bbee	dc.w	0
W.1bbf0	dc.w	0
W.1bbf2	dc.w	0
W.1bbf4	dc.w	0
sin.x	dc.w	0
	dc.b	0
corner.values.offset	dc.b	0
W.1bbfa	dc.w	0
	dc.w	0
	dc.w	0
W.1bc00	dc.w	0
W.1bc02	dc.w	0
W.1bc04	dc.w	0
W.1bc06	dc.w	0
W.1bc08	dc.w	0
W.1bc0a	dc.w	0
W.1bc0c	dc.w	0
near.left.word	dc.w	0
near.right.word	dc.w	0
W.1bc12	dc.w	0
B.1bc14	dc.b	0,0
B.1bc16	dc.b	0,0
W.1bc18	dc.w	0
	dc.w	0
W.1bc1c	dc.w	0
dnr.value	dc.w	0
W.1bc20	dc.w	0
W.1bc22	dc.w	0
W.1bc24	dc.w	0
W.1bc26	dc.w	0
W.1bc28	dc.w	0
W.1bc2a	dc.w	0
	dc.w	0
W.1bc2e	dc.w	0
W.1bc30	dc.w	0
banked.road.alternating.flag	dc.b	0,0
W.1bc34	dc.w	0
W.1bc36	dc.w	0
W.1bc38	dc.w	0
B.1bc3a	dc.b	0,0
W.1bc3c	dc.w	0
W.1bc3e	dc.w	0
W.1bc40	dc.w	0
x.amount	dc.w	0
near.section.flag.byte3	dc.b	0,0
	dc.w	0
	dc.w	0
top.two.bits	dc.b	0,0
W.1bc4c	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
W.1bc56	dc.w	0
fp.y2	dc.w	0
fp.y	dc.w	0
clip.value	dc.w	0
W.1bc5e	dc.w	0
W.1bc60	dc.w	0
W.1bc62	dc.w	0
W.1bc64	dc.w	0
W.1bc66	dc.w	0
W.1bc68	dc.w	0
W.1bc6a	dc.w	0
W.1bc6c	dc.w	0
W.1bc6e	dc.w	0
W.1bc70	dc.w	0
W.1bc72	dc.w	0
W.1bc74	dc.w	0
W.1bc76	dc.w	0
W.1bc78	dc.w	0
W.1bc7a	dc.w	0
W.1bc7c	dc.w	0
W.1bc7e	dc.w	0
W.1bc80	dc.w	0
W.1bc82	dc.w	0
W.1bc84	dc.w	0
W.1bc86	dc.w	0
W.1bc88	dc.w	0
W.1bc8a	dc.w	0
near.left.offset	dc.w	0
	dc.w	0
near.right.offset	dc.w	0
	dc.w	0
self.righting.value1	dc.l	0
self.righting.value2	dc.l	0
self.righting.value3	dc.l	0
L.1bca0	dc.l	0
L.1bca4	dc.l	0
L.1bca8	dc.l	0
L.1bcac	dc.l	0
L.1bcb0	dc.l	0
L.1bcb4	dc.l	0
L.1bcb8	dc.l	0
near.offset3	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
B.1bcc8	dc.b	0,0
	dc.w	0
L.1bccc	dc.l	0
W.1bcd0	dc.w	0
	dc.w	0
L.1bcd4	dc.l	0
player.x	dc.l	0
player.y	dc.l	0
player.z	dc.l	0
x.angle	dc.w	0
y.angle	dc.w	0
z.angle	dc.w	0
W.1bcea	dc.w	0
W.1bcec	dc.w	0
W.1bcee	dc.w	0
W.1bcf0	dc.w	0
W.1bcf2	dc.w	0
W.1bcf4	dc.w	0
cmov3.values	dc.w	0,0,0
W.1bcfc	dc.w	0
W.1bcfe	dc.w	0
W.1bd00	dc.w	0
corner.value1	dc.w	0
corner.value2	dc.w	0
corner.value3	dc.w	0
corner.value4	dc.w	0
corner.value5	dc.w	0
corner.value6	dc.w	0
W.1bd0e	dc.w	0
W.1bd10	dc.w	0
W.1bd12	dc.w	0
W.1bd14	dc.w	0
W.1bd16	dc.w	0
W.1bd18	dc.w	0
W.1bd1a	dc.w	0
W.1bd1c	dc.w	0
W.1bd1e	dc.w	0
W.1bd20	dc.w	0
W.1bd22	dc.w	0
W.1bd24	dc.w	0
W.1bd26	dc.w	0
W.1bd28	dc.w	0
car.acceleration	dc.w	0
steering.values	dc.w	0,0,0
W.1bd32	dc.w	0
W.1bd34	dc.w	0
W.1bd36	dc.w	0
W.1bd38	dc.w	0
str2.values	dc.w	0,0,0
W.1bd40	dc.w	0
W.1bd42	dc.w	0
W.1bd44	dc.w	0
W.1bd46	dc.w	0
W.1bd48	dc.w	0
W.1bd4a	dc.w	0
W.1bd4c	dc.w	0
B.1bd4e	dc.b	0,0
B.1bd50	dc.b	0,0
B.1bd52	dc.b	0,0
W.1bd54	dc.w	0
W.1bd56	dc.w	0
W.1bd58	dc.w	0
y.corner.angle	dc.w	0
W.1bd5c	dc.w	0
W.1bd5e	dc.w	0
W.1bd60	dc.w	0
W.1bd62	dc.w	0
	dc.w	0
W.1bd66	dc.w	0
W.1bd68	dc.w	0
W.1bd6a	dc.w	0
	dc.w	0
W.1bd6e	dc.w	0
W.1bd70	dc.w	0
W.1bd72	dc.w	0
	dc.w	0
W.1bd76	dc.w	0
W.1bd78	dc.w	0
W.1bd7a	dc.w	0
	dc.w	0
W.1bd7e	dc.w	0
W.1bd80	dc.w	0
W.1bd82	dc.w	0
	dc.w	0
W.1bd86	dc.w	0
W.1bd88	dc.w	0
W.1bd8a	dc.w	0
	dc.w	0
DAT.1bd8e	ds.w	33

DAT.1bdd0	ds.w	80
DAT.1be70	ds.w	160
x.values	ds.w	160
y.values	ds.w	160
sin.cos.values	ds.w	36
		ds.w	4


dw.sub1	move.b	B.1bb04+2,d0
	add.b	B.1bbd6,d0
	cmp.b	#16,d0
	bcc.s	ds11

	asl.b	#4,d0
	move.b	d0,road.height.value+3

	move.b	B.1bb04,d0
	add.b	B.1bbd5,d0
	cmp.b	#16,d0
	bcc.s	ds11

	and.b	#$f,d0
	or.b	road.height.value+3,d0
	move.b	d0,d1
	move.l	#road.aerial.map,a1
	move.b	(a1,d1.w),d0
	and.b	#%11110,ccr
	rts

ds11	or.b	#1,ccr
	rts


fetch.near.section.stuff
	move.l	#near.left.road.section.IDs,a1
	move.b	(a1,d1.w),d2
	move.b	d2,current.near.left.road.section.ID
	asl.b	#1,d2
	move.l	#road.section.words+32,a2
	move.w	(a2,d2.w),near.left.offset

	move.l	#near.right.road.section.IDs,a1
	move.b	(a1,d1.w),d2
	asl.b	#1,d2
	move.b	#0,d0
	roxl.b	#1,d0
	asl.b	#1,d0
	move.b	d0,two.or.zero
	move.l	#road.section.words+32,a2
	move.w	(a2,d2.w),d0
	move.w	d0,near.right.offset

	asl.b	#1,d1
	move.l	#near.left.road.section.words,a1
	move.w	(a1,d1.w),near.left.word

	move.l	#near.right.road.section.words,a1
	move.w	(a1,d1.w),near.right.word

	lsr.b	#1,d1
	move.l	#near.road.section.bytes2,a1
	move.b	(a1,d1.w),d0
	and.b	#$c0,d0
	move.b	d0,top.two.bits

	move.b	(a1,d1.w),d0
	and.b	#$10,d0
	asl.b	#3,d0
	move.b	d0,banked.road.alternating.flag

	move.b	(a1,d1.w),d0
	and.b	#$f,d0
	move.b	d0,bottom.four.bits

	asl.b	#1,d0
	move.b	d0,d2
	move.l	#road.section.words,a2
	move.w	(a2,d2.w),near.offset3

	move.w	near.offset3,d0
	rol.w	#8,d0
	sub.w	#$b100,d0
	and.l	#$ffff,d0
	add.l	#road.section.words,d0
	move.l	d0,a0
	move.b	1(a0),near.section.byte1
	move.b	(a0),d2
	move.b	(a0,d2.w),d0
	addq.b	#1,d2
	move.b	d0,d3
	move.b	d0,near.section.byte2
	asl.b	#1,d3
	move.b	d3,near.section.byte2.doubled
	subq.b	#2,d0
	move.b	d0,near.section.byte2.minus2
	asl.b	#1,d0
	move.b	d0,near.section.byte2.minus2.doubled
	move.b	near.section.byte2,d0
	lsr.b	#1,d0
	subq.b	#1,d0
	move.b	d0,half.near.section.byte2.minus1
	move.b	(a0,d2.w),d0
	addq.b	#1,d2
	lsr.b	#1,d0
	roxr.b	#1,d0
	and.b	#$80,d0
	move.b	d0,near.section.flag.byte3
	move.b	(a0,d2.w),near.section.byte4
	addq.b	#1,d2
	move.b	(a0,d2.w),near.section.byte5
	addq.b	#3,d2
	move.b	(a0,d2.w),near.section.byte6
	addq.b	#1,d2
	rts


dw.sub9.sub
	move.l	#near.road.section.bytes,a1
	and.w	#$ff,d0
	move.b	(a1,d0.w),d3
	lsr.b	#4,d3
	move.b	(a1,d0.w),d0
	and.b	#$f,d0
	sub.b	B.1bb04,d0
	sub.b	B.1bb04+2,d3
	tst.b	W.1bc30
	bmi.s	ds9s1

	btst	#6,W.1bc30
	beq.s	ds9s3

	exg	d0,d3
	neg.b	d0
	bra.s	ds9s3

ds9s1	btst	#6,W.1bc30
	bne.s	ds9s2
	neg.b	d0
	neg.b	d3
	bra.s	ds9s3

ds9s2	exg	d0,d3
	neg.b	d3

ds9s3	move.b	d0,B.65ec0
	move.b	d3,B.65ec2
	asl.b	#3,d0
	add.b	B.1bb2e,d0
	move.b	d0,B.1bb22

	asl.b	#3,d3
	add.b	B.1bb32,d3
	move.b	d3,B.1bb26
	rts


dw.sub2	move.b	d0,road.height.value+3
	move.b	d2,road.height.value+2
	cmp.b	road.height.value+3,d2
	bcc.s	ds22

	add.b	road.height.value+2,d0
	bcc.s	ds21

	move.b	d1,d0
	and.b	#$f,d0
	cmp.b	#$f,d0
	beq.s	ds25

	addq.b	#1,d1
	bra.s	ds24

ds21	move.b	d1,d0
	and.b	#$f0,d0
	beq.s	ds25

	sub.b	#$10,d1
	bra.s	ds24

ds22	add.b	road.height.value+2,d0
	bcc.s	ds23

	move.b	d1,d0
	and.b	#$f0,d0
	cmp.b	#$f0,d0
	beq.s	ds25

	add.b	#$10,d1
	bra.s	ds24

ds23	move.b	d1,d0
	and.b	#$f,d0
	beq.s	ds25

	subq.b	#1,d1
ds24	move.l	#road.aerial.map,a1
	move.b	(a1,d1.w),d0
	rts

ds25	move.b	#$ff,d0
	rts


dw.sub.sub.sub
	lsr.w	#8,d0
	move.b	d0,road.height.value+1

	move.l	#player.x,a0
	move.l	#B.1bb07,a1
	move.l	#B.1bb04,a2
	tst.w	2(a0)
	bne.s	dsss1
	addq.w	#1,2(a0)

dsss1	move.l	(a0),d0
	asl.l	#1,d0
	swap	d0
	move.b	d0,(a1)
	lsr.w	#8,d0
	move.b	d0,(a2)

	tst.w	10(a0)
	bne.s	dsss2
	addq.w	#1,10(a0)

dsss2	move.l	8(a0),d0
	asl.l	#1,d0
	swap	d0
	move.b	d0,2(a1)
	lsr.w	#8,d0
	move.b	d0,2(a2)

	tst.b	road.height.value+1
	bmi.s	dsss4

	btst	#6,road.height.value+1
	bne.s	dsss3

	move.l	player.x,L.1bccc
	move.l	player.z,L.1bcd4
	rts

dsss3	move.l	player.x,L.1bcd4

	move.l	#$8000000,d0
	sub.l	player.z,d0
	move.l	d0,L.1bccc
	rts

dsss4	btst	#6,road.height.value+1
	bne.s	dsss5

	move.l	#$8000000,d0
	sub.l	player.x,d0
	move.l	d0,L.1bccc

	move.l	#$8000000,d0
	sub.l	player.z,d0
	move.l	d0,L.1bcd4
	rts

dsss5	move.l	#$8000000,d0
	sub.l	player.x,d0
	move.l	d0,L.1bcd4

	move.l	player.z,L.1bccc
	rts


dw.sub.sub
	move.w	y.angle,d0
	add.w	#$2000,d0
	and.w	#$c000,d0
	move.w	d0,W.1bc30

	bsr	dw.sub.sub.sub
	move.l	player.y,d0
	lsr.l	#8,d0
	lsr.l	#3,d0
	move.w	d0,W.1bcd0

	move.w	#$780,d3
	move.w	W.1bd38,d0
	cmp.w	#$500,d0
	bcs.s	dss1

	asl.w	#1,d0
	move.w	#$280,d3

dss1	add.w	d3,d0
	move.w	x.angle,d3
	bpl.s	dss2

	asr.w	#1,d3
	sub.w	d3,d0

dss2	asr.w	#4,d0
	add.w	W.1bcd0,d0
	move.w	d0,W.1bbfa

	move.l	L.1bccc,d0
	lsr.l	#8,d0
	lsr.l	#4,d0
	and.w	#$7ff,d0
	neg.w	d0
	move.b	d0,B.1bb23
	lsr.w	#8,d0
	move.b	d0,B.1bb2e

	move.l	L.1bcd4,d0
	lsr.l	#8,d0
	lsr.l	#4,d0
	and.w	#$7ff,d0
	neg.w	d0
	move.b	d0,B.1bb27
	lsr.w	#8,d0
	move.b	d0,B.1bb32

	move.w	y.angle,d0
	add.w	#$2000,d0
	and.w	#$3ffe,d0
	sub.w	#$2000,d0
	move.w	d0,W.1bc2e
	rts


dw.subA	move.b	#0,clip.flag

	move.w	W.1bc5e,d0
	sub.w	#192,d0
	tst.b	banked.road.alternating.flag
	bpl.s	dsA1
	neg.w	d0

dsA1	move.w	d0,clip.value

	bpl.s	dsA2
	neg.w	d0

dsA2	cmp.w	#192,d0
	blt.s	dsA3

	move.b	#$80,clip.flag
	tst.w	clip.value
	bmi.s	dsA3
	move.b	#2,clip.flag

dsA3	cmp.w	#256,d0
	blt.s	dsA5

	tst.b	B.1bb9c
	bmi.s	dsA4

	move.b	#$80,B.1bb9c
	move.b	clip.value,swing.from.left.or.right
	move.b	#$10,W.1bb40+1
	bsr	init.table
dsA4	rts

dsA5	btst	#6,B.1bb9c
	bne.s	dsA4

	move.b	#0,B.1bb9c
	move.b	#0,B.1bb75
	rts


dw.subF.sub1
	move.l	#DAT.1be70,a6
	move.l	#DAT.1bdd0,a0
	move.b	near.section.byte2,d4
	lsr.b	#1,d4
	move.w	#0,d1
	move.b	near.section.byte2,d2
	subq.b	#1,d2
	asl.b	#1,d2

dsFs1.1	move.w	(a6,d1.w),d0
	move.w	(a6,d2.w),(a6,d1.w)
	move.w	d0,(a6,d2.w)
	subq.b	#2,d2
	btst	#1,d1
	bne.s	dsFs1.2

	move.b	(a0,d1.w),d0
	move.b	(a0,d2.w),(a0,d1.w)
	move.b	d0,(a0,d2.w)

dsFs1.2	addq.b	#2,d1
	subq.b	#1,d4
	bne.s	dsFs1.1
	rts


initialise.data3
	bsr	to.previous.road.section

	move.b	d1,current.road.section
	move.b	d1,player.road.section
	move.l	#near.road.section.bytes2,a1
	move.b	(a1,d1.w),d0
	and.b	#$f,d0
	move.b	d0,d2
	move.l	#TAB.1f0c2,a2
	move.b	(a2,d2.w),d0
	bmi.s	initialise.data3

	move.b	B.1ca2f,d2
	beq.s	id32
	subq.b	#1,d2

id31	move.b	d1,d0
	move.l	#DAT.1c8e8,a2
	cmp.b	(a2,d2.w),d0
	beq.s	initialise.data3

	subq.b	#1,d2
	bpl.s	id31

id32	move.l	#L.1bccc,a0

id33	move.b	#0,(a0)+
	cmp.l	#W.1bd5e,a0
	bne.s	id33

	move.b	#240,dnr.flag
	bsr	fetch.near.section.stuff
	move.l	#near.road.section.bytes,a1
	move.b	(a1,d1.w),d0
	and.b	#$f,d0
	move.b	d0,B.1bbd5

	move.b	(a1,d1.w),d0
	lsr.b	#4,d0
	move.b	d0,B.1bbd6

	move.w	#0,d0
	move.w	d0,player.x+2
	move.w	d0,player.z+2

	move.b	B.1bbd5,d0
	and.w	#$ff,d0
	asl.w	#7,d0
	add.w	#64,d0
	move.w	d0,player.x

	move.b	B.1bbd6,d0
	and.w	#$ff,d0
	asl.w	#7,d0
	add.w	#64,d0
	move.w	d0,player.z

	move.b	#4,player.y
	move.b	#0,d1
	move.b	bottom.four.bits,d0
	cmp.b	#4,d0
	beq.s	id34

	cmp.b	#10,d0
	bne.s	id35

id34	move.b	#32,d1

id35	move.b	top.two.bits,d0
	move.b	banked.road.alternating.flag,d3
	eor.b	d3,d0
	add.b	d1,d0
	move.b	d0,y.angle

	bsr	dw.sub.sub
	bsr	dw.sub9
	bsr	dw.subA
	bsr	car.movement
	move.w	#0,player.y+2
	move.w	#16,player.y

	move.l	L.1bcac,d0
	move.l	d0,d3
	move.b	B.1bbc4,d2
	beq.s	id36

	asl.l	#8,d0
	asl.l	#1,d0
	add.l	#$180000,d0
	move.l	d0,player.y
	move.b	#230,dnr.flag

id36	lsr.l	#2,d3
	move.w	d3,W.1bc60

	bsr	init.data3.sub
	move.b	#8,d1
	move.l	#L.1bca4,a1
	move.l	#self.righting.value1,a2

id37	move.l	#$1000,(a1,d1.w)
	move.l	#$1000,(a2,d1.w)
	subq.b	#4,d1
	bpl.s	id37

	move.l	#$0,W.1bd1a
	move.w	#0,W.1bd1e
	bsr	dw.sub.sub
	move.b	#176,B.1bbea
	move.b	#8,B.1bbe9
	rts


dw.subD	move.w	W.1bb0c,d0
	sub.w	W.1bb0a,d0
	asr.w	#3,d0
	move.b	opponents.road.section,d1
	move.b	player.road.section,d2
	move.l	#opponent.appear.values,a0
	asl.b	#1,d1
	asl.b	#1,d2
	move.w	(a0,d1.w),d3
	sub.w	(a0,d2.w),d3
	add.w	d3,d0
	move.w	d0,d5
	move.w	d0,W.1bc3e
	bpl.s	dsD1
	neg.w	d0

dsD1	move.w	W.1ca1e,d4
	sub.w	d0,d4
	cmp.w	d0,d4
	bcs.s	dsD2

	move.w	d0,d4
	eor.w	#$8000,d5

dsD2	move.w	d4,W.1bc38

	eor.w	#$8000,d5
	lsr.w	#8,d5
	move.b	d5,B.1bbb8
	rts


calculate.if.winning
	move.b	B.1bb21,d0
	sub.b	B.1bb20,d0
	bne.s	ciw3

	move.b	player.road.section,d0
	sub.b	B.1ca32,d0
	bcc.s	ciw1
	add.b	number.of.road.sections,d0

ciw1	move.b	opponents.road.section,d3
	sub.b	B.1ca32,d3
	bcc.s	ciw2
	add.b	number.of.road.sections,d3

ciw2	sub.b	d0,d3
	bne.s	ciw3

	move.w	W.1bc3e,d0
	bne.s	ciw3

	move.b	B.57c3c,d0
ciw3	rts


nitro.print
	move.b	nitro.reserve,d3
	and.b	#$f,ccr
	abcd	d3,d0
	cmp.b	nitro.max.units,d0
	bcs.s	nitro.ok
	move.b	nitro.max.units,d0
nitro.ok
	move.b	d0,nitro.reserve

	move.b	#31,d0
	bsr	print.character
	move.b	#9,d0			column 9
	bsr	print.character
	move.b	#22,d0			row 22
	bsr	print.character

	move.b	#4,print.fine.x
	move.b	#2,print.fine.y
	move.b	nitro.reserve,d0
	lsr.b	#4,d0
	bsr	print.dec.digit

	move.b	nitro.reserve,d0
	and.b	#$f,d0
	bsr	print.dec.digit

	move.b	#0,print.fine.x
	move.b	#0,print.fine.y
	rts


nitro.power
	move.b	nitro.flag,d0
	or.b	L.1bca0+2,d0
	bne.s	nitro.off

	move.b	accelerating,d0
	bmi.s	update.nitro

	move.b	player.input,d0
	and.b	#3,d0
	beq.s	nitro.off

update.nitro
	move.b	nitro.reserve,d0
	beq.s	nitro.off

	tst.b	unlimited.nitro
	bmi.s	nitro.on

	subq.b	#1,nitro.unit
	bpl.s	nitro.on

	move.b	nitro.unit.value,d2
	move.b	d2,nitro.unit
	move.b	#$99,d0			subtract 1 from nitro reserve
	bsr	nitro.print

nitro.on
	move.b	#$80,nitro.activated
	asl.w	(car.acceleration).l	double car acceleration
	rts

nitro.off
	move.b	#0,nitro.activated
	rts


copy.damage.hole
	move.b	#23,d1
	bra.s	copy.damage.graphic

copy.damage.hole.smashed
	move.b	#25,d1
	bra.s	copy.damage.graphic

copy.damage.clear
	move.b	#27,d1

copy.damage.graphic
	move.w	d1,-(sp)
	move.l	#graphic.info+8,a0
	move.b	d2,d0
	asl.b	#1,d0
	add.b	d2,d0
	addq.b	#6,d0
	lsr.b	#1,d0
	bcc.s	cdg2
	addq.b	#1,d1

cdg2	and.w	#$ff,d0
	move.w	d1,d3
	asl.w	#4,d3
	move.w	d0,(a0,d3.w)

	move.l	screen2,-(sp)
	move.l	screen.mem,screen2
	move.b	d1,d0
	bsr	copy.graphic

	move.l	#32000,d0
	add.l	d0,screen2
	move.b	d1,d0
	bsr	copy.graphic

	move.l	(sp)+,screen2
	move.w	(sp)+,d1
	rts


init.damage.bar2
	move.b	#9,d2
idb21	cmp.b	B.1c9cf,d2
	bge.s	idb22

	bsr.s	copy.damage.clear
	bra.s	idb23

idb22	bsr.s	copy.damage.hole

idb23	subq.b	#1,d2
	bpl.s	idb21
	rts


get.player.input
	bsr	randomize.long
	move.b	#$10,d7
	move.b	#0,d6
	move.l	#control.keys,a4
	move.b	#4,d2
next.key
	move.b	(a4,d2.w),d1
	bsr	test.key
	bne.s	not.pressed
	or.b	d7,d6
not.pressed
	lsr.b	#1,d7
	subq.b	#1,d2
	bpl.s	next.key

	move.b	d6,d0
	btst	#4,d6
	beq.s	not.return
	bset	#0,d0
not.return
	btst	#1,d6
	beq.s	not.space
	bset	#4,d0
not.space
	btst	#0,d6
	beq.s	not.hash
	bset	#1,d0
	bclr	#0,d0
not.hash
	tst.b	d0
	bne.s	some.control

	addq.b	#1,joystick.reads
	bsr	read.joystick
	move.b	joystick.state,d0
	eor.b	#$ff,d0
	bne.s	some.control

	tst.b	B.5d724
	bmi.s	some.control

	move.b	#$44,d1			RETURN
	bsr	test.key
	bne.s	not.return2

	move.b	#$10,d0
	bra.s	some.control

not.return2
	move.b	#0,d0

some.control
	and.b	#$1f,d0
	tst.b	B.57c3c
	beq.s	save.input

	move.b	d0,player.input

	move.b	#$45,d1			ESCAPE
	bsr	test.key
	move.w	sr,-(sp)
	move.b	player.input,d0
	move.w	(sp)+,sr

save.input
	move.b	d0,player.input
	rts

joystick.reads	dc.b	0,0

control.keys
	dc.b	$2a,$40,$21,$22,$44,1,2,3,4,0


draw.dust.clouds
	move.b	#6,B.f360		off road
	move.b	W.1bd5c,d0
	cmp.b	#16,d0
	blt.s	ddc1
	move.b	#16,d0
ddc1	move.b	d0,B.1bbd7

	move.b	#15,d1
	tst.b	B.57c3c
	beq.s	ddc2
	move.b	#3,d1

ddc2	bsr	randomize.long
	and.w	#$1c,d0
	add.w	#450,d0
	move.w	d0,effect.table+6*16+8	off road period
	bra	ddcb


ddc3	rts


init.table
	move.w	#62,d1
	move.w	#212,d0
it	move.l	#TAB.1c3c0,a1
	move.w	d0,(a1,d1.w)
	subq.b	#2,d1
	bpl.s	it
	rts


draw.sparks
	move.b	#1,B.f360		wreck
	move.b	B.1bbda,d0
	bne.s	ddc6

	move.b	L.1bca0+2,d0
	beq.s	ddc3

ddc6	tst.b	B.1bb9c
	bmi.s	ddc3

	move.b	W.1bd5c,d0
	cmp.b	#1,d0
	blt.s	ddc3

	cmp.b	#50,d0
	blt.s	ddc7
	move.b	#50,d0

ddc7	move.b	d0,B.1bbd7
	move.b	#31,d1
	bsr	randomize.long
	and.b	#7,d0
	move.b	d0,d2
	move.b	B.1bbd7,d0
	lsr.b	#1,d0
	bra.s	ddc9

	cmp.b	#8,d0
	bge.s	ddc8

	move.b	#8,d0
	bne.s	ddc9

ddc8	cmp.b	#6,d2
	blt.s	ddc9

	move.b	#13,d0
	cmp.b	#7,d2
	bne.s	ddc9
	move.b	#3,d0

ddc9	cmp.b	#31,d0
	bcs.s	ddca
	move.b	#31,d0

ddca	eor.b	#$1f,d0
	and.w	#$ff,d0
	asl.w	#2,d0
	add.w	#170,d0
	move.w	d0,effect.table+16+8	wreck period

ddcb	asl.b	#1,d1
	move.b	d1,B.1bba7

	move.b	off.ground.value,d0
	beq	init.table

	move.b	(B.f360).l,d0
	jsr	(sound.effect).l

	move.l	#TAB.1c380,a4
	move.l	#TAB.1c400,a5
	move.b	B.1bba7,d1

ddcc	bsr	draw.spark
	bne.s	ddcd

	addq.w	#2,64(a5,d1.w)

	move.w	64(a5,d1.w),d0
	add.w	d0,64(a4,d1.w)

	move.w	(a5,d1.w),d0
	add.w	d0,(a4,d1.w)

ddcd	subq.b	#2,d1
	bpl.s	ddcc

	move.b	B.1bba7,d1

ddce	move.w	64(a4,d1.w),d0
	cmp.w	#128,d0
	bcs.s	ddc12

	bsr	randomize.long
	and.w	#7,d0
	move.w	d0,d3
	clr.w	d0
	move.b	B.1bbd7,d0
	lsr.w	#1,d0
	tst.b	B.1bb9c
	bmi.s	ddcf
	lsr.w	#1,d0

ddcf	add.w	d3,d0
	not.w	d0
	move.w	d0,64(a5,d1.w)
	tst.b	B.1bb9c
	bpl.s	ddc10

	bsr	draw.spark2
	bra.s	ddc11

ddc10	bsr	randomize.long
	and.w	#$7f,d0
	add.w	#64,d0
	move.w	d0,(a4,d1.w)
	move.w	d0,d5

	bsr	randomize.long
	or.w	#$fff8,d0
	add.w	#127,d0
	move.w	d0,64(a4,d1.w)

ddc11	move.w	d5,d0
	sub.w	#128,d0
	asr.w	#3,d0
	move.w	d0,(a5,d1.w)
	bsr.s	draw.spark

ddc12	subq.b	#2,d1
	bpl.s	ddce
	rts


draw.spark
	move.b	d1,B.1bbe4
	move.w	64(a4,d1.w),d5
	cmp.w	#128,d5
	bcc.s	dspk1

	move.w	(a4,d1.w),d0
	cmp.w	#256,d0
	bcc.s	dspk1

	cmp.w	#1,d5
	bcc.s	dspk2

dspk1	move.w	#210,64(a4,d1.w)
	rts

dspk2	tst.b	B.1bb9c
	bpl.s	dspk3

	bsr.s	draw.spark.sub
	bra.s	dspk4

dspk3	move.w	d0,d4
	cmp.w	#$fe,d0
	bcc.s	dspk1

	move.l	current.scene,a0
	ext.l	d0
	ext.l	d5
	lsr.l	#3,d0
	and.b	#$fe,d0
	add.l	d0,a0
	move.l	d5,d0
	asl.l	#2,d0
	add.l	d5,d0
	asl.l	#3,d0
	add.l	d0,a0

	move.b	#3,d0
	bsr	set.pixel.colour
	bsr	plot.pixel

	addq.w	#1,d4
	bsr	plot.pixel

	lea	-40(a0),a0
	subq.w	#1,d4
	bsr	plot.pixel

	addq.w	#1,d4
	move.b	#15,d0
	bsr	set.pixel.colour
	bsr	plot.pixel

dspk4	move.b	B.1bbe4,d1
	move.b	#0,d0
	rts


draw.spark2
	bsr	randomize.long
	and.w	#$ff,d0
	move.w	d0,(a4,d1.w)
	move.w	d0,d5

	bsr	randomize.long
	and.w	#7,d0
	add.w	#118,d0
	move.w	d0,64(a4,d1.w)
	rts


draw.spark.sub
	move.b	d1,d2
	lsr.b	#1,d2
	add.b	B.1bbac,d2
	and.w	#$f,d2
	move.l	#TAB.60fac,a0
	move.b	(a0,d2.w),d2

	asl.b	#1,d2
	move.w	(a4,d1.w),d4
	move.l	#TAB.60f9c,a0
	sub.w	(a0,d2.w),d4
	add.w	#32,d4
	move.w	64(a4,d1.w),d5
	add.w	#16,d5
	move.b	d2,d0
	lsr.b	#1,d0
	add.b	#29,d0
	bra	draw.spark.sub2


TAB.60f9c
	dc.w	$20,$20,$20,$28,$18,$20,$20,$20

TAB.60fac
	dc.b	3,6,7,2,1,5,0,4,0,5,1,2,7,6,2,7

B.60fbc	dc.b	0,0


car.movement1
	move.w	steering.values+4,d0
	bpl.s	cm11
	neg.w	d0

cm11	move.w	d0,W.1bd5c
	move.b	off.ground.value,d1
	bne.s	cm12

	move.w	W.1bc62,d0
	lsr.w	#2,d0
	sub.w	d0,W.1bc62
	rts

cm12	cmp.w	#$800,d0
	bge.s	cm13

	asl.w	#3,d0
	move.w	d0,W.1bc62
	rts

cm13	asl.w	#1,d0
	add.w	#$3000,d0
	bcc.s	cm14
	move.w	#$ff00,d0

cm14	move.w	d0,W.1bc62
	rts


steering2
	move.b	player.road.section,d1
	move.b	d1,current.road.section
	bsr	fetch.near.section.stuff
	move.w	y.corner.angle,d4
	sub.w	y.angle,d4
	move.w	banked.road.alternating.flag,d3
	eor.w	d3,d4
	move.b	#0,d2
	tst.b	near.section.byte1
	bpl.s	steer21

	addq.b	#2,d2
	move.w	near.section.flag.byte3,d0
	eor.w	d3,d0
	bpl.s	steer21
	addq.b	#2,d2

steer21	move.l	#steering2.values,a0
	add.w	(a0,d2.w),d4
	move.w	d4,d0
	bpl.s	steer22
	neg.w	d0

steer22	move.w	d0,W.1bc2a
	move.w	d4,sin.x
	cmp.w	#2048,d0
	bcs.s	steer23

	move.w	#32767,d0
	bne.s	steer24
steer23	asl.w	#4,d0

steer24	move.w	d0,W.1bc3c
	move.b	half.near.section.byte2.minus1,d0
	sub.b	W.1bb0a,d0
	cmp.b	#2,d0
	bcc.s	steer25

	bsr	to.next.road.section
	bsr	fetch.near.section.stuff

steer25	move.b	near.section.flag.byte3,d0
	move.b	banked.road.alternating.flag,d3
	eor.b	d3,d0
	move.b	d0,B.1bb5d

	move.b	left.right.value,d0
	beq.s	steer29

	move.b	sin.x,d3
	eor.b	d3,d0
	move.b	d0,road.height.value+3

	move.b	near.section.byte1,d0
	bpl.s	steer27

	move.b	left.right.value,d0
	move.b	B.1bb5d,d3
	eor.b	d3,d0
	bmi.s	steer26

	move.b	near.section.byte6,d0
	add.b	#45,d0
	bra.s	steer27a

steer26	move.b	B.1bb5d,d0
	move.b	d0,left.right.value
	move.b	near.section.byte6,d0
	sub.b	#35,d0
	bra.s	steer28

steer27	move.b	near.section.byte6,d0
steer27a
	tst.b	road.height.value+3
	bmi.s	steer28
	add.b	W.1bc3c,d0

steer28	bra	steer212a

steer29	move.w	#0,d4
	move.b	near.section.byte1,d0
	bpl.s	steer2a

	move.b	B.1bb5d,left.right.value
	move.b	near.section.byte6,d0
	bra	steer212a

steer2a	move.b	sin.x,left.right.value
	move.w	W.1bc2a,d0
	move.b	d0,d2
	move.b	W.1bc2a,d3
	beq.s	steer2b

	sub.w	#7680,d0
	bpl.s	steer2e
	move.b	#$ff,d2

steer2b	move.b	d2,road.height.value+2
	move.w	steering.values+4,d0
	bpl.s	steer2c
	neg.w	d0

steer2c	add.w	#2560,d0
	bpl.s	steer2d
	move.w	#$7f00,d0

steer2d	move.b	road.height.value+2,d3
	asl.w	#7,d3
	bclr	#15,d3
	muls	d3,d0
	asl.l	#1,d0
	swap	d0
	lsr.w	#7,d0
	tst.b	d0
	bne.s	steer2e
	addq.b	#1,d0

steer2e	tst.b	sin.x
	bpl.s	steer2f
	neg.w	d0

steer2f	add.w	d0,y.angle

steer210
	move.w	#0,d2
	move.w	W.1bcf2,d0
	and.l	#$f,d2
	lsr.w	d2,d0
	sub.w	d0,d4
	move.l	#special.long+$14874,a0
	sub.l	#$14874,a0
	move.l	#$667b379f,d3
	add.l	#$36729563,d3
	cmp.l	(a0),d3
	bne.s	steer211

	tst.b	off.ground.value
	bne.s	steer212
steer211
	move.w	#0,d4
steer212
	move.w	d4,W.1bcfe
	rts

steer212a
	move.b	d0,road.height.value+2
	move.w	steering.values+4,d0
	move.b	road.height.value+2,d3
	asl.w	#7,d3
	bclr	#15,d3
	muls	d3,d0
	asl.l	#1,d0
	swap	d0
	tst.b	left.right.value
	bpl.s	steer213
	neg.w	d0

steer213
	asr.w	#3,d0
	move.w	d0,d4
	cmp.b	#30,W.1bc2a
	bcs.s	steer210
	bra	steer2a


steering2.values
	dc.w	0,217,-217


coll1.sub1.sub2
	and.w	#$ff,d0
	move.b	road.height.value+2,d3
	and.w	#$ff,d3
	mulu	d0,d3
	move.w	d3,d0
	move.b	d0,road.height.value+3
	lsr.w	#8,d0
	rts


test.key
	move.l	#key.array,a0
	move.b	(a0,d1.w),d1
	cmp.b	#$b3,d1
	rts


mult.minus317
	move.w	#-317,d0
	bra.s	sin.cos.mult
mult317
	move.w	#317,d0
sin.cos.mult
	asl.w	#1,d1
	move.l	#sin.cos.values,a0
	move.w	(a0,d1.w),d3
	muls	d3,d0
	asl.l	#1,d0
	swap	d0
	lsr.w	#1,d1
	rts


square.it
	move.w	d0,d3
	muls	d3,d0
	tst.l	d0
	bpl.s	sqr.pos
	neg.l	d0
sqr.pos	rts


make.sin.cos
	move.l	#sin.cos.values,a5
	move.w	y.angle,d0
	bsr	get.sin
	move.w	d0,4(a5)
	move.w	d0,12(a5)
	move.w	d0,14(a5)
	move.w	d0,20(a5)
	move.w	d0,22(a5)

	move.w	y.angle,d0
	bsr	get.cos
	move.w	d0,6(a5)
	move.w	d0,16(a5)
	move.w	d0,18(a5)
	move.w	d0,24(a5)
	move.w	d0,26(a5)

	move.w	y.angle,d0
	sub.w	y.corner.angle,d0
	move.w	d0,-(sp)
	bsr	get.sin
	move.w	d0,52(a5)
	move.w	d0,66(a5)
	move.w	d0,68(a5)

	move.w	(sp)+,d0
	bsr	get.cos
	move.w	d0,56(a5)
	move.w	d0,62(a5)
	move.w	d0,70(a5)

	move.w	x.angle,d0
	bsr	get.sin
	move.w	d0,8(a5)

	move.w	x.angle,d0
	bsr	get.cos
	move.w	d0,10(a5)
	move.w	d0,28(a5)
	move.w	d0,30(a5)

	move.w	z.angle,d0
	bsr	get.cos
	move.w	d0,34(a5)

	move.w	z.angle,d0
	bsr	get.sin
	move.w	d0,32(a5)

	move.w	8(a5),d5
	move.w	#12,d3
msc1	move.w	(a5,d3.w),d4
	muls	d5,d4
	asl.l	#1,d4
	swap	d4
	move.w	d4,(a5,d3.w)
	addq.w	#2,d3
	cmp.w	#18,d3
	ble.s	msc1

	move.w	8(a5),d5
	move.w	#52,d3
msc2	move.w	(a5,d3.w),d4
	muls	d5,d4
	asl.l	#1,d4
	swap	d4
	move.w	d4,(a5,d3.w)
	addq.w	#4,d3
	cmp.w	#56,d3
	ble.s	msc2

	move.w	12(a5),(a5)
	move.w	16(a5),2(a5)
	move.w	10(a5),d5
	move.w	#4,d3
msc3	move.w	(a5,d3.w),d4
	muls	d5,d4
	asl.l	#1,d4
	swap	d4
	move.w	d4,(a5,d3.w)
	addq.w	#2,d3
	cmp.w	#6,d3
	ble.s	msc3

	move.w	10(a5),d5
	move.w	#68,d3
msc4	move.w	(a5,d3.w),d4
	muls	d5,d4
	asl.l	#1,d4
	swap	d4
	move.w	d4,(a5,d3.w)
	addq.w	#2,d3
	cmp.w	#70,d3
	ble.s	msc4

	move.w	32(a5),d5
	move.w	#12,d3
msc5	move.w	(a5,d3.w),d4
	muls	d5,d4
	asl.l	#1,d4
	swap	d4
	move.w	d4,(a5,d3.w)
	addq.w	#4,d3
	cmp.w	#28,d3
	ble.s	msc5

	move.w	32(a5),d5
	move.w	#52,d3
msc6	move.w	(a5,d3.w),d4
	muls	d5,d4
	asl.l	#1,d4
	swap	d4
	move.w	d4,(a5,d3.w)
	addq.w	#4,d3
	cmp.w	#56,d3
	ble.s	msc6

	move.w	34(a5),d5
	move.w	#14,d3
msc7	move.w	(a5,d3.w),d4
	muls	d5,d4
	asl.l	#1,d4
	swap	d4
	move.w	d4,(a5,d3.w)
	addq.w	#4,d3
	cmp.w	#30,d3
	ble.s	msc7

	move.w	34(a5),d5
	move.w	#62,d3
msc8	move.w	(a5,d3.w),d4
	muls	d5,d4
	asl.l	#1,d4
	swap	d4
	move.w	d4,(a5,d3.w)
	addq.w	#4,d3
	cmp.w	#66,d3
	ble.s	msc8

	move.w	24(a5),d0
	sub.w	14(a5),d0
	move.w	d0,40(a5)

	move.w	18(a5),d0
	neg.w	d0
	sub.w	20(a5),d0
	move.w	d0,42(a5)

	move.w	26(a5),d0
	add.w	12(a5),d0
	move.w	d0,44(a5)

	move.w	16(a5),d0
	sub.w	22(a5),d0
	move.w	d0,46(a5)

	move.w	28(a5),48(a5)
	neg.w	48(a5)

	move.w	32(a5),d0
	neg.w	d0
	move.w	d0,36(a5)
	rts


steering
	move.w	#2,d2
	move.l	#sin.cos.offsets,a5
	move.l	#steering.values,a4
steering1
	move.w	#0,d5
	move.w	W.1bcea,d0
	move.b	(a5,d2.w),d1
	bsr	sin.cos.mult
	add.w	d0,d5

	move.w	W.1bcec,d0
	move.b	3(a5,d2.w),d1
	bsr	sin.cos.mult
	add.w	d0,d5

	move.w	W.1bcee,d0
	move.b	6(a5,d2.w),d1
	bsr	sin.cos.mult
	add.w	d0,d5

	asl.w	#1,d2
	move.w	d5,(a4,d2.w)
	lsr.w	#1,d2
	subq.b	#2,d2
	bpl.s	steering1
	rts


car.movement2
	move.w	#15,d1
	bsr	mult.minus317
	move.w	d0,W.1bd10

	move.w	#4,d1
	bsr	mult.minus317
	move.w	d0,W.1bd12

	move.w	#14,d1
	bsr	mult317
	move.w	d0,W.1bd0e
	rts


car.movement3
	move.w	#2,d2
	move.l	#sin.cos.offsets,a5
	move.l	#cmov3.values,a4

cmov3	move.w	#0,d5
	move.w	W.1bd32,d0
	move.b	9(a5,d2.w),d1
	bsr	sin.cos.mult
	add.w	d0,d5

	move.w	W.1bd34,d0
	move.b	12(a5,d2.w),d1
	bsr	sin.cos.mult
	add.w	d0,d5

	move.w	W.1bd36,d0
	move.b	15(a5,d2.w),d1
	bsr	sin.cos.mult
	add.w	d0,d5

	asl.w	#1,d2
	move.w	d5,(a4,d2.w)
	lsr.w	#1,d2
	subq.b	#1,d2
	bpl.s	cmov3
	rts


stick.to.road2
	move.w	#1,d2
	move.l	#sin.cos.offsets,a5
	move.l	#str2.values,a4

str2	move.w	#0,d5
	move.w	W.1bcf0,d0
	move.b	18(a5,d2.w),d1
	bsr	sin.cos.mult
	add.w	d0,d5

	move.w	W.1bcf2,d0
	move.b	20(a5,d2.w),d1
	bsr	sin.cos.mult
	add.w	d0,d5

	asl.w	#1,d2
	move.w	d5,(a4,d2.w)
	lsr.w	#1,d2
	subq.b	#1,d2
	bpl.s	str2

	move.w	str2.values+2,d0
	move.w	#4,d1
	bsr	sin.cos.mult
	add.w	W.1bcf4,d0
	move.w	d0,str2.values+4
	rts


	dc.w	0
frame.count	dc.b	0,0
B.616da	dc.b	0,0


frames.wheels.engine
	clr.w	d1
	clr.w	d2
	tst.b	frame.count
	beq.s	fwe1
	subq.b	#1,frame.count

fwe1	tst.b	B.616da
	beq.s	fwe2
	subq.b	#1,B.616da

fwe2	tst.b	B.5d724
	bpl.s	fwe3

	tst.b	B.1bbb9
	bne.s	fwe3
	bsr	update.wheel.rotation

fwe3	move.w	W.69ede,dmacon+$dff000
	move.w	W.1bc34,d0
	add.w	W.1bbf4,d0
	bpl.s	fwe5

	tst.b	B.1bb63
	beq.s	fwe4

	move.w	#1,dmacon+$dff000
	move.w	#$80,intena+$dff000
	bra.s	fwea

fwe4	move.w	#0,d0

fwe5	move.w	d0,W.1bc34
	add.w	#378,d0
	move.l	#4800000,d3
	divu	d0,d3
	cmp.w	#$3fff,d3
	bcs.s	fwe6
	move.w	#$3ffe,d3

fwe6	or.b	B.5b646,d3
	cmp.w	#124,d3
	bge.s	fwe7
	move.w	#124,d3

fwe7	move.w	#6,d4

fwe8	cmp.w	#256,d3
	blt.s	fwe9

	lsr.w	#1,d3
	subq.w	#1,d4
	bpl.s	fwe8

	move.w	#0,d4
	bra.s	fwe8

fwe9	move.l	#engine.pitch.table,a0
	lea	$dff000.l,a1
	asl.w	#3,d4
	move.l	(a0,d4.w),aud0lch(a1)
	move.w	6(a0,d4.w),aud0len(a1)
	move.w	d3,W.f472
fwea	rts


dw.subI.sub
	move.b	B.1bbe4,d1
	move.b	#2,d3

dsIs1	eor.b	#2,d1
	move.l	#x.values,a4
	move.l	#y.values,a5
	move.w	(a4,d1.w),d0
	sub.w	#128,d0
	bpl.s	dsIs2
	neg.w	d0

dsIs2	sub.w	#160,d0
	bmi.s	dsIs3

	lsr.w	#3,d0
	add.w	d0,(a5,d1.w)

dsIs3	subq.b	#1,d3
	bne.s	dsIs1
	rts


collision1.sub
	move.w	#276,d3
	beq.s	.zero
	muls	d3,d0
	asr.l	#8,d0
.zero	add.w	d6,d0
	rts


car.movement
	bsr	make.sin.cos
	bsr.s	make.corner.sin.cos
	bsr	hit1
	bsr	self.righting.values
	bsr	steering
	bsr	car.movement1
	bsr	car.movement2
	bsr	collision1
	move.b	B.1bb72,d0
	beq.s	left.track

	bsr	collision2
	bsr	steering2
	bsr	car.movement3
	bsr	speed.acceleration
	bsr	keep.on.ground
	bsr	stick.to.road1
	bsr	stick.to.road2
left.track
	bsr	car.movement4
	bsr.s	update.position
	rts


make.corner.sin.cos
	move.w	sin.cos.values+62,d4
	move.w	sin.cos.values+52,d0
	asr.w	#1,d4
	asr.w	#1,d0
	sub.w	d0,d4

	move.w	sin.cos.values+56,d5
	move.w	sin.cos.values+66,d0
	asr.w	#1,d5
	asr.w	#1,d0
	sub.w	d0,d5

	move.w	sin.cos.values+68,d0
	move.w	sin.cos.values+70,d3
	asr.w	#5,d4
	asr.w	#5,d5
	asr.w	#5,d0
	asr.w	#5,d3

	move.w	d0,corner.value3
	neg.w	corner.value3

	move.w	d3,corner.value6
	neg.w	corner.value6

	move.w	d0,corner.value1
	move.w	d0,corner.value2

	move.w	d3,corner.value4
	move.w	d3,corner.value5

	sub.w	d4,corner.value1
	sub.w	d5,corner.value4

	add.w	d4,corner.value2
	add.w	d5,corner.value5
	rts


update.position
	move.w	W.1bcea,d0
	move.b	#238,d2
	beq.s	upos1

	muls	d2,d0
	asr.l	#8,d0
upos1	ext.l	d0
	asl.l	#6,d0
	add.l	d0,player.x

	move.w	W.1bcec,d0
	move.b	#238,d2
	beq.s	upos2

	muls	d2,d0
	asr.l	#8,d0
upos2	ext.l	d0
	asl.l	#7,d0
	add.l	d0,player.y

	move.w	W.1bcee,d0
	move.b	#238,d2
	beq.s	upos3

	muls	d2,d0
	asr.l	#8,d0
upos3	ext.l	d0
	asl.l	#6,d0
	add.l	d0,player.z

	move.w	player.y,d0
	cmp.w	#1000,d0
	blt.s	upos4
	move.w	#1000,player.y

upos4	move.w	str2.values,d0
	move.b	#238,d2
	beq.s	upos5

	muls	d2,d0
	asr.l	#8,d0
upos5	add.w	d0,x.angle

	move.w	str2.values+2,d0
	move.b	#238,d2
	beq.s	upos6

	muls	d2,d0
	asr.l	#8,d0
upos6	add.w	d0,y.angle

	move.w	str2.values+4,d0
	move.b	#238,d2
	beq.s	upos7

	muls	d2,d0
	asr.l	#8,d0
upos7	add.w	d0,z.angle

	move.w	#0,d2
	tst.b	B.1bb75
	bpl.s	upos8

	move.b	at.side.flag,d0
	cmp.b	#$e0,d0
	bne.s	upos8
	addq.b	#2,d2

upos8	move.l	#update.position.values,a0
	move.w	x.angle,d3
	bmi.s	upos9

	move.w	(a0,d2.w),d0
	cmp.w	d3,d0
	bcc.s	uposb
	bra.s	uposa

upos9	move.w	4(a0,d2.w),d0
	cmp.w	d3,d0
	bcs.s	uposb

uposa	move.w	d0,x.angle
	move.w	W.1bcf0,d3
	eor.w	d3,d0
	bmi.s	uposb
	move.w	#0,W.1bcf0

uposb	move.w	z.angle,d3
	bmi.s	uposc
	move.w	(a0,d2.w),d0
	cmp.w	d3,d0
	bcc.s	upose
	bra.s	uposd

uposc	move.w	4(a0,d2.w),d0
	cmp.w	d3,d0
	bcs.s	upose

uposd	move.w	d0,z.angle
	move.w	W.1bcf4,d3
	eor.w	d3,d0
	bmi.s	upose
	move.w	#0,W.1bcf4

upose	bclr	#7,B.1bbab
	move.b	x.angle,d0
	bpl.s	uposf
	neg.b	d0

uposf	cmp.b	#15,d0
	blt.s	upos10
	bset	#7,B.1bbab

upos10	move.w	#0,d0
	sub.w	x.angle,d0
	move.w	d0,x.amount
	rts


update.position.values	dc.w	$2c00,$0a00,$d300,$f500


car.movement4
	move.w	cmov3.values,d0
	move.b	#238,d2
	beq.s	cmov41

	muls	d2,d0
	asr.l	#8,d0
cmov41	add.w	d0,W.1bcea

	move.w	cmov3.values+2,d0
	move.b	#238,d2
	beq.s	cmov42

	muls	d2,d0
	asr.l	#8,d0
cmov42	add.w	d0,W.1bcec

	move.w	cmov3.values+4,d0
	move.b	#238,d2
	beq.s	cmov43

	muls	d2,d0
	asr.l	#8,d0
cmov43	add.w	d0,W.1bcee
	rts


stick.to.road1
	move.w	W.1bcfc,d0
	move.b	#238,d2
	beq.s	str11

	muls	d2,d0
	asr.l	#8,d0
str11	add.w	d0,W.1bcf0

	move.w	W.1bcfe,d0
	move.b	#238,d2
	beq.s	str12

	muls	d2,d0
	asr.l	#8,d0
str12	add.w	d0,W.1bcf2

	move.w	W.1bd00,d0
	move.b	#238,d2
	beq.s	str13

	muls	d2,d0
	asr.l	#8,d0
str13	add.w	d0,W.1bcf4
	rts


self.righting.values
	move.w	x.angle,d0
	bsr	get.sin
	move.w	d0,sin.x

	move.w	z.angle,d0
	bsr	get.sin
	ext.l	d0
	asl.l	#3,d0			8sinz

	move.w	sin.x,d3
	ext.l	d3
	asl.l	#4,d3			16sinx
	move.l	player.y,d4
	sub.l	d3,d4			player.y - 16sinx
	asr.l	#8,d4
	move.l	d4,self.righting.value3

	move.l	player.y,d4
	add.l	d3,d4			player.y + 16sinx
	move.l	d4,d5
	sub.l	d0,d5			player.y + 16sinx - 8sinz
	asr.l	#8,d5
	move.l	d5,self.righting.value2

	add.l	d0,d4			player.y + 16sinx + 8sinz
	asr.l	#8,d4
	move.l	d4,self.righting.value1
	rts


collision1
	move.b	#0,B.1bb7d
	move.b	#0,B.1bc3a
	move.l	L.1bca4,d0
	sub.l	self.righting.value1,d0
	sub.l	L.1bca0,d0
	move.l	d0,L.1bcb0
	bmi.s	coll11

	cmp.l	#5120,d0
	bcs.s	coll13
	bra.s	coll12

coll11	cmp.l	#-$300,d0
	bcc.s	coll13

	move.l	#-$300,d0
	bra.s	coll13

coll12	move.l	#5120,d0

coll13	move.w	d0,W.1bd14
	move.w	d0,d6
	move.w	W.1bd1a,d3
	sub.w	d3,d0
	bsr	collision1.sub
	bmi	coll19

	move.w	W.1bd20,d4
	move.w	d0,W.1bd20
	cmp.w	#1024,d0
	blt.s	coll14

	cmp.w	#512,d4
	bge.s	coll14
	addq.b	#1,B.1bb7d

coll14	move.w	W.1bd20,d0
	move.b	B.1bb01,d3
	asl.w	#8,d3
	sub.w	d3,d0
	bmi.s	coll1a

	cmp.w	#$700,d0
	blt.s	coll1a

	cmp.w	B.1bc3a,d0
	bcs.s	coll15
	move.w	d0,B.1bc3a

coll15	sub.w	#$600,d0
	tst.b	unlimited.nitro
	bmi.s	coll17

	addq.b	#1,B.1bb56
	move.b	B.1bb56,d3
	cmp.b	B.63ce2,d3
	bge.s	coll17

	lsr.w	#8,d0
	move.b	d0,d3
	lsr.b	#1,d3
	add.b	d3,d0
	add.b	B.1bb4f,d0
	bcc.s	coll16
	move.b	#$ff,d0

coll16	move.b	d0,B.1bb4f
	move.b	#$80,B.1bb54

coll17	move.w	W.1bd20,d0
	cmp.w	#$1200,d0
	bcs.s	coll18
	move.w	#$11ff,W.1bd20
coll18	bra.s	coll1b

coll19	move.w	#0,W.1bd20

coll1a	move.b	#0,B.1bb56

coll1b	move.w	W.1bd14,W.1bd1a
	move.l	L.1bca8,d0
	sub.l	self.righting.value2,d0
	sub.l	L.1bca0,d0
	move.l	d0,L.1bcb4
	bmi.s	coll1c

	cmp.l	#$1400,d0
	bcs.s	coll1e
	bra.s	coll1d

coll1c	cmp.l	#-$300,d0
	bcc.s	coll1e
	move.l	#-$300,d0
	bra.s	coll1e

coll1d	move.l	#$1400,d0

coll1e	move.w	d0,W.1bd16
	move.w	d0,d6
	move.w	W.1bd1c,d3
	sub.w	d3,d0
	bsr	collision1.sub
	bmi	coll114

	move.w	W.1bd22,d4
	move.w	d0,W.1bd22
	cmp.w	#1024,d0
	blt.s	coll1f

	cmp.w	#512,d4
	bge.s	coll1f
	addq.b	#1,B.1bb7d

coll1f	move.w	W.1bd22,d0
	move.b	B.1bb01,d3
	asl.w	#8,d3
	sub.w	d3,d0
	bmi.s	coll115

	cmp.w	#$700,d0
	blt.s	coll115

	cmp.w	B.1bc3a,d0
	bcs.s	coll110
	move.w	d0,B.1bc3a

coll110	sub.w	#$600,d0
	tst.b	unlimited.nitro
	bmi.s	coll112

	addq.b	#1,B.1bb56
	move.b	B.1bb56,d3
	cmp.b	B.63ce2,d3
	bge.s	coll112

	lsr.w	#8,d0
	move.b	d0,d3
	lsr.b	#1,d3
	add.b	d3,d0
	add.b	B.1bb50,d0
	bcc.s	coll111
	move.b	#$ff,d0

coll111	move.b	d0,B.1bb50
	move.b	#$80,B.1bb54

coll112	move.w	W.1bd22,d0
	cmp.w	#$1200,d0
	bcs.s	coll113
	move.w	#$11ff,W.1bd22
coll113	bra.s	coll116

coll114	move.w	#0,W.1bd22

coll115	move.b	#0,B.1bb56

coll116	move.w	W.1bd16,W.1bd1c
	move.l	L.1bcac,d0
	sub.l	self.righting.value3,d0
	sub.l	L.1bca0,d0
	move.l	d0,L.1bcb8
	bmi.s	coll117

	cmp.l	#$1400,d0
	bcs.s	coll119
	bra.s	coll118

coll117	cmp.l	#-$300,d0
	bcc.s	coll119
	move.l	#-$300,d0
	bra.s	coll119

coll118	move.l	#$1400,d0

coll119	move.w	d0,W.1bd18
	move.w	d0,d6
	move.w	W.1bd1e,d3
	sub.w	d3,d0
	bsr	collision1.sub
	bmi	coll11f

	move.w	W.1bd24,d4
	move.w	d0,W.1bd24
	cmp.w	#1024,d0
	blt.s	coll11a

	cmp.w	#512,d4
	bge.s	coll11a
	addq.b	#1,B.1bb7d

coll11a	move.w	W.1bd24,d0
	move.b	B.1bb01,d3
	asl.w	#8,d3
	sub.w	d3,d0
	bmi.s	coll120

	cmp.w	#$700,d0
	blt.s	coll120

	cmp.w	B.1bc3a,d0
	bcs.s	coll11b
	move.w	d0,B.1bc3a

coll11b	sub.w	#$600,d0
	tst.b	unlimited.nitro
	bmi.s	coll11d

	addq.b	#1,B.1bb56
	move.b	B.1bb56,d3
	cmp.b	B.63ce2,d3
	bge.s	coll11d

	lsr.w	#8,d0
	move.b	d0,d3
	lsr.b	#1,d3
	add.b	d3,d0
	add.b	B.1bb51,d0
	bcc.s	coll11c
	move.b	#$ff,d0

coll11c	move.b	d0,B.1bb51
	move.b	#$80,B.1bb54

coll11d	move.w	W.1bd24,d0
	cmp.w	#$1200,d0
	bcs.s	coll11e
	move.w	#$11ff,W.1bd24
coll11e	bra.s	coll121

coll11f	move.w	#0,W.1bd24

coll120	move.b	#0,B.1bb56

coll121	move.w	W.1bd18,W.1bd1e
	move.w	W.1bd20,d0
	add.w	W.1bd22,d0
	asr.w	#1,d0
	move.w	d0,sin.x
	add.w	W.1bd24,d0
	asr.w	#1,d0
	move.w	d0,W.1bd38
	bsr	collision1.sub1
	move.w	W.1bd20,d0
	sub.w	W.1bd22,d0
	move.w	d0,d3
	asl.w	#1,d0
	add.w	d3,d0
	bpl.s	coll122
	neg.w	d0

coll122	cmp.w	#$1000,d0
	blt.s	coll123
	move.w	#$1000,d0

coll123	tst.w	d3
	bpl.s	coll124
	neg.w	d0

coll124	move.w	d0,W.1bd28
	move.w	sin.x,d0
	sub.w	W.1bd24,d0
	move.w	d0,W.1bd26
	move.b	W.1bd38,d0
	or.b	W.1bd38+1,d0
	move.b	d0,off.ground.value
	bne.s	coll129

	tst.b	dnr.flag
	bne.s	coll129

	move.w	#-128,d3
	move.w	x.angle,d0
	bpl.s	coll126

	move.b	(B.1ca33).l,d0
	cmp.b	#7,d0
	bne.s	coll125

	move.b	#248,d1
	bra.s	coll127

coll125	cmp.b	#4,d0
	bne.s	coll129

	move.w	#-8,d3
	bra.s	coll127

coll126	cmp.w	#$1000,d0
	blt.s	coll127
	move.w	#-256,d3

coll127	sub.w	W.1bd26,d3
	bpl.s	coll129

	move.b	W.1bcf0,d0
	bpl.s	coll128

	cmp.b	#$ff,d0
	bne.s	coll129

coll128	move.w	d3,W.1bd26

coll129	bsr	collision1.sub2
	move.w	W.1bd44,W.1bd46
	bsr	car.to.car.collision
	tst.b	B.620b6
	beq.s	coll12a
	subq.b	#1,B.620b6

coll12a	tst.b	B.1bb7d
	beq.s	coll12d

	move.b	B.1bc3a,d0
	cmp.b	#7,d0
	bcc.s	coll12b
	move.b	#7,d0

coll12b	asl.b	#2,d0
	cmp.b	#64,d0
	bcs.s	coll12c
	move.b	#64,d0

coll12c	move.b	d0,effect.table+3*16+11	grounded volume
	tst.b	B.620b6
	bne.s	coll12d

	move.b	#3,d0			grounded
	jsr	(sound.effect).l
	move.b	#5,B.620b6
coll12d	rts


B.620b6	dc.b	0,0


collision2
	move.w	W.1bd10,d0
	add.w	W.1bd42,d0
	move.w	d0,W.1bd34

	move.b	car.acceleration,d0
	or.b	steering.values+4,d0
	bmi.s	coll21

	tst.b	car.acceleration+1
	beq.s	coll21

	and.w	#$ff,d0
	sub.w	d0,car.acceleration

coll21	move.w	car.acceleration,d3
	bpl.s	coll22
	neg.w	d3

coll22	bsr	collision2.sub1
	sub.w	d0,d3
	bcs.s	coll24

	tst.b	car.acceleration
	bpl.s	coll23
	neg.w	d0

coll23	move.w	d0,car.acceleration

coll24	move.w	car.acceleration,d0
	add.w	W.1bd44,d0
	add.w	W.1bd12,d0
	move.w	d0,W.1bd36
	bsr.s	collision2.sub
	rts


keep.on.ground
	move.w	W.1bcf0,d3
	asr.w	#4,d3
	move.w	W.1bd26,d0
	sub.w	d3,d0
	tst.b	off.ground.value
	beq.s	kog

	move.w	W.1bd36,d3
	asr.w	#2,d3
	add.w	d3,d0

kog	move.w	d0,W.1bcfc

	move.w	W.1bcf4,d3
	asr.w	#4,d3
	move.w	W.1bd28,d0
	sub.w	d3,d0
	move.w	d0,W.1bd00
	rts


collision2.sub
	move.w	W.1bd0e,d4
	add.w	W.1bd40,d4
	move.w	d4,d3
	sub.w	steering.values,d3
	bpl.s	coll2.sub1
	neg.w	d3

coll2.sub1
	bsr.s	collision2.sub1
	cmp.w	d0,d3
	bcs.s	coll2.sub3

	tst.b	steering.values
	bpl.s	coll2.sub2
	neg.w	d0

coll2.sub2
	sub.w	d0,d4
	move.w	d4,W.1bd32
	move.b	#$80,B.1bbc1
	rts

coll2.sub3
	move.w	W.1bd40,d0
	sub.w	steering.values,d0
	move.w	d0,W.1bd32
	move.b	#0,B.1bbc1
	rts


collision2.sub1
	tst.b	off.ground.value
	beq.s	coll2.sub11

	move.w	W.1bd42,d0
	asl.w	#1,d0
	rts

coll2.sub11
	move.w	#0,d0
	rts


speed.acceleration
	moveq	#1,d7
	tst.b	off.ground.value
	beq.s	sa2

	move.b	W.1bd46,d0
	bpl.s	sa1
	eor.b	#$ff,d0

sa1	cmp.b	#3,d0
	bge.s	sa4

	tst.b	B.1bb9c
	bmi.s	sa4

	tst.b	L.1bca0+2
	bne.s	sa3

sa2	tst.b	dnr.flag
	beq.s	sa5

sa3	moveq	#3,d7

sa4	move.w	#$6000,d0
	bra.s	sab

sa5	move.w	steering.values,d0
	bpl.s	sa6
	neg.w	d0

sa6	move.w	steering.values+2,d3
	bpl.s	sa7
	neg.w	d3

sa7	cmp.w	d3,d0
	bge.s	sa8
	move.w	d3,d0

sa8	move.w	steering.values+4,d3
	bpl.s	sa9
	neg.w	d3

sa9	cmp.w	d3,d0
	bge.s	saa
	move.w	d3,d0

saa	moveq	#5,d7
	tst.b	B.1bbc7
	bpl.s	sab

	tst.b	B.1bbb8
	bmi.s	sab

	move.w	#20,d3
	asl.w	#7,d3
	sub.w	d3,d0
	bcc.s	sab
	move.w	#0,d0

sab	move.w	W.1bcea,d3
	muls	d0,d3
	swap	d3
	asr.w	d7,d3
	sub.w	d3,cmov3.values

	move.w	W.1bcec,d3
	muls	d0,d3
	swap	d3
	asr.w	d7,d3
	sub.w	d3,cmov3.values+2

	move.w	W.1bcee,d3
	muls	d0,d3
	swap	d3
	asr.w	d7,d3
	sub.w	d3,cmov3.values+4
	rts


collision1.sub1
	move.w	#0,W.1bd4a
	move.l	L.1bcb0,d0
	add.l	L.1bcb4,d0
	asr.l	#1,d0
	sub.l	L.1bcb8,d0
	asr.l	#4,d0
	move.w	d0,d3
	eor.w	#$8000,d3
	move.w	d3,W.1bd4c

	bsr	coll1.sub1.sub1
	move.b	B.1bb2d,B.1bb2c
	move.b	B.1bb2b,B.1bd52
	move.l	L.1bcb0,d0
	sub.l	L.1bcb4,d0
	asr.l	#3,d0
	move.w	d0,W.1bd48

	bsr	coll1.sub1.sub1
	move.b	B.1bb2c,road.height.value+2

	move.b	B.1bb2d,d0
	bsr	coll1.sub1.sub2
	move.b	d0,B.1bd50

	move.b	B.1bb2b,d0
	bsr	coll1.sub1.sub2
	move.b	d0,B.1bd4e

	move.b	B.1bd4e,road.height.value+2
	move.b	W.1bd48,B.1bbbb
	move.w	W.1bd38,d0
	move.b	road.height.value+2,d3
	and.w	#$ff,d3
	tst.b	B.1bbbb
	bpl.s	coll1.sub11
	neg.w	d3

coll1.sub11
	asl.w	#7,d3
	muls	d3,d0
	asl.l	#1,d0
	swap	d0
	move.w	d0,W.1bd40

	move.b	B.1bd50,road.height.value+2
	move.b	W.1bd4a,B.1bbbb
	move.w	W.1bd38,d0
	move.b	road.height.value+2,d3
	and.w	#$ff,d3
	tst.b	B.1bbbb
	bpl.s	coll1.sub12
	neg.w	d3

coll1.sub12
	asl.w	#7,d3
	muls	d3,d0
	asl.l	#1,d0
	swap	d0
	move.w	d0,W.1bd42

	move.b	B.1bd52,road.height.value+2
	move.b	W.1bd4c,B.1bbbb
	move.w	W.1bd38,d0
	move.b	road.height.value+2,d3
	and.w	#$ff,d3
	tst.b	B.1bbbb
	bpl.s	coll1.sub13
	neg.w	d3

coll1.sub13
	asl.w	#7,d3
	muls	d3,d0
	asl.l	#1,d0
	swap	d0
	move.w	d0,W.1bd44
	rts


coll1.sub1.sub1
	tst.w	d0
	bpl.s	coll1.sub1.sub11
	neg.w	d0

coll1.sub1.sub11
	move.b	#$ff,d1
	cmp.w	#256,d0
	bge.s	coll1.sub1.sub12
	move.b	d0,d1

coll1.sub1.sub12
	move.b	d1,B.1bb2b
	lsr.b	#1,d1
	move.l	#collision1.table,a0
	move.b	(a0,d1.w),d0
	move.b	d0,B.1bb2d
	rts


dw.subF.sub2
	move.w	sin.x,d0
	move.w	corner.values.offset-1,d3
	tst.b	B.1bb8f
	bpl.s	dsFs21

	asr.w	#1,d0
	asr.w	#1,d3
	move.w	d3,W.1bc36

	add.b	#49,W.1bc36
	asr.w	#1,d3
	add.w	#$4900,d3
	bsr	dw.sub9.sub3

	sub.w	W.1bc2e,d0
	asr.w	#3,d0
	move.l	#x.values,a0
	move.w	d0,(a0,d1.w)
	rts

dsFs21	bsr	dw.sub9.sub3
	sub.w	W.1bc2e,d0
	asr.w	#3,d0
	move.l	#x.values,a0
	move.w	d0,(a0,d1.w)

	bsr	dw.sub9.sub4
	move.w	d0,W.1bc36
	rts


dw.subF.sub3
	move.l	#DAT.1be70,a0
	move.w	(a0,d1.w),d0
	sub.w	W.1bbfa,d0
	neg.w	d0
	asr.w	#2,d0
	move.w	W.1bc36,d3
	tst.b	B.1bb8f
	bpl.s	dsFs31

	move.w	#19483,d4
	muls	d4,d0
	asl.l	#1,d0
	swap	d0

dsFs31	bsr	dw.sub9.sub3
	sub.w	x.amount,d0
	asr.w	#3,d0
	move.l	#y.values,a0
	move.w	d0,(a0,d1.w)
	rts


z.rotate0
	move.l	#DAT.1be70,a0
	tst.w	(a0,d1.w)
	bmi.s	zr.end
z.rotate
	move.l	#sin.cos.values,a3
	move.l	#x.values,a5
	move.l	#y.values,a4
z.rotate1
	move.w	(a5,d1.w),d5
	move.w	(a4,d1.w),d4

	move.w	34(a3),d0
	muls	d5,d0
	asl.l	#1,d0
	swap	d0
	move.w	32(a3),d3
	muls	d4,d3
	asl.l	#1,d3
	swap	d3
	add.w	d3,d0
	asr.w	#2,d0
	add.w	#128,d0
	move.w	d0,(a5,d1.w)

	move.w	34(a3),d0
	muls	d4,d0
	asl.l	#1,d0
	swap	d0
	move.w	32(a3),d3
	muls	d5,d3
	asl.l	#1,d3
	swap	d3
	sub.w	d3,d0
	asr.w	#2,d0
	add.w	#64,d0
	move.w	d0,(a4,d1.w)
zr.end	rts


randomize.long
	move.w	random.long+2,d0
	lsr.w	#4,d0
	move.w	random.long,d3
	lsr.w	#1,d3
	eor.b	d3,d0
	move.l	random.long,d3
	asl.l	#8,d3
	move.b	random.byte,d3
	move.l	d3,random.long
	move.b	d0,random.byte
	rts


random.long	dc.l	0
random.byte	dc.b	0,0


set.random.values
	move.l	random.seed,random.long
	move.b	random.seed+1,random.byte
	rts


random.seed	dc.l	0,0


dw.subE	move.b	(B.1ca29).l,d1
	move.b	#0,d2
	move.b	d2,B.1bbc7

	move.b	W.1bbec+1,d0
	move.b	d0,B.1bba7

	sub.b	B.1bba1,d0
	bcc.s	dsE1

	neg.b	d0
	subq.b	#1,d2

dsE1	move.b	d0,sin.x+1
	move.b	d2,sin.x

	move.b	W.1bc38,d0
	beq.s	dsE2
	bra	dsEd

dsE2	move.b	W.1bc38+1,d0
	cmp.b	#64,d0
	bcc.s	dsE4

	tst.b	B.1bbb8
	bmi.s	dsE3

	cmp.b	#50,sin.x+1
	bcc.s	dsE4

dsE3	subq.b	#1,B.1bbc7

dsE4	cmp.b	#16,d0
	bcc.s	dsE7

	tst.b	B.57c3c
	beq.s	dsE5

	tst.b	W.1bbec
	bne.s	dsE7

dsE5	move.b	sin.x+1,d0
	cmp.b	#50,d0
	bcc.s	dsE7

	move.b	W.1bc5e,d0
	cmp.b	#1,d0
	bcs.s	dsE6
	bne.s	dsE7

	move.b	W.1bc5e+1,d0
	cmp.b	#$80,d0
	bcc.s	dsE7

dsE6	bsr	dw.subE.sub
	bra.s	dsE7a

dsE7	move.b	#0,d0
	move.b	d0,B.1bbc3

	move.b	#0,B.1bbeb

	move.b	W.1bc38+1,d0
	cmp.b	#24,d0
	bcc.s	dsE9

dsE7a	move.l	#TAB.1ed8a,a1
	move.b	(a1,d1.w),d0
	and.b	#8,d0
	beq.s	dsE8

	tst.b	B.1bbb8
	bmi.s	dsE8

	move.b	W.1bc38+1,d0
	cmp.b	#14,d0
	bcc.s	dsEd

dsE8	bsr	dw.subE.sub1
	bra	dsE11a

dsE9	tst.b	B.1bbb8
	bmi.s	dsEc

	cmp.b	#50,d0
	bcc.s	dsEa

	move.l	#TAB.1ed8a,a1
	move.b	(a1,d1.w),d0
	and.b	#2,d0
	beq.s	dsEb

	bsr	dw.subE.sub2
	bra.s	dsEfa

dsEa	cmp.b	#200,d0
	bcc.s	dsEd

	move.l	#TAB.1ed8a,a1
	move.b	(a1,d1.w),d0
	and.b	#$20,d0
	beq.s	dsEd

dsEb	bsr	dsEs10
	bra.s	dsEfa

dsEc	bsr	dsEs10
	bra.s	dsE11a

dsEd	move.b	#64,d2
	move.l	#TAB.1ed8a,a1
	move.b	(a1,d1.w),d0
	and.b	#8,d0
	beq.s	dsEe
	move.b	#110,d2

dsEe	move.b	d1,d0
	and.b	#1,d0
	beq.s	dsEf
	not.b	d2

dsEf	move.b	d2,B.1bba7
dsEfa	move.b	#2,d0
	move.b	d0,road.height.value+1

	move.b	opponents.road.section,d1
	move.b	d1,current.road.section

dsE10	move.l	#near.road.section.bytes2,a1
	move.b	(a1,d1.w),d0
	and.b	#$f,d0
	move.b	d0,d2
	move.l	#TAB.1f0c2,a2
	move.b	(a2,d2.w),d0
	bpl.s	dsE11
	move.b	#$80,B.1bba7

dsE11	bsr	to.next.road.section
	subq.b	#1,road.height.value+1
	bne.s	dsE10

dsE11a	move.b	B.1bbbd,d0
	bmi.s	dsE12
	bne.s	dsE13

	move.b	B.1bba7,d0
	sub.b	W.1bbec+1,d0
	beq.s	dsE15
	bcc.s	dsE13

dsE12	cmp.b	#$f0,d0
	bcc.s	dsE15

	move.b	#247,d0
	bne.s	dsE14

dsE13	cmp.b	#16,d0
	bcs.s	dsE15
	move.b	#9,d0

dsE14	add.b	W.1bbec+1,d0
	move.b	B.1bb44,d2
	beq.s	dsE15

	cmp.b	#225,d0
	bcc.s	dsE15

	cmp.b	#32,d0
	bcs.s	dsE15

	tst.b	B.57c3c
	bne.s	dsE15

	move.b	d0,W.1bbec+1
dsE15	rts


dw.subE.sub1
	move.b	sin.x+1,d0
	cmp.b	#56,d0
	bcc.s	dsEs14

	tst.b	sin.x
	bmi.s	dsEs13
	bpl.s	dsEs11

dsEs10	move.b	sin.x+1,d0
	cmp.b	#56,d0
	bcc.s	dsEs14

	move.b	B.1bba1,d0
	tst.b	sin.x
	bmi.s	dsEs12

	cmp.b	#160,d0
	bcc.s	dsEs13

dsEs11	move.b	#$e0,d0
	move.b	d0,B.1bba7
	rts

dsEs12	cmp.b	#96,d0
	bcs.s	dsEs11

dsEs13	move.b	#32,d0
	move.b	d0,B.1bba7
dsEs14	rts


dw.subE.sub2
	move.b	B.1bba1,d0
	move.b	d0,B.1bba7
	rts


dw.sub4	move.b	B.1bbc4,d0
	beq	ds44

	move.b	B.1bb74,d0
	bne	ds44

	move.b	opponents.road.section,d1
	bsr	fetch.near.section.stuff
	bsr	dw.sub4.sub
	bsr	dw.sub4.sub1
	bsr	dw.sub4.sub2
	bsr	dw.sub4.sub3
	bsr	dw.sub4.sub4

	move.b	near.section.byte5,d0
	move.b	d0,road.height.value+2

	move.w	W.1bbee,d0
	move.b	road.height.value+2,d3
	asl.w	#7,d3
	bclr	#15,d3
	muls	d3,d0
	asl.l	#1,d0
	swap	d0
	move.b	#$ee,d2
	beq.s	ds41

	muls	d2,d0
	asr.l	#8,d0

ds41	ext.l	d0
	asl.l	#3,d0
	move.b	d0,d3
	asr.l	#8,d0
	add.b	d3,B.1bb3c
	bcc.s	ds42
	addq.w	#1,d0

ds42	add.w	d0,W.1bb0c

	move.b	W.1bb0c,d0
	cmp.b	half.near.section.byte2.minus1,d0
	bcs.s	ds44

	sub.b	half.near.section.byte2.minus1,d0
	move.b	d0,W.1bb0c

	move.b	opponents.road.section,d1
	addq.b	#1,d1
	cmp.b	(number.of.road.sections).l,d1
	bcs.s	ds43
	move.b	#0,d1

ds43	move.b	d1,opponents.road.section
ds44	rts


initialise.data2
	bsr	dw.sub5
	bsr	randomize.long
	and.w	#$7f,d0
	add.b	#$68,d0
	move.l	#W.1bd86,a0
	move.l	#W.1bd66,a1
	move.b	#6,d1

.set	move.w	(a0,d1.w),d3
	add.w	d0,d3
	move.w	d3,(a1,d1.w)
	subq.b	#2,d1
	bpl.s	.set
	rts


dw.sub4.sub4
	move.w	#0,road.height.value
	move.b	W.1bbee+1,d0
	asl.b	#1,d0
	move.b	W.1bbee,d0
	bmi.s	ds4s43

	roxl.b	#1,d0
	tst.b	B.1bbc7
	bpl.s	ds4s41

	tst.b	B.1bbb8
	bpl.s	ds4s41

	sub.b	#20,d0
	bcc.s	ds4s41
	move.b	#0,d0

ds4s41	move.b	d0,road.height.value+2

	move.b	W.1bbee,d0
	bsr	coll1.sub1.sub2
	asr.w	#6,d3
	move.w	d3,road.height.value

	move.b	B.1bb44,d0
	beq.s	ds4s43

	move.w	W.1bbf0,d0
	bmi.s	ds4s43

	move.w	#0,d3
	move.b	W.1bbee,d3
	sub.w	d3,d0
	tst.b	near.section.byte1
	bpl.s	ds4s42

	sub.w	d3,d0
	sub.w	#35,d0

ds4s42	move.w	d0,W.1bbf0

ds4s43	move.w	W.1bbf0,d0
	sub.w	road.height.value,d0
	tst.b	B.1bb44
	beq.s	ds4s47

	move.w	W.1bd86,d3
	add.w	W.1bd88,d3
	lsr.w	#1,d3
	sub.w	W.1bd8a,d3
	move.w	d3,d4
	bpl.s	ds4s44
	neg.w	d4

ds4s44	cmp.w	#512,d4
	bcs.s	ds4s45
	move.w	#510,d4

ds4s45	lsr.w	#1,d4
	move.w	d4,d5
	asr.w	#2,d5
	add.w	d4,d5
	tst.w	d3
	bpl.s	ds4s46
	neg.w	d5

ds4s46	add.w	d5,d0

ds4s47	move.b	#$ee,d2
	beq.s	ds4s48

	muls	d2,d0
	asr.l	#8,d0

ds4s48	add.w	d0,W.1bbee
	bpl.s	ds4s49

	move.w	#0,W.1bbee
ds4s49	rts


dw.sub4.sub2
	move.b	B.1bafc,d0
	move.b	B.1bafd,d2
	move.b	B.1bbc0,d1
	beq.s	ds4s21
	sub.b	#25,d0

ds4s21	move.b	B.1bb44,d1
	bne.s	ds4s22
	move.b	#0,d0
	move.b	d0,d2

ds4s22	move.b	d0,W.1bbf0+1
	move.b	d2,W.1bbf0
	rts


dw.sub4.sub3
	tst.b	B.1bb44
	bne.s	ds4s31
	rts

ds4s31	move.b	opponents.road.section,d1
	move.l	#opponent.acceleration.values,a0
	move.b	(a0,d1.w),d0
	bmi.s	ds4s32

	cmp.b	B.63ce0,d0
	bcs.s	ds4s32
	move.b	B.63ce0,d0

ds4s32	and.b	#$7f,d0
	move.b	d0,B.1bb4a

	move.b	W.1bbee,d0
	sub.b	B.1bb4a,d0
	bcs.s	ds4s33
	beq.s	ds4s36

	move.b	#$80,B.1bb45
	neg.w	W.1bbf0
	cmp.b	#14,d0
	bcs.s	ds4s35

ds4s33	move.l	#opponent.acceleration.values,a1
	tst.b	(a1,d1.w)
	bmi.s	ds4s34

	tst.b	d0
	bpl.s	ds4s34

	move.b	B.1bb45,d2
	beq.s	ds4s34

	cmp.b	#$fe,d0
	bcc.s	ds4s35
	bclr	#7,B.1bb45

ds4s34	asl.w	(W.1bbf0).l
ds4s35	rts

ds4s36	move.b	#$80,B.1bb45
	rts


B.63ce0	dc.b	0,0
B.63ce2	dc.b	0,0


dw.subE.sub
	move.b	B.1bbc4,d0
	bne.s	dsEs2
	rts

dsEs1	move.b	#3,B.1bbc3
	rts

dsEs2	move.b	B.1bb44,d0
	beq.s	dsEs3

	move.b	off.ground.value,d0
	bne.s	dsEs6

dsEs3	move.w	W.1bcd0,d0
	sub.w	W.1bd66,d0
	move.w	d0,d4
	add.w	#40,d0
	bpl.s	dsEs4
	neg.w	d0

dsEs4	cmp.w	#192,d0
	bge.s	dsEs1

	tst.b	B.1bbc3
	beq.s	dsEs6

	subq.b	#1,B.1bbc3
	move.w	#256,d3
	sub.w	d0,d3
	tst.w	d4
	bpl.s	dsEs5
	neg.w	d3

dsEs5	asl.w	#4,d3
	move.w	d3,W.1bd56

dsEs6	move.b	sin.x+1,d0
	cmp.b	#45,d0
	bcc.s	dsEs8

	move.b	W.1bc38+1,d0
	cmp.b	#8,d0
	bcc.s	dsEs8

	move.b	#8,d0
	tst.b	sin.x
	bmi.s	dsEs7
	move.b	#248,d0

dsEs7	move.b	d0,W.1bd54

dsEs8	tst.b	B.1bbeb
	bmi.s	dsEsb

	move.w	#3,d3
	move.w	#0,d0
	tst.b	B.1bb74
	bne.s	dsEs9
	move.w	W.1bbee,d0

dsEs9	sub.w	steering.values+4,d0
	bpl.s	dsEsa
	move.w	#-3,d3

dsEsa	asr.w	#1,d0
	add.w	d3,d0
	move.w	d0,W.1bd58

dsEsb	move.b	#$80,cars.collided
	move.b	#$80,B.1bbeb
	move.w	#512,d3
	move.w	W.1bd54,d0
	bpl.s	dsEsc
	neg.w	d0

dsEsc	add.w	d0,d3
	move.w	W.1bd56,d0
	bpl.s	dsEsd
	neg.w	d0

dsEsd	add.w	d0,d3
	move.w	W.1bd58,d0
	bpl.s	dsEse
	neg.w	d0

dsEse	add.w	d0,d3
	lsr.w	#8,d3
	move.l	#B.1bb4f,a0
	move.w	#2,d2

dsEsf	move.b	(a0,d2.w),d0
	add.b	d3,d0
	bcc.s	dsEsg
	move.b	#$ff,d0

dsEsg	move.b	d0,(a0,d2.w)
	subq.b	#1,d2
	bpl.s	dsEsf

	move.b	#$80,B.1bb54
	rts


car.to.car.collision
	tst.b	cars.collided.delay
	beq.s	coll1.sub31
	subq.b	#1,cars.collided.delay

coll1.sub31
	tst.b	cars.collided
	beq	coll1.sub33

	move.b	#0,cars.collided
	move.w	W.1bbee,d0
	sub.w	W.1bd58,d0
	bpl.s	coll1.sub32
	move.w	#0,d0

coll1.sub32
	move.w	d0,W.1bbee

	move.w	W.1bd56,d0
	asr.w	#4,d0
	sub.w	d0,W.1bd76
	sub.w	d0,W.1bd78
	sub.w	d0,W.1bd7a

	move.w	W.1bd54,d0
	add.w	d0,W.1bd40

	move.w	W.1bd56,d0
	add.w	d0,W.1bd42

	move.w	W.1bd58,d0
	add.w	d0,W.1bd44

	move.w	#0,W.1bd54
	move.w	#0,W.1bd56
	move.w	#0,W.1bd58

	tst.b	cars.collided.delay
	bne.s	coll1.sub33

	move.b	#2,d0			hit car
	jsr	(sound.effect).l
	move.b	#5,cars.collided.delay
coll1.sub33
	rts


W.63ede	dc.w	0
cars.collided.delay	dc.b	0,0


dw.sub4.sub
	move.w	#$8000,W.63ede
	move.w	#40,d0
	tst.b	near.section.byte1
	bpl.s	ds4s1
	move.w	#124,d0

ds4s1	move.w	d0,corner.values.offset-1

	move.w	#0,d7
	move.w	W.1bd86,d0
	sub.w	W.1bd66,d0
	cmp.w	W.63ede,d0
	blt.s	ds4s2
	move.w	d0,W.63ede

ds4s2	add.w	corner.values.offset-1,d0
	bpl.s	ds4s3

	cmp.w	#-96,d0
	bcc.s	ds4s3
	move.w	#-96,d0

ds4s3	move.w	d0,d6
	sub.w	W.1bd6e,d0
	bsr	collision1.sub
	bpl.s	ds4s4
	move.w	#0,d0

ds4s4	cmp.w	#1024,d0
	blt.s	ds4s5
	move.w	#1023,d0

ds4s5	or.w	d0,d7
	sub.w	corner.values.offset-1,d0
	move.w	d0,W.1bd5e
	move.w	d6,W.1bd6e
	move.w	W.1bd88,d0
	sub.w	W.1bd68,d0
	cmp.w	W.63ede,d0
	blt.s	ds4s6
	move.w	d0,W.63ede

ds4s6	add.w	corner.values.offset-1,d0
	bpl.s	ds4s7
	cmp.w	#-96,d0
	bcc.s	ds4s7
	move.w	#-96,d0

ds4s7	move.w	d0,d6
	sub.w	W.1bd70,d0
	bsr	collision1.sub
	bpl.s	ds4s8
	move.w	#0,d0

ds4s8	cmp.w	#1024,d0
	blt.s	ds4s9
	move.w	#1023,d0

ds4s9	or.w	d0,d7
	sub.w	corner.values.offset-1,d0
	move.w	d0,W.1bd60
	move.w	d6,W.1bd70
	move.w	W.1bd8a,d0
	sub.w	W.1bd6a,d0
	cmp.w	W.63ede,d0
	blt.s	ds4sa
	move.w	d0,W.63ede

ds4sa	add.w	corner.values.offset-1,d0
	bpl.s	ds4sb
	cmp.w	#-96,d0
	bcc.s	ds4sb
	move.w	#-96,d0

ds4sb	move.w	d0,d6
	sub.w	W.1bd72,d0
	bsr	collision1.sub
	bpl.s	ds4sc
	move.w	#0,d0

ds4sc	cmp.w	#1024,d0
	blt.s	ds4sd
	move.w	#1023,d0

ds4sd	or.w	d0,d7
	sub.w	corner.values.offset-1,d0
	move.w	d0,W.1bd62
	move.w	d6,W.1bd72
	move.w	d7,d0
	asr.w	#8,d0
	or.b	d7,d0
	move.b	d0,B.1bb44

	move.w	W.1bd5e,d4
	add.w	W.1bd60,d4
	add.w	W.1bd62,d4
	move.w	W.1bd5e,d7
	asl.w	#2,d7
	move.w	d4,d0
	add.w	W.1bd5e,d0
	add.w	d7,d0
	asr.w	#3,d0
	move.w	d0,W.1bd7e

	move.w	W.1bd60,d7
	asl.w	#2,d7
	move.w	d4,d0
	add.w	W.1bd60,d0
	add.w	d7,d0
	asr.w	#3,d0
	move.w	d0,W.1bd80

	move.w	W.1bd62,d7
	asl.w	#2,d7
	move.w	d4,d0
	add.w	W.1bd62,d0
	add.w	d7,d0
	asr.w	#3,d0
	move.w	d0,W.1bd82

	move.b	(B.1ca29).l,d1
	move.l	#TAB.1ed8a,a0
	move.b	(a0,d1.w),d0
	and.b	#4,d0
	beq.s	ds4se

	move.w	W.1bd7a,d0
	or.w	W.1bd82,d0
	and.w	#$fffc,d0
	bne.s	ds4se

	bsr	randomize.long
	and.b	#$f,d0
	bne.s	ds4se
	move.w	#160,W.1bd7a

ds4se	move.w	W.1bd7e,d0
	move.b	#$ee,d2
	beq.s	ds4sf
	muls	d2,d0
	asr.l	#8,d0

ds4sf	add.w	W.1bd76,d0
	move.w	d0,W.1bd76
	move.b	#$ee,d2
	beq.s	ds4s10
	muls	d2,d0
	asr.l	#8,d0

ds4s10	asr.w	#1,d0
	add.w	d0,W.1bd66
	move.w	W.1bd80,d0
	move.b	#$ee,d2
	beq.s	ds4s11
	muls	d2,d0
	asr.l	#8,d0

ds4s11	add.w	W.1bd78,d0
	move.w	d0,W.1bd78

	move.b	#$ee,d2
	beq.s	ds4s12
	muls	d2,d0
	asr.l	#8,d0

ds4s12	asr.w	#1,d0
	add.w	d0,W.1bd68

	move.w	W.1bd82,d0
	move.b	#$ee,d2
	beq.s	ds4s13
	muls	d2,d0
	asr.l	#8,d0

ds4s13	add.w	W.1bd7a,d0
	move.w	d0,W.1bd7a

	move.b	#$ee,d2
	beq.s	ds4s14
	muls	d2,d0
	asr.l	#8,d0

ds4s14	asr.w	#1,d0
	add.w	d0,W.1bd6a
	move.w	#296,sin.x

	move.b	#0,d1
	move.b	#2,d2
	bsr	dw.sub4.sub.sub
	move.w	#368,sin.x
	move.b	#0,d1
	tst.w	d4
	bpl.s	ds4s15
	addq.b	#2,d1

ds4s15	move.b	#4,d2
	bsr.s	dw.sub4.sub.sub

	move.w	W.1bd66,DAT.1be70+$f4
	add.w	#80,DAT.1be70+$f4

	move.w	W.1bd68,DAT.1be70+$f8
	add.w	#80,DAT.1be70+$f8

	move.w	W.1bd6a,DAT.1be70+$f6
	add.w	#80,DAT.1be70+$f6

	move.w	DAT.1be70+$f8,d0
	sub.w	DAT.1be70+$f4,d0
	asr.w	#1,d0
	move.w	DAT.1be70+$f6,d3
	add.w	d0,d3
	move.w	d3,DAT.1be70+$fa

	move.w	DAT.1be70+$f6,d3
	sub.w	d0,d3
	move.w	d3,DAT.1be70+$f6
	rts


dw.sub4.sub.sub.sub
	move.l	#W.1bd66,a0
	move.w	(a0,d1.w),d0
	sub.w	(a0,d2.w),d0
	move.w	d0,d4
	tst.w	d0
	bpl.s	ds4s16
	neg.w	d0
ds4s16	rts


dw.sub4.sub.sub
	move.l	#W.1bd76,a4
	move.b	d1,corner.values.offset

	bsr.s	dw.sub4.sub.sub.sub

	move.w	sin.x,d3
	sub.w	d0,d3
	bpl.s	ds4ss3

	tst.w	d4
	bpl.s	ds4ss1
	move.b	d2,d1

ds4ss1	move.l	#W.1bd66,a0
	add.w	d3,(a0,d1.w)
	cmp.b	#4,d2
	beq.s	ds4ss2

	move.b	#0,d1
	bra.s	average.two.values

ds4ss2	move.b	#0,d1
	move.b	#2,d2
	bsr.s	average.two.values

	move.b	#4,d1
	bsr.s	average.two.values

	move.b	#0,d1
	bsr.s	average.two.values

	move.b	#4,d2
	move.b	corner.values.offset,d1

ds4ss3	cmp.b	#4,d2
	bne.s	ds4ss7

	move.b	B.1bb44,d0
	bne.s	ds4ss7

	tst.b	road.height.value
	bmi	ds4ss4

ds4ss4	move.w	(a4,d1.w),d0
	sub.w	4(a4),d0
	bmi.s	ds4ss5

	cmp.w	#16,d0
	bge.s	ds4ss7

ds4ss5	move.b	#4,d1
	move.l	#TAB.642ea,a0

ds4ss6	move.w	(a0,d1.w),d0
	add.w	d0,(a4,d1.w)
	subq.b	#2,d1
	bpl.s	ds4ss6
ds4ss7	rts


TAB.642ea
	dc.w	4,4,-4


average.two.values
	move.w	(a4,d1.w),d0
	add.w	(a4,d2.w),d0
	asr.w	#1,d0
	move.w	d0,(a4,d1.w)
	move.w	d0,(a4,d2.w)
	rts


fade.screen.out
	move.w	d0,st.colours
	move.b	#30,B.616da
	move.l	#st.colours,a0
	move.w	#30,d4

set.dest.colours
	move.w	(a0),32(a0,d4.w)
	subq.w	#2,d4
	bpl.s	set.dest.colours

fade.screen.in
	move.l	#st.colours,a0
	move.w	#30,d4
	move.b	#0,d7

fade1	move.b	32(a0,d4.w),d0
	and.b	#$f,d0
	move.b	(a0,d4.w),d3
	and.b	#$f,d3
	cmp.b	d3,d0
	beq.s	fade3
	bgt.s	fade2
	subq.b	#2,d3

fade2	addq.b	#1,d3
	addq.b	#1,d7

fade3	move.b	d3,(a0,d4.w)
	move.b	33(a0,d4.w),d0
	lsr.b	#4,d0
	move.b	1(a0,d4.w),d3
	lsr.b	#4,d3
	cmp.b	d3,d0
	beq.s	fade5
	bgt.s	fade4
	subq.b	#2,d3

fade4	addq.b	#1,d3
	addq.b	#1,d7

fade5	move.b	1(a0,d4.w),d0
	and.b	#$f,d0
	asl.b	#4,d3
	or.b	d3,d0
	move.b	d0,1(a0,d4.w)
	move.b	33(a0,d4.w),d0
	and.b	#$f,d0
	move.b	1(a0,d4.w),d3
	and.b	#$f,d3
	cmp.b	d3,d0
	beq.s	fade7
	bgt.s	fade6
	subq.b	#2,d3

fade6	addq.b	#1,d3
	addq.b	#1,d7

fade7	move.b	1(a0,d4.w),d0
	and.b	#$f0,d0
	or.b	d3,d0
	move.b	d0,1(a0,d4.w)
	subq.w	#2,d4
	bpl.s	fade1

	tst.b	d7
	beq.s	fade9

	jsr	(set.amiga.colours).l
	move.b	#2,frame.count

fade8	tst.b	frame.count
	bne.s	fade8
	bra	fade.screen.in

fade9	tst.b	B.616da
	bne.s	fade9
	rts


special.long	dc.l	$9cedcd02


get.sin	move.w	#0,d5
	bra.s	get.sin.cos
get.cos	move.w	#$4000,d5
get.sin.cos
	move.l	#sin.table,a0
	move.w	d0,d3
	and.w	#$3fff,d3
	move.w	d0,d6
	and.w	#$4000,d6
	eor.w	d5,d6
	bne.s	gsc1
	eor.w	#$3fff,d3
	addq.w	#1,d3
gsc1	ror.w	#5,d3
	move.w	d3,d4
	and.w	#$3fe,d4
	move.w	(a0,d4.w),d6
	sub.w	2(a0,d4.w),d6
	ror.w	#1,d3
	and.w	#$fc00,d3
	mulu	d3,d6
	swap	d6
	move.w	(a0,d4.w),d7
	sub.w	d6,d7
	lsr.w	#1,d7
	move.w	d0,d3
	and.w	d5,d3
	asl.w	#1,d3
	eor.w	d3,d0
	bpl.s	gsc2
	neg.w	d7
gsc2	move.w	d7,d0
	rts


dw.sub9.sub3
	move.l	#TAB.1cc46,a0
	move.w	d0,d4
	bpl.s	ds9s31
	neg.w	d0

ds9s31	move.w	d3,d5
	bpl.s	ds9s32
	neg.w	d3

ds9s32	cmp.w	d0,d3
	bne.s	ds9s33

	move.w	#$ffff,d7
	move.w	#$2000,d0
	bra.s	ds9s37

ds9s33	bgt.s	ds9s36

	swap	d3
	clr.w	d3
	divu	d0,d3
	move.w	d3,d7
	lsr.w	#4,d3
	and.b	#$fe,d3
	move.w	(a0,d3.w),d0
	move.w	d4,d3
	eor.w	d5,d3
	bmi.s	ds9s34
	neg.w	d0

ds9s34	move.w	#$4000,d3
	tst.w	d4
	bpl.s	ds9s35
	move.w	#$c000,d3

ds9s35	add.w	d3,d0
	rts

ds9s36	swap	d0
	clr.w	d0
	divu	d3,d0
	move.w	d0,d7
	lsr.w	#4,d0
	and.b	#$fe,d0
	move.w	(a0,d0.w),d0

ds9s37	move.w	d4,d3
	eor.w	d5,d3
	bpl.s	ds9s38
	neg.w	d0

ds9s38	tst.w	d5
	bpl.s	ds9s39
	add.w	#$8000,d0
ds9s39	rts


dw.sub9.sub4
	move.l	#TAB.1dc46,a0
	tst.w	d4
	bpl.s	ds9s41
	neg.w	d4

ds9s41	tst.w	d5
	bpl.s	ds9s42
	neg.w	d5

ds9s42	cmp.w	d4,d5
	bge.s	ds9s43
	exg	d4,d5

ds9s43	lsr.w	#4,d7
	and.b	#$fe,d7
	move.w	(a0,d7.w),d0
	mulu	d4,d0
	swap	d0
	add.w	d5,d0
	rts


dw.sub	bsr	dw.sub.sub
	move.b	#0,d0
	move.b	d0,B.1bbae
	move.b	d0,B.1bb5c
	move.b	d0,B.1bb7f
	move.w	#-1,W.1bc12
	move.b	#0,B.1bbba
	bsr	dw.sub.sub1
	rts


draw.world
	bsr.s	dw.sub

	move.b	#0,d0
	move.b	d0,B.1bbd5
	move.b	d0,B.1bbd6

	bsr	dw.sub1
	bcs.s	dw1

	cmp.b	#$ff,d0
	bne.s	dw4

	move.b	B.1bb07,d0
	move.b	B.1bb07+2,d2
	bsr	dw.sub2

	cmp.b	#$ff,d0
	bne.s	dw4

dw1	move.b	#$c0,B.1bb9c
	tst.b	B.57c3c
	beq	dw2

dw2	tst.b	B.1ca22
	bpl.s	dw3

	bsr	dw.sub4
	bsr	dw.sub5

dw3	move.b	B.1bb9f,W.1bb0e
	move.w	W.1bc28,W.1bc26
	move.b	B.1bb9e,B.1bb58
	bra.s	dw7

	bsr	draw.horizon
	bsr	draw.mountains
	bra	dwca

dw4	move.b	d0,current.road.section
	bsr	dw.sub9
	bsr	dw.subA
	move.b	current.road.section,d0
	move.b	d0,player.road.section

	btst	#6,B.1bb9c
	bne.s	dw5
	move.b	d0,B.1bb9b

dw5	bsr	dw.subB
	move.b	W.1bb0e,B.1bb9f
	move.w	W.1bc26,W.1bc28
	move.b	B.1bb58,B.1bb9e
	tst.b	B.57c3c
	beq.s	dw6

	bra.s	dw7

dw6	tst.b	B.1ca22
	bpl.s	dw7

	bsr	dw.sub4
	bsr	dw.subD
	bsr	dw.subE
	bsr	dw.sub5

dw7	move.b	#$80,d0
	move.b	d0,B.1bc14
	move.b	d0,B.1bc16
	move.b	player.road.section,current.road.section
	move.b	#0,B.1bbc5

	move.b	W.1bb0e,d0
	bpl.s	dw8
	bsr	to.next.road.section
	move.b	#0,W.1bb0e

dw8	tst.b	W.1bb0e
	bne.s	dwa

	bsr	to.previous.road.section
	cmp.b	B.1bba6,d1
	bne.s	dw9
	move.w	#0,W.1bc12

dw9	bsr	to.next.road.section

dwa	bsr	dw.subF
	bsr	dw.subG
	bsr	dw.subH
	bsr	dw.subI
	move.b	#0,B.1bbe5
	move.b	#0,B.1bb60
	move.b	#4,B.1bbc5
	bsr	dw.subJ
	bsr	to.next.road.section

	bsr	dw.subF
	bsr	dw.subG
	bsr	dw.subI2
	bsr	dw.subJ
	move.b	#1,B.1bb7f
	bsr	to.next.road.section

	bsr	dw.subF
	bsr	dw.subG
	bsr	dw.subI2
	bsr	dw.subJ
	bsr	to.next.road.section

	move.w	road.section.offset,far.road.limit
	move.w	x.values+240,W.660fc
	move.w	x.values+242,W.660fe
	bsr	dw.subK
	bsr	make.far.track.edges
	tst.b	B.1ca22
	bmi.s	dwb
	move.w	#-1,W.1bc12

dwb	tst.b	B.57c3c
	beq	dwc

dwc	move.w	road.section.offset,-(sp)
	bsr	draw.horizon
	bsr	draw.mountains
	move.w	(sp)+,road.section.offset

	bsr	set.opponent.draw.flag
	bsr	draw.far.road

	move.w	far.road.limit,road.section.offset
	bsr	draw.near.road

dwca
dwd	bsr	draw.sparks

	bsr	update.wheel.positions

dw11	bsr	race.prompts
	rts


update.wheel.rotation
	move.b	W.1bc62,d0
	add.b	d0,B.1bbe3
	bcc.s	uwr1
	bsr	wheel.frame.number

uwr1	move.b	B.1bbdb,d0
	add.b	#37,d0
	cmp.w	#126,graphic.info+10
	bge.s	uwr2
	addq.b	#6,d0
uwr2	move.w	#0,d1
	bsr	set.sprite.pointers

	move.b	#5,d0
	sub.b	B.1bbdb,d0
	add.b	#37,d0
	cmp.w	#126,graphic.info+3*16+10
	bge.s	uwr3
	addq.b	#6,d0
uwr3	move.w	#1,d1
	bsr	set.sprite.pointers
	rts


dw.subF	move.l	#DAT.1be70,a6
	move.b	current.road.section,d1
	bsr	fetch.near.section.stuff

	move.b	current.road.section,d0
	bsr	dw.sub9.sub

	move.b	W.1bc30,d0
	sub.b	top.two.bits,d0
	move.b	d0,W.1bbf2

	bsr	dw.subF.sub
	move.b	B.1bb60,d1
	beq.s	dsF1

	move.l	#DAT.1be70-4,a0
	move.w	(a0,d1.w),W.1bb34
	move.w	2(a0,d1.w),W.1bb36

dsF1	tst.b	B.5d724
	bmi.s	dsF5

	move.b	W.1bbf2,d0
	move.b	banked.road.alternating.flag,d3
	eor.b	d3,d0
	tst.b	B.1bb93
	bpl.s	dsF2

	tst.b	near.section.byte1
	bmi.s	dsF3

	btst	#6,near.section.byte1
	beq.s	dsF3

dsF2	tst.b	near.section.flag.byte3
	bpl.s	dsF4

dsF3	add.b	#$40,d0

dsF4	move.b	#0,B.1bbad
	bpl.s	dsF5

	move.b	d0,B.1bbae
	move.b	#0,B.1bbc5
	bsr	dw.subF.sub1

	move.b	two.or.zero,d0
	add.b	near.section.byte2.minus2,d0
	and.b	#2,d0
	move.b	d0,two.or.zero

	tst.b	banked.road.alternating.flag
	bne.s	dsF6
	bra	dsFba

dsF5	tst.b	banked.road.alternating.flag
	beq.s	dsF6
	bra	dsFba

dsF6	move.w	near.offset3,d0
	rol.w	#8,d0
	sub.w	#$b100,d0
	and.l	#$ffff,d0
	add.l	#road.section.words,d0
	move.l	d0,a0
	move.b	(a0),d0
	addq.b	#7,d0
	move.b	d0,B.1bb91

	move.b	B.1bbc5,d1
	move.l	#DAT.1be70,a6

dsF7	tst.w	(a6,d1.w)
	bmi.s	dsFb

	move.w	#$8000,120(a6,d1.w)
	cmp.b	B.1bb60,d1
	bge.s	dsF8

	move.w	#$8000,(a6,d1.w)
	bra.s	dsFb

dsF8	move.w	d1,d2
	asl.w	#1,d2
	add.b	B.1bb91,d2
	bsr	dw.sub9.sub2
	bsr	dw.subF.sub2
	bsr	dw.subF.sub3
	btst	#6,B.1bb9c
	beq.s	dsF9

	bsr	dw.subF.sub4
	bcs.s	dsFa

dsF9	bsr	dw.subF.sub5

dsFa	move.b	d1,d2
	and.b	#2,d2
	move.l	#B.1bc14,a2
	move.b	d1,(a2,d2.w)

dsFb	addq.b	#2,d1
	cmp.b	near.section.byte2.doubled,d1
	bne.s	dsF7
	bra	dsF10a

dsFba	move.w	near.offset3,d0
	rol.w	#8,d0
	sub.w	#$b100,d0
	and.l	#$ffff,d0
	add.l	#road.section.words,d0
	move.l	d0,a0
	move.b	(a0),d0
	addq.b	#7,d0
	move.b	near.section.byte2,d3
	subq.b	#1,d3
	asl.b	#2,d3
	add.b	d3,d0
	move.b	d0,B.1bb91

	move.b	B.1bbc5,d1
	move.l	#DAT.1be70,a6

dsFc	tst.w	(a6,d1.w)
	bmi.s	dsF10

	move.w	#$8000,120(a6,d1.w)
	cmp.b	B.1bb60,d1
	bge.s	dsFd

	move.w	#$8000,(a6,d1.w)
	bra.s	dsF10

dsFd	move.b	d1,d3
	asl.b	#1,d3
	move.b	B.1bb91,d2
	sub.b	d3,d2
	bsr	dw.sub9.sub2
	bsr	dw.subF.sub2
	bsr	dw.subF.sub3
	btst	#6,B.1bb9c
	beq.s	dsFe

	bsr	dw.subF.sub4
	bcs.s	dsFf

dsFe	bsr.s	dw.subF.sub5

dsFf	move.b	d1,d2
	and.b	#2,d2
	move.l	#B.1bc14,a2
	move.b	d1,(a2,d2.w)

dsF10	addq.b	#2,d1
	cmp.b	near.section.byte2.doubled,d1
	bne.s	dsFc

dsF10a	move.l	#x.values,a1
	move.b	B.1bc14,d1
	move.w	(a1,d1.w),x.values+240

	move.b	B.1bc16,d1
	move.w	(a1,d1.w),x.values+242

	move.b	B.1bbc5,d1
dsF11	tst.w	(a6,d1.w)
	bmi.s	dsF12
	bsr	z.rotate

dsF12	addq.b	#2,d1
	cmp.b	near.section.byte2.doubled,d1
	bne.s	dsF11

	move.b	B.1bc14,B.654c0
	rts


B.654c0	dc.b	0,0


dw.subF.sub5
	move.l	#x.values,a4
	move.l	#y.values,a5
	move.b	d1,d2
	and.b	#2,d2
	move.l	#B.1bc14,a2
	move.b	(a2,d2.w),d2
	bpl.s	dsFs51

	tst.b	unused.flag
	bmi.s	dsFs54

	move.b	clip.flag,d0
	beq.s	dsFs55

	eor.b	d1,d0
	and.b	#2,d0
	beq.s	dsFs54
	bra.s	dsFs55

dsFs51	cmp.b	#4,d2
	bge.s	dsFs52

	tst.b	unused.flag
	bmi.s	dsFs52
	add.b	#$f0,d2

dsFs52	move.b	d1,d0
	and.b	#2,d0
	bne.s	dsFs53

	move.w	(a4,d2.w),d0
	sub.w	(a4,d1.w),d0
	bmi.s	dsFs55
	bra.s	dsFs54

dsFs53	move.w	(a4,d1.w),d0
	sub.w	(a4,d2.w),d0
	bmi.s	dsFs55

dsFs54	move.w	#512,120(a6,d1.w)
	move.w	(a4,d1.w),120(a4,d1.w)
	add.b	#120,d1
	bsr	dw.subF.sub3
	bsr	z.rotate0
	sub.b	#120,d1
dsFs55	rts


dw.subJ	move.l	#x.values,a4
	move.l	#y.values,a5
	move.b	near.section.byte2.doubled,d1
	move.b	B.654c0,d0
	bmi.s	dsJ1

	addq.b	#4,d0
	move.b	d0,d1

dsJ1	tst.b	B.1bbae
	bmi.s	dsJ3
	move.b	#2,d2

dsJ2	subq.b	#2,d1
	move.w	(a4,d1.w),(a4,d2.w)
	move.w	(a5,d1.w),(a5,d2.w)
	move.w	(a6,d1.w),(a6,d2.w)

	move.w	120(a4,d1.w),120(a4,d2.w)
	move.w	120(a5,d1.w),120(a5,d2.w)
	move.w	120(a6,d1.w),120(a6,d2.w)

	subq.b	#2,d2
	bpl.s	dsJ2

	move.b	#0,B.1bc14
	move.b	#2,d0
	move.b	d0,B.1bc16
	cmp.w	#256,(a4,d1.w)
	rts

dsJ3	move.b	#0,B.1bbc5
	subq.b	#4,d1
	cmp.w	#256,(a4,d1.w)
	rts


dw.subG	clr.w	d0
	move.b	current.road.section,d0
	move.l	#TAB.7aa1a,a0
	asl.w	#2,d0
	move.l	(a0,d0.w),a0
	move.w	(a0),W.66100
	move.l	#DAT.1bdd0,a3
	move.l	#DAT.1be70,a6
	move.b	near.section.byte2.doubled,d1
	bsr.s	dsG0
	move.b	near.section.byte2.doubled,d1
	addq.b	#2,d1

dsG0	subq.b	#4,d1
	tst.w	(a6,d1.w)
	bmi.s	dsG3

	tst.w	120(a6,d1.w)
	bpl.s	dsG5

	move.b	d1,d0
	bclr	#1,d0
	cmp.b	B.1bb60,d0
	beq.s	dsG2

	btst	#1,d1
	bne.s	dsG1

	btst	#7,W.66100
	bne.s	dsG6
	bra.s	dsG3

dsG1	btst	#6,W.66100
	bne.s	dsG6
	bra.s	dsG3

dsG2	tst.b	clip.flag
	beq.s	dsG3

	move.w	clip.value,d0
	rol.w	#2,d0
	eor.b	d1,d0
	and.b	#2,d0
	beq.s	dsG3
	bra.s	dsG6

dsG3	subq.b	#4,d1
	bmi.s	dsG8

dsG4	tst.w	(a6,d1.w)
	bmi.s	dsG3

	tst.w	120(a6,d1.w)
	bmi.s	dsG3

	move.w	d1,d3
	bclr	#1,d3
	or.b	#$40,(a3,d3.w)

dsG5	subq.b	#4,d1
	bmi.s	dsG8

	tst.w	(a6,d1.w)
	bmi.s	dsG5

	tst.w	120(a6,d1.w)
	bpl.s	dsG5

	cmp.b	B.1bb60,d1
	blt.s	dsG8

dsG6	bsr.s	dw.subG.sub

	move.w	d1,d3
	bclr	#1,d3
	or.b	#$40,(a3,d3.w)
	subq.b	#4,d1
	bpl.s	dsG4

	addq.b	#4,d1
	move.w	road.section.offset,d3
	cmp.w	#32,d3
	beq.s	dsG8

	move.w	d3,-(sp)
	sub.w	#16,d3
	tst.w	d1
	beq.s	dsG7
	addq.w	#4,d3

dsG7	move.w	d3,road.section.offset
	move.w	d1,d2
	add.b	#120,d1
	bsr	clip.line.make.edge
	move.w	(sp)+,road.section.offset
dsG8	rts


dw.subG.sub
	movem.l	d1-d7/a3-a6,-(sp)

	move.b	d1,B.1bbe4
	move.w	#512,120(a6,d1.w)
	move.w	d1,d0
	lsr.w	#2,d0
	bsr	dw.sub5.sub

	move.b	B.1bbe4,d1
	move.w	d1,d2
	and.w	#2,d2
	add.b	#120,d1
	bsr	dw.subG.sub.sub

	movem.l	(sp)+,d1-d7/a3-a6
	rts


dw.subF.sub
	move.w	near.left.offset,d0
	rol.w	#8,d0
	sub.w	#$b100,d0
	and.l	#$ffff,d0
	add.l	#road.section.words,d0
	move.l	d0,a4

	move.w	near.right.offset,d0
	rol.w	#8,d0
	sub.w	#$b100,d0
	and.l	#$ffff,d0
	add.l	#road.section.words,d0
	move.l	d0,a5

	move.l	#DAT.1bdd0,a3
	move.w	#46,d7
	sub.w	W.1bc26,d7
	bpl.s	dsFs1
	move.b	#0,d7

dsFs1	clr.w	d0
	move.b	half.near.section.byte2.minus1,d0
	add.w	d0,W.1bc26

	move.b	#0,d0
	move.b	near.section.byte2.minus2,d1
	asl.w	#1,d1
	move.b	current.road.section,d2
	cmp.b	(B.1ca1c).l,d2
	bne.s	dsFs2
	move.b	#1,d0

dsFs2	move.b	d0,(a3,d1.w)
	move.b	#0,d2
	move.b	B.1bbc5,d1
	bne.s	dsFs4

	move.b	d2,B.1bb7a

	tst.b	current.near.left.road.section.ID
	bpl.s	dsFs3

	move.b	B.1bb7a,d2
	asl.b	#1,d2
	move.b	(a4,d2.w),d0
	bpl	dsFsd
	bra	dsFsc

dsFs3	move.b	(a4,d2.w),d0
	bmi.s	dsFs6
	bra.s	dsFs7

dsFs4	move.b	#1,d2
	move.b	d2,B.1bb7a

	tst.b	current.near.left.road.section.ID
	bmi	dsFsb

dsFs5	move.b	(a4,d2.w),d0
	bmi.s	dsFs6

	cmp.b	d7,d2
	bcs.s	dsFs7

	move.w	#$8000,(a6,d1.w)
	move.w	#$8000,2(a6,d1.w)
	bra	dsFsaa

dsFs6	move.b	#0,(a3,d1.w)

dsFs7	move.b	(a4,d2.w),d0
	move.b	d0,d3
	asl.b	#1,d0
	and.w	#$e0,d0
	and.b	#$f,d3
	asl.w	#8,d3
	or.w	d3,d0
	add.w	near.left.word,d0
	move.w	d0,(a6,d1.w)
	tst.b	(a3,d1.w)
	bmi.s	dsFsa

	move.w	-4(a6,d1.w),d3
	bpl.s	dsFs8

	tst.b	B.1bb7f
	beq.s	dsFsa

	cmp.b	#4,d1
	blt.s	dsFsa

	move.w	d0,-(sp)
	subq.b	#1,d2
	move.b	(a4,d2.w),d0
	move.b	d0,d3
	asl.b	#1,d0
	and.w	#$e0,d0
	and.b	#$f,d3
	asl.w	#8,d3
	or.w	d3,d0
	add.w	near.left.word,d0
	addq.b	#1,d2
	move.w	d0,d3
	move.w	(sp)+,d0

dsFs8	sub.w	d3,d0
	bpl.s	dsFs9
	neg.w	d0

dsFs9	cmp.w	#640,d0
	blt.s	dsFsa

	cmp.b	#4,d1
	blt.s	dsFsa
	or.b	#$20,(a3,d1.w)

dsFsa	move.b	(a5,d2.w),d0
	move.b	d0,d3
	asl.b	#1,d0
	and.w	#$e0,d0
	and.b	#$f,d3
	asl.w	#8,d3
	or.w	d3,d0
	add.w	near.right.word,d0
	move.w	d0,2(a6,d1.w)

dsFsaa	addq.b	#1,d2
	addq.b	#4,d1
	cmp.b	near.section.byte2.minus2.doubled,d1
	blt	dsFs5

	beq	dsFs7
	bra	dsFs11

dsFsb	move.b	B.1bb7a,d2
	asl.b	#1,d2
	tst.b	(a4,d2.w)
	bmi.s	dsFsc

	move.b	B.1bb7a,d0
	cmp.b	d7,d0
	bcs.s	dsFsd

	move.w	#$8000,(a6,d1.w)
	move.w	#$8000,2(a6,d1.w)
	bra	dsFs10a

dsFsc	move.b	#0,(a3,d1.w)

dsFsd	move.b	1(a4,d2.w),d3
	move.b	(a4,d2.w),d0
	and.b	#$7f,d0
	asl.w	#8,d0
	or.b	d3,d0
	add.w	near.left.word,d0
	move.w	d0,(a6,d1.w)
	tst.b	(a3,d1.w)
	bmi.s	dsFs10

	move.w	-4(a6,d1.w),d3
	bpl.s	dsFse

	tst.b	B.1bb7f
	beq.s	dsFs10

	cmp.b	#4,d1
	blt.s	dsFs10

	move.w	d0,-(sp)
	subq.b	#2,d2
	move.b	1(a4,d2.w),d3
	move.b	(a4,d2.w),d0
	and.b	#$7f,d0
	asl.w	#8,d0
	or.b	d3,d0
	add.w	near.left.word,d0
	addq.b	#2,d2
	move.w	d0,d3
	move.w	(sp)+,d0

dsFse	sub.w	d3,d0
	bpl.s	dsFsf
	neg.w	d0

dsFsf	cmp.w	#640,d0
	blt.s	dsFs10

	cmp.b	#4,d1
	blt.s	dsFs10
	or.b	#$20,(a3,d1.w)

dsFs10	move.b	1(a5,d2.w),d3
	move.b	(a5,d2.w),d0
	and.b	#$7f,d0
	asl.w	#8,d0
	or.b	d3,d0
	add.w	near.right.word,d0
	move.w	d0,2(a6,d1.w)

dsFs10a	addq.b	#1,B.1bb7a
	addq.b	#4,d1
	cmp.b	near.section.byte2.minus2.doubled,d1
	blt	dsFsb

	bne.s	dsFs12
	move.b	B.1bb7a,d2
	asl.b	#1,d2
	bra	dsFsd

dsFs11	subq.b	#1,d2

dsFs12	move.b	(a4,d2.w),d0
	bpl.s	dsFs13

	move.b	#$80,-4(a3,d1.w)
	move.b	half.near.section.byte2.minus1,d2
	cmp.b	d7,d2
	bcs.s	dsFs13

	move.w	#$8000,-4(a6,d1.w)
	move.w	#$8000,-2(a6,d1.w)
dsFs13	rts


dw.subH	move.b	B.1bb60,d1
	bne.s	dsH1
	rts

dsH1	move.w	#8,d3
	bsr.s	dw.subH.sub

	move.b	B.1bb60,d1
	addq.b	#2,d1
	move.w	#9,d3
	bsr.s	dw.subH.sub

	move.b	B.1bb60,d1
	add.b	#120,d1
	move.w	#10,d3
	bsr.s	dw.subH.sub

	move.b	B.1bb60,d1
	add.b	#122,d1
	move.w	#11,d3
	bsr.s	dw.subH.sub

	move.w	#32,road.section.offset
	rts


dw.subH.sub
	asl.w	#2,d3
	move.w	d3,road.section.offset

	move.l	#x.values,a4
	move.l	#y.values,a5
	move.b	d1,B.1bbe4
	cmp.w	#120,d1
	blt.s	dsHs1

	tst.w	(a6,d1.w)
	bmi.s	dsHs2

dsHs1	move.w	(a4,d1.w),d0
	cmp.w	#256,d0
	bcc.s	dsHs2

	move.w	(a5,d1.w),d0
	cmp.w	#128,d0
	bcc.s	dsHs2

	bsr.s	dw.subH.sub.sub
	move.b	B.1bbe4,d1
	move.w	d1,d2
	subq.b	#4,d2
	bsr	clip.line.make.edge
	rts

dsHs2	move.l	#section.data,a1
	move.w	road.section.offset,d3
	move.l	#$80000000,(a1,d3.w)
	rts


dw.subH.sub.sub
	move.b	d1,B.1bbe4
	move.b	d1,d0
	and.b	#2,d0
	move.b	d0,B.1bbe8

	move.b	d0,d2
	cmp.w	#120,d1
	blt.s	dsHss1

	move.w	#512,-4(a6,d1.w)
	bra.s	dsHss2

dsHss1	move.l	#W.1bb34,a2
	move.w	(a2,d2.w),-4(a6,d1.w)

dsHss2	move.b	W.1bb0e,d0
	bsr	dw.sub5.sub

	move.b	B.1bbe8,d1
	move.b	#8,d2
	move.b	W.1bb0e+1,d0
	and.w	#$ff,d0
	bsr	ds5s11

	move.b	B.1bbe4,d1
	cmp.w	#120,d1
	bge.s	dsHss3

	move.b	#0,d0
	move.b	W.1bb0e+1,road.height.value+2
	move.w	(a6,d1.w),d0
	sub.w	-4(a6,d1.w),d0
	move.b	road.height.value+2,d3
	asl.w	#7,d3
	bclr	#15,d3
	muls	d3,d0
	asl.l	#1,d0
	swap	d0
	add.w	d0,-4(a6,d1.w)

dsHss3	subq.b	#4,d1
	move.b	#8,d2
	bsr	dw.subG.sub.sub

	move.l	#x.values,a4
	move.l	#y.values,a5
	move.w	(a4,d1.w),d4
	move.w	(a5,d1.w),d5
	move.w	d4,d0
	cmp.w	#256,d0
	bcc.s	dsHss6

	move.w	d5,d0
	cmp.w	#128,d0
	bcc.s	dsHss6

	move.w	d4,d6
	sub.w	4(a4,d1.w),d6
	move.w	d5,d7
	sub.w	4(a5,d1.w),d7
	bne.s	dsHss5

	tst.w	d6
	bne.s	dsHss5

	move.w	#1,d7
	bra.s	dsHss5

dsHss4	move.w	d4,d0
	cmp.w	#256,d0
	bcc.s	dsHss6

	move.w	d5,d0
	cmp.w	#128,d0
	bcc.s	dsHss6

dsHss5	add.w	d6,d4
	add.w	d7,d5
	bra.s	dsHss4

dsHss6	move.w	d4,(a4,d1.w)
	move.w	d5,(a5,d1.w)
	rts


road.visible.range.table
	dcb.b	44,120
	dcb.b	36,0

B.65ec0	dc.b	0,0
B.65ec2	dc.b	0,0


dw.subK	clr.w	d0
	move.b	current.road.section,d0
	move.l	#TAB.7aa1a,a0
	asl.w	#2,d0
	move.l	(a0,d0.w),a6
	move.w	#4,d1

dsK1	move.w	(a6)+,d0
	move.l	#DAT.7ab5a,a0
	move.w	d0,(a0,d1.w)
	move.w	d0,W.66100
	move.b	d0,current.road.section

	bsr	dw.sub9.sub
	move.b	B.65ec0,d0
	ext.w	d0
	move.b	B.1bb2e,d4
	asl.w	#8,d4
	move.b	B.1bb23,d4
	asr.w	#1,d4
	asl.w	#2,d0
	asl.w	#8,d0
	add.w	d0,d4
	move.w	d4,B.65ec0

	move.b	B.65ec2,d0
	ext.w	d0
	move.b	B.1bb32,d4
	asl.w	#8,d4
	move.b	B.1bb27,d4
	asr.w	#1,d4
	asl.w	#2,d0
	asl.w	#8,d0
	add.w	d0,d4
	move.w	d4,B.65ec2

dsK2	tst.b	W.1bc30
	bmi.s	dsK4

	btst	#6,W.1bc30
	bne.s	dsK3

	move.w	(a6)+,d0
	move.w	(a6)+,d3
	bra.s	dsK6

dsK3	move.w	(a6)+,d3
	move.w	#2048,d0
	sub.w	(a6)+,d0
	bra.s	dsK6

dsK4	btst	#6,W.1bc30
	bne.s	dsK5

	move.w	#2048,d0
	sub.w	(a6)+,d0
	move.w	#2048,d3
	sub.w	(a6)+,d3
	bra.s	dsK6

dsK5	move.w	#2048,d3
	sub.w	(a6)+,d3
	move.w	(a6)+,d0

dsK6	asr.w	#1,d0
	asr.w	#1,d3
	add.w	B.65ec0,d0
	add.w	B.65ec2,d3
	bsr	dsFs21

	move.w	(a6)+,d0
	move.l	a6,-(sp)
	move.l	#DAT.1be70,a6
	move.w	d0,(a6,d1.w)
	sub.w	W.1bbfa,d0
	neg.w	d0
	asr.w	#3,d0
	move.w	W.1bc36,d3
	bsr	dsFs31

	move.l	#x.values,a4
	move.w	(a4,d1.w),d0
	btst	#1,d1
	bne.s	dsK8

	move.w	W.660fc,d3
	move.w	d0,W.660fc
	cmp.w	d3,d0
	blt.s	dsKa
	bne.s	dsK7

	tst.b	clip.flag
	bne.s	dsKa

dsK7	btst	#7,W.66100
	bne.s	dsKa
	bra.s	dsKb

dsK8	move.w	W.660fe,d3
	move.w	d0,W.660fe
	cmp.w	d3,d0
	bgt.s	dsKa
	bne.s	dsK9

	tst.b	clip.flag
	bne.s	dsKa

dsK9	btst	#6,W.66100
	beq.s	dsKb

dsKa	move.w	#512,120(a6,d1.w)
	move.w	(a4,d1.w),120(a4,d1.w)
	move.w	W.1bbfa,d0
	sub.w	#512,d0
	asr.w	#3,d0
	add.b	#120,d1
	move.w	W.1bc36,d3
	bsr	dsFs31
	bsr	z.rotate
	sub.b	#120,d1
	bra.s	dsKc

dsKb	move.w	#$8000,120(a6,d1.w)

dsKc	bsr	z.rotate
	move.l	(sp)+,a6
	cmp.l	L.66102,a6
	blt.s	dsKd
	move.l	#far.section0,a6

dsKd	addq.b	#2,d1
	btst	#1,d1
	bne	dsK2

	move.b	current.road.section,d2
	move.l	#road.visible.range.table,a0
	cmp.b	(a0,d2.w),d1
	bge.s	dsKf

	move.l	#x.values,a4
	cmp.w	#256,-4(a4,d1.w)
	bcs	dsK1

	cmp.w	#256,-2(a4,d1.w)
	bcs	dsK1

	move.l	#DAT.1be70,a0
	tst.w	116(a0,d1.w)
	bmi.s	dsKe

	cmp.w	#256,116(a4,d1.w)
	bcs	dsK1
	bra.s	dsKf

dsKe	tst.w	118(a0,d1.w)
	bmi.s	dsKf

	cmp.w	#256,118(a4,d1.w)
	bcs	dsK1

dsKf	move.b	d1,B.660fa
	rts


B.660fa	dc.b	0,0
W.660fc	dc.w	0
W.660fe	dc.w	0
W.66100	dc.w	0
L.66102	dc.l	0


draw.chains
	move.b	dnr.flag,d0
	bne.s	dch1

	move.b	B.1bbea,d0
	cmp.b	#96,d0
	beq.s	dch3

	sub.b	B.1bbe9,d0
	move.b	d0,B.1bbea

	addq.b	#8,B.1bbe9

dch1	move.b	B.1bbea,d2

dch2	move.l	#graphic.info+19*16+10,a3
	move.w	d2,d3
	sub.w	#48,d3
	move.w	d3,(a3)			y position of chain tops
	move.w	d3,32(a3)

	addq.w	#8,d3
	move.w	d3,16(a3)		y position of chain bottoms
	move.w	d3,48(a3)

	cmp.w	#16,16(a3)
	blt.s	dch3

	move.b	#20,d0			left chain bottom
	bsr	copy.graphic

	move.b	#22,d0			right chain bottom
	bsr	copy.graphic

	cmp.w	#16,(a3)
	blt.s	dch3

	move.b	#19,d0			left chain top
	bsr	copy.graphic

	move.b	#21,d0			right chain top
	bsr	copy.graphic

	sub.b	#16,d2
	bra.s	dch2

dch3	rts


set.pixel.colour
	lsr.b	#1,d0
	bcs.s	spc1
	bclr	#6,pp1+1
	bclr	#6,pp6+1
	bra.s	spc2
spc1	bset	#6,pp1+1
	bset	#6,pp6+1

spc2	lsr.b	#1,d0
	bcs.s	spc3
	bclr	#6,pp2+1
	bclr	#6,pp7+1
	bra.s	spc4
spc3	bset	#6,pp2+1
	bset	#6,pp7+1

spc4	lsr.b	#1,d0
	bcs.s	spc5
	bclr	#6,pp3+1
	bclr	#6,pp8+1
	bra.s	spc6
spc5	bset	#6,pp3+1
	bset	#6,pp8+1

spc6	lsr.b	#1,d0
	bcs.s	spc7
	bclr	#6,pp4+1
	bclr	#6,pp9+1
	bra.s	spc8
spc7	bset	#6,pp4+1
	bset	#6,pp9+1
spc8	rts


plot.pixel
	move.b	d4,d0
	and.w	#$f,d0
	eor.w	#$f,d0
	cmp.w	#8,d0
	bge.s	pp5

pp1	bclr	d0,1(a0)
pp2	bclr	d0,8001(a0)
pp3	bclr	d0,16001(a0)
pp4	bclr	d0,24001(a0)
	rts

pp5	and.w	#7,d0
pp6	bclr	d0,(a0)
pp7	bclr	d0,8000(a0)
pp8	bclr	d0,16000(a0)
pp9	bclr	d0,24000(a0)
	rts


fill.word
	move.w	d4,d2
	not.w	d2
word.col
	bra.w	col0

col0	and.w	d2,(a4)+
	and.w	d2,7998(a4)
	and.w	d2,15998(a4)
	and.w	d2,23998(a4)
	rts

col1	or.w	d4,(a4)+
	and.w	d2,7998(a4)
	and.w	d2,15998(a4)
	and.w	d2,23998(a4)
	rts

col2	and.w	d2,(a4)+
	or.w	d4,7998(a4)
	and.w	d2,15998(a4)
	and.w	d2,23998(a4)
	rts

col3	or.w	d4,(a4)+
	or.w	d4,7998(a4)
	and.w	d2,15998(a4)
	and.w	d2,23998(a4)
	rts

col4	and.w	d2,(a4)+
	and.w	d2,7998(a4)
	or.w	d4,15998(a4)
	and.w	d2,23998(a4)
	rts

col5	or.w	d4,(a4)+
	and.w	d2,7998(a4)
	or.w	d4,15998(a4)
	and.w	d2,23998(a4)
	rts

col6	and.w	d2,(a4)+
	or.w	d4,7998(a4)
	or.w	d4,15998(a4)
	and.w	d2,23998(a4)
	rts

col7	or.w	d4,(a4)+
	or.w	d4,7998(a4)
	or.w	d4,15998(a4)
	and.w	d2,23998(a4)
	rts

col8	and.w	d2,(a4)+
	and.w	d2,7998(a4)
	and.w	d2,15998(a4)
	or.w	d4,23998(a4)
	rts

col9	or.w	d4,(a4)+
	and.w	d2,7998(a4)
	and.w	d2,15998(a4)
	or.w	d4,23998(a4)
	rts

col10	and.w	d2,(a4)+
	or.w	d4,7998(a4)
	and.w	d2,15998(a4)
	or.w	d4,23998(a4)
	rts

col11	or.w	d4,(a4)+
	or.w	d4,7998(a4)
	and.w	d2,15998(a4)
	or.w	d4,23998(a4)
	rts

col12	and.w	d2,(a4)+
	and.w	d2,7998(a4)
	or.w	d4,15998(a4)
	or.w	d4,23998(a4)
	rts

col13	or.w	d4,(a4)+
	and.w	d2,7998(a4)
	or.w	d4,15998(a4)
	or.w	d4,23998(a4)
	rts

col14	and.w	d2,(a4)+
	or.w	d4,7998(a4)
	or.w	d4,15998(a4)
	or.w	d4,23998(a4)
	rts

col15	or.w	d4,(a4)+
	or.w	d4,7998(a4)
	or.w	d4,15998(a4)
	or.w	d4,23998(a4)
	rts


fill.horizontal.line
	cmp.w	d4,d5
	bgt.s	fhl1
	beq.s	fhl6

	tst.b	daft.flag
	bpl.s	fhl6
	bra.s	fhl6

fhl1	move.w	d4,d1
	and.w	#$f0,d1
	lsr.w	#3,d1
	lea	(a6,d1.w),a4
	move.w	d4,d3
	move.w	d5,d1
	lsr.w	#4,d3
	lsr.w	#4,d1
	sub.w	d3,d1
	bne.s	fhl2

	and.w	#$f,d4
	asl.w	#2,d4
	move.w	(a5,d4.w),d4
	and.w	#$f,d5
	asl.w	#2,d5
	move.w	64(a5,d5.w),d5
	and.w	d5,d4
	bsr	fill.word
	bra.s	fhl6

fhl2	subq.b	#1,d1
	and.w	#$f,d4
	beq.s	fhl3

	asl.w	#2,d4
	move.w	(a5,d4.w),d4
	bsr	fill.word
	subq.w	#1,d1
	bmi.s	fhl5

fhl3	move.l	d6,d2
	move.l	d7,d3
	swap	d2
	swap	d3

fhl4	move.w	d2,(a4)+
	move.w	d6,7998(a4)
	move.w	d3,15998(a4)
	move.w	d7,23998(a4)
	dbra	d1,fhl4

fhl5	and.w	#$f,d5
	beq.s	fhl6

	asl.w	#2,d5
	move.w	64(a5,d5.w),d4
	bsr	fill.word

fhl6	moveq	#0,d1
	moveq	#0,d2
	rts


simple.poly.fill
	move.w	(a2),d2
	move.w	(a0),d0
	cmp.w	(a3),d0
	bne.s	spf2

	cmp.w	(a1),d2
	bne.s	spf4

	cmp.w	d2,d0
	bge.s	spf4

spf1	exg	a2,a0
	exg	a3,a1
	bra.s	spf4

spf2	blt.s	spf3

	cmp.w	(a1),d2
	beq.s	spf1

	exg	d0,a0
	move.l	a1,a0
	move.l	a2,a1
	move.l	a3,a2
	move.l	d0,a3
	bra.s	spf4

spf3	cmp.w	(a1),d2
	beq.s	spf1

	exg	d0,a3
	move.l	a2,a3
	move.l	a1,a2
	move.l	a0,a1
	move.l	d0,a0

spf4	move.b	#2,simple.poly.count
simple.poly.fill2
	move.l	#start.masks,a5
	move.w	(a0)+,d1
	move.w	(a3)+,d0
	cmp.w	d1,d0
	bne	spfe

	addq.l	#6,a0
	addq.l	#6,a3
	move.w	d1,fp.y
	subq.w	#1,d1
	bmi	spfe

	move.l	current.scene,a6
	moveq	#0,d0
	move.w	d1,d0
	asl.w	#2,d0
	add.w	d1,d0
	asl.w	#3,d0
	add.l	d0,a6

spf5	move.w	(a0)+,d4
	bpl.s	spf6

	subq.b	#1,simple.poly.count
	bmi	spfe

	move.l	a1,a0
	move.l	a2,a1
	move.w	(a0)+,d0
	cmp.w	fp.y,d0
	bne	spfe

	addq.l	#6,a0
	move.w	(a0)+,d4
	bpl.s	spf6

	subq.b	#1,simple.poly.count
	bmi	spfe

	move.l	a1,a0
	move.w	(a0)+,d0
	cmp.w	fp.y,d0
	bne	spfe

	addq.l	#6,a0
	move.w	(a0)+,d4
	bmi	spfe

spf6	move.w	(a3)+,d5
	bpl.s	spf7

	subq.b	#1,simple.poly.count
	bmi	spfe

	move.l	a2,a3
	move.l	a1,a2
	move.w	(a3)+,d0
	cmp.w	fp.y,d0
	bne	spfe

	addq.l	#6,a3
	move.w	(a3)+,d5
	bpl.s	spf7

	subq.b	#1,simple.poly.count
	bmi	spfe

	move.l	a2,a3
	move.w	(a3)+,d0
	cmp.w	fp.y,d0
	bne	spfe

	addq.l	#6,a3
	move.w	(a3)+,d5
	bmi	spfe

spf7	cmp.w	d4,d5
	bgt.s	spf8
	beq	spfd

	tst.b	daft.flag
	bpl.s	spfd
	bra	spfe

spf8	move.w	d4,d1
	and.w	#$f0,d1
	lsr.w	#3,d1
	lea	(a6,d1.w),a4
	move.w	d4,d3
	move.w	d5,d1
	lsr.w	#4,d3
	lsr.w	#4,d1
	sub.w	d3,d1
	bne.s	spf9

	and.w	#$f,d4
	asl.w	#2,d4
	move.w	(a5,d4.w),d4

	and.w	#$f,d5
	asl.w	#2,d5
	move.w	64(a5,d5.w),d5
	and.w	d5,d4
	bsr	fill.word
	bra.s	spfd

spf9	subq.b	#1,d1
	and.w	#$f,d4
	beq.s	spfa

	asl.w	#2,d4
	move.w	(a5,d4.w),d4
	bsr	fill.word
	subq.w	#1,d1
	bmi.s	spfc

spfa	move.l	d6,d2
	move.l	d7,d3
	swap	d2
	swap	d3

spfb	move.w	d2,(a4)+
	move.w	d6,7998(a4)
	move.w	d3,15998(a4)
	move.w	d7,23998(a4)
	dbra	d1,spfb

spfc	and.w	#$f,d5
	beq.s	spfd

	asl.w	#2,d5
	move.w	64(a5,d5.w),d4
	bsr	fill.word

spfd	subq.w	#1,fp.y
	lea	-40(a6),a6
	cmp.l	current.scene,a6
	bge	spf5

spfe	moveq	#0,d1
	moveq	#0,d2
	rts


start.masks
	dc.w	$ffff,$ffff,$7fff,$7fff,$3fff,$3fff,$1fff,$1fff
	dc.w	$0fff,$0fff,$07ff,$07ff,$03ff,$03ff,$01ff,$01ff
	dc.w	$00ff,$00ff,$007f,$007f,$003f,$003f,$001f,$001f
	dc.w	$000f,$000f,$0007,$0007,$0003,$0003,$0001,$0001

end.masks
	dc.w	$0000,$0000,$8000,$8000,$c000,$c000,$e000,$e000
	dc.w	$f000,$f000,$f800,$f800,$fc00,$fc00,$fe00,$fe00
	dc.w	$ff00,$ff00,$ff80,$ff80,$ffc0,$ffc0,$ffe0,$ffe0
	dc.w	$fff0,$fff0,$fff8,$fff8,$fffc,$fffc,$fffe,$fffe


simple.poly.count	dc.b	0,0
straight.edge.count	dc.w	0
straight.edge.value	dc.w	0
y.saved	dc.w	0

clip.line.make.edge
	move.l	#section.data,a1
	move.w	#0,y.saved
	move.w	#-1,straight.edge.count
	move.w	road.section.offset,d0
	move.l	drs.sub.ptr,a0
	cmp.l	#end.edge.space,a0
	blt.s	clme1

	tst.b	standard.clip.flag
	bmi.s	clme1

	move.l	#$80000000,(a1,d0.w)
	clr.w	d1
	clr.w	d2
	rts

clme1	move.l	a0,(a1,d0.w)
	move.l	a0,a2
	addq.l	#8,a0
	move.l	#x.values,a4
	move.l	#y.values,a5
	move.w	(a4,d1.w),d4
	move.w	(a4,d2.w),d6
	move.w	(a5,d1.w),d5
	move.w	(a5,d2.w),d7
	cmp.w	d7,d5
	bge.s	clme2

	exg	d7,d5
	exg	d6,d4
	or.b	#$40,(a1,d0.w)

clme2	move.w	#0,d0
	move.w	d0,d3
	cmp.w	#256,d4
	bcs.s	clme4
	tst.w	d4
	bpl.s	clme3
	bset	#3,d0
	bra.s	clme4

clme3	bset	#2,d0
clme4	cmp.w	#256,d6
	bcs.s	clme6
	tst.w	d6
	bpl.s	clme5
	bset	#3,d3
	bra.s	clme6

clme5	bset	#2,d3
clme6	cmp.w	#128,d5
	bcs.s	clme8
	tst.w	d5
	bpl.s	clme7
	bset	#1,d0
	bra.s	clme8

clme7	bset	#0,d0
clme8	cmp.w	#128,d7
	bcs.s	clmea
	tst.w	d7
	bpl.s	clme9
	bset	#1,d3
	bra.s	clmea

clme9	bset	#0,d3
clmea	move.b	d0,d1
	move.b	d3,d2
	swap	d0
	move.b	d1,d0
	or.b	d2,d0
	and.b	#$f,d0
	beq	clme55

	move.b	d1,d0
	and.b	d2,d0
	and.b	#$f,d0
	beq.s	clmeb

	bsr	edge.off.screen
	clr.w	d1
	clr.w	d2
	rts

clmeb	swap	d0
	btst	#1,d1
	beq.s	clme12
	bclr	#7,d1
	move.w	d6,d0
	sub.w	d4,d0
	bpl.s	clmec
	bset	#7,d1
	neg.w	d0

clmec	move.w	d7,d3
	sub.w	d5,d3
	bpl.s	clmed
	bchg	#7,d1
	neg.w	d3

clmed	neg.w	d5
	cmp.w	d0,d3
	blt.s	clmee
	beq.s	clme10
	swap	d0
	clr.w	d0
	divu	d3,d0
	mulu	d0,d5
	swap	d5
	bra.s	clme10

clmee	cmp.w	d3,d5
	blt.s	clmef
	move.w	d0,d5
	bra.s	clme10

clmef	swap	d5
	clr.w	d5
	divu	d3,d5
	mulu	d0,d5
	swap	d5

clme10	tst.b	d1
	bpl.s	clme11
	neg.w	d5

clme11	add.w	d5,d4
	move.w	#0,d5
	bra.s	clme19

clme12	btst	#0,d1
	beq	clme1d
	bclr	#7,d1
	move.w	d6,d0
	sub.w	d4,d0
	bpl.s	clme13
	bset	#7,d1
	neg.w	d0

clme13	move.w	d7,d3
	sub.w	d5,d3
	bpl.s	clme14
	bchg	#7,d1
	neg.w	d3

clme14	sub.w	#128,d5
	cmp.w	d0,d3
	blt.s	clme15
	beq.s	clme17
	swap	d0
	clr.w	d0
	divu	d3,d0
	mulu	d0,d5
	swap	d5
	bra.s	clme17

clme15	cmp.w	d3,d5
	blt.s	clme16
	move.w	d0,d5
	bra.s	clme17

clme16	swap	d5
	clr.w	d5
	divu	d3,d5
	mulu	d0,d5
	swap	d5

clme17	tst.b	d1
	bmi.s	clme18
	neg.w	d5

clme18	add.w	d5,d4
	move.w	#128,d5

clme19	and.b	#$f0,d1
	cmp.w	#256,d4
	bcs.s	clme1b
	tst.w	d4
	bpl.s	clme1a
	bset	#3,d1
	bra.s	clme1b

clme1a	bset	#2,d1

clme1b	swap	d0
	move.b	d1,d0
	or.b	d2,d0
	and.b	#$f,d0
	beq	clme55

	move.b	d1,d0
	and.b	d2,d0
	and.b	#$f,d0
	beq.s	clme1c

	bsr	edge.off.screen
	clr.w	d1
	clr.w	d2
	rts

clme1c	swap	d0
clme1d	btst	#1,d2
	beq.s	clme24
	bclr	#7,d1
	move.w	d6,d0
	sub.w	d4,d0
	bpl.s	clme1e
	bset	#7,d1
	neg.w	d0

clme1e	move.w	d7,d3
	sub.w	d5,d3
	bpl.s	clme1f
	bchg	#7,d1
	neg.w	d3

clme1f	neg.w	d7
	cmp.w	d0,d3
	blt.s	clme20
	beq.s	clme22
	swap	d0
	clr.w	d0
	divu	d3,d0
	mulu	d0,d7
	swap	d7
	bra.s	clme22

clme20	cmp.w	d3,d7
	blt.s	clme21
	move.w	d0,d7
	bra.s	clme22

clme21	swap	d7
	clr.w	d7
	divu	d3,d7
	mulu	d0,d7
	swap	d7

clme22	tst.b	d1
	bpl.s	clme23
	neg.w	d7

clme23	add.w	d7,d6
	move.w	#0,d7
	bra.s	clme2b

clme24	btst	#0,d2
	beq	clme2f
	bclr	#7,d1
	move.w	d6,d0
	sub.w	d4,d0
	bpl.s	clme25
	bset	#7,d1
	neg.w	d0

clme25	move.w	d7,d3
	sub.w	d5,d3
	bpl.s	clme26
	bchg	#7,d1
	neg.w	d3

clme26	sub.w	#128,d7
	cmp.w	d0,d3
	blt.s	clme27
	beq.s	clme29
	swap	d0
	clr.w	d0
	divu	d3,d0
	mulu	d0,d7
	swap	d7
	bra.s	clme29

clme27	cmp.w	d3,d7
	blt.s	clme28
	move.w	d0,d7
	bra.s	clme29

clme28	swap	d7
	clr.w	d7
	divu	d3,d7
	mulu	d0,d7
	swap	d7

clme29	tst.b	d1
	bmi.s	clme2a
	neg.w	d7

clme2a	add.w	d7,d6
	move.w	#128,d7

clme2b	and.b	#$f0,d2
	cmp.w	#256,d6
	bcs.s	clme2d
	tst.w	d6
	bpl.s	clme2c
	bset	#3,d2
	bra.s	clme2d

clme2c	bset	#2,d2

clme2d	swap	d0
	move.b	d1,d0
	or.b	d2,d0
	and.b	#$f,d0
	beq	clme55

	move.b	d1,d0
	and.b	d2,d0
	and.b	#$f,d0
	beq.s	clme2e

	bsr	edge.off.screen
	clr.w	d1
	clr.w	d2
	rts

clme2e	swap	d0
clme2f	move.w	d5,(a2)
	move.w	d7,2(a2)
	subq.b	#1,y.saved
	btst	#3,d1
	beq.s	clme3a
	move.w	d5,-(sp)
	bclr	#7,d1
	move.w	d6,d0
	sub.w	d4,d0
	bpl.s	clme30
	bset	#7,d1
	neg.w	d0

clme30	move.w	d7,d3
	sub.w	d5,d3
	bpl.s	clme31
	bchg	#7,d1
	neg.w	d3

clme31	neg.w	d4
	cmp.w	d3,d0
	blt.s	clme32
	beq.s	clme34
	swap	d3
	clr.w	d3
	divu	d0,d3
	mulu	d3,d4
	swap	d4
	bra.s	clme34

clme32	cmp.w	d0,d4
	blt.s	clme33
	move.w	d3,d4
	bra.s	clme34

clme33	swap	d4
	clr.w	d4
	divu	d0,d4
	mulu	d3,d4
	swap	d4

clme34	tst.b	d1
	bpl.s	clme35
	neg.w	d4

clme35	add.w	d4,d5
	move.w	#0,d4
	move.w	(sp)+,d3
	tst.b	standard.clip.flag
	bpl.s	clme36
	move.w	d5,d3
	move.w	d5,(a2)

clme36	sub.w	d5,d3
	bmi.s	clme39
	bra.s	clme38

clme37	move.w	#0,(a0)+
clme38	dbra	d3,clme37
clme39	bra.s	clme44

clme3a	btst	#2,d1
	beq.s	clme44
	move.w	d5,-(sp)
	bclr	#7,d1
	move.w	d6,d0
	sub.w	d4,d0
	bpl.s	clme3b
	bset	#7,d1
	neg.w	d0

clme3b	move.w	d7,d3
	sub.w	d5,d3
	bpl.s	clme3c
	bchg	#7,d1
	neg.w	d3

clme3c	sub.w	#256,d4
	cmp.w	d3,d0
	blt.s	clme3d
	beq.s	clme3f
	swap	d3
	clr.w	d3
	divu	d0,d3
	mulu	d3,d4
	swap	d4
	bra.s	clme3f

clme3d	cmp.w	d0,d4
	blt.s	clme3e
	move.w	d3,d4
	bra.s	clme3f

clme3e	swap	d4
	clr.w	d4
	divu	d0,d4
	mulu	d3,d4
	swap	d4

clme3f	tst.b	d1
	bmi.s	clme40
	neg.w	d4

clme40	add.w	d4,d5
	move.w	#256,d4
	move.w	(sp)+,d3
	tst.b	standard.clip.flag
	bpl.s	clme41
	move.w	d5,d3
	move.w	d5,(a2)

clme41	sub.w	d5,d3
	bmi.s	clme44
	bra.s	clme43

clme42	move.w	#256,(a0)+
clme43	dbra	d3,clme42

clme44	btst	#3,d2
	beq.s	clme4d
	move.w	d7,-(sp)
	bclr	#7,d1
	move.w	d6,d0
	sub.w	d4,d0
	bpl.s	clme45
	bset	#7,d1
	neg.w	d0

clme45	move.w	d7,d3
	sub.w	d5,d3
	bpl.s	clme46
	bchg	#7,d1
	neg.w	d3

clme46	neg.w	d6
	cmp.w	d3,d0
	blt.s	clme47
	beq.s	clme49
	swap	d3
	clr.w	d3
	divu	d0,d3
	mulu	d3,d6
	swap	d6
	bra.s	clme49

clme47	cmp.w	d0,d6
	blt.s	clme48
	move.w	d3,d6
	bra.s	clme49

clme48	swap	d6
	clr.w	d6
	divu	d0,d6
	mulu	d3,d6
	swap	d6

clme49	tst.b	d1
	bpl.s	clme4a
	neg.w	d6

clme4a	add.w	d6,d7
	move.w	#0,d6
	move.w	d7,d3
	sub.w	(sp)+,d3
	subq.w	#1,d3
	tst.b	standard.clip.flag
	bpl.s	clme4b
	move.w	d7,2(a2)
	bra.s	clme4c

clme4b	move.w	d3,straight.edge.count
	move.w	#0,straight.edge.value
clme4c	bra.s	clme55

clme4d	btst	#2,d2
	beq.s	clme55
	move.w	d7,-(sp)
	bclr	#7,d1
	move.w	d6,d0
	sub.w	d4,d0
	bpl.s	clme4e
	bset	#7,d1
	neg.w	d0

clme4e	move.w	d7,d3
	sub.w	d5,d3
	bpl.s	clme4f
	bchg	#7,d1
	neg.w	d3

clme4f	sub.w	#256,d6
	cmp.w	d3,d0
	blt.s	clme50
	beq.s	clme52
	swap	d3
	clr.w	d3
	divu	d0,d3
	mulu	d3,d6
	swap	d6
	bra.s	clme52

clme50	cmp.w	d0,d6
	blt.s	clme51
	move.w	d3,d6
	bra.s	clme52

clme51	swap	d6
	clr.w	d6
	divu	d0,d6
	mulu	d3,d6
	swap	d6

clme52	tst.b	d1
	bmi.s	clme53
	neg.w	d6

clme53	add.w	d6,d7
	move.w	#256,d6
	move.w	d7,d3
	sub.w	(sp)+,d3
	subq.w	#1,d3
	tst.b	standard.clip.flag
	bpl.s	clme54
	move.w	d7,2(a2)
	bra.s	clme55

clme54	move.w	d3,straight.edge.count
	move.w	#256,straight.edge.value

clme55	move.w	d5,d2
	sub.w	d7,d2
	move.w	d4,d1
	sub.w	d6,d1
	bpl	clme61
	neg.w	d1
	cmp.w	d2,d1
	blt.s	clme5b
	tst.w	y.saved
	bmi.s	clme56
	move.w	d5,(a2)
	move.w	d7,2(a2)

clme56	move.w	d4,4(a2)
	move.w	d6,6(a2)
	move.w	d1,d3
	lsr.w	#1,d3
	not.w	d3
	bra.s	clme58

clme57	addq.w	#1,d4
	add.w	d2,d3
	bcc.s	clme58
	sub.w	d1,d3
	subq.w	#1,d5
	move.w	d4,(a0)+

clme58	cmp.w	d6,d4
	bne.s	clme57
	move.w	straight.edge.count,d0
	bmi.s	clme5a

clme59	move.w	straight.edge.value,(a0)+
	dbra	d0,clme59

clme5a	move.w	#$8000,(a0)+
	move.l	a0,drs.sub.ptr
	clr.w	d1
	clr.w	d2
	rts

clme5b	tst.w	y.saved
	bmi.s	clme5c
	move.w	d5,(a2)
	move.w	d7,2(a2)

clme5c	move.w	d4,4(a2)
	move.w	d6,6(a2)
	move.w	d2,d3
	lsr.w	#1,d3
	not.w	d3
	bra.s	clme5e

clme5d	subq.w	#1,d5
	move.w	d4,(a0)+
	add.w	d1,d3
	bcc.s	clme5e
	sub.w	d2,d3
	addq.w	#1,d4

clme5e	cmp.w	d7,d5
	bne.s	clme5d
	move.w	straight.edge.count,d0
	bmi.s	clme60

clme5f	move.w	straight.edge.value,(a0)+
	dbra	d0,clme5f

clme60	move.w	#$8000,(a0)+
	move.l	a0,drs.sub.ptr
	clr.w	d1
	clr.w	d2
	rts

clme61	cmp.w	d2,d1
	blt.s	clme67
	tst.w	y.saved
	bmi.s	clme62
	move.w	d5,(a2)
	move.w	d7,2(a2)

clme62	move.w	d4,4(a2)
	move.w	d6,6(a2)
	move.w	d1,d3
	lsr.w	#1,d3
	not.w	d3
	bra.s	clme64

clme63	subq.w	#1,d4
	add.w	d2,d3
	bcc.s	clme64
	sub.w	d1,d3
	subq.w	#1,d5
	move.w	d4,(a0)+

clme64	cmp.w	d6,d4
	bne.s	clme63
	move.w	straight.edge.count,d0
	bmi.s	clme66

clme65	move.w	straight.edge.value,(a0)+
	dbra	d0,clme65

clme66	move.w	#$8000,(a0)+
	move.l	a0,drs.sub.ptr
	clr.w	d1
	clr.w	d2
	rts

clme67	tst.w	y.saved
	bmi.s	clme68
	move.w	d5,(a2)
	move.w	d7,2(a2)

clme68	move.w	d4,4(a2)
	move.w	d6,6(a2)
	move.w	d2,d3
	lsr.w	#1,d3
	not.w	d3
	bra.s	clme6a

clme69	subq.w	#1,d5
	move.w	d4,(a0)+
	add.w	d1,d3
	bcc.s	clme6a
	sub.w	d2,d3
	subq.w	#1,d4

clme6a	cmp.w	d7,d5
	bne.s	clme69
	move.w	straight.edge.count,d0
	bmi.s	clme6c

clme6b	move.w	straight.edge.value,(a0)+
	dbra	d0,clme6b

clme6c	move.w	#$8000,(a0)+
	move.l	a0,drs.sub.ptr
	clr.w	d1
	clr.w	d2
	rts


dw.sub.sub1
	move.l	#edge.space,a0
	move.l	#section.data,a1
	move.l	a1,a3
	move.l	#$80000000,d0
	move.l	d0,(a3)+
	move.l	d0,(a3)+
	move.l	d0,(a3)+
	move.l	d0,(a3)+
	move.l	d0,(a3)+
	move.l	d0,(a3)+
	move.l	d0,(a3)+
	move.b	#0,30(a1)
	move.l	a0,drs.sub.ptr
	move.w	#32,road.section.offset
	rts


pit.routine
	move.b	#$ff,B.1bb7c
	move.w	road.section.offset,d0
pit.routine1
	move.l	#section.data,a0
	sub.w	#32,d0
	cmp.w	#$ff00,W.63ede
	blt.s	pr1

	btst	#5,30(a1,d0.w)
	bne.s	pr1
	sub.w	#32,d0

pr1	and.w	#$ffe0,d0
	move.w	d0,W.1bc12
	rts


dw.subI	move.b	#$ff,d4
	move.b	B.1bba6,d0
	cmp.b	current.road.section,d0
	bne.s	dsI1

	move.b	W.1bc24,d4
	asl.b	#2,d4

dsI1	move.b	d4,B.1bb7c
	move.b	#0,B.1bc14
	move.w	#48,road.section.offset
	move.b	B.1bb60,d1
	beq	dsI9

	move.l	#DAT.1bdd0,a3
	move.w	d1,d0
	bra.s	dsI3

dsI2	move.b	#$80,(a3,d0.w)

dsI3	subq.w	#4,d0
	bpl.s	dsI2

	move.b	d1,d0
	lsr.b	#2,d0
	subq.b	#1,d0
	add.b	d0,B.1bb58
	bra.s	dsI9

dw.subI2
	move.l	#DAT.1bdd0,a3
	cmp.w	#47*32,road.section.offset
	bcc	dsI1f

	move.b	#$ff,d4
	move.b	B.1bba6,d0
	cmp.b	current.road.section,d0
	bne.s	dsI4

	move.b	W.1bc24,d4
	asl.b	#2,d4

dsI4	move.b	d4,B.1bb7c
	tst.b	B.1bb7c
	bne.s	dsI5
	bsr	pit.routine

dsI5	move.b	#0,B.1bc14
	move.w	#4,d1

dsI6	tst.w	(a6,d1.w)
	bpl.s	dsI9

dsI7	move.b	#$80,(a3,d1.w)
	cmp.b	B.1bb7c,d1
	bcs.s	dsI8
	bsr	pit.routine

dsI8	addq.b	#4,d1
	addq.b	#1,B.1bb58
	cmp.b	near.section.byte2.doubled,d1
	blt.s	dsI6
	rts

dsI9	move.b	B.1bc14,d2
	move.b	d1,B.1bbe4

	move.b	two.or.zero,d0
	asl.b	#1,d0
	eor.b	d1,d0
	and.b	#4,d0
	move.b	d0,B.69ad8

	move.l	#DAT.1bdd0,a3
	move.b	(a3,d1.w),B.69ada

	bsr	dw.subI.sub
	cmp.w	#48,road.section.offset
	beq	dsI12

	tst.w	(a6,d2.w)
	bmi.s	dsIa

	tst.w	(a6,d1.w)
	bmi.s	dsIa

	bsr	clip.line.make.edge
	move.b	B.1bbe4,d1
	move.b	B.1bc14,d2
	bra.s	dsIb

dsIa	move.w	road.section.offset,d0
	move.l	#section.data,a1
	move.l	#$80000000,(a1,d0.w)

dsIb	addq.w	#4,road.section.offset
	tst.w	2(a6,d2.w)
	bmi.s	dsIc

	tst.w	2(a6,d1.w)
	bmi.s	dsIc

	addq.b	#2,d2
	addq.b	#2,d1
	bsr	clip.line.make.edge
	move.b	B.1bbe4,d1
	move.b	B.1bc14,d2
	bra.s	dsId

dsIc	move.w	road.section.offset,d0
	move.l	#section.data,a1
	move.l	#$80000000,(a1,d0.w)

dsId	addq.w	#4,road.section.offset
	tst.w	120(a6,d2.w)
	bmi.s	dsIe

	tst.w	120(a6,d1.w)
	bmi.s	dsIe

	add.b	#120,d2
	add.b	#120,d1
	bsr	clip.line.make.edge
	move.b	B.1bbe4,d1
	move.b	B.1bc14,d2
	bra.s	dsIf

dsIe	move.w	road.section.offset,d0
	move.l	#section.data,a1
	move.l	#$80000000,(a1,d0.w)

dsIf	addq.w	#4,road.section.offset
	tst.w	122(a6,d2.w)
	bmi.s	dsI10

	tst.w	122(a6,d1.w)
	bmi.s	dsI10

	add.b	#122,d2
	add.b	#122,d1
	bsr	clip.line.make.edge
	move.b	B.1bbe4,d1
	move.b	B.1bc14,d2
	bra.s	dsI11

dsI10	move.w	road.section.offset,d0
	move.l	#section.data,a1
	move.l	#$80000000,(a1,d0.w)

dsI11	addq.w	#4,road.section.offset

dsI12	tst.b	B.69ad8
	beq.s	dsI13

	tst.b	B.69ada
	bpl.s	dsI13

	btst	#6,B.69ada
	bne.s	dsI13

	move.w	road.section.offset,d3
	move.l	#section.data,a1
	move.l	#$80000000,(a1,d3.w)
	move.l	#$80000000,4(a1,d3.w)
	addq.w	#8,road.section.offset
	bra.s	dsI18

dsI13	tst.w	120(a6,d1.w)
	bmi.s	dsI14

	tst.w	(a6,d1.w)
	bmi.s	dsI14

	move.b	d1,d2
	add.b	#120,d2
	bsr	clip.line.make.edge
	move.b	B.1bbe4,d1
	move.b	B.1bc14,d2
	bra.s	dsI15

dsI14	move.w	road.section.offset,d0
	move.l	#section.data,a1
	move.l	#$80000000,(a1,d0.w)

dsI15	addq.w	#4,road.section.offset
	tst.w	2(a6,d1.w)
	bmi.s	dsI16

	tst.w	122(a6,d1.w)
	bmi.s	dsI16

	move.b	d1,d2
	addq.b	#2,d2
	add.b	#122,d1
	bsr	clip.line.make.edge
	move.b	B.1bbe4,d1
	move.b	B.1bc14,d2
	bra.s	dsI17

dsI16	move.w	road.section.offset,d0
	move.l	#section.data,a1
	move.l	#$80000000,(a1,d0.w)

dsI17	addq.w	#4,road.section.offset

dsI18	tst.b	B.69ada
	bpl.s	dsI19

	move.w	road.section.offset,d3
	move.l	#section.data,a1
	move.l	#$80000000,(a1,d3.w)
	addq.w	#4,road.section.offset
	bra.s	dsI1c

dsI19	tst.w	(a6,d1.w)
	bmi.s	dsI1a

	tst.w	2(a6,d1.w)
	bmi.s	dsI1a

	move.b	d1,d2
	addq.b	#2,d1
	bsr	clip.line.make.edge
	move.b	B.1bbe4,d1
	move.b	B.1bc14,d2
	bra.s	dsI1b

dsI1a	move.w	road.section.offset,d0
	move.l	#section.data,a1
	move.l	#$80000000,(a1,d0.w)

dsI1b	addq.w	#4,road.section.offset

dsI1c	move.w	road.section.offset,d3
	move.b	current.road.section,(a1,d3.w)
	move.b	near.section.byte1,3(a1,d3.w)
	move.b	#9,d0
	cmp.b	#38,B.1bb58
	blt.s	dsI1d

	move.b	#10,d0
	cmp.b	#42,B.1bb58
	blt.s	dsI1d

	move.b	#11,d0
	cmp.b	#44,B.1bb58
	blt.s	dsI1d

	or.b	#$80,d0
	bra.s	dsI1e

dsI1d	tst.b	B.69ad8
	beq.s	dsI1e
	move.b	#3,d0

dsI1e	move.b	d0,1(a1,d3.w)
	move.b	B.69ada,2(a1,d3.w)
	addq.w	#4,road.section.offset
	move.l	#DAT.1bdd0,a3
	move.b	d1,B.1bc14
	cmp.w	#47*32,road.section.offset
	bcs	dsI7
dsI1f	rts


make.far.track.edges
	move.b	#0,B.1bb67
	move.l	#DAT.1be70,a6
	move.b	#0,d2
	move.b	#4,d1

mfte1	cmp.w	#47*32,road.section.offset
	bcc	mfte11

	move.b	d1,B.1bbe4
	move.b	d2,B.1bc14
	tst.w	(a6,d2.w)
	bmi.s	mfte2

	tst.w	(a6,d1.w)
	bmi.s	mfte2

	bsr	clip.line.make.edge
	move.b	B.1bbe4,d1
	move.b	B.1bc14,d2
	bra.s	mfte3

mfte2	move.w	road.section.offset,d0
	move.l	#section.data,a1
	move.l	#$80000000,(a1,d0.w)

mfte3	addq.w	#4,road.section.offset
	tst.w	2(a6,d2.w)
	bmi.s	mfte4

	tst.w	2(a6,d1.w)
	bmi.s	mfte4

	addq.b	#2,d2
	addq.b	#2,d1
	bsr	clip.line.make.edge
	move.b	B.1bbe4,d1
	move.b	B.1bc14,d2
	bra.s	mfte5

mfte4	move.w	road.section.offset,d0
	move.l	#section.data,a1
	move.l	#$80000000,(a1,d0.w)

mfte5	addq.w	#4,road.section.offset
	tst.w	120(a6,d2.w)
	bmi.s	mfte6

	tst.w	120(a6,d1.w)
	bmi.s	mfte6

	add.b	#120,d2
	add.b	#120,d1
	bsr	clip.line.make.edge
	move.b	B.1bbe4,d1
	move.b	B.1bc14,d2
	bra.s	mfte7

mfte6	move.w	road.section.offset,d0
	move.l	#section.data,a1
	move.l	#$80000000,(a1,d0.w)

mfte7	addq.w	#4,road.section.offset
	tst.w	122(a6,d2.w)
	bmi.s	mfte8

	tst.w	122(a6,d1.w)
	bmi.s	mfte8

	add.b	#122,d2
	add.b	#122,d1
	bsr	clip.line.make.edge
	move.b	B.1bbe4,d1
	move.b	B.1bc14,d2
	bra.s	mfte9

mfte8	move.w	road.section.offset,d0
	move.l	#section.data,a1
	move.l	#$80000000,(a1,d0.w)

mfte9	addq.w	#4,road.section.offset
	tst.w	120(a6,d1.w)
	bmi.s	mftea

	tst.w	(a6,d1.w)
	bmi.s	mftea

	move.b	d1,d2
	add.b	#120,d2
	bsr	clip.line.make.edge
	move.b	B.1bbe4,d1
	move.b	B.1bc14,d2
	bra.s	mfteb

mftea	move.w	road.section.offset,d0
	move.l	#section.data,a1
	move.l	#$80000000,0(a1,d0.w)

mfteb	addq.w	#4,road.section.offset
	tst.w	2(a6,d1.w)
	bmi.s	mftec

	tst.w	122(a6,d1.w)
	bmi.s	mftec

	move.b	d1,d2
	addq.b	#2,d2
	add.b	#122,d1
	bsr	clip.line.make.edge
	move.b	B.1bbe4,d1
	move.b	B.1bc14,d2
	bra.s	mfted

mftec	move.w	road.section.offset,d0
	move.l	#section.data,a1
	move.l	#$80000000,(a1,d0.w)

mfted	addq.w	#4,road.section.offset
	tst.w	(a6,d1.w)
	bmi.s	mftee

	tst.w	2(a6,d1.w)
	bmi.s	mftee

	move.b	d1,d2
	addq.b	#2,d1
	bsr	clip.line.make.edge
	move.b	B.1bbe4,d1
	move.b	B.1bc14,d2
	bra.s	mftef

mftee	move.w	road.section.offset,d0
	move.l	#section.data,a1
	move.l	#$80000000,(a1,d0.w)

mftef	addq.w	#4,road.section.offset
	move.l	#section.data,a0
	move.w	road.section.offset,d3
	move.l	#DAT.7ab5a,a3
	move.w	(a3,d1.w),road.height.value+2
	move.b	road.height.value+3,d0
	move.b	d0,(a0,d3.w)
	move.b	road.height.value+2,2(a0,d3.w)
	tst.b	B.1bb67
	bne.s	mfte10

	cmp.b	B.1bba6,d0
	bne.s	mfte10

	move.w	d3,d0
	addq.w	#4,d0
	bsr	pit.routine1
	move.b	#$80,B.1bb67

mfte10	addq.w	#4,road.section.offset
	move.b	d1,d2
	addq.b	#4,d1
	cmp.b	B.660fa,d1
	blt	mfte1
mfte11	rts


make.masks
	move.b	d0,d6
	asl.b	#4,d6
	addq.b	#2,d6
	move.b	d6,word.col+3

	moveq	#0,d6
	moveq	#0,d7
	lsr.b	#1,d0
	bcc.s	mask1.set4
	not.w	d6
mask1.set4
	swap	d6
	lsr.b	#1,d0
	bcc.s	mask2.set4
	not.w	d6
mask2.set4
	lsr.b	#1,d0
	bcc.s	mask3.set4
	not.w	d7
mask3.set4
	swap	d7
	lsr.b	#1,d0
	bcc.s	mask4.set4
	not.w	d7
mask4.set4
	rts


edge.off.screen
	move.w	road.section.offset,d3
	or.b	#$80,d0
	or.b	d0,(a1,d3.w)
	tst.w	d4
	bpl.s	eos1
	move.w	#0,d4

eos1	cmp.w	#256,d4
	blt.s	eos2
	move.w	#256,d4

eos2	tst.w	d6
	bpl.s	eos3
	move.w	#0,d6

eos3	cmp.w	#256,d6
	blt.s	eos4
	move.w	#256,d6

eos4	lsr.b	#1,d0
	bcc.s	eos5
	move.w	#128,(a2)
	move.w	#128,2(a2)
	move.w	d4,4(a2)
	move.w	d6,6(a2)
	move.w	#$8000,(a0)+
	move.l	a0,drs.sub.ptr
	rts

eos5	lsr.b	#1,d0
	bcc.s	eos6
	move.l	#0,(a2)
	move.w	d4,4(a2)
	move.w	d6,6(a2)
	move.w	#$8000,(a0)+
	move.l	a0,drs.sub.ptr
	rts

eos6	cmp.w	d7,d5
	bge.s	eos7
	exg	d7,d5

eos7	lsr.b	#1,d0
	bcc.s	eosf
	tst.w	d5
	bpl.s	eos8
	move.w	#0,d5

eos8	cmp.w	#128,d5
	bcs.s	eos9
	move.w	#128,d5

eos9	move.w	d5,(a2)
	tst.w	d7
	bpl.s	eosa
	move.w	#0,d7

eosa	cmp.w	#128,d7
	bcs.s	eosb
	move.w	#128,d7

eosb	move.w	d7,2(a2)
	move.w	d4,4(a2)
	move.w	d6,6(a2)
	move.w	#256,d3
	sub.w	d7,d5
	bpl.s	eosd
	bra.s	eose

eosc	move.w	d3,(a0)+
eosd	dbra	d5,eosc
eose	move.w	#$8000,(a0)+
	move.l	a0,drs.sub.ptr
	rts

eosf	lsr.b	#1,d0
	bcc.s	eos17
	tst.w	d5
	bpl.s	eos10
	move.w	#0,d5

eos10	cmp.w	#128,d5
	bcs.s	eos11
	move.w	#128,d5

eos11	move.w	d5,(a2)
	tst.w	d7
	bpl.s	eos12
	move.w	#0,d7

eos12	cmp.w	#128,d7
	bcs.s	eos13
	move.w	#128,d7

eos13	move.w	d7,2(a2)
	move.w	d4,4(a2)
	move.w	d6,6(a2)
	move.w	#0,d3
	sub.w	d7,d5
	bpl.s	eos15
	bra.s	eos16

eos14	move.w	d3,(a0)+
eos15	dbra	d5,eos14
eos16	move.w	#$8000,(a0)+
	move.l	a0,drs.sub.ptr
	rts
eos17	rts


draw.horizon
	move.w	#$500,d0
	move.w	d0,x.values+6
	neg.w	d0
	move.w	d0,x.values+4
	move.w	x.amount,d0
	asr.w	#3,d0
	neg.w	d0
	tst.b	unused.flag
	bmi.s	dh1
	subq.w	#8,d0

dh1	move.w	d0,y.values+4
	move.w	d0,y.values+6

	move.w	#4,d1
	bsr	z.rotate
	move.w	#6,d1
	bsr	z.rotate

	move.w	#0,road.section.offset
	move.w	#4,d1
	move.w	#6,d2
	move.b	#$80,standard.clip.flag
	bsr	clip.line.make.edge

	move.b	#0,standard.clip.flag
	move.l	drs.sub.ptr,a3
	move.l	a3,a4
	move.l	(a1),d0
	and.l	#$ffffff,d0
	beq	dh9

	move.l	d0,a0
	move.l	a0,a2
	move.w	(a2)+,d0
	move.w	d0,(a4)+
	move.w	d0,fp.y
	cmp.w	#129,d0
	bcc	dh9

	move.w	(a2)+,d3
	move.w	d3,fp.y2
	cmp.w	#129,d3
	bcc	dh9

	move.w	d3,(a4)+
	move.w	#256,d6
	move.w	y.values+6,d7
	sub.w	y.values+4,d7
	bpl.s	dh2
	move.w	#0,d6
	exg	a0,a3

dh2	move.w	d6,(a4)+
	move.w	d6,(a4)+
	sub.w	d3,d0
	bmi.s	dh4

dh3	move.w	d6,(a4)+
	dbra	d0,dh3

dh4	move.w	#$8000,(a4)+
	movem.l	a0-a2,-(sp)
	move.l	current.scene,a4
	move.w	fp.y2,d0
	asl.w	#2,d0
	add.w	fp.y2,d0
	asl.w	#3,d0
	lea	(a4,d0.w),a4
	move.w	#127,d4
	sub.w	fp.y2,d4
	bmi.s	dh6
	move.b	#13,d0
	bsr	make.masks
	bsr	convert.masks

dh5	lea	8000(a4),a0
	lea	16000(a4),a1
	lea	24000(a4),a2

	rept	8
	move.l	d6,(a4)+
	move.l	d1,(a0)+
	move.l	d7,(a1)+
	move.l	d2,(a2)+
	endr

	addq.l	#8,a4
	dbra	d4,dh5

dh6	move.b	#7,d0
	bsr	make.masks
	bsr.s	convert.masks
	move.w	fp.y2,d4
	subq.b	#1,d4
	bmi.s	dh8
	move.l	current.scene,a4

dh7	lea	8000(a4),a0
	lea	16000(a4),a1
	lea	24000(a4),a2

	rept	8
	move.l	d6,(a4)+
	move.l	d1,(a0)+
	move.l	d7,(a1)+
	move.l	d2,(a2)+
	endr

	addq.l	#8,a4
	dbra	d4,dh7

dh8	move.b	#0,simple.poly.count
	movem.l	(sp)+,a0-a2
	clr.w	d1
	clr.w	d2
	move.b	#7,d0
	bsr	make.masks
	bra	simple.poly.fill2
dh9	rts


convert.masks
	move.l	d6,d0
	move.l	d6,d1
	swap	d1
	move.w	d6,d1
	swap	d0
	move.w	d0,d6

	move.l	d7,d0
	move.l	d7,d2
	swap	d2
	move.w	d7,d2
	swap	d0
	move.w	d0,d7
	rts


draw.opponent
	tst.b	B.1bbb8
	bmi	end.draw.opponent

	move.w	W.1bc38,d0
	cmp.w	#10,d0
	bcs	end.draw.opponent

	cmp.w	#3200,d0
	bge	end.draw.opponent

	move.w	road.section.offset,-(sp)
	move.w	#47*32,road.section.offset
	bsr	make.opponent

	move.b	#$80,daft.flag
	move.w	#47*32,road.section.offset
	tst.b	B.1bbba
	bne	left.front.wheel

	cmp.w	#28,W.1bbec
	blt	left.front.wheel

	cmp.w	#228,W.1bbec
	bgt	left.front.wheel

	add.w	#128,road.section.offset

shadow	move.l	#section.data,a4
	move.w	road.section.offset,d3
	move.l	(a4,d3.w),d0
	move.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	no.shadow

	move.l	d0,a0
	move.l	4(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	no.shadow

	move.l	d0,a1
	move.l	8(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	no.shadow

	move.l	d0,a2
	move.l	12(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	no.shadow

	move.l	d0,a3
	and.l	#$f000000,d4
	bne.s	no.shadow

	move.b	#5,d0
	move.b	d0,d6
	asl.b	#4,d6
	addq.b	#2,d6
	move.b	d6,word.col+3

	moveq	#0,d6
	moveq	#0,d7
	lsr.b	#1,d0
	bcc.s	mask1.set5
	not.w	d6
mask1.set5
	swap	d6
	lsr.b	#1,d0
	bcc.s	mask2.set5
	not.w	d6
mask2.set5
	lsr.b	#1,d0
	bcc.s	mask3.set5
	not.w	d7
mask3.set5
	swap	d7
	lsr.b	#1,d0
	bcc.s	mask4.set5
	not.w	d7
mask4.set5
	bsr	simple.poly.fill

no.shadow
	sub.w	#128,road.section.offset

left.front.wheel
	move.l	#section.data,a4
	move.w	road.section.offset,d3
	move.l	96(a4,d3.w),d0
	move.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	right.front.wheel

	move.l	d0,a0
	move.l	100(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	right.front.wheel

	move.l	d0,a1
	move.l	104(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	right.front.wheel

	move.l	d0,a2
	move.l	108(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	right.front.wheel

	move.l	d0,a3
	and.l	#$f000000,d4
	bne.s	right.front.wheel

	move.b	#0,d0
	move.b	d0,d6
	asl.b	#4,d6
	addq.b	#2,d6
	move.b	d6,word.col+3

	moveq	#0,d6
	moveq	#0,d7
	lsr.b	#1,d0
	bcc.s	mask1.set6
	not.w	d6
mask1.set6
	swap	d6
	lsr.b	#1,d0
	bcc.s	mask2.set6
	not.w	d6
mask2.set6
	lsr.b	#1,d0
	bcc.s	mask3.set6
	not.w	d7
mask3.set6
	swap	d7
	lsr.b	#1,d0
	bcc.s	mask4.set6
	not.w	d7
mask4.set6
	bsr	simple.poly.fill

right.front.wheel
	move.l	#section.data,a4
	move.w	road.section.offset,d3
	move.l	112(a4,d3.w),d0
	move.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	left.body.panel

	move.l	d0,a0
	move.l	116(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	left.body.panel

	move.l	d0,a1
	move.l	120(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	left.body.panel

	move.l	d0,a2
	move.l	124(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	left.body.panel

	move.l	d0,a3
	and.l	#$f000000,d4
	bne.s	left.body.panel

	move.b	#0,d0
	move.b	d0,d6
	asl.b	#4,d6
	addq.b	#2,d6
	move.b	d6,word.col+3

	moveq	#0,d6
	moveq	#0,d7
	lsr.b	#1,d0
	bcc.s	mask1.set7
	not.w	d6
mask1.set7
	swap	d6
	lsr.b	#1,d0
	bcc.s	mask2.set7
	not.w	d6
mask2.set7
	lsr.b	#1,d0
	bcc.s	mask3.set7
	not.w	d7
mask3.set7
	swap	d7
	lsr.b	#1,d0
	bcc.s	mask4.set7
	not.w	d7
mask4.set7
	bsr	simple.poly.fill

left.body.panel
	move.l	#section.data,a4
	move.w	road.section.offset,d3
	move.l	32(a4,d3.w),d0
	move.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	right.body.panel

	move.l	d0,a0
	move.l	56(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	right.body.panel

	move.l	d0,a1
	move.l	16(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	right.body.panel

	move.l	d0,a2
	move.l	48(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	right.body.panel

	move.l	d0,a3
	and.l	#$f000000,d4
	bne.s	right.body.panel

	move.b	#12,d0
	move.b	d0,d6
	asl.b	#4,d6
	addq.b	#2,d6
	move.b	d6,word.col+3

	moveq	#0,d6
	moveq	#0,d7
	lsr.b	#1,d0
	bcc.s	mask1.set8
	not.w	d6
mask1.set8
	swap	d6
	lsr.b	#1,d0
	bcc.s	mask2.set8
	not.w	d6
mask2.set8
	lsr.b	#1,d0
	bcc.s	mask3.set8
	not.w	d7
mask3.set8
	swap	d7
	lsr.b	#1,d0
	bcc.s	mask4.set8
	not.w	d7
mask4.set8
	bsr	simple.poly.fill

right.body.panel
	move.l	#section.data,a4
	move.w	road.section.offset,d3
	move.l	24(a4,d3.w),d0
	move.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	rear.body.panel

	move.l	d0,a0
	move.l	60(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	rear.body.panel

	move.l	d0,a1
	move.l	40(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	rear.body.panel

	move.l	d0,a2
	move.l	52(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	rear.body.panel

	move.l	d0,a3
	and.l	#$f000000,d4
	bne.s	rear.body.panel

	move.b	#12,d0
	move.b	d0,d6
	asl.b	#4,d6
	addq.b	#2,d6
	move.b	d6,word.col+3

	moveq	#0,d6
	moveq	#0,d7
	lsr.b	#1,d0
	bcc.s	mask1.set9
	not.w	d6
mask1.set9
	swap	d6
	lsr.b	#1,d0
	bcc.s	mask2.set9
	not.w	d6
mask2.set9
	lsr.b	#1,d0
	bcc.s	mask3.set9
	not.w	d7
mask3.set9
	swap	d7
	lsr.b	#1,d0
	bcc.s	mask4.set9
	not.w	d7
mask4.set9
	bsr	simple.poly.fill

rear.body.panel
	move.l	#section.data,a4
	move.w	road.section.offset,d3
	move.l	16(a4,d3.w),d0
	move.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	top.body.panel

	move.l	d0,a0
	move.l	20(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	top.body.panel

	move.l	d0,a1
	move.l	24(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	top.body.panel

	move.l	d0,a2
	move.l	28(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	top.body.panel

	move.l	d0,a3
	and.l	#$f000000,d4
	bne.s	top.body.panel

	move.b	#10,d0
	move.b	d0,d6
	asl.b	#4,d6
	addq.b	#2,d6
	move.b	d6,word.col+3

	moveq	#0,d6
	moveq	#0,d7
	lsr.b	#1,d0
	bcc.s	mask1.setA
	not.w	d6
mask1.setA
	swap	d6
	lsr.b	#1,d0
	bcc.s	mask2.setA
	not.w	d6
mask2.setA
	lsr.b	#1,d0
	bcc.s	mask3.setA
	not.w	d7
mask3.setA
	swap	d7
	lsr.b	#1,d0
	bcc.s	mask4.setA
	not.w	d7
mask4.setA
	bsr	simple.poly.fill

top.body.panel
	move.l	#section.data,a4
	move.w	road.section.offset,d3
	move.l	56(a4,d3.w),d0
	move.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	bottom.body.panel

	move.l	d0,a0
	move.l	36(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	bottom.body.panel

	move.l	d0,a1
	move.l	60(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	bottom.body.panel

	move.l	d0,a2
	move.l	20(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	bottom.body.panel

	move.l	d0,a3
	and.l	#$f000000,d4
	bne.s	bottom.body.panel

	move.b	#15,d0
	move.b	d0,d6
	asl.b	#4,d6
	addq.b	#2,d6
	move.b	d6,word.col+3

	moveq	#0,d6
	moveq	#0,d7
	lsr.b	#1,d0
	bcc.s	mask1.setB
	not.w	d6
mask1.setB
	swap	d6
	lsr.b	#1,d0
	bcc.s	mask2.setB
	not.w	d6
mask2.setB
	lsr.b	#1,d0
	bcc.s	mask3.setB
	not.w	d7
mask3.setB
	swap	d7
	lsr.b	#1,d0
	bcc.s	mask4.setB
	not.w	d7
mask4.setB
	bsr	simple.poly.fill

bottom.body.panel
	move.l	#section.data,a4
	move.w	road.section.offset,d3
	move.l	48(a4,d3.w),d0
	move.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	left.rear.wheel

	move.l	d0,a0
	move.l	28(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	left.rear.wheel

	move.l	d0,a1
	move.l	52(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	left.rear.wheel

	move.l	d0,a2
	move.l	44(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	left.rear.wheel

	move.l	d0,a3
	and.l	#$f000000,d4
	bne.s	left.rear.wheel

	move.b	#9,d0
	move.b	d0,d6
	asl.b	#4,d6
	addq.b	#2,d6
	move.b	d6,word.col+3

	moveq	#0,d6
	moveq	#0,d7
	lsr.b	#1,d0
	bcc.s	mask1.setC
	not.w	d6
mask1.setC
	swap	d6
	lsr.b	#1,d0
	bcc.s	mask2.setC
	not.w	d6
mask2.setC
	lsr.b	#1,d0
	bcc.s	mask3.setC
	not.w	d7
mask3.setC
	swap	d7
	lsr.b	#1,d0
	bcc.s	mask4.setC
	not.w	d7
mask4.setC
	bsr	simple.poly.fill

left.rear.wheel
	move.l	#section.data,a4
	move.w	road.section.offset,d3
	move.l	64(a4,d3.w),d0
	move.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	right.rear.wheel

	move.l	d0,a0
	move.l	68(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	right.rear.wheel

	move.l	d0,a1
	move.l	72(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	right.rear.wheel

	move.l	d0,a2
	move.l	76(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	right.rear.wheel

	move.l	d0,a3
	and.l	#$f000000,d4
	bne.s	right.rear.wheel

	move.b	#0,d0
	move.b	d0,d6
	asl.b	#4,d6
	addq.b	#2,d6
	move.b	d6,word.col+3

	moveq	#0,d6
	moveq	#0,d7
	lsr.b	#1,d0
	bcc.s	mask1.setD
	not.w	d6
mask1.setD
	swap	d6
	lsr.b	#1,d0
	bcc.s	mask2.setD
	not.w	d6
mask2.setD
	lsr.b	#1,d0
	bcc.s	mask3.setD
	not.w	d7
mask3.setD
	swap	d7
	lsr.b	#1,d0
	bcc.s	mask4.setD
	not.w	d7
mask4.setD
	bsr	simple.poly.fill

right.rear.wheel
	move.l	#section.data,a4
	move.w	road.section.offset,d3
	move.l	80(a4,d3.w),d0
	move.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	no.right.rear.wheel

	move.l	d0,a0
	move.l	84(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	no.right.rear.wheel

	move.l	d0,a1
	move.l	88(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	no.right.rear.wheel

	move.l	d0,a2
	move.l	92(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	no.right.rear.wheel

	move.l	d0,a3
	and.l	#$f000000,d4
	bne.s	no.right.rear.wheel

	move.b	#0,d0
	move.b	d0,d6
	asl.b	#4,d6
	addq.b	#2,d6
	move.b	d6,word.col+3

	moveq	#0,d6
	moveq	#0,d7
	lsr.b	#1,d0
	bcc.s	mask1.setE
	not.w	d6
mask1.setE
	swap	d6
	lsr.b	#1,d0
	bcc.s	mask2.setE
	not.w	d6
mask2.setE
	lsr.b	#1,d0
	bcc.s	mask3.setE
	not.w	d7
mask3.setE
	swap	d7
	lsr.b	#1,d0
	bcc.s	mask4.setE
	not.w	d7
mask4.setE
	bsr	simple.poly.fill

no.right.rear.wheel
	move.b	#0,daft.flag
	move.w	(sp)+,road.section.offset
end.draw.opponent
	rts


drs.sub.ptr	dc.l	0
road.section.offset	dc.w	0


drs.sub	cmp.w	d2,d1
	bge.s	drs.sub1
	exg	d1,d2

drs.sub1
	move.l	drs.sub.ptr,a0
	cmp.l	#end.edge.space,a0
	bgt.s	drs.sub6

	cmp.w	#129,d2
	bcc.s	drs.sub6

	cmp.w	#129,d1
	bcc.s	drs.sub6

	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	sub.w	d2,d1
	bra.s	drs.sub3

drs.sub2
	move.w	d0,(a0)+
drs.sub3
	dbra	d1,drs.sub2

	move.w	#$8000,(a0)+
	tst.b	clip.flag1
	bmi.s	drs.sub4

	move.l	drs.sub.ptr,(a1)+
	bra.s	drs.sub5

drs.sub4
	move.l	drs.sub.ptr,-(a2)

drs.sub5
	move.l	a0,drs.sub.ptr
	move.w	#0,d1
	move.w	d1,d2
	rts

drs.sub6
	move.w	#1,d1
	move.w	d1,d2
	rts


get.coord.pair
	btst	#6,d0
	beq.s	get.end.pair

	move.w	(a5),d7
	move.w	4(a5),d6
	rts

get.end.pair
	move.w	2(a5),d7
	move.w	6(a5),d6
	rts


clip.word	dc.w	0


clip.closest.section
	move.b	#0,closest.section.flag
	move.b	#0,clip.flag1
	bsr	clip.sub
	tst.b	clip.flag2
	bpl.s	ccs7

	tst.b	clip.flag4
	beq.s	ccs5

	move.b	clip.flag,d1
	beq.s	ccs6

	move.b	clip.flag4,d3
	eor.b	d3,d1
	bne.s	ccs6

	move.w	clip.value,d3
	bpl.s	ccs1
	neg.w	d3

ccs1	cmp.w	#197,d3
	blt.s	ccs6

	cmp.w	#576,d3
	bge.s	ccs6

	tst.b	clip.flag4
	bmi.s	ccs3

	tst.w	d7
	beq.s	ccs2

	tst.w	d6
	bne.s	ccs6

	cmp.w	#64,d7
	bge.s	ccs6

ccs2	cmp.w	d7,d5
	ble.s	ccs6
	bra.s	ccs7

ccs3	tst.w	d5
	beq.s	ccs4

	cmp.w	#256,d0
	bne.s	ccs6

	cmp.w	#64,d5
	bge.s	ccs6

ccs4	cmp.w	d5,d7
	ble.s	ccs6
	bra.s	ccs7

ccs5	tst.b	clip.flag
	beq.s	ccs7

ccs6	tst.b	clip.flag2
	bpl.s	ccs7

	exg	d0,d6
	exg	d5,d7
	move.b	#$80,clip.flag1
ccs7
ccs8	move.w	d0,clip.word
	move.b	#0,clip.flag3
	cmp.w	#256,d0
	beq.s	ccsa

	cmp.w	#0,d0
	beq.s	ccsc

	cmp.w	#128,d5
	beq.s	ccsb

	cmp.w	#0,d5
	beq.s	ccsd
	bra.s	end.clip

ccs9	addq.b	#1,clip.flag3
ccsa	bsr.s	clip.sub1
	bcc.s	end.clip2

ccsb	bsr	clip.sub3
	bcc.s	end.clip2

ccsc	bsr.s	clip.sub2
	bcc.s	end.clip2

ccsd	bsr	clip.sub4
	bcc.s	end.clip2

	cmp.b	#2,clip.flag3
	blt.s	ccs9

end.clip
	move.b	#$80,closest.section.flag
end.clip2
	rts


clip.sub1
	cmp.w	#256,d6
	beq.s	cs12

cs11	move.w	#256,d0
	move.w	d5,d1
	move.w	#128,d2
	bsr	drs.sub
	bne.s	end.clip

	move.w	#128,d5
	or.b	#1,ccr
	rts

cs12	cmp.w	d7,d5
	bgt.s	cs11

	move.w	#256,d0
	move.w	d5,d1
	move.w	d7,d2
	bsr	drs.sub
	bne.s	end.clip

	and.b	#%11110,ccr
	rts


clip.sub2
	cmp.w	#0,d6
	beq.s	cs22

cs21	move.w	#0,d0
	move.w	d5,d1
	move.w	#0,d2
	bsr	drs.sub
	bne.s	end.clip

	move.w	#0,d5
	or.b	#1,ccr
	rts

cs22	cmp.w	d7,d5
	blt.s	cs21

	move.w	#0,d0
	move.w	d5,d1
	move.w	d7,d2
	bsr	drs.sub
	bne.s	end.clip

	and.b	#%11110,ccr
	rts


clip.sub3
	cmp.w	#128,d7
	beq.s	cs32

cs31	move.w	#0,clip.word
	or.b	#1,ccr
	rts

cs32	move.w	clip.word,d0
	cmp.w	d6,d0
	blt.s	cs31

	and.b	#%11110,ccr
	rts


clip.sub4
	cmp.w	#0,d7
	beq.s	cs42

cs41	move.w	#256,clip.word
	or.b	#1,ccr
	rts

cs42	move.w	clip.word,d0
	cmp.w	d6,d0
	bgt.s	cs41

	and.b	#%11110,ccr
	rts


clip.sub
	move.w	d0,d1
	move.w	d5,d2
	bsr.s	clip.sub5
	move.w	d3,-(sp)
	move.w	d6,d1
	move.w	d7,d2
	bsr.s	clip.sub5
	sub.w	(sp)+,d3
	bpl.s	cs1

	neg.w	d3
	cmp.w	#384,d3
	blt.s	cs2
	bra.s	cs3

cs1	cmp.w	#384,d3
	blt.s	cs3

cs2	move.b	#$80,clip.flag2
	rts

cs3	move.b	#0,clip.flag2
	rts


clip.sub5
	move.w	#0,d3
	cmp.w	#0,d2
	bne.s	cs51

	move.w	d1,d3
	bra.s	cs54

cs51	add.w	#256,d3
	cmp.w	#256,d1
	bne.s	cs52

	add.w	d2,d3
	bra.s	cs54

cs52	add.w	#128,d3
	cmp.w	#128,d2
	bne.s	cs53

	add.w	#256,d3
	sub.w	d1,d3
	bra.s	cs54

cs53	add.w	#256,d3
	add.w	#128,d3
	sub.w	d2,d3

cs54	clr.w	d1
	clr.w	d2
	rts


dw.subF.sub4
	move.l	#x.values,a0
	move.w	(a0,d1.w),d0
	bpl.s	dsFs41
	neg.w	d0

dsFs41	cmp.w	#$c00,d0
	bge.s	dsFs42

	and.b	#%11110,ccr
	rts

dsFs42	move.w	#$8000,(a6,d1.w)
	or.b	#1,ccr
	rts


clip.flag1	dc.b	0
clip.flag2	dc.b	0
clip.flag3	dc.b	0
clip.flag4	dc.b	0


fp0	move.w	bottom.ptrs.offset,d2
	move.l	#bottom.ptrs,a4
fp1	move.w	(a4,d2.w),d0
	bpl.s	fp3

fp2	sub.w	#10,d2
	bpl.s	fp1

	move.w	#$8000,d0
	rts

fp3	cmp.l	a2,a1
	bgt.s	fp4

	cmp.l	2(a4,d2.w),a1
	bgt.s	fp2

	cmp.l	2(a4,d2.w),a2
	blt.s	fp2
	bra.s	fp5

fp4	cmp.l	2(a4,d2.w),a1
	blt.s	fp5

	cmp.l	2(a4,d2.w),a2
	blt.s	fp2

fp5	move.w	d2,d1
fp6	sub.w	#10,d2
	bmi.s	fp9

	cmp.w	(a4,d2.w),d0
	bge.s	fp6

	cmp.l	a2,a1
	bgt.s	fp7

	cmp.l	2(a4,d2.w),a1
	bgt.s	fp6

	cmp.l	2(a4,d2.w),a2
	blt.s	fp6
	bra.s	fp8

fp7	cmp.l	2(a4,d2.w),a1
	blt.s	fp8

	cmp.l	2(a4,d2.w),a2
	blt.s	fp6

fp8	move.w	d2,d1
	move.w	(a4,d1.w),d0
	bra.s	fp6

fp9	move.w	#$8000,(a4,d1.w)
	rts


fill.polygon
	move.b	#0,fp.level
	move.l	a1,fp.end
	move.l	a2,fp.start
	sub.l	a2,a1
	move.l	a1,fp.diff
	beq	fp2b

	move.w	#0,d7
	move.b	start.line.flag,d6
	and.b	#$40,d6
	eor.b	#$40,d6
	move.l	#bottom.ptrs,a4
	move.l	#section.side.ptrs,a0
	move.l	(a0)+,a5
	move.l	a0,a3
	bra.s	fpf

fpa	move.l	a0,a3
	move.l	(a0)+,a5
	move.w	(a5),d0
	cmp.w	2(a5),d0
	bne.s	fpb

	cmp.l	#section.side.ptrs,a3
	bne.s	fpf

	btst	#6,start.line.flag
	bne.s	fpc
	bra.s	fpf

fpb	cmp.w	d4,d0
	beq.s	fpc

	cmp.w	2(a5),d3
	bne.s	fpd

	move.b	#$40,d6
	bra.s	fpf

fpc	tst.b	d6
	bne.s	fpd

	move.b	#0,d6
	bra.s	fpf

fpd	eor.b	#$40,d6
	bne.s	fpf

	move.l	a3,6(a4,d7.w)
	move.l	a0,d2
	subq.l	#8,d2
	cmp.l	fp.start,d2
	bge.s	fpe

	add.l	fp.diff,d2

fpe	move.l	d2,2(a4,d7.w)
	move.w	d0,(a4,d7.w)
	add.w	#10,d7

fpf	move.w	(a5),d3
	move.w	2(a5),d4
	cmp.l	fp.end,a0
	bne.s	fp10

	sub.l	fp.diff,a0

fp10	cmp.l	#section.side.ptrs,a3
	bne.s	fpa

	sub.w	#10,d7
	beq.s	fp14
	bmi	fp2c

	move.w	d7,bottom.ptrs.offset
	move.w	bottom.ptrs.offset,d2
	move.w	(a4,d2.w),d0
	move.w	d2,d1
	bra.s	fp12

fp11	cmp.w	(a4,d2.w),d0
	bge.s	fp12

	move.w	(a4,d2.w),d0
	move.w	d2,d1

fp12	sub.w	#10,d2
	bpl.s	fp11

	move.w	#$8000,(a4,d1.w)
	move.l	6(a4,d1.w),a1
	move.l	2(a4,d1.w),a2
	bsr	fp0
	move.w	d0,fp.y.flag
	bmi.s	fp13

	move.l	6(a4,d1.w),fp.ptr1
	move.l	2(a4,d1.w),fp.ptr2
fp13	bra.s	fp15

fp14	move.w	#$8000,fp.y.flag
	move.l	6(a4),a1
	move.l	2(a4),a2

fp15	move.l	(a1),a0
	move.l	(a2),a3

	move.b	fp.colour,d0
	move.b	d0,d6
	asl.b	#4,d6
	addq.b	#2,d6
	move.b	d6,word.col+3

	moveq	#0,d6
	moveq	#0,d7
	lsr.b	#1,d0
	bcc.s	mask1.set
	not.w	d6
mask1.set
	swap	d6
	lsr.b	#1,d0
	bcc.s	mask2.set
	not.w	d6
mask2.set
	lsr.b	#1,d0
	bcc.s	mask3.set
	not.w	d7
mask3.set
	swap	d7
	lsr.b	#1,d0
	bcc.s	mask4.set
	not.w	d7
mask4.set
	move.l	#start.masks,a5

	move.w	(a0)+,d1
	move.w	(a3)+,d0
	cmp.w	d1,d0
	bne	fp2c

	addq.l	#6,a0
	addq.l	#6,a3
	move.w	d1,fp.y
	subq.w	#1,d1
	cmp.w	#128,d1
	bcc	fp2c

	move.l	current.scene,a6
	moveq	#0,d0
	move.w	d1,d0
	asl.w	#2,d0
	add.w	d1,d0
	asl.w	#3,d0
	add.l	d0,a6

fp1a	move.w	fp.y,d0
	cmp.w	fp.y.flag,d0
	bne.s	fp1c

	move.w	fp.y,-(sp)
	move.l	a6,-(sp)
	move.l	a3,-(sp)
	move.l	a2,-(sp)
	move.l	fp.ptr1,-(sp)
	addq.b	#1,fp.level
	move.l	fp.ptr2,a2
	move.l	(a2),a3
	addq.l	#8,a3
	bsr	fp0
	move.w	d0,fp.y.flag
	bmi.s	fp1b

	move.l	6(a4,d1.w),fp.ptr1
	move.l	2(a4,d1.w),fp.ptr2
fp1b	bra.s	fp1a

fp1c	move.w	(a0)+,d4
	bpl.s	fp1f

fp1d	addq.l	#4,a1
	cmp.l	fp.end,a1
	blt.s	fp1e

	sub.l	fp.diff,a1

fp1e	cmp.l	a2,a1
	beq	fp29

	move.l	(a1),a0
	move.w	(a0)+,d4
	cmp.w	fp.y,d4
	bne	fp2c

	addq.l	#6,a0
	move.w	(a0)+,d4
	bmi.s	fp1d

fp1f	move.w	(a3)+,d5
	bpl.s	fp22

fp20	cmp.l	fp.start,a2
	bne.s	fp21

	add.l	fp.diff,a2

fp21	move.l	-(a2),a3
	cmp.l	a1,a2
	beq	fp29

	move.w	(a3)+,d5
	cmp.w	fp.y,d5
	bne	fp2c

	addq.l	#6,a3
	move.w	(a3)+,d5
	bmi.s	fp20

fp22	cmp.w	d4,d5
	bgt.s	fp23
	beq.s	fp28

	tst.b	daft.flag
	bpl.s	fp28
	bra.s	fp28

fp23	move.w	d4,d1
	and.w	#$f0,d1
	lsr.w	#3,d1
	lea	(a6,d1.w),a4
	move.w	d4,d3
	move.w	d5,d1
	lsr.w	#4,d3
	lsr.w	#4,d1
	sub.w	d3,d1
	bne.s	fp24

	and.w	#$f,d4
	asl.w	#2,d4
	move.w	(a5,d4.w),d4

	and.w	#$f,d5
	asl.w	#2,d5
	move.w	64(a5,d5.w),d5
	and.w	d5,d4
	bsr	fill.word
	bra.s	fp28

fp24	subq.b	#1,d1
	and.w	#$f,d4
	beq.s	fp25

	asl.w	#2,d4
	move.w	(a5,d4.w),d4
	bsr	fill.word
	subq.w	#1,d1
	bmi.s	fp27

fp25	move.l	d6,d2
	move.l	d7,d3
	swap	d2
	swap	d3

fp26	move.w	d2,(a4)+
	move.w	d6,7998(a4)
	move.w	d3,15998(a4)
	move.w	d7,23998(a4)
	dbra	d1,fp26

fp27	and.w	#$f,d5
	beq.s	fp28

	asl.w	#2,d5
	move.w	64(a5,d5.w),d4
	bsr	fill.word

fp28	subq.w	#1,fp.y
	lea	-40(a6),a6
	cmp.l	current.scene,a6
	bge	fp1a

fp29	tst.b	fp.level
	beq.s	fp2b

	move.l	(sp)+,a1
	move.l	(sp)+,a2
	move.l	(sp)+,a3
	move.l	(sp)+,a6
	move.w	(sp)+,fp.y
	subq.b	#1,fp.level
	move.l	(a1),a0
	addq.l	#8,a0
	bsr	fp0
	move.w	d0,fp.y.flag
	bmi.s	fp2a

	move.l	6(a4,d1.w),fp.ptr1
	move.l	2(a4,d1.w),fp.ptr2
fp2a	bra	fp1a

fp2b	moveq	#0,d1
	moveq	#0,d2
	rts

fp2c	tst.b	fp.level
	beq.s	fp2b

	move.l	(sp)+,a1
	move.l	(sp)+,a2
	move.l	(sp)+,a3
	move.l	(sp)+,a6
	move.w	(sp)+,fp.y
	subq.b	#1,fp.level
	move.l	(a1),a0
	addq.l	#8,a0
	bra.s	fp2c


draw.start.line
	move.l	#section.data,a4
	move.w	road.section.offset,d3
	move.b	#15,d0
	bsr	set.pixel.colour
	move.l	24(a4,d3.w),d0
	and.l	#$ffffff,d0
	beq.s	done.start.line
	move.l	d0,a3
	bsr	plot.line
done.start.line
	rts


draw.left.side.lines
	move.l	#section.data,a4
	move.w	road.section.offset,d3
	bra.s	dlsl3

dlsl1	move.b	29(a4,d3.w),d0
	bmi.s	dlsl2

	cmp.b	#3,d0
	beq.s	dlsl2

	move.b	side.lines.colour,d0
	bsr	set.pixel.colour
	move.l	16(a4,d3.w),d0
	and.l	#$ffffff,d0
	beq.s	dlsl2

	move.l	d0,a3
	bsr	plot.line
dlsl2	sub.w	#32,d3
dlsl3	cmp.w	next.road.section.offset,d3
	bne.s	dlsl1
	rts


draw.right.side.lines
	move.l	#section.data,a4
	move.w	road.section.offset,d3
	bra.s	drsl3

drsl1	move.b	29(a4,d3.w),d0
	bmi.s	drsl2

	cmp.b	#3,d0
	beq.s	drsl2

	move.b	side.lines.colour,d0
	bsr	set.pixel.colour
	move.l	20(a4,d3.w),d0
	and.l	#$ffffff,d0
	beq.s	drsl2

	move.l	d0,a3
	bsr	plot.line
drsl2	sub.w	#32,d3
drsl3	cmp.w	next.road.section.offset,d3
	bne.s	drsl1
	rts


draw.left.road.lines
	move.l	#section.data,a4
	move.w	road.section.offset,d3
	bra.s	dlrl3

dlrl1	move.b	29(a4,d3.w),d0
	bmi.s	dlrl2

	bsr	set.pixel.colour
	move.l	(a4,d3.w),d0
	and.l	#$ffffff,d0
	beq.s	dlrl2

	move.l	d0,a3
	bsr	plot.line
dlrl2	sub.w	#32,d3
dlrl3	cmp.w	next.road.section.offset,d3
	bne.s	dlrl1
	rts


draw.right.road.lines
	move.l	#section.data,a4
	move.w	road.section.offset,d3
	bra.s	drrl3

drrl1	move.b	29(a4,d3.w),d0
	bmi.s	drrl2

	bsr	set.pixel.colour
	move.l	4(a4,d3.w),d0
	and.l	#$ffffff,d0
	beq.s	drrl2

	move.l	d0,a3
	bsr	plot.line
drrl2	sub.w	#32,d3
drrl3	cmp.w	next.road.section.offset,d3
	bne.s	drrl1
	rts


draw.near.left.sides
	move.b	#$80,clip.flag4
	move.l	#section.data,a4
	move.w	road.section.offset,d3
dnls1	move.w	d3,copy.road.section.offset
	move.l	16(a4,d3.w),d0
	move.l	d0,d4
	and.l	#$ffffff,d0
	bne.s	dnls3

dnls2	sub.w	#32,d3
	cmp.w	next.road.section.offset,d3
	ble	dnlse

	move.l	16(a4,d3.w),d0
	and.l	#$ffffff,d0
	beq.s	dnls2
	bra.s	dnls1

dnls3	move.l	#section.side.ptrs,a1
	move.l	a1,a2
	move.b	#15,d5
	btst	#0,28(a4,d3.w)
	beq.s	dnls4
	move.b	sides.colour,d5

dnls4	tst.b	use.lines.colour
	beq.s	dnls5
	move.b	side.lines.colour,d5

dnls5	move.b	d5,fp.colour
	move.l	d0,(a1)+
	move.b	16(a4,d3.w),d0
	move.b	d0,start.line.flag
	move.b	d0,left.side.flag
	eor.b	#$40,d0
	move.b	d0,right.side.flag
	cmp.w	#32,copy.road.section.offset
	beq.s	dnlsa

dnls6	move.l	(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	dnls8

	move.b	(a4,d3.w),right.side.flag
	move.l	d0,(a1)+

	move.l	8(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	dnls7

	move.b	8(a4,d3.w),left.side.flag
	move.l	d0,-(a2)

	sub.w	#32,d3
	cmp.w	next.road.section.offset,d3
	beq.s	dnls9

	cmp.w	#32,d3
	bne.s	dnls6
	bra.s	dnlsa

dnls7	subq.l	#4,a1

dnls8	cmp.w	road.section.offset,d3
	beq.s	dnlse

dnls9	move.l	16(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	dnlse

	move.b	16(a4,d3.w),right.side.flag
	move.l	d0,(a1)+
	bra.s	dnlsd


dnlsa	move.l	(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	dnlsb

	move.b	(a4,d3.w),right.side.flag
	move.l	d0,(a1)+

dnlsb	move.l	-4(a1),a5
	move.b	right.side.flag,d0
	bsr	get.coord.pair
	move.w	d6,-(sp)
	move.w	d7,d5

	move.l	8(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	dnlsc

	move.b	8(a4,d3.w),left.side.flag
	move.l	d0,-(a2)

dnlsc	move.l	(a2),a5
	move.b	left.side.flag,d0
	bsr	get.coord.pair
	move.w	(sp)+,d0

	bsr	clip.closest.section

	tst.b	closest.section.flag
	bmi.s	dnlse

dnlsd	and.l	#$f000000,d4
	bne.s	dnlse

	bsr	fill.polygon
dnlse	rts


draw.near.right.sides
	move.b	#2,clip.flag4
	move.l	#section.data,a4
	move.w	road.section.offset,d3
dnrsf	move.w	d3,copy.road.section.offset
	move.l	20(a4,d3.w),d0
	move.l	d0,d4
	and.l	#$ffffff,d0
	bne.s	dnrs11

dnrs10	sub.w	#32,d3
	cmp.w	next.road.section.offset,d3
	ble	dnrs1c

	move.l	20(a4,d3.w),d0
	and.l	#$ffffff,d0
	beq.s	dnrs10
	bra.s	dnrsf

dnrs11	move.l	#section.side.ptrs,a1
	move.l	a1,a2
	move.b	#15,d5
	btst	#0,28(a4,d3.w)
	beq.s	dnrs12
	move.b	sides.colour,d5

dnrs12	tst.b	use.lines.colour
	beq.s	dnrs13
	move.b	side.lines.colour,d5

dnrs13	move.b	d5,fp.colour
	move.l	d0,(a1)+
	move.b	20(a4,d3.w),d0
	move.b	d0,start.line.flag
	move.b	d0,left.side.flag
	eor.b	#$40,d0
	move.b	d0,right.side.flag
	cmp.w	#32,copy.road.section.offset
	beq.s	dnrs18

dnrs14	move.l	12(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	dnrs16

	move.b	12(a4,d3.w),right.side.flag
	move.l	d0,(a1)+

	move.l	4(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	dnrs15

	move.b	4(a4,d3.w),left.side.flag
	move.l	d0,-(a2)

	sub.w	#32,d3
	cmp.w	next.road.section.offset,d3
	beq.s	dnrs17

	cmp.w	#32,d3
	bne.s	dnrs14
	bra.s	dnrs18

dnrs15	subq.l	#4,a1

dnrs16	cmp.w	road.section.offset,d3
	beq.s	dnrs1c

dnrs17	move.l	20(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	dnrs1c

	move.b	20(a4,d3.w),right.side.flag
	move.l	d0,(a1)+
	bra.s	dnrs1b


dnrs18	move.l	12(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	dnrs19

	move.b	12(a4,d3.w),right.side.flag
	move.l	d0,(a1)+

dnrs19	move.l	-4(a1),a5
	move.b	right.side.flag,d0
	bsr	get.coord.pair
	move.w	d6,-(sp)
	move.w	d7,d5

	move.l	4(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	dnrs1a

	move.b	4(a4,d3.w),left.side.flag
	move.l	d0,-(a2)

dnrs1a	move.l	(a2),a5
	move.b	left.side.flag,d0
	bsr	get.coord.pair
	move.w	(sp)+,d0

	bsr	clip.closest.section

	tst.b	closest.section.flag
	bmi.s	dnrs1c

dnrs1b	and.l	#$f000000,d4
	bne.s	dnrs1c

	bsr	fill.polygon
dnrs1c	rts


draw.road.surface
	move.b	#0,clip.flag4
	move.b	#0,section.flags2
	move.b	#$80,drs.flag
	move.l	#section.data,a4
	move.w	road.section.offset,d3
	move.w	d3,copy.road.section.offset

	move.l	24(a4,d3.w),d0
	move.l	d0,d4
	and.l	#$ffffff,d0
	beq	surface.done

	move.l	#section.side.ptrs,a1
	move.l	a1,a2
	move.b	#1,d5
	btst	#0,28(a4,d3.w)
	beq.s	drs.col1
	move.b	#2,d5

drs.col1
	move.b	30(a4,d3.w),section.flags2
	btst	#5,section.flags2
	beq.s	drs.col.set
	move.b	#0,d5

drs.col.set
	move.b	d5,fp.colour

	move.l	d0,(a1)+

	move.b	24(a4,d3.w),d0
	move.b	d0,start.line.flag

	move.b	d0,left.side.flag
	eor.b	#$40,d0
	move.b	d0,right.side.flag

	cmp.w	#32,copy.road.section.offset
	beq.s	closest.section

save.right.left.sides
	move.l	4(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	no.right.side

	move.b	4(a4,d3.w),right.side.flag
	move.l	d0,(a1)+

	move.l	(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	no.left.side

	move.b	(a4,d3.w),left.side.flag
	move.l	d0,-(a2)

	sub.w	#32,d3
	cmp.w	next.road.section.offset,d3
	beq.s	save.next.start.line

	cmp.w	#32,d3
	bne.s	save.right.left.sides
	bra.s	closest.section

no.left.side
	subq.l	#4,a1

no.right.side
	cmp.w	road.section.offset,d3
	beq.s	surface.done

save.next.start.line
	move.l	24(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	surface.done

	move.b	24(a4,d3.w),right.side.flag
	move.l	d0,(a1)+
	bra.s	now.draw.surface


closest.section
	move.l	4(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	no.closest.right.side

	move.b	4(a4,d3.w),right.side.flag
	move.l	d0,(a1)+

no.closest.right.side
	move.l	-4(a1),a5
	move.b	right.side.flag,d0
	bsr	get.coord.pair
	move.w	d6,-(sp)
	move.w	d7,d5

	move.l	(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	no.closest.left.side

	move.b	(a4,d3.w),left.side.flag
	move.l	d0,-(a2)

no.closest.left.side
	move.l	(a2),a5
	move.b	left.side.flag,d0
	bsr	get.coord.pair
	move.w	(sp)+,d0

	bsr	clip.closest.section

	tst.b	closest.section.flag
	bmi.s	surface.done

now.draw.surface
	and.l	#$f000000,d4
	bne.s	surface.done
	bsr	fill.polygon

surface.done
	move.b	#0,drs.flag
	btst	#0,section.flags2
	beq.s	start.line.done

	bsr	draw.start.line
start.line.done
	rts


draw.near.road
	sub.w	#32,road.section.offset
	cmp.w	#64,road.section.offset
	blt	dnr.end

dnr1	move.l	#section.data,a4
	move.w	road.section.offset,d3

dnr2	sub.w	#32,d3
	beq.s	dnr3

	tst.b	30(a4,d3.w)
	bmi.s	dnr2

dnr3	move.w	d3,next.road.section.offset
	cmp.w	dnr.value,d3
	blt	dnr.end

	tst.b	at.side.flag
	bne.s	dnr.side

	bsr	draw.near.left.sides
	bsr	draw.left.side.lines
	bsr	draw.near.right.sides
	bsr	draw.right.side.lines
	bsr	draw.opponent.test1
	bsr	draw.opponent.test2
	bsr	draw.road.surface
	bsr	draw.left.road.lines
	bsr	draw.right.road.lines
	bsr	draw.opponent.test3
	bra	dnr8

dnr.side
	tst.b	clip.value
	bpl.s	dnr.right.side

	bsr	draw.opponent.test1
	bsr	draw.near.right.sides
	bsr	draw.right.side.lines
	bsr	draw.road.surface
	bsr	draw.right.road.lines
	bsr	draw.opponent.test3
	bsr	draw.near.left.sides
	bsr	draw.left.side.lines
	move.w	road.section.offset,d3
	cmp.w	copy.road.section.offset,d3
	beq.s	dnr4

	tst.b	dnr.flag
	bne.s	dnr4

	move.w	road.section.offset,-(sp)
	move.w	copy.road.section.offset,road.section.offset
	bsr	draw.left.road.lines
	move.w	(sp)+,road.section.offset
	bra.s	dnr5

dnr4	bsr	draw.left.road.lines
dnr5	bsr	draw.opponent.test2
	bra.s	dnr8

dnr.right.side
	bsr	draw.opponent.test2
	bsr	draw.near.left.sides
	bsr	draw.left.side.lines
	bsr	draw.road.surface
	bsr	draw.left.road.lines
	bsr	draw.opponent.test3
	bsr	draw.near.right.sides
	bsr	draw.right.side.lines
	move.w	road.section.offset,d3
	cmp.w	copy.road.section.offset,d3
	beq.s	dnr6

	tst.b	dnr.flag
	bne.s	dnr6

	move.w	road.section.offset,-(sp)
	move.w	copy.road.section.offset,road.section.offset
	bsr	draw.right.road.lines
	move.w	(sp)+,road.section.offset
	bra.s	dnr7

dnr6	bsr	draw.right.road.lines
dnr7	bsr.s	draw.opponent.test1

dnr8	move.w	next.road.section.offset,road.section.offset
	bne	dnr1
dnr.end	rts


draw.far.road
	sub.w	#32,road.section.offset
	move.w	road.section.offset,d3
	cmp.w	far.road.limit,d3
	blt.s	dfr.end

	sub.w	#32,d3
	move.w	d3,next.road.section.offset
	tst.b	at.side.flag
	bne.s	dfr.side

	bsr	draw.far.left.sides
	bsr.s	draw.far.right.sides
	bsr.s	draw.opponent.test1
	bsr.s	draw.opponent.test2
	bsr	draw.road.surface
	bsr.s	draw.opponent.test3
	bra.s	dfr.next

dfr.side
	tst.b	clip.value
	bpl.s	dfr.right.side

	bsr.s	draw.opponent.test1
	bsr.s	draw.far.right.sides
	bsr	draw.road.surface
	bsr.s	draw.opponent.test3
	bsr	draw.far.left.sides
	bsr.s	draw.opponent.test2
	bra.s	dfr.next

dfr.right.side
	bsr.s	draw.opponent.test2
	bsr	draw.far.left.sides
	bsr	draw.road.surface
	bsr.s	draw.opponent.test3
	bsr.s	draw.far.right.sides
	bsr.s	draw.opponent.test1
dfr.next
	bra.s	draw.far.road
dfr.end	rts


draw.opponent.test1
	tst.b	opponent.draw.flag
	beq.s	dot2
	bpl.s	dot1
	rts

draw.opponent.test2
	tst.b	opponent.draw.flag
	bmi.s	dot1
	rts

draw.opponent.test3
	tst.b	opponent.draw.flag
	bne.s	dot2

dot1	move.w	next.road.section.offset,d3
	cmp.w	W.1bc12,d3
	bgt.s	dot2

	bsr	draw.opponent
	move.w	#-1,W.1bc12
dot2	rts


sides.colour	dc.b	0
side.lines.colour	dc.b	0


draw.far.right.sides
	move.l	#section.data,a4
	move.w	road.section.offset,d3
	move.b	#15,d7
	btst	#0,28(a4,d3.w)
	beq.s	dfrs.col.set
	move.b	sides.colour,d7

dfrs.col.set
	move.l	#section.data,a4
	move.w	road.section.offset,d3
	move.l	12(a4,d3.w),d0
	move.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	end.dfrs

	move.l	d0,a0
	move.l	-12(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	end.dfrs

	move.l	d0,a1
	move.l	4(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	end.dfrs

	move.l	d0,a2
	move.l	20(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	end.dfrs

	move.l	d0,a3
	and.l	#$f000000,d4
	bne.s	end.dfrs

	move.b	d7,d0
	move.b	d0,d6
	asl.b	#4,d6
	addq.b	#2,d6
	move.b	d6,word.col+3

	moveq	#0,d6
	moveq	#0,d7
	lsr.b	#1,d0
	bcc.s	mask1.set2
	not.w	d6
mask1.set2
	swap	d6
	lsr.b	#1,d0
	bcc.s	mask2.set2
	not.w	d6
mask2.set2
	lsr.b	#1,d0
	bcc.s	mask3.set2
	not.w	d7
mask3.set2
	swap	d7
	lsr.b	#1,d0
	bcc.s	mask4.set2
	not.w	d7
mask4.set2
	bsr	simple.poly.fill
end.dfrs
	rts


draw.far.left.sides
	move.l	#section.data,a4
	move.w	road.section.offset,d3
	move.b	#15,d7
	btst	#0,28(a4,d3.w)
	beq.s	dfls.col.set
	move.b	sides.colour,d7

dfls.col.set
	move.l	#section.data,a4
	move.w	road.section.offset,d3
	move.l	8(a4,d3.w),d0
	move.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	end.dfls

	move.l	d0,a0
	move.l	16(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	end.dfls

	move.l	d0,a1
	move.l	(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	end.dfls

	move.l	d0,a2
	move.l	-16(a4,d3.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	end.dfls

	move.l	d0,a3
	and.l	#$f000000,d4
	bne.s	end.dfls

	move.b	d7,d0
	move.b	d0,d6
	asl.b	#4,d6
	addq.b	#2,d6
	move.b	d6,word.col+3

	moveq	#0,d6
	moveq	#0,d7
	lsr.b	#1,d0
	bcc.s	mask1.set3
	not.w	d6
mask1.set3
	swap	d6
	lsr.b	#1,d0
	bcc.s	mask2.set3
	not.w	d6
mask2.set3
	lsr.b	#1,d0
	bcc.s	mask3.set3
	not.w	d7
mask3.set3
	swap	d7
	lsr.b	#1,d0
	bcc.s	mask4.set3
	not.w	d7
mask4.set3
	bsr	simple.poly.fill
end.dfls
	rts


far.road.limit	dc.w	0


plot.line
	cmp.w	#128,2(a3)
	bcc	pl15

	move.l	a3,a2
	addq.l	#8,a3
	move.w	(a2),d5
	subq.w	#1,d5
	move.w	4(a2),d4
	beq.s	pl5

	cmp.w	#256,d4
	bge.s	pl1

	move.w	(a3)+,d6
	bpl.s	pl6

	move.w	6(a2),d6
	bra.s	pl6

pl1	bne	pl15

	subq.w	#1,d4
	bra.s	pl3

pl2	subq.w	#1,d5
pl3	move.w	(a3)+,d6
	cmp.w	#256,d6
	beq.s	pl2

	tst.w	d6
	bpl.s	pl6

	move.w	6(a2),d6
	cmp.w	#256,d6
	beq	pl15
	bra.s	pl6

pl4	subq.w	#1,d5
pl5	move.w	(a3)+,d6
	beq.s	pl4
	bpl.s	pl6

	move.w	6(a2),d6
	beq	pl15

pl6	cmp.w	#128,d5
	bcc	pl15

	cmp.w	#256,d4
	bcc	pl15

	subq.l	#2,a3
	move.w	4(a2),d0
	sub.w	6(a2),d0
	bmi.s	ple

	move.l	current.scene,a0
	move.w	d4,d0
	ext.l	d0
	ext.l	d5
	lsr.l	#3,d0
	and.b	#$fe,d0
	add.l	d0,a0
	move.l	d5,d0
	asl.l	#2,d0
	add.l	d5,d0
	asl.l	#3,d0
	add.l	d0,a0
	move.b	#0,d2
	move.w	(a3)+,d6
	bpl.s	pl7

	tst.b	d2
	bmi.s	pld

	move.b	#$80,d2
	subq.l	#2,a3
	move.w	6(a2),d6
pl7	bne.s	pl8

	move.w	#$ffff,d6

pl8	bsr	plot.pixel

	cmp.w	d4,d6
	bne.s	plb

	move.w	(a3)+,d6
	bpl.s	pl9

	tst.b	d2
	bmi.s	pld

	move.b	#$80,d2
	subq.l	#2,a3
	move.w	6(a2),d6
pl9	bne.s	pla

	move.w	#$ffff,d6

pla	subq.w	#1,d5
	bmi	pl15

	lea	-40(a0),a0
	cmp.w	d4,d6
	beq.s	pl8

plb	move.w	d4,d0
	subq.w	#1,d4
	and.w	#$f,d0
	bne.s	plc

	tst.w	d4
	bmi.s	pl15

	subq.l	#2,a0
plc	bra.s	pl8
pld	rts

ple	move.l	current.scene,a0
	move.w	d4,d0
	ext.l	d0
	ext.l	d5
	lsr.l	#3,d0
	and.b	#$fe,d0
	add.l	d0,a0
	move.l	d5,d0
	asl.l	#2,d0
	add.l	d5,d0
	asl.l	#3,d0
	add.l	d0,a0
	move.b	#0,d2
	move.w	(a3)+,d6
	bpl.s	plf

	tst.b	d2
	bmi.s	pl15

	move.b	#$80,d2
	subq.l	#2,a3
	move.w	6(a2),d6
plf	bne.s	pl10

	move.w	#$ffff,d6

pl10	bsr	plot.pixel

	cmp.w	d4,d6
	bne.s	pl13

	move.w	(a3)+,d6
	bpl.s	pl11

	tst.b	d2
	bmi.s	pl15

	move.b	#$80,d2
	subq.l	#2,a3
	move.w	6(a2),d6
pl11	bne.s	pl12

	move.w	#$ffff,d6

pl12	subq.w	#1,d5
	bmi.s	pl15

	lea	-40(a0),a0
	cmp.w	d4,d6
	beq.s	pl10

pl13	addq.w	#1,d4
	move.w	d4,d0
	and.w	#$f,d0
	bne.s	pl14

	cmp.w	#256,d4
	bge.s	pl15

	addq.l	#2,a0
pl14	bra.s	pl10
pl15	rts


sort.three.edges
	move.w	(a0),d0
	cmp.w	(a2),d0
	beq.s	ste2

	cmp.w	(a1),d0
	beq.s	ste1

	move.l	a1,a3
	move.l	a0,a1
	exg	a0,a2
	bra.s	ste3

ste1	move.l	a0,a3
	move.l	a1,a0
	move.l	a2,a1
	bra.s	ste3

ste2	move.l	a2,a3
	move.l	a1,a2
ste3	move.b	#1,simple.poly.count
	bra	simple.poly.fill2


draw.mountains
	move.w	x.amount,d0
	asr.w	#3,d0
	neg.w	d0
	move.w	d0,mountain.y.offset

	move.l	#mountain.positions,a0
	move.b	y.angle,d6
	sub.b	#28,d6
	move.b	#44,d7
	move.b	mountain.count,d1
	subq.b	#1,d1

dm1	move.b	(a0,d1.w),d0
	sub.b	d6,d0
	cmp.b	d7,d0
	bcc	dmA

	movem.l	d1/d6-a0,-(sp)
	sub.b	#28,d0
	asl.w	#8,d0
	clr.w	d3
	move.b	y.angle+1,d3
	and.b	#$fe,d3
	sub.w	d3,d0
	asr.w	#3,d0
	move.w	d0,mountain.x.offset
	clr.w	d0
	move.l	#mountain.numbers,a0
	move.b	(a0,d1.w),d0
	asl.w	#3,d0
	move.l	#mountain.table,a0
	move.l	(a0,d0.w),a6
	move.l	4(a0,d0.w),a2
	move.w	(a6)+,d6
	subq.w	#1,d6
	move.b	d6,d1
	asl.b	#1,d1
	move.l	#x.values,a4
	move.l	#y.values,a5
	move.w	mountain.x.offset,d4
	move.w	mountain.y.offset,d5

dm2	move.w	(a6)+,d0
	bpl.s	dm3
	move.w	(a2)+,d0

dm3	add.w	d4,d0
	move.w	d0,(a4)+

	move.w	(a6)+,d0
	bpl.s	dm4
	move.w	(a2)+,d0

dm4	sub.w	d5,d0
	neg.w	d0
	move.w	d0,(a5)+
	dbra	d6,dm2

	move.l	a6,-(sp)
	move.l	#sin.cos.values,a3
	move.l	#x.values,a5
	move.l	#y.values,a4

dm5	bsr	z.rotate1
	subq.b	#2,d1
	bpl.s	dm5

	move.l	(sp)+,a6
	move.w	#0,road.section.offset
	move.b	(a6)+,mountain.total.edges

dm6	move.b	(a6)+,d1
	move.b	(a6)+,d2
	move.l	a6,-(sp)
	bsr	clip.line.make.edge
	move.l	(sp)+,a6
	addq.w	#4,road.section.offset
	subq.b	#1,mountain.total.edges
	bne.s	dm6

	move.b	(a6)+,mountain.poly.count

dm7	move.l	#section.data,a5
	move.b	(a6)+,d0
	bsr	make.masks
	move.b	(a6)+,mountain.poly.edges
	moveq	#$ffffffff,d4

	move.b	(a6)+,d2
	move.l	(a5,d2.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	dm9
	move.l	d0,a0

	move.b	(a6)+,d2
	move.l	(a5,d2.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	dm9
	move.l	d0,a1

	move.b	(a6)+,d2
	move.l	(a5,d2.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	dm9
	move.l	d0,a2

	cmp.b	#3,mountain.poly.edges
	bne.s	dm8

	and.l	#$f000000,d4
	bne.s	dm9

	move.l	a6,-(sp)
	bsr	sort.three.edges
	move.l	(sp)+,a6
	bra.s	dm9

dm8	move.b	(a6)+,d2
	move.l	(a5,d2.w),d0
	and.l	d0,d4
	and.l	#$ffffff,d0
	beq.s	dm9
	move.l	d0,a3

	and.l	#$f000000,d4
	bne.s	dm9

	move.l	a6,-(sp)
	bsr	simple.poly.fill
	move.l	(sp)+,a6

dm9	subq.b	#1,mountain.poly.count
	bne	dm7

	movem.l	(sp)+,d1/d6-a0
dmA	subq.b	#1,d1
	bpl	dm1
	rts


mountain.positions
	dc.b	$05,$0f,$15,$1f,$25,$2f,$35,$3f
	dc.b	$45,$4f,$55,$5f,$65,$6f,$75,$7f
	dc.b	$85,$8f,$95,$9f,$a5,$af,$b5,$bf
	dc.b	$c5,$cf,$d5,$df,$e5,$ef,$f5,$ff
	ds.w	8

mountain.numbers
	dc.b	0,13,10,11,12,5,2,3,0,1,4,5,2,1,0,5
	dc.b	2,3,4,5,0,9,6,7,8,5,0,3,4,1,2,5
	ds.w	8

mountain.poly.edges
	dc.b	0
mountain.total.edges
	dc.b	0
mountain.poly.count
	dc.b	0
mountain.count
	dc.b	32
mountain.x.offset
	dc.w	0
mountain.y.offset
	dc.w	0

standard
	dc.w	4
	dc.w	0,0,$80c8,0,$804b,$8019,$8078,$801e
	dc.b	4
	dc.b	0,2,0,4,4,6,2,6
	dc.b	1

	dc.b	5
	dc.b	4
	dc.b	0,4,8,12

taller	dc.w	4
	dc.w	0,0,$80c8,0,$80fa,0,$8050,$801e
	dc.b	5
	dc.b	0,2,2,4,0,6,2,6,4,6
	dc.b	2

	dc.b	4
	dc.b	3
	dc.b	0,8,12

	dc.b	5
	dc.b	3
	dc.b	4,12,16

snow.capped
	dc.w	7
	dc.w	0,0,$81f4,0,$8348,0,$84a6,0,$8302,$805c
	dc.w	$8230,$8069,$833e,$80e6
	dc.b	10
	dc.b	0,2,2,4,4,6,0,10,2,8,4,8,6,12,8,10,10,12,8,12
	dc.b	4

	dc.b	4
	dc.b	4
	dc.b	0,12,28,16

	dc.b	5
	dc.b	3
	dc.b	4,16,20

	dc.b	5
	dc.b	4
	dc.b	8,20,36,24

	dc.b	15
	dc.b	3
	dc.b	28,32,36

buildings
	dc.w	6
	dc.w	0,0,$805a,0,$808c,0,0,$8140,$805a,$8140,$808c,$8140
	dc.b	7
	dc.b	0,2,2,4,0,6,2,8,4,10,6,8,8,10
	dc.b	2

	dc.b	15
	dc.b	4
	dc.b	0,8,20,12

	dc.b	14
	dc.b	4
	dc.b	4,12,24,16

lake	dc.w	4
	dc.w	0,8,$32,0,$28a,0,$2bc,8
	dc.b	4
	dc.b	2,4,0,2,0,6,4,6
	dc.b	1

	dc.b	6
	dc.b	4
	dc.b	0,4,8,12

sm1	dc.w	$180,$4b,$1c,$104,$10
sm2	dc.w	$100,$7d,$12,$c0,$1e
sm3	dc.w	$180,$64,$14,$136,$25
sm4	dc.w	$100,$46,$18,$d8,$24
sm5	dc.w	$180,$c8,$27,$f0,$1f
sm6	dc.w	$100,$32,$c,$a8,$1a
sm7	dc.w	$172,$70,$19,$e6,$14
sm8	dc.w	$fa,$64,$c,$bb,$12
sm9	dc.w	$180,$c6,$1c,$13b,$18
smA	dc.w	$100,$23,$28,$6e,$37
smB	dc.w	$159,$5c,$2a,$f0,$1e
smC	dc.w	$fa,$2d,$f,$80,$b
smD	dc.w	$17c,$88,$2b,$d2,$23
smE	dc.w	$100,$4b,$29,$9b,$37

	dc.w	$64,$19a,$fa,$2d,$4b,$23f,$aa,$2d
	dc.w	$b9,$145,$7d,$46,$32,$12c,$a5,$15

scm1	dc.w	$fa,$1a4,$253,$181,$2e,$118,$34,$19f,$73
scm2	dc.w	$4b,$127,$1f4,$af,$32,$87,$3c,$ff,$48
scm3	dc.w	$87,$c5,$fa,$96,$46,$69,$50,$aa,$5f
scm4	dc.w	$87,$113,$1a9,$91,$2a,$3c,$32,$8c,$4d

bm1	dc.w	$10,$18,$50,$10,$50,$18,$50
bm2	dc.w	$10,$18,$3c,$10,$3c,$18,$3c
bm3	dc.w	$28,$3c,$39,$28,$39,$3c,$39
bm4	dc.w	$69,$7d,$2a,$69,$2a,$7d,$2a

lm	dc.w	0

mountain.table
	dc.l	standard,sm1
	dc.l	standard,sm2
	dc.l	standard,sm3
	dc.l	standard,sm4
	dc.l	standard,sm5
	dc.l	standard,sm6
	dc.l	standard,sm7
	dc.l	standard,sm8
	dc.l	standard,sm9
	dc.l	standard,smA
	dc.l	standard,smB
	dc.l	standard,smC
	dc.l	standard,smD
	dc.l	standard,smE
	dc.l	taller,smD
	dc.l	taller,smE
	dc.l	snow.capped,scm1
	dc.l	snow.capped,scm2
	dc.l	snow.capped,scm3
	dc.l	snow.capped,scm4
	dc.l	buildings,bm1
	dc.l	buildings,bm2
	dc.l	buildings,bm3
	dc.l	buildings,bm4
	dc.l	lake,lm
	dc.l	unknown,unknown

unknown	ds.w	33


fp.level	dc.b	0,0
bottom.ptrs.offset	dc.w	0
fp.y.flag	dc.w	0
fp.ptr1	dc.l	0
fp.ptr2	dc.l	0
B.69ad8	dc.b	0,0
B.69ada	dc.b	0,0
closest.section.flag	dc.b	0,0
left.side.flag	dc.b	0,0
	dc.w	0
right.side.flag	dc.b	0,0
	dc.w	0
next.road.section.offset	dc.w	0
copy.road.section.offset	dc.w	0
start.line.flag	dc.b	0,0
fp.colour	dc.b	0,0
	dc.w	0
fp.start	dc.l	0
fp.end	dc.l	0
fp.diff	dc.l	0
	ds.l	32
section.side.ptrs
	ds.l	32
bottom.ptrs
	ds.l	64


set.sprite.colours
	move.l	#colour16+2,a0
	move.l	#sprite.colours,a1
	move.w	#8-1,d0
.set.cols
	move.w	(a1)+,(a0)+
	addq.l	#2,a0
	dbra	d0,.set.cols
	rts


sprite.colours
	dc.w	$000,$000,$fff,$c88,000,$000,$fff,$c88


W.69ec4	dc.w	$3c


W.69ede	dc.w	0


set.sprite.pointers
	move.l	#graphic.pointers,a1
	and.w	#$ff,d0
	asl.w	#2,d0
	move.l	(a1,d0.w),d0

	move.l	#sprite0+2,a0
	asl.w	#3,d1
	move.w	d0,4(a0,d1.w)
	swap	d0
	move.w	d0,(a0,d1.w)
	rts


update.sprites
	move.w	#37*4,d1

us1	move.l	#graphic.pointers,a0
	move.l	(a0,d1.w),a0

	move.w	d1,d0
	asl.w	#2,d0
	move.l	#graphic.info,a1
	move.w	10(a1,d0.w),d0		get y position

	add.w	W.69ec4,d0		add hardware offset
	move.b	2(a0),d3
	sub.b	(a0),d3
	move.b	d0,(a0)
	add.b	d3,d0
	move.b	d0,2(a0)

	addq.w	#4,d1
	cmp.w	#49*4,d1
	bne.s	us1
	rts


	dc.b	0
adjust.sprites	dc.b	0


copy.graphic
	move.l	d5,-(sp)
	move.w	d1,-(sp)
	movem.l	a4-a6,-(sp)
	and.w	#$ff,d0
	asl.w	#2,d0
	move.l	#graphic.pointers,a1
	move.l	(a1,d0.w),a1		get source pointer

	asl.w	#2,d0
	move.l	#graphic.info,a2
	lea	4(a2,d0.w),a2

	move.w	4(a2),d0		get x word position
	move.w	6(a2),d3		get y position
	move.l	screen2,a0
	and.l	#$ff,d0
	and.l	#$ff,d3
	asl.l	#1,d0
	add.l	d0,a0

	move.l	d3,d0
	asl.l	#2,d0
	add.l	d0,d3
	asl.l	#3,d3
	add.l	d3,a0

	lea	8000(a0),a4
	lea	16000(a0),a5
	lea	24000(a0),a6
	move.w	(a2),d1			get width count
	move.w	2(a2),d4		get height count
copy.line
	move.l	a0,a2
	move.w	d1,d3
copy.word
	move.w	(a1)+,d5		get mask word

	move.w	(a0),d0
	and.w	d5,d0
	or.w	(a1)+,d0
	move.w	d0,(a0)+

	move.w	(a4),d0
	and.w	d5,d0
	or.w	(a1)+,d0
	move.w	d0,(a4)+

	move.w	(a5),d0
	and.w	d5,d0
	or.w	(a1)+,d0
	move.w	d0,(a5)+

	move.w	(a6),d0
	and.w	d5,d0
	or.w	(a1)+,d0
	move.w	d0,(a6)+

	dbra	d3,copy.word

	lea	40(a2),a0
	lea	8040(a2),a4
	lea	16040(a2),a5
	lea	24040(a2),a6
	dbra	d4,copy.line

	movem.l	(sp)+,a4-a6
	move.w	(sp)+,d1
	move.l	(sp)+,d5
	rts


draw.spark.sub2.sub
	move.w	(a1)+,d0
	swap	d0
	move.w	#$ffff,d0
	ror.l	d3,d0
	move.l	d0,d6
	swap	d0
	move.w	d0,d6
	move.l	d0,d7
	swap	d0
	move.w	d0,d7
	move.l	d7,-(sp)

	move.l	(a1)+,d0
	move.l	d0,d7
	clr.w	d0
	swap	d7
	clr.w	d7
	lsr.l	d3,d0
	lsr.l	d3,d7
	move.l	d0,d4
	swap	d7
	move.w	d7,d4
	move.w	d0,d7
	swap	d7
	move.l	d7,-(sp)

	move.l	(a1)+,d0
	move.l	d0,d7
	clr.w	d0
	swap	d7
	clr.w	d7
	lsr.l	d3,d0
	lsr.l	d3,d7
	move.l	d0,d5
	swap	d7
	move.w	d7,d5
	move.w	d0,d7
	swap	d7
	cmp.w	#16,W.6a168
	bcc.s	dspks2s1

	move.w	(a0),d0
	swap	d0
	move.w	8000(a0),d0
	and.l	d6,d0
	or.l	d4,d0
	move.w	d0,8000(a0)
	swap	d0
	move.w	d0,(a0)+

	move.w	15998(a0),d0
	swap	d0
	move.w	23998(a0),d0
	and.l	d6,d0
	or.l	d5,d0
	move.w	d0,23998(a0)
	swap	d0
	move.w	d0,15998(a0)
	bra.s	dspks2s2

dspks2s1
	addq.l	#2,a0
dspks2s2
	move.l	(sp)+,d4
	move.l	(sp)+,d6
	addq.w	#1,W.6a168
	cmp.w	#16,W.6a168
	bcc.s	dspks2s3

	move.w	(a0),d0
	swap	d0
	move.w	8000(a0),d0
	and.l	d6,d0
	or.l	d4,d0
	move.w	d0,8000(a0)
	swap	d0
	move.w	d0,(a0)

	move.w	16000(a0),d0
	swap	d0
	move.w	24000(a0),d0
	and.l	d6,d0
	or.l	d7,d0
	move.w	d0,24000(a0)
	swap	d0
	move.w	d0,16000(a0)

dspks2s3
	subq.w	#1,W.6a168
	rts


draw.spark.sub2
	move.w	d1,-(sp)
	move.w	d2,-(sp)
	and.w	#$ff,d0
	asl.w	#2,d0
	move.l	#graphic.pointers,a1
	move.l	(a1,d0.w),a1

	asl.w	#2,d0
	move.l	#graphic.info,a2
	lea	4(a2,d0.w),a2

	move.l	screen2,a0
	move.w	d4,d0
	ext.l	d0
	ext.l	d5
	lsr.l	#3,d0
	and.b	#$fe,d0
	add.l	d0,a0
	move.l	d5,d0
	asl.l	#2,d0
	add.l	d5,d0
	asl.l	#3,d0
	add.l	d0,a0
	move.w	(a2),a6
	move.w	2(a2),d2
	move.w	d4,d3
	and.l	#$f,d3
	move.w	d4,d0
	asr.w	#4,d0
	subq.w	#2,d0
	move.w	d0,W.6a166
	move.w	d0,W.6a168
	move.w	d5,d0
	sub.w	#16,d0
	move.w	d0,W.6a16a

dspks21	move.l	a0,a2
	move.w	a6,d1
	cmp.w	#128,W.6a16a
	bcc.s	dspks23

dspks22	bsr	draw.spark.sub2.sub
	addq.w	#1,W.6a168
	dbra	d1,dspks22

dspks23	move.w	W.6a166,W.6a168
	lea	40(a2),a0
	addq.w	#1,W.6a16a
	dbra	d2,dspks21

	move.w	(sp)+,d2
	move.w	(sp)+,d1
	rts


W.6a166	dc.w	0
W.6a168	dc.w	0
W.6a16a	dc.w	0


graphic.info
;	word 1  --  not used
;	word 2  --  not used
;	word 3  --  number of words wide - 1
;	word 4  --  number of lines high - 1
;	word 5  --  x position in words
;	word 6  --  y position
;	word 7  --  not used
;	word 8  --  not used

	dc.w	0,0,1,57,16,119,0,0	right wheels
	dc.w	2,0,1,57,16,119,0,0
	dc.w	4,0,1,57,16,119,0,0

	dc.w	8,0,1,57,2,119,0,0	left wheels
	dc.w	10,0,1,57,2,119,0,0
	dc.w	12,0,1,57,2,119,0,0

	dc.w	0,68,3,27,2,123,0,0	left flames
	dc.w	4,68,3,27,2,123,0,0

	dc.w	8,68,3,27,14,123,0,0	right flames
	dc.w	12,68,3,27,14,123,0,0

	dc.w	2,123,15,20,2,123,0,0	engine block

	dc.w	2,144,1,14,2,144,0,0	left / right exhaust covering wheel
	dc.w	16,144,1,14,16,144,0,0

	dc.w	2,16,0,5,2,16,0,0	left / right top corner
	dc.w	17,16,0,5,17,16,0,0

	dc.w	14,0,0,7,6,190,0,0	chequered flag bright / dull
	dc.w	14,8,0,7,6,190,0,0

	dc.w	14,16,0,7,13,190,0,0	stop watch bright / dull
	dc.w	14,24,0,7,13,190,0,0

	dc.w	15,0,0,7,4,16,0,0	left chain top / bottom
	dc.w	15,8,0,7,4,24,0,0

	dc.w	15,16,0,7,15,16,0,0	right chain top / bottom
	dc.w	15,24,0,7,15,24,0,0

	dc.w	16,0,1,7,4,0,0,0	hole position 1 / 2
	dc.w	16,8,1,7,4,0,0,0

	dc.w	16,16,1,7,4,0,0,0	smash position 1 / 2
	dc.w	16,24,1,7,4,0,0,0

	dc.w	16,32,1,7,4,0,0,0	damage bar clear position 1 / 2
	dc.w	16,40,1,7,4,0,0,0

	dc.w	0,96,3,33,0,0,0,0	dust clouds
	dc.w	5,96,3,30,0,0,0,0
	dc.w	9,96,3,37,0,0,0,0
	dc.w	13,96,4,35,0,0,0,0
	dc.w	0,134,2,27,0,0,0,0
	dc.w	3,134,3,33,0,0,0,0
	dc.w	7,134,3,33,0,0,0,0
	dc.w	11,134,3,35,0,0,0,0

	dc.w	1,176,0,15,17,119,0,0	sprites
	dc.w	3,176,0,15,17,119,0,0
	dc.w	5,176,0,15,17,119,0,0
	dc.w	8,176,0,15,2,119,0,0
	dc.w	10,176,0,15,2,119,0,0
	dc.w	12,176,0,15,2,119,0,0
	dc.w	0,176,0,15,17,119,0,0
	dc.w	2,176,0,15,17,119,0,0
	dc.w	4,176,0,15,17,119,0,0
	dc.w	7,176,0,15,2,119,0,0
	dc.w	9,176,0,15,2,119,0,0
	dc.w	11,176,0,15,2,119,0,0

	dc.w	16,68,3,27,2,123,0,0	left flame

	dc.w	16,172,3,27,14,123,0,0	right flame

	dc.w	16,134,3,27,8,27,0,0	message panel


graphic.pointers
	dc.l	$6490,$6918,$6da0,$7228
	dc.l	$76b0,$7b38,$7fc0,$8420
	dc.l	$8880,$8ce0,$d2a8,$dfc8
	dc.l	$e0f4,$e220,$e25c,$9140
	dc.l	$9190,$91e0,$9230,$9280
	dc.l	$92d0,$9320,$9370,$93c0
	dc.l	$9460,$9500,$95a0,$9640
	dc.l	$96e0,$9780,$9cd0,$a1a8
	dc.l	$a798,$aea0,$b1e8,$b738
	dc.l	$bc88

	dc.l	$c228,$c270,$c2b8,$c300
	dc.l	$c348,$c390,$c3d8,$c420
	dc.l	$c468,$c4b0,$c4f8,$c540

	dc.l	$c588,$c9e8,$ce48
	dc.l	0,0


TAB.7aa1a
	dc.l	far.section0,far.section1,far.section2,far.section3
	dc.l	far.section4,far.section5,far.section6,far.section7
	dc.l	far.section8,far.section9,far.section10,far.section11
	dc.l	far.section12,far.section13,far.section14,far.section15
	dc.l	far.section16,far.section17,far.section18,far.section19
	dc.l	far.section20,far.section21,far.section22,far.section23
	dc.l	far.section24,far.section25,far.section26,far.section27
	dc.l	far.section28,far.section29,far.section30,far.section31
	dc.l	far.section32,far.section33,far.section34,far.section35
	dc.l	far.section36,far.section37,far.section38,far.section39
	dc.l	far.section40,far.section41,far.section42,far.section43
	ds.l	36


DAT.7ab5a
	ds.w	64


far.section0
	dc.w	0,$04c0,$0200,$0660,$0340,$0200,$0660
	dc.w	0!$2000,$04c0,$0100,$0280,$0340,$0100,$0280
	dc.w	0,$04c0,$0000,$0280,$0340,$0000,$0280

far.section1
	dc.w	1,$04c0,$0500,$0280,$0340,$0500,$0280
	dc.w	1!$2000,$04c0,$0400,$0780,$0340,$0400,$0780
	dc.w	1,$04c0,$0000,$0780,$0340,$0000,$0780

far.section2
	dc.w	2,$04c0,$0000,$0a60,$0340,$0000,$0a60

far.section3
	dc.w	3,$04c0,$0000,$1260,$0340,$0000,$1260

far.section4
	dc.w	4,$04c0,$0000,$1a60,$0340,$0000,$1a60

far.section5
	dc.w	5,$04c0,$0200,$1d40,$0340,$0200,$1d40
	dc.w	5,$04c0,$0000,$1d40,$0340,$0000,$1d40

far.section6
	dc.w	6,$04c0,$0000,$1d40,$0340,$0000,$1d40

far.section7
	dc.w	7,$04c0,$0000,$1d40,$0340,$0000,$1d40

far.section8
	dc.w	8,$04c0,$0100,$1d20,$0340,$0100,$1d20

far.section9
	dc.w	9,$04c0,$0000,$19a0,$0340,$0000,$19a0

far.section10
	dc.w	10!$4000,$04c0,$0000,$17a0,$0340,$0000,$13a0

far.section11
	dc.w	11,$0104,$fefd,$1380,$fff5,$000c,$0ec0

far.section12
	dc.w	12,$011c,$034d,$0f60,$00fb,$04cb,$0ae0

far.section13
	dc.w	13,$0000,$0340,$08a0,$0000,$04c0,$08a0

far.section14
	dc.w	14,$0000,$0340,$0560,$0000,$04c0,$0560

far.section15
	dc.w	15!$0100,$0000,$0340,$0500,$0000,$04c0,$0500

far.section16
	dc.w	16,$0000,$0340,$0500,$0000,$04c0,$0500

far.section17
	dc.w	17,$0000,$0340,$0500,$0000,$04c0,$0500

far.section18
	dc.w	18,$0000,$0340,$0500,$0000,$04c0,$0500

far.section19
	dc.w	19,$0000,$0340,$0500,$0000,$04c0,$0500

far.section20
	dc.w	20,$0000,$0340,$0500,$0000,$04c0,$0500

far.section21
	dc.w	21,$0000,$0340,$0500,$0000,$04c0,$0500

far.section22
	dc.w	22,$0000,$0340,$0500,$0000,$04c0,$0500

far.section23
	dc.w	23,$0000,$0340,$0500,$0000,$04c0,$0500

far.section24
	dc.w	24,$0000,$0340,$0700,$0000,$04c0,$0300

far.section25
	dc.w	25,$fefd,$06fc,$0760,$000c,$080b,$02a0

far.section26
	dc.w	26,$0340,$0800,$0760,$04c0,$0800,$02a0

far.section27
	dc.w	27,$059c,$069a,$0740,$06c5,$05a6,$02c0

far.section28
	dc.w	28,$0779,$0888,$0500,$0888,$0779,$0500

far.section29
	dc.w	29,$0778,$0887,$0500,$0887,$0778,$0500

far.section30
	dc.w	30,$0778,$0887,$0500,$0887,$0778,$0500

far.section31
	dc.w	31,$0778,$0887,$0500,$0887,$0778,$0500

far.section32
	dc.w	32,$0778,$0887,$0aa0,$0887,$0778,$0aa0

far.section33
	dc.w	33,$048f,$059f,$0f00,$059f,$048f,$0f00
	dc.w	33,$0778,$0887,$0500,$0887,$0778,$0500

far.section34
	dc.w	34,$0778,$0887,$0500,$0887,$0778,$0500

far.section35
	dc.w	35!$2000,$0032,$0141,$0c80,$0141,$0032,$0c80
	dc.w	35,$0778,$0887,$0640,$0887,$0778,$0640

far.section36
	dc.w	36,$0778,$0887,$0500,$0887,$0778,$0500

far.section37
	dc.w	37,$0778,$0887,$0500,$0887,$0778,$0500

far.section38
	dc.w	38,$0778,$0887,$0500,$0887,$0778,$0500

far.section39
	dc.w	39!$4000,$08a4,$09b3,$0700,$09b3,$08a4,$0300

far.section40
	dc.w	40,$0800,$04bf,$0760,$0800,$033f,$02a0

far.section41
	dc.w	41,$0903,$0104,$0760,$07f4,$fff5,$02a0

far.section42
	dc.w	42,$04b3,$011c,$0740,$0335,$00fb,$02c0

far.section43
	dc.w	43,$04c0,$0000,$0500,$0340,$0000,$0500

	ds.w	243


section.data
	ds.l	412


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
