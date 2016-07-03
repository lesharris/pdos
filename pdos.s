;
;  pdos.s
;  Easily work with Prodos
;

.org $2000

; Common definitions

.include "zeropage.s"
.include "prodosmli.s"
.include "monitor.s"

; Macros

.include "macros.s"

; WEEGUI

.include "WeeGUI_MLI.s"
WGInit = $7b00

PDMain:
  CallPDos PDOpenFile,WEEGUI_File
  bcc @Opened
  jmp @ExitPdos

@Opened:
  CallPDos PDReadFile,WEEGUI_File
  bcc @Read
  jmp @ExitPdos

@Read:
  CallPDos PDCloseFile,WEEGUI_File
  bcc @Closed
  jmp @ExitPdos
  
@Closed:
  jsr WGInit

  CallWeegui WGDesktop
  CallWeegui WGCreateButton,QuitButton
  CallWeegui WGCreateButton,CatButton
  CallWeegui WGCreateView,MainWindow
  lda #0
  CallWeegui WGSelectView
  CallWeegui WGViewSetTitle,MainWindowTitle
  CallWeegui WGViewPaintAll
  CallWeegui WGEnableMouse

@Main:
  CallWeegui WGPendingViewAction

  lda #0
  CallWeegui WGSelectView

  jsr GuiPrintDateTime

  lda GuiQuit
  cmp #1
  beq @Exit

  bra @Main

@Exit:
  CallWeegui WGDisableMouse
  CallWeegui WGExit

  jsr $fc58
  jsr $fb2f

  jsr PDPrintBitmap

@ExitPdos:
  rts

GuiPrintDateTime:
  jsr PDStoreDateTime
  lda #1
  sta PARAM0
  lda #0
  sta PARAM1
  CallWeegui WGSetCursor
  CallWeegui WGPrint,MLIDateString
  
  lda #11
  sta PARAM0
  lda #0
  sta PARAM1
  CallWeegui WGSetCursor
  CallWeegui WGPrint,MLITimeString

  rts

CatButtonCallback:
  lda #6
  sta GuiCurrCol

  lda #0
  CallWeegui WGSelectView
  CallWeegui WGEraseViewContents
  CallWeegui WGViewSetTitle,MainWindowTitle
  CallWeegui WGPaintView

; Redraw Quit Button
  lda #1
  CallWeegui WGSelectView
  CallWeegui WGPaintView

  lda #0
  CallWeegui WGSelectView

  lda #1
  sta PARAM0
  lda #2
  sta PARAM1
  CallWeegui WGSetCursor
  CallWeegui WGPrint,DirFileName

  lda #1
  sta PARAM0
  lda #4
  sta PARAM1
  CallWeegui WGSetCursor
  CallWeegui WGPrint,GuiCat_Name

  lda #16
  sta PARAM0
  lda #4
  sta PARAM1
  CallWeegui WGSetCursor
  CallWeegui WGPrint,GuiCat_Type

  lda #21
  sta PARAM0
  lda #4
  sta PARAM1
  CallWeegui WGSetCursor
  CallWeegui WGPrint,GuiCat_Modified

  lda #38
  sta PARAM0
  lda #4
  sta PARAM1
  CallWeegui WGSetCursor
  CallWeegui WGPrint,GuiCat_Created

  CallPDos PDOpenFile,DirFile
  bcs CatButtonCallback_Error

  lda #0
  ldx #9
  sta DirFile,x
  inx
  lda #$60
  sta DirFile,x
  CallPDos PDReadFile,DirFile
  bcs CatButtonCallback_Error

  lda #>GuiDirCallback
  sta PDPARAM3
  lda #<GuiDirCallback
  sta PDPARAM2
  CallPDos PDReadDirectory,DirFile
  bcs CatButtonCallback_Error

  CallPDos PDCloseFile,DirFile
  bcs CatButtonCallback_Error
  bra CatButtonCallback_Return

CatButtonCallback_Error:
  clv
  CallWeegui WGPrint,MLIErrorString

CatButtonCallback_Return:
  rts

GuiDirCallback:
  ldx #0
  ldy #0
GuiDirCallback_PrintName:
  cpx PDDirEntry_NameLength
  beq GuiDirCallback_Done

  lda PDDirEntry_FileName,y
  sta ReadDirFileNameBuffer,x

  iny
  inx
  bra GuiDirCallback_PrintName

GuiDirCallback_Done:
  lda #0
  sta ReadDirFileNameBuffer,x

; Print File Name
  lda #1
  sta PARAM0
  lda GuiCurrCol
  sta PARAM1
  CallWeegui WGSetCursor
  CallWeegui WGPrint,ReadDirFileNameBuffer

; Print Type
  lda #17
  sta PARAM0
  lda GuiCurrCol
  sta PARAM1
  CallWeegui WGSetCursor
  CallWeegui WGPrint,PDDirEntry_FileTypeStr

; Update Mod Date/Time
  lda PDDirEntry_ModificationDate
  sta MLIDate
  lda PDDirEntry_ModificationDate+1
  sta MLIDate+1
  lda PDDirEntry_ModificationTime
  sta MLITime
  lda PDDirEntry_ModificationTime+1
  sta MLITime+1
  jsr PDRenderDateTime

; Print Mod Date
  lda #21
  sta PARAM0
  lda GuiCurrCol
  sta PARAM1
  CallWeegui WGSetCursor
  CallWeegui WGPrint,MLIDateString

; Print Mod Time
  lda #31
  sta PARAM0
  lda GuiCurrCol
  sta PARAM1
  CallWeegui WGSetCursor
  CallWeegui WGPrint,MLITimeString

; Update Create Date/Time
  lda PDDirEntry_CreationDate
  sta MLIDate
  lda PDDirEntry_CreationDate+1
  sta MLIDate+1
  lda PDDirEntry_CreationTime
  sta MLITime
  lda PDDirEntry_CreationTime+1
  sta MLITime+1
  jsr PDRenderDateTime

; Print Create Date
  lda #38
  sta PARAM0
  lda GuiCurrCol
  sta PARAM1
  CallWeegui WGSetCursor
  CallWeegui WGPrint,MLIDateString

; Print Create Time
  lda #48
  sta PARAM0
  lda GuiCurrCol
  sta PARAM1
  CallWeegui WGSetCursor
  CallWeegui WGPrint,MLITimeString

  inc GuiCurrCol
  rts

QuitButtonCallback:
  lda #1
  sta GuiQuit
  rts

DirFile:
  .byte 0                       ; Reference Number
  .byte 0,0,0                   ; File Length
  .byte 0,0,0                   ; File Mark
  .word 512                     ; I/O Byte Count
  .addr $6000                   ; Data Location
  .byte 0                       ; String Length
DirFileName:
  .asciiz "/PRODOS402"          ; Null Terminated String

WEEGUI_File:
  .byte 0                       ; Reference Number
  .byte 0,0,0                   ; File Length
  .byte 0,0,0                   ; File Mark
  .word 0                       ; I/O Byte Count
  .addr 0                       ; Data Location
  .byte 0                       ; String Length
  .asciiz "/PRODOS402/WEEGUI"   ; Null Terminated String

MainWindow:
  .byte 0                       ; ID
  .byte 2                       ; Style
  .byte 2, 1                    ; Left, Top
  .byte 76, 21                  ; Width, Height
  .byte 76, 40                  ; Content Width, Content Height

QuitButton:
  .byte 1
  .byte 67,1
  .byte 10
  .addr QuitButtonCallback
  .addr QuitButtonStr

CatButton:
  .byte 2
  .byte 20,1
  .byte 13
  .addr CatButtonCallback
  .addr CatButtonStr

GuiCurrCol:
  .byte 1

GuiQuit:
  .byte 0

ReadDirFileNameBuffer:
  .res 16

MainWindowTitle:
  .asciiz "PDos Demo"
QuitButtonStr:
  .asciiz "Quit"
CatButtonStr:
  .asciiz "Catalog"
GuiCat_Name:
  .asciiz "NAME"
GuiCat_Type:
  .asciiz "TYPE"
GuiCat_Blocks:
  .asciiz "BLOCKS"
GuiCat_Modified:
  .asciiz "MODIFIED"
GuiCat_Created:
  .asciiz "CREATED"
GuiCat_EndFile:
  .asciiz "ENDFILE"
GuiCat_SubType:
  .asciiz "SUBTYPE"

; BRUN'ing Pdos hits here.
main:
  jsr PDInit
  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDOSDispatch
; The dispatcher for calling the assembly-language API from assembly programs
; X: API call number
; PDPARAM0-3,Y: Parameters to call, as needed
PDOSDispatch:
  jmp (PDEntryPointTable,x)

; Entry point jump table
PDEntryPointTable:
; PDos API Calls
.addr PDOpenFile
.addr PDReadFile
.addr PDCloseFile
.addr PDGetInfo
.addr PDSetEOF

; Memory
.addr PDReservePage
.addr PDReleasePage
.addr PDFindHighestFreePage
.addr PDReserveRange
.addr PDReleaseRange
.addr PDCheckPageFree
.addr PDFindBuffer
.addr PDReserveBuffer
.addr PDReleaseBuffer

; Utilities
.addr PDStoreDateTime
.addr PDErrorFromCode
.addr PDPrintBitmap
.addr PDPrintCurrentError
.addr PDPrintErrorString

; Lower-level Prodos MLI Wrappers
.addr PDSysOpen
.addr PDSysRead
.addr PDSysWrite
.addr PDSysClose
.addr PDSysFlush
.addr PDSysGetTime
.addr PDSysGetFileInfo
.addr PDSysGetEOF
.addr PDSysSetEOF
.addr PDSysGetMark
.addr PDSysSetMark

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDInit
; Sets PDos up.  Reserves PDos in memory map.
PDInit:
  rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PDExit
; Cleans up PDos.  Call when done.
PDExit:
  rts

; Core modules
.include "memory.s"
.include "utils.s"
.include "syscalls.s"

; Functional modules
.include "files.s"

; Data
.include "parameters.s"
.include "vars.s"
.include "strings.s"

; Suppress some linker warnings - Must be the last thing in the file
.SEGMENT "ZPSAVE"
.SEGMENT "EXEHDR"
.SEGMENT "STARTUP"
.SEGMENT "INIT"
.SEGMENT "LOWCODE"
