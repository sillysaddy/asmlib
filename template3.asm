;1 + 4 + 7+ .. + 148
.MODEL SMALL
 
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
    mov bx, 1  ; Start with the first term (1) 
    call sum_series


;exit to DOS
               
MOV AX,4C00H
INT 21H

MAIN ENDP
proc sum_series
    
sum_loop:
    add ax, bx  ; Add the current term (bx) to sum (ax)
    
    ; Check if the current term (bx) is greater than 148
    cmp bx, 148
    je done     ; If bx = 148, exit the loop

    add bx, 3    ; Move to the next term (increment by 3)
    jmp sum_loop ; Repeat the loop

done:
    mov sum, ax  ; Store the result in the sum variable
    ret
endp sum_series

    END MAIN
