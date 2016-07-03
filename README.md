## Synopsis

PDos is a helper library for dealing with the Prodos MLI.  It works on several levels and at its core implements a very simple stack based calling mechanism for Prodos system calls.  Built on top of that core is small but useful (and growing) set of routines that attempt to be the start of a Prodos MLI 'standard library' of sorts.  Long way off from that goal but I believe its at a sufficiently complete state to be useful for study, or at the least, to point out all the numerous ways I'm doing things incorrectly.

## Code Example

```
; Let's read a file into memory using Prodos!
; That's what the kids like these days, right?

; Set aside some memory to store needed and useful Prodos file bits
; including the all important path to your file.
YourAwesome_File_Struct:
  .byte 0                       ; Reference Number
  .byte 0,0,0                   ; File Length
  .byte 0,0,0                   ; File Mark
  .word 0                       ; I/O Byte Count
  .addr 0                       ; Data Location
  .byte 0                       ; String Length
  .asciiz "/PATH/TO/YOUR/FILE"  ; Null Terminated String

 ; And now lets open up the file, read it into memory and close it
 ; The nice part here is PDos is handling reserving pages in the
 ; Prodos bitmap for you and a bunch of other tedium.
  CallPDos PDOpenFile,YourAwesome_File_Struct:
  bcc @Opened
  jmp @ExitPdos

@Opened:
  CallPDos PDReadFile,YourAwesome_File_Struct:
  bcc @Read
  jmp @ExitPdos

@Read:
  CallPDos PDCloseFile,YourAwesome_File_Struct:
  bcc @Closed
  jmp @ExitPdos

; File is now in memory, let's boogie.
```

## Motivation

Quinn Dunki's amazing [WeeGUI](https://github.com/blondie7575/WeeGUI) made me want to try to write some kind of GUI-based file utilty. A WeeGui Commander or something if you will and I sort of got sidetracked on implementing all the Prodos bits which I found to be oddly compelling in a sort of masochistic way.  The demo disk in the repo can be booted using Applewin or your emulator (or hardware I suppose) of choice.  Then simply BRUN PDOS.  PDos is used to load WeeGUI into memory, then creates a simple UI with it showing the current date and time, and lets you catalog the demo disk.  Doesn't sound like much I know but like with many things there is a lot going on to get to that point.

There are definietly some things I have 'borrowed' from Quinn Dunki and the calling structure will be very apparent to anyone who has used WeeGUI.  The purpose and code should is sufficiently different that I believe it falls into a realm of acceptability but I do want to give credit where credit definetly due.
