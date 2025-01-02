;1 + 4 + 7+ .. + 148 

.MODEL SMALL
sum_series macro temp_sum, curr_term, last_term  
    mov bx, curr_term
sum_loop:
    add temp_sum, bx  ; Add the current term (bx) to sum (ax)
    
    ; Check if the current term (bx) is greater than 148
    cmp bx, last_term
    je done     ; If bx = 148, exit the loop

    add bx, 3    ; Move to the next term (increment by 3)
    jmp sum_loop ; Repeat the loop

done:
    mov sum, temp_sum  ; Store the result in the sum variable
    
endm
 
.STACK 100H

.DATA
sum dw ?  
.CODE
MAIN PROC

;iniitialize DS

MOV AX,@DATA
MOV DS,AX
 
; enter your code here 
    ; Initialize sum to 0
    mov ax, 0  
    mov cx, 1  ; Start with the first term (1)
    mov dx, 148 
    sum_series ax, cx, dx 
   
;exit to DOS
               
MOV AX,4C00H
INT 21H

MAIN ENDP

    END MAIN