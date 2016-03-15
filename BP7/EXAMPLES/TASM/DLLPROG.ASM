; Turbo Assembler    Copyright (c) 1988, 1993 By Borland International, Inc.

; DLLPROG.ASM - Template for writing .DLL files.

; From the Turbo Assembler Users Guide

P286               ;286 processor; the minimum if we're writing
                   ; for protected mode
WARN PRO           ;enable protected mode warning
MODEL LARGE

;Include files
INCLUDE WINDOWS.INC      ;WINDOWS.INC contains assembly language
                         ; definitions for Windows data types, etc.

DATASEG
   ;<<Initialized data goes here>>

UDATASEG
   ;<<Uninitialized data goes here>>

CODESEG
;----------------------------------------------------------------------
;Dynamic link library initialization procedure.
;LibMain is called to initialize the DLL library routines in module.
;This routine should return a 1 in AX if the library is
;successfully initialized, 0 otherwise.
;----------------------------------------------------------------------
LibMain PROC PASCAL FAR
PUBLIC  PASCAL LibMain
ARG     @@hInstance:WORD,   \Descriptor for instance of application
   @@wDataSeg:WORD,         \Library's data segment
   @@wHeapSize:WORD,        \Heap size
   @@lpszCmdLine:DWORD      ;pointer to command line
USES ES,SI,DI
   ;<<User code that initializes library goes here>>
   MOV AX,1                 ;signals successful initialization
   RET
LibMain ENDP

;----------------------------------------------------------------------
;Dynamic link library de-initialization procedure.
;This routine is optional.
;The example here does nothing; it is included as a guide.
;Returns AX=1 if deinitialization was successful
;----------------------------------------------------------------------
WEP PROC  WINDOWS PASCAL FAR
PUBLICDLL PASCAL WEP
ARG       @@nParameter      ;parameter; specifies situation in which
                            ; WEP is called
USES ES,SI,DI
   ;<<De-initialization code goes here>>
   MOV AX,1                 ;signals successful de-initialization
   RET
WEP ENDP

;----------------------------------------------------------------------
;Dynamic Link Library Routines.
;All user-defined library routines must be declared as PASCAL FAR
;procedures, and must be published using the PUBLICDLL directive.
;The arguments passed to and returned from DLL procedures are
;determined entirely by the programmer.
;----------------------------------------------------------------------
;[SetHello]
;Copy string 'Hello, Windows from dllprog.dll!' into a buffer.
;Pass address of buffer.
;Return length of string in AX.
PUBLICDLL PASCAL SETHELLO
SETHELLO  PROC WINDOWS PASCAL FAR
ARG       @@lpszParam:DWORD         ;storage for string
USES ES,SI,DI
   ;<<User code goes here - here's an example:>>

   DATASEG
@@Hello   DB 'Welcome to Windows from Assembly: Press LButton ',0
@@HSize = $-@@Hello
   CODESEG
   MOV SI,OFFSET @@Hello
   LES DI,@@lpszParam
   MOV CX,@@Hsize
   CLD
   REP MOVSB
   MOV AX,@@Hsize-1
   RET
SETHELLO ENDP
END

