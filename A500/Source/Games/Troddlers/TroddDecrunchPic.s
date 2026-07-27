	section	DecrunchPic,code_c
	opt	c-,o+




start	move.l	4.w,a6
	jsr	-132(a6)		turn multitasking off

	move.l	#4*40*256,d0
	move.l	#$10002,d1		clear chip
	jsr	-198(a6)		AllocMem
	tst.l	d0
	beq	exit_now
	move.l	d0,screen.mem

	lea	graf.name(pc),a1
	moveq	#0,d0
	jsr	-552(a6)		OpenLibrary
	tst.l	d0
	beq	exit_freemem

	move.l	d0,gfxbase
	move.l	d0,a6
	jsr	-456(a6)		OwnBlitter

	move.l	38(a6),old.copper

	move.l	screen.mem(pc),d0
	lea	copper.list(pc),a0
	bsr	init.copper

	lea	$dff000,a6
	move.w	intenar(a6),old.ints	save system interrupt status
	move.w	#$3fef,intena(a6)
	move.w	#$c010,intena(a6)	enable copper interrupt

vpwait	move.l	vposr(a6),d0		get vertical beam position
	and.l	#$1ff00,d0
	lsr.l	#8,d0
	cmp.w	#312,d0			wait for bottom line
	bne.s	vpwait			before disabling sprite DMA

	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	$14.w,old.dbz		division-by-zero exception handler
	move.l	#rte.ins,$14.w		set to rte instruction

;	lea	crunched.pic(pc),a0	initialise colours
	lea	temp.colour.table(pc),a0
	lea	color0(a6),a1
	moveq	#8-1,d0
set.colours
	move.l	(a0)+,(a1)+
	dbra	d0,set.colours

	move.w	#$4200,bplcon0(a6)	initialise screen
	move.w	#$2c81,diwstrt(a6)
	move.w	#$2cc1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	moveq	#0,d0
	move.w	d0,bplcon1(a6)
	move.w	d0,bplcon2(a6)
	moveq	#3*40,d0
	move.w	d0,bpl1mod(a6)
	move.w	d0,bpl2mod(a6)




;"""""""""""""""""""""""""""""""
;" SET THE NEW COPPER LOCATION "
;"			       "
;"""""""""""""""""""""""""""""""

	move.l	#copper.list,cop1lch(a6)
	move.w	d0,copjmp1(a6)

	move.w	#$87c0,dmacon(a6)	DMA on (bitplane, copper, blitter)




;""""""""""""""""""""""""""""""""
;" INITIALISE LEVEL 3 INTERRUPT "
;"				"
;""""""""""""""""""""""""""""""""

	move.l	$6c.w,old.level3
	move.l	#new.level3,$6c.w




;	lea	crunched.pic+32(pc),a0	skip colours
	lea	bodydata(pc),a0
	move.l	screen.mem(pc),a1
	bsr	decrunch.pic




;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

loop	clr.w	next.frame
wait	tst.w	next.frame
	beq.s	wait

	btst	#6,$bfe001
	bne.s	loop




;""""""""""""""""
;" EXIT ROUTINE "
;"		"
;""""""""""""""""

wait2	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait2

	move.l	old.level3(pc),$6c.w

	move.l	old.copper(pc),cop1lch(a6)

	move.l	old.dbz(pc),$14.w	restore division-by-zero handler

	move.w	#$8030,dmacon(a6)	DMA on (sprite, disk)

	move.w	old.ints(pc),d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status

	move.l	gfxbase(pc),a6
	jsr	-462(a6)		DisownBlitter

	move.l	4.w,a6
	move.l	gfxbase(pc),a1
	jsr	-414(a6)		CloseLibrary

exit_freemem
	move.l	screen.mem(pc),a1
	move.l	#4*40*256,d0
	jsr	-210(a6)		FreeMem

exit_now
	jsr	-138(a6)		turn multitasking on

	moveq	#0,d0
	rts




;"""""""""""""""""""""
;" LEVEL 3 INTERRUPT "
;"		     "
;"""""""""""""""""""""

new.level3
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$10,intreq(a6)

	move.w	#1,next.frame

	movem.l	(sp)+,d0-d7/a0-a6
rte.ins	rte




;"""""""""""""""
;" SUBROUTINES "
;"	       "
;"""""""""""""""

decrunch.pic
	move.w	#4*200-1,d0		bitplanes * lines

dp.bitplane
	moveq	#40,d1			width of screen in bytes

dp.byte	moveq	#0,d2
	move.b	(a0)+,d2
	bmi.s	next.byte.n.times


next.n.bytes.literally
	sub.b	d2,d1
	subq.b	#1,d1			remove from byte count

.loop	move.b	(a0)+,(a1)+		copy n bytes
	dbra	d2,.loop

	bra.s	check.byte.count


next.byte.n.times
	neg.b	d2
	bmi.s	dp.byte			if = -128

	sub.b	d2,d1
	subq.b	#1,d1			remove from byte count

	move.b	(a0)+,d3		get byte

.loop	move.b	d3,(a1)+		copy n times
	dbra	d2,.loop


check.byte.count
	tst.b	d1
	bne.s	dp.byte			until all bytes in bitplane are done

	dbra	d0,dp.bitplane
	rts




init.copper
	moveq	#4-1,d1
	moveq	#40,d2			width of screen in bytes
next.plane
	move.w	d0,6(a0)		save low word
	swap	d0
	move.w	d0,2(a0)		save high word
	swap	d0
	add.l	d2,d0			next bitplane
	addq.w	#8,a0			update pointer to copper list
	dbra	d1,next.plane
	rts




;"""""""""""""""""""
;" THE COPPER LIST "
;"		   "
;"""""""""""""""""""

copper.list
	dc.w	bpl1pth,0		4 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$2c01,$ff00

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
aud0vol	equ	$0a8
aud1vol	equ	$0b8
aud2vol	equ	$0c8
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
old.ints	dc.w	0
old.dbz		dc.l	0
gfxbase		dc.l	0
old.copper	dc.l	0
old.level3	dc.l	0
next.frame	dc.w	0




;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

graf.name	dc.b	'graphics.library',0
		even




;"""""""""""""""""
;" GRAPHICS DATA "
;"		 "
;"""""""""""""""""

temp.colour.table
	dc.w	$666,$242,$464,$7a7,$234,$446,$668,$88a
	dc.w	$400,$600,$820,$a42,$c62,$ea0,$000,$bbf

* This is the start of the FORM ILBMBMHD
formilbm
	dc.b	$46,$4f,$52,$4d		FORM
	dc.l	$00,$00,$60,$e8		length 24808

	dc.b	$49,$4c,$42,$4d		ILBM

	dc.b	$42,$4d,$48,$44		BMHD
	dc.l	20					length

	dc.b	$01,$40				width 320
	dc.b	$00,$c8				height 200
	dc.b	$00,$00				xstart
	dc.b	$00,$00				ystart
	dc.b	$04,$00				4 planes, no mask
	dc.b	$01,$00				ByteRun1 compression
	dc.b	$00,$00				transparent colour
	dc.b	$0a,$0b				X aspect, Y aspect
	dc.b	$01,$40				src width
	dc.b	$00,$c8				src height

	dc.b	$43,$41,$4d,$47		CAMG
	dc.b	$00,$00,$00,$04		length 4
	dc.b	$00,$00,$00,$00

	dc.b	$43,$4d,$41,$50		CMAP
	dc.b	$00,$00,$00,$30		length 48
	dc.b	$60,$60,$60,$20,$40,$20,$40,$60,$40,$70,$a0,$70,$20,$30,$40,$40
	dc.b	$40,$60,$60,$60,$80,$80,$80,$a0,$40,$00,$00,$60,$00,$00,$80,$20
	dc.b	$00,$a0,$40,$20,$c0,$60,$20,$e0,$a0,$00,$00,$00,$00,$b0,$b0,$f0

	dc.b	$42,$4f,$44,$59		BODY
	dc.b	$00,$00,$60,$7c		length 24700
bodydata
	dc.b	$01,$4f,$48,$fd,$00,$07,$0f,$30,$00,$00
	dc.b	$4f,$4a,$2f,$8c,$f7,$00,$07,$28,$54,$28,$54,$28,$54,$28,$54,$fb
	dc.b	$00,$01,$14,$00,$01,$ff,$b7,$fc,$ff,$00,$cf,$fe,$ff,$1c,$b7,$ff
	dc.b	$f3,$f7,$7f,$2a,$be,$fe,$fe,$3e,$fe,$fe,$fc,$9b,$99,$9b,$99,$9b
	dc.b	$99,$9b,$99,$07,$e0,$7f,$fe,$fc,$1e,$ee,$07,$01,$e6,$37,$fd,$ff
	dc.b	$21,$e6,$07,$ff,$ff,$e6,$37,$e7,$01,$f7,$7f,$2a,$be,$fe,$fe,$3e
	dc.b	$fe,$fe,$fc,$85,$e1,$85,$e1,$85,$e1,$85,$e1,$07,$e0,$7f,$fe,$fc
	dc.b	$1e,$a2,$07,$01,$a6,$35,$fd,$ff,$11,$a6,$05,$ff,$ff,$a6,$35,$c7
	dc.b	$00,$f7,$7f,$2a,$be,$fe,$fe,$3e,$fe,$fe,$fc,$f9,$ff,$07,$07,$e0
	dc.b	$7f,$fe,$fc,$1e,$a2,$07,$27,$40,$04,$ff,$7f,$ff,$fe,$a0,$04,$7f
	dc.b	$ff,$40,$01,$c5,$41,$a2,$7f,$00,$22,$7e,$7e,$3e,$7e,$7e,$f8,$24
	dc.b	$e4,$24,$e4,$24,$e4,$24,$e4,$08,$80,$39,$52,$c4,$0c,$54,$0a,$01
	dc.b	$ff,$fb,$fd,$ff,$01,$df,$fb,$fc,$ff,$1a,$fe,$ff,$fe,$ff,$fd,$81
	dc.b	$81,$41,$81,$81,$06,$1e,$78,$de,$7b,$de,$78,$1e,$7b,$17,$18,$fe
	dc.b	$ed,$7b,$ff,$eb,$f7,$f5,$ff,$1b,$ea,$ab,$88,$ff,$d5,$3f,$19,$19
	dc.b	$59,$19,$19,$36,$4d,$f2,$cd,$f3,$cd,$f2,$4d,$f3,$1f,$f8,$80,$4d
	dc.b	$ff,$e1,$8b,$f1,$10,$9f,$f9,$01,$00,$00,$01,$1f,$f9,$80,$00,$9f
	dc.b	$fc,$0a,$aa,$08,$c0,$d5,$fe,$01,$13,$41,$01,$01,$06,$00,$40,$c0
	dc.b	$43,$c0,$40,$00,$43,$10,$18,$80,$4d,$03,$e1,$8b,$f1,$27,$4f,$48
	dc.b	$01,$3e,$1e,$08,$1f,$48,$61,$00,$4f,$32,$06,$68,$1d,$74,$7f,$ff
	dc.b	$80,$80,$40,$80,$80,$04,$28,$54,$68,$56,$68,$54,$28,$56,$07,$20
	dc.b	$45,$d2,$f7,$d4,$5f,$f2,$27,$ff,$b7,$ff,$ff,$e1,$fd,$ff,$b7,$f6
	dc.b	$ff,$ff,$cd,$ff,$f7,$f2,$ca,$aa,$be,$ff,$ff,$3f,$ff,$ff,$fa,$9b
	dc.b	$99,$fb,$9f,$fb,$99,$9b,$9f,$3f,$c4,$fe,$6d,$fd,$eb,$ff,$ff,$11
	dc.b	$e6,$37,$ff,$ff,$e1,$ff,$c6,$37,$ff,$ef,$e6,$0f,$94,$c4,$e2,$ff
	dc.b	$80,$3e,$fc,$19,$10,$32,$85,$e1,$f5,$ef,$f5,$e1,$85,$ef,$3f,$e4
	dc.b	$90,$09,$00,$00,$3f,$fc,$11,$a6,$35,$aa,$a0,$a1,$09,$c6,$35,$a0
	dc.b	$ea,$a6,$0d,$10,$c4,$62,$80,$80,$20,$fc,$01,$10,$02,$ff,$ff,$df
	dc.b	$fb,$df,$ff,$ff,$fb,$20,$1c,$90,$09,$00,$00,$30,$04,$14,$40,$04
	dc.b	$00,$2a,$0e,$b4,$05,$04,$50,$c0,$42,$28,$5f,$75,$2a,$ea,$2a,$a9
	dc.b	$80,$80,$02,$fe,$80,$0f,$24,$e4,$74,$ee,$74,$e4,$24,$ee,$1f,$a8
	dc.b	$06,$00,$04,$0a,$5a,$d0,$01,$ff,$fb,$fe,$ff,$22,$49,$ff,$fb,$e3
	dc.b	$ff,$ff,$d7,$ef,$fb,$f5,$54,$ff,$d6,$ff,$ff,$fd,$ff,$ff,$7f,$1e
	dc.b	$78,$fe,$7f,$fe,$78,$1e,$7f,$7f,$c2,$ff,$ff,$fb,$f5,$f5,$27,$27
	dc.b	$ff,$ff,$55,$7f,$5a,$7f,$5a,$ab,$fe,$d5,$d5,$52,$a6,$c2,$80,$7f
	dc.b	$d5,$56,$19,$19,$b9,$19,$19,$3b,$4d,$f2,$fd,$ff,$fd,$f2,$4d,$ff
	dc.b	$7f,$f2,$bd,$9d,$fb,$f5,$bf,$fd,$27,$9f,$f9,$55,$61,$50,$41,$5a
	dc.b	$a9,$82,$15,$95,$52,$a6,$c2,$80,$00,$d5,$56,$01,$01,$81,$01,$01
	dc.b	$03,$00,$40,$e8,$57,$e8,$40,$00,$57,$47,$0e,$ad,$9d,$fb,$f5,$a0
	dc.b	$05,$27,$4f,$48,$aa,$be,$bf,$82,$a7,$e4,$4b,$ea,$47,$9d,$6f,$7f
	dc.b	$05,$4c,$6a,$ae,$80,$80,$86,$80,$80,$c2,$28,$54,$70,$4e,$70,$54
	dc.b	$28,$4e,$5f,$a4,$1e,$20,$1f,$ec,$75,$52,$01,$ff,$b7,$fe,$ff,$22
	dc.b	$e9,$ff,$fb,$e7,$ff,$ff,$ef,$ff,$fb,$ff,$f2,$95,$53,$ff,$ff,$79
	dc.b	$ff,$ff,$3d,$9b,$99,$ff,$bf,$ff,$99,$9b,$bf,$3f,$c2,$ff,$c7,$ff
	dc.b	$f3,$da,$a5,$14,$e6,$37,$55,$7f,$47,$3f,$47,$a3,$fa,$25,$c0,$02
	dc.b	$ce,$c9,$fa,$ff,$95,$50,$19,$19,$31,$fe,$19,$0f,$85,$e1,$fd,$ff
	dc.b	$fd,$e1,$85,$ff,$7f,$f2,$fa,$17,$3f,$f9,$1f,$fc,$11,$a6,$35,$55
	dc.b	$7f,$47,$29,$43,$81,$a0,$05,$80,$02,$ce,$c1,$fa,$80,$95,$50,$fb
	dc.b	$01,$0f,$ff,$ff,$f7,$ef,$f7,$ff,$ff,$ef,$0e,$0e,$c2,$0f,$30,$01
	dc.b	$00,$04,$27,$40,$04,$aa,$b4,$af,$c4,$af,$f4,$57,$ea,$4f,$c5,$5f
	dc.b	$79,$35,$40,$3f,$fd,$fe,$fe,$7e,$fe,$fe,$fc,$24,$e4,$7c,$ee,$7c
	dc.b	$e4,$24,$ee,$3e,$4c,$1a,$40,$52,$52,$53,$a4,$08,$ff,$fb,$ff,$eb
	dc.b	$ff,$f3,$ff,$fb,$ef,$fb,$ff,$02,$e0,$ff,$fb,$fb,$ff,$0f,$1e,$78
	dc.b	$fa,$5f,$fa,$78,$1e,$5f,$ff,$81,$7f,$a2,$fd,$a7,$bc,$53,$fc,$ff
	dc.b	$22,$9f,$ff,$d3,$f7,$1f,$e7,$4f,$ee,$cb,$8a,$ff,$ff,$fe,$ff,$ff
	dc.b	$78,$ff,$fe,$3d,$4d,$f2,$fd,$ff,$fd,$f2,$4d,$ff,$ff,$e1,$7c,$32
	dc.b	$bf,$fc,$bf,$f9,$27,$9f,$f9,$ff,$c1,$ff,$91,$f7,$c1,$87,$1f,$a7
	dc.b	$0f,$ee,$c3,$8a,$c0,$e0,$02,$ff,$ff,$78,$ff,$fe,$3d,$00,$40,$f0
	dc.b	$4f,$f0,$40,$00,$4f,$9c,$1f,$4c,$2e,$a0,$04,$a0,$01,$27,$4f,$48
	dc.b	$aa,$a0,$bf,$e4,$bf,$f4,$4f,$fa,$4f,$ed,$6f,$43,$55,$3e,$aa,$93
	dc.b	$fe,$fe,$78,$fe,$fe,$3c,$28,$54,$74,$2e,$74,$54,$28,$2e,$3c,$c6
	dc.b	$3d,$8c,$75,$b6,$7d,$52,$01,$ff,$b7,$fe,$ff,$02,$fb,$ff,$fb,$fb
	dc.b	$ff,$03,$bf,$c0,$75,$69,$fb,$ff,$0f,$9b,$99,$fb,$df,$fb,$99,$9b
	dc.b	$df,$ff,$09,$ff,$41,$da,$43,$d2,$a5,$19,$e6,$37,$ff,$ff,$ef,$af
	dc.b	$e7,$c3,$ff,$8f,$ef,$a7,$c1,$81,$aa,$ff,$3f,$fc,$99,$99,$81,$99
	dc.b	$99,$03,$85,$e1,$fe,$ff,$0a,$e1,$85,$ff,$ff,$e1,$fe,$61,$1f,$f9
	dc.b	$1f,$fc,$11,$a6,$35,$ff,$c1,$ef,$89,$e7,$c1,$9f,$8f,$af,$87,$c0
	dc.b	$81,$aa,$80,$00,$00,$fc,$81,$10,$03,$ff,$ff,$e3,$c7,$e3,$ff,$ff
	dc.b	$c7,$98,$1f,$9e,$5f,$00,$01,$00,$04,$11,$60,$02,$aa,$a0,$af,$ec
	dc.b	$af,$f0,$4f,$ea,$4f,$e5,$40,$01,$3f,$40,$b2,$68,$fb,$00,$0f,$24
	dc.b	$e4,$00,$80,$00,$e4,$24,$80,$39,$9a,$3c,$c6,$49,$52,$54,$a6,$fc
	dc.b	$ff,$00,$f3,$f9,$ff,$19,$d7,$bf,$ed,$93,$ff,$ff,$7f,$ff,$ff,$fe
	dc.b	$1e,$78,$fe,$7f,$fe,$78,$1e,$7f,$fe,$0d,$ff,$09,$b6,$a7,$bb,$53
	dc.b	$19,$ff,$ff,$55,$7f,$5f,$87,$57,$c7,$ef,$b5,$ef,$8a,$bf,$fe,$80
	dc.b	$2b,$7f,$fe,$ff,$ff,$7f,$ff,$ff,$fe,$4d,$f2,$fe,$ff,$0a,$f2,$4d
	dc.b	$ff,$ff,$c1,$ff,$e1,$bf,$fc,$bf,$f9,$27,$df,$f9,$55,$41,$5f,$81
	dc.b	$57,$c5,$8f,$95,$af,$8a,$bf,$fe,$80,$2b,$40,$02,$ff,$ff,$7f,$ff
	dc.b	$ff,$fe,$00,$40,$fe,$7f,$fe,$40,$00,$7f,$90,$3f,$98,$1f,$a0,$04
	dc.b	$a0,$01,$27,$0f,$4a,$00,$20,$0f,$e0,$0f,$fc,$5f,$c0,$5f,$e0,$1f
	dc.b	$7c,$55,$14,$20,$01,$ff,$ff,$7f,$ff,$ff,$fe,$28,$54,$78,$1e,$78
	dc.b	$54,$28,$1e,$5b,$0e,$39,$8a,$50,$02,$7a,$b2,$01,$ff,$b5,$fc,$ff
	dc.b	$12,$f3,$ff,$ff,$cf,$ff,$ff,$fb,$fe,$eb,$c0,$02,$ff,$ff,$df,$ff
	dc.b	$ff,$fd,$9b,$99,$fe,$ff,$0a,$99,$9b,$ff,$bc,$15,$fe,$1d,$e0,$07
	dc.b	$d5,$47,$11,$e6,$37,$55,$7f,$47,$07,$43,$97,$ff,$85,$ef,$a2,$9e
	dc.b	$f0,$aa,$eb,$7f,$fe,$fb,$ff,$0f,$85,$e1,$e3,$c7,$e3,$e1,$85,$c7
	dc.b	$ff,$c9,$ff,$c1,$3f,$fd,$1f,$fc,$14,$a6,$35,$55,$41,$47,$05,$43
	dc.b	$81,$af,$85,$8f,$82,$8e,$f0,$aa,$eb,$40,$02,$ff,$ff,$bf,$fc,$ff
	dc.b	$0d,$e3,$c7,$e3,$ff,$ff,$c7,$80,$3f,$90,$3f,$20,$05,$00,$04,$27
	dc.b	$40,$04,$aa,$a0,$af,$e0,$8f,$e4,$7f,$c2,$67,$c5,$1e,$7c,$54,$3e
	dc.b	$85,$53,$ff,$ff,$1f,$ff,$ff,$fc,$24,$e4,$74,$ae,$74,$e4,$24,$ae
	dc.b	$05,$88,$5b,$0e,$54,$0e,$55,$44,$11,$ff,$fb,$55,$7f,$5f,$ff,$7f
	dc.b	$fb,$df,$fd,$df,$fa,$ff,$fb,$ff,$c0,$7a,$af,$fc,$cc,$10,$cd,$1e
	dc.b	$78,$fa,$5f,$fa,$78,$1e,$5f,$bb,$65,$bc,$15,$ab,$f7,$fa,$b3,$27
	dc.b	$ff,$ff,$55,$7f,$58,$27,$58,$0f,$c7,$55,$f7,$0a,$a0,$ca,$aa,$ff
	dc.b	$7a,$af,$33,$33,$f3,$33,$33,$37,$4d,$f2,$e3,$c7,$e3,$f2,$4d,$c7
	dc.b	$fe,$59,$ff,$c9,$ab,$f0,$bf,$f9,$14,$9f,$f9,$55,$41,$50,$05,$50
	dc.b	$09,$87,$15,$97,$0a,$a0,$c2,$aa,$80,$7a,$ae,$33,$33,$b3,$fe,$33
	dc.b	$0f,$00,$40,$e2,$47,$e2,$40,$00,$47,$82,$7f,$80,$3f,$ab,$f0,$a0
	dc.b	$01,$27,$7f,$f0,$00,$34,$27,$c0,$37,$fc,$7f,$98,$43,$cc,$0e,$76
	dc.b	$5a,$e1,$2c,$af,$cc,$cc,$2c,$cc,$cc,$ca,$28,$54,$60,$46,$60,$54
	dc.b	$28,$46,$3a,$5c,$06,$08,$10,$c2,$5c,$d2,$fe,$ff,$24,$eb,$df,$ff
	dc.b	$cf,$e3,$df,$e7,$ef,$f3,$ff,$f9,$f7,$7e,$df,$da,$cc,$cc,$ec,$cc
	dc.b	$cc,$cf,$9b,$99,$ff,$bf,$ff,$99,$9b,$bf,$c7,$ab,$b8,$25,$ff,$fd
	dc.b	$f3,$25,$fd,$ff,$23,$c4,$47,$c4,$2f,$d0,$87,$f8,$43,$80,$c0,$80
	dc.b	$7f,$c2,$03,$ff,$ff,$9f,$ff,$ff,$fd,$85,$e1,$c5,$e3,$c5,$e1,$85
	dc.b	$e3,$fc,$33,$ff,$99,$aa,$15,$bf,$fd,$14,$b8,$01,$ff,$c1,$c0,$05
	dc.b	$c0,$01,$80,$07,$88,$03,$80,$c0,$80,$40,$c2,$00,$33,$33,$b3,$fe
	dc.b	$33,$0f,$ff,$ff,$c7,$e3,$c7,$ff,$ff,$e3,$c4,$3f,$80,$7f,$aa,$15
	dc.b	$a0,$05,$27,$6c,$36,$00,$3e,$02,$28,$2b,$ac,$6e,$08,$41,$80,$56
	dc.b	$6d,$14,$02,$01,$43,$33,$33,$53,$33,$33,$30,$24,$e4,$48,$d2,$48
	dc.b	$e4,$24,$d2,$06,$20,$38,$38,$7f,$be,$60,$04,$01,$fb,$d9,$fe,$ff
	dc.b	$0f,$d7,$d7,$c3,$df,$f7,$f7,$ff,$af,$f2,$fb,$c0,$ff,$fe,$ff,$ff
	dc.b	$bf,$fe,$ff,$0f,$1e,$78,$f6,$6f,$f6,$78,$1e,$6f,$47,$ca,$40,$6a
	dc.b	$ff,$7f,$d0,$03,$fd,$ff,$23,$d5,$57,$d2,$9f,$ca,$17,$fd,$8f,$a2
	ds.b	24700
