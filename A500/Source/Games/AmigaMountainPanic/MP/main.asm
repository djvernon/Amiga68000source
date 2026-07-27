

**********
*	opt	l+,o+,ow+,ow1-,ow2-,ow6-,d+,CHKIMM
*
* A note about the options above:-
*
* l+ sets linkable code on (as I mix C and Assember in my current projects)
*
* o+ enables optimise mode.
*
* ow+ enables optimiser warnings (they act as errors with SLINK, so I edit
* my source when I get an optimiser warning)
*
* ow1- disables warnings on short backwards branch optimising
*
* ow2- disables warnings on address register indirect with displacement zero
* to address register indirect optimising, again I don't want to edit my code
* if I have (for example)
*
*         move.l   vs_vscreen1b(a0),a1  ; vs_vscreen1b = 0
*
* ow6- disables warnings if short branches forwards can be made
*
* d+ debug information on
*
* CHKIMM - Check Immediate values. This will report an error if any
* immediate addresses are used (the most common mistake in assembler
* is to leave the # from a value). Address 4 (EXECBASE) is allowed, and
* other fixed addesses (eg CUSTOM - $dff000) are allowed as long as
* you add a .L to the end.
*
*         add.l 123,d0         ; This now gives an error!
*         LEA   (CUSTOM).L,a0  ; This doesn't.
**********

;DEBUG_WITH_MONAM	equ	1

;24/08/2022 Uncomment DEBUG_OUTPUT below to output some values.  Uncomment DEBUG_SHOW_PLAYER_POS in player.asm to see player position and state.

;25/05/2022 Don't use startup.asm, as it doesn't do a Forbid (to allow input handler to work), which causes SoundEffect3 method to fail (likely due to level4 interrupt handler clashing with OS).
;USE_STARTUP	equ	1		; 23/05/2022 When defined, also needs "source\startup.asm" reinstating in the "vbcc_asmfiles=" line within build.bat.

	;23/05/2022
	IFD	USE_STARTUP
	xref	SystemAddVBlankRoutine
	xref	SystemRemoveVBlankRoutine
	xref	_GfxBase
	xdef	DebugWithMonam
;	xref	RawKeyCode
	xref	RawKeyArray

	xdef	_main
	ENDC

	section	main,code             ; need not be in chipram

	include	"include/exec_lib.i"
	include	"include/graphics_lib.i"

	incdir	"source/MP/"


_customBase	equ	$dff000
;SHOW_KINGTUT_SPRITES	equ	1
;SNOWFLAKES_USE_HARDWARE_SPRITES	equ	1
ATTACH_EFFECT_USE_HARDWARE_SPRITES	equ	1
SCR_KEYBOARD_HANDLER	equ	1	; Needed on A1200 and above (keyboard doesn't work reliably otherwise)

;DEBUG_OUTPUT	equ	1
;STEALTH_MODE	equ	1


waitBlit	macro
.\@	btst	#6,dmaconr(a6)		wait for blitter to finish
	bne.s	.\@
	endm


*"""""""""""""""""
*" 23/05/2022: START OF CODE, WHEN NOT USING startup.asm "
*"		 "
*"""""""""""""""""
	IFND	USE_STARTUP
start
	IFD	DEBUG_WITH_MONAM
	st.b	DebugWithMonam
	ENDC

	move.l	4.w,a6
	tst.b	DebugWithMonam
	bne.s	.continue1
	jsr	-132(a6)		turn multitasking off
.continue1

	moveq	#0,d0
	lea	grafName(pc),a1
	jsr	-552(a6)		OpenLibrary
	tst.l	d0
	beq	exitNow

	move.l	d0,_GfxBase
	tst.b	DebugWithMonam
	bne.s	.continue2
	move.l	d0,a6
	jsr	-456(a6)		OwnBlitter
.continue2

	lea	_customBase,a6
	waitBlit


;"""""""""""""""""""""""""
;" INITIALISE INTERRUPTS "
;"			 "
;"""""""""""""""""""""""""

	tst.b	DebugWithMonam
	bne.s	.continue3
	move.w	intenar(a6),oldInts	save system interrupt status

	move.w	#$7fff,intena(a6)	disable all interrupts

	move.b	#%00010111,$bfed01	set CIA-A ICR

	move.l	$68.w,oldLevel2
	move.l	#newLevel2,$68.w

	move.l	$6c.w,oldLevel3
	move.l	#newLevel3,$6c.w

	move.l	$70.w,oldLevel4
	move.l	#newLevel4,$70.w

	IFD	SCR_KEYBOARD_HANDLER
	move.l	$78.w,oldLevel6
	move.l	#newLevel6,$78.w

	move.w	#$e018,intena(a6)	enable level6, copper and level2 interrupts

	ELSE

	move.w	#$c018,intena(a6)	enable copper and level2 interrupts
	ENDC


	IFD	NOT_USED
	move.l	$14.w,oldDbz		division-by-zero exception handler
	move.l	#rteIns,$14.w		set to rte instruction
	ENDC
.continue3


	IFD	SCR_KEYBOARD_HANDLER
	jsr	setCIAs
	ENDC

	jsr	_main


;""""""""""""""""
;" EXIT ROUTINE	"
;"		"
;""""""""""""""""

	tst.b	DebugWithMonam
	bne.s	.continue4

* 30/05/2022 Reset CIA registers correctly (previously A1200 keyboard wasn't working in OS after exiting game)

	lea	CIAA,a0
	move.b	#%00001000,CRA(a0)
	move.b	#%00000001,CRB(a0)
	move.b	#%10011111,ICR(a0)

	lea	CIAB,a0
	move.b	#%00000000,CRA(a0)
	move.b	#%10000000,CRB(a0)
	move.b	#%10011111,ICR(a0)

	lea	_customBase,a6		restore a6 (as trashed by "shutdown")
	waitBlit

	move.w	#$7fff,intena(a6)	disable all interrupts

	move.b	#%10011010,$bfed01	restore CIA-A ICR

	move.l	oldLevel2(pc),$68.w

	move.l	oldLevel3(pc),$6c.w

	move.l	oldLevel4(pc),$70.w

	IFD	SCR_KEYBOARD_HANDLER
	move.l	oldLevel6(pc),$78.w
	ENDC

	move.w	oldInts(pc),d0
	or.w	#$c000,d0		set SET and INTEN bits
	move.w	d0,intena(a6)		restore system interrupt status


	IFD	NOT_USED
	move.l	oldDbz(pc),$14.w	restore division-by-zero handler
	ENDC


	move.w	#$03ff,dmacon(a6)	DMA off

	move.l	_GfxBase(pc),a0
	move.l	38(a0),cop1lch(a6)	restore system copper

	move.w	#$87f0,dmacon(a6)	DMA on
.continue4

	move.l	a0,a6
	tst.b	DebugWithMonam
	bne.s	.continue5
	jsr	-462(a6)		DisownBlitter
.continue5

	move.l	a6,a1
	move.l	4.w,a6
	jsr	-414(a6)		CloseLibrary

exitNow
	tst.b	DebugWithMonam
	bne.s	.continue6
	jsr	-138(a6)		turn multitasking on
.continue6

	moveq	#0,d0
	rts


_GfxBase	dc.l  0
oldInts	dc.w	0
oldLevel2	dc.l	0
oldLevel3	dc.l	0
oldLevel4	dc.l	0
	IFD	SCR_KEYBOARD_HANDLER
oldLevel6	dc.l	0
	ENDC
	IFD	NOT_USED
oldDbz		dc.l	0
	ENDC
DebugWithMonam	dc.b	0
RawKeyCode	dc.b	0
RawKeyArray	ds.b	128
grafName	dc.b	'graphics.library',0
		even
	ENDC	; IFND	USE_STARTUP


*"""""""""""""""""""""""
*" VERSION INFORMATION "
*"		       "
*"""""""""""""""""""""""
	IFD	USE_STARTUP
	xdef _VersionString
;_VersionString	dc.b	0,"$VER: Amiga Mountain Panic 0.1 May 19 2014",0
_VersionString	dc.b	0,"$VER: Amiga Mountain Panic 1.0 Aug 16 2022",0
	even
	ENDC


*"""""""""""""""""""""""
* 6502 to 68000 macros "
*"""""""""""""""""""""""

AREG	equr	d0
XREG	equr	d1
YREG	equr	d2

SCRATCHREG	equr	d3

* Note that '8' is appended to any whose names match 68000 mnemonics, to prevent conflicts

ADC	MACRO
	;TODO include Carry bit
	add.b	\1,AREG
	ENDM


AND8	MACRO
	IFC	'\2',''
	;AND without X or Y register
	and.b	\1,AREG

	ELSE

	IFC	'\2','X)'
	FAIL AND with X index indirect not supported!
	ENDC

	IFC	'\2','X'
	FAIL AND with X index not supported!

	ELSE

	IFC	'\2','Y'
	;AND with Y index
	lea	\1,a0
	add.w	YREG,a0
	and.b	(a0),AREG
	ENDC

	ENDC

	ENDC
	ENDM


ASL8	MACRO
	IFC	'\1','A'
	asl.b	#1,AREG

	ELSE

	IFC	'\2','X'
	;ASL with X index
	FAIL ASL with X index not supported!
	ELSE

	move.b	\1,SCRATCHREG
	asl.b	#1,SCRATCHREG
	move.b	SCRATCHREG,\1
	ENDC

	ENDC
	ENDM


CLC	MACRO
	ENDM


CMP8	MACRO
	IFC	'\2',''
	;CMP without X or Y register
	cmp.b	\1,AREG

	ELSE

	IFC	'\2','X)'
	FAIL CMP with X index indirect not supported!
	ENDC

	IFC	'\2','X'
	;CMP with X index
	lea	\1,a0
	add.w	XREG,a0
	cmp.b	(a0),AREG

	ELSE

	IFC	'\2','Y'
	;CMP with Y index
	lea	\1,a0
	add.w	YREG,a0
	cmp.b	(a0),AREG
	ENDC

	ENDC

	ENDC
	ENDM


CPX	MACRO
	cmp.b	\1,XREG
	ENDM


CPY	MACRO
	cmp.b	\1,YREG
	ENDM


DEC	MACRO
	IFC	'\2','X'
	FAIL DEC with X index not supported!
	ELSE
	sub.b	#1,\1
	ENDC
	ENDM


DEX	MACRO
	subq.b	#1,XREG
	ENDM


DEY	MACRO
	subq.b	#1,YREG
	ENDM


INC	MACRO
	IFC	'\2','X'
	FAIL INC with X index not supported!
	ELSE
	add.b	#1,\1
	ENDC
	ENDM


INX	MACRO
	addq.b	#1,XREG
	ENDM


INY	MACRO
	addq.b	#1,YREG
	ENDM


LDA	MACRO
	IFC	'\2',''
	;LDA without X or Y register
	move.b	\1,AREG

	ELSE

	IFC	'\2','X)'
	FAIL LDA with X index indirect not supported!
	ENDC

	IFC	'\2','X'
	;LDA with X index
	lea	\1,a0
	add.w	XREG,a0
	move.b	(a0),AREG

	ELSE

	IFC	'\2','Y'
	;LDA with Y index
	lea	\1,a0
	add.w	YREG,a0
	move.b	(a0),AREG
	ENDC

	ENDC

	ENDC
	ENDM


LDX	MACRO
	move.b	\1,XREG
	ENDM


LDY	MACRO
	move.b	\1,YREG
	ENDM


LSR8	MACRO
	IFC	'\1','A'
	lsr.b	#1,AREG

	ELSE

	IFC	'\2','X'
	;LSR with X index
	FAIL LSR with X index not supported!
	ELSE

	move.b	\1,SCRATCHREG
	lsr.b	#1,SCRATCHREG
	move.b	SCRATCHREG,\1
	ENDC

	ENDC
	ENDM


ORA	MACRO
	IFC	'\2',''
	;ORA without X or Y register
	or.b	\1,AREG
	ELSE
	FAIL ORA with X or Y index not supported!
	ENDC
	ENDM


PHA	MACRO
	move.w	AREG,-(sp)
	ENDM


PLA	MACRO
	move.w	(sp)+,AREG
	ENDM


ROL8	MACRO
	IFC	'\1','A'
	FAIL ROL A not supported!
	rol.b	#1,AREG

	ELSE

	IFC	'\2','X'
	;ROL with X index
	FAIL ROL with X index not supported!
	ELSE

	move.b	\1,SCRATCHREG
	rol.b	#1,SCRATCHREG
	move.b	SCRATCHREG,\1
	ENDC

	ENDC
	ENDM


SBC	MACRO
	;TODO include Carry bit
	sub.b	\1,AREG
	ENDM


SEC	MACRO
	ENDM


STA	MACRO
	IFC	'\2',''
	;STA without X or Y register
	move.b	AREG,\1

	ELSE

	IFC	'\2','X)'
	FAIL STA with X index indirect not supported!
	ENDC

	IFC	'\2','X'
	;STA with X index
	lea	\1,a0
	add.w	XREG,a0
	move.b	AREG,(a0)

	ELSE

	IFC	'\2','Y'
	;STA with Y index
	lea	\1,a0
	add.w	YREG,a0
	move.b	AREG,(a0)
	ENDC

	ENDC

	ENDC
	ENDM


STX	MACRO
	move.b	XREG,\1
	ENDM


STY	MACRO
	IFC	'\2',''
	;STY without X register
	move.b	YREG,\1

	ELSE

	IFC	'\2','X'
	;STY with X index
	lea	\1,a0
	add.w	XREG,a0
	move.b	YREG,(a0)
	ENDC

	ENDC
	ENDM


TAX	MACRO
	move.b	AREG,XREG
	ENDM


TAY	MACRO
	move.b	AREG,YREG
	ENDM


TXA	MACRO
	move.b	XREG,AREG
	ENDM


TYA	MACRO
	move.b	YREG,AREG
	ENDM


*""""""""""""""""""""""
*" SCREEN DEFINITIONS "
*"		      "
*""""""""""""""""""""""

SCREEN_WIDTH	equ	256
SCREEN_HEIGHT	equ	256
SCREEN_DEPTH	equ	4
;;SCREEN_Y_OFFSET	equ	$48

PLANAR_SCREEN_SIZE	equ	SCREEN_WIDTH/8*SCREEN_HEIGHT*SCREEN_DEPTH

PLANAR_MEMORY_SIZE	equ	PLANAR_SCREEN_SIZE*2

HARDWARE_X_OFFSET	equ	$9f	;Hardware horizontal start (NB value is $7f for standard screen width of 320)
HARDWARE_Y_OFFSET	equ	$2c	;Hardware vertical start

AMIGA_X_OFFSET	equ	0	;32 for SCREEN_WIDTH 320

PLANE_2_OFFSET	equ	SCREEN_WIDTH/8
PLANE_3_OFFSET	equ	(SCREEN_WIDTH/8)*2
PLANE_4_OFFSET	equ	(SCREEN_WIDTH/8)*3

PANEL_ROWS	equ	2
TOP_PANEL_Y	equ	0
BOTTOM_PANEL_Y	equ	SCREEN_HEIGHT-(16*PANEL_ROWS)

AMIGA_BLACK	equ	0
AMIGA_BLUE	equ	4	;1
AMIGA_WHITE	equ	7	;2
AMIGA_CYAN	equ	6	;3
AMIGA_RED	equ	1	;6
AMIGA_YELLOW	equ	3	;8
AMIGA_HP_RED	equ	9	;14

XOR_PLOT_MODE	equ	16


*"""""""""""""""""""""""""""""
*" SOURCE BITMAP DEFINITIONS "
*"			     "
*"""""""""""""""""""""""""""""

BITMAP_WIDTH	equ	320	;256
BITMAP_HEIGHT	equ	256	;208
BITMAP_DEPTH	equ	4

;BITMAP_SIZE	equ	BITMAP_WIDTH/8*BITMAP_HEIGHT*BITMAP_DEPTH

TILES_PLANE_2_OFFSET	equ	BITMAP_WIDTH/8
TILES_PLANE_3_OFFSET	equ	(BITMAP_WIDTH/8)*2
TILES_PLANE_4_OFFSET	equ	(BITMAP_WIDTH/8)*3

;SOURCE_WIDTH	equ	64		* Size within bitmap
;SOURCE_HEIGHT	equ	64

* NB subroutines are hard-coded for tile/sprite size of 16 (and item size of 8)
PLAYER_ROW	equ	3
ALIEN_ROW1	equ	4
ALIEN_ROW2	equ	5

BLANK_ITEM_COL	equ	15
ITEMS_ROW	equ	8
ITEMS_HEIGHT	equ	8

TILE_BANK1_ROW	equ	0
TILE_BANK2_ROW	equ	1
TILEX_ROW	equ	2
BLANK_TILE_COL	equ	7
BLANK_TILE_ROW	equ	TILE_BANK1_ROW


*""""""""""""""""""""""
*" START OF MAIN CODE "
*"		      "
*""""""""""""""""""""""

_main:
	IFD	USE_STARTUP
	;startup code is complete, this is where the main code starts,  - called from startup.asm
	tst.w	d0		;is it pal
	bne	.done		;not pal, exit now!
	ENDC

	* Wait for one frame - this allows system to run its' stuff (disk etc.)
.lp0
	IFD	USE_STARTUP
	move.l	_GfxBase,a6
	jsr	_LVOWaitTOF(a6)
	ELSE
	lea	_customBase,a6
	bsr	waitBOF
	ENDC
	btst	#6,$bfe001		; make sure mouse is NOT held down when starting (avoid instant exit)
	beq.s	.lp0

	bsr.s	initialise
	beq.s	.done

;	bsr.s	showTilesInterleaved

	moveq	#0,AREG
	moveq	#0,XREG
	moveq	#0,YREG
	lea	_customBase,a6
	bsr	runMountainPanic

	* Wait for one frame - this allows system to run its' stuff (disk etc.)
	IFD	USE_STARTUP
	move.l	_GfxBase,a6
	jsr	_LVOWaitTOF(a6)
	ELSE
	bsr	waitBOF
	ENDC

	bsr.s	shutdown
.done
	rts


;""""""""""""""
;" INITIALISE "
;"	      "
;""""""""""""""

initialise
	* Allocate screen memory
	move.l	#PLANAR_MEMORY_SIZE,d0
	move.l	#$10002,d1			; #MEMF_CHIP!MEMF_CLEAR,d1
	move.l	4.w,a6
	jsr	-198(a6)			; CALLEXEC AllocMem
	tst.l	d0
	beq.s	.failure
	move.l	d0,screenMemory

	move.l	d0,screen1
	add.l	#SCREEN_WIDTH/8*SCREEN_HEIGHT*SCREEN_DEPTH,d0
	move.l	d0,screen2

	tst.b	DebugWithMonam
	bne.s	.continue7
	bsr	initialiseDisplay
.continue7
	bsr.s	calcYTab
	bsr.s	makeTileBitmapFlippedInX
	bsr.s	makeTileMasks

	IFND	SHOW_KINGTUT_SPRITES
	IFND	SNOWFLAKES_USE_HARDWARE_SPRITES
	bsr	makeHardwareSpriteData
	ENDC
	ENDC

	* Initialise random number generator
	jsr	setRandomValues
	move.b	#$3b,randomLong+3
	moveq	#12-1,d7
.loop	bsr	randomizeLong
	dbra	d7,.loop

	bsr	initialiseSnowFlakes

	IFD	USE_STARTUP
	lea	VBlankInterrupt(PC),a0
	bsr	SystemAddVBlankRoutine
	ENDC

.success
	moveq	#1,d0
	rts

.failure
	rts


;""""""""""""
;" SHUTDOWN "
;"	    "
;""""""""""""

shutdown
	IFD	USE_STARTUP
	bsr	SystemRemoveVBlankRoutine
	ENDC

	* Free screen memory
	move.l	#PLANAR_MEMORY_SIZE,d0
	move.l	screenMemory(pc),a1
	move.l	4.w,a6
	jsr	-210(a6)			; CALLEXEC FreeMem
	rts


****************************************


	IFND	USE_STARTUP
	IFD	SCR_KEYBOARD_HANDLER
setCIAs
	lea	CIAA,a0
	move.b	#%00001000,CRA(a0)
	move.b	#%00001000,CRB(a0)
	move.b	#%01110101,ICR(a0)
	move.b	#%10001010,ICR(a0)	allow SP and Timer B interrupts

	lea	CIAB,a0
	move.b	#%00001000,CRA(a0)
	move.b	#%00001000,CRB(a0)
	move.b	#%01111101,ICR(a0)	allow Timer B interrupts
	move.b	#%10000010,ICR(a0)
	rts
	ENDC
	ENDC


;"""""""""""""""""""""
;" LEVEL 2 INTERRUPT "
;"		     "
;"""""""""""""""""""""

	IFND	USE_STARTUP
	IFD	SCR_KEYBOARD_HANDLER
newLevel2
	jsr	handleCIAA
	move.w	#8,intreq+custom
	rte


*"""""""""""""""""""""
*" LEVEL 6 INTERRUPT "
*"		     "
*"""""""""""""""""""""

newLevel6
	jsr	handleCIAB
	move.w	#$2000,intreq+custom
	rte


****************************************


handleCIAA
	movem.l	d0/a0/a3,-(sp)
	lea	CIAA,a3
	move.b	ICR(a3),d0
	bpl	endHandleCIAA		if IR not set

	btst	#1,d0			TB
	beq	testSP
	clr.b	CIAAtimerBcountdown

testSP
	btst	#3,d0			SP
	beq	endHandleCIAA

;	move.l	#key.array,a0
	lea	RawKeyArray(pc),a0
	clr.w	d0
	move.b	KEY(a3),d0
	ror.b	#1,d0
	eori.b	#$ff,d0
	cmpi.b	#$f0,d0
	bcc	handshake

	tst.b	d0
	bpl	keyPressed

keyReleased
	andi.b	#$7f,d0
;	move.b	#0,(a0,d0.w)
	sf.b	(a0,d0.w)
	bra	handshake

keyPressed
;	move.b	#$b3,(a0,d0.w)
	st.b	(a0,d0.w)

handshake
	jsr	startHandshake

endHandleCIAA
	movem.l	(sp)+,d0/a0/a3
	rts


****************************************


startHandshake
	tst.b	CIABtimerBcountdown
	bne	timerRunning

	move.b	#$80,CIABtimerBcountdown

	lea	CIAA,a0
	bset	#6,CRA(a0)		set SP to output

	lea	CIAB,a0
	move.b	#%00001000,CRB(a0)
	move.b	#%10000010,ICR(a0)
	move.b	#176,TBLO(a0)		245us
	move.b	#0,TBHI(a0)
timerRunning
	rts


****************************************


CIAAtimerBcountdown
	dc.b	0
CIABtimerBcountdown
	dc.b	0


****************************************


handleCIAB
	movem.l	d0/a0,-(sp)
	lea	CIAB,a0
	move.b	ICR(a0),d0
	bpl	endHandleCIAB		if IR not set

	btst	#1,d0			TB
	beq	endHandleCIAB

endHandshake
	lea	CIAA,a0
	bclr	#6,CRA(a0)		set SP back to input
	clr.b	CIABtimerBcountdown

endHandleCIAB
	movem.l	(sp)+,d0/a0
	rts


****************************************


	ELSE	; SCR_KEYBOARD_HANDLER


newLevel2
	movem.l	d0/a0-a1,-(sp)
	move.w	#$8,intreq+$dff000

	lea	$bfe001,a0

	btst	#3,$d00(a0)		read CIA-A ICR
	beq.s	endLevel2		if key not pressed

	lea	RawKeyArray(pc),a1

	move.b	$c00(a0),d0		get raw key code
	not.b	d0
	ror.b	#1,d0
	move.b	d0,RawKeyCode
	bmi.s	.clearArray
.setArray
	st.b	(a1,d0.w)
	bra.s	.arrayDone
.clearArray
	and.b	#$7f,d0
	sf.b	(a1,d0.w)
.arrayDone

	bset	#6,$e00(a0)		set SP to output

; NB This delay loop makes the handshake signal last approx. 80us on an A500 (and less on higher models),
; which is not enough, because the Hardware Reference Manual states it must be at least 85us.
	moveq	#54,d0

handShake
	dbra	d0,handShake		output handshake pulse

	bclr	#6,$e00(a0)		set SP back to input

endLevel2
	movem.l	(sp)+,d0/a0-a1
rteIns
	rte
	ENDC	; SCR_KEYBOARD_HANDLER
	ENDC	; IFND	USE_STARTUP


;"""""""""""""""""""""
;" LEVEL 3 INTERRUPT "
;"		     "
;"""""""""""""""""""""

	IFD	USE_STARTUP
VBlankInterrupt:
	movem.l	d2-d7/a2-a4,-(sp)	; all other registers can be trashed
	move.l	a1,a6			;customBase - coming from is_data

	st	VBlankOccured

	IFD	SHOW_KINGTUT_SPRITES
	bsr	positionSprites
	ENDC

	bsr	updateHPColour

	movem.l	(sp)+,d2-d7/a2-a4

	; If you set your interrupt to priority 10 or higher then a0 must point at $dff000 on exit.
	lea	_customBase,a0

	moveq	#0,d0			; must set Z flag on exit!
	rts				;Not rte!!!

	ELSE

newLevel3
	movem.l	d0-d1/a0,-(sp)
	move.w	#$10,intreq+$dff000

	st	CopperIntOccured

	bsr	updateHPColour

endLevel3
	movem.l	(sp)+,d0-d1/a0
	rte

	IFD	NOT_USED
VBlankWait
;	sf	VBlankOccured
.wait
	tst.b	VBlankOccured
	beq.s	.wait
	sf	VBlankOccured
	rts
	ENDC

	ENDC


; NB Using copper interrupt now as this is triggered (by copper list) earlier in the frame
copperWait
	IFD	USE_STARTUP
	move.w	intreqr(a6),d7
	and.w	#$10,d7
	beq.s	copperWait
	move.w	#$10,intreq(a6)
	ELSE
.wait
	tst.b	CopperIntOccured
	beq.s	.wait
	sf	CopperIntOccured
	ENDC
	rts


	IFND	USE_STARTUP
waitBOF
	move.l	vposr(a6),d0		get vertical beam position
	and.l	#$1ff00,d0
	lsr.l	#8,d0
	cmp.w	#312,d0			wait for bottom line
	bne.s	waitBOF
	rts
	ENDC


updateHPColour
	tst.b	playerHPLoss
	beq.s	.end

	subq.w	#1,irqHPCounter
	bne.s	.end

	; Dropped to 0 - reprogram palette
	not.b	irqHPIndex
	bne.s	.white

.red	move.w	#$f00,color0+AMIGA_HP_RED*2(a6)		Restore player energy bar colour to red
	bra.s	.reload

.white	move.w	#$fff,color0+AMIGA_HP_RED*2(a6)		Change player energy bar colour to white

	; And reload latch
.reload	move.w	#5,irqHPCounter
.end	rts

irqHPCounter
	dc.w	5
irqHPIndex
	dc.b	0,0


*"""""""""""""""""""""
*" LEVEL 4 INTERRUPT "
*"		     "
*"""""""""""""""""""""

	; Sound Effect code taken from SoundEffect3.s

newLevel4
	movem.l	d0-d3/a0,-(sp)

	move.w	intreqr(a6),d0
	and.w	intenar(a6),d0
	and.w	#$780,d0
	move.w	d0,intreq(a6)		acknowledge interrupt

	lsl.w	#5,d0
	moveq	#3,d1

.nextChannel
	add.w	d0,d0
	bcc.s	.channelDone

	moveq	#0,d2
	lea	channelStates(pc),a0
	move.b	(a0,d1.w),d2
	subq.w	#2,d2
	move.b	d2,(a0,d1.w)
	jsr	audioTable(pc,d2.w)

.channelDone
	dbra	d1,.nextChannel

	movem.l	(sp)+,d0-d3/a0
	rte



	bra.s	audioError
audioTable
	bra.s	audioOff
	rts				ignore the second interrupt
	bra.s	audioOn



audioError
	addq.w	#1,audioColour
	move.w	audioColour(pc),color0(a6)
	bra.s	audioError

audioOn
	move.w	#$8000,d2
	bset	d1,d2
	move.w	d2,dmacon(a6)		enable channel DMA
	rts

audioOff
	moveq	#0,d2
	bset	d1,d2
	move.w	d2,dmacon(a6)		disable channel DMA
	lsl.w	#7,d2
	move.w	d2,intena(a6)		disable channel interrupts
	rts



audioColour	dc.w	0
channelStates	dc.b	0,0,0,0
channelNext	dc.w	0



soundEffect
	; 23/05/2022 Sound effect table data ptr now supplied in a1
	movem.w	d0-d2,-(sp)

	move.l	(a1)+,a0
	move.l	(a1)+,d0
	lsr.l	#1,d0
	move.w	(a1)+,d1
	move.w	(a1),d2

; a0 = sample address
; d0.w = length in words
; d1.w = period (124 - 65535)
; d2.w = volume (0 - 64)

	lea	channelStates+4(pc),a1
	moveq	#3,d3
.findChannel
	tst.b	-(a1)			find first free channel
	dbeq	d3,.findChannel

	beq.s	.channelFound

	move.w	channelNext(pc),d3	get next in line if no channels free
	addq.w	#1,d3
	and.w	#3,d3
	move.w	d3,channelNext
	add.w	d3,a1

.channelFound
	moveq	#0,d4
	bset	d3,d4			set channel bit
	move.w	d4,d5
	lsl.w	#7,d5
	move.w	d5,intena(a6)		disable channel interrupts
	move.w	d4,dmacon(a6)		disable channel DMA

	move.b	#6,(a1)			set channel status
	lsl.w	#4,d3
	lea	aud0lch(a6),a1
	add.w	d3,a1
	move.l	a0,(a1)+		set sample address
	movem.w	d0-d2,(a1)		set length, period, volume

	or.w	#$8000,d5
	move.w	d5,intena(a6)		enable channel interrupts
	movem.w	(sp)+,d0-d2
	rts


* sound effect table:-
*	address, length (in bytes)
*	period, volume, channel no. (unused), spare word
*
* period = 3546895/22050Hz = 161

walkSoundLoInfo
	dc.l	walkLoSample,2370
	dc.w	161,64,1,0

walkSoundHiInfo
	dc.l	walkHiSample,2376
	dc.w	161,64,1,0

colSoundInfo
	dc.l	colSample,23300
	dc.w	161,64,0,0

pickupSoundInfo
	dc.l	pickupSample,23290
	dc.w	161,64,0,0

ropeAttachSoundInfo
	dc.l	ropeAttachSample,5716
	dc.w	161,64,0,0

soundEerieInfo
	dc.l	soundEerieSample,42624
	dc.w	161,64,0,0

itemUseInfo
	dc.l	itemUseSample,23280
	dc.w	161,64,0,0

shoggothHitInfo
	dc.l	shoggothHitSample,23334
	dc.w	161,64,0,0




;"""""""""""""""""""""""""""""
;" INITIALISE SCREEN DISPLAY "
;"			     "
;"""""""""""""""""""""""""""""

initialiseDisplay
	lea	_customBase,a6

	move.w	#$800f,dmacon(a6)	all sound channels on	;27/05/2022 This is required for sound output (with SoundEffect3 at least)

	bsr	waitBOF			wait for bottom line before disabling sprite DMA

	move.w	#$03ff,dmacon(a6)	DMA off

;;	lea	colour.table(pc),a0	initialise playfield colours
	lea	tileBitmap,a0
	clr.w	(a0)			change colour 0 to black (it is grey in the source .iff to indicate the transparent colour and differentiate it from the solid black)
	lea	color0(a6),a1
	moveq	#(1<<(SCREEN_DEPTH-1))-1,d0
setColours
	move.l	(a0)+,(a1)+
	dbra	d0,setColours

	IFD	SHOW_KINGTUT_SPRITES
	lea	ktSpriteColourTable,a0
	ELSE
	lea	spriteColourTable,a0
	ENDC
	lea	color16(a6),a1
	moveq	#(1<<(SCREEN_DEPTH-1))-1,d0
setSpriteColours
	move.l	(a0)+,(a1)+		initialise sprite colours
	dbra	d0,setSpriteColours

	move.w	#$4200,bplcon0(a6)	initialise screen
	IFEQ	SCREEN_WIDTH-320
	move.w	#$2c81,diwstrt(a6)	(use #$4881 for SCREEN_HEIGHT of 200)
	move.w	#$2cc1,diwstop(a6)	(use #$10c1 for SCREEN_HEIGHT of 200)
	move.w	#$38,ddfstrt(a6)
	move.w	#$d0,ddfstop(a6)
	ENDC
	IFEQ	SCREEN_WIDTH-256
	move.w	#$2ca1,diwstrt(a6)
	move.w	#$2ca1,diwstop(a6)
	move.w	#$48,ddfstrt(a6)
	move.w	#$c0,ddfstop(a6)
	ENDC
	move.w	#0,bplcon1(a6)
;	IFD	SHOW_KINGTUT_SPRITES
	move.w	#%100100,bplcon2(a6)	position sprites in front of playfield
;	ELSE
;	move.w	#%000000,bplcon2(a6)	position sprites behind playfield
;	ENDC
	moveq	#(SCREEN_WIDTH/8)*3,d0
	move.w	d0,bpl1mod(a6)
	move.w	d0,bpl2mod(a6)

	bsr	makeCopperLists		initialise copper

	move.l	copper1(pc),cop1lch(a6)
	move.w	d0,copjmp1(a6)

	move.w	#$87e0,dmacon(a6)	DMA on
	move.w	#$00ff,adkcon(a6)
	rts


;"""""""""""""""""""""
;" CALCULATE Y-TABLE "
;"		     "
;"""""""""""""""""""""

calcYTab
	move.w	#SCREEN_HEIGHT-1,d0
	moveq	#0,d1			offset starts at zero
	move.l	#SCREEN_WIDTH/8*SCREEN_DEPTH,d2		width of all bitplanes
	lea	yTable(pc),a0

.yTabLoop
	move.l	d1,(a0)+
	add.l	d2,d1
	dbra	d0,.yTabLoop
	rts


;""""""""""""""""
;" SUBROUTINES	"
;"		"
;""""""""""""""""

* Flip each 32 pixel wide column
makeTileBitmapFlippedInX
	lea	tileBitmap+32,a0	NB skip colour data
	lea	tileBitmapFlippedInX+32,a1	NB skip colour data
	move.w	#(BITMAP_WIDTH/32*BITMAP_HEIGHT*BITMAP_DEPTH)-1,d7

.nextLong
	moveq	#0,d4
	move.l	(a0)+,d6

	REPT	32
	lsr.l	#1,d6
	addx.l	d4,d4
	ENDR

	move.l	d4,(a1)+
	dbra	d7,.nextLong
	rts


makeTileMasks
	lea	tileBitmap+32,a0	NB skip colour data
	lea	tileBitmapMasks,a4
	bsr.s	makeTileMasksCommon

	lea	tileBitmapFlippedInX+32,a0	NB skip colour data
	lea	tileBitmapMasksFlippedInX,a4

makeTileMasksCommon
	lea	BITMAP_WIDTH/8(a0),a1
	lea	BITMAP_WIDTH/8(a1),a2
	lea	BITMAP_WIDTH/8(a2),a3
	move.l	a4,a5
	moveq	#(BITMAP_WIDTH/8)*3,d7	set planes modulo
	move.w	#BITMAP_HEIGHT-1,d0

.nextLine
	moveq	#(BITMAP_WIDTH/16)-1,d1

.nextWord
	move.w	(a0)+,d2
	or.w	(a1)+,d2
	or.w	(a2)+,d2
	or.w	(a3)+,d2

	move.w	d2,TILES_PLANE_4_OFFSET(a4)
	move.w	d2,TILES_PLANE_3_OFFSET(a4)
	move.w	d2,TILES_PLANE_2_OFFSET(a4)
	move.w	d2,(a4)+
	dbra	d1,.nextWord	do all words in current line

	add.w	d7,a0		align registers for next line
	add.w	d7,a1
	add.w	d7,a2
	add.w	d7,a3
	add.w	d7,a4
	dbra	d0,.nextLine	do all lines

* Now change the mask to solid for all items, so that the background will be erased when they are drawn (by plotSprite8x8)
	lea	(BITMAP_WIDTH/8)*(ITEMS_ROW*16)*BITMAP_DEPTH(a5),a5
	move.w	#(BITMAP_WIDTH/32*ITEMS_HEIGHT*BITMAP_DEPTH)-1,d7
	moveq	#-1,d0
.itemsLoop
	move.l	d0,(a5)+
	dbra	d7,.itemsLoop
	rts


	IFND	SHOW_KINGTUT_SPRITES
	IFND	SNOWFLAKES_USE_HARDWARE_SPRITES
*
* Hardware sprite usage:-
*  Sprite 0: Harpoon (hook on end of rope)
*  Sprite 1: Rope 'attach effect'
*  Sprite 2: Icicle (for icicle drop)
*  Sprite 3:
*
makeHardwareSpriteData
* Make 'normal' harpoon sprite
	moveq	#0,d6		;_itemHook
	moveq	#ITEMS_ROW,d7
	lea	tileBitmap+32,a0	NB skip colour data
	lea	harpoonSprite+2*2,a1
	bsr	.copyHardwareSpriteData

* Make 'FlippedInX' harpoon sprite
	moveq	#1,d6		;_itemHook is now in column 1 because the tileBitmapFlippedInX data is flipped using a 32 pixel column width
	moveq	#ITEMS_ROW,d7
	lea	tileBitmapFlippedInX+32,a0	NB skip colour data
	lea	harpoonSpriteFlippedInX+2*2,a1
	bsr	.copyHardwareSpriteData

* Make icicle sprite
	moveq	#12,d6		;icicle
	moveq	#ITEMS_ROW,d7
	lea	tileBitmap+32,a0	NB skip colour data
	lea	icicleSprite+2*2,a1
;	bsr	.copyHardwareSpriteData

* a0 = source bitmap data
* a1 = destination sprite data
* d6.w = source column number (NB column width is 16 pixels)
* d7.w = source row number (NB row height is 16 pixels)
.copyHardwareSpriteData
;.setSource
	mulu	#16*BITMAP_WIDTH/8*SCREEN_DEPTH,d7
	add.l	d7,a0
	add.w	d6,d6
	add.w	d6,a0

	moveq	#ITEMS_HEIGHT-1,d7

.nextLine
	move.w	(a0),(a1)+			plane 1
	lea	(BITMAP_WIDTH/8)(a0),a0		to next bitmap plane (interleaved)
	move.w	(a0),(a1)+			plane 2
	lea	(BITMAP_WIDTH/8)*3(a0),a0	to plane 1 of next bitmap line (interleaved)
	dbra	d7,.nextLine
	clr.l	(a1)				end of sprite
	rts



* d7.w = hardware sprite number * 8
disableSprite
	move.l	#disabledSprite,d4
	move.l	#copperList1Sprites,a0
	move.w	d4,6(a0,d7.w)		save low word
	swap	d4
	move.w	d4,2(a0,d7.w)		save high word
	rts


* d4.w = screen x position (i.e. non-hardware position)
* d5.w = screen y position (i.e. non-hardware position)
* d6.w = sprite height
* d7.w = hardware sprite number * 8
* a0 = sprite data start
positionAndShowSprite
	add.w	#HARDWARE_X_OFFSET+AMIGA_X_OFFSET,d4
	add.w	#HARDWARE_Y_OFFSET,d5

	add.w	d5,d6

	lsl.w	#8,d6
	bcc.s	novstop8

	addq.w	#2,d6			set vstop bit 8

novstop8
	lsl.w	#8,d5
	bcc.s	novstart8

	addq.w	#4,d6			set vstart bit 8

novstart8
	lsr.w	#1,d4
	bcc.s	nohstart0

	addq.w	#1,d6			set hstart bit 0

nohstart0
	move.b	d4,d5

;	or.w	#%10000000,d6		set attach bit

	move.l	a0,d4
	move.w	d5,(a0)+
	move.w	d6,(a0)

* Show sprite by storing its address in the copper list
	move.l	#copperList1Sprites,a0
	move.w	d4,6(a0,d7.w)		save low word
	swap	d4
	move.w	d4,2(a0,d7.w)		save high word
	rts
	ENDC
	ENDC




*""""""""""""""""
*" COPY ORIGINAL TILE DATA TO INTERLEAVED SCREEN
*"		"
*""""""""""""""""
;;SKIP_LINES	equ	12
;
;copyHalfOfTiles
;	move.w	#(BITMAP_HEIGHT/2*SCREEN_DEPTH)-1,d7
;
;.nextLine
;	move.w	#BITMAP_WIDTH/8-1,d5
;
;.nextByte
;	move.b	(a0)+,(a2)+
;	dbra	d5,.nextByte
;
;	lea	((SCREEN_WIDTH-BITMAP_WIDTH)/8)(a2),a2		to next plane (interleaved)
;	dbra	d7,.nextLine
;	rts
;
;showTilesInterleaved
;	; Copy first half of tiles to left side of screen
;	lea	tileBitmap+32,a0	NB skip colour data
;	move.l	screen1(pc),a2
;;	lea	(SCREEN_WIDTH/8)*SCREEN_DEPTH*SKIP_LINES(a2),a2
;	bsr.s	copyHalfOfTiles
;
;	; Copy second half of tiles to right of the first half
;	move.l	screen1(pc),a2
;;	lea	(SCREEN_WIDTH/8)*SCREEN_DEPTH*SKIP_LINES(a2),a2
;	lea	(BITMAP_WIDTH/8)(a2),a2
;	bra.s	copyHalfOfTiles


*""""""""""""""""
*" COPY DOUBLE WIDTH TILE DATA TO INTERLEAVED SCREEN
*"		"
*""""""""""""""""
	IFD	NOT_USED
showTilesInterleaved
	lea	tileBitmap+32,a0	NB skip colour data
	move.l	screen1(pc),a2
	move.w	#(BITMAP_HEIGHT*SCREEN_DEPTH)-1,d7

.nextLine
	move.w	#BITMAP_WIDTH/8-1,d5

.nextByte
	move.b	(a0)+,(a2)+
	dbra	d5,.nextByte

	lea	((SCREEN_WIDTH-BITMAP_WIDTH)/8)(a2),a2		to next plane (interleaved)
	dbra	d7,.nextLine
	rts
	ENDC


* d0 = source row number
* d6 = destination screen x
* d7 = destination screen y
copyTile16x16Row
	lea	tileBitmap+32,a0	NB skip colour data
	mulu	#16*BITMAP_WIDTH/8*SCREEN_DEPTH,d0
	add.l	d0,a0

	move.l	screen1(pc),a2
	lsr.w	#3,d6			x in bytes
	add.w	d6,a2
	lea	yTable(pc),a3
	add.w	d7,d7
	add.w	d7,d7
	add.l	(a3,d7.w),a2

	moveq	#(16*SCREEN_DEPTH)-1,d7

.nextLine
	move.w	#BITMAP_WIDTH/8-1,d5

.nextByte
	move.b	(a0)+,(a2)+
	dbra	d5,.nextByte

	lea	((SCREEN_WIDTH-BITMAP_WIDTH)/8)(a2),a2		to next plane (interleaved)
	dbra	d7,.nextLine
	rts


showPanels
	* copy top panel, which is all of rows 10 and 11 in the tile data
	moveq	#10,d0
	moveq	#AMIGA_X_OFFSET,d6
	moveq	#TOP_PANEL_Y,d7
	bsr.s	copyTile16x16Row
	moveq	#11,d0
	moveq	#AMIGA_X_OFFSET,d6
	moveq	#TOP_PANEL_Y+16,d7
	bsr.s	copyTile16x16Row

	* copy bottom panel, which is all of rows 6 and 7 in the tile data
	moveq	#6,d0
	moveq	#AMIGA_X_OFFSET,d6
	move.w	#BOTTOM_PANEL_Y,d7
	bsr.s	copyTile16x16Row
	moveq	#7,d0
	moveq	#AMIGA_X_OFFSET,d6
	move.w	#BOTTOM_PANEL_Y+16,d7
	bra.s	copyTile16x16Row




	IFD	SHOW_KINGTUT_SPRITES
positionSprites
	move.b	joy0dat+1(a6),d0	x mouse movement
	move.b	d0,d1
	sub.b	registerMouseX(pc),d0
	move.b	d1,registerMouseX
	ext.w	d0
	add.w	spriteHoriz(pc),d0
	bpl.s	horizok

	moveq	#0,d0
	bra.s	horizok2

horizok
	cmp.w	#511,d0
	ble.s	horizok2

	move.w	#511,d0

horizok2
	move.w	d0,spriteHoriz



	move.b	joy0dat(a6),d1		y mouse movement
	move.b	d1,d2
	sub.b	registerMouseY(pc),d1
	move.b	d2,registerMouseY
	ext.w	d1
	add.w	spriteVert(pc),d1

	cmp.w	#26,d1
	bge.s	vertok

	moveq	#26,d1
	bra.s	vertok2

vertok	cmp.w	#280,d1
	ble.s	vertok2

	move.w	#280,d1

vertok2
	move.w	d1,spriteVert



	moveq	#64,d2			height of sprites
	add.w	d1,d2

	lsl.w	#8,d2
	bcc.s	novstop8

	addq.w	#2,d2			set vstop bit 8

novstop8
	lsl.w	#8,d1
	bcc.s	novstart8

	addq.w	#4,d2			set vstart bit 8

novstart8
	lsr.w	#1,d0
	bcc.s	nohstart0

	addq.w	#1,d2			set hstart bit 0

nohstart0
	move.b	d0,d1

	or.w	#%10000000,d2		set attach bit



	move.w	d1,ktsprite0
	move.w	d1,ktsprite1
	addq.b	#8,d1
	move.w	d1,ktsprite2
	move.w	d1,ktsprite3
	addq.b	#8,d1
	move.w	d1,ktsprite4
	move.w	d1,ktsprite5
	addq.b	#8,d1
	move.w	d1,ktsprite6
	move.w	d1,ktsprite7

	move.w	d2,ktsprite0+2
	move.w	d2,ktsprite1+2
	move.w	d2,ktsprite2+2
	move.w	d2,ktsprite3+2
	move.w	d2,ktsprite4+2
	move.w	d2,ktsprite5+2
	move.w	d2,ktsprite6+2
	move.w	d2,ktsprite7+2
	rts


;	move.w	spriteHoriz(pc),d0
;	bsr	make.decimal
;	moveq	#14,d0
;	moveq	#120,d1
;	lea	decimal.text(pc),a0
;	bsr.s	print

;	move.w	spriteVert(pc),d0
;	bsr	make.decimal
;	moveq	#19,d0
;	moveq	#120,d1
;	lea	decimal.text(pc),a0
;	bra.s	print
	ENDC




;""""""""""""""""""""""
;" PIXEL PLOT ROUTINE "
;"		      "
;""""""""""""""""""""""

	IFD	NOT_USED
clear.pixel				; d0 = x, d1 = y
	move.l	screen1(pc),a0		; d0-d1 and a0-a1 trashed
	lea	y.table(pc),a1
	add.w	d1,d1
	add.w	d1,d1
	add.l	(a1,d1.w),a0		address of line containing pixel
	moveq	#$f,d1
	and.w	d0,d1
	sub.w	d1,d0
	lsr.w	#3,d0
	add.w	d0,a0			address of word containing pixel
	add.w	d1,d1
	move.w	pixel.masks(pc,d1.w),d0	positive mask
	not.w	d0			make negative mask

	and.w	d0,(a0)			plane1
	and.w	d0,44(a0)		plane2
	and.w	d0,88(a0)		plane3
	and.w	d0,132(a0)		plane4
	rts
	ENDC




* Plot a double pixel (i.e. width of 2).  Assumes x is always even
* d6.w = x, d7.w = y
* d4.w to d7.w trashed
* Outputs d4.w = offset of pixel mask, d5.l = offset of word containing pixel
plotPixel
;	add.w	#AMIGA_X_OFFSET,d6
	tst.w	d6			check x is onscreen
	bmi.s	failedPlotPixel	less than 0 ?
	cmp.w	#SCREEN_WIDTH-1,d6
	bgt.s	failedPlotPixel	greater than SCREEN_WIDTH-1 ?

	tst.w	d7			check y is onscreen
	bmi.s	failedPlotPixel	less than 0 ?
	cmp.w	#SCREEN_HEIGHT-1,d7
	bgt.s	failedPlotPixel	greater than SCREEN_HEIGHT-1 ?

	move.w	newColour(pc),d5
;	cmp.w	oldColour(pc),d5
;	beq.s	.plotColourOK
;	move.w	d5,oldColour
;	lsl.w	#4,d5			16 bytes of instructions
;	lea	plotIns(pc,d5.w),a0
;	lea	plotPixelNow(pc),a1
;	move.l	(a0)+,(a1)+		copy instructions
;	move.l	(a0)+,(a1)+
;	move.l	(a0)+,(a1)+
;	move.l	(a0),(a1)
	add.w	d5,d5
	add.w	d5,d5
;	move.l	plotTable(pc,d5.w),a2
	lea	plotTable(pc),a2
	move.l	(a2,d5.w),a2

;.plotColourOK
	move.l	screen1(pc),a0
	lea	yTable(pc),a1
	add.w	d7,d7
	add.w	d7,d7
;	add.l	(a1,d7.w),a0		address of line containing pixel
	move.l	(a1,d7.w),d5		offset of line containing pixel
	moveq	#$f,d4
	and.w	d6,d4
	sub.w	d4,d6
	lsr.w	#3,d6
;	add.w	d6,a0			address of word containing pixel
	and.l	#$ffff,d6		TODO optimise this block to remove this slow instruction
	add.l	d6,d5			offset of word containing pixel
	add.l	d5,a0			address of word containing pixel
	add.w	d4,d4
	move.w	pixelMasks(pc,d4.w),d6	positive mask
;plotPixelQuick
	move.w	d6,d7
	not.w	d7			make negative mask

;plotPixelNow
	jmp	(a2)

;successPlotPixel
;	rts

failedPlotPixel
	moveq	#-1,d5
	rts


newColour	dc.w	0
;oldColour	dc.w	0




* Save target bitplane words then plot a double pixel (i.e. width of 2).  Assumes x is always even
* d6.w = x, d7.w = y, a5.l = destination address for save data (long screen address, then 'SCREEN_DEPTH' words of bitplane data)
* d6.w to d7.w trashed
plotPixelWithSave
;	add.w	#AMIGA_X_OFFSET,d6
;	tst.w	d6			check x is onscreen
;	bmi.s	failedPlotPixel	less than 0 ?
;	cmp.w	#SCREEN_WIDTH-1,d6
;	bgt.s	failedPlotPixel	greater than SCREEN_WIDTH-1 ?

;	tst.w	d7			check y is onscreen
;	bmi.s	failedPlotPixel	less than 0 ?
;	cmp.w	#SCREEN_HEIGHT-1,d7
;	bgt.s	failedPlotPixel	greater than SCREEN_HEIGHT-1 ?

	move.l	screen1(pc),a0
	lea	yTable(pc),a1
	add.w	d7,d7
	add.w	d7,d7
	add.l	(a1,d7.w),a0		address of line containing pixel
	moveq	#$f,d7
	and.w	d6,d7
	sub.w	d7,d6
	lsr.w	#3,d6
	add.w	d6,a0			address of word containing pixel

* Save original screen data (NB done in reverse order to work with .removeOldFlakesLoop)
	move.w	PLANE_4_OFFSET(a0),(a5)+
	move.w	PLANE_3_OFFSET(a0),(a5)+
	move.w	PLANE_2_OFFSET(a0),(a5)+
	move.w	(a0),(a5)+
	move.l	a0,(a5)+

	move.w	newColour(pc),d6
	add.w	d6,d6
	add.w	d6,d6
	move.l	plotTable(pc,d6.w),a2

	add.w	d7,d7
	move.w	pixelMasks(pc,d7.w),d6	positive mask
	move.w	d6,d7
	not.w	d7			make negative mask
	jmp	(a2)




;pixelMasks	;Values for original single pixel plot
;	dc.w	$8000,$4000,$2000,$1000,$0800,$0400,$0200,$0100
;	dc.w	$0080,$0040,$0020,$0010,$0008,$0004,$0002,$0001
pixelMasks
	dc.w	$c000,$c000,$3000,$3000,$0c00,$0c00,$0300,$0300
	dc.w	$00c0,$00c0,$0030,$0030,$000c,$000c,$0003,$0003




plotTable
	dc.l	plot0,plot1,plot2,plot3,plot4,plot5,plot6,plot7,plot8,plot9,plot10,plot11,plot12,plot13,plot14,plot15
	dc.l	plotX0,plotX1,plotX2,plotX3,plotX4,plotX5,plotX6,plotX7,plotX8,plotX9,plotX10,plotX11,plotX12,plotX13,plotX14,plotX15



;plotIns
plot0	and.w	d7,(a0)
	and.w	d7,PLANE_2_OFFSET(a0)
	and.w	d7,PLANE_3_OFFSET(a0)
	and.w	d7,PLANE_4_OFFSET(a0)
	rts

plot1	or.w	d6,(a0)
	and.w	d7,PLANE_2_OFFSET(a0)
	and.w	d7,PLANE_3_OFFSET(a0)
	and.w	d7,PLANE_4_OFFSET(a0)
	rts

plot2	and.w	d7,(a0)
	or.w	d6,PLANE_2_OFFSET(a0)
	and.w	d7,PLANE_3_OFFSET(a0)
	and.w	d7,PLANE_4_OFFSET(a0)
	rts

plot3	or.w	d6,(a0)
	or.w	d6,PLANE_2_OFFSET(a0)
	and.w	d7,PLANE_3_OFFSET(a0)
	and.w	d7,PLANE_4_OFFSET(a0)
	rts

plot4	and.w	d7,(a0)
	and.w	d7,PLANE_2_OFFSET(a0)
	or.w	d6,PLANE_3_OFFSET(a0)
	and.w	d7,PLANE_4_OFFSET(a0)
	rts

plot5	or.w	d6,(a0)
	and.w	d7,PLANE_2_OFFSET(a0)
	or.w	d6,PLANE_3_OFFSET(a0)
	and.w	d7,PLANE_4_OFFSET(a0)
	rts

plot6	and.w	d7,(a0)
	or.w	d6,PLANE_2_OFFSET(a0)
	or.w	d6,PLANE_3_OFFSET(a0)
	and.w	d7,PLANE_4_OFFSET(a0)
	rts

plot7	or.w	d6,(a0)
	or.w	d6,PLANE_2_OFFSET(a0)
	or.w	d6,PLANE_3_OFFSET(a0)
	and.w	d7,PLANE_4_OFFSET(a0)
	rts

plot8	and.w	d7,(a0)
	and.w	d7,PLANE_2_OFFSET(a0)
	and.w	d7,PLANE_3_OFFSET(a0)
	or.w	d6,PLANE_4_OFFSET(a0)
	rts

plot9	or.w	d6,(a0)
	and.w	d7,PLANE_2_OFFSET(a0)
	and.w	d7,PLANE_3_OFFSET(a0)
	or.w	d6,PLANE_4_OFFSET(a0)
	rts

plot10	and.w	d7,(a0)
	or.w	d6,PLANE_2_OFFSET(a0)
	and.w	d7,PLANE_3_OFFSET(a0)
	or.w	d6,PLANE_4_OFFSET(a0)
	rts

plot11	or.w	d6,(a0)
	or.w	d6,PLANE_2_OFFSET(a0)
	and.w	d7,PLANE_3_OFFSET(a0)
	or.w	d6,PLANE_4_OFFSET(a0)
	rts

plot12	and.w	d7,(a0)
	and.w	d7,PLANE_2_OFFSET(a0)
	or.w	d6,PLANE_3_OFFSET(a0)
	or.w	d6,PLANE_4_OFFSET(a0)
	rts

plot13	or.w	d6,(a0)
	and.w	d7,PLANE_2_OFFSET(a0)
	or.w	d6,PLANE_3_OFFSET(a0)
	or.w	d6,PLANE_4_OFFSET(a0)
	rts

plot14	and.w	d7,(a0)
	or.w	d6,PLANE_2_OFFSET(a0)
	or.w	d6,PLANE_3_OFFSET(a0)
	or.w	d6,PLANE_4_OFFSET(a0)
	rts

plot15	or.w	d6,(a0)
	or.w	d6,PLANE_2_OFFSET(a0)
	or.w	d6,PLANE_3_OFFSET(a0)
	or.w	d6,PLANE_4_OFFSET(a0)
	rts

;plotInsXor
plotX0	rts

plotX1	eor.w	d6,(a0)
	rts

plotX2	eor.w	d6,PLANE_2_OFFSET(a0)
	rts

plotX3	eor.w	d6,(a0)
	eor.w	d6,PLANE_2_OFFSET(a0)
	rts

plotX4	eor.w	d6,PLANE_3_OFFSET(a0)
	rts

plotX5	eor.w	d6,(a0)
	eor.w	d6,PLANE_3_OFFSET(a0)
	rts

plotX6	eor.w	d6,PLANE_2_OFFSET(a0)
	eor.w	d6,PLANE_3_OFFSET(a0)
	rts

plotX7	eor.w	d6,(a0)
	eor.w	d6,PLANE_2_OFFSET(a0)
	eor.w	d6,PLANE_3_OFFSET(a0)
	rts

plotX8	eor.w	d6,PLANE_4_OFFSET(a0)
	rts

plotX9	eor.w	d6,(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)
	rts

plotX10	eor.w	d6,PLANE_2_OFFSET(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)
	rts

plotX11	eor.w	d6,(a0)
	eor.w	d6,PLANE_2_OFFSET(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)
	rts

plotX12	eor.w	d6,PLANE_3_OFFSET(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)
	rts

plotX13	eor.w	d6,(a0)
	eor.w	d6,PLANE_3_OFFSET(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)
	rts

plotX14	eor.w	d6,PLANE_2_OFFSET(a0)
	eor.w	d6,PLANE_3_OFFSET(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)
	rts

plotX15	eor.w	d6,(a0)
	eor.w	d6,PLANE_2_OFFSET(a0)
	eor.w	d6,PLANE_3_OFFSET(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)
	rts

	IFD OLD_XOR_VERSION
	;0
	eor.w	d6,(a0)
	nop
	eor.w	d6,PLANE_2_OFFSET(a0)
	eor.w	d6,PLANE_3_OFFSET(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)

	;1
	eor.w	d6,(a0)
	nop
	eor.w	d6,PLANE_2_OFFSET(a0)
	eor.w	d6,PLANE_3_OFFSET(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)

	;2
	eor.w	d6,(a0)
	nop
	eor.w	d6,PLANE_2_OFFSET(a0)
	eor.w	d6,PLANE_3_OFFSET(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)

	;3
	eor.w	d6,(a0)
	nop
	eor.w	d6,PLANE_2_OFFSET(a0)
	eor.w	d6,PLANE_3_OFFSET(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)

	;4
	eor.w	d6,(a0)
	nop
	eor.w	d6,PLANE_2_OFFSET(a0)
	eor.w	d6,PLANE_3_OFFSET(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)

	;5
	eor.w	d6,(a0)
	nop
	eor.w	d6,PLANE_2_OFFSET(a0)
	eor.w	d6,PLANE_3_OFFSET(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)

	;6
	eor.w	d6,(a0)
	nop
	eor.w	d6,PLANE_2_OFFSET(a0)
	eor.w	d6,PLANE_3_OFFSET(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)

	;7
	eor.w	d6,(a0)
	nop
	eor.w	d6,PLANE_2_OFFSET(a0)
	eor.w	d6,PLANE_3_OFFSET(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)

	;8
	eor.w	d6,(a0)
	nop
	eor.w	d6,PLANE_2_OFFSET(a0)
	eor.w	d6,PLANE_3_OFFSET(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)

	;9
	eor.w	d6,(a0)
	nop
	eor.w	d6,PLANE_2_OFFSET(a0)
	eor.w	d6,PLANE_3_OFFSET(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)

	;10
	eor.w	d6,(a0)
	nop
	eor.w	d6,PLANE_2_OFFSET(a0)
	eor.w	d6,PLANE_3_OFFSET(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)

	;11
	eor.w	d6,(a0)
	nop
	eor.w	d6,PLANE_2_OFFSET(a0)
	eor.w	d6,PLANE_3_OFFSET(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)

	;12
	eor.w	d6,(a0)
	nop
	eor.w	d6,PLANE_2_OFFSET(a0)
	eor.w	d6,PLANE_3_OFFSET(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)

	;13
	eor.w	d6,(a0)
	nop
	eor.w	d6,PLANE_2_OFFSET(a0)
	eor.w	d6,PLANE_3_OFFSET(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)

	;14
	eor.w	d6,(a0)
	nop
	eor.w	d6,PLANE_2_OFFSET(a0)
	eor.w	d6,PLANE_3_OFFSET(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)

	;15
	eor.w	d6,(a0)
	nop
	eor.w	d6,PLANE_2_OFFSET(a0)
	eor.w	d6,PLANE_3_OFFSET(a0)
	eor.w	d6,PLANE_4_OFFSET(a0)
	ENDC




;"""""""""""""""""""""
;" OTHER SUBROUTINES "
;"		     "
;"""""""""""""""""""""

	IFD	NOT_USED
keyboard.requests
	tst.b	frames.requested
	beq.s	no.request1

	bsr	frames.per.sec

no.request1
	tst.b	palette.requested
	beq.s	no.request2

	bsr.s	display.palette
	bsr	update.screens

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
	bsr.s	fill.box

;;	addq.w	#4,fill.colour+2	next colour
	add.w	#SCREEN_WIDTH/8,d2	next start x
	dbra	d3,next.column

	add.w	#25,d0			next start y
	dbra	d1,next.row
	rts




fill.box
	movem.w	d0-d3,-(sp)

	move.w	d2,d3
	add.w	#30,d3			31 pixels wide
	moveq	#20-1,d1		20 pixels tall

	lea	fill.coords(pc),a1
	move.w	d0,(a1)+		save start y

fill.box.loop
	move.w	d2,(a1)+		save start x
	move.w	d3,(a1)+		save end x
	dbra	d1,fill.box.loop

;;	bsr	fill

	movem.w	(sp)+,d0-d3
	rts
	ENDC




* Hard-coded to print in color 7
print	move.l	screen1(pc),a1		d0 = x, d1 = y
	add.w	d1,d1			a0 = text ending with 0
	add.w	d1,d1
	lea	yTable(pc),a2
	add.l	(a2,d1.w),a1
	add.w	d0,a1			screen start address
	moveq	#0,d1
	move.w	#SCREEN_WIDTH/8*SCREEN_DEPTH,d2		bytes per line (width of all bitplanes)

.printLoop
	move.b	(a0)+,d0		get next character
	beq.s	.endPrint

	sub.b	#32,d0			ASCII value for space
	ext.w	d0
	lsl.w	#3,d0			8 bytes per character of font
	lea	font(pc,d0.w),a3	source start address

	moveq	#8-1,d0			count-1
	move.l	a1,a2

.charLoop
	move.b	(a3)+,d1
	move.b	d1,(a2)			copy byte of character, bitplane 1
	move.b	d1,PLANE_2_OFFSET(a2)	bitplane 2
	move.b	d1,PLANE_3_OFFSET(a2)	bitplane 3
	clr.b	PLANE_4_OFFSET(a2)	bitplane 4

	add.w	d2,a2			next screen line
	dbra	d0,.charLoop

	addq.w	#1,a1			next column
	bra.s	.printLoop

.endPrint
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




makeHexWord			; d0.w = number
	lea	hexText(pc),a0
makeHexWord2
	moveq	#4-1,d1
	bra.s	makeHex

makeHexLong			; d0.l = number
	lea	hexText(pc),a0
makeHexLong2
	moveq	#8-1,d1

makeHex
	lea	hexDigits(pc),a1

.loop	move.w	d0,d2
	and.w	#$f,d2
	move.b	(a1,d2.w),(a0,d1.w)
	ror.l	#4,d0
	dbra	d1,.loop
	rts


hexDigits
	dc.b	'0123456789ABCDEF'


hexText
	ds.b	9
	even


	IFD	NOT_USED
makeDecimal
	and.l	#$ffff,d0		d0.w = number (0-65535)
	move.w	#10000,d1		start with 10000's
	lea	decimalText(pc),a0
	moveq	#0,d4			miss off leading zeros

.makeDecLoop
	move.l	d0,d2
	divu	d1,d2			calculate digit

	bne.s	.saveDigit		if digit is not zero then save it
	tst.b	d4			if flag is zero
	bne.s	.saveDigit
	move.b	#' ',(a0)+		then miss this zero digit
	bra.s	.nextPosition

.saveDigit
	moveq	#1,d4			don't miss off any more zeros
	move.b	d2,d3
	add.b	#48,d3			offset for ASCII digits
	move.b	d3,(a0)+		save decimal digit

	mulu	d1,d2			move digit back to correct place
	sub.l	d2,d0			remove from original number

.nextPosition
	ext.l	d1
	divu	#10,d1			next decimal position
	cmp.w	#1,d1			have we reached units ?
	bne.s	.makeDecLoop		loop back if not

	add.b	#48,d0			offset for ASCII digits
	move.b	d0,(a0)			save units
	rts



decimalText
	ds.b	6
	ENDC




	IFD	NOT_USED
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




updateScreens
	move.l	screen1(pc),d0
	move.l	screen2(pc),screen1
	move.l	d0,screen2

	move.l	copper1(pc),d0
	move.l	copper2(pc),copper1
	move.l	d0,copper2

	move.l	d0,cop1lch(a6)		set new copper list address
	move.w	d0,copjmp1(a6)
	rts
	ENDC




makeCopperLists
	move.l	screen1(pc),d0
	move.l	copper1(pc),a0
	bsr.s	initCopper

	move.l	screen2(pc),d0
	move.l	copper2(pc),a0
;	bra.s	initCopper
	bsr.s	initCopper

	IFD	SHOW_KINGTUT_SPRITES
	move.l	#ktsprite0,d3
	ELSE

	IFD	SNOWFLAKES_USE_HARDWARE_SPRITES
	move.l	#sprite0,d3
	ELSE
	move.l	#disabledSprite,d3
	ENDC

	ENDC

	move.l	d3,d0
	move.l	#copperList1Sprites,a0
	bsr.s	initCopperSprites

	move.l	d3,d0
	move.l	#copperList2Sprites,a0
	bra.s	initCopperSprites




initCopper
	moveq	#4-1,d1
	moveq	#SCREEN_WIDTH/8,d2	width of one bitplane

.nextPlane
	move.w	d0,6(a0)		save low word
	swap	d0
	move.w	d0,2(a0)		save high word
	swap	d0
	add.l	d2,d0			next bitplane
	addq.w	#8,a0			update pointer to copper list
	dbra	d1,.nextPlane
	rts




initCopperSprites
	moveq	#8-1,d1
	IFD	SHOW_KINGTUT_SPRITES
	move.l	#66*2*2,d2		size of data for one sprite
	ELSE

	IFD	SNOWFLAKES_USE_HARDWARE_SPRITES
	move.l	#SNOWFLAKES_HARDWARE_SPRITE_WORDS*2,d2
	ELSE
	moveq	#0,d2
	ENDC

	ENDC

.nextSprite
	move.w	d0,6(a0)		save low word
	swap	d0
	move.w	d0,2(a0)		save high word
	swap	d0
	add.l	d2,d0			next sprite
	addq.w	#8,a0			update pointer to copper list
	dbra	d1,.nextSprite
	rts




****************************************

* Taken from StuntCarRacer
setRandomValues
	move.l	randomSeed,randomLong
	move.b	randomSeed+1,randomByte
	rts


randomSeed	dc.l	$3b3b1e49,$3b3b3562


randomizeLong
	move.w	randomLong+2,d4
	lsr.w	#4,d4
	move.w	randomLong,d3
	lsr.w	#1,d3
	eor.b	d3,d4
	move.l	randomLong,d3
	asl.l	#8,d3
	move.b	randomByte,d3
	move.l	d3,randomLong
	move.b	d4,randomByte
	rts


randomLong	dc.l	0
randomByte	dc.b	0,0


****************************************


;"""""""""""""
;" VARIABLES "
;"	     "
;"""""""""""""

screenMemory	dc.l	0

screen1		dc.l	0
screen2		dc.l	0

copper1		dc.l	copperList1
copper2		dc.l	copperList2

yTable	ds.l	SCREEN_HEIGHT

;raw.key.code	dc.b	0
;palette.requested	dc.b	0
;frames.requested	dc.b	0
;auto.move	dc.b	0
	IFD	USE_STARTUP
VBlankOccured	dc.b	0
	ELSE
CopperIntOccured	dc.b	0
	ENDC
	even

;mouse.data	dc.b	0,0
;old.mouse.x	dc.b	0
;old.mouse.y	dc.b	0

	IFD	SHOW_KINGTUT_SPRITES
spriteHoriz	dc.w	256		start in centre of screen
spriteVert	dc.w	140

registerMouseX	dc.b	0
registerMouseY	dc.b	0
	ENDC




;"""""""""""""
;" CONSTANTS "
;"	     "
;"""""""""""""

	IFD	SNOWFLAKES_USE_HARDWARE_SPRITES
spriteColourTable
	dc.w	$000,$fff,$0f0,$00f,$000,$fff,$0f0,$00f
	dc.w	$000,$fff,$0f0,$00f,$000,$fff,$0f0,$00f
	ELSE
* Colours 0-3 for harpoon and attach effect
* Colours 4-7 for icicle
spriteColourTable
	dc.w	$000,$00f,$0ff,$fff,$000,$f00,$0f0,$ff0
	dc.w	$000,$fff,$0f0,$00f,$000,$fff,$0f0,$00f
	ENDC




;"""""""""""""""""
;" GRAPHICS DATA "
;"		 "
;"""""""""""""""""
	section graphicsData,data_c

	IFD	SHOW_KINGTUT_SPRITES
ktsprite0
	dc.w	$8c80,$cc00
	dc.w	$7de0,$0ff8
	dc.w	$3ef3,$09f8
	dc.w	$0f62,$04fd
	dc.w	$018b,$037e
	dc.w	$68df,$49bc
	dc.w	$7e65,$36de
	dc.w	$56ab,$24de
	dc.w	$4693,$7e2f
	dc.w	$69c9,$6f17
	dc.w	$0ec9,$0f8f
	dc.w	$67e5,$1fd7
	dc.w	$3ff0,$4def
	dc.w	$07ae,$7f47
	dc.w	$72db,$0f6e
	dc.w	$7e77,$06f3
	dc.w	$7d7d,$6017
	dc.w	$7ffb,$7fed
	dc.w	$41dc,$3e75
	dc.w	$5fab,$3234
	dc.w	$49f2,$3602
	dc.w	$7ffc,$7ff4
	dc.w	$7ffe,$7ffe
	dc.w	$7fe4,$7ffc
	dc.w	$3ff0,$7ffe
	dc.w	$7c40,$03be
	dc.w	$3e0c,$41f3
	dc.w	$7fca,$7ffb
	dc.w	$7feb,$7f77
	dc.w	$3fab,$7ff7
	dc.w	$7e09,$01ff
	dc.w	$7e9b,$217d
	dc.w	$7fef,$7fed
	dc.w	$7ff3,$201d
	dc.w	$3e17,$41e7
	dc.w	$7fc2,$3fb4
	dc.w	$7f8f,$007c
	dc.w	$7ff7,$07ec
	dc.w	$7fc4,$073f
	dc.w	$7e01,$01ff
	dc.w	$7904,$06fb
	dc.w	$3c82,$437d
	dc.w	$7ffc,$7de7
	dc.w	$7ff0,$7f3f
	dc.w	$1964,$669b
	dc.w	$7ffe,$0001
	dc.w	$57e0,$285f
	dc.w	$7fe0,$7fff
	dc.w	$1300,$6cff
	dc.w	$0002,$7fff
	dc.w	$6208,$1df7
	dc.w	$7fff,$0000
	dc.w	$13e4,$6c1b
	dc.w	$7ff9,$7fc7
	dc.w	$3ffc,$7fe3
	dc.w	$68f8,$1747
	dc.w	$7fff,$7fff
	dc.w	$7fc7,$7fc5
	dc.w	$7ffc,$0003
	dc.w	$7ede,$0121
	dc.w	$6fff,$7c62
	dc.w	$423f,$7fd6
	dc.w	$7ffd,$0002
	dc.w	$7e7f,$0180
	dc.w	$3f3f,$40c0
	dc.w	$0000,$0000

ktsprite1
	dc.w	$8c80,$cc80
	dc.w	$71ff,$01e0
	dc.w	$36ff,$40f0
	dc.w	$0b7a,$7000
	dc.w	$408d,$7c38
	dc.w	$785f,$3604
	dc.w	$7e27,$0908
	dc.w	$57ab,$0f06
	dc.w	$4793,$47c5
	dc.w	$69c9,$79e3
	dc.w	$0ee1,$7e72
	dc.w	$6761,$0678
	dc.w	$33b0,$0119
	dc.w	$00ac,$001c
	dc.w	$709b,$0006
	dc.w	$0716,$781e
	dc.w	$62ed,$7d03
	dc.w	$7ff3,$7c22
	dc.w	$419c,$0017
	dc.w	$4dc1,$000b
	dc.w	$49fe,$0001
	dc.w	$7ff9,$1e02
	dc.w	$7ff9,$7fc8
	dc.w	$7ffe,$7fe5
	dc.w	$7ffd,$3ff1
	dc.w	$7c40,$0001
	dc.w	$7e0c,$001c
	dc.w	$7fde,$0024
	dc.w	$7f7b,$60cd
	dc.w	$7fbe,$3008
	dc.w	$7e1d,$000b
	dc.w	$5e9f,$000b
	dc.w	$7fff,$4037
	dc.w	$2017,$7ffb
	dc.w	$7e17,$000f
	dc.w	$404f,$000a
	dc.w	$7f8f,$000e
	dc.w	$07ef,$7813
	dc.w	$073e,$78c0
	dc.w	$7e00,$0000
	dc.w	$7904,$0000
	dc.w	$7c82,$0000
	dc.w	$7de7,$721c
	dc.w	$7f3f,$7ef0
	dc.w	$1964,$0000
	dc.w	$7ffe,$0000
	dc.w	$57a0,$0000
	dc.w	$7fff,$7fe0
	dc.w	$6cff,$1300
	dc.w	$7fff,$0002
	dc.w	$6208,$0000
	dc.w	$7fff,$0000
	dc.w	$13e4,$0000
	dc.w	$7fc1,$71bf
	dc.w	$7fe0,$38df
	dc.w	$68b8,$0000
	dc.w	$7fff,$0000
	dc.w	$7fc5,$7fff
	dc.w	$7ffc,$0000
	dc.w	$7ede,$0000
	dc.w	$7c62,$6fff
	dc.w	$7fd6,$423f
	dc.w	$7ffd,$0000
	dc.w	$7e7f,$0000
	dc.w	$7f3f,$0000
	dc.w	$0000,$0000
	
ktsprite2
	dc.w	$8c88,$cc00
	dc.w	$69d8,$f1e0
	dc.w	$793b,$752b
	dc.w	$7d5a,$180b
	dc.w	$ad5c,$305c
	dc.w	$b5a8,$7aa6
	dc.w	$acae,$6fa8
	dc.w	$ccc4,$2ffe
	dc.w	$ec8c,$8bfe
	dc.w	$58a0,$bff7
	dc.w	$f020,$d707
	dc.w	$b390,$d03f
	dc.w	$de90,$cd37
	dc.w	$6800,$fba7
	dc.w	$8806,$fb9f
	dc.w	$8440,$f1cf
	dc.w	$a000,$701f
	dc.w	$081f,$881f
	dc.w	$8a00,$8aff
	dc.w	$499e,$8f9e
	dc.w	$0784,$0787
	dc.w	$8118,$2f1f
	dc.w	$d81c,$9fdc
	dc.w	$1fc3,$3bdf
	dc.w	$2ffb,$67fb
	dc.w	$4c7d,$cfff
	dc.w	$88ed,$8dfd
	dc.w	$a853,$bfdb
	dc.w	$9857,$9bbf
	dc.w	$65e3,$fa13
	dc.w	$143b,$87eb
	dc.w	$0fe6,$8476
	dc.w	$0fe5,$84ed
	dc.w	$8fed,$002d
	dc.w	$8fcd,$c05d
	dc.w	$0fdf,$405f
	dc.w	$87de,$c07f
	dc.w	$83f8,$c13f
	dc.w	$81e2,$e13f
	dc.w	$c1fc,$601d
	dc.w	$c1f7,$b017
	dc.w	$41e5,$d027
	dc.w	$01e0,$d01f
	dc.w	$1180,$d967
	dc.w	$7121,$8de5
	dc.w	$11e0,$f3e7
	dc.w	$0073,$f977
	dc.w	$3e3f,$febf
	dc.w	$010e,$fd4f
	dc.w	$40cf,$ffef
	dc.w	$002e,$ffaf
	dc.w	$e11f,$1f7f
	dc.w	$0177,$fe77
	dc.w	$c1ef,$3fff
	dc.w	$e5fa,$9e7a
	dc.w	$046a,$fe7a
	dc.w	$047c,$267c
	dc.w	$f873,$3a71
	dc.w	$371f,$cf1f
	dc.w	$75df,$8fdd
	dc.w	$ffce,$f5ce
	dc.w	$fd63,$7fe3
	dc.w	$c5ff,$3ffd
	dc.w	$f476,$0ef2
	dc.w	$fa3b,$0779
	dc.w	$0000,$0000
	
ktsprite3
	dc.w	$8c88,$cc80
	dc.w	$eff8,$61c7
	dc.w	$fb33,$31e4
	dc.w	$9612,$71e6
	dc.w	$fe7e,$019f
	dc.w	$b4d2,$0109
	dc.w	$a8d8,$100f
	dc.w	$e8de,$1005
	dc.w	$6cfe,$100d
	dc.w	$58f8,$0008
	dc.w	$b04c,$88f8
	dc.w	$b374,$0cc0
	dc.w	$fefc,$0448
	dc.w	$486e,$c458
	dc.w	$8806,$4460
	dc.w	$0840,$6e70
	dc.w	$a81d,$6fe0
	dc.w	$781f,$77fe
	dc.w	$faff,$7700
	dc.w	$6f9f,$f9fd
	dc.w	$d787,$fffb
	dc.w	$d09f,$f067
	dc.w	$e02f,$4003
	dc.w	$5bc3,$8ce0
	dc.w	$bffb,$1c37
	dc.w	$7fff,$3c59
	dc.w	$da3f,$700b
	dc.w	$e43b,$4017
	dc.w	$7a6f,$0442
	dc.w	$65f3,$000e
	dc.w	$7feb,$f836
	dc.w	$7c77,$fbe9
	dc.w	$7cf7,$fbfa
	dc.w	$783f,$ffd2
	dc.w	$b86f,$7ff7
	dc.w	$bc7f,$7feb
	dc.w	$be5f,$7ff2
	dc.w	$bf3d,$7fe8
	dc.w	$9f3f,$7fe2
	dc.w	$de1d,$3ff2
	dc.w	$0e1f,$7ff8
	dc.w	$6e3f,$5ff9
	dc.w	$ee3f,$1fe0
	dc.w	$f707,$1ff8
	dc.w	$63ff,$1f1b
	dc.w	$1dff,$0798
	dc.w	$06f7,$038b
	dc.w	$ff7f,$39c7
	dc.w	$fbbf,$00f6
	dc.w	$fcdf,$4031
	dc.w	$007f,$001e
	dc.w	$e1df,$0007
	dc.w	$00ff,$015f
	dc.w	$3de8,$c090
	dc.w	$9c75,$e5c0
	dc.w	$0465,$0590
	dc.w	$dc77,$fd84
	dc.w	$397c,$fd82
	dc.w	$3618,$06e8
	dc.w	$7650,$0422
	dc.w	$f541,$fe30
	dc.w	$7dec,$e010
	dc.w	$c570,$0140
	dc.w	$f7f9,$0150
	dc.w	$fbfc,$00a8
	dc.w	$0000,$0000
	
ktsprite4
	dc.w	$8c90,$cc00
	dc.w	$3789,$37b5
	dc.w	$02d3,$feeb
	dc.w	$0033,$ca43
	dc.w	$0036,$cc06
	dc.w	$026f,$4a07
	dc.w	$83fc,$cfed
	dc.w	$719e,$ffbf
	dc.w	$712c,$f98b
	dc.w	$77cd,$ffca
	dc.w	$442d,$4fae
	dc.w	$424a,$4f8c
	dc.w	$01db,$055c
	dc.w	$305d,$34d9
	dc.w	$b31a,$b5f4
	dc.w	$b3cd,$b5f9
	dc.w	$8388,$b7ac
	dc.w	$8387,$ffaf
	dc.w	$0005,$fffd
	dc.w	$c408,$bc0c
	dc.w	$023a,$7a3d
	dc.w	$1c3d,$e3fe
	dc.w	$0800,$0ff9
	dc.w	$e032,$fb82
	dc.w	$d873,$fe66
	dc.w	$140f,$ffe7
	dc.w	$c717,$3baf
	dc.w	$1a37,$d9d9
	dc.w	$681b,$4dfb
	dc.w	$77a4,$405f
	dc.w	$7e06,$3786
	dc.w	$7f82,$3bda
	dc.w	$5fc2,$77de
	dc.w	$2fe3,$5ef1
	dc.w	$fbe1,$ed7f
	dc.w	$e863,$bb1a
	dc.w	$b8c0,$f330
	dc.w	$1c00,$ffe0
	dc.w	$0251,$db90
	dc.w	$2543,$fd40
	dc.w	$a273,$bc31
	dc.w	$e3d7,$e653
	dc.w	$85e7,$8067
	dc.w	$90cf,$8347
	dc.w	$bc78,$a89c
	dc.w	$0efd,$f61d
	dc.w	$28fe,$f0bf
	dc.w	$f0da,$f8e9
	dc.w	$089b,$ccd9
	dc.w	$e8f0,$ecf9
	dc.w	$d964,$f9e9
	dc.w	$f9ca,$fbfd
	dc.w	$eff8,$ffdf
	dc.w	$fd60,$fdf7
	dc.w	$ee40,$a867
	dc.w	$ee60,$f2e7
	dc.w	$ca21,$8822
	dc.w	$b159,$015a
	dc.w	$fb63,$e367
	dc.w	$8679,$0877
	dc.w	$ef4a,$e347
	dc.w	$e663,$e86e
	dc.w	$e66b,$c067
	dc.w	$a7ed,$01e7
	dc.w	$53f6,$00f3
	dc.w	$0000,$0000
	
ktsprite5
	dc.w	$8c90,$cc80
	dc.w	$078d,$cbc3
	dc.w	$7adb,$0187
	dc.w	$fc3b,$0187
	dc.w	$cc36,$33cf
	dc.w	$3277,$858e
	dc.w	$c3fc,$b22e
	dc.w	$c9be,$415c
	dc.w	$c928,$475c
	dc.w	$fff9,$423c
	dc.w	$7fed,$c05c
	dc.w	$4f6b,$f238
	dc.w	$359b,$cb30
	dc.w	$781f,$b338
	dc.w	$c91a,$0221
	dc.w	$c9dd,$03f2
	dc.w	$fba8,$0077
	dc.w	$bfaf,$0078
	dc.w	$fffd,$001a
	dc.w	$bc0c,$47f3
	dc.w	$fe3f,$fdc6
	dc.w	$fc03,$fc03
	dc.w	$f807,$f001
	dc.w	$e3bb,$047e
	dc.w	$dffe,$f9bd
	dc.w	$ffef,$4019
	dc.w	$785f,$c41f
	dc.w	$fc07,$1a06
	dc.w	$7414,$f220
	dc.w	$7fa4,$f802
	dc.w	$3787,$ee79
	dc.w	$3bff,$efbd
	dc.w	$77ff,$dffd
	dc.w	$7efd,$afde
	dc.w	$fd7f,$f39e
	dc.w	$fffe,$57fd
	dc.w	$fffc,$8fff
	dc.w	$bff8,$13ff
	dc.w	$fbd8,$25ff
	dc.w	$f540,$5abf
	dc.w	$f431,$1fef
	dc.w	$fe53,$9fef
	dc.w	$8667,$ffde
	dc.w	$b347,$fdfe
	dc.w	$fd9e,$5f79
	dc.w	$fe1b,$0df9
	dc.w	$f0be,$0ffa
	dc.w	$f8f4,$f7d3
	dc.w	$ccf9,$37be
	dc.w	$ecf0,$d7be
	dc.w	$f964,$df9e
	dc.w	$fbce,$feb2
	dc.w	$effa,$f0f0
	dc.w	$0173,$03a8
	dc.w	$1047,$41b8
	dc.w	$0367,$13d8
	dc.w	$3421,$41ff
	dc.w	$4f59,$90f7
	dc.w	$076b,$02f8
	dc.w	$707d,$89fa
	dc.w	$134e,$02f9
	dc.w	$106b,$09f3
	dc.w	$586f,$61fa
	dc.w	$59ff,$807c
	dc.w	$acff,$403e
	dc.w	$0000,$0000
	
ktsprite6
	dc.w	$8c98,$cc00
	dc.w	$d980,$e7bf
	dc.w	$9bc0,$e3bf
	dc.w	$b7ff,$c387
	dc.w	$6f2b,$87cc
	dc.w	$67e0,$8408
	dc.w	$4da4,$8e37
	dc.w	$3f4f,$9c68
	dc.w	$bad7,$3c58
	dc.w	$75af,$28e0
	dc.w	$7f90,$612b
	dc.w	$7a4f,$713f
	dc.w	$a62c,$80ef
	dc.w	$018f,$0070
	dc.w	$001c,$04ef
	dc.w	$0138,$4247
	dc.w	$28cf,$a13f
	dc.w	$18c3,$da47
	dc.w	$9d00,$e8df
	dc.w	$16c8,$d737
	dc.w	$0bff,$c880
	dc.w	$89ff,$4a40
	dc.w	$1fcf,$b8ef
	dc.w	$21af,$07af
	dc.w	$7aff,$d950
	dc.w	$b39f,$ff70
	dc.w	$dc0f,$c9b8
	dc.w	$e9bf,$ffe8
	dc.w	$e13f,$b97f
	dc.w	$70bf,$eec0
	dc.w	$18df,$37e0
	dc.w	$3c6f,$06f0
	dc.w	$1dff,$577f
	dc.w	$83f0,$dfff
	dc.w	$d03f,$41c0
	dc.w	$623f,$6dc0
	dc.w	$461f,$75e0
	dc.w	$0060,$35df
	dc.w	$9000,$5fff
	dc.w	$f7ff,$e818
	dc.w	$dfdb,$e024
	dc.w	$0623,$07ff
	dc.w	$0fe0,$0fff
	dc.w	$4380,$439f
	dc.w	$06ff,$7900
	dc.w	$7c03,$8000
	dc.w	$2f27,$d0d8
	dc.w	$ffcc,$ff9f
	dc.w	$dfc3,$de7f
	dc.w	$6fe1,$ef3f
	dc.w	$ffc3,$03bc
	dc.w	$ffff,$0000
	dc.w	$1fbf,$e040
	dc.w	$c624,$ffff
	dc.w	$e312,$ffff
	dc.w	$8df3,$73fc
	dc.w	$8760,$ffff
	dc.w	$ff1f,$efff
	dc.w	$bfff,$c000
	dc.w	$8307,$c4f8
	dc.w	$ffff,$d300
	dc.w	$7fff,$ffc0
	dc.w	$9f00,$fcff
	dc.w	$f808,$07f7
	dc.w	$fc04,$83fb
	dc.w	$0000,$0000
	
ktsprite7
	dc.w	$8c98,$cc80
	dc.w	$d9a0,$81c0
	dc.w	$9fc0,$8380
	dc.w	$bfff,$0387
	dc.w	$7f3c,$070b
	dc.w	$77e8,$0e17
	dc.w	$6df7,$1c2c
	dc.w	$7fef,$1c58
	dc.w	$fbdf,$3070
	dc.w	$f7af,$10f0
	dc.w	$ff93,$11e4
	dc.w	$7e4f,$81cf
	dc.w	$be2c,$63bc
	dc.w	$19bf,$e700
	dc.w	$3950,$c600
	dc.w	$3138,$8e80
	dc.w	$5a8f,$8d14
	dc.w	$3dc7,$c078
	dc.w	$de9f,$5160
	dc.w	$5c48,$e080
	dc.w	$cf7f,$f000
	dc.w	$cdbf,$b000
	dc.w	$bbcf,$c33c
	dc.w	$a1af,$fe7f
	dc.w	$7eaf,$2000
	dc.w	$b78f,$8280
	dc.w	$ffc7,$d440
	dc.w	$fde8,$62b7
	dc.w	$7f7f,$66bf
	dc.w	$3cff,$3300
	dc.w	$1edf,$d900
	dc.w	$feef,$fd00
	dc.w	$dfff,$edc0
	dc.w	$cbff,$7770
	dc.w	$723f,$dd00
	dc.w	$7e3f,$f200
	dc.w	$5e1f,$ee00
	dc.w	$41df,$8e60
	dc.w	$3fff,$c000
	dc.w	$d7e7,$8000
	dc.w	$dfdb,$8000
	dc.w	$87ff,$7e23
	dc.w	$8fff,$7fe0
	dc.w	$c39f,$7fe0
	dc.w	$86ff,$0000
	dc.w	$7fff,$0000
	dc.w	$2f27,$0000
	dc.w	$ffbf,$01ec
	dc.w	$de7f,$7fc3
	dc.w	$6f3f,$3fe1
	dc.w	$fc43,$0000
	dc.w	$ffff,$0000
	dc.w	$1fbf,$0000
	dc.w	$ffff,$c624
	dc.w	$ffff,$6312
	dc.w	$0c03,$8000
	dc.w	$ffff,$0760
	dc.w	$efff,$3b1f
	dc.w	$bfff,$0000
	dc.w	$bb07,$8000
	dc.w	$d300,$ffff
	dc.w	$7fc0,$803f
	dc.w	$8300,$8000
	dc.w	$f808,$8000
	dc.w	$fc04,$4000
	dc.w	$0000,$0000

ktSpriteColourTable
	dc.w	$000,$558,$001,$012,$023,$003,$310,$850
	dc.w	$640,$740,$a72,$850,$a71,$d93,$fc5,$530
	ELSE


tileBitmap
	incbin	MP/tileNew2.bin
tileBitmapSize	equ	*-tileBitmap


	IFD	ATTACH_EFFECT_USE_HARDWARE_SPRITES
attachEffectSprite
	ds.w	2					; two control words
	dc.w	%1100000000000000,%1100000000000000	; two data words * sprite height
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000110000000000,%0000110000000000
	dc.w	0,0					; two end words
	ENDC


	section	chip_data,bss_c

tileBitmapMasks
	ds.b	tileBitmapSize-32	NB excluding colour data


tileBitmapFlippedInX
	ds.b	tileBitmapSize		NB including size of colour data, but only to give correct mask offset

;NB this must immediately follow tileBitmapFlippedInX
tileBitmapMasksFlippedInX
	ds.b	tileBitmapSize-32	NB excluding colour data


savedArea1A	ds.w	16*3*4		16 lines * 3 words * 4 bitplanes
savedArea1B	ds.w	16*3*4		16 lines * 3 words * 4 bitplanes
savedArea2A	ds.w	16*3*4
savedArea2B	ds.w	16*3*4
savedArea3A	ds.w	16*3*4
savedArea3B	ds.w	16*3*4
savedArea4A	ds.w	16*3*4
savedArea4B	ds.w	16*3*4


	IFD	SNOWFLAKES_USE_HARDWARE_SPRITES
* NB initCopperSprites assumes all sprites are contiguous
	even
sprite0
	ds.w	SNOWFLAKES_HARDWARE_SPRITE_WORDS
sprite1
	ds.w	SNOWFLAKES_HARDWARE_SPRITE_WORDS
sprite2
	ds.w	SNOWFLAKES_HARDWARE_SPRITE_WORDS
sprite3
	ds.w	SNOWFLAKES_HARDWARE_SPRITE_WORDS
sprite4
	ds.w	SNOWFLAKES_HARDWARE_SPRITE_WORDS
sprite5
	ds.w	SNOWFLAKES_HARDWARE_SPRITE_WORDS
sprite6
	ds.w	SNOWFLAKES_HARDWARE_SPRITE_WORDS
sprite7
	ds.w	SNOWFLAKES_HARDWARE_SPRITE_WORDS

	ELSE

disabledSprite		; For sprites 0 to 7
	dc.w	0,0
harpoonSprite
	ds.w	2+(2*ITEMS_HEIGHT)+2	; two control words + (two data words * sprite height) + two end words
harpoonSpriteFlippedInX
	ds.w	2+(2*ITEMS_HEIGHT)+2
icicleSprite
	ds.w	2+(2*ITEMS_HEIGHT)+2	; two control words + (two data words * sprite height) + two end words

	ENDC

	ENDC




;""""""""""""""""""""
;" THE COPPER LISTS "
;"		    "
;""""""""""""""""""""
	section copperData,data_c

copperList1
	dc.w	bpl1pth,0		4 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

copperList1Sprites
	dc.w	spr0pth,0
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

	dc.w	$ffe1,$fffe		PAL enable

;	dc.w	$1001,$ff00
	dc.w	$0001,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe
	dc.w	$ffff,$fffe




copperList2
	dc.w	bpl1pth,0		4 bitplane display
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

copperList2Sprites
	dc.w	spr0pth,0
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

	dc.w	$ffe1,$fffe		PAL enable

;	dc.w	$1001,$ff00
	dc.w	$0001,$ff00

	dc.w	intreq,$8010

	dc.w	$ffff,$fffe
	dc.w	$ffff,$fffe




;""""""""""""""
;" SOUND DATA "
;"		 "
;""""""""""""""
	section soundData,data_c

walkLoSample
	incbin	sound_data/walklo.raw
walkHiSample
	incbin	sound_data/walkhi.raw
colSample
	incbin	sound_data/collided.raw
pickupSample
	incbin	sound_data/pickup.raw
ropeAttachSample
	incbin	sound_data/ropeAttach.raw
soundEerieSample
	incbin	sound_data/soundEerie.raw
itemUseSample
	incbin	sound_data/itemUse.raw
shoggothHitSample
	incbin	sound_data/shoggothHit.raw




;""""""""""""""""""""""
;" HARDWARE REGISTERS "
;"		      "
;""""""""""""""""""""""

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
aud0vol	equ	$0a8
aud0lch	equ	$0a0
aud0len	equ	$0a4
aud0per	equ	$0a6
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

CIAA	equ	$bfe001
CIAB	equ	$bfd000
TBLO	equ	$600			CIA equates
TBHI	equ	$700
KEY	equ	$c00
ICR	equ	$d00
CRA	equ	$e00
CRB	equ	$f00




;""""""""""""""""""""""""""""""""""""""""""""""""""""""
;" REST OF FILE TAKEN FROM panic.asm (BBC MICRO CODE) "
;"						      "
;""""""""""""""""""""""""""""""""""""""""""""""""""""""

	section	panic,code

	;;
	;;  MOUNTAIN PANIC
	;;  --------------
	;;
	;;  Started:    January 2008
	;;  Finished: 	13:00 May 31st 2013 (RC)
	;;              22:00 July 1st 2013 (RC_1)
    ;;              17:00 Sept 11th 2013 (RC_2)
	;; 
    ;;  Released:   Play Expo 2013

 INCLUDE "memory.asm"

_startingScreen   = 1;original 1 ; 23 ; 45 = Shoggoth, 41 = entrance to abyss		;DJV 11 for screen with first rope, 5 for screen where rope can be fired to right, 17 for flipped pillars
_playerStartPosX  = 16+4;original 16+4
_playerStartPosY  = 192;original 192;16*2;16*6;192 ;16*6

SCREEN_FLAGS_ITEM_PRESENT = $04


;"""""""""""""
;" MAIN LOOP "
;"	     "
;"""""""""""""

	even
sexyJacky
;	move.l	#sexyJacky,$70000	;DEBUG code
;	bra.s	sexyJacky	;DEBUG code
;	move.l	screen1(pc),$70000	;DEBUG code
;	move.l	#currentTileBank,$70000	;DEBUG code
;	move.l	#elderSignsPos,$70000	;DEBUG code
;	move.l	#localElderSignPos,$70004	;DEBUG code
	move.l	#exitMountainPanic,$70000

    LDX #0	;temp (was 0)	;7:19 Poor Lake
    STX titleScreenNumber
    INX
    STX titleScreenTextThree
    LDX #9
    STX titleScreenTextOne
    INX
    STX titleScreenTextTwo

 ;.drawTitle:
drawTitle:
	JSR setupPlayer

	LDA titleScreenNumber
	STA playerScreen

    ; Refresh item and elder sign
    JSR drawItem
    JSR drawElderSign

	; Restore HP & San bars
    JSR refillHealthBars
        
	; Palette
;	LDA #$90 + PAL_red
;	STA $fe21
;	LDA #$e0 + PAL_red
;	STA $fe21
	move.w	#$f00,color0+AMIGA_HP_RED*2(a6)		Restore player energy bar colour to red

    ; Draw screen
	JSR drawScreen

    ; Text
.textAmiga
	tst.b	titleScreenNumber
	bne.s	.textOne
	LDX #0
	LDY #27
	moveq	#1+16/2,d4		+16/2 to centre on double width Amiga screen
	move.w	#8*8,d5
	JSR drawStringWithOSFont

.textOne:        
	LDX #0
	LDY titleScreenTextOne
    BEQ .textTwo
;	LDA #LO((&4000+(512*9))+32*4)	;DJV row=9, column=4
;	STA t2
;	LDA #HI((&4000+(512*9))+32*4)
;	STA t3
	moveq	#4+16/2,d4		+16/2 to centre on double width Amiga screen
	move.w	#9*8,d5
	JSR drawStringWithOSFont

.textTwo:        
	LDX #0
	LDY titleScreenTextTwo
;	LDA #LO((&4000+(512*10))+32*1)	;DJV row=10, column=1
;	STA t2
;	LDA #HI((&4000+(512*10))+32*1)
;	STA t3
	moveq	#1+16/2,d4		+16/2 to centre on double width Amiga screen
	move.w	#10*8,d5
	JSR drawStringWithOSFont

.textThree:        
	LDX #0
	LDY titleScreenTextThree
;	LDA #LO(&4000+(512*20)+64)	;DJV row=20, column=64/32=2
;	STA t2
;	LDA #HI(&4000+(512*20)+64)
;	STA t3
	moveq	#2+16/2,d4		+16/2 to centre on double width Amiga screen
	move.w	#20*8,d5
	JSR drawStringWithOSFont

	lda #1
	sta joystickEnabledFlag ; initially we always attempt to read joystick

.titleLoop:
;	move.w	#$0f0,color0(a6)
	bsr	restoreScreenUnderSnowFlakes
	IFND	STEALTH_MODE
	bsr	snowFlakes
	ENDC
;	move.w	#$000,color0(a6)

;.titleVsync:
;	jsr	updateScreens
;	LDA irqCounter
;	BEQ titleVsync
;	LDA #0
;	STA irqCounter
	tst.b	DebugWithMonam
	bne.s	.continue8
	bsr	copperWait	;bsr	VBlankWait
.continue8

******** DEBUG CODE ********
	IFD	TEST_ICONS
	btst	#7,$bfe001
	bne.s	.notPressed

	add.b	#32,playerUsingItem
	jsr	drawItem

	add.b	#$10,playerInventory
	jsr	drawElderSign
;.notReleased
;	btst	#7,$bfe001
;	beq.s	.notReleased
.notPressed
	ENDC
	btst	#6,$bfe001
	beq	exitMountainPanic
******** DEBUG CODE END ********

	JSR updateKeys
	LDA keyFlags
	AND8 #(_keyFire|_keyJoystickUsed)
	BEQ .titleLoop

	AND8 #_keyJoystickUsed	; If we've used a joystick here, assume we're reading one..
	BNE .debounce
	LDA #0
	STA joystickEnabledFlag ; otherwise, disable it
	
.debounce:
	JSR updateKeys
	LDA keyFlags
	AND8 #_keyFire
	BNE .debounce

    ; If we are coming from congratulations screen, display main page
    LDA titleScreenNumber
    CMP8 #49
    BNE .notCongrat
    JMP sexyJacky
	
.notCongrat:
	; Start game off
	LDA #_startingScreen
	STA playerScreen

	JSR drawScreen
	bsr	saveScreenUnderBobs

;.gameLoop:
gameLoop:
	; Check for inventory first
	JSR updateKeys
	JSR updateInventory
	
	bsr	restoreAllScreen	; Must be done before effects

	JSR updateShoggoth
;DJV temp	move.b	currentTileBank,theByte3

;DJV temp	move.b	shogForceElderDraw,theByte2
;DJV temp	move.b	numElderSigns,theByte3

	LDA #0
	STA redrawPlayerFlag
	JSR updatePlayer

;DJV temp	st.b	shogForceElderDraw
;DJV temp	move.b	#1,numElderSigns
;DJV temp	move.b	#16+3,elderSignsPos
;DJV temp	move.b	#16*6,elderSignsPos+1

    LDA shogForceElderDraw
    BNE .drawElderSigns
    LDA redrawPlayerFlag ; need to check the elder flag here..
    BEQ .sexyJR

;DJV draw elder signs in the player area (for screens 41 and 45)
.drawElderSigns:
    LDA numElderSigns
    IFD	DEBUG_OUTPUT
    move.b	AREG,theByte2
    ENDC
    BEQ .sexyJR

.elderSignsLoop:
    PHA ; save number of signs
    ASL8 A
    TAX
;    LDA #LO(itemSprites+(6*8*4))
;    STA t0
;    LDA #HI(itemSprites+(6*8*4))
;    STA t1
	move.w	#_itemElderSign/32,d6
	moveq	#ITEMS_ROW,d7
    LDA #0
    STA t4
    DEX ; x=3, load y, then X
    LDA elderSignsPos,X
;    move.b	AREG,theByte3
    STA t3
    LDA elderSignsPos-1,X
;    move.b	AREG,theByte2
    STA t2
;    CLC
	moveq	#0,d3		; No flip in x
    JSR plotSprite8x8
    PLA
;    SEC
    SBC #1
    BNE .elderSignsLoop
    LDA #0
    STA shogForceElderDraw

.sexyJR:
	jsr	updatePlayerBob		;JSR drawPlayer

	JSR updateEnemies
	JSR updateRope

	; NB no need for a waitBlit here because one is already done in the previous restoreAllScreen call
	IFND	STEALTH_MODE
	bsr	doEffects
	ENDC
	bsr	saveScreenUnderBobs
;	IFND	STEALTH_MODE
	bsr	drawAllBobs
;	ENDC

	JSR updateHPAndSan
	JSR drawItem
	; NB waitBlit before any screen updates (in the player area)
	waitBlit
	JSR updateDynamicText

;.doRope:        
	LDA ropeState
	CMP8 #_ropeStateAttached
	BNE .vSync
	JSR fastPlotRope

.vSync:
;	move.w	#$000,color0(a6)
	IFD	DEBUG_OUTPUT
	move.b	playerScreen,theByte1
	bsr	showTheBytes	;DEBUG
	ENDC
;	jsr	updateScreens
;.lockedVsync:
;	LDA irqCounter
;	BEQ lockedVsync
;	LDA #0
;	STA irqCounter
	tst.b	DebugWithMonam
	bne.s	.continue9
	bsr	copperWait	;bsr	VBlankWait
.continue9
;	move.w	#$f00,color0(a6)

;.readJoy:
;	lda #0
;	sta &fec0

	btst	#6,$bfe001              ; DEBUG
	beq	exitMountainPanic      ; DEBUG

	LDA playerEnergy
    BEQ .gameOver
	JMP gameLoop

.gameOver:        
    JSR gameOverText
    LDA #200
    STA t0
        
.gameOverWait:
;	LDA irqCounter
;	BEQ gameOverWait
;	LDA #0
;	STA irqCounter
	tst.b	DebugWithMonam
	bne.s	.continue10
	bsr	copperWait	;bsr	VBlankWait
.continue10
    DEC t0
    BNE .gameOverWait
	JMP drawTitle

exitMountainPanic:
	rts


restoreAllScreen
	bsr	restoreScreenUnderBobs
	waitBlit	; NB must wait for blitter to finish updating screen (this fixes the corruption seen with the last snow flake)
	bsr	restoreScreenUnderSnowFlakes
	rts

	IFD	DEBUG_OUTPUT
showTheBytes
	movem.w	d0-d2,-(sp)
	move.b	theByte1(pc),d0
	bsr	makeHexWord
	moveq	#0,d0
	moveq	#16,d1
	lea	hexText+2(pc),a0	only need to print final two digits
	bsr	print

	move.b	theByte2(pc),d0
	bsr	makeHexWord
	moveq	#3,d0
	moveq	#0,d1
	lea	hexText+2(pc),a0	only need to print final two digits
	bsr	print

	move.b	theByte3(pc),d0
	bsr	makeHexWord
	moveq	#6,d0
	moveq	#0,d1
	lea	hexText+2(pc),a0	only need to print final two digits
	bsr	print
	movem.w	(sp)+,d0-d2
	rts

theByte1	dc.b	0
theByte2	dc.b	0
theByte3	dc.b	0
	even
	ENDC

setupPlayer:
;	{
	; Set up player
	LDA #_playerStartPosX
	STA playerPosX
	
	LDA #_playerStartPosY
	STA playerPosY

	LDA #0
	STA ropeState
	STA ropeLength
	STA playerHPLoss
;	STA flakeActiveList
	STA playerFlags
;DJV temp	move.b	#1,playerFlags
	STA playerGems
    STA icicleDropFlag
    ;;  INVENTORY vvvv
    ; LDA #_bitRope|_bitGemBlue|_bitGemRed|_bitTorch
;DJV trainer    LDA #_bitRope
	STA playerInventory
    ;LDA #_itemRope
;DJV trainer    LDA #_itemRope
    STA playerUsingItem
;	move.b	#_bitRope|_bitGemBlue|_bitGemRed|_bitTorch,playerInventory	;DJV trainer
;	move.b	#$f0|_bitRope|_bitGemBlue|_bitGemRed|_bitTorch,playerInventory	;DJV trainer
;	move.b	#_itemRope,playerUsingItem	;DJV trainer

	; Force an update on first frame
	LDA #$FF
	STA playerOldState
    STA lastDrawnPlayerItem
	
	LDA #28
	STA playerEnergy

	LDA #_playerStateNormal
	STA playerState

	; Reset rope
	LDA #_ropeLengthBasic;+20
;	LDA #_ropeLengthBasic+20	;DJV trainer
	STA currentRopeLength

	JSR initShoggoth

	; Re-initialise all items
NUM_SCREENS = 49
	
;	LDA #LO(mapData)
;	STA t0
;	LDA #HI(mapData)
;	STA t1
	lea	mapData,a5

	LDX #0

.setupScreenLoop:
	LDY #7
	LDA (a5),Y	;LDA (t0),Y
    STA t2
	AND8 #1 ; check for original item bit ... ; lda #1: bit t2 ...   lda #%10 : bit t2...
	BEQ .noItem
	LDY #2
	LDA (a5),Y	;LDA (t0),Y
	ORA #SCREEN_FLAGS_ITEM_PRESENT
	STA (a5),Y	;STA (t0),Y
    LDY #7
.noItem:
    LDA t2
    AND8 #%10 ; check for original sanity bit
    BEQ .noSanity
    LDA t2
    ORA #%100 ; set sanity bit again
    STA (a5),Y	;STA (t0),Y ; and save back
.noSanity:        
;	CLC
;	LDA t0
;	ADC #8 ; next screen
;	STA t0
;	LDA t1
;	ADC #0
;	STA t1
	addq.w	#8,a5	; next screen
	INX
	CPX #NUM_SCREENS
	BNE .setupScreenLoop
	RTS
;	}


doEffects
	; Load effects bit for this screen : Probably can do this in the 'drawScreen' routine
	; when setting the screen up instead of every frame: Save about 20 cycles or so.
;	LDY #2
;	LDA (curScreenLO),Y
	move.l	curScreen,a5
	move.b	2(a5),d3
	and.b	#_effectSnow|_effectGems,d3
	bne.s	.effectsPresent
	IFD	SNOWFLAKES_USE_HARDWARE_SPRITES
	bsr	hideSnowFlakes
	ENDC
.effectsDone:
	rts

.effectsPresent:
;	AND #_effectGems
;	BEQ fxSnow
;	LDA #LO(fxRoutines+2)
;	STA effectJump+1
;	LDA #HI(fxRoutines+2)
;	STA effectJump+2
;	JMP sexySolange
	and.b	#_effectGems,d3
	beq.s	.fxSnow
	IFD	SNOWFLAKES_USE_HARDWARE_SPRITES
	bsr	hideSnowFlakes
	ENDC

;	lea	effectGems,a4
;	bra.s	.effectJump
	bra	effectGems
	
.fxSnow:
;	; Load base table address, then INC or ADC jmp address and store at 'effectJump+1'.
;	; Perhaps ensure jump table is page-aligned so can just alter LS byte.
;	LDA #LO(fxRoutines)
;	STA effectJump+1
;	LDA #HI(fxRoutines)
;	STA effectJump+2

;	lea	snowFlakes,a4
;	bra.s	.effectJump
	bra	snowFlakes

	; ^^^^
	; THIS SHOULD BE DONE IN 'drawScreen'
	; vvvv
;.sexySolange:
;	; Push return address for RTS
;	LDA #HI(effectsDone-1)
;	PHA
;	LDA #LO(effectsDone-1)
;	PHA
		
.effectJump:
;	JMP (&0000)
;	jmp	(a4)


	IFD	NOT_REQUIRED
.fxRoutines
	; Effect routines jump table, remember to align properly so can be sure to just increment the lo byte.
	EQUW snowFlakes		
	EQUW effectGems
	ENDC


;DJV draw elder signs in the inventory area
drawElderSign:
;        {
        LDA playerInventory
        STA tc ; tc is work byte, check for elder sign bits
        
        LDA #0
        STA tb ; tb is loop counter
        
.drawSignLoop:
        LDA tc
        AND8 #$80
        BNE .haveThisPiece

.clearPiece:
;        LDA #0
;        STA t0
;        STA t1
	moveq	#BLANK_ITEM_COL,d6
	moveq	#ITEMS_ROW,d7
        bra.s	.cont

.haveThisPiece:        
;	    LDA #LO(itemSprites+_itemElderSign) ; Since these will be different, these will also come from a look-up table
;	    STA t0
;	    LDA #HI(itemSprites+_itemElderSign) ; Since these will be different, these will also come from a look-up table
;	    STA t1
	move.w	#_itemElderSign/32,d6
	moveq	#ITEMS_ROW,d7

.cont:        
        LDX tb
	    LDA elderSignPositions,X
	    STA t2
        LDA elderSignPositions+1,X
        STX tb
	    STA t3
	    LDA #0
	    STA t4
;	    CLC
	moveq	#0,d3		; No flip in x
	    JSR plotSprite8x8
        
        ;LDA tc
        ASL8 tc
        ;STA tc
        LDX tb
        INX
        INX
        STX tb
        CPX #8
        BNE .drawSignLoop
        RTS
        
;        }

drawItem:
;        {
        LDA #112
        STA t2
        LDA #240
        STA t3
        LDA #0
        STA t4
        LDA playerUsingItem
        CMP8 lastDrawnPlayerItem
        BNE .mustDraw
        RTS
.mustDraw:        
        STA lastDrawnPlayerItem
        CMP8 #0			; NB this assumes item 0 (_itemHook) isn't used
        BNE .hasItem
.noItem:
;        LDA #0
;        STA t0
;        STA t1
	moveq	#BLANK_ITEM_COL,d6
	moveq	#ITEMS_ROW,d7
	bra.s	.drawItemOut
        
.hasItem:
        CLC
;        ADC #LO(itemSprites)
;        STA t0
;	    LDA #HI(itemSprites)
;        ADC #0
;	    STA t1
* Convert BBC Micro value back to item number
	moveq	#0,d6
	move.b	AREG,d6
	lsr.w	#5,d6
	moveq	#ITEMS_ROW,d7
	
.drawItemOut:
;	    CLC
	moveq	#0,d3		; No flip in x
	    JSR plotSprite8x8
        RTS
;        }

	INCLUDE "inventory.asm"
	INCLUDE "items.asm"
	INCLUDE "rope.asm"
	INCLUDE "sprites.asm"
	IFD	NOT_DONE_YET
INCLUDE "hardware.asm"
	ENDC
	INCLUDE "tiles.asm"
	INCLUDE "player.asm"
	INCLUDE "enemy.asm"
	INCLUDE "shoggoth.asm"
	INCLUDE "text.asm"
	INCLUDE "screen.asm"
	INCLUDE "snowflakes.asm"
	INCLUDE "gems.asm"
	INCLUDE "keys.asm"
	INCLUDE "drawing.asm"

	INCLUDE "HPAndSan.asm"
	INCLUDE "collision.asm"

	IFD	NOT_DONE_YET
INCLUDE "unpack.asm"
INCLUDE "sound.asm"
	ENDC

	INCLUDE "dyntext.asm"
	
;.codeEnd:
	INCLUDE "LevelData.asm"
	
;.realEnd:
;ALIGN &100
;.end:
;
;NATIVE_ADDR = &100 ; all the memory
;RELOAD_ADDR = &1900
;OFFSET      = RELOAD_ADDR - NATIVE_ADDR

********** Start Mountain Panic **********
	even
runMountainPanic:
;.relocate:
;  LDA #140
;  JSR &FFF4 ; *TAPE
;
;  ; Patch in key definitions
;  lda &70
;  sta keyCheckLeft+1+OFFSET
;  lda &71
;  sta keyCheckRight+1+OFFSET
;  lda &72
;  sta keyCheckUp+1+OFFSET
;  lda &73
;  sta keyCheckDown+1+OFFSET
;  lda &74
;  sta keyCheckRET+1+OFFSET
;  lda &75
;  sta keyCheckSpace+1+OFFSET
;
;  LDA #0
;  LDX #1
;  JSR &FFF4
;  STX machineType + OFFSET
;
;  CPX #3
;  BCC sexyTraceyElvik
;        
;  LDA #25:LDX #0:JSR &FFF4 ; reset master font definition
;
;.sexyTraceyElvik:        
;  SEI
;        
;  LDX #LO(stackEnd-1)
;  TXS
;
;   ; Set up VIA for sound
;	
;   ; Disable all interrupts
;   LDA #&7F
;   STA &FE4E
;
;   LDA #&FF:STA &FE43               ; set DDRA on System VIA to %1111 1111
;   LDA #&0F:STA &FE42               ; set DDRB on System VIA to %0000 1111
;   LDA #&08:STA &FE40				; sound chip enable pulled high (disabled for now)
;   LDA #&0B:STA &FE40				; keyboard enable pulled high (disabled)
;   LDA #&00:STA &FE62               ; set DDRB on User VIA (used for master compact joystick)
;	
;  ;;  zero sound workspace
;  LDA #0
;  LDY #32
;	
;.zeroLoop:
;  STA soundtemp,Y
;  DEY
;  BPL zeroLoop
;
;  LDX #HI(end-start)
;  LDY #0
;  TYA ; ????
;
;.relocateloop:
;  LDA RELOAD_ADDR,Y
;  STA NATIVE_ADDR,Y
;  INY
;  BNE relocateloop
;  INC relocateloop + 2 + OFFSET   ; address corrected
;  INC relocateloop + 5 + OFFSET   ; address corrected
;  DEX
;  BNE relocateloop
;
;  ; TODO: Move screen setup here to save more memory..?
;  LDA #0
;  STA packedTileTable+0
;  STA packedTileTable+1
;  LDA #LO(tileSpritesPacked2-tileSpritesPacked)
;  STA packedTileTable+2
;  LDA #HI(tileSpritesPacked2-tileSpritesPacked)
;  STA packedTileTable+3
;  LDA #LO(tileSpritesPacked3-tileSpritesPacked2)
;  STA packedTileTable+4
;  LDA #HI(tileSpritesPacked3-tileSpritesPacked2)
;  STA packedTileTable+5
;
;  LDY #0	
;  LDX #8
;	
;.downloadTopPanel:
;  LDA topPanel + OFFSET,Y
;  STA &4000,Y
;  DEY
;  BNE downloadTopPanel
;  INC downloadTopPanel + 2 + OFFSET
;  INC downloadTopPanel + 5 + OFFSET
;  DEX
;  BNE downloadTopPanel
;
;  LDY #0	
;  LDX #8
;	
;.downloadBottomPanel:
;  LDA bottomPanel + OFFSET,Y
;  STA &7800,Y
;  DEY
;  BNE downloadBottomPanel
;  INC downloadBottomPanel + 2 + OFFSET
;  INC downloadBottomPanel + 5 + OFFSET
;  DEX
;  BNE downloadBottomPanel

  LDA #0
  STA dynTextFrames

	IFND	STEALTH_MODE
	bsr	showPanels
	ENDC

;
;.hardwareSetup:        
;
;    LDA machineType + OFFSET
;	CMP #3
;	BCC normalBBC
;
;    CMP #5
;    BNE patchSheilaADC
;
;    ; Patch for Master Compact Joystick (11/09/2013)
;    LDX #0
;.joystickPatchLoop:
;    LDA masterCompactJoystickRoutineStart + OFFSET,X
;    STA startJoystickPatch,X
;    INX
;    CPX #61
;    BNE joystickPatchLoop
;
;	; ADC on Master 128 is at a different SHEILA address (&18)
;	; Will also need to patch font in here.
;.patchSheilaADC:
;	LDA #&18
;	STA readJoy+3
;	STA getADCChannel+1
;	LDA #&19
;	STA channel1ADC+1
;	STA channel2ADC+1
;	LDA #&18
;	STA channel1ADCa+1
;
;    LDA #$80
;    STA $FE30 ; page in vdu ram bank for master charset
;
;    LDY #0
;.copycharsloop:
;    LDA &8900,Y:STA &C000,Y
;    LDA &8A00,Y:STA &C100,Y
;    LDA &8B00,Y:STA &C200,Y
;    INY
;    BNE copycharsloop
;
;    LDA machineType + OFFSET
;    CMP #5
;    BNE normalBBC
;
;.normalBBC:
;	; Disable all interrupts
;    LDA #&7F
;	STA &FE4E
;        
;	LDA #0
;	STA irqCounter
;	STA joyTemp
;	STA joyTemp2
;
;;IF TRUE ; disable this lot for proper sound on real h/w
;IF FALSE
;	; Keyboard stuff
;	LDA #&7F
;	STA &FE43
;	LDA #&0F
;	STA &FE42
;	LDA #&03
;	STA &FE40
;ENDIF
;
;	; Enable vsync, timer1, and adc interrupts
;	; $82 - just vsync, $c2 vsync and timer 1, $d2 - adc,vsync and timer1
;	LDA #&D2
;	STA &FE4E
;
;.setupScreen:
;	SEI
;
;IF 0        
;	; Full screen clear - ($3000-$7fff) = 40.
;    ; Clear to panel address = 38.
;	LDX #&28
;	LDA #0
;	TAY
;.clearloop:
;	STA &4800,Y
;	INY
;	BNE clearloop
;	INC clearloop + 2 + OFFSET
;	DEX
;	BNE clearloop
;ENDIF        
;	
;.skipClear:
;	LDX #13
;        
;.crtcloop:
;	STX &FE00
;	LDA crtcregs + OFFSET,X
;	STA &FE01
;	DEX
;	BPL crtcloop
;
;	; Video ULA
;	LDA #&F4
;	;STA &248
;	STA &FE20
;
;	LDX #8
;.palloop
;	LDA paldata + OFFSET,X
;	STA &FE21
;	ORA #&80
;	STA &FE21
;	DEX
;	BPL palloop
;
;	; Set trans
;	LDA #&f0 + PAL_black
;	STA &FE21
;	CLI
;
;	; Set up tables
;	LDA #LO(sinTable):STA sinTableLO
;	LDA #HI(sinTable):STA sinTableHI
;	LDA #LO(flakes):STA flakesLO
;	LDA #HI(flakes):STA flakesHI
;	;LDA #LO(screenStrings):STA stringTableLO
;	;LDA #HI(screenStrings):STA stringTableHI
;	LDA #LO(lookup128):STA lookup128LO
;	LDA #HI(lookup128):STA lookup128HI
;
;	; Zero-page player sprite routine mask table
;	LDA #0
;	STA maskTable+0
;	STA maskTable+7
;	LDA #&55
;	STA maskTable+1
;	STA maskTable+6
;	LDA #&AA
;	STA maskTable+2
;	STA maskTable+5
;	LDA #&FF
;	STA maskTable+3
;	STA maskTable+4
;
;	; seutp HP & san colours
;	LDA #&E0 + PAL_red
;	STA &FE21
;	LDA #&90 + PAL_red
;	STA &FE21
;
;?	; Initialise snow window
;	LDA #0
;	STA snowWindow+0
;	STA snowWindow+1
;	LDA #16*8
;	STA snowWindow+2
;	LDA #16*12
;	STA snowWindow+3
;
;	; Init bitmasks
;	LDA #&55
;	STA spriteBitMasks
;	LDA #&AA
;	STA spriteBitMasks+1

	moveq	#0,d0
	move.b	d0,animFlag
	move.b	d0,redrawPlayerFlag
	move.b	d0,wasPressedFlagGems
	move.b	d0,wasPressedFlagInventory
	move.b	d0,playerWalkSfxFlag

	move.b	#5*2,animDelay

;    ; init colours for plot pixel
;    LDX #17
;.sexyMadonna:
;    LDA coloursForPlotPixel+OFFSET,X
;    STA colours,X
;    DEX
;    BPL sexyMadonna

	move.b	#1,playerCollFlag

	move.b	#_hpLossFrameDelayLatch,hpLossFrameDelay

;    ; Enable interrupts and go
;    ; CLI
;    ; Start us off, Jacky!
	jmp	sexyJacky

	IFD	NOT_REQUIRED
.machineType:
  EQUB 0
        
.crtcregs:
	EQUB 127		; R0  horizontal total
	EQUB 64			; R1  horizontal displayed - shrunk a little
	EQUB 90			; R2  horizontal position
	EQUB 40			; R3  sync width
	EQUB 38			; R4  vertical total
	EQUB 0			; R5  vertical total adjust
	EQUB 32			; R6  vertical displayed
	EQUB 34			; R7  vertical position
	EQUB 0			; R8  interlace
	EQUB 7			; R9  scanlines per row
	EQUB 32			; R10 cursor start
	EQUB 8			; R11 cursor end
	EQUB HI(&4000/8)	; R12 screen start address, high
	EQUB LO(&4000/8)	; R13 screen start address, low
	
.paldata:
	EQUB &00 + PAL_black
	EQUB &10 + PAL_red
	EQUB &20 + PAL_green
	EQUB &30 + PAL_yellow
	EQUB &40 + PAL_blue
	EQUB &50 + PAL_magenta
	EQUB &60 + PAL_cyan
	EQUB &70 + PAL_white
	EQUB &80 + PAL_green ; Initially green, but red in hell.  This is done in 'drawscreen' so may not be stricly needed to set it up here.

.coloursForPlotPixel: ; for plotpixel
	EQUB 0,0		; Black
	EQUB 2,1		; Red
	EQUB 8,4		; Green
	EQUB &A,5		; Yellow
	EQUB &20,&10		; Blue
	EQUB &22,&11		; Magenta
	EQUB &28,&14		; Cyan
	EQUB &2A,&15		; White
	EQUB &82,&41		; White2!

.masterCompactJoystickRoutineStart:
    LDA &FE60
    TAX
    AND #1 ; fire
	BNE cj1
	LDA keyFlags
	ORA #(_keyFire OR _keyJoystickUsed)
	STA keyFlags

.cj1:
    TXA
    AND #2 ; left
    BNE cj2
    LDA keyFlags
    ORA #_keyLeft
    STA keyFlags

.cj2:
    TXA
    AND #16 ; right
    BNE cj3
    LDA keyFlags
    ORA #_keyRight
    STA keyFlags

.cj3:
    TXA
    AND #8 ; up
    BNE cj4
    LDA keyFlags
    ORA #_keyUp
    STA keyFlags

.cj4:
    TXA
    AND #4 ; down
    BNE cj5
    LDA keyFlags
    ORA #_keyDown
    STA keyFlags

.cj5:
    NOP
    NOP
    NOP

.masterCompactJoystickRoutineEnd:        
.topPanel:
  INCBIN "BIN/BBCPAN2.DAT"
	
.bottomPanel:
  INCBIN "BIN/BBCPAN.DAT"
	
.veryend:
PRINT "Very end: ",~veryend
PRINT "Total used:",realEnd-start
PRINT "Bytes remaining:",&4000-(realEnd-start)-&100
PRINT "OFFSET: ",OFFSET        
PRINT "Size of joystick code to patch:",endJoystickPatch-startJoystickPatch
PRINT "Size of compact joystick code:",masterCompactJoystickRoutineEnd-masterCompactJoystickRoutineStart
SAVE "Code", &100, veryend, relocate + OFFSET, RELOAD_ADDR
	ENDC


* DJV colour palette notes *
	IFD	NOT_USED
0: black
1: red
2: green
3: yellow
4: blue
5: magenta
6: cyan
7: white
8: green ; Initially green, but red in hell.  This is done in 'drawscreen' so may not be stricly needed to set it up here. OR MAY START OUT AS BLACK DUE TO .palloop
9: red	;HP & san colour
A: green
B: yellow
C: blue
D: magenta
E: red	;HP & san colour
F: black


Register &FE21
19.2.3 Physical colour field 
The physical colours are: 
 &00(0) black 
 &01(1) red 
 &02(2) green 
 &03(3) yellow (green—red) 
 &04(4) blue 
 &05(5) magenta (red—blue) 
 &06(6) cyan (green—blue) 
 &07(7) white 
 &08(8) flashing black—white 
 &09(9) flashing red—cyan 
 &0A(10) flashing green—magenta 
 &0B(11) flashing yellow—blue 
 &0C(12) flashing blue—yellow 
 &0D(13) flashing magenta—green 
 &0E(14) flashing cyan—red 
 &0F(15) flashing white—black 
	ENDC
