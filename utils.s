;
;  utils.s
;  General Utilities
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDStoreDateTime
; Get Current System Datetime and render it into MLIDateString
; and MLITimeString
PDStoreDateTime:
	SAVE_AXY
	jsr PDSysGetTime
	jsr PDRenderDateTime
	RESTORE_AXY
	rts

; Renders the date in MLIDate and MLITime into MLIDateString
; and MLITimeString
PDRenderDateTime:
	SAVE_AXY

	; Get the day
	lda MLIDate
	cmp #0
	bne PDRenderDateTime_ValidDate
	jmp PDRenderDateTime_NoDate

PDRenderDateTime_ValidDate:
	and #$1F

	jsr PDByteToDecimalString

	lda #<MLIConvStr
	sta POINTER 
	lda #>MLIConvStr
	sta POINTER+1
	ldy #0
	ldx #0

PDRenderDateTime_RenderDay:   
	lda (POINTER),y
	cmp #0
	beq PDRenderDateTime_RenderSep1

	sta MLIDateString,x
	inx
	iny
	bra PDRenderDateTime_RenderDay

PDRenderDateTime_RenderSep1:   
	lda #$AD                      ; -
	sta MLIDateString,x
	inx

	; Get the month
	; The month is 4 bits spread over 2 bytes.
	; These shifts and add move it to a single byte.
	lda MLIDate
	and #$E0 
	lsr
	lsr
	lsr
	lsr
	lsr
	sta SCRATCH1

	lda MLIDate+1
	and #$01
	asl
	asl
	asl
	clc
	adc SCRATCH1

	; Multiply by 4 to turn into an index for MLIMonthStrings
	asl
	asl
	tay

	lda #<MLIMonthStrings
	sta POINTER 
	lda #>MLIMonthStrings
	sta POINTER+1

PDRenderDateTime_RenderMonth:
	lda (POINTER),y
	cmp #0
	beq PDRenderDateTime_RenderSep2

	ora #$80
	sta MLIDateString,x
	iny
	inx
	bra PDRenderDateTime_RenderMonth

PDRenderDateTime_RenderSep2:
	lda #$AD                      ; -
	sta MLIDateString,x
	inx

	; Get the year
	lda MLIDate+1
	and #$FE
	lsr

	phx
	jsr PDByteToDecimalString
	plx

	lda #<MLIConvStr
	sta POINTER 
	lda #>MLIConvStr
	sta POINTER+1
	ldy #0

PDRenderDateTime_RenderYear:
	lda (POINTER),y
	cmp #0
	beq PDRenderDateTime_EndDate

	sta MLIDateString,x
	iny
	inx
	bra PDRenderDateTime_RenderYear

PDRenderDateTime_EndDate:
	lda #0
	sta MLIDateString,x

	; Get the time
	lda MLITime+1                      ; Hours

	jsr PDByteToDecimalString

	ldx #0
	ldy #0

PDRenderDateTime_RenderHours:
	lda (POINTER),y
	cmp #0
	beq PDRenderDateTime_RenderTimeSep

	sta MLITimeString,x
	inx
	iny
	bra PDRenderDateTime_RenderHours

PDRenderDateTime_RenderTimeSep:
	lda #$BA                          ; :
	sta MLITimeString,x
	inx

	lda MLITime                       ; Minutes

	phx
	jsr PDByteToDecimalString
	plx

	jsr PDStringZLength
	
	cmp #1
	beq PDRenderDateTime_LeadZero
	ldy #0
	bra PDRenderDateTime_RenderMinutes

PDRenderDateTime_LeadZero:
	ldy #0
	lda #$b0
	sta MLITimeString,x
	inx
PDRenderDateTime_RenderMinutes:
	lda (POINTER),y
	cmp #0
	beq PDRenderDateTime_EndTime

	sta MLITimeString,x
	inx
	iny
	bra PDRenderDateTime_RenderMinutes

PDRenderDateTime_EndTime:
	lda #0
	sta MLITimeString,x
	bra PDRenderDateTime_Return

PDRenderDateTime_NoDate:
	lda #>NODATE
	sta POINTER+1
	lda #<NODATE
	sta POINTER

	lda #0
	sta MLITimeString

	ldy #0
	ldx #0
PDRenderDateTime_RenderNoDate:
	lda (POINTER),y
	cmp #0
	beq PDRenderDateTime_Return

	ora #$80
	sta MLIDateString,x
	iny
	inx
	bra PDRenderDateTime_RenderNoDate

PDRenderDateTime_Return:
	RESTORE_AXY

	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDErrorFromCode
; Params: A - Prodos Error Code
; Renders a null terminated string with the error message into
; MLIErrorString
PDErrorFromCode:
	SAVE_AXY

	sta SCRATCH1
	ldx #0

PDErrorFromCode_FindErrorInTable:
	lda MLIErrorMessages,x
	cmp SCRATCH1
	beq PDErrorFromCode_FoundError

	lda MLIErrorMessages,x
	cmp #$FF
	beq PDErrorFromCode_ErrorNotFound

	inx
	inx
	inx
	bra PDErrorFromCode_FindErrorInTable

PDErrorFromCode_FoundError:
	inx
	lda MLIErrorMessages,x
	sta POINTER 
	inx
	lda MLIErrorMessages,x
	sta POINTER+1
	bra PDErrorFromCode_InitRender

PDErrorFromCode_ErrorNotFound:
	lda #<ERRNOTFND
	sta POINTER 
	lda #>ERRNOTFND
	sta POINTER+1

PDErrorFromCode_InitRender:
	ldy #0
	ldx #0
PDErrorFromCode_RenderError:
	lda (POINTER),y
	cmp #0
	beq PDErrorFromCode_EndRender

	ora #$80
	sta MLIErrorString,x
	inx
	iny
	bra PDErrorFromCode_RenderError

PDErrorFromCode_EndRender:
	lda #0
	sta MLIErrorString,x

	RESTORE_AXY
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDByteToDecimalString
; Params: A - Byte Value
; Converts byte into a string representation of the decimal value.
PDByteToDecimalString:
	SAVE_AXY

	sta MLIValue
	stz MLIIndex

	lda #$0
	sta MLIConvStr
	sta MLIConvStr+1
	sta MLIConvStr+2
	sta MLIConvStr+3

	ldx #2
	stx MLILead0
@P1:
	lda #$B0
	sta MLIDigit

@P2:
	sec
	lda MLIValue
	sbc MLITable10,x
	bcc @P3

	sta MLIValue
	inc MLIDigit
	bra @P2

@P3:     
	lda MLIDigit
	cpx #0
	beq @P5
	cmp #$B0
	beq @P4
	sta MLILead0

@P4:
	bit MLILead0
	bpl @P6

@P5:
	phx
	ldx MLIIndex
	inc MLIIndex
	sta MLIConvStr,x
	plx

@P6:
	dex
	bpl @P1

	RESTORE_AXY
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDPrintBitmap
; Prints the Prodos bitmap.  Displays 1 for a reserved page and
; 0 for a free page.
PDPrintBitmap:
	SAVE_AXY

	ldy #0
@NextByte:
	ldx #0
@PrintBits:
	lda MLIBitmap,y
	bit MLIReversePositionTable,x
	bne @One
	
	lda #$b0			; 0
	bra @Print

@One:
	lda #$b1			; 1

@Print:
	jsr COUT
	
	inx
	cpx #8
	bne @PrintBits

	iny
	tya

;  if y % 6 == 0 print \n
	sec
@NextSub6:
	sbc #6
	bcs @NextSub6
	adc #6

	cmp #0
	bne @CheckDone

	lda #$8d			; Return
	jsr COUT

@CheckDone:
	cpy #$18
	bcc @NextByte

	RESTORE_AXY
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDPrintCurrentError
; Updates current error message and prints it.
PDPrintCurrentError:
	lda MLIError
	jsr PDErrorFromCode

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDPrintErrorString
; Prints the current rendered error message.
PDPrintErrorString:
	lda #>MLIErrorString
	sta POINTER+1
	lda #<MLIErrorString
	sta POINTER

	jsr PDPrintStringZ
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDPrintConvString
; Prints the decimal string stored in MLIConvStr
PDPrintConvString:
	jsr PDByteToDecimalString

	lda #>MLIConvStr
	sta POINTER+1
	lda #<MLIConvStr
	sta POINTER

	jsr PDPrintStringZ
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDPrintStringZ
; Prints null-terminated string whose address is stored in POINTER
PDPrintStringZ:
	ldy #0
@Loop:
	lda (POINTER),y
	cmp	#0
	beq @Done

	ora #$80
	jsr COUT
	iny
	bra @Loop

@Done:
	lda	#$8d
	jsr COUT
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDStringZLength
; Calculates the length of the null terminated string pointed to
; by POINTER
; Returns value in A
PDStringZLength:
	phy
	ldy #0

@Loop:
	lda (POINTER),y
	beq @Done
	iny
	bra @Loop

@Done:
	tya
	ply
	rts
