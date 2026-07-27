	section	SCSICommand,code_c


	incdir	DH0:include/

	include	devices/input.i
	include	devices/scsidisk.i
	include	exec/exec_lib.i


READ_BUFFER_SIZE	equ	256


* Add read reply port

	sub.l	a1,a1
	CALLEXEC FindTask
	move.l	d0,our.task

	lea	read.reply.port(pc),a1
	move.l	d0,MP_SIGTASK(a1)
	CALLEXEC AddPort


* Open SCSI device

	lea	SCSI.device.name(pc),a0
	moveq	#0,d0			unit DH0:
	lea	SCSI.IO.request(pc),a1
	moveq	#0,d1			no flags
	CALLEXEC OpenDevice
	tst.l	d0
	bne	error


* Perform command

	lea	SCSI.command(pc),a1
	move.l	#read.buffer,scsi_Data(a1)
	move.l	#254,scsi_Length(a1)
	move.w	#6,scsi_CmdLength(a1)
	move.b	#SCSIF_AUTOSENSE|SCSIF_READ,scsi_Flags(a1)
	move.l	#sense.data,scsi_SenseData(a1)
	move.w	#18,scsi_SenseLength(a1)
	move.w	#0,scsi_SenseActual(a1)
	move.l	#mode.sense,scsi_Command(a1)

	lea	SCSI.IO.request(pc),a1
	move.l	#read.reply.port,MN_REPLYPORT(a1)
	move.w	#HD_SCSICMD,IO_COMMAND(a1)
	move.l	#SCSI.command,IO_DATA(a1)
	move.l	#scsi_SIZEOF,IO_LENGTH(a1)
	CALLEXEC DoIO

	moveq	#0,d0
	move.b	SCSI.command+scsi_Status(pc),d0


* Close SCSI device

	lea	SCSI.IO.request(pc),a1
	CALLEXEC CloseDevice


* Remove reply port

error	lea	read.reply.port(pc),a1
	CALLEXEC RemPort
	rts


SCSI.device.name	dc.b	'scsi.device',0
mode.sense	dc.b	$1a,0,$ff,0,254,0
start.unit	dc.b	$1b,0,0,0,1,0
stop.unit	dc.b	$1b,0,0,0,0,0


our.task	dc.l	0
read.reply.port	ds.b	MP_SIZE
SCSI.IO.request	ds.b	IOSTD_SIZE
SCSI.command	ds.b	scsi_SIZEOF
read.buffer	ds.b	READ_BUFFER_SIZE
sense.data	ds.b	20
