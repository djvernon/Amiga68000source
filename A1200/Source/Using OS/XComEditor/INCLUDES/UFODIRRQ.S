**********************************************

FREQ_LOAD	equ	0
FREQ_SAVE	equ	2

FILE_NAME_LENGTH	equ	110


request.dir.name

* d7 = function (FREQ_LOAD / FREQ_SAVE)

	moveq	#RT_FILEREQ,d0		initialise file requester
	sub.l	a0,a0
	CALLRT	AllocRequestA
	move.l	d0,file.req
	beq	.requester.not.allocated

	move.l	#file.req.dir,d1
	moveq	#FILE_NAME_LENGTH,d2
	CALLDOS	GetCurrentDirName

	lea	file.req.tags1(pc),a0
	move.l	file.req(pc),a1
	CALLRT	ChangeReqAttrA

	move.l	UFO_EditorWnd(pc),file.req.window
	moveq	#FREQF_PATGAD!FREQF_NOFILES,d0
	cmp.w	#FREQ_SAVE,d7
	bne.s	.flags
	or.l	#FREQF_SAVE,d0

.flags	move.l	d0,file.req.flags
	lea	file.req.tags2(pc),a0
	move.l	file.req(pc),a1
	lea	file.name(pc),a2
	lsl.w	#2,d7
	lea	file.req.prompts(pc),a3
	move.l	(a3,d7.w),a3

.freq	CALLRT	FileRequestA		request file name from user

	tst.l	d0
	beq.s	.not.selected

	move.l	file.req(pc),a0
	move.l	rtfi_Dir(a0),a4

.done	move.l	file.req(pc),a1
	CALLRT	FreeRequest

	moveq	#0,d0
	rts

.not.selected
	move.l	file.req(pc),a1
	CALLRT	FreeRequest

.requester.not.allocated
	moveq	#-1,d0
	rts

file.req.tags1
	dc.l	RTFI_Dir,file.req.dir
	dc.l	TAG_END

file.req.tags2
	dc.l	RTFI_Flags
file.req.flags
	dc.l	FREQF_PATGAD!FREQF_SAVE!FREQF_NOFILES
	dc.l	RTFI_Height,230
	dc.l	RT_ReqPos,REQPOS_CENTERSCR
	dc.l	RT_TopOffset,6
	dc.l	RT_Window
file.req.window
	dc.l	0
	dc.l	TAG_END


file.name	ds.b	FILE_NAME_LENGTH

file.req.dir	ds.b	FILE_NAME_LENGTH

file.req.prompts
	dc.l	req.load.text
	dc.l	0
	dc.l	req.save.text


req.load.text	dc.b	'Select Save Game Directory',0
	even

req.save.text	dc.b	'Select Directory To Save To',0
	even

file.req	dc.l	0
