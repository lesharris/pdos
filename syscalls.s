;
;  syscalls.s
;  Prodos MLI Syscalls
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDSysOpen
; Params:
;    Stack: Address of file path string, Address of free buffer
; Opens file, returns refnum in A
; Set carry signals error
PDSysOpen:
	SAVE_RETURN

; Store buffer address
	pla
	sta MLIOpenParam+3
	pla
	sta MLIOpenParam+4

; Store path Address
	pla
	sta MLIOpenParam+1
	pla
	sta MLIOpenParam+2

	RESTORE_RETURN

; Configure Syscall
	lda #MLIOpen
	sta MLICall

	lda #<MLIOpenParam
	sta MLIParam

	lda #>MLIOpenParam
	sta MLIParam+1

; Let 'er rip
	jsr MLISyscall
  	bcs PDSysOpen_Error

  	clc
	bra PDSysOpen_Return

PDSysOpen_Error:
  	sec

PDSysOpen_Return:
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDSysClose
; Params:
;    Stack: Refnum of Open File
; Closes file
; Set carry signals error
PDSysClose:
	lda #MLIClose
	sta SCRATCH1
	bra PDProcessCloseFlush

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDSysFlush
; Params:
;    Stack: Refnum of Open File
; Flushes file
; Set carry signals error
PDSysFlush:
	lda #MLIFlush
	sta SCRATCH1

PDProcessCloseFlush:
	SAVE_RETURN

	pla
	sta MLICloseFlushParam+1

	RESTORE_RETURN

	lda SCRATCH1
	sta MLICall

	lda #<MLICloseFlushParam
	sta MLIParam
	lda #>MLICloseFlushParam
	sta MLIParam+1

  	jsr MLISyscall
  	bcs PDProcessCloseFlush_Error

  	clc
  	bra PDProcessCloseFlush_Return

PDProcessCloseFlush_Error:
  	sec

PDProcessCloseFlush_Return:
  	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDSysRead
; Params:
;    Stack: Refnum from Open File
;           Destination Address
;           Number of bytes to read
; Reads Number of Bytes from open file into Destination Address
; Set carry signals error
PDSysRead:
	lda #MLIRead
	sta SCRATCH1
	bra PDSysReadWrite

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDSysWrite
; Params:
;    Stack: Refnum from Open File
;           Source Address
;           Number of bytes to write
; Writes Number of Bytes destination address into open file
; Set carry signals error
PDSysWrite:
	lda #MLIWrite
	sta SCRATCH1

PDSysReadWrite:
; Save return address
	SAVE_RETURN

; Get Refnum
	pla
	sta MLIReadWriteParam+1

; Get Destination Address
	pla
	sta MLIReadWriteParam+2
	pla
	sta MLIReadWriteParam+3

; Get number of bytes to Read or Write
	pla
	sta MLIReadWriteParam+4
	pla
	sta MLIReadWriteParam+5

	RESTORE_RETURN

; Setup MLISyscall
	lda SCRATCH1
  	sta MLICall

	lda #<MLIReadWriteParam
	sta MLIParam
	lda #>MLIReadWriteParam
	sta MLIParam+1
  
  	jsr MLISyscall
  	bcs PDSysReadWrite_Error
  	
  	clc
  	bra PDSysReadWrite_Return

PDSysReadWrite_Error:
  	sec

PDSysReadWrite_Return:
  	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDSysGetTime
; Params: None
; Stores in the current date and time in MLIDate and MLITime
PDSysGetTime:
	lda #MLIGetTime
	sta MLICall

  	jsr MLISyscall
  	bcs PDSysGetTime_Error

  	clc
  	bra PDSysGetTime_Return

PDSysGetTime_Error:
  	sec

PDSysGetTime_Return:
  	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDSysGetFileInfo
; Params:
;    Stack: Address to Prodos spec path
; Set carry signals error
PDSysGetFileInfo:
	SAVE_RETURN

; Store filepath address
	pla
	sta MLIGetFileInfoParam+1
	pla
	sta MLIGetFileInfoParam+2

	RESTORE_RETURN

	lda #MLIGetFileInfo
	sta MLICall

	lda #<MLIGetFileInfoParam
	sta MLIParam
	lda #>MLIGetFileInfoParam
	sta MLIParam+1

  	jsr MLISyscall
  	bcs PDSysGetFileInfo_Error

  	clc
  	bra PDSysGetFileInfo_Return

PDSysGetFileInfo_Error:
  	sec

PDSysGetFileInfo_Return:
  	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDSysGetMark
; Params:
;    Stack: File Reference Number
; Set carry signals error
PDSysGetMark:
	lda #MLIGetMark
	sta SCRATCH1
	bra PDProcessGetSetMarkEOF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDSysSetMark
; Params:
;    Stack: File Reference Number
; Set carry signals error
PDSysSetMark:
	lda #MLISetMark
	sta SCRATCH1
	bra PDProcessGetSetMarkEOF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDSysSetEOF
; Params:
;    Stack: File Reference Number
; Set carry signals error
PDSysSetEOF:
	lda #MLISetEOF
	sta SCRATCH1
	bra PDProcessGetSetMarkEOF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDSysGetEOF
; Params:
;    Stack: File Reference Number
; Set carry signals error
PDSysGetEOF:
	lda #MLIGetEOF
	sta SCRATCH1

PDProcessGetSetMarkEOF:
	SAVE_RETURN

; Store Reference Number
	pla
	sta MLIGetSetMarkEOFParam+1

; Getting doesn't need to put marker/eof on stack, skip it.
	lda SCRATCH1
	cmp #MLIGetEOF
	beq PDProcessGetSetMarkEOF_Execute
	cmp #MLIGetMark
	beq PDProcessGetSetMarkEOF_Execute

; Store EOF/Mark
	pla
	sta MLIGetSetMarkEOFParam+2
	pla
	sta MLIGetSetMarkEOFParam+3
	pla
	sta MLIGetSetMarkEOFParam+4
	
PDProcessGetSetMarkEOF_Execute:
	RESTORE_RETURN

	lda SCRATCH1
	sta MLICall

	lda #<MLIGetSetMarkEOFParam
	sta MLIParam
	lda #>MLIGetSetMarkEOFParam
	sta MLIParam+1

  	jsr MLISyscall
  	bcs PDProcessGetSetMarkEOF_Error

  	clc
  	bra PDProcessGetSetMarkEOF_Return

PDProcessGetSetMarkEOF_Error:
  	sec

PDProcessGetSetMarkEOF_Return:
  	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MLISyscall
; Params: None
; Executes the MLI command stored in MLICall using
; the parameter block stored in MLIParam
; Set carry signals error.
; Error code stored in MLIError
; Error code message stored in MLIErrorString
MLISyscall:
; Clear error code
  	lda #$0
	sta MLIError

; Execute call
	jsr MLI

; These are modified by calling wrapper
MLICall:
  	.byte $ff
MLIParam:
	.addr $ffff

	sta MLIError

; Error in call?
	bne MLISyscall_Error

  	clc
	bra MLISyscall_Return

MLISyscall_Error:
; Write error message to MLIErrorString
  	jsr PDErrorFromCode
  	sec

MLISyscall_Return:
  	rts 
