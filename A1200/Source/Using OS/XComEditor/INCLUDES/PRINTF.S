*****************************************************************************
* PrintInit( )
* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
* $Inputs:	None.
* $Outputs:	d0.l=0 if failed.. 
*
* Initializes further usage of Print( ) function.
* Gets output handle, calls AllocMem() for 127 byte output buffer, and
* RawIOInit().  Preserves all registers used.  This should be placed
* in your "opening" routine before any printf() calls.
* D0 will contain a non-zero value ( Z = 0 ) if AllocMem() was successful,
* otherwise D0 = 0 ( Z = 1 ) on return if failure.
*
* ( If PrintInit() fails, you don't need to quit.  Print( ) and can tell that 
* the allocation failed and will return without doing anything. )
******************************************************************************

_PrintInit
	lea	DosName(pc),a1
	moveq	#0,d0
	CALLEXEC OpenLibrary			open dos library
	move.l	d0,_DOSBase
	beq.s	_NoPrintInit

	CALLDOS	Output				get output base
	move.l	d0,_DosOutput

	moveq	#127,d0
	move.l	#(MEMF_PUBLIC+MEMF_CLEAR),d1
	CALLEXEC AllocMem			allocate 127 bytes
	move.l	d0,_MemPtr1

	jsr	_LVORawIOInit(a6)		do a raw IO init

_NoPrintInit
	rts

******************************************************************************
* PrintClose( )
* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*
* If AllocMem() from PrintInit( ) was successful, this does a FreeMem()
* freeing the 127 byte output buffer.  Preserves all registers used.
* This should be placed in your "closing" routine after last printf() call.
******************************************************************************

_PrintClose
	move.l	_MemPtr1,a1
	tst.l	a1
	beq.s	_NoPrintClose

	moveq	#127,d0
	CALLEXEC FreeMem			free raw io memory

_NoPrintClose
	rts

******************************************************************************
* Usage:  printf( FormatString DataStream )
*                   A0            A1
*
* Performs "C" language like formatting of the data stream. Where % formatting
* cmd`s are found in FormatString, they're replaced with the corresponding 
* element in the DataStream.
*
* Printf() outputs the results to the current output handle, usually the CLI.
********************************************************************************

printf
	tst.l	_MemPtr1
	beq.s	_NoPrint
	lea	PrintChar(pc),a2

	move.l	_MemPtr1(pc),a3
	CALLEXEC RawDoFmt

	move.l	_DosOutput(pc),d1
	move.l	_MemPtr1(pc),d2

	move.l	_MemPtr1(pc),a3
	moveq	#-1,d3

getlen	addq.l	#1,d3

	tst.b	(a3)+
	bne.s	getlen

	CALLDOS	Write

_NoPrint
	rts

PrintChar
	move.b	d0,(a3)+
	rts
