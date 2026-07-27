	section	SOD,code
	opt	c+


	include	DH0:Devpac/System2.gs


DEBUG	equ	0
IPHASE_LOAD	equ	0

SCREEN_WIDTH	equ	640
SCREEN_HEIGHT	equ	256
SCREEN_DEPTH	equ	2

WINDOWS	equ	6

MAX_OBJECTS	equ	256

MAX_COORDS	equ	200
MAX_COMPONENTS	equ	200

MAX_POLY_SIDES1	equ	6		* Full object defn.
MAX_POLY_SIDES2	equ	10		* Co-ordinates only

MIN_POLY_SIDES	equ	3

CONSOLE1_ROWS	equ	11
CONSOLE1_COLUMNS	equ	25

CONSOLE2_ROWS	equ	1
CONSOLE2_COLUMNS	equ	25

CONSOLE3_ROWS	equ	11
CONSOLE3_COLUMNS	equ	52

CONSOLE4_ROWS	equ	1
CONSOLE4_COLUMNS	equ	52

PLAN_WINDOW_WIDTH	equ	319
PLAN_WINDOW_HEIGHT	equ	128

CONBUF_SIZE	equ	100

INTUITICKS_PER_SECOND	equ	10
ERROR_MSG_SECONDS	equ	5

		rsreset
COORD		rs.w	0
X_VALUE		rs.w	1
Y_VALUE		rs.w	1
Z_VALUE		rs.w	1
COORD_SIZE	rs.w	0

		rsreset
COMPONENT	rs.w	0
SKIP		rs.w	1
CLR		rs.w	1
TYPE		rs.w	1
NUM_COORDS	rs.w	1
COORDS		rs.w	MAX_POLY_SIDES2
COMPONENT_SIZE	rs.w	0

NOCLR	equ	-1			* For components without colour
UNKNCLR	equ	-2			* For new components, unknown colour

OBJECT_NAME_LENGTH	equ	32

		rsreset
OBJECT_NAME	rs.b	OBJECT_NAME_LENGTH
OBJECT_COORDS	rs.b	MAX_COORDS*COORD_SIZE
OBJECT_COMPONENTS	rs.b	MAX_COMPONENTS*COMPONENT_SIZE
OBJECT_TOTAL_COORDS	rs.w	1
OBJECT_TOTAL_COMPONENTS	rs.w	1
OBJECT_MODIFIED	rs.w	1
OBJECT_DEFINITION_SIZE	rs.b	0


* ASCII values

BEL	equ	7
BS	equ	8
HT	equ	9
LF	equ	10
CR	equ	13
ESC	equ	$1b
QUOTE	equ	$27
DEL	equ	$7f
CSI	equ	$9b

* Component types

CIRCLE	equ	1
END	equ	2
GOSUB	equ	3
GOTO	equ	4
POLYGON	equ	5
ROTATE	equ	6
VECTOR	equ	7
ZPRI	equ	8

MAX_COMPONENT_TYPES	equ	8


*"""""""""""""""""
*" START OF CODE "
*"		 "
*"""""""""""""""""

	jsr	initialise.environment


* Execute main code

	bsr	serve.windows


* Close down

	jmp	exit.SOD


*"""""""""""""""
*" SUBROUTINES "
*"	       "
*"""""""""""""""

	include	SODDebug.s


CALLRT	MACRO
	move.l	_ReqBase,a6
	jsr	_LVOrt\1(a6)
	ENDM


****************************************


ERROR	MACRO	; <MESSAGE>

	movem.l	d0-d2/a0-a2,-(sp)

	lea	.error\@(pc),a2
	jsr	error.message

	movem.l	(sp)+,d0-d2/a0-a2
	bra.s	.error\@.done

.error\@
	dc.b	'\1',0
	even

.error\@.done

	ENDM


error.message

* a2 = NULL terminated ASCII error string

	lea	current.screen.title,a0
	lea	screen.title.buffer,a1
	bsr.s	copy.text

	move.l	a2,a0
	bsr.s	copy.text

	move.w	current.window,d2
	beq.s	.beep
	lea	window.msg.counters,a2
	subq.w	#1,d2
	add.w	d2,d2
	move.w	#ERROR_MSG_SECONDS,(a2,d2.w)

	lea	window.ptrs,a2
	add.w	d2,d2
	move.l	(a2,d2.w),a0
	move.w	#-1,a1
	lea	screen.title.buffer,a2
	CALLINT	SetWindowTitles

.beep	move.l	normal.screen,a0
	CALLINT	DisplayBeep
	rts


copy.text
	move.b	(a0)+,(a1)+
	bne.s	copy.text
	subq.w	#1,a1
	rts


****************************************


CHECK	MACRO	; NUMBER, SUBROUTINE, REGISTERS

	move.l	#.check\@.done,-(sp)
.check\@.mask
	movem.l	\3,-(sp)
	jsr	\2
	move.b	ccr,saved.ccr
	move.w	#\1,-(sp)
	move.w	.check\@.mask+2(pc),-(sp)
	jmp	check.registers

.check\@.done

	ENDM


saved.ccr	dc.w	0


check.registers

* (sp).w = register list mask
* 2(sp).w = unique number for this check

	movem.l	d0-d3/a0,.saved.d0
	move.w	(sp)+,d0
	move.w	(sp)+,.check.number
	moveq	#16-1,d1

.loop	btst	d1,d0
	beq.s	.next
	move.l	(sp)+,d2
	move.l	.table(pc,d1.w*4),a0
	jmp	(a0)
.next	dbra	d1,.loop

	movem.l	.saved.d0(pc),d0-d3/a0
	move.b	saved.ccr(pc),ccr
	rts


.table	dc.l	.a7,.a6,.a5,.a4,.a3,.a2,.a1,.a0
	dc.l	.d7,.d6,.d5,.d4,.d3,.d2,.d1,.d0

.a7	move.l	a7,d3
	bra.s	.cond

.a6	move.l	a6,d3
	bra.s	.cond

.a5	move.l	a5,d3
	bra.s	.cond

.a4	move.l	a4,d3
	bra.s	.cond

.a3	move.l	a3,d3
	bra.s	.cond

.a2	move.l	a2,d3
	bra.s	.cond

.a1	move.l	a1,d3
	bra.s	.cond

.a0	move.l	.saved.a0(pc),d3
	bra.s	.cond

.d7	move.l	d7,d3
	bra.s	.cond

.d6	move.l	d6,d3
	bra.s	.cond

.d5	move.l	d5,d3
	bra.s	.cond

.d4	move.l	d4,d3
	bra.s	.cond

.d3	move.l	.saved.d3(pc),d3
	bra.s	.cond

.d2	move.l	.saved.d2(pc),d3
	bra.s	.cond

.d1	move.l	.saved.d1(pc),d3
	bra.s	.cond

.d0	move.l	.saved.d0(pc),d3
;	bra.s	.cond


.cond	cmp.l	d3,d2
	beq	.next			if register not changed

	move.l	d2,.old.reg
	move.l	d3,.new.reg

	movem.l	d0-d1/a0-a4,-(sp)	otherwise inform user of change
	move.l	window1,.check.window

	move.w	d1,-(sp)
	lea	.check.title+6(pc),a0
	move.w	.check.number(pc),d0
	jsr	word.to.ASCII
	move.b	#':',(a0)+
	clr.b	(a0)

	lea	.check.old+11(pc),a0
	move.l	.old.reg(pc),d0
	jsr	longword.to.HEX

	lea	.check.new+11(pc),a0
	move.l	.new.reg(pc),d0
	jsr	longword.to.HEX

	move.w	(sp)+,d1
	lea	.regs(pc,d1.w*2),a0
	lea	.check.prompt+9(pc),a1
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+

	lea	.check.tags(pc),a0
	lea	.check.prompt(pc),a1
	lea	.check.buttons(pc),a2
	sub.l	a3,a3
	sub.l	a4,a4
	CALLRT	EZRequestA

	movem.l	(sp)+,d0-d1/a0-a4
	bra	.next


.regs	dc.b	'A7A6A5A4A3A2A1A0D7D6D5D4D3D2D1D0'

.check.tags
	dc.l	RT_Underscore,'_'
	dc.l	RTEZ_Flags,EZREQF_NORETURNKEY
	dc.l	RTEZ_ReqTitle,.check.title
	dc.l	RT_ReqPos,REQPOS_CENTERSCR
	dc.l	RT_TopOffset,-60
	dc.l	RT_Window
.check.window
	dc.l	0
	dc.l	TAG_END


.check.buffer	dc.b	'00000000'
	even

.check.title	dc.b	'Check 00000:',0
	even

.check.prompt	dc.b	'Register Rn changed !!!',10,10
.check.old	dc.b	'Old value $00000000',10
.check.new	dc.b	'New value $00000000',0
	even

.check.buttons	dc.b	' _Ok ',0
	even


.saved.d0	dc.l	0
.saved.d1	dc.l	0
.saved.d2	dc.l	0
.saved.d3	dc.l	0
.saved.a0	dc.l	0

.old.reg	dc.l	0
.new.reg	dc.l	0

.check.number	dc.w	0


****************************************


window1.main
	bsr	window1.active

window1.start.read
	bsr	start.console1.read

window1.loop
	move.l	window1,a0
	move.l	wd_UserPort(a0),a0
	CALLEXEC GetMsg
	tst.l	d0
	bne.s	window1.event

	lea	read.reply.port1,a0
	CALLEXEC GetMsg
	tst.l	d0
	beq.s	window1.loop

	bsr	console1.interface
	tst.b	window1.deactivated
	bne.s	window1.loop
	bra.s	window1.start.read

window1.event
	move.l	d0,a1
	move.l	im_Class(a1),d2
	move.w	im_Code(a1),d3
	move.w	im_Qualifier(a1),d4
	CALLEXEC ReplyMsg

	cmp.l	#INACTIVEWINDOW,d2
	beq.s	window1.exit

	cmp.l	#MENUPICK,d2
	beq.s	window1.menu

	jsr	intuiticks.handler
	bra.s	window1.loop

window1.menu
	bsr	serve.menus
	move.b	SOD.quit.request(pc),d2
	beq.s	window1.loop

window1.exit
	sf	window1.deactivated
	bsr	window1.inactive
	bra	serve.windows


****************************************


window2.main
	bsr	window2.active

window2.start.read
	bsr	start.console2.read

window2.loop
	moveq	#1,d1
	CALLDOS	Delay

	move.l	window2,a0
	move.l	wd_UserPort(a0),a0
	CALLEXEC GetMsg
	tst.l	d0
	bne.s	window2.event

	lea	read.reply.port2,a0
	CALLEXEC GetMsg
	tst.l	d0
	beq.s	window2.loop

	bsr	console2.interface
	tst.b	window2.deactivated
	bne.s	window2.loop
	bra.s	window2.start.read

window2.event
	move.l	d0,a1
	move.l	im_Class(a1),d2
	move.w	im_Code(a1),d3
	move.w	im_Qualifier(a1),d4
	CALLEXEC ReplyMsg

	cmp.l	#INACTIVEWINDOW,d2
	beq.s	window2.exit

	cmp.l	#MENUPICK,d2
	beq.s	window2.menu

	jsr	intuiticks.handler
	bra.s	window2.loop

window2.menu
	bsr	serve.menus
	move.b	SOD.quit.request(pc),d2
	beq.s	window2.loop

window2.exit
	bsr	window2.inactive
	sf	window2.deactivated
	bra	serve.windows


****************************************


window3.main
	bsr	window3.active

window3.start.read
	bsr	start.console3.read

window3.loop
	move.l	window3,a0
	move.l	wd_UserPort(a0),a0
	CALLEXEC GetMsg
	tst.l	d0
	bne.s	window3.event

	lea	read.reply.port3,a0
	CALLEXEC GetMsg
	tst.l	d0
	beq.s	window3.loop

	bsr	console3.interface
	tst.b	window3.deactivated
	bne.s	window3.loop
	bra.s	window3.start.read

window3.event
	move.l	d0,a1
	move.l	im_Class(a1),d2
	move.w	im_Code(a1),d3
	move.w	im_Qualifier(a1),d4
	CALLEXEC ReplyMsg

	cmp.l	#INACTIVEWINDOW,d2
	beq.s	window3.exit

	cmp.l	#MENUPICK,d2
	beq.s	window3.menu

	jsr	intuiticks.handler
	bra.s	window3.loop

window3.menu
	bsr	serve.menus
	move.b	SOD.quit.request(pc),d2
	beq.s	window3.loop

window3.exit
	bsr	window3.inactive
	sf	window3.deactivated
	bra	serve.windows


****************************************


window4.main
	bsr	window4.active

window4.start.read
	bsr	start.console4.read

window4.loop
	moveq	#1,d1
	CALLDOS	Delay

	move.l	window4,a0
	move.l	wd_UserPort(a0),a0
	CALLEXEC GetMsg
	tst.l	d0
	bne.s	window4.event

	lea	read.reply.port4,a0
	CALLEXEC GetMsg
	tst.l	d0
	beq.s	window4.loop

	bsr	console4.interface
	tst.b	window4.deactivated
	bne.s	window4.loop
	bra.s	window4.start.read

window4.event
	move.l	d0,a1
	move.l	im_Class(a1),d2
	move.w	im_Code(a1),d3
	move.w	im_Qualifier(a1),d4
	CALLEXEC ReplyMsg

	cmp.l	#INACTIVEWINDOW,d2
	beq.s	window4.exit

	cmp.l	#MENUPICK,d2
	beq.s	window4.menu

	jsr	intuiticks.handler
	bra.s	window4.loop

window4.menu
	bsr	serve.menus
	move.b	SOD.quit.request(pc),d2
	beq.s	window4.loop

window4.exit
	bsr	window4.inactive
	sf	window4.deactivated
	bra	serve.windows


****************************************


window5.main
	bsr	window5.active

window5.loop
	move.l	window5,a0
	move.l	wd_UserPort(a0),a0
	CALLEXEC WaitPort

	move.l	window5,a0
	move.l	wd_UserPort(a0),a0
	CALLEXEC GetMsg
	tst.l	d0
	beq.s	window5.loop

window5.event
	move.l	d0,a1
	move.l	im_Class(a1),d2
	move.w	im_Code(a1),d3
	move.w	im_Qualifier(a1),d4
	CALLEXEC ReplyMsg

	cmp.l	#INACTIVEWINDOW,d2
	beq.s	window5.exit

	cmp.l	#RAWKEY,d2
	beq.s	window5.raw.key

	cmp.l	#MENUPICK,d2
	beq.s	window5.menu

	jsr	intuiticks.handler
	bra.s	window5.loop

window5.raw.key
	bsr	serve.raw.keys
	bra.s	window5.loop

window5.menu
	bsr	serve.menus
	move.b	SOD.quit.request(pc),d2
	beq.s	window5.loop

window5.exit
	bsr	window5.inactive
	bra	serve.windows


****************************************


window6.main
	bsr	window6.active

window6.loop
	move.l	window6,a0
	move.l	wd_UserPort(a0),a0
	CALLEXEC WaitPort

	move.l	window6,a0
	move.l	wd_UserPort(a0),a0
	CALLEXEC GetMsg
	tst.l	d0
	beq.s	window6.loop

window6.event
	move.l	d0,a1
	move.l	im_Class(a1),d2
	move.w	im_Code(a1),d3
	move.w	im_Qualifier(a1),d4
	CALLEXEC ReplyMsg

	cmp.l	#INACTIVEWINDOW,d2
	beq.s	window6.exit

	cmp.l	#RAWKEY,d2
	beq.s	window6.raw.key

	cmp.l	#MENUPICK,d2
	beq.s	window6.menu

	jsr	intuiticks.handler
	bra.s	window6.loop

window6.raw.key
	bsr	serve.raw.keys
	bra.s	window6.loop

window6.menu
	bsr	serve.menus
	move.b	SOD.quit.request(pc),d2
	beq.s	window6.loop

window6.exit
	bsr	window6.inactive
	bra	serve.windows


****************************************


start.console1.read
	lea	console1.read.IO.request,a1
	move.l	#read.reply.port1,MN_REPLYPORT(a1)
	move.w	#CMD_READ,IO_COMMAND(a1)
	move.l	#console1.read.buffer,IO_DATA(a1)
	move.l	#CONBUF_SIZE,IO_LENGTH(a1)
	CALLEXEC SendIO
	rts


****************************************


console1.interface
	moveq	#0,d0
	move.b	console1.read.buffer,d0
	cmp.w	#$7f,d0
	bgt	console1.special

	bsr	global.console.interface
	bmi	console1.done		if input was processed

console1.quote
	cmp.b	#QUOTE,d0
	bne.s	console1.tab

	IFNE	DEBUG
	DEBUGM	<QUOTE>
	ENDC

	move.l	window2,a0
	CALLINT	ActivateWindow		switch from co-ord view to entry

	st	window1.deactivated
	rts

console1.tab
	cmp.b	#HT,d0
	bne.s	console1.invalid

	IFNE	DEBUG
	DEBUGM	<HT>
	ENDC

	move.l	window3,a0
	CALLINT	ActivateWindow		switch from co-ords to object defn.

	st	window1.deactivated
	rts

console1.invalid
	IFNE	DEBUG
	DEBUGW	<INV	Command char : >,console1.read.buffer
	ENDC

console1.done
	rts

console1.special
	cmp.b	#CSI,d0
	bne.s	console1.invalid

	move.b	console1.read.buffer+1,d0

console1.up
	cmp.b	#'A',d0
	bne.s	console1.down

	IFNE	DEBUG
	DEBUGM	<Up>
	ENDC

	move.w	console1.cursor.coord,d0
	move.w	console1.cursor.line,d1

	cmp.w	#1,d0
	ble	console1.invalid
	subq.w	#1,d0			if not first co-ord

	cmp.w	#1,d1
	ble.s	.top.line
	subq.w	#1,d1			if not top line

.top.line
	bra	console1.update

console1.down
	cmp.b	#'B',d0
	bne.s	console1.shift.up

	IFNE	DEBUG
	DEBUGM	<Down>
	ENDC

	move.w	console1.cursor.coord,d0
	move.w	console1.cursor.line,d1

	cmp.w	total.coords,d0
	bge	console1.invalid
	addq.w	#1,d0			if not last co-ord

	cmp.w	#CONSOLE1_ROWS,d1
	bge.s	.bottom.line
	addq.w	#1,d1			if not bottom line

.bottom.line
	bra	console1.update

console1.shift.up
	cmp.b	#'T',d0
	bne.s	console1.shift.down

	IFNE	DEBUG
	DEBUGM	<Shift Up>
	ENDC

	move.w	console1.cursor.coord,d0
	move.w	console1.cursor.line,d1

	cmp.w	#1,d0
	ble	console1.invalid

	cmp.w	#1,d1			if not first co-ord
	ble.s	.top.line
	sub.w	d1,d0			if not top line
	moveq	#1,d1			cursor to top line
	add.w	d1,d0
	bra	console1.update

.top.line
	sub.w	#CONSOLE1_ROWS-1,d0

	cmp.w	#1,d0
	bge.s	.valid.coord
	moveq	#1,d0			set to first co-ord

.valid.coord
	bra	console1.update

console1.shift.down
	cmp.b	#'S',d0
	bne	console1.invalid

	IFNE	DEBUG
	DEBUGM	<Shift Down>
	ENDC

	move.w	console1.cursor.coord,d0
	move.w	console1.cursor.line,d1

	cmp.w	total.coords,d0
	bge	console1.invalid

	move.w	#CONSOLE1_ROWS,d2	calculate max. rows in window
	cmp.w	total.coords,d2
	ble.s	.all.rows
	move.w	total.coords,d2

.all.rows
	cmp.w	d2,d1			if not last co-ord
	bge.s	.bottom.line
	sub.w	d1,d0			if not bottom line
	move.w	d2,d1			cursor to bottom line
	add.w	d1,d0
	bra	console1.update

.bottom.line
	add.w	#CONSOLE1_ROWS-1,d0

	cmp.w	total.coords,d0
	ble.s	.valid.coord
	move.w	total.coords,d0	set to last co-ord

.valid.coord
	bra	console1.update


****************************************


start.console2.read
	lea	console2.read.IO.request,a1
	move.l	#read.reply.port2,MN_REPLYPORT(a1)
	move.w	#CMD_READ,IO_COMMAND(a1)
	move.l	#console2.read.buffer,IO_DATA(a1)
	move.l	#CONBUF_SIZE,IO_LENGTH(a1)
	CALLEXEC SendIO
	rts


****************************************


console2.interface
	moveq	#0,d0
	move.b	console2.read.buffer,d0
	cmp.w	#$7f,d0
	bgt	console2.special

	bsr	global.console.interface
	bmi	console2.done		if input was processed

console2.entry
	lea	alpha.numeric.check(pc),a1
	move.b	(a1,d0.w),d1		check char. is one to be output
	bmi	console2.backspace

	move.w	console2.entry.len,d2
	cmp.w	console2.entry.columns,d2	check for buffer overflow
	bge	console2.invalid

	lea	console2.entry.buffer,a1
	move.w	console2.entry.pos,d3
	cmp.w	d2,d3
	beq.s	.save			if at end of command buffer

	move.w	d2,d4			else inserting into buffer
	sub.w	d3,d4
	subq.w	#1,d4
	lea	(a1,d2.w),a2
.move	move.b	-1(a2),(a2)		move trailing chars. right by one
	lea	-1(a2),a2
	dbra	d4,.move

	lea	console2.write.buffer,a0
	move.b	#CSI,(a0)+
	move.b	#'@',(a0)+		insert a space
	clr.b	(a0)
	movem.l	d1/d3/a1,-(sp)
	bsr	console2.output.buffer
	movem.l	(sp)+,d1/d3/a1

.save	move.b	d1,(a1,d3.w)		save char. in buffer
	addq.w	#1,console2.entry.len
	addq.w	#1,console2.entry.pos

	IFNE	DEBUG
	DEBUGS	<Entry,	Command : >,#console2.entry.buffer
;	DEBUGW	<	Command len : >,console2.entry.len
;	DEBUGW	<	Command pos : >,console2.entry.pos
	ENDC

	move.b	d1,console2.write.buffer
	bra	console2.output.char

console2.backspace
	cmp.b	#BS,d0
	bne	console2.delete

	move.w	console2.entry.pos,d3
	beq	console2.invalid

	lea	console2.entry.buffer,a1
	clr.b	-1(a1,d3.w)		clear char. at previous position

	move.w	console2.entry.len,d2
	cmp.w	d2,d3
	beq.s	.done			if at end of command buffer

	sub.w	d3,d2			else deleting inside buffer
	lea	-1(a1,d3.w),a2
.move	move.b	1(a2),(a2)+		move trailing chars. left by one
	dbra	d2,.move

.done	subq.w	#1,console2.entry.len
	subq.w	#1,console2.entry.pos

	IFNE	DEBUG
	DEBUGS	<BS,	Command : >,#console2.entry.buffer
;	DEBUGW	<	Command len : >,console2.entry.len
;	DEBUGW	<	Command pos : >,console2.entry.pos
	ENDC

	lea	console2.write.buffer,a0
	move.b	#BS,(a0)+
	move.b	#CSI,(a0)+
	move.b	#'P',(a0)+
	clr.b	(a0)
	bra	console2.output.buffer

console2.delete
	cmp.b	#DEL,d0
	bne	console2.return

	move.w	console2.entry.len,d2
	move.w	console2.entry.pos,d3
	cmp.w	d2,d3
	beq	console2.invalid

	lea	console2.entry.buffer,a1
	clr.b	(a1,d3.w)		clear char. at current position

	sub.w	d3,d2
	subq.w	#1,d2
	lea	(a1,d3.w),a2
.move	move.b	1(a2),(a2)+		move trailing chars. left by one
	dbra	d2,.move

	subq.w	#1,console2.entry.len

	IFNE	DEBUG
	DEBUGS	<DEL,	Command : >,#console2.entry.buffer
;	DEBUGW	<	Command len : >,console2.entry.len
;	DEBUGW	<	Command pos : >,console2.entry.pos
	ENDC

	lea	console2.write.buffer,a0
	move.b	#CSI,(a0)+
	move.b	#'P',(a0)+
	clr.b	(a0)
	bra	console2.output.buffer

console2.return
	cmp.b	#CR,d0
	bne.s	console2.escape

	IFNE	DEBUG
	DEBUGS	<CR,	Command : >,#console2.entry.buffer
	ENDC

	move.l	console2.entry.parser,a1
	jmp	(a1)

console2.escape
	cmp.b	#ESC,d0
	bne.s	console2.quote

	IFNE	DEBUG
	DEBUGS	<ESC,	Command : >,#console2.entry.buffer
	ENDC

	move.l	#console2.command.parse.list,console2.entry.parsers.ptr
	bra	set.console2.entry.parser

console2.quote
	cmp.b	#QUOTE,d0
	bne.s	console2.tab

	IFNE	DEBUG
	DEBUGS	<QUOTE,	Command : >,#console2.entry.buffer
	ENDC

	move.l	window1,a0
	CALLINT	ActivateWindow		switch from co-ord entry to view

	st	window2.deactivated
	rts

console2.tab
	cmp.b	#HT,d0
	bne.s	console2.invalid

	IFNE	DEBUG
	DEBUGS	<HT,	Command : >,#console2.entry.buffer
	ENDC

	move.l	window4,a0
	CALLINT	ActivateWindow		switch from co-ords to object defn.

	st	window2.deactivated
	rts

console2.invalid
	IFNE	DEBUG
	DEBUGW	<INV	Command char : >,console2.read.buffer
	ENDC

console2.done
	rts

console2.special
	cmp.b	#CSI,d0
	bne.s	console2.invalid

	move.b	console2.read.buffer+1,d0

console2.right
	cmp.b	#'C',d0
	bne	console2.left

	move.w	console2.entry.len,d2
	cmp.w	console2.entry.pos,d2
	ble	console2.invalid

	addq.w	#1,console2.entry.pos

	IFNE	DEBUG
	DEBUGS	<Right,	Command : >,#console2.entry.buffer
;	DEBUGW	<	Command len : >,console2.entry.len
;	DEBUGW	<	Command pos : >,console2.entry.pos
	ENDC

	lea	console2.write.buffer,a0
	move.b	#CSI,(a0)+
	move.b	#'C',(a0)+
	clr.b	(a0)
	bra	console2.output.buffer

console2.left
	cmp.b	#'D',d0
	bne	console2.invalid

	move.w	console2.entry.pos,d3
	beq	console2.invalid

	subq.w	#1,console2.entry.pos

	IFNE	DEBUG
	DEBUGS	<Left,	Command : >,#console2.entry.buffer
;	DEBUGW	<	Command len : >,console2.entry.len
;	DEBUGW	<	Command pos : >,console2.entry.pos
	ENDC

	lea	console2.write.buffer,a0
	move.b	#CSI,(a0)+
	move.b	#'D',(a0)+
	clr.b	(a0)
	bra	console2.output.buffer


alpha.numeric.check
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$20,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$ff,$2d,$ff,$ff
	dc.b	$30,$31,$32,$33,$34,$35,$36,$37
	dc.b	$38,$39,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$41,$42,$43,$44,$45,$46,$47
	dc.b	$48,$49,$4a,$4b,$4c,$4d,$4e,$4f
	dc.b	$50,$51,$52,$53,$54,$55,$56,$57
	dc.b	$58,$59,$5a,$ff,$ff,$ff,$ff,$ff
	dc.b	$ff,$41,$42,$43,$44,$45,$46,$47
	dc.b	$48,$49,$4a,$4b,$4c,$4d,$4e,$4f
	dc.b	$50,$51,$52,$53,$54,$55,$56,$57
	dc.b	$58,$59,$5a,$ff,$ff,$ff,$ff,$ff
	even


****************************************


start.console3.read
	lea	console3.read.IO.request,a1
	move.l	#read.reply.port3,MN_REPLYPORT(a1)
	move.w	#CMD_READ,IO_COMMAND(a1)
	move.l	#console3.read.buffer,IO_DATA(a1)
	move.l	#CONBUF_SIZE,IO_LENGTH(a1)
	CALLEXEC SendIO
	rts


****************************************


console3.interface
	moveq	#0,d0
	move.b	console3.read.buffer,d0
	cmp.w	#$7f,d0
	bgt	console3.special

	bsr	global.console.interface
	bmi	console3.done		if input was processed

console3.quote
	cmp.b	#QUOTE,d0
	bne.s	console3.tab

	IFNE	DEBUG
	DEBUGM	<QUOTE>
	ENDC

	move.l	window4,a0
	CALLINT	ActivateWindow		switch from component view to entry

	st	window3.deactivated
	rts

console3.tab
	cmp.b	#HT,d0
	bne.s	console3.invalid

	IFNE	DEBUG
	DEBUGM	<HT>
	ENDC

	move.l	window1,a0
	CALLINT	ActivateWindow		switch from object defn. to co-ords

	st	window3.deactivated
	rts

console3.invalid
	IFNE	DEBUG
	DEBUGW	<INV	Command char : >,console3.read.buffer
	ENDC

console3.done
	rts

console3.special
	cmp.b	#CSI,d0
	bne.s	console3.invalid

	move.b	console3.read.buffer+1,d0

console3.up
	cmp.b	#'A',d0
	bne.s	console3.down

	IFNE	DEBUG
	DEBUGM	<Up>
	ENDC

	move.w	console3.cursor.component,d0
	move.w	console3.cursor.line,d1

	cmp.w	#1,d0
	ble	console3.invalid
	subq.w	#1,d0			if not first co-ord

	cmp.w	#1,d1
	ble.s	.top.line
	subq.w	#1,d1			if not top line

.top.line
	bra	console3.update

console3.down
	cmp.b	#'B',d0
	bne.s	console3.shift.up

	IFNE	DEBUG
	DEBUGM	<Down>
	ENDC

	move.w	console3.cursor.component,d0
	move.w	console3.cursor.line,d1

	cmp.w	total.components,d0
	bge	console3.invalid
	addq.w	#1,d0			if not last co-ord

	cmp.w	#CONSOLE3_ROWS,d1
	bge.s	.bottom.line
	addq.w	#1,d1			if not bottom line

.bottom.line
	bra	console3.update

console3.shift.up
	cmp.b	#'T',d0
	bne.s	console3.shift.down

	IFNE	DEBUG
	DEBUGM	<Shift Up>
	ENDC

	move.w	console3.cursor.component,d0
	move.w	console3.cursor.line,d1

	cmp.w	#1,d0
	ble	console3.invalid

	cmp.w	#1,d1			if not first co-ord
	ble.s	.top.line
	sub.w	d1,d0			if not top line
	moveq	#1,d1			cursor to top line
	add.w	d1,d0
	bra	console3.update

.top.line
	sub.w	#CONSOLE3_ROWS-1,d0

	cmp.w	#1,d0
	bge.s	.valid.coord
	moveq	#1,d0			set to first co-ord

.valid.coord
	bra	console3.update

console3.shift.down
	cmp.b	#'S',d0
	bne	console3.shift.right

	IFNE	DEBUG
	DEBUGM	<Shift Down>
	ENDC

	move.w	console3.cursor.component,d0
	move.w	console3.cursor.line,d1

	cmp.w	total.components,d0
	bge	console3.invalid

	move.w	#CONSOLE3_ROWS,d2	calculate max. rows in window
	cmp.w	total.components,d2
	ble.s	.all.rows
	move.w	total.components,d2

.all.rows
	cmp.w	d2,d1			if not last co-ord
	bge.s	.bottom.line
	sub.w	d1,d0			if not bottom line
	move.w	d2,d1			cursor to bottom line
	add.w	d1,d0
	bra	console3.update

.bottom.line
	add.w	#CONSOLE3_ROWS-1,d0

	cmp.w	total.components,d0
	ble.s	.valid.coord
	move.w	total.components,d0	set to last co-ord

.valid.coord
	bra	console3.update

console3.shift.right
	cmp.b	#' ',d0
	bne	console3.invalid

	move.b	console3.read.buffer+2,d0

	cmp.b	#'@',d0
	bne.s	console3.shift.left

	IFNE	DEBUG
	DEBUGM	<Shift Right>
	ENDC

	move.b	console3.coords.only,d1
	bne	console3.invalid

	move.l	#window3.active.title2,window3.current.active.title
	st	console3.coords.only

	move.l	window3(pc),a0
	move.l	window3.current.active.title(pc),a1
	move.w	#-1,a2
	CALLINT	SetWindowTitles

	bra	console3.refresh

console3.shift.left
	cmp.b	#'A',d0
	bne	console3.invalid

	IFNE	DEBUG
	DEBUGM	<Shift Left>
	ENDC

	move.b	console3.coords.only,d1
	beq	console3.invalid

	move.l	#window3.active.title1,window3.current.active.title
	sf	console3.coords.only

	move.l	window3(pc),a0
	move.l	window3.current.active.title(pc),a1
	move.w	#-1,a2
	CALLINT	SetWindowTitles

	bra	console3.refresh


****************************************


start.console4.read
	lea	console4.read.IO.request,a1
	move.l	#read.reply.port4,MN_REPLYPORT(a1)
	move.w	#CMD_READ,IO_COMMAND(a1)
	move.l	#console4.read.buffer,IO_DATA(a1)
	move.l	#CONBUF_SIZE,IO_LENGTH(a1)
	CALLEXEC SendIO
	rts


****************************************


console4.interface
	moveq	#0,d0
	move.b	console4.read.buffer,d0
	cmp.w	#$7f,d0
	bgt	console4.special

	bsr	global.console.interface
	bmi	console4.done		if input was processed

console4.entry
	lea	alpha.numeric.check(pc),a1
	move.b	(a1,d0.w),d1		check char. is one to be output
	bmi	console4.backspace

	move.w	console4.entry.len,d2
	cmp.w	console4.entry.columns,d2	check for buffer overflow
	bge	console4.invalid

	lea	console4.entry.buffer,a1
	move.w	console4.entry.pos,d3
	cmp.w	d2,d3
	beq.s	.save			if at end of command buffer

	move.w	d2,d4			else inserting into buffer
	sub.w	d3,d4
	subq.w	#1,d4
	lea	(a1,d2.w),a2
.move	move.b	-1(a2),(a2)		move trailing chars. right by one
	lea	-1(a2),a2
	dbra	d4,.move

	lea	console4.write.buffer,a0
	move.b	#CSI,(a0)+
	move.b	#'@',(a0)+		insert a space
	clr.b	(a0)
	movem.l	d1/d3/a1,-(sp)
	bsr	console4.output.buffer
	movem.l	(sp)+,d1/d3/a1

.save	move.b	d1,(a1,d3.w)		save char. in buffer
	addq.w	#1,console4.entry.len
	addq.w	#1,console4.entry.pos

	IFNE	DEBUG
	DEBUGS	<Entry,	Command : >,#console4.entry.buffer
;	DEBUGW	<	Command len : >,console4.entry.len
;	DEBUGW	<	Command pos : >,console4.entry.pos
	ENDC

	move.b	d1,console4.write.buffer
	bra	console4.output.char

console4.backspace
	cmp.b	#BS,d0
	bne	console4.delete

	move.w	console4.entry.pos,d3
	beq	console4.invalid

	lea	console4.entry.buffer,a1
	clr.b	-1(a1,d3.w)		clear char. at previous position

	move.w	console4.entry.len,d2
	cmp.w	d2,d3
	beq.s	.done			if at end of command buffer

	sub.w	d3,d2			else deleting inside buffer
	lea	-1(a1,d3.w),a2
.move	move.b	1(a2),(a2)+		move trailing chars. left by one
	dbra	d2,.move

.done	subq.w	#1,console4.entry.len
	subq.w	#1,console4.entry.pos

	IFNE	DEBUG
	DEBUGS	<BS,	Command : >,#console4.entry.buffer
;	DEBUGW	<	Command len : >,console4.entry.len
;	DEBUGW	<	Command pos : >,console4.entry.pos
	ENDC

	lea	console4.write.buffer,a0
	move.b	#BS,(a0)+
	move.b	#CSI,(a0)+
	move.b	#'P',(a0)+
	clr.b	(a0)
	bra	console4.output.buffer

console4.delete
	cmp.b	#DEL,d0
	bne	console4.return

	move.w	console4.entry.len,d2
	move.w	console4.entry.pos,d3
	cmp.w	d2,d3
	beq	console4.invalid

	lea	console4.entry.buffer,a1
	clr.b	(a1,d3.w)		clear char. at current position

	sub.w	d3,d2
	subq.w	#1,d2
	lea	(a1,d3.w),a2
.move	move.b	1(a2),(a2)+		move trailing chars. left by one
	dbra	d2,.move

	subq.w	#1,console4.entry.len

	IFNE	DEBUG
	DEBUGS	<DEL,	Command : >,#console4.entry.buffer
;	DEBUGW	<	Command len : >,console4.entry.len
;	DEBUGW	<	Command pos : >,console4.entry.pos
	ENDC

	lea	console4.write.buffer,a0
	move.b	#CSI,(a0)+
	move.b	#'P',(a0)+
	clr.b	(a0)
	bra	console4.output.buffer

console4.return
	cmp.b	#CR,d0
	bne.s	console4.escape

	IFNE	DEBUG
	DEBUGS	<CR,	Command : >,#console4.entry.buffer
	ENDC

	move.l	console4.entry.parser,a1
	jmp	(a1)

console4.escape
	cmp.b	#ESC,d0
	bne.s	console4.quote

	IFNE	DEBUG
	DEBUGS	<ESC,	Command : >,#console4.entry.buffer
	ENDC

	move.l	#console4.command.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.quote
	cmp.b	#QUOTE,d0
	bne.s	console4.tab

	IFNE	DEBUG
	DEBUGS	<QUOTE,	Command : >,#console4.entry.buffer
	ENDC

	move.l	window3(pc),a0
	CALLINT	ActivateWindow		switch from component entry to view

	st	window4.deactivated
	rts

console4.tab
	cmp.b	#HT,d0
	bne.s	console4.invalid

	IFNE	DEBUG
	DEBUGS	<HT,	Command : >,#console4.entry.buffer
	ENDC

	move.l	window2(pc),a0
	CALLINT	ActivateWindow		switch from object defn. to co-ords

	st	window4.deactivated
	rts

console4.invalid
	IFNE	DEBUG
	DEBUGW	<INV	Command char : >,console4.read.buffer
	ENDC

console4.done
	rts

console4.special
	cmp.b	#CSI,d0
	bne.s	console4.invalid

	move.b	console4.read.buffer+1(pc),d0

console4.right
	cmp.b	#'C',d0
	bne.s	console4.left

	move.w	console4.entry.len,d2
	cmp.w	console4.entry.pos,d2
	ble.s	console4.invalid

	addq.w	#1,console4.entry.pos

	IFNE	DEBUG
	DEBUGS	<Right,	Command : >,#console4.entry.buffer
;	DEBUGW	<	Command len : >,console4.entry.len
;	DEBUGW	<	Command pos : >,console4.entry.pos
	ENDC

	lea	console4.write.buffer(pc),a0
	move.b	#CSI,(a0)+
	move.b	#'C',(a0)+
	clr.b	(a0)
	bra	console4.output.buffer

console4.left
	cmp.b	#'D',d0
	bne	console4.invalid

	move.w	console4.entry.pos,d3
	beq	console4.invalid

	subq.w	#1,console4.entry.pos

	IFNE	DEBUG
	DEBUGS	<Left,	Command : >,#console4.entry.buffer
;	DEBUGW	<	Command len : >,console4.entry.len
;	DEBUGW	<	Command pos : >,console4.entry.pos
	ENDC

	lea	console4.write.buffer(pc),a0
	move.b	#CSI,(a0)+
	move.b	#'D',(a0)+
	clr.b	(a0)
	bra	console4.output.buffer


****************************************


global.console.interface

* d0.b = first input character
*
* returns 1 if input was not recognised
* returns -1 if input was recognised and processed

.check.prev
	cmp.b	#',',d0			previous object command
	bne	.check.next

	IFNE	DEBUG
	DEBUGM	<Global previous object>
	ENDC

	move.w	current.SOD.object,d0
	cmp.w	#1,d0
	ble	.processed

	bsr	store.current.SOD.object
	subq.w	#1,current.SOD.object
	bsr	set.current.SOD.object
	bra	.processed

.check.next
	cmp.b	#'.',d0			next object command
	bne	.done

	IFNE	DEBUG
	DEBUGM	<Global next object>
	ENDC

	move.w	current.SOD.object,d0
	cmp.w	total.SOD.objects,d0
	bge.s	.processed

	bsr	store.current.SOD.object
	addq.w	#1,current.SOD.object
	bsr	set.current.SOD.object

.processed
	moveq	#-1,d1
	rts

.done	moveq	#1,d1
	rts


****************************************


console2.command.parser
	move.b	console2.entry.buffer,d0
	move.b	console2.entry.buffer+1,d1
	move.b	console2.entry.buffer+2,d2

console2.check.ACS
	cmp.b	#'A',d0
	bne	console2.check.DC
	cmp.b	#'C',d1
	bne	console2.command.invalid

	move.w	total.coords,d0
	addq.w	#1,d0			insert at end of co-ords i.e. add
	move.w	d0,coord.insert.pos

	cmp.b	#'S',d2
	bne	console2.command.AC

	lea	console2.entry.buffer+3,a0
	bsr	get.number.of.extra.coords
	bmi	console2.command.invalid
	move.w	d0,extra.coords
	cmp.w	#1,d0
	beq	console2.begin.AC

	IFNE	DEBUG
	DEBUGW	<ACS,	Co-ords to add : >,extra.coords
	ENDC

	move.l	#console2.ACS.parse.list,console2.entry.parsers.ptr
	bra	set.console2.entry.parser

console2.command.AC
	lea	console2.entry.buffer+2,a0
	bsr	get.number.of.extra.coords
	bmi	console2.command.invalid
	move.w	d0,extra.coords

console2.begin.AC
	IFNE	DEBUG
	DEBUGW	<AC,	Co-ords to add : >,extra.coords
	ENDC

	move.l	#console2.AC.parse.list,console2.entry.parsers.ptr
	bra	set.console2.entry.parser

console2.check.DC
	cmp.b	#'D',d0
	bne	console2.check.ICS
	cmp.b	#'C',d1
	bne	console2.command.invalid

	lea	console2.entry.buffer+2,a0
	bsr	get.coord.range
	bmi	console2.command.invalid

	IFNE	DEBUG
	DEBUGW	<DC,	Co-ord pos1 : >,coord.pos1
	DEBUGW	<	Co-ord pos2 : >,coord.pos2
	ENDC

	jsr	check.components.allow.coord.deletion
	bmi.s	console2.DC.invalid
	jsr	delete.coord.range
	bsr	console1.delete
	bsr	console3.refresh
	bsr	refresh.plan.views

	move.l	#console2.command.parse.list,console2.entry.parsers.ptr
	bra	set.console2.entry.parser

console2.DC.invalid
	ERROR	<  Components forbid co-ord deletion>
	rts

console2.check.ICS
	cmp.b	#'I',d0
	bne	console2.check.MC
	cmp.b	#'C',d1
	bne	console2.command.invalid
	cmp.b	#'S',d2
	bne	console2.command.IC

	lea	console2.entry.buffer+3(pc),a0
	bsr	get.number.of.extra.coords
	bmi	console2.command.invalid
	move.w	d0,extra.coords
	cmp.w	#1,d0
	beq	console2.begin.IC

	IFNE	DEBUG
	DEBUGW	<ICS,	Co-ords to insert : >,extra.coords
	ENDC

	move.l	#console2.ICS.parse.list,console2.entry.parsers.ptr
	bra	set.console2.entry.parser

console2.command.IC
	lea	console2.entry.buffer+2(pc),a0
	bsr	get.number.of.extra.coords
	bmi	console2.command.invalid
	move.w	d0,extra.coords

console2.begin.IC
	IFNE	DEBUG
	DEBUGW	<IC,	Co-ords to insert : >,extra.coords
	ENDC

	move.l	#console2.IC.parse.list,console2.entry.parsers.ptr
	bra	set.console2.entry.parser

console2.check.MC
	cmp.b	#'M',d0
	bne	console2.check.PC
	cmp.b	#'C',d1
	bne	console2.command.invalid

	lea	console2.entry.buffer+2(pc),a0
	bsr	get.coord.range
	bmi	console2.command.invalid
	move.w	coord.pos1,coord.modify.pos

	IFNE	DEBUG
	DEBUGW	<MC,	Co-ord pos1 : >,coord.pos1
	DEBUGW	<	Co-ord pos2 : >,coord.pos2
	ENDC

	move.l	#console2.MC.parse.list,console2.entry.parsers.ptr
	bra	set.console2.entry.parser

console2.check.PC
	cmp.b	#'P',d0
	bne.s	console2.command.invalid
	cmp.b	#'C',d1
	bne	console2.command.invalid


console2.command.invalid
	ERROR	<  Command invalid>
	rts


****************************************


store.coord.insert.pos
	lea	console2.entry.buffer(pc),a0
	bsr	get.coord.insert.pos
	bmi.s	coord.insert.pos.invalid
	move.w	d0,coord.insert.pos

	IFNE	DEBUG
	DEBUGW	<Co-ord insert pos : >,coord.insert.pos
	ENDC

	bra	set.console2.entry.parser


coord.insert.pos.invalid
	ERROR	<  Insert position invalid>
	rts


****************************************


store.x.value
	lea	console2.entry.buffer(pc),a0
	bsr	get.coord.value
	bmi	coord.value.invalid
	move.w	d0,coord.x.value

	IFNE	DEBUG
	DEBUGW	<Co-ord x value : >,coord.x.value
	ENDC

	bra	set.console2.entry.parser


****************************************


store.y.value
	lea	console2.entry.buffer(pc),a0
	bsr	get.coord.value
	bmi	coord.value.invalid
	move.w	d0,coord.y.value

	IFNE	DEBUG
	DEBUGW	<Co-ord y value : >,coord.y.value
	ENDC

	bra	set.console2.entry.parser


****************************************


store.z.value
	lea	console2.entry.buffer(pc),a0
	bsr	get.coord.value
	bmi	coord.value.invalid
	move.w	d0,coord.z.value

	IFNE	DEBUG
	DEBUGW	<Co-ord z value : >,coord.z.value
	ENDC

	bra	set.console2.entry.parser


****************************************


store.x.step
	lea	console2.entry.buffer(pc),a0
	bsr	get.coord.value
	bmi	coord.value.invalid
	move.w	d0,coord.x.step

	IFNE	DEBUG
	DEBUGW	<Co-ord x step : >,coord.x.step
	ENDC

	bra	set.console2.entry.parser


****************************************


store.y.step
	lea	console2.entry.buffer(pc),a0
	bsr	get.coord.value
	bmi	coord.value.invalid
	move.w	d0,coord.y.step

	IFNE	DEBUG
	DEBUGW	<Co-ord y step : >,coord.y.step
	ENDC

	bra	set.console2.entry.parser


****************************************


store.z.step.insert.coords
	lea	console2.entry.buffer(pc),a0
	bsr	get.coord.value
	bmi	coord.value.invalid
	move.w	d0,coord.z.step

	IFNE	DEBUG
	DEBUGW	<Co-ord z step : >,coord.z.step
	ENDC

	move.w	coord.x.step,d5
	move.w	coord.y.step,d6
	move.w	coord.z.step,d7

.insert	jsr	insert.coord
	add.w	d5,coord.x.value
	add.w	d6,coord.y.value
	add.w	d7,coord.z.value

	addq.w	#1,coord.insert.pos
	subq.w	#1,extra.coords
	bne.s	.insert

	bsr	console1.refresh
	bsr	console3.refresh
	bsr	refresh.plan.views
	bra	set.console2.entry.parser


****************************************


store.z.value.insert.coord
	lea	console2.entry.buffer(pc),a0
	bsr	get.coord.value
	bmi	coord.value.invalid
	move.w	d0,coord.z.value

	IFNE	DEBUG
	DEBUGW	<Co-ord z value : >,coord.z.value
	ENDC

	jsr	insert.coord
	bsr	console1.refresh
	bsr	console3.refresh
	bsr	refresh.plan.views
	subq.w	#1,extra.coords
	beq.s	.done

	addq.w	#1,coord.insert.pos
	move.l	#console2.AC.parse.list,console2.entry.parsers.ptr

.done	bra	set.console2.entry.parser


****************************************


store.z.value.modify.coord
	lea	console2.entry.buffer(pc),a0
	bsr	get.coord.value
	bmi	coord.value.invalid
	move.w	d0,coord.z.value

	IFNE	DEBUG
	DEBUGW	<Co-ord z value : >,coord.z.value
	ENDC

	jsr	modify.coord
	bsr	console1.refresh
	bsr	refresh.plan.views

	move.w	coord.modify.pos,d0
	cmp.w	coord.pos2,d0
	bge.s	.done

	addq.w	#1,coord.modify.pos
	move.l	#console2.MC.parse.list,console2.entry.parsers.ptr

.done	bra.s	set.console2.entry.parser


coord.value.invalid
	ERROR	<  Co-ord value invalid>
	rts


****************************************


set.console2.entry.parser
	move.l	console2.entry.parsers.ptr(pc),a5

	move.l	(a5)+,a0
	bsr	console2.output.string

	move.w	(a5)+,console2.entry.columns
	move.w	#0,console2.entry.len
	move.w	#0,console2.entry.pos

	moveq	#0,d3
	moveq	#CONSOLE2_COLUMNS-1,d4
	lea	console2.entry.buffer(pc),a4
.clear	move.b	d3,(a4)+		clear previous input from buffer
	dbra	d4,.clear

	move.l	(a5)+,console2.entry.parser

	move.l	a5,console2.entry.parsers.ptr
	rts


****************************************


console2.ICS.parse.list
	dc.l	prompt.insert.pos.text
	dc.w	CONSOLE2_COLUMNS-10
	dc.l	store.coord.insert.pos

console2.ACS.parse.list
	dc.l	prompt.x.start.text
	dc.w	CONSOLE2_COLUMNS-9
	dc.l	store.x.value

	dc.l	prompt.y.start.text
	dc.w	CONSOLE2_COLUMNS-9
	dc.l	store.y.value

	dc.l	prompt.z.start.text
	dc.w	CONSOLE2_COLUMNS-9
	dc.l	store.z.value

	dc.l	prompt.x.step.text
	dc.w	CONSOLE2_COLUMNS-8
	dc.l	store.x.step

	dc.l	prompt.y.step.text
	dc.w	CONSOLE2_COLUMNS-8
	dc.l	store.y.step

	dc.l	prompt.z.step.text
	dc.w	CONSOLE2_COLUMNS-8
	dc.l	store.z.step.insert.coords

console2.command.parse.list
	dc.l	prompt.command.text
	dc.w	CONSOLE2_COLUMNS-9
	dc.l	console2.command.parser


console2.IC.parse.list
	dc.l	prompt.insert.pos.text
	dc.w	CONSOLE2_COLUMNS-10
	dc.l	store.coord.insert.pos

console2.AC.parse.list
	dc.l	prompt.x.value.text
	dc.w	CONSOLE2_COLUMNS-9
	dc.l	store.x.value

	dc.l	prompt.y.value.text
	dc.w	CONSOLE2_COLUMNS-9
	dc.l	store.y.value

	dc.l	prompt.z.value.text
	dc.w	CONSOLE2_COLUMNS-9
	dc.l	store.z.value.insert.coord

	dc.l	prompt.command.text
	dc.w	CONSOLE2_COLUMNS-9
	dc.l	console2.command.parser


console2.MC.parse.list
	dc.l	prompt.x.value.text
	dc.w	CONSOLE2_COLUMNS-9
	dc.l	store.x.value

	dc.l	prompt.y.value.text
	dc.w	CONSOLE2_COLUMNS-9
	dc.l	store.y.value

	dc.l	prompt.z.value.text
	dc.w	CONSOLE2_COLUMNS-9
	dc.l	store.z.value.modify.coord

	dc.l	prompt.command.text
	dc.w	CONSOLE2_COLUMNS-9
	dc.l	console2.command.parser


prompt.insert.pos.text
	dc.b	CR,'POSITION>',CSI,'K',0

prompt.x.start.text
	dc.b	CR,'X START>',CSI,'K',0

prompt.y.start.text
	dc.b	CR,'Y START>',CSI,'K',0

prompt.z.start.text
	dc.b	CR,'Z START>',CSI,'K',0

prompt.x.step.text
	dc.b	CR,'X STEP>',CSI,'K',0

prompt.y.step.text
	dc.b	CR,'Y STEP>',CSI,'K',0

prompt.z.step.text
	dc.b	CR,'Z STEP>',CSI,'K',0

prompt.x.value.text
	dc.b	CR,'X VALUE>',CSI,'K',0

prompt.y.value.text
	dc.b	CR,'Y VALUE>',CSI,'K',0

prompt.z.value.text
	dc.b	CR,'Z VALUE>',CSI,'K',0

prompt.coord.text
	dc.b	CR,'CO-ORD>',CSI,'K',0

prompt.coord1.text
	dc.b	CR,'CO-ORD 1>',CSI,'K',0

prompt.coord2.text
	dc.b	CR,'CO-ORD 2>',CSI,'K',0

prompt.radius.text
	dc.b	CR,'RADIUS>',CSI,'K',0

prompt.goto.pos.text
	dc.b	CR,'GOTO POSITION>',CSI,'K',0

prompt.gosub.pos.text
	dc.b	CR,'GOSUB POSITION>',CSI,'K',0

prompt.skip.pos.text
	dc.b	CR,'SKIP POSITION>',CSI,'K',0

prompt.num.coords.text
	dc.b	CR,'NUMBER OF CO-ORDS>',CSI,'K',0

prompt.command.text
	dc.b	CR,'COMMAND>',CSI,'K',0
	even


****************************************


console4.command.parser
	move.b	console4.entry.buffer(pc),d0
	move.b	console4.entry.buffer+1(pc),d1

console4.check.AC
	cmp.b	#'A',d0
	bne	console4.check.DC

	bsr	check.space.for.extra.component
	bmi	console4.command.invalid
	move.w	total.components,d0
	addq.w	#1,d0			insert at end of components i.e. add
	move.w	d0,component.insert.pos

	cmp.b	#'C',d1
	bne.s	console4.check.AE

	move.w	#CIRCLE,component.type
	move.l	#console4.AC.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.check.AE
	cmp.b	#'E',d1
	bne.s	console4.check.AG

	move.w	#END,component.type
	jsr	insert.component
	bsr	console3.refresh
	bsr	refresh.plan.views

	move.l	#console4.command.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.check.AG
	cmp.b	#'G',d1
	bne.s	console4.check.AP

	move.w	#GOTO,component.type
	move.l	#console4.AG.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.check.AP
	cmp.b	#'P',d1
	bne.s	console4.check.AR

	move.w	#POLYGON,component.type
	clr.w	num.polygon.coords
	move.l	#console4.AP.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.check.AR
	cmp.b	#'R',d1
	bne.s	console4.check.AS

	move.w	#ROTATE,component.type
	move.l	#console4.AR.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.check.AS
	cmp.b	#'S',d1
	bne.s	console4.check.AV

	move.w	#GOSUB,component.type
	move.l	#console4.AS.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.check.AV
	cmp.b	#'V',d1
	bne.s	console4.check.AZ

	move.w	#VECTOR,component.type
	move.l	#console4.AV.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.check.AZ
	cmp.b	#'Z',d1
	bne	console4.command.invalid

	move.w	#ZPRI,component.type
	move.l	#console4.AZ.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.check.DC
	cmp.b	#'D',d0
	bne	console4.check.IC
	cmp.b	#'C',d1
	bne	console4.command.invalid

	lea	console4.entry.buffer+2(pc),a0
	bsr	get.component.range
	bmi	console4.command.invalid

	IFNE	DEBUG
	DEBUGW	<DC,	Component pos1 : >,component.pos1
	DEBUGW	<	Component pos2 : >,component.pos2
	ENDC

	jsr	check.skips.allow.component.deletion
	bmi.s	console4.DC.invalid
	jsr	delete.component.range
	bsr	console3.delete
	bsr	refresh.plan.views

	move.l	#console4.command.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.DC.invalid
	ERROR	<  Skips forbid component deletion>
	rts

console4.check.IC
	cmp.b	#'I',d0
	bne	console4.check.MC

	bsr	check.space.for.extra.component
	bmi	console4.command.invalid

	cmp.b	#'C',d1
	bne.s	console4.check.IE

	move.w	#CIRCLE,component.type
	move.l	#console4.IC.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.check.IE
	cmp.b	#'E',d1
	bne.s	console4.check.IG

	move.w	#END,component.type
	move.l	#console4.IE.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.check.IG
	cmp.b	#'G',d1
	bne.s	console4.check.IP

	move.w	#GOTO,component.type
	move.l	#console4.IG.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.check.IP
	cmp.b	#'P',d1
	bne.s	console4.check.IR

	move.w	#POLYGON,component.type
	clr.w	num.polygon.coords
	move.l	#console4.IP.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.check.IR
	cmp.b	#'R',d1
	bne.s	console4.check.IS

	move.w	#ROTATE,component.type
	move.l	#console4.IR.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.check.IS
	cmp.b	#'S',d1
	bne.s	console4.check.IV

	move.w	#GOSUB,component.type
	move.l	#console4.IS.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.check.IV
	cmp.b	#'V',d1
	bne.s	console4.check.IZ

	move.w	#VECTOR,component.type
	move.l	#console4.IV.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.check.IZ
	cmp.b	#'Z',d1
	bne	console4.command.invalid

	move.w	#ZPRI,component.type
	move.l	#console4.IZ.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.check.MC
	cmp.b	#'M',d0
	bne	console4.command.invalid
	cmp.b	#'C',d1
	bne	console4.check.MO

	lea	console4.entry.buffer+2(pc),a0
	bsr	get.component.pos
	bmi	console4.command.invalid
	move.w	d0,component.modify.pos

	jsr	get.component.type
	cmp.w	#CIRCLE,d0
	bne	console4.command.invalid

	IFNE	DEBUG
	DEBUGW	<Component modify position : >,component.modify.pos
	ENDC

	move.l	#console4.MC.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.check.MO
	cmp.b	#'O',d1
	bne	console4.check.MP

	lea	console4.entry.buffer+2(pc),a0
	bsr	get.component.pos
	bmi	console4.command.invalid
	move.w	d0,component.modify.pos

	jsr	get.component.type
	cmp.w	#POLYGON,d0
	bne	console4.command.invalid

	IFNE	DEBUG
	DEBUGW	<Component modify position : >,component.modify.pos
	ENDC

	move.l	component.memory(pc),a0
	move.w	component.modify.pos,d0
	subq.w	#1,d0
	mulu	#COMPONENT_SIZE,d0
	add.l	d0,a0

	move.w	NUM_COORDS(a0),d0
	move.w	d0,num.polygon.coords
	subq.w	#1,d0
	lea	COORDS(a0),a1
	lea	polygon.coords,a2

.loop	move.w	(a1)+,d1
	bpl.s	.plus
	neg.w	d1
.plus	move.w	d1,(a2)+
	dbra	d0,.loop

	clr.w	num.orientation.coords
	move.l	#console4.MO.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.check.MP
	cmp.b	#'P',d1
	bne	console4.check.MR

	lea	console4.entry.buffer+2(pc),a0
	bsr	get.component.pos
	bmi	console4.command.invalid
	move.w	d0,component.modify.pos

	jsr	get.component.type
	cmp.w	#POLYGON,d0
	bne	console4.command.invalid

	IFNE	DEBUG
	DEBUGW	<Component modify position : >,component.modify.pos
	ENDC

	clr.w	num.polygon.coords
	move.l	#console4.MP.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.check.MR
	cmp.b	#'R',d1
	bne	console4.check.MS

	lea	console4.entry.buffer+2(pc),a0
	bsr	get.component.pos
	bmi	console4.command.invalid
	move.w	d0,component.modify.pos

	jsr	get.component.type
	cmp.w	#ROTATE,d0
	bne	console4.command.invalid

	IFNE	DEBUG
	DEBUGW	<Component modify position : >,component.modify.pos
	ENDC

	move.l	#console4.MR.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.check.MS
	cmp.b	#'S',d1
	bne	console4.check.MV

	lea	console4.entry.buffer+2(pc),a0
	bsr	get.component.pos
	bmi	console4.command.invalid
	move.w	d0,component.modify.pos

	jsr	get.component.type
	cmp.w	#GOSUB,d0
	beq.s	.skip.used
	cmp.w	#GOTO,d0
	beq.s	.skip.used
	cmp.w	#POLYGON,d0
	beq.s	.skip.used
	cmp.w	#ZPRI,d0
	bne	console4.command.invalid

.skip.used
	IFNE	DEBUG
	DEBUGW	<Component modify position : >,component.modify.pos
	ENDC

	move.l	#console4.MS.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.check.MV
	cmp.b	#'V',d1
	bne	console4.check.MZ

	lea	console4.entry.buffer+2(pc),a0
	bsr	get.component.pos
	bmi	console4.command.invalid
	move.w	d0,component.modify.pos

	jsr	get.component.type
	cmp.w	#VECTOR,d0
	bne	console4.command.invalid

	IFNE	DEBUG
	DEBUGW	<Component modify position : >,component.modify.pos
	ENDC

	move.l	#console4.MV.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.check.MZ
	cmp.b	#'Z',d1
	bne	console4.command.invalid

	lea	console4.entry.buffer+2(pc),a0
	bsr	get.component.pos
	bmi	console4.command.invalid
	move.w	d0,component.modify.pos

	jsr	get.component.type
	cmp.w	#ZPRI,d0
	bne.s	console4.command.invalid

	IFNE	DEBUG
	DEBUGW	<Component modify position : >,component.modify.pos
	ENDC

	move.l	#console4.MZ.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

console4.command.invalid
	ERROR	<  Command invalid>
	rts


****************************************


store.component.coord.pos
	lea	console4.entry.buffer(pc),a0
	bsr	get.coord.pos
	bmi	coord.pos.invalid
	move.w	d0,component.coord.pos

	IFNE	DEBUG
	DEBUGW	<Component co-ord pos : >,component.coord.pos
	ENDC

	bra	set.console4.entry.parser


store.component.coord.pos1
	lea	console4.entry.buffer(pc),a0
	bsr	get.coord.pos
	bmi	coord.pos.invalid
	move.w	d0,component.coord.pos1

	IFNE	DEBUG
	DEBUGW	<Component co-ord pos1 : >,component.coord.pos1
	ENDC

	bra	set.console4.entry.parser


store.component.coord.pos2.insert.component
	lea	console4.entry.buffer(pc),a0
	bsr	get.coord.pos
	bmi	coord.pos.invalid
	move.w	d0,component.coord.pos2

	IFNE	DEBUG
	DEBUGW	<Component co-ord pos2 : >,component.coord.pos2
	ENDC

	jsr	insert.component
	bsr	console3.refresh
	bsr	refresh.plan.views

	bra	set.console4.entry.parser


store.component.coord.pos2.modify.component
	lea	console4.entry.buffer(pc),a0
	bsr	get.coord.pos
	bmi.s	coord.pos.invalid
	move.w	d0,component.coord.pos2

	IFNE	DEBUG
	DEBUGW	<Component co-ord pos2 : >,component.coord.pos2
	ENDC

	jsr	modify.component
	bsr	console3.refresh
	bsr	refresh.plan.views

	bra	set.console4.entry.parser


coord.pos.invalid
	ERROR	<  Co-ord position invalid>
	rts


****************************************


store.radius.insert.component
	lea	console4.entry.buffer(pc),a0
	bsr	get.radius.value
	bmi	radius.value.invalid
	move.l	d0,radius.value

	IFNE	DEBUG
	DEBUGL	<Radius value : >,radius.value
	ENDC

	jsr	insert.component
	bsr	console3.refresh
	bsr	refresh.plan.views

	bra	set.console4.entry.parser


store.radius.modify.component
	lea	console4.entry.buffer(pc),a0
	bsr	get.radius.value
	bmi.s	radius.value.invalid
	move.l	d0,radius.value

	IFNE	DEBUG
	DEBUGL	<Radius value : >,radius.value
	ENDC

	jsr	modify.component
	bsr	console3.refresh
	bsr	refresh.plan.views

	bra	set.console4.entry.parser


radius.value.invalid
	ERROR	<  Radius value invalid>
	rts


****************************************


store.component.insert.pos
	lea	console4.entry.buffer(pc),a0
	bsr	get.component.insert.pos
	bmi	component.insert.pos.invalid
	move.w	d0,component.insert.pos

	IFNE	DEBUG
	DEBUGW	<Component insert position : >,component.insert.pos
	ENDC

	bra	set.console4.entry.parser


store.component.insert.pos.insert.component
	lea	console4.entry.buffer(pc),a0
	bsr	get.component.insert.pos
	bmi	component.insert.pos.invalid
	move.w	d0,component.insert.pos

	IFNE	DEBUG
	DEBUGW	<Component insert position : >,component.insert.pos
	ENDC

	jsr	insert.component
	bsr	console3.refresh
	bsr	refresh.plan.views

	bra	set.console4.entry.parser


component.insert.pos.invalid
	ERROR	<  Insert position invalid>
	rts


****************************************


store.component.pos
	lea	console4.entry.buffer(pc),a0
	bsr	get.component.pos
	bmi	component.pos.invalid
	move.w	d0,component.pos

	IFNE	DEBUG
	DEBUGW	<Component position : >,component.pos
	ENDC

	bra	set.console4.entry.parser


store.component.pos.insert.component
	lea	console4.entry.buffer(pc),a0
	bsr	get.component.pos
	bmi	component.pos.invalid
	move.w	d0,component.pos

	IFNE	DEBUG
	DEBUGW	<Component position : >,component.pos
	ENDC

	jsr	insert.component
	bsr	console3.refresh
	bsr	refresh.plan.views

	bra	set.console4.entry.parser


store.component.pos.modify.component.skip
	move.w	component.modify.pos(pc),d0
	jsr	get.component.type
	cmp.w	#POLYGON,d0
	bne.s	.normal.skip

	lea	console4.entry.buffer(pc),a0
	cmp.b	#'N',(a0)+		test for 'NCHK'
	bne.s	.normal.skip
	cmp.b	#'C',(a0)+
	bne.s	.normal.skip
	cmp.b	#'H',(a0)+
	bne.s	.normal.skip
	cmp.b	#'K',(a0)+
	bne.s	.normal.skip

.no.check
	move.w	#-1,component.pos
	bra.s	.modify

.normal.skip
	lea	console4.entry.buffer(pc),a0
	bsr	get.component.pos
	bmi.s	component.pos.invalid
	move.w	d0,component.pos

.modify
	IFNE	DEBUG
	DEBUGW	<Component position : >,component.pos
	ENDC

	jsr	modify.component.skip
	bsr	console3.refresh
	bsr	refresh.plan.views

	bra	set.console4.entry.parser


component.pos.invalid
	ERROR	<  Component position invalid>
	rts


****************************************


store.polygon.coords.insert.component
	lea	console4.entry.buffer(pc),a0
	bsr	get.coord.pos.or.NULL
	bmi	polygon.coord.pos.invalid
	beq	.NULL.entered
	move.w	num.polygon.coords(pc),d1
	lea	polygon.coords(pc),a2
	move.w	d1,d2
	add.w	d2,d2
	move.w	d0,(a2,d2.w)
	addq.w	#1,d1
	move.w	d1,num.polygon.coords

	IFNE	DEBUG
	move.w	d0,component.coord.pos
	DEBUGW	<Polygon co-ord pos : >,component.coord.pos
	ENDC

	cmp.w	#MAX_POLY_SIDES2,d1
	beq.s	.insert

	move.l	#console4.AP.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

.NULL.entered
	cmp.w	#MIN_POLY_SIDES,num.polygon.coords
	blt	polygon.coord.pos.invalid

* first negate co-ords that are used for polygon orientation check

.insert	lea	polygon.coords(pc),a2
	REPT	MIN_POLY_SIDES
	neg.w	(a2)+
	ENDR

	jsr	insert.component
	bsr	console3.refresh
	bsr	refresh.plan.views

	bra	set.console4.entry.parser


store.polygon.coords.modify.component
	lea	console4.entry.buffer(pc),a0
	bsr	get.coord.pos.or.NULL
	bmi	polygon.coord.pos.invalid
	beq	.NULL.entered
	move.w	num.polygon.coords(pc),d1
	lea	polygon.coords(pc),a2
	move.w	d1,d2
	add.w	d2,d2
	move.w	d0,(a2,d2.w)
	addq.w	#1,d1
	move.w	d1,num.polygon.coords

	IFNE	DEBUG
	move.w	d0,component.coord.pos
	DEBUGW	<Polygon co-ord pos : >,component.coord.pos
	ENDC

	cmp.w	#MAX_POLY_SIDES2,d1
	beq.s	.modify

	move.l	#console4.MP.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

.NULL.entered
	cmp.w	#MIN_POLY_SIDES,num.polygon.coords
	blt.s	polygon.coord.pos.invalid

* first negate co-ords that are used for polygon orientation check

.modify	lea	polygon.coords(pc),a2
	REPT	MIN_POLY_SIDES
	neg.w	(a2)+
	ENDR

	jsr	modify.component
	bsr	console3.refresh
	bsr	refresh.plan.views

	bra	set.console4.entry.parser


polygon.coord.pos.invalid
	ERROR	<  Co-ord position invalid>
	rts


store.polygon.orientation.modify.component
	lea	console4.entry.buffer(pc),a0
	bsr	get.coord.pos
	bmi.s	polygon.coord.pos.invalid

* check co-ord belongs to polygon, if it does then negate it

	move.w	num.polygon.coords(pc),d1
	subq.w	#1,d1
	lea	polygon.coords(pc),a1

.loop	cmp.w	(a1),d0
	beq.s	.found
	lea	2(a1),a1
	dbra	d1,.loop
	bra.s	polygon.coord.pos.invalid

.found	neg.w	(a1)
	addq.w	#1,num.orientation.coords

	IFNE	DEBUG
	move.w	d0,component.coord.pos
	DEBUGW	<Polygon co-ord pos : >,component.coord.pos
	ENDC

	cmp.w	#MIN_POLY_SIDES,num.orientation.coords
	beq.s	.modify

	move.l	#console4.MO.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser

.modify	jsr	modify.component
	bsr	console3.refresh
	bsr	refresh.plan.views

	bra	set.console4.entry.parser


****************************************


store.rotate.range.insert.component
	lea	console4.entry.buffer(pc),a0
	bsr	get.coord.pos
	bmi	rotate.range.invalid
	move.w	d0,d3

* find last rotated co-ord position before our new rotate position

	move.w	component.insert.pos(pc),d1
	subq.w	#1,d1			calculate components before position
	beq.s	.none.before

	move.l	component.memory(pc),a0
	move.w	d1,d0
	mulu	#COMPONENT_SIZE,d0
	add.l	d0,a0

	subq.w	#1,d1
.find.before
	lea	-COMPONENT_SIZE(a0),a0
	cmp.w	#ROTATE,TYPE(a0)
	dbeq	d1,.find.before

	bne.s	.none.before
	move.w	COORDS+2(a0),d4
	bra.s	.done.before

.none.before
	move.w	#0,d4

.done.before

* find first rotated co-ord position after our new rotate position

	move.w	component.insert.pos(pc),d0
	move.w	total.components(pc),d1
	sub.w	d0,d1
	bmi.s	.none.after
	addq.w	#1,d1			calculate components after position

	move.l	component.memory(pc),a0
	subq.w	#1,d0
	mulu	#COMPONENT_SIZE,d0
	add.l	d0,a0

	subq.w	#1,d1
	lea	-COMPONENT_SIZE(a0),a0
.find.after
	lea	COMPONENT_SIZE(a0),a0
	cmp.w	#ROTATE,TYPE(a0)
	dbeq	d1,.find.after

	bne.s	.none.after
	move.w	COORDS(a0),d5
	bra.s	.done.after

.none.after
	move.w	total.coords(pc),d5
	addq.w	#1,d5

.done.after

* now we have :-
*
* d3 = new number of co-ords to rotate
* d4 = last rotated co-ord position before us
* d5 = first rotated co-ord position after us

	sub.w	d4,d5
	subq.w	#1,d5
	ble	rotate.range.invalid	if no room for new rotate

	cmp.w	d3,d5
	blt	rotate.range.invalid	if not enough room for new rotate

	addq.w	#1,d4
	move.w	d4,rotate.coord.pos1
	add.w	d3,d4
	subq.w	#1,d4
	move.w	d4,rotate.coord.pos2

	IFNE	DEBUG
	DEBUGW	<Rotate co-ord pos1 : >,rotate.coord.pos1
	DEBUGW	<Rotate co-ord pos2 : >,rotate.coord.pos2
	ENDC

	jsr	insert.component
	bsr	console3.refresh
	bsr	refresh.plan.views

	bra	set.console4.entry.parser


store.rotate.range.modify.component
	lea	console4.entry.buffer(pc),a0
	bsr	get.coord.pos
	bmi	rotate.range.invalid
	move.w	d0,d3

* find last rotated co-ord position before our current rotate position

	move.w	component.modify.pos(pc),d1
	subq.w	#1,d1			calculate components before position
	beq.s	.none.before

	move.l	component.memory(pc),a0
	move.w	d1,d0
	mulu	#COMPONENT_SIZE,d0
	add.l	d0,a0

	subq.w	#1,d1
.find.before
	lea	-COMPONENT_SIZE(a0),a0
	cmp.w	#ROTATE,TYPE(a0)
	dbeq	d1,.find.before

	bne.s	.none.before
	move.w	COORDS+2(a0),d4
	bra.s	.done.before

.none.before
	move.w	#0,d4

.done.before

* find first rotated co-ord position after our current rotate position

	move.w	component.modify.pos(pc),d0
	move.w	total.components(pc),d1
	sub.w	d0,d1
	beq.s	.none.after		calculate components after position

	move.l	component.memory(pc),a0
	subq.w	#1,d0
	mulu	#COMPONENT_SIZE,d0
	add.l	d0,a0

	subq.w	#1,d1
.find.after
	lea	COMPONENT_SIZE(a0),a0
	cmp.w	#ROTATE,TYPE(a0)
	dbeq	d1,.find.after

	bne.s	.none.after
	move.w	COORDS(a0),d5
	bra.s	.done.after

.none.after
	move.w	total.coords(pc),d5
	addq.w	#1,d5

.done.after

* now we have :-
*
* d3 = new number of co-ords to rotate
* d4 = last rotated co-ord position before us
* d5 = first rotated co-ord position after us

	sub.w	d4,d5
	subq.w	#1,d5
	ble	rotate.range.invalid	if no room for new rotate

	cmp.w	d3,d5
	blt	rotate.range.invalid	if not enough room for new rotate

	addq.w	#1,d4
	move.w	d4,rotate.coord.pos1
	add.w	d3,d4
	subq.w	#1,d4
	move.w	d4,rotate.coord.pos2

	IFNE	DEBUG
	DEBUGW	<Rotate co-ord pos1 : >,rotate.coord.pos1
	DEBUGW	<Rotate co-ord pos2 : >,rotate.coord.pos2
	ENDC

	jsr	modify.component
	bsr	console3.refresh
	bsr	refresh.plan.views

	bra.s	set.console4.entry.parser


rotate.range.invalid
	ERROR	<  Rotate range invalid>
	rts


****************************************


set.console4.entry.parser
	move.l	console4.entry.parsers.ptr(pc),a5

	move.l	(a5)+,a0
	bsr	console4.output.string

	move.w	(a5)+,console4.entry.columns
	move.w	#0,console4.entry.len
	move.w	#0,console4.entry.pos

	moveq	#0,d3
	moveq	#CONSOLE4_COLUMNS-1,d4
	lea	console4.entry.buffer(pc),a4
.clear	move.b	d3,(a4)+		clear previous input from buffer
	dbra	d4,.clear

	move.l	(a5)+,console4.entry.parser

	move.l	a5,console4.entry.parsers.ptr
	rts


****************************************


console4.IC.parse.list
	dc.l	prompt.insert.pos.text
	dc.w	CONSOLE4_COLUMNS-10
	dc.l	store.component.insert.pos

console4.AC.parse.list
	dc.l	prompt.coord.text
	dc.w	CONSOLE4_COLUMNS-8
	dc.l	store.component.coord.pos

	dc.l	prompt.radius.text
	dc.w	CONSOLE4_COLUMNS-8
	dc.l	store.radius.insert.component

console4.command.parse.list
	dc.l	prompt.command.text
	dc.w	CONSOLE4_COLUMNS-9
	dc.l	console4.command.parser


console4.IE.parse.list
	dc.l	prompt.insert.pos.text
	dc.w	CONSOLE4_COLUMNS-10
	dc.l	store.component.insert.pos.insert.component

	dc.l	prompt.command.text
	dc.w	CONSOLE4_COLUMNS-9
	dc.l	console4.command.parser


console4.IG.parse.list
	dc.l	prompt.insert.pos.text
	dc.w	CONSOLE4_COLUMNS-10
	dc.l	store.component.insert.pos

console4.AG.parse.list
	dc.l	prompt.goto.pos.text
	dc.w	CONSOLE4_COLUMNS-15
	dc.l	store.component.pos.insert.component

	dc.l	prompt.command.text
	dc.w	CONSOLE4_COLUMNS-9
	dc.l	console4.command.parser


console4.IS.parse.list
	dc.l	prompt.insert.pos.text
	dc.w	CONSOLE4_COLUMNS-10
	dc.l	store.component.insert.pos

console4.AS.parse.list
	dc.l	prompt.gosub.pos.text
	dc.w	CONSOLE4_COLUMNS-16
	dc.l	store.component.pos.insert.component

	dc.l	prompt.command.text
	dc.w	CONSOLE4_COLUMNS-9
	dc.l	console4.command.parser


console4.IP.parse.list
	dc.l	prompt.insert.pos.text
	dc.w	CONSOLE4_COLUMNS-10
	dc.l	store.component.insert.pos

console4.AP.parse.list
	dc.l	prompt.coord.text
	dc.w	CONSOLE4_COLUMNS-8
	dc.l	store.polygon.coords.insert.component

	dc.l	prompt.command.text
	dc.w	CONSOLE4_COLUMNS-9
	dc.l	console4.command.parser


console4.IR.parse.list
	dc.l	prompt.insert.pos.text
	dc.w	CONSOLE4_COLUMNS-10
	dc.l	store.component.insert.pos

console4.AR.parse.list
	dc.l	prompt.num.coords.text
	dc.w	CONSOLE4_COLUMNS-19
	dc.l	store.rotate.range.insert.component

	dc.l	prompt.command.text
	dc.w	CONSOLE4_COLUMNS-9
	dc.l	console4.command.parser


console4.IV.parse.list
	dc.l	prompt.insert.pos.text
	dc.w	CONSOLE4_COLUMNS-10
	dc.l	store.component.insert.pos

console4.AV.parse.list
	dc.l	prompt.coord1.text
	dc.w	CONSOLE4_COLUMNS-10
	dc.l	store.component.coord.pos1

	dc.l	prompt.coord2.text
	dc.w	CONSOLE4_COLUMNS-10
	dc.l	store.component.coord.pos2.insert.component

	dc.l	prompt.command.text
	dc.w	CONSOLE4_COLUMNS-9
	dc.l	console4.command.parser


console4.IZ.parse.list
	dc.l	prompt.insert.pos.text
	dc.w	CONSOLE4_COLUMNS-10
	dc.l	store.component.insert.pos

console4.AZ.parse.list
	dc.l	prompt.goto.pos.text
	dc.w	CONSOLE4_COLUMNS-15
	dc.l	store.component.pos

	dc.l	prompt.coord1.text
	dc.w	CONSOLE4_COLUMNS-10
	dc.l	store.component.coord.pos1

	dc.l	prompt.coord2.text
	dc.w	CONSOLE4_COLUMNS-10
	dc.l	store.component.coord.pos2.insert.component

	dc.l	prompt.command.text
	dc.w	CONSOLE4_COLUMNS-9
	dc.l	console4.command.parser


console4.MC.parse.list
	dc.l	prompt.coord.text
	dc.w	CONSOLE4_COLUMNS-8
	dc.l	store.component.coord.pos

	dc.l	prompt.radius.text
	dc.w	CONSOLE4_COLUMNS-8
	dc.l	store.radius.modify.component

	dc.l	prompt.command.text
	dc.w	CONSOLE4_COLUMNS-9
	dc.l	console4.command.parser


console4.MO.parse.list
	dc.l	prompt.coord.text
	dc.w	CONSOLE4_COLUMNS-8
	dc.l	store.polygon.orientation.modify.component

	dc.l	prompt.command.text
	dc.w	CONSOLE4_COLUMNS-9
	dc.l	console4.command.parser


console4.MP.parse.list
	dc.l	prompt.coord.text
	dc.w	CONSOLE4_COLUMNS-8
	dc.l	store.polygon.coords.modify.component

	dc.l	prompt.command.text
	dc.w	CONSOLE4_COLUMNS-9
	dc.l	console4.command.parser


console4.MR.parse.list
	dc.l	prompt.num.coords.text
	dc.w	CONSOLE4_COLUMNS-19
	dc.l	store.rotate.range.modify.component

	dc.l	prompt.command.text
	dc.w	CONSOLE4_COLUMNS-9
	dc.l	console4.command.parser


console4.MV.parse.list
	dc.l	prompt.coord1.text
	dc.w	CONSOLE4_COLUMNS-10
	dc.l	store.component.coord.pos1

	dc.l	prompt.coord2.text
	dc.w	CONSOLE4_COLUMNS-10
	dc.l	store.component.coord.pos2.modify.component

	dc.l	prompt.command.text
	dc.w	CONSOLE4_COLUMNS-9
	dc.l	console4.command.parser


console4.MZ.parse.list
	dc.l	prompt.coord1.text
	dc.w	CONSOLE4_COLUMNS-10
	dc.l	store.component.coord.pos1

	dc.l	prompt.coord2.text
	dc.w	CONSOLE4_COLUMNS-10
	dc.l	store.component.coord.pos2.modify.component

	dc.l	prompt.command.text
	dc.w	CONSOLE4_COLUMNS-9
	dc.l	console4.command.parser


console4.MS.parse.list
	dc.l	prompt.skip.pos.text
	dc.w	CONSOLE4_COLUMNS-15
	dc.l	store.component.pos.modify.component.skip

	dc.l	prompt.command.text
	dc.w	CONSOLE4_COLUMNS-9
	dc.l	console4.command.parser


****************************************


refresh.consoles
	move.w	#1,console1.cursor.coord
	move.w	#1,console1.cursor.line
	bsr	console1.refresh

	move.l	#console2.command.parse.list,console2.entry.parsers.ptr
	bsr	set.console2.entry.parser

	move.w	#1,console3.cursor.component
	move.w	#1,console3.cursor.line
	bsr	console3.refresh

	move.l	#console4.command.parse.list,console4.entry.parsers.ptr
	bra	set.console4.entry.parser


****************************************


console1.output.buffer
	lea	console1.write.buffer(pc),a0

console1.output.string

* a0 = address of string

	lea	console1.write.IO.request(pc),a1
	move.l	#write.reply.port1,MN_REPLYPORT(a1)
	move.w	#CMD_WRITE,IO_COMMAND(a1)
	move.l	a0,IO_DATA(a1)
	move.l	#-1,IO_LENGTH(a1)
	CALLEXEC DoIO
	rts


****************************************


console2.output.char
	lea	console2.write.IO.request(pc),a1
	move.l	#write.reply.port2,MN_REPLYPORT(a1)
	move.w	#CMD_WRITE,IO_COMMAND(a1)
	move.l	#console2.write.buffer,IO_DATA(a1)
	move.l	#1,IO_LENGTH(a1)
	CALLEXEC DoIO
	rts


****************************************


console2.output.buffer
	lea	console2.write.buffer(pc),a0

console2.output.string

* a0 = address of string

	lea	console2.write.IO.request(pc),a1
	move.l	#write.reply.port2,MN_REPLYPORT(a1)
	move.w	#CMD_WRITE,IO_COMMAND(a1)
	move.l	a0,IO_DATA(a1)
	move.l	#-1,IO_LENGTH(a1)
	CALLEXEC DoIO
	rts


****************************************


console1.delete
	move.w	#1,console1.cursor.coord
	move.w	#1,console1.cursor.line

console1.refresh
	moveq	#CONSOLE1_ROWS-1,d7
	lea	console1.refresh.text(pc),a0

	move.b	#CSI,(a0)+
	move.b	#'H',(a0)+		home

	move.w	console1.cursor.coord(pc),d6
	sub.w	console1.cursor.line(pc),d6
	addq.w	#1,d6			calculate top line co-ord

	move.w	total.coords(pc),d5
	sub.w	d6,d5
	bmi.s	.coords.done

	cmp.w	d7,d5			calculate co-ords to output
	ble.s	.output.coords
	move.w	d7,d5

.output.coords
	move.l	coord.memory(pc),a1
	move.w	d6,d1
	subq.w	#1,d1
	mulu	#COORD_SIZE,d1
	add.l	d1,a1

.loop	CHECK	1,console1.create.row,d5-d7/a1

	addq.w	#1,d6			next co-ord position
	lea	COORD_SIZE(a1),a1

	subq.w	#1,d7			decrement row count
	dbra	d5,.loop

	tst.w	d7
	bmi.s	.done			if all required rows done

.coords.done
	moveq	#' ',d1			else output required blank lines

.blank
	REPT	CONSOLE1_COLUMNS-1
	move.b	d1,(a0)+
	ENDR

	tst.w	d7
	beq.s	.skip.space		if last row in window
	move.b	d1,(a0)+

.skip.space
	dbra	d7,.blank

.done	move.b	#CSI,(a0)+
	move.w	#CONSOLE1_ROWS,d0
	bsr	word.to.ASCII
	move.b	#';',(a0)+
	move.w	#5,d0
	bsr	word.to.ASCII
	move.b	#'H',(a0)+		move cursor to last line, column 5

	move.b	#CSI,(a0)+
	move.b	#'@',(a0)+		insert a space

	move.b	#CSI,(a0)+
	move.w	console1.cursor.line(pc),d0
	bsr	word.to.ASCII
	move.b	#'H',(a0)+		move cursor to correct position
	clr.b	(a0)

	lea	console1.refresh.text(pc),a0
	bra	console1.output.string


****************************************


console1.update

* d0 = new cursor co-ord
* d1 = new cursor line

	move.w	console1.cursor.coord(pc),d2
	move.w	console1.cursor.line(pc),d3

	move.w	d0,console1.cursor.coord
	move.w	d1,console1.cursor.line

	cmp.w	d0,d2
	beq.s	.done			if cursor co-ord not changed

	cmp.w	d1,d3
	beq.s	.line.not.changed

.line.changed
	lea	console1.write.buffer(pc),a0
	move.b	#CSI,(a0)+
	move.w	d1,d0
	bsr	word.to.ASCII
	move.b	#'H',(a0)+		move cursor to new position
	clr.b	(a0)
	bra	console1.output.buffer

.line.not.changed
	sub.w	d2,d0
	bra.s	console1.window.scroll

.done	rts


****************************************


console1.window.scroll

* d0 = number of lines to scroll

	tst.w	d0
	bmi.s	.down

.up	cmp.w	#1,d0
	bgt	console1.refresh	if more than one line to scroll

	lea	console1.write.buffer(pc),a0
	move.b	#CSI,(a0)+
	move.b	#'S',(a0)+		scroll contents up one line

	move.w	console1.cursor.coord(pc),d6
	sub.w	console1.cursor.line(pc),d6
	add.w	#CONSOLE1_ROWS,d6	calculate bottom line co-ord

	move.l	coord.memory(pc),a1
	move.w	d6,d1
	subq.w	#1,d1
	mulu	#COORD_SIZE,d1
	add.l	d1,a1

	moveq	#0,d7
	bsr.s	console1.create.row

	move.b	#CSI,(a0)+
	move.w	#CONSOLE1_ROWS,d0
	bsr	word.to.ASCII
	move.b	#';',(a0)+
	move.w	#5,d0
	bsr	word.to.ASCII
	move.b	#'H',(a0)+		move cursor to last line, column 5

	move.b	#CSI,(a0)+
	move.b	#'@',(a0)+		insert a space

	move.b	#CR,(a0)+		move cursor to start of line
	clr.b	(a0)
	bra	console1.output.buffer

.down	neg.w	d0
	cmp.w	#1,d0
	bgt	console1.refresh	if more than one line to scroll

	lea	console1.write.buffer(pc),a0
	move.b	#CSI,(a0)+
	move.b	#'T',(a0)+		scroll contents down one line

	move.w	console1.cursor.coord(pc),d6
	sub.w	console1.cursor.line(pc),d6
	addq.w	#1,d6			calculate top line co-ord

	move.l	coord.memory(pc),a1
	move.w	d6,d1
	subq.w	#1,d1
	mulu	#COORD_SIZE,d1
	add.l	d1,a1

	moveq	#1,d7
	bsr.s	console1.create.row

	move.b	#CSI,(a0)+
	move.b	#'A',(a0)+		move cursor up one line
	clr.b	(a0)
	bra	console1.output.buffer


****************************************


console1.create.row
	move.w	d6,d0			output co-ord position
	bsr	pos.to.ASCII

	tst.w	d7
	beq.s	.skip.space		if last row in window
	move.b	#' ',(a0)+

.skip.space
	move.w	X_VALUE(a1),d0		output x value
	bsr	coord.value.to.ASCII
	move.b	#' ',(a0)+

	move.w	Y_VALUE(a1),d0		output y value
	bsr	coord.value.to.ASCII
	move.b	#' ',(a0)+

	move.w	Z_VALUE(a1),d0		output z value
	bra	coord.value.to.ASCII


****************************************


console3.output.buffer
	lea	console3.write.buffer(pc),a0

console3.output.string

* a0 = address of string

	lea	console3.write.IO.request(pc),a1
	move.l	#write.reply.port3,MN_REPLYPORT(a1)
	move.w	#CMD_WRITE,IO_COMMAND(a1)
	move.l	a0,IO_DATA(a1)
	move.l	#-1,IO_LENGTH(a1)
	CALLEXEC DoIO
	rts


****************************************


console4.output.char
	lea	console4.write.IO.request(pc),a1
	move.l	#write.reply.port4,MN_REPLYPORT(a1)
	move.w	#CMD_WRITE,IO_COMMAND(a1)
	move.l	#console4.write.buffer,IO_DATA(a1)
	move.l	#1,IO_LENGTH(a1)
	CALLEXEC DoIO
	rts


****************************************


console4.output.buffer
	lea	console4.write.buffer(pc),a0

console4.output.string

* a0 = address of string

	lea	console4.write.IO.request(pc),a1
	move.l	#write.reply.port4,MN_REPLYPORT(a1)
	move.w	#CMD_WRITE,IO_COMMAND(a1)
	move.l	a0,IO_DATA(a1)
	move.l	#-1,IO_LENGTH(a1)
	CALLEXEC DoIO
	rts


****************************************


console3.delete
	move.w	#1,console3.cursor.component
	move.w	#1,console3.cursor.line

console3.refresh
	moveq	#CONSOLE3_ROWS-1,d7
	lea	console3.refresh.text(pc),a0

	move.b	#CSI,(a0)+
	move.b	#'H',(a0)+		home

	move.w	console3.cursor.component(pc),d6
	sub.w	console3.cursor.line(pc),d6
	addq.w	#1,d6			calculate top line component

	move.w	total.components(pc),d5
	sub.w	d6,d5
	bmi.s	.components.done

	cmp.w	d7,d5			calculate components to output
	ble.s	.output.components
	move.w	d7,d5

.output.components
	move.l	component.memory(pc),a1
	move.w	d6,d1
	subq.w	#1,d1
	mulu	#COMPONENT_SIZE,d1
	add.l	d1,a1

.loop	CHECK	2,console3.create.row,d5-d7/a1

	addq.w	#1,d6			next component position
	lea	COMPONENT_SIZE(a1),a1

	subq.w	#1,d7			decrement row count
	dbra	d5,.loop

	tst.w	d7
	bmi.s	.done			if all required rows done

.components.done
	moveq	#' ',d1			else output required blank lines

.blank
	REPT	CONSOLE3_COLUMNS-1
	move.b	d1,(a0)+
	ENDR
	move.b	#LF,(a0)+
	dbra	d7,.blank

.done	lea	-1(a0),a0		don't do last line feed

	move.b	#CSI,(a0)+
	move.w	console3.cursor.line(pc),d0
	bsr	word.to.ASCII
	move.b	#'H',(a0)+		move cursor to correct position
	clr.b	(a0)

	lea	console3.refresh.text(pc),a0
	bra	console3.output.string


****************************************


console3.update

* d0 = new cursor co-ord
* d1 = new cursor line

	move.w	console3.cursor.component(pc),d2
	move.w	console3.cursor.line(pc),d3

	move.w	d0,console3.cursor.component
	move.w	d1,console3.cursor.line

	cmp.w	d0,d2
	beq.s	.done			if cursor co-ord not changed

	cmp.w	d1,d3
	beq.s	.line.not.changed

.line.changed
	lea	console3.write.buffer(pc),a0
	move.b	#CSI,(a0)+
	move.w	d1,d0
	bsr	word.to.ASCII
	move.b	#'H',(a0)+		move cursor to new position
	clr.b	(a0)
	bra	console3.output.buffer

.line.not.changed
	sub.w	d2,d0
	bra.s	console3.window.scroll

.done	rts


****************************************


console3.window.scroll

* d0 = number of lines to scroll

	tst.w	d0
	bmi.s	.down

.up	cmp.w	#1,d0
	bgt	console3.refresh	if more than one line to scroll

	lea	console3.write.buffer(pc),a0
	move.b	#CSI,(a0)+
	move.b	#'S',(a0)+		scroll contents up one line

	move.w	console3.cursor.component(pc),d6
	sub.w	console3.cursor.line(pc),d6
	add.w	#CONSOLE3_ROWS,d6	calculate bottom line component

	move.l	component.memory(pc),a1
	move.w	d6,d1
	subq.w	#1,d1
	mulu	#COMPONENT_SIZE,d1
	add.l	d1,a1

	bsr.s	console3.create.row
	lea	-1(a0),a0		don't do last line feed

	move.b	#CR,(a0)+		move cursor to start of line
	clr.b	(a0)
	bra	console3.output.buffer

.down	neg.w	d0
	cmp.w	#1,d0
	bgt	console3.refresh	if more than one line to scroll

	lea	console3.write.buffer(pc),a0
	move.b	#CSI,(a0)+
	move.b	#'T',(a0)+		scroll contents down one line

	move.w	console3.cursor.component(pc),d6
	sub.w	console3.cursor.line(pc),d6
	addq.w	#1,d6			calculate top line component

	move.l	component.memory(pc),a1
	move.w	d6,d1
	subq.w	#1,d1
	mulu	#COMPONENT_SIZE,d1
	add.l	d1,a1

	bsr.s	console3.create.row
	lea	-1(a0),a0		don't do last line feed

	move.b	#CR,(a0)+		move cursor to start of line
	clr.b	(a0)
	bra	console3.output.buffer


****************************************


console3.create.row
	move.l	a0,a5
	lea	CONSOLE3_COLUMNS-1(a5),a5

	move.b	console3.coords.only(pc),d1
	bne.s	.coords

	move.w	d6,d0			output component position
	bsr	pos.to.ASCII
	move.b	#' ',(a0)+

	bsr.s	skip.to.ASCII		output skip position
	move.b	#' ',(a0)+

	bsr.s	clr.to.ASCII		output colour value
	move.b	#' ',(a0)+

	bsr	type.to.ASCII		output component type
	move.b	#' ',(a0)+

.coords	bsr	coords.used.to.ASCII	output co-ords used

	move.l	a5,d1
	sub.l	a0,d1
	subq.w	#1,d1
	bmi.s	.done

	moveq	#' ',d2

.blank	move.b	d2,(a0)+		blank remaining section of line
	dbra	d1,.blank

.done	move.b	#LF,(a0)+
	rts


****************************************


skip.to.ASCII
	move.w	SKIP(a1),d0
	bmi.s	.no.skip
	bsr	pos.to.ASCII
	bra.s	.skip.done

.no.skip
	cmp.w	#POLYGON,TYPE(a1)
	beq.s	.no.check

	REPT	4
	move.b	#'-',(a0)+
	ENDR
	bra.s	.skip.done

.no.check
	move.b	#'N',(a0)+
	move.b	#'C',(a0)+
	move.b	#'H',(a0)+
	move.b	#'K',(a0)+

.skip.done
	rts


****************************************


clr.to.ASCII
	move.w	CLR(a1),d0
	cmp.w	#NOCLR,d0
	beq.s	.no.clr

	cmp.w	#UNKNCLR,d0
	beq.s	.unkn.clr

	bsr	colour.value.to.ASCII
	bra.s	.clr.done

.no.clr
	REPT	3
	move.b	#'-',(a0)+
	ENDR
	bra.s	.clr.done

.unkn.clr
	REPT	3
	move.b	#'?',(a0)+
	ENDR

.clr.done
	rts


****************************************


type.to.ASCII
	move.w	TYPE(a1),d0
	bmi.s	.bad			make sure we get a valid text ptr
	cmp.w	#MAX_COMPONENT_TYPES,d0
	ble.s	.ok

.bad	moveq	#0,d0			use error text otherwise

.ok	add.w	d0,d0
	add.w	d0,d0
	lea	component.types(pc),a2
	move.l	(a2,d0.w),a2

.copy	move.b	(a2)+,(a0)+
	bne.s	.copy

	lea	-1(a0),a0
	rts


component.types
	dc.l	error.text
	dc.l	circle.text
	dc.l	end.text
	dc.l	gosub.text
	dc.l	goto.text
	dc.l	polygon.text
	dc.l	rotate.text
	dc.l	vector.text
	dc.l	zpri.text


****************************************


coords.used.to.ASCII
	move.w	NUM_COORDS(a1),d0
	bmi.s	.done

	move.w	TYPE(a1),d1
	ble.s	.done			make sure we get a valid type
	cmp.w	#MAX_COMPONENT_TYPES,d1
	bgt.s	.done

.type.circle
	cmp.w	#CIRCLE,d1
	bne.s	.type.rotate

	move.w	COORDS(a1),d0
	bsr	pos.to.ASCII		output centre co-ord
	move.l	COORDS+2(a1),d0
	bra	radius.to.ASCII		output circle radius

.type.rotate
	cmp.w	#ROTATE,d1
	bne.s	.type.standard

	move.w	COORDS(a1),d0
	bsr	pos.to.ASCII		output start co-ord
	move.b	#'-',(a0)+
	move.w	COORDS+2(a1),d0
	bra	pos.to.ASCII		output end co-ord

.type.standard
	move.w	#MAX_POLY_SIDES1,d2	calculate max. allowable co-ords
	move.b	console3.coords.only(pc),d1
	beq.s	.got.max
	move.w	#MAX_POLY_SIDES2,d2

.got.max
	cmp.w	d2,d0
	ble.s	.good.amount
	move.w	d2,d0			calculate co-ords to output

.good.amount
	subq.w	#1,d0
	bmi.s	.error
	lea	COORDS(a1),a2

	tst.w	SKIP(a1)
	bmi.s	.first.normal
	bra.s	.first.highlight

.loopn	move.b	#',',(a0)+

.first.normal
	move.w	d0,-(sp)
	move.w	(a2)+,d0
	bpl.s	.plus
	neg.w	d0		if this co-ord is used for orientation check

.plus	bsr	pos.to.ASCII		output next co-ord
	move.w	(sp)+,d0
	dbra	d0,.loopn
.done	rts

.error	ERROR	<  dbra error 1>
	rts


* highlight co-ords that are used for polygon orientation check

.looph	move.b	#',',(a0)+

.first.highlight
	move.w	d0,-(sp)
	move.w	(a2)+,d0
	bmi.s	.highlight

	bsr	pos.to.ASCII		output next co-ord
	move.w	(sp)+,d0
	dbra	d0,.looph
	rts

.highlight
	neg.w	d0
	bsr	highlight.pos.to.ASCII	output next co-ord
	lea	6(a5),a5		allow for the six control chars.

	move.w	(sp)+,d0
	dbra	d0,.looph
	rts


****************************************


radius.to.ASCII
	lea	radius.text(pc),a2

.copy	move.b	(a2)+,(a0)+
	bne.s	.copy

	lea	-1(a0),a0
	bra	longword.to.ASCII


****************************************


get.coord.range

* a0 = NULL terminated ASCII input string
*
* returns 1 if range valid, with coord.pos1 and coord.pos2 containing limits
* returns -1 if invalid range or no range found
*
* uses d0-d3, a0

	bsr	get.coord.pos
	bmi.s	.bad.range
	move.w	d0,coord.pos1

	lea	-1(a0),a0		to terminating char. position

.skip	move.b	(a0)+,d0
	beq.s	.single.pos

	cmp.b	#'-',d0
	bne.s	.skip			search for '-'

	bsr	get.coord.pos
	bmi.s	.bad.range
	move.w	d0,coord.pos2

* now ensure limits are in ascending order

	cmp.w	coord.pos1(pc),d0
	bge.s	.good.range

	move.w	coord.pos1(pc),coord.pos2
	move.w	d0,coord.pos1

.good.range
	moveq	#1,d1
	rts

.single.pos
	move.w	coord.pos1(pc),coord.pos2
	bra.s	.good.range

.bad.range
	moveq	#-1,d1
	rts


****************************************


get.component.range

* a0 = NULL terminated ASCII input string
*
* returns 1 if range valid, with component.pos1 and component.pos2
* containing limits
* returns -1 if invalid range or no range found
*
* uses d0-d3, a0

	bsr	get.component.pos
	bmi.s	.bad.range
	move.w	d0,component.pos1

	lea	-1(a0),a0		to terminating char. position

.skip	move.b	(a0)+,d0
	beq.s	.single.pos

	cmp.b	#'-',d0
	bne.s	.skip			search for '-'

	bsr	get.component.pos
	bmi.s	.bad.range
	move.w	d0,component.pos2

* now ensure limits are in ascending order

	cmp.w	component.pos1(pc),d0
	bge.s	.good.range

	move.w	component.pos1(pc),component.pos2
	move.w	d0,component.pos1

.good.range
	moveq	#1,d1
	rts

.single.pos
	move.w	component.pos1(pc),component.pos2
	bra.s	.good.range

.bad.range
	moveq	#-1,d1
	rts


****************************************


get.number.of.extra.coords

* a0 = NULL terminated ASCII input string
*
* returns 1 if number valid, with d0.w = number
* returns 1 if no number found, with d0.w = default number
* returns -1 if invalid number or not enough space for co-ords
*
* uses d0-d3, a0

	bsr	ASCII.to.longword
	bmi.s	.bad.number
	bne.s	.check.number

.default.number
	moveq	#1,d0			set default number of co-ords
	bra.s	.check.space

.check.number
	tst.w	d0
	bmi.s	.bad.number
	beq.s	.default.number

.check.space
	move.w	#MAX_COORDS,d2
	sub.w	total.coords(pc),d2
	cmp.w	d2,d0
	bgt.s	.bad.number

.good.number
	moveq	#1,d1
	rts

.bad.number
	moveq	#-1,d1
	rts


****************************************


check.space.for.extra.component

* returns 1 if there is enough space for one extra component
* returns -1 otherwise
*
* uses d0

	move.w	#MAX_COMPONENTS,d0
	sub.w	total.components(pc),d0
	cmp.w	#1,d0
	blt.s	.no.space

.space	moveq	#1,d0
	rts

.no.space
	moveq	#-1,d0
	rts


****************************************


get.coord.insert.pos

* a0 = NULL terminated ASCII input string
* position at end of co-ords also valid i.e. same as the add (AC) function
*
* returns 1 if position valid, with d0.w = position
* returns -1 if invalid position or no position found
*
* uses d0-d3, a0

	bsr	ASCII.to.longword
	bmi.s	.bad.number
	bne.s	.check.number

.bad.number
	moveq	#-1,d1
	rts

.check.number
	tst.w	d0
	bmi.s	.bad.number
	beq.s	.bad.number

	move.w	total.coords(pc),d2
	addq.w	#1,d2
	cmp.w	d2,d0
	bgt.s	.bad.number

.good.number
	moveq	#1,d1
	rts


****************************************


get.coord.pos

* a0 = NULL terminated ASCII input string
*
* returns 1 if position valid, with d0.w = position
* returns -1 if invalid position or no position found
*
* uses d0-d3, a0

	bsr	ASCII.to.longword
	bmi.s	.bad.number
	bne.s	.check.number

.bad.number
	moveq	#-1,d1
	rts

.check.number
	tst.w	d0
	bmi.s	.bad.number
	beq.s	.bad.number

	move.w	total.coords(pc),d2
	cmp.w	d2,d0
	bgt.s	.bad.number

.good.number
	moveq	#1,d1
	rts


****************************************


get.coord.pos.or.NULL

* a0 = NULL terminated ASCII input string
*
* returns 1 if position valid, with d0.w = position
* returns 0 if no position found (NULL entry)
* returns -1 if invalid position
*
* uses d0-d3, a0

	bsr	ASCII.to.longword
	bmi.s	.bad.number
	bne.s	.check.number

.no.number
	moveq	#0,d1
	rts

.bad.number
	moveq	#-1,d1
	rts

.check.number
	tst.w	d0
	bmi.s	.bad.number
	beq.s	.bad.number

	move.w	total.coords(pc),d2
	cmp.w	d2,d0
	bgt.s	.bad.number

.good.number
	moveq	#1,d1
	rts


****************************************


get.coord.value

* a0 = NULL terminated ASCII input string
*
* returns 1 if number valid, with d0.w = number
* returns -1 if invalid number or no number found
*
* uses d0-d3, a0

	bsr	ASCII.to.longword
	bmi.s	.bad.number
	bne.s	.check.number

.bad.number
	moveq	#-1,d1
	rts

.check.number
	cmp.l	#-32768,d0
	blt.s	.bad.number

	cmp.l	#32767,d0
	bgt.s	.bad.number

.good.number
	moveq	#1,d1
	rts


****************************************


get.radius.value

* a0 = NULL terminated ASCII input string
*
* returns 1 if number valid, with d0.l = number
* returns -1 if invalid number or no number found
*
* uses d0-d3, a0

	bsr	ASCII.to.longword
	bmi.s	.bad.number
	bne.s	.check.number

.bad.number
	moveq	#-1,d1
	rts

.check.number
	tst.l	d0
	bmi.s	.bad.number

.good.number
	moveq	#1,d1
	rts


****************************************


get.component.insert.pos

* a0 = NULL terminated ASCII input string
* position at end of components also valid i.e. same as the add functions
*
* returns 1 if position valid, with d0.w = position
* returns -1 if invalid position or no position found
*
* uses d0-d3, a0

	bsr	ASCII.to.longword
	bmi.s	.bad.number
	bne.s	.check.number

.bad.number
	moveq	#-1,d1
	rts

.check.number
	tst.w	d0
	bmi.s	.bad.number
	beq.s	.bad.number

	move.w	total.components(pc),d2
	addq.w	#1,d2
	cmp.w	d2,d0
	bgt.s	.bad.number

.good.number
	moveq	#1,d1
	rts


****************************************


get.component.pos

* a0 = NULL terminated ASCII input string
*
* returns 1 if position valid, with d0.w = position
* returns -1 if invalid position or no position found
*
* uses d0-d3, a0

	bsr	ASCII.to.longword
	bmi.s	.bad.number
	bne.s	.check.number

.bad.number
	moveq	#-1,d1
	rts

.check.number
	tst.w	d0
	bmi.s	.bad.number
	beq.s	.bad.number

	move.w	total.components(pc),d2
	cmp.w	d2,d0
	bgt.s	.bad.number

.good.number
	moveq	#1,d1
	rts


****************************************


window1.active
	move.w	#1,current.window

	IFNE	DEBUG
	DEBUGM	<Window1 Active>
	ENDC

	move.l	window1(pc),a0
	lea	window1.active.title(pc),a1
	move.w	#-1,a2
	CALLINT	SetWindowTitles

	lea	cursor.visible.text(pc),a0
	bra	console1.output.string


window1.inactive
	IFNE	DEBUG
	DEBUGM	<Window1 Inactive>
	ENDC

	move.l	window1(pc),a0
	lea	window1.title(pc),a1
	move.w	#-1,a2
	CALLINT	SetWindowTitles

	lea	cursor.invisible.text(pc),a0
	bra	console1.output.string


****************************************


window2.active
	move.w	#2,current.window

	IFNE	DEBUG
	DEBUGM	<Window2 Active>
	ENDC

	lea	cursor.visible.text(pc),a0
	bra	console2.output.string


window2.inactive
	IFNE	DEBUG
	DEBUGM	<Window2 Inactive>
	ENDC

	lea	cursor.invisible.text(pc),a0
	bra	console2.output.string


****************************************


window3.active
	move.w	#3,current.window

	IFNE	DEBUG
	DEBUGM	<Window3 Active>
	ENDC

	move.l	window3(pc),a0
	move.l	window3.current.active.title(pc),a1
	move.w	#-1,a2
	CALLINT	SetWindowTitles

	lea	cursor.visible.text(pc),a0
	bra	console3.output.string


window3.inactive
	IFNE	DEBUG
	DEBUGM	<Window3 Inactive>
	ENDC

	move.l	window3(pc),a0
	lea	window3.title(pc),a1
	move.w	#-1,a2
	CALLINT	SetWindowTitles

	lea	cursor.invisible.text(pc),a0
	bra	console3.output.string


****************************************


window4.active
	move.w	#4,current.window

	IFNE	DEBUG
	DEBUGM	<Window4 Active>
	ENDC

	lea	cursor.visible.text(pc),a0
	bra	console4.output.string


window4.inactive
	IFNE	DEBUG
	DEBUGM	<Window4 Inactive>
	ENDC

	lea	cursor.invisible.text(pc),a0
	bra	console4.output.string


****************************************


window5.active
	move.w	#5,current.window

	IFNE	DEBUG
	DEBUGM	<Window5 Active>
	ENDC

	rts


window5.inactive
	IFNE	DEBUG
	DEBUGM	<Window5 Inactive>
	ENDC

	rts


****************************************


window6.active
	move.w	#6,current.window

	IFNE	DEBUG
	DEBUGM	<Window6 Active>
	ENDC

	rts


window6.inactive
	IFNE	DEBUG
	DEBUGM	<Window6 Inactive>
	ENDC

	rts


****************************************


serve.windows
	move.b	SOD.quit.request(pc),d1
	bne.s	.quit

	clr.w	current.window
	move.l	#WINDOWACTIVE,d1

	move.l	window1(pc),a2
	move.l	wd_Flags(a2),d2
	and.l	d1,d2
	bne	window1.main

	move.l	window2(pc),a2
	move.l	wd_Flags(a2),d2
	and.l	d1,d2
	bne	window2.main

	move.l	window3(pc),a2
	move.l	wd_Flags(a2),d2
	and.l	d1,d2
	bne	window3.main

	move.l	window4(pc),a2
	move.l	wd_Flags(a2),d2
	and.l	d1,d2
	bne	window4.main

	move.l	window5(pc),a2
	move.l	wd_Flags(a2),d2
	and.l	d1,d2
	bne	window5.main

	move.l	window6(pc),a2
	move.l	wd_Flags(a2),d2
	and.l	d1,d2
	bne	window6.main

	moveq	#5,d1
	CALLDOS	Delay
	bra.s	serve.windows

.quit	rts


SOD.quit.request	dc.b	0
	even


****************************************


RAW_R	equ	$13
RAW_T	equ	$14
RAW_I	equ	$17
RAW_O	equ	$18

RAW_UP	equ	$4c
RAW_DOWN	equ	$4d
RAW_LEFT	equ	$4f
RAW_RIGHT	equ	$4e


serve.raw.keys
	cmp.b	#RAW_T,d3		toggle plan view command
	bne	.check.i

	IFNE	DEBUG
	DEBUGM	<Plan toggle>
	ENDC

	bsr	toggle.current.plan.view
	bra	.done

.check.i
	cmp.b	#RAW_I,d3		zoom in command
	bne.s	.check.o

	IFNE	DEBUG
	DEBUGM	<Plan zoom in>
	ENDC

	cmp.w	#MAXIMUM_ZOOM,plan.zoom.percent
	beq	.done

	bsr	current.plan.data.ptr
	add.w	#PLAN_ZOOM_INC,ZOOM_PERCENT(a0)
	bsr	refresh.current.plan.view
	bra	.done

.check.o
	cmp.b	#RAW_O,d3		zoom out command
	bne.s	.check.up

	IFNE	DEBUG
	DEBUGM	<Plan zoom out>
	ENDC

	cmp.w	#MINIMUM_ZOOM,plan.zoom.percent
	beq	.done

	bsr	current.plan.data.ptr
	sub.w	#PLAN_ZOOM_INC,ZOOM_PERCENT(a0)
	bsr	refresh.current.plan.view
	bra	.done

.check.up
	cmp.b	#RAW_UP,d3
	bne.s	.check.down

	IFNE	DEBUG
	DEBUGM	<Plan up>
	ENDC

	bsr	current.plan.data.ptr
	add.w	#PLAN_ZOOM_INC/2,Y_ZOOM_OFFSET(a0)
	bsr	refresh.current.plan.view
	bra	.done

.check.down
	cmp.b	#RAW_DOWN,d3
	bne.s	.check.left

	IFNE	DEBUG
	DEBUGM	<Plan down>
	ENDC

	bsr	current.plan.data.ptr
	sub.w	#PLAN_ZOOM_INC/2,Y_ZOOM_OFFSET(a0)
	bsr	refresh.current.plan.view
	bra	.done

.check.left
	cmp.b	#RAW_LEFT,d3
	bne.s	.check.right

	IFNE	DEBUG
	DEBUGM	<Plan left>
	ENDC

	bsr	current.plan.data.ptr
	add.w	#PLAN_ZOOM_INC/2,X_ZOOM_OFFSET(a0)
	bsr	refresh.current.plan.view
	bra	.done

.check.right
	cmp.b	#RAW_RIGHT,d3
	bne.s	.check.reset

	IFNE	DEBUG
	DEBUGM	<Plan right>
	ENDC

	bsr	current.plan.data.ptr
	sub.w	#PLAN_ZOOM_INC/2,X_ZOOM_OFFSET(a0)
	bsr	refresh.current.plan.view
	bra	.done

.check.reset
	cmp.b	#RAW_R,d3		reset zoom command
	bne.s	.check.prev

	IFNE	DEBUG
	DEBUGM	<Plan reset>
	ENDC

	bsr	current.plan.data.ptr
	bsr	set.plan.zoom.values
	bsr	refresh.current.plan.view
	bra	.done

.check.prev
	cmp.b	#RAW_COMMA,d3		previous object command
	bne.s	.check.next

	IFNE	DEBUG
	DEBUGM	<Plan previous object>
	ENDC

	move.w	current.SOD.object(pc),d0
	cmp.w	#1,d0
	ble.s	.done

	bsr	store.current.SOD.object
	subq.w	#1,current.SOD.object
	bsr	set.current.SOD.object
	bra.s	.done

.check.next
	cmp.b	#RAW_DOT,d3		next object command
	bne.s	.done

	IFNE	DEBUG
	DEBUGM	<Plan next object>
	ENDC

	move.w	current.SOD.object(pc),d0
	cmp.w	total.SOD.objects(pc),d0
	bge.s	.done

	bsr	store.current.SOD.object
	addq.w	#1,current.SOD.object
	bsr	set.current.SOD.object

.done	rts


****************************************


PLAN_FRONT	equ	0
PLAN_TOP	equ	1
PLAN_SIDE	equ	2


PLAN_BORDER	equ	7

* PLAN_WIDTH is divided by two because screen pixels are hi-res

PLAN_WIDTH	equ	(PLAN_WINDOW_WIDTH/2)-(PLAN_BORDER*2)
PLAN_HEIGHT	equ	(PLAN_WINDOW_HEIGHT)-(PLAN_BORDER*2)


MINIMUM_ZOOM	equ	60
DEFAULT_ZOOM	equ	100
MAXIMUM_ZOOM	equ	1000
PLAN_ZOOM_INC	equ	20

		rsreset
PLAN_DATA	rs.w	0
ZOOM_PERCENT	rs.w	1
X_ZOOM_OFFSET	rs.w	1
Y_ZOOM_OFFSET	rs.w	1
PLAN_DATA_SIZE	rs.w	0


initialise.plan.views
	move.w	#PLAN_FRONT,window5.plan.view
	move.w	#PLAN_TOP,window6.plan.view

	lea	front.plan.data(pc),a0
	bsr	set.plan.zoom.values
	lea	top.plan.data(pc),a0
	bsr	set.plan.zoom.values
	lea	side.plan.data(pc),a0
	bsr	set.plan.zoom.values
	rts


****************************************


set.plan.zoom.values
	move.w	#DEFAULT_ZOOM,ZOOM_PERCENT(a0)
	move.w	#0,X_ZOOM_OFFSET(a0)
	move.w	#0,Y_ZOOM_OFFSET(a0)
	rts


plan.zoom.percent	dc.w	0
plan.x.zoom.offset	dc.w	0
plan.y.zoom.offset	dc.w	0

plan.sorted.by.x	dc.b	0
plan.sorted.by.y	dc.b	0
plan.sorted.by.z	dc.b	0
	even


****************************************


current.plan.data.ptr
	move.w	current.window(pc),d0
	subq.w	#5,d0
	add.w	d0,d0
	move.w	window5.plan.view(pc,d0.w),d0
	lsl.w	#2,d0
	lea	plan.data.table(pc),a0
	move.l	(a0,d0.w),a0
	rts


****************************************


toggle.current.plan.view
	move.w	current.window(pc),d0
	subq.w	#5,d0
	add.w	d0,d0
	lea	window5.plan.view(pc,d0.w),a5

	moveq	#3,d5
	sub.w	window5.plan.view(pc),d5
	sub.w	window6.plan.view(pc),d5
	move.w	d5,(a5)

	add.w	d0,d0
	move.l	refresh.plan.table(pc,d0.w),a0
	jmp	(a0)


window5.plan.view	dc.w	0
window6.plan.view	dc.w	0

refresh.plan.table
	dc.l	refresh.window5
	dc.l	refresh.window6


****************************************


refresh.current.plan.view
	move.w	current.window(pc),d0
	subq.w	#5,d0
	lsl.w	#2,d0
	move.l	refresh.plan.table(pc,d0.w),a0
	jmp	(a0)


****************************************


refresh.plan.views
	st	SOD.object.modified

	sf	plan.sorted.by.x
	sf	plan.sorted.by.y
	sf	plan.sorted.by.z

	bsr	calculate.plan.x.y.z.ranges

	bsr.s	refresh.window5
	bra.s	refresh.window6


****************************************


refresh.window5
	move.l	window5(pc),a0
	move.l	wd_RPort(a0),plan.rp
	bsr	clear.plan.view
	move.w	window5.plan.view(pc),d0
	lsl.w	#2,d0
	move.l	plan.data.table(pc,d0.w),a0
	bsr	get.plan.zoom.values
	move.l	plan.view.table(pc,d0.w),a0
	jmp	(a0)


refresh.window6
	move.l	window6(pc),a0
	move.l	wd_RPort(a0),plan.rp
	bsr	clear.plan.view
	move.w	window6.plan.view(pc),d0
	lsl.w	#2,d0
	move.l	plan.data.table(pc,d0.w),a0
	bsr	get.plan.zoom.values
	move.l	plan.view.table(pc,d0.w),a0
	jmp	(a0)


get.plan.zoom.values
	move.w	ZOOM_PERCENT(a0),plan.zoom.percent
	move.w	X_ZOOM_OFFSET(a0),plan.x.zoom.offset
	move.w	Y_ZOOM_OFFSET(a0),plan.y.zoom.offset
	rts


plan.rp	dc.l	0

plan.view.table	dc.l	front.plan.view
		dc.l	top.plan.view
		dc.l	side.plan.view

plan.data.table	dc.l	front.plan.data
		dc.l	top.plan.data
		dc.l	side.plan.data


front.plan.data	ds.b	PLAN_DATA_SIZE
top.plan.data	ds.b	PLAN_DATA_SIZE
side.plan.data	ds.b	PLAN_DATA_SIZE


****************************************


PLAN_WINDOW_BORDER	equ	2


clear.plan.view
	moveq	#3,d0
	move.l	plan.rp(pc),a1
	CALLGRAF SetAPen

	move.w	#PLAN_WINDOW_BORDER*2,d0
	move.w	#PLAN_WINDOW_BORDER,d1
	move.w	#PLAN_WINDOW_WIDTH-(PLAN_WINDOW_BORDER*2+1),d2
	move.w	#PLAN_WINDOW_HEIGHT-(PLAN_WINDOW_BORDER+1),d3
	move.l	plan.rp(pc),a1
	CALLGRAF RectFill

	moveq	#1,d0
	move.l	plan.rp(pc),a1
	CALLGRAF SetAPen
	rts


****************************************


calculate.plan.x.y.z.ranges
	move.l	coord.memory(pc),a5
	lea	X_VALUE(a5),a4
	bsr	calculate.plan.range
	move.w	d0,plan.min.x
	sub.w	d0,d1
	bne.s	.store.x
	moveq	#1,d1			prevent division by zero later on
.store.x
	move.w	d1,plan.x.range

	move.l	coord.memory(pc),a5
	lea	Y_VALUE(a5),a4
	bsr	calculate.plan.range
	move.w	d0,plan.min.y
	sub.w	d0,d1
	bne.s	.store.y
	moveq	#1,d1			prevent division by zero later on
.store.y
	move.w	d1,plan.y.range

	move.l	coord.memory(pc),a5
	lea	Z_VALUE(a5),a4
	bsr	calculate.plan.range
	move.w	d0,plan.min.z
	sub.w	d0,d1
	bne.s	.store.z
	moveq	#1,d1			prevent division by zero later on
.store.z
	move.w	d1,plan.z.range
	rts


calculate.plan.range

* a4 = ptr to first x, y or z co-ord

	moveq	#0,d0			min. co-ord
	moveq	#0,d1			max. co-ord
	move.w	total.coords(pc),d7
	beq.s	.done
	subq.w	#1,d7
	move.l	a4,a3

* first work out the minimum and maximum co-ord values

.loop	move.w	(a4),d6			next co-ord value

.min	cmp.w	d6,d0
	ble.s	.max
	move.w	d6,d0
	bra.s	.next

.max	cmp.w	d6,d1
	bge.s	.next
	move.w	d6,d1

.next	lea	COORD_SIZE(a4),a4
	dbra	d7,.loop

* now take the radii of any circles into account

	move.w	total.components(pc),d7
	beq.s	.done
	subq.w	#1,d7
	move.l	component.memory(pc),a4

.loop2	move.w	TYPE(a4),d6
	cmp.w	#CIRCLE,d6
	bne.s	.next2

	move.w	COORDS(a4),d6
	subq.w	#1,d6
	mulu	#COORD_SIZE,d6
	move.w	(a3,d6.l),d6		get circle centre co-ord

	move.l	COORDS+2(a4),d5
	asr.l	#7,d5			get circle radius

.min2	move.w	d6,d4
	sub.w	d5,d4			circle minimum point

	cmp.w	d4,d0
	ble.s	.max2
	move.w	d4,d0

.max2	move.w	d6,d4
	add.w	d5,d4			circle maximum point

	cmp.w	d4,d1
	bge.s	.next2
	move.w	d4,d1

.next2	lea	COMPONENT_SIZE(a4),a4
	dbra	d7,.loop2

.done	rts


plan.min.x	dc.w	0
plan.min.y	dc.w	0
plan.min.z	dc.w	0

plan.x.range	dc.w	0
plan.y.range	dc.w	0
plan.z.range	dc.w	0


****************************************


calculate.plan.scale

* d7.w = value to use as x range
* d6.w = value to use as y range
* d5.w = value to use as min. x
* d4.w = value to use as min. y
*
* calculate x and y centre offsets
*
* x centre offset = ((((0 - min.x) * WIDTH) / x.range) + BORDER)

	neg.w	d5
	muls	#PLAN_WIDTH,d5
	divs	d7,d5
	add.w	#PLAN_BORDER,d5
	move.w	d5,plan.x.centre

* y centre offset = ((((0 - min.y) * HEIGHT) / y.range) + BORDER)

	neg.w	d4
	muls	#PLAN_HEIGHT,d4
	divs	d6,d4
	add.w	#PLAN_BORDER,d4
	move.w	d4,plan.y.centre

* calculate scale multiplier and divisor
*
* aspect ratio = PLAN_WIDTH / PLAN_HEIGHT

	move.w	d6,d5
	mulu	#PLAN_WIDTH,d5
	divu	#PLAN_HEIGHT,d5		multiply by aspect ratio

	cmp.w	d7,d5
	bgt.s	.y.range

.x.range
	move.w	#PLAN_WIDTH,d5
	bra.s	.store

.y.range
	move.w	#PLAN_HEIGHT,d5
	move.w	d6,d7

.store	move.w	d5,plan.scale.multiplier
	move.w	d7,plan.scale.divisor
	rts


plan.scale.multiplier	dc.w	0
plan.scale.divisor	dc.w	0

plan.x.centre	dc.w	0
plan.y.centre	dc.w	0


****************************************


calculate.plan.coord

* d0.w = co-ord position
*
* a5 = ptr to co-ords to use for plan x
* a4 = ptr to co-ords to use for plan y
*
* returns with d0.w = plan x co-ord, d1.w = plan y co-ord

	subq.w	#1,d0
	mulu	#COORD_SIZE,d0


	move.w	(a4,d0.l),d1			y co-ord
	muls	plan.scale.multiplier(pc),d1	multiply by scale
	divs	plan.scale.divisor(pc),d1

	muls	plan.zoom.percent(pc),d1	multiply by zoom
	divs	#100,d1

	add.w	plan.y.centre(pc),d1		add centre offset

	tst.b	reverse.y.coords
	beq.s	.no.y.reverse

	move.w	d1,d4
	move.w	#PLAN_WINDOW_HEIGHT,d1
	sub.w	d4,d1


.no.y.reverse
	move.w	(a5,d0.l),d0			x co-ord
	muls	plan.scale.multiplier(pc),d0	multiply by scale
	divs	plan.scale.divisor(pc),d0

	muls	plan.zoom.percent(pc),d0	multiply by zoom
	divs	#100,d0

	add.w	plan.x.centre(pc),d0		add centre offset
	add.w	d0,d0				double up for hi-res

	tst.b	reverse.x.coords
	beq.s	.no.x.reverse

	move.w	d0,d4
	move.w	#PLAN_WINDOW_WIDTH,d0
	sub.w	d4,d0

.no.x.reverse

* adjust x and y, for current zoom position

	move.w	plan.x.zoom.offset(pc),d4
	muls	#PLAN_WIDTH,d4
	divs	#100,d4
	add.w	d4,d0

	move.w	plan.y.zoom.offset(pc),d4
	muls	#PLAN_HEIGHT,d4
	divs	#100,d4
	add.w	d4,d1
	rts


reverse.x.coords	dc.b	0
reverse.y.coords	dc.b	0


****************************************


FRONT_IMAGE_WIDTH	equ	26
FRONT_IMAGE_HEIGHT	equ	7


front.plan.view
	move.w	plan.x.range(pc),d7
	move.w	plan.y.range(pc),d6
	move.w	plan.min.x(pc),d5
	move.w	plan.min.y(pc),d4
	bsr	calculate.plan.scale

	tst.b	plan.sorted.by.z
	bne.s	.draw
	bsr	sort.plan.by.z

.draw	sf	reverse.x.coords
	sf	reverse.y.coords
	bsr	draw.plan.axes

	move.l	coord.memory(pc),a5
	lea	Y_VALUE(a5),a4
	lea	X_VALUE(a5),a5
	bsr	draw.plan.components

* display view name

	move.l	plan.rp(pc),a0
	lea	front.image(pc),a1
	move.w	#(PLAN_WINDOW_WIDTH-FRONT_IMAGE_WIDTH)/2+1,d0
	moveq	#PLAN_WINDOW_BORDER,d1
	CALLINT	DrawImage

	bsr	label.plan.coords.by.z
	rts


front.image	dc.w	0		left
		dc.w	0		top
		dc.w	FRONT_IMAGE_WIDTH	width
		dc.w	FRONT_IMAGE_HEIGHT	height
		dc.w	SCREEN_DEPTH	depth
		dc.l	front.data	image data
		dc.b	%01		plane pick
		dc.b	%00		plane on off
		dc.l	0		next image


****************************************


TOP_IMAGE_WIDTH		equ	15
TOP_IMAGE_HEIGHT	equ	7


top.plan.view
	move.w	plan.x.range(pc),d7
	move.w	plan.z.range(pc),d6
	move.w	plan.min.x(pc),d5
	move.w	plan.min.z(pc),d4
	bsr	calculate.plan.scale

	tst.b	plan.sorted.by.y
	bne.s	.draw
	bsr	sort.plan.by.y

.draw	sf	reverse.x.coords
	st	reverse.y.coords
	bsr	draw.plan.axes

	move.l	coord.memory(pc),a5
	lea	Z_VALUE(a5),a4
	lea	X_VALUE(a5),a5
	bsr	draw.plan.components

* display view name

	move.l	plan.rp(pc),a0
	lea	top.image(pc),a1
	move.w	#(PLAN_WINDOW_WIDTH-TOP_IMAGE_WIDTH)/2+1,d0
	moveq	#PLAN_WINDOW_BORDER,d1
	CALLINT	DrawImage

	bsr	label.plan.coords.by.y
	rts


top.image	dc.w	0		left
		dc.w	0		top
		dc.w	TOP_IMAGE_WIDTH	width
		dc.w	TOP_IMAGE_HEIGHT	height
		dc.w	SCREEN_DEPTH	depth
		dc.l	top.data	image data
		dc.b	%01		plane pick
		dc.b	%00		plane on off
		dc.l	0		next image


****************************************


SIDE_IMAGE_WIDTH	equ	19
SIDE_IMAGE_HEIGHT	equ	7


side.plan.view
	move.w	plan.z.range(pc),d7
	move.w	plan.y.range(pc),d6
	move.w	plan.min.z(pc),d5
	move.w	plan.min.y(pc),d4
	bsr	calculate.plan.scale

	tst.b	plan.sorted.by.x
	bne.s	.draw
	bsr	sort.plan.by.x

.draw	st	reverse.x.coords
	sf	reverse.y.coords
	bsr	draw.plan.axes

	move.l	coord.memory(pc),a5
	lea	Y_VALUE(a5),a4
	lea	Z_VALUE(a5),a5
	bsr	draw.plan.components

* display view name

	move.l	plan.rp(pc),a0
	lea	side.image(pc),a1
	move.w	#(PLAN_WINDOW_WIDTH-SIDE_IMAGE_WIDTH)/2+1,d0
	moveq	#PLAN_WINDOW_BORDER,d1
	CALLINT	DrawImage

	bsr	label.plan.coords.by.x
	rts


side.image	dc.w	0		left
		dc.w	0		top
		dc.w	SIDE_IMAGE_WIDTH	width
		dc.w	SIDE_IMAGE_HEIGHT	height
		dc.w	SCREEN_DEPTH	depth
		dc.l	side.data	image data
		dc.b	%01		plane pick
		dc.b	%00		plane on off
		dc.l	0		next image


****************************************


		rsreset
NODE		rs.w	0
NEXT		rs.l	1
POS		rs.w	1
VALUE		rs.w	1
NODE_SIZE	rs.w	0


sort.plan.by.x
	move.l	coord.memory(pc),a5
	lea	X_VALUE(a5),a5
	lea	x.node.space(pc),a4
	bsr.s	sort.plan.coords.descending
	move.l	a0,x.top.list
	rts


sort.plan.by.y
	move.l	coord.memory(pc),a5
	lea	Y_VALUE(a5),a5
	lea	y.node.space(pc),a4
	bsr.s	sort.plan.coords.descending
	move.l	a0,y.top.list
	rts


sort.plan.by.z
	move.l	coord.memory(pc),a5
	lea	Z_VALUE(a5),a5
	lea	z.node.space(pc),a4
	bsr.s	sort.plan.coords.descending
	move.l	a0,z.top.list
	rts


sort.plan.coords.descending

* a5 = ptr to first x, y or z co-ord
* a4 = ptr to node space for sorted co-ords
*
* returns with a0 = top of list

	sub.l	a0,a0			top of list
	move.w	total.coords(pc),d7
	beq.s	.done
	subq.w	#1,d7
	moveq	#1,d6			first co-ord pos

.loop	move.w	(a5),d5
	CHECK	3,add.coord.to.list.descending,d5-d7/a4-a5
	lea	NODE_SIZE(a4),a4
	lea	COORD_SIZE(a5),a5
	addq.w	#1,d6
	dbra	d7,.loop

.done	rts


add.coord.to.list.descending
	clr.l	NEXT(a4)		initialise node values
	move.w	d6,POS(a4)
	move.w	d5,VALUE(a4)

	move.l	a0,d4
	bne.s	.not.NULL
	move.l	a4,a0
	rts


.not.NULL
	move.l	d4,a3			current node

	cmp.w	VALUE(a3),d5
	bgt.s	.insert

	move.l	NEXT(a3),d4
	beq.s	.append

	move.l	a3,a2			store as previous node
	bra.s	.not.NULL


.insert	cmp.l	a0,a3
	beq.s	.top.of.list

	move.l	a4,NEXT(a2)
	move.l	a3,NEXT(a4)
	rts


.top.of.list
	move.l	a3,NEXT(a4)
	move.l	a4,a0
	rts


.append	move.l	a4,NEXT(a3)
	rts


x.top.list	dc.l	0
y.top.list	dc.l	0
z.top.list	dc.l	0

x.node.space	ds.b	MAX_COORDS*NODE_SIZE
y.node.space	ds.b	MAX_COORDS*NODE_SIZE
z.node.space	ds.b	MAX_COORDS*NODE_SIZE


****************************************


draw.plan.axes
	moveq	#3,d0
	move.l	plan.rp(pc),a1
	CALLGRAF SetBPen

* calculate origin position, using a dummy co-ord

 	moveq	#1,d0
	lea	zero.coord(pc),a4
	lea	zero.coord(pc),a5
	bsr	calculate.plan.coord
	move.w	d0,d6
	move.w	d1,d7

* draw horizontal axis

	cmp.w	#PLAN_WINDOW_BORDER,d7		min. y
	blt.s	.vert

	cmp.w	#PLAN_WINDOW_HEIGHT-(PLAN_WINDOW_BORDER+1),d7	max. y
	bgt.s	.vert

	move.l	plan.rp(pc),a1
	move.w	#$cccc,rp_LinePtrn(a1)

	move.w	#PLAN_WINDOW_BORDER*2,d0	min. x
	move.w	d7,d1
	move.l	plan.rp(pc),a1
	CALLGRAF Move

	move.w	#PLAN_WINDOW_WIDTH-(PLAN_WINDOW_BORDER*2+1),d0	max. x
	move.w	d7,d1
	move.l	plan.rp(pc),a1
	CALLGRAF Draw

* draw vertical axis

.vert	cmp.w	#PLAN_WINDOW_BORDER*2,d6	min. x
	blt.s	.done

	cmp.w	#PLAN_WINDOW_WIDTH-(PLAN_WINDOW_BORDER*2+1),d6	max. x
	bgt.s	.done

	move.l	plan.rp(pc),a1
	move.w	#$aaaa,rp_LinePtrn(a1)

	move.w	d6,d0
	move.w	#PLAN_WINDOW_BORDER,d1		min. y
	move.l	plan.rp(pc),a1
	CALLGRAF Move

	move.w	d6,d0
	move.w	#PLAN_WINDOW_HEIGHT-(PLAN_WINDOW_BORDER+1),d1	max. y
	move.l	plan.rp(pc),a1
	CALLGRAF Draw

* restore drawing mode

.done	move.l	plan.rp(pc),a1
	move.w	#$ffff,rp_LinePtrn(a1)

	moveq	#0,d0
	move.l	plan.rp(pc),a1
	CALLGRAF SetBPen
	rts


zero.coord	dc.w	0


****************************************


draw.plan.components

* a5 = ptr to co-ords to use for plan x
* a4 = ptr to co-ords to use for plan y

	move.w	total.components(pc),d7
	beq	.done
	subq.w	#1,d7
	move.l	component.memory(pc),a3

.loop	move.w	TYPE(a3),d6
	cmp.w	#CIRCLE,d6
	bne.s	.check.polygon
	CHECK	4,draw.plan.circle,d7/a3
	bra.s	.next

.check.polygon
	cmp.w	#POLYGON,d6
	bne.s	.check.vector
	CHECK	5,draw.plan.polygon,d7/a3
	bra.s	.next

.check.vector
	cmp.w	#VECTOR,d6
	bne.s	.next
	CHECK	6,draw.plan.vector,d7/a3

.next	lea	COMPONENT_SIZE(a3),a3
	dbra	d7,.loop

.done	rts


****************************************


draw.plan.circle

* a5 = ptr to co-ords to use for plan x
* a4 = ptr to co-ords to use for plan y

	move.w	COORDS(a3),d0
	bsr	calculate.plan.coord
	move.w	d0,d5			get circle centre
	move.w	d1,d6

	move.l	COORDS+2(a3),d4
	asr.l	#7,d4			get circle radius
	muls	plan.scale.multiplier(pc),d4
	divs	plan.scale.divisor(pc),d4
	muls	plan.zoom.percent(pc),d4
	divs	#100,d4

	move.w	d7,-(sp)
	bsr	clip.plan.circle
	move.w	(sp)+,d7
	rts


****************************************


clip.plan.circle

* d4.w = radius, d5.w = x centre, d6.w = y centre
*
* uses d0-d4/d7, a1

	moveq	#0,d3			starting X, radius becomes Y

	bsr.s	plot.8.circle.octants

	moveq	#3,d7
	sub.w	d4,d7			3-R
	sub.w	d4,d7			3-2R = first decision parameter

	bpl.s	.move.M2		when decision parameter >= 0

.move.M1				* when decision parameter < 0
	addq.w	#1,d3			X+1

	cmp.w	d4,d3			X-Y
	bge.s	.done			if X >= Y

	bsr.s	plot.8.circle.octants

	move.w	d3,d2
	add.w	d2,d2			2Xn
	add.w	d2,d2			4Xn
	add.w	d2,d7			old parameter + 4Xn
	addq.w	#2,d7			old parameter + 4Xn + 2

	bmi.s	.move.M1

.move.M2				* when decision parameter >= 0
	addq.w	#1,d3			X+1
	subq.w	#1,d4			Y-1

	cmp.w	d4,d3			X-Y
	bge.s	.done			if X >= Y

	bsr.s	plot.8.circle.octants

	move.w	d3,d2
	sub.w	d4,d2
	add.w	d2,d2			2(Xn-Yn)
	add.w	d2,d2			4(Xn-Yn)
	add.w	d2,d7			old parameter + 4(Xn-Yn)
	addq.w	#2,d7			old parameter + 4(Xn-Yn) + 2

	bmi.s	.move.M1
	bra.s	.move.M2

.done					* X >= Y
	beq.s	plot.8.circle.octants	plot last points (here X = Y)
	rts				if X not equal to Y then don't plot


****************************************


plot.8.circle.octants			* take advantage of symmetry
	add.w	d3,d3			double up for hi-res

	move.w	d3,d0			X
	move.w	d4,d1			Y
	add.w	d5,d0			centre X up
	add.w	d6,d1			centre Y up
	bsr.s	plot.plan.pixel

	neg.w	d3			-X
	move.w	d3,d0			-X
	move.w	d4,d1			Y
	add.w	d5,d0			centre X up
	add.w	d6,d1			centre Y up
	bsr.s	plot.plan.pixel

	neg.w	d4			-Y
	move.w	d3,d0			-X
	move.w	d4,d1			-Y
	add.w	d5,d0			centre X up
	add.w	d6,d1			centre Y up
	bsr.s	plot.plan.pixel

	neg.w	d3			X
	move.w	d3,d0			X
	move.w	d4,d1			-Y
	add.w	d5,d0			centre X up
	add.w	d6,d1			centre Y up
	bsr.s	plot.plan.pixel

	lsr.w	#1,d3
	exg	d3,d4			exchange X with Y
	add.w	d3,d3			double up for hi-res

	move.w	d3,d0			-Y
	move.w	d4,d1			X
	add.w	d5,d0			centre X up
	add.w	d6,d1			centre Y up
	bsr.s	plot.plan.pixel

	neg.w	d4			-X
	move.w	d3,d0			-Y
	move.w	d4,d1			-X
	add.w	d5,d0			centre X up
	add.w	d6,d1			centre Y up
	bsr.s	plot.plan.pixel

	neg.w	d3			Y
	move.w	d3,d0			Y
	move.w	d4,d1			-X
	add.w	d5,d0			centre X up
	add.w	d6,d1			centre Y up
	bsr.s	plot.plan.pixel

	neg.w	d4			X
	move.w	d3,d0			Y
	move.w	d4,d1			X
	add.w	d5,d0			centre X up
	add.w	d6,d1			centre Y up

	lsr.w	#1,d3
	exg	d3,d4			restore X and Y
;	bra.s	plot.plan.pixel		directly after it


****************************************


plot.plan.pixel

* d0.w = x, d1.w = y

	cmp.w	#PLAN_WINDOW_BORDER*2,d0	min. x
	blt.s	.done

	cmp.w	#PLAN_WINDOW_BORDER,d1		min. y
	blt.s	.done

	cmp.w	#PLAN_WINDOW_WIDTH-(PLAN_WINDOW_BORDER*2+1),d0	max. x
	bge.s	.done

	cmp.w	#PLAN_WINDOW_HEIGHT-(PLAN_WINDOW_BORDER+1),d1	max. y
	bgt.s	.done

	movem.l	d0-d1,-(sp)
	move.l	plan.rp(pc),a1
	CALLGRAF WritePixel
	movem.l	(sp)+,d0-d1

	addq.w	#1,d0
	move.l	plan.rp(pc),a1
	CALLGRAF WritePixel		draw adjacent pixel for hi-res

.done	rts


****************************************


draw.plan.polygon

* a5 = ptr to co-ords to use for plan x
* a4 = ptr to co-ords to use for plan y

	move.w	NUM_COORDS(a3),d6
	subq.w	#1,d6
	bmi.s	.error
	lea	COORDS(a3),a2
	move.w	d6,d2
	add.w	d2,d2
	move.w	(a2,d2.w),d0		last co-ord position
	bpl.s	.plus
	neg.w	d0
.plus	bsr	calculate.plan.coord
	move.w	d0,d2
	move.w	d1,d3

.loop	move.w	(a2)+,d0		next co-ord position
	bpl.s	.plus2
	neg.w	d0
.plus2	bsr	calculate.plan.coord

	movem.w	d0-d1/d6-d7,-(sp)
	bsr	clip.plan.line
	movem.w	(sp)+,d2-d3/d6-d7

	dbra	d6,.loop
	rts

.error	ERROR	<  dbra error 2>
	rts


****************************************


draw.plan.vector

* a5 = ptr to co-ords to use for plan x
* a4 = ptr to co-ords to use for plan y

	move.w	COORDS(a3),d0
	bsr	calculate.plan.coord
	move.w	d0,d2
	move.w	d1,d3

	move.w	COORDS+2(a3),d0
	bsr	calculate.plan.coord

	move.w	d7,-(sp)
	bsr	clip.plan.line
	move.w	(sp)+,d7
	rts


****************************************


clip.plan.line

* d0 = x1, d1 = y1, d2 = x2, d3 = y2
*
* uses d4-d7, a0-a1

	move.w	#PLAN_WINDOW_BORDER*2,a0	min. x
	move.w	#PLAN_WINDOW_BORDER,a1		min. y

	move.w	#PLAN_WINDOW_WIDTH-(PLAN_WINDOW_BORDER*2+1),d6	max. x
	move.w	#PLAN_WINDOW_HEIGHT-(PLAN_WINDOW_BORDER+1),d7	max. y

	cmp.w	a0,d0			x1
	bge.s	.x1.not.off.left

* x1 is off left of screen

	cmp.w	a0,d2			x2
	blt.s	.end.clip.line		if line is off left of screen

* clip line to left edge, giving a new value for y1

	move.w	d2,d4			x2
	sub.w	d0,d4			x2-x1
	move.w	d3,d5			y2
	sub.w	d1,d5			y2-y1
	sub.w	a0,d0			x1-min
	muls	d0,d5			(x1-min) * (y2-y1)
	divs	d4,d5			((x1-min) * (y2-y1)) / (x2-x1)
	sub.w	d5,d1			y1 - (((x1-min) * (y2-y1)) / (x2-x1))
	move.w	a0,d0			x1 = min
	bra.s	.x1.clipped

.end.clip.line
	rts


.x1.not.off.left
	cmp.w	d6,d0			x1
	ble.s	.x1.clipped

* x1 is off right of screen

	cmp.w	d6,d2			x2
	bgt.s	.end.clip.line		if line is off right of screen

* clip line to right edge, giving a new value for y1

	move.w	d2,d4			x2
	sub.w	d0,d4			x2-x1
	move.w	d3,d5			y2
	sub.w	d1,d5			y2-y1
	sub.w	d6,d0			x1-max
	muls	d0,d5			(x1-max) * (y2-y1)
	divs	d4,d5			((x1-max) * (y2-y1)) / (x2-x1)
	sub.w	d5,d1			y1 - (((x1-max) * (y2-y1)) / (x2-x1))
	move.w	d6,d0			x1 = max


.x1.clipped
	cmp.w	a1,d1			y1
	bge.s	.y1.not.off.top

* y1 is off top of screen

	cmp.w	a1,d3			y2
	blt.s	.end.clip.line		if line is off top of screen

* clip line to top edge, giving a new value for x1

	move.w	d2,d4			x2
	sub.w	d0,d4			x2-x1
	move.w	d3,d5			y2
	sub.w	d1,d5			y2-y1
	sub.w	a1,d1			y1-min
	muls	d1,d4			(y1-min) * (x2-x1)
	divs	d5,d4			((y1-min) * (x2-x1)) / (y2-y1)
	sub.w	d4,d0			x1 - (((y1-min) * (x2-x1)) / (y2-y1))

	cmp.w	a0,d0
	blt.s	.end.clip.line2		if new x1 is off left of screen

	move.w	a1,d1			y1 = min

	cmp.w	d6,d0
	ble.s	.y1.clipped		if new x1 is not off right of screen

.end.clip.line2
	rts


.y1.not.off.top
	cmp.w	d7,d1			y1
	ble.s	.y1.clipped

* y1 is off bottom of screen

	cmp.w	d7,d3			y2
	bgt.s	.end.clip.line2		if line is off bottom of screen

* clip line to bottom edge, giving a new value for x1

	move.w	d2,d4			x2
	sub.w	d0,d4			x2-x1
	move.w	d3,d5			y2
	sub.w	d1,d5			y2-y1
	sub.w	d7,d1			y1-max
	muls	d1,d4			(y1-max) * (x2-x1)
	divs	d5,d4			((y1-max) * (x2-x1)) / (y2-y1)
	sub.w	d4,d0			x1 - (((y1-max) * (x2-x1)) / (y2-y1))

	cmp.w	a0,d0
	blt.s	.end.clip.line2		if new x1 is off left of screen

	cmp.w	d6,d0
	bgt.s	.end.clip.line2		if new x1 is off right of screen

	move.w	d7,d1			y1 = max


.y1.clipped
	cmp.w	a0,d2			x2
	bge.s	.x2.not.off.left

* x2 is off left of screen

* clip line to left edge, giving a new value for y2

	move.w	d0,d4			x1
	sub.w	d2,d4			x1-x2
	move.w	d1,d5			y1
	sub.w	d3,d5			y1-y2
	sub.w	a0,d2			x2-min
	muls	d2,d5			(x2-min) * (y1-y2)
	divs	d4,d5			((x2-min) * (y1-y2)) / (x1-x2)
	sub.w	d5,d3			y2 - (((x2-min) * (y1-y2)) / (x1-x2))
	move.w	a0,d2			x2 = min
	bra.s	.x2.clipped


.x2.not.off.left
	cmp.w	d6,d2			x2
	ble.s	.x2.clipped

* x2 is off right of screen

* clip line to right edge, giving a new value for y2

	move.w	d0,d4			x1
	sub.w	d2,d4			x1-x2
	move.w	d1,d5			y1
	sub.w	d3,d5			y1-y2
	sub.w	d6,d2			x2-max
	muls	d2,d5			(x2-max) * (y1-y2)
	divs	d4,d5			((x2-max) * (y1-y2)) / (x1-x2)
	sub.w	d5,d3			y2 - (((x2-max) * (y1-y2)) / (x1-x2))
	move.w	d6,d2			x2 = max


.x2.clipped
	cmp.w	a1,d3			y2
	bge.s	.y2.not.off.top

* y2 is off top of screen

* clip line to top edge, giving a new value for x2

	move.w	d0,d4			x1
	sub.w	d2,d4			x1-x2
	move.w	d1,d5			y1
	sub.w	d3,d5			y1-y2
	sub.w	a1,d3			y2-min
	muls	d3,d4			(y2-min) * (x1-x2)
	divs	d5,d4			((y2-min) * (x1-x2)) / (y1-y2)
	sub.w	d4,d2			x2 - (((y2-min) * (x1-x2)) / (y1-y2))

	cmp.w	a0,d2
	blt.s	.end.clip.line3		if new x2 is off left of screen

	move.w	a1,d3			y2 = min

	cmp.w	d6,d2
	ble.s	.draw.line		if new x1 is not off right of screen

.end.clip.line3
	rts


.y2.not.off.top
	cmp.w	d7,d3			y2
	ble.s	.draw.line

* y2 is off bottom of screen

* clip line to bottom edge, giving a new value for x2

	move.w	d0,d4			x1
	sub.w	d2,d4			x1-x2
	move.w	d1,d5			y1
	sub.w	d3,d5			y1-y2
	sub.w	d7,d3			y2-max
	muls	d3,d4			(y2-max) * (x1-x2)
	divs	d5,d4			((y2-max) * (x1-x2)) / (y1-y2)
	sub.w	d4,d2			x2 - (((y2-max) * (x1-x2)) / (y1-y2))

	cmp.w	a0,d2
	blt.s	.end.clip.line3		if new x2 is off left of screen

	cmp.w	d6,d2
	bgt.s	.end.clip.line3		if new x2 is off right of screen

	move.w	d7,d3			y2 = max


.draw.line
	move.l	plan.rp(pc),a1
	CALLGRAF Move

	move.w	d2,d0
	move.w	d3,d1
	move.l	plan.rp(pc),a1
	CALLGRAF Draw
	rts


****************************************


label.plan.coords.by.x
	move.l	coord.memory(pc),a5
	lea	Y_VALUE(a5),a4
	lea	Z_VALUE(a5),a5
	move.l	x.top.list(pc),d7
	bne.s	label.plan.coords
	rts


label.plan.coords.by.y
	move.l	coord.memory(pc),a5
	lea	Z_VALUE(a5),a4
	lea	X_VALUE(a5),a5
	move.l	y.top.list(pc),d7
	bne.s	label.plan.coords
	rts


label.plan.coords.by.z
	move.l	coord.memory(pc),a5
	lea	Y_VALUE(a5),a4
	lea	X_VALUE(a5),a5
	move.l	z.top.list(pc),d7
	bne.s	label.plan.coords
	rts


COORD_IMAGE_MIN_X	equ	PLAN_WINDOW_BORDER*2
COORD_IMAGE_MAX_X	equ	PLAN_WINDOW_WIDTH-(PLAN_WINDOW_BORDER*2+1)

COORD_IMAGE_MIN_Y	equ	PLAN_WINDOW_BORDER
COORD_IMAGE_MAX_Y	equ	PLAN_WINDOW_HEIGHT-(PLAN_WINDOW_BORDER+1)


label.plan.coords

* a5 = ptr to co-ords to use for plan x
* a4 = ptr to co-ords to use for plan y
* d7 = top of sorted co-ord list (must not be NULL)

.loop	move.l	d7,a3
	move.w	POS(a3),d6

	bsr	build.coord.image

* display co-ord position using x, y co-ords

	move.l	plan.rp(pc),a0
	lea	coord.image(pc),a1
	move.w	d6,d0
	bsr	calculate.plan.coord
	move.w	coord.image.width(pc),d2
	move.w	d2,d3
	lsr.w	#1,d3
	sub.w	d3,d0			centre image over co-ord
	sub.w	#COORD_IMAGE_HEIGHT/2,d1

	cmp.w	#COORD_IMAGE_MIN_X,d0
	blt.s	.next

	move.w	d0,d3
	add.w	d2,d3
	cmp.w	#COORD_IMAGE_MAX_X+1,d3
	bgt.s	.next

	cmp.w	#COORD_IMAGE_MIN_Y,d1
	blt.s	.next

	move.w	d1,d3
	add.w	#COORD_IMAGE_HEIGHT,d3
	cmp.w	#COORD_IMAGE_MAX_Y+1,d3
	bgt.s	.next

	CALLINT	DrawImage

.next	move.l	NEXT(a3),d7
	bne.s	.loop

	rts


****************************************


COORD_IMAGE_HEIGHT	equ	7

DIGIT_IMAGE_WIDTH	equ	6


build.coord.image

* build up bitmap data for digits
*
* d6.w = co-ord position

	move.w	d6,d0
	lea	coord.buffer(pc),a0
	bsr	word.to.ASCII
	clr.b	(a0)

	lea	coord.buffer(pc),a0
	lea	coord.data,a1
	moveq	#0,d0
	move.l	a1,a2			first clear co-ord image data
	REPT	COORD_IMAGE_HEIGHT
	move.w	d0,(a2)+
	ENDR

	moveq	#0,d1			first digit will not be shifted
	move.b	(a0)+,d0

.loop	sub.b	#'0',d0
	lsl.w	#2,d0
	move.l	digit.data.table(pc,d0.w),a2

	moveq	#COORD_IMAGE_HEIGHT-1,d3
	move.l	a1,a6

.loop2	move.w	(a2)+,d2
	lsr.w	d1,d2			shift and store all lines of digit
	or.w	d2,(a6)+
	dbra	d3,.loop2

	addq.w	#DIGIT_IMAGE_WIDTH-1,d1	increase shift value for next digit

	move.b	(a0)+,d0
	bne.s	.loop

	addq.w	#1,d1
	move.w	d1,coord.image.width
	rts


coord.buffer	ds.b	6


coord.image	dc.w	0		left
		dc.w	0		top
coord.image.width
		dc.w	0		width
		dc.w	COORD_IMAGE_HEIGHT	height
		dc.w	SCREEN_DEPTH	depth
		dc.l	coord.data	image data
		dc.b	%01		plane pick
		dc.b	%00		plane on off
		dc.l	0		next image


digit.data.table
	dc.l	zero,one,two,three,four,five,six,seven,eight,nine


****************************************


MENU1	equ	0

MENU1_LOADBANK	equ	0
MENU1_OPENBANK	equ	1
MENU1_SAVEBANK	equ	2
MENU1_LOADDIR	equ	3
MENU1_OPENDIR	equ	4
MENU1_SAVEDIR	equ	5
MENU1_CLEAR	equ	6
MENU1_QUIT	equ	7

MENU2	equ	1

MENU2_3DVIEW	equ	0
MENU2_NEW	equ	1
MENU2_LOAD	equ	2
MENU2_OPEN	equ	3
MENU2_SAVE	equ	4
MENU2_RENAME	equ	5
MENU2_DELETE	equ	6
MENU2_ANIMATE	equ	7


serve.menus
	move.w	d3,d4
	and.w	#$1f,d3			menu number

	lsr.w	#5,d4
	and.w	#$3f,d4			menu item number

	IFNE	DEBUG
	move.w	d3,.menu
	move.w	d4,.menu.item
	DEBUGW	<Menu : >,.menu
	DEBUGW	<Menu item : >,.menu.item
	ENDC

	cmp.w	#MENU1,d3
	beq.s	serve.menu1

	cmp.w	#MENU2,d3
	beq.s	serve.menu2
	rts


.menu	dc.w	0
.menu.item	dc.w	0


serve.menu1
	cmp.w	#MENU1_LOADBANK,d4
	bne.s	.item1
	bra	load.SOD.bank

.item1	cmp.w	#MENU1_OPENBANK,d4
	bne.s	.item2
	bra	open.SOD.bank

.item2	cmp.w	#MENU1_SAVEBANK,d4
	bne.s	.item3
	bra	save.SOD.bank

.item3	cmp.w	#MENU1_LOADDIR,d4
	bne.s	.item4
	bra.s	.done

.item4	cmp.w	#MENU1_OPENDIR,d4
	bne.s	.item5
	bra.s	.done

.item5	cmp.w	#MENU1_SAVEDIR,d4
	bne.s	.item6
	bra.s	.done

.item6	cmp.w	#MENU1_CLEAR,d4
	bne.s	.item7
	bra	clear.SOD.data

.item7	cmp.w	#MENU1_QUIT,d4
	bne.s	.done
	st	SOD.quit.request

.done	rts


serve.menu2
	cmp.w	#MENU2_3DVIEW,d4
	bne.s	.item1
	bra	_3D.view

.item1	cmp.w	#MENU2_NEW,d4
	bne.s	.item2
	bra	new.SOD.object

.item2	cmp.w	#MENU2_LOAD,d4
	bne.s	.item3
	IFEQ	IPHASE_LOAD
	bra	load.binary.object
	ELSE
	bra	load.iphase.objects
	ENDC

.item3	cmp.w	#MENU2_OPEN,d4
	bne.s	.item4
	IFEQ	IPHASE_LOAD
	bra	open.binary.object
	ELSE
	bra.s	.done
	ENDC

.item4	cmp.w	#MENU2_SAVE,d4
	bne.s	.item5
	bra	save.binary.object

.item5	cmp.w	#MENU2_RENAME,d4
	bne.s	.item6
	bra	rename.current.SOD.object

.item6	cmp.w	#MENU2_DELETE,d4
	bne.s	.item7
	bra.s	.done

.item7	cmp.w	#MENU2_ANIMATE,d4
	bne.s	.done
	nop

.done	rts


****************************************


allocate.all.SOD.mem
	moveq	#0,d7
	move.w	total.SOD.objects(pc),d6
	beq.s	.done
	lsl.w	#2,d6

.loop	CHECK	7,allocate.SOD.object.mem,d6-d7
	bmi.s	.error

	addq.w	#4,d7			next longword ptr
	cmp.w	d6,d7
	bne.s	.loop

.done	moveq	#1,d0
	rts

.error	moveq	#-1,d0
	rts


****************************************


allocate.extra.SOD.mem

* d0.w = required number of extra objects

	move.w	total.SOD.objects(pc),d6
	move.w	d6,d7
	lsl.w	#2,d7
	add.w	d0,d6
	move.w	d6,total.SOD.objects
	lsl.w	#2,d6

.loop	CHECK	8,allocate.SOD.object.mem,d6-d7
	bmi.s	.error

	addq.w	#4,d7			next longword ptr
	cmp.w	d6,d7
	bne.s	.loop

.done	moveq	#1,d0
	rts

.error	moveq	#-1,d0
	rts


****************************************


allocate.SOD.object.mem
	lea	SOD.object.ptrs(pc),a4
	move.l	#OBJECT_DEFINITION_SIZE,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	CALLEXEC AllocMem
	move.l	d0,(a4,d7.w)		save SOD object ptr
	beq.s	.error

.done	moveq	#1,d0
	rts

.error	ERROR	<  Out of memory>

	moveq	#-1,d0
	rts


****************************************


deallocate.all.SOD.mem
	moveq	#0,d7
	move.w	total.SOD.objects(pc),d6
	beq.s	.done
	lsl.w	#2,d6

.loop	CHECK	9,deallocate.SOD.object.mem,d6-d7
	addq.w	#4,d7			next longword ptr
	cmp.w	d6,d7
	bne.s	.loop

	clr.w	total.SOD.objects

.done	rts


****************************************


deallocate.SOD.object.mem
	lea	SOD.object.ptrs(pc),a4
	move.l	(a4,d7.w),d4		get SOD object ptr
	beq.s	.done			if non-zero then de-allocate mem

	move.l	d4,a1
	move.l	#OBJECT_DEFINITION_SIZE,d0
	CALLEXEC FreeMem

	clr.l	(a4,d7.w)		clear ptr

.done	rts


****************************************


store.current.SOD.object
	move.w	current.SOD.object(pc),d0
	subq.w	#1,d0
	lsl.w	#2,d0
	lea	SOD.object.ptrs(pc),a0
	move.l	(a0,d0.w),a0

	move.w	total.coords(pc),OBJECT_TOTAL_COORDS(a0)
	move.w	total.components(pc),OBJECT_TOTAL_COMPONENTS(a0)

	move.b	SOD.object.modified,OBJECT_MODIFIED(a0)
	rts


****************************************


set.current.SOD.object
	move.w	current.SOD.object(pc),d4
	subq.w	#1,d4
	lsl.w	#2,d4
	lea	SOD.object.ptrs(pc),a4
	move.l	(a4,d4.w),a4

* Store program name plus object name as current screen title

	lea	default.screen.title(pc),a0
	lea	current.screen.title(pc),a1
	move.l	a1,a2
	bsr	copy.text
	move.b	#' ',(a1)+		separate the two names
	move.b	#'-',(a1)+
	move.b	#'-',(a1)+
	move.b	#' ',(a1)+
	lea	OBJECT_NAME(a4),a0
	moveq	#OBJECT_NAME_LENGTH-1,d0
.copy	move.b	(a0)+,(a1)+		append object name
	dbeq	d0,.copy
	beq.s	.set
	clr.b	(a1)

.set	moveq	#WINDOWS-1,d3
	lea	window.ptrs(pc),a3
.loop	move.l	(a3)+,a0		next window ptr
	move.w	#-1,a1
	CALLINT	SetWindowTitles		set screen title for all windows
	dbra	d3,.loop

	lea	OBJECT_COORDS(a4),a3
	move.l	a3,coord.memory
	lea	OBJECT_COMPONENTS(a4),a3
	move.l	a3,component.memory

	move.w	OBJECT_TOTAL_COORDS(a4),total.coords
	move.w	OBJECT_TOTAL_COMPONENTS(a4),total.components

	move.b	OBJECT_MODIFIED(a4),SOD.object.modified

	bsr	refresh.consoles
	bsr	refresh.plan.views
	rts


****************************************


load.SOD.bank
	bsr	deallocate.all.SOD.mem
	bsr	deallocate.all.3D.mem

	moveq	#FREQ_LOAD,d7
	moveq	#FREQ_BANK,d6
	bsr	request.file.name
	bmi.s	.done

	bsr	open.file.name.for.read
	bmi.s	.done

* read object count, plus name and totals for first object

	moveq	#2+OBJECT_NAME_LENGTH+4,d3
	bsr	read.file.memory
	bmi	read.SOD.bank.close
	move.l	file.memory(pc),a0
	move.w	(a0)+,total.SOD.objects

	move.l	a0,-(sp)
	bsr	allocate.all.SOD.mem
	move.l	(sp)+,a0
	bmi	read.SOD.bank.close

* read each object's data in turn

	moveq	#0,d7
	bsr	read.SOD.bank.data

	move.w	#1,current.SOD.object
	bsr	set.current.SOD.object

.done	rts


****************************************


open.SOD.bank
	moveq	#FREQ_OPEN,d7
	moveq	#FREQ_BANK,d6
	bsr	request.file.name
	bmi.s	.done

	bsr	open.file.name.for.read
	bmi.s	.done

* read object count, plus name and totals for first object

	moveq	#2+OBJECT_NAME_LENGTH+4,d3
	bsr	read.file.memory
	bmi	read.SOD.bank.close
	move.l	file.memory(pc),a0
	move.w	(a0)+,d0

* check there is room for extra objects

	CHECK	10,check.space.for.extra.objects,d0
	bmi	read.SOD.bank.close

	move.w	total.SOD.objects(pc),d7
	move.w	d7,d6
	addq.w	#1,d6
	move.w	d6,first.opened.object

	movem.l	d7/a0,-(sp)
	bsr	allocate.extra.SOD.mem
	movem.l	(sp)+,d7/a0
	bmi	read.SOD.bank.close

* read each object's data in turn

	lsl.w	#2,d7
	bsr	read.SOD.bank.data

	bsr	store.current.SOD.object
	move.w	first.opened.object(pc),current.SOD.object
	bsr	set.current.SOD.object

.done	rts


****************************************


read.SOD.bank.data

* d7.w = offset for first SOD object ptr to be used

	move.w	total.SOD.objects(pc),d6
	lsl.w	#2,d6
	lea	SOD.object.ptrs(pc),a2
	move.l	file.memory(pc),a4

.loop	move.l	(a2,d7.w),a3		get SOD object ptr

.name	lea	OBJECT_NAME(a3),a1	copy object name
	REPT	(OBJECT_NAME_LENGTH/4)
	move.l	(a0)+,(a1)+
	ENDR

	move.w	(a0)+,d5		get co-ord count
	move.w	d5,OBJECT_TOTAL_COORDS(a3)

	move.w	(a0),d4			get component count
	move.w	d4,OBJECT_TOTAL_COMPONENTS(a3)

	st	OBJECT_MODIFIED(a3)

* read object co-ords and components, plus name and totals for next object

	move.w	d5,d3
	mulu	#COORD_SIZE,d3
	move.w	d4,d2
	mulu	#COMPONENT_SIZE,d2
	add.l	d2,d3
	add.l	#OBJECT_NAME_LENGTH+4,d3
	CHECK	11,read.file.memory,d4-d7/a2-a4
	bmi	read.SOD.bank.close
	move.l	a4,a0

.coords	subq.w	#1,d5
	bmi.s	.components
	lea	OBJECT_COORDS(a3),a1	copy object co-ords
.copy1
	REPT	(COORD_SIZE/2)
	move.w	(a0)+,(a1)+
	ENDR
	dbra	d5,.copy1

.components
	subq.w	#1,d4
	bmi.s	.next
	lea	OBJECT_COMPONENTS(a3),a1	copy object components
.copy2
	REPT	(COMPONENT_SIZE/2)
	move.w	(a0)+,(a1)+
	ENDR
	dbra	d4,.copy2

.next	addq.w	#4,d7			next longword ptr
	cmp.w	d6,d7
	bne	.loop

* close input file

read.SOD.bank.close
	move.l	file.handle(pc),d1
	CALLDOS	Close
	rts


****************************************


save.SOD.bank
	bsr	store.current.SOD.object

	move.w	total.SOD.objects(pc),d0
	beq	.error

	moveq	#FREQ_SAVE,d7
	moveq	#FREQ_BANK,d6
	bsr	request.file.name
	bmi	.done

	bsr	open.file.name.for.write
	bmi	.done

* write object count

	move.l	file.memory(pc),a0
	move.w	total.SOD.objects(pc),(a0)
	moveq	#2,d3
	bsr	write.file.memory
	bmi	.close

* write each object's data in turn

	moveq	#0,d7
	move.w	total.SOD.objects(pc),d6
	lsl.w	#2,d6
	lea	SOD.object.ptrs(pc),a2
	move.l	file.memory(pc),a4

.loop	move.l	a4,a0
	move.l	(a2,d7.w),a3		get SOD object ptr

.name	lea	OBJECT_NAME(a3),a1	copy object name
	REPT	(OBJECT_NAME_LENGTH/4)
	move.l	(a1)+,(a0)+
	ENDR

	move.w	OBJECT_TOTAL_COORDS(a3),d5	copy co-ord count
	move.w	d5,(a0)+

	move.w	OBJECT_TOTAL_COMPONENTS(a3),d4	copy component count
	move.w	d4,(a0)+

.coords	subq.w	#1,d5
	bmi.s	.components
	lea	OBJECT_COORDS(a3),a1	copy object co-ords
.copy1
	REPT	(COORD_SIZE/2)
	move.w	(a1)+,(a0)+
	ENDR
	dbra	d5,.copy1

.components
	subq.w	#1,d4
	bmi.s	.write
	lea	OBJECT_COMPONENTS(a3),a1	copy object components
.copy2
	REPT	(COMPONENT_SIZE/2)
	move.w	(a1)+,(a0)+
	ENDR
	dbra	d4,.copy2

.write	move.l	a0,d3
	sub.l	a4,d3
	CHECK	12,write.file.memory,d6-d7/a2/a4
	bmi.s	.close

	addq.w	#4,d7			next longword ptr
	cmp.w	d6,d7
	bne	.loop

* close output file

.close	move.l	file.handle(pc),d1
	CALLDOS	Close

.done	rts


.error	ERROR	<  No objects to save>
	rts


****************************************


FREQ_LOAD	equ	0
FREQ_OPEN	equ	1
FREQ_SAVE	equ	2

FREQ_ANY	equ	0
FREQ_BANK	equ	1

FILE_NAME_LENGTH	equ	110


request.file.name

* d7 = function (FREQ_LOAD / FREQ_OPEN / FREQ_SAVE)
* d6 = file type (FREQ_ANY / FREQ_BANK (i.e. #?.sod))

	move.l	#RT_FILEREQ,d0		initialise file requester
	sub.l	a0,a0
	CALLRT	AllocRequestA
	move.l	d0,file.req
	beq	.error1

	move.l	#file.req.dir,d1
	move.l	#FILE_NAME_LENGTH,d2
	CALLDOS	GetCurrentDirName

	lea	file.req.tags1(pc),a0
	cmp.w	#FREQ_BANK,d6
	beq.s	.bank
	lea	file.req.tags2(pc),a0
.bank	move.l	file.req(pc),a1
	CALLRT	ChangeReqAttrA

	move.l	window1(pc),file.req.window
	move.l	#FREQF_PATGAD,d0
	cmp.w	#FREQ_SAVE,d7
	bne.s	.flags
	or.l	#FREQF_SAVE,d0

.flags	move.l	d0,file.req.flags
	lea	file.req.tags3(pc),a0
	move.l	file.req(pc),a1
	lea	file.name(pc),a2
	clr.b	(a2)
	lsl.w	#2,d7
	lea	file.req.prompts(pc),a3
	move.l	(a3,d7.w),a3

.freq	CALLRT	FileRequestA		request file name from user
	tst.l	d0
	beq	.error2

	move.l	file.req(pc),a3
	move.l	rtfi_Dir(a3),d1
	CALLDOS	SetCurrentDirName

	move.l	rtfi_Dir(a3),a0
	lea	file.name(pc),a1
	lea	full.file.name(pc),a2

.nextd	move.b	(a0)+,(a2)+		combine directory and file name
	bne.s	.nextd
	subq.w	#1,a2

	cmp.b	#':',-1(a2)
	beq.s	.nextf
	move.b	#'/',(a2)+

.nextf	move.b	(a1)+,(a2)+
	bne.s	.nextf

.done	move.l	file.req(pc),a1
	CALLRT	FreeRequest

	DEBUGS	<request.file.name : >,#full.file.name

	moveq	#1,d0
	rts

.error2	DEBUGM	<request.file.name : None selected>

	move.l	file.req(pc),a1
	CALLRT	FreeRequest

.error1	moveq	#-1,d0
	rts


file.req.tags1
	dc.l	RTFI_MatchPat,file.req.pat
file.req.tags2
	dc.l	RTFI_Dir,file.req.dir
	dc.l	TAG_END


file.req.dir	ds.b	FILE_NAME_LENGTH

file.req.pat	dc.b	'#?.sod',0
	even


file.req.tags3
	dc.l	RTFI_Flags
file.req.flags
	dc.l	FREQF_PATGAD!FREQF_SAVE
	dc.l	RTFI_Height,230
	dc.l	RT_ReqPos,REQPOS_CENTERSCR
	dc.l	RT_TopOffset,6
	dc.l	RT_Window
file.req.window
	dc.l	0
	dc.l	TAG_END


file.name	ds.b	FILE_NAME_LENGTH


full.file.name	ds.b	256


file.req.prompts
	dc.l	req.load.text
	dc.l	req.open.text
	dc.l	req.save.text


req.load.text	dc.b	'Select File to Load',0
	even

req.open.text	dc.b	'Select File to Open',0
	even

req.save.text	dc.b	'Select File to Save As',0
	even


****************************************


examine.file.name
	move.l	#full.file.name,d1
	move.l	#ACCESS_READ,d2
	CALLDOS	Lock
	move.l	d0,file.handle
	beq.s	.error1

	move.l	d0,d1
	move.l	file.memory(pc),d2
	CALLDOS	Examine
	tst.l	d0
	beq.s	.error2

	move.l	file.handle(pc),d1
	CALLDOS	UnLock

.done	moveq	#1,d0
	rts

.error2	move.l	file.handle(pc),d1
	CALLDOS	UnLock

.error1	moveq	#-1,d0
	rts


****************************************


open.file.name.for.read
	move.l	#full.file.name,d1
	move.l	#MODE_OLDFILE,d2
	CALLDOS	Open
	move.l	d0,file.handle
	beq	.error

.done	moveq	#1,d0
	rts

.error	ERROR	<  Could not open input file>
	moveq	#-1,d0
	rts


****************************************


open.file.name.for.write
	move.l	#full.file.name,d1
	move.l	#MODE_NEWFILE,d2
	CALLDOS	Open
	move.l	d0,file.handle
	beq	.error

.done	moveq	#1,d0
	rts

.error	ERROR	<  Could not open output file>
	moveq	#-1,d0
	rts


****************************************


read.file.memory

* d3.l = byte length to be read

	move.l	file.handle(pc),d1
	move.l	file.memory(pc),d2
	CALLDOS	Read
	tst.l	d0
	bmi.s	.error

.done	moveq	#1,d0
	rts

.error	ERROR	<  Could not read input file>
	moveq	#-1,d0
	rts


****************************************


write.file.memory
	move.l	file.memory(pc),d2

write.memory

* d2.l = ptr to memory to be written
* d3.l = byte length to be written

	move.l	file.handle(pc),d1
	CALLDOS	Write
	tst.l	d0
	bmi.s	.error

.done	moveq	#1,d0
	rts

.error	ERROR	<  Could not write output file>
	moveq	#-1,d0
	rts


****************************************


clear.SOD.data
	bsr	deallocate.all.SOD.mem
	bsr	deallocate.all.3D.mem

allocate.initial.object.mem
	move.w	#1,total.SOD.objects
	bsr	allocate.all.SOD.mem
	bmi.s	.error

	move.w	#1,current.SOD.object
	lea	default.object.name(pc),a0
	move.l	SOD.object.ptrs(pc),a1
	lea	OBJECT_NAME(a1),a1
.copy	move.b	(a0)+,(a1)+
	bne.s	.copy
	bra	set.current.SOD.object

.error	st	SOD.quit.request
	rts


****************************************


_3D.view
	bsr.s	_3D.view.initialisation
	bsr	set.current.3D.object

	sf	hold.3D.object
	sf	colour.selection.disabled
	bsr	_3D.view.main

	bsr	set.current.SOD.object
	rts


****************************************


_3D.view.initialisation

* build up 3D object definitions for all valid objects,
* for use by the 3D view routines

	moveq	#0,d7
	move.w	total.SOD.objects(pc),d6
	beq	.error

	CHECK	13,store.current.SOD.object,d6-d7

	lsl.w	#2,d6
	lea	SOD.object.ptrs(pc),a2

.loop	move.l	(a2,d7.w),a3		get SOD object ptr
	move.b	OBJECT_MODIFIED(a3),d3	test if object was modified
	beq	.next
	sf	OBJECT_MODIFIED(a3)

	CHECK	14,deallocate.3D.object.mem,d6-d7/a2-a3

	CHECK	15,check.object.definition,d6-d7/a2-a3
	bmi	.next

	CHECK	16,calc.3D.object.mem.without.optimisations,d6-d7/a2-a3
	CHECK	17,allocate.3D.object.mem,d6-d7/a2-a3
	bmi.s	.next

	CHECK	18,build.3D.object.without.optimisations,d6-d7/a2-a3
	bpl.s	.next
	CHECK	19,deallocate.3D.object.mem,d6-d7/a2-a3

.next	addq.w	#4,d7			next longword ptr
	cmp.w	d6,d7
	bne	.loop
	rts

.error	ERROR	<  No objects to view>
	rts


****************************************



deallocate.all.3D.mem
	moveq	#0,d7

.loop	CHECK	20,deallocate.3D.object.mem,d7
	addq.w	#4,d7			next longword ptr
	cmp.w	#MAX_OBJECTS*4,d7
	bne.s	.loop
	rts


****************************************


deallocate.3D.object.mem
	lea	_3D.object.ptrs(pc),a4
	lea	_3D.object.sizes(pc),a5
	move.l	(a4,d7.w),d4		get 3D object ptr
	beq.s	.done			if non-zero then de-allocate mem

	move.l	d4,a1
	move.l	(a5,d7.w),d0
	CALLEXEC FreeMem

	clr.l	(a4,d7.w)		clear ptr
	clr.l	(a5,d7.w)		clear size

.done	rts


****************************************


check.object.definition
	move.w	OBJECT_TOTAL_COMPONENTS(a3),d5	get component count
	beq.s	.error

	bsr.s	check.coords.used.are.rotated
	bmi.s	.error

	bsr	check.object.definition.ends
	bmi.s	.error

	bsr	check.nothing.skips.to.itself
	bmi.s	.error

.done	moveq	#1,d0
	rts

.error	moveq	#-1,d0
	rts


****************************************


check.coords.used.are.rotated
	bsr	clear.rotated.flags

	move.w	OBJECT_TOTAL_COMPONENTS(a3),d5	get component count
	beq.s	.done
	subq.w	#1,d5
	lea	OBJECT_COMPONENTS(a3),a4

.loop	move.w	TYPE(a4),d4		search object definition for rotates
	cmp.w	#ROTATE,d4
	bne.s	.other

.rotate	CHECK	21,set.rotated.flags,d5/a3-a4
	bra.s	.next

.other	CHECK	22,check.rotated.flags,d5/a3-a4
	bmi.s	.error

.next	lea	COMPONENT_SIZE(a4),a4	next component
	dbra	d5,.loop

.done	moveq	#1,d0
	rts

.error	ERROR	<  Co-ord not rotated>
	moveq	#-1,d0
	rts


****************************************


clear.rotated.flags
	moveq	#0,d0
	move.w	#MAX_COORDS-1,d1
	lea	coord.rotated.flags(pc),a0

.clear	move.b	d0,(a0)+		clear all co-ord rotated flags
	dbra	d1,.clear
	rts


****************************************


set.rotated.flags
	move.w	COORDS(a4),d0		first rotated co-ord
	move.w	COORDS+2(a4),d1		last rotated co-ord
	sub.w	d0,d1
	bmi.s	.error
	subq.w	#1,d0
	lea	coord.rotated.flags(pc),a0
	lea	(a0,d0.w),a0

.loop	st	(a0)+			set flags of rotated co-ords
	dbra	d1,.loop
	rts

.error	ERROR	<  dbra error 3>
	rts


****************************************


check.rotated.flags
	move.w	NUM_COORDS(a4),d4
	subq.w	#1,d4
	bmi.s	.done

	lea	COORDS(a4),a5
	lea	coord.rotated.flags(pc),a0

.loop	move.w	(a5)+,d3		get next co-ord
	bpl.s	.plus
	neg.w	d3		if this co-ord is used for orientation check

.plus	subq.w	#1,d3
	tst.b	(a0,d3.w)		test co-ord rotated flag
	dbeq	d4,.loop
	beq.s	.error			if zero then not rotated

.done	moveq	#1,d0
	rts

.error	moveq	#-1,d0
	rts


****************************************


check.object.definition.ends
	move.w	OBJECT_TOTAL_COMPONENTS(a3),d5	get component count
	move.w	d5,d4
	beq.s	.done
	subq.w	#1,d5
	lea	OBJECT_COMPONENTS(a3),a4

* check last component is an END

	move.w	d5,d1
	mulu	#COMPONENT_SIZE,d1
	lea	(a4,d1.l),a1		ptr to last component
	cmp.w	#END,TYPE(a1)
	bne.s	.error

* check that all skips are to positions
* that are not after the last component

	lea	SKIP(a4),a4
.loop	cmp.w	(a4),d4
	lea	COMPONENT_SIZE(a4),a4	next component
	dblt	d5,.loop
	blt.s	.error

.done	moveq	#1,d0
	rts

.error	ERROR	<  Component path must end>
	moveq	#-1,d0
	rts


****************************************


check.nothing.skips.to.itself
	move.w	OBJECT_TOTAL_COMPONENTS(a3),d5	get component count
	beq.s	.done
	subq.w	#1,d5
	lea	OBJECT_COMPONENTS(a3),a4

	moveq	#1,d4			position of first component
	lea	SKIP(a4),a4
.loop	cmp.w	(a4),d4
	beq.s	.error
	lea	COMPONENT_SIZE(a4),a4	next component
	addq.w	#1,d4
	dbra	d5,.loop

.done	moveq	#1,d0
	rts

.error	ERROR	<  Component skips to itself>
	moveq	#-1,d0
	rts


****************************************


calc.3D.object.mem.with.optimisations
	st	optimise
	move.w	#NOCLR,current.fillcol
	move.w	#NOCLR,current.vectcol
	bra.s	calc.3D.object.mem

calc.3D.object.mem.without.optimisations
	sf	optimise

calc.3D.object.mem

* also stores the offset of each component from the 3D object start
*
* returns with d0.l = size of 3D object (bytes)

	moveq	#0,d2
	move.w	OBJECT_TOTAL_COMPONENTS(a3),d5	get component count
	beq.s	.done
	subq.w	#1,d5
	lea	OBJECT_COMPONENTS(a3),a4
	lea	_3D.component.offsets(pc),a5

.loop	move.l	d2,(a5)+		save current component's offset
	CHECK	23,get.component.size,d2/d5/a3-a5
	add.l	d0,d2
	lea	COMPONENT_SIZE(a4),a4	next component
	dbra	d5,.loop

.done	move.l	d2,d0
	rts


optimise	dc.b	0
	even


current.fillcol	dc.w	0
current.vectcol	dc.w	0


****************************************


get.component.size

* a4 = ptr to current component
*
* returns with d0.l = 3D size of this component

	move.w	TYPE(a4),d4

.check.circle
	cmp.w	#CIRCLE,d4
	bne.s	.check.end

	moveq	#8,d0
	bsr	.add.fillcol.size
	bra	.done

.check.end
	cmp.w	#END,d4
	bne.s	.check.gosub

	moveq	#2,d0

	move.w	#NOCLR,current.fillcol
	move.w	#NOCLR,current.vectcol
	bra.s	.done

.check.gosub
	cmp.w	#GOSUB,d4
	bne.s	.check.goto

	moveq	#4,d0

	move.w	#NOCLR,current.fillcol
	move.w	#NOCLR,current.vectcol
	bra.s	.done

.check.goto
	cmp.w	#GOTO,d4
	bne.s	.check.polygon

	moveq	#4,d0
	bra.s	.done

.check.polygon
	cmp.w	#POLYGON,d4
	bne.s	.check.rotate

	moveq	#4,d0
	cmp.w	#-1,SKIP(a4)		test for 'NCHK'
	beq.s	.nchk
	addq.l	#8,d0

.nchk	moveq	#0,d4
	move.w	NUM_COORDS(a4),d4
	add.w	d4,d4
	add.l	d4,d0
	bsr.s	.add.fillcol.size
	bra.s	.done

.check.rotate
	cmp.w	#ROTATE,d4
	bne.s	.check.vector

	moveq	#6,d0
	moveq	#0,d4
	move.w	COORDS+2(a4),d4
	sub.w	COORDS(a4),d4
	addq.w	#1,d4
	mulu	#COORD_SIZE,d4
	add.l	d4,d0
	bra.s	.done

.check.vector
	cmp.w	#VECTOR,d4
	bne.s	.check.zpri

	moveq	#6,d0
	bsr.s	.add.vectcol.size
	bra.s	.done

.check.zpri
	cmp.w	#ZPRI,d4
	bne.s	.done

	moveq	#8,d0

.done	rts


.add.fillcol.size
	tst.b	optimise
	beq.s	.add1

	move.w	CLR(a4),d4
	cmp.w	#UNKNCLR,d4
	beq.s	.add1

	cmp.w	current.fillcol(pc),d4
	beq.s	.done1
	move.w	d4,current.fillcol

.add1	addq.l	#4,d0

.done1	rts


.add.vectcol.size
	tst.b	optimise
	beq.s	.add2

	move.w	CLR(a4),d4
	cmp.w	#UNKNCLR,d4
	beq.s	.add2

	cmp.w	current.vectcol(pc),d4
	beq.s	.done2
	move.w	d4,current.vectcol

.add2	addq.l	#4,d0

.done2	rts


****************************************


allocate.3D.object.mem

* d0 = memory size

	lea	_3D.object.ptrs(pc),a4
	lea	_3D.object.sizes(pc),a5

	move.l	d0,(a5,d7.w)		save 3D object size
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	CALLEXEC AllocMem
	move.l	d0,(a4,d7.w)		save 3D object ptr
	beq.s	.error

.done	moveq	#1,d0
	rts

.error	clr.l	(a5,d7.w)		clear size
	ERROR	<  Out of memory>

	moveq	#-1,d0
	rts


****************************************


build.3D.object.with.optimisations
	st	optimise
	move.w	#NOCLR,current.fillcol
	move.w	#NOCLR,current.vectcol
	bra.s	build.3D.object

build.3D.object.without.optimisations
	sf	optimise

build.3D.object
	lea	_3D.object.ptrs(pc),a4
	move.l	(a4,d7.w),a0		get 3D object ptr
	move.l	a0,d5
	lea	_3D.component.offsets(pc),a5

	move.w	OBJECT_TOTAL_COMPONENTS(a3),d3	get component count
	beq	.done
	subq.w	#1,d3
	lea	OBJECT_COMPONENTS(a3),a4

.loop	move.w	TYPE(a4),d4

.check.circle
	cmp.w	#CIRCLE,d4
	bne.s	.check.end

	bsr	build.fill.colour.offset

	move.w	#_3D_CIRCLE,(a0)+
	move.w	COORDS(a4),d0
	bsr	build.coord.offset

	move.l	COORDS+2(a4),(a0)+
	bra	.next

.check.end
	cmp.w	#END,d4
	bne.s	.check.gosub

	move.w	#NOCLR,current.fillcol
	move.w	#NOCLR,current.vectcol

	move.w	#_3D_END,(a0)+
	bra	.next

.check.gosub
	cmp.w	#GOSUB,d4
	bne.s	.check.goto

	move.w	#NOCLR,current.fillcol
	move.w	#NOCLR,current.vectcol

	move.w	#_3D_GOSUB,(a0)+
	bsr	build.skip.offset
	bmi	.error
	bra	.next

.check.goto
	cmp.w	#GOTO,d4
	bne.s	.check.polygon

	move.w	#_3D_GOTO,(a0)+
	bsr	build.skip.offset
	bmi	.error
	bra	.next

.check.polygon
	cmp.w	#POLYGON,d4
	bne.s	.check.rotate

	bsr	build.fill.colour.offset

	cmp.w	#-1,SKIP(a4)		test for 'NCHK'
	beq.s	.nchk

	move.w	#_3D_POLYGON,(a0)+
	moveq	#MIN_POLY_SIDES-1,d1
	lea	COORDS(a4),a1

.loop2	move.w	(a1)+,d0
	bpl.s	.loop2
	neg.w	d0			store co-ords that are used for
	bsr	build.coord.offset	polygon orientation check
.next2	dbra	d1,.loop2

	bsr	build.skip.offset
	bmi	.error
	bra.s	.coords

.nchk	move.w	#_3D_POLYDRAW,(a0)+

.coords	move.w	NUM_COORDS(a4),d1
	move.w	d1,(a0)+
	subq.w	#1,d1
	bmi	.error2
	lea	COORDS(a4),a1

.loop3	move.w	(a1)+,d0
	bpl.s	.plus
	neg.w	d0
.plus	bsr	build.coord.offset
	dbra	d1,.loop3
	bra.s	.next

.check.rotate
	cmp.w	#ROTATE,d4
	bne.s	.check.vector

	move.w	#_3D_ROTATE,(a0)+
	move.w	COORDS(a4),d0
	move.w	d0,d1
	bsr	build.coord.offset

	move.w	COORDS+2(a4),d0
	sub.w	d1,d0
	bmi	.error3
	move.w	d0,(a0)+

	lea	OBJECT_COORDS(a3),a1
	subq.w	#1,d1
	mulu	#COORD_SIZE,d1
	add.l	d1,a1
.copy
	REPT	(COORD_SIZE/2)
	move.w	(a1)+,(a0)+
	ENDR
	dbra	d0,.copy
	bra.s	.next

.check.vector
	cmp.w	#VECTOR,d4
	bne.s	.check.zpri

	bsr	build.line.colour.offset

	move.w	#_3D_VECTOR,(a0)+
	move.w	COORDS(a4),d0
	bsr	build.coord.offset
	move.w	COORDS+2(a4),d0
	bsr	build.coord.offset
	bra.s	.next

.check.zpri
	cmp.w	#ZPRI,d4
	bne.s	.next

	move.w	#_3D_ZPRI,(a0)+
	move.w	COORDS(a4),d0
	bsr	build.coord.offset
	move.w	COORDS+2(a4),d0
	bsr	build.coord.offset

	bsr	build.skip.offset
	bmi.s	.error

.next	lea	COMPONENT_SIZE(a4),a4	next component
	dbra	d3,.loop

.done	moveq	#1,d0
	rts

.error	moveq	#-1,d0
	rts

.error2	ERROR	<  dbra error 4>
	rts

.error3	ERROR	<  dbra error 5>
	rts


****************************************


build.fill.colour.offset
	move.w	CLR(a4),d0
	tst.b	optimise
	beq.s	.build1

	cmp.w	current.fillcol(pc),d0
	beq.s	.done

.build1	move.w	#_3D_FILLCOL,(a0)+
	cmp.w	#UNKNCLR,d0
	beq.s	.unkn.clr

	move.w	d0,current.fillcol

	lsl.w	#2,d0
	move.w	d0,(a0)+
.done	rts

.unkn.clr
	bsr	random.word
	lsl.w	#2,d0
	move.w	d0,(a0)+
	rts


****************************************


build.line.colour.offset
	move.w	CLR(a4),d0
	tst.b	optimise
	beq.s	.build2

	cmp.w	current.vectcol(pc),d0
	beq.s	.done

.build2	move.w	#_3D_VECTCOL,(a0)+
	cmp.w	#UNKNCLR,d0
	beq.s	.unkn.clr

	move.w	d0,current.vectcol

	lsl.w	#3,d0
	move.w	d0,(a0)+
.done	rts

.unkn.clr
	bsr	random.word
	lsl.w	#3,d0
	move.w	d0,(a0)+
	rts


****************************************


build.coord.offset

* d0.w = co-ord position

	subq.w	#1,d0
	mulu	#COORD_SIZE,d0

	cmp.w	#ZPRI,d4
	bne.s	.other

	addq.w	#4,d0			zpri wants offset for z co-ord

.other	move.w	d0,(a0)+
	rts


****************************************


build.skip.offset
	move.w	SKIP(a4),d0
	bmi.s	.error

	subq.w	#1,d0
	lsl.w	#2,d0
	move.l	(a5,d0.w),d0
	add.l	d5,d0			address of destination component
	sub.l	a0,d0			offset to destination component

	cmp.w	#POLYGON,d4
	beq.s	.adjust
	cmp.w	#ZPRI,d4
	bne.s	.other

.adjust	subq.l	#2,d0			adjust if polygon or zpri skip

.other	cmp.l	#-32768,d0
	blt.s	.error

	cmp.l	#32767,d0
	bgt.s	.error

	move.w	d0,(a0)+

.done	moveq	#1,d0
	rts

.error	ERROR	<  Skip exceeds allowable range>

	moveq	#-1,d0
	rts


****************************************


random.word
	move.l	a0,-(sp)
	lea	random.value(pc),a0
	move.w	vhposr+$dff000.l,d0	new value
	muls	(a0),d0			multiply by old value
	add.w	#5293,d0		plus a constant
	move.w	d0,(a0)			save new value
	move.l	(sp)+,a0
	and.w	#$f,d0
	rts


random.value	dc.w	0


****************************************


_3D.view.main
	bsr	show.3D.view.screen
	bmi.s	_3D.view.done

_3D.view.loop
;	bsr	mouse.x.y

	movem.w	base.x.angle(pc),d0-d2	get x angle, y angle and z angle
	bsr	calc.sin.cos.values

	move.l	current.3D.object.ptr(pc),a0
	bsr	draw.3D.object

	bsr	update.visible.screen

	sf	vblank.occured
wait.vblank
	tst.b	vblank.occured
	beq.s	wait.vblank

	bsr	clear.current.screen

	bsr	_3D.view.interface
	bsr	_3D.view.colour.selection

	tst.b	_3D.view.quit.request
	beq.s	_3D.view.loop

	bsr	restore.normal.screen

_3D.view.done
	rts


_3D.view.quit.request	dc.b	0
	even


****************************************


RAW_E		equ	$12
RAW_D		equ	$22
RAW_H		equ	$25
RAW_X		equ	$32
RAW_C		equ	$33
RAW_COMMA	equ	$38
RAW_DOT		equ	$39
RAW_ESC		equ	$45


_3D.view.interface
	move.b	raw.key.code(pc),d0
	cmp.b	#RAW_ESC,d0
	bne.s	.check.prev

	IFNE	DEBUG
	DEBUGM	<3D quit>
	ENDC

	st	_3D.view.quit.request
	bra	.done

.check.prev
	cmp.b	#RAW_COMMA,d0		previous object command
	bne.s	.check.next

	IFNE	DEBUG
	DEBUGM	<3D previous object>
	ENDC

	move.w	current.SOD.object(pc),d0
	cmp.w	#1,d0
	ble	.done

	subq.w	#1,current.SOD.object
	bsr	set.current.3D.object
	bra	.done

.check.next
	cmp.b	#RAW_DOT,d0		next object command
	bne.s	.check.x

	IFNE	DEBUG
	DEBUGM	<3D next object>
	ENDC

	move.w	current.SOD.object(pc),d0
	cmp.w	total.SOD.objects(pc),d0
	bge	.done

	addq.w	#1,current.SOD.object
	bsr	set.current.3D.object
	bra	.done

.check.x
	cmp.b	#RAW_X,d0		previous coloured component command
	bne.s	.check.c

	IFNE	DEBUG
	DEBUGM	<3D previous component>
	ENDC

	tst.b	no.coloured.components
	bne	.done

	bsr	restore.current.3D.colour
	bsr	to.previous.coloured.component
	bra	.done

.check.c
	cmp.b	#RAW_C,d0		next coloured component command
	bne.s	.check.h

	IFNE	DEBUG
	DEBUGM	<3D next component>
	ENDC

	tst.b	no.coloured.components
	bne	.done

	bsr	restore.current.3D.colour
	bsr	to.next.coloured.component
	bra	.done

.check.h
	cmp.b	#RAW_H,d0		hold object command
	bne.s	.check.d

	IFNE	DEBUG
	DEBUGM	<3D hold object>
	ENDC

	not.b	hold.3D.object
	bra	.done

.check.d
	cmp.b	#RAW_D,d0		disable colour selection command
	bne.s	.check.e

	IFNE	DEBUG
	DEBUGM	<3D disable selection>
	ENDC

	tst.b	no.coloured.components
	bne.s	.done

	bsr	restore.current.3D.colour
	st	colour.selection.disabled
	bra.s	.done

.check.e
	cmp.b	#RAW_E,d0		enable colour selection command
	bne.s	.done

	IFNE	DEBUG
	DEBUGM	<3D enable selection>
	ENDC

	sf	colour.selection.disabled

.done	clr.b	raw.key.code
	rts


****************************************


restore.current.3D.colour

* set colour of current 3D component (because it
* could have changed due to the flash routine)

	move.w	current.SOD.component(pc),d5
	move.l	current.SOD.object.ptr(pc),a5
	lea	OBJECT_COMPONENTS(a5),a5
	subq.w	#1,d5
	mulu	#COMPONENT_SIZE,d5
	lea	(a5,d5.l),a4		ptr to current component
	bra	set.current.3D.colour


****************************************


_3D.view.colour.selection
	tst.b	no.coloured.components
	bne	.done

	tst.b	colour.selection.disabled
	bne	.done

	tst.b	left.button
	beq.s	.flash

* set current component to user selected colour

	moveq	#0,d0
	moveq	#0,d1
	move.w	colour.x(pc),d0
	move.w	colour.y(pc),d1
	bmi	.done			check mouse was clicked on palette
	cmp.w	#PALETTE_HEIGHT,d1
	bge	.done
	lea	rp(pc),a1
	CALLGRAF ReadPixel		read colour that was selected
	tst.l	d0
	bmi.s	.done

* store colour in SOD object definition

	move.w	current.SOD.component(pc),d5
	move.l	current.SOD.object.ptr(pc),a5
	lea	OBJECT_COMPONENTS(a5),a5
	subq.w	#1,d5
	mulu	#COMPONENT_SIZE,d5
	lea	(a5,d5.l),a4		ptr to current component
	move.w	d0,CLR(a4)

* set colour in 3D object

	st	current.colour.set
	bra	set.current.3D.colour


* flash current component (if it has not been set)

.flash	tst.b	current.colour.set
	bne.s	.done

	addq.w	#1,flash.colour.count
	move.w	flash.colour.count(pc),d0
	and.w	#%111,d0
	bne.s	.done

	move.l	current.3D.object.ptr(pc),a5
	add.l	current.3D.component.offset(pc),a5
	move.w	2(a5),d0
	cmp.w	#_3D_VECTCOL,(a5)
	beq.s	.line

.fill	eor.w	#1<<(_3D_VIEW_DEPTH+1),d0
	bra.s	.set

.line	eor.w	#1<<(_3D_VIEW_DEPTH+2),d0

.set	move.w	d0,2(a5)

.done	rts


****************************************


set.current.3D.colour

* a4 = ptr to current component

	move.l	current.3D.object.ptr(pc),a5
	add.l	current.3D.component.offset(pc),a5
	move.w	CLR(a4),d0
	cmp.w	#UNKNCLR,d0
	beq.s	.done

	cmp.w	#VECTOR,TYPE(a4)
	beq.s	.line

.fill	lsl.w	#2,d0
	bra.s	.set

.line	lsl.w	#3,d0

.set	move.w	d0,2(a5)

.done	rts


****************************************


set.current.3D.object
	st	unknown.colours.only
	sf	no.coloured.components
	move.w	#1,current.SOD.component
	move.l	#0,current.3D.component.offset

	move.w	current.SOD.object(pc),d0
	subq.w	#1,d0
	lsl.w	#2,d0
	lea	SOD.object.ptrs(pc),a1
	move.l	(a1,d0.w),current.SOD.object.ptr

	lea	_3D.object.ptrs(pc),a0
	move.l	(a0,d0.w),d0
	bne.s	.valid			if 3D object does not exist

.blank	move.l	#blank.object,d0	then use 'blank' object
	move.l	d0,current.3D.object.ptr
	st	no.coloured.components
	rts

.valid	move.l	d0,current.3D.object.ptr

* calculate offset to last 3D component

	moveq	#0,d2
	move.l	current.SOD.object.ptr(pc),a5
	move.w	OBJECT_TOTAL_COMPONENTS(a5),d5	get component count
	subq.w	#2,d5
	bmi.s	.done
	lea	OBJECT_COMPONENTS(a5),a4
	sf	optimise

.loop	CHECK	24,get.component.size,d2/d5/a4-a5
	add.l	d0,d2
	lea	COMPONENT_SIZE(a4),a4	next component
	dbra	d5,.loop

.done	move.l	d2,last.3D.component.offset

* find first coloured component

	bsr.s	to.next.coloured.component
	rts


****************************************


to.next.coloured.component
	moveq	#1,d3
	moveq	#0,d1			offset to first 3D component
	bra.s	to.coloured.component

to.previous.coloured.component
	moveq	#-1,d3
	move.l	last.3D.component.offset(pc),d1

to.coloured.component
	sf	optimise
	move.w	current.SOD.component(pc),d7
	move.l	current.SOD.object.ptr(pc),a5
	move.w	OBJECT_TOTAL_COMPONENTS(a5),d6
	lea	OBJECT_COMPONENTS(a5),a5
	move.l	current.3D.component.offset(pc),d2

	move.w	d7,d5
	subq.w	#1,d5
	mulu	#COMPONENT_SIZE,d5
	lea	(a5,d5.l),a4		ptr to current component

	move.w	d6,d5
	subq.w	#1,d5
	mulu	#COMPONENT_SIZE,d5
	lea	(a5,d5.l),a3		ptr to last component

	moveq	#0,d5			counter for components searched


.loop	add.w	d3,d7			next/previous component
	tst.w	d3
	bmi.s	.to.prev


.to.next
	cmp.w	d6,d7
	ble.s	.next.ok		if not after end of components

	moveq	#1,d7			else go to first component
	move.l	d1,d2
	move.l	a5,a4
	bra.s	.search

.next.ok
	CHECK	25,get.component.size,d1-d3/d5-d7/a3-a5
	add.l	d0,d2			get offset to next component
	lea	COMPONENT_SIZE(a4),a4	next component
	bra.s	.search


.to.prev
	cmp.w	#1,d7
	bge.s	.prev.ok		if not before start of components

	move.w	d6,d7			else go to last component
	move.l	d1,d2
	move.l	a3,a4
	bra.s	.search

.prev.ok
	lea	-COMPONENT_SIZE(a4),a4	previous component
	CHECK	26,get.component.size,d1-d3/d5-d7/a3-a5
	sub.l	d0,d2			get offset to previous component


.search	move.w	TYPE(a4),d4

.check.circle
	cmp.w	#CIRCLE,d4
	beq.s	.colour

.check.polygon
	cmp.w	#POLYGON,d4
	beq.s	.colour

.check.vector
	cmp.w	#VECTOR,d4
	bne.s	.next

* coloured component found
* if necessary, check that its colour is unknown

.colour	tst.b	unknown.colours.only
	beq.s	.found			don't check colour is unknown

.check.unkn
	move.w	CLR(a4),d4
	cmp.w	#UNKNCLR,d4
	bne.s	.next

.found	move.w	d7,current.SOD.component
	move.l	d2,current.3D.component.offset
	sf	current.colour.set
	bra.s	.done

* coloured component not found or not unknown, so continue search

.next	addq.w	#1,d5			one more component searched
	cmp.w	d6,d5
	blt	.loop

* if all components were searched for unknown colours but none were found,
* start searching for any coloured components

	tst.b	unknown.colours.only
	bne.s	.search.any

* if this object contains no coloured components at all, flag this and exit

	st	no.coloured.components
	bra.s	.done

.search.any
	sf	unknown.colours.only
	moveq	#0,d5
	bra	.loop

.done	rts


****************************************


new.SOD.object
	moveq	#1,d0
	bsr	check.space.for.extra.objects
	bmi.s	.done

	move.w	total.SOD.objects(pc),d0
	addq.w	#1,d0
	bsr	request.object.name.default
	bmi.s	.done

	move.w	total.SOD.objects(pc),d6
	move.w	d6,d7
	lsl.w	#2,d7
	CHECK	27,allocate.SOD.object.mem,d6
	bmi.s	.done

	CHECK	28,store.current.SOD.object,d6

	addq.w	#1,d6
	move.w	d6,total.SOD.objects
	move.w	d6,current.SOD.object

	bsr	set.current.SOD.object.name

.done	rts


****************************************


request.object.name.default

* d0.w = object number

	lea	name.buffer(pc),a0	set default object name
	lea	name.default(pc),a1
.loop	move.b	(a1)+,(a0)+
	bne.s	.loop
	subq.w	#1,a0
	bsr	word.to.ASCII
	clr.b	(a0)
	bra.s	request.object.name

request.object.name.current
	move.w	current.SOD.object(pc),d0
	subq.w	#1,d0
	lsl.w	#2,d0
	lea	SOD.object.ptrs(pc),a0
	move.l	(a0,d0.w),a1
	lea	OBJECT_NAME(a1),a1
	lea	name.buffer(pc),a0
	moveq	#OBJECT_NAME_LENGTH-1,d0
.copy	move.b	(a1)+,(a0)+		get current object name
	dbeq	d0,.copy
	beq.s	request.object.name
	clr.b	(a0)

request.object.name
	move.l	window1(pc),name.window

	lea	name.tags(pc),a0
	moveq	#OBJECT_NAME_LENGTH,d0
	lea	name.buffer(pc),a1
	lea	name.prompt(pc),a2
	sub.l	a3,a3
	CALLRT	GetStringA		request object name from user
	tst.l	d0
	beq.s	.cancel

.ok	DEBUGS	<request.object.name : >,#name.buffer
	moveq	#1,d0
	rts

.cancel	DEBUGM	<request.object.name : None selected>
	moveq	#-1,d0
	rts


name.tags
	dc.l	RT_ReqPos,REQPOS_CENTERSCR
	dc.l	RT_TopOffset,-60
	dc.l	RT_Window
name.window
	dc.l	0
	dc.l	TAG_END


name.buffer	ds.b	OBJECT_NAME_LENGTH+1
	even

name.default	dc.b	'Object',0
	even

name.prompt	dc.b	'Enter Object Name',0
	even

name.buttons	dc.b	' _Ok ',0
	even


****************************************


rename.current.SOD.object
	bsr	request.object.name.current
	bmi.s	.done
	bsr	set.current.SOD.object.name
.done	rts


****************************************


set.current.SOD.object.name
	move.w	current.SOD.object(pc),d0
	subq.w	#1,d0
	lsl.w	#2,d0
	lea	SOD.object.ptrs(pc),a0
	move.l	(a0,d0.w),a0
	lea	OBJECT_NAME(a0),a0
	lea	name.buffer(pc),a1
	moveq	#OBJECT_NAME_LENGTH-1,d0
.copy	move.b	(a1)+,(a0)+		store object name
	dbeq	d0,.copy
	bne.s	.done

	subq.w	#1,d0
	bmi.s	.done
.clear	clr.b	(a0)+			clear rest of object name
	dbra	d0,.clear

.done	bsr	set.current.SOD.object
	rts


****************************************


check.space.for.extra.objects

* d0.w = required number of extra objects
*
* returns 1 if there is enough space for the extra objects
* returns -1 otherwise
*
* uses d1-d2

	move.w	#MAX_OBJECTS,d2
	sub.w	total.SOD.objects(pc),d2
	cmp.w	d2,d0
	bgt.s	.bad.number

.good.number
	moveq	#1,d1
	rts

.bad.number
	ERROR	<  Not enough space for extra object(s)>
	moveq	#-1,d1
	rts


****************************************


	IFEQ	IPHASE_LOAD


open.binary.object
	moveq	#1,d0
	bsr	check.space.for.extra.objects
	bmi.s	.done

	move.w	total.SOD.objects(pc),d6
	move.w	d6,d7
	lsl.w	#2,d7
	CHECK	29,allocate.SOD.object.mem,d6
	bmi.s	.done

	CHECK	30,store.current.SOD.object,d6

	addq.w	#1,d6
	move.w	d6,total.SOD.objects
	move.w	d6,current.SOD.object

	moveq	#FREQ_OPEN,d7
	bra.s	load.open.binary.object

.done	rts


load.binary.object
	moveq	#FREQ_LOAD,d7

load.open.binary.object
	moveq	#FREQ_ANY,d6
	bsr	request.file.name
	bmi.s	.done

* examine object, check size is within allocated file memory size

	bsr	examine.file.name
	bmi.s	.done
	move.l	file.memory(pc),a5
	move.l	fib_Size(a5),d3
	cmp.l	#OBJECT_DEFINITION_SIZE,d3
	bgt.s	.error

	bsr	open.file.name.for.read
	bmi.s	.done

	bsr	read.file.memory
	bmi.s	.close

	bsr	convert.binary.object

* close input file

.close	move.l	file.handle(pc),d1
	CALLDOS	Close

.done	rts


.error	ERROR	<  Object file is too long>
	rts


convert.binary.object

* a5 = ptr to object to convert

	move.w	current.SOD.object(pc),d0
	subq.w	#1,d0
	lsl.w	#2,d0
	lea	SOD.object.ptrs(pc),a4
	move.l	(a4,d0.w),a4		get SOD object ptr
	lea	OBJECT_COMPONENTS(a4),a3

	clr.w	total.coords
	clr.w	total.components

	sf	polydraw.required
	sf	definition.complete
	move.w	#UNKNCLR,component.fillcol
	move.w	#UNKNCLR,component.vectcol

	lea	component.offsets(pc),a2
	lea	component.skips(pc),a1

.save.offset
	move.l	a5,(a2)+

.loop	move.w	(a5)+,d4

.check.circle
	cmp.w	#_3D_CIRCLE,d4
	bne.s	.check.end

	move.w	#CIRCLE,TYPE(a3)
	move.w	component.fillcol(pc),CLR(a3)
	move.w	#1,NUM_COORDS(a3)
	moveq	#0,d4
	move.w	(a5)+,d4
	divu	#COORD_SIZE,d4
	addq.w	#1,d4
	move.w	d4,COORDS(a3)		store co-ord position
	move.l	(a5)+,COORDS+2(a3)	store radius

	clr.l	(a1)+			no skip
	bra	.next.component

.check.end
	cmp.w	#_3D_END,d4
	bne.s	.check.gosub

	move.w	#END,TYPE(a3)
	move.w	#NOCLR,CLR(a3)
	move.w	#-1,NUM_COORDS(a3)

	clr.l	(a1)+			no skip

	movem.l	a0-a4,-(sp)
	bsr	check.definition.complete
	movem.l	(sp)+,a0-a4
	bmi.s	.not.complete
	st	definition.complete

.not.complete
	bra	.next.component

.check.gosub
	cmp.w	#_3D_GOSUB,d4
	bne.s	.check.goto

	move.w	#GOSUB,TYPE(a3)
	move.w	#NOCLR,CLR(a3)
	move.w	#-1,NUM_COORDS(a3)

	move.l	a5,a0
	add.w	(a5)+,a0
	move.l	a0,(a1)+		save skip
	bra	.next.component

.check.goto
	cmp.w	#_3D_GOTO,d4
	bne.s	.check.polygon

	move.w	#GOTO,TYPE(a3)
	move.w	#NOCLR,CLR(a3)
	move.w	#-1,NUM_COORDS(a3)

	move.l	a5,a0
	add.w	(a5)+,a0
	move.l	a0,(a1)+		save skip
	bra	.next.component

.check.polygon
	cmp.w	#_3D_POLYGON,d4
	bne.s	.check.polydraw

* store co-ords that are used for polygon orientation check

	lea	polygon.coords(pc),a0
	REPT	MIN_POLY_SIDES
	move.w	(a5)+,(a0)+
	ENDR

	move.w	(a5)+,d4
	lea	(a5,d4.w),a0
	move.l	a0,(a1)+		save skip

	st	polydraw.required
	bra.s	.store.polydraw

.check.polydraw
	cmp.w	#_3D_POLYDRAW,d4
	bne	.check.rotate

	clr.l	(a1)+			no skip for 'NCHK' polygon

.store.polydraw
	move.w	#POLYGON,TYPE(a3)
	move.w	component.fillcol(pc),CLR(a3)

	move.w	(a5)+,d4
	move.w	d4,NUM_COORDS(a3)
	subq.w	#1,d4
	bmi	.error

* store polygon co-ord positions

	move.w	d4,d3
	lea	COORDS(a3),a0

.copy	moveq	#0,d1
	move.w	(a5)+,d1
	divu	#COORD_SIZE,d1
	addq.w	#1,d1
	move.w	d1,(a0)+
	dbra	d3,.copy

* negate co-ords that are used for polygon orientation check

	moveq	#0,d5
	tst.b	polydraw.required
	beq.s	.check

	moveq	#MIN_POLY_SIDES-1,d2
	lea	polygon.coords(pc),a0

.neg	moveq	#0,d1
	move.w	(a0)+,d1
	divu	#COORD_SIZE,d1
	addq.w	#1,d1

	lea	COORDS(a3),a6
	move.w	d4,d3

.loop4	cmp.w	(a6),d1
	bne.s	.next2
	neg.w	(a6)
	addq.w	#1,d5
	bra.s	.next

.next2	lea	2(a6),a6
	dbra	d3,.loop4

.next	dbra	d2,.neg

* ensure that MIN_POLY_SIDES number of co-ords are negated

.check	cmp.w	#MIN_POLY_SIDES,d5
	bge.s	.neg.done

	moveq	#MIN_POLY_SIDES-1,d4
	sub.w	d5,d4
	lea	COORDS(a3),a6

.loop5	tst.w	(a6)
	bpl.s	.neg2
	lea	2(a6),a6
	bra.s	.loop5

.neg2	neg.w	(a6)+
	dbra	d4,.loop5

.neg.done
	sf	polydraw.required
	bra	.next.component

.check.rotate
	cmp.w	#_3D_ROTATE,d4
	bne.s	.check.vector

	move.w	#ROTATE,TYPE(a3)
	move.w	#NOCLR,CLR(a3)
	move.w	#2,NUM_COORDS(a3)

	moveq	#0,d5
	move.w	(a5)+,d5
	move.w	(a5)+,d4
	bmi	.error2
	lea	OBJECT_COORDS(a4,d5.w),a0	address for first co-ord
	divu	#COORD_SIZE,d5
	addq.w	#1,d5

	move.w	d5,COORDS(a3)			co-ord position 1
	add.w	d4,d5
	move.w	d5,COORDS+2(a3)			co-ord position 2
	move.w	d5,total.coords

.copy2
	REPT	(COORD_SIZE/2)
	move.w	(a5)+,(a0)+
	ENDR
	dbra	d4,.copy2

	clr.l	(a1)+			no skip
	bra	.next.component

.check.vector
	cmp.w	#_3D_VECTOR,d4
	bne.s	.check.zpri

	move.w	#VECTOR,TYPE(a3)
	move.w	component.vectcol(pc),CLR(a3)
	move.w	#2,NUM_COORDS(a3)

	moveq	#2-1,d5
	lea	COORDS(a3),a0

.loop2	moveq	#0,d4
	move.w	(a5)+,d4
	divu	#COORD_SIZE,d4
	addq.w	#1,d4
	move.w	d4,(a0)+		store co-ord positions
	dbra	d5,.loop2

	clr.l	(a1)+			no skip
	bra	.next.component

.check.zpri
	cmp.w	#_3D_ZPRI,d4
	bne.s	.check.fillcol

	move.w	#ZPRI,TYPE(a3)
	move.w	#NOCLR,CLR(a3)
	move.w	#2,NUM_COORDS(a3)

	moveq	#2-1,d5
	lea	COORDS(a3),a0

.loop3	moveq	#0,d4
	move.w	(a5)+,d4
	divu	#COORD_SIZE,d4
	addq.w	#1,d4
	move.w	d4,(a0)+		store co-ord positions
	dbra	d5,.loop3

	move.w	(a5)+,d4
	lea	(a5,d4.w),a0
	move.l	a0,(a1)+		save skip
	bra	.next.component

.check.fillcol
	cmp.w	#_3D_FILLCOL,d4
	bne.s	.check.vectcol

	move.w	(a5)+,d4
	lsr.w	#2,d4
	move.w	d4,component.fillcol
	bra	.loop

.check.vectcol
;	cmp.w	#_3D_VECTCOL,d4
;	bne.s	.check.

	move.w	(a5)+,d4
	lsr.w	#3,d4
	move.w	d4,component.vectcol
	bra	.loop

.next.component
	lea	COMPONENT_SIZE(a3),a3
	addq.w	#1,total.components

	tst.b	definition.complete
	beq	.save.offset

.complete
	CHECK	31,set.component.skips,a4

	move.w	total.coords(pc),OBJECT_TOTAL_COORDS(a4)
	move.w	total.components(pc),OBJECT_TOTAL_COMPONENTS(a4)
	st	OBJECT_MODIFIED(a4)

	move.w	current.SOD.object(pc),d0
	bsr	request.object.name.default
	bsr	set.current.SOD.object.name

.done	rts

.error	ERROR	<  dbra error 6>
	rts

.error2	ERROR	<  dbra error 7>
	rts


	ELSE


IP_ZPOLYVIS	equ	$fdec
IP_ROTATE1	equ	$fe9e
IP_ROTATE2	equ	$ff2c
IP_GOSUB	equ	$ff94
IP_END		equ	$ffb0
IP_GOTO		equ	$ffb2
IP_POLYDRAW	equ	$ffba
IP_ZPOLYDRAW	equ	$ffc4
IP_FILLCOL	equ	$ffde
IP_VECTCOL	equ	$ffea
IP_VECTOR	equ	$fff6
IP_CIRCLE	equ	$0004
IP_ZPRI		equ	$001e
IP_POLYVIS	equ	$0038
IP_LIGHTCOL	equ	$006a
IP_ELLIPSE	equ	$02ea


load.iphase.objects
	bsr	deallocate.all.SOD.mem
	bsr	deallocate.all.3D.mem
	lea	iphase.objects(pc),a5

.loop	bsr	display.iphase.offset
	bmi.s	.done
	bsr	convert.iphase.object

.next	cmp.l	#iphase.objects.end,a5
	blt.s	.loop

.done	move.w	#1,current.SOD.object
	bsr	set.current.SOD.object
	rts


display.iphase.offset
	move.l	window1(pc),iphase.window

	move.l	a5,d0
	sub.l	#iphase.objects,d0
	add.l	#$d1fc,d0		offset for first object
	lea	iphase.buffer(pc),a0
	bsr	longword.to.HEX

	lea	iphase.tags(pc),a0
	moveq	#8,d0			max. chars
	lea	iphase.buffer(pc),a1
	lea	iphase.prompt(pc),a2
	sub.l	a3,a3
	CALLRT	GetStringA		request object offset from user
	tst.l	d0
	beq.s	.cancel

	lea	iphase.buffer(pc),a0
	bsr	to.upper.case
	bsr	HEX.to.longword
	beq.s	.cancel
	bmi.s	.cancel

	sub.l	#$d1fc,d0		offset for first object
	add.l	#iphase.objects,d0
	move.l	d0,a5

.done	moveq	#1,d0
	rts

.cancel	moveq	#-1,d0
	rts


iphase.tags
	dc.l	RT_ReqPos,REQPOS_CENTERSCR
	dc.l	RT_TopOffset,-60
	dc.l	RT_Window
iphase.window
	dc.l	0
	dc.l	TAG_END


iphase.buffer	dc.b	'00000000',0
	even

iphase.prompt	dc.b	'Next offset to convert from (Hex) :-',0
	even


convert.iphase.object

* a5 = ptr to object to convert

	moveq	#1,d0
	bsr	check.space.for.extra.objects
	bmi	.done

	move.w	total.SOD.objects(pc),d6
	move.w	d6,d7
	lsl.w	#2,d7
	bsr	allocate.SOD.object.mem
	bmi	.done

	move.l	(a4,d7.w),a4		get SOD object ptr
	lea	OBJECT_COMPONENTS(a4),a3

	addq.w	#1,d6
	move.w	d6,total.SOD.objects
	move.w	d6,current.SOD.object

	clr.w	total.coords
	clr.w	total.components

	sf	polydraw.required
	sf	definition.complete
	move.w	#UNKNCLR,component.fillcol
	move.w	#UNKNCLR,component.vectcol

	lea	component.offsets(pc),a2
	lea	component.skips(pc),a1

.save.offset
	move.l	a5,(a2)+

.loop	move.w	(a5)+,d4

.check.circle
	cmp.w	#IP_CIRCLE,d4
	bne.s	.check.ellipse

	move.w	#CIRCLE,TYPE(a3)
	move.w	component.fillcol(pc),CLR(a3)
	move.w	#1,NUM_COORDS(a3)
	moveq	#0,d4
	move.w	(a5)+,d4
	divu	#COORD_SIZE,d4
	addq.w	#1,d4
	move.w	d4,COORDS(a3)		store co-ord position
	move.l	(a5)+,COORDS+2(a3)	store radius

	clr.l	(a1)+			no skip
	bra	.next.component

.check.ellipse
	cmp.w	#IP_ELLIPSE,d4
	bne.s	.check.end

	lea	8(a5),a5		ignore ellipse data
	bra.s	.loop

.check.end
	cmp.w	#IP_END,d4
	bne.s	.check.gosub

	move.w	#END,TYPE(a3)
	move.w	#NOCLR,CLR(a3)
	move.w	#-1,NUM_COORDS(a3)

	clr.l	(a1)+			no skip

	movem.l	a0-a4,-(sp)
	bsr	check.definition.complete
	movem.l	(sp)+,a0-a4
	bmi.s	.not.complete
	st	definition.complete

.not.complete
	bra	.next.component

.check.gosub
	cmp.w	#IP_GOSUB,d4
	bne.s	.check.goto

	move.w	#GOSUB,TYPE(a3)
	move.w	#NOCLR,CLR(a3)
	move.w	#-1,NUM_COORDS(a3)

	move.l	a5,a0
	add.w	(a5)+,a0
	move.l	a0,(a1)+		save skip
	bra	.next.component

.check.goto
	cmp.w	#IP_GOTO,d4
	bne.s	.check.polyvis

* if the previous component is a rotate (i.e. animated object)
* then follow this goto, instead of storing it

	cmp.w	#ROTATE,TYPE-COMPONENT_SIZE(a3)
	bne.s	.goto
	lea	-4(a2),a2
	add.w	(a5),a5
	bra	.save.offset

.goto	move.w	#GOTO,TYPE(a3)
	move.w	#NOCLR,CLR(a3)
	move.w	#-1,NUM_COORDS(a3)

	move.l	a5,a0
	add.w	(a5)+,a0
	move.l	a0,(a1)+		save skip
	bra	.next.component

.check.polyvis
	cmp.w	#IP_POLYVIS,d4
	beq.s	.polyvis
	cmp.w	#IP_ZPOLYVIS,d4
	bne.s	.check.rotate

.polyvis
	move.w	#POLYGON,TYPE(a3)
	move.w	#UNKNCLR,CLR(a3)

* store co-ords that are used for polygon orientation check

	lea	polygon.coords(pc),a0
	REPT	MIN_POLY_SIDES
	move.w	(a5)+,(a0)+
	ENDR

	move.w	(a5)+,d4
	lea	(a5,d4.w),a0
	move.l	a0,(a1)+		save skip

	st	polydraw.required
	bra	.loop

.check.rotate
	cmp.w	#IP_ROTATE1,d4
	beq.s	.rotate
	cmp.w	#IP_ROTATE2,d4
	bne.s	.check.vector

.rotate	move.w	#ROTATE,TYPE(a3)
	move.w	#NOCLR,CLR(a3)
	move.w	#2,NUM_COORDS(a3)

	move.w	(a5)+,d4
	moveq	#0,d5
	move.w	(a5)+,d5
	lea	OBJECT_COORDS(a4,d5.w),a0	address for first co-ord
	divu	#COORD_SIZE,d5
	addq.w	#1,d5

	move.w	d5,COORDS(a3)			co-ord position 1
	add.w	d4,d5
	move.w	d5,COORDS+2(a3)			co-ord position 2
	move.w	d4,d5
	addq.w	#1,d5
	add.w	d5,total.coords

.copy
	REPT	(COORD_SIZE/2)
	move.w	(a5)+,(a0)+
	ENDR
	dbra	d4,.copy

	clr.l	(a1)+			no skip
	bra	.next.component

.check.vector
	cmp.w	#IP_VECTOR,d4
	bne.s	.check.zpri

	move.w	#VECTOR,TYPE(a3)
	move.w	component.vectcol(pc),CLR(a3)
	move.w	#2,NUM_COORDS(a3)

	moveq	#2-1,d5
	lea	COORDS(a3),a0

.loop2	moveq	#0,d4
	move.w	(a5)+,d4
	divu	#COORD_SIZE,d4
	addq.w	#1,d4
	move.w	d4,(a0)+		store co-ord positions
	dbra	d5,.loop2

	clr.l	(a1)+			no skip
	bra	.next.component

.check.zpri
	cmp.w	#IP_ZPRI,d4
	bne.s	.check.polydraw

	move.w	#ZPRI,TYPE(a3)
	move.w	#NOCLR,CLR(a3)
	move.w	#2,NUM_COORDS(a3)

	moveq	#2-1,d5
	lea	COORDS(a3),a0

.loop3	moveq	#0,d4
	move.w	(a5)+,d4
	divu	#COORD_SIZE,d4
	addq.w	#1,d4
	move.w	d4,(a0)+		store co-ord positions
	dbra	d5,.loop3

	move.w	(a5)+,d4
	lea	(a5,d4.w),a0
	move.l	a0,(a1)+		save skip
	bra	.next.component

.check.polydraw
	cmp.w	#IP_POLYDRAW,d4
	bne.s	.check.zpolydraw
	moveq	#COORD_SIZE,d0
	bra.s	.polydraw

.check.zpolydraw
	cmp.w	#IP_ZPOLYDRAW,d4
	bne	.check.fillcol
	moveq	#COORD_SIZE+4,d0

.polydraw
	tst.b	polydraw.required
	bne.s	.nchk.done

	clr.l	(a1)+			no skip for 'NCHK' polygon

.nchk.done
	move.w	#POLYGON,TYPE(a3)
	move.w	component.fillcol(pc),CLR(a3)

	move.w	(a5)+,d4
	move.w	d4,NUM_COORDS(a3)
	subq.w	#1,d4

* store polygon co-ord positions

	move.w	d4,d3
	lea	COORDS(a3),a0

.copy2	moveq	#0,d1
	move.w	(a5)+,d1
	divu	d0,d1
	addq.w	#1,d1
	move.w	d1,(a0)+
	dbra	d3,.copy2

* negate co-ords that are used for polygon orientation check

	tst.b	polydraw.required
	beq.s	.neg.done

	moveq	#0,d5
	moveq	#MIN_POLY_SIDES-1,d2
	lea	polygon.coords(pc),a0

.neg	moveq	#0,d1
	move.w	(a0)+,d1
	divu	d0,d1
	addq.w	#1,d1

	lea	COORDS(a3),a6
	move.w	d4,d3

.loop4	cmp.w	(a6),d1
	bne.s	.next2
	neg.w	(a6)
	addq.w	#1,d5
	bra.s	.next

.next2	lea	2(a6),a6
	dbra	d3,.loop4

.next	dbra	d2,.neg

* ensure that MIN_POLY_SIDES number of co-ords are negated

	cmp.w	#MIN_POLY_SIDES,d5
	bge.s	.neg.done

	moveq	#MIN_POLY_SIDES-1,d4
	sub.w	d5,d4
	lea	COORDS(a3),a6

.loop5	tst.w	(a6)
	bpl.s	.neg2
	lea	2(a6),a6
	bra.s	.loop5

.neg2	neg.w	(a6)+
	dbra	d4,.loop5

* ignore last co-ord position if zpolydraw

.neg.done
	cmp.w	#COORD_SIZE,d0
	beq.s	.not.zpoly
	lea	2(a5),a5

.not.zpoly
	sf	polydraw.required
	bra.s	.next.component

.check.fillcol
	cmp.w	#IP_FILLCOL,d4
	bne.s	.check.vectcol

	move.w	(a5)+,d4
	and.w	#$00ff,d4
	lsr.w	#4,d4
	move.w	d4,component.fillcol
	bra	.loop

.check.vectcol
	cmp.w	#IP_VECTCOL,d4
	bne.s	.check.lightcol

	move.w	(a5)+,component.vectcol
	bra	.loop

.check.lightcol
	cmp.w	#IP_LIGHTCOL,d4
	bne	.show.value

	moveq	#0,d3
	move.w	(a5)+,d3
	add.w	(a5)+,d3
	add.w	(a5)+,d3
	rol.w	#2,d3
	and.w	#%11,d3

	move.w	(a5)+,d4
	lsr.w	#2,d4
	moveq	#12,d5
	sub.w	d4,d5
	add.w	d3,d5
	move.w	d5,component.fillcol
	bra	.loop

.next.component
	lea	COMPONENT_SIZE(a3),a3
	addq.w	#1,total.components

	tst.b	definition.complete
	beq	.save.offset

.complete
	bsr	set.component.skips

	move.w	total.coords(pc),OBJECT_TOTAL_COORDS(a4)
	move.w	total.components(pc),OBJECT_TOTAL_COMPONENTS(a4)
	st	OBJECT_MODIFIED(a4)

	move.l	a5,-(sp)
	move.w	current.SOD.object(pc),d0
	bsr	request.object.name.default
	bsr	set.current.SOD.object.name
	move.l	(sp)+,a5

.done	rts


.show.value
	movem.l	a0-a4,-(sp)
	move.l	window1(pc),.value.window

	move.w	d4,d0
	lea	.value.buffer(pc),a0
	bsr	longword.to.HEX
	lea	4(a0),a0
	lea	.value.prompt+16(pc),a1
	REPT	4
	move.b	(a0)+,(a1)+
	ENDR

	lea	.value.tags(pc),a0
	lea	.value.prompt(pc),a1
	lea	.value.buttons(pc),a2
	sub.l	a3,a3
	sub.l	a4,a4
	CALLRT	EZRequestA

	movem.l	(sp)+,a0-a4
	bra	.loop


.value.tags
	dc.l	RT_Underscore,'_'
	dc.l	RTEZ_Flags,EZREQF_NORETURNKEY
	dc.l	RT_ReqPos,REQPOS_CENTERSCR
	dc.l	RT_TopOffset,-60
	dc.l	RT_Window
.value.window
	dc.l	0
	dc.l	TAG_END


.value.buffer	dc.b	'00000000'
	even

.value.prompt	dc.b	'Unknown offset $0000 found',0
	even

.value.buttons	dc.b	' _Ok ',0
	even


	ENDC


component.offsets	ds.l	MAX_COMPONENTS
component.skips	ds.l	MAX_COMPONENTS

polydraw.required	dc.b	0
definition.complete	dc.b	0

component.fillcol	dc.w	0
component.vectcol	dc.w	0


****************************************


check.definition.complete

* following value does not include last component (i.e. it is total-1)

	move.w	total.components(pc),d5
	beq.s	.error

* get address of last converted component

	lea	component.offsets(pc),a2
	move.w	d5,d4
	lsl.w	#2,d4
	add.w	d4,a2
	move.l	(a2),d4

* check that all skips are to addresses that
* are not after the last converted component

	lea	component.skips(pc),a1
.loop	cmp.l	(a1)+,d4
	dblt	d5,.loop
	blt.s	.error

.done	moveq	#1,d0
	rts

.error	moveq	#-1,d0
	rts


****************************************


set.component.skips
	move.w	total.components(pc),d7
	beq.s	.done
	subq.w	#1,d7
	move.w	d7,d6
	lea	OBJECT_COMPONENTS(a4),a3
	lea	component.skips(pc),a1

.loop	move.l	(a1)+,d1
	bne.s	.search
	move.w	#-1,SKIP(a3)
	bra.s	.next

.search	move.w	d6,d5
	moveq	#0,d4
	lea	component.offsets(pc),a2

.loop2	addq.w	#1,d4
	cmp.l	(a2)+,d1
	dbeq	d5,.loop2
	beq.s	.found

.error	ERROR	<  Skip position not found>
	move.w	#-1,SKIP(a3)
	bra.s	.next

.found	move.w	d4,SKIP(a3)

.next	lea	COMPONENT_SIZE(a3),a3	next component
	dbra	d7,.loop

.done	moveq	#0,d0
	rts


****************************************


save.binary.object
	bsr	store.current.SOD.object

	move.w	current.SOD.object(pc),d7
	subq.w	#1,d7
	lsl.w	#2,d7
	lea	SOD.object.ptrs(pc),a2
	move.l	(a2,d7.w),a3		get SOD object ptr

* set modification flag, so object will be re-built
* without optimisations (when it is next viewed)

	st	OBJECT_MODIFIED(a3)

	CHECK	32,deallocate.3D.object.mem,a3

	CHECK	33,check.object.definition,a3
	bmi	.done

	CHECK	34,calc.3D.object.mem.with.optimisations,a3
	CHECK	35,allocate.3D.object.mem,a3
	bmi	.done

	CHECK	36,build.3D.object.with.optimisations,a3
	bpl.s	.save
	CHECK	37,deallocate.3D.object.mem,a3
	bra.s	.done

.save	moveq	#FREQ_SAVE,d7
	moveq	#FREQ_ANY,d6
	bsr	request.file.name
	bmi.s	.done

	bsr	open.file.name.for.write
	bmi.s	.done

	move.w	current.SOD.object(pc),d7
	subq.w	#1,d7
	lsl.w	#2,d7
	lea	_3D.object.ptrs(pc),a4
	move.l	(a4,d7.w),d2		get 3D object ptr
	lea	_3D.object.sizes(pc),a5
	move.l	(a5,d7.w),d3		get 3D object size
	bsr	write.memory

* close output file

.close	move.l	file.handle(pc),d1
	CALLDOS	Close

.done	rts


****************************************


intuiticks.handler
	cmp.l	#INTUITICKS,d2
	bne.s	.done

	move.w	intuiticks.count(pc),d7
	addq.w	#1,d7
	cmp.w	#INTUITICKS_PER_SECOND,d7
	bne.s	.save

	moveq	#0,d7			one second has elapsed

* Check all window message counters, decrementing any that are above zero
* When counters reach zero, the screen title for associated windows is reset

	moveq	#WINDOWS-1,d6
	lea	window.msg.counters(pc),a4
	lea	window.ptrs(pc),a3

.loop	move.w	(a4),d5
	beq.s	.next

	subq.w	#1,d5
	move.w	d5,(a4)
	bne.s	.next

* Counter is exhausted, so reset screen title of associated window

	move.l	(a3),a0
	move.w	#-1,a1
	lea	current.screen.title(pc),a2
	CALLINT	SetWindowTitles

.next	addq.l	#2,a4			next counter
	addq.l	#4,a3			next window ptr
	dbra	d6,.loop

.save	move.w	d7,intuiticks.count

.done	rts


*"""""""""""""
*" VARIABLES "
*"	     "
*"""""""""""""

_IntuitionBase	dc.l	0
_GfxBase	dc.l	0
_DOSBase	dc.l	0
_ReqBase	dc.l	0

StdOutHandle	dc.l	0

file.memory	dc.l	0
coord.memory	dc.l	0
component.memory	dc.l	0
normal.screen	dc.l	0
our.task	dc.l	0
file.req	dc.l	0
file.handle	dc.l	0

window.ptrs
window1		dc.l	0		ptrs must stay together and in order
window2		dc.l	0
window3		dc.l	0
window4		dc.l	0
window5		dc.l	0
window6		dc.l	0

current.window	dc.w	0
window.msg.counters	ds.w	WINDOWS		for error message display
intuiticks.count	dc.w	0

window3.current.active.title	dc.l	0

current.screen.title	ds.b	SCREEN_WIDTH/8	for title
screen.title.buffer	ds.b	SCREEN_WIDTH/8	for title + error message

read.reply.port1	ds.b	MP_SIZE
write.reply.port1	ds.b	MP_SIZE

read.reply.port2	ds.b	MP_SIZE
write.reply.port2	ds.b	MP_SIZE

read.reply.port3	ds.b	MP_SIZE
write.reply.port3	ds.b	MP_SIZE

read.reply.port4	ds.b	MP_SIZE
write.reply.port4	ds.b	MP_SIZE

console1.read.IO.request	ds.b	IOSTD_SIZE
console1.write.IO.request	ds.b	IOSTD_SIZE

console2.read.IO.request	ds.b	IOSTD_SIZE
console2.write.IO.request	ds.b	IOSTD_SIZE

console3.read.IO.request	ds.b	IOSTD_SIZE
console3.write.IO.request	ds.b	IOSTD_SIZE

console4.read.IO.request	ds.b	IOSTD_SIZE
console4.write.IO.request	ds.b	IOSTD_SIZE

console1.read.buffer	ds.b	CONBUF_SIZE
console1.write.buffer	ds.b	CONBUF_SIZE

console2.read.buffer	ds.b	CONBUF_SIZE
console2.write.buffer	ds.b	CONBUF_SIZE

console3.read.buffer	ds.b	CONBUF_SIZE
console3.write.buffer	ds.b	CONBUF_SIZE

console4.read.buffer	ds.b	CONBUF_SIZE
console4.write.buffer	ds.b	CONBUF_SIZE

console1.refresh.text
	ds.b	CONSOLE1_COLUMNS*CONSOLE1_ROWS+30

console1.cursor.coord	dc.w	0
console1.cursor.line	dc.w	0

console3.refresh.text
	ds.b	(CONSOLE3_COLUMNS+3*6)*CONSOLE3_ROWS+30

console3.cursor.component	dc.w	0
console3.cursor.line	dc.w	0

console2.entry.parsers.ptr	dc.l	0
console2.entry.parser	dc.l	0
console2.entry.columns	dc.w	0
console2.entry.len	dc.w	0
console2.entry.pos	dc.w	0
console2.entry.buffer	ds.b	CONSOLE2_COLUMNS
	even

console4.entry.parsers.ptr	dc.l	0
console4.entry.parser	dc.l	0
console4.entry.columns	dc.w	0
console4.entry.len	dc.w	0
console4.entry.pos	dc.w	0
console4.entry.buffer	ds.b	CONSOLE4_COLUMNS
	even

total.SOD.objects	dc.w	0
current.SOD.object	dc.w	0
first.opened.object	dc.w	0
SOD.object.modified	dc.w	0
SOD.object.ptrs	ds.l	MAX_OBJECTS

current.SOD.object.ptr	dc.l	0
current.SOD.component	dc.w	0

flash.colour.count	dc.w	0

unknown.colours.only	dc.b	0
no.coloured.components	dc.b	0
current.colour.set	dc.b	0
hold.3D.object		dc.b	0
colour.selection.disabled	dc.b	0
	even

current.3D.object.ptr	dc.l	0
current.3D.component.offset	dc.l	0
last.3D.component.offset	dc.l	0

_3D.object.ptrs	ds.l	MAX_OBJECTS
_3D.object.sizes	ds.l	MAX_OBJECTS

_3D.component.offsets	ds.l	MAX_COMPONENTS

coord.rotated.flags	ds.b	MAX_COORDS

total.coords	dc.w	0
extra.coords	dc.w	0
coord.insert.pos	dc.w	0
coord.modify.pos	dc.w	0
coord.pos1	dc.w	0
coord.pos2	dc.w	0

coord.x.value	dc.w	0
coord.y.value	dc.w	0
coord.z.value	dc.w	0

coord.x.step	dc.w	0
coord.y.step	dc.w	0
coord.z.step	dc.w	0

total.components	dc.w	0
component.insert.pos	dc.w	0
component.modify.pos	dc.w	0
component.coord.pos	dc.w	0
component.coord.pos1	dc.w	0
component.coord.pos2	dc.w	0
rotate.coord.pos1	dc.w	0
rotate.coord.pos2	dc.w	0
radius.value		dc.l	0
component.type		dc.w	0
component.pos		dc.w	0
component.pos1		dc.w	0
component.pos2		dc.w	0
num.polygon.coords	dc.w	0
num.orientation.coords	dc.w	0
polygon.coords		ds.w	MAX_POLY_SIDES2

window1.deactivated	dc.b	0
window2.deactivated	dc.b	0
window3.deactivated	dc.b	0
window4.deactivated	dc.b	0
console3.coords.only	dc.b	0
	even


*"""""""""""""
*" CONSTANTS "
*"	     "
*"""""""""""""

intuition.name	INTNAME
graphics.name	GRAFNAME
DOS.name	DOSNAME
reqtools.name	REQTOOLSNAME

default.screen.title	dc.b	'SOD 1.00b',0
default.object.name	dc.b	'Object1',0
;font.name	dc.b	'topaz.font',0

window1.title	dc.b	'Co-ordinate List',0
window1.active.title	dc.b	'POS.      X      Y      Z',0

window3.title	dc.b	'Object Definition',0
window3.active.title1	dc.b	'POS. SKIP CLR TYPE    CO-ORDINATES USED',0
window3.active.title2	dc.b	'CO-ORDINATES USED',0

menu1.name	dc.b	'Project',0
menu1.text1	dc.b	'Load Bank...',0
menu1.text2	dc.b	'Open Bank...',0
menu1.text3	dc.b	'Save Bank...',0
menu1.text4	dc.b	'Load Dir...',0
menu1.text5	dc.b	'Open Dir...',0
menu1.text6	dc.b	'Save Dir...',0
menu1.text7	dc.b	'Clear',0
menu1.text8	dc.b	'Quit SOD',0

menu2.name	dc.b	'Object',0
menu2.text1	dc.b	'3D View',0
menu2.text2	dc.b	'New',0
menu2.text3	dc.b	'Load...',0
menu2.text4	dc.b	'Open...',0
menu2.text5	dc.b	'Save...',0
menu2.text6	dc.b	'Rename',0
menu2.text7	dc.b	'Delete',0
menu2.text8	dc.b	'Animate',0

console.device.name	dc.b	'console.device',0

console1.top.offset.text
	dc.b	CSI,'12y',0
console2.top.offset.text
	dc.b	CSI,'3y',0
console3.top.offset.text
	dc.b	CSI,'12y',0
console4.top.offset.text
	dc.b	CSI,'3y',0

cursor.visible.text
	dc.b	CSI,' p',0
cursor.invisible.text
	dc.b	CSI,'0 p',0

error.text
	dc.b	'ERROR  ',0
circle.text
	dc.b	'CIRCLE ',0
end.text
	dc.b	'END    ',0
gosub.text
	dc.b	'GOSUB  ',0
goto.text
	dc.b	'GOTO   ',0
polygon.text
	dc.b	'POLYGON',0
rotate.text
	dc.b	'ROTATE ',0
vector.text
	dc.b	'VECTOR ',0
zpri.text
	dc.b	'ZPRI   ',0

radius.text
	dc.b	'     RADIUS ',0
	even


zero	dc.w	%1111110000000000
	dc.w	%1100110000000000
	dc.w	%1011010000000000
	dc.w	%1011010000000000
	dc.w	%1011010000000000
	dc.w	%1100110000000000
	dc.w	%1111110000000000

one	dc.w	%1111110000000000
	dc.w	%1101110000000000
	dc.w	%1001110000000000
	dc.w	%1101110000000000
	dc.w	%1101110000000000
	dc.w	%1000110000000000
	dc.w	%1111110000000000

two	dc.w	%1111110000000000
	dc.w	%1100110000000000
	dc.w	%1011010000000000
	dc.w	%1110110000000000
	dc.w	%1101110000000000
	dc.w	%1000010000000000
	dc.w	%1111110000000000

three	dc.w	%1111110000000000
	dc.w	%1000110000000000
	dc.w	%1111010000000000
	dc.w	%1100110000000000
	dc.w	%1111010000000000
	dc.w	%1000110000000000
	dc.w	%1111110000000000

four	dc.w	%1111110000000000
	dc.w	%1010110000000000
	dc.w	%1010110000000000
	dc.w	%1000010000000000
	dc.w	%1110110000000000
	dc.w	%1110110000000000
	dc.w	%1111110000000000

five	dc.w	%1111110000000000
	dc.w	%1000010000000000
	dc.w	%1011110000000000
	dc.w	%1000010000000000
	dc.w	%1111010000000000
	dc.w	%1000110000000000
	dc.w	%1111110000000000

six	dc.w	%1111110000000000
	dc.w	%1100010000000000
	dc.w	%1011110000000000
	dc.w	%1000010000000000
	dc.w	%1011010000000000
	dc.w	%1100110000000000
	dc.w	%1111110000000000

seven	dc.w	%1111110000000000
	dc.w	%1000010000000000
	dc.w	%1111010000000000
	dc.w	%1110110000000000
	dc.w	%1101110000000000
	dc.w	%1101110000000000
	dc.w	%1111110000000000

eight	dc.w	%1111110000000000
	dc.w	%1100110000000000
	dc.w	%1011010000000000
	dc.w	%1100110000000000
	dc.w	%1011010000000000
	dc.w	%1100110000000000
	dc.w	%1111110000000000

nine	dc.w	%1111110000000000
	dc.w	%1100110000000000
	dc.w	%1011010000000000
	dc.w	%1100010000000000
	dc.w	%1111010000000000
	dc.w	%1100110000000000
	dc.w	%1111110000000000


*""""""""""""""""""""""""
*" INTUITION STRUCTURES "
*"			"
*""""""""""""""""""""""""

new.normal.screen
		dc.w	0,0	;131		left, top
		dc.w	SCREEN_WIDTH,SCREEN_HEIGHT
		dc.w	SCREEN_DEPTH
		dc.b	-1,-1		pens
		dc.w	V_HIRES		viewmodes
		dc.w	CUSTOMSCREEN!NS_EXTENDED	type
		dc.l	0		font
		dc.l	default.screen.title	title
		dc.l	0		gadgets
		dc.l	0		bitmap
		dc.l	normal.tags


normal.tags	dc.l	SA_FullPalette,1
		dc.l	SA_LikeWorkbench,1
		dc.l	SA_SysFont,1
		dc.l	TAG_END


new.window1	dc.w	0,12		left, top
		dc.w	208,102		width, height
		dc.b	-1,-1		pens
		dc.l	INACTIVEWINDOW!MENUPICK!INTUITICKS	IDCMP
		dc.l	ACTIVATE!WFLG_NEWLOOKMENUS	flags
		dc.l	0		first gadget
		dc.l	0		checkmark
		dc.l	window1.title	title
		dc.l	0		screen
		dc.l	0		bitmap
		dc.w	0		min. width
		dc.w	0		min. height
		dc.w	0		max. width
		dc.w	0		max. height
		dc.w	CUSTOMSCREEN	screen type
		dc.l	0


new.window2	dc.w	0,114		left, top
		dc.w	208,13		width, height
		dc.b	-1,-1		pens
		dc.l	INACTIVEWINDOW!MENUPICK!INTUITICKS	IDCMP
		dc.l	WFLG_NEWLOOKMENUS	flags
		dc.l	0		first gadget
		dc.l	0		checkmark
		dc.l	0		title
		dc.l	0		screen
		dc.l	0		bitmap
		dc.w	0		min. width
		dc.w	0		min. height
		dc.w	0		max. width
		dc.w	0		max. height
		dc.w	CUSTOMSCREEN	screen type


new.window3	dc.w	210,12		left, top
		dc.w	430,102		width, height
		dc.b	-1,-1		pens
		dc.l	INACTIVEWINDOW!MENUPICK!INTUITICKS	IDCMP
		dc.l	WFLG_NEWLOOKMENUS	flags
		dc.l	0		first gadget
		dc.l	0		checkmark
		dc.l	window3.title	title
		dc.l	0		screen
		dc.l	0		bitmap
		dc.w	0		min. width
		dc.w	0		min. height
		dc.w	0		max. width
		dc.w	0		max. height
		dc.w	CUSTOMSCREEN	screen type


new.window4	dc.w	210,114		left, top
		dc.w	430,13		width, height
		dc.b	-1,-1		pens
		dc.l	INACTIVEWINDOW!MENUPICK!INTUITICKS	IDCMP
		dc.l	WFLG_NEWLOOKMENUS	flags
		dc.l	0		first gadget
		dc.l	0		checkmark
		dc.l	0		title
		dc.l	0		screen
		dc.l	0		bitmap
		dc.w	0		min. width
		dc.w	0		min. height
		dc.w	0		max. width
		dc.w	0		max. height
		dc.w	CUSTOMSCREEN	screen type


new.window5	dc.w	0,128		left, top
		dc.w	PLAN_WINDOW_WIDTH,PLAN_WINDOW_HEIGHT
		dc.b	-1,-1		pens
		dc.l	INACTIVEWINDOW!RAWKEY!MENUPICK!INTUITICKS	IDCMP
		dc.l	WFLG_NEWLOOKMENUS	flags
		dc.l	0		first gadget
		dc.l	0		checkmark
		dc.l	0		title
		dc.l	0		screen
		dc.l	0		bitmap
		dc.w	0		min. width
		dc.w	0		min. height
		dc.w	0		max. width
		dc.w	0		max. height
		dc.w	CUSTOMSCREEN	screen type


new.window6	dc.w	321,128		left, top
		dc.w	PLAN_WINDOW_WIDTH,PLAN_WINDOW_HEIGHT
		dc.b	-1,-1		pens
		dc.l	INACTIVEWINDOW!RAWKEY!MENUPICK!INTUITICKS	IDCMP
		dc.l	WFLG_NEWLOOKMENUS	flags
		dc.l	0		first gadget
		dc.l	0		checkmark
		dc.l	0		title
		dc.l	0		screen
		dc.l	0		bitmap
		dc.w	0		min. width
		dc.w	0		min. height
		dc.w	0		max. width
		dc.w	0		max. height
		dc.w	CUSTOMSCREEN	screen type


new.menu1	dc.l	new.menu2	next menu
		dc.w	2,0		left, top
		dc.w	64,9		width, height
		dc.w	MENUENABLED	flags
		dc.l	menu1.name	menu name
		dc.l	menu1.item1	first menu item
		dc.w	0		jazzx
		dc.w	0		jazzy
		dc.w	0		beatx
		dc.w	0		beaty


menu1.item1	dc.l	menu1.item2	next menu item
		dc.w	0,0		left, top
		dc.w	144,11		width, height
		dc.w	ITEMTEXT!COMMSEQ!ITEMENABLED!HIGHCOMP	flags
		dc.l	0		mutual exclude
		dc.l	menu1.itext1	intuitext
		dc.l	0		select fill
		dc.b	'L',0		alternate command key
		dc.l	0		subitem
		dc.w	0		next select


menu1.itext1	dc.b	1,0		frontpen, backpen
		dc.b	RP_JAM1,0	drawmode
		dc.w	2,2		leftedge, topedge
		dc.l	0		font
		dc.l	menu1.text1	text
		dc.l	0		next text


menu1.item2	dc.l	menu1.item3	next menu item
		dc.w	0,11		left, top
		dc.w	144,11		width, height
		dc.w	ITEMTEXT!COMMSEQ!ITEMENABLED!HIGHCOMP	flags
		dc.l	0		mutual exclude
		dc.l	menu1.itext2	intuitext
		dc.l	0		select fill
		dc.b	'O',0		alternate command key
		dc.l	0		subitem
		dc.w	0		next select


menu1.itext2	dc.b	1,0		frontpen, backpen
		dc.b	RP_JAM1,0	drawmode
		dc.w	2,2		leftedge, topedge
		dc.l	0		font
		dc.l	menu1.text2	text
		dc.l	0		next text


menu1.item3	dc.l	menu1.item4	next menu item
		dc.w	0,22		left, top
		dc.w	144,11		width, height
		dc.w	ITEMTEXT!COMMSEQ!ITEMENABLED!HIGHCOMP	flags
		dc.l	0		mutual exclude
		dc.l	menu1.itext3	intuitext
		dc.l	0		select fill
		dc.b	'S',0		alternate command key
		dc.l	0		subitem
		dc.w	0		next select


menu1.itext3	dc.b	1,0		frontpen, backpen
		dc.b	RP_JAM1,0	drawmode
		dc.w	2,2		leftedge, topedge
		dc.l	0		font
		dc.l	menu1.text3	text
		dc.l	0		next text


menu1.item4	dc.l	menu1.item5	next menu item
		dc.w	0,33		left, top
		dc.w	144,11		width, height
		dc.w	ITEMTEXT!HIGHCOMP	flags
		dc.l	0		mutual exclude
		dc.l	menu1.itext4	intuitext
		dc.l	0		select fill
		dc.b	0,0		alternate command key
		dc.l	0		subitem
		dc.w	0		next select


menu1.itext4	dc.b	1,0		frontpen, backpen
		dc.b	RP_JAM1,0	drawmode
		dc.w	2,2		leftedge, topedge
		dc.l	0		font
		dc.l	menu1.text4	text
		dc.l	0		next text


menu1.item5	dc.l	menu1.item6	next menu item
		dc.w	0,44		left, top
		dc.w	144,11		width, height
		dc.w	ITEMTEXT!HIGHCOMP	flags
		dc.l	0		mutual exclude
		dc.l	menu1.itext5	intuitext
		dc.l	0		select fill
		dc.b	0,0		alternate command key
		dc.l	0		subitem
		dc.w	0		next select


menu1.itext5	dc.b	1,0		frontpen, backpen
		dc.b	RP_JAM1,0	drawmode
		dc.w	2,2		leftedge, topedge
		dc.l	0		font
		dc.l	menu1.text5	text
		dc.l	0		next text


menu1.item6	dc.l	menu1.item7	next menu item
		dc.w	0,55		left, top
		dc.w	144,11		width, height
		dc.w	ITEMTEXT!HIGHCOMP	flags
		dc.l	0		mutual exclude
		dc.l	menu1.itext6	intuitext
		dc.l	0		select fill
		dc.b	0,0		alternate command key
		dc.l	0		subitem
		dc.w	0		next select


menu1.itext6	dc.b	1,0		frontpen, backpen
		dc.b	RP_JAM1,0	drawmode
		dc.w	2,2		leftedge, topedge
		dc.l	0		font
		dc.l	menu1.text6	text
		dc.l	0		next text


menu1.item7	dc.l	menu1.item8	next menu item
		dc.w	0,66		left, top
		dc.w	144,11		width, height
		dc.w	ITEMTEXT!ITEMENABLED!HIGHCOMP	flags
		dc.l	0		mutual exclude
		dc.l	menu1.itext7	intuitext
		dc.l	0		select fill
		dc.b	0,0		alternate command key
		dc.l	0		subitem
		dc.w	0		next select


menu1.itext7	dc.b	1,0		frontpen, backpen
		dc.b	RP_JAM1,0	drawmode
		dc.w	2,2		leftedge, topedge
		dc.l	0		font
		dc.l	menu1.text7	text
		dc.l	0		next text


menu1.item8	dc.l	0		next menu item
		dc.w	0,77		left, top
		dc.w	144,11		width, height
		dc.w	ITEMTEXT!COMMSEQ!ITEMENABLED!HIGHCOMP	flags
		dc.l	0		mutual exclude
		dc.l	menu1.itext8	intuitext
		dc.l	0		select fill
		dc.b	'Q',0		alternate command key
		dc.l	0		subitem
		dc.w	0		next select


menu1.itext8	dc.b	1,0		frontpen, backpen
		dc.b	RP_JAM1,0	drawmode
		dc.w	2,2		leftedge, topedge
		dc.l	0		font
		dc.l	menu1.text8	text
		dc.l	0		next text


new.menu2	dc.l	0		next menu
		dc.w	75,0		left, top
		dc.w	56,9		width, height
		dc.w	MENUENABLED	flags
		dc.l	menu2.name	menu name
		dc.l	menu2.item1	first menu item
		dc.w	0		jazzx
		dc.w	0		jazzy
		dc.w	0		beatx
		dc.w	0		beaty


menu2.item1	dc.l	menu2.item2	next menu item
		dc.w	0,0		left, top
		dc.w	108,11		width, height
		dc.w	ITEMTEXT!COMMSEQ!ITEMENABLED!HIGHCOMP	flags
		dc.l	0		mutual exclude
		dc.l	menu2.itext1	intuitext
		dc.l	0		select fill
		dc.b	'V',0		alternate command key
		dc.l	0		subitem
		dc.w	0		next select


menu2.itext1	dc.b	1,0		frontpen, backpen
		dc.b	RP_JAM1,0	drawmode
		dc.w	2,2		leftedge, topedge
		dc.l	0		font
		dc.l	menu2.text1	text
		dc.l	0		next text


menu2.item2	dc.l	menu2.item3	next menu item
		dc.w	0,11		left, top
		dc.w	108,11		width, height
		dc.w	ITEMTEXT!COMMSEQ!ITEMENABLED!HIGHCOMP	flags
		dc.l	0		mutual exclude
		dc.l	menu2.itext2	intuitext
		dc.l	0		select fill
		dc.b	'N',0		alternate command key
		dc.l	0		subitem
		dc.w	0		next select


menu2.itext2	dc.b	1,0		frontpen, backpen
		dc.b	RP_JAM1,0	drawmode
		dc.w	2,2		leftedge, topedge
		dc.l	0		font
		dc.l	menu2.text2	text
		dc.l	0		next text


menu2.item3	dc.l	menu2.item4	next menu item
		dc.w	0,22		left, top
		dc.w	108,11		width, height
		dc.w	ITEMTEXT!ITEMENABLED!HIGHCOMP	flags
		dc.l	0		mutual exclude
		dc.l	menu2.itext3	intuitext
		dc.l	0		select fill
		dc.b	0,0		alternate command key
		dc.l	0		subitem
		dc.w	0		next select


menu2.itext3	dc.b	1,0		frontpen, backpen
		dc.b	RP_JAM1,0	drawmode
		dc.w	2,2		leftedge, topedge
		dc.l	0		font
		dc.l	menu2.text3	text
		dc.l	0		next text


menu2.item4	dc.l	menu2.item5	next menu item
		dc.w	0,33		left, top
		dc.w	108,11		width, height
		dc.w	ITEMTEXT!ITEMENABLED!HIGHCOMP	flags
		dc.l	0		mutual exclude
		dc.l	menu2.itext4	intuitext
		dc.l	0		select fill
		dc.b	0,0		alternate command key
		dc.l	0		subitem
		dc.w	0		next select


menu2.itext4	dc.b	1,0		frontpen, backpen
		dc.b	RP_JAM1,0	drawmode
		dc.w	2,2		leftedge, topedge
		dc.l	0		font
		dc.l	menu2.text4	text
		dc.l	0		next text


menu2.item5	dc.l	menu2.item6	next menu item
		dc.w	0,44		left, top
		dc.w	108,11		width, height
		dc.w	ITEMTEXT!ITEMENABLED!HIGHCOMP	flags
		dc.l	0		mutual exclude
		dc.l	menu2.itext5	intuitext
		dc.l	0		select fill
		dc.b	0,0		alternate command key
		dc.l	0		subitem
		dc.w	0		next select


menu2.itext5	dc.b	1,0		frontpen, backpen
		dc.b	RP_JAM1,0	drawmode
		dc.w	2,2		leftedge, topedge
		dc.l	0		font
		dc.l	menu2.text5	text
		dc.l	0		next text


menu2.item6	dc.l	menu2.item7	next menu item
		dc.w	0,55		left, top
		dc.w	108,11		width, height
		dc.w	ITEMTEXT!COMMSEQ!ITEMENABLED!HIGHCOMP	flags
		dc.l	0		mutual exclude
		dc.l	menu2.itext6	intuitext
		dc.l	0		select fill
		dc.b	'R',0		alternate command key
		dc.l	0		subitem
		dc.w	0		next select


menu2.itext6	dc.b	1,0		frontpen, backpen
		dc.b	RP_JAM1,0	drawmode
		dc.w	2,2		leftedge, topedge
		dc.l	0		font
		dc.l	menu2.text6	text
		dc.l	0		next text


menu2.item7	dc.l	menu2.item8	next menu item
		dc.w	0,66		left, top
		dc.w	108,11		width, height
		dc.w	ITEMTEXT!HIGHCOMP	flags
		dc.l	0		mutual exclude
		dc.l	menu2.itext7	intuitext
		dc.l	0		select fill
		dc.b	0,0		alternate command key
		dc.l	0		subitem
		dc.w	0		next select


menu2.itext7	dc.b	1,0		frontpen, backpen
		dc.b	RP_JAM1,0	drawmode
		dc.w	2,2		leftedge, topedge
		dc.l	0		font
		dc.l	menu2.text7	text
		dc.l	0		next text


menu2.item8	dc.l	0		next menu item
		dc.w	0,77		left, top
		dc.w	108,11		width, height
		dc.w	ITEMTEXT!COMMSEQ!HIGHCOMP	flags
		dc.l	0		mutual exclude
		dc.l	menu2.itext8	intuitext
		dc.l	0		select fill
		dc.b	'A',0		alternate command key
		dc.l	0		subitem
		dc.w	0		next select


menu2.itext8	dc.b	1,0		frontpen, backpen
		dc.b	RP_JAM1,0	drawmode
		dc.w	2,2		leftedge, topedge
		dc.l	0		font
		dc.l	menu2.text8	text
		dc.l	0		next text


****************************************


ASCII.to.longword

* a0 = NULL terminated ASCII input string
* skips any leading non-numeric characters
* conversion ends when non-numeric characters are next encountered
*
* returns 1 if number converted successfully, with d0.l = number
* returns 0 if no number found
* returns -1 if invalid number found
*
* uses d0-d3, a0

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3

.skip	move.b	(a0)+,d0
	beq.s	.no.number

	addq.w	#1,d2			count chars.

	cmp.b	#'0',d0
	blt.s	.skip
	cmp.b	#'9',d0
	bgt.s	.skip

* now we have the first valid digit

	cmp.w	#2,d2
	blt.s	.sign.done		if no possibility of a '-' sign

	cmp.b	#'-',-2(a0)		check for '-' sign
	bne.s	.sign.done

	moveq	#-1,d3			remember '-' sign

.sign.done
	sub.b	#'0',d0			convert first digit to decimal

.next	move.b	(a0)+,d1
	beq.s	.got.number

	cmp.b	#'0',d1
	blt.s	.got.number
	cmp.b	#'9',d1
	bgt.s	.got.number

* now we have the next valid digit

	sub.b	#'0',d1			convert to decimal

	add.l	d0,d0			* 2
	bvs.s	.bad.number
	move.l	d0,d2
	add.l	d0,d0			* 4
	bvs.s	.bad.number
	add.l	d0,d0			* 8
	bvs.s	.bad.number
	add.l	d2,d0			* 10
	bvs.s	.bad.number

	add.l	d1,d0			add to previous total * 10
	bvc.s	.next

.bad.number
	moveq	#-1,d1
	rts

.no.number
	moveq	#0,d1
	rts

.got.number
	tst.w	d3
	bpl.s	.pos.number
	neg.l	d0			negate number if '-' flag set

.pos.number
	moveq	#1,d1
	rts


****************************************


longword.to.ASCII

* d0 = number (longword)
* a0 = address for ASCII string to be written
* leading zeros are not output
*
* returns with a0 = address of position after last char. of string
*
* uses d0-d4, a0/a2

	tst.l	d0
	beq.s	.decimal.zero

	lea	powers.of.ten(pc),a2
	moveq	#10-1,d3		do 10 digits
	moveq	#0,d4			miss off leading zeros

.loop	moveq	#'0',d1
	move.l	(a2)+,d2		get next power of ten

.calc.digit
	sub.l	d2,d0
	bcs.s	.digit.done
	addq.b	#1,d1			next digit up
	bra.s	.calc.digit

.digit.done
	add.l	d2,d0			restore remaining part of number

	tst.b	d4			if flag is set
	bne.s	.save.digit		then save all digits

	cmp.b	#'0',d1			if digit is zero
	beq.s	.next.position		then miss it

	st	d4			don't miss off any more zeros

.save.digit
	move.b	d1,(a0)+

.next.position
	dbra	d3,.loop
	rts

.decimal.zero
	move.b	#'0',(a0)+
	rts


powers.of.ten
	dc.l	1000000000,100000000,10000000,1000000
	dc.l	100000,10000,1000,100,10,1


****************************************


to.upper.case

* a0 = NULL terminated ASCII input string
*
* uses a1, d1

	move.l	a0,a1

.loop	move.b	(a1),d1
	cmp.b	#'a',d1
	blt.s	.store
	cmp.b	#'z',d1
	bgt.s	.store

	sub.b	#'a'-'A',d1

.store	move.b	d1,(a1)+
	bne.s	.loop
	rts


****************************************


HEX.to.longword

* a0 = NULL terminated ASCII input string
* skips any leading non-numeric characters
* conversion ends when non-numeric characters are next encountered
*
* returns 1 if number converted successfully, with d0.l = number
* returns 0 if no number found
* returns -1 if invalid number found
*
* uses d0-d1, a0

	moveq	#0,d0
	moveq	#0,d1

.skip	move.b	(a0)+,d0
	beq.s	.no.number

	cmp.b	#'0',d0
	blt.s	.skip
	cmp.b	#'9',d0
	ble.s	.valid

	cmp.b	#'A',d0
	blt.s	.skip
	cmp.b	#'F',d0
	bgt.s	.skip

* now we have the first valid digit

.valid	cmp.b	#'9',d0			convert first digit to hex
	bgt.s	.AtoF
	sub.b	#'0',d0
	bra.s	.next
.AtoF	sub.b	#'A'-10,d0

.next	move.b	(a0)+,d1
	beq.s	.got.number

	cmp.b	#'0',d1
	blt.s	.got.number
	cmp.b	#'9',d1
	ble.s	.valid2

	cmp.b	#'A',d1
	blt.s	.got.number
	cmp.b	#'F',d1
	bgt.s	.got.number

* now we have the next valid digit

.valid2	cmp.b	#'9',d1			convert to hex
	bgt.s	.AtoF2
	sub.b	#'0',d1
	bra.s	.add
.AtoF2	sub.b	#'A'-10,d1

.add	asl.l	#4,d0			* 16
	bvs.s	.bad.number

	add.l	d1,d0			add to previous total * 16
	bvc.s	.next

.bad.number
	moveq	#-1,d1
	rts

.no.number
	moveq	#0,d1
	rts

.got.number
	moveq	#1,d1
	rts


****************************************


longword.to.HEX

* d0 = number (longword)
* a0 = address for ASCII string to be written
*
* uses d0-d2, a1

	lea	.digits(pc),a1
	moveq	#0,d1

.loop	rol.l	#4,d0
	move.w	d0,d2
	and.w	#$f,d2
	move.b	(a1,d2.w),(a0,d1.w)
	addq.w	#1,d1
	cmp.w	#8,d1
	bne.s	.loop
	rts


.digits
	dc.b	'0123456789ABCDEF'


****************************************


word.to.ASCII

* d0 = number (word)
* a0 = address for ASCII string to be written
* leading zeros are not output
*
* returns with a0 = address of position after last char. of string
*
* uses d0-d4, a0

	and.l	#$ffff,d0
	move.w	#10000,d1		start with 10000's
	moveq	#0,d4			miss off leading zeros

.loop	move.l	d0,d2
	divu	d1,d2			calculate digit
	bne.s	.save.digit		if digit is not zero then save it

	tst.b	d4			if flag is zero
	beq.s	.next.position		then miss this zero digit

.save.digit
	moveq	#1,d4			don't miss off any more zeros
	move.b	d2,d3
	add.b	#'0',d3			offset for ASCII digits
	move.b	d3,(a0)+		save decimal digit

	mulu	d1,d2			move digit back to correct place
	sub.l	d2,d0			remove from original number

.next.position
	ext.l	d1
	divu	#10,d1			next decimal position
	cmp.w	#1,d1			have we reached units ?
	bne.s	.loop			loop back if not

	add.b	#'0',d0			offset for ASCII digits
	move.b	d0,(a0)+		save units
	rts


****************************************


colour.value.to.ASCII

* d0 = number (word 0-999)
* a0 = address for ASCII string to be written
* leading zeros are output as spaces
*
* returns with a0 = address of position after last char. of string
*
* uses d0-d4, a0

	and.l	#$ffff,d0
	move.w	#100,d1			start with 100's
	moveq	#0,d4			miss off leading zeros

.loop	move.l	d0,d2
	divu	d1,d2			calculate digit
	bne.s	.save.digit		if digit is not zero then save it

	tst.b	d4			if flag is zero
	bne.s	.save.digit
	move.b	#' ',(a0)+		then miss this zero digit
	bra.s	.next.position

.save.digit
	moveq	#1,d4			don't miss off any more zeros
	move.b	d2,d3
	add.b	#'0',d3			offset for ASCII digits
	move.b	d3,(a0)+		save decimal digit

	mulu	d1,d2			move digit back to correct place
	sub.l	d2,d0			remove from original number

.next.position
	ext.l	d1
	divu	#10,d1			next decimal position
	cmp.w	#1,d1			have we reached units ?
	bne.s	.loop			loop back if not

	add.b	#'0',d0			offset for ASCII digits
	move.b	d0,(a0)+		save units
	rts


****************************************


pos.to.ASCII

* d0 = position (word 0-9999)
* a0 = address for ASCII string to be written
* leading zeros are output as spaces
*
* returns with a0 = address of position after last char. of string
*
* uses d0-d4, a0

	and.l	#$ffff,d0
	move.w	#1000,d1		start with 1000's
	moveq	#0,d4			miss off leading zeros

.loop	move.l	d0,d2
	divu	d1,d2			calculate digit
	bne.s	.save.digit		if digit is not zero then save it

	tst.b	d4			if flag is zero
	bne.s	.save.digit
	move.b	#' ',(a0)+		then miss this zero digit
	bra.s	.next.position

.save.digit
	moveq	#1,d4			don't miss off any more zeros
	move.b	d2,d3
	add.b	#'0',d3			offset for ASCII digits
	move.b	d3,(a0)+		save decimal digit

	mulu	d1,d2			move digit back to correct place
	sub.l	d2,d0			remove from original number

.next.position
	ext.l	d1
	divu	#10,d1			next decimal position
	cmp.w	#1,d1			have we reached units ?
	bne.s	.loop			loop back if not

	add.b	#'0',d0			offset for ASCII digits
	move.b	d0,(a0)+		save units
	rts


****************************************


highlight.pos.to.ASCII

* d0 = position (word 0-9999)
* a0 = address for ASCII string to be written
* leading zeros are output as spaces
*
* returns with a0 = address of position after last char. of string
*
* uses d0-d4, a0

	and.l	#$ffff,d0
	move.w	#1000,d1		start with 1000's
	moveq	#0,d4			miss off leading zeros

.loop	move.l	d0,d2
	divu	d1,d2			calculate digit
	bne.s	.save.digit		if digit is not zero then save it

	tst.b	d4			if flag is zero
	bne.s	.not.first.digit
	move.b	#' ',(a0)+		then miss this zero digit
	bra.s	.next.position

.save.digit
	tst.b	d4
	bne.s	.not.first.digit
	move.b	#CSI,(a0)+
	move.b	#'7',(a0)+
	move.b	#'m',(a0)+		inverse video on

	moveq	#1,d4			don't miss off any more zeros

.not.first.digit
	move.b	d2,d3
	add.b	#'0',d3			offset for ASCII digits
	move.b	d3,(a0)+		save decimal digit

	mulu	d1,d2			move digit back to correct place
	sub.l	d2,d0			remove from original number

.next.position
	ext.l	d1
	divu	#10,d1			next decimal position
	cmp.w	#1,d1			have we reached units ?
	bne.s	.loop			loop back if not

	tst.b	d4
	bne.s	.not.one.digit
	move.b	#CSI,(a0)+
	move.b	#'7',(a0)+
	move.b	#'m',(a0)+		inverse video on

.not.one.digit
	add.b	#'0',d0			offset for ASCII digits
	move.b	d0,(a0)+		save units

	move.b	#CSI,(a0)+
	move.b	#'0',(a0)+
	move.b	#'m',(a0)+		normal video
	rts


****************************************


coord.value.to.ASCII

* d0 = number (signed word)
* a0 = address for ASCII string to be written
* leading zeros are output as spaces
*
* returns with a0 = address of position after last char. of string
*
* uses d0-d4, a0

	and.l	#$ffff,d0
	move.w	#10000,d1		start with 10000's
	moveq	#' ',d4
	tst.w	d0			check for -'ve number
	bpl.s	.loop

	neg.w	d0
	moveq	#'-',d4			set minus sign

.loop	move.l	d0,d2
	divu	d1,d2			calculate digit
	bne.s	.save.digit		if digit is not zero then save it

	tst.b	d4			if flag is not zero
	beq.s	.not.first.digit
	move.b	#' ',(a0)+		then miss this zero digit
	bra.s	.next.position

.save.digit
	tst.b	d4
	beq.s	.not.first.digit
	move.b	d4,(a0)+		save space/minus sign
	moveq	#0,d4			don't miss off any more zeros

.not.first.digit
	move.b	d2,d3
	add.b	#'0',d3			offset for ASCII digits
	move.b	d3,(a0)+		save decimal digit

	mulu	d1,d2			move digit back to correct place
	sub.l	d2,d0			remove from original number

.next.position
	ext.l	d1
	divu	#10,d1			next decimal position
	cmp.w	#1,d1			have we reached units ?
	bne.s	.loop			loop back if not

	tst.b	d4
	beq.s	.not.one.digit
	move.b	d4,(a0)+		save space/minus sign

.not.one.digit
	add.b	#'0',d0			offset for ASCII digits
	move.b	d0,(a0)+		save units
	rts


****************************************


insert.coord

* insert an extra co-ord into the list at coord.insert.pos
* assumes coord.insert.pos is not greater than total.coords + 1
*
* uses d0-d3, a0-a2

	move.l	coord.memory(pc),a0
	move.w	total.coords(pc),d0
	move.w	d0,d1
	mulu	#COORD_SIZE,d0
	add.l	d0,a0

	sub.w	coord.insert.pos(pc),d1
	bmi.s	.set			if no co-ords after insert position

	lea	COORD_SIZE(a0),a1

* move all co-ords from insert position onwards down by one position

.move
	REPT	(COORD_SIZE/2)
	move.w	-(a0),-(a1)
	ENDR
	dbra	d1,.move

* update components that use co-ord positions on or after insert position

	move.w	coord.insert.pos(pc),d0
	move.w	total.components(pc),d1
	subq.w	#1,d1
	bmi.s	.set			if there are no components
	move.l	component.memory(pc),a1

.loop	move.w	NUM_COORDS(a1),d2
	bmi.s	.next			if this component has no co-ords
	subq.w	#1,d2
	bmi.s	.error
	lea	COORDS(a1),a2

.loop2	move.w	(a2),d3
	bmi.s	.minus		if this co-ord is used for orientation check

	cmp.w	d3,d0
	bgt.s	.next2
	addq.w	#1,(a2)			increment co-ord position

.next2	lea	2(a2),a2
	dbra	d2,.loop2		check all co-ords
	bra.s	.next

.minus	neg.w	d3
	cmp.w	d3,d0
	bgt.s	.next2
	subq.w	#1,(a2)			increment co-ord position
	bra.s	.next2

.next	lea	COMPONENT_SIZE(a1),a1
	dbra	d1,.loop		check all components

* lastly set the values for the new co-ord

.set	move.w	coord.x.value(pc),X_VALUE(a0)
	move.w	coord.y.value(pc),Y_VALUE(a0)
	move.w	coord.z.value(pc),Z_VALUE(a0)
	addq.w	#1,total.coords
	rts

.error	ERROR	<  dbra error 8>
	rts


****************************************


check.components.allow.coord.deletion

* if any of the co-ords in the deletion range (coord.pos1 to coord.pos2)
* are used by the object's components then deletion is not allowed
*
* returns 1 if co-ords can be deleted
* returns -1 otherwise
*
* uses d0-d4, a0-a1

	move.w	coord.pos1(pc),d0
	move.w	coord.pos2(pc),d1
	move.w	total.components(pc),d2
	subq.w	#1,d2
	bmi.s	.good.delete		if there are no components
	move.l	component.memory(pc),a0

.loop	move.w	NUM_COORDS(a0),d3
	bmi.s	.next			if this component has no co-ords
	subq.w	#1,d3
	bmi.s	.error
	lea	COORDS(a0),a1

.loop2	move.w	(a1)+,d4
	bpl.s	.plus
	neg.w	d4		if this co-ord is used for orientation check

.plus	cmp.w	d0,d4
	blt.s	.next2			if before coord.pos1
	cmp.w	d1,d4
	ble.s	.bad.delete		if within deletion range
.next2	dbra	d3,.loop2		check all co-ords

.next	lea	COMPONENT_SIZE(a0),a0
	dbra	d2,.loop		check all components

.good.delete
	moveq	#1,d1
	rts

.bad.delete
	moveq	#-1,d1
	rts

.error	ERROR	<  dbra error 9>
	rts


****************************************


delete.coord.range

* delete co-ords from the list, in the range coord.pos1 to coord.pos2
* assumes coord.pos1 and coord.pos2 are within range of total.coords
*
* uses d0-d4, a0-a1

	move.w	total.coords(pc),d1
	sub.w	coord.pos2(pc),d1
	beq.s	.set			if no co-ords after deletion range
	subq.w	#1,d1

	move.l	coord.memory(pc),a0
	move.l	a0,a1
	move.w	coord.pos2(pc),d0
	mulu	#COORD_SIZE,d0
	add.l	d0,a0

	move.w	coord.pos1(pc),d0
	subq.w	#1,d0
	mulu	#COORD_SIZE,d0
	add.l	d0,a1

* move all co-ords after deletion range upwards by required amount

.move
	REPT	(COORD_SIZE/2)
	move.w	(a0)+,(a1)+
	ENDR
	dbra	d1,.move

* update components that use co-ord positions after coord.pos2

	move.w	coord.pos2(pc),d0
	move.w	d0,d1
	sub.w	coord.pos1(pc),d1
	addq.w	#1,d1
	move.w	total.components(pc),d2
	subq.w	#1,d2
	bmi.s	.set			if there are no components
	move.l	component.memory(pc),a0

.loop	move.w	NUM_COORDS(a0),d3
	bmi.s	.next			if this component has no co-ords
	subq.w	#1,d3
	bmi.s	.error
	lea	COORDS(a0),a1

.loop2	move.w	(a1),d4
	bmi.s	.minus		if this co-ord is used for orientation check

	cmp.w	d0,d4
	ble.s	.next2
	sub.w	d1,(a1)			update co-ord position

.next2	lea	2(a1),a1
	dbra	d3,.loop2		check all co-ords
	bra.s	.next

.minus	neg.w	d4
	cmp.w	d0,d4
	ble.s	.next2
	add.w	d1,(a1)			update co-ord position
	bra.s	.next2

.next	lea	COMPONENT_SIZE(a0),a0
	dbra	d2,.loop		check all components

* lastly set the new number of total co-ords

.set	move.w	coord.pos2(pc),d1
	sub.w	coord.pos1(pc),d1
	addq.w	#1,d1
	sub.w	d1,total.coords
	rts

.error	ERROR	<  dbra error 10>
	rts


****************************************


modify.coord

* modify the co-ord in the list at coord.modify.pos
* assumes coord.modify.pos is within range of total.coords
*
* uses d0, a0

	move.l	coord.memory(pc),a0
	move.w	coord.modify.pos(pc),d0
	subq.w	#1,d0
	mulu	#COORD_SIZE,d0
	add.l	d0,a0

	move.w	coord.x.value(pc),X_VALUE(a0)
	move.w	coord.y.value(pc),Y_VALUE(a0)
	move.w	coord.z.value(pc),Z_VALUE(a0)
	rts


****************************************


insert.component

* insert an extra component into the list at component.insert.pos
* assumes component.insert.pos is not greater than total.components + 1
*
* uses d0-d2, a0-a1

	move.l	component.memory(pc),a0
	move.w	total.components(pc),d0
	move.w	d0,d1
	mulu	#COMPONENT_SIZE,d0
	add.l	d0,a0

	sub.w	component.insert.pos(pc),d1
	bmi.s	.set		if no components after insert position

* increment all SKIP values where they are greater than insert position

	move.w	component.insert.pos(pc),d0
	move.w	total.components(pc),d2
	subq.w	#1,d2
	bmi	.error
	move.l	component.memory(pc),a1

.loop	cmp.w	SKIP(a1),d0
	bge.s	.next
	addq.w	#1,SKIP(a1)		increment skip value
.next	lea	COMPONENT_SIZE(a1),a1
	dbra	d2,.loop		check all components

* move all components from insert position onwards down by one position

	lea	COMPONENT_SIZE(a0),a1

.move
	REPT	(COMPONENT_SIZE/2)
	move.w	-(a0),-(a1)
	ENDR
	dbra	d1,.move

* lastly set the values for the new component

.set	moveq	#0,d1			first clear all co-ordinates
	lea	COORDS(a0),a1
	REPT	MAX_POLY_SIDES2
	move.w	d1,(a1)+
	ENDR

	move.w	component.type(pc),d0
	move.w	d0,TYPE(a0)
	addq.w	#1,total.components

.check.circle
	cmp.w	#CIRCLE,d0
	bne.s	.check.end

.set.circle
	move.w	#-1,SKIP(a0)
	move.w	#UNKNCLR,CLR(a0)
	move.w	#1,NUM_COORDS(a0)
	move.w	component.coord.pos(pc),COORDS(a0)
	move.l	radius.value(pc),COORDS+2(a0)
	rts

.check.end
	cmp.w	#END,d0
	bne.s	.check.gosub

.set.end
	move.w	#-1,SKIP(a0)
	move.w	#NOCLR,CLR(a0)
	move.w	#-1,NUM_COORDS(a0)
	rts

.check.gosub
	cmp.w	#GOSUB,d0
	bne.s	.check.goto

.set.gosub
	move.w	component.pos(pc),SKIP(a0)
	move.w	#NOCLR,CLR(a0)
	move.w	#-1,NUM_COORDS(a0)
	rts

.check.goto
	cmp.w	#GOTO,d0
	bne.s	.check.polygon

.set.goto
	move.w	component.pos(pc),SKIP(a0)
	move.w	#NOCLR,CLR(a0)
	move.w	#-1,NUM_COORDS(a0)
	rts

.check.polygon
	cmp.w	#POLYGON,d0
	bne.s	.check.rotate

.set.polygon
	move.w	component.insert.pos(pc),d1
	addq.w	#1,d1
	move.w	d1,SKIP(a0)
	move.w	#UNKNCLR,CLR(a0)
	move.w	num.polygon.coords(pc),d1
	move.w	d1,NUM_COORDS(a0)

	subq.w	#1,d1
	bmi	.error2
	lea	polygon.coords(pc),a1
	lea	COORDS(a0),a0
.copy	move.w	(a1)+,(a0)+
	dbra	d1,.copy
	rts

.check.rotate
	cmp.w	#ROTATE,d0
	bne.s	.check.vector

.set.rotate
	move.w	#-1,SKIP(a0)
	move.w	#NOCLR,CLR(a0)
	move.w	#2,NUM_COORDS(a0)
	move.w	rotate.coord.pos1(pc),COORDS(a0)
	move.w	rotate.coord.pos2(pc),COORDS+2(a0)
	rts

.check.vector
	cmp.w	#VECTOR,d0
	bne.s	.check.zpri

.set.vector
	move.w	#-1,SKIP(a0)
	move.w	#UNKNCLR,CLR(a0)
	move.w	#2,NUM_COORDS(a0)
	move.w	component.coord.pos1(pc),COORDS(a0)
	move.w	component.coord.pos2(pc),COORDS+2(a0)
	rts

.check.zpri
	cmp.w	#ZPRI,d0
	bne.s	.check.done

.set.zpri
	move.w	component.pos(pc),SKIP(a0)
	move.w	#NOCLR,CLR(a0)
	move.w	#2,NUM_COORDS(a0)
	move.w	component.coord.pos1(pc),COORDS(a0)
	move.w	component.coord.pos2(pc),COORDS+2(a0)
	rts

.check.done
	rts

.error	ERROR	<  dbra error 11>
	rts

.error2	ERROR	<  dbra error 12>
	rts


****************************************


check.skips.allow.component.deletion

* if any of the object's components have a SKIP to a position within the
* deletion range (component.pos1 to component.pos2) then deletion is not
* allowed
*
* returns 1 if components can be deleted
* returns -1 otherwise
*
* uses d0-d3, a0

	move.w	component.pos1(pc),d0
	move.w	component.pos2(pc),d1
	move.w	total.components(pc),d2
	subq.w	#1,d2
	bmi.s	.good.delete		if there are no components
	move.l	component.memory(pc),a0

.loop	move.w	SKIP(a0),d3
	cmp.w	d0,d3
	blt.s	.next			if before component.pos1
	cmp.w	d1,d3
	ble.s	.bad.delete		if within deletion range
.next	lea	COMPONENT_SIZE(a0),a0
	dbra	d2,.loop		check all components

.good.delete
	moveq	#1,d1
	rts

.bad.delete
	moveq	#-1,d1
	rts


****************************************


delete.component.range

* delete components from the list,
* in the range component.pos1 to component.pos2
* assumes component.pos1 and component.pos2
* are within range of total.components
*
* uses d0-d2, a0-a1

	move.w	total.components(pc),d1
	sub.w	component.pos2(pc),d1
	beq.s	.set			if no components after deletion range
	subq.w	#1,d1

	move.l	component.memory(pc),a0
	move.l	a0,a1
	move.w	component.pos2(pc),d0
	mulu	#COMPONENT_SIZE,d0
	add.l	d0,a0

	move.w	component.pos1(pc),d0
	subq.w	#1,d0
	mulu	#COMPONENT_SIZE,d0
	add.l	d0,a1

* move all components after deletion range upwards by required amount

.move
	REPT	(COMPONENT_SIZE/2)
	move.w	(a0)+,(a1)+
	ENDR
	dbra	d1,.move

* update components that have a SKIP to a position after component.pos2

	move.w	component.pos2(pc),d0
	move.w	d0,d1
	sub.w	component.pos1(pc),d1
	addq.w	#1,d1
	move.w	total.components(pc),d2
	subq.w	#1,d2
	bmi.s	.set			if there are no components
	move.l	component.memory(pc),a0

.loop	cmp.w	SKIP(a0),d0
	bge.s	.next
	sub.w	d1,SKIP(a0)		update skip value
.next	lea	COMPONENT_SIZE(a0),a0
	dbra	d2,.loop		check all components

* lastly set the new number of total components

.set	move.w	component.pos2(pc),d1
	sub.w	component.pos1(pc),d1
	addq.w	#1,d1
	sub.w	d1,total.components
	rts


****************************************


modify.component

* modify the component in the list at component.modify.pos
* assumes component.modify.pos is within range of total.components
*
* uses d0-d1, a0-a1

	move.l	component.memory(pc),a0
	move.w	component.modify.pos(pc),d0
	subq.w	#1,d0
	mulu	#COMPONENT_SIZE,d0
	add.l	d0,a0
	move.w	TYPE(a0),d0

.check.circle
	cmp.w	#CIRCLE,d0
	bne.s	.check.polygon

.modify.circle
	move.w	component.coord.pos(pc),COORDS(a0)
	move.l	radius.value(pc),COORDS+2(a0)
	rts

.check.polygon
	cmp.w	#POLYGON,d0
	bne.s	.check.rotate

.modify.polygon
	moveq	#0,d1			first clear all co-ordinates
	lea	COORDS(a0),a1
	REPT	MAX_POLY_SIDES2
	move.w	d1,(a1)+
	ENDR

	move.w	num.polygon.coords(pc),d1
	move.w	d1,NUM_COORDS(a0)

	subq.w	#1,d1
	bmi.s	.error
	lea	polygon.coords(pc),a1
	lea	COORDS(a0),a0
.copy	move.w	(a1)+,(a0)+
	dbra	d1,.copy
	rts

.check.rotate
	cmp.w	#ROTATE,d0
	bne.s	.check.vector

.modify.rotate
	move.w	rotate.coord.pos1(pc),COORDS(a0)
	move.w	rotate.coord.pos2(pc),COORDS+2(a0)
	rts

.check.vector
	cmp.w	#VECTOR,d0
	bne.s	.check.zpri

.modify.vector
	move.w	component.coord.pos1(pc),COORDS(a0)
	move.w	component.coord.pos2(pc),COORDS+2(a0)
	rts

.check.zpri
	cmp.w	#ZPRI,d0
	bne.s	.check.done

.modify.zpri
	move.w	component.coord.pos1(pc),COORDS(a0)
	move.w	component.coord.pos2(pc),COORDS+2(a0)
	rts

.check.done
	rts

.error	ERROR	<  dbra error 13>
	rts


****************************************


modify.component.skip

* modify the SKIP value of the component in the list at component.modify.pos
* assumes component.modify.pos is within range of total.components
*
* uses d0, a0

	move.l	component.memory(pc),a0
	move.w	component.modify.pos(pc),d0
	subq.w	#1,d0
	mulu	#COMPONENT_SIZE,d0
	add.l	d0,a0
	move.w	component.pos(pc),SKIP(a0)
	rts


****************************************


get.component.type

* d0 = component position (word)
*
* returns with d0.w = component type
*
* uses d0, a0

	move.l	component.memory(pc),a0
	subq.w	#1,d0
	mulu	#COMPONENT_SIZE,d0
	add.l	d0,a0
	move.w	TYPE(a0),d0
	rts


*""""""""""""""""""""""""""""""
*" INITIALISATION SUBROUTINES "
*"			      "
*""""""""""""""""""""""""""""""

initialise.environment

* Open the intuition library

	moveq	#0,d0
	lea	intuition.name(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_IntuitionBase
	beq	exit.false

* Open the graphics library

	moveq	#0,d0
	lea	graphics.name(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_GfxBase
	beq	exit.close.int

* Open the DOS library

	moveq	#0,d0
	lea	DOS.name(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_DOSBase
	beq	exit.close.graf

* Open the ReqTools library

	move.l	#REQTOOLSVERSION,d0
	lea	reqtools.name(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_ReqBase
	beq	exit.close.dos

* Allocate file memory

	move.l	#OBJECT_DEFINITION_SIZE,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	CALLEXEC AllocMem
	move.l	d0,file.memory
	beq	exit.close.reqtools

* Open the screen

	lea	new.normal.screen(pc),a0
	CALLINT	OpenScreen
	move.l	d0,normal.screen
	beq	exit.free.file.mem

* Set screen ptr of window structures

	move.l	d0,new.window1+nw_Screen
	move.l	d0,new.window2+nw_Screen
	move.l	d0,new.window3+nw_Screen
	move.l	d0,new.window4+nw_Screen
	move.l	d0,new.window5+nw_Screen
	move.l	d0,new.window6+nw_Screen

* Open first window

	lea	new.window1(pc),a0
	CALLINT	OpenWindow
	move.l	d0,window1
	beq	exit.close.screen

* Open second window

	lea	new.window2(pc),a0
	CALLINT	OpenWindow
	move.l	d0,window2
	beq	exit.close.window1

* Open third window

	lea	new.window3(pc),a0
	CALLINT	OpenWindow
	move.l	d0,window3
	beq	exit.close.window2

* Open fourth window

	lea	new.window4(pc),a0
	CALLINT	OpenWindow
	move.l	d0,window4
	beq	exit.close.window3

* Open fifth window

	lea	new.window5(pc),a0
	CALLINT	OpenWindow
	move.l	d0,window5
	beq	exit.close.window4

* Open sixth window

	lea	new.window6(pc),a0
	CALLINT	OpenWindow
	move.l	d0,window6
	beq	exit.close.window5

* Attach menu1 to window1

	move.l	window1(pc),a0
	lea	new.menu1(pc),a1
	CALLINT	SetMenuStrip

* Attach menu1 to window2

	move.l	window2(pc),a0
	lea	new.menu1(pc),a1
	CALLINT	SetMenuStrip

* Attach menu1 to window3

	move.l	window3(pc),a0
	lea	new.menu1(pc),a1
	CALLINT	SetMenuStrip

* Attach menu1 to window4

	move.l	window4(pc),a0
	lea	new.menu1(pc),a1
	CALLINT	SetMenuStrip

* Attach menu1 to window5

	move.l	window5(pc),a0
	lea	new.menu1(pc),a1
	CALLINT	SetMenuStrip

* Attach menu1 to window6

	move.l	window6(pc),a0
	lea	new.menu1(pc),a1
	CALLINT	SetMenuStrip

* Add reply ports for first window

	sub.l	a1,a1
	CALLEXEC FindTask
	move.l	d0,our.task

	lea	read.reply.port1(pc),a1
	move.l	d0,MP_SIGTASK(a1)
	CALLEXEC AddPort

	lea	write.reply.port1(pc),a1
	move.l	our.task(pc),MP_SIGTASK(a1)
	CALLEXEC AddPort

* Open console device for first window

	lea	console.device.name(pc),a0
	moveq	#0,d0
	lea	console1.read.IO.request(pc),a1
	move.l	window1(pc),IO_DATA(a1)
	move.l	#wd_Size,IO_LENGTH(a1)
	moveq	#0,d1
	CALLEXEC OpenDevice
	tst.l	d0
	bne	exit.rem.window1.ports

	lea	console1.read.IO.request(pc),a1
	move.l	IO_DEVICE(a1),console1.write.IO.request+IO_DEVICE
	move.l	IO_UNIT(a1),console1.write.IO.request+IO_UNIT

* Add reply ports for second window

	lea	read.reply.port2(pc),a1
	move.l	our.task(pc),MP_SIGTASK(a1)
	CALLEXEC AddPort

	lea	write.reply.port2(pc),a1
	move.l	our.task(pc),MP_SIGTASK(a1)
	CALLEXEC AddPort

* Open console device for second window

	lea	console.device.name(pc),a0
	moveq	#0,d0
	lea	console2.read.IO.request(pc),a1
	move.l	window2(pc),IO_DATA(a1)
	move.l	#wd_Size,IO_LENGTH(a1)
	moveq	#0,d1
	CALLEXEC OpenDevice
	tst.l	d0
	bne	exit.rem.window2.ports

	lea	console2.read.IO.request(pc),a1
	move.l	IO_DEVICE(a1),console2.write.IO.request+IO_DEVICE
	move.l	IO_UNIT(a1),console2.write.IO.request+IO_UNIT

* Add reply ports for third window

	lea	read.reply.port3(pc),a1
	move.l	our.task(pc),MP_SIGTASK(a1)
	CALLEXEC AddPort

	lea	write.reply.port3(pc),a1
	move.l	our.task(pc),MP_SIGTASK(a1)
	CALLEXEC AddPort

* Open console device for third window

	lea	console.device.name(pc),a0
	moveq	#0,d0
	lea	console3.read.IO.request(pc),a1
	move.l	window3(pc),IO_DATA(a1)
	move.l	#wd_Size,IO_LENGTH(a1)
	moveq	#0,d1
	CALLEXEC OpenDevice
	tst.l	d0
	bne	exit.rem.window3.ports

	lea	console3.read.IO.request(pc),a1
	move.l	IO_DEVICE(a1),console3.write.IO.request+IO_DEVICE
	move.l	IO_UNIT(a1),console3.write.IO.request+IO_UNIT

* Add reply ports for fourth window

	lea	read.reply.port4(pc),a1
	move.l	our.task(pc),MP_SIGTASK(a1)
	CALLEXEC AddPort

	lea	write.reply.port4(pc),a1
	move.l	our.task(pc),MP_SIGTASK(a1)
	CALLEXEC AddPort

* Open console device for fourth window

	lea	console.device.name(pc),a0
	moveq	#0,d0
	lea	console4.read.IO.request(pc),a1
	move.l	window4(pc),IO_DATA(a1)
	move.l	#wd_Size,IO_LENGTH(a1)
	moveq	#0,d1
	CALLEXEC OpenDevice
	tst.l	d0
	bne	exit.rem.window4.ports

	lea	console4.read.IO.request(pc),a1
	move.l	IO_DEVICE(a1),console4.write.IO.request+IO_DEVICE
	move.l	IO_UNIT(a1),console4.write.IO.request+IO_UNIT

* Get standard output handle

	CALLDOS	Output
	move.l	d0,StdOutHandle

* 3D view screen initialisation

	jsr	create.3D.view.screen
	bmi	exit.close.console4

* Normal screen initialisation

	bsr.s	initialise.all

	IFNE	DEBUG
	DEBUGM	<SODOUTPUT>
	ENDC

	rts


****************************************


initialise.all
	clr.w	intuiticks.count

	move.l	#window3.active.title1,window3.current.active.title
	sf	console3.coords.only

	sf	SOD.quit.request

	bsr	initialise.consoles
	bsr	initialise.plan.views

	bsr	allocate.initial.object.mem
	rts


****************************************


initialise.consoles
	bsr.s	initialise.console1
	bsr.s	initialise.console2
	bsr.s	initialise.console3
	bra.s	initialise.console4


initialise.console1
	lea	console1.top.offset.text(pc),a0
	jsr	console1.output.string

	lea	cursor.invisible.text(pc),a0
	jmp	console1.output.string


initialise.console2
	lea	console2.top.offset.text(pc),a0
	jsr	console2.output.string

	lea	cursor.invisible.text(pc),a0
	jmp	console2.output.string


initialise.console3
	lea	console3.top.offset.text(pc),a0
	jsr	console3.output.string

	lea	cursor.invisible.text(pc),a0
	jmp	console3.output.string


initialise.console4
	lea	console4.top.offset.text(pc),a0
	jsr	console4.output.string

	lea	cursor.invisible.text(pc),a0
	jmp	console4.output.string


*""""""""""""""""""""
*" EXIT SUBROUTINES "
*"		    "
*""""""""""""""""""""

exit.SOD
	bsr	deallocate.all.SOD.mem
	bsr	deallocate.all.3D.mem
	jsr	destroy.3D.view.screen

exit.close.console4
	lea	console4.read.IO.request(pc),a1
	CALLEXEC CloseDevice

exit.rem.window4.ports
	lea	read.reply.port4(pc),a1
	CALLEXEC RemPort

	lea	write.reply.port4(pc),a1
	CALLEXEC RemPort

exit.close.console3
	lea	console3.read.IO.request(pc),a1
	CALLEXEC CloseDevice

exit.rem.window3.ports
	lea	read.reply.port3(pc),a1
	CALLEXEC RemPort

	lea	write.reply.port3(pc),a1
	CALLEXEC RemPort

exit.close.console2
	lea	console2.read.IO.request(pc),a1
	CALLEXEC CloseDevice

exit.rem.window2.ports
	lea	read.reply.port2(pc),a1
	CALLEXEC RemPort

	lea	write.reply.port2(pc),a1
	CALLEXEC RemPort

exit.close.console1
	lea	console1.read.IO.request(pc),a1
	CALLEXEC CloseDevice

exit.rem.window1.ports
	lea	read.reply.port1(pc),a1
	CALLEXEC RemPort

	lea	write.reply.port1(pc),a1
	CALLEXEC RemPort

exit.clear.menu1
	move.l	window6(pc),a0
	CALLINT	ClearMenuStrip

	move.l	window5(pc),a0
	CALLINT	ClearMenuStrip

	move.l	window4(pc),a0
	CALLINT	ClearMenuStrip

	move.l	window3(pc),a0
	CALLINT	ClearMenuStrip

	move.l	window2(pc),a0
	CALLINT	ClearMenuStrip

	move.l	window1(pc),a0
	CALLINT	ClearMenuStrip

exit.close.window6
	move.l	window6(pc),a0
	CALLINT	CloseWindow

exit.close.window5
	move.l	window5(pc),a0
	CALLINT	CloseWindow

exit.close.window4
	move.l	window4(pc),a0
	CALLINT	CloseWindow

exit.close.window3
	move.l	window3(pc),a0
	CALLINT	CloseWindow

exit.close.window2
	move.l	window2(pc),a0
	CALLINT	CloseWindow

exit.close.window1
	move.l	window1(pc),a0
	CALLINT	CloseWindow

exit.close.screen
	move.l	normal.screen(pc),a0
	CALLINT	CloseScreen

exit.free.file.mem
	move.l	file.memory(pc),a1
	move.l	#OBJECT_DEFINITION_SIZE,d0
	CALLEXEC FreeMem

exit.close.reqtools
	move.l	_ReqBase(pc),a1
	CALLEXEC CloseLibrary

exit.close.dos
	move.l	_DOSBase(pc),a1
	CALLEXEC CloseLibrary

exit.close.graf
	move.l	_GfxBase(pc),a1
	CALLEXEC CloseLibrary

exit.close.int
	move.l	_IntuitionBase(pc),a1
	CALLEXEC CloseLibrary

exit.false
	moveq	#0,d0
	rts


****************************************


	include	3D_Routines.s


****************************************


	IFNE	IPHASE_LOAD

iphase.objects	incbin	IPhase.bin
iphase.objects.end

	ENDC


*"""""""""""""""""
*" GRAPHICS DATA "
*"		 "
*"""""""""""""""""

	section	SODgfx,code_c

front.data
	dc.l	%11111111111111111111111111111111
	dc.l	%10000100011100110111010001111111
	dc.l	%10111101101011010011011011111111
	dc.l	%10001100011011010101011011111111
	dc.l	%10111101101011010110011011111111
	dc.l	%10111101101100110111011011111111
	dc.l	%11111111111111111111111111111111

top.data
	dc.w	%1111111111111111
	dc.w	%1000110011000111
	dc.w	%1101101101011011
	dc.w	%1101101101000111
	dc.w	%1101101101011111
	dc.w	%1101110011011111
	dc.w	%1111111111111111

side.data
	dc.l	%11111111111111111111111111111111
	dc.l	%11001000100011000011111111111111
	dc.l	%10111101101101011111111111111111
	dc.l	%11011101101101000111111111111111
	dc.l	%11101101101101011111111111111111
	dc.l	%10011000100011000011111111111111
	dc.l	%11111111111111111111111111111111

coord.data
	ds.w	COORD_IMAGE_HEIGHT


****************************************
