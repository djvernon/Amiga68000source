	section	lard,code
	opt	c+
	opt	d+


	include DH0:Devpac/System2.gs


CINIT	MACRO
	move.l	\1,a0
	move.l	#\2,d0
	CALLGRAF	UCopperListInit	
	ENDM

CMOVE	MACRO
	move.l	\1,a1
	move.w	\2,d0
	move.w	\3,d1
	CALLGRAF	CMove
	move.l	\1,a1
	CALLGRAF	CBump	
	ENDM

CWAIT	MACRO
	move.l	\1,a1
	move.w	\2,d0
	move.w	\3,d1
	CALLGRAF	CWait
	move.l	\1,a1
	CALLGRAF	CBump	
	ENDM

CEND	MACRO
	move.l	\1,a1
	move.w	#10000,d0
	move.w	#255,d1
	CALLGRAF	CWait
	move.l	\1,a1
	CALLGRAF	CBump	
	ENDM

	*-----------------*


	lea	CopperList,a0

NextWord
	cmp.w	#$ffff,(a0)
	beq.s	StopChange

	sub.w	#$2c00,(a0)
	add.l	#8,a0
	bra.s	NextWord


	*-----------------*

StopChange
	Lea	GFXName,A1
	Moveq	#0,D0
	CALLEXEC	OpenLibrary
	Move.l 	D0,_GfxBase
	Beq	Error

	Lea	DosName,A1
	Moveq	#0,D0
	CALLEXEC	OpenLibrary
	Move.l 	D0,_DOSBase
	Beq	Error

	Lea	IntName,A1
	Moveq	#0,D0
	CALLEXEC	OpenLibrary
	Move.l	D0,_IntuitionBase
	Beq	Error

	*-----------------------------------------------*

	Lea	MyScreen,a0
	CALLINT	OpenScreen
	Move.l	D0,_MyScrBase
	Beq	CloseInt

	*-----------------------------------------------*

	move.l	#ucl_SIZEOF,d0
	move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1
	CALLEXEC	AllocMem
	move.l	d0,MyCopper

	*-------------------*

	CINIT 	MyCopper,5000

	lea	CopperList,a5

floop	movem.w	(a5)+,d0-d1
	bsr	CopCom
	
	cmp.w	#$ffff,0(a5)
	bne	floop
	
	CEND	MyCopper

	*-------------------*

	CALLEXEC	Forbid

	Move.l	_MyScrBase,a0
	lea	sc_ViewPort(a0),a1
	move.l	MyCopper,vp_UCopIns(a1)		;viewPort->UCopIns=uCopList

	CALLEXEC	Permit
	CALLINT	RethinkDisplay

	*-----------------------------------------------*

yWaitLoop
	btst	#6,$bfe001
	bne.s	yWaitLoop
	
	*-------------------------------*

	Move.l	_MyScrBase,a0
	lea	sc_ViewPort(a0),a1
	move.l	d0,a0
	CALLGRAF FreeVPortCopLists
	CALLINT	RethinkDisplay

	Move.l	_MyScrBase,A0
	CALLINT	CloseScreen

	*-------------------------------*
	
CloseInt
	Move.l	_IntuitionBase,A1
	CALLEXEC CloseLibrary

	Move.l	_DOSBase,A1
	CALLEXEC CloseLibrary

	Move.l	_GfxBase,A1
	CALLEXEC CloseLibrary

	*-------------------------------*

Error	Moveq	#0,D0
	Rts

	*-------------------------------*

CopCom:	btst	#0,d0
	beq	.move

	move.w	d0,d1
	and.l	#$000000ff,d1
	lsr.w	#8,d0
	
	CWAIT 	MyCopper,d0,d1
	rts
	
.move	CMOVE	MyCopper,d0,d1
	rts
		
	*-------------------------------*

_MyScrBase		Dc.l	0

_IntuitionBase	Dc.l	0
_DOSBase		Dc.l	0
_GfxBase		dc.l	0

GFXName		GRAFNAME
IntName		INTNAME
DosName		DOSNAME
		even

	
**************************************************

MyScreen:
	dc.w	0,0
	dc.w	640,200
	dc.w	2
	dc.b	0,1
	dc.w	V_HIRES
	dc.w	CUSTOMSCREEN+SCREENQUIET
	dc.l	0
	dc.l	NewScreenName
	dc.l	0
	dc.l	0
NewScreenName:
	dc.b	'Lard',0

	even

**************************************************

MyCopper:	dc.l	0
	
CopperList:
	dc.w	$2c01,$fffe,$0180,$0fff
	dc.w	$2d01,$fffe,$0180,$0fff
	dc.w	$2e01,$fffe,$0180,$0fff
	dc.w	$2f01,$fffe,$0180,$0fff
	dc.w	$3001,$fffe,$0180,$0fff
	dc.w	$3101,$fffe,$0180,$0fff
	dc.w	$3201,$fffe,$0180,$0fff
	dc.w	$3301,$fffe,$0180,$0fff
	dc.w	$3401,$fffe,$0180,$0fff
	dc.w	$3501,$fffe,$0180,$0fff
	dc.w	$3601,$fffe,$0180,$0fff
	dc.w	$3701,$fffe,$0180,$0fff
	dc.w	$3801,$fffe,$0180,$0fff
	dc.w	$3901,$fffe,$0180,$0eef
	dc.w	$3a01,$fffe,$0180,$0fff
	dc.w	$3b01,$fffe,$0180,$0eef
	dc.w	$3c01,$fffe,$0180,$0eef
	dc.w	$3d01,$fffe,$0180,$0eef
	dc.w	$3e01,$fffe,$0180,$0eef
	dc.w	$3f01,$fffe,$0180,$0eef
	dc.w	$4001,$fffe,$0180,$0eef
	dc.w	$4101,$fffe,$0180,$0eef
	dc.w	$4201,$fffe,$0180,$0eef
	dc.w	$4301,$fffe,$0180,$0eef
	dc.w	$4401,$fffe,$0180,$0eef
	dc.w	$4501,$fffe,$0180,$0ddf
	dc.w	$4601,$fffe,$0180,$0eef
	dc.w	$4701,$fffe,$0180,$0ddf
	dc.w	$4801,$fffe,$0180,$0ddf
	dc.w	$4901,$fffe,$0180,$0ddf
	dc.w	$4a01,$fffe,$0180,$0ddf
	dc.w	$4b01,$fffe,$0180,$0ddf
	dc.w	$4c01,$fffe,$0180,$0ddf
	dc.w	$4d01,$fffe,$0180,$0ddf
	dc.w	$4e01,$fffe,$0180,$0ddf
	dc.w	$4f01,$fffe,$0180,$0ddf
	dc.w	$5001,$fffe,$0180,$0ddf
	dc.w	$5101,$fffe,$0180,$0ddf
	dc.w	$5201,$fffe,$0180,$0ddf
	dc.w	$5301,$fffe,$0180,$0ccf
	dc.w	$5401,$fffe,$0180,$0ddf
	dc.w	$5501,$fffe,$0180,$0ccf
	dc.w	$5601,$fffe,$0180,$0ccf
	dc.w	$5701,$fffe,$0180,$0ccf
	dc.w	$5801,$fffe,$0180,$0ccf
	dc.w	$5901,$fffe,$0180,$0ccf
	dc.w	$5a01,$fffe,$0180,$0ccf
	dc.w	$5b01,$fffe,$0180,$0ccf
	dc.w	$5c01,$fffe,$0180,$0ccf
	dc.w	$5d01,$fffe,$0180,$0ccf
	dc.w	$5e01,$fffe,$0180,$0ccf
	dc.w	$5f01,$fffe,$0180,$0ccf
	dc.w	$6001,$fffe,$0180,$0bbf
	dc.w	$6101,$fffe,$0180,$0ccf
	dc.w	$6201,$fffe,$0180,$0bbf
	dc.w	$6301,$fffe,$0180,$0bbf
	dc.w	$6401,$fffe,$0180,$0bbf
	dc.w	$6501,$fffe,$0180,$0bbf
	dc.w	$6601,$fffe,$0180,$0bbf
	dc.w	$6701,$fffe,$0180,$0bbf
	dc.w	$6801,$fffe,$0180,$0bbf
	dc.w	$6901,$fffe,$0180,$0bbf
	dc.w	$6a01,$fffe,$0180,$0bbf
	dc.w	$6b01,$fffe,$0180,$0bbf
	dc.w	$6c01,$fffe,$0180,$0bbf
	dc.w	$6d01,$fffe,$0180,$0aaf
	dc.w	$6e01,$fffe,$0180,$0bbf
	dc.w	$6f01,$fffe,$0180,$0aaf
	dc.w	$7001,$fffe,$0180,$0aaf
	dc.w	$7101,$fffe,$0180,$0aaf
	dc.w	$7201,$fffe,$0180,$0aaf
	dc.w	$7301,$fffe,$0180,$0aaf
	dc.w	$7401,$fffe,$0180,$0aaf
	dc.w	$7501,$fffe,$0180,$0aaf
	dc.w	$7601,$fffe,$0180,$0aaf
	dc.w	$7701,$fffe,$0180,$0aaf
	dc.w	$7801,$fffe,$0180,$0aaf
	dc.w	$7901,$fffe,$0180,$0aaf
	dc.w	$7a01,$fffe,$0180,$0aaf
	dc.w	$7b01,$fffe,$0180,$099f
	dc.w	$7c01,$fffe,$0180,$0aaf
	dc.w	$7d01,$fffe,$0180,$099f
	dc.w	$7e01,$fffe,$0180,$099f
	dc.w	$7f01,$fffe,$0180,$099f
	dc.w	$8001,$fffe,$0180,$099f
	dc.w	$8101,$fffe,$0180,$099f
	dc.w	$8201,$fffe,$0180,$099f
	dc.w	$8301,$fffe,$0180,$099f
	dc.w	$8401,$fffe,$0180,$099f
	dc.w	$8501,$fffe,$0180,$099f
	dc.w	$8601,$fffe,$0180,$099f
	dc.w	$8701,$fffe,$0180,$088f
	dc.w	$8801,$fffe,$0180,$099f
	dc.w	$8901,$fffe,$0180,$088f
	dc.w	$8a01,$fffe,$0180,$088f
	dc.w	$8b01,$fffe,$0180,$088f
	dc.w	$8c01,$fffe,$0180,$088f
	dc.w	$8d01,$fffe,$0180,$088f
	dc.w	$8e01,$fffe,$0180,$088f
	dc.w	$8f01,$fffe,$0180,$088f
	dc.w	$9001,$fffe,$0180,$088f
	dc.w	$9101,$fffe,$0180,$088f
	dc.w	$9201,$fffe,$0180,$088f
	dc.w	$9301,$fffe,$0180,$088f
	dc.w	$9401,$fffe,$0180,$088f
	dc.w	$9501,$fffe,$0180,$088f
	dc.w	$9601,$fffe,$0180,$077f
	dc.w	$9701,$fffe,$0180,$088f
	dc.w	$9801,$fffe,$0180,$077f
	dc.w	$9901,$fffe,$0180,$077f
	dc.w	$9a01,$fffe,$0180,$077f
	dc.w	$9b01,$fffe,$0180,$077f
	dc.w	$9c01,$fffe,$0180,$077f
	dc.w	$9d01,$fffe,$0180,$077f
	dc.w	$9e01,$fffe,$0180,$077f
	dc.w	$9f01,$fffe,$0180,$077f
	dc.w	$a001,$fffe,$0180,$077f
	dc.w	$a101,$fffe,$0180,$066f
	dc.w	$a201,$fffe,$0180,$077f
	dc.w	$a301,$fffe,$0180,$066f
	dc.w	$a401,$fffe,$0180,$066f
	dc.w	$a501,$fffe,$0180,$066f
	dc.w	$a601,$fffe,$0180,$066f
	dc.w	$a701,$fffe,$0180,$066f
	dc.w	$a801,$fffe,$0180,$066f
	dc.w	$a901,$fffe,$0180,$066f
	dc.w	$aa01,$fffe,$0180,$055f
	dc.w	$ab01,$fffe,$0180,$066f
	dc.w	$ac01,$fffe,$0180,$055f
	dc.w	$ad01,$fffe,$0180,$055f
	dc.w	$ae01,$fffe,$0180,$055f
	dc.w	$af01,$fffe,$0180,$055f
	dc.w	$b001,$fffe,$0180,$055f
	dc.w	$b101,$fffe,$0180,$055f
	dc.w	$b201,$fffe,$0180,$055f
	dc.w	$b301,$fffe,$0180,$044f
	dc.w	$b401,$fffe,$0180,$055f
	dc.w	$b501,$fffe,$0180,$044f
	dc.w	$b601,$fffe,$0180,$044f
	dc.w	$b701,$fffe,$0180,$044f
	dc.w	$b801,$fffe,$0180,$044f
	dc.w	$b901,$fffe,$0180,$044f
	dc.w	$ba01,$fffe,$0180,$044f
	dc.w	$bb01,$fffe,$0180,$033f
	dc.w	$bc01,$fffe,$0180,$044f
	dc.w	$bd01,$fffe,$0180,$033f
	dc.w	$be01,$fffe,$0180,$033f
	dc.w	$bf01,$fffe,$0180,$033f
	dc.w	$c001,$fffe,$0180,$033f
	dc.w	$c101,$fffe,$0180,$033f
	dc.w	$c201,$fffe,$0180,$033f
	dc.w	$c301,$fffe,$0180,$033f
	dc.w	$c401,$fffe,$0180,$033f
	dc.w	$c501,$fffe,$0180,$033f
	dc.w	$c601,$fffe,$0180,$033f
	dc.w	$c701,$fffe,$0180,$033f
	dc.w	$c801,$fffe,$0180,$033f
	dc.w	$c901,$fffe,$0180,$000f
	dc.w	$ca01,$fffe,$0180,$000f
	dc.w	$cb01,$fffe,$0180,$000f
	dc.w	$cc01,$fffe,$0180,$000f
	dc.w	$cd01,$fffe,$0180,$000f
	dc.w	$ce01,$fffe,$0180,$000f
	dc.w	$cf01,$fffe,$0180,$000f
	dc.w	$d001,$fffe,$0180,$000f
	dc.w	$d101,$fffe,$0180,$000f
	dc.w	$d201,$fffe,$0180,$000f
	dc.w	$d301,$fffe,$0180,$000f
	dc.w	$d401,$fffe,$0180,$000f
	dc.w	$d501,$fffe,$0180,$000f
	dc.w	$d601,$fffe,$0180,$000f
	dc.w	$d701,$fffe,$0180,$000f
	dc.w	$d801,$fffe,$0180,$000f
	dc.w	$d901,$fffe,$0180,$000f
	dc.w	$da01,$fffe,$0180,$000f
	dc.w	$db01,$fffe,$0180,$000f
	dc.w	$dc01,$fffe,$0180,$000f
	dc.w	$dd01,$fffe,$0180,$000f
	dc.w	$de01,$fffe,$0180,$000f
	dc.w	$df01,$fffe,$0180,$000f
	dc.w	$e001,$fffe,$0180,$000f
	dc.w	$e101,$fffe,$0180,$000f
	dc.w	$e201,$fffe,$0180,$000f
	dc.w	$e301,$fffe,$0180,$000f
	dc.w	$e401,$fffe,$0180,$000f
	dc.w	$e501,$fffe,$0180,$000f
	dc.w	$e601,$fffe,$0180,$000f
	dc.w	$e701,$fffe,$0180,$000f
	dc.w	$e801,$fffe,$0180,$000f
	dc.w	$e901,$fffe,$0180,$000f
	dc.w	$ea01,$fffe,$0180,$000f
	dc.w	$eb01,$fffe,$0180,$000f
	dc.w	$ec01,$fffe,$0180,$000f
	dc.w	$ed01,$fffe,$0180,$000f
	dc.w	$ee01,$fffe,$0180,$000f
	dc.w	$ef01,$fffe,$0180,$000f
	dc.w	$f001,$fffe,$0180,$000f
	dc.w	$f101,$fffe,$0180,$000f
	dc.w	$f201,$fffe,$0180,$000f
	dc.w	$f301,$fffe,$0180,$000f
	dc.w	$f401,$fffe,$0180,$000f
	dc.w	$f501,$fffe,$0180,$000f
	dc.w	$f601,$fffe,$0180,$000f
	dc.w	$f701,$fffe,$0180,$000f
	dc.w	$f801,$fffe,$0180,$000f
	dc.w	$f901,$fffe,$0180,$000f
	dc.w	$fa01,$fffe,$0180,$000f
	dc.w	$fb01,$fffe,$0180,$000f
	dc.w	$fc01,$fffe,$0180,$000f
	dc.w	$fd01,$fffe,$0180,$000f
	dc.w	$fe01,$fffe,$0180,$000f
	dc.w	$ff01,$fffe,$0180,$000f

	dc.w	$ffff,$fffe
	
	end



