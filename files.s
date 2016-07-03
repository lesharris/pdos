;
;  files.s
;  PDos File Handling
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDOpenFile
PDOpenFile:
	SAVE_AXY

	lda	PDPARAM0
	sta PDFileStruct
	sta POINTER
	lda PDPARAM1
	sta PDFileStruct+1
	sta POINTER+1

	ldy #12
	ldx #0
PDOpenFile_CountChars:
	lda (POINTER),y
	cmp #0
	beq PDOpenFile_CountDone

	inx
	iny
	bra PDOpenFile_CountChars

PDOpenFile_CountDone:
	txa
	ldy #11
	sta (POINTER),y

	jsr PDFindBuffer
	bcc PDOpenFile_SetupFilePathAddr
	jmp PDOpenFile_Error

PDOpenFile_SetupFilePathAddr:
	sta PDFileBufferScratch+1
	stz PDFileBufferScratch

	lda #11
	sta PDFilePathAddr
	stz PDFilePathAddr+1

	clc
	lda	PDFileStruct
	adc PDFilePathAddr
	sta PDFilePathAddr
	lda PDFileStruct+1
	adc PDFilePathAddr+1
	sta PDFilePathAddr+1

; File Path Address
	lda PDFilePathAddr+1
	pha
	lda PDFilePathAddr
	pha

; Buffer address
	lda	PDFileBufferScratch+1
	pha
	lda	PDFileBufferScratch
	pha
	
	jsr PDSysOpen
	bcs PDOpenFile_Error

; Store Ref Num
	lda MLIOpenParam+5
	ldy #0
	sta (POINTER),y

; Check if destination address is entered. If so,
; skip loading aux type.
	ldy #10
	lda (POINTER),y
	cmp #0
	bne PDOpenFile_SkipAuxType

; Get Aux Type
	lda PDFileStruct
	sta PDPARAM0
	lda PDFileStruct+1
	sta PDPARAM1

	jsr PDGetInfo
	bcs PDOpenFile_Error

	lda PDFileInfo_AuxType
	ldy #9
	sta (POINTER),y
	iny
	lda PDFileInfo_AuxType+1
	sta (POINTER),y

PDOpenFile_SkipAuxType:
; Get EOF
	ldy #0
	lda (POINTER),y
	pha

	jsr PDSysGetEOF
	bcs PDOpenFile_Error

	ldy #1 
	lda MLIGetSetMarkEOFParam+2
	sta (POINTER),y
	iny
	lda MLIGetSetMarkEOFParam+3
	sta (POINTER),y
	iny
	lda MLIGetSetMarkEOFParam+4
	sta (POINTER),y

	clc
	bra PDOpenFile_Return

PDOpenFile_Error:
	sec

PDOpenFile_Return:
	RESTORE_AXY
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDCloseFile
PDCloseFile:
	SAVE_AXY

	lda PDPARAM0
	sta POINTER
	lda PDPARAM1
	sta POINTER+1

	ldy #0
	lda (POINTER),y
	pha

	jsr PDSysClose
	bcs PDCloseFile_Error

; Clear File Struct
	lda #0
	ldy #0
	sta (POINTER),y
	
	iny
	sta (POINTER),y
	iny
	sta (POINTER),y
	iny
	sta (POINTER),y
	
	iny
	sta (POINTER),y
	iny
	sta (POINTER),y
	iny
	sta (POINTER),y

	iny
	sta (POINTER),y
	iny
	sta (POINTER),y

	iny
	sta (POINTER),y
	iny
	sta (POINTER),y

	iny
	sta (POINTER),y

	clc
	bra PDCloseFile_Return

PDCloseFile_Error:
	sec

PDCloseFile_Return:
	RESTORE_AXY
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDReadFile
PDReadFile:
	SAVE_AXY

	lda	#1
	sta PDReadCount

	lda	PDPARAM0
	sta PDFileStruct
	sta POINTER
	lda PDPARAM1
	sta PDFileStruct+1
	sta POINTER+1

; If Byte Count is 0 then we will read in the entire file,
; otherwise we will respect the byte count.
	ldy #8
	lda (POINTER),y
	sta PDByteCount
	dey
	lda (POINTER),y
	sta PDByteCount+1

	lda PDByteCount
	bne PDReadFile_UserDefinedCount
	lda PDByteCount+1
	bne PDReadFile_UserDefinedCount

	bra PDReadFile_CountZero

PDReadFile_UserDefinedCount:
	jmp PDReadFile_ReadFile

PDReadFile_CountZero:
; If high byte of File length is zero we can read the 
; entire file with one read operation.
	ldy #3
	lda (POINTER),y
	cmp #0
	beq PDReadFile_ReadCountSet

; Otherwise, set byte count to maximum value $ffff
	lda #$ff
	ldy #7
	sta (POINTER),y
	sta PDReadSize
	iny
	sta (POINTER),y
	sta PDReadSize+1

	ldy #1
	lda (POINTER),y
	sta PDRemainingBytes
	iny
	lda (POINTER),y
	sta PDRemainingBytes+1
	iny
	lda (POINTER),y
	sta PDRemainingBytes+2

; Calculate number of reads necessary by subtracting Byte Count from Total bytes
; in the file until it goes negative.
PDReadFile_CalcReadCount:
	sec
	lda PDRemainingBytes
	sbc PDReadSize
	sta PDRemainingBytes
	lda PDRemainingBytes+1
	sbc PDReadSize+1
	sta PDRemainingBytes+1
	lda PDRemainingBytes+2
	sbc PDReadSize+2
	sta PDRemainingBytes+2
	bcc PDReadFile_ReadCountSet

	inc PDReadCount
	bra PDReadFile_CalcReadCount

PDReadFile_ReadCountSet:
; Reset Remaining Bytes
	ldy #1
	lda (POINTER),y
	sta PDRemainingBytes
	iny
	lda (POINTER),y
	sta PDRemainingBytes+1
	iny
	lda (POINTER),y
	sta PDRemainingBytes+2

; If we can read the whole file in at once, set the byte count to the size of the file.
	lda PDReadCount
	cmp #1
	beq PDReadFile_SetCountToEOF

; Otherwise set it to PDReadSize bytes
	ldy #7
	lda PDReadSize
	sta (POINTER),y
	iny
	lda PDReadSize+1
	sta (POINTER),y
	bra PDReadFile_ReadFile

PDReadFile_SetCountToEOF:
	ldy #1
	lda (POINTER),y
	ldy #7
	sta (POINTER),y

	ldy #2
	lda (POINTER),y
	ldy #8
	sta (POINTER),y

PDReadFile_ReadFile:
; Push Byte Count on Stack
	ldy #8
	lda (POINTER),y
	pha
	dey
	lda (POINTER),y
	pha

; Push Destination Address
	ldy #10
	lda (POINTER),y
	pha
	dey
	lda (POINTER),y
	pha

; Push Reference Number
	ldy #0
	lda (POINTER),y
	pha
	
	jsr PDSysRead
	bcs PDReadFile_Error

	dec PDReadCount
	cmp #0
	beq PDReadFile_Finished

; Subtract Read Size from Remaining Bytes
	sec
	lda PDRemainingBytes
	sbc PDReadSize
	sta PDRemainingBytes
	lda PDRemainingBytes+1
	sbc PDReadSize+1
	sta PDRemainingBytes+1
	lda PDRemainingBytes+2
	sbc PDReadSize+2
	sta PDRemainingBytes+2

; Are the remaining bytes less or equal to $FFFF?
	lda PDRemainingBytes+2
	cmp #0
	beq PDReadFile_SetFinalReadSize
	bra PDReadFile_ReadAgain

PDReadFile_SetFinalReadSize:
; Yes, set byte count to final number of bytes
	lda PDRemainingBytes
	ldy #7
	sta (POINTER),y
	iny
	lda PDRemainingBytes+1
	sta (POINTER),y

PDReadFile_ReadAgain:
	bra PDReadFile_ReadFile

PDReadFile_Finished:
	clc
	bra PDReadFile_Return

PDReadFile_Error:
	sec

PDReadFile_Return:
	RESTORE_AXY
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDGetInfo
PDGetInfo:
	SAVE_AXY

	lda	PDPARAM0
	sta PDFileStruct
	lda PDPARAM1
	sta PDFileStruct+1

; Calculate address of file path 11 bytes into PDFileStruct
	lda #11
	sta PDFilePathAddr
	stz PDFilePathAddr+1

	clc
	lda	PDFileStruct
	adc PDFilePathAddr
	sta PDFilePathAddr
	lda PDFileStruct+1
	adc PDFilePathAddr+1
	sta PDFilePathAddr+1

	lda PDFilePathAddr+1
	pha
	lda PDFilePathAddr
	pha 

	jsr PDSysGetFileInfo
	bcs PDGetInfo_Error

; Copy result into PDFileInfo struct
	ldx #1
	ldy #0
PDGetInfo_CopyInfo:
	lda MLIGetFileInfoParam,x
	sta PDFileInfo,y

	inx
	iny
	cpx #18
	beq PDGetInfo_CopyDone
	bra PDGetInfo_CopyInfo

PDGetInfo_CopyDone:
	clc
	bra PDGetInfo_Return
PDGetInfo_Error:
	sec
PDGetInfo_Return:
	RESTORE_AXY
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDSetEOF
PDSetEOF:
	SAVE_AXY

	lda	PDPARAM0
	sta PDFileStruct
	lda PDPARAM1
	sta PDFileStruct+1

; Push new EOF Marker
	ldy #3
	lda (POINTER),y
	pha
	dey
	lda (POINTER),y
	pha
	dey
	lda (POINTER),y
	pha
	
; Push Reference Number
	ldy #0
	lda (POINTER),y
	pha

	jsr PDSysSetEOF
	bcs PDSetEOF_Error

	clc
	bra PDSetEOF_Return

PDSetEOF_Error:
	sec
PDSetEOF_Return:
	RESTORE_AXY
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Directory Routines

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDReadDirectory
PDReadDirectory:
	SAVE_AXY

	stz PDActiveEntries

	lda #2
	sta PDBlockEntries

	ldy #10
	lda (PDPARAM0),y
	sta POINTER+1
	dey
	lda (PDPARAM0),y
	sta POINTER

	ldy #$23
	lda (POINTER),y
	sta PDEntryLength

	iny
	lda (POINTER),y
	sta PDEntriesPerBlock

	iny
	lda (POINTER),y
	sta PDFileCount

	iny
	lda (POINTER),y
	sta PDFileCount+1

	lda #4
	clc
	adc PDEntryLength
	sta PDEntryPointer

PDReadDirectory_EntryLoop:
; Check if we're done with the entries.
	lda PDActiveEntries
	cmp PDFileCount
	bcc PDReadDirectory_ProcessEntry

	jmp PDReadDirectory_EntryDone

PDReadDirectory_ProcessEntry:
; Skip if first byte is 0
	ldy PDEntryPointer
	lda (POINTER),y
	cmp #0
	bne PDReadDirectory_GetStorageAndName
	jmp PDReadDirectory_NextEntry

PDReadDirectory_GetStorageAndName:
	ldy PDEntryPointer

	lda (POINTER),y
	and #$f0
	lsr
	lsr
	lsr
	lsr
	sta PDDirEntry_StorageType
	lda (POINTER),y
	and #$0f
	sta PDDirEntry_NameLength

; Skip if StorageType or NameLength are 0
	lda PDDirEntry_StorageType
	cmp #0
	bne PDReadDirectory_CheckNameLength
	jmp PDReadDirectory_NextEntry

PDReadDirectory_CheckNameLength:
	lda PDDirEntry_NameLength
	cmp #0
	bne PDReadDirectory_InitBlockPopulate
	jmp PDReadDirectory_NextEntry

; Populate DirEntry block
PDReadDirectory_InitBlockPopulate:
	iny
	ldx #0

; File Name
PDReadDirectory_PopulateNameField:
	cpx PDDirEntry_NameLength
	beq PDReadDirectory_LoadFields
 
PDReadDirectory_LoadChar:
	lda (POINTER),y
	ora #$80
	sta PDDirEntry_FileName,x 

	iny
	inx
	bra PDReadDirectory_PopulateNameField

PDReadDirectory_LoadFields:
	lda #$10
	clc
	adc PDEntryPointer
	tay

; File Type
	lda (POINTER),y
	sta PDDirEntry_FileType

; Key Pointer
	iny
	lda (POINTER),y
	sta PDDirEntry_KeyPointer
	iny
	lda (POINTER),y
	sta PDDirEntry_KeyPointer+1

; Blocks Used
	iny
	lda (POINTER),y
	sta PDDirEntry_BlocksUsed
	iny
	lda (POINTER),y
	sta PDDirEntry_BlocksUsed+1

; EOF
	iny
	lda (POINTER),y
	sta PDDirEntry_EOF
	iny
	lda (POINTER),y
	sta PDDirEntry_EOF+1
	iny
	lda (POINTER),y
	sta PDDirEntry_EOF+2

; Creation Date
	iny
	lda (POINTER),y
	sta PDDirEntry_CreationDate
	iny
	lda (POINTER),y
	sta PDDirEntry_CreationDate+1

; Creation Time
	iny
	lda (POINTER),y
	sta PDDirEntry_CreationTime
	iny
	lda (POINTER),y
	sta PDDirEntry_CreationTime+1

; Version
	iny
	lda (POINTER),y
	sta PDDirEntry_Version

; Minimum Version
	iny
	lda (POINTER),y
	sta PDDirEntry_MinVersion

; Access
	iny
	lda (POINTER),y
	sta PDDirEntry_Access

; Aux Type
	iny
	lda (POINTER),y
	sta PDDirEntry_AuxType
	iny
	lda (POINTER),y
	sta PDDirEntry_AuxType+1

; Modification Date
	iny
	lda (POINTER),y
	sta PDDirEntry_ModificationDate
	iny
	lda (POINTER),y
	sta PDDirEntry_ModificationDate+1

; Modification Time
	iny
	lda (POINTER),y
	sta PDDirEntry_ModificationTime
	iny
	lda (POINTER),y
	sta PDDirEntry_ModificationTime+1

; Header Pointer
	iny
	lda (POINTER),y
	sta PDDirEntry_HeaderPointer
	iny
	lda (POINTER),y
	sta PDDirEntry_HeaderPointer+1

; Render File Type String
	ldx PDDirEntry_FileTypeStr

	ldy #1
	ldx #0
PDReadDirectory_FindFileTypeInTable:
	cpx PDFileTypes
	beq PDReadDirectory_TypeNotFound

	lda PDFileTypes,y
	cmp PDDirEntry_FileType
	beq PDReadDirectory_FoundType

	iny
	iny
	iny
	inx
	bra PDReadDirectory_FindFileTypeInTable

PDReadDirectory_FoundType:
	iny
	lda PDFileTypes,y
	sta POINTER2
	iny
	lda PDFileTypes,y
	sta POINTER2+1

	ldy #0
	ldx #0
PDReadDirectory_RenderFileTypeStr:
	lda (POINTER2),y
	cmp #0
	beq PDReadDirectory_SetupCallback

	ora #$80
	sta PDDirEntry_FileTypeStr,x
	inx
	iny
	bra PDReadDirectory_RenderFileTypeStr

PDReadDirectory_TypeNotFound:
	lda #$a4
	sta PDDirEntry_FileTypeStr
	ldx #1
	lda PDFileInfo_FileType
	pha
	lsr
	lsr
	lsr
	lsr
	jsr PDReadDirectory_ConvByte
	pla
PDReadDirectory_ConvByte:
	and #$0f
	ora #$b0
	cmp #$ba
	bcc PDReadDirectory_RenderByte
    adc #$06
    bra PDReadDirectory_SetupCallback

PDReadDirectory_RenderByte:
	sta PDDirEntry_FileTypeStr,x
	inx
	rts

PDReadDirectory_SetupCallback:
	lda #0
	sta PDDirEntry_FileTypeStr,x

; Call User Callback

	lda PDPARAM2
	sta PDReadDirectory_UserCallback+1
	lda PDPARAM3
	sta PDReadDirectory_UserCallback+2

	lda POINTER+1
	pha
	lda POINTER
	pha

PDReadDirectory_UserCallback:
	jsr $FFFF		; Modified to address passed in PDPARAM2

	pla
	sta POINTER
	pla
	sta POINTER+1

PDReadDirectory_NextEntry:
	inc PDActiveEntries

	lda PDEntriesPerBlock
	cmp PDBlockEntries
	beq PDReadDirectory_NextBlock

	lda PDEntryPointer
	clc
	adc PDEntryLength
	sta PDEntryPointer
	inc PDBlockEntries
	jmp PDReadDirectory_EntryLoop

PDReadDirectory_NextBlock:
	jsr PDReadFile
	bcs PDReadDirectory_Error

	lda #$01
	sta PDBlockEntries
	lda #$04
	sta PDEntryPointer

	jmp PDReadDirectory_EntryLoop

PDReadDirectory_EntryDone:
	RESTORE_AXY
	clc
	bra PDReadDirectory_Return

PDReadDirectory_Error:
	sec
PDReadDirectory_Return:
	rts
