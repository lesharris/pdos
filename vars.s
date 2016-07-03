;
;  vars.s
;  Variables for PDos
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; "Private" Variables
; Internally used variables, applications should not depend
; on any of these. (62 bytes)
MLILo:
  .byte 0
MLIHi:
  .byte 0
MLIAddr:
  .addr $FFFF
MLIDigit:
  .byte 0
MLIValue:
  .byte 0
MLILead0:
  .byte 0
MLIIndex:
  .byte 0
MLIConvStr:
  .res 4
MLICurrPage:
  .byte 0
MLICurrByte:
  .byte 0
MLIPageStart:
  .byte 0
MLIPageEnd:
  .byte 0
MLIFileRefNum:
  .byte 0
MLITransCount:
  .word $0000
MLIReadCount:
  .word $0000

PDFileStruct:
  .addr $0000     ; File Struct
PDFilePathAddr:
  .addr $0000     ; Pointer to Filepath
PDFileLocation:
  .addr $0000     ; Pointer to R/W Destination
PDRefNumber:
  .byte 0         ; Reference Number
PDByteCount:
  .word 0
PDReadCount:
  .byte 0
PDReadSize:
  .byte 0,0,0
PDRemainingBytes:
  .byte 0,0,0
PDFileBufferScratch:
  .addr $0000     ; Prodos 1024-byte I/O Buffer Pointer
PDEntryLength:
  .byte 0
PDEntriesPerBlock:
  .byte 0
PDFileCount:
  .word 0
PDEntryPointer:
  .byte 0
PDBlockEntries:
  .byte 2
PDActiveEntries:
  .byte 0

; Tables
MLIPositionTable:
  .byte %00000001
  .byte %00000010
  .byte %00000100
  .byte %00001000
  .byte %00010000
  .byte %00100000
  .byte %01000000
  .byte %10000000
MLIReversePositionTable:
  .byte %10000000
  .byte %01000000
  .byte %00100000
  .byte %00010000
  .byte %00001000
  .byte %00000100
  .byte %00000010
  .byte %00000001

MLITable10:
  .byte 1
  .byte 10
  .byte 100

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Public Variables
; Variables that are useful for library users. (109 bytes)

; MLI Status
MLIError:
  .byte 0
MLIErrorString:
  .res 35
MLIDateString:
  .res 10
MLITimeString:
  .res 6

; File Info Struct
PDFileInfo:
PDFileInfo_Path:
  .addr $FFFF            ; PATHNAME
PDFileInfo_Access:
  .res 1                 ; ACCESS
PDFileInfo_FileType:
  .res 1                 ; FILE_TYPE
PDFileInfo_AuxType:
  .res 2                 ; AUX_TYPE
PDFileInfo_StorageType:
  .res 1                 ; STORAGE_TYPE
PDFileInfo_BlocksUsed:
  .res 2                 ; BLOCKS USED
PDFileInfo_ModDate:
  .res 2                 ; MOD_DATE
PDFileInfo_ModTime:
  .res 2                 ; MOD_TIME
PDFileInfo_CreateDate:
  .res 2                 ; CREATE_DATE
PDFileInfo_CreateTime:
  .res 2                 ; CREATE_TIME

; Current Directory Entry Struct
PDDirEntry:
PDDirEntry_StorageType:
  .byte 0
PDDirEntry_NameLength:
  .byte 0
PDDirEntry_FileName:
  .res 15
PDDirEntry_FileType:
  .byte 0
PDDirEntry_KeyPointer:
  .addr $0000
PDDirEntry_BlocksUsed:
  .word 0
PDDirEntry_EOF:
  .byte 0,0,0
PDDirEntry_CreationDate:
  .word 0
PDDirEntry_CreationTime:
  .word 0
PDDirEntry_Version:
  .byte 0
PDDirEntry_MinVersion:
  .byte 0
PDDirEntry_Access:
  .byte 0
PDDirEntry_AuxType:
  .word 0
PDDirEntry_ModificationDate:
  .word 0
PDDirEntry_ModificationTime:
  .word 0
PDDirEntry_HeaderPointer:
  .addr $0000
PDDirEntry_FileTypeStr:
  .res 4