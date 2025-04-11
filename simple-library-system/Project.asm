.MODEL SMALL
.STACK 256

.DATA
    ; Predefined user credentials
    AdminUsername DB 'admin', 0
    AdminPassword DB 'password', 0
    UserUsername DB 'user', 0
    UserPassword DB 'password', 0

    ; Book data storage
    BookTitle DB 50 DUP(0)  ; Buffer for book title
    BookAuthor DB 50 DUP(0) ; Buffer for book author
    BookISBN DB 20 DUP(0)   ; Buffer for book ISBN
    BookRecord DB 100 DUP(0) ; Buffer for a single book record

    ; Messages
    LoginPrompt DB 'Enter username: $'
    PasswordPrompt DB 'Enter password: $'
    SuccessMessage DB 'Login successful!$'
    FailureMessage DB 'Login failed!$'
    AddBookPrompt DB 'Enter book title, author, and ISBN: $'
    BookAddedMessage DB 'Book added successfully!$'
    ExitMessage DB 'Exiting...$'

.CODE
MAIN PROC
    ; Initialize data segment
    MOV AX, @data
    MOV DS, AX

    ; Main program loop
    CALL MainMenu

    ; Terminate program
    MOV AX, 4C00h
    INT 21h
MAIN ENDP

; Procedure to display the main menu and handle user input
MainMenu PROC
    ; Display login prompt and handle login
    ; Call AdminLogin or UserLogin based on user choice
    ; Implement session management and call respective functions
    RET
MainMenu ENDP

; Procedure for admin login
AdminLogin PROC
    ; Prompt for username and password
    ; Validate against predefined credentials
    ; Set session state for admin
    RET
AdminLogin ENDP

; Procedure for user login
UserLogin PROC
    ; Prompt for username and password
    ; Validate against predefined credentials
    ; Set session state for user
    RET
UserLogin ENDP

; Procedure to add a book
AddBook PROC
    ; Prompt for book details
    ; Store book details in BookRecord
    ; Append to books.dat file
    RET
AddBook ENDP

; Procedure to view books
ViewBooks PROC
    ; Read from books.dat file
    ; Display book records
    RET
ViewBooks ENDP

END MAIN