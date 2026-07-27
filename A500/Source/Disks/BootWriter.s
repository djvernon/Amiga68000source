
		* Bootwriter program *

	section	boot,code_c


* Open the DOS library

	lea	dosname,a1
	moveq.l	#0,d0
	move.l	4.w,a6
	jsr	-552(a6)		OpenLibrary
	move.l	d0,_DOSBase
	beq	error

* Read in boot sectors

	move.l	_DOSBase,a6
	move.l	#InputFile,d1
	move.l	#$3ed,d2		Mode_OldFile
	jsr	-30(a6)			Open
	tst.l	d0
	beq	error_closeDOS
	move.l	d0,_Input

	move.l	_Input,d1
	move.l	#_DiskBuffer,d2
	move.l	#1024,d3
	jsr	-42(a6)			Read

	move.l	_Input,d1
	jsr	-36(a6)			Close

error_closeDOS
	move.l	4.w,a6
	move.l	_DOSBase,a1
	jsr	-414(a6)

* Find current task structure

	move.l	4.w,a6
	sub.l	a1,a1
	jsr	-294(a6)		FindTask
	move.l	d0,_ReadReply+$10	SigTask

* Add reply port

	lea	_ReadReply,a1
	jsr	-354(a6)		AddPort

* Open Disk device

	lea	_DiskIO,a1
	move.l	#0,d0			DF0:
	clr.l	d1			no flags
	lea	TrackDiskDevice,a0
	jsr	-444(a6)		OpenDevice
	tst.l	d0
	bne	error

* Fill I/O structure

	lea	_DiskIO,a1
	move.l	#_ReadReply,14(a1)	set reply port
	move	#3,28(a1)		Write
	move.l	#_DiskBuffer,40(a1)	source
	move.l	#1024,36(a1)		two sectors
	clr.l	44(a1)			no offset

* Write data to disk drive

	move.l	4.w,a6
	jsr	-456(a6)		DoIO
	move.l	_DiskIO+32,d6		actual bytes read
	lea	_DiskIO,a1
	move	#9,28(a1)		turn motor off
	move.l	#0,36(a1)
	jsr	-456(a6)		DoIO

* Remove reply port

	lea	_ReadReply,a1
	jsr	-360(a6)		RemPort

* Close Disk device

	lea	_DiskIO,a1
	jsr	-450(a6)		CloseDevice

error
	rts

TrackDiskDevice	dc.b	'trackdisk.device',0
	even
dosname	dc.b	'dos.library',0
	even
InputFile	dc.b	'ram:Boot',0
	even

_DiskIO	dcb.l	20,0
_ReadReply	dcb.l	8,0
_DiskBuffer	dcb.b	1024,0
_DOSBase	dc.l	0
_Input	dc.l	0
	end
