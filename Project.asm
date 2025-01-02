.MODEL SMALL
 
.STACK 100H

.DATA
; Messages
prompt_id db 'Enter ID (2 digits): $'
prompt_pass db 'Enter Password (6 digits): $'
admin_msg1 db 13,10,'    ********************************$'
admin_msg2 db 13,10,'    *      WELCOME TO ASMLIB       *$'
admin_msg3 db 13,10,'    *     MANAGEMENT SYSTEM        *$'
admin_msg4 db 13,10,'    *                              *$'
admin_msg5 db 13,10,'    *         ADMIN PANEL          *$'
admin_msg6 db 13,10,'    ********************************$'

user_msg1 db 13,10,'    +=========================+$'
user_msg2 db 13,10,'    |     WELCOME TO ASMLIB   |$'
user_msg3 db 13,10,'    |    MANAGEMENT SYSTEM    |$'
user_msg4 db 13,10,'    |                         |$'
user_msg5 db 13,10,'    |      USER INTERFACE     |$'
user_msg6 db 13,10,'    +=========================+$'

error_msg db 13,10
         db '    !!!!!!!!!!!!!!!!!!!!!!!!!!!!$'
         db 13,10,'    ! Invalid ID or Password! !$'
         db 13,10,'    !      Please try again   !$'
         db 13,10,'    !!!!!!!!!!!!!!!!!!!!!!!!!!!!$'

newline db 13,10,'$'

; User database
; Format: ID (2 bytes), Password (6 bytes)
users db '01','123456'  ; Admin1
      db '02','223456'  ; Admin2
      db '03','323456'  ; Admin3
      db '04','423456'  ; User1
      db '05','523456'  ; User2
      db '06','623456'  ; User3
      db '07','723456'  ; User4
      db '08','823456'  ; User5

; Input buffers
input_id db 3 dup(?) 
input_pass db 7 dup(?)

.CODE
MAIN PROC
    ; Initialize DS
    MOV AX, @DATA
    MOV DS, AX

login_start:
    ; Display ID prompt
    LEA DX, prompt_id
    MOV AH, 9
    INT 21h
    
    ; Read ID
    MOV CX, 2  ; Read 2 characters
    LEA SI, input_id
    CALL read_input
    
    ; Display password prompt
    LEA DX, newline
    MOV AH, 9
    INT 21h
    LEA DX, prompt_pass
    INT 21h
    
    ; Read password
    MOV CX, 6  ; Read 6 characters
    LEA SI, input_pass
    CALL read_input
    
    ; Validate credentials
    MOV CX, 8  ; Number of users
    LEA SI, users
    
check_credentials:
    PUSH CX
    
    ; Compare ID
    MOV CX, 2
    LEA DI, input_id
    CALL compare_strings
    JNE next_user
    
    ; Compare password
    MOV CX, 6
    LEA DI, input_pass
    ADD SI, 2  ; Move to password in database
    CALL compare_strings
    JE valid_login
    
next_user:
    POP CX
    ADD SI, 8  ; Move to next user (2 bytes ID + 6 bytes password)
    LOOP check_credentials
    
    ; Invalid login
    LEA DX, newline
    MOV AH, 9
    INT 21h
    LEA DX, error_msg
    INT 21h
    JMP login_start
    
valid_login:
    POP CX
    LEA DX, newline
    MOV AH, 9
    INT 21h
    
    ; Check if admin (ID <= 03) or user
    MOV SI, OFFSET input_id
    CMP BYTE PTR [SI], '0'
    JNE user_welcome
    MOV AL, [SI+1]
    CMP AL, '3'
    JA user_welcome
    
    ; Display admin welcome
    LEA DX, admin_msg1
    MOV AH, 9
    INT 21h
    
    LEA DX, admin_msg2
    MOV AH, 9
    INT 21h
    
    LEA DX, admin_msg3
    MOV AH, 9
    INT 21h
    
    LEA DX, admin_msg4
    MOV AH, 9
    INT 21h
    
    LEA DX, admin_msg5
    MOV AH, 9
    INT 21h
    
    LEA DX, admin_msg6
    MOV AH, 9
    INT 21h
    
    LEA DX, newline
    MOV AH, 9
    INT 21h
    JMP exit_prog
    
user_welcome:
    LEA DX, user_msg1
    MOV AH, 9
    INT 21h
    
    LEA DX, user_msg2
    MOV AH, 9
    INT 21h
    
    LEA DX, user_msg3
    MOV AH, 9
    INT 21h
    
    LEA DX, user_msg4
    MOV AH, 9
    INT 21h
    
    LEA DX, user_msg5
    MOV AH, 9
    INT 21h
    
    LEA DX, user_msg6
    MOV AH, 9
    INT 21h
    
    LEA DX, newline
    MOV AH, 9
    INT 21h
    
exit_prog:
    MOV AX, 4C00H
    INT 21H
MAIN ENDP

; Procedure to read input string
; Parameters: CX = number of characters to read, SI = buffer address
read_input PROC
    PUSH AX
read_loop:
    MOV AH, 1
    INT 21h
    MOV [SI], AL
    INC SI
    LOOP read_loop
    POP AX
    RET
read_input ENDP

; Procedure to compare strings
; Parameters: CX = length, SI = string1, DI = string2
; Returns: ZF set if equal
compare_strings PROC
    PUSH AX
    PUSH SI
    PUSH DI
compare_loop:
    MOV AL, [SI]
    CMP AL, [DI]
    JNE compare_end
    INC SI
    INC DI
    LOOP compare_loop
    ; Set zero flag if strings match
    XOR AX, AX  ; This will set ZF=1
    JMP compare_done
compare_end:
    OR AX, 1    ; This will set ZF=0
compare_done:    
    POP DI
    POP SI
    POP AX
    RET
compare_strings ENDP

; Debug - verify first user ID
MOV AL, [SI]      ; Should be '0'
MOV AH, [SI+1]    ; Should be '1'

END MAIN