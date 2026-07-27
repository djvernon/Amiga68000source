	section SaveTracks,code_c


; Read and decode tracks then write data to file


;SAVE_HIGH_SCORES	equ	1


	IFD	SAVE_HIGH_SCORES
START_TRACK	equ	0	(High scores are on track 1 top side)
END_TRACK	equ	0
TRACK_LEN	equ	2068

	ELSE

START_TRACK	equ	2	(Or start at 1 for top side: Extra data for expansion RAM)
END_TRACK	equ	75	(Track 75 is last one required)
TRACK_LEN	equ	5656
	ENDC


;DEBUG	equ	1


;DISABLE_HEAD_THRASHING	equ	1	;Comment out after WIP

;IDENTIFY_BAD_TRACKS	equ	1	;Comment out after WIP
;RETRY_BAD_TRACK	equ	1	;Comment out after WIP

;USE_COPY_PROTECTION	equ	1	;Uncommented for WIP

;DO_TRACK2_SAVE_HEX	equ	1




XMAX	equ	320
YMAX	equ	200
XMID	equ	XMAX/2
YMID	equ	YMAX/2


	move.l	4.w,a6
	IFND	DEBUG
	jsr	-132(a6)		Forbid
	ENDC


	move.l	#2*4*40*200,d0
	moveq	#2,d1			chip
	jsr	-198(a6)		AllocMem
	tst.l	d0
	beq	exit_now
	move.l	d0,screen.mem

	move.l	d0,screen1
	add.l	#4*40*200,d0
	move.l	d0,screen2


	moveq	#0,d0
	lea	graf.name(pc),a1
	jsr	-552(a6)		OpenLibrary
	move.l	d0,gfxbase
	beq	exit_freemem

	move.l	d0,a6
	IFND	DEBUG
	jsr	-456(a6)		OwnBlitter
	ENDC


*"""""""""""""""""""""""""
*" INITIALISE INTERRUPTS "
*"			 "
*"""""""""""""""""""""""""

	IFND	DEBUG
	lea	custom,a6
	move.w	intenar(a6),old.ints	save system interrupt status

	move.w	#$7fff,intena(a6)	disable all interrupts

;	move.l	$64.w,old.level1
;	move.l	$68.w,old.level2
;	move.l	$6c.w,old.level3
;	move.l	$70.w,old.level4
;	move.l	$74.w,old.level5
;	move.l	$78.w,old.level6
;	move.l	$7c.w,old.level7
;	move.l	#new.level1,$64.w
;	move.l	#new.level2,$68.w
;	move.l	#new.level3,$6c.w
;	move.l	#new.level4,$70.w
;	move.l	#new.level5,$74.w
;	move.l	#new.level6,$78.w
;	move.l	#new.level7,$7c.w

;	move.w	#$e839,intena(a6)	enable interrupts


	move.l	$14.w,old.dbz		division-by-zero exception handler
	move.l	#rte.ins,$14.w		set to rte instruction


*"""""""""""""""""""""""""""""
*" INITIALISE SCREEN DISPLAY "
*"			     "
*"""""""""""""""""""""""""""""

	move.w	#$01ff,dmacon(a6)	DMA off, excluding DMAEN


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
	moveq	#0,d0
	move.w	d0,bplcon1(a6)
	move.w	d0,bplcon2(a6)
	moveq	#3*40,d0
	move.w	d0,bpl1mod(a6)
	move.w	d0,bpl2mod(a6)


	bsr	make.copper.lists	initialise copper

	move.l	copper1(pc),cop1lch(a6)
	move.w	d0,copjmp1(a6)


	move.w	#$87c0,dmacon(a6)	DMA on
	ENDC


;"""""""""""""""""""""
;" CALCULATE Y-TABLE "
;"		     "
;"""""""""""""""""""""

	move.w	#200-1,d0
	moveq	#0,d1			offset starts at zero
	move.w	#160,d2			width of four bitplanes
	lea	y.table(pc),a0

y.tab.loop
	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,y.tab.loop


*"""""""""""""""""""""
*" CALL MAIN PROGRAM "
*"		     "
*"""""""""""""""""""""

	IFND	DEBUG
	bsr	clear
	bsr	blitWait
	ENDC

	IFD	SAVE_HIGH_SCORES
	bsr	readHighScoresTrack
	ELSE
	bsr	readTracks
	ENDC
	move.l	d0,readStatus
	bsr	printStatusCode		DJV debug

	bsr	waitLeftMouseBounce


;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""
	;bsr	clear
	;bsr	update.screens
	;bsr	clear
	;bsr	blitWait

	IFND	DEBUG
loop
	IFND	DEBUG
	bsr	frames.per.sec
	ENDC

	jsr	vblWait		NB ensure this routine remains intact
	IFND	DEBUG
	bsr	update.screens

	bsr	clear		For some reason this was once overwriting the FPS text
	bsr	blitWait
	ENDC

	btst	#6,$bfe001
	bne.s	loop
	ENDC


*""""""""""""""""
*" EXIT ROUTINE	"
*"		"
*""""""""""""""""
	IFND	DEBUG
	lea	custom,a6
wait	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	wait


	move.w	#$7fff,intena(a6)	disable all interrupts

;	move.l	old.level1(pc),$64.w
;	move.l	old.level2(pc),$68.w
;	move.l	old.level3(pc),$6c.w
;	move.l	old.level4(pc),$70.w
;	move.l	old.level5(pc),$74.w
;	move.l	old.level6(pc),$78.w
;	move.l	old.level7(pc),$7c.w

	move.w	old.ints(pc),d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status

	move.l	old.dbz(pc),$14.w	restore division-by-zero handler


	move.w	#$03ff,dmacon(a6)	DMA off
	ENDC

	move.l	gfxbase(pc),a1
	IFND	DEBUG
	move.l	38(a1),cop1lch(a6)	restore system copper

	move.w	#$87f0,dmacon(a6)	DMA on
	ENDC


	move.l	a1,a6
	IFND	DEBUG
	jsr	-462(a6)		DisownBlitter
	ENDC

	move.l	a6,a1
	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary

exit_freemem
	move.l	#2*4*40*200,d0
	move.l	screen.mem(pc),a1
	jsr	-210(a6)		FreeMem

exit_now
	IFND	DEBUG
	jsr	-138(a6)		Permit
	ENDC

	IFD	DO_TRACK2_SAVE_HEX
	move.l	theLong1(pc),d0
	bsr	make.hex
	jsr	save_hex_text
	ENDC

	move.l	readStatus(pc),d0
	bne.s	.done
	jsr	save_tracks

.done	moveq	#0,d0
	rts


rte.ins	rte


*"""""""""""""
*" VARIABLES "
*"	     "
*"""""""""""""

screen.mem	dc.l	0

screen1		dc.l	0
screen2		dc.l	0

copper1		dc.l	copper.list1
copper2		dc.l	copper.list2

gfxbase	dc.l	0
old.ints	dc.w	0
;old.level1	dc.l	0
;old.level2	dc.l	0
;old.level3	dc.l	0
;old.level4	dc.l	0
;old.level5	dc.l	0
;old.level6	dc.l	0
;old.level7	dc.l	0
old.dbz		dc.l	0

readStatus	dc.l	0
;theLong1	dc.l	0
DOSBase	dc.l	0
StdOutHandle	dc.l	0
OutFileName	dc.l	0
OutFileHandle	dc.l	0
OutFileMem	dc.l	0
OutFileLen	dc.l	0

y.table	ds.w	200


*"""""""""""""
*" CONSTANTS "
*"	     "
*"""""""""""""

graf.name	dc.b	'graphics.library',0
	even

dosname	dc.b	'dos.library',0
	even

HexAddrFileName	dc.b	"dh0:Hex.txt",0
	even

	IFD	SAVE_HIGH_SCORES
TracksFileName	dc.b	"dh0:HighScor.bin",0
	ELSE
TracksFileName	dc.b	"dh0:Trck2T75.bin",0
	ENDC
	even


;"""""""""""""""""
;" GRAPHICS DATA "
;"		 "
;"""""""""""""""""

colour.table
	dc.w	$000,$eee,$850,$a60,$c71,$e92,$04c,$0be
	dc.w	$a10,$e20,$793,$9c4,$0c0,$fd0,$567,$9ab




;"""""""""""""""""""""
;" OTHER SUBROUTINES "
;"		     "
;"""""""""""""""""""""

blitWait
	btst	#6,dmaconr(a6)
	bne.s	blitWait
	rts


vblWait
	move.w	#$20,$dff09c

.loop	move.w	$dff01e,d0
	btst	#$5,d0
	beq.s	.loop
	move.w	#$20,$dff09c
	rts


clear	lea	$dff000,a6
.loop	btst	#6,dmaconr(a6)
	bne.s	.loop

	move.w	#0,bltdmod(a6)
	move.l	#$1000000,bltcon0(a6)	USE D
	move.l	screen1(pc),bltdpth(a6)
	move.w	#YMAX*4*64+20,bltsize(a6)
	rts




print	move.l	screen1(pc),a1		d0 = x, d1 = y
	add.w	d1,d1			a0 = text ending with 0
	lea	y.table(pc),a2
	add.w	(a2,d1.w),d0
	add.w	d0,a1			screen start address
	moveq	#0,d1
	move.w	#160,d2			bytes per line

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
	move.b	d1,40(a2)		bitplane 2
	move.b	d1,80(a2)		bitplane 3
	move.b	d1,120(a2)		bitplane 4

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




make.hex
	lea	hex.text(pc),a0		d0.l = number
	lea	hex.digits(pc),a1
	moveq	#0,d1

make.hex.loop
	rol.l	#4,d0
	move.w	d0,d2
	and.w	#$f,d2
	move.b	(a1,d2.w),(a0,d1.w)
	addq.w	#1,d1
	cmp.w	#8,d1
	bne.s	make.hex.loop
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
	moveq	#16,d0			x
	moveq	#0,d1			y
	bra	print



old.counter
	dc.w	0



frames.text
	dc.b	'F/S     ',0
	even




update.screens
	move.l	screen1(pc),d0
	move.l	screen2(pc),screen1
	move.l	d0,screen2

	move.l	copper1(pc),d0
	move.l	copper2(pc),copper1
	move.l	d0,copper2

	move.l	d0,cop1lch+$dff000	set new copper list address
	rts




make.copper.lists
	move.l	screen1(pc),d0
	move.l	copper1(pc),a0
	bsr.s	init.copper

	move.l	screen2(pc),d0
	move.l	copper2(pc),a0
;	bra.s	init.copper




init.copper
	moveq	#4-1,d1
	moveq	#40,d2			width of one bitplane

next.plane
	move.w	d0,6(a0)		save low word
	swap	d0
	move.w	d0,2(a0)		save high word
	swap	d0
	add.l	d2,d0			next bitplane
	addq.w	#8,a0			update pointer to copper list
	dbra	d1,next.plane
	rts




;""""""""""""""""""""
;" THE COPPER LISTS "
;"		    "
;""""""""""""""""""""

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




	IFD	DO_TRACK2_SAVE_HEX
save_hex_text
	move.l	#HexAddrFileName,OutFileName
	move.l	#hex.text,OutFileMem
	move.l	#9,OutFileLen
	bra	save_memory
	ENDC

save_tracks
	move.l	#TracksFileName,OutFileName
	move.l	#trackData,OutFileMem
	move.l	#trackDataSize,OutFileLen
	bra	save_memory



save_memory
* Open the DOS library

	moveq	#0,d0
	lea	dosname(pc),a1
	move.l	4.w,a6
	jsr	-552(a6)		OpenLibrary
	move.l	d0,DOSBase
	beq	return_now

* Get standard output handle

	move.l	DOSBase(pc),a6
	jsr	-60(a6)			Output
	move.l	d0,StdOutHandle

* Open output file

	move.l	OutFileName(pc),d1
	move.l	#1006,d2		MODE_NEWFILE
	move.l	DOSBase(pc),a6
	jsr	-30(a6)			Open
	move.l	d0,OutFileHandle
;	beq	error6
	beq	closedos

* Write memory to file

	move.l	OutFileHandle(pc),d1
	move.l	OutFileMem(pc),d2
	move.l	OutFileLen(pc),d3	Length
	move.l	DOSBase(pc),a6
	jsr	-48(a6)			Write
;	tst.l	d0
;	bmi	error7

* Close output file

	move.l	OutFileHandle(pc),d1
	move.l	DOSBase(pc),a6
	jsr	-36(a6)			Close

closedos
	move.l	DOSBase(pc),a1
	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary

return_now
	rts



; d6 = x, d7 = y
wordPrintd0
	move.w	d6,printX
	move.w	d7,printY
	bsr	make.hex

	lea	hex.text+4,a0		only print low word
	move.w	printX(pc),d0
	move.w	printY(pc),d1
	bra	print

; d6 = x, d7 = y
longPrintd0
	move.w	d6,printX
	move.w	d7,printY
	bsr	make.hex

	lea	hex.text,a0		print entire long
	move.w	printX(pc),d0
	move.w	printY(pc),d1
	bra	print

printX	dc.w	0
printY	dc.w	0




*"""""""""""""""""
*" DISK ROUTINES "
*"		 "
*"""""""""""""""""

initDrive
;L7205c
	clr.w	$dff024			DSKLEN
	move.b	#$7d,$bfd100
	move.b	#$75,$bfd100		motor on, select drive 0 (i.e. bit 3 clear), bottom head (i.e. bit 2 set), inward direction (i.e. bit 1 clear)
	move.w	#$4489,$dff07e
	move.w	#$8400,$dff09e		WORDSYNC
	move.w	#$8100,$dff09e		MFM
	move.w	#$8010,$dff096		enable disk DMA (TODO NB with DMAEN also set, otherwise no DMA is enabled)
;    MOVE.W    #$8210,$00DFF096		enable disk DMA (NB with DMAEN also set, otherwise no DMA is enabled)
	move.w	#$2,$dff09c		no DSKBLK interrupt
	rts


TRACK	equr	d1
START_SECTOR	equr	d2
NUM_SECTORS	equr	d3

SECTORS_PER_TRACK	equ	11


readTracks
	bsr	initDrive
	bsr	stepDriveBackAndForth
	st	currentTrack
	IFD	DISABLE_HEAD_THRASHING
	sf	currentTrackReadOK
	ENDC
	move.l	#trackData,a0		destination
	moveq	#START_TRACK,TRACK
	move.w	#(END_TRACK+1-START_TRACK)*SECTORS_PER_TRACK,NUM_SECTORS

;	move.w	#1,topSide		select top side of disk
L721f8
	moveq	#0,START_SECTOR
	moveq	#SECTORS_PER_TRACK,NUM_SECTORS
	move.w	d1,-(a7)
	bsr	readSectorsFromTrack

	IFD	IDENTIFY_BAD_TRACKS
; Also show number of copy protection byte matches in top word
	swap	d0
	move.w	numByteMatches,d0
	swap	d0
	ENDC
	bsr	printStatusCode		DJV debug

	move.w	(a7)+,d1
	tst.l	d0
	IFD	IDENTIFY_BAD_TRACKS
	beq.s	.notBad
	bsr	showBadTrack

	IFD	RETRY_BAD_TRACK
	bsr	stepDriveBackAndForth
	bra.s	L721f8
	ENDC

.notBad
	ELSE
	bne	L72216
	ENDC

	movea.l	a1,a0
	addq.w	#1,TRACK
	cmp.w	#END_TRACK,TRACK
	bls.s	L721f8
;	bra.s	L7221e


L72216
;	load error
L7221e
	bsr	drivesOff
	tst.l	d0
	bpl.s	L720be
	rts


	IFD	IDENTIFY_BAD_TRACKS
showBadTrack
	move.w	#$800,$dff180		set background red
	bsr	waitLeftMouseBounce

	move.w	#$000,$dff180		set background black
	moveq	#0,d0
	bsr	printStatusCode		clear status code
	rts
	ENDC


L720be
;	move.l	#trackData,a0
;	lea	L7269e(pc),a1
;	moveq	#$7,d7
;L720c8
;	cmpm.b	(a0)+,(a1)+
;	bne.s	L720d4
;	dbra	d7,L720c8
	moveq	#$0,d0
	rts


;L720d4
;	moveq	#-$21,d0		; #$ffffffdf
;	rts


drivesOff
	clr.w	$dff024
	move.b	#$7d,$bfd100
	move.b	#$fd,$bfd100
	move.b	#$f5,$bfd100
	move.b	#$fd,$bfd100
	move.w	#$10,$dff096
	rts


;* read sectors from current track
readSectorsFromTrack
;L722c4
	IFD	DISABLE_HEAD_THRASHING
	tst.b	currentTrackReadOK	; DJV Added check to prevent copying of invalid track data (as currentTrack isn't invalidated in this mode)
	beq.s	.retryTrackRead
	ENDC

	cmp.w	currentTrack(pc),TRACK
	beq.s	trackRead

.retryTrackRead
	movem.l	d1-d3/a0,-(a7)
	bsr	readTrack
	movem.l	(a7)+,d1-d3/a0
	tst.l	d0
	bpl.s	trackRead
	IFD	DISABLE_HEAD_THRASHING
	sf	currentTrackReadOK
	ENDC
	IFD	IDENTIFY_BAD_TRACKS
	movea.l	a0,a1			; DJV Also restore a1 upon failure, as process continues when in IDENTIFY_BAD_TRACKS mode
	ENDC
	rts


trackRead
;L722dc
	IFD	DISABLE_HEAD_THRASHING
	st	currentTrackReadOK
	ENDC
	lea	diskBuffer,a1
	mulu.w	#$200,START_SECTOR
	adda.w	START_SECTOR,a1
	mulu.w	#$200,d3
	bra.s	L722ee


copySectors
;L722ec
	move.b	(a1)+,(a0)+
L722ee
	dbra	d3,copySectors
	movea.l	a0,a1
	moveq	#$0,d0
	rts


readTrack
;L722f8
	moveq	#$3,d2			number of retries
L722fa
	IFD	IDENTIFY_BAD_TRACKS
	clr.w	numByteMatches
	ENDC
	lea	currentTrack(pc),a1
	cmp.w	(a1),d1
	beq	L7230e
	bsr	moveHeadToTrack
	bsr	printCurrentTrack	DJV debug
	tst.l	d0
	bmi	L7252a
L7230e
	move.w	#$4489,$dff07e
	move.w	#$8500,$dff09e
	lea	diskBuffer,a0
	move.l	a0,$dff020
	tst.w	topSide
	beq.s	L72338
	move.b	#$71,$bfd100		select top head (i.e. bit 2 clear)
L72338
	btst	#RDY,$bfe001
	bne.s	L72338
	tst.b	$bfdd00
L72348
	btst	#RDY,$bfe001
	bne	L72528
	btst	#$4,$bfdd00		INDEX
	beq.s	L72348
	move.w	#TRACK_LEN!$8000,$dff024	DSKLEN
	move.w	#TRACK_LEN!$8000,$dff024
L7236e
	move.w	$dff01e,d0
	btst	#$1,d0
	bne.s	L72396
	btst	#$4,$bfdd00
	beq.s	L7236e
	clr.w	$dff024
	move.w	#$2,$dff09c
	IFD	IDENTIFY_BAD_TRACKS
	bra	codeF2
	ELSE
	bra	L7252c
	ENDC

;track now read
L72396
	clr.w	$dff024
	move.w	#$2,$dff09c

	IFD	USE_COPY_PROTECTION
; Now read second copy (just 18 words this time)
;	lea	LEnd+$24cc(pc),a1		;L754e0
	lea	diskBuffer2,a1
	move.l	a1,$dff020
	tst.b	$bfdd00
L723b4
	btst	#RDY,$bfe001
	bne	L72528
	btst	#$4,$bfdd00		INDEX
	beq.s	L723b4
	move.w	#$8012,$dff024		DSKLEN
	move.w	#$8012,$dff024		18 words
L723da
	move.w	$dff01e,d0
	btst	#$1,d0
	bne.s	L72402
	btst	#$4,$bfdd00
	beq.s	L723da
	clr.w	$dff024
	move.w	#$2,$dff09c
	IFD	IDENTIFY_BAD_TRACKS
	bra	codeF3
	ELSE
	bra	L7252c
	ENDC

;first 18 words of track now read
L72402
	clr.w	$dff024
	move.w	#$2,$dff09c
	ENDC

; Check the markers bytes in the track data
	moveq	#$9,d0
L72412
	cmpi.w	#$4489,(a0)+
	bne.s	L72420
	cmpi.l	#$2aaaaaaa,(a0)
	beq.s	L72428
L72420
	dbra	d0,L72412
	IFD	IDENTIFY_BAD_TRACKS
	bra	codeF4
	ELSE
	bra	L7252c
	ENDC
L72428
	addq.w	#4,a0

	IFD	USE_COPY_PROTECTION
; Check the markers bytes in the second copy of track data
	moveq	#$9,d0
L7242c
	cmpi.w	#$4489,(a1)+
	bne.s	L7243a
	cmpi.l	#$2aaaaaaa,(a1)
	beq.s	L72442
L7243a
	dbra	d0,L7242c
	IFD	IDENTIFY_BAD_TRACKS
	bra	codeF5
	ELSE
	bra	L7252c
	ENDC

L72442
	addq.w	#4,a1
	ENDC


	IFD	USE_COPY_PROTECTION
; Compare the next eight bytes from both reads
; Check there are not more than three matching bytes
	moveq	#$7,d1
L72446
	cmpm.b	(a0)+,(a1)+
	seq	d0
	swap	d1
	sub.b	d0,d1
	swap	d1
	dbra	d1,L72446
	swap	d1

	IFD	NOT_USED
;DJV zero the total for every odd track, to show bug where numByteMatches value was incorrect afterwards (due to a1 not being restored by readSectorsFromTrack block)
	move.w	currentTrack,d7
	btst	#0,d7
	beq.s	.compare
	moveq	#0,d1
.compare
	ENDC

	cmp.b	#$3,d1
	IFD	IDENTIFY_BAD_TRACKS
	bhi	codeF6
	ELSE
	bhi	L7252c
	ENDC

	ELSE
	addq.w	#8,a0		DJV instead skip past the eight bytes
	ENDC

	addq.w	#4,a0
	move.w	#$4489,d0
	moveq	#$4,d1
L72466
	cmp.w	(a0)+,d0
	beq.s	L72472
	dbra	d1,L72466
	IFD	IDENTIFY_BAD_TRACKS
	bra	codeF7
	ELSE
	bra	L7252c
	ENDC

L72472
	cmp.w	(a0),d0
	bne.s	L72478
	addq.w	#2,a0
L72478
	cmpi.w	#$2aaa,(a0)+
	IFD	IDENTIFY_BAD_TRACKS
	bne	codeF8
	ELSE
	bne	L7252c
	ENDC
	move.w	#$8440,$dff096
	bsr	blit.wait
	clr.l	$dff060
	clr.l	$dff064
	move.l	#$ffffffff,$dff044
	move.w	#$5555,$dff070
	lea	L728ae,a1
	move.l	a1,$dff054
	move.l	a0,$dff050
	adda.w	#5642,a0
	move.l	a0,$dff04c
	move.l	#$de4f000,$dff040	USE A,B,D	D = A.C + B.notC	B shifted right one position
	move.w	#$b044,$dff058		705*64+4 -> 705*4*2 = 5640 bytes
	bsr	blit.wait
	tst.w	(a1)+
	bne.s	L7252c
	tst.w	topSide
	bne.s	L724fe

; Bottom side of disk: Decode the data
	pea	(a1)
	addq.w	#2,a1
	move.w	#$580,d1
	move.l	#$12345678,d0
L724f4
	eor.l	d0,(a1)
	move.l	(a1)+,d0
	dbra	d1,L724f4
	movea.l	(a7)+,a1
L724fe
	move.w	#$57f,d1
	moveq	#$0,d0
	move.w	(a1)+,d0
L72506
	add.l	(a1)+,d0
	dbra	d1,L72506
	cmp.l	(a1),d0
	beq.s	L72514
	moveq	#-$4,d0		; #$fffffffc
	bra.s	L7252e


L72514
	move.w	currentTrack(pc),d1
	lea	L728b0,a1
	cmp.w	(a1),d1
	beq.s	L72524
	moveq	#-$6,d0		; #$fffffffa
	bra.s	L72538

L72524
	moveq	#$0,d0
	rts


L72528
	moveq	#-$2,d0		; #$fffffffe
L7252a
	rts


	IFD	IDENTIFY_BAD_TRACKS
codeF2	moveq	#-14,d0
	bra.s	L7252e
codeF3	moveq	#-13,d0
	bra.s	L7252e
codeF4	moveq	#-12,d0
	bra.s	L7252e
codeF5	moveq	#-11,d0
	bra.s	L7252e
codeF6	moveq	#-10,d0
	move.w	d1,numByteMatches
	bra.s	L7252e
codeF7	moveq	#-9,d0
	bra.s	L7252e
codeF8	moveq	#-8,d0
	bra.s	L7252e
	ENDC
L7252c
	moveq	#-$7,d0		; #$fffffff9
L7252e
	move.w	currentTrack(pc),d1
	btst	#$0,d2
	bne.s	L7253e
L72538
	IFD	DISABLE_HEAD_THRASHING
	nop
	ELSE
	st	currentTrack
	ENDC
L7253e
	dbra	d2,L722fa
	rts


;move disk head to required track
;d1 = required track
moveHeadToTrack
;L72544
	tst.w	(a1)
	bpl.s	L7255e		when track number known
	bsr	waitvbl
toTrack0
;L7254c
	btst	#TK0,$bfe001	is head at track 0 ?
	beq.s	atTrack0
	bsr	stepOutwards2
	bra.s	toTrack0


atTrack0
;L7255c
	clr.w	(a1)
L7255e
	cmp.b	$1(a1),d1
	bne.s	moveHead
	clr.b	(a1)
	moveq	#$0,d0
	rts


moveHead
;L7256a
	bsr	waitvbl
	move.w	(a1),d0
	move.w	d1,(a1)
	sub.w	d0,d1
	bhi.s	L72590
	neg.w	d1
	bne.s	L72584
	moveq	#$0,d0
	rts


L7257e
	bsr	stepOutwards
	bmi.s	L72598
L72584
	dbra	d1,L7257e
	rts


L7258a
	bsr	stepInwards
	bmi.s	L72598
L72590
	dbra	d1,L7258a
	rts


L72596
	moveq	#-$e,d0		; #$fffffff2
L72598
	rts


* just steps drive back and forth one track, ending up in its original position
stepDriveBackAndForth
;L7259a
	bsr	waitvbl
	btst	#TK0,$bfe001	is head at track 0 ?
	beq.s	L725ac
	bsr.s	stepOutwards2
	bra.s	stepInwards2


;* at track 0
L725ac
	bsr.s	stepInwards2
	bra.s	stepOutwards2


stepInwards
;L725b0
	btst	#CHNG,$bfe001
	beq.s	L72596
stepInwards2
;L725ba
	move.b	#$74,$bfd100
	move.b	#$75,$bfd100
	bsr	waitvbl
	moveq	#$0,d0
	rts


stepOutwards
;L725d2
	btst	#CHNG,$bfe001
	beq.s	L72596
stepOutwards2
;L725dc
	move.b	#$76,$bfd100
	move.b	#$77,$bfd100
	bsr	waitvbl
	moveq	#$0,d0
	rts


waitvbl
;L725f4
	move.w	#$20,$dff09c
L725fc
	move.w	$dff01e,d0
	btst	#$5,d0
	beq.s	L725fc
	move.w	#$20,$dff09c
	rts


blit.wait
;L72612
	btst	#$6,$dff002
	bne.s	blit.wait
	rts


L7269e
	dc.w	$5348,$4f2e,$626f,$6f74		;'SHO.boot'

currentTrack
;L726a6
	dc.w	$ffff
	IFD	DISABLE_HEAD_THRASHING
currentTrackReadOK
	dc.b	0,0
	ENDC
topSide
;L726ac
	dc.w	$0000


	IFD	SAVE_HIGH_SCORES
readHighScoresTrack
	bsr	initDrive
	bsr	stepDriveBackAndForth
	st	currentTrack
	move.l	#trackData,a0		destination
	moveq	#0,d1			track 0
	bsr	L5a06
	bsr	drivesOff
* Copy decoded data
	lea	diskBuffer,a2
	lea	trackData,a3
	move.w	#(trackDataSize/2)-1,d4
.copy	move.w	(a2)+,(a3)+
	dbra	d4,.copy
	rts


L5a06
	moveq	#$3,d2
L5a08
;	lea	L64c4(pc),a1
	lea	currentTrack(pc),a1
	cmp.w	(a1),d1
	beq	L5a1c
;	bsr	L5956
	bsr	moveHeadToTrack
	bsr	printCurrentTrack	DJV debug
	tst.l	d0
	bmi	L5b58
L5a1c
	move.w	#$4489,$dff07e
	move.w	#$8500,$dff09e
;	movea.l	L64b2(pc),a0
	lea	diskBuffer,a0
	move.l	a0,$dff020

	move.b	#$71,$bfd100		select top head (i.e. bit 2 clear)

;	moveq	#$1,d0
;L5a38
;	move.b	#$38,L6d3a
L5a40
;	tst.b	L6d3a
;	bne.s	L5a50
;	dbra	d0,L5a38
;	bra	L5b56


L5a50
	btst	#$5,$bfe001
	bne.s	L5a40
	tst.b	$bfdd00
L5a60
	btst	#$5,$bfe001
	bne	L5b56
	btst	#$4,$bfdd00
	beq.s	L5a60
	move.w	#$8814,$dff024
	move.w	#$8814,$dff024
L5a86
	move.w	$dff01e,d0
	btst	#$1,d0
	bne.s	L5aae
	btst	#$4,$bfdd00
	beq.s	L5a86
	clr.w	$dff024
	move.w	#$2,$dff09c
	bra	L5b5a


L5aae
	clr.w	$dff024
	move.w	#$2,$dff09c
	moveq	#$9,d0
L5abe
	cmpi.w	#$4489,(a0)+
	bne.s	L5aca
	cmpi.w	#$2aaa,(a0)
	beq.s	L5ad2
L5aca
	dbra	d0,L5abe
	bra	L5b5a


L5ad2
	addq.w	#2,a0
;	bsr	L1518
	bsr	blit.wait
	clr.l	$dff060
	clr.l	$dff064
	move.l	#$ffffffff,$dff044
	move.w	#$5555,$dff070
	move.w	#$4044,d0		257*64+4 -> 257*4*2 = 2056 bytes
;	movea.l	L64b2(pc),a1
	lea	diskBuffer,a1
	subq.w	#4,a1
	move.l	a1,$dff054
	move.l	a0,$dff050
	adda.w	#$80a,a0
	move.l	a0,$dff04c
	move.l	#$de4f000,$dff040
;	bsr	L150a
;	bsr	L1518
	move.w	d0,$dff058
	bsr	blit.wait
	tst.w	(a1)+
	bne.s	L5b5a
	move.w	#$1ff,d1
	moveq	#$0,d0
	move.w	(a1)+,d0
L5b34
	add.l	(a1)+,d0
	dbra	d1,L5b34
	cmp.l	(a1),d0
	beq.s	L5b42
	moveq	#-$4,d0
	bra.s	L5b5c


L5b42
;	move.w	L64c4(pc),d1
	move.w	currentTrack(pc),d1
;	movea.l	L64b2(pc),a1
	lea	diskBuffer,a1
	cmp.w	-(a1),d1
	beq.s	L5b52
	moveq	#-$6,d0
	bra.s	L5b66


L5b52
	moveq	#$0,d0
	rts


L5b56
	moveq	#-$2,d0
L5b58
	rts


L5b5a
	moveq	#-$7,d0
L5b5c
;	move.w	L64c4(pc),d1
	move.w	currentTrack(pc),d1
	btst	#$0,d2
	bne.s	L5b6c
L5b66
;	st	L64c4
	st	currentTrack
L5b6c
	dbra	d2,L5a08
	rts
	ENDC


*"""""""""""""""""""""
*" DEBUG/DIAGNOSTICS "
*"		     "
*"""""""""""""""""""""
printCurrentTrack
	movem.l	d0-d2/a0-a3,-(a7)

	moveq	#0,d0
	move.w	currentTrack(pc),d0
	moveq	#8,d6			x
	moveq	#0,d7			y
	bsr	wordPrintd0

	movem.l	(a7)+,d0-d2/a0-a3
	rts


;print d0, i.e. status code
printStatusCode
	movem.l	d0-d2/a0-a3,-(a7)

	moveq	#8,d6			x
	moveq	#16,d7			y
	bsr	longPrintd0

	movem.l	(a7)+,d0-d2/a0-a3
	rts


; Wait for left mouse button to be pressed and released
waitLeftMouseBounce
.waitp	btst	#6,$bfe001
	bne.s	.waitp
.waitr	btst	#6,$bfe001
	beq.s	.waitr
	rts


*"""""""""""""""""""""
*"  "
*"		     "
*"""""""""""""""""""""
	section	ChipData,bss_c

L728ae
	ds.w	1
L728b0
	ds.w	1
diskBuffer
	ds.w	TRACK_LEN
diskBuffer2
	ds.w	18
	ds.w	8	; safety margin
numByteMatches
	ds.w	1


trackData
	IFD	SAVE_HIGH_SCORES
	ds.w	4*(512/2)
	ELSE
	ds.w	(END_TRACK+1-START_TRACK)*SECTORS_PER_TRACK*(512/2)
	ENDC
trackDataEnd
trackDataSize	equ	trackDataEnd-trackData


*""""""""""""""""""""""
*" HARDWARE REGISTERS "
*"		      "
*""""""""""""""""""""""

custom	equ	$dff000
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
color0	equ	$180
color1	equ	$182
color2	equ	$184
color4	equ	$188
color8	equ	$190
color16	equ	$1a0

CIAA	equ	$bfe001
CIAB	equ	$bfd000
TBLO	equ	$600			CIA equates
TBHI	equ	$700
KEY	equ	$c00
ICR	equ	$d00
CRA	equ	$e00
CRB	equ	$f00

;$bfe001 bits
RDY	equ	5
TK0	equ	4
CHNG	equ	2
