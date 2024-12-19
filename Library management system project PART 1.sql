-- Library management system project PART 1
-- by mauzum shamil

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

--PROJECT TASK 

--  CRUD Operations
-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')
SELECT * FROM books;

-- Task 2: Update an Existing Member's Address

UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
SELECT * FROM members;

-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

SELECT * FROM issued_status;

DELETE FROM issued_status
WHERE issued_id = 'IS121';


-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'

SELECT *
FROM issued_status
WHERE issued_emp_id = 'E101';


-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
      issued_emp_id,
	  COUNT(issued_id) AS total_book_issued
FROM issued_status
GROUP BY 1
HAVING COUNT(issued_id)>1;

-- CTAS (Create Table As Select)

-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results 
-- each book and total book_issued_cnt**


CREATE TABLE book_counts
AS
SELECT 
      b.isbn,
	  b.book_title,
	  COUNT(ist.issued_id) as No_issued
FROM books as b
JOIN issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1,2;

SELECT * FROM book_counts;

-- Data Analysis & Findings
-- The following SQL queries were used to address specific questions:

-- Task 7. Retrieve All Books in a Specific Category:

SELECT *
FROM books
WHERE category = 'History';


-- Task 8: Find Total Rental Income by Category:

SELECT 
      b.category,
	  COUNT(*),
	  SUM(b.rental_price) as total_rental_price
FROM books as b
JOIN issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1 
ORDER BY 2 DESC;


-- TASK 9: List Members Who Registered in the Last 180 Days:


INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('C117','mauzum','124 bkr st', '2024-12-18'),
('C120', 'amal', '125 bkr st', '2024-12-17')

SELECT * 
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

SELECT CURRENT_DATE

-- TASK 10: List Employees with Their Branch Manager's Name and their branch details:

SELECT 
       e1.emp_id,
       e1.emp_name,
	   e1.position,
	   e1.salary,
	   b.*,
	   e2.emp_name as manager	   	   
FROM employees as e1
JOIN branch as b
ON b.branch_id = e1.branch_id
JOIN employees as e2
ON e2.emp_id = b.manager_id


-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD:

CREATE TABLE books_price_greater_than_seven
AS
SELECT * 
FROM books
WHERE rental_price > 7;

SELECT * FROM books_price_greater_than_seven;

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT 
      ist.issued_book_name
FROM issued_status as ist
LEFT JOIN return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL 


--- END OF THE PROJECT PART 1 --





