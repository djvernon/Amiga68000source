	opt	c+,a+


	include DH0:Devpac/System2.gs


DisplayReg	macro		<reg>
		move.l		#0,_RegString
		move.w		#'\1',_RegString
		move.l		\1,-(sp)
		bsr		_BuildString
		move.l		(sp)+,\1
		endm

DisplayMem	macro		<label>
		move.l		#'mem ',_RegString
		move.l		\1,-(sp)
		bsr		_BuildString
		move.l		(sp)+,\1
		endm


* Open the DOS library

	moveq	#0,d0
	lea	DOS.name(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_DOSBase
	beq	exit.false

* Get standard output handle

	CALLDOS	Output
	move.l	d0,StdOutHandle


*"""""""""""""
*" MAIN LOOP "
*"	     "
*"""""""""""""

	move.l	#23,d0
	DisplayReg	d0

	bsr	MousePress


*""""""""""""""""
*" EXIT ROUTINE	"
*"		"
*""""""""""""""""

exit.close.dos
	move.l	_DOSBase(pc),a1
	CALLEXEC CloseLibrary

exit.false
	moveq	#0,d0
	rts


*"""""""""""""""
*" SUBROUTINES "
*"	       "
*"""""""""""""""

MousePress	btst		#6,$bfe001.l
		bne		MousePress
.loop		btst		#6,$bfe001.l
		beq		.loop
		rts


****************************************


; Entry		value on stack!

_BuildString	movem.l		d0-d3/a0-a6,-(sp)
		move.l		4*12(sp),d0
		move.l		d0,_DS1			save
		move.l		d0,_DS1+4
		bsr		_MakeBinStr
		lea		_Template,a0
		lea		_DStream,a1
		lea		_PutC,a2
		lea		_DBuff,a3
		CALLEXEC	RawDoFmt
		lea		_DBuff,a0
		bsr		DosMsg
		movem.l		(sp)+,d0-d3/a0-a6
		rts


****************************************


_PutC		move.b		d0,(a3)+
		rts


****************************************


; Entry		d0=longword value to convert

; Exit		_BinString contains binary string

; Corrupt	None


_MakeBinStr	movem.l		d0-d2/a0,-(sp)		save
		moveq.l		#31,d1			counter
		lea		_BinString(pc),a0	buffer

.loop		move.b		#'0',d2			default
		rol.l		#1,d0			next bit into C flag
		bcc.s		.ok			skip if bit=0
		move.b		#'1',d2

.ok		move.b		d2,(a0)+		write next char
		dbra		d1,.loop		and loop
		
		movem.l		(sp)+,d0-d2/a0		restore
							
		rts					exit


****************************************


***************	Subroutine to display any message in the CLI window

; Entry		a0 must hold address of 0 terminated message.
;		STD_OUT should hold handle of file to be written to.
;		DOS library must be open

DosMsg		movem.l		d0-d3/a0-a3,-(sp) save registers

		move.l		a0,a1		get a working copy

;--------------	Determine length of message

		moveq.l		#-1,d3		reset counter
.loop		addq.l		#1,d3		bump counter
		tst.b		(a1)+		is this byte a 0
		bne.s		.loop		if not loop back

;--------------	Make sure there was a message

		tst.l		d3		was there a message ?
		beq.s		.error		if not, graceful exit

;--------------	Get handle of output file

		move.l		StdOutHandle,d1	d1=file handle
		beq.s		.error		leave if no handle

;--------------	Now print the message
;		At this point, d3 already holds length of message
;		and d1 holds the file handle.

		move.l		a0,d2		d2=address of message
		CALLDOS		Write		and print it

;--------------	All done so finish

.error		movem.l		(sp)+,d0-d3/a0-a3 restore registers
		rts


*"""""""""""""
*" VARIABLES "
*"	     "
*"""""""""""""

_DOSBase	dc.l	0

StdOutHandle	dc.l	0

_DStream	dc.l		_RegString
		dc.w		'%'
		dc.l		_BinString
_DS1		dc.l		0
		dc.l		0

_RegString	ds.b		6
_BinString	ds.b		32
		dc.w		0		NULL terminate
_DBuff		ds.b		82


*"""""""""""""
*" CONSTANTS "
*"	     "
*"""""""""""""

DOS.name	DOSNAME

_Template	dc.b		'%s = %c%s,%11ld,$%08lx',$0a,0
		even

