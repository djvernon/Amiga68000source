	section	Screen,code_c
	opt	o+,o2-




start	move.l	4.w,a6
	jsr	-132(a6)		turn multitasking off

	move.l	#4*40*200,d0
	move.l	#$10002,d1		clear chip
	jsr	-198(a6)		AllocMem
	tst.l	d0
	beq	exit_now
	move.l	d0,screen.mem

	move.l	d0,screen1
;	move.l	#4*40*200,d1
;	add.l	d1,d0
;	move.l	d0,screen2
;	add.l	d1,d0
;	move.l	d0,screen3

	lea	graf.name(pc),a1
	moveq	#0,d0
	jsr	-552(a6)		OpenLibrary
	tst.l	d0
	beq	exit_freemem

	move.l	d0,gfxbase
	move.l	d0,a6
	jsr	-456(a6)		OwnBlitter

	move.l	38(a6),old.copper

	bsr	make.copper.lists

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

	lea	colour.table(pc),a0	initialise colours
	lea	color0(a6),a1
	moveq	#8-1,d0
set.colours
	move.l	(a0)+,(a1)+
	dbra	d0,set.colours

	move.w	#$4200,bplcon0(a6)	initialise screen
	move.w	#$4881,diwstrt(a6)
	move.w	#$10c1,diwstop(a6)
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	move.w	#0,bplcon1(a6)
	move.w	#0,bplcon2(a6)
	move.w	#3*40,bpl1mod(a6)
	move.w	#3*40,bpl2mod(a6)




;"""""""""""""""""""""""""""""""
;" SET THE NEW COPPER LOCATION "
;"			       "
;"""""""""""""""""""""""""""""""

	move.l	copper1,cop1lc(a6)
	move.w	d0,copjmp1(a6)

	move.w	#$87c0,dmacon(a6)	DMA on (bitplane, copper, blitter)




;""""""""""""""""""""""""""""""""
;" INITIALISE LEVEL 3 INTERRUPT "
;"				"
;""""""""""""""""""""""""""""""""

	move.l	$6c.w,old.level3
	move.l	#new.level3,$6c.w




;"""""""""""""""""""""
;" CALCULATE Y-TABLE "
;"		     "
;"""""""""""""""""""""

	move.w	#200-1,d0		count
	moveq	#0,d1			offset starts at zero
	move.w	#160,d2			bytes per line
	lea	y.table(pc),a0
y.tab.loop
	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,y.tab.loop




;""""""""""""""""
;" MAIN PROGRAM	"
;"		"
;""""""""""""""""

	bsr	setup.screen


	lea	title.text(pc),a0
	bsr	text			print title


	bsr	display.3.messages
	dc.w	1,0,0			reading master, blank, blank
	bsr	wait.mouse

	bsr	display.3.messages
	dc.w	0,1,1			blank, error reading, retry
	bsr	wait.mouse

	bsr	display.3.messages
	dc.w	0,4,2			blank, insert backup, continue
	bsr	wait.mouse


	bsr	display.3.messages
	dc.w	2,0,0			writing backup, blank, blank
	bsr	wait.mouse

	bsr	display.3.messages
	dc.w	0,2,1			blank, error writing, retry
	bsr	wait.mouse

	bsr	display.3.messages
	dc.w	0,3,2			blank, insert master, continue
	bsr	wait.mouse


	bsr	display.3.messages
	dc.w	1,0,0			reading master, blank, blank
	bsr	wait.mouse

	bsr	display.3.messages
	dc.w	0,1,1			blank, error reading, retry
	bsr	wait.mouse

	bsr	display.3.messages
	dc.w	0,4,2			blank, insert backup, continue
	bsr	wait.mouse


	bsr	display.3.messages
	dc.w	2,0,0			writing backup, blank, blank
	bsr	wait.mouse

	bsr	display.3.messages
	dc.w	0,2,1			blank, error writing, retry
	bsr	wait.mouse

	bsr	display.3.messages
	dc.w	3,5,0			backup complete, reset, blank
	bsr	wait.mouse




;""""""""""""""""
;" EXIT ROUTINE "
;"		"
;""""""""""""""""

wait2	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait2

	move.l	old.level3(pc),$6c.w

	move.l	old.copper(pc),cop1lc(a6)

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
	move.l	#4*40*200,d0
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

setup.screen
	move.l	screen.mem(pc),a0
	add.w	#3*40,a0		start of screen, bitplane 4

	moveq	#46-1,d5
	bsr.s	window

	moveq	#0,d0			for left border
	moveq	#0,d1			for middle
	moveq	#0,d2			for right border
	moveq	#8-1,d4
	bsr.s	print.lines

	move.w	#142-1,d5


window	bsr.s	print.full.line

	move.w	#$8000,d0		for left border
	moveq	#0,d1			for middle
	moveq	#1,d2			for right border
	move.w	d5,d4
	bsr.s	print.lines


print.full.line
	moveq	#-1,d0			for left border
	moveq	#-1,d1			for middle
	moveq	#-1,d2			for right border
	moveq	#1-1,d4			print 1 line


print.lines
	move.w	d0,(a0)+		save leftmost word

	moveq	#18-1,d3
.loop	move.w	d1,(a0)+		save middle words
	dbra	d3,.loop

	move.w	d2,(a0)+		save rightmost word

	lea	120(a0),a0		to next line of bitplane 4
	dbra	d4,print.lines
	rts




wait.mouse
	btst	#6,$bfe001
	beq.s	mouse.pressed

	btst	#2,potgor(a6)
	bne.s	wait.mouse

mouse.pressed
	rts




display.3.messages
	move.l	(sp)+,a0
	move.w	(a0)+,value1
	move.w	(a0)+,value2
	move.w	(a0)+,value3
	move.l	a0,-(sp)

	lea	position1.text(pc),a0
	bsr.s	text

	lea	text1.pointers(pc),a0
	move.w	value1(pc),d0
	bsr.s	select.text

	lea	position2.text(pc),a0
	bsr.s	text

	lea	text2.pointers(pc),a0
	move.w	value2(pc),d0
	bsr.s	select.text

	lea	position3.text(pc),a0
	bsr.s	text

	lea	text3.pointers(pc),a0
	move.w	value3(pc),d0
	bsr.s	select.text

	rts




select.text
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a0,d0.w),a0
	move.l	a0,-(sp)

	lea	blank.text(pc),a0
	bsr.s	text

	move.l	(sp)+,a0
;	bra.s	text



text	movem.l	d0-d7/a1-a5,-(sp)

	clr.w	d1
	clr.w	d2
	move.b	current.x(pc),d1
	move.b	current.y(pc),d2

	bsr.s	print.text

	move.b	d1,current.x
	move.b	d2,current.y

	movem.l	(sp)+,d0-d7/a1-a5
	rts




print.text
	clr.w	d0
	move.b	(a0)+,d0		get next character

	cmp.b	#6,d0
	bls.s	less.or.equal6

	cmp.b	#13,d0
	beq.s	carriage.return

	bsr.s	print.char

	bra.s	print.text




carriage.return
	move.b	left.border.x(pc),d1	set x to left border value
	addq.w	#8,d2
	bra.s	print.text




less.or.equal6
	tst.b	d0
	beq.s	character.null

	subq.b	#1,d0
	beq.s	change.x

	subq.b	#1,d0
	beq.s	change.y

	subq.b	#1,d0
	beq.s	change.x.y

	subq.b	#1,d0
	beq.s	change.left.border

	subq.b	#1,d0
	beq.s	change.colour

skip.spaces
	move.b	(a0)+,d0
	beq.s	character.null

	cmp.b	#' ',d0
	beq.s	skip.spaces

	subq.w	#1,a0
	bra.s	print.text




change.colour
	move.b	(a0)+,d0
	bsr.s	set.colour
	bra.s	print.text




set.colour
	move.b	d0,d4
	lsr.b	#4,d4
	moveq	#4-1,d3
	lea	print.loop+7(pc),a1

.loop	lsr.b	#1,d0
	scc	d5
	lsr.b	#1,d4
	scs	d6
	eor.b	d5,d6
	move.b	d6,(a1)
	move.b	d5,4(a1)
	lea	16(a1),a1
	dbra	d3,.loop
	rts




change.left.border
	move.b	d1,left.border.x	set to current x
	bra.s	print.text




change.x
	move.b	(a0)+,d1
	bra.s	print.text




change.y
	move.b	(a0)+,d2
	bra.s	print.text




change.x.y
	move.b	(a0)+,d1
	move.b	(a0)+,d2
	bra	print.text




character.null
	rts




print.char
	move.l	screen.mem(pc),a5	start of screen, bitplane 1
	lea	y.table(pc),a1
	move.w	d2,d3
	add.w	d3,d3
	add.w	(a1,d3.w),a5
	add.w	d1,a5			screen start address

	sub.w	#' ',d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0			8 bytes per character
	lea	font(pc),a4
	add.w	d0,a4			start address of character

	addq.w	#1,d1			update x position

	moveq	#8-1,d0

print.loop
	move.b	(a4)+,d6		get byte of character
	move.b	d6,d5
	or.b	#0,d5
	eor.b	#0,d5
	move.b	d5,(a5)			set bitplane 1

	lea	40(a5),a5
	move.b	d6,d5
	or.b	#0,d5
	eor.b	#0,d5
	move.b	d5,(a5)			set bitplane 2

	lea	40(a5),a5
	move.b	d6,d5
	or.b	#0,d5
	eor.b	#0,d5
	move.b	d5,(a5)			set bitplane 3

	lea	40(a5),a5
	move.b	d6,d5
	or.b	#0,d5
	eor.b	#0,d5
	move.b	d5,(a5)			set bitplane 4

	lea	40(a5),a5
	dbra	d0,print.loop		do all bytes of character
	rts




update.screens
	move.l	screen1(pc),d0
	move.l	screen2(pc),screen1
	move.l	screen3(pc),screen2
	move.l	d0,screen3

	move.l	copper1(pc),d0
	move.l	copper2(pc),copper1
	move.l	copper3(pc),copper2
	move.l	d0,copper3

	move.l	d0,cop1lc(a6)		set new copper list address
	rts




make.copper.lists
	move.l	screen1(pc),d0
	move.l	copper1(pc),a0
	bsr.s	init.copper

;	move.l	screen2(pc),d0
;	move.l	copper2(pc),a0
;	bsr.s	init.copper

;	move.l	screen3(pc),d0
;	move.l	copper3(pc),a0
;	bsr.s	init.copper
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




;""""""""""""""""""""""""""""""""""""""""
;	" THE COPPER LIST "
;	"                 "
;	"""""""""""""""""""

copper.list.1
	dc.w	bpl1pth			4 bitplane display
	dc.w	0,bpl1ptl
	dc.w	0,bpl2pth
	dc.w	0,bpl2ptl
	dc.w	0,bpl3pth
	dc.w	0,bpl3ptl
	dc.w	0,bpl4pth
	dc.w	0,bpl4ptl
	dc.w	0

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$1001,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe




copper.list.2
	dc.w	bpl1pth			4 bitplane display
	dc.w	0,bpl1ptl
	dc.w	0,bpl2pth
	dc.w	0,bpl2ptl
	dc.w	0,bpl3pth
	dc.w	0,bpl3ptl
	dc.w	0,bpl4pth
	dc.w	0,bpl4ptl
	dc.w	0

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$1001,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe




copper.list.3
	dc.w	bpl1pth			4 bitplane display
	dc.w	0,bpl1ptl
	dc.w	0,bpl2pth
	dc.w	0,bpl2ptl
	dc.w	0,bpl3pth
	dc.w	0,bpl3ptl
	dc.w	0,bpl4pth
	dc.w	0,bpl4ptl
	dc.w	0

	dc.w	$ffe1,$fffe		PAL enable

	dc.w	$1001,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe




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

screen.mem	dc.l	0

screen1		dc.l	0
screen2		dc.l	0
screen3		dc.l	0

copper1		dc.l	copper.list.1
copper2		dc.l	copper.list.2
copper3		dc.l	copper.list.3

old.ints	dc.w	0
old.dbz		dc.l	0
gfxbase		dc.l	0
old.copper	dc.l	0
old.level3	dc.l	0
next.frame	dc.w	0

left.border.x
	dc.b	0

current.x
	dc.b	0

current.y
	dc.b	0

title.text
	dc.b	5,5,3,7,8,'Realtime Amiga Backerupper'
	dc.b	3,6,24,'Remember, Piracy is illegal!',0

value1	dc.w	0
value2	dc.w	0
value3	dc.w	0

text1.pointers
	dc.l	blank.text
	dc.l	reading.text
	dc.l	writing.text
	dc.l	finished1.text

text2.pointers
	dc.l	blank.text
	dc.l	error1.text
	dc.l	error2.text
	dc.l	insert1.text
	dc.l	insert2.text
	dc.l	finished2.text

text3.pointers
	dc.l	blank.text
	dc.l	retry.text
	dc.l	continue.text

blank.text
	dc.b	1,1,'                                      ',0

position1.text
	dc.b	2,80,5,5,0

reading.text
	dc.b	1,10,'Reading Master Disk',0

writing.text
	dc.b	1,10,'Writing Backup Disk',0

finished1.text
	dc.b	1,13,'Backup Complete',0

position2.text
	dc.b	2,120,5,1,0

error1.text
	dc.b	1,7,'Error Reading Master Disk',0

error2.text
	dc.b	1,7,'Error Writing Backup Disk',0

insert1.text
	dc.b	1,11,'Insert Master Disk',0

insert2.text
	dc.b	1,11,'Insert Backup Disk',0

finished2.text
	dc.b	1,6,'Reset Computer To Run Game',0

position3.text
	dc.b	2,144,5,5,0

retry.text
	dc.b	1,4,'Press Mouse Button To Try Again',0

continue.text
	dc.b	1,5,'Press Mouse Button When Ready',0




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

colour.table
	dc.w	$000,$e00,$0ae,$864,$286,$ca0,$a80,$00c
	dc.w	$eee,$aaa,$04c,$2a4,$060,$666,$e64,$000


y.table	ds.w	200


font	dc.b	$00,$00,$00,$00,$00,$00,$00,$00,$10,$10,$10,$10,$10,$00,$10,$00
	dc.b	$28,$28,$28,$00,$00,$00,$00,$00,$00,$28,$7c,$28,$7c,$28,$00,$00
	dc.b	$10,$3c,$50,$38,$14,$78,$10,$00,$00,$62,$64,$08,$10,$26,$46,$00
	dc.b	$30,$48,$48,$32,$4c,$4c,$32,$00,$18,$08,$10,$00,$00,$00,$00,$00
	dc.b	$08,$10,$20,$20,$20,$10,$08,$00,$10,$08,$04,$04,$04,$08,$10,$00
	dc.b	$00,$54,$38,$7c,$38,$54,$00,$00,$00,$10,$10,$7c,$10,$10,$00,$00
	dc.b	$00,$00,$00,$00,$00,$18,$08,$10,$00,$00,$00,$7e,$00,$00,$00,$00
	dc.b	$00,$00,$00,$00,$00,$18,$18,$00,$02,$04,$08,$10,$20,$40,$80,$00
	dc.b	$7c,$86,$8a,$92,$a2,$c2,$7c,$00,$38,$08,$08,$08,$08,$08,$3e,$00
	dc.b	$3c,$42,$02,$3c,$40,$42,$7e,$00,$3c,$42,$02,$1c,$02,$42,$3c,$00
	dc.b	$0c,$14,$24,$44,$7e,$04,$0e,$00,$7e,$42,$40,$7c,$02,$42,$3c,$00
	dc.b	$3c,$42,$40,$7c,$42,$42,$3c,$00,$7e,$42,$04,$08,$10,$10,$10,$00
	dc.b	$3c,$42,$42,$3c,$42,$42,$3c,$00,$3c,$42,$42,$3e,$02,$42,$3c,$00
	dc.b	$00,$00,$18,$18,$00,$18,$18,$00,$00,$00,$18,$18,$00,$18,$08,$10
	dc.b	$08,$10,$20,$40,$20,$10,$08,$00,$00,$00,$7e,$00,$00,$7e,$00,$00
	dc.b	$20,$10,$08,$04,$08,$10,$20,$00,$3c,$42,$42,$0c,$10,$00,$10,$00
	dc.b	$3c,$42,$5a,$5a,$5e,$40,$3c,$00,$18,$24,$42,$42,$7e,$42,$42,$00
	dc.b	$7c,$22,$22,$3c,$22,$22,$7c,$00,$3c,$42,$40,$40,$40,$42,$3c,$00
	dc.b	$7c,$22,$22,$22,$22,$22,$7c,$00,$7e,$22,$28,$38,$28,$22,$7e,$00
	dc.b	$7e,$22,$28,$38,$28,$20,$70,$00,$3c,$42,$40,$4e,$42,$42,$3e,$00
	dc.b	$ee,$44,$44,$7c,$44,$44,$ee,$00,$38,$10,$10,$10,$10,$10,$38,$00
	dc.b	$3e,$04,$04,$04,$44,$44,$38,$00,$76,$24,$28,$30,$28,$24,$76,$00
	dc.b	$70,$20,$20,$20,$22,$22,$7e,$00,$c3,$66,$5a,$42,$42,$42,$e7,$00
	dc.b	$ce,$64,$54,$54,$4c,$44,$e6,$00,$3c,$42,$42,$42,$42,$42,$3c,$00
	dc.b	$7c,$22,$22,$3c,$20,$20,$70,$00,$3c,$42,$42,$42,$4a,$44,$3a,$00
	dc.b	$7c,$22,$22,$3c,$28,$24,$76,$00,$3c,$42,$40,$3c,$02,$42,$3c,$00
	dc.b	$7c,$54,$10,$10,$10,$10,$38,$00,$ee,$44,$44,$44,$44,$44,$3e,$00
	dc.b	$ee,$44,$44,$44,$28,$28,$10,$00,$e7,$42,$42,$42,$5a,$5a,$24,$00
	dc.b	$82,$44,$28,$10,$28,$44,$82,$00,$ee,$44,$44,$38,$10,$10,$38,$00
	dc.b	$7e,$44,$08,$10,$20,$42,$7e,$00,$3c,$20,$20,$20,$20,$20,$3c,$00
	dc.b	$00,$40,$20,$10,$08,$04,$02,$00,$3c,$04,$04,$04,$04,$04,$3c,$00
	dc.b	$10,$38,$7c,$10,$10,$10,$10,$00,$00,$00,$00,$00,$00,$00,$00,$ff
	dc.b	$30,$18,$0c,$00,$00,$00,$00,$00,$00,$00,$3e,$44,$44,$44,$3e,$00
	dc.b	$60,$20,$3c,$22,$22,$22,$7c,$00,$00,$00,$3c,$42,$40,$42,$3c,$00
	dc.b	$0c,$04,$3c,$44,$44,$44,$3e,$00,$00,$00,$3c,$46,$58,$62,$3c,$00
	dc.b	$18,$24,$20,$78,$20,$20,$70,$00,$00,$00,$3e,$44,$44,$3c,$04,$38
	dc.b	$60,$20,$3c,$22,$22,$22,$62,$00,$10,$00,$30,$10,$10,$10,$38,$00
	dc.b	$02,$00,$06,$02,$02,$42,$42,$3c,$60,$20,$24,$28,$38,$24,$62,$00
	dc.b	$30,$10,$10,$10,$10,$10,$38,$00,$00,$00,$ec,$92,$92,$92,$82,$00
	dc.b	$00,$00,$7c,$22,$22,$22,$22,$00,$00,$00,$3c,$42,$42,$42,$3c,$00
	dc.b	$00,$00,$7c,$22,$22,$3c,$20,$70,$00,$00,$3c,$48,$48,$38,$0a,$0c
	dc.b	$00,$00,$78,$24,$20,$20,$70,$00,$00,$00,$3c,$40,$3c,$02,$7c,$00
	dc.b	$20,$20,$7c,$20,$20,$22,$1c,$00,$00,$00,$66,$24,$24,$24,$1e,$00
	dc.b	$00,$00,$c6,$44,$44,$28,$10,$00,$00,$00,$c6,$54,$54,$7c,$28,$00
	dc.b	$00,$00,$44,$28,$10,$28,$44,$00,$00,$00,$66,$24,$24,$1c,$04,$38
	dc.b	$00,$00,$7e,$48,$10,$22,$7e,$00,$0e,$70,$3c,$46,$58,$62,$3c,$00
	dc.b	$70,$0e,$3c,$46,$58,$62,$3c,$00,$18,$66,$3c,$46,$58,$62,$3c,$00
	dc.b	$00,$00,$20,$54,$08,$00,$00,$00,$1c,$22,$20,$78,$20,$22,$7e,$00
