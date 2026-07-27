	section	ReadMouseJoystick,code_c
	opt	c+


	include	DH0:Devpac/system2.gs




* Open the intuition library

	moveq	#0,d0
	lea	IntuitionName(pc),a1
	CALLEXEC OpenLibrary
	tst.l	d0
	beq	exit_false
	move.l	d0,_IntuitionBase

* Open the graphics library

	moveq	#0,d0
	lea	GfxName(pc),a1
	CALLEXEC OpenLibrary
	tst.l	d0
	beq	exit_closeint
	move.l	d0,_GfxBase

* Open the DOS library

	moveq	#0,d0
	lea	DOSName(pc),a1
	CALLEXEC OpenLibrary
	tst.l	d0
	beq	exit_closegraf
	move.l	d0,_DOSBase

* Allocate screen memory

	move.l	#4*40*200,d0
	move.l	#MEMF_CHIP!MEMF_CLEAR,d1
	CALLEXEC AllocMem
	tst.l	d0
	beq	exit_closedos
	move.l	d0,ScreenMem

* Initialize bitmap

	lea	TheBitMap(pc),a0
	moveq	#4,d0			four bitplanes
	move.l	#320,d1			width
	move.l	#200,d2			height
	CALLGRAF InitBitMap

	move.l	ScreenMem(pc),a0
	lea	TheBitMap(pc),a1
	lea	bm_Planes(a1),a1
	move.l	a0,(a1)+
	lea	40*200(a0),a0
	move.l	a0,(a1)+
	lea	40*200(a0),a0
	move.l	a0,(a1)+
	lea	40*200(a0),a0
	move.l	a0,(a1)

* Open the screen

	lea	TheNewScreen(pc),a0
	CALLINT	OpenScreen
	tst.l	d0
	beq	exit_freemem
	move.l	d0,TheScreen

* Change colours

	move.l	TheScreen(pc),a0
	lea	sc_ViewPort(a0),a0
	lea	colour.table(pc),a1
	moveq	#16,d0			sixteen colours
	CALLGRAF LoadRGB4

* Add vertical blank interrupt server

	moveq	#5,d0
	lea	VBlankInterrupt(pc),a1
	move.b	#NT_INTERRUPT,LN_TYPE(a1)
	move.b	#0,LN_PRI(a1)
	move.l	#VBlankInterruptName,LN_NAME(a1)
	move.l	#VBlankInterruptCode,IS_CODE(a1)
	CALLEXEC AddIntServer

* Add reply port

	sub.l	a1,a1
	CALLEXEC FindTask		find our task

	lea	ReplyPort(pc),a1
	move.b	#NT_MSGPORT,LN_TYPE(a1)
	move.l	d0,MP_SIGTASK(a1)	signal to our task
	CALLEXEC AddPort

* Open input device

	lea	InputDeviceName(pc),a0
	moveq	#0,d0
	lea	InputIORequest(pc),a1
	moveq	#0,d1
	CALLEXEC OpenDevice
	tst.l	d0
	bne	exit_remport

* Add input handler with priority 52

	lea	InputHandlerInterrupt(pc),a0
	move.b	#NT_INTERRUPT,LN_TYPE(a0)
	move.b	#52,LN_PRI(a0)
	move.l	#InputHandlerInterruptName,LN_NAME(a0)
	move.l	#InputHandlerInterruptCode,IS_CODE(a0)

	lea	InputIORequest(pc),a1
	move.l	#ReplyPort,MN_REPLYPORT(a1)
	move.w	#IND_ADDHANDLER,IO_COMMAND(a1)
	move.l	a0,IO_DATA(a1)
	CALLEXEC DoIO

* Open gameport device

	lea	GameportDeviceName(pc),a0
	moveq	#1,d0			Unit 1: Right port
	lea	GameportIORequest(pc),a1
	moveq	#0,d1
	CALLEXEC OpenDevice
	tst.l	d0
	bne	exit_remhandler

* Set port type

	lea	GameportIORequest(pc),a1
	move.l	#ReplyPort,MN_REPLYPORT(a1)
	move.w	#11,IO_COMMAND(a1)	GPD_SETCTYPE
	move.l	#1,IO_LENGTH(a1)
	move.l	#GameportData,IO_DATA(a1)
	move.b	#3,GameportData		GPCT_ABSJOYSTICK
	CALLEXEC DoIO

* Set triggering event

	lea	GameportIORequest,a1
	move.l	#ReplyPort,MN_REPLYPORT(a1)
	move.w	#13,IO_COMMAND(a1)	GPD_SETTRIGGER
	move.l	#8,IO_LENGTH(a1)	gpt_SIZEOF
	move.l	#GameportTrigger,IO_DATA(a1)
	CALLEXEC DoIO




*"""""""""""""""""""""
*" CALCULATE Y-TABLE "
*"		     "
*"""""""""""""""""""""
CalcYTab
	move.w	#200-1,d0
	moveq	#0,d1			offset starts at zero
	moveq	#40,d2			width of one bitplane
	lea	y.table(pc),a0

y.tab.loop
	move.w	d1,(a0)+
	add.w	d2,d1
	dbra	d0,y.tab.loop




*""""""""""""""""
*" PRINT LABELS "
*"		"
*""""""""""""""""

	lea	MouseText(pc),a0
	move.w	#0,d0
	move.w	#60,d1
	bsr	print

	lea	JoystickText(pc),a0
	move.w	#0,d0
	move.w	#140,d1
	bsr	print




*"""""""""""""
*" MAIN LOOP "
*"	     "
*"""""""""""""

MainLoop
	sf	VBlankOccured
WaitVBlank
	tst.b	VBlankOccured
	beq.s	WaitVBlank

* Note that the DoIO call below doesn't cause MainLoop to be suspended until a joystick event occurs,
* because the trigger timeout is set to 1/50 second.  Therefore mouse values continue to be printed
* even when there's no joystick input.
* (Also the WaitVBlank above could be removed).

* wait for joystick event

	lea	GameportIORequest,a1
	move.l	#ReplyPort,MN_REPLYPORT(a1)
	move.w	#9,IO_COMMAND(a1)	GPD_READEVENT
	clr.b	IO_FLAGS(a1)
	move.l	#22,IO_LENGTH(a1)
	move.l	#GameportInputEvent,IO_DATA(a1)
	CALLEXEC DoIO

* print approximate number of seconds elapsed

	addq.l	#1,LoopCount
	move.l	LoopCount,d0
	divu	#50,d0
	moveq	#0,d6
	moveq	#16,d7
	bsr	print.hex.word

* print mouse values

	move.w	MouseCode(pc),d0
	moveq	#18,d6
	moveq	#60,d7
	bsr	print.hex.word

	move.w	MouseX(pc),d0
	moveq	#15,d6
	moveq	#76,d7
	bsr	print.hex.word

	move.w	MouseY(pc),d0
	moveq	#21,d6
	moveq	#76,d7
	bsr	print.hex.word

* print joystick values

	move.w	GameportInputEvent+ie_Qualifier(pc),d0
	moveq	#18,d6
	move.w	#140,d7
	bsr	print.hex.word

	move.w	GameportInputEvent+ie_X(pc),d0
	moveq	#15,d6
	move.w	#156,d7
	bsr	print.hex.word

	move.w	GameportInputEvent+ie_Y(pc),d0
	moveq	#21,d6
	move.w	#156,d7
	bsr	print.hex.word

;	btst	#6,$bfe001
	cmp.w	#IECODE_LBUTTON,MouseCode
	bne	MainLoop




*""""""""""""""""
*" EXIT ROUTINE	"
*"		"
*""""""""""""""""

exit_test

* return port control

	lea	GameportIORequest(pc),a1
	move.l	#ReplyPort,MN_REPLYPORT(a1)
	move.w	#11,IO_COMMAND(a1)	GPD_SETCTYPE
	move.l	#1,IO_LENGTH(a1)
	move.l	#GameportData,IO_DATA(a1)
	move.b	#0,GameportData		GPCT_NOCONTROLLER
	CALLEXEC DoIO

	lea	GameportIORequest(pc),a1
	CALLEXEC CloseDevice

exit_remhandler
	lea	InputIORequest(pc),a1
	move.w	#IND_REMHANDLER,IO_COMMAND(a1)
	move.l	#InputHandlerInterrupt,IO_DATA(a1)
	CALLEXEC DoIO

	lea	InputIORequest(pc),a1
	CALLEXEC CloseDevice

exit_remport
	lea	ReplyPort(pc),a1
	CALLEXEC RemPort

	moveq	#5,d0
	lea	VBlankInterrupt(pc),a1
	CALLEXEC RemIntServer

	move.l	TheScreen(pc),a0
	CALLINT	CloseScreen

exit_freemem
	move.l	ScreenMem(pc),a1
	move.l	#4*40*200,d0
	CALLEXEC FreeMem

exit_closedos
	move.l	_DOSBase(pc),a1
	CALLEXEC CloseLibrary

exit_closegraf
	move.l	_GfxBase(pc),a1
	CALLEXEC CloseLibrary

exit_closeint
	move.l	_IntuitionBase(pc),a1
	CALLEXEC CloseLibrary

exit_false
	moveq	#0,d0
	rts


* the definition of the screen

TheNewScreen	dc.w	0,0		left, top
		dc.w	320,200		width, height
		dc.w	4		depth
		dc.b	0,1		pens
		dc.w	0		viewmodes
		dc.w	CUSTOMBITMAP!CUSTOMSCREEN	type
		dc.l	0		font
		dc.l	ScreenTitle	title
		dc.l	0		gadgets
		dc.l	TheBitMap	bitmap

TheBitMap	ds.w	1		bytes per row
		ds.w	1		rows
		ds.b	1		flags
		ds.b	1		depth
		ds.w	1		pad
		ds.l	8		plane pointers


* the variables

_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DOSBase	dc.l	0
ScreenMem	dc.l	0
TheScreen	dc.l	0
MouseCode	dc.w	0
MouseX		dc.w	0
MouseY		dc.w	0
VBlankOccured	dc.b	0
	even
LoopCount	dc.l	0


VBlankInterrupt	ds.b	IS_SIZE
InputHandlerInterrupt	ds.b	IS_SIZE
ReplyPort	ds.b	MP_SIZE
InputIORequest	ds.b	IOSTD_SIZE
GameportIORequest	ds.b	IOSTD_SIZE
GameportData	ds.b	1
	even
GameportTrigger
	dc.w	0
	dc.w	1	Timeout 1/50 second
	dc.w	0
	dc.w	0
GameportInputEvent	ds.b	ie_SIZEOF


* some strings

IntuitionName	INTNAME
GfxName		GRAFNAME
DOSName		DOSNAME

ScreenTitle	dc.b	'Read Mouse Joystick',0
InputDeviceName	dc.b	'input.device',0
GameportDeviceName	dc.b	'gameport.device',0
VBlankInterruptName	dc.b	'Custom VBlank',0
InputHandlerInterruptName	dc.b	'Custom InputHandler',0
MouseText	dc.b	'Mouse:',0
JoystickText	dc.b	'Joystick:',0
	even




;"""""""""""""""
;" SUBROUTINES "
;"	       "
;"""""""""""""""

VBlankInterruptCode
	movem.l	d0-d7/a0-a6,-(sp)

	st	VBlankOccured

	movem.l	(sp)+,d0-d7/a0-a6
	rts




InputHandlerInterruptCode
	move.l	a0,-(sp)

	move.b	ie_Class(a0),d0
	cmp.b	#IECLASS_RAWMOUSE,d0
	bne.s	ExitInputHandlerInterrupt

	move.w	ie_Code(a0),MouseCode
	move.w	ie_X(a0),MouseX
	move.w	ie_Y(a0),MouseY
;	move.l	ie_NextEvent(a0),a0	get pointer to next event in list

ExitInputHandlerInterrupt
	move.l	a0,d0			return event list pointer
	move.l	(sp)+,a0
	rts




print.hex.word
	bsr	make.hex		d0.w = number
	lea	hex.text+4(pc),a0
	move.w	d6,d0			d6.w = x, d7.w = y
	move.w	d7,d1
	bra	print




print	move.l	ScreenMem(pc),a1	d0 = x, d1 = y
	add.w	d1,d1			a0 = text ending with 0
	lea	y.table(pc),a2
	add.w	(a2,d1.w),d0
	add.w	d0,a1			screen start address

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
	move.b	(a3)+,d1
	move.b	d1,(a2)			copy byte of character, bitplane 1
	move.b	d1,8000(a2)		bitplane 2
	move.b	d1,16000(a2)		bitplane 3
	move.b	d1,24000(a2)		bitplane 4

	lea	40(a2),a2		next screen line
	dbra	d0,char.loop

	addq.l	#1,a1			next column
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




y.table	ds.w	200




*"""""""""""""""""
*" GRAPHICS DATA "
*"		 "
*"""""""""""""""""

colour.table
	dc.w	$000,$060,$0a0,$0e0,$400,$800,$c00,$e00
	dc.w	$004,$008,$00c,$00e,$444,$888,$ccc,$eee
