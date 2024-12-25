-- SQL PROJECT LIBRARY MANAGEMENT SYSTEM QUERY 2
-- MAUZUM SHAMIL

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;


/*Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.*/

SELECT 
      ist.issued_member_id,
	  m.member_name,
	  b.book_title,
	  ist.issued_date,
	  CURRENT_DATE - ist.issued_date AS days_overdue
FROM issued_status as ist
JOIN members as m
    ON ist.issued_member_id = m.member_id
JOIN books as b
    ON b.isbn = ist.issued_book_isbn
LEFT JOIN return_status as rs
    ON ist.issued_id = rs.issued_id
WHERE rs.return_date IS NULL
AND (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1 ;


/*Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned
(based on entries in the return_status table).*/


SELECT * FROM books;
SELECT * FROM issued_status;

-- store procedures
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
       v_isbn VARCHAR(50);
	   v_book_name VARCHAR(75);
BEGIN 

	   INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
	   VALUES
	   (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

	   SELECT 
	         issued_book_isbn,
			 issued_book_name
			 INTO
			 v_isbn,
			 v_book_name
	   FROM issued_status
	   WHERE issued_id = p_issued_id;


	   UPDATE books
	   SET status = 'yes'
	   WHERE isbn = v_isbn;
	   
       RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
END;
$$

CALL add_return_records()


-- TESTING FUNCTIONS add_return_records()
SELECT *
FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT *
FROM issued_status
WHERE issued_id ='IS135';

SELECT *
FROM return_status
WHERE issued_id ='IS135';

SELECT *
FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

-- calling the function 

CALL add_return_records('RS138', 'IS135', 'Good');

-- calling the function 

CALL add_return_records('RS148','IS140', 'good');

/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, 
showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/


CREATE TABLE branch_reports
AS
SELECT 
      b.branch_id,
	  b.manager_id,
	  COUNT(rs.return_id) as total_books_returned,
	  SUM(bk.rental_price) as total_revenue,
	  COUNT(ist.issued_id) as total_books_issued	  
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN 
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN 
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1,2
ORDER BY 1;

SELECT * FROM branch_reports


-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members 
-- who have issued at least one book in the last 6 months.

CREATE TABLE active_members
AS 
SELECT *
FROM members
WHERE member_id IN
(
SELECT 
     DISTINCT ist.issued_member_id
FROM issued_status as ist
WHERE 
     ist.issued_date >= CURRENT_DATE - INTERVAL '6 month'
);

SELECT * FROM active_members

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. 
-- Display the employee name, number of books processed, and their branch.

SELECT 
      e.emp_name,
	  COUNT(ist.issued_id) AS number_of_books_processed,
	  e.branch_id
FROM issued_status as ist
JOIN employees as e
ON ist.issued_emp_id = e.emp_id
GROUP BY 1,3
ORDER BY 2 DESC
LIMIT 3;

/*
Task 19: Stored Procedure Objective: 
Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: 
The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/


SELECT * FROM books;
SELECT * FROM issued_status;

CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), 
p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE 
-- all the variable 
      v_status VARCHAR(10);
	  
BEGIN 
-- all the code
      --1-check book is avaialble 'yes'

	  SELECT 
	        status 
	        INTO
			v_status
	  FROM books
	  WHERE isbn = p_issued_book_isbn;

      IF v_status = 'yes' THEN 

	     INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
	     VALUES 
		 (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

		 UPDATE books
		     SET status = 'no'
		 WHERE isbn = p_issued_book_isbn;
		 
	     RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;
      
	  ELSE

		 RAISE NOTICE 'sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;

	  END IF;
END; 
$$


SELECT * FROM books;
--978-0-553-29698-2 -- yes
--978-0-375-41398-8 -- no
SELECT * FROM issued_status;

-- testing the procedure

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104')


-- testing the procedure 

CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104')


SELECT * 
FROM books
WHERE isbn = '978-0-553-29698-2' ;


/*Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've issued damaged books.*/

SELECT * FROM issued_status
SELECT * FROM return_status

UPDATE issued_status
SET issued_member_id = 'C110'
WHERE issued_id = 'IS118';

SELECT 
    m.member_name,
    COUNT(ist.issued_id) AS number_of_times_issued
FROM 
    return_status rs
JOIN 
    issued_status ist
ON 
    rs.issued_id = ist.issued_id
JOIN 
    members m
ON 
    ist.issued_member_id = m.member_id
WHERE 
    rs.book_quality = 'Damaged'
GROUP BY 
    m.member_name
HAVING 
    COUNT(ist.issued_id) >= 2;


/*Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. The number of books issued by each member. 
The resulting table should show: Member ID Number of overdue books Total fines*/


SELECT * FROM issued_status;
SELECT * FROM return_status

SELECT 
      ist.issued_member_id,
	  COUNT(issued_book_name) AS no_of_overdue_books,
	  return_date - issued_date * 0.50 AS Total_fines
FROM issued_status ist
JOIN return_status rs
ON rs.issued_id = ist.issued_id
GROUP BY 1

CREATE TABLE overdue_books_summary
AS
SELECT 
    ist.issued_member_id AS member_id,
    COUNT(CASE 
             WHEN CURRENT_DATE - ist.issued_date > 30 THEN ist.issued_id 
         END) AS no_of_overdue_books,
    SUM(CASE 
             WHEN CURRENT_DATE - ist.issued_date > 30 THEN (CURRENT_DATE - ist.issued_date - 30) * 0.50 
             ELSE 0 
         END) AS total_fines,
    COUNT(ist.issued_id) AS total_books_issued
FROM 
    issued_status ist
LEFT JOIN 
    return_status rs
ON 
    ist.issued_id = rs.issued_id
WHERE 
    rs.return_date IS NULL OR CURRENT_DATE - ist.issued_date > 30
GROUP BY 
    ist.issued_member_id;


SELECT * FROM overdue_books_summary;

-- END OF THE PROJECT LIBRARY SYSTEM MANAGEMENT 
-- BY MAUZUM SHAMIL 






