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

error_msg1 db 13,10,'    !!!!!!!!!!!!!!!!!!!!!!!!!!!!$'
error_msg2 db 13,10,'    ! Invalid ID or Password! !$'
error_msg3 db 13,10,'    !      Please try again   !$'
error_msg4 db 13,10,'    !!!!!!!!!!!!!!!!!!!!!!!!!!!!$'

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

; Add to the .DATA section:

; Book structure (50 bytes per book)
MAX_BOOKS equ 100    ; Maximum number of books
BOOK_SIZE equ 50     ; Size of each book record

books db MAX_BOOKS * BOOK_SIZE dup(?) ; Book database
book_count dw 0      ; Current number of books

; Book management menu messages
book_menu_header1 db 13,10,'    ==================================$'
book_menu_header2 db 13,10,'    |       BOOK MANAGEMENT          |$'
book_menu_header3 db 13,10,'    ==================================$'
book_menu_option1 db 13,10,'    |   1. Add New Book             |$'
book_menu_option2 db 13,10,'    |   2. Remove Book              |$'
book_menu_option3 db 13,10,'    |   3. View All Books           |$'
book_menu_option4 db 13,10,'    |   4. Return to Main Menu      |$'
book_menu_footer  db 13,10,'    ==================================$'
book_menu_prompt  db 13,10,'    Enter choice: $'

; Book input prompts
prompt_bookid db 13,10,'Enter Book ID (4 digits): $'
prompt_title db 13,10,'Enter Book Title (30 chars max): $'
prompt_author db 13,10,'Enter Author Name (15 chars max): $'

; Success/Error messages
book_added db 13,10,'Book successfully added!$'
book_removed db 13,10,'Book successfully removed!$'
book_error db 13,10,'Error: Invalid input or database full!$'

; Add to DATA section
prompt_remove_id db 13,10,'Enter Book ID to remove: $'
book_not_found db 13,10,'Error: Book not found!$'

; Add to DATA section
view_header1 db 13,10,'    +===========================================+$'
view_header2 db 13,10,'    |              BOOK LISTING               |$'
view_header3 db 13,10,'    |-------------------------------------------$'
view_header4 db 13,10,'    | ID  |     Title          |    Author     |$'
view_header5 db 13,10,'    |-------------------------------------------$'
no_books db 13,10,'    |          No books in database           |$'
total_books db 13,10,'    Total books: $'
book_format db 13,10,'    | $'

; Add to DATA section
admin_menu_header db 13,10,'    ================================$'
                 db 13,10,'    |      ADMIN CONTROL PANEL      |$'
                 db 13,10,'    ================================$'
                 db 13,10,'$'  ; Extra newline after header

admin_options db 13,10,'    [1] Book Management$'
             db 13,10,'    [2] Logout$'
             db 13,10,13,10,'    Select option (1-2): $'

invalid_option db 13,10,'    Invalid option! Please try again.$'
goodbye_msg db 13,10,'    Logging out... Thank you!$'

; In the DATA section, add:
admin_initial_menu db 13,10,'    [1] Go to Admin Control Panel$'
                  db 13,10,13,10,'    Select option (1): $'

; In DATA section, modify the header definition:
admin_header1 db 13,10,'    ================================$'
admin_header2 db 13,10,'    |      ADMIN CONTROL PANEL      |$'
admin_header3 db 13,10,'    ================================$'

; In DATA section:
admin_option1 db 13,10,'    [1] Book Management$'
admin_option2 db 13,10,'    [2] Logout$'
admin_select db 13,10,13,10,'    Select option (1-2): $'

; In DATA section:
; Book Structure (50 bytes per book):
; - ID (4 bytes)
; - Title (20 bytes)
; - Author (15 bytes)
; - Genre (10 bytes)
; - Status (1 byte): 0=Available, 1=Borrowed

initial_books db '0001', 'Pride Prejudice     ', 'Jane Austen     ', 'Romance   ', 0
             db '0002', 'Great Expectations  ', 'Charles Dickens', 'Coming Age', 0   ; Correct: 4+20+15+10+1=50
             db '0003', 'Animal Farm        ', 'George Orwell  ', 'Political ', 0    ; Correct: 4+20+15+10+1=50
             db '0004', 'Invisible Man      ', 'Ralph Ellison  ', 'Fiction   ', 0     ; Correct
             db '0005', 'Catch-22           ', 'Joseph Heller  ', 'Satirical ', 0     ; Correct
             db '0006', 'Brave New World    ', 'Aldous Huxley  ', 'Dystopian ', 0      ; Correct
             db '0007', 'Beloved Memory     ', 'Toni Morrison  ', 'Historical', 0    ; Correct
             db '0008', 'White Teeth        ', 'Zadie Smith    ', 'Contemp   ', 0      ; Correct
             db '0009', 'Rebecca Memories   ', 'Daphne Maurier ', 'Gothic    ', 0      ; Correct
             db '0010', 'Fahrenheit 451     ', 'Ray Bradbury   ', 'SciFi     ', 0        ; Correct

num_buffer db 6 dup(?), '$'  ; Buffer for number conversion

.CODE
MAIN PROC
    ; Initialize DS
    MOV AX, @DATA
    MOV DS, AX

    ; Initialize books database
    MOV CX, 10              ; Number of initial books
    MOV SI, OFFSET initial_books
    MOV DI, OFFSET books
    MOV book_count, CX      ; Set initial book count

copy_initial_books_outer:
    PUSH CX              ; Save the outer loop counter

    ; Inner loop: copy 50 bytes for each book
    MOV CX, BOOK_SIZE    ; CX = 50 (bytes per book)

copy_initial_books_inner:
    MOV AL, [SI]         ; Load byte from initial_books
    MOV [DI], AL         ; Store byte to books
    INC SI               ; Move to next byte in initial_books
    INC DI               ; Move to next byte in books
    LOOP copy_initial_books_inner

    POP CX               ; Restore the outer loop counter
    DEC CX               ; Decrement book count
    JNZ copy_initial_books_outer  ; If not zero, continue copying

    ; All books copied
    JMP after_copy_initial_books

copy_initial_books_done:
    ; Handle any errors if needed
    JMP after_copy_initial_books

after_copy_initial_books:
    ; Continue with the rest of your program

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
    
    LEA DX, error_msg1
    MOV AH, 9
    INT 21h
    
    LEA DX, error_msg2
    MOV AH, 9
    INT 21h
    
    LEA DX, error_msg3
    MOV AH, 9
    INT 21h
    
    LEA DX, error_msg4
    MOV AH, 9
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
    
    LEA DX, admin_initial_menu
    MOV AH, 9
    INT 21h

initial_choice:
    ; Get choice
    MOV AH, 1
    INT 21h
    SUB AL, '0'  ; Convert ASCII to number
    
    CMP AL, 1
    JE admin_menu
    
    ; If invalid choice, wait for correct input
    JMP initial_choice

admin_menu:
    ; Clear screen
    MOV AX, 0003h
    INT 10h
    
    ; Display header
    LEA DX, admin_header1
    MOV AH, 9
    INT 21h
    
    LEA DX, admin_header2
    MOV AH, 9
    INT 21h
    
    LEA DX, admin_header3
    MOV AH, 9
    INT 21h
    
    ; Display newline
    LEA DX, newline
    MOV AH, 9
    INT 21h
    
    ; Display options
    LEA DX, admin_option1
    MOV AH, 9
    INT 21h
    
    LEA DX, admin_option2
    MOV AH, 9
    INT 21h
    
    LEA DX, admin_select
    MOV AH, 9
    INT 21h

get_admin_choice:    
    ; Get choice
    MOV AH, 1
    INT 21h
    SUB AL, '0'  ; Convert ASCII to number
    
    CMP AL, 1
    JE book_mgmt
    CMP AL, 2
    JE logout
    
    ; Invalid option
    LEA DX, invalid_option
    MOV AH, 9
    INT 21h
    JMP admin_menu
    
book_mgmt:
    CALL book_management
    JMP admin_menu
    
logout:
    LEA DX, goodbye_msg
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

; Add these procedures after MAIN ENDP

; Book Management Menu Procedure
book_management PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

book_menu_loop:
    ; Clear screen
    MOV AX, 0003h
    INT 10h
    
    ; Display menu line by line
    LEA DX, book_menu_header1
    MOV AH, 9
    INT 21h
    
    LEA DX, book_menu_header2
    MOV AH, 9
    INT 21h
    
    LEA DX, book_menu_header3
    MOV AH, 9
    INT 21h
    
    LEA DX, book_menu_option1
    MOV AH, 9
    INT 21h
    
    LEA DX, book_menu_option2
    MOV AH, 9
    INT 21h
    
    LEA DX, book_menu_option3
    MOV AH, 9
    INT 21h
    
    LEA DX, book_menu_option4
    MOV AH, 9
    INT 21h
    
    LEA DX, book_menu_footer
    MOV AH, 9
    INT 21h
    
    LEA DX, book_menu_prompt
    MOV AH, 9
    INT 21h
    
    ; Get choice
    MOV AH, 1
    INT 21h
    SUB AL, '0'  ; Convert ASCII to number
    
    CMP AL, 1
    JE add_book_label
    CMP AL, 2
    JE remove_book_label
    CMP AL, 3
    JE view_books_label
    CMP AL, 4
    JE exit_book_menu
    
    JMP book_menu_loop

add_book_label:
    CALL add_book
    JMP book_menu_loop
    
remove_book_label:
    CALL remove_book
    JMP book_menu_loop
    
view_books_label:
    CALL view_books
    JMP book_menu_loop
    
exit_book_menu:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
book_management ENDP

; Add Book Procedure
add_book PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    ; Check if database is full
    MOV AX, book_count
    CMP AX, MAX_BOOKS
    JAE add_book_error
    
    ; Calculate offset for new book
    MOV BX, BOOK_SIZE
    MUL BX          ; AX = book_count * BOOK_SIZE
    LEA SI, books
    ADD SI, AX      ; SI points to new book location
    
    ; Get Book ID
    LEA DX, prompt_bookid
    MOV AH, 9
    INT 21h
    MOV CX, 4
    CALL read_input
    
    ; Get Book Title
    LEA DX, prompt_title
    MOV AH, 9
    INT 21h
    MOV CX, 20 ;Read 20 bytes for title
    ADD SI, 4       ; Skip past ID
    CALL read_input
    
    ; Get Author Name
    LEA DX, prompt_author
    MOV AH, 9
    INT 21h
    MOV CX, 15     ; Read 15 bytes for author
    ADD SI, 20      ; Skip past title
    CALL read_input

    ; Initialize Genre and Status (Optional)
        ; You can initialize Genre and Status here if needed
    MOV BYTE PTR [SI], ' '    ; Initialize Genre with spaces
    MOV BYTE PTR [SI+10], 0    ; Initialize Status to Available (0)
    
    ; Increment book count
    INC book_count
    
    ; Display success message
    LEA DX, book_added
    MOV AH, 9
    INT 21h
    JMP add_book_done
    
add_book_error:
    LEA DX, book_error
    MOV AH, 9
    INT 21h
    
add_book_done:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
add_book ENDP

; Add after add_book ENDP
remove_book PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    ; Display prompt
    LEA DX, prompt_remove_id
    MOV AH, 9
    INT 21h

    ; Read book ID
    MOV CX, 4
    LEA SI, input_id    ; Reuse input_id buffer
    CALL read_input

    ; Search for book
    MOV CX, book_count
    LEA SI, books
search_loop:
    PUSH CX
    MOV CX, 4          ; Compare 4 digits of ID
    LEA DI, input_id
    CALL compare_strings
    JE found_book
    ADD SI, BOOK_SIZE  ; Move to next book
    POP CX
    LOOP search_loop

    ; Book not found
    LEA DX, book_not_found
    MOV AH, 9
    INT 21h
    JMP remove_done

found_book:
    POP CX             ; Clean up stack
    
    ; Calculate books to move
    MOV AX, book_count
    DEC AX             ; Total books - 1
    MOV CX, AX
    
    ; Move remaining books up
shift_loop:
    PUSH CX
    MOV CX, BOOK_SIZE
    LEA DI, [SI]       ; Destination
    ADD SI, BOOK_SIZE  ; Source
    
    ; Copy book data
copy_loop:
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    LOOP copy_loop
    
    POP CX
    LOOP shift_loop
    
    ; Decrease book count
    DEC book_count
    
    ; Display success
    LEA DX, book_removed
    MOV AH, 9
    INT 21h

remove_done:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
remove_book ENDP

; Add after remove_book ENDP
view_books PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    ; Clear screen
    MOV AX, 0003h
    INT 10h

    ; Display headers
    LEA DX, view_header1
    MOV AH, 9
    INT 21h
    LEA DX, view_header2
    MOV AH, 9
    INT 21h
    LEA DX, view_header3
    MOV AH, 9
    INT 21h
    LEA DX, view_header4
    MOV AH, 9
    INT 21h
    LEA DX, view_header5
    MOV AH, 9
    INT 21h

    ; Check if books exist
    MOV AX, book_count
    CMP AX, 0
    JE no_books_found

    ; Initialize
    MOV BX, book_count        ; Use BX for outer loop (number of books)
    LEA SI, books             ; Point to the first book

display_books_loop:
    PUSH BX                   ; Save outer loop counter

    ; Display book format prefix
    LEA DX, book_format
    MOV AH, 9
    INT 21h

    ; Display ID (4 chars)
    MOV CX, 4                 ; Use CX for inner loop (ID)
display_id_loop:
    MOV DL, [SI]
    MOV AH, 2
    INT 21h
    INC SI
    LOOP display_id_loop      ; LOOP decrements CX and jumps if not zero

    ; Display separator
    MOV DL, ' '
    MOV AH, 2
    INT 21h
    MOV DL, '|'
    MOV AH, 2
    INT 21h
    MOV DL, ' '
    MOV AH, 2
    INT 21h

    ; Display Title (20 chars)
    MOV CX, 20                ; Use CX for inner loop (Title)
display_title_loop:
    MOV DL, [SI]
    MOV AH, 2
    INT 21h
    INC SI
    LOOP display_title_loop

    ; Display separator
    MOV DL, ' '
    MOV AH, 2
    INT 21h
    MOV DL, '|'
    MOV AH, 2
    INT 21h
    MOV DL, ' '
    MOV AH, 2
    INT 21h

    ; Display Author (15 chars)
    MOV CX, 15                ; Use CX for inner loop (Author)
display_author_loop:
    MOV DL, [SI]
    MOV AH, 2
    INT 21h
    INC SI
    LOOP display_author_loop

    ; Add newline
    LEA DX, newline
    MOV AH, 9
    INT 21h

    ; Skip Genre and Status (11 bytes)
    ADD SI, 11

    POP BX                    ; Restore outer loop counter
    DEC BX                    ; Decrement book count
    JNZ display_books_loop    ; If not zero, continue looping

    JMP display_total

no_books_found:
    LEA DX, no_books
    MOV AH, 9
    INT 21h

display_total:
    ; Display footer
    LEA DX, view_header1
    MOV AH, 9
    INT 21h

    ; Show total books
    LEA DX, total_books
    MOV AH, 9
    INT 21h

    ; Convert book_count to ASCII and store in num_buffer
    MOV AX, book_count
    CALL convert_number_to_string

    ; Display the number
    LEA DX, num_buffer
    MOV AH, 9
    INT 21h

    ; Add newline
    LEA DX, newline
    MOV AH, 9
    INT 21h

    ; Wait for keypress
    MOV AH, 1
    INT 21h

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
view_books ENDP

; Number conversion procedure
convert_number_to_string PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI

    ; Initialize
    XOR AX, AX          ; Clear AX
    MOV AX, book_count  ; AX = book_count
    XOR CX, CX          ; CX = 0 (digit counter)
    LEA DI, num_buffer  ; DI points to num_buffer

convert_number_loop:
    XOR DX, DX          ; Clear DX before DIV
    MOV BX, 10
    DIV BX              ; Divide AX by 10; AX = quotient, DX = remainder
    ADD DL, '0'         ; Convert remainder to ASCII
    MOV [DI], DL        ; Store ASCII digit
    INC DI
    INC CX
    CMP AX, 0
    JNZ convert_number_loop

    ; Append '$' to terminate the string
    MOV BYTE PTR [DI], '$'

    ; Reverse the digits in num_buffer for correct order
    ; Assuming max 5 digits for book_count
    ; Initialize SI to start of num_buffer and DI to end
    LEA SI, num_buffer
    DEC DI               ; Point to last digit
    ; Simple reverse algorithm
reverse_digits_loop:
    CMP SI, DI
    JGE reverse_done
    MOV AL, [SI]
    MOV BL, [DI]
    MOV [SI], BL
    MOV [DI], AL
    INC SI
    DEC DI
    JMP reverse_digits_loop
reverse_done:

    ; Restore registers
    POP DI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
convert_number_to_string ENDP

; Debug - verify first user ID
MOV AL, [SI]      ; Should be '0'
MOV AH, [SI+1]    ; Should be '1'

END MAIN