;
;  macros.s
;  Generally useful macros for 6502 code
;

; Macros

.macro SAVE_RETURN			; Saves return address
	pla
	sta MLILo
	pla
	sta MLIHi
.endmacro

.macro RESTORE_RETURN		; Restores Return address
	lda MLIHi
	pha
	lda MLILo
	pha
.endmacro

.macro SAVE_AXY				; Saves all registers
	pha
	phx
	phy
.endmacro

.macro RESTORE_AXY			; Restores all registers
	ply
	plx
	pla
.endmacro


.macro SAVE_AY				; Saves accumulator and Y index
	pha
	phy
.endmacro


.macro RESTORE_AY			; Restores accumulator and Y index
	ply
	pla
.endmacro


.macro SAVE_AX				; Saves accumulator and X index
	pha
	phx
.endmacro


.macro RESTORE_AX			; Restores accumulator and X index
	plx
	pla
.endmacro


.macro SAVE_XY				; Saves X and Y index
	phx
	phy
.endmacro


.macro RESTORE_XY			; Restores X and Y index
	ply
	plx
.endmacro

.macro WEEGUIPARAM addr
	lda #<addr
	sta PARAM0
	lda #>addr
	sta PARAM1
.endmacro

.macro CallWeegui func,param
.ifnblank param
	WEEGUIPARAM param
.endif
	ldx #func
	jsr WeeGUI
.endmacro

.macro PDPARAM addr
	lda #<addr
	sta PDPARAM0
	lda #>addr
	sta PDPARAM1
.endmacro


.macro CallPDos func,addr
	PDPARAM addr
	jsr func
.endmacro
