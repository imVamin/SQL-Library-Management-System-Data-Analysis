--Create table "Branch"--

drop table if exists branch;

create table branch
(	
	branch_id varchar(10) primary key,
	manager_id varchar(10),
	branch_address varchar(100),
	contact_no varchar(15)
);


--Create table "Employees"--

DROP TABLE IF EXISTS employees;

CREATE TABLE employees
(
	emp_id VARCHAR(10) PRIMARY KEY,
	emp_name VARCHAR(30),
	position VARCHAR(30),
	salary int,
	branch_id VARCHAR(10),
	FOREIGN KEY (branch_id)
	REFERENCES branch(branch_id)
);


--Create table "Books"--

DROP TABLE IF EXISTS books;

CREATE TABLE books
(
	isbn VARCHAR(50) PRIMARY KEY,
	book_title VARCHAR(80),
	category VARCHAR(30),
	rental_price DECIMAL(10,2),
	status VARCHAR(10),
	author VARCHAR(30),
	publisher VARCHAR(30)
);


--Create table "Members"--

DROP TABLE IF EXISTS members;

CREATE TABLE members
(
	member_id VARCHAR(10) PRIMARY KEY,
	member_name VARCHAR(30),
	member_address VARCHAR(30),
	reg_date DATE
);


--Create table "IssueStatus"--

DROP TABLE IF EXISTS issued_status;

CREATE TABLE issued_status
(
	issued_id VARCHAR(10) PRIMARY KEY,
	issued_member_id VARCHAR(30),
	issued_book_name VARCHAR(80),
	issued_date DATE,
	issued_book_isbn VARCHAR(50),
	issued_emp_id VARCHAR(10),
	FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
	FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
	FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);


--Create table "ReturnStatus"--

DROP TABLE IF EXISTS return_status;

CREATE TABLE return_status
(
	return_id VARCHAR(10) PRIMARY KEY,
	issued_id VARCHAR(30),
	return_book_name VARCHAR(80),
	return_date DATE,
	return_book_isbn VARCHAR(50),
	FOREIGN KEY (return_book_isbn)
	REFERENCES books(isbn)
);


--Data Cleaning and Analysis--

--Create a New Book Record--

INSERT INTO books
(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');


--Update an Existing Member's Address--

UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';


--Delete a Record from the Issued Status Table--

DELETE FROM issued_status
WHERE   issued_id =   'IS121';


--Retrieve All Books Issued by a Specific Employee--

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'


--List Members Who Have Issued More Than One Book--

SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1


--Create Summary Tables: Used CTAS to generate new tables based on query results--

CREATE TABLE book_issued_cnt
AS
SELECT 
		b.isbn,
		b.book_title,
		COUNT(ist.issued_id)
		AS issue_count
FROM issued_status
as ist
JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;


--Retrieve All Books in a Specific Category--

SELECT * FROM books
WHERE category = 'Classic';


--Find Total Rental Income by Category--

SELECT 
    b.category,
    SUM(b.rental_price),
    COUNT(*)
FROM 
issued_status as ist
JOIN
books as b
ON b.isbn = ist.issued_book_isbn
GROUP BY 1;


--List of Members Who Registered in the Last 180 Days--

SELECT *
FROM members
WHERE reg_date >= DATE '2021-06-20' - INTERVAL '180 days';


--List Employees with Their Branch Manager's Name and their branch details--

SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name as manager
FROM employees as e1
JOIN 
branch as b
ON e1.branch_id = b.branch_id    
JOIN
employees as e2
ON e2.emp_id = b.manager_id;


--Find which books are the most popular among readers--

SELECT 
    b.book_title,
    COUNT(ist.issued_id) AS total_issues
FROM issued_status AS ist
JOIN books AS b 
    ON ist.issued_book_isbn = b.isbn
GROUP BY b.book_title
ORDER BY total_issues DESC
LIMIT 5;


--Create a Table of Books with Rental Price Above a Certain Threshold--

CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;


--Retrieve the List of Books Not Yet Returned--

SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;


--Identify Members with Overdue Books--

SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    -- rs.return_date,
    CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist
JOIN 
members as m
    ON m.member_id = ist.issued_member_id
JOIN 
books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1;


--Calculate how long members usually take to return books.--

SELECT 
    m.member_name,
    ROUND(AVG(rs.return_date - ist.issued_date), 2) AS avg_days_to_return
FROM issued_status AS ist
JOIN return_status AS rs 
    ON ist.issued_id = rs.issued_id
JOIN members AS m 
    ON m.member_id = ist.issued_member_id
GROUP BY m.member_name
ORDER BY avg_days_to_return DESC;


--Compare revenue across branches to see which performs best--

SELECT 
    b.branch_id,
    COUNT(ist.issued_id) AS books_issued,
    SUM(bk.rental_price) AS total_revenue
FROM issued_status ist
JOIN employees e ON ist.issued_emp_id = e.emp_id
JOIN branch b ON e.branch_id = b.branch_id
JOIN books bk ON bk.isbn = ist.issued_book_isbn
GROUP BY b.branch_id
ORDER BY total_revenue DESC;


--Find which categories generate the most total revenue.--

SELECT 
    b.category,
    COUNT(ist.issued_id) AS total_issues,
    SUM(b.rental_price) AS total_income
FROM issued_status ist
JOIN books b ON b.isbn = ist.issued_book_isbn
GROUP BY b.category
ORDER BY total_income DESC;


--Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals--

CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) 
		as number_book_issued,
    COUNT(rs.return_id) 
		as number_of_book_return,
    SUM(bk.rental_price) 
		as total_revenue
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
GROUP BY 1, 2;


--See which categories have the highest average rental value.--

SELECT 
    category,
    ROUND(AVG(rental_price), 2) AS avg_rental_price
FROM books
GROUP BY category
ORDER BY avg_rental_price DESC;


--Find books that are available but have never been issued--

SELECT 
    b.isbn,
    b.book_title,
    b.category
FROM books AS b
LEFT JOIN issued_status AS ist 
    ON b.isbn = ist.issued_book_isbn
WHERE ist.issued_id IS NULL;


--Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months--

drop TABLE if exists active_members;

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN 
			(
			SELECT 
            DISTINCT issued_member_id   
            FROM issued_status
            WHERE 
            issued_date >= CURRENT_DATE - INTERVAL '24 month'
			);


--Find Employees with the Most Book Issues Processed--

SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) as no_book_issued
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1, 2
order by no_book_issued desc; 
