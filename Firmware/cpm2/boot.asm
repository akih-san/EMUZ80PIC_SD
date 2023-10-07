	page 0
	cpu z80

;	CP/M 2.2 boot-loader for Z80-Simulator
;
;	Copyright (C) 1988-2007 by Udo Munk
;
	ORG	0		;mem base of boot
;
MSIZE	EQU	64		;mem size in kbytes
;
BIAS	EQU	(MSIZE-20)*1024	;offset from 20k system
CCP	EQU	3400H+BIAS	;base of the ccp
BIOS	EQU	CCP+1600H	;base of the bios
BIOSL	EQU	0300H		;length of the bios
BOOT	EQU	BIOS
SIZE	EQU	BIOS+BIOSL-CCP	;size of cp/m system
SECTS	EQU	SIZE/128	;# of sectors to load
;
;	I/O ports
;
CONDAT	EQU	41h		;console data port
FDCDAT	EQU	48h		;fdc-port: data (non-DMA)
DRIVE   EQU	4ah		;fdc-port: # of drive
TRACK   EQU	4bh		;fdc-port: # of track
SECTOR  EQU	4ch		;fdc-port: # of sector
FDCOP   EQU	4dh		;fdc-port: command
FDCST   EQU	4eh		;fdc-port: status
DMAL    EQU	4fh		;dma-port: dma address low
DMAH    EQU	50h		;dma-port: dma address high
;
	JP	COLD
;
ERRMSG:	DB	"BOOT: error booting"
	DB	13,10,0
;
;	begin the load operation
;
COLD:	LD	BC,2		;b=track 0, c=sector 2
	LD	D,SECTS		;d=# sectors to load
	LD	HL,CCP		;base transfer address
	XOR	A		;select drive A
	OUT	(DRIVE),A
;
;	load the next sector
;
LSECT:	LD	A,B		;set track
	OUT	(TRACK),A
	LD	A,C		;set sector
	OUT	(SECTOR),A
	LD	A,H
	OUT	(DMAH),A
	LD	A,L
	OUT	(DMAL),A
	LD	A,2		;read sector (non-DMA)
	OUT	(FDCOP),A
	IN	A,(FDCST)	;get status of fdc
	OR	A		;read successful ?
	JP	Z,CONT		;yes, continue
	LD	HL,ERRMSG	;no, print error
PRTMSG:	LD	A,(HL)
	OR	A
	JP	Z,STOP
	OUT	(CONDAT),A
	INC	HL
	JP	PRTMSG
STOP:	DI
	HALT			;and halt cpu
;
CONT:
;
;	read data to the destination address
;
	LD	E,128		;128 bytes per sector
LBYTE:
	IN	A,(FDCDAT)
	LD	(HL),A
	INC	HL
	DEC	E
	JP	NZ,LBYTE
				;go to next sector if load is incomplete
	DEC	D		;sects=sects-1
	JP	Z,BOOT		;head for the bios
;
;	more sectors to load
;
	INC	C		;sector = sector + 1
	LD	A,C
	CP	27		;last sector of track ?
	JP	C,LSECT		;no, go read another
;
;	end of track, increment to next track
;
	LD	C,1		;sector = 1
	INC	B		;track = track + 1
	JP	LSECT		;for another group
;
	END			;of boot loader
