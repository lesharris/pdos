;
;  strings.s
;  String tables
;

; Maps error code to address of error string.
MLIErrorMessages:
	.byte $00
	.addr NOERROR
	.byte $01
	.addr BADCALL
	.byte $04
	.addr BADPCOUNT
	.byte $25
	.addr INTVECFUL
	.byte $27
	.addr IOERR
	.byte $28
	.addr NODEVICE
	.byte $2B
	.addr NOWRITE
	.byte $2E
	.addr DISKGONE
	.byte $40
	.addr BADPATHSYN
	.byte $42
	.addr FCBTFULL
	.byte $43
	.addr BADREF
	.byte $44
	.addr BADPATH
	.byte $45
	.addr BADVOL
	.byte $46
	.addr BADFILE
	.byte $47
	.addr DUPFILE
	.byte $48
	.addr OVERRUN
	.byte $49
	.addr VOLFULL
	.byte $4A
	.addr BADFRMT
	.byte $4B
	.addr BADSTYPE
	.byte $4C
	.addr EOF
	.byte $4D
	.addr POSBAD
	.byte $4E
	.addr ACCERR
	.byte $50
	.addr FILEOPEN
	.byte $51
	.addr DCNTERR
	.byte $52
	.addr NOTPDOS
	.byte $53
	.addr BADPARAM
	.byte $55
	.addr VCBTFULL
	.byte $56
	.addr BADBUFADR
	.byte $57
	.addr DUPVOL
	.byte $5A
	.addr BADBITMP
; End of Table marker
	.byte $FF

; MLI Error Strings
NOERROR:     .asciiz "NO ERROR"
BADCALL:     .asciiz "BAD SYSTEM CALL NUMBER"
BADPCOUNT:   .asciiz "BAD SYSTEM CALL PARAMETER COUNT"
INTVECFUL:   .asciiz "INTERRUPT VECTOR TABLE FULL"
IOERR:       .asciiz "I/O ERROR"
NODEVICE:    .asciiz "NO DEVICED DETECTED/CONNECTED"
NOWRITE:     .asciiz "DISK WRITE PROTECTED"
DISKGONE:    .asciiz "DISK SWITCHED"
BADPATHSYN:  .asciiz "INVALID PATHNAME SYNTAX"
FCBTFULL:    .asciiz "FILE CONTROL BLOCK TABLE FULL"
BADREF:      .asciiz "INVALID REFERENCE NUMBER"
BADPATH:     .asciiz "PATH NOT FOUND"
BADVOL:      .asciiz "VOLUME DIRECTORY NOT FOUND"
BADFILE:     .asciiz "FILE NOT FOUND"
DUPFILE:     .asciiz "DUPLICATE FILENAME"
OVERRUN:     .asciiz "OVERRUN ERROR"
VOLFULL:     .asciiz "VOLUME DIRECTORY FULL"
BADFRMT:     .asciiz "INCOMPATIBLE FILE FORMAT"
BADSTYPE:    .asciiz "UNSUPPORTED STORAGE TYPE"
EOF: 	     .asciiz "END OF FILE HAS BEEN ENCOUNTERED"
POSBAD:      .asciiz "POSITION OUT OF RANGE"
ACCERR:      .asciiz "ACCESS ERROR"
FILEOPEN:    .asciiz "FILE IS OPEN"
DCNTERR:     .asciiz "DIRECTORY COUNT ERROR"
NOTPDOS:     .asciiz "NOT A PRODOS DISK"
BADPARAM:    .asciiz "INVALID PARAMETER"
VCBTFULL:    .asciiz "VOLUME CONTROL BLOCK TABLE FULL"
BADBUFADR:   .asciiz "BAD BUFFER ADDRESS"
DUPVOL:      .asciiz "DUPLICATE VOLUME"
BADBITMP:    .asciiz "BIT MAP DISK ADDRESS IS IMPOSSIBLE"
ERRNOTFND:   .asciiz "MLI ERROR CODE NOT FOUND"

; Month abbreviations
MLIMonthStrings:
; Padding
  .res 4
  .asciiz "JAN"
  .asciiz "FEB"
  .asciiz "MAR"
  .asciiz "APR"
  .asciiz "MAY"
  .asciiz "JUN"
  .asciiz "JUL"
  .asciiz "AUG"
  .asciiz "SEP"
  .asciiz "OCT"
  .asciiz "NOV"
  .asciiz "DEC"

PDFileTypes:
; Number of Entries
  .byte $06

  .byte $04
  .addr FILETYPE_TXT
  .byte $05
  .addr FILETYPE_PAS
  .byte $06
  .addr FILETYPE_BIN
  .byte $0F
  .addr FILETYPE_DIR
  .byte $FC
  .addr FILETYPE_BAS
  .byte $FF
  .addr FILETYPE_SYS


FILETYPE_TXT:	.asciiz "TXT"
FILETYPE_PAS:	.asciiz "PAS"
FILETYPE_BIN:	.asciiz "BIN"
FILETYPE_DIR:	.asciiz "DIR"
FILETYPE_BAS:	.asciiz "BAS"
FILETYPE_SYS:	.asciiz "SYS"

NODATE: .asciiz "<NO DATE>"