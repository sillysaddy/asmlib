# Simple Library Management System

## Overview
The Simple Library Management System is a text-based application developed in 8086 assembly language. It allows administrators to manage a basic book database and enables users to view available books. The system is designed to demonstrate fundamental programming concepts in assembly language while providing essential library functionalities.

## Project Structure
The project consists of the following files and directories:

- **Project.asm**: Contains the main assembly code implementing functionalities such as admin and user login, session management, adding books, and viewing the list of books. The code is organized into procedures for better modularity and clarity.

- **data/**: This directory holds data files used by the application.
  - **books.dat**: Stores book records in a simple flat file format. Each record includes details such as Title, Author, and ISBN.
  - **users.dat**: Contains predefined user credentials (username and password) for both admin and regular users, formatted for easy access and validation during login.

- **include/**: This directory contains reusable components.
  - **macros.inc**: Includes macros that simplify common tasks in the assembly code, such as input/output operations and string handling, promoting cleaner code by reducing repetition.

## Building and Running the Project
To build and run the Simple Library Management System, follow these steps:

1. **Setup Environment**: Ensure you have an 8086 assembly language environment set up, such as EMU8086 or a compatible emulator.

2. **Assemble the Code**: Open `Project.asm` in your assembly environment and assemble the code to generate the executable.

3. **Run the Executable**: Execute the generated program. Follow the on-screen prompts to log in as either an admin or a user.

## Functionalities
The system includes the following core functionalities:

- **Admin Login**: Admins can log in using predefined credentials to access admin-specific functions.
- **User Login**: Users can log in to view the list of available books.
- **Session Management**: The system maintains the state of the current user (Admin/User) and controls access to functions accordingly.
- **Add Book**: Logged-in admins can add new book records to the library database.
- **View Books**: Both admins and users can view the list of all books in the library.

## Future Enhancements
Potential future enhancements may include:
- User registration functionality.
- Ability to delete or modify existing book records.
- Implementation of book borrowing and returning status.
- Basic search functionality (e.g., search by title).
- More robust error handling and input validation.

## Conclusion
This project serves as a proof-of-concept for a simple library management system, showcasing the capabilities of 8086 assembly language in managing user sessions and data persistence.