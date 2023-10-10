	page 0
	cpu z80

;	Z80 CBIOS for Z80-Simulator
;
;	Copyright (C) 1988-2007 by Udo Munk
;
MSIZE	EQU	64		;cp/m version memory size in kilobytes
;
;	"bias" is address offset from 3400H for memory systems
;	than 16K (referred to as "b" throughout the text).
;
BIAS	EQU	(MSIZE-20)*1024
CCP	EQU	3400H+BIAS	;base of ccp
BDOS	EQU	CCP+806H	;base of bdos
BIOS	EQU	CCP+1600H	;base of bios
NSECTS	EQU	(BIOS-CCP)/128	;warm start sector count
CDISK	EQU	0004H		;current disk number 0=A,...,15=P
IOBYTE	EQU	0003H		;intel i/o byte
;
;	I/O ports
;
PRTSTA	EQU	2		;printer status port
PRTDAT	EQU	3		;printer data port
AUXDAT	EQU	5		;auxiliary data port

CONSTA	EQU	40h		;console status port
CONDAT	EQU	41h		;console data port
FDCDAT	EQU	48h		;fdc-port: data (non-DMA)
FDCD	EQU	4ah		;fdc-port: # of drive
FDCT	EQU	4bh		;fdc-port: # of track
FDCS	EQU	4ch		;fdc-port: # of sector
FDCOP	EQU	4dh		;fdc-port: command
FDCST	EQU	4eh		;fdc-port: status
DMAL	EQU	4fh		;dma-port: dma address low
DMAH	EQU	50h		;dma-port: dma address high

DMA_R_W	set	0	; DMA R/W operation switch
PIC_64K	set	0
PIC_32K	set	0

; control priority: DMA_R_W > PIC_32K > PIC_64K

	if	DMA_R_W=0
PIC_64K	set	0
PIC_32K	set	0
	else
	if	PIC_32K=1
PIC_64K	set	0
	else
PIC_64K	set	1
	endif	; PIC_32K=1
	endif	; DMA_R_W=0

PIC_LMTADR	equ	8000h	; PIC can directly access 0 - 7fffh

D_DMA_READ	equ	0
D_DMA_WRITE	equ	1
D_READ		equ	2
D_WRITE		equ	3
D_SUCCESS	equ	0
D_ERROR		equ	1

;
	ORG	BIOS		;origin of this program
;
;	jump vector for individual subroutines
;
	JP	BOOT		;cold start
WBOOTE: JP	WBOOT		;warm start
	JP	CONST		;console status
	JP	CONIN		;console character in
	JP	CONOUT		;console character out
	JP	LIST		;list character out
	JP	PUNCH		;punch character out
	JP	READER		;reader character in
	JP	HOME		;move head to home position
	JP	SELDSK		;select disk
	JP	SETTRK		;set track number
	JP	SETSEC		;set sector number
	JP	SETDMA		;set dma address
	JP	READ		;read disk
	JP	WRITE		;write disk
	JP	LISTST		;return list status
	JP	SECTRAN		;sector translate
;
;	fixed data tables for four-drive standard
;	IBM-compatible 8" SD disks
;
;	disk parameter header for disk 00
DPBASE:	DEFW	TRANS,0000H
	DEFW	0000H,0000H
	DEFW	DIRBF,DPBLK
	DEFW	CHK00,ALL00
;	disk parameter header for disk 01
	DEFW	TRANS,0000H
	DEFW	0000H,0000H
	DEFW	DIRBF,DPBLK
	DEFW	CHK01,ALL01
;	disk parameter header for disk 02
	DEFW	TRANS,0000H
	DEFW	0000H,0000H
	DEFW	DIRBF,DPBLK
	DEFW	CHK02,ALL02
;	disk parameter header for disk 03
	DEFW	TRANS,0000H
	DEFW	0000H,0000H
	DEFW	DIRBF,DPBLK
	DEFW	CHK03,ALL03
;
;	sector translate vector for the IBM 8" SD disks
;
TRANS:	DEFB	1,7,13,19	;sectors 1,2,3,4
	DEFB	25,5,11,17	;sectors 5,6,7,8
	DEFB	23,3,9,15	;sectors 9,10,11,12
	DEFB	21,2,8,14	;sectors 13,14,15,16
	DEFB	20,26,6,12	;sectors 17,18,19,20
	DEFB	18,24,4,10	;sectors 21,22,23,24
	DEFB	16,22		;sectors 25,26
;
;	disk parameter block, common to all IBM 8" SD disks
;
DPBLK:  DEFW	26		;sectors per track
	DEFB	3		;block shift factor
	DEFB	7		;block mask
	DEFB	0		;extent mask
	DEFW	242		;disk size-1
	DEFW	63		;directory max
	DEFB	192		;alloc 0
	DEFB	0		;alloc 1
	DEFW	16		;check size
	DEFW	2		;track offset
;
;	fixed data tables for 4MB harddisks
;
;	disk parameter header
HDB1:	DEFW	0000H,0000H
	DEFW	0000H,0000H
	DEFW	DIRBF,HDBLK
	DEFW	CHKHD1,ALLHD1
HDB2:	DEFW	0000H,0000H
	DEFW	0000H,0000H
	DEFW	DIRBF,HDBLK
	DEFW	CHKHD2,ALLHD2
;
;       disk parameter block for harddisk
;
HDBLK:  DEFW    128		;sectors per track
	DEFB    4		;block shift factor
	DEFB    15		;block mask
	DEFB    0		;extent mask
	DEFW    2039		;disk size-1
	DEFW    1023		;directory max
	DEFB    255		;alloc 0
	DEFB    255		;alloc 1
	DEFW    0		;check size
	DEFW    0		;track offset
;
;	messages
;
SIGNON: DB	'64K CP/M Vers. 2.2 (Z80 CBIOS V1.2 for Z80SIM, '
	DB	'Copyright 1988-2007 by Udo Munk)'
	DB	13,10,0
;
LDERR:	DB	'BIOS: error booting'
	DB	13,10,0

;
;	end of fixed tables
;
;	utility functions
;
;	print a 0 terminated string to console device
;	pointer to string in HL
;
PRTMSG:	LD	A,(HL)
	OR	A
	RET	Z
	LD	C,A
	CALL	CONOUT
	INC	HL
	JP	PRTMSG
;
;	individual subroutines to perform each function
;	simplest case is to just perform parameter initialization
;
BOOT:   LD	SP,80H		;use space below buffer for stack
	LD	HL,SIGNON	;print message
	CALL	PRTMSG
	XOR	A		;zero in the accum
	LD	(IOBYTE),A	;clear the iobyte
	LD	(CDISK),A	;select disk zero
	JP	GOCPM		;initialize and go to cp/m
;
;	simplest case is to read the disk until all sectors loaded
;
WBOOT:  LD	SP,80H		;use space below buffer for stack
	LD	C,0		;select disk 0
	CALL	SELDSK
	CALL	HOME		;go to track 00
;
	LD	B,NSECTS	;b counts # of sectors to load
	LD	C,0		;c has the current track number
	LD	D,2		;d has the next sector to read
;	note that we begin by reading track 0, sector 2 since sector 1
;	contains the cold start loader, which is skipped in a warm start
	LD	HL,CCP		;base of cp/m (initial load point)
LOAD1:				;load one more sector
	PUSH	BC		;save sector count, current track
	PUSH	DE		;save next sector to read
	PUSH	HL		;save dma address
	LD	C,D		;get sector address to register c
	CALL	SETSEC		;set sector address from register c
	POP	BC		;recall dma address to b,c
	PUSH	BC		;replace on stack for later recall
	CALL	SETDMA		;set dma address from b,c
;	drive set to 0, track set, sector set, dma address set
	CALL	READ
	OR	A		;any errors?
	JP	Z,LOAD2		;no, continue
	LD	HL,LDERR	;error, print message
	CALL	PRTMSG
	DI			;and halt the machine
	HALT
;	no error, move to next sector
LOAD2:	POP	HL		;recall dma address
	LD	DE,128		;dma=dma+128
	ADD	HL,DE		;new dma address is in h,l
	POP	DE		;recall sector address
	POP	BC		;recall number of sectors remaining,
				;and current trk
	DEC	B		;sectors=sectors-1
	JP	Z,GOCPM		;transfer to cp/m if all have been loaded
;	more sectors remain to load, check for track change
	INC	D
	LD	A,D		;sector=27?, if so, change tracks
	CP	27
	JP	C,LOAD1		;carry generated if sector<27
;	end of current track, go to next track
	LD	D,1		;begin with first sector of next track
	INC	C		;track=track+1
;	save register state, and change tracks
	CALL	SETTRK		;track address set from register c
	JP	LOAD1		;for another sector
;	end of load operation, set parameters and go to cp/m
GOCPM:
	LD	A,0C3H		;c3 is a jmp instruction
	LD	(0),A		;for jmp to wboot
	LD	HL,WBOOTE	;wboot entry point
	LD	(1),HL		;set address field for jmp at 0
;
	LD	(5),A		;for jmp to bdos
	LD	HL,BDOS		;bdos entry point
	LD	(6),HL		;address field of jump at 5 to bdos
;
	LD	BC,80H		;default dma address is 80h
	CALL	SETDMA
;
	LD	A,(CDISK)	;get current disk number
	LD	C,A		;send to the ccp
	JP	CCP		;go to cp/m for further processing
;
;
;	simple i/o handlers
;
;	console status, return 0ffh if character ready, 00h if not
;
CONST:	IN	A,(CONSTA)	;get console status
	RET
;
;	console character into register a
;
CONIN:	IN	A,(CONDAT)	;get character from console
	RET
;
;	console character output from register c
;
CONOUT: LD	A,C		;get to accumulator
	OUT	(CONDAT),A	;send character to console
	RET
;
;	list character from register c
;
LIST:	LD	A,C		;character to register a
	OUT	(PRTDAT),A
	RET
;
;	return list status (00h if not ready, 0ffh if ready)
;
LISTST: IN	A,(PRTSTA)
	RET
;
;	punch character from register c
;
PUNCH:	LD	A,C		;character to register a
	OUT	(AUXDAT),A
	RET
;
;	read character into register a from reader device
;
READER: IN	A,(AUXDAT)
	RET
;
;
;	i/o drivers for the disk follow
;
;	move to the track 00 position of current drive
;	translate this call into a settrk call with parameter 00
;
HOME:	LD	C,0		;select track 0
	JP	SETTRK		;we will move to 00 on first read/write
;
;	select disk given by register C
;
SELDSK: LD	HL,0000H	;error return code
	LD	A,C
	CP	4		;FD drive 0-3?
	JP	C,SELFD		;go
	CP	8		;harddisk 1?
	JP	Z,SELHD1	;go
	CP	9		;harddisk 2?
	JP	Z,SELHD2	;go
	RET			;no, error
;	disk number is in the proper range
;	compute proper disk parameter header address
SELFD:	OUT	(FDCD),A	;selekt disk drive
	LD	L,A		;L=disk number 0,1,2,3
	ADD	HL,HL		;*2
	ADD	HL,HL		;*4
	ADD	HL,HL		;*8
	ADD	HL,HL		;*16 (size of each header)
	LD	DE,DPBASE
	ADD	HL,DE		;HL=.dpbase(diskno*16)
	RET
SELHD1:	LD	HL,HDB1		;dph harddisk 1
	JP	SELHD
SELHD2:	LD	HL,HDB2		;dph harddisk 2
SELHD:	OUT	(FDCD),A	;select harddisk drive
	RET
;
;	set track given by register c
;
SETTRK: LD	A,C
	OUT	(FDCT),A
	RET
;
;	set sector given by register c
;
SETSEC: LD	A,C
	OUT	(FDCS),A
	RET
;
;	translate the sector given by BC using the
;	translate table given by DE
;
SECTRAN:
	LD	A,D		;do we have a translation table?
	OR	E
	JP	NZ,SECT1	;yes, translate
	LD	L,C		;no, return untranslated
	LD	H,B		;in HL
	INC	L		;sector no. start with 1
	RET	NZ
	INC	H
	RET
SECT1:	EX	DE,HL		;HL=.trans
	ADD	HL,BC		;HL=.trans(sector)
	LD	L,(HL)		;L = trans(sector)
	LD	H,0		;HL= trans(sector)
	RET			;with value in HL
;
;	set dma address given by registers b and c
;
SETDMA: LD	A,C		;low order address
	OUT	(DMAL),A
	LD	HL,DSTL
	LD	(HL),A
	LD	A,B		;high order address
	OUT	(DMAH),A	;in dma
	LD	HL,DSTH
	LD	(HL),A
	RET

	if	DMA_R_W=0	;I/O byte RW operation
;
;	perform read operation
;
READ:	LD	A,D_READ	;read command -> A
	OUT	(FDCOP),A	;start i/o operation
	IN	A,(FDCST)	;status of i/o operation -> A
	OR	A
	RET	NZ		;return if an error occurred
	; read 128 bytes from the I/O port
	PUSH	DE
	PUSH	HL
	LD	E,128
	LD	A,(DSTH)
	LD	H,A
	LD	A,(DSTL)
	LD	L,A
LREAD:
	IN	A,(FDCDAT)
	LD	(HL),A
	INC	HL
	DEC	E
	JP	NZ,LREAD
	POP	HL
	POP	DE
	LD	A,0
	RET

;
;	perform a write operation
;
WRITE:	LD	A,D_WRITE	;write command -> A
	OUT	(FDCOP),A	;start i/o operation
	; write 128 bytes from the I/O port
	PUSH	DE
	PUSH	HL
	LD	E,128
	LD	A,(DSTH)
	LD	H,A
	LD	A,(DSTL)
	LD	L,A
LWRITE:
	LD	A,(HL)
	OUT	(FDCDAT),A
	INC	HL
	DEC	E
	JP	NZ,LWRITE
	POP	HL
	POP	DE
	IN	A,(FDCST)	;status of i/o operation -> A
	RET

	endif	; DMA_R_W=0

	if	PIC_32K=1
;
;	perform read operation
;
READ:
	PUSH	DE
	PUSH	HL
	ld	hl, (DSTL)	; get dma address
	ld	de, 127		; get accsess end address
	add	hl, de
	jr	c, byte_read	; overlap ffff -> 0000
	
	ld	de, PIC_LMTADR
	sbc	hl, de		; check address in DMA area
	jr	c, dma_read	; jp, if end address is not DMA area

byte_read:
	LD	A,D_READ	;byte read command
	OUT	(FDCOP),A	;start i/o operation
	IN	A,(FDCST)	;status of i/o operation -> A
	OR	A
	jr	nz, ret_read	;return if an error occurred
	; read 128 bytes from the I/O port
	LD	E,128
	LD	A,(DSTH)
	LD	H,A
	LD	A,(DSTL)
	LD	L,A
LREAD:
	IN	A,(FDCDAT)
	LD	(HL),A
	INC	HL
	DEC	E
	JP	NZ,LREAD
	LD	A,0
ret_read:
	POP	HL
	POP	DE
	RET

dma_read:
	LD	A,D_DMA_READ	;read command -> A
	OUT	(FDCOP),A	;start i/o operation
	IN	A,(FDCST)	;status of i/o operation -> A
	OR	A
	jr	ret_read

;
;	perform a write operation
;
WRITE:
	PUSH	DE
	PUSH	HL
	ld	hl, (DSTL)	; get dma address
	ld	de, 127		; get accsess end address
	add	hl, de
	jr	c, byte_write	; overlap ffff -> 0000
	
	ld	de, PIC_LMTADR
	sbc	hl, de		; check address in DMA area
	jr	c, dma_write	; jp, if end address is not DMA area

byte_write:
	LD	A,D_WRITE	;byte read command
	OUT	(FDCOP),A	;start i/o operation
	; write 128 bytes from the I/O port
	LD	E,128
	LD	A,(DSTH)
	LD	H,A
	LD	A,(DSTL)
	LD	L,A
LWRITE:
	LD	A,(HL)
	OUT	(FDCDAT),A
	INC	HL
	DEC	E
	JP	NZ,LWRITE

ret_write:
	IN	A,(FDCST)	;status of i/o operation -> A
	POP	HL
	POP	DE
	RET

dma_write:
	LD	A,D_DMA_WRITE	;write command -> A
	OUT	(FDCOP),A	;start i/o operation
	jr	ret_write

	endif	; PIC_32K=1

	if	PIC_64K=1	;DMA RW operation
;
;	perform read operation
;
READ:	LD	A,D_DMA_READ	;read command -> A
	OUT	(FDCOP),A	;start i/o operation
	IN	A,(FDCST)	;status of i/o operation -> A
	OR	A
	RET	

;
;	perform a write operation
;
WRITE:	LD	A,D_DMA_WRITE	;write command -> A
	OUT	(FDCOP),A	;start i/o operation
	IN	A,(FDCST)	;status of i/o operation -> A
	OR	A
	RET

	endif	; PIC_64K=1
;
;	disk I/O destination address in non DMA mode
;
DSTL:	DEFB	0		;disk I/O destination address low
DSTH:	DEFB	0		;disk I/O destination address high
;
;	the remainder of the CBIOS is reserved uninitialized
;	data area, and does not need to be a part of the
;	system memory image (the space must be available,
;	however, between "begdat" and "enddat").
;
;	scratch ram area for BDOS use
;
BEGDAT	EQU	$		;beginning of data area
DIRBF:	DS	128		;scratch directory area
ALL00:	DS	31		;allocation vector 0
ALL01:	DS	31		;allocation vector 1
ALL02:	DS	31		;allocation vector 2
ALL03:	DS	31		;allocation vector 3
ALLHD1:	DS	255		;allocation vector harddisk 1
ALLHD2:	DS	255		;allocation vector harddisk 2
CHK00:	DS	16		;check vector 0
CHK01:	DS	16		;check vector 1
CHK02:	DS	16		;check vector 2
CHK03:	DS	16		;check vector 3
CHKHD1:				;check vector harddisk 1
CHKHD2:				;check vector harddisk 2
;CHKHD1:	DS	0		;check vector harddisk 1
;CHKHD2:	DS	0		;check vector harddisk 2
;
ENDDAT	EQU	$		;end of data area
DATSIZ	EQU	$-BEGDAT	;size of data area
;
	END			;of BIOS
