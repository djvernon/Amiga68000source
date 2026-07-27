	section	CreateProcess,code
	opt	c+

	incdir	DH0:include/

	include	exec/exec_lib.i
	include	libraries/dos.i
	include	libraries/dos_lib.i
	include	libraries/dosextens.i


* When the program is loaded into memory by DOS, the longword directly
* before the start of the program is a BCPL pointer to the next program
* segment in the list.  In this case, the longword points to the code of
* the process to be created.


start	sub.l	a1,a1
	CALLEXEC FindTask
	move.l	d0,a4

	tst.l	pr_CLI(a4)
	bne.s	open.DOS		if called from the CLI

* we were called from the Workbench

from.WB	lea	pr_MsgPort(a4),a0
	CALLEXEC WaitPort
	lea	pr_MsgPort(a4),a0
	CALLEXEC GetMsg
	move.l	d0,Return.Msg		save message for later

open.DOS
	moveq	#0,d0
	lea	dos_name0(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_DOSBase0
	beq.s	exit.false

	CALLEXEC Forbid

	move.l	#Process.Name,d1
	moveq	#0,d2
	move.b	LN_PRI(a4),d2		copy priority from current process
	lea	start-4(pc),a0
	move.l	(a0),d3			get pointer to next program segment

* Now clear pointer, so that DOS will only unload this program segment (the
* process creator) and will leave all following segments intact (because
* these will still be in use by the created process).  When the created
* process finishes, it will unload its segments before terminating.

	clr.l	(a0)

	move.l	#4000,d4		set stack size
	move.l	_DOSBase0(pc),a6
	jsr	_LVOCreateProc(a6)

	CALLEXEC Permit

	move.l	_DOSBase0(pc),a1
	CALLEXEC CloseLibrary

exit.false
	tst.l	Return.Msg
	beq.s	exit.to.DOS

	CALLEXEC Forbid
	move.l	Return.Msg(pc),a1
	CALLEXEC ReplyMsg

exit.to.DOS
	moveq	#0,d0
	rts


Return.Msg	dc.l	0
_DOSBase0	dc.l	0


dos_name0	DOSNAME


Process.Name	dc.b	'Dan''s Process',0
	even


********************************************************************************

	section	Process,code


process.start
	sub.l	a1,a1
	CALLEXEC FindTask
	move.l	d0,Process.Task

	moveq	#0,d0
	lea	dos_name(pc),a1
	CALLEXEC OpenLibrary
	move.l	d0,_DOSBase
	beq	process.exit.false

	bsr	process.main

	CALLEXEC Forbid

	lea	process.start-4(pc),a0
	move.l	a0,d1
	lsr.l	#2,d1
	CALLDOS UnLoadSeg

	move.l	_DOSBase(pc),a1
	CALLEXEC CloseLibrary

process.exit.false
	moveq	#0,d0
	rts


process.main
	moveq	#10,d1
	CALLDOS	Delay

	btst	#7,$bfe001
	bne.s	process.main
	rts

	
Process.Task	dc.l	0
_DOSBase	dc.l	0


dos_name	DOSNAME
	even
