	section	ArteSphere,code_c
	opt	c+


; NOTE: Program uses VERTB interrupt instead of COPPER


;DEBUG	equ	1

;	IFND	DEBUG
;	opt	o+
;	ENDC


;""""""""""""""""""""""
;" SCREEN DEFINITIONS "
;"		      "
;""""""""""""""""""""""

SCREEN_WIDTH	equ	224
SCREEN_HEIGHT	equ	224
;SCREEN_DEPTH	equ	5

; 4 bitplanes for the fixed moon graphic
PLANAR_MEMORY_SIZE	equ	SCREEN_WIDTH/8*SCREEN_HEIGHT*4
; 1 bitplane for the animated overlay
PLANE5_MEMORY_SIZE	equ	$49d4*2


;"""""""""""""""""
;" START OF CODE "
;"		 "
;"""""""""""""""""

start	move.l	4.w,a6
	IFND	DEBUG
	jsr	-132(a6)		turn multitasking off
	ENDC

* Allocate planar screen memory

	; allocate plane 1-4 memory
	move.l	#PLANAR_MEMORY_SIZE,d0
	move.l	#$10002,d1		clear chip
	jsr	-198(a6)		AllocMem
	move.l	d0,screen.memory
	beq	exit_now

	move.l	d0,screen1
	IFD	NOT_USED
	move.l	#4*40*200,d1
	add.l	d1,d0
	move.l	d0,screen2
	add.l	d1,d0
	move.l	d0,screen3
	ENDC

	; allocate plane 5 memory
	move.l	#PLANE5_MEMORY_SIZE,d0
	move.l	#$10002,d1		clear chip
	jsr	-198(a6)		AllocMem
	move.l	d0,screen.memory.plane5
	beq	exit_free_mem

	moveq	#0,d0
	lea	graf.name,a1
	jsr	-552(a6)		OpenLibrary
	tst.l	d0
	beq	exit_free_mem_plane5

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

	move.w	#$c028,intena(a6)	enable vertical blank and level2 interrupts


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


	IFD	NOT_USED
	lea	colour.table(pc),a0	initialise colours
;;	move.l	#bitmap+BITMAP_SIZE,a0
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
	ENDC


;	jsr	make.copper.lists	initialise copper

;	move.l	copper1,cop1lch(a6)
	move.l	#copper.list,cop1lch(a6)
	move.w	d0,copjmp1(a6)


	move.w	#$87c0,dmacon(a6)	DMA on
	ENDC



;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

;	bsr	init.auto.move

	bsr	gen_instruction_buffer3
	bsr	gen_instruction_buffer2
	bsr	initialise_display

	bsr	calc.y.table
;	bsr	set.sprite.pointers
;	st.b	frames.requested

main.loop
	bsr	render_frame

;	bsr	auto.move.object

	IFND	DEBUG
	jsr	keyboard.requests

; limit to 50fps (ensure at least one vertical blank has occured)
	move.w	last.vblank.count(pc),d7
wait.vblank
	cmp.w	vblank.count(pc),d7
	beq.s	wait.vblank

	move.w	vblank.count(pc),last.vblank.count
	ENDC

	btst	#6,$bfe001
	bne.s	main.loop


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

exit_free_mem_plane5
	move.l	#PLANE5_MEMORY_SIZE,d0
	move.l	screen.memory.plane5,a1
	jsr	-210(a6)		FreeMem

exit_free_mem
	move.l	#PLANAR_MEMORY_SIZE,d0
	move.l	screen.memory,a1
	jsr	-210(a6)		FreeMem

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
	move.w	#$20,intreq+$dff000

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


	IFD	NOT_USED
set.x.y.z.angles
	lea	mouse.data,a0
	btst	#2,potgor+$dff000	right mouse button
	beq.s	right.pressed

	move.b	(a0)+,d0		mouse x
	ext.w	d0
	add.w	d0,d0			word offset for tables
	add.w	d0,base.z.angle		update z angle
	and.w	#$7fe,base.z.angle

	move.b	(a0),d0			mouse y
	ext.w	d0
	add.w	d0,d0			word offset for tables
	add.w	d0,base.x.angle		update x angle
	and.w	#$7fe,base.x.angle
	rts


right.pressed
	move.b	(a0)+,d0		mouse x
	ext.w	d0
	add.w	d0,d0			word offset for tables
	add.w	d0,base.y.angle		update y angle
	and.w	#$7fe,base.y.angle

	move.b	(a0),d0			mousey
	ext.w	d0
	add.w	d0,z.offset		update z distance
	rts
	ENDC


;""""""""""""""""""""""""""""""""""""""""
;" SUBROUTINES TO PRODUCE THE 3D OBJECT	"
;"					"
;""""""""""""""""""""""""""""""""""""""""

	IFD	NOT_USED
set.sprite.pointers
	lea	copper.sprites+2(pc),a6
	move.l	#sprite.data,d7
	moveq	#8-1,d6
.loop	swap	d7
	move.w	d7,(a6)
	lea	4(a6),a6
	swap	d7
	move.w	d7,(a6)
	lea	4(a6),a6
	dbra	d6,.loop
	rts
	ENDC


;"""""""""""""""""""""
;" CALCULATE Y-TABLE "
;"		     "
;"""""""""""""""""""""

calc.y.table
	move.w	#SCREEN_HEIGHT-1,d0
	moveq	#0,d1			offset starts at zero
	moveq	#SCREEN_WIDTH/8,d2	width of one bitplane
	lea	y.table,a0

.loop	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,.loop
	rts


;""""""""""""""""""""""""""""""""""""""""
;" ARTE DEMO - IMAGE MOVING OVER SPHERE "
;"					"
;""""""""""""""""""""""""""""""""""""""""

L.157a
	bra.s   L.158e

L.157c
	swap    D0
	move.w  D3,(A0)+
	addq.w  #2,D3
	move.w  D0,(A0)+
	swap    D0
	move.w  D3,(A0)+
	addq.w  #2,D3
	move.w  D0,(A0)+
	add.l   D1,D0
L.158e
	dbra    D2,L.157c
	rts


;L.8009e
copper.list	;COP1LC
	dc.w	$1001,$fffe
	dc.w	diwstrt,$39b1
	dc.w	diwstop,$1991		display is 224 wide by 224 high
	dc.w	ddfstrt,$0050
	dc.w	ddfstop,$00b8		14 display words per line (14*16 = 224)

	dc.w	bplcon0
;L.800b4
copper.bplcon0
	dc.w	$5200
	dc.w	bplcon1,$0000
	dc.w	bplcon2,$0000
	dc.w	bpl1mod,$0000
	dc.w	bpl2mod,$0000
;L.800c6
copper.sprites
	dc.w	spr0pth,0,spr0ptl,0
	dc.w	spr1pth,0,spr1ptl,0
	dc.w	spr2pth,0,spr2ptl,0
	dc.w	spr3pth,0,spr3ptl,0
	dc.w	spr4pth,0,spr4ptl,0
	dc.w	spr5pth,0,spr5ptl,0
	dc.w	spr6pth,0,spr6ptl,0
	dc.w	spr7pth,0,spr7ptl,0

	dc.w	bpl1pth
;L.80108
copper.bitplanes
	dc.w	$0000,bpl1ptl,$0000
	dc.w	bpl2pth,$0000,bpl2ptl,$0000
	dc.w	bpl3pth,$0000,bpl3ptl,$0000
	dc.w	bpl4pth,$0000,bpl4ptl,$0000
	dc.w	bpl5pth
;L.80128
copper.bitplane5
	dc.w	$0000,bpl5ptl,$0000
	dc.w	bpl6pth,$0000,bpl6ptl,$0000

;L.80136
copper.colours
	dc.w	$0180,$0100,$0182,$0214,$0184,$0324,$0186,$0fdc,$0188,$0fba,$018a,$0f9a,$018c,$0d89,$018e,$0c78
	dc.w	$0190,$0a67,$0192,$0956,$0194,$0845,$0196,$0634,$0198,$0523,$019a,$0412,$019c,$0303,$019e,$0202
	dc.w	$01a0,$0000,$01a2,$0547,$01a4,$0657,$01a6,$0fff,$01a8,$0eee,$01aa,$0ddd,$01ac,$0ccc,$01ae,$0bbb
	dc.w	$01b0,$0aaa,$01b2,$0999,$01b4,$0888,$01b6,$0777,$01b8,$0666,$01ba,$0555,$01bc,$0444,$01be,$0333

	dc.w	$1501,$fffe
	dc.w	dmacon,$802f		sprite and audio DMA enable
;L.801be
copper.top.section
	dc.w	$18df,$fffe,$0180,$0100
	dc.w	$19df,$fffe,$0180,$0100
	dc.w	$1adf,$fffe,$0180,$0100
	dc.w	$1bdf,$fffe,$0180,$0100
	dc.w	$1cdf,$fffe,$0180,$0100
	dc.w	$1ddf,$fffe,$0180,$0100
	dc.w	$1edf,$fffe,$0180,$0100
	dc.w	$1fdf,$fffe,$0180,$0100
	dc.w	$20df,$fffe,$0180,$0100
	dc.w	$21df,$fffe,$0180,$0100
	dc.w	$22df,$fffe,$0180,$0100
	dc.w	$23df,$fffe,$0180,$0100
	dc.w	$24df,$fffe,$0180,$0100
	dc.w	$25df,$fffe,$0180,$0100
	dc.w	$26df,$fffe,$0180,$0100
	dc.w	$27df,$fffe,$0180,$0100
	dc.w	$28df,$fffe,$0180,$0100
	dc.w	$29df,$fffe,$0180,$0100
	dc.w	$2adf,$fffe,$0180,$0100
	dc.w	$2bdf,$fffe,$0180,$0100
	dc.w	$2cdf,$fffe,$0180,$0100
	dc.w	$2ddf,$fffe,$0180,$0100
	dc.w	$2edf,$fffe,$0180,$0100
	dc.w	$2fdf,$fffe,$0180,$0100
	dc.w	$30df,$fffe,$0180,$0100
	dc.w	$31df,$fffe,$0180,$0100
	dc.w	$32df,$fffe,$0180,$0100
	dc.w	$33df,$fffe,$0180,$0100
	dc.w	$34df,$fffe,$0180,$0100
	dc.w	$35df,$fffe,$0180,$0100
	dc.w	$36df,$fffe,$0180,$0100
	dc.w	$37df,$fffe,$0180,$0100

	dc.w	$38df,$fffe,bpl5ptl,$0000
;L.802c6
copper.middle
	dc.w	$0100,$0200,$0180,$0100
	dc.w	$39df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$3adf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$3bdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$3cdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$3ddf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$3edf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$3fdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$40df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$41df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$42df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$43df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$44df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$45df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$46df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$47df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$48df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$49df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$4adf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$4bdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$4cdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$4ddf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$4edf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180
;L.8042c
copper.middle.color0
	dc.w	$0411

	dc.w	$4fdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$50df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$51df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$52df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$53df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$54df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$55df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$56df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$57df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$58df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$59df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$5adf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$5bdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$5cdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$5ddf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$5edf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$5fdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$60df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$61df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$62df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$63df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$64df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$65df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$66df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$67df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$68df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$69df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$6adf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$6bdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$6cdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$6ddf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$6edf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$6fdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$70df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$71df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$72df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$73df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$74df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$75df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$76df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$77df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$78df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$79df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$7adf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$7bdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$7cdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$7ddf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$7edf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$7fdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$80df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$81df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$82df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$83df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$84df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$85df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$86df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$87df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$88df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$89df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$8adf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$8bdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$8cdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$8ddf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$8edf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$8fdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$90df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$91df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$92df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$93df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$94df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$95df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$96df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$97df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$98df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$99df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$9adf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$9bdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$9cdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$9ddf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$9edf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$9fdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$a0df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$a1df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$a2df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$a3df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$a4df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$a5df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$a6df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$a7df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$a8df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$a9df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$aadf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$abdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$acdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$addf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$aedf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$afdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$b0df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$b1df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$b2df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$b3df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$b4df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$b5df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$b6df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$b7df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$b8df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$b9df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$badf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$bbdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$bcdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$bddf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$bedf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$bfdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$c0df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$c1df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$c2df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$c3df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$c4df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$c5df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$c6df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$c7df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$c8df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$c9df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$cadf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$cbdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$ccdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$cddf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$cedf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$cfdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$d0df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$d1df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$d2df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$d3df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$d4df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$d5df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$d6df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$d7df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$d8df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$d9df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$dadf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$dbdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$dcdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$dddf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$dedf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$dfdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$e0df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$e1df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$e2df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$e3df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$e4df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$e5df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$e6df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$e7df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$e8df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$e9df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$eadf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$ebdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$ecdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$eddf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$eedf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$efdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$f0df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$f1df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$f2df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$f3df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$f4df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$f5df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$f6df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$f7df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$f8df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$f9df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$fadf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$fbdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$fcdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$fddf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$fedf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$ffdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$00df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411
	dc.w	$01df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0411

	dc.w	$02df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$03df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$04df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$05df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$06df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$07df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$08df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$09df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$0adf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$0bdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$0cdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$0ddf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$0edf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$0fdf,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$10df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$11df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$12df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$13df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$14df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$15df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
	dc.w	$16df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100
;L.810ae
copper.bottom.section
	dc.w	$17df,$fffe,bpl5ptl,$0000,$0100,$0200,$0180,$0100

	dc.w	$18df,$fffe,$0180,$0100
	dc.w	$19df,$fffe,$0180,$0100
	dc.w	$1adf,$fffe,$0180,$0100
	dc.w	$1bdf,$fffe,$0180,$0100
	dc.w	$1cdf,$fffe,$0180,$0100
	dc.w	$1ddf,$fffe,$0180,$0100
	dc.w	$1edf,$fffe,$0180,$0100
	dc.w	$1fdf,$fffe,$0180,$0100
	dc.w	$20df,$fffe,$0180,$0100
	dc.w	$21df,$fffe,$0180,$0100
	dc.w	$22df,$fffe,$0180,$0100
	dc.w	$23df,$fffe,$0180,$0100
	dc.w	$24df,$fffe,$0180,$0100
	dc.w	$25df,$fffe,$0180,$0100
	dc.w	$26df,$fffe,$0180,$0100
	dc.w	$27df,$fffe,$0180,$0100
	dc.w	$28df,$fffe,$0180,$0100
	dc.w	$29df,$fffe,$0180,$0100
	dc.w	$2adf,$fffe,$0180,$0100
	dc.w	$2bdf,$fffe,$0180,$0100
	dc.w	$2cdf,$fffe,$0180,$0100
	dc.w	$2ddf,$fffe,$0180,$0100
	dc.w	$2edf,$fffe,$0180,$0100
	dc.w	$2fdf,$fffe,$0180,$0100
	dc.w	$30df,$fffe,$0180,$0100
	dc.w	$31df,$fffe,$0180,$0100
	dc.w	$32df,$fffe,$0180,$0100
	dc.w	$33df,$fffe,$0180,$0100
	dc.w	$34df,$fffe,$0180,$0100
	dc.w	$35df,$fffe,$0180,$0100
	dc.w	$36df,$fffe,$0180,$0100
	dc.w	$37df,$fffe,$0180,$0100
	dc.w	$ffff,$fffe
	; end of copper list

sprite.data
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L.811e2	;14*32 = 448 bytes
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L.813a2	;14*32 = 448 bytes
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
L.81562	;14*32 = 448 bytes
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$6834,$0008,$174e,$0000,$17dc,$0002,$bffe,$0000,$0000
	dc.w	$0000,$0000,$0000,$000c,$0008,$7f8e


render_frame
	movem.l D0-D7/A0-A6,-(A7)
;	lea     L.eba5e,A5
;	movea.l $0(A5),A6
;	movea.l $8(A5),A0
;	movea.l $8(A0),A0
;	jsr     (A0)				play music
	bsr     L.ebc54				animate sphere overlay
	movem.l (A7)+,D0-D7/A0-A6
	rts


;L.ebc52
;	rts


; animate sphere overlay
L.ebc54
	addq.w  #1,L.ebc8c
	cmpi.w  #$5,L.ebc8c
	ble.s   L.ebc8a
	cmpi.w  #$380,L.ebc8c
	bne.s   L.ebc76
	move.b  #$10,L.ec9f2
L.ebc76
;	bsr     L.ec944			apparently not needed
	bsr     update_display_ptrs
	bsr     L.ebc8e
	bsr     L.ec88c
	bsr     L.ebde8			render sphere overlay
L.ebc8a
	rts


L.ebc8c
	dc.w	0


; third animate subroutine
L.ebc8e
	move.w  L.ebde0,D0
	tst.w   D0
	ble     L.ebd5e
	bsr     L.ebdac
	move.w  #$3,D7
	move.w  #$100,D6
	move.w  #$5200,D5
	bsr     L.ebd60
	subi.w  #$4,L.ebde0
	move.w  L.ebde2,D0
	bsr     L.ebdac
	move.w  #$3,D7
	move.w  #$100,D6
	move.w  #$5200,D5
	bsr     L.ebd86
	addi.w  #$4,L.ebde2
	lea     copper.bitplanes,A0
	move.l  L.ec050,D0
	move.w  L.ebde0,D1
	subi.w  #$20,D1
	tst.w   D1
	bgt.s   L.ebcf4
	moveq   #$0,D1
L.ebcf4
	mulu.w  #$1c,D1
	add.l   D1,D0
	move.w  #$3,D7
L.ebcfe
	move.w  D0,$4(A0)
	swap    D0
	move.w  D0,(A0)
	swap    D0
	addi.l  #$1880,D0
	lea     $8(A0),A0
	dbra    D7,L.ebcfe

	move.w  L.ebde4,D0
	tst.w   D0
	ble.s   L.ebd5e

	bsr     L.ebdac
	move.w  #$3,D7
	move.w  #$411,D6
	move.w  #$200,D5
	bsr     L.ebd60
	subi.w  #$4,L.ebde4
	move.w  L.ebde6,D0
	bsr     L.ebdac
	move.w  #$3,D7
	move.w  #$411,D6
	move.w  #$200,D5
	bsr     L.ebd86
	addi.w  #$4,L.ebde6
L.ebd5e
	rts


L.ebd60
	lea     copper.middle,A1
	cmpa.l  A1,A0
	blt.s   L.ebd78
	move.w  D5,-$6(A0)
	move.w  D6,-$2(A0)
	lea     -$10(A0),A0
	bra.s   L.ebd80


L.ebd78
	move.w  D6,-$2(A0)
	lea     -$8(A0),A0
L.ebd80
	dbra    D7,L.ebd60
	rts


L.ebd86
	lea     copper.bottom.section,A1
	cmpa.l  A1,A0
	bgt.s   L.ebd9e
	move.w  D5,$a(A0)
	move.w  D6,$e(A0)
	lea     $10(A0),A0
	bra.s   L.ebda6


L.ebd9e
	move.w  D6,$6(A0)
	lea     $8(A0),A0
L.ebda6
	dbra    D7,L.ebd86
	rts


L.ebdac
	lea     copper.top.section,A0
	cmp.w   #$20,D0
	bgt.s   L.ebdbe
	lsl.w   #3,D0
	adda.w  D0,A0
	bra.s   L.ebdde


L.ebdbe
	cmp.w   #$100,D0
	bgt.s   L.ebdd2
	subi.w  #$20,D0
	lsl.w   #4,D0
	lea     $100(A0),A0
	adda.w  D0,A0
	bra.s   L.ebdde


L.ebdd2
	subi.w  #$100,D0
	lsl.w   #3,D0
	lea     $f00(A0),A0
	adda.w  D0,A0
L.ebdde
	rts


L.ebde0
	dc.w	$0090
L.ebde2
	dc.w	$0090
L.ebde4
	dc.w	$0038
L.ebde6
	dc.w	$00e8


; render sphere overlay
L.ebde8	movea.l instruction_buffer3_ptr,A1
	adda.w  scroll_x,A1	for horizontal motion

	movea.l instruction_buffer1_ptr,A2

	lea     L.ec244,A3	array of copy routines, A1 source, A2 dest
	adda.w  scroll_y,A3	for vertical motion

	move.w  #$23,D7
L.ebe0a
	movea.l (A3)+,A4
	jsr     (A4)
	lea     $5a0(A1),A1

	movea.l (A3)+,A4
	jsr     (A4)
	lea     $5a0(A1),A1

	movea.l (A3)+,A4
	jsr     (A4)
	lea     $5a0(A1),A1

	movea.l (A3)+,A4
	jsr     (A4)
	lea     $5a0(A1),A1

	movea.l (A3)+,A4
	jsr     (A4)
	lea     $5a0(A1),A1
	dbra    D7,L.ebe0a

	move.w  L.ebf26,(A2)+
	bsr     L.ec864
	move.w  #$3,D0
	move.w  #$c,D1
	move.w  #$30,D2
	move.w  #$c0,D3
	movea.l bitplane5.hidden2.ptr,A0
	movea.l instruction_buffer1_ptr,A2
	jsr     (A2)
;	bra     L.ebe94


;	addi.w  #$4,scroll_x
;	cmpi.w  #$2d0,scroll_x
;	blt.s   L.ebe7c
;	subi.w  #$2d0,scroll_x
;L.ebe7c
;	subi.w  #$8,scroll_y
;	tst.w   scroll_y
;	bge.s   L.ebe94
;	addi.w  #$2d0,scroll_y

;L.ebe94
; horizontal scroll
	lea     sin90,A0
	adda.w  scroll_x_index,A0
	addi.w  #6,scroll_x_index
	cmpi.w  #720-6,scroll_x_index
	blt.s   .xiok
	subi.w  #720-12,scroll_x_index

.xiok	move.w  (A0),D0
	muls.w  #80*2,D0
	swap    D0
	addi.w  #80,D0		value from 0 to 160

.limitx	cmp.w   #180,D0
	blt.s   .xok
	subi.w  #180,D0
	bra.s   .limitx

.xok	add.w   D0,D0
	add.w   D0,D0
	move.w  D0,scroll_x

; vertical scroll
	lea     sin90,A0
	adda.w  scroll_y_index,A0
	addi.w  #2,scroll_y_index
	cmpi.w  #720,scroll_y_index
	bne.s   .yiok
	subi.w  #720,scroll_y_index

.yiok	move.w  (A0),D0
	muls.w  #200*2,D0
	swap    D0
	addi.w  #200,D0		value from 0 to 400

.limity	cmp.w   #180,D0
	blt.s   .yok
	subi.w  #180,D0
	bra.s   .limity

.yok	add.w   D0,D0
	add.w   D0,D0
	move.w  D0,scroll_y
	rts


L.ebf26
	rts


scroll_x
	dc.w	$0000
scroll_y
	dc.w	$0000
scroll_x_index
	dc.w	$0000
scroll_y_index
	dc.w	$0000


; A6=$32E0
;L.ebf30
initialise_display
	lea     copper.sprites,A0
	move.l  #sprite.data,D0
	moveq   #$0,D1
	moveq   #$8,D2
	move.w  #$120,D3
	jsr     L.157a		;jsr     -$72(A6)	$326e => jmp $157a
	;jsr     -$11a(A6)	$31c6 => jmp $1ae6
	;move.w  $1c(A0),D0		0
	;or.w    D0,copper.bplcon0
	movem.l A4-A6,-(A7)
	;move.l  #PLANAR_MEMORY_SIZE,D0
	;move.l  #$1,D1					$1 - chip
	;jsr     -$2a(A6)	$32b6 => jmp $78ac	allocate memory
	move.l	screen.memory(pc),d0
	move.l  D0,L.ec050
	movea.l D0,A1
	lea     L.ee0fa,A0
	move.w  #$30f,D7
L.ebf7c
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	move.l  (A0)+,(A1)+
	dbra    D7,L.ebf7c
	lea     copper.bitplanes,A0
	move.l  L.ec050,D0
	move.w  #$3,D7
L.ebfa0
	move.w  D0,$4(A0)
	swap    D0
	move.w  D0,(A0)
	swap    D0
	addi.l  #$1880,D0
	lea     $8(A0),A0
	dbra    D7,L.ebfa0

	; allocate $49d4 bytes that all lie in same $10000 byte chunk (i.e. top word of address is constant)
	;move.l  #$49d4,D0
	;move.l  #$41,D1		$40 - clear memory, $1 - chip
	;jsr     -$30(A6)	$32b0 => jmp $7950
	move.l	screen.memory.plane5(pc),d0
	add.l	#$ffff,d0
	andi.l	#$ffff0000,d0	adjust to next $10000 byte boundary

	lea     L.ec914,A0
	move.l  D0,(A0)
	move.l  D0,24(A0)

	addi.l  #$189c,D0
	move.l  D0,8(A0)
	move.l  D0,32(A0)

	addi.l  #$189c,D0
	move.l  D0,16(A0)
	move.l  D0,40(A0)

	bsr     update_display_ptrs
	lea     L.ec914,A0
	move.l  (A0),D0
	move.l  $8(A0),D1
	move.l  $10(A0),D2
	lea     L.811e2,A0
	lea     L.813a2,A1
	lea     L.81562,A2
	move.w  #$6f,D7
L.ec01a
	move.w  D0,(A0)+
	move.w  D1,(A1)+
	move.w  D2,(A2)+
	move.w  D0,(A0)+
	move.w  D1,(A1)+
	move.w  D2,(A2)+
	addi.l  #$1c,D0
	addi.l  #$1c,D1
	addi.l  #$1c,D2
	dbra    D7,L.ec01a

	lea     $dff002,A4
	move.l  #$ffffffff,$42(A4)
	movem.l (A7)+,A4-A6
	rts


L.ec050
	dc.l	0


	IFD	NOT_USED
; initialisation code, called before $ebf30
L.ec054
	lea     copper.sprites,A0
	move.l  #sprite.data,D0
	moveq   #$0,D1
	moveq   #$8,D2
	move.w  #$120,D3
	jsr     -$72(A6)		set sprite pointers (done again later)

	jsr     -$11a(A6)
	move.w  $1c(A0),D0
	or.w    D0,copper.bplcon0

	movem.l A4-A6,-(A7)
	move.l  #$2ee0,D0		12000 bytes
	move.l  #$0,D1			public
	jsr     -$2a(A6)		allocate memory
	move.l  D0,instruction_buffer1_ptr

	move.l  #$2ee0,D0		12000 bytes
	move.l  #$0,D1			public
	jsr     -$2a(A6)		allocate memory
	move.l  D0,instruction_buffer2_ptr

	move.l  #$3f480,D0		180*180*8 bytes
	move.l  #$0,D1			public
	jsr     -$2a(A6)		allocate memory
	move.l  D0,instruction_buffer3_ptr

	lea     L.ecfda,A0
	lea     copper.colours+2,A1
	moveq   #$1f,D7
L.ec0ce
	move.w  (A0)+,(A1)
	addq.w  #4,A1
	dbra    D7,L.ec0ce

	bsr     gen_instruction_buffer3
	bsr     gen_instruction_buffer2
	bsr     L.ec7e4

	move.w  #$90,L.ebde0
	move.w  #$90,L.ebde2
	move.w  #$38,L.ebde4
	move.w  #$e8,L.ebde6

	clr.w   L.ebc8c

	move.l  #L.ecf9a,L.ec9ee
	move.l  #copper.colours,L.ec9ea

	clr.w   L.ec9f6
	move.w  #3,L.ec9f4
	move.b  #0,L.ec9f2
	move.w  #32,L.ec9f8
	movem.l (A7)+,A4-A6
	rts
	ENDC


;L.ec140
instruction_buffer1_ptr
	dc.l	instruction_buffer1
;L.ec144
instruction_buffer2_ptr
	dc.l	instruction_buffer2
;L.ec148
instruction_buffer3_ptr
	dc.l	instruction_buffer3


; initialisation code, called before $ebf30
;L.ec14c
gen_instruction_buffer3
	lea     L.ec1cc,A3	plot instructions
	movea.l instruction_buffer3_ptr,A4
	lea     L.ecc16,A5	cos(180) table
	moveq   #0,D2
	move.w  #180-1,D6
L.ec164
	lea     L.ecc16,A0	cos(180) table
	lea     L.ec9fa,A1	sin table
	move.w  #180-1,D7
L.ec174
	move.w  (A0)+,D0
	muls.w  #112,D0
	swap    D0
	addi.w  #112/2,D0
	add.w   D0,D0		value from 0 to (111+56)

	; get value from 0 to 1 to 0
	move.w  (A1)+,D1	$0000,$023c,$0478,$06b3,$08ee,$0b28,$0d61,$0f99,$11d0,$1406,$163a,$186c,$1a9c,$1ccb,$1ef7,$2120
	; get value from -1 to 1
	move.w  (A5,D2.w),D3	$8001,$8006,$8015,$802e,$8050,$807d,$80b4,$80f5,$813f,$8194,$81f2,$825a,$82cc,$8348,$83cd,$845c
	muls.w  D3,D1
	swap    D1
	muls.w  #112*2,D1
	swap    D1
	addi.w  #112/2,D1
	mulu.w  #56/2,D1

	move.w  D0,D3
	lsr.w   #3,D0
	add.w   D0,D1
	not.w   D3
	andi.w  #7,D3
	add.w   D3,D3
	move.l  (A3,D3.w),(A4)+
	move.w  D1,-2(A4)
	dbra    D7,L.ec174

	; copy row again
	lea     -180*4(A4),A6
	move.w  #180-1,D7
L.ec1bc
	move.l  (A6)+,(A4)+
	dbra    D7,L.ec1bc

	addi.w  #2,D2
	dbra    D6,L.ec164
	rts

L.ec1cc	nop
	or.b    D0,0(A0)
	or.b    D1,0(A0)
	or.b    D2,0(A0)
	or.b    D3,0(A0)


; initialisation code, called before $ebf30
;L.ec1de
gen_instruction_buffer2
	lea     L.ed01a,A0
	movea.l instruction_buffer2_ptr,A1
	lea     L.ec244,A2
	move.w  #180-1,D6
L.ec1f4
	move.l  A1,(A2)+
	moveq   #0,D0
	move.w  #180-1,D7
L.ec1fc
	move.w  D0,D1
	move.w  D0,D2
	lsr.w   #3,D1
	not.w   D2
	btst    D2,(A0,D1.w)
	beq.s   L.ec218
	move.w  D0,D1
	add.w   D1,D1
	add.w   D1,D1
	move.w  L.ec23e,(A1)+
	move.w  D1,(A1)+
L.ec218
	addq.w  #1,D0
	dbra    D7,L.ec1fc

	move.w  L.ec242,(A1)+
	lea     24(A0),A0
	dbra    D6,L.ec1f4

	lea     L.ec244,A1
	move.w  #180-1,D7
L.ec236
	move.l  (A1)+,(A2)+
	dbra    D7,L.ec236
	rts

L.ec23e	move.l  0(A1),(A2)+	NOTE: Don't remove 0 from this instruction

L.ec242	rts


L.ec244	ds.l	360
;	dc.l	L.e5c9e,L.e5ce8,L.e5d2e,L.e5d78,L.e5dc2,L.e5e08,L.e5e42,L.e5e84
;	dc.l	L.e5ed2,L.e5f34,L.e5f92,L.e5fd8,L.e5fea,L.e5fec,L.e5fee,L.e5ff0
;	...
;	dc.l	L.e8262,L.e82b8,L.e8312,L.e8368,L.e5c9e,L.e5ce8,L.e5d2e,L.e5d78
;	dc.l	L.e5dc2,L.e5e08,L.e5e42,L.e5e84,L.e5ed2,L.e5f34,L.e5f92,L.e5fd8
;	...
;	dc.l	L.e7e9a,L.e7ee8,L.e7f3a,L.e7f8c,L.e7fda,L.e8020,L.e8062,L.e80c8
;	dc.l	L.e8116,L.e8164,L.e81ba,L.e8214,L.e8262,L.e82b8,L.e8312,L.e8368


	IFD	NOT_USED
; initialisation code, called before $ebf30
; initalise main section of copper list (section that changes color0 and bpl5ptl)
L.ec7e4
	lea     copper.top.section,A0
	move.w  #$18df,D0
	move.w  #$1f,D7
L.ec7f2
	move.w  D0,(A0)+
	addi.w  #$100,D0
	move.w  #$fffe,(A0)+
	move.w  #$180,(A0)+
	move.w  #$100,(A0)+
	dbra    D7,L.ec7f2

	move.w  #$df,D7
L.ec80c
	move.w  D0,(A0)+
	addi.w  #$100,D0
	move.w  #$fffe,(A0)+
	move.w  #bpl5ptl,(A0)+
	move.w  #0,(A0)+
	move.w  #$100,(A0)+
	move.w  #$200,(A0)+
	move.w  #$180,(A0)+
	move.w  #$100,(A0)+
	dbra    D7,L.ec80c

	move.w  #$1f,D7
L.ec836
	move.w  D0,(A0)+
	addi.w  #$100,D0
	move.w  #$fffe,(A0)+
	move.w  #$180,(A0)+
	move.w  #$100,(A0)+
	dbra    D7,L.ec836

	lea     copper.middle.color0,A0
	move.w  #$b3,D7
L.ec856
	move.w  #$411,(A0)
	lea     $10(A0),A0
	dbra    D7,L.ec856
	rts
	ENDC


L.ec864
	lea     $dff002,A4
L.ec86a
	btst    #$6,(A4)
	bne.s   L.ec86a
	clr.w   $64(A4)
	move.l  #$1000000,$3e(A4)
	move.l  bitplane5.hidden1.ptr,$52(A4)
	move.w  #$1c0e,$56(A4)
	rts


; fourth animate subroutine
; copies bpl5ptl values into copper list
L.ec88c
	lea     $dff002,A4
L.ec892
	btst    #$6,(A4)
	bne.s   L.ec892
	move.l  #$e,$62(A4)
	move.l  #$9f00000,$3e(A4)
	move.l  source.data.ptr,$4e(A4)
	move.l  #copper.middle-2,$52(A4)	address of first bpl5ptl value in copper list
	move.w  #$3801,$56(A4)
	rts


; second animate subroutine
update_display_ptrs
;L.ec8c0
	addq.w  #8,L.ec912
	cmpi.w  #24,L.ec912
	bne.s   L.ec8d6
	clr.w   L.ec912
L.ec8d6
	lea     L.ec914,A0
	adda.w  L.ec912(PC),A0
	move.l  (A0)+,D0
	move.l  (A0)+,source.data.ptr
	move.l  (A0),bitplane5.hidden2.ptr
	move.l  8(A0),bitplane5.hidden1.ptr
	lea     copper.bitplane5,A0
	move.w  D0,4(A0)
	swap    D0
	move.w  D0,(A0)
	rts


;L.ec906
source.data.ptr	dc.l	0
;L.ec90a
bitplane5.hidden1.ptr	dc.l	0
;L.ec90e
bitplane5.hidden2.ptr	dc.l	0

L.ec912	dc.w	0
L.ec914	dc.l	0,L.811e2
	dc.l	0,L.813a2
	dc.l	0,L.81562
	dc.l	0,L.811e2
	dc.l	0,L.813a2
	dc.l	0,L.81562


; first animate subroutine
; apparently not needed (possible fade routine)
L.ec944
	tst.w   L.ec9f6
	beq.s   L.ec956
	subq.w  #1,L.ec9f6
	bra     L.ec9e8

L.ec956
	move.w  L.ec9f4(PC),L.ec9f6
	tst.b   L.ec9f2
	bne.s   L.ec96a
	bra     L.ec9e8

L.ec96a
	subq.b  #1,L.ec9f2
	movea.l L.ec9ee(PC),A1
	movea.l L.ec9ea(PC),A0
	lea     $2(A0),A0
	move.w  L.ec9f8,D4
	subq.w  #1,D4
L.ec984
	move.w  (A0),D0
	move.w  (A1)+,D2
	move.w  D0,D1
	move.w  D2,D3
	andi.w  #$f,D1
	andi.w  #$f,D3
	cmp.w   D1,D3
	beq.s   L.ec9a0
	blt.s   L.ec99e
	addq.w  #1,(A0)
	bra.s   L.ec9a0


L.ec99e
	subq.w  #1,(A0)
L.ec9a0
	move.w  D0,D1
	move.w  D2,D3
	lsr.w   #4,D1
	lsr.w   #4,D3
	andi.w  #$f,D1
	andi.w  #$f,D3
	cmp.w   D1,D3
	beq.s   L.ec9c0
	blt.s   L.ec9bc
	addi.w  #$10,(A0)
	bra.s   L.ec9c0


L.ec9bc
	subi.w  #$10,(A0)
L.ec9c0
	move.w  D0,D1
	move.w  D2,D3
	lsr.w   #8,D1
	lsr.w   #8,D3
	andi.w  #$f,D1
	andi.w  #$f,D3
	cmp.w   D1,D3
	beq.s   L.ec9e0
	blt.s   L.ec9dc
	addi.w  #$100,(A0)
	bra.s   L.ec9e0


L.ec9dc
	subi.w  #$100,(A0)
L.ec9e0
	lea     $4(A0),A0
	dbra    D4,L.ec984
L.ec9e8
	rts


L.ec9ea
	dc.l	copper.colours
L.ec9ee
	dc.l	L.ecf9a
L.ec9f2
	dc.w	0
L.ec9f4
	dc.w	3
L.ec9f6
	dc.w	0
L.ec9f8
	dc.w	32

L.ec9fa
; sin table, one value per degree, 90 values
	dc.w	$0000,$023c,$0478,$06b3,$08ee,$0b28,$0d61,$0f99,$11d0,$1406,$163a,$186c,$1a9c,$1ccb,$1ef7,$2120
	dc.w	$2348,$256c,$278d,$29ac,$2bc7,$2dde,$2ff2,$3203,$340f,$3618,$381c,$3a1c,$3c17,$3e0d,$3fff,$41ec
	dc.w	$43d3,$45b6,$4793,$496a,$4b3b,$4d07,$4ecd,$508c,$5246,$53f9,$55a5,$574b,$58e9,$5a81,$5c12,$5d9c
	dc.w	$5f1e,$6099,$620c,$6378,$64dc,$6638,$678d,$68d9,$6a1d,$6b58,$6c8b,$6db6,$6ed9,$6ff2,$7103,$720b
	dc.w	$730a,$7401,$74ee,$75d2,$76ad,$777e,$7847,$7905,$79bb,$7a67,$7b09,$7ba2,$7c31,$7cb7,$7d33,$7da5
	dc.w	$7e0d,$7e6b,$7ec0,$7f0b,$7f4b,$7f82,$7faf,$7fd2,$7feb,$7ffa
sin90
; sin(90)
	dc.w	$7fff,$7ffa,$7feb,$7fd2,$7faf,$7f82,$7f4c,$7f0b,$7ec0,$7e6c,$7e0d,$7da5,$7d33,$7cb8,$7c32,$7ba3
	dc.w	$7b0a,$7a68,$79bc,$7906,$7848,$777f,$76ae,$75d3,$74ef,$7402,$730c,$720d,$7104,$6ff4,$6eda,$6db8
	dc.w	$6c8d,$6b5a,$6a1e,$68da,$678e,$663a,$64de,$637a,$620e,$609b,$5f20,$5d9e,$5c14,$5a83,$58ec,$574d
	dc.w	$55a7,$53fb,$5248,$508f,$4ecf,$4d0a,$4b3e,$496c,$4795,$45b8,$43d6,$41ee,$4002,$3e10,$3c19,$3a1e
	dc.w	$381e,$361a,$3412,$3206,$2ff5,$2de1,$2bca,$29ae,$2790,$256f,$234a,$2123,$1efa,$1cce,$1a9f,$186f
	dc.w	$163d,$1409,$11d3,$0f9c,$0d64,$0b2b,$08f1,$06b6,$047b,$023f
; sin(180)
	dc.w	$0003,$fdc7,$fb8c,$f950,$f715,$f4db
	dc.w	$f2a2,$f06a,$ee33,$ebfd,$e9c9,$e797,$e567,$e338,$e10c,$dee2,$dcbb,$da97,$d876,$d657,$d43c,$d225
	dc.w	$d010,$ce00,$cbf4,$c9eb,$c7e7,$c5e7,$c3ec,$c1f5,$c004,$be17,$bc2f,$ba4d,$b870,$b699,$b4c7,$b2fb
	dc.w	$b136,$af76,$adbd,$ac0a,$aa5d,$a8b8,$a719,$a581,$a3f0,$a266,$a0e4,$9f69,$9df6,$9c8a,$9b26,$99c9
	dc.w	$9875,$9729,$95e5,$94a9,$9376,$924b,$9129,$900f,$8efe,$8df6,$8cf7,$8c01,$8b14,$8a2f,$8955,$8883
	dc.w	$87bb,$86fc,$8646,$859a,$84f8,$845f,$83cf,$834a,$82ce,$825c,$81f4,$8195,$8141,$80f6,$80b5,$807e
	dc.w	$8051,$802e,$8015,$8006
L.ecc16
; cos table, one value per degree (starting at cos(180))
; sin(270)
	dc.w	$8001,$8006,$8015,$802e,$8050,$807d,$80b4,$80f5,$813f,$8194,$81f2,$825a,$82cc,$8348,$83cd,$845c
	dc.w	$84f5,$8597,$8643,$86f9,$87b7,$8880,$8951,$8a2c,$8b10,$8bfd,$8cf3,$8df2,$8efa,$900b,$9124,$9247
	dc.w	$9371,$94a4,$95e0,$9724,$9870,$99c4,$9b20,$9c84,$9df0,$9f63,$a0de,$a260,$a3ea,$a57a,$a712,$a8b1
	dc.w	$aa57,$ac03,$adb6,$af6f,$b12e,$b2f4,$b4c0,$b691,$b868,$ba45,$bc27,$be0f,$bffc,$c1ed,$c3e4,$c5df
	dc.w	$c7df,$c9e3,$cbeb,$cdf8,$d008,$d21c,$d434,$d64f,$d86d,$da8e,$dcb3,$deda,$e103,$e32f,$e55e,$e78e
	dc.w	$e9c0,$ebf4,$ee2a,$f061,$f299,$f4d2,$f70c,$f947,$fb82,$fdbe
; sin(360)
	dc.w	$0000,$023c,$0478,$06b3,$08ee,$0b28
	dc.w	$0d61,$0f99,$11d0,$1406,$163a,$186c,$1a9c,$1ccb,$1ef7,$2120,$2348,$256c,$278d,$29ac,$2bc7,$2dde
	dc.w	$2ff2,$3203,$340f,$3618,$381c,$3a1c,$3c17,$3e0d,$3fff,$41ec,$43d3,$45b6,$4793,$496a,$4b3b,$4d07
	dc.w	$4ecd,$508c,$5246,$53f9,$55a5,$574b,$58e9,$5a81,$5c12,$5d9c,$5f1e,$6099,$620c,$6378,$64dc,$6638
	dc.w	$678d,$68d9,$6a1d,$6b58,$6c8b,$6db6,$6ed9,$6ff2,$7103,$720b,$730a,$7401,$74ee,$75d2,$76ad,$777e
	dc.w	$7847,$7905,$79bb,$7a67,$7b09,$7ba2,$7c31,$7cb7,$7d33,$7da5,$7e0d,$7e6b,$7ec0,$7f0b,$7f4b,$7f82
	dc.w	$7faf,$7fd2,$7feb,$7ffa
; sin(450)
	dc.w	$7fff,$7ffa,$7feb,$7fd2,$7faf,$7f82,$7f4c,$7f0b,$7ec0,$7e6c,$7e0d,$7da5
	dc.w	$7d33,$7cb8,$7c32,$7ba3,$7b0a,$7a68,$79bc,$7906,$7848,$777f,$76ae,$75d3,$74ef,$7402,$730c,$720d
	dc.w	$7104,$6ff4,$6eda,$6db8,$6c8d,$6b5a,$6a1e,$68da,$678e,$663a,$64de,$637a,$620e,$609b,$5f20,$5d9e
	dc.w	$5c14,$5a83,$58ec,$574d,$55a7,$53fb,$5248,$508f,$4ecf,$4d0a,$4b3e,$496c,$4795,$45b8,$43d6,$41ee
	dc.w	$4002,$3e10,$3c19,$3a1e,$381e,$361a,$3412,$3206,$2ff5,$2de1,$2bca,$29ae,$2790,$256f,$234a,$2123
	dc.w	$1efa,$1cce,$1a9f,$186f,$163d,$1409,$11d3,$0f9c,$0d64,$0b2b,$08f1,$06b6,$047b,$023f
; sin(540)
	dc.w	$0003,$fdc7
	dc.w	$fb8c,$f950,$f715,$f4db,$f2a2,$f06a,$ee33,$ebfd,$e9c9,$e797,$e567,$e338,$e10c,$dee2,$dcbb,$da97
	dc.w	$d876,$d657,$d43c,$d225,$d010,$ce00,$cbf4,$c9eb,$c7e7,$c5e7,$c3ec,$c1f5,$c004,$be17,$bc2f,$ba4d
	dc.w	$b870,$b699,$b4c7,$b2fb,$b136,$af76,$adbd,$ac0a,$aa5d,$a8b8,$a719,$a581,$a3f0,$a266,$a0e4,$9f69
	dc.w	$9df6,$9c8a,$9b26,$99c9,$9875,$9729,$95e5,$94a9,$9376,$924b,$9129,$900f,$8efe,$8df6,$8cf7,$8c01
	dc.w	$8b14,$8a2f,$8955,$8883,$87bb,$86fc,$8646,$859a,$84f8,$845f,$83cf,$834a,$82ce,$825c,$81f4,$8195
	dc.w	$8141,$80f6,$80b5,$807e,$8051,$802e,$8015,$8006
; sin(630)
	dc.w	$8001,$8006,$8015,$802e,$8050,$807d,$80b4,$80f5
	dc.w	$813f,$8194,$81f2,$825a,$82cc,$8348,$83cd,$845c,$84f5,$8597,$8643,$86f9,$87b7,$8880,$8951,$8a2c
	dc.w	$8b10,$8bfd,$8cf3,$8df2,$8efa,$900b,$9124,$9247,$9371,$94a4,$95e0,$9724,$9870,$99c4,$9b20,$9c84
	dc.w	$9df0,$9f63,$a0de,$a260,$a3ea,$a57a,$a712,$a8b1,$aa57,$ac03,$adb6,$af6f,$b12e,$b2f4,$b4c0,$b691
	dc.w	$b868,$ba45,$bc27,$be0f,$bffc,$c1ed,$c3e4,$c5df,$c7df,$c9e3,$cbeb,$cdf8,$d008,$d21c,$d434,$d64f
	dc.w	$d86d,$da8e,$dcb3,$deda,$e103,$e32f,$e55e,$e78e,$e9c0,$ebf4,$ee2a,$f061,$f299,$f4d2,$f70c,$f947
	dc.w	$fb82,$fdbe
; sin(720)

L.ecf9a
	dc.w	$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100
	dc.w	$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100,$0100

	IFD	NOT_USED
; colour palette
L.ecfda
	dc.w	$0100,$0214,$0324,$0fdc,$0fba,$0f9a,$0d89,$0c78,$0a67,$0956,$0845,$0634,$0523,$0412,$0303,$0202
	dc.w	$0000,$0547,$0657,$0fff,$0eee,$0ddd,$0ccc,$0bbb,$0aaa,$0999,$0888,$0777,$0666,$0555,$0444,$0333
	ENDC

; graphic data (animated text) for fifth bitplane
L.ed01a	dc.w	$0000,$0000,$0000,$3f00,$0e0e,$0400,$0300,$e000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$1f00
	dc.w	$01ce,$1800,$0300,$6000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$1f00,$003e,$7800,$0300,$6000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$1f80,$003c,$f000,$0300,$3000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0f80,$003c,$7000,$0300,$0e00,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0780
	dc.w	$003c,$7000,$0100,$3000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$03c0,$003c,$7000,$0100,$f000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$01c0,$003c,$6000,$0303,$e001,$c000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$00e0,$007c,$6000,$0187,$fc00,$e000,$0000,$0000,$0000,$0000,$0000,$0000,$0038
	dc.w	$07cc,$6000,$0180,$0fc0,$e000,$0000,$0000,$0000,$0000,$0000,$0000,$0007,$f800,$0000,$0000,$003f
	dc.w	$e000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$e000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0c00,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$1c00,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$1c03,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0c03,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0803,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0003,$0807,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$8006,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$8006,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$c006,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$c000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$6000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$7000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$3000,$c01c,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0300,$3e01,$807c,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0780,$1fff,$81f8,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$07c0,$007f,$0fe0,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$00e0,$0007,$8f00,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0078,$0703,$c000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$001c,$1d80,$e000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$001e,$7980,$7000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0003,$bbbb,$8000,$3ffc,$f1c0,$7000,$0007,$7777,$0000,$0000,$0000,$0000,$0003,$bbbb,$8000
	dc.w	$3fe0,$e1c0,$3800,$0007,$7777,$0000,$0000,$0000,$0000,$0003,$bbbb,$8000,$0001,$c1c0,$1f00,$0007
	dc.w	$7777,$0000,$0000,$0000,$0000,$0003,$bbbb,$8000,$0003,$81c0,$1e00,$0007,$7777,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0007,$0180,$1800,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0007,$0180,$3800,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$000e,$0380,$3800,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$000e,$0700,$3000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$001e,$0700,$7000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$003e,$0400,$6300,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$03fe,$0000,$e3e0,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0fff,$0003,$e1f0,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0e0f,$000f,$e030,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$000f,$807e,$7000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0007,$c1f8,$1800,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$000f,$ffe0,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0018,$ff80,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0307,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$8307,$8000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$8303,$8000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0001,$8001,$c000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0003,$8000,$c000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0007,$0000,$c000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0006,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0006,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0001,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$8000,$0070,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$0000,$00fe,$0000,$0004,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0002,$0000,$01e1,$8000,$0006,$0000,$0078,$0000,$0000,$0000,$0000,$0000
	dc.w	$01e2,$6000,$03c0,$8000,$0003,$8000,$01f0,$0000,$0000,$0000,$0000,$0000,$039c,$9000,$0700,$c000
	dc.w	$0001,$e000,$06e0,$0000,$0000,$0000,$0000,$0000,$0305,$1000,$0e00,$e000,$0000,$f000,$1840,$0000
	dc.w	$0000,$0000,$0000,$0000,$0209,$1008,$dc01,$f000,$0000,$7c00,$7d80,$0000,$0000,$0000,$0000,$0000
	dc.w	$020b,$1198,$bc01,$e000,$0000,$6780,$3e1e,$0000,$0000,$0000,$0000,$0000,$0112,$d311,$7803,$c000
	dc.w	$0000,$24e0,$009b,$00f0,$f0f0,$f0f0,$f0f0,$f0f0,$f0e4,$3722,$7007,$8000,$0000,$3438,$0199,$80f0
	dc.w	$f0f0,$f0f0,$f0f0,$f0f0,$f024,$1e44,$e00f,$0000,$00c0,$140e,$0199,$00f0,$f0f0,$f0f0,$f0f0,$f0f0
	dc.w	$f004,$32cd,$c01e,$0000,$01c0,$1403,$81cc,$00f0,$f0f0,$f0f0,$f0f0,$f0f0,$f003,$e599,$c03c,$0000
	dc.w	$02c0,$1c40,$e0de,$0800,$0000,$0000,$0000,$0000,$0000,$873b,$8078,$0000,$06c0,$0cc0,$78d8,$1800
	dc.w	$0000,$0000,$0000,$0000,$0000,$0d53,$00f0,$0000,$0480,$0dc0,$3ce8,$1800,$0000,$0000,$0000,$0000
	dc.w	$0000,$09b3,$01c0,$0000,$0800,$0740,$0efc,$3000,$0000,$0000,$0000,$0000,$0000,$0326,$0780,$0000
	dc.w	$3800,$0600,$1ee6,$2000,$0000,$0000,$0000,$0000,$0000,$0266,$0f00,$0000,$1800,$0300,$3883,$4000
	dc.w	$0000,$0000,$0000,$0000,$0000,$044c,$3c00,$0000,$0c00,$01c0,$6001,$8000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00cc,$f000,$0000,$e600,$0070,$c000,$0000,$0000,$0000,$0000,$0000,$0000,$009b,$c000,$0000
	dc.w	$f600,$001f,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$00ff,$0000,$7000,$7200,$0004,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0010,$0001,$8000,$2000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0002,$0000,$4000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0004,$0000
	dc.w	$8000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0008,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0018,$3000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$001c,$c000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$003f,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0038,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0fe0,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$007f,$e000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$7f00,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$07e0,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$007c,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$601f
	dc.w	$e000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$1c0f,$fe00,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0f07,$fc00,$e000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$03e1,$f800,$e000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$01f0
	dc.w	$f001,$8000,$0020,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$2000,$7001,$0000,$01e0,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$3000,$2000,$0000,$07e0,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$1000,$0000,$7e00,$38c0,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0001,$c100,$c0c0,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0003,$8081,$8080,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0007,$0000,$0000,$0003,$0041,$8100,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$001e,$0000,$0000,$0002,$0020,$0600,$0000,$0000,$0000,$0000,$0000,$0000,$0036,$0000,$0000
	dc.w	$0004,$0020,$1c00,$0000,$0000,$0000,$0000,$0000,$0000,$00e6,$0000,$0000,$0004,$0030,$3000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$018c,$0000,$0000,$0004,$0078,$7c00,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0208,$0000,$0000,$0002,$00f0,$03c0,$0000,$0000,$0000,$0000,$0000,$0000,$0408,$0000,$0000
	dc.w	$0003,$01c0,$0078,$0000,$0000,$0000,$0000,$0000,$0000,$1818,$0000,$0000,$0001,$ff80,$000e,$0000
	dc.w	$0000,$0080,$0000,$0000,$0000,$2018,$0000,$0000,$0000,$0300,$001e,$0000,$0000,$c3e0,$0000,$0000
	dc.w	$0000,$6038,$0000,$0000,$0000,$0600,$001c,$0000,$0003,$f3f0,$0000,$0000,$0000,$8030,$0000,$0000
	dc.w	$0000,$0400,$0038,$0000,$0007,$fff8,$0000,$0000,$0001,$8030,$0000,$0c00,$0000,$0800,$0070,$0000
	dc.w	$0007,$fff8,$0000,$0000,$0003,$0030,$0000,$1800,$0000,$0800,$00e0,$0000,$0007,$fff8,$0000,$0000
	dc.w	$0007,$0030,$0000,$3000,$0000,$100c,$00c0,$0000,$0007,$fff8,$0000,$0000,$0007,$8030,$0001,$e000
	dc.w	$0000,$301c,$0180,$0000,$0003,$fff0,$0000,$0000,$0003,$c030,$0007,$2000,$0000,$0014,$0300,$0000
	dc.w	$0000,$ffe0,$0000,$0000,$0000,$e030,$0078,$4000,$0000,$0004,$0600,$0000,$0000,$7fe0,$0000,$0000
	dc.w	$0000,$7000,$0080,$8000,$0000,$0004,$0400,$0000,$0000,$1fc0,$0000,$0000,$0000,$3c00,$80c1,$8000
	dc.w	$0000,$0000,$0800,$0000,$0000,$07c0,$0000,$0000,$0000,$0e01,$8001,$0000,$0000,$0002,$1000,$0000
	dc.w	$0000,$0380,$0000,$0000,$0000,$0306,$8002,$0000,$0000,$0002,$2000,$0000,$0000,$0180,$0000,$0000
	dc.w	$0000,$0184,$8002,$0000,$0000,$0000,$8000,$0000,$0004,$c080,$0000,$0000,$0000,$4068,$9004,$0000
	dc.w	$0000,$0000,$0000,$0000,$000f,$e000,$0000,$0000,$0000,$8038,$bc05,$0c00,$0000,$0000,$0000,$0000
	dc.w	$000f,$e000,$0000,$0000,$0000,$807c,$b20a,$1800,$0000,$0000,$0000,$0000,$000f,$c000,$0000,$0000
	dc.w	$0000,$80d3,$e2ca,$3000,$0000,$0000,$0000,$0000,$0003,$c000,$0000,$0000,$0000,$4301,$e492,$7000
	dc.w	$0000,$0000,$0000,$0000,$0000,$8000,$0000,$0000,$0000,$7c00,$c594,$c000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0935,$8000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0927,$8000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0027,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0002,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0006,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0004,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$000c,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0008,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0008,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0010,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0010,$0000
	dc.w	$0000,$0000,$0003,$c000,$0000,$0000,$0000,$0000,$0000,$0000,$0010,$0000,$0000,$0000,$003f,$8080
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0010,$0000,$0000,$0020,$01ff,$8160,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$00e0,$1fff,$8210,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$03c0,$f7ff,$0008,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$1f83,$873f,$0404
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$f71e,$0707,$0006,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0007,$861c,$0703,$0803,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$007c,$0c0c,$0700,$1003,$8000,$0000,$0000,$0000,$0000,$0000,$0000,$000f,$ffc0,$1800,$2700,$1003
	dc.w	$c000,$0000,$0000,$0000,$0000,$0000,$0000,$0007,$8000,$3800,$f700,$3001,$c000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0007,$0000,$7001,$f700,$2001,$e000,$0000,$0000,$0000,$0000,$0000,$0000,$0007
	dc.w	$8000,$6003,$f700,$6001,$e000,$0000,$0000,$0000,$0000,$0000,$0000,$0003,$8000,$e00d,$f700,$6001
	dc.w	$e000,$0000,$0000,$0000,$0000,$0000,$0000,$0001,$e000,$c011,$e700,$6003,$8000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$3f00,$7001,$8020,$e700,$e000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$3ff0
	dc.w	$0003,$8040,$c700,$e000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$3f8f,$0003,$0080,$c300,$e000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$3f00,$f007,$0300,$0300,$e000,$0000,$0000,$0000,$0000


;"""""""""""""""""""""""""""""""""""""""
;" PRINT PLAYER POSITION AND DIRECTION "
;"				       "
;"""""""""""""""""""""""""""""""""""""""

	IFD	NOT_USED
print.player.pos
	move.l	player.x(pc),d0
	lea	.pos.text+2(pc),a0
	bsr	make.hex.long2

	move.l	player.z(pc),d0
	lea	.pos.text+13(pc),a0
	bsr	make.hex.long2

	move.w	player.y.angle(pc),d0
	lea	.pos.text+24(pc),a0
	bsr	make.hex.word2

;	move.w	wall.x.start(pc),d0
;	lea	.pos.text+31(pc),a0
;	bsr	make.hex.word2

	lea	.pos.text(pc),a0
	moveq	#0,d0
	move.w	#200-8,d1
	bra	print


.pos.text	dc.b	'X 00000000 Z 00000000 A 0000 V 0000',0
	even
	ENDC


;"""""""""""""""""""""
;" OTHER SUBROUTINES "
;"		     "
;"""""""""""""""""""""

keyboard.requests
	tst.b	frames.requested
	beq.s	no.request1

	bsr	frames.per.sec

no.request1
	tst.b	palette.requested
	beq.s	no.request2

	bsr.s	display.palette
;	bsr	update.screens

palette.wait
	tst.b	palette.requested
	bne.s	palette.wait

no.request2
	rts




display.palette
	moveq	#2,d0			start y
	moveq	#2-1,d1			2 rows
;;	clr.w	fill.colour+2		start colour at 0

next.row
	moveq	#4,d2			start x
	moveq	#8-1,d3			8 columns

next.column
;;	bsr.s	fill.box

;;	addq.w	#4,fill.colour+2	next colour
	add.w	#40,d2			next start x
	dbra	d3,next.column

	add.w	#25,d0			next start y
	dbra	d1,next.row
	rts




fill.box
	movem.w	d0-d3,-(sp)

	move.w	d2,d3
	add.w	#30,d3			31 pixels wide
	moveq	#20-1,d1		20 pixels tall

;;	lea	fill.coords(pc),a1
	move.w	d0,(a1)+		save start y

fill.box.loop
	move.w	d2,(a1)+		save start x
	move.w	d3,(a1)+		save end x
	dbra	d1,fill.box.loop

;;	bsr	fill

	movem.w	(sp)+,d0-d3
	rts




print	move.l	screen1(pc),a1		d0 = x, d1 = y
	add.w	d1,d1			a0 = text ending with 0
	lea	y.table(pc),a2
	add.w	(a2,d1.w),d0
	add.w	d0,a1			screen start address
	moveq	#0,d1
	move.w	#40,d2			bytes per line

print.loop
	move.b	(a0)+,d0		get next character
	beq.s	end.print

	sub.b	#32,d0			ASCII value for space
	ext.w	d0
	lsl.w	#3,d0			8 bytes per character of font
	lea	font(pc,d0.w),a3	source start address

	moveq	#8-1,d0			count-1
	move.l	a1,a2

char.loop
	move.b	(a3)+,(a2)		copy byte of character, bitplane 1
;;	move.b	d1,40(a2)		bitplane 2
;;	move.b	d1,80(a2)		bitplane 3
;;	move.b	d1,120(a2)		bitplane 4

	add.w	d2,a2			next screen line
	dbra	d0,char.loop

	addq.w	#1,a1			next column
	bra.s	print.loop

end.print
	rts



; Spectrum font, characters 32-126, each 8*8 pixels

font	dc.b	$00,$00,$00,$00,$00,$00,$00,$00
	dc.b	$00,$10,$10,$10,$10,$00,$10,$00
	dc.b	$00,$24,$24,$00,$00,$00,$00,$00
	dc.b	$00,$24,$7e,$24,$24,$7e,$24,$00
	dc.b	$00,$08,$3e,$28,$3e,$0a,$3e,$08
	dc.b	$00,$62,$64,$08,$10,$26,$46,$00
	dc.b	$00,$10,$28,$10,$2a,$44,$3a,$00
	dc.b	$00,$08,$10,$00,$00,$00,$00,$00
	dc.b	$00,$04,$08,$08,$08,$08,$04,$00
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




make.hex.word			; d0.w = number
	lea	hex.text(pc),a0
make.hex.word2
	moveq	#4-1,d1
	bra.s	make.hex

make.hex.long			; d0.l = number
	lea	hex.text(pc),a0
make.hex.long2
	moveq	#8-1,d1

make.hex
	lea	hex.digits(pc),a1

.loop	move.w	d0,d2
	and.w	#$f,d2
	move.b	(a1,d2.w),(a0,d1.w)
	ror.l	#4,d0
	dbra	d1,.loop
	rts


hex.digits
	dc.b	'0123456789ABCDEF'



hex.text
	ds.b	9
	even




make.decimal
	and.l	#$ffff,d0		d0.w = number (0-65535)
	move.w	#10000,d1		start with 10000's
	lea	decimal.text(pc),a0
	moveq	#0,d4			miss off leading zeros

make.dec.loop
	move.l	d0,d2
	divu	d1,d2			calculate digit

	bne.s	save.digit		if digit is not zero then save it
	tst.b	d4			if flag is zero
	bne.s	save.digit
	move.b	#' ',(a0)+		then miss this zero digit
	bra.s	next.position

save.digit
	moveq	#1,d4			don't miss off any more zeros
	move.b	d2,d3
	add.b	#48,d3			offset for ASCII digits
	move.b	d3,(a0)+		save decimal digit

	mulu	d1,d2			move digit back to correct place
	sub.l	d2,d0			remove from original number

next.position
	ext.l	d1
	divu	#10,d1			next decimal position
	cmp.w	#1,d1			have we reached units ?
	bne.s	make.dec.loop		loop back if not

	add.b	#48,d0			offset for ASCII digits
	move.b	d0,(a0)			save units
	rts



decimal.text
	ds.b	6




*""""""""""""""""""""
*" PRINT FRAME RATE "
*"		    "
*""""""""""""""""""""

frames.per.sec			; using horiz. sync. pulse counter in CIA-B
				; it is a 24-bit counter
	move.b	$bfda00,d0		get counter into latch
	move.b	$bfd900,d0		bits 8-15 of counter
	lsl.w	#8,d0			into correct position
	move.b	$bfd800,d0		bits 0-7 of counter

	move.w	d0,d1
	sub.w	old.counter(pc),d1	get counter difference
	move.w	d0,old.counter		save for next time

	move.l	#156250,d0		pulses per second * 10
	divu	d1,d0			frames per second * 10

	bsr.s	make.decimal

	lea	decimal.text+4(pc),a0
	lea	frames.text+7(pc),a1
	move.b	(a0),(a1)
	move.b	#'.',-(a1)		insert decimal point
	move.w	-(a0),-(a1)

	lea	frames.text(pc),a0
	moveq	#32,d0			x
	moveq	#0,d1			y
	bra	print



old.counter
	dc.w	0



frames.text
	dc.b	'F/S     ',0
	even




	IFD	NOT_USED
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
	ENDC




;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

screen.memory	dc.l	0
screen.memory.plane5	dc.l	0

screen1		dc.l	0
	IFD	NOT_USED
screen2		dc.l	0
screen3		dc.l	0

copper1		dc.l	copper.list1
copper2		dc.l	copper.list2
copper3		dc.l	copper.list3
	ENDC

gfxbase		dc.l	0
old.ints	dc.w	0
old.level2	dc.l	0
old.level3	dc.l	0
old.dbz		dc.l	0

raw.key.code	dc.b	0
palette.requested	dc.b	0
frames.requested	dc.b	0
auto.move	dc.b	0

;vblank.occured	dc.b	0,0




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

y.table	ds.w	SCREEN_HEIGHT

	IFD	NOT_USED
colour.table
	dc.w	$000,$eee,$850,$a60,$c71,$e92,$04c,$0be
	dc.w	$a10,$e20,$793,$9c4,$0c0,$fd0,$567,$9ab
	ENDC

; graphic data (moon picture) for first four bitplanes
L.ee0fa	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0660,$0660,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0005,$5dfc,$6013,$6000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00aa,$aaa6,$3dba,$d900,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0a80
	dc.w	$0054,$7ff7,$26d0,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$aa00,$a28a,$257e
	dc.w	$f759,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0006,$8003,$005e,$58e7,$01fe,$a000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0034,$4389,$441a,$8582,$f80d,$f400,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$01c0,$193e,$2f7a,$011f,$0823,$f680,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0455,$7c00,$57f2,$809b,$240d,$7160,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$382e,$e604,$1ee9,$0038,$ae00,$06cc,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$e155,$5741,$0f54,$0200,$d3ba,$a1e1,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0002,$0bc0,$cf12
	dc.w	$9ff2,$6503,$663c,$0bf0,$4000,$0000,$0000,$0000,$0000,$0000,$0000,$0004,$1541,$9e8d,$6feb,$5aaa
	dc.w	$1317,$277f,$1000,$0000,$0000,$0000,$0000,$0000,$0000,$0013,$5fff,$1f89,$dfc9,$ff71,$008f,$97e7
	dc.w	$6400,$0000,$0000,$0000,$0000,$0000,$0000,$009d,$8fa4,$3a80,$ab7b,$fbaa,$a054,$bcd3,$c100,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0172,$07ea,$a427,$57bb,$fffd,$4003,$e7cb,$9000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$05ea,$52d5,$51b6,$a84b,$fd6a,$aa12,$a4a1,$d2e0,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0643,$adff,$b85f,$0006,$feff,$f10f,$1f64,$f8b0,$0000,$0000,$0000,$0000,$0000,$0000,$33d4
	dc.w	$c6f7,$e01f,$8083,$e15f,$a8e7,$b7b7,$787c,$0000,$0000,$0000,$0000,$0000,$0000,$c92a,$1e3e,$d05b
	dc.w	$8003,$dc2f,$fd06,$2bf7,$debf,$0000,$0000,$0000,$0000,$0000,$0000,$9255,$df29,$8034,$e801,$8185
	dc.w	$460d,$0d3f,$ffbe,$8000,$0000,$0000,$0000,$0000,$0000,$fb3e,$7f0a,$f060,$9c30,$7bf0,$2e87,$cefb
	dc.w	$ef0a,$4000,$0000,$0000,$0000,$0000,$000c,$ec6b,$5a55,$68e8,$6af9,$7b95,$27b5,$e55f,$5680,$1000
	dc.w	$0000,$0000,$0000,$0000,$000e,$14c6,$06ab,$f8ec,$c5e9,$fd42,$8e28,$7e3f,$2ec2,$0c00,$0000,$0000
	dc.w	$0000,$0000,$003b,$048b,$7155,$5a1d,$caa2,$aa85,$4c6a,$1e57,$5e2b,$5600,$0000,$0000,$0000,$0000
	dc.w	$0004,$ed7d,$f6ff,$b965,$f41f,$e100,$1ff8,$ff0f,$7f17,$3700,$0000,$0000,$0000,$0000,$0182,$cada
	dc.w	$af7b,$a125,$c347,$5aaa,$1522,$1d9d,$17d0,$3380,$0000,$0000,$0000,$0000,$03d9,$8f1d,$4dff,$cb17
	dc.w	$8b5f,$fd55,$2af6,$1f23,$0389,$71c0,$0000,$0000,$0000,$0000,$06a6,$0a5e,$94bf,$c71b,$c5ef,$daba
	dc.w	$8c43,$3435,$c3f7,$8ec0,$0000,$0000,$0000,$0000,$03f0,$7a7c,$bddf,$7d45,$eddf,$fdfa,$6732,$e985
	dc.w	$b3fb,$5f80,$0000,$0000,$0000,$0000,$1cc3,$65f8,$7e7d,$2aab,$a8aa,$bcb8,$3f87,$04cc,$0beb,$7fd0
	dc.w	$0000,$0000,$0000,$0000,$3bf8,$cb30,$fd3f,$c001,$0657,$fcf3,$afb9,$85be,$2ff9,$df38,$0000,$0000
	dc.w	$0000,$0000,$44f6,$b540,$3e95,$e437,$86aa,$a76a,$d774,$4f9e,$517b,$ca9e,$0000,$0000,$0000,$0000
	dc.w	$d4f4,$0e30,$6b0f,$e23f,$3801,$58bf,$6bd0,$37ff,$f097,$e61f,$0000,$0000,$0000,$0001,$68ab,$106d
	dc.w	$d447,$b497,$448a,$bb59,$0774,$ffff,$8a4d,$b31f,$8000,$0000,$0000,$0003,$12ed,$f0e0,$a223,$c083
	dc.w	$0000,$1aa5,$1091,$9fdf,$0cf2,$fe4f,$8000,$0000,$0000,$0003,$a3f6,$65f1,$0155,$d555,$5510,$07ce
	dc.w	$8fcf,$3deb,$4331,$4f73,$0000,$0000,$0000,$000d,$e6d8,$031c,$0020,$eeee,$a200,$8360,$7fa1,$ffff
	dc.w	$3070,$e5f8,$d000,$0000,$0000,$0013,$5e70,$0b4d,$1555,$5525,$5554,$1882,$fb6d,$75da,$9e41,$61b9
	dc.w	$b800,$0000,$0000,$003f,$80d4,$05f2,$0a9f,$ff03,$faaf,$f39f,$3d34,$a3fc,$7c80,$44b7,$1c00,$0000
	dc.w	$0000,$0014,$7de6,$83d6,$9555,$fe0e,$3558,$d16f,$7adb,$557a,$8120,$23fe,$9c00,$0000,$0000,$002c
	dc.w	$f543,$47e5,$6fdf,$7e36,$8fcd,$d8b4,$f44a,$00ff,$6026,$c8fb,$4000,$0000,$0000,$0040,$a056,$dff0
	dc.w	$d71b,$ba33,$c750,$01ee,$e804,$275d,$31c7,$5dee,$0900,$0000,$0000,$001b,$6305,$03ff,$ffbf,$3fc1
	dc.w	$8795,$da4f,$d20c,$8bbf,$5372,$fab7,$0380,$0000,$0000,$0356,$8b2a,$9ec7,$7fab,$2a00,$d291,$7a0b
	dc.w	$d046,$0f5f,$b889,$f9f2,$8540,$0000,$0000,$0101,$14d0,$76ef,$fe61,$51c3,$2cbb,$7d0e,$62f3,$861f
	dc.w	$fbd7,$fc1e,$f3c0,$0000,$0000,$0684,$66ae,$f557,$bae8,$aadb,$467b,$9a87,$c15d,$c035,$a53f,$fbaf
	dc.w	$a5c0,$0000,$0000,$0c02,$ef08,$d38f,$f48a,$0055,$d431,$5f21,$4afa,$816b,$fabc,$ff89,$c8c0,$0000
	dc.w	$0000,$1b92,$92b1,$543e,$aa89,$2402,$242c,$dd1d,$455d,$c815,$7ce8,$fc7f,$cd68,$0000,$0000,$1283
	dc.w	$4521,$2cff,$d60e,$09a3,$8152,$5fba,$c8fe,$e006,$ffe8,$7ab6,$7ee4,$0000,$0000,$3e4b,$f287,$57f7
	dc.w	$a61a,$9193,$87da,$c62a,$855f,$c587,$5ad0,$d9ce,$7976,$0000,$0000,$2c01,$e002,$bf53,$d477,$513b
	dc.w	$576f,$c1cd,$802f,$9040,$ffc0,$bcff,$3cba,$0000,$0000,$3458,$aa15,$591f,$65fd,$b0d8,$6db9,$fdf9
	dc.w	$a957,$d5a7,$56e8,$fc4f,$ed57,$0000,$0000,$4c38,$502f,$e898,$ca7f,$09a7,$023e,$7fbc,$000f,$ef3f
	dc.w	$afb0,$3503,$f3fb,$8000,$0000,$1c5c,$b855,$64a3,$af7f,$e590,$4da3,$4da7,$aa55,$8cbf,$d7b8,$2013
	dc.w	$b7f9,$c000,$0000,$88b8,$782f,$d441,$d4e8,$8103,$5e0b,$c3d3,$d003,$999e,$8fd8,$444a,$f0ec,$c000
	dc.w	$0003,$895e,$a95b,$4112,$4354,$0098,$2941,$d6b2,$aa15,$e207,$45ea,$4397,$541d,$e000,$0002,$8078
	dc.w	$b00e,$eaa1,$2023,$0059,$2c44,$05df,$f05c,$f4be,$02fd,$f18f,$c206,$a000,$0003,$e555,$a554,$2549
	dc.w	$ea98,$800a,$3f03,$5e15,$a21f,$f576,$016e,$3fcd,$2505,$7000,$0007,$40e2,$00b8,$2bdc,$3b4e,$0007
	dc.w	$05c1,$8733,$d00d,$aeac,$02fc,$dff3,$7702,$a000,$000e,$a544,$a57b,$49d4,$59f4,$0000,$02c5,$a50b
	dc.w	$e2a1,$8da7,$407a,$8ff5,$7a43,$7800,$0007,$025d,$0232,$ebba,$af30,$300e,$02c5,$a430,$47f4,$98f2
	dc.w	$60b5,$ef79,$4ec3,$3800,$001a,$84da,$8536,$e1ed,$6061,$5004,$0140,$cbc8,$bbc6,$e3e6,$705e,$c0f8
	dc.w	$ed61,$5c00,$0017,$0044,$02f9,$cb19,$b399,$0808,$0340,$d86a,$40ea,$2ff2,$9874,$f870,$be20,$3c00
	dc.w	$000a,$94d4,$157c,$f631,$10b5,$8105,$0184,$fa0b,$a84c,$f7e5,$4100,$7d61,$5e39,$4e00,$003d,$0305
	dc.w	$02fb,$d677,$da81,$0001,$80c1,$e947,$8c53,$9770,$c068,$c0c0,$f09f,$aa00,$0042,$9642,$957a,$be43
	dc.w	$7455,$0100,$8081,$c347,$d457,$9881,$a9ae,$18e0,$30b4,$2e00,$001c,$0b2d,$0bfe,$2e06,$233a,$0000
	dc.w	$c003,$5a0b,$417a,$cc27,$d5cd,$3e0e,$7afa,$7f00,$002a,$1788,$15ef,$a7ed,$32f3,$0040,$4000,$006f
	dc.w	$78cd,$b293,$ebe4,$2cb6,$de36,$2700,$006c,$0e4c,$2ffd,$10ee,$6b79,$0088,$6183,$24bf,$bacf,$a79f
	dc.w	$dff2,$755e,$265a,$9f80,$00ca,$5585,$57ab,$80fc,$4a30,$0088,$43a0,$18d7,$d877,$323f,$e9e2,$ff4a
	dc.w	$6a74,$5580,$0184,$0f0e,$0ff4,$0003,$2a20,$0000,$37d3,$824c,$4ff7,$7669,$e7f2,$6951,$5cd9,$1580
	dc.w	$000a,$5599,$55aa,$005f,$afdc,$b484,$479f,$fd3a,$65c2,$6f60,$d81c,$d89b,$9ccc,$8140,$0080,$29eb
	dc.w	$2fd0,$2c09,$daab,$cd18,$c73b,$fc33,$3891,$4748,$7d1e,$2066,$d619,$a880,$0200,$5114,$57a9,$7aef
	dc.w	$df24,$9d83,$021f,$fe67,$e743,$9532,$d57f,$aa02,$0ed8,$c7c0,$0311,$087c,$3ff3,$f954,$0385,$c603
	dc.w	$8257,$5e7e,$7097,$83e5,$461f,$f00c,$05dc,$66a0,$010a,$d729,$57ab,$f5c7,$f155,$8002,$04fc,$7fd2
	dc.w	$5b18,$a392,$f93f,$aa18,$6fc8,$b6e0,$0713,$a57a,$2fc3,$dfc1,$f810,$800e,$05fa,$3ee4,$c83d,$0111
	dc.w	$fd1f,$f011,$d64e,$9520,$016f,$54a7,$d7ab,$6fba,$d0b0,$0004,$8778,$3cf1,$a5d0,$c59e,$793f,$aa2d
	dc.w	$8c26,$18f0,$06b7,$3be2,$bf80,$7bf8,$7201,$0002,$0308,$2c6a,$4a00,$030c,$eb1f,$f433,$2413,$0660
	dc.w	$0f6f,$5663,$d680,$37a5,$9401,$2008,$000c,$0070,$6880,$8fbd,$6827,$eab5,$2014,$8b50,$0192,$2fc0
	dc.w	$bf00,$0790,$e000,$600c,$0018,$3048,$0f43,$0594,$5694,$b50a,$6637,$9a60,$09d8,$572d,$5680,$078a
	dc.w	$1000,$e06c,$0012,$17f3,$e89f,$0cd2,$0d43,$ca14,$4127,$5558,$0398,$3f40,$bf00,$0182,$0100,$c018
	dc.w	$0036,$f1e9,$b109,$80c7,$85ba,$5c0c,$a3f3,$2da8,$1359,$5c21,$5e00,$0c06,$6001,$8010,$0041,$3118
	dc.w	$72a4,$8542,$1cc0,$c293,$812f,$fed8,$0930,$3d00,$7f80,$1cef,$b600,$0008,$0058,$411f,$e072,$d2d0
	dc.w	$6ee2,$6001,$742b,$f0c8,$07e9,$582d,$5288,$0006,$b002,$4000,$00dc,$039b,$f8f4,$b5a1,$5e76,$e906
	dc.w	$4816,$655c,$1be0,$b880,$bf40,$1a8d,$fea1,$8002,$0014,$20ff,$e86e,$d913,$aa7b,$9c04,$7533,$757c
	dc.w	$25a9,$1101,$5e28,$2c05,$fc37,$c000,$00e0,$babb,$d023,$e060,$8b56,$a78e,$73e2,$66dc,$0fd0,$e740
	dc.w	$7e00,$1843,$b42e,$8000,$9b30,$7d9f,$f9fb,$e954,$d58d,$e3f7,$e0f1,$71bc,$37bc,$a185,$5608,$719f
	dc.w	$72df,$a000,$125a,$ff0f,$e8bc,$7084,$ff44,$579e,$e2fb,$315c,$2e55,$0a80,$bb40,$7d36,$129f,$0000
	dc.w	$1416,$7c3f,$fdc9,$b04e,$58f5,$62f4,$c1cb,$a828,$1e6d,$2e01,$57a7,$4826,$a037,$0000,$00bc,$f07f
	dc.w	$f837,$1faa,$21f9,$51b2,$09ad,$097c,$602d,$7d80,$7fdf,$5c8d,$900e,$0000,$0117,$c07f,$edb1,$012d
	dc.w	$d5b8,$c973,$052a,$b8de,$1857,$04a5,$57b7,$bd1b,$3021,$0000,$005f,$a0bf,$ca13,$1c7f,$67fb,$03d2
	dc.w	$4219,$9e5e,$623f,$2d40,$bfdf,$e21e,$3032,$0000,$002e,$00bf,$c8b5,$ff73,$4cae,$8af6,$61ec,$b83e
	dc.w	$68ec,$58a1,$5fb7,$5256,$2010,$0000,$0002,$841f,$9b01,$0c02,$d6df,$303a,$168a,$a8b6,$6b2f,$1dc0
	dc.w	$3fdf,$c2e9,$8000,$0000,$0048,$200f,$896d,$c3c8,$3a3e,$f913,$619c,$1d5e,$7755,$0ead,$57af,$4932
	dc.w	$8000,$0000,$0008,$0287,$1118,$7dca,$703f,$6e1f,$0288,$d0bc,$2f96,$1340,$3fc0,$fb73,$4000,$0000
	dc.w	$0000,$0547,$0508,$b27a,$267e,$ef37,$47ec,$c85e,$25e8,$3b61,$56ab,$e78a,$0000,$0000,$0000,$2f2c
	dc.w	$16a2,$a5c6,$0e6d,$eabb,$aac6,$187e,$bfe4,$4c30,$2fd6,$d2dc,$b000,$0000,$0000,$1f00,$0300,$f91c
	dc.w	$9433,$570e,$f540,$453b,$e786,$1458,$5787,$c96e,$b800,$0000,$0000,$5800,$7547,$d93c,$d007,$ba30
	dc.w	$7085,$01f7,$6bf2,$0230,$3fb8,$f003,$bc00,$0000,$2005,$4c00,$bfed,$f829,$c48f,$d9e2,$3884,$116f
	dc.w	$55a9,$1759,$5542,$7855,$bc00,$002f,$fe6f,$c000,$3d47,$6c2e,$bbdf,$ff07,$fc8b,$b867,$8fd3,$ac30
	dc.w	$2f68,$2c05,$3800,$001b,$c6f7,$4000,$1b2a,$907f,$f78d,$df30,$3709,$a027,$d5a8,$d218,$55d5,$2800
	dc.w	$3f00,$005f,$e380,$4000,$9e04,$9885,$af5f,$3b54,$f90b,$56ef,$0bf0,$4728,$007e,$b400,$2780,$001e
	dc.w	$7c60,$c000,$7b16,$7bf7,$dea4,$7ce8,$760c,$7f2f,$45ea,$ec56,$5c7f,$5000,$0780,$001e,$f637,$8001
	dc.w	$7c3f,$9ff5,$f575,$7960,$bf29,$3357,$15ea,$ec56,$5ceb,$7800,$0780,$000d,$ce7d,$8001,$7d87,$8ff5
	dc.w	$f3dd,$7950,$db79,$3357,$43f0,$162c,$22fd,$3000,$0780,$000f,$98f5,$0000,$0fe0,$db8f,$f466,$f8c0
	dc.w	$dfae,$425b,$352a,$8d6c,$4efa,$8000,$0280,$0003,$b6e6,$0005,$55f0,$73d5,$b755,$7963,$052d,$9c5f
	dc.w	$1bf4,$cf70,$1ffd,$0001,$8080,$0008,$47c8,$a000,$2ff4,$57af,$f043,$fcd6,$0048,$ecd3,$09ea,$9464
	dc.w	$397a,$8081,$e390,$000b,$9d54,$ce85,$b5f9,$7fd7,$a43d,$eb00,$8a81,$ff97,$5ef8,$040f,$12fd,$80c0
	dc.w	$07f8,$0015,$2b68,$ebb9,$5fde,$fcaf,$c6a2,$ff80,$4ccb,$bc9b,$796a,$d7d5,$857a,$a3e0,$07f8,$000f
	dc.w	$0760,$405e,$bdf7,$fd55,$e3c4,$fb18,$02b2,$fb77,$bbfc,$3d88,$42ff,$41c0,$03f8,$001e,$0700,$20be
	dc.w	$9f89,$b8bf,$39d1,$7f5c,$b751,$2d33,$956a,$9d53,$955e,$ac80,$01f0,$003b,$0f90,$80ea,$5782,$3d57
	dc.w	$11f0,$6b6b,$3e39,$1695,$c2fd,$1af9,$02ff,$dc40,$00e3,$b9fd,$5079,$5036,$eaf0,$b8fe,$e278,$76f6
	dc.w	$5f43,$410f,$457a,$997a,$8557,$c787,$0007,$bfde,$5c54,$fe1a,$f5a0,$0dce,$789b,$bdbc,$fc7a,$e1af
	dc.w	$10fd,$02ff,$00bf,$c38f,$800f,$1a1f,$136e,$7f8c,$70c0,$153a,$4cb5,$bac1,$650e,$fbc7,$d95a,$a55a
	dc.w	$a155,$e71f,$c78f,$dec6,$00e2,$7fed,$09e0,$2398,$712a,$745f,$c7e5,$17df,$98fd,$02ff,$802f,$fd1c
	dc.w	$47bf,$f46c,$09ec,$49c4,$5c70,$1211,$2b31,$f80f,$c4b8,$87f7,$295a,$a54d,$a857,$7ab0,$07e7,$f63c
	dc.w	$044a,$e193,$eab2,$c790,$d8a2,$b897,$83a1,$67f6,$40bf,$408b,$c00b,$3f40,$6ff2,$bf3c,$029c,$f947
	dc.w	$6f41,$cb06,$7b45,$ea83,$9184,$f7ee,$795e,$a143,$a814,$3aa1,$2dfc,$74df,$03e8,$7ab4,$ea97,$175e
	dc.w	$7631,$c695,$4eb3,$6fde,$502f,$c026,$c800,$1fe0,$4bbf,$e41f,$807c,$7803,$7f03,$9eba,$2d5f,$d1cf
	dc.w	$f28c,$d3be,$0c57,$a857,$aac0,$17c5,$36f7,$67f1,$c32c,$7b03,$2a8a,$d5ff,$3425,$e735,$8509,$f01e
	dc.w	$042f,$c02d,$f400,$0b08,$a9f7,$e3a0,$c318,$6283,$7d5e,$abfb,$00df,$c05b,$9e4e,$a8d6,$5e57,$e857
	dc.w	$ee86,$033b,$49fd,$d041,$4207,$206a,$29dd,$156f,$a57e,$884d,$1f2f,$708e,$542f,$f62d,$cd34,$073b
	dc.w	$37de,$f8c9,$c23a,$1a27,$76b1,$2ff2,$c2ff,$40c5,$029e,$b55e,$2857,$ff54,$06ee,$07d1,$bd68,$d744
	dc.w	$cbe1,$3773,$2f6d,$95ad,$aa7d,$114b,$51fd,$4a0c,$370b,$ff0b,$80fe,$0b00,$9900,$0787,$8385,$d914
	dc.w	$0619,$bfff,$c379,$ff95,$b4ec,$bddc,$0915,$ff15,$867e,$15ee,$7196,$afaf,$ab77,$c0a1,$a59e,$97a9
	dc.w	$22fc,$be4b,$911e,$789c,$1a03,$ff00,$15ff,$82fc,$dbd3,$1f4f,$fde7,$00c7,$a10f,$3ff1,$c6f4,$47ff
	dc.w	$ec86,$b63c,$3485,$7e80,$54ef,$555f,$f5f9,$ab0d,$b6e5,$216d,$83a3,$53a8,$47f0,$a6bf,$b90b,$6c7c
	dc.w	$1303,$fd03,$061f,$8004,$f8fc,$d60f,$0b5e,$cc47,$6f19,$0791,$576b,$4fff,$fc2f,$c438,$1ea5,$5aa1
	dc.w	$d495,$8525,$f62f,$479f,$22c7,$65dd,$6df7,$5681,$f096,$b2c6,$8407,$f0f8,$0f02,$fd13,$21e3,$3916
	dc.w	$fc7f,$ff2c,$47a1,$d59b,$4d4b,$7f43,$e082,$30e7,$23bb,$e178,$1da5,$5ab3,$5fcc,$bfbd,$5bbb,$86dc
	dc.w	$838f,$d47e,$8046,$78a1,$ab42,$55ea,$60bf,$1af8,$0e40,$bff7,$8d5a,$0bf2,$b00f,$8a2d,$a44f,$78d4
	dc.w	$8e83,$cec0,$c78e,$a19c,$407d,$5170,$08a1,$56a0,$5268,$b1ed,$5aa0,$0c1c,$802b,$d2e9,$42d3,$e328
	dc.w	$bbea,$870c,$f473,$20b0,$00d0,$2fd0,$ffe4,$8fc2,$2800,$062c,$c445,$a9f3,$aa5b,$8580,$b1ee,$0309
	dc.w	$3474,$e1f0,$0aa8,$57aa,$fef3,$1d85,$56d4,$8e14,$f552,$4c47,$7f03,$b6a4,$55e6,$011e,$c3da,$c230
	dc.w	$03f0,$0ff5,$e1ed,$cd80,$0abc,$1bdd,$ffe0,$bd7a,$6c01,$f780,$4365,$0d90,$e2e5,$f5a0,$016a,$15ea
	dc.w	$f5e8,$76e1,$5554,$9b5b,$5554,$7062,$5f20,$a900,$7f27,$0a52,$e660,$e960,$07b8,$07fd,$7a51,$acc0
	dc.w	$022e,$71f3,$eea3,$a2f4,$2773,$0f00,$0975,$8403,$466c,$fbe0,$030a,$957a,$dfdb,$1a68,$8454,$ea04
	dc.w	$d555,$b9b0,$5273,$0640,$a133,$8245,$8f21,$ef40,$019c,$02ff,$b820,$fd00,$0003,$6553,$ae00,$64a1
	dc.w	$b1f3,$c01d,$bcd3,$2c03,$8a32,$f3c0,$03ba,$a53f,$d43e,$351a,$a012,$63a9,$aa54,$43a7,$e1e3,$991d
	dc.w	$8813,$5615,$31e1,$e5c0,$013f,$022f,$e8ea,$eb25,$0006,$1792,$6fd0,$743f,$8961,$3e32,$3f91,$370f
	dc.w	$1a6c,$f980,$00d7,$2527,$f568,$e816,$a886,$6d77,$07e2,$ff36,$03a1,$f550,$0b32,$694a,$60ca,$2980
	dc.w	$012e,$8097,$f800,$dac3,$4002,$4f04,$84b9,$b983,$0745,$be34,$09ba,$ef12,$6e05,$7780,$004f,$6950
	dc.w	$ec40,$acd6,$daab,$b4b4,$025d,$fa68,$1fe2,$8acd,$7639,$df61,$369a,$2300,$00c4,$1025,$f211,$56c7
	dc.w	$0510,$d750,$407a,$a23e,$8d80,$068b,$bc18,$8e89,$6bc6,$df00,$0062,$a850,$785e,$dc76,$86ab,$4470
	dc.w	$eaac,$a8df,$0002,$51a3,$0a7d,$9943,$ff0f,$2600,$0037,$f200,$1a4b,$b417,$0354,$48b1,$f055,$43ff
	dc.w	$c000,$0463,$7ff8,$985b,$ee01,$0e00,$0069,$eb95,$3446,$9496,$02a8,$4d4b,$faae,$bfaf,$82a3,$567d
	dc.w	$fe3d,$fbbb,$cb75,$8e00,$001f,$8ec2,$e877,$70c3,$83f0,$7815,$75f1,$dfba,$0504,$0fb9,$9932,$efb3
	dc.w	$efa0,$ac00,$003d,$63e5,$c063,$61fd,$c7b0,$fbab,$aaff,$817b,$001d,$439d,$0cad,$c7e1,$5ff0,$fc00
	dc.w	$0003,$83e0,$60bb,$23fa,$25f0,$7f3f,$ff9f,$c2b6,$003f,$869f,$6679,$4318,$eb27,$7800,$001a,$eee1
	dc.w	$709f,$0132,$cbf8,$3e6e,$eeaf,$e2a0,$2017,$1d0d,$4e78,$d7a2,$59cc,$6800,$0006,$cdd1,$4266,$8f88
	dc.w	$c3fe,$04ff,$ffff,$c0c1,$080b,$b4f0,$1c69,$ebb3,$c3e3,$b000,$0008,$40a9,$e392,$1780,$e75f,$847f
	dc.w	$fff7,$5ca2,$0617,$c65c,$3162,$6472,$d7da,$d000,$0003,$b0cf,$f088,$24d0,$25ff,$c0fe,$fe63,$a700
	dc.w	$23cc,$a3cb,$6348,$50fb,$fe3b,$e000,$0007,$ad87,$6b5a,$506c,$3b1f,$d95f,$ec7d,$6264,$19e1,$5884
	dc.w	$2d89,$65fd,$ff19,$e000,$0000,$7646,$8537,$6d6e,$2455,$fc8d,$dfd2,$2f0e,$09e4,$2c57,$4d38,$9dfc
	dc.w	$5fba,$4000,$0003,$16ab,$c62f,$fabf,$4878,$1d01,$a861,$5f26,$d840,$2726,$a209,$14dc,$6dff,$4000
	dc.w	$0000,$dc3b,$cc5f,$ff1f,$fdad,$8c1b,$9bd4,$1e02,$3e13,$be8d,$d426,$d07f,$3ae4,$8000,$0000,$3918
	dc.w	$fc4b,$fe82,$7be5,$df77,$78c7,$0414,$54be,$faf6,$acf6,$8955,$55b7,$0000,$0000,$da3a,$1cde,$ffc4
	dc.w	$63e9,$1fdb,$c500,$0400,$fe19,$10cb,$56fd,$ce70,$70b5,$0000,$0000,$2db0,$79f7,$3ffc,$1a80,$fc74
	dc.w	$838c,$8151,$690e,$1a44,$b223,$f57d,$c1d8,$0000,$0000,$2ff0,$13bc,$3efc,$0d12,$7e43,$c7bb,$102f
	dc.w	$c281,$0cdd,$302c,$cfdf,$eafc,$0000,$0000,$27c5,$b5fe,$02af,$5aba,$323f,$e71e,$3d13,$6903,$a852
	dc.w	$5052,$dd07,$6bfc,$0000,$0000,$0785,$d3f5,$5387,$fd58,$0465,$a7bc,$066e,$7017,$81ef,$f627,$7f86
	dc.w	$f1f0,$0000,$0000,$1f08,$0ffa,$1b91,$b9ad,$996a,$7e54,$f05a,$48cb,$e5d5,$fa4f,$ff80,$4368,$0000
	dc.w	$0000,$0a4f,$74d4,$143c,$d957,$aa3c,$3efb,$b1f9,$c1f7,$11de,$fd0c,$bb0a,$2fb0,$0000,$0000,$0071
	dc.w	$5aaa,$9105,$8844,$ff82,$05c2,$9e62,$3ebc,$884f,$ea19,$9f3e,$7ba0,$0000,$0000,$0131,$b87d,$0021
	dc.w	$efa3,$57d9,$5ef6,$1b28,$7517,$3c8f,$f75c,$5e5d,$ffc0,$0000,$0000,$02ed,$d8ea,$a857,$3b61,$ff9b
	dc.w	$5872,$21c5,$de26,$d64f,$a599,$bc7f,$ff40,$0000,$0000,$0105,$11df,$48f6,$9791,$1feb,$2d29,$3d28
	dc.w	$940a,$45ff,$a183,$3e3f,$bc80,$0000,$0000,$004e,$c17e,$9a32,$ad18,$0de0,$aead,$8409,$27d4,$c77b
	dc.w	$0b82,$7f77,$d900,$0000,$0000,$007c,$4acf,$ee40,$e180,$07c0,$3d07,$1e50,$5ff1,$937e,$8532,$f08e
	dc.w	$b800,$0000,$0000,$0022,$bf26,$b86e,$6028,$ad48,$3417,$1cda,$cbfc,$d0ac,$78be,$f525,$d000,$0000
	dc.w	$0000,$0029,$2f48,$234f,$46ef,$c885,$1a2c,$a2d4,$c11c,$b0f5,$fdfe,$f389,$ac00,$0000,$0000,$0016
	dc.w	$ed34,$3125,$7906,$5c4e,$a41c,$f156,$c1aa,$48be,$e27f,$c5ef,$f800,$0000,$0000,$0003,$0f80,$1bde
	dc.w	$799f,$8ba4,$d2ac,$ed4b,$81ef,$df4f,$cc8f,$eeef,$d000,$0000,$0000,$0000,$4431,$07e8,$d30a,$c1d6
	dc.w	$28d9,$eab9,$a1ec,$3a95,$abcf,$e2ff,$a000,$0000,$0000,$0001,$e4f6,$5ef9,$260b,$4048,$f87c,$a839
	dc.w	$5404,$3d7f,$f3ff,$ee9f,$4000,$0000,$0000,$0000,$8f57,$b5e6,$d18a,$e603,$9ef8,$796f,$e476,$2abd
	dc.w	$b7df,$4d3f,$8000,$0000,$0000,$0000,$6f7b,$cefb,$c4f3,$4f02,$2375,$07bf,$9bc7,$70e8,$6ffa,$e13e
	dc.w	$0000,$0000,$0000,$0000,$3372,$c5b9,$8ca6,$68b8,$1fef,$3a91,$a9eb,$4b2a,$94fc,$5798,$0000,$0000
	dc.w	$0000,$0000,$18d8,$f0b7,$b8e4,$997e,$0bc1,$3d9e,$87f4,$26ad,$457b,$effc,$0000,$0000,$0000,$0000
	dc.w	$0c74,$bd36,$6f61,$5aba,$76ab,$86cd,$c554,$481b,$b67f,$7cf0,$0000,$0000,$0000,$0000,$0d84,$541a
	dc.w	$f149,$84ae,$dfdf,$e143,$70a0,$3030,$cadf,$ffd0,$0000,$0000,$0000,$0000,$02e6,$14fd,$509d,$e102
	dc.w	$3f9b,$a8a3,$1e80,$ed29,$87fd,$eee0,$0000,$0000,$0000,$0000,$0260,$b6c0,$7f1f,$a823,$116b,$c50e
	dc.w	$6105,$1cc3,$c0d4,$d7c0,$0000,$0000,$0000,$0000,$01a5,$33a0,$bdf1,$12d3,$0a65,$c624,$832b,$f7c4
	dc.w	$f57d,$5f80,$0000,$0000,$0000,$0000,$0010,$7d73,$33da,$0ff9,$5b0b,$c075,$1528,$d5ff,$69fc,$be00
	dc.w	$0000,$0000,$0000,$0000,$0008,$278f,$ba7b,$0d54,$1d01,$e0aa,$e630,$68aa,$70ff,$fc00,$0000,$0000
	dc.w	$0000,$0000,$0015,$b35f,$f8ff,$d28a,$8800,$4766,$7020,$401b,$0377,$f800,$0000,$0000,$0000,$0000
	dc.w	$000b,$c68a,$c454,$a5bb,$8e80,$58f2,$3c20,$d2b1,$0e57,$f000,$0000,$0000,$0000,$0000,$0001,$d270
	dc.w	$be02,$7c56,$2ec0,$0626,$e6f9,$cdf4,$800f,$c000,$0000,$0000,$0000,$0000,$0000,$8cc8,$006f,$b86a
	dc.w	$12f1,$c30f,$1b2e,$3ff9,$9d57,$8000,$0000,$0000,$0000,$0000,$0000,$b603,$14ac,$b74f,$1797,$040f
	dc.w	$f4c0,$feb7,$e2bf,$0000,$0000,$0000,$0000,$0000,$0000,$3aa0,$2f7a,$eeb3,$4ce3,$084a,$4b5d,$fd5b
	dc.w	$b754,$0000,$0000,$0000,$0000,$0000,$0000,$0d17,$121d,$d597,$8731,$2274,$b7fb,$7cfc,$0ff0,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$07e3,$c94f,$ed49,$a9da,$a589,$5aff,$b21f,$57e0,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0170,$01c3,$145c,$5622,$0c72,$c3cf,$fabb,$2f80,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00be,$d391,$d6e8,$ef15,$628e,$31d5,$d97f,$ff00,$0000,$0000,$0000,$0000,$0000,$0000,$002e
	dc.w	$2007,$ab7d,$7e40,$d03e,$b3ea,$fff9,$fc00,$0000,$0000,$0000,$0000,$0000,$0000,$000a,$114b,$f20d
	dc.w	$4c0a,$625b,$d7da,$ffe3,$f000,$0000,$0000,$0000,$0000,$0000,$0000,$0003,$7338,$7007,$d426,$354f
	dc.w	$9f6f,$1ccf,$c000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$94a4,$a383,$f0be,$e39d,$77f3,$f7ff
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$2c52,$e7a9,$18b9,$e009,$244e,$e6fc,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0435,$45d9,$eb68,$c79c,$bbf7,$dfe0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0101,$a04e,$d2fd,$fffe,$0fe7,$ff80,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0020,$7a14,$e4a7,$bf79,$dfdf,$5400,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0006,$7e01,$e3f8,$66d6,$7bed,$e000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$eb87
	dc.w	$f8ff,$81fd,$ff55,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0c91,$cb1f,$e37f
	dc.w	$fbf0,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$00df,$ffaa,$fd7f,$ff00,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0007,$f75f,$3aff,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$07ae,$a780,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0780,$01e0,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0006,$7ffc,$6010,$e000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00cf,$fff4,$3fba,$8700,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0cff
	dc.w	$fffe,$fff7,$0830,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$cfff,$ffff,$fffe
	dc.w	$8007,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0004,$ffff,$ff81,$ffe7,$0040,$6000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0027,$bff9,$fb81,$ff82,$f800,$0c00,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$017f,$f9ff,$d605,$ff1f,$1c00,$0180,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$05aa,$bfff,$a00b,$fffb,$ac00,$0020,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$2fd1,$1fff,$c117,$ffff,$fe00,$003c,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$beaa,$af7e,$f0af,$fdff,$fdba,$a01f,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0002,$f43f,$3f1d
	dc.w	$600f,$daff,$f8fc,$080f,$c000,$0000,$0000,$0000,$0000,$0000,$0000,$000f,$eabe,$7f8a,$8007,$a555
	dc.w	$fc7f,$0600,$f000,$0000,$0000,$0000,$0000,$0000,$0000,$003f,$e000,$ffae,$0018,$008e,$ffff,$8718
	dc.w	$9c00,$0000,$0000,$0000,$0000,$0000,$0000,$00b9,$f00a,$fffe,$007c,$0455,$5fff,$be8c,$3f00,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0073,$f815,$5fd8,$03b8,$0002,$bfff,$a9c4,$6f80,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$05ef,$a82a,$ae08,$0048,$0015,$55fa,$fea0,$2fe0,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0fbf,$d000,$0000,$0001,$0000,$0eff,$2f60,$07f0,$0000,$0000,$0000,$0000,$0000,$0000,$27ab
	dc.w	$b808,$0000,$0000,$1000,$571f,$bfb0,$07fc,$0000,$0000,$0000,$0000,$0000,$0000,$83f5,$e000,$a004
	dc.w	$0000,$2400,$02fe,$1ff0,$01ef,$0000,$0000,$0000,$0000,$0000,$0001,$23aa,$2039,$800b,$0000,$5f80
	dc.w	$01f4,$0fb8,$00cf,$8000,$0000,$0000,$0000,$0000,$0002,$03c0,$000a,$d01f,$4000,$7ff0,$3778,$0ff8
	dc.w	$00f7,$c000,$0000,$0000,$0000,$0000,$0008,$0580,$a055,$781f,$8001,$7b80,$279e,$07fe,$013f,$f000
	dc.w	$0000,$0000,$0000,$0000,$001c,$6701,$f0ab,$f81f,$001f,$fd40,$1e18,$07ff,$01bd,$fc00,$0000,$0000
	dc.w	$0000,$0000,$0018,$2200,$8955,$59fe,$204f,$fa80,$1e1a,$06ff,$41dc,$fe00,$0000,$0000,$0000,$0000
	dc.w	$0031,$7000,$06ff,$b8e6,$001f,$e100,$0f18,$07ff,$20ec,$ff00,$0000,$0000,$0000,$0000,$0190,$6020
	dc.w	$077f,$a0e6,$3f87,$5aaa,$0721,$e7ff,$082f,$ff80,$0000,$0000,$0000,$0000,$03c9,$c0e0,$0dff,$c4f6
	dc.w	$7d1f,$fd55,$0381,$e753,$0c76,$bfc0,$0000,$0000,$0000,$0000,$07e7,$c1a0,$17ff,$c0fe,$39ff,$dabe
	dc.w	$f1c4,$c469,$cc00,$7fe0,$0000,$0000,$0000,$0000,$0fdf,$8480,$bfff,$fcf8,$11ff,$fdfd,$f8f1,$0c01
	dc.w	$8400,$bff0,$0000,$0000,$0000,$0000,$03af,$cb80,$7f7d,$7850,$01ff,$fcbe,$b07f,$1d01,$8812,$bff8
	dc.w	$0000,$0000,$0000,$0000,$0406,$d4c0,$ff3f,$f831,$07ff,$fcfc,$3009,$fe01,$cc00,$3ffc,$0000,$0000
	dc.w	$0000,$0000,$0a0b,$ea00,$7f95,$fc07,$87ff,$ff6f,$e018,$7001,$f80a,$3ffe,$0000,$0000,$0000,$0000
	dc.w	$5808,$f030,$7f8f,$fe3f,$ffff,$f8bc,$8030,$2800,$f014,$19ff,$0000,$0000,$0000,$0000,$d809,$607d
	dc.w	$ffc7,$ebe7,$bbff,$fbf8,$0010,$2000,$8a08,$4cff,$8000,$0000,$0000,$0000,$a111,$c0e7,$fde3,$ff7b
	dc.w	$ffff,$dfa0,$10b8,$0020,$8c08,$01bf,$c000,$0000,$0000,$0006,$e60b,$85f2,$feb1,$aaaa,$aaef,$de58
	dc.w	$8dfb,$8014,$c24c,$00af,$e000,$0000,$0000,$000f,$0e30,$03fd,$ffdf,$1111,$5dff,$fd8c,$7d9e,$0000
	dc.w	$c08e,$0017,$f000,$0000,$0000,$0016,$8ce8,$0abf,$eaaa,$aafa,$aaab,$e572,$ffde,$8025,$411e,$2047
	dc.w	$f800,$0000,$0000,$002c,$1de0,$041e,$f540,$00fc,$0550,$0a4a,$be6f,$0003,$a03e,$4009,$fc00,$0000
	dc.w	$0000,$0030,$4146,$882e,$6aaa,$01ff,$ea60,$2824,$7934,$0005,$605c,$6001,$fc00,$0000,$0000,$0060
	dc.w	$0203,$701d,$1020,$01f6,$f06b,$4ba4,$f7b8,$0000,$a058,$b000,$fe00,$0000,$0000,$0048,$33d7,$c00e
	dc.w	$28a1,$01f3,$b8ad,$17ee,$effc,$0002,$e018,$7005,$f700,$0000,$0000,$0100,$100f,$fc00,$0020,$80c1
	dc.w	$f868,$beff,$dffc,$0000,$a00c,$fc06,$ff80,$0000,$0000,$0224,$2b7f,$ff38,$8060,$0081,$a968,$45f7
	dc.w	$effe,$0000,$50f5,$f802,$7fc0,$0000,$0000,$0200,$1eff,$ff10,$00a0,$c003,$d27b,$62fd,$9fff,$8000
	dc.w	$0baf,$fce0,$0fc0,$0000,$0000,$0404,$8fff,$f6a8,$01e0,$0032,$be3b,$656c,$3fff,$c000,$5faf,$fa50
	dc.w	$5fe0,$0000,$0000,$0002,$0fff,$dc70,$00c4,$0006,$0cf7,$e0e4,$3fff,$8000,$07cc,$fd70,$37f0,$0000
	dc.w	$0000,$1013,$17ff,$6bc0,$0086,$03c9,$8daa,$e2fb,$bfff,$c000,$0300,$fc00,$33f8,$0000,$0000,$1c07
	dc.w	$87ff,$d300,$01b6,$079c,$0f4c,$e079,$bfff,$e000,$0008,$7809,$81fc,$0000,$0000,$0c4f,$97fa,$a800
	dc.w	$08b2,$0ff0,$8fd1,$b8a8,$ffff,$fc00,$0510,$f811,$87fe,$0000,$0000,$1c1f,$cffd,$40c8,$0d80,$0f43
	dc.w	$8710,$3c0c,$ffff,$e780,$0020,$e400,$c3fe,$0000,$0000,$124f,$dfea,$a318,$9d00,$0f42,$9dce,$1c78
	dc.w	$d7ff,$ee40,$0128,$c010,$13ff,$0000,$0000,$a827,$bfd0,$00b7,$bf80,$c742,$d271,$1c7c,$ffff,$ffc0
	dc.w	$0030,$8a0c,$0fff,$8000,$0000,$9853,$7faa,$95ff,$ef80,$e382,$63a0,$0c7f,$55ff,$d8c0,$0079,$8f04
	dc.w	$5fff,$c000,$0000,$70b8,$ffd0,$1fff,$d400,$60dd,$23c4,$a41e,$2fff,$c860,$003f,$c340,$0fff,$c000
	dc.w	$0002,$615f,$eea4,$deef,$410d,$0063,$11c2,$815d,$55ff,$f978,$0011,$c080,$bfff,$e000,$0003,$4078
	dc.w	$fff1,$f55f,$a220,$003f,$5245,$9020,$0fff,$e478,$0000,$7180,$7fff,$e000,$0004,$0555,$faab,$fa9c
	dc.w	$ec1a,$0005,$8044,$a0f8,$5dff,$feff,$0010,$7fc0,$ffff,$f000,$0004,$00e2,$ff47,$d41d,$f00c,$0003
	dc.w	$0200,$793c,$2ffd,$a9b0,$8000,$fff0,$ffff,$f000,$0000,$0545,$fa86,$b60b,$fd00,$0006,$0100,$7be6
	dc.w	$1d59,$83a9,$8000,$fff0,$ffbf,$f800,$0008,$027f,$fdcd,$1405,$ecc8,$400c,$0100,$7ba3,$b80a,$c7ed
	dc.w	$a001,$ff78,$ffbf,$f800,$0000,$04e7,$fac9,$0e03,$e3d1,$2800,$0201,$171b,$f705,$cfe9,$9007,$e4f9
	dc.w	$1f9f,$fc00,$0010,$006b,$fd06,$00f7,$82ec,$820f,$0001,$1c0b,$d08e,$17f7,$b80c,$c070,$1fdf,$fc00
	dc.w	$0028,$14cb,$ea82,$01f7,$0430,$8103,$0041,$2e13,$b0f4,$0fff,$4108,$0460,$1fc7,$fe00,$0038,$031e
	dc.w	$fd04,$01f5,$ac30,$0100,$0101,$2147,$f0f8,$75ff,$0068,$30c0,$0fe3,$fe00,$0050,$1653,$ea80,$0147
	dc.w	$9a0c,$0040,$8001,$0267,$e0ec,$76be,$003e,$e0e0,$2f7f,$fe00,$0030,$0b2e,$f400,$0106,$000e,$0020
	dc.w	$0001,$1b1b,$b1e6,$3498,$001c,$c000,$4d1f,$ff00,$0000,$167f,$ea00,$00fc,$02df,$0040,$0000,$1f0f
	dc.w	$81c3,$826c,$041c,$2020,$89cf,$ff00,$00e0,$0e7b,$d000,$001e,$f339,$00c0,$0001,$22bf,$87c2,$27a0
	dc.w	$1c0f,$c910,$19af,$ff80,$00c0,$5532,$a800,$002a,$861e,$0008,$2040,$19f7,$c2f4,$c3c0,$0e19,$824a
	dc.w	$1d9f,$ff80,$0100,$0c61,$f000,$0056,$210d,$00c0,$0021,$9fcf,$cdf0,$ef86,$170d,$9650,$bfbe,$ff80
	dc.w	$0180,$54e6,$aa00,$000a,$4413,$0800,$2079,$e3fd,$e1e9,$ffb0,$8082,$a718,$7fbf,$7fc0,$0000,$29d4
	dc.w	$d000,$006b,$1c31,$7cf0,$c0f9,$e3fc,$f8cf,$b7a0,$31c0,$bf90,$3ffe,$3fc0,$0300,$506b,$a800,$041d
	dc.w	$d0c0,$df41,$81dd,$e198,$1fbb,$e5e0,$20c0,$55fa,$7d3f,$3fc0,$0000,$0b63,$c000,$042c,$33bd,$1e03
	dc.w	$01ed,$e180,$0f75,$73e0,$3040,$0ffc,$3a3f,$bfe0,$0000,$5036,$a800,$083f,$e3b5,$8003,$0105,$e001
	dc.w	$85f8,$838d,$0420,$55f8,$003f,$ffe0,$0600,$2075,$d000,$003d,$ff9c,$8004,$0205,$e100,$e6e9,$030e
	dc.w	$0500,$0ff0,$11b7,$ffe0,$0600,$54b8,$2800,$0001,$ef00,$800c,$0007,$e30d,$92ae,$c4c1,$8300,$55e8
	dc.w	$0bdf,$fff0,$0040,$39fd,$4000,$0000,$0400,$2010,$0007,$f392,$43ff,$80e3,$0300,$0bf0,$83ef,$fff0
	dc.w	$0880,$56fc,$2800,$001c,$0000,$400c,$0003,$f780,$26be,$8862,$1800,$1560,$43ff,$fff0,$0a40,$2fff
	dc.w	$4000,$000e,$0000,$8008,$0007,$f5b8,$03bc,$0020,$3d00,$4ae0,$07eb,$eff0,$0220,$57fa,$a800,$003c
	dc.w	$0000,$0048,$000f,$f00f,$c6c5,$0a12,$3781,$f5f0,$03df,$fff8,$0270,$3fff,$4000,$007c,$0001,$0070
	dc.w	$0008,$fe17,$8f07,$8300,$85d8,$53fc,$000f,$fff8,$1281,$5ffe,$a000,$00f8,$0000,$0010,$003e,$3ee7
	dc.w	$8523,$8441,$08e8,$cd7a,$801f,$bff8,$1a60,$3fff,$8000,$0070,$0100,$000c,$0007,$cfe0,$09b1,$cbd0
	dc.w	$20e8,$6ffd,$141f,$9ff8,$0c21,$5ffa,$a800,$00f8,$0002,$4006,$0097,$ffe4,$1836,$f1a1,$0061,$fffe
	dc.w	$481f,$bffc,$1400,$bf7f,$4000,$0170,$0021,$8002,$000f,$df80,$0829,$1891,$8070,$27fc,$d50f,$fffc
	dc.w	$3a01,$16fe,$a000,$33c4,$0037,$c001,$01ff,$4704,$206c,$19a4,$8812,$83ff,$e81f,$fff4,$3001,$20bf
	dc.w	$8000,$2782,$002e,$8000,$81ef,$8200,$1178,$08c8,$3875,$c1fe,$f30e,$fffc,$0802,$047a,$a800,$1140
	dc.w	$00df,$a000,$6585,$0000,$17ba,$809d,$3cfe,$869e,$d384,$fff4,$3182,$0b7f,$4400,$2248,$009f,$0000
	dc.w	$1109,$8000,$038e,$8065,$bffe,$837c,$63a0,$fffc,$0982,$0bfe,$a800,$4f98,$c037,$0000,$0003,$0000
	dc.w	$0407,$ffa5,$defe,$0106,$0813,$fffc,$6fd2,$b9ff,$8000,$c7a1,$d00e,$0000,$0000,$0000,$0545,$ff3a
	dc.w	$0a7c,$008b,$0513,$7ff6,$5fa8,$81fa,$a808,$a11b,$f021,$0000,$0000,$0040,$0263,$e118,$3000,$000e
	dc.w	$1207,$7ffe,$2dc0,$21ff,$4000,$e00b,$b032,$0000,$0000,$0040,$0425,$0448,$7c88,$000b,$1913,$dfea
	dc.w	$3f00,$45fe,$a008,$f243,$2010,$0000,$0000,$00e0,$0662,$0bd2,$bea0,$0407,$9a55,$df7e,$34d0,$01ff
	dc.w	$c000,$3cb2,$0000,$0000,$0000,$00f0,$072f,$c0e3,$dfc0,$090b,$d923,$eefa,$68a9,$07fa,$a800,$317b
	dc.w	$0000,$0000,$0000,$0278,$07fb,$f8eb,$ffc0,$0607,$d267,$affe,$3046,$03ff,$c000,$013b,$8000,$0000
	dc.w	$0000,$0538,$02ef,$74df,$ff80,$0f07,$8703,$b7fa,$3a10,$137e,$a800,$01b2,$c000,$0000,$0000,$2f10
	dc.w	$017c,$6619,$ff10,$0a8b,$8aa1,$e7fe,$b024,$343f,$d001,$e1c6,$c000,$0000,$0000,$1f00,$00ff,$3b20
	dc.w	$6700,$af0e,$e543,$baff,$f807,$685f,$a80f,$c0ed,$c000,$0000,$0000,$5800,$003a,$59c0,$8f00,$4a31
	dc.w	$f083,$fefd,$f403,$fc3f,$c01f,$e0bc,$c000,$0000,$0000,$0c00,$4016,$0804,$0b00,$21e1,$f803,$eeff
	dc.w	$ea03,$d55e,$aa1f,$e418,$4000,$002c,$0000,$0000,$c038,$0c3a,$3400,$00e1,$3904,$cffd,$7002,$ae3f
	dc.w	$d057,$e418,$4000,$001c,$3908,$8000,$e0d8,$085b,$f002,$00f0,$fb06,$1fff,$6a00,$d41f,$a82a,$e400
	dc.w	$0000,$0050,$7fff,$8000,$61f4,$889f,$a800,$05f0,$7c04,$2f7f,$7400,$c92f,$fe01,$7000,$0000,$0001
	dc.w	$7a7f,$0000,$01fe,$4bc7,$fc00,$03e8,$3800,$aefd,$7a00,$3857,$bd00,$b000,$0000,$0000,$f438,$0000
	dc.w	$01ff,$8fff,$fc00,$07e0,$a000,$6ffd,$6a00,$3857,$bd00,$9000,$0000,$0003,$ec32,$0000,$007f,$8fff
	dc.w	$fe00,$07d0,$a000,$6ffd,$7c00,$7a2f,$e100,$0000,$0000,$0003,$9c1b,$8000,$001f,$dbff,$fa80,$07c1
	dc.w	$0000,$ffff,$3a80,$3947,$8200,$0000,$0000,$0007,$3819,$4000,$000f,$f3ff,$b900,$07e2,$0010,$7ffd
	dc.w	$1c00,$3103,$c400,$0000,$0000,$0006,$b81f,$8000,$000c,$57ff,$fde0,$03c8,$0040,$3fbf,$1e00,$6a05
	dc.w	$ea80,$0040,$0000,$0006,$403f,$ee80,$4018,$ffff,$a430,$158f,$8280,$7f7f,$1d00,$780e,$fd00,$01e0
	dc.w	$0000,$0000,$00bf,$eb80,$a01d,$ffff,$f0f4,$008f,$c0c0,$fffe,$3e80,$2955,$7a80,$01e0,$0000,$0007
	dc.w	$019f,$c03d,$4073,$ffff,$a3ff,$0487,$82a9,$7ffd,$3c00,$0188,$fd00,$03e0,$0000,$0006,$03ff,$a07f
	dc.w	$e04f,$ffff,$fffe,$8043,$376a,$fefe,$1a80,$0151,$eaa0,$03c0,$0000,$0007,$03ff,$40e8,$e87f,$ffff
	dc.w	$6fff,$9474,$3e03,$fd7f,$7d00,$02f9,$fd00,$0380,$0000,$0003,$1c7e,$8050,$e00f,$fffe,$0ebf,$8888
	dc.w	$3f61,$befe,$fa80,$017f,$faa8,$3800,$0000,$4021,$846f,$008c,$f85f,$ffce,$197b,$c090,$3c01,$5f7d
	dc.w	$bf00,$02ff,$ff40,$3c00,$0000,$e7f0,$0f8f,$804e,$7e3f,$fd0e,$0675,$c0b1,$f001,$ffbe,$dea0,$055f
	dc.w	$feaa,$1800,$0000,$27f8,$0f3b,$806e,$161f,$d38e,$06aa,$003f,$e003,$fff1,$8f00,$02fb,$ffd0,$0003
	dc.w	$8000,$0c70,$079f,$1647,$a38f,$8213,$8d30,$007f,$c1d7,$fffd,$0ea0,$0547,$ffa8,$800f,$c018,$0e20
	dc.w	$036c,$13e3,$554d,$67a7,$dc21,$407f,$81df,$fffa,$0f40,$0083,$fff4,$c00f,$800d,$4e20,$01f8,$01b9
	dc.w	$90be,$0b7d,$fb06,$007f,$92ab,$eff6,$1ea0,$0143,$dfeb,$c00d,$f203,$8c60,$00fc,$05c5,$1568,$97f9
	dc.w	$f7fc,$027f,$c10d,$f7f8,$1fd0,$0026,$17ff,$e01f,$6c00,$1c20,$01fc,$05f4,$80fc,$5ff9,$ffa0,$03ff
	dc.w	$ea03,$efee,$5fa8,$0054,$0fbf,$e830,$2508,$9fce,$00fc,$06fc,$d575,$7ff8,$ffd0,$073f,$9c17,$5ff4
	dc.w	$4fd0,$002c,$07ff,$f4e7,$3208,$1fdf,$00fc,$1c7c,$8221,$7ff8,$ff20,$085f,$806d,$ffb8,$5fa8,$0054
	dc.w	$07ff,$fcf7,$1a02,$2fbf,$81e4,$d81d,$d7e2,$ffe8,$7a80,$080f,$001f,$ff76,$47d0,$002c,$37ff,$f887
	dc.w	$bc00,$073f,$81db,$7478,$8c38,$fff0,$7d00,$4005,$002f,$faaa,$01a8,$0054,$f7ff,$f8b3,$f280,$08bf
	dc.w	$80b9,$08e4,$dc2c,$7fa8,$3580,$388b,$0017,$f5f4,$03f4,$000b,$60ff,$f4b1,$57f0,$007f,$805e,$46fb
	dc.w	$f71e,$7ffc,$1c80,$cc15,$9003,$c3a0,$21ea,$0015,$05bf,$ead6,$6df8,$00ff,$80ae,$df67,$b35e,$7fa8
	dc.w	$3706,$be0b,$8805,$c7f4,$22fc,$0000,$1dbf,$fd60,$ebf2,$00ff,$007f,$3f07,$9eef,$7ff0,$6780,$47ff
	dc.w	$f009,$cfd4,$25fa,$8000,$548f,$ea97,$85f8,$00fe,$4829,$fead,$fdc3,$73a8,$2784,$a6bf,$a4c5,$97f4
	dc.w	$03fc,$0003,$19ef,$ffff,$08fc,$01f0,$f43f,$fc90,$7f61,$4790,$2797,$4fff,$c1c0,$3fe0,$07fa,$a007
	dc.w	$1fe5,$fafa,$0c7f,$4f60,$fc25,$e392,$5dc8,$4680,$206a,$befe,$89c0,$3fd0,$13fd,$000e,$d3fa,$3ff9
	dc.w	$047f,$dfd3,$f86b,$cbb8,$5d46,$5f40,$01fd,$3fff,$0000,$3ee8,$19fa,$a00c,$a3f4,$3ffa,$afff,$bfa1
	dc.w	$fc47,$d3b1,$e040,$78a0,$4bfc,$3ffe,$0080,$e598,$0cff,$400a,$73ca,$0bfd,$4fff,$f7d1,$bbcf,$f73f
	dc.w	$3283,$c040,$3ff8,$ff9c,$b282,$aec0,$0efe,$a800,$29c8,$01fa,$afff,$f3e0,$bfbf,$df17,$f803,$cca8
	dc.w	$7bf6,$7f0e,$6304,$dfc0,$0eff,$d000,$00fc,$73fd,$d7ff,$f9d0,$5bbf,$a303,$d003,$fb00,$71f8,$ff02
	dc.w	$4b9a,$1e90,$0cff,$a800,$03fc,$e1fa,$abab,$f9e8,$3eaf,$0483,$a503,$a920,$71e0,$f803,$bc05,$3dd0
	dc.w	$05ff,$f000,$1df2,$f1ff,$f543,$fc20,$001e,$a90f,$9f01,$f000,$0363,$fc08,$7f1a,$0a40,$067f,$ea00
	dc.w	$0ae7,$88fe,$aaab,$deae,$aaab,$680f,$a020,$a800,$2020,$ea02,$ff9f,$1680,$043f,$f800,$05ce,$b0ff
	dc.w	$fdd1,$ff1f,$115d,$be1f,$d171,$8000,$6e74,$6401,$ff92,$0720,$009f,$ea80,$227f,$e87f,$fbab,$ffc4
	dc.w	$aaaa,$dbaf,$e270,$c000,$7638,$6200,$7fdc,$1580,$021f,$fd00,$47eb,$8c3f,$ffff,$8fc2,$d1ff,$d3de
	dc.w	$49f0,$2001,$7cdc,$f000,$77c8,$0e00,$021f,$fa80,$2be7,$c61f,$ffef,$4701,$87ab,$f81c,$41e0,$6002
	dc.w	$801c,$f800,$ff9e,$1a40,$003f,$fd20,$170f,$02a7,$fffe,$024c,$1fff,$f400,$4660,$e00b,$001e,$f700
	dc.w	$e793,$0e00,$0157,$7a80,$0abb,$1b97,$fffe,$596e,$7fec,$7f01,$0c20,$0f8c,$f03d,$eb15,$8fb5,$d680
	dc.w	$012e,$bf50,$07dd,$0103,$fffe,$3f16,$fc8f,$7d00,$0804,$1e4d,$fc3d,$e12d,$9bfa,$8a80,$00c7,$7eae
	dc.w	$13ff,$0917,$dfff,$52b7,$fe5c,$74e0,$1002,$b93d,$9c3f,$c01f,$fff7,$de00,$0094,$3fde,$8d8f,$2307
	dc.w	$07ff,$b2e7,$fff9,$bba0,$8800,$23bb,$ce1f,$b03f,$ffff,$2900,$000a,$ffaf,$07cf,$2386,$07ff,$3317
	dc.w	$fffd,$af20,$4002,$3151,$f47f,$a43f,$fffe,$d800,$0043,$ffff,$05d5,$1fe6,$03fc,$3bff,$ffff,$7c20
	dc.w	$4000,$1ec8,$01ff,$a0af,$ffff,$b800,$0041,$ffea,$0bc1,$73e4,$03f8,$3d7f,$fff7,$e020,$02a6,$017c
	dc.w	$023f,$c447,$fffb,$7200,$0023,$8efc,$d7e2,$77e4,$83f0,$043f,$ffe5,$c035,$8507,$017c,$6037,$e04f
	dc.w	$ffff,$5000,$0025,$67fa,$5fe3,$6f89,$87f0,$003f,$ffcf,$c038,$0002,$017e,$f0af,$c01f,$ffff,$3400
	dc.w	$0012,$83ff,$7f73,$1f5b,$05f0,$003f,$ff87,$c036,$0000,$0b7e,$f87f,$c0ff,$fffa,$a000,$0010,$43fe
	dc.w	$2f37,$7e03,$ebf8,$007f,$ff8f,$c220,$2000,$1c7e,$f073,$c1dd,$fff3,$f800,$0009,$01fe,$ef9f,$751b
	dc.w	$e0fe,$00ff,$fffb,$c041,$080c,$340f,$e079,$e5fc,$fffc,$c000,$0009,$88ff,$1fed,$e99f,$80df,$807f
	dc.w	$fffb,$5ca2,$1c80,$0603,$c062,$63fd,$fffd,$f000,$0004,$40ce,$01f7,$dbff,$c03f,$c0f0,$fe6b,$a700
	dc.w	$3343,$c3c7,$9b40,$17ff,$fffd,$c000,$0004,$0284,$90e5,$abab,$411f,$d140,$fa5d,$4220,$1af7,$e0b3
	dc.w	$1190,$03ff,$ffff,$2000,$0003,$0845,$7a48,$902d,$e01f,$e081,$efd2,$1000,$1cff,$3068,$6100,$03ff
	dc.w	$ffef,$8000,$0002,$882c,$3b80,$007c,$607f,$c101,$df61,$4021,$05f0,$ba38,$a204,$0bff,$ff9c,$c000
	dc.w	$0001,$003a,$30c0,$007c,$e02e,$3003,$a4f4,$0000,$01f4,$7f81,$d400,$dfff,$ff1f,$0000,$0000,$8298
	dc.w	$0040,$807d,$e022,$a007,$033d,$0003,$0159,$7afe,$aa02,$bfff,$ff5c,$0000,$0000,$85b8,$0000,$803b
	dc.w	$902f,$601b,$007e,$0000,$29f8,$700b,$5205,$bfff,$fffa,$0000,$0000,$4210,$413b,$c003,$e01e,$2074
	dc.w	$0072,$000c,$04fe,$fa00,$b253,$1fff,$ffbe,$0000,$0000,$0000,$03bf,$c003,$f00e,$0042,$0044,$000e
	dc.w	$2d7e,$fcf1,$3004,$3fff,$f7e0,$0000,$0000,$2021,$b5ff,$e2f0,$a006,$001e,$00e0,$000f,$16fc,$57f4
	dc.w	$f002,$3fff,$f5b4,$0000,$0000,$1079,$d3ff,$e5f8,$0186,$1478,$4040,$0040,$8fe8,$7ff8,$f600,$3fff
	dc.w	$e7e8,$0000,$0000,$12fe,$09ff,$e5ee,$0383,$9971,$e1aa,$e005,$b734,$1fdc,$fa00,$1fff,$eff0,$0000
	dc.w	$0000,$0ffc,$04ff,$ebc3,$26a9,$b039,$f11c,$f006,$be48,$5fde,$fd00,$7fff,$d2c0,$0000,$0000,$07fe
	dc.w	$a3ff,$eedb,$b7bb,$e003,$ea3c,$289f,$d1a3,$6f8f,$ea18,$ffdf,$e740,$0000,$0000,$03ff,$c07f,$ffcf
	dc.w	$f05c,$e800,$f909,$e79f,$891e,$c98f,$f735,$ffbf,$ea00,$0000,$0000,$03bb,$ac3f,$ff8f,$0c9f,$c020
	dc.w	$df81,$e3de,$062f,$04cf,$af7c,$7fff,$ecc0,$0000,$0000,$01ff,$fe1f,$f7ee,$406f,$e014,$acca,$fccf
	dc.w	$0c0a,$42ff,$8e7e,$ffff,$e380,$0000,$0000,$00bb,$fe9f,$effe,$04ef,$f21f,$6f6a,$dc02,$3e0e,$c07b
	dc.w	$767f,$ffdf,$f600,$0000,$0000,$0013,$fd0f,$1e3e,$037f,$f83f,$de84,$ff51,$7c1f,$d07f,$78ff,$ffff
	dc.w	$c600,$0000,$0000,$001f,$ce86,$b8bf,$00ff,$fabf,$eb16,$e6fa,$4839,$f0af,$84ff,$ffdf,$fc00,$0000
	dc.w	$0000,$003f,$d708,$63ff,$c0ff,$f37f,$e52f,$5ff0,$c019,$b0f1,$00ff,$fff7,$f000,$0000,$0000,$001f
	dc.w	$b294,$31f5,$791f,$2dbf,$fb1f,$0f21,$4044,$f8a0,$9dff,$ff7b,$4800,$0000,$0000,$000f,$f1c0,$1a3e
	dc.w	$381f,$f9de,$fdaf,$1330,$03c1,$ff40,$33ff,$fffe,$a000,$0000,$0000,$0007,$bb91,$04b8,$120e,$bdeb
	dc.w	$7fde,$0616,$0788,$3a80,$57ff,$fffc,$4000,$0000,$0000,$0002,$3f00,$1d78,$220f,$fff7,$fbff,$4266
	dc.w	$03c4,$3d40,$0fff,$fffe,$8000,$0000,$0000,$0001,$7fa4,$1424,$518f,$f7ff,$8fff,$a510,$2106,$2aa3
	dc.w	$5fff,$ffd5,$0000,$0000,$0000,$0000,$ff80,$0ef8,$06ff,$fffe,$03f8,$d940,$2c37,$70e7,$bfff,$fef9
	dc.w	$0000,$0000,$0000,$0000,$7fa0,$0570,$0df4,$7cfc,$07f3,$c448,$5a5a,$8be5,$7fff,$fa6e,$0000,$0000
	dc.w	$0000,$0000,$3ff4,$0052,$b8f0,$bbfe,$0bfa,$223c,$7c07,$c562,$baff,$f290,$0000,$0000,$0000,$0000
	dc.w	$1feb,$0574,$4f91,$5ffe,$77fc,$003e,$3e03,$87c4,$41ff,$ebc8,$0000,$0000,$0000,$0000,$0fff,$8802
	dc.w	$f13b,$805a,$dfd0,$003c,$0e00,$2fce,$f1ff,$daa0,$0000,$0000,$0000,$0000,$07fb,$e855,$503b,$e030
	dc.w	$3f90,$021c,$0280,$efd7,$fdff,$9100,$0000,$0000,$0000,$0000,$03ff,$4000,$7937,$a070,$1f04,$0100
	dc.w	$4506,$8fff,$ffff,$ef00,$0000,$0000,$0000,$0000,$01fb,$ce00,$fc45,$10f3,$1e02,$0020,$83ea,$8ffb
	dc.w	$ffff,$f480,$0000,$0000,$0000,$0000,$006f,$8300,$7202,$0ff9,$1908,$0075,$39ff,$2ff0,$ffff,$fc00
	dc.w	$0000,$0000,$0000,$0000,$003f,$f860,$3e00,$0554,$a200,$04aa,$ba1f,$97f9,$ffff,$5800,$0000,$0000
	dc.w	$0000,$0000,$001f,$fc30,$0400,$020a,$7000,$0160,$301f,$bffc,$fffe,$c000,$0000,$0000,$0000,$0000
	dc.w	$000f,$ff3c,$0c00,$0510,$3080,$588c,$001f,$7fff,$fffd,$5000,$0000,$0000,$0000,$0000,$0003,$ff8f
	dc.w	$4800,$0001,$d160,$0058,$000e,$fffb,$ffff,$c000,$0000,$0000,$0000,$0000,$0001,$ffb7,$ff70,$0041
	dc.w	$e012,$4000,$c5d5,$fff7,$fffd,$8000,$0000,$0000,$0000,$0000,$0000,$fffc,$ef60,$0040,$e060,$0000
	dc.w	$0bff,$ffff,$ffff,$0000,$0000,$0000,$0000,$0000,$0000,$3fff,$f0a0,$004c,$b000,$3714,$15f7,$ffff
	dc.w	$fffc,$0000,$0000,$0000,$0000,$0000,$0000,$0fff,$fde0,$01e8,$78c0,$1d89,$cfff,$fbff,$feb0,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$07ff,$feb0,$0222,$ffa0,$0377,$efff,$fdff,$fd60,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$01ff,$fffc,$e3a1,$fddd,$53bf,$3fff,$ffdf,$fd80,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00ff,$afff,$a183,$feeb,$8571,$cfff,$f7ff,$d700,$0000,$0000,$0000,$0000,$0000,$0000,$003f
	dc.w	$dfff,$f880,$fdff,$efc3,$cfff,$ffff,$fc00,$0000,$0000,$0000,$0000,$0000,$0000,$000f,$eebf,$f9ff
	dc.w	$bfff,$9de7,$eff5,$ffff,$d000,$0000,$0000,$0000,$0000,$0000,$0000,$0003,$fdc7,$ffff,$efff,$cbff
	dc.w	$ffff,$ffff,$c000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$fbfb,$ffff,$ffff,$ffff,$ff7f,$ffff
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$3ffd,$dfd7,$ff7f,$fffe,$ffff,$fffc,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$07fa,$bbef,$febf,$bfff,$5fff,$ffe0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$01ff,$fff7,$7d77,$fffd,$ffff,$ff80,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$003f,$ffeb,$fbfb,$ffff,$ffff,$fc00,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0007,$ffff,$ffff,$ffff,$ffff,$e000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$ffff
	dc.w	$ffff,$ffff,$ffff,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0fff,$f7ff,$ffff
	dc.w	$fff0,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$00ff,$ffff,$ffff,$ff00,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0007,$ffff,$ffff,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$07ff,$ff80,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$07ff,$ffe0,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0007,$8003,$9fef,$e000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00f0,$000b,$c045,$7f00,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0f00
	dc.w	$0001,$0008,$fff0,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$f000,$0000,$0001
	dc.w	$7fff,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0007,$0000,$0000,$0018,$ffbf,$e000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0038,$0006,$0000,$007d,$07ff,$fc00,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0180,$0600,$0600,$00e0,$e3ff,$ff80,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0600,$0000,$0000,$0004,$53ff,$ffe0,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$3000,$0000,$0000,$0000,$01ff,$fffc,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$c000,$0080,$0000,$0000,$0045,$5fff,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0003,$0000,$00e0
	dc.w	$0000,$0000,$0003,$f7ff,$c000,$0000,$0000,$0000,$0000,$0000,$0000,$0008,$0000,$0070,$0000,$0000
	dc.w	$0000,$f9ff,$f000,$0000,$0000,$0000,$0000,$0000,$0000,$0020,$0000,$0050,$0018,$0000,$0000,$78ff
	dc.w	$fc00,$0000,$0000,$0000,$0000,$0000,$0000,$00c6,$0000,$0000,$007c,$0000,$0000,$417f,$ff00,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$018c,$0000,$0000,$03b8,$0000,$0000,$203f,$ff80,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0610,$0000,$0000,$0048,$0000,$0005,$215f,$ffe0,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0800,$0000,$0000,$0000,$0000,$0000,$c09f,$fff0,$0000,$0000,$0000,$0000,$0000,$0000,$3800
	dc.w	$0000,$0000,$0000,$0000,$0000,$404f,$fffc,$0000,$0000,$0000,$0000,$0000,$0000,$fc00,$0000,$8000
	dc.w	$0000,$0c00,$0001,$e00f,$ffff,$0000,$0000,$0000,$0000,$0000,$0001,$fc00,$0039,$c000,$0000,$1f80
	dc.w	$0003,$f047,$ffff,$8000,$0000,$0000,$0000,$0000,$0003,$fc00,$000a,$f000,$0000,$7ff0,$3003,$f007
	dc.w	$ffff,$c000,$0000,$0000,$0000,$0000,$000f,$fa00,$0055,$7800,$0001,$7b80,$2801,$f801,$ffff,$f000
	dc.w	$0000,$0000,$0000,$0000,$0013,$f800,$00ab,$f800,$000f,$fd40,$01c7,$f800,$ffff,$fc00,$0000,$0000
	dc.w	$0000,$0000,$0027,$f800,$0155,$5800,$000f,$fa80,$01e5,$f900,$bfff,$fe00,$0000,$0000,$0000,$0000
	dc.w	$004f,$8000,$06ff,$b818,$001f,$e100,$00e7,$f800,$dfff,$ff00,$0000,$0000,$0000,$0000,$016f,$8000
	dc.w	$077f,$a018,$0307,$5aaa,$00df,$f800,$ffff,$ff80,$0000,$0000,$0000,$0000,$0236,$0000,$0dff,$c008
	dc.w	$011f,$fd55,$007f,$f88c,$ffff,$ffc0,$0000,$0000,$0000,$0000,$0418,$0000,$17ff,$c000,$01ff,$dabe
	dc.w	$803f,$fbe6,$3fff,$ffe0,$0000,$0000,$0000,$0000,$0800,$0100,$bfff,$fc00,$01ff,$fdff,$800f,$f302
	dc.w	$7fff,$fff0,$0000,$0000,$0000,$0000,$1000,$4000,$7f7d,$7800,$01ff,$fcbf,$4000,$e200,$77fd,$fff8
	dc.w	$0000,$0000,$0000,$0000,$2001,$0000,$ff3f,$f801,$07ff,$fcfe,$c006,$0000,$33ff,$fffc,$0000,$0000
	dc.w	$0000,$0000,$4000,$0000,$7f95,$fc07,$87ff,$ff6e,$000f,$8000,$07f5,$fffe,$0000,$0000,$0000,$0000
	dc.w	$c007,$0030,$7f8f,$fe3f,$ffff,$f8bc,$000f,$c000,$0feb,$ffff,$0000,$0000,$0000,$0001,$c006,$807d
	dc.w	$ffc7,$fff7,$ffff,$fbf8,$00cf,$c000,$75f7,$ffff,$8000,$0000,$0000,$0003,$8006,$00e7,$ffe3,$fffb
	dc.w	$ffff,$dfa0,$1147,$c000,$73ff,$ffff,$c000,$0000,$0000,$0007,$8000,$05f3,$fff1,$ffff,$ffff,$df18
	dc.w	$8c00,$0000,$3dff,$ffdf,$e000,$0000,$0000,$000f,$0000,$03fd,$ffff,$ffff,$ffff,$ff68,$7c00,$0000
	dc.w	$3fff,$ffef,$f000,$0000,$0000,$0016,$0000,$0bff,$ffff,$ffff,$ffff,$fcf2,$ffc0,$0000,$3fff,$dfff
	dc.w	$f800,$0000,$0000,$002c,$0000,$07fe,$ffff,$ffff,$ffff,$f838,$3fe0,$0000,$1fff,$bfff,$fc00,$0000
	dc.w	$0000,$0010,$4086,$8ffe,$ffff,$bfff,$ff7f,$e420,$7bf0,$0000,$1fff,$9fff,$fc00,$0000,$0000,$0020
	dc.w	$0183,$7ffd,$ffff,$3ff6,$ff8f,$33a4,$f7f8,$0000,$1fbf,$0fff,$fe00,$0000,$0000,$00c0,$0057,$dfff
	dc.w	$ffff,$3ff3,$ffff,$e7ee,$effc,$0000,$1fff,$87fb,$ff00,$0000,$0000,$0100,$000f,$ffff,$ff7e,$3fc1
	dc.w	$ff7f,$deff,$dffc,$0000,$1fff,$03f9,$ff80,$0000,$0000,$0204,$0b7f,$ffff,$fe7d,$3f81,$fff0,$9fff
	dc.w	$fffe,$0000,$0f7e,$07fd,$ffc0,$0000,$0000,$0000,$1eff,$ffff,$fe31,$ffc3,$ffdb,$bfff,$ffff,$8000
	dc.w	$0478,$03ff,$ffc0,$0000,$0000,$0004,$0fff,$f7ff,$ff79,$fff3,$fdbb,$bfe1,$ffff,$c000,$0050,$05ff
	dc.w	$ffe0,$0000,$0000,$0802,$0fff,$dfff,$ff59,$ffc7,$fcf7,$bfe2,$ffff,$8000,$0003,$02ff,$fff0,$0000
	dc.w	$0000,$1010,$17ff,$7fff,$ff59,$ffc1,$fdae,$bff8,$ffff,$c000,$0007,$03ff,$fff8,$0000,$0000,$0000
	dc.w	$07ff,$ffff,$ff79,$ff80,$ff4e,$bff8,$ffff,$e000,$0007,$87ff,$fffc,$0000,$0000,$2040,$17ff,$ffff
	dc.w	$fe7b,$ff8c,$f7df,$bfe8,$ffff,$fc00,$000f,$07ff,$fffe,$0000,$0000,$0000,$0fff,$ffcf,$fdff,$ff3d
	dc.w	$ff7f,$bfcc,$ffff,$f000,$001f,$1bff,$fffe,$0000,$0000,$4840,$1fff,$ff1f,$fdff,$ff3c,$e5ff,$bff8
	dc.w	$ffff,$e000,$0017,$3fff,$ffff,$0000,$0000,$9020,$3fff,$f8bf,$ffff,$ff1c,$c27f,$bffc,$ffff,$e000
	dc.w	$000f,$7fff,$ffff,$8000,$0000,$2050,$7fff,$f5ff,$efff,$ff8c,$49bf,$afff,$ffff,$c700,$0006,$7fff
	dc.w	$ffff,$c000,$0001,$00b8,$ffff,$dfff,$d4ff,$ffc1,$18ff,$27df,$ffff,$c780,$0000,$3fbf,$ffff,$c000
	dc.w	$0002,$015f,$efff,$dfff,$41fd,$ffe3,$7afb,$07ff,$ffff,$e780,$0000,$3f7f,$ffff,$e000,$0000,$0078
	dc.w	$ffff,$ffff,$a3e1,$ffff,$fdff,$1fff,$ffff,$eb00,$0000,$0e7f,$ffff,$e000,$0004,$0555,$ffff,$fffd
	dc.w	$ef9b,$fffe,$feff,$3fff,$ffff,$f000,$0000,$003f,$ffff,$f000,$0000,$00e2,$ffff,$ffff,$f70f,$ffff
	dc.w	$ffff,$3f3f,$fffd,$a84f,$0000,$000f,$ffff,$f000,$0008,$0545,$ffff,$ffff,$ff07,$ffff,$ffff,$3f0f
	dc.w	$fff9,$805e,$0001,$000f,$ffff,$f800,$0000,$027f,$ffff,$ffff,$ee0f,$ffff,$ffff,$3f43,$fffe,$c01e
	dc.w	$2002,$0087,$ffff,$f800,$0010,$04ff,$ffff,$ffff,$e21f,$0ff1,$ffff,$1f63,$fffc,$001c,$3000,$1b07
	dc.w	$ffff,$fc00,$0000,$007f,$ffff,$ffff,$823b,$7bf9,$ffff,$1c33,$d0f9,$e008,$3803,$3f8f,$ffff,$fc00
	dc.w	$0028,$14ff,$ffff,$fff7,$783f,$fdfd,$ffff,$2203,$a0f3,$f000,$4107,$fb9f,$ffff,$fe00,$0018,$031f
	dc.w	$ffff,$fff7,$702f,$fe7e,$ffff,$3f47,$c0f7,$fa00,$0067,$ff3f,$ffff,$fe00,$0050,$1613,$ffff,$ff47
	dc.w	$6013,$ffff,$ffff,$1c07,$c0e3,$f900,$0021,$ff1f,$dfff,$fe00,$0070,$0b2f,$ffff,$ff0e,$0019,$ff7f
	dc.w	$ffff,$046b,$81e1,$fbc0,$0003,$ffff,$bfff,$ff00,$0020,$167f,$ffff,$fffc,$02d8,$ff3f,$fffe,$000f
	dc.w	$81c0,$7dc0,$0003,$dfdf,$7fff,$ff00,$00e0,$0e7f,$ffff,$fffe,$033a,$ffbf,$ffff,$20bf,$83c1,$d840
	dc.w	$0000,$3eef,$ffff,$ff80,$0040,$553f,$ffff,$ffe9,$fa1d,$ffb7,$fffe,$19f7,$c2f3,$ec00,$1000,$7c35
	dc.w	$ffff,$ff80,$0100,$0c7f,$ffff,$ffc1,$dc0c,$ffbb,$dfff,$9fcf,$cdf7,$f000,$0800,$f86f,$ffff,$ff80
	dc.w	$0100,$54ff,$ffff,$ffc9,$f81e,$e7b7,$bfff,$ffff,$e1e7,$f02f,$0701,$f007,$ffff,$ffc0,$0100,$29ff
	dc.w	$ffff,$ffe8,$e03e,$c79f,$7ffb,$ffff,$f8c3,$f81f,$d201,$c00f,$ffff,$ffc0,$0200,$507f,$ffff,$fffc
	dc.w	$20ff,$c37e,$7fdf,$ffff,$ff85,$fa1f,$f000,$0005,$ffff,$ffc0,$0200,$087f,$ffff,$fffc,$03be,$70fc
	dc.w	$ffff,$ffff,$ff0a,$fc1f,$f800,$0003,$ffff,$ffe0,$0200,$503f,$ffff,$ffff,$e3f6,$7ff9,$ffff,$ffff
	dc.w	$ff07,$7c7f,$f820,$0007,$ffff,$ffe0,$0400,$207f,$ffff,$fffd,$ffff,$3ff9,$ffff,$fffc,$fe06,$fcff
	dc.w	$f900,$000f,$efff,$ffe0,$0400,$54bf,$ffff,$ffff,$ffff,$3ff3,$ffff,$fff9,$9e1f,$3bff,$ff00,$0017
	dc.w	$f7ff,$fff0,$0400,$39ff,$ffff,$ffff,$fffe,$3ffb,$ffff,$fff2,$4e3f,$7fff,$ff00,$000f,$ffff,$fff0
	dc.w	$0c00,$56ff,$ffff,$ffff,$fffe,$7ff7,$ffff,$fff0,$2e7f,$77ff,$fc00,$001f,$ffff,$fff0,$0c00,$2fff
	dc.w	$ffff,$ffff,$fffe,$fff7,$ffff,$fff8,$0f7e,$ffff,$f800,$001f,$fbff,$fff0,$0c00,$57ff,$ffff,$ffff
	dc.w	$fffe,$ff37,$ffff,$ffff,$deb8,$f7ed,$f800,$000f,$ffff,$fff8,$0c00,$3fff,$ffff,$ffff,$ffff,$ffc7
	dc.w	$fffe,$ffff,$bf00,$7fff,$7a1b,$a003,$ffff,$fff8,$1c21,$5fff,$ffff,$ffff,$ffff,$ffe7,$ffff,$3fff
	dc.w	$fc20,$7bbf,$f70f,$3005,$7fff,$fff8,$1400,$3fff,$ffff,$ffff,$ffff,$fff7,$ffff,$cfff,$f830,$3c2f
	dc.w	$df07,$9002,$ebff,$fff8,$1001,$5fff,$ffff,$ffff,$fffd,$bffb,$ff6f,$ffff,$f835,$0e5e,$ff8f,$0001
	dc.w	$b7ff,$fffc,$0000,$bfff,$ffff,$ffff,$ffde,$7fff,$ffef,$ffff,$e82b,$c7ee,$7f8f,$c003,$eaff,$fffc
	dc.w	$2001,$17ff,$ffff,$ffc7,$ffc8,$3fff,$ff1f,$ffff,$e06b,$e7df,$77ed,$4001,$f7ff,$fff4,$2000,$27ff
	dc.w	$ffff,$ff83,$ffd1,$7fff,$ff3f,$ffff,$f1fb,$f7bf,$fffa,$0001,$ffff,$fffc,$2000,$07ff,$ffff,$f100
	dc.w	$ff20,$5fff,$fc7f,$ffff,$ffb9,$ff7b,$fffd,$0661,$ffff,$fff4,$0000,$0bff,$ffff,$e000,$7f60,$ffff
	dc.w	$f1ff,$ffff,$ff88,$7f9b,$fffe,$0303,$ffff,$fffc,$2000,$0bff,$ffff,$c000,$ffc8,$ffff,$ffff,$ffff
	dc.w	$fc00,$005f,$fffe,$0179,$f7ff,$fffc,$5000,$39ff,$ffff,$c091,$eff1,$ffff,$ffff,$ffff,$fd02,$00ff
	dc.w	$fffe,$00fc,$faff,$fff6,$6000,$01ff,$ffff,$a103,$cfde,$ffff,$ffff,$ffff,$fa00,$00ff,$cffc,$01fd
	dc.w	$fdff,$fffe,$5000,$21ff,$ffff,$e003,$cfcd,$ffff,$ffff,$ffff,$fc44,$03bf,$8370,$03fc,$feff,$ffea
	dc.w	$4000,$41ff,$ffff,$f243,$dfef,$ffff,$ffff,$ffff,$fe02,$07fd,$0100,$03fc,$7dff,$fffe,$4000,$01ff
	dc.w	$ffff,$fe83,$ffff,$ffff,$ffff,$ffff,$ff2f,$cffc,$0000,$0efc,$3eff,$fffa,$0001,$07ff,$ffff,$ff03
	dc.w	$ffff,$ffff,$ffff,$fdff,$fffb,$f7f4,$0000,$01f8,$3dff,$fffe,$4006,$03ff,$ffff,$ff03,$ffff,$ffff
	dc.w	$ffff,$faff,$ffef,$f3e0,$0000,$00f8,$38ff,$fffa,$4018,$037f,$ffff,$ff82,$ffff,$ffff,$ffff,$d0ff
	dc.w	$ffff,$e5e0,$0000,$0574,$757f,$fffe,$c024,$043f,$ffff,$ffc6,$ffff,$ffff,$ffff,$e0ff,$ffff,$fac0
	dc.w	$0800,$00f1,$fabf,$ffff,$8007,$005f,$ffff,$cfef,$ffff,$ffff,$ffff,$a7ff,$fffe,$7900,$8000,$0dcf
	dc.w	$ff7f,$fffd,$8003,$003f,$ffff,$e7bf,$ffff,$ffff,$ffff,$f3ff,$fffc,$1800,$0000,$021f,$ffff,$ffff
	dc.w	$8003,$295f,$ffdf,$e7df,$ffff,$ffd3,$ffff,$ffff,$fff8,$0c22,$3000,$001f,$ffff,$fffd,$8002,$503f
	dc.w	$ffff,$e7ff,$ffff,$ffe7,$ffff,$ffff,$fff8,$0843,$f000,$000f,$fcff,$ffff,$8000,$281f,$ffff,$e7ff
	dc.w	$ffff,$ffaf,$ffff,$ffff,$fff4,$88a7,$a800,$000f,$ffff,$ffff,$8000,$312f,$ffff,$f7ff,$ffff,$ffff
	dc.w	$787f,$ffff,$fffe,$4bc7,$fc00,$0017,$ffff,$fffd,$8000,$0057,$fdff,$f7ff,$ffff,$fffe,$f83f,$ffff
	dc.w	$ffff,$8fff,$fc00,$001f,$7fff,$fffd,$8000,$0057,$fdff,$ffff,$ffff,$ffff,$f03f,$ffff,$ffff,$8fff
	dc.w	$fe00,$002f,$7fff,$fffd,$8000,$022f,$e1ff,$ffff,$ffff,$ffff,$a01f,$ffff,$ffff,$dbff,$fe00,$003e
	dc.w	$ffff,$ffff,$c000,$0147,$c3ff,$ffff,$ffff,$ffff,$401f,$7fff,$ffff,$f3ff,$bf00,$001d,$ffff,$fffd
	dc.w	$e000,$0103,$c7ff,$ffff,$ffff,$fffe,$001f,$bfff,$fffc,$57ff,$fc00,$003f,$ffbf,$ffff,$e000,$0005
	dc.w	$efff,$ffff,$ffff,$fffe,$003f,$f17f,$fff8,$ffff,$a3c0,$007f,$7d7f,$ffff,$e000,$000f,$ffff,$ffff
	dc.w	$ffff,$fffc,$007f,$f47f,$ffdd,$ffff,$ef08,$007f,$bf3f,$fffe,$c000,$0155,$ffff,$ffff,$ffff,$ffff
	dc.w	$00ff,$dfff,$fff3,$ffff,$dc00,$007f,$fd5f,$fffd,$c000,$0188,$ffff,$ffff,$ffff,$fffe,$01ff,$bfff
	dc.w	$ffcf,$ffff,$8000,$003f,$c8bf,$fffe,$e000,$0151,$ffff,$ffff,$ffff,$ffff,$03ff,$ffe8,$ffff,$ffff
	dc.w	$0000,$005f,$c1ff,$ffff,$8000,$02f9,$ffff,$ffff,$ffff,$ffff,$1c7f,$ff10,$efff,$fffe,$0100,$00df
	dc.w	$c0bf,$fffe,$8000,$017f,$ffff,$ffff,$ffff,$ffff,$fc7f,$ff80,$ffff,$ffce,$1604,$008f,$83ff,$fffd
	dc.w	$c000,$02ff,$ffff,$ffff,$ffff,$ffff,$ff8f,$ffd0,$7fff,$fd0e,$180a,$008e,$0fff,$fffe,$a000,$055f
	dc.w	$ffff,$ffff,$ffff,$ffff,$ff0b,$ffd0,$1fff,$f38e,$3855,$8000,$1fff,$fff9,$f000,$02ff,$ffff,$ffff
	dc.w	$ffff,$fc7f,$ff9f,$1ff8,$3fff,$c21f,$70cf,$0000,$3fef,$fffd,$7000,$0547,$ffff,$ffff,$ffff,$fe3f
	dc.w	$ff6e,$07fc,$7fff,$c7be,$23de,$0000,$7fff,$fffa,$7000,$0083,$ffff,$ffff,$ffff,$fe3f,$fffc,$03de
	dc.w	$ffff,$8b7c,$04f8,$0000,$6fff,$fff6,$6000,$0143,$ffff,$fffd,$ffff,$fc7f,$fffc,$03e9,$ffff,$97f8
	dc.w	$0800,$0200,$3fff,$fff8,$6000,$0026,$1fff,$ffff,$0fff,$fc3f,$fffc,$01ff,$ffff,$dff8,$0000,$0000
	dc.w	$1dff,$ffee,$6000,$0054,$0fff,$fff0,$c7ff,$ffff,$fffc,$03ff,$ffff,$fff8,$0000,$00c0,$7bff,$fff4
	dc.w	$7000,$002c,$07ff,$ffe0,$c3ff,$ffff,$fffc,$03ff,$ffff,$fff8,$0000,$07a0,$7fbf,$fff8,$6000,$0054
	dc.w	$07ff,$fff0,$e3ff,$ffff,$ffe6,$03ff,$ffff,$ffe8,$0000,$07f0,$ffff,$fff6,$7800,$002c,$07ff,$ff80
	dc.w	$47ff,$ffff,$fffb,$07ff,$fc3f,$fff0,$0000,$4ffa,$ffff,$ffea,$3e00,$0054,$07ff,$ff8c,$07ff,$ffff
	dc.w	$ffe1,$0fff,$f82f,$ffa8,$4000,$37f4,$ffff,$fff4,$3c00,$000b,$00ff,$ff8e,$1fff,$ffff,$ffc0,$1fff
	dc.w	$f01f,$fffc,$6000,$03ea,$6fff,$ffe0,$3e00,$0015,$043f,$ffc0,$7dff,$ffff,$ffe0,$3fe7,$b61e,$ffa8
	dc.w	$4005,$41f4,$7fff,$fff4,$3d00,$0000,$1a3f,$ffe0,$fbf3,$ffff,$ffe0,$7fc7,$9b0f,$7ff0,$0803,$b800
	dc.w	$1fff,$ffd4,$3a00,$0000,$5b0f,$ffd7,$f5f8,$ffff,$ffe1,$ffed,$fc03,$73a8,$1803,$5940,$5fff,$fff4
	dc.w	$1c00,$0003,$0f0f,$ffff,$f8fc,$7fff,$ffff,$fe10,$7f01,$4790,$1800,$b000,$3fff,$ffe0,$1800,$0001
	dc.w	$0e05,$ffff,$fc7f,$7fff,$ffe7,$e5e8,$7dc0,$4680,$1f01,$4101,$7fff,$ffd0,$1c00,$0000,$0c02,$3fff
	dc.w	$fc7f,$ffff,$ffe3,$cbf0,$5d40,$7f40,$1e00,$c000,$ffff,$ffe8,$1e00,$0000,$0004,$3fff,$ffff,$bfff
	dc.w	$ffc7,$d7f8,$b040,$78a0,$0400,$0001,$ff7f,$ff98,$0f00,$0002,$0032,$0bff,$ffff,$ffff,$bfcf,$f7f8
	dc.w	$7a83,$c040,$0000,$8063,$ff7f,$ffc0,$0f00,$0000,$00f0,$01ff,$ffff,$ffff,$bfbf,$d7f8,$3c03,$d028
	dc.w	$0401,$00f1,$ffff,$ffc0,$0f00,$0000,$01f4,$03ff,$ffff,$ffff,$dfff,$a7f8,$3c03,$c000,$0e07,$00fc
	dc.w	$ffef,$ff90,$0f00,$0000,$01f4,$01ff,$ffff,$ffff,$ffff,$03f8,$1803,$a020,$0e1f,$07fc,$7fff,$ffd0
	dc.w	$0600,$0000,$03f0,$01ff,$ffff,$ffff,$fffe,$a6f0,$0001,$f000,$3c9e,$03ff,$ffff,$ff40,$0780,$0000
	dc.w	$03f0,$00ff,$ffff,$dfff,$ffff,$67f0,$0020,$a800,$1fde,$15fd,$ffff,$fe80,$07c0,$0000,$03e0,$40ff
	dc.w	$ffff,$ffff,$ffff,$a1e0,$0170,$0000,$1f88,$1bfe,$ffff,$ff20,$03e0,$0000,$0181,$f07f,$ffff,$ffc4
	dc.w	$ffff,$c040,$0270,$0000,$0fc0,$1dff,$ffff,$fd80,$03e0,$0000,$0017,$f03f,$ffff,$8fc2,$ffff,$c800
	dc.w	$01f0,$0001,$0320,$0fff,$ffff,$ff00,$03e0,$0000,$000f,$f81f,$ffff,$4701,$ffff,$e000,$01e0,$0002
	dc.w	$7fe0,$07ff,$ffff,$fa40,$01c0,$0020,$001f,$fc27,$fffe,$0200,$7fff,$f400,$0060,$0001,$ffe0,$08ff
	dc.w	$ffff,$fe00,$01a8,$8000,$001f,$fc17,$fffe,$4080,$7fef,$ff00,$0020,$0003,$ffc0,$14ff,$ffff,$fe80
	dc.w	$01d1,$4010,$003f,$fc03,$fffe,$00e4,$fc8f,$7c00,$0004,$0183,$ffc0,$1eff,$ffff,$fe80,$00b8,$8000
	dc.w	$003f,$fe17,$dfff,$0f47,$fe5c,$7b60,$1002,$8783,$ffc0,$3fff,$ffff,$fe00,$00fb,$c000,$807f,$fc07
	dc.w	$07ff,$8f07,$fff8,$b420,$8800,$1f45,$ffe0,$7fff,$ffff,$f900,$007d,$0000,$003f,$fc06,$07ff,$0f17
	dc.w	$fffd,$a020,$4002,$0e8e,$ff80,$7fff,$ffff,$f800,$007c,$0000,$003f,$f806,$03fc,$06ff,$ffff,$6020
	dc.w	$4000,$0137,$fe00,$7fff,$ffff,$d800,$007e,$0000,$003f,$b804,$03f8,$037f,$ffff,$e020,$02a0,$00fb
	dc.w	$fdc0,$3fff,$ffff,$b200,$003c,$7100,$c01d,$8000,$83f0,$003f,$ffe5,$c030,$0500,$00ff,$ffc8,$1fff
	dc.w	$ffff,$d000,$003a,$9800,$401c,$8006,$07f0,$003f,$ffc7,$c038,$0000,$00ff,$ff50,$3fff,$ffff,$b400
	dc.w	$001d,$7c00,$600c,$c024,$c5f0,$003f,$ff87,$c036,$0000,$08ff,$ff80,$3fff,$ffff,$a000,$001f,$bc00
	dc.w	$6008,$80ec,$0bf8,$007f,$ff8f,$c220,$2000,$13ff,$ff80,$3fff,$ffff,$e800,$000f,$fe00,$0000,$00e4
	dc.w	$00fe,$00ff,$fffb,$c041,$0800,$2bff,$ff86,$1fff,$ffff,$c000,$000f,$ff00,$e000,$0060,$005f,$807f
	dc.w	$fff3,$5ca2,$1080,$19ff,$ff9d,$9fff,$fffe,$d000,$0007,$ff31,$fe00,$0000,$003f,$c0f0,$fe63,$a700
	dc.w	$2d20,$1c3f,$fcbf,$efff,$ffff,$c000,$0007,$ff7b,$ff00,$0010,$011f,$d140,$f99d,$4220,$0400,$0f7f
	dc.w	$fe7f,$ffff,$ffff,$2000,$0003,$ffbb,$ff80,$0010,$001f,$e081,$e022,$0000,$0000,$c7bf,$9eff,$ffff
	dc.w	$ffef,$0000,$0003,$ffd3,$fc00,$0000,$807f,$c101,$c099,$4020,$000f,$41df,$5dff,$ffff,$ff9c,$4000
	dc.w	$0001,$ffc5,$ff40,$0000,$002f,$8003,$8008,$0000,$000f,$807e,$2bff,$3fff,$ff1e,$0000,$0000,$ffe7
	dc.w	$ff80,$0000,$0020,$8007,$0001,$0000,$0007,$8501,$55fd,$7fff,$ff1c,$0000,$0000,$ffc7,$ffe1,$0000
	dc.w	$0020,$801b,$0000,$0000,$0007,$8ff4,$adfa,$7fff,$ffb8,$0000,$0000,$7fef,$bec0,$0000,$0001,$c074
	dc.w	$0000,$0000,$1801,$05ff,$4dfc,$ffff,$ffb8,$0000,$0000,$3fff,$fc40,$0000,$0001,$e042,$0000,$0000
	dc.w	$1000,$030e,$cffb,$ffff,$ffe0,$0000,$0000,$3ffe,$4a00,$0200,$0001,$e01e,$0000,$0004,$0000,$000f
	dc.w	$0ffd,$ffff,$ffb4,$0000,$0000,$1ffe,$2c00,$0400,$0001,$e47c,$0000,$0047,$0000,$0007,$09ff,$ffff
	dc.w	$ffe0,$0000,$0000,$1fff,$f600,$0000,$0000,$697c,$0000,$e003,$0000,$0023,$05ff,$ffff,$f7e0,$0000
	dc.w	$0000,$0fff,$fb00,$0000,$0000,$403c,$0000,$f001,$0040,$2021,$02ff,$ffff,$e2c0,$0000,$0000,$07ff
	dc.w	$fc00,$0020,$4000,$0002,$1000,$2700,$0040,$f070,$15e7,$ffff,$e700,$0000,$0000,$03ff,$ff80,$0010
	dc.w	$0000,$0000,$0000,$1fc0,$02e1,$f670,$08fb,$ffff,$ea00,$0000,$0000,$03ff,$ffc0,$0000,$f000,$0000
	dc.w	$2000,$1fe0,$01d1,$ff30,$50ff,$ffff,$ec40,$0000,$0000,$01ff,$ffe0,$0001,$fc00,$0000,$5208,$03f0
	dc.w	$03f5,$bf00,$71ff,$ffff,$e080,$0000,$0000,$00ff,$ffe0,$0001,$fa00,$0000,$1010,$23fc,$21f1,$3f84
	dc.w	$f9ff,$ffff,$f000,$0000,$0000,$007f,$fff0,$0101,$fc00,$0000,$0078,$00ae,$43e0,$2f80,$ffff,$ffff
	dc.w	$c000,$0000,$0000,$003f,$fff9,$0700,$ff00,$0000,$00e8,$0105,$37c0,$0f50,$ffff,$ffff,$f000,$0000
	dc.w	$0000,$003f,$fff7,$9c00,$3f00,$0400,$00d0,$000f,$3fe6,$4f0e,$ffff,$ffff,$e000,$0000,$0000,$001f
	dc.w	$ffeb,$ce0a,$86e0,$8200,$00e0,$00ff,$bfff,$075f,$7fff,$fffb,$4800,$0000,$0000,$000f,$ffff,$e401
	dc.w	$c7e0,$0401,$0050,$00ff,$fffe,$00bf,$ffff,$fffe,$8000,$0000,$0000,$0007,$ffee,$fb07,$edf1,$0200
	dc.w	$8020,$01ff,$fff7,$c57f,$ffff,$fffc,$0000,$0000,$0000,$0003,$ffff,$e387,$ddf0,$0000,$0400,$1ddf
	dc.w	$fffb,$c2bf,$ffff,$fffe,$0000,$0000,$0000,$0001,$fffb,$ebdb,$ae70,$0800,$7000,$1eff,$dff9,$d55f
	dc.w	$ffff,$ffd5,$0000,$0000,$0000,$0000,$ffff,$f107,$f900,$0001,$fc00,$3eff,$f7f8,$8f1f,$ffff,$fff8
	dc.w	$0000,$0000,$0000,$0000,$7fff,$fa0f,$f20b,$8303,$f800,$3fff,$fff5,$f41f,$ffff,$ffe8,$0000,$0000
	dc.w	$0000,$0000,$3fff,$ff0d,$470f,$4401,$f407,$dfff,$fffb,$fb9f,$ffff,$ffd0,$0000,$0000,$0000,$0000
	dc.w	$1fff,$fa8b,$b00e,$a001,$8807,$ffff,$ffff,$ffff,$ffff,$ffe0,$0000,$0000,$0000,$0000,$0fff,$fffd
	dc.w	$0e84,$7f05,$202f,$ffff,$ffff,$dfff,$ffff,$ffc0,$0000,$0000,$0000,$0000,$07ff,$ffaa,$afc0,$1f8f
	dc.w	$c06f,$fdff,$fd7f,$1fff,$ffff,$ff80,$0000,$0000,$0000,$0000,$03ff,$ffff,$86c4,$5f8f,$e0ff,$feff
	dc.w	$baf8,$7fff,$ffff,$ff00,$0000,$0000,$0000,$0000,$01ff,$ffff,$03ba,$ef0c,$e1ff,$ffdf,$7c14,$7fff
	dc.w	$ffff,$fc80,$0000,$0000,$0000,$0000,$007f,$ffff,$8dfd,$f006,$e6f7,$ff8a,$fe1f,$ffff,$ffff,$fc00
	dc.w	$0000,$0000,$0000,$0000,$003f,$ffff,$c1ff,$faab,$ffff,$ff55,$7dff,$ffff,$ffff,$5800,$0000,$0000
	dc.w	$0000,$0000,$001f,$ffff,$c3ff,$fdf5,$ffff,$fe9f,$ffff,$ffff,$fffe,$c000,$0000,$0000,$0000,$0000
	dc.w	$000f,$ffff,$e3ff,$faef,$ff7f,$a77f,$ffff,$ffff,$fffd,$5000,$0000,$0000,$0000,$0000,$0003,$ffff
	dc.w	$f7ff,$ffff,$ff9f,$ffff,$ffff,$ffff,$ffff,$c000,$0000,$0000,$0000,$0000,$0001,$ffff,$ff8f,$ffbf
	dc.w	$ffef,$bfff,$ffff,$ffff,$fffd,$8000,$0000,$0000,$0000,$0000,$0000,$ffff,$ff9f,$ffbf,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$0000,$0000,$0000,$0000,$0000,$0000,$3fff,$ffdf,$ffbf,$ffff,$ffff,$ffff,$ffff
	dc.w	$fffc,$0000,$0000,$0000,$0000,$0000,$0000,$0fff,$ffff,$fe1f,$ffff,$ffff,$ffff,$ffff,$feb0,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$07ff,$ffff,$ff9f,$ffff,$ffff,$ffff,$ffff,$fd60,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$01ff,$ffff,$ffdf,$ffff,$ffff,$ffff,$ffff,$fd80,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00ff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$d700,$0000,$0000,$0000,$0000,$0000,$0000,$003f
	dc.w	$ffff,$f7ff,$ffff,$ffff,$ffff,$ffff,$fc00,$0000,$0000,$0000,$0000,$0000,$0000,$000f,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff,$d000,$0000,$0000,$0000,$0000,$0000,$0000,$0003,$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$c000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$3fff,$ffff,$ffff,$ffff,$ffff,$fffc,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$07ff,$ffff,$ffff,$ffff,$ffff,$ffe0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$01ff,$ffff,$ffff,$ffff,$ffff,$ff80,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$003f,$ffff,$ffff,$ffff,$ffff,$fc00,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0007,$ffff,$ffff,$ffff,$ffff,$e000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$ffff
	dc.w	$ffff,$ffff,$ffff,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0fff,$ffff,$ffff
	dc.w	$fff0,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$00ff,$ffff,$ffff,$ff00,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0007,$ffff,$ffff,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$07ff,$ff80,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$07ff,$ffe0,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0007,$ffff,$ffff,$e000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00ff,$ffff,$ffff,$ff00,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0fff
	dc.w	$ffff,$ffff,$fff0,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$ffff,$ffff,$ffff
	dc.w	$ffff,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0007,$ffff,$ffff,$ffff,$ffff,$e000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$003f,$ffff,$ffff,$ffff,$ffff,$fc00,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$01ff,$ffff,$f9ff,$ffff,$ffff,$ff80,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$07ff,$ffff,$ffff,$ffff,$ffff,$ffe0,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$3fff,$ffff,$ffff,$ffff,$ffff,$fffc,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0003,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff,$c000,$0000,$0000,$0000,$0000,$0000,$0000,$000f,$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$f000,$0000,$0000,$0000,$0000,$0000,$0000,$003f,$ffff,$ffff,$ffe7,$ffff,$ffff,$ffff
	dc.w	$fc00,$0000,$0000,$0000,$0000,$0000,$0000,$00ff,$ffff,$ffff,$ff83,$ffff,$ffff,$ffff,$ff00,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$01ff,$ffff,$ffff,$fc47,$ffff,$ffff,$dfff,$ff80,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$07ff,$ffff,$ffff,$ffb7,$ffff,$ffff,$dfff,$ffe0,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0fff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$fff0,$0000,$0000,$0000,$0000,$0000,$0000,$3fff
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$fffc,$0000,$0000,$0000,$0000,$0000,$0000,$ffff,$ffff,$7fff
	dc.w	$ffff,$f3ff,$ffff,$ffff,$ffff,$0000,$0000,$0000,$0000,$0000,$0001,$ffff,$ffc6,$3fff,$ffff,$e07f
	dc.w	$ffff,$ffff,$ffff,$8000,$0000,$0000,$0000,$0000,$0003,$ffff,$fff5,$0fff,$ffff,$800f,$cfff,$ffff
	dc.w	$ffff,$c000,$0000,$0000,$0000,$0000,$000f,$ffff,$ffaa,$87ff,$fffe,$847f,$dfff,$ffff,$ffff,$f000
	dc.w	$0000,$0000,$0000,$0000,$001f,$ffff,$ff54,$07ff,$fff0,$02bf,$ffff,$ffff,$ffff,$fc00,$0000,$0000
	dc.w	$0000,$0000,$003f,$ffff,$feaa,$a7ff,$fff0,$057f,$ffff,$ffff,$ffff,$fe00,$0000,$0000,$0000,$0000
	dc.w	$007f,$ffff,$f900,$47ff,$ffe0,$1eff,$ffff,$ffff,$ffff,$ff00,$0000,$0000,$0000,$0000,$01ff,$ffff
	dc.w	$f880,$5fff,$fcf8,$a555,$ffff,$ffff,$ffff,$ff80,$0000,$0000,$0000,$0000,$03ff,$ffff,$f200,$3fff
	dc.w	$fee0,$02aa,$ffff,$ffff,$ffff,$ffc0,$0000,$0000,$0000,$0000,$07ff,$ffff,$e800,$3fff,$fe00,$2541
	dc.w	$7fff,$ff9f,$ffff,$ffe0,$0000,$0000,$0000,$0000,$0fff,$ffff,$4000,$03ff,$fe00,$0200,$7fff,$ffff
	dc.w	$ffff,$fff0,$0000,$0000,$0000,$0000,$1fff,$bfff,$8082,$87ff,$fe00,$0340,$ffff,$ffff,$ffff,$fff8
	dc.w	$0000,$0000,$0000,$0000,$3fff,$ffff,$00c0,$07fe,$f800,$0301,$ffff,$ffff,$ffff,$fffc,$0000,$0000
	dc.w	$0000,$0000,$7fff,$ffff,$806a,$03f8,$7800,$0091,$ffff,$ffff,$ffff,$fffe,$0000,$0000,$0000,$0000
	dc.w	$bfff,$ffcf,$8070,$01c0,$0000,$0743,$ffff,$ffff,$ffff,$ffff,$0000,$0000,$0000,$0001,$3fff,$ff82
	dc.w	$0038,$0008,$0000,$0407,$ffff,$ffff,$ffff,$ffff,$8000,$0000,$0000,$0002,$7fff,$ff18,$001c,$0004
	dc.w	$0000,$205f,$efff,$ffff,$ffff,$ffff,$c000,$0000,$0000,$0004,$7fff,$fa0c,$000e,$0000,$0000,$20e7
	dc.w	$73ff,$ffff,$ffff,$ffff,$e000,$0000,$0000,$0008,$ffff,$fc02,$0000,$0000,$0000,$00f7,$83ff,$ffff
	dc.w	$ffff,$ffff,$f000,$0000,$0000,$0019,$ffff,$f400,$0000,$0000,$0000,$03fd,$003f,$ffff,$ffff,$ffff
	dc.w	$f800,$0000,$0000,$0033,$ffff,$f801,$0000,$0000,$0000,$07ff,$c01f,$ffff,$ffff,$ffff,$fc00,$0000
	dc.w	$0000,$002f,$bff9,$7001,$0000,$4000,$0080,$1fdf,$840f,$ffff,$ffff,$ffff,$fc00,$0000,$0000,$005f
	dc.w	$fffc,$8002,$0000,$c009,$0070,$fc5b,$0807,$ffff,$ffff,$ffff,$fe00,$0000,$0000,$00bf,$ffa8,$2000
	dc.w	$0000,$c00c,$007f,$f811,$1003,$ffff,$ffff,$ffff,$ff00,$0000,$0000,$01ff,$fff0,$0000,$0081,$c03e
	dc.w	$00ff,$e100,$2003,$ffff,$ffff,$ffff,$ff80,$0000,$0000,$03fb,$f480,$0000,$0182,$c07e,$00ff,$e000
	dc.w	$0001,$ffff,$ffff,$ffff,$ffc0,$0000,$0000,$03ff,$e100,$0000,$01ce,$003c,$01e4,$c000,$0000,$7fff
	dc.w	$ffff,$ffff,$ffc0,$0000,$0000,$07fb,$f000,$0800,$0086,$000c,$03c4,$c01e,$0000,$3fff,$ffff,$ffff
	dc.w	$ffe0,$0000,$0000,$0ffd,$f000,$2000,$00a6,$0038,$0308,$c01f,$0000,$7fff,$ffff,$ffff,$fff0,$0000
	dc.w	$0000,$1fef,$e800,$8000,$00a6,$003e,$0251,$c007,$0000,$3fff,$ffff,$ffff,$fff8,$0000,$0000,$1fff
	dc.w	$f800,$0000,$0086,$007f,$00b1,$c007,$0000,$1fff,$ffff,$ffff,$fffc,$0000,$0000,$3fbf,$e800,$0000
	dc.w	$0184,$007f,$0820,$c017,$0000,$03ff,$ffff,$ffff,$fffe,$0000,$0000,$3fff,$f000,$0030,$0200,$00fe
	dc.w	$0880,$c033,$0000,$0fff,$ffff,$ffff,$fffe,$0000,$0000,$7fbf,$e000,$00e0,$0200,$00ff,$1a00,$c007
	dc.w	$0000,$1fff,$ffff,$ffff,$ffff,$0000,$0000,$ffdf,$c000,$0740,$0000,$00ff,$3d80,$c003,$0000,$1fff
	dc.w	$ffff,$ffff,$ffff,$8000,$0000,$ffaf,$8000,$0a00,$1000,$007f,$b640,$d000,$0000,$3fff,$ffff,$ffff
	dc.w	$ffff,$c000,$0001,$ff47,$0000,$2000,$2b00,$003e,$e700,$d820,$0000,$3fff,$ffff,$ffff,$ffff,$c000
	dc.w	$0003,$fea0,$1000,$2000,$be02,$001c,$c704,$f800,$0000,$1fff,$ffff,$ffff,$ffff,$e000,$0003,$ff87
	dc.w	$0000,$0000,$5c1e,$0000,$8300,$e000,$0000,$1fff,$ffff,$ffff,$ffff,$e000,$0007,$faaa,$0000,$0002
	dc.w	$1064,$0001,$0100,$c000,$0000,$0fff,$ffff,$ffff,$ffff,$f000,$0007,$ff1d,$0000,$0000,$08f0,$0000
	dc.w	$0000,$c0c0,$0002,$57ff,$ffff,$ffff,$ffff,$f000,$000f,$faba,$0000,$0000,$00f8,$0000,$0000,$c0f0
	dc.w	$0006,$7fff,$ffff,$ffff,$ffff,$f800,$000f,$fd80,$0000,$0000,$11f0,$0000,$0000,$c0fc,$0001,$3fff
	dc.w	$dfff,$ffff,$ffff,$f800,$001f,$fb00,$0000,$0000,$1de0,$f00e,$0000,$e0fc,$0003,$ffff,$cfff,$ffff
	dc.w	$ffff,$fc00,$001f,$ff80,$0000,$0000,$7dc7,$8406,$0000,$e3fc,$2f07,$ffff,$c7ff,$ffff,$ffff,$fc00
	dc.w	$0037,$eb00,$0000,$0008,$ffcf,$0202,$0000,$ddfc,$5f0f,$ffff,$beff,$ffff,$ffff,$fe00,$0027,$fce0
	dc.w	$0000,$0008,$ffdf,$0181,$0000,$deb8,$3f0f,$ffff,$ff9f,$ffff,$ffff,$fe00,$006f,$e9ec,$0000,$00b8
	dc.w	$ffef,$0080,$0000,$fff8,$3f1f,$ffff,$ffdf,$ffff,$ffff,$fe00,$004f,$f4d0,$0000,$00f1,$ffe7,$00c0
	dc.w	$0000,$fff4,$7e1f,$ffff,$ffff,$ffff,$ffff,$ff00,$005f,$e980,$0000,$0003,$fd27,$00e0,$0001,$fff0
	dc.w	$7e3f,$ffff,$ffff,$ffff,$ffff,$ff00,$009f,$f180,$0000,$0001,$fcc7,$0070,$0000,$df40,$7c3f,$ffff
	dc.w	$ffff,$ffff,$ffff,$ff80,$00bf,$aac0,$0000,$0017,$fde3,$0078,$0001,$e608,$3d0f,$ffff,$ffff,$ffff
	dc.w	$ffff,$ff80,$01ff,$f380,$0000,$003f,$fff3,$007c,$2000,$6030,$320f,$ffff,$ffff,$ffbf,$ffff,$ff80
	dc.w	$01ff,$ab00,$0000,$0037,$ffe1,$1878,$4000,$0000,$1e1f,$ffdf,$ffff,$ffff,$ffff,$ffc0,$01ff,$d600
	dc.w	$0000,$0017,$ffc1,$3860,$8004,$0000,$073f,$ffff,$efff,$ffff,$ffff,$ffc0,$03ff,$af80,$0000,$0003
	dc.w	$ff01,$3c81,$8020,$0000,$007f,$ffff,$ffff,$ffff,$ffff,$ffc0,$03ff,$f780,$0000,$0003,$fc41,$8f03
	dc.w	$0000,$0000,$00ff,$ffff,$ffff,$ffff,$ffff,$ffe0,$03ff,$afc0,$0000,$0000,$1c09,$8006,$0000,$0000
	dc.w	$00ff,$ffff,$ffdf,$ffff,$ffff,$ffe0,$07ff,$df80,$0000,$0002,$0001,$c006,$0000,$0003,$01ff,$ffff
	dc.w	$feff,$ffff,$ffff,$ffe0,$07ff,$ab40,$0000,$0000,$0001,$c00c,$0000,$0006,$61ff,$ffff,$fcff,$ffff
	dc.w	$ffff,$fff0,$07ff,$c600,$0000,$0000,$0001,$c00c,$0000,$000d,$b1ff,$ffff,$fcff,$ffff,$ffff,$fff0
	dc.w	$0fff,$a900,$0000,$0000,$0001,$8018,$0000,$000f,$d1ff,$ffff,$ffff,$ffff,$ffff,$fff0,$0fff,$d000
	dc.w	$0000,$0000,$0001,$0038,$0000,$0007,$f0ff,$ffff,$ffff,$ffff,$ffff,$fff0,$0fff,$a800,$0000,$0000
	dc.w	$0001,$00f8,$0000,$0000,$217f,$ffff,$ffff,$ffff,$ffff,$fff8,$0fff,$c000,$0000,$0000,$0000,$0038
	dc.w	$0001,$0000,$40ff,$ffff,$ffe7,$ffff,$ffff,$fff8,$1ffe,$a000,$0000,$0000,$0000,$0018,$0000,$c000
	dc.w	$03df,$ffff,$fff7,$ffff,$ffff,$fff8,$1fff,$c000,$0000,$0000,$0000,$0008,$0000,$3000,$07cf,$ffff
	dc.w	$ffff,$ffff,$ffff,$fff8,$1ffe,$a000,$0000,$0000,$0000,$0004,$00f0,$0000,$07cb,$ffff,$ffff,$ffff
	dc.w	$ffff,$fffc,$1fff,$4000,$0000,$0000,$0000,$0000,$00f0,$0000,$17d7,$ffff,$ffff,$ffff,$ffff,$fffc
	dc.w	$3ffe,$e800,$0000,$0038,$0000,$0000,$00e0,$0000,$1f97,$ffff,$ffff,$ffff,$ffff,$fff4,$3fff,$d800
	dc.w	$0000,$007c,$0000,$0000,$00c0,$0000,$0e07,$ffff,$ffff,$ffff,$ffff,$fffc,$3fff,$f800,$0000,$0eff
	dc.w	$0000,$0000,$0380,$0000,$0047,$ffff,$ffff,$f9ff,$ffff,$fff4,$3fff,$f400,$0000,$1fff,$8000,$0000
	dc.w	$0e00,$0000,$0077,$ffff,$ffff,$fcff,$ffff,$fffc,$3fff,$f400,$0000,$3fff,$0000,$0000,$0000,$0000
	dc.w	$03ff,$ffff,$ffff,$feff,$ffff,$fffc,$7fff,$c600,$0000,$3f7e,$0000,$0000,$0000,$0000,$02ff,$ffff
	dc.w	$ffff,$ffff,$ffff,$fff6,$7fff,$fe00,$0000,$5efc,$0000,$0000,$0000,$0000,$05ff,$ffff,$ffff,$ffff
	dc.w	$ffff,$fffe,$7fff,$de00,$0000,$1ffc,$0000,$0000,$0000,$0000,$03fb,$ffff,$ffff,$ffff,$ffff,$ffea
	dc.w	$7fff,$be00,$0000,$0dbc,$0000,$0000,$0000,$0000,$01fd,$ffff,$ffff,$ffff,$ffff,$fffe,$7fff,$fe00
	dc.w	$0000,$017c,$0000,$0000,$0000,$0000,$00d0,$3fff,$ffff,$f7ff,$ffff,$fffa,$7ffe,$f800,$0000,$00fc
	dc.w	$0000,$0000,$0000,$0000,$0004,$0fff,$ffff,$ffff,$ffff,$fffe,$7ff9,$fc00,$0000,$00fc,$0000,$0000
	dc.w	$0000,$0000,$0010,$0fff,$ffff,$ffff,$ffff,$fffa,$7fe7,$fc80,$0000,$007d,$0000,$0000,$0000,$0000
	dc.w	$0000,$1bff,$ffff,$ffff,$ffff,$fffe,$ffdb,$fbc0,$0000,$0039,$0000,$0000,$0000,$0000,$0000,$05ff
	dc.w	$ffff,$ffff,$ffff,$ffff,$fff8,$ffa0,$0000,$3010,$0000,$0000,$0000,$0000,$0001,$86ff,$7fff,$f7ff
	dc.w	$ffff,$fffd,$fffc,$ffc0,$0000,$1840,$0000,$0000,$0000,$0000,$0003,$e7ff,$ffff,$ffff,$ffff,$ffff
	dc.w	$fffc,$fea0,$0020,$1820,$0000,$0000,$0000,$0000,$0007,$f3dd,$cfff,$ffff,$ffff,$fffd,$fffd,$ffc0
	dc.w	$0000,$1800,$0000,$0000,$0000,$0000,$0007,$f7bc,$0fff,$ffff,$ffff,$ffff,$ffff,$ffe0,$0000,$1800
	dc.w	$0000,$0000,$0000,$0000,$000b,$7778,$57ff,$ffff,$ffff,$ffff,$ffff,$fed0,$0000,$0800,$0000,$0000
	dc.w	$8780,$0000,$0001,$b438,$03ff,$ffff,$ffff,$fffd,$ffff,$ffa8,$0200,$0800,$0000,$0001,$0fc0,$0000
	dc.w	$0000,$7000,$03ff,$ffff,$ffff,$fffd,$ffff,$ffa8,$0200,$0000,$0000,$0000,$1fc0,$0000,$0000,$7000
	dc.w	$01ff,$ffff,$ffff,$fffd,$ffff,$fdd0,$1e00,$0000,$0000,$0000,$7fe0,$0000,$0000,$2400,$01ff,$ffff
	dc.w	$ffff,$ffff,$ffff,$feb8,$3c00,$0000,$0000,$0000,$ffe0,$8000,$0000,$0c00,$40ff,$ffff,$ffff,$fffd
	dc.w	$ffff,$fefc,$3800,$0000,$0000,$0001,$ffe0,$4000,$0003,$a800,$03ff,$ffff,$ffff,$ffff,$ffff,$fffa
	dc.w	$1000,$0000,$0000,$0001,$ffc0,$0000,$0007,$0000,$5fff,$ffff,$ffff,$ffff,$ffff,$fff0,$0000,$0000
	dc.w	$0000,$0003,$ff80,$0000,$0022,$0000,$1fff,$ffff,$ffff,$fffe,$ffff,$feaa,$0000,$0000,$0000,$0000
	dc.w	$ff00,$2000,$000c,$0000,$3fff,$ffff,$ffff,$fffd,$ffff,$fe77,$0000,$0000,$0000,$0001,$fe00,$4000
	dc.w	$0030,$0000,$7fff,$ffff,$ffff,$fffe,$ffff,$feae,$0000,$0000,$0000,$0000,$fc00,$0017,$0000,$0000
	dc.w	$ffff,$ffbf,$ffff,$ffff,$ffff,$fd06,$0000,$0000,$0000,$0000,$e380,$00ef,$1000,$0001,$ffff,$ff3f
	dc.w	$ffff,$fffe,$ffff,$fe80,$0000,$0000,$0000,$0000,$0380,$007f,$0000,$0031,$efff,$ff7f,$ffff,$fffd
	dc.w	$ffff,$fd00,$0000,$0000,$0000,$0000,$0070,$003f,$8000,$02f1,$ffff,$ff7f,$ffff,$fffe,$ffff,$faa0
	dc.w	$0000,$0000,$0000,$0000,$00f4,$003f,$e000,$0c71,$ffff,$ffff,$ffff,$fff9,$ffff,$fd00,$0000,$0000
	dc.w	$0000,$0380,$0060,$e03f,$c000,$3de0,$ffff,$ffff,$ffff,$fffd,$7fff,$fab8,$0000,$0000,$0000,$01c0
	dc.w	$0091,$f83f,$8000,$3841,$ffff,$ffff,$ffff,$fffa,$7fff,$ff7c,$0000,$0000,$0000,$01c0,$0003,$fc3f
	dc.w	$0000,$7483,$ffff,$ffff,$ffff,$fff6,$7fff,$febc,$0000,$0002,$0000,$0380,$0003,$fc1e,$0000,$6807
	dc.w	$ffff,$fdff,$ffff,$fff8,$7fff,$ffd9,$e000,$0000,$f000,$03c0,$0003,$fe00,$0000,$2007,$ffff,$ffff
	dc.w	$ffff,$ffee,$7fff,$ffab,$f000,$000f,$f800,$0000,$0003,$fc00,$0000,$0007,$ffff,$ffff,$ffff,$fff4
	dc.w	$7fff,$ffd3,$f800,$001f,$fc00,$0000,$0003,$fc00,$0000,$0007,$ffff,$ffff,$ffff,$fff8,$7fff,$ffab
	dc.w	$f800,$000f,$fc00,$0000,$0019,$fc00,$0000,$0017,$ffff,$ffff,$ffff,$fff6,$7fff,$ffd3,$f800,$007f
	dc.w	$f800,$0000,$0004,$f800,$03c0,$000f,$ffff,$bfff,$ffff,$ffea,$3fff,$ffab,$f800,$007f,$f800,$0000
	dc.w	$001e,$f000,$07d0,$0057,$ffff,$cfff,$ffff,$fff4,$3fff,$fff4,$ff00,$007f,$e000,$0000,$003f,$e000
	dc.w	$0fe0,$0003,$ffff,$ffff,$ffff,$ffe0,$3fff,$ffea,$fbc0,$003f,$8200,$0000,$001f,$c018,$4fe1,$0057
	dc.w	$fffb,$ffff,$ffff,$fff4,$3fff,$ffff,$e7c0,$001f,$040c,$0000,$001f,$8038,$67f0,$800f,$ffff,$ffff
	dc.w	$ffff,$ffd4,$3fff,$ffff,$aff0,$0028,$0a07,$0000,$001e,$0012,$03fc,$8c57,$ffff,$ffff,$ffff,$fff4
	dc.w	$1fff,$fffc,$fff0,$0000,$0703,$8000,$0000,$01ef,$80fe,$b86f,$ffff,$ffff,$ffff,$ffe0,$1fff,$fffe
	dc.w	$fffa,$0000,$0380,$8000,$0018,$1bf7,$823f,$b97f,$ffff,$ffff,$ffff,$ffd0,$1fff,$ffff,$fffd,$c000
	dc.w	$0380,$0000,$001c,$37ff,$a2bf,$80bf,$ffff,$ffff,$ffff,$ffe8,$1fff,$ffff,$fffb,$c000,$0000,$4000
	dc.w	$0038,$2fff,$7fbf,$875f,$ffff,$ffff,$ffff,$ff98,$0fff,$fffd,$fffd,$f400,$0000,$0000,$4030,$0fff
	dc.w	$fd7c,$3fbf,$ffff,$7fff,$ffff,$ffc0,$0fff,$ffff,$ffff,$fe00,$0000,$0000,$4040,$2fff,$fffc,$3fd7
	dc.w	$ffff,$ffff,$ffff,$ffc0,$0fff,$ffff,$fffb,$fc00,$0000,$0000,$2000,$5fff,$fffc,$3fff,$ffff,$ffff
	dc.w	$ffff,$ff90,$0fff,$ffff,$fffb,$fe00,$0000,$0000,$0000,$ffff,$fffc,$5fdf,$ffff,$ffff,$ffff,$ffd0
	dc.w	$07ff,$ffff,$ffff,$fe00,$0000,$0000,$0001,$5fff,$fffe,$0fff,$ffff,$ffff,$ffff,$ff40,$07ff,$ffff
	dc.w	$ffff,$ff00,$0000,$2000,$0000,$9fff,$ffdf,$57ff,$ffff,$ffff,$ffff,$fe80,$07ff,$ffff,$ffff,$ff00
	dc.w	$0000,$0000,$0000,$5fff,$fe8f,$ffff,$ffff,$ffff,$ffff,$ff20,$03ff,$ffff,$ffff,$ff80,$0000,$003b
	dc.w	$0000,$3fff,$fd8f,$ffff,$ffff,$ffff,$ffff,$fd80,$03ff,$ffff,$ffff,$ffc0,$0000,$703d,$0000,$3fff
	dc.w	$fe0f,$fffe,$ffff,$ffff,$ffff,$ff00,$03ff,$ffff,$ffff,$ffe0,$0000,$b8fe,$0000,$1fff,$fe1f,$fffd
	dc.w	$ffff,$ffff,$ffff,$fa40,$01ff,$ffdf,$ffff,$ffd8,$0001,$fdff,$8000,$0bff,$ff9f,$ffff,$ffff,$ffff
	dc.w	$ffff,$fe00,$01ff,$ffff,$ffff,$ffe8,$0001,$bfff,$8010,$00ff,$ffdf,$ffff,$ffff,$ffff,$ffff,$fe80
	dc.w	$01ff,$ffef,$ffff,$fffc,$0001,$fffb,$0370,$83ff,$fffb,$ffff,$ffff,$ffff,$ffff,$fe80,$00ff,$ffff
	dc.w	$ffff,$ffe8,$2000,$fff8,$01a3,$879f,$effd,$7fff,$ffff,$ffff,$ffff,$fe00,$00ff,$ffff,$7fff,$fff8
	dc.w	$f800,$7ff8,$0007,$4fdf,$77ff,$ffff,$ffff,$ffff,$ffff,$f900,$007f,$ffff,$ffff,$fff9,$f800,$ffe8
	dc.w	$0002,$5fdf,$bffd,$ffff,$ffff,$ffff,$ffff,$f800,$007f,$ffff,$ffff,$fff9,$fc03,$ff00,$0000,$9fdf
	dc.w	$bfff,$ffff,$ffff,$ffff,$ffff,$d800,$007f,$ffff,$ffff,$fffb,$fc07,$fe80,$0000,$1fdf,$fd5f,$ffff
	dc.w	$ffff,$ffff,$ffff,$b200,$003f,$ffff,$3fff,$ffff,$7c0f,$ffc0,$001a,$3fcf,$faff,$ffff,$ffff,$ffff
	dc.w	$ffff,$d000,$003f,$ffff,$bfff,$ffff,$f80f,$ffc0,$0038,$3fc7,$ffff,$ffff,$ffff,$ffff,$ffff,$b400
	dc.w	$001f,$ffff,$9fff,$ffff,$fa0f,$ffc0,$0078,$3fc9,$ffff,$f7ff,$ffff,$ffff,$ffff,$a000,$001f,$ffff
	dc.w	$9fff,$ffff,$f407,$ff80,$0070,$3ddf,$dfff,$efff,$ffff,$ffff,$ffff,$e800,$000f,$ffff,$ffff,$ffff
	dc.w	$ff01,$ff00,$0004,$3fbe,$f7ff,$dfff,$ffff,$ffff,$ffff,$c000,$000f,$ffff,$ffff,$ffff,$ffa0,$7f80
	dc.w	$000c,$a35d,$ef7f,$ffff,$ffff,$ffff,$fffe,$d000,$0007,$ffff,$ffff,$ffff,$ffc0,$3f0f,$019c,$58ff
	dc.w	$deff,$ffff,$ffff,$ffff,$ffff,$c000,$0007,$ffff,$ffff,$ffff,$fee0,$2ebf,$07e2,$bddf,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$2000,$0003,$ffff,$ffff,$ffff,$ffe0,$1f7e,$1ffd,$ffff,$ffff,$ffff,$ffff,$ffff
	dc.w	$ffef,$0000,$0003,$ffff,$ffff,$ffff,$ff80,$3efe,$3ffe,$bfdf,$ffff,$ffff,$ffff,$ffff,$ff9c,$4000
	dc.w	$0001,$ffff,$ffbf,$ffff,$ffd0,$7ffc,$7fff,$ffff,$ffff,$ffff,$ffff,$ffff,$ff1e,$0000,$0000,$ffff
	dc.w	$ffff,$ffff,$ffdf,$7ff8,$fffe,$ffff,$ffff,$ffff,$ffff,$ffff,$ff1c,$0000,$0000,$ffff,$ffff,$ffff
	dc.w	$ffdf,$ffe4,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffb8,$0000,$0000,$7fff,$ffff,$ffff,$ffff,$ff8b
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffb8,$0000,$0000,$3fff,$ffff,$ffff,$ffff,$ffbd,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffe0,$0000,$0000,$3fff,$ffff,$fdff,$ffff,$ffe1,$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffb4,$0000,$0000,$1fff,$ffff,$fbff,$ffff,$fb83,$ffff,$ffbf,$ffff,$ffff,$ffff,$ffff
	dc.w	$ffe0,$0000,$0000,$1fff,$ffff,$ffff,$ffff,$f683,$ffff,$1fff,$ffff,$ffff,$ffff,$ffff,$f7e0,$0000
	dc.w	$0000,$0fff,$ffff,$ffff,$ffff,$ffc3,$ffff,$0fff,$ffbf,$ffff,$ffff,$ffff,$e2c0,$0000,$0000,$07ff
	dc.w	$ffff,$ffff,$ffff,$fffd,$ffff,$dfff,$ffff,$ffff,$ffff,$ffff,$e700,$0000,$0000,$03ff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ea00,$0000,$0000,$03ff,$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ec40,$0000,$0000,$01ff,$ffff,$ffff,$ffff,$ffff,$fff7,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff,$e080,$0000,$0000,$00ff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$dfff,$ffff
	dc.w	$ffff,$ffff,$f000,$0000,$0000,$007f,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$bfff,$ffff,$ffff,$ffff
	dc.w	$c000,$0000,$0000,$003f,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$f000,$0000
	dc.w	$0000,$003f,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$e000,$0000,$0000,$001f
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$fffb,$4800,$0000,$0000,$000f,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$fffe,$8000,$0000,$0000,$0007,$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$fffc,$0000,$0000,$0000,$0003,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$fffe,$0000,$0000,$0000,$0001,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffd5,$0000,$0000,$0000,$0000,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$fff8
	dc.w	$0000,$0000,$0000,$0000,$7fff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffe8,$0000,$0000
	dc.w	$0000,$0000,$3fff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffd0,$0000,$0000,$0000,$0000
	dc.w	$1fff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffe0,$0000,$0000,$0000,$0000,$0fff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffc0,$0000,$0000,$0000,$0000,$07ff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ff80,$0000,$0000,$0000,$0000,$03ff,$ffff,$fffb,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ff00,$0000,$0000,$0000,$0000,$01ff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$fc80,$0000,$0000,$0000,$0000,$007f,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$fc00
	dc.w	$0000,$0000,$0000,$0000,$003f,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$5800,$0000,$0000
	dc.w	$0000,$0000,$001f,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$fffe,$c000,$0000,$0000,$0000,$0000
	dc.w	$000f,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$fffd,$5000,$0000,$0000,$0000,$0000,$0003,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$c000,$0000,$0000,$0000,$0000,$0001,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff,$fffd,$8000,$0000,$0000,$0000,$0000,$0000,$ffff,$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$0000,$0000,$0000,$0000,$0000,$0000,$3fff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
	dc.w	$fffc,$0000,$0000,$0000,$0000,$0000,$0000,$0fff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$feb0,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$07ff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$fd60,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$01ff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$fd80,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$00ff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$d700,$0000,$0000,$0000,$0000,$0000,$0000,$003f
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$fc00,$0000,$0000,$0000,$0000,$0000,$0000,$000f,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff,$d000,$0000,$0000,$0000,$0000,$0000,$0000,$0003,$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$c000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$3fff,$ffff,$ffff,$ffff,$ffff,$fffc,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$07ff,$ffff,$ffff,$ffff,$ffff,$ffe0,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$01ff,$ffff,$ffff,$ffff,$ffff,$ff80,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$003f,$ffff,$ffff,$ffff,$ffff,$fc00,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0007,$ffff,$ffff,$ffff,$ffff,$e000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$ffff
	dc.w	$ffff,$ffff,$ffff,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0fff,$ffff,$ffff
	dc.w	$fff0,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$00ff,$ffff,$ffff,$ff00,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0007,$ffff,$ffff,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$07ff,$ff80,$0000,$0000,$0000,$0000,$0000,$0000
L.f42fa




;""""""""""""""""""""
;" THE COPPER LISTS "
;"		    "
;""""""""""""""""""""
	IFD	NOT_USED
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
	ENDC




	section	generated_code,bss

;L.a681e
instruction_buffer3
	ds.w	180*180*4	public memory
; code like this is generated here:
;	or.b    D3,$620(A0)
;	or.b    D3,$604(A0)
;	or.b    D3,$5e8(A0)
;	or.b    D3,$5cc(A0)
;	or.b    D3,$5b0(A0)
;	or.b    D3,$594(A0)
; basically just a huge list of  'or.b    D1-3,offset(A0)'


instruction_buffer2
	ds.w	6000		public memory
; code like this is generated here:
;L.e5c9e
;	move.l  $c8(A1),(A2)+
;	move.l  $cc(A1),(A2)+
;	move.l  $d0(A1),(A2)+
;	move.l  $d4(A1),(A2)+
;	move.l  $d8(A1),(A2)+
;	move.l  $dc(A1),(A2)+
;	move.l  $110(A1),(A2)+
;	move.l  $114(A1),(A2)+
;	move.l  $118(A1),(A2)+
;	move.l  $130(A1),(A2)+
;	move.l  $134(A1),(A2)+
;	move.l  $138(A1),(A2)+
;	move.l  $154(A1),(A2)+
;	move.l  $198(A1),(A2)+
;	move.l  $19c(A1),(A2)+
;	move.l  $1c0(A1),(A2)+
;	move.l  $1c4(A1),(A2)+
;	move.l  $1c8(A1),(A2)+
;	rts
;
;	...
;
;L.e5fd8
;	move.l  $1fc(A1),(A2)+
;	move.l  $200(A1),(A2)+
;	move.l  $204(A1),(A2)+
;	move.l  $208(A1),(A2)+
;	rts
;
;L.e5fea
;	rts
;
;	...


;L.e8b7e
instruction_buffer1
	ds.w	6000		public memory




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
