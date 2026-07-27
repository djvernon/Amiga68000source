_keyLeft		= 1
_keyRight		= 2
_keyFire		= 4
_keyUp			= 8
_keyDown		= 16
_keyInventory		= 32
_keyJoystickUsed        = 128 ; 27/10/2013 - Set so that we can set joystick enable
	IFD	NOT_REQUIRED
_joystickDeadZone	= $28
	ENDC

updateKeys
	IFD	DEBUG_KEYS
	bsr	showRawKeyCode
	ENDC
	;{
;	LDA #&03
;	STA &FE40
	LDA #0
	STA keyFlags
;	LDA #&7f
;	STA &FE43

	; 27/10/2013 Only check joystick if we are enabled
	LDA joystickEnabledFlag
	BEQ .keyCheckLeft

;.startJoystickPatch:        
.checkJoyFire
;	LDA &FE40
;	AND #16
	btst	#7,$bfe001
	BNE .notFired

.fired
	LDA keyFlags
	ORA #(_keyFire|_keyJoystickUsed)
	STA keyFlags
	
.notFired
;	LDA joyTemp
;	TAX
;	CMP #_joystickDeadZone
;	BCS notJoyLeft
	move.w	joy1dat(a6),d3
	btst	#9,d3
	beq.s	.notJoyLeft

.joyLeft
	LDA keyFlags
	ORA #_keyLeft
	STA keyFlags
	
.notJoyLeft
;	TXA
;	CMP #&ff - _joystickDeadZone
;	BCC notJoyRight
	btst	#1,d3
	beq.s	.notJoyRight
	
.joyRight
	LDA keyFlags
	ORA #_keyRight
	STA keyFlags
	
.notJoyRight
;	LDA joyTemp2
;	TAX
;	CMP #&ff - _joystickDeadZone
;	BCC notJoyUp
	move.w	d3,d4
	lsr.w	#1,d4
	eor.w	d3,d4
	btst	#8,d4
	beq.s	.notJoyUp

.joyUp
	LDA keyFlags
	ORA #_keyUp
	STA keyFlags
	
.notJoyUp
;	TXA
;	CMP #_joystickDeadZone
;	BCS keyCheckLeft
	btst	#0,d4
	beq.s	.keyCheckLeft

.joyDown
	LDA keyFlags
	ORA #_keyDown
	STA keyFlags

.endJoystickPatch:        

.keyCheckLeft:
;	LDA #97:STA &FE4F:LDA &FE4F  ; N flag = whether 'Z' pressed
;	BPL keyCheckRight
;	cmp.b	#$31,RawKeyCode
;	bne.s	.keyCheckRight
	tst.b	RawKeyArray+$31
	beq.s	.keyCheckRight
	LDA keyFlags
	ORA #_keyLeft
	STA keyFlags
        
.keyCheckRight:
;	LDA #66:STA &FE4F:LDA &FE4F  ; N flag = whether 'X' pressed
;	BPL keyCheckRET
;	cmp.b	#$32,RawKeyCode
;	bne.s	.keyCheckRET
	tst.b	RawKeyArray+$32
	beq.s	.keyCheckRET
	LDA keyFlags
	ORA #_keyRight
	STA keyFlags
        
.keyCheckRET:
;	LDA #73:STA &FE4F:LDA &FE4F  ; N flag = whether 'RET' pressed
;	BPL keyCheckUp
;	cmp.b	#$44,RawKeyCode
;	bne.s	.keyCheckUp
	tst.b	RawKeyArray+$44
	beq.s	.keyCheckUp
	LDA keyFlags
	ORA #_keyFire
	STA keyFlags
        
.keyCheckUp:
;	LDA #72:STA &FE4F:LDA &FE4F  ; N flag = whether ':' pressed
;	BPL keyCheckDown
;	cmp.b	#$29,RawKeyCode
;	bne.s	.keyCheckDown
	tst.b	RawKeyArray+$29
	beq.s	.keyCheckDown
	LDA keyFlags
	ORA #_keyUp
	STA keyFlags
        
.keyCheckDown:
;	LDA #104:STA &FE4F:LDA &FE4F  ; N flag = whether '/' pressed
;	BPL keyCheckSpace
;	cmp.b	#$39,RawKeyCode		; DJV using '.' instead because of different keyboard layout (TODO check Amiga)
;	bne.s	.keyCheckSpace
	tst.b	RawKeyArray+$39
	beq.s	.keyCheckSpace
	LDA keyFlags
	ORA #_keyDown
	STA keyFlags
        
.keyCheckSpace:
;	LDA #98:STA &FE4F:LDA &FE4F
;	BPL notSpace
;	cmp.b	#$40,RawKeyCode
;	bne.s	.notSpace
	tst.b	RawKeyArray+$40
	beq.s	.notSpace
	LDA keyFlags
	ORA #_keyInventory
	STA keyFlags
        
.notSpace:
;	; PULL KEYBOARD ENABLE HIGH AGAIN FOR SOUND
;	LDA #&ff
;	STA &FE43
;	LDA #&0B
;	STA &FE40
	IFD	DEBUG_KEYS
	bsr	showKeyFlags
	ENDC
	RTS
	;}

	IFD	DEBUG_KEYS
showRawKeyCode
	movem.w	d0-d2,-(sp)
	move.b	RawKeyCode,d0
	bsr	makeHexWord
	moveq	#15,d0
	moveq	#32,d1
	lea	hexText+2(pc),a0	only need to print final two digits
	bsr	print
	movem.w	(sp)+,d0-d2
	rts

showKeyFlags
	movem.w	d0-d2,-(sp)
	move.b	keyFlags,d0
	bsr	makeHexWord
	moveq	#18,d0
	moveq	#32,d1
	lea	hexText+2(pc),a0	only need to print final two digits
	bsr	print
	movem.w	(sp)+,d0-d2
	rts
	ENDC

	IFD	NOT_USED
* StuntCarRacer:-
****************************************


read.joystick
	movem.l	d3-d4/a0,-(sp)
	clr.b	d4
	move.w	joy1dat+custom,d0
	move.w	d0,d3
	lsr.w	#1,d3
	eor.w	d0,d3
	btst	#8,d3
	beq	not.forward1
	bset	#0,d4
not.forward1
	btst	#0,d3
	beq	not.back1
	bset	#1,d4
not.back1
	btst	#9,d0
	beq	not.left1
	bset	#2,d4
not.left1
	btst	#1,d0
	beq	not.right1
	bset	#3,d4
not.right1
	lea	CIAA,a0
	andi.b	#$7f,$200(a0)
	btst	#7,$000(a0)
	bne	not.fire1
	bset	#4,d4
not.fire1
	eori.b	#$ff,d4
	move.b	d4,joystick.state
	movem.l	(sp)+,d3-d4/a0
	rts


****************************************


* Turrican:-
read.joystick
	move.w	joy1dat(a6),d0
	moveq	#0,d2			initial x speed
	moveq	#0,d3			initial y speed

test.joy.left
	btst	#9,d0
	beq.s	test.joy.right

	moveq	#-4,d2
	bra.s	test.joy.up

test.joy.right
	btst	#1,d0
	beq.s	test.joy.up

	moveq	#4,d2

test.joy.up
	move.w	d0,d1
	lsr.w	#1,d1
	eor.w	d0,d1

	btst	#8,d1
	beq.s	test.joy.down

	moveq	#-4,d3
	bra.s	joystick.read

test.joy.down
	btst	#0,d1
	beq.s	joystick.read

	moveq	#4,d3

joystick.read
	move.w	d2,x.speed
	move.w	d3,y.speed
	rts


TextureWalls:-
read.joystick
	move.w	joy1dat+$dff000.l,d0
	moveq	#0,d2
	moveq	#0,d3
	sf	fire.pressed

.left	btst	#9,d0
	beq.s	.right
	moveq	#-JOY_SPEED,d2
	bra.s	.up

.right	btst	#1,d0
	beq.s	.up
	moveq	#JOY_SPEED,d2

.up	move.w	d0,d1
	asr.w	#1,d1
	eor.w	d0,d1

	btst	#8,d1
	beq.s	.down
	moveq	#JOY_SPEED,d3
	bra.s	.store

.down	btst	#0,d1
	beq.s	.store
	moveq	#-JOY_SPEED,d3

.store	move.w	d2,joystick.x
	move.w	d3,joystick.y

	andi.b	#$7f,$bfe201.l
	btst	#7,$bfe001.l
	bne.s	.done
	st	fire.pressed

.done	rts


joystick.x	dc.w	0
joystick.y	dc.w	0
fire.pressed	dc.b	0,0
	ENDC
