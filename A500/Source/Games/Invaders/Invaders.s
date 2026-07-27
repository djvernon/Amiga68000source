	section Invaders,code_c
	opt	o+,o3-


ship.speed	equ	2
missile.speed	equ	8
missile.starty	equ	215


start	bset	#1,$bfe001	low pass filter off

;	move.l	4,a6
;	move.l	#40960,d0	4*40*256
;	move.l	#$10002,d1	clear chip
;	jsr	-198(a6)	AllocMem
;	move.l	d0,screenmem
;	move.l	d0,screen2
;	move.l	d0,a1
;
;	lea	screendata,a0
;	move.l	a0,screen1
;
;	move.l	#10239,d1	((4*40*256)/4)-1
;copylp	move.l	(a0)+,(a1)+
;	dbra	d1,copylp
;
;	bsr	set.screen

	move.l	4,a6				*
	move.l	#81920,d0	2*4*40*256	*
	move.l	#$10002,d1	clear chip	*
	jsr	-198(a6)	AllocMem	*
	move.l	d0,screenmem			*
	move.l	d0,screen1			*
	add.l	#40960,d0			*
	move.l	d0,screen2			*
	bsr	set.screen			*

	move.l	4,a6
	lea	grafname(pc),a1
	moveq	#0,d0
	jsr	-552(a6)	openlibrary
	tst.l	d0
	beq	end
	move.l	d0,gfxbase
	move.l	d0,a6
	move.l	38(a6),oldcopper
	jsr	-456(a6)	ownblitter

	lea	$dff000,a6
	move.w	intenar(a6),ints	save system interrupt status
	move.w	#$3fdf,intena(a6)
	move.w	#$c020,intena(a6)	enable vertical blanking interrupt
	move.w	#$03ff,dmacon(a6)	DMA off

	lea	coltab,a0		initialise colours
	lea	$dff180,a1
	moveq	#31,d0
nextcol	move.w	(a0)+,(a1)+
	dbra	d0,nextcol

	move.w	#$4200,bplcon0(a6)	initialise screen
	move.w	#$2c81,diwstrt(a6)
	move.w	#$2cc1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	move.w	#0,bplcon1(a6)
	move.w	#$24,bplcon2(a6)
	move.w	#120,bpl1mod(a6)
	move.w	#120,bpl2mod(a6)


;""""""""""""""""""""""""""
;" SET UP SPRITE POINTERS "
;"			  "
;""""""""""""""""""""""""""

	move.l	#ship0,d0
	move.w	d0,sp0l
	swap	d0
	move.w	d0,sp0h
	move.l	#ship1,d0
	move.w	d0,sp1l
	swap	d0
	move.w	d0,sp1h

	move.l	#sprite2,d0
	move.w	d0,sp2l
	swap	d0
	move.w	d0,sp2h
	move.l	#sprite3,d0
	move.w	d0,sp3l
	swap	d0
	move.w	d0,sp3h
	move.l	#sprite4,d0
	move.w	d0,sp4l
	swap	d0
	move.w	d0,sp4h
	move.l	#sprite5,d0
	move.w	d0,sp5l
	swap	d0
	move.w	d0,sp5h
	move.l	#sprite6,d0
	move.w	d0,sp6l
	swap	d0
	move.w	d0,sp6h
	move.l	#sprite7,d0
	move.w	d0,sp7l
	swap	d0
	move.w	d0,sp7h


;"""""""""""""""""""""""""""""""""""""""""""""""""
;" SET NEW COPPER LOCATION AND LEVEL 3 INTERRUPT "
;"						 "
;"""""""""""""""""""""""""""""""""""""""""""""""""

	move.l	#new,cop1lc(a6)
	clr.w	copjmp1(a6)
	move.w	#$83e0,dmacon(a6)	DMA on (bitplane, copper,
;						blitter, sprite)
	move.l	$6c,oldlevel3
	move.l	#level3,$6c

	lea	variables(pc),a5

	lea	buffer,a0
	move.l	a0,buffer1(a5)
	add.l	#7168,a0
	move.l	a0,buffer2(a5)
	add.l	#7168,a0
	move.l	a0,buffer3(a5)
	add.l	#96,a0
	move.l	a0,buffer4(a5)

	move.w	#152,shipx(a5)
	move.w	#39,aliensx(a5)
	move.w	#36,aliensy(a5)

	move.w	aliensx(a5),oldaliensx2(a5)
	move.w	aliensy(a5),oldaliensy2(a5)
	move.l	screen2,a0
	move.l	buffer2(a5),a1
	bsr	save.bgnd1a


;""""""""""""""""""
;" MAIN GAME LOOP "
;"		  "
;""""""""""""""""""

mainloop
	bsr	player.missile
	bsr	save.bgnd1
	bsr	save.bgnd2
	bsr	draw.aliens
	bsr	draw.missile
	bsr	swap.pointers
;	bsr	update.aliens
	bsr	restore.bgnd1
	bsr	restore.bgnd2
	bsr	move.aliens

	btst	#6,$bfe001
	bne.s	mainloop


exit	move.l	oldlevel3,$6c

	move.l	oldcopper,cop1lc(a6)

	move.w	#$8210,dmacon(a6)	disk DMA on
	move.w	ints,d0
	ori.w	#$c000,d0	set SET and INTEN bits
	move.w	d0,intena(a6)	restore system interrupt status

	move.l	gfxbase,a6
	jsr	-462(a6)	disownblitter
	move.l	gfxbase,a1
	move.l	4,a6
	jsr	-414(a6)	closelibrary

end	move.l	4,a6
	move.l	screenmem,a1
;	move.l	#40960,d0	4*40*256
	move.l	#81920,d0	2*4*40*256	*
	jsr	-210(a6)	FreeMem

	bclr	#1,$bfe001	low pass filter on
	moveq	#0,d0
	rts


;"""""""""""""""""""""
;" LEVEL 3 INTERRUPT "
;"		     "
;"""""""""""""""""""""

level3	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$20,intreq(a6)

	bsr	move.ship

out	movem.l	(sp)+,d0-d7/a0-a6
	rte


;""""""""""""""""""""
;" GAME SUBROUTINES "
;"		    "
;""""""""""""""""""""

swap.pointers
	btst	#6,dmaconr(a6)
	bne.s	swap.pointers
wait1	btst	#0,$dff005	wait for bottom of screen
	beq.s	wait1
wait2	cmpi.b	#45,vhposr(a6)
	bcs.s	wait2

	bchg	#0,restore.bit(a5)

	move.l	buffer1(a5),d0
	move.l	buffer2(a5),buffer1(a5)
	move.l	d0,buffer2(a5)

	move.l	buffer3(a5),d0
	move.l	buffer4(a5),buffer3(a5)
	move.l	d0,buffer4(a5)

	move.w	oldaliensx1(a5),d0
	move.w	oldaliensy1(a5),d1
	move.w	oldaliensx2(a5),oldaliensx1(a5)
	move.w	oldaliensy2(a5),oldaliensy1(a5)
	move.w	d0,oldaliensx2(a5)
	move.w	d1,oldaliensy2(a5)

	move.w	oldmissilex1(a5),d0
	move.w	oldmissiley1(a5),d1
	move.w	oldmissilex2(a5),oldmissilex1(a5)
	move.w	oldmissiley2(a5),oldmissiley1(a5)
	move.w	d0,oldmissilex2(a5)
	move.w	d1,oldmissiley2(a5)

	move.l	screen1,d0
	move.l	screen2,screen1
	move.l	d0,screen2

set.screen
	lea	new(pc),a0
	moveq	#3,d1
nextpl	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40,d0		next bitplane
	addq.w	#8,a0		update pointer to copper list
	dbra	d1,nextpl
	rts

************************************************************

move.ship
	move.w	joy1dat(a6),d0
	btst	#9,d0		joystick left
	beq.s	try.right
	cmp.w	#0,shipx(a5)	is ship at far left of screen ?
	ble.s	no.move
	subq.w	#ship.speed,shipx(a5)
	bsr.s	x.to.sprite
	rts

try.right
	btst	#1,d0		joystick right
	beq.s	no.move
	cmp.w	#304,shipx(a5)	is ship at far right of screen ?
	bge.s	no.move
	addq.w	#ship.speed,shipx(a5)
	bsr.s	x.to.sprite
no.move	rts

************************************************************

x.to.sprite
	move.l	#$1300,d0		set vstart
	move.w	shipx(a5),d1
	add.w	#128,d1			hardware offset horizontal
	lsr.w	#1,d1			/2 low bit into extend
	or.w	d1,d0
	swap	d0
	roxl.w	#1,d0			get low bit of hstart into bit 0
	or.w	#$2306,d0		set vstop and MSB of vstart + vend
	move.l	d0,ship0		set control words for sprite 0
	or.w	#$80,d0			set attach bit
	move.l	d0,ship1		set control words for sprite 1
	rts

************************************************************

move.aliens
	not.b	pause.aliens(a5)	move aliens every other frame
	beq.s	no.aliens.move
	move.w	aliensx(a5),d0
	tst.b	aliens.dir(a5)
	beq.s	aliens.left
aliens.right
	addq.w	#1,d0
	cmp.w	#79,d0
	blt.s	still.right
	sf	aliens.dir(a5)
still.right
	move.w	d0,aliensx(a5)
	rts

aliens.left
	subq.w	#1,d0
	sle	aliens.dir(a5)
	move.w	d0,aliensx(a5)
no.aliens.move
	rts

************************************************************

draw.aliens
	move.l	screen1,a0
	move.w	aliensy(a5),d0
	mulu	#160,d0		y offset
	add.l	d0,a0		add y offset
	move.w	aliensx(a5),d0
	moveq	#$f,d1
	and.w	d0,d1		low four bits from x
	sub.w	d1,d0		x offset in multiples of 16 bits
	lsr.w	#3,d0		x offset in even bytes
	add.w	d0,a0		start address for screen
	lea	aliens,a2	start address for source
	move.l	a2,a1
	add.l	#13440,a1	start address for mask
	ror.w	#4,d1		shift distance
bltfin	btst	#6,dmaconr(a6)
	bne.s	bltfin
	move.l	a1,bltapth(a6)		mask
	move.l	a2,bltbpth(a6)		source data
	move.l	a0,bltcpth(a6)		source
	move.l	a0,bltdpth(a6)		destination
	move.w	d1,bltcon1(a6)
	or.w	#$fca,d1		USE A,B,C,D ; LFx : D = A.B + a.C
	move.w	d1,bltcon0(a6)
	move.l	#$ffff0000,bltafwm(a6)
	move.w	#-2,bltamod(a6)		to start of next line
	move.w	#-2,bltbmod(a6)		to start of next line
	move.w	#8,bltcmod(a6)		40-(30+2)
	move.w	#8,bltdmod(a6)		40-(30+2)
	move.w	#$7010,bltsize(a6)	112*4*64+16	1 word extra width
	rts

************************************************************

player.missile
	tst.b	missile.fired(a5)	is a missile still on the screen ?
	bne.s	move.missile
	btst	#7,$bfe001		joystick1 fire button
	bne.s	no.new.missile
	st	missile.fired(a5)	new missile active so set flag
	move.w	shipx(a5),missilex(a5)		set x position for missile
	move.w	#missile.starty,missiley(a5)	set starting y position
	st	missile.draw(a5)	set draw flag
no.new.missile
	rts

move.missile
	subq.w	#missile.speed,missiley(a5)	move missile up screen
	tst.w	missiley(a5)		is missile off top of screen ?
	blt.s	end.missile		if yes then deactivate it
	st	missile.draw(a5)	if no then set draw flag
	bra.s	no.missile
end.missile
	sf	missile.fired(a5)	missile is no longer active
no.missile
	rts

************************************************************

draw.missile
	tst.b	missile.draw(a5)
	beq	no.missile.draw
	sf	missile.draw(a5)
	move.l	screen1,a0
	move.w	missiley(a5),d0
	mulu	#160,d0		y offset
	add.l	d0,a0		add y offset
	move.w	missilex(a5),d0
	moveq	#$f,d1
	and.w	d0,d1		low four bits from x
	sub.w	d1,d0		x offset in multiples of 16 bits
	lsr.w	#3,d0		x offset in even bytes
	add.w	d0,a0		start address for screen
	move.l	a0,a3
	add.l	#40,a3		start address for bitplane 2 of screen
	lea	missilemask,a1	start address for mask
	lea	missile,a2	start address for source
	ror.w	#4,d1		shift distance
	move.w	d1,d0
	or.w	#$ee0,d0		USE A,B,C ; LFx : D = A . B+C
bltfin2	btst	#6,dmaconr(a6)
	bne.s	bltfin2
	move.l	a1,bltapth(a6)		mask
	move.l	a3,bltbpth(a6)		screen - bitplane 2
	add.l	#40,a3
	move.l	a3,bltcpth(a6)		screen - bitplane 3
	move.w	d0,bltcon0(a6)
	move.w	#0,bltcon1(a6)
	move.l	#$ffff0000,bltafwm(a6)
	move.w	#-2,bltamod(a6)		to start of next line
	move.w	#36,bltbmod(a6)		40-(2+2)
	move.w	#36,bltcmod(a6)		40-(2+2)
	move.w	#$1002,bltsize(a6)	16*4*64+2	1 word extra width
bltfin3	btst	#6,dmaconr(a6)
	bne.s	bltfin3
	btst	#5,dmaconr(a6)		test BZERO
	bne.s	no.flash		if true then no collision
	bchg	#1,$bfe001
no.flash
	move.l	a1,bltapth(a6)		mask
	move.l	a2,bltbpth(a6)		source data
	move.l	a0,bltcpth(a6)		source
	move.l	a0,bltdpth(a6)		destination
	move.w	d1,bltcon1(a6)
	or.w	#$fca,d1		USE A,B,C,D ; LFx : D = A.B + a.C
	move.w	d1,bltcon0(a6)
	move.w	#-2,bltbmod(a6)		to start of next line
	move.w	#36,bltdmod(a6)		40-(2+2)
	move.w	#$1002,bltsize(a6)	16*4*64+2	1 word extra width
no.missile.draw
	rts

************************************************************

save.bgnd1			; save screen below aliens
	move.l	screen1,a0
	move.l	buffer1(a5),a1
save.bgnd1a
	move.w	aliensy(a5),d0
	mulu	#160,d0		y offset
	add.l	d0,a0		add y offset
	move.w	aliensx(a5),d0
	and.w	#$fff0,d0	x offset in multiples of 16 bits
	lsr.w	#3,d0		x offset in even bytes
	add.w	d0,a0		start address for source
	move.w	#$9f0,d1	USE A,D ; LFx : D = A
	moveq	#0,d0
bltfin4	btst	#6,dmaconr(a6)
	bne.s	bltfin4
	move.l	a0,bltapth(a6)		source
	move.l	a1,bltdpth(a6)		destination
	move.w	d1,bltcon0(a6)
	move.w	d0,bltcon1(a6)
	move.l	#$ffffffff,bltafwm(a6)
	move.w	#8,bltamod(a6)		40-(30+2)
	move.w	d0,bltdmod(a6)
	move.w	#$7010,bltsize(a6)	112*4*64+16
	move.w	aliensx(a5),oldaliensx1(a5)
	move.w	aliensy(a5),oldaliensy1(a5)
	rts

************************************************************

restore.bgnd1			; restore screen below aliens
	move.w	oldaliensx2(a5),d0
	move.w	oldaliensy2(a5),d1
	move.l	screen1,a0
	move.l	buffer1(a5),a1
	mulu	#160,d1		y offset
	add.l	d1,a0		add y offset
	and.w	#$fff0,d0	x offset in multiples of 16 bits
	lsr.w	#3,d0		x offset in even bytes
	add.w	d0,a0		start address for destination
	move.w	#$9f0,d1	USE A,D ; LFx : D = A
	moveq	#0,d0
bltfin5	btst	#6,dmaconr(a6)
	bne.s	bltfin5
	move.l	a1,bltapth(a6)		source
	move.l	a0,bltdpth(a6)		destination
	move.w	d1,bltcon0(a6)
	move.w	d0,bltcon1(a6)
	move.l	#$ffffffff,bltafwm(a6)
	move.w	d0,bltamod(a6)
	move.w	#8,bltdmod(a6)		40-(30+2)
	move.w	#$7010,bltsize(a6)	112*4*64+16
	rts

************************************************************

save.bgnd2			; save screen below missile
	tst.b	missile.draw(a5)
	beq.s	no.missile.save
	move.b	restore.bit(a5),d2
	bset	d2,missile.restore(a5)
	move.l	screen1,a0
	move.l	buffer3(a5),a1
	move.w	missiley(a5),d0
	mulu	#160,d0		y offset
	add.l	d0,a0		add y offset
	move.w	missilex(a5),d0
	and.w	#$fff0,d0	x offset in multiples of 16 bits
	lsr.w	#3,d0		x offset in even bytes
	add.w	d0,a0		start address for source
	move.w	#$9f0,d1	USE A,D ; LFx : D = A
	moveq	#0,d0
bltfin6	btst	#6,dmaconr(a6)
	bne.s	bltfin6
	move.l	a0,bltapth(a6)		source
	move.l	a1,bltdpth(a6)		destination
	move.w	d1,bltcon0(a6)
	move.w	d0,bltcon1(a6)
	move.l	#$ffffffff,bltafwm(a6)
	move.w	#36,bltamod(a6)		40-(2+2)
	move.w	d0,bltdmod(a6)
	move.w	#$1002,bltsize(a6)	16*4*64+2
	move.w	missilex(a5),oldmissilex1(a5)
	move.w	missiley(a5),oldmissiley1(a5)
no.missile.save
	rts

************************************************************

restore.bgnd2			; restore screen below missile
	move.b	restore.bit(a5),d2
	btst	d2,missile.restore(a5)
	beq.s	no.restore.bgnd2
	bclr	d2,missile.restore(a5)
	move.w	oldmissilex1(a5),d0
	move.w	oldmissiley1(a5),d1
	move.l	screen1,a0
	move.l	buffer3(a5),a1
	mulu	#160,d1		y offset
	add.l	d1,a0		add y offset
	and.w	#$fff0,d0	x offset in multiples of 16 bits
	lsr.w	#3,d0		x offset in even bytes
	add.w	d0,a0		start address for destination
	move.w	#$9f0,d1	USE A,D ; LFx : D = A
	moveq	#0,d0
bltfin7	btst	#6,dmaconr(a6)
	bne.s	bltfin7
	move.l	a1,bltapth(a6)		source
	move.l	a0,bltdpth(a6)		destination
	move.w	d1,bltcon0(a6)
	move.w	d0,bltcon1(a6)
	move.l	#$ffffffff,bltafwm(a6)
	move.w	d0,bltamod(a6)
	move.w	#36,bltdmod(a6)		40-(2+2)
	move.w	#$1002,bltsize(a6)	16*4*64+2
no.restore.bgnd2
	rts


;""""""""""""""""""""""""""""""""""""""""
;	" THE COPPER LIST "
;	"                 "
;	"""""""""""""""""""

new	dc.w	bpl1pth		4 bitplane display
bp1h	dc.w	0,bpl1ptl
bp1l	dc.w	0,bpl2pth
bp2h	dc.w	0,bpl2ptl
bp2l	dc.w	0,bpl3pth
bp3h	dc.w	0,bpl3ptl
bp3l	dc.w	0,bpl4pth
bp4h	dc.w	0,bpl4ptl
bp4l	dc.w	0,spr0pth	set up sprite pointers now
sp0h	dc.w	0,spr0ptl
sp0l	dc.w	0,spr1pth
sp1h	dc.w	0,spr1ptl
sp1l	dc.w	0,spr2pth
sp2h	dc.w	0,spr2ptl
sp2l	dc.w	0,spr3pth
sp3h	dc.w	0,spr3ptl
sp3l	dc.w	0,spr4pth
sp4h	dc.w	0,spr4ptl
sp4l	dc.w	0,spr5pth
sp5h	dc.w	0,spr5ptl
sp5l	dc.w	0,spr6pth
sp6h	dc.w	0,spr6ptl
sp6l	dc.w	0,spr7pth
sp7h	dc.w	0,spr7ptl
sp7l	dc.w	0

	dc.w	$ffdf,$fffe	PAL enable
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

screen1		dc.l	0
screen2		dc.l	0
screenmem	dc.l	0
gfxbase		dc.l	0
oldcopper	dc.l	0
oldlevel3	dc.l	0
ints		dc.w	0

buffer1		rs.l	1
buffer2		rs.l	1
buffer3		rs.l	1
buffer4		rs.l	1
shipx		rs.w	1
aliensx		rs.w	1
aliensy		rs.w	1
oldaliensx1	rs.w	1
oldaliensy1	rs.w	1
oldaliensx2	rs.w	1
oldaliensy2	rs.w	1
aliens.dir	rs.b	1
pause.aliens	rs.b	1
missile.fired	rs.b	1
missile.draw	rs.b	1
missile.restore	rs.b	1
restore.bit	rs.b	1
missilex	rs.w	1
missiley	rs.w	1
oldmissilex1	rs.w	1
oldmissiley1	rs.w	1
oldmissilex2	rs.w	1
oldmissiley2	rs.w	1
variables.len	rs.b	0

variables	ds.b	variables.len


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

ship0	dc.w	$138c,$2306	SPR0POS,SPR0CTL
	dc.w	$0180,$02a0
	dc.w	$0180,$02a0
	dc.w	$0660,$04e0
	dc.w	$03a0,$06c0
	dc.w	$0760,$04e0
	dc.w	$02e0,$0380
	dc.w	$06a0,$0460
	dc.w	$0f50,$0af0
	dc.w	$1da8,$343c
	dc.w	$0810,$599a
	dc.w	$2184,$8991
	dc.w	$324c,$9819
	dc.w	$53ca,$2664
	dc.w	$17e8,$4422
	dc.w	$0180,$2bd4
	dc.w	$0180,$1008
	dc.w	$0000,$0000	Sprite End

ship1	dc.w	$138c,$2386	SPR1POS,SPR1CTL
	dc.w	$0460,$0000
	dc.w	$0460,$0000
	dc.w	$07e0,$0000
	dc.w	$0100,$07e0
	dc.w	$07e0,$0000
	dc.w	$0460,$0000
	dc.w	$07e0,$0000
	dc.w	$0ff0,$0000
	dc.w	$3c3c,$0180
	dc.w	$781e,$03c0
	dc.w	$d81b,$03c0
	dc.w	$c993,$03c0
	dc.w	$4992,$07e0
	dc.w	$6bd6,$07e0
	dc.w	$381c,$07e0
	dc.w	$1008,$0180
	dc.w	$0000,$0000	Sprite End

sprite2
sprite3
sprite4
sprite5
sprite6
sprite7	dc.l	0,0

missile	dc.w	$0100,$0180,$0000,$0180
	dc.w	$0240,$0200,$0180,$03c0
	dc.w	$03c0,$0200,$0180,$03c0
	dc.w	$03c0,$0200,$0180,$03c0
	dc.w	$03c0,$0200,$0180,$03c0
	dc.w	$03c0,$0200,$0180,$03c0
	dc.w	$03c0,$0200,$0180,$03c0
	dc.w	$03c0,$0200,$0180,$03c0
	dc.w	$03c0,$0200,$0180,$03c0
	dc.w	$03c0,$0200,$0180,$03c0
	dc.w	$03c0,$0200,$0180,$03c0
	dc.w	$03c0,$0200,$0180,$03c0
	dc.w	$03c0,$0200,$0180,$03c0
	dc.w	$03c0,$0200,$0180,$03c0
	dc.w	$03c0,$0200,$0180,$03c0
	dc.w	$03c0,$0200,$0180,$03c0

missilemask
	dc.w	$0180,$0180,$0180,$0180
	dc.w	$03c0,$03c0,$03c0,$03c0
	dc.w	$03c0,$03c0,$03c0,$03c0
	dc.w	$03c0,$03c0,$03c0,$03c0
	dc.w	$03c0,$03c0,$03c0,$03c0
	dc.w	$03c0,$03c0,$03c0,$03c0
	dc.w	$03c0,$03c0,$03c0,$03c0
	dc.w	$03c0,$03c0,$03c0,$03c0
	dc.w	$03c0,$03c0,$03c0,$03c0
	dc.w	$03c0,$03c0,$03c0,$03c0
	dc.w	$03c0,$03c0,$03c0,$03c0
	dc.w	$03c0,$03c0,$03c0,$03c0
	dc.w	$03c0,$03c0,$03c0,$03c0
	dc.w	$03c0,$03c0,$03c0,$03c0
	dc.w	$03c0,$03c0,$03c0,$03c0
	dc.w	$03c0,$03c0,$03c0,$03c0

aliens	incbin	Invaders.bin

buffer	ds.w	7168	4*112*16	space to save screen1 below aliens
	ds.w	7168	4*112*16	space to save screen2 below aliens
	ds.w	128	4*16*2		space to save screen1 below missile
	ds.w	128	4*16*2		space to save screen2 below missile

;screendata	incbin	Game-Screen.bin

coltab	dc.w	$000,$000,$aac,$88a,$668,$446,$224,$002
	dc.w	$400,$600,$820,$a40,$c62,$ea0,$642,$ece
	dc.w	$000,$ece,$aac,$88a,$668,$446,$224,$002
	dc.w	$400,$600,$820,$a40,$c62,$ea0,$642,$000
