# Project Requirement Document: Simple Library System (8086 Assembly)

**Version:** 1.0
**Date:** 2025-04-11

## 1. Introduction

### 1.1 Purpose
This document outlines the requirements for a basic, text-based library management system. The system will allow administrators to manage a simple book database and users to view the available books.

### 1.2 Scope
The project includes the following core functionalities:
* Admin login and logout.
* User login and logout.
* Admin ability to add book records.
* Basic session management to differentiate user types and states.
* User ability to view the list of books.
* Admin ability to view the list of books.

**Out of Scope:**
* Graphical User Interface (GUI).
* User registration (Users/Admins are assumed to be pre-defined).
* Book borrowing, returning, or availability status.
* Deleting or editing existing book records.
* Advanced search or filtering capabilities.
* Complex data validation.
* Password encryption (due to 8086 limitations, passwords might be stored plainly or via simple obfuscation).
* Concurrency control (designed for single-user access at a time).

### 1.3 Goals
* To create a functional proof-of-concept library system within the constraints of 8086 assembly.
* To provide distinct interfaces and capabilities for Admin and regular User roles.
* To implement basic data persistence for book records (e.g., writing to a simple file).

## 2. Target Audience
* **Administrators:** Responsible for logging in and adding new books to the system.
* **Users:** Responsible for logging in and viewing the list of books available in the library.

## 3. Functional Requirements

### FR-01: Admin Login
* **Description:** The system shall provide a mechanism for an administrator to log in.
* **Details:**
    * The system shall prompt for an Admin username and password.
    * The system shall validate the entered credentials against pre-defined admin credentials.
    * Upon successful validation, the system shall grant access to Admin-specific functions and enter an "Admin Session" state.
    * Upon failed validation, the system shall display an error message and deny access.
* **Input:** Admin Username, Admin Password.
* **Output:** Success/Failure message, Access to Admin menu/functions.

### FR-02: Admin Logout
* **Description:** The system shall allow a logged-in administrator to log out.
* **Details:**
    * An option shall be available in the Admin menu/interface to log out.
    * Selecting logout shall terminate the "Admin Session" state.
    * The system shall return to the initial login prompt or exit.
* **Precondition:** Admin must be logged in.
* **Output:** Return to login screen or program termination.

### FR-03: User Login
* **Description:** The system shall provide a mechanism for a standard user to log in.
* **Details:**
    * The system shall prompt for a User username and password.
    * The system shall validate the entered credentials against pre-defined user credentials.
    * Upon successful validation, the system shall grant access to User-specific functions and enter a "User Session" state.
    * Upon failed validation, the system shall display an error message and deny access.
* **Input:** User Username, User Password.
* **Output:** Success/Failure message, Access to User menu/functions.

### FR-04: User Logout
* **Description:** The system shall allow a logged-in user to log out.
* **Details:**
    * An option shall be available in the User menu/interface to log out.
    * Selecting logout shall terminate the "User Session" state.
    * The system shall return to the initial login prompt or exit.
* **Precondition:** User must be logged in.
* **Output:** Return to login screen or program termination.

### FR-05: Admin Add Book
* **Description:** The system shall allow a logged-in administrator to add new book records to the library database.
* **Details:**
    * The system shall prompt the admin to enter book details (e.g., Title, Author, ISBN).
    * Input validation will be minimal (e.g., ensuring some text is entered).
    * The entered book details shall be appended to the book data storage (e.g., a data file).
    * The system shall provide feedback on successful addition or failure (e.g., disk full, if applicable).
* **Precondition:** Admin must be logged in.
* **Input:** Book Title, Book Author, Book ISBN (Specific fields and lengths TBD based on data storage approach).
* **Output:** Confirmation/Error message.

### FR-06: Session Management
* **Description:** The system must maintain the state of the current user (Not Logged In, Logged In as User, Logged In as Admin) and control access to functions accordingly.
* **Details:**
    * Access to "Admin Add Book" and "Admin View Books" shall be restricted to users in the "Admin Session" state.
    * Access to "User View Books" shall be restricted to users in the "User Session" state.
    * The system shall use a simple mechanism (e.g., a flag or state variable in memory) to track the current session state.

### FR-07: User View Books
* **Description:** The system shall allow a logged-in user to view the list of all books in the library database.
* **Details:**
    * The system shall read the book records from the data storage.
    * The system shall display the details (e.g., Title, Author, ISBN) of each book in a list format on the console.
    * Display might need pagination if the list exceeds screen capacity.
* **Precondition:** User must be logged in.
* **Output:** Console display of book list.

### FR-08: Admin View Books
* **Description:** The system shall allow a logged-in admin to view the list of all books in the library database.
* **Details:**
    * Functionality is similar to FR-07.
    * The system shall read the book records from the data storage.
    * The system shall display the details (e.g., Title, Author, ISBN) of each book in a list format on the console.
* **Precondition:** Admin must be logged in.
* **Output:** Console display of book list.

## 4. Non-Functional Requirements

### NFR-01: Performance
* **Description:** System responses for login, logout, viewing books, and adding books should be reasonably fast, without noticeable lag on the target 8086 environment (or emulator).

### NFR-02: Usability
* **Description:** The system shall provide clear text prompts for all inputs. Output messages (success, error) shall be clear and understandable. The interface will be command-line based.

### NFR-03: Reliability
* **Description:** The system should operate without crashing during expected user interactions. Data storage operations should handle basic file I/O reliably (within OS/emulator limits).

### NFR-04: Security
* **Description:** Access control based on login status (Admin/User) must be enforced. (Note: Due to 8086 limitations, credential storage will be very basic and not cryptographically secure).

### NFR-05: Maintainability
* **Description:** Assembly code should be commented appropriately to explain logic, memory usage, and interrupt calls. Use of labels and procedures should structure the code logically.

## 5. Constraints

### C-01: Implementation Language
* **Description:** The *entire* system must be implemented using **8086 assembly language**. This imposes significant limitations:
    * Manual memory management is required.
    * Limited standard libraries; reliance on BIOS/DOS interrupts (e.g., INT 21h for file I/O, console I/O).
    * Text-based user interface only.
    * Simple data structures (e.g., fixed-size arrays, records).
    * Basic file handling (sequential access likely easiest).
    * Rudimentary session management (flags/state variables).
    * Limited error handling capabilities.
    * Minimal security features.

### C-02: Operating Environment
* **Description:** The system is expected to run on an 8086-compatible environment, such as real hardware running DOS, or an emulator like DOSBox or EMU8086. Assumes standard BIOS/DOS interrupts are available.

### C-03: Data Storage
* **Description:** Book data and potentially user credentials must persist between program runs. This will likely be implemented using simple flat files (.txt, .dat) with fixed-length records or simple delimiters. Data capacity will be limited by available disk space and memory for processing.

## 6. Assumptions

* **A-01:** Pre-defined Credentials: At least one Admin and one User account credential (username/password) exist and are accessible by the program (e.g., hardcoded, stored in a simple config file). This PRD does not cover creating these initial credentials.
* **A-02:** Basic I/O: The target environment provides reliable console input/output and file input/output via system interrupts.
* **A-03:** Data Format: A specific, simple format for storing book data in a file will be defined during implementation (e.g., fixed-width fields for Title, Author, ISBN per line).

## 7. Future Enhancements (Optional)

* User Registration functionality.
* Ability to delete or modify existing book records.
* Implementation of book borrowing and returning status.
* Basic search functionality (e.g., search by title).
* More robust error handling and input validation.