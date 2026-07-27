	section	GfxBase,code


	include	DH0:Devpac/System2.gs


* Open the graphics library

	moveq	#0,d0
	lea	graphics.name(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_GfxBase
	beq	exit.false

* Open the DOS library

	moveq	#0,d0
	lea	DOS.name(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_DOSBase
	beq	exit.close.graf

* Get standard output handle

	CALLDOS	Output
	move.l	d0,StdOutHandle


	bsr	show.gfxbase


*""""""""""""""""
*" EXIT ROUTINE	"
*"		"
*""""""""""""""""

exit.close.dos
	move.l	_DOSBase(pc),a1
	CALLEXEC CloseLibrary

exit.close.graf
	move.l	_GfxBase(pc),a1
	CALLEXEC CloseLibrary

exit.false
	moveq	#0,d0
	rts


*"""""""""""""
*" VARIABLES "
*"	     "
*"""""""""""""

_GfxBase	dc.l	0
_DOSBase	dc.l	0
StdOutHandle	dc.l	0


*"""""""""""""
*" CONSTANTS "
*"	     "
*"""""""""""""

graphics.name	GRAFNAME
DOS.name	DOSNAME


*"""""""""""""""
*" SUBROUTINES "
*"	       "
*"""""""""""""""

	include	"DH0:Source/Using OS/Debug.s"


show.gfxbase
	DEBUGL	<GfxBase : >,_GfxBase
	rts


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

