;
;  parameters.s
;  Prodos MLI Parameter Blocks
;

; Housekeeping Parameters

;; CREATE
MLICreateParam:
	.byte 7                ; PARAM_COUNT
	.addr $FFFF            ; PATHNAME
	.byte $FF              ; ACCESS
	.byte $FF              ; FILE_TYPE
	.addr $FFFF            ; AUX_TYPE
	.byte $FF              ; STORAGE_TYPE
	.addr $FFFF            ; CREATE_DATE
	.addr $FFFF            ; CREATE_TIME

;; DESTROY
MLIDestroyParam:
	.byte 1                ; PARAM_COUNT
	.addr $FFFF            ; PATHNAME

;; RENAME
MLIRenameParam:
	.byte 2                ; PARAM_COUNT
	.addr $FFFF            ; PATHNAME
	.addr $FFFF            ; NEW_PATHNAME

;; SET_FILE_INFO
MLISetFileInfoParam:
	.byte 7                ; PARAM_COUNT
	.addr $FFFF            ; PATHNAME
	.byte $FF              ; ACCESS
	.byte $FF              ; FILE_TYPE
	.addr $FFFF            ; AUX_TYPE
	.res 3                 ; NULL
	.addr $FFFF            ; MOD_DATE
	.addr $FFFF            ; MOD_TIME

;; GET_FILE_INFO
MLIGetFileInfoParam:
	.byte $A               ; PARAM_COUNT
	.addr $FFFF            ; PATHNAME
	.res 1                 ; ACCESS (RESULT)
	.res 1                 ; FILE_TYPE (RESULT)
	.res 2                 ; AUX_TYPE (RESULT)
	.res 1                 ; STORAGE_TYPE (RESULT)
	.res 2                 ; BLOCKS USED (RESULT)
	.res 2                 ; MOD_DATE (RESULT)
	.res 2                 ; MOD_TIME (RESULT)
	.res 2                 ; CREATE_DATE (RESULT)
	.res 2                 ; CREATE_TIME (RESULT)

;; ON_LINE
MLIOnlineParam:
	.byte 2                ; PARAM_COUINT
	.byte $FF              ; UNIT_NUM
	.res 256               ; DATA_BUFFER (RESULT)

;; SET_PREFIX
MLISetPrefixParam:
	.byte 1                ; PARAM_COUNT
	.addr $FFFF            ; PATHNAME

;; GET_PREFIX
MLIGetPrefixParam:
	.byte 1                ; PARAM_COUNT
	.res 64                ; DATA_BUFFER (RESULT)

; Filing Parameters

;; OPEN
MLIOpenParam:
	.byte 3                ; PARAM_COUNT
	.addr $FFFF            ; PATHNAME
	.addr $FFFF            ; IO_BUFFER
	.res 1                 ; REFNUM (Result)

;; NEWLINE
MLINewlineParam:
	.byte 3                ; PARAM_COUNT
	.byte $FF              ; REF_NUM
	.byte $FF              ; ENABLE_MASK
	.byte $FF              ; NEWLINE_CHAR

;; READ
;; WRITE
MLIReadWriteParam:
	.byte 4                ; PARAM_COUNT
	.byte $FF              ; REF_NUM
	.addr $FFFF            ; DATA_BUFFER
	.res 2                 ; REQUEST_COUNT
	.res 2                 ; TRANS_COUNT (RESULT)

;; CLOSE
;; FLUSH
MLICloseFlushParam:
	.byte 1                ; PARAM_COUNT
	.byte $FF              ; REF_NUM

;; SET_MARK
;; GET_MARK
;; SET_EOF
;; GET_EOF
MLIGetSetMarkEOFParam:
	.byte 2                ; PARAM_COUNT
	.byte $FF              ; REF_NUM
	.byte $FF,$FF,$FF      ; POSITION/EOF (RESULT)

;; SET_BUF
;; GET_BUF
MLIGetSetBufParam:
	.byte 2                ; PARAM_COUNT
	.byte $FF              ; REF_NUM
	.addr $FFFF            ; IO_BUFFER

; System Call Parameters

;; ALLOC_INTERRUPT
MLIAllocInterruptParam:
	.byte 2                ; PARAM_COUNT
	.res 1                 ; INT_NUM (RESULT)
	.addr $FFFF            ; INT_CODE

;; DEALLOC_INTERRUPT
MLIDeallocInterruptParam:
	.byte 1                ; PARAM_COUNT
	.byte $FF              ; INT_NUM

; Direct Disk Access Call Parameters

;; READ_BLOCK
;; WRITE_BLOCK
MLIReadWriteBlockParam:
	.byte 3                ; PARAM_COUNT
	.byte $FF              ; UNIT_NUM
	.addr $FFFF            ; DATA_BUFFER
	.addr $FFFF            ; BLOCK_NUM
