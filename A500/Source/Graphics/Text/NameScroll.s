	section	NameScroll,code_c
	opt	o+,o3-



start	bset	#1,$bfe001	low pass filter off

	move.l	4.w,a6
	move.l	#2*40*256,d0
	move.l	#$10002,d1	clear chip
	jsr	-198(a6)	AllocMem
	move.l	d0,screenmem

	move.l	d0,screen1
	add.l	#40*256,d0
	move.l	d0,screen2

	move.l	4.w,a6
	jsr	-132(a6)	turn off multitasking

	lea	$dff000,a6
	move.w	intenar(a6),ints	save system interrupt status
	move.w	#$3fef,intena(a6)
	move.w	#$c010,intena(a6)	enable copper interrupt
	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	$14.w,olddbz	division-by-zero exception handler
	move.l	#rteins,$14.w	set to rte instruction

	move.l	screen2(pc),d0		set up bitplanes
	move.w	d0,bp1l
	swap	d0
	move.w	d0,bp1h

	move.w	#$1200,bplcon0(a6)	initialise screen
	move.w	#$2c81,diwstrt(a6)
	move.w	#$2cc1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	moveq	#0,d0
	move.w	d0,bplcon1(a6)
	move.w	d0,bplcon2(a6)
	move.w	d0,bpl1mod(a6)
	move.w	d0,bpl2mod(a6)



;"""""""""""""""""""""""""""""""
;" SET THE NEW COPPER LOCATION "
;"			       "
;"""""""""""""""""""""""""""""""

	move.l	4.w,a6
	lea	grafname(pc),a1
	moveq	#0,d0
	jsr	-552(a6)	openlibrary
	tst.l	d0
	beq	end
	move.l	d0,gfxbase
	move.l	d0,a6
	jsr	-456(a6)	ownblitter

	move.l	gfxbase(pc),a1
	move.l	38(a1),oldcopper

	lea	$dff000,a6
	move.l	#new,cop1lc(a6)
	clr.w	copjmp1(a6)
	move.w	#$83c0,dmacon(a6)	DMA on (bitplane, copper, blitter)



;""""""""""""""""""""""""""""""""
;" INITIALISE LEVEL 3 INTERRUPT "
;"				"
;""""""""""""""""""""""""""""""""

	move.l	$6c.w,old
	move.l	#level3,$6c.w



;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

loop	bsr	scroll
	clr.w	nextframe
wait	tst.w	nextframe
	beq.s	wait
	bsr	swap.screens
	btst	#6,$bfe001
	bne.s	loop

wait2	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait2


	move.l	old(pc),$6c.w

	move.l	oldcopper(pc),cop1lc(a6)

	move.w	#$8030,dmacon(a6)	DMA on (sprite, disk)
	move.w	ints(pc),d0
	ori.w	#$c000,d0	set SET and INTEN bits
	move.w	d0,intena(a6)	restore system interrupt status

	move.l	olddbz(pc),$14.w   restore division-by-zero exception handler

	move.l	gfxbase(pc),a6
	jsr	-462(a6)	disownblitter
	move.l	gfxbase(pc),a1
	move.l	4.w,a6
	jsr	-414(a6)	closelibrary

end	move.l	4.w,a6
	jsr	-138(a6)	turn on multitasking

	move.l	4.w,a6
	move.l	screenmem(pc),a1
	move.l	#2*40*256,d0
	jsr	-210(a6)	FreeMem

	bclr	#1,$bfe001	low pass filter on
	moveq	#0,d0
	rts



;"""""""""""""""""""""
;" LEVEL 3 INTERRUPT "
;"		     "
;"""""""""""""""""""""

level3	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$10,intreq(a6)

	move.w	#1,nextframe

	movem.l	(sp)+,d0-d7/a0-a6
rteins	rte



;"""""""""""""""
;" SUBROUTINES "
;"	       "
;"""""""""""""""

scroll	moveq	#38,d0			scroll existing characters
	lea	sine(pc),a2
	
nextcolumn
	move.l	#40*15+39,a0
	sub.l	d0,a0
	move.l	a0,a1
	add.l	screen2(pc),a0
	add.l	screen1(pc),a1
	subq.l	#1,a1
	add.l	(a2)+,a1
	add.l	(a2),a0
	moveq	#3,d1

four	moveq	#7,d2

splat	move.b	(a0),(a1)
	move.b	40(a0),40(a1)
	add.l	#80,a0
	add.l	#80,a1
	dbra	d2,splat

	add.l	#40*54,a0
	add.l	#40*54,a1
	dbra	d1,four

	dbra	d0,nextcolumn


	move.l	screen1(pc),a0		print new character
	add.l	#40*15+39,a0

	bsr.s	nextchar

	lea	letters(pc),a2
	add.w	d0,a2
	moveq	#3,d0

print	moveq	#7,d1
	move.l	a2,a1

printlp	move.b	(a1),(a0)
	move.b	(a1)+,40(a0)
	add.l	#80,a0
	dbra	d1,printlp

	add.l	#40*54,a0
	dbra	d0,print
	rts



nextchar
	move.l	textptr(pc),a1
	moveq	#0,d0
	move.b	(a1)+,d0
	cmp.b	#0,d0
	bne.s	charok
	lea	text(pc),a1
	move.b	(a1)+,d0
charok	move.l	a1,textptr
	lsl.w	#3,d0		multiply by eight
	rts



swap.screens
	move.l	screen1(pc),d0
	move.l	screen2(pc),screen1
	move.l	d0,screen2

	move.w	d0,bp1l
	swap	d0
	move.w	d0,bp1h
	rts



;""""""""""""""""""""""""""""""""""""""""
;	" THE COPPER LIST "
;	"                 "
;	"""""""""""""""""""

new	dc.w	bpl1pth		1 bitplane display
bp1h	dc.w	0,bpl1ptl
bp1l	dc.w	0

	dc.w	color0,0


	dc.w	$2c01,$ff00
	dc.w	color1,$000

	dc.w	$2d01,$ff00
	dc.w	color1,$111

	dc.w	$2e01,$ff00
	dc.w	color1,$222

	dc.w	$2f01,$ff00
	dc.w	color1,$333

	dc.w	$3001,$ff00
	dc.w	color1,$444

	dc.w	$3101,$ff00
	dc.w	color1,$555

	dc.w	$3201,$ff00
	dc.w	color1,$666

	dc.w	$3301,$ff00
	dc.w	color1,$777

	dc.w	$3401,$ff00
	dc.w	color1,$888

	dc.w	$3501,$ff00
	dc.w	color1,$888

	dc.w	$3601,$ff00
	dc.w	color1,$999

	dc.w	$3701,$ff00
	dc.w	color1,$999

	dc.w	$3801,$ff00
	dc.w	color1,$aaa

	dc.w	$3901,$ff00
	dc.w	color1,$aaa

	dc.w	$3a01,$ff00
	dc.w	color1,$bbb

	dc.w	$3b01,$ff00
	dc.w	color1,$bbb

	dc.w	$3c01,$ff00
	dc.w	color1,$ccc

	dc.w	$3d01,$ff00
	dc.w	color1,$ccc

	dc.w	$3e01,$ff00
	dc.w	color1,$ddd

	dc.w	$3f01,$ff00
	dc.w	color1,$ddd

	dc.w	$4001,$ff00
	dc.w	color1,$eee

	dc.w	$4101,$ff00
	dc.w	color1,$eee

	dc.w	$4201,$ff00
	dc.w	color1,$fff

	dc.w	$4301,$ff00
	dc.w	color1,$fff

	dc.w	$4401,$ff00
	dc.w	color1,$eee

	dc.w	$4501,$ff00
	dc.w	color1,$eee

	dc.w	$4601,$ff00
	dc.w	color1,$ddd

	dc.w	$4701,$ff00
	dc.w	color1,$ddd

	dc.w	$4801,$ff00
	dc.w	color1,$ccc

	dc.w	$4901,$ff00
	dc.w	color1,$ccc

	dc.w	$4a01,$ff00
	dc.w	color1,$bbb

	dc.w	$4b01,$ff00
	dc.w	color1,$bbb

	dc.w	$4c01,$ff00
	dc.w	color1,$aaa

	dc.w	$4d01,$ff00
	dc.w	color1,$aaa

	dc.w	$4e01,$ff00
	dc.w	color1,$999

	dc.w	$4f01,$ff00
	dc.w	color1,$999

	dc.w	$5001,$ff00
	dc.w	color1,$888

	dc.w	$5101,$ff00
	dc.w	color1,$888

	dc.w	$5201,$ff00
	dc.w	color1,$777

	dc.w	$5301,$ff00
	dc.w	color1,$666

	dc.w	$5401,$ff00
	dc.w	color1,$555

	dc.w	$5501,$ff00
	dc.w	color1,$444

	dc.w	$5601,$ff00
	dc.w	color1,$333

	dc.w	$5701,$ff00
	dc.w	color1,$222

	dc.w	$5801,$ff00
	dc.w	color1,$111

	dc.w	$5901,$ff00
	dc.w	color1,$000


	dc.w	$7201,$ff00
	dc.w	color1,$000

	dc.w	$7301,$ff00
	dc.w	color1,$111

	dc.w	$7401,$ff00
	dc.w	color1,$222

	dc.w	$7501,$ff00
	dc.w	color1,$333

	dc.w	$7601,$ff00
	dc.w	color1,$444

	dc.w	$7701,$ff00
	dc.w	color1,$555

	dc.w	$7801,$ff00
	dc.w	color1,$666

	dc.w	$7901,$ff00
	dc.w	color1,$777

	dc.w	$7a01,$ff00
	dc.w	color1,$888

	dc.w	$7b01,$ff00
	dc.w	color1,$888

	dc.w	$7c01,$ff00
	dc.w	color1,$999

	dc.w	$7d01,$ff00
	dc.w	color1,$999

	dc.w	$7e01,$ff00
	dc.w	color1,$aaa

	dc.w	$7f01,$ff00
	dc.w	color1,$aaa

	dc.w	$8001,$ff00
	dc.w	color1,$bbb

	dc.w	$8101,$ff00
	dc.w	color1,$bbb

	dc.w	$8201,$ff00
	dc.w	color1,$ccc

	dc.w	$8301,$ff00
	dc.w	color1,$ccc

	dc.w	$8401,$ff00
	dc.w	color1,$ddd

	dc.w	$8501,$ff00
	dc.w	color1,$ddd

	dc.w	$8601,$ff00
	dc.w	color1,$eee

	dc.w	$8701,$ff00
	dc.w	color1,$eee

	dc.w	$8801,$ff00
	dc.w	color1,$fff

	dc.w	$8901,$ff00
	dc.w	color1,$fff

	dc.w	$8a01,$ff00
	dc.w	color1,$eee

	dc.w	$8b01,$ff00
	dc.w	color1,$eee

	dc.w	$8c01,$ff00
	dc.w	color1,$ddd

	dc.w	$8d01,$ff00
	dc.w	color1,$ddd

	dc.w	$8e01,$ff00
	dc.w	color1,$ccc

	dc.w	$8f01,$ff00
	dc.w	color1,$ccc

	dc.w	$9001,$ff00
	dc.w	color1,$bbb

	dc.w	$9101,$ff00
	dc.w	color1,$bbb

	dc.w	$9201,$ff00
	dc.w	color1,$aaa

	dc.w	$9301,$ff00
	dc.w	color1,$aaa

	dc.w	$9401,$ff00
	dc.w	color1,$999

	dc.w	$9501,$ff00
	dc.w	color1,$999

	dc.w	$9601,$ff00
	dc.w	color1,$888

	dc.w	$9701,$ff00
	dc.w	color1,$888

	dc.w	$9801,$ff00
	dc.w	color1,$777

	dc.w	$9901,$ff00
	dc.w	color1,$666

	dc.w	$9a01,$ff00
	dc.w	color1,$555

	dc.w	$9b01,$ff00
	dc.w	color1,$444

	dc.w	$9c01,$ff00
	dc.w	color1,$333

	dc.w	$9d01,$ff00
	dc.w	color1,$222

	dc.w	$9e01,$ff00
	dc.w	color1,$111

	dc.w	$9f01,$ff00
	dc.w	color1,$000


	dc.w	$b801,$ff00
	dc.w	color1,$000

	dc.w	$b901,$ff00
	dc.w	color1,$111

	dc.w	$ba01,$ff00
	dc.w	color1,$222

	dc.w	$bb01,$ff00
	dc.w	color1,$333

	dc.w	$bc01,$ff00
	dc.w	color1,$444

	dc.w	$bd01,$ff00
	dc.w	color1,$555

	dc.w	$be01,$ff00
	dc.w	color1,$666

	dc.w	$bf01,$ff00
	dc.w	color1,$777

	dc.w	$c001,$ff00
	dc.w	color1,$888

	dc.w	$c101,$ff00
	dc.w	color1,$888

	dc.w	$c201,$ff00
	dc.w	color1,$999

	dc.w	$c301,$ff00
	dc.w	color1,$999

	dc.w	$c401,$ff00
	dc.w	color1,$aaa

	dc.w	$c501,$ff00
	dc.w	color1,$aaa

	dc.w	$c601,$ff00
	dc.w	color1,$bbb

	dc.w	$c701,$ff00
	dc.w	color1,$bbb

	dc.w	$c801,$ff00
	dc.w	color1,$ccc

	dc.w	$c901,$ff00
	dc.w	color1,$ccc

	dc.w	$ca01,$ff00
	dc.w	color1,$ddd

	dc.w	$cb01,$ff00
	dc.w	color1,$ddd

	dc.w	$cc01,$ff00
	dc.w	color1,$eee

	dc.w	$cd01,$ff00
	dc.w	color1,$eee

	dc.w	$ce01,$ff00
	dc.w	color1,$fff

	dc.w	$cf01,$ff00
	dc.w	color1,$fff

	dc.w	$d001,$ff00
	dc.w	color1,$eee

	dc.w	$d101,$ff00
	dc.w	color1,$eee

	dc.w	$d201,$ff00
	dc.w	color1,$ddd

	dc.w	$d301,$ff00
	dc.w	color1,$ddd

	dc.w	$d401,$ff00
	dc.w	color1,$ccc

	dc.w	$d501,$ff00
	dc.w	color1,$ccc

	dc.w	$d601,$ff00
	dc.w	color1,$bbb

	dc.w	$d701,$ff00
	dc.w	color1,$bbb

	dc.w	$d801,$ff00
	dc.w	color1,$aaa

	dc.w	$d901,$ff00
	dc.w	color1,$aaa

	dc.w	$da01,$ff00
	dc.w	color1,$999

	dc.w	$db01,$ff00
	dc.w	color1,$999

	dc.w	$dc01,$ff00
	dc.w	color1,$888

	dc.w	$dd01,$ff00
	dc.w	color1,$888

	dc.w	$de01,$ff00
	dc.w	color1,$777

	dc.w	$df01,$ff00
	dc.w	color1,$666

	dc.w	$e001,$ff00
	dc.w	color1,$555

	dc.w	$e101,$ff00
	dc.w	color1,$444

	dc.w	$e201,$ff00
	dc.w	color1,$333

	dc.w	$e301,$ff00
	dc.w	color1,$222

	dc.w	$e401,$ff00
	dc.w	color1,$111

	dc.w	$e501,$ff00
	dc.w	color1,$000


	dc.w	$fe01,$ff00
	dc.w	color1,$000

	dc.w	$ff01,$ff00
	dc.w	color1,$111

	dc.w	$ffdf,$fffe

	dc.w	$0001,$ff00
	dc.w	color1,$222

	dc.w	$0101,$ff00
	dc.w	color1,$333

	dc.w	$0201,$ff00
	dc.w	color1,$444

	dc.w	$0301,$ff00
	dc.w	color1,$555

	dc.w	$0401,$ff00
	dc.w	color1,$666

	dc.w	$0501,$ff00
	dc.w	color1,$777

	dc.w	$0601,$ff00
	dc.w	color1,$888

	dc.w	$0701,$ff00
	dc.w	color1,$888

	dc.w	$0801,$ff00
	dc.w	color1,$999

	dc.w	$0901,$ff00
	dc.w	color1,$999

	dc.w	$0a01,$ff00
	dc.w	color1,$aaa

	dc.w	$0b01,$ff00
	dc.w	color1,$aaa

	dc.w	$0c01,$ff00
	dc.w	color1,$bbb

	dc.w	$0d01,$ff00
	dc.w	color1,$bbb

	dc.w	$0e01,$ff00
	dc.w	color1,$ccc

	dc.w	$0f01,$ff00
	dc.w	color1,$ccc

	dc.w	$1001,$ff00
	dc.w	color1,$ddd

	dc.w	$1101,$ff00
	dc.w	color1,$ddd

	dc.w	$1201,$ff00
	dc.w	color1,$eee

	dc.w	$1301,$ff00
	dc.w	color1,$eee

	dc.w	$1401,$ff00
	dc.w	color1,$fff

	dc.w	$1501,$ff00
	dc.w	color1,$fff

	dc.w	$1601,$ff00
	dc.w	color1,$eee

	dc.w	$1701,$ff00
	dc.w	color1,$eee

	dc.w	$1801,$ff00
	dc.w	color1,$ddd

	dc.w	$1901,$ff00
	dc.w	color1,$ddd

	dc.w	$1a01,$ff00
	dc.w	color1,$ccc

	dc.w	$1b01,$ff00
	dc.w	color1,$ccc

	dc.w	$1c01,$ff00
	dc.w	color1,$bbb

	dc.w	$1d01,$ff00
	dc.w	color1,$bbb

	dc.w	$1e01,$ff00
	dc.w	color1,$aaa

	dc.w	$1f01,$ff00
	dc.w	color1,$aaa

	dc.w	$2001,$ff00
	dc.w	color1,$999

	dc.w	$2101,$ff00
	dc.w	color1,$999

	dc.w	$2201,$ff00
	dc.w	color1,$888

	dc.w	$2301,$ff00
	dc.w	color1,$888

	dc.w	$2401,$ff00
	dc.w	color1,$777

	dc.w	$2501,$ff00
	dc.w	color1,$666

	dc.w	$2601,$ff00
	dc.w	color1,$555

	dc.w	$2701,$ff00
	dc.w	color1,$444

	dc.w	$2801,$ff00
	dc.w	color1,$333

	dc.w	$2901,$ff00
	dc.w	color1,$222

	dc.w	$2a01,$ff00
	dc.w	color1,$111

	dc.w	$2b01,$ff00
	dc.w	color1,$000


	dc.w	intreq,$8010

	dc.w	$ffff,$fffe	END



;""""""""""""""""""""""
;" Hardware registers "
;"		      "
;""""""""""""""""""""""

bltddat	equ	$000
dmaconr	equ	$002
vposr	equ	$004
vhposr	equ	$006
dskdatr	equ	$008
joy0dat	equ	$00A
joy1dat	equ	$00C
clxdat	equ	$00E
adkconr	equ	$010
pot0dat	equ	$012
pot1dat	equ	$014
potgor	equ	$016
serdatr	equ	$018
dskbytr	equ	$01A
intenar	equ	$01C
intreqr	equ	$01E
dskpt	equ	$020
dsklen	equ	$024
dskdat	equ	$026
refptr	equ	$028
vposw	equ	$02A
vhposw	equ	$02C
copcon	equ	$02E
serdat	equ	$030
serper	equ	$032
potgo	equ	$034
joytest	equ	$036
strequ	equ	$038
strvbl	equ	$03A
strhor	equ	$03C
strlong	equ	$03E
bltcon0	equ	$040
bltcon1	equ	$042
bltafwm	equ	$044
bltalwm	equ	$046
bltcpth	equ	$048
bltcptl	equ	$04A
bltbpth	equ	$04C
bltbptl	equ	$04E
bltapth	equ	$050
bltaptl	equ	$052
bltdpth	equ	$054
bltdptl	equ	$056
bltsize	equ	$058
bltcmod	equ	$060
bltbmod	equ	$062
bltamod	equ	$064
bltdmod	equ	$066
bltcdat	equ	$070
bltbdat	equ	$072
bltadat	equ	$074
dsksync	equ	$07E
cop1lc	equ	$080
cop2lc	equ	$084
copjmp1	equ	$088
copjmp2	equ	$08A
copins	equ	$08C
diwstrt	equ	$08E
diwstop	equ	$090
ddfstrt	equ	$092
ddfstop	equ	$094
dmacon	equ	$096
clxcon	equ	$098
intena	equ	$09A
intreq	equ	$09C
adkcon	equ	$09E
aud0vol	equ	$0A8
aud1vol	equ	$0B8
aud2vol	equ	$0C8
aud3vol	equ	$0D8
bpl1pth	equ	$0E0
bpl1ptl	equ	$0E2
bpl2pth	equ	$0E4
bpl2ptl	equ	$0E6
bpl3pth	equ	$0E8
bpl3ptl	equ	$0EA
bpl4pth	equ	$0EC
bpl4ptl	equ	$0EE
bpl5pth	equ	$0F0
bpl5ptl	equ	$0F2
bpl6pth	equ	$0F4
bpl6ptl	equ	$0F6
bplcon0	equ	$100
bplcon1	equ	$102
bplcon2	equ	$104
bpl1mod	equ	$108
bpl2mod	equ	$10A
bpldat	equ	$110
spr0pth	equ	$120
spr0ptl	equ	$122
spr1pth	equ	$124
spr1ptl	equ	$126
spr2pth	equ	$128
spr2ptl	equ	$12A
spr3pth	equ	$12C
spr3ptl	equ	$12E
spr4pth	equ	$130
spr4ptl	equ	$132
spr5pth	equ	$134
spr5ptl	equ	$136
spr6pth	equ	$138
spr6ptl	equ	$13A
spr7pth	equ	$13C
spr7ptl	equ	$13E
spr0pos	equ	$140
spr1pos	equ	$148
spr2pos	equ	$150
spr3pos	equ	$158
spr4pos	equ	$160
spr5pos	equ	$168
spr6pos	equ	$170
spr7pos	equ	$178
spr0ctl	equ	$142
spr1ctl	equ	$14A
spr2ctl	equ	$152
spr3ctl	equ	$15A
spr4ctl	equ	$162
spr5ctl	equ	$16A
spr6ctl	equ	$172
spr7ctl	equ	$17A
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
color16	equ	$1A0



;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

screenmem	dc.l	0
screen1		dc.l	0
screen2		dc.l	0
olddbz		dc.l	0
oldcopper	dc.l	0
gfxbase		dc.l	0
ints		dc.w	0
old		dc.l	0
nextframe	dc.w	0



;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

grafname	dc.b	'graphics.library',0
		even



;"""""""""""""""""
;" GRAPHICS DATA "
;"		 "
;"""""""""""""""""

sine	dc.l	80,200,280,360,440,480,520,560,600,600
	dc.l	600,560,520,480,440,360,280,200,80,0
	dc.l	-80,-200,-280,-360,-440,-480,-520,-560,-600,-600
	dc.l	-600,-560,-520,-480,-440,-360,-280,-200,-80,0



textptr	dc.l	text
text	dc.b	$3d,$3d,$3e,$3e,$3f,$3f,$40,$40
	dc.b	"SOUL STEALERS AND DANIEL J VERNON"
	dc.b	$40,$40,$3f,$3f,$3e,$3e,$3d,$3d
	dc.b	"          "
	dc.b	0
	even



letters	dcb.b	8*$3c,0

	dc.b	0,0,0,0,0,0,0,0

	dc.b	255,0,0,0,0,0,0,0

	dc.b	255,0,255,0,0,0,0,0

	dc.b	255,0,255,0,255,0,0,0

	dc.b	255,0,255,0,255,0,255,0

	dc.b	%00011100	;A
	dc.b	%00100010
	dc.b	%01000001
	dc.b	%01111111
	dc.b	%01000001
	dc.b	%01000001
	dc.b	%01000001
	dc.b	%01100011

	dcb.b	8,0		;B

	dc.b	%00011110	;C
	dc.b	%00100001
	dc.b	%01000000
	dc.b	%01000000
	dc.b	%01000000
	dc.b	%01000000
	dc.b	%00100001
	dc.b	%00011110

	dc.b	%01111100	;D
	dc.b	%01000010
	dc.b	%01000001
	dc.b	%01000001
	dc.b	%01000001
	dc.b	%01000001
	dc.b	%01000010
	dc.b	%01111100

	dc.b	%01111111	;E
	dc.b	%01000001
	dc.b	%01000100
	dc.b	%01111100
	dc.b	%01000100
	dc.b	%01000000
	dc.b	%01000001
	dc.b	%01111111

	dcb.b	8,0		;F

	dcb.b	8,0		;G

	dcb.b	8,0		;H

	dc.b	%01111111	;I
	dc.b	%01001001
	dc.b	%00001000
	dc.b	%00001000
	dc.b	%00001000
	dc.b	%00001000
	dc.b	%01001001
	dc.b	%01111111

	dc.b	%01111111	;J
	dc.b	%01000100
	dc.b	%00000100
	dc.b	%00000100
	dc.b	%00000100
	dc.b	%00000100
	dc.b	%01000100
	dc.b	%00111000

	dcb.b	8,0		;K

	dc.b	%01000000	;L
	dc.b	%01000000
	dc.b	%01000000
	dc.b	%01000000
	dc.b	%01000000
	dc.b	%01000000
	dc.b	%01000001
	dc.b	%01111111

	dcb.b	8,0		;M

	dc.b	%01100011
	dc.b	%01010001
	dc.b	%01010001
	dc.b	%01001001
	dc.b	%01001001
	dc.b	%01000101
	dc.b	%01000101
	dc.b	%01100011

	dc.b	%00011100	;O
	dc.b	%00100010
	dc.b	%01000001
	dc.b	%01000001
	dc.b	%01000001
	dc.b	%01000001
	dc.b	%00100010
	dc.b	%00011100

	dcb.b	8,0		;P

	dcb.b	8,0		;Q

	dc.b	%01111110	;R
	dc.b	%01000001
	dc.b	%01000001
	dc.b	%01111110
	dc.b	%01000010
	dc.b	%01000001
	dc.b	%01000001
	dc.b	%01100011

	dc.b	%00111111	;S
	dc.b	%01000001
	dc.b	%00100000
	dc.b	%00011000
	dc.b	%00000100
	dc.b	%00000010
	dc.b	%01000010
	dc.b	%01111110

	dc.b	%01111111	;T
	dc.b	%01001001
	dc.b	%00001000
	dc.b	%00001000
	dc.b	%00001000
	dc.b	%00001000
	dc.b	%00001000
	dc.b	%00011100

	dc.b	%01100011	;U
	dc.b	%01000001
	dc.b	%01000001
	dc.b	%01000001
	dc.b	%01000001
	dc.b	%01000001
	dc.b	%00100010
	dc.b	%00011100

	dc.b	%01100011	;V
	dc.b	%01000001
	dc.b	%01000001
	dc.b	%00100010
	dc.b	%00100010
	dc.b	%00010100
	dc.b	%00010100
	dc.b	%00001000

	dcb.b	8,0		;W

	dcb.b	8,0		;X

	dcb.b	8,0		;Y

	dcb.b	8,0		;Z
