; This file contains reusable macros for the simple library management system
; These macros simplify common tasks in assembly code, enhancing code readability and maintainability

; Macro for printing a string to the console
PRINT_STRING MACRO str
    MOV DX, OFFSET str  ; Load the address of the string into DX
    MOV AH, 09h         ; DOS function to display a string
    INT 21h             ; Call DOS interrupt
ENDM

; Macro for reading a string from the console
READ_STRING MACRO buffer, maxLength
    MOV DX, OFFSET buffer  ; Load the address of the buffer into DX
    MOV AH, 0Ah            ; DOS function to read a string
    INT 21h                ; Call DOS interrupt
ENDM

; Macro for clearing the screen
CLEAR_SCREEN MACRO
    MOV AX, 0600h         ; Function to clear the screen
    MOV BH, 0             ; Attribute (0 = black)
    MOV CX, 0             ; Upper left corner (0,0)
    MOV DX, 184Fh         ; Lower right corner (80,25)
    INT 10h               ; Call BIOS interrupt
ENDM

; Macro for displaying a newline
NEWLINE MACRO
    MOV AH, 02h           ; DOS function to display a character
    MOV DL, 0Dh           ; Carriage return
    INT 21h               ; Call DOS interrupt
    MOV DL, 0Ah           ; Line feed
    INT 21h               ; Call DOS interrupt
ENDM

; Macro for displaying an error message
DISPLAY_ERROR MACRO msg
    PRINT_STRING msg      ; Print the error message
    NEWLINE               ; Print a newline
ENDM

; End of macros.inc