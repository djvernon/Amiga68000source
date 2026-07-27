
		* Boot track reader program *
		* NB This reads all 11 sectors from the boot track *

	section	bootTrack,code_c


* Find current task structure

	move.l	4,a6
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
	move	#2,28(a1)		Read
	move.l	#_DiskBuffer,40(a1)	destination
	move.l	#11*512,36(a1)		11 sectors
	clr.l	44(a1)			no offset

* Read data from disk drive

	move.l	4,a6
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

* Open the DOS library

	lea	dosname,a1
	moveq.l	#0,d0
	jsr	-552(a6)		OpenLibrary
	move.l	d0,_DOSBase
	beq	error

* Write out boot sectors

	move.l	_DOSBase,a6
	move.l	#OutputFile,d1
	move.l	#$3ee,d2		Mode_NewFile
	jsr	-30(a6)			Open
	tst.l	d0
	beq	error_closeDOS
	move.l	d0,_Output

	move.l	_Output,d1
	move.l	#_DiskBuffer,d2
	move.l	#11*512,d3
	jsr	-48(a6)			Write

	move.l	_Output,d1
	jsr	-36(a6)			Close

error_closeDOS
	move.l	$4,a6
	move.l	_DOSBase,a1
	jsr	-414(a6)

error
	rts

TrackDiskDevice	dc.b	'trackdisk.device',0
	even
dosname	dc.b	'dos.library',0
	even
OutputFile	dc.b	'ram:BootTrack',0
	even

_DiskIO	dcb.l	20,0
_ReadReply	dcb.l	8,0
_DiskBuffer	dcb.b	11*512,0
_DOSBase	dc.l	0
_Output	dc.l	0
	end
