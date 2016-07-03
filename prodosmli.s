;
;  prodosmli.s
;  Prodos MLI Information
;

; Prodos MLI Entry Point
MLI                  = $BF00

; Prodos MLI Commands

;; Housekeeping Calls
MLICreate            = $C0
MLIDestroy           = $C1
MLIRename            = $C2
MLISetFileInfo       = $C3
MLIGetFileInfo       = $C4
MLIOnline            = $C5
MLISetPrefix         = $C6
MLIGetPrefix         = $C7

;; Filing Calls
MLIOpen              = $C8
MLINewline           = $C9
MLIRead              = $CA
MLIWrite             = $CB
MLIClose             = $CC
MLIFlush             = $CD
MLISetMark           = $CE
MLIGetMark           = $CF
MLISetEOF            = $D0
MLIGetEOF            = $D1
MLISetBuffer         = $D2
MLIGetBuffer         = $D3

;; System Calls
MLIGetTime           = $82
MLIAllocInterrupt    = $40
MLIDeallocInterrupt  = $41

;; Direct Disk Access Calls
MLIReadBlock         = $80
MLIWriteBlock        = $81

; Location of the Prodos Bitmap
MLIBitmap            = $BF58

; Location of Prodos Date and Time Bytes
MLIDate              = $BF90
MLITime              = $BF92