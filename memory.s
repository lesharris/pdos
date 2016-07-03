;
;  memory.s
;  Routines to reserve, release, and otherwise manage the prodos
;  bitmap.
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Memory Page Routines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDReservePage
; Params: A - High byte of page address
; Reserves page in A in the Prodos bitmap
; Checks if page is already reserved
; Set Carry signals error
PDReservePage:
  SAVE_AXY

  sta MLICurrPage
  jsr PDCheckPageFree
  bcs PDReservePage_PageInUse

; Get bitmap byte for page
  lda MLICurrPage
  and #$F8
  lsr
  lsr
  lsr
  tax

; Get page bit position in bitmap byte
  lda MLICurrPage
  and #$07
; 3-bit complement
  eor #$07
  tay

; Set the page bit.
  lda MLIBitmap,X
  sta MLICurrByte

  lda MLIPositionTable,Y
  ora MLICurrByte
  sta MLIBitmap,X

; Success
  clc
  bra PDReservePage_Return

PDReservePage_PageInUse:
; Failure
  sec
PDReservePage_Return:
  RESTORE_AXY
  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDReleasePage
; Params: A - high byte of page address
; Releases page passed in A from prodos bitmap.
; Checks if page is already free.
; Set Carry signals error
PDReleasePage:
  SAVE_AXY

  sta MLICurrPage
  jsr PDCheckPageFree
  bcc PDReleasePage_PageNotFree

; Get bitmap byte for page
  lda MLICurrPage
  and #$F8
  lsr
  lsr
  lsr
  tax

; Get bit position in bitmap byte
  lda MLICurrPage
  and #$07
  eor #$07
  tay

  lda MLIBitmap,X
  sta MLICurrByte

  lda MLIPositionTable,Y
; Get complement
  eor #$FF
; Clear bit
  and MLICurrByte
; Save it
  sta MLIBitmap,X
  
; Success
  clc
  bra PDReleasePage_Return

PDReleasePage_PageNotFree:
  sec

PDReleasePage_Return:
  RESTORE_AXY
  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDFindHighestFreePage
; Params: A - High byte of start page address.
; Returns highest free page in prodos bitmap starting from the
; page passed in A
; Set carry signals no free pages found.
PDFindHighestFreePage:
  SAVE_AXY

  sta MLICurrPage

PDFindHighestFreePage_CheckCurrentPage:
  lda MLICurrPage
  jsr PDCheckPageFree
  bcc PDFindHighestFreePage_FoundFreePage

  dec MLICurrPage
  lda MLICurrPage
  cmp #1
  beq PDFindHighestFreePage_FreePageNotFound
  bra PDFindHighestFreePage_CheckCurrentPage

PDFindHighestFreePage_FoundFreePage:
; Success
  lda MLICurrPage
  clc
  bra PDFindHighestFreePage_Return

PDFindHighestFreePage_FreePageNotFound:
; Failure
  sec

PDFindHighestFreePage_Return:
  RESTORE_AXY
  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDReserveRange
; Params: A - First Page, Y - Last Page
; Checks if all pages in range are free and reserves
; the inclusive range if so.
PDReserveRange:
  SAVE_AXY

	sta MLIPageStart
	sta MLICurrPage
	sty MLIPageEnd

; Check that MLIPageStart <= MLIPageEnd
	lda MLIPageEnd
	cmp MLIPageStart
	bcc PDReserveRange_Failed

	inc MLIPageEnd

; Loop through the range and make sure pages are free.
PDReserveRange_CheckForFreePages:
  lda MLICurrPage
	cmp MLIPageEnd
	beq PDReserveRange_ReservePages

	jsr PDCheckPageFree
	bcs PDReserveRange_Failed
	inc MLICurrPage
	bra PDReserveRange_CheckForFreePages

PDReserveRange_ReservePages:    
  lda MLIPageStart
	sta MLICurrPage

PDReserveRange_ReservePage:    
  lda MLICurrPage
	cmp MLIPageEnd
	beq PDReserveRange_Success

	jsr PDReservePage
	bcs PDReserveRange_Failed

	inc MLICurrPage
	bra PDReserveRange_ReservePage

PDReserveRange_Success:
; Success   
  clc
	bra PDReserveRange_Return

PDReserveRange_Failed:
; Failure   
  sec

PDReserveRange_Return:
  RESTORE_AXY
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDReleaseRange
; Params: A - First Page, Y - Last Page
; Releases all page in inclusive range
PDReleaseRange:
  SAVE_AXY

  sta MLIPageStart
  sta MLICurrPage
  sty MLIPageEnd

; Check that MLIPageStart <= MLIPageEnd
  lda MLIPageEnd
  cmp MLIPageStart
  bcc PDReleaseRange_Failed

  inc MLIPageEnd

PDReleaseRange_ReleasePages:    
  lda MLIPageStart
  sta MLICurrPage

PDReleaseRange_ReleasePage:    
  lda MLICurrPage
  cmp MLIPageEnd
  beq PDReleaseRange_Success

  jsr PDReleasePage
  bcs PDReleaseRange_Failed

  inc MLICurrPage
  bra PDReleaseRange_ReleasePage

PDReleaseRange_Success:
; Success   
  clc
  bra PDReleaseRange_Return

PDReleaseRange_Failed:
; Failure   
  sec

PDReleaseRange_Return:
  RESTORE_AXY
  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDCheckPageFree
; Params: A - High byte of page address
; Checks if Page A is free in the prodos bitmap
; Set carry: Page in use, Clear Carry: Page free
; Routine from Prodos 8 Tech Manual
PDCheckPageFree:
  SAVE_AXY

  cmp #$C0
  bcs PDCheckPageFree_PageNotFree

  tax
  lsr
  lsr
  lsr
  tay
  txa
  and #$7
  tax
  lda #$80

PDCheckPageFree_NextBit:
  dex
  bmi PDCheckPageFree_CheckBit
  lsr
  bra PDCheckPageFree_NextBit

PDCheckPageFree_CheckBit:
  and MLIBitmap,y
  bne PDCheckPageFree_PageNotFree

; Page Free
  clc
  bra PDCheckPageFree_Return

PDCheckPageFree_PageNotFree:
  sec

PDCheckPageFree_Return:
  RESTORE_AXY
  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Prodos 1024-byte Buffer Routines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDFindBuffer
; Attempts to find a 1024-byte buffer in memory.
; Returns high byte of buffer address in A
; Set carry signals no buffer found.
PDFindBuffer:
  SAVE_AXY

; Start at highest valid page
	lda #$BF
	jsr PDFindHighestFreePage
	bcs PDFindBuffer_Failure

	sta MLICurrPage
	sta MLIPageStart

PDFindBuffer_CheckWindow:
  lda MLICurrPage
	jsr PDCheckPageFree
	bcs PDFindBuffer_NextWindow

	dec MLICurrPage
	lda MLICurrPage
	jsr PDCheckPageFree
	bcs PDFindBuffer_NextWindow

	dec MLICurrPage
	lda MLICurrPage
	jsr PDCheckPageFree
	bcs PDFindBuffer_NextWindow

	dec MLICurrPage
	lda MLICurrPage
	jsr PDCheckPageFree
	bcs PDFindBuffer_NextWindow

; Success, found a 4 page window
	lda MLICurrPage
	clc
  RESTORE_AXY
	rts

PDFindBuffer_NextWindow:
  dec MLIPageStart
	lda MLIPageStart
	sta MLICurrPage

; Don't search below text page 2
	cmp #7
	beq PDFindBuffer_Failure
	bra PDFindBuffer_CheckWindow

PDFindBuffer_Failure:
  sec
  RESTORE_AXY
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDReserveBuffer
; Params: A - High byte of buffer start page.
; Allocates a 1024 byte buffer in the prodos memory map.
; Set carry signals error
PDReserveBuffer:
  SAVE_AXY

	sta MLICurrPage

	jsr PDReservePage
	bcs PDReserveBuffer_Failure
	inc MLICurrPage

	lda MLICurrPage
	jsr PDReservePage
	bcs PDReserveBuffer_Failure
	inc MLICurrPage

	lda MLICurrPage
	jsr PDReservePage
	bcs PDReserveBuffer_Failure
	inc MLICurrPage

	lda MLICurrPage
	jsr PDReservePage
	bcs PDReserveBuffer_Failure

; Success
	clc
	bra PDReserveBuffer_Return

PDReserveBuffer_Failure:
  sec

PDReserveBuffer_Return:
  RESTORE_AXY
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDReleaseBuffer
; Params: A - High byte of buffer start page.
; Releases a 1024 byte buffer in the prodos memory map.
; Set carry signals error
PDReleaseBuffer:
  SAVE_AXY

	sta MLICurrPage

	jsr PDReleasePage
	bcs PDReleaseBuffer_Failure
	inc MLICurrPage

	lda MLICurrPage
	jsr PDReleasePage
	bcs PDReleaseBuffer_Failure
	inc MLICurrPage

	lda MLICurrPage
	jsr PDReleasePage
	bcs PDReleaseBuffer_Failure
	inc MLICurrPage

	lda MLICurrPage
	jsr PDReleasePage
	bcs PDReleaseBuffer_Failure

; Success
	clc
	bra PDReleaseBuffer_Return

PDReleaseBuffer_Failure:
  sec

PDReleaseBuffer_Return:
  RESTORE_AXY
	rts
