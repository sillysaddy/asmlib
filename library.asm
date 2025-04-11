; filepath: d:\proj341\library.asm
; Simple Library System - 8086 Assembly Implementation
; Based on PRD requirements v1.0 (2025-04-11)

.MODEL SMALL
.STACK 256
.DATA
    ; System messages
    welcomeMsg      DB 'Welcome to Library Management System', 13, 10, '$'
    adminPrompt     DB 'Enter Admin Username: $'
    userPrompt      DB 'Enter User Username: $'
    passwordPrompt  DB 'Enter Password: $'
    loginFailMsg    DB 'Login failed. Try again.', 13, 10, '$'
    loginSuccessMsg DB 'Login successful!', 13, 10, '$'
    logoutMsg       DB 'Logged out successfully.', 13, 10, '$'
    pressAnyKeyMsg  DB 'Press any key to continue...', 13, 10, '$'
    
    ; Menu headers
    mainMenuHeader  DB 'MAIN MENU', 13, 10, '=========', 13, 10, '$'
    adminMenuHeader DB 'ADMIN MENU', 13, 10, '==========', 13, 10, '$'
    userMenuHeader  DB 'USER MENU', 13, 10, '=========', 13, 10, '$'
    
    ; Menu options
    mainMenuOptions DB '1. Admin Login', 13, 10
                    DB '2. User Login', 13, 10
                    DB '3. Exit', 13, 10
                    DB 'Enter choice: $'
                    
    adminMenuOptions DB '1. Add Book', 13, 10
                     DB '2. View Books', 13, 10
                     DB '3. Logout', 13, 10
                     DB 'Enter choice: $'
                     
    userMenuOptions DB '1. View Books', 13, 10
                    DB '2. Logout', 13, 10
                    DB 'Enter choice: $'
    
    ; Book-related messages
    addBookHeader   DB 'ADD BOOK', 13, 10, '========', 13, 10, '$'
    titlePrompt     DB 'Enter book title: $'
    authorPrompt    DB 'Enter author name: $'
    isbnPrompt      DB 'Enter ISBN: $'
    addSuccessMsg   DB 'Book added successfully!', 13, 10, '$'
    addFailMsg      DB 'Failed to add book.', 13, 10, '$'
    viewBooksHeader DB 'BOOK LIST', 13, 10, '=========', 13, 10, '$'
    noBooksMsg      DB 'No books found in the library.', 13, 10, '$'
    bookDisplayFmt  DB 'Title: %s', 13, 10, 'Author: %s', 13, 10, 'ISBN: %s', 13, 10, '----------------------', 13, 10, '$'
    
    ; Credentials - Simple predefined credentials for demo purposes
    adminUsername   DB 'admin$'        ; $ terminated for string comparison
    adminPassword   DB 'admin123$'     ; $ terminated for string comparison
    userUsername    DB 'user$'         ; $ terminated for string comparison
    userPassword    DB 'user123$'      ; $ terminated for string comparison
    
    ; Input buffers
    usernameBuffer  DB 20, 0          ; Max size 20, actual size stored at +1
                    DB 20 DUP(?)      ; Username characters
    passwordBuffer  DB 20, 0          ; Max size 20, actual size stored at +1 
                    DB 20 DUP(?)      ; Password characters
    titleBuffer     DB 50, 0          ; Max size 50, actual size stored at +1
                    DB 50 DUP(?)      ; Title characters
    authorBuffer    DB 30, 0          ; Max size 30, actual size stored at +1
                    DB 30 DUP(?)      ; Author characters
    isbnBuffer      DB 15, 0          ; Max size 15, actual size stored at +1
                    DB 15 DUP(?)      ; ISBN characters
    displayBuffer   DB 100 DUP(?)     ; General purpose display buffer
    
    ; State variables
    sessionState    DB 0              ; 0=Not logged in, 1=Admin, 2=User
    
    ; File handling
    bookFile        DB 'books.txt', 0   ; Filename for book data
    fileHandle      DW ?               ; File handle for operations
    bookRecordSize  EQU 97            ; Title(50) + Author(30) + ISBN(15) + separators(2)
    bookRecord      DB bookRecordSize DUP(?)   ; Buffer for reading/writing book records
    
    ; Error messages
    fileOpenErrMsg  DB 'Error opening file.', 13, 10, '$'
    fileReadErrMsg  DB 'Error reading file.', 13, 10, '$'
    fileWriteErrMsg DB 'Error writing to file.', 13, 10, '$'
    fileCreateErrMsg DB 'Error creating file.', 13, 10, '$'
    
    ; Other constants
    newLine         DB 13, 10, '$'    ; Carriage return + line feed with $ terminator
    separator       DB '|'            ; Field separator for book records

.CODE
MAIN PROC
    ; Initialize data segment
    MOV AX, @data
    MOV DS, AX
    
    ; Program starts here
    CALL ClearScreen
    
MainLoop:
    ; Display welcome message and main menu
    CALL ShowMainMenu
    
    ; Get user choice
    CALL GetCharInput
    
    ; Process choice
    CMP AL, '1'
    JE AdminLoginChoice
    CMP AL, '2'
    JE UserLoginChoice
    CMP AL, '3'
    JE ExitProgram
    
    ; Invalid choice, loop back
    JMP MainLoop
    
AdminLoginChoice:
    CALL AdminLogin
    JMP MainLoop
    
UserLoginChoice:
    CALL UserLogin
    JMP MainLoop
    
ExitProgram:
    ; Terminate program
    MOV AX, 4C00h
    INT 21h
MAIN ENDP

; Procedure: ShowMainMenu
; Displays the main menu options
ShowMainMenu PROC
    PUSH AX
    PUSH DX
    
    CALL ClearScreen
    
    ; Display header
    LEA DX, welcomeMsg
    CALL DisplayString
    
    LEA DX, newLine
    CALL DisplayString
    
    LEA DX, mainMenuHeader
    CALL DisplayString
    
    ; Display options
    LEA DX, mainMenuOptions
    CALL DisplayString
    
    POP DX
    POP AX
    RET
ShowMainMenu ENDP

; Procedure: AdminLogin
; Handles admin login process
AdminLogin PROC
    PUSH AX
    PUSH DX
    
    CALL ClearScreen
    
    ; Display admin login prompt
    LEA DX, adminPrompt
    CALL DisplayString
    
    ; Get admin username
    LEA DX, usernameBuffer
    CALL GetStringInput
    
    ; Display password prompt
    LEA DX, passwordPrompt
    CALL DisplayString
    
    ; Get password
    LEA DX, passwordBuffer
    CALL GetStringInput
    
    ; Verify credentials
    CALL ValidateAdminCredentials
    CMP AL, 1           ; AL = 1 if credentials are valid
    JNE AdminLoginFailed
    
    ; Successful login
    LEA DX, loginSuccessMsg
    CALL DisplayString
    
    ; Set session state to Admin (1)
    MOV sessionState, 1
    
    ; Show admin menu
    CALL AdminMenu
    JMP AdminLoginDone
    
AdminLoginFailed:
    LEA DX, loginFailMsg
    CALL DisplayString
    LEA DX, pressAnyKeyMsg
    CALL DisplayString
    CALL GetCharInputNoEcho
    
AdminLoginDone:
    POP DX
    POP AX
    RET
AdminLogin ENDP

; Procedure: UserLogin
; Handles user login process
UserLogin PROC
    PUSH AX
    PUSH DX
    
    CALL ClearScreen
    
    ; Display user login prompt
    LEA DX, userPrompt
    CALL DisplayString
    
    ; Get user username
    LEA DX, usernameBuffer
    CALL GetStringInput
    
    ; Display password prompt
    LEA DX, passwordPrompt
    CALL DisplayString
    
    ; Get password
    LEA DX, passwordBuffer
    CALL GetStringInput
    
    ; Verify credentials
    CALL ValidateUserCredentials
    CMP AL, 1           ; AL = 1 if credentials are valid
    JNE UserLoginFailed
    
    ; Successful login
    LEA DX, loginSuccessMsg
    CALL DisplayString
    
    ; Set session state to User (2)
    MOV sessionState, 2
    
    ; Show user menu
    CALL UserMenu
    JMP UserLoginDone
    
UserLoginFailed:
    LEA DX, loginFailMsg
    CALL DisplayString
    LEA DX, pressAnyKeyMsg
    CALL DisplayString
    CALL GetCharInputNoEcho
    
UserLoginDone:
    POP DX
    POP AX
    RET
UserLogin ENDP

; Procedure: AdminMenu
; Displays and handles the admin menu
AdminMenu PROC
    PUSH AX
    PUSH DX
    
AdminMenuLoop:
    CALL ClearScreen
    
    ; Display admin menu header
    LEA DX, adminMenuHeader
    CALL DisplayString
    
    ; Display admin menu options
    LEA DX, adminMenuOptions
    CALL DisplayString
    
    ; Get admin choice
    CALL GetCharInput
    
    ; Process choice
    CMP AL, '1'
    JE AdminAddBook
    CMP AL, '2'
    JE AdminViewBooks
    CMP AL, '3'
    JE AdminLogout
    
    ; Invalid choice, loop back
    JMP AdminMenuLoop
    
AdminAddBook:
    CALL AddBook
    JMP AdminMenuContinue
    
AdminViewBooks:
    CALL ViewBooks
    JMP AdminMenuContinue
    
AdminLogout:
    ; Reset session state
    MOV sessionState, 0
    
    ; Display logout message
    LEA DX, logoutMsg
    CALL DisplayString
    
    LEA DX, pressAnyKeyMsg
    CALL DisplayString
    CALL GetCharInputNoEcho
    
    ; Exit admin menu
    JMP AdminMenuDone
    
AdminMenuContinue:
    ; Wait for user acknowledgment before showing menu again
    LEA DX, pressAnyKeyMsg
    CALL DisplayString
    CALL GetCharInputNoEcho
    
    JMP AdminMenuLoop
    
AdminMenuDone:
    POP DX
    POP AX
    RET
AdminMenu ENDP

; Procedure: UserMenu
; Displays and handles the user menu
UserMenu PROC
    PUSH AX
    PUSH DX
    
UserMenuLoop:
    CALL ClearScreen
    
    ; Display user menu header
    LEA DX, userMenuHeader
    CALL DisplayString
    
    ; Display user menu options
    LEA DX, userMenuOptions
    CALL DisplayString
    
    ; Get user choice
    CALL GetCharInput
    
    ; Process choice
    CMP AL, '1'
    JE UserViewBooks
    CMP AL, '2'
    JE UserLogout
    
    ; Invalid choice, loop back
    JMP UserMenuLoop
    
UserViewBooks:
    CALL ViewBooks
    JMP UserMenuContinue
    
UserLogout:
    ; Reset session state
    MOV sessionState, 0
    
    ; Display logout message
    LEA DX, logoutMsg
    CALL DisplayString
    
    LEA DX, pressAnyKeyMsg
    CALL DisplayString
    CALL GetCharInputNoEcho
    
    ; Exit user menu
    JMP UserMenuDone
    
UserMenuContinue:
    ; Wait for user acknowledgment before showing menu again
    LEA DX, pressAnyKeyMsg
    CALL DisplayString
    CALL GetCharInputNoEcho
    
    JMP UserMenuLoop
    
UserMenuDone:
    POP DX
    POP AX
    RET
UserMenu ENDP

; Procedure: AddBook
; Handles adding a new book to the system
AddBook PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    CALL ClearScreen
    
    ; Display add book header
    LEA DX, addBookHeader
    CALL DisplayString
    
    ; Get book title
    LEA DX, titlePrompt
    CALL DisplayString
    LEA DX, titleBuffer
    CALL GetStringInput
    
    ; Get author name
    LEA DX, authorPrompt
    CALL DisplayString
    LEA DX, authorBuffer
    CALL GetStringInput
    
    ; Get ISBN
    LEA DX, isbnPrompt
    CALL DisplayString
    LEA DX, isbnBuffer
    CALL GetStringInput
    
    ; Create book record in the format: Title|Author|ISBN
    ; Copy title to record
    LEA SI, titleBuffer + 2  ; Skip size bytes
    LEA DI, bookRecord
    MOV CL, titleBuffer + 1  ; Get actual length
    XOR CH, CH
    JCXZ SkipTitleCopy       ; Skip if empty
    
CopyTitle:
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    LOOP CopyTitle
    
SkipTitleCopy:
    ; Add separator
    MOV AL, '|'
    MOV [DI], AL
    INC DI
    
    ; Copy author to record
    LEA SI, authorBuffer + 2 ; Skip size bytes
    MOV CL, authorBuffer + 1 ; Get actual length
    XOR CH, CH
    JCXZ SkipAuthorCopy      ; Skip if empty
    
CopyAuthor:
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    LOOP CopyAuthor
    
SkipAuthorCopy:
    ; Add separator
    MOV AL, '|'
    MOV [DI], AL
    INC DI
    
    ; Copy ISBN to record
    LEA SI, isbnBuffer + 2   ; Skip size bytes
    MOV CL, isbnBuffer + 1   ; Get actual length
    XOR CH, CH
    JCXZ SkipIsbnCopy        ; Skip if empty
    
CopyIsbn:
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    LOOP CopyIsbn
    
SkipIsbnCopy:
    ; Add newline at the end
    MOV AL, 13
    MOV [DI], AL
    INC DI
    MOV AL, 10
    MOV [DI], AL
    INC DI
    
    ; Calculate record length
    LEA AX, bookRecord
    SUB DI, AX        ; DI - bookRecord = record length
    MOV CX, DI        ; CX = record length
    
    ; Append to books file
    CALL AppendBookToFile
    CMP AL, 0         ; AL = 0 if failed
    JE AddBookFailed
    
    ; Success message
    LEA DX, addSuccessMsg
    CALL DisplayString
    JMP AddBookDone
    
AddBookFailed:
    ; Failure message
    LEA DX, addFailMsg
    CALL DisplayString
    
AddBookDone:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
AddBook ENDP

; Procedure: ViewBooks
; Displays all books in the system
ViewBooks PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    CALL ClearScreen
    
    ; Display view books header
    LEA DX, viewBooksHeader
    CALL DisplayString
    
    ; Open books file for reading
    LEA DX, bookFile
    CALL OpenFileRead
    CMP AX, 0         ; AX = 0 if failed
    JE NoBooks
    
    MOV fileHandle, AX  ; Store file handle
    
    ; Read and display books
    MOV BX, 0         ; Book counter
    
ReadNextBook:
    CALL ReadBookRecord
    CMP AX, 0         ; AX = 0 if EOF or error
    JE FinishReading
    
    ; Increment book counter
    INC BX
    
    ; Parse and display book fields
    CALL DisplayBookRecord
    JMP ReadNextBook
    
FinishReading:
    ; Close file
    MOV BX, fileHandle
    CALL CloseFile
    
    ; Check if no books were displayed
    CMP BX, 0
    JE NoBooks
    JMP ViewBooksDone
    
NoBooks:
    ; Display no books message
    LEA DX, noBooksMsg
    CALL DisplayString
    
ViewBooksDone:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
ViewBooks ENDP

; Procedure: AppendBookToFile
; Appends a book record to the books file
; Input: bookRecord = record to append, CX = record length
; Output: AL = 1 (success) or 0 (failure)
AppendBookToFile PROC
    PUSH BX
    PUSH DX
    
    ; Try to open file for append
    LEA DX, bookFile
    CALL OpenFileAppend
    
    ; If file doesn't exist, create it
    CMP AX, 0
    JNE FileOpenedForAppend
    
    ; Create file
    LEA DX, bookFile
    CALL CreateFile
    CMP AX, 0
    JE AppendBookFail  ; Failed to create
    
FileOpenedForAppend:
    MOV fileHandle, AX  ; Store file handle
    
    ; Write record to file
    MOV BX, fileHandle
    LEA DX, bookRecord
    ; CX already contains record length
    CALL WriteFile
    CMP AX, 0
    JE AppendBookFail
    
    ; Close file
    MOV BX, fileHandle
    CALL CloseFile
    
    ; Success
    MOV AL, 1
    JMP AppendBookDone
    
AppendBookFail:
    ; If file was opened, close it
    CMP fileHandle, 0
    JE SkipClose
    MOV BX, fileHandle
    CALL CloseFile
    
SkipClose:
    ; Failure
    MOV AL, 0
    
AppendBookDone:
    POP DX
    POP BX
    RET
AppendBookToFile ENDP

; Procedure: ReadBookRecord
; Reads a book record from the file
; Input: fileHandle = open file handle
; Output: AX = bytes read (0 if EOF or error)
ReadBookRecord PROC
    PUSH BX
    PUSH CX
    PUSH DX
    
    ; Read a line from the file
    MOV BX, fileHandle
    LEA DX, bookRecord
    MOV CX, bookRecordSize
    
    ; Initialize buffer
    PUSH AX
    PUSH DI
    LEA DI, bookRecord
    XOR AL, AL        ; Fill with zeros
    REP STOSB
    POP DI
    POP AX
    
    ; Read from file
    MOV AH, 3Fh       ; DOS function: Read from file
    INT 21h
    
    ; Check for EOF
    CMP AX, 0
    JE ReadBookRecordDone
    
    ; Record is incomplete if we didn't find a newline
    ; This is a simplified approach - in a real system, we'd need more robust parsing
    
ReadBookRecordDone:
    POP DX
    POP CX
    POP BX
    RET
ReadBookRecord ENDP

; Procedure: DisplayBookRecord
; Displays a book record in formatted form
; Input: bookRecord = record to display
DisplayBookRecord PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    
    ; Parse the record (Title|Author|ISBN)
    LEA SI, bookRecord
    LEA DI, displayBuffer
    
    ; Extract title
    XOR CX, CX        ; Character counter
    
ExtractTitle:
    MOV AL, [SI]
    CMP AL, '|'       ; Check for field separator
    JE EndTitle
    CMP AL, 0         ; Check for end of string
    JE EndBookDisplay
    
    ; Copy character
    MOV [DI], AL
    INC SI
    INC DI
    INC CX
    JMP ExtractTitle
    
EndTitle:
    ; Add null terminator to title
    MOV BYTE PTR [DI], 0
    INC SI            ; Skip separator
    
    ; Display title
    LEA DX, displayBuffer
    CALL DisplayTitleLine
    
    ; Extract author
    LEA DI, displayBuffer
    XOR CX, CX        ; Reset counter
    
ExtractAuthor:
    MOV AL, [SI]
    CMP AL, '|'       ; Check for field separator
    JE EndAuthor
    CMP AL, 0         ; Check for end of string
    JE EndBookDisplay
    
    ; Copy character
    MOV [DI], AL
    INC SI
    INC DI
    INC CX
    JMP ExtractAuthor
    
EndAuthor:
    ; Add null terminator to author
    MOV BYTE PTR [DI], 0
    INC SI            ; Skip separator
    
    ; Display author
    LEA DX, displayBuffer
    CALL DisplayAuthorLine
    
    ; Extract ISBN (everything until newline or end)
    LEA DI, displayBuffer
    XOR CX, CX        ; Reset counter
    
ExtractIsbn:
    MOV AL, [SI]
    CMP AL, 13        ; Check for CR
    JE EndIsbn
    CMP AL, 10        ; Check for LF
    JE EndIsbn
    CMP AL, 0         ; Check for end of string
    JE EndIsbn
    
    ; Copy character
    MOV [DI], AL
    INC SI
    INC DI
    INC CX
    JMP ExtractIsbn
    
EndIsbn:
    ; Add null terminator to ISBN
    MOV BYTE PTR [DI], 0
    
    ; Display ISBN
    LEA DX, displayBuffer
    CALL DisplayIsbnLine
    
    ; Display separator line
    LEA DX, newLine
    CALL DisplayString
    
EndBookDisplay:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DisplayBookRecord ENDP

; Procedure: DisplayTitleLine
; Displays "Title: [title]"
; Input: DX = pointer to title string
DisplayTitleLine PROC
    PUSH AX
    
    ; Display "Title: " prefix
    PUSH DX
    LEA DX, BYTE PTR [offset bookDisplayFmt]
    CALL DisplayString
    POP DX
    
    ; Display the title
    MOV AH, 9
    INT 21h
    
    POP AX
    RET
DisplayTitleLine ENDP

; Procedure: DisplayAuthorLine
; Displays "Author: [author]"
; Input: DX = pointer to author string
DisplayAuthorLine PROC
    PUSH AX
    
    ; Display "Author: " prefix
    PUSH DX
    LEA DX, BYTE PTR [offset bookDisplayFmt + 18]  ; Skip "Title: %s", 13, 10
    CALL DisplayString
    POP DX
    
    ; Display the author
    MOV AH, 9
    INT 21h
    
    POP AX
    RET
DisplayAuthorLine ENDP

; Procedure: DisplayIsbnLine
; Displays "ISBN: [isbn]"
; Input: DX = pointer to ISBN string
DisplayIsbnLine PROC
    PUSH AX
    
    ; Display "ISBN: " prefix
    PUSH DX
    LEA DX, BYTE PTR [offset bookDisplayFmt + 37]  ; Skip "Title: %s", 13, 10, "Author: %s", 13, 10
    CALL DisplayString
    POP DX
    
    ; Display the ISBN
    MOV AH, 9
    INT 21h
    
    POP AX
    RET
DisplayIsbnLine ENDP

; Procedure: ValidateAdminCredentials
; Validates admin username and password
; Output: AL = 1 if valid, 0 if invalid
ValidateAdminCredentials PROC
    PUSH SI
    PUSH DI
    PUSH CX
    
    ; Convert entered username to $ terminated string for comparison
    LEA SI, usernameBuffer + 2  ; Skip size bytes
    MOV CL, usernameBuffer + 1  ; Get actual length
    XOR CH, CH
    
    ; Prepare for username comparison
    LEA DI, adminUsername
    CALL CompareStrings
    CMP AL, 1                   ; AL = 1 if strings match
    JNE InvalidAdminCredentials
    
    ; Convert entered password to $ terminated string for comparison
    LEA SI, passwordBuffer + 2  ; Skip size bytes
    MOV CL, passwordBuffer + 1  ; Get actual length
    XOR CH, CH
    
    ; Prepare for password comparison
    LEA DI, adminPassword
    CALL CompareStrings
    CMP AL, 1                   ; AL = 1 if strings match
    JNE InvalidAdminCredentials
    
    ; Both username and password match
    MOV AL, 1
    JMP ValidateAdminDone
    
InvalidAdminCredentials:
    MOV AL, 0
    
ValidateAdminDone:
    POP CX
    POP DI
    POP SI
    RET
ValidateAdminCredentials ENDP

; Procedure: ValidateUserCredentials
; Validates user username and password
; Output: AL = 1 if valid, 0 if invalid
ValidateUserCredentials PROC
    PUSH SI
    PUSH DI
    PUSH CX
    
    ; Convert entered username to $ terminated string for comparison
    LEA SI, usernameBuffer + 2  ; Skip size bytes
    MOV CL, usernameBuffer + 1  ; Get actual length
    XOR CH, CH
    
    ; Prepare for username comparison
    LEA DI, userUsername
    CALL CompareStrings
    CMP AL, 1                   ; AL = 1 if strings match
    JNE InvalidUserCredentials
    
    ; Convert entered password to $ terminated string for comparison
    LEA SI, passwordBuffer + 2  ; Skip size bytes
    MOV CL, passwordBuffer + 1  ; Get actual length
    XOR CH, CH
    
    ; Prepare for password comparison
    LEA DI, userPassword
    CALL CompareStrings
    CMP AL, 1                   ; AL = 1 if strings match
    JNE InvalidUserCredentials
    
    ; Both username and password match
    MOV AL, 1
    JMP ValidateUserDone
    
InvalidUserCredentials:
    MOV AL, 0
    
ValidateUserDone:
    POP CX
    POP DI
    POP SI
    RET
ValidateUserCredentials ENDP

; Procedure: CompareStrings
; Compares input string with target $ terminated string
; Input: SI = input string, CX = input length, DI = target string with $ terminator
; Output: AL = 1 if match, 0 if not
CompareStrings PROC
    PUSH SI
    PUSH DI
    PUSH CX
    PUSH BX
    
    MOV BX, CX      ; Save original length
    
CompareLoop:
    ; Get characters
    MOV AL, [SI]
    MOV AH, [DI]
    
    ; Check if target string ended
    CMP AH, '$'
    JE CheckInputEnd
    
    ; Compare characters
    CMP AL, AH
    JNE NotEqual
    
    ; Move to next character
    INC SI
    INC DI
    LOOP CompareLoop
    
    ; Check if target string ended exactly here
    CMP BYTE PTR [DI], '$'
    JNE NotEqual
    
    ; Both strings match
    MOV AL, 1
    JMP CompareStringsDone
    
CheckInputEnd:
    ; Check if input string is at its end (CX = 0)
    CMP CX, 0
    JNE NotEqual
    
    ; Both strings ended at the same time = match
    MOV AL, 1
    JMP CompareStringsDone
    
NotEqual:
    MOV AL, 0
    
CompareStringsDone:
    POP BX
    POP CX
    POP DI
    POP SI
    RET
CompareStrings ENDP

; Procedure: DisplayString
; Displays a $ terminated string
; Input: DX = pointer to string
DisplayString PROC
    PUSH AX
    
    MOV AH, 9        ; DOS function: Print string
    INT 21h
    
    POP AX
    RET
DisplayString ENDP

; Procedure: GetStringInput
; Gets string input from user
; Input: DX = pointer to buffer (first byte = max length, second byte will get actual length)
GetStringInput PROC
    PUSH AX
    
    MOV AH, 0Ah      ; DOS function: Buffered keyboard input
    INT 21h
    
    ; Add newline after input
    PUSH DX
    LEA DX, newLine
    CALL DisplayString
    POP DX
    
    POP AX
    RET
GetStringInput ENDP

; Procedure: GetCharInput
; Gets a single character input from user and echoes it
; Output: AL = character
GetCharInput PROC
    MOV AH, 1        ; DOS function: Read character with echo
    INT 21h
    
    ; Add newline after input
    PUSH AX
    LEA DX, newLine
    CALL DisplayString
    POP AX
    
    RET
GetCharInput ENDP

; Procedure: GetCharInputNoEcho
; Gets a single character input from user without echo
; Output: AL = character
GetCharInputNoEcho PROC
    MOV AH, 8        ; DOS function: Read character without echo
    INT 21h
    RET
GetCharInputNoEcho ENDP

; Procedure: ClearScreen
; Clears the screen using scroll window function
ClearScreen PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV AH, 6        ; Scroll window up function
    MOV AL, 0        ; Clear entire window
    MOV BH, 7        ; Normal attribute (white on black)
    MOV CX, 0        ; Upper left corner (0,0)
    MOV DH, 24       ; Lower right corner row (24)
    MOV DL, 79       ; Lower right corner column (79)
    INT 10h
    
    ; Set cursor to top-left (0,0)
    MOV AH, 2        ; Set cursor position
    MOV BH, 0        ; Page number
    MOV DH, 0        ; Row
    MOV DL, 0        ; Column
    INT 10h
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
ClearScreen ENDP

; Procedure: OpenFileRead
; Opens a file for reading
; Input: DX = pointer to filename (ASCIIZ)
; Output: AX = file handle or 0 if failed
OpenFileRead PROC
    MOV AH, 3Dh      ; DOS function: Open file
    MOV AL, 0        ; 0 = read access
    INT 21h
    JC OpenFileReadFail
    RET
    
OpenFileReadFail:
    XOR AX, AX       ; Return 0 on failure
    RET
OpenFileRead ENDP

; Procedure: OpenFileAppend
; Opens a file for appending (read/write, position at EOF)
; Input: DX = pointer to filename (ASCIIZ)
; Output: AX = file handle or 0 if failed
OpenFileAppend PROC
    MOV AH, 3Dh      ; DOS function: Open file
    MOV AL, 2        ; 2 = read/write access
    INT 21h
    JC OpenFileAppendFail
    
    ; Seek to end of file
    PUSH BX
    MOV BX, AX       ; BX = file handle
    MOV AH, 42h      ; DOS function: Seek
    MOV AL, 2        ; 2 = seek from EOF
    XOR CX, CX       ; Offset = 0 (CX:DX)
    XOR DX, DX
    INT 21h
    POP BX
    
    RET
    
OpenFileAppendFail:
    XOR AX, AX       ; Return 0 on failure
    RET
OpenFileAppend ENDP

; Procedure: CreateFile
; Creates a new file for writing
; Input: DX = pointer to filename (ASCIIZ)
; Output: AX = file handle or 0 if failed
CreateFile PROC
    MOV AH, 3Ch      ; DOS function: Create file
    XOR CX, CX       ; Normal file attribute
    INT 21h
    JC CreateFileFail
    RET
    
CreateFileFail:
    XOR AX, AX       ; Return 0 on failure
    RET
CreateFile ENDP

; Procedure: WriteFile
; Writes data to a file
; Input: BX = file handle, DX = pointer to data, CX = bytes to write
; Output: AX = bytes written or 0 if failed
WriteFile PROC
    MOV AH, 40h      ; DOS function: Write to file
    INT 21h
    JC WriteFileFail
    RET
    
WriteFileFail:
    XOR AX, AX       ; Return 0 on failure
    RET
WriteFile ENDP

; Procedure: CloseFile
; Closes a file
; Input: BX = file handle
CloseFile PROC
    MOV AH, 3Eh      ; DOS function: Close file
    INT 21h
    RET
CloseFile ENDP

END MAIN