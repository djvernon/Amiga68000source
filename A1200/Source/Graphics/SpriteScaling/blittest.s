	section	blittest,code
	opt	c+


; 1. Test if blitter runs faster on A500 with less than four bitplane display (can blitter use odd cycles?)
; Answer - yes it does run faster with less bitplanes, so is using odd cycles.


;""""""""""""""""""""""
;" SCREEN DEFINITIONS "
;"		      "
;""""""""""""""""""""""

SCREEN_WIDTH	equ	320
SCREEN_HEIGHT	equ	200
SCREEN_DEPTH	equ	4
;;SCREEN_Y_OFFSET	equ	$48

PLANAR_SCREEN_SIZE	equ	SCREEN_WIDTH/8*SCREEN_HEIGHT*SCREEN_DEPTH
CHUNKY_SCREEN_SIZE	equ	SCREEN_WIDTH*SCREEN_HEIGHT

PLANAR_MEMORY_SIZE	equ	PLANAR_SCREEN_SIZE*3
CHUNKY_MEMORY_SIZE	equ	CHUNKY_SCREEN_SIZE

XMAX	equ	SCREEN_WIDTH
YMAX	equ	SCREEN_HEIGHT
XMID	equ	XMAX/2
YMID	equ	YMAX/2


;"""""""""""""""""""""""""""""
;" SOURCE BITMAP DEFINITIONS "
;"			     "
;"""""""""""""""""""""""""""""

BITMAP_WIDTH	equ	64	;320
BITMAP_HEIGHT	equ	64	;256
BITMAP_DEPTH	equ	4

BITMAP_SIZE	equ	BITMAP_WIDTH/8*BITMAP_HEIGHT*BITMAP_DEPTH

SOURCE_WIDTH	equ	64		* Size within bitmap
SOURCE_HEIGHT	equ	64


;"""""""""""""""""
;" START OF CODE "
;"		 "
;"""""""""""""""""

start	move.l	4.w,a6
	IFND	DEBUG
	jsr	-132(a6)		turn multitasking off
	ENDC

	IFD	TEST_CHUNKY_METHOD
* Allocate chunky screen memory

	move.l	#CHUNKY_MEMORY_SIZE,d0
	moveq	#1,d1			public
	jsr	-198(a6)		AllocMem
	move.l	d0,chunky.memory
	beq	exit_now
	ENDC

* Allocate planar screen memory

	move.l	#PLANAR_MEMORY_SIZE,d0
	move.l	#$10002,d1		clear chip
	jsr	-198(a6)		AllocMem
	move.l	d0,screen.memory
	beq	exit_free_chunky_mem

	move.l	d0,screen1
	move.l	#4*40*200,d1
	add.l	d1,d0
	move.l	d0,screen2
	add.l	d1,d0
	move.l	d0,screen3


	moveq	#0,d0
	lea	graf.name,a1
	jsr	-552(a6)		OpenLibrary
	tst.l	d0
	beq	exit_free_mem

	move.l	d0,gfxbase
	move.l	d0,a6
	IFND	DEBUG
	jsr	-456(a6)		OwnBlitter
	ENDC




;"""""""""""""""""""""""""
;" INITIALISE INTERRUPTS "
;"			 "
;"""""""""""""""""""""""""

	IFND	DEBUG
	lea	$dff000,a6
	move.w	intenar(a6),old.ints	save system interrupt status

	move.w	#$7fff,intena(a6)	disable all interrupts

	move.b	#%00010111,$bfed01	set CIA-A ICR

	move.l	$68.w,old.level2
	move.l	#new.level2,$68.w

	move.l	$6c.w,old.level3
	move.l	#new.level3,$6c.w

	move.w	#$c018,intena(a6)	enable copper and level2 interrupts


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


	lea	colour.table(pc),a0	initialise colours
	lea	color0(a6),a1
	moveq	#(1<<(SCREEN_DEPTH-1))-1,d0

set.colours
	move.l	(a0)+,(a1)+
	dbra	d0,set.colours


	move.w	#$4200,bplcon0(a6)	initialise screen
	move.w	#$4881,diwstrt(a6)
	move.w	#$10c1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	moveq	#0,d0
	move.w	d0,bplcon1(a6)
	move.w	d0,bplcon2(a6)
;;	moveq	#3*40,d0
	move.w	d0,bpl1mod(a6)
	move.w	d0,bpl2mod(a6)


	jsr	make.copper.lists	initialise copper

	move.l	copper1,cop1lch(a6)
	move.w	d0,copjmp1(a6)


	move.w	#$87c0,dmacon(a6)	DMA on
	ENDC



;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

	clr.w	d0
	move.w	#(SCREEN_HEIGHT*SCREEN_DEPTH)*64+(SCREEN_WIDTH/16),d2
	move.l	#1000,d7
main_loop
	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	main_loop

	move.l	#$ffffffff,bltafwm(a6)
	move.w	d0,bltamod(a6)
	move.w	d0,bltdmod(a6)
	move.l	#blit_area,bltapth(a6)
	move.l	screen1(pc),bltdpth(a6)
	move.w	#$19f0,bltcon0(a6)	copy and shift right one bit
	move.w	d0,bltcon1(a6)
	move.w	d2,$dff000+bltsize

.wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	.wait

	move.l	#$ffffffff,bltafwm(a6)
	move.w	d0,bltamod(a6)
	move.w	d0,bltdmod(a6)
	move.l	screen1(pc),bltapth(a6)
	move.l	#blit_area,bltdpth(a6)
	move.w	#$19f0,bltcon0(a6)	copy and shift right one bit
	move.w	d0,bltcon1(a6)
	move.w	d2,$dff000+bltsize

	subq.l	#1,d7
	bne.s	main_loop


;""""""""""""""""
;" EXIT ROUTINE	"
;"		"
;""""""""""""""""
	IFND	DEBUG
	lea	$dff000,a6
wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait


	move.w	#$7fff,intena(a6)	disable all interrupts

	move.b	#%10011010,$bfed01	restore CIA-A ICR

	move.l	old.level2,$68.w

	move.l	old.level3,$6c.w

	move.w	old.ints,d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status


	move.l	old.dbz,$14.w	restore division-by-zero handler


	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	gfxbase,a0
	move.l	38(a0),cop1lch(a6)	restore system copper

	move.w	#$87f0,dmacon(a6)	DMA on
	ENDC

	move.l	a0,a6
	IFND	DEBUG
	jsr	-462(a6)		DisownBlitter
	ENDC

	move.l	a6,a1
	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary

exit_free_mem
	move.l	#PLANAR_MEMORY_SIZE,d0
	move.l	screen.memory,a1
	jsr	-210(a6)		FreeMem

exit_free_chunky_mem
	IFD	TEST_CHUNKY_METHOD
	move.l	#CHUNKY_MEMORY_SIZE,d0
	move.l	chunky.memory(pc),a1
	jsr	-210(a6)		FreeMem
	ENDC

exit_now
	IFND	DEBUG
	jsr	-138(a6)		turn multitasking on
	ENDC

	moveq	#0,d0
	rts


test.count	dc.w	0


;"""""""""""""""""""""
;" LEVEL 2 INTERRUPT "
;"		     "
;"""""""""""""""""""""

new.level2
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	move.w	#$8,intreq+$dff000

	lea	$bfe001,a0

	btst	#3,$d00(a0)		read CIA-A ICR
	beq.s	end.level2		if key not pressed

	move.b	$c00(a0),d0		get raw key code
	not.b	d0
	ror.b	#1,d0
	move.b	d0,raw.key.code

	bset	#6,$e00(a0)		set SP to output

	moveq	#54,d0

hand.shake
	dbra	d0,hand.shake		output handshake pulse

	bclr	#6,$e00(a0)		set SP back to input

; now check for special key presses

	move.b	raw.key.code,d0

	cmp.b	#$46,d0			DELETE
	bne.s	check.help
	not.b	frames.requested
	bra.s	end.level2

check.help
	cmp.b	#$5f,d0			HELP
	bne.s	check.auto
	not.b	palette.requested
	bra.s	end.level2

check.auto
	cmp.b	#$20,d0			A
	bne.s	end.level2
	not.b	auto.move

end.level2
	move.l	(sp)+,a0
	move.l	(sp)+,d0
rte.ins	rte




;"""""""""""""""""""""
;" LEVEL 3 INTERRUPT "
;"		     "
;"""""""""""""""""""""

new.level3
	movem.l	d0-d1/a0,-(sp)
	move.w	#$10,intreq+$dff000

;	st.b	vblank.occured
	addq.w	#1,vblank.count

	IFD	NOT_USED
	lea	mouse.data,a0

	move.b	$dff00b,d0		x mouse movement
	move.b	d0,d1
	sub.b	old.mouse.x(pc),d0
	move.b	d1,old.mouse.x
	move.b	d0,(a0)+		save mouse x

	move.b	$dff00a,d0		y mouse movement
	move.b	d0,d1
	sub.b	old.mouse.y(pc),d0
	move.b	d1,old.mouse.y
	move.b	d0,(a0)			save mouse y
	ENDC

;	tst.b	auto.move
;	bne.s	end.level3

;	bsr.s	set.x.y.z.angles

end.level3
	movem.l	(sp)+,d0-d1/a0
	rte


vblank.count	dc.w	0
last.vblank.count	dc.w	0


update.screens
	move.l	screen1(pc),d0
	move.l	screen2(pc),screen1
	move.l	screen3(pc),screen2
	move.l	d0,screen3

	move.l	copper1(pc),d0
	move.l	copper2(pc),copper1
	move.l	copper3(pc),copper2
	move.l	d0,copper3

	move.l	d0,cop1lch+$dff000	set new copper list address
	rts




make.copper.lists
	move.l	screen1(pc),d0
	move.l	copper1(pc),a0
	bsr.s	init.copper

	move.l	screen2(pc),d0
	move.l	copper2(pc),a0
	bsr.s	init.copper

	move.l	screen3(pc),d0
	move.l	copper3(pc),a0
;	bra.s	init.copper




init.copper
	moveq	#4-1,d1
;	moveq	#40,d2			width of one bitplane
	move.l	#SCREEN_WIDTH/8*SCREEN_HEIGHT,d2	size of one bitplane

next.plane
	move.w	d0,6(a0)		save low word
	swap	d0
	move.w	d0,2(a0)		save high word
	swap	d0
	add.l	d2,d0			next bitplane
	addq.w	#8,a0			update pointer to copper list
	dbra	d1,next.plane
	rts




;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

screen.memory	dc.l	0
chunky.memory	dc.l	0

screen1		dc.l	0
screen2		dc.l	0
screen3		dc.l	0

copper1		dc.l	copper.list1
copper2		dc.l	copper.list2
copper3		dc.l	copper.list3

gfxbase		dc.l	0
old.ints	dc.w	0
old.level2	dc.l	0
old.level3	dc.l	0
old.dbz		dc.l	0

raw.key.code	dc.b	0
palette.requested	dc.b	0
frames.requested	dc.b	0
auto.move	dc.b	0




;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

graf.name	dc.b	'graphics.library',0
		even

colour.table
	dc.w	$000,$111,$222,$333,$444,$555,$666,$777
	dc.w	$888,$999,$aaa,$bbb,$ccc,$ddd,$eee,$fff




;""""""""""""""""""""
;" THE COPPER LISTS "
;"		    "
;""""""""""""""""""""
	section	copper,code_c

copper.list1
	dc.w	bpl1pth,0		4 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$1001,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe


copper.list2
	dc.w	bpl1pth,0		4 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$1001,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe


copper.list3
	dc.w	bpl1pth,0		4 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$1001,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe




blit_area
	dcb.w	(SCREEN_WIDTH/16)*SCREEN_HEIGHT*SCREEN_DEPTH,$1234




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
color3	equ	$186
color4	equ	$188
color8	equ	$190
color16	equ	$1a0
