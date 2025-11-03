# 📚 Library Management System SQL Project

## 🔗 Project Overview
This project is a **Library Management System** built entirely in SQL. It manages books, members, employees, branches, and the issuance and return of books. It also includes a variety of **data analysis queries** to gain insights into operations, performance, and trends.

---

## 🧱 Database Schema

### 🏢 1. Branch Table
Stores details about each library branch.
```sql
CREATE TABLE branch (
  branch_id VARCHAR(10) PRIMARY KEY,
  manager_id VARCHAR(10),
  branch_address VARCHAR(100),
  contact_no VARCHAR(15)
);
```

### 👨‍💼 2. Employees Table
Keeps employee details and their assigned branch.
```sql
CREATE TABLE employees (
  emp_id VARCHAR(10) PRIMARY KEY,
  emp_name VARCHAR(30),
  position VARCHAR(30),
  salary INT,
  branch_id VARCHAR(10),
  FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);
```

### 📘 3. Books Table
Stores book inventory and rental details.
```sql
CREATE TABLE books (
  isbn VARCHAR(50) PRIMARY KEY,
  book_title VARCHAR(80),
  category VARCHAR(30),
  rental_price DECIMAL(10,2),
  status VARCHAR(10),
  author VARCHAR(30),
  publisher VARCHAR(30)
);
```

### 🧑‍🤝‍🧑 4. Members Table
Holds data for registered library members.
```sql
CREATE TABLE members (
  member_id VARCHAR(10) PRIMARY KEY,
  member_name VARCHAR(30),
  member_address VARCHAR(30),
  reg_date DATE
);
```

### 📦 5. Issued Status Table
Tracks books issued to members by employees.
```sql
CREATE TABLE issued_status (
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
```

### 🔁 6. Return Status Table
Logs returned books and their dates.
```sql
CREATE TABLE return_status (
  return_id VARCHAR(10) PRIMARY KEY,
  issued_id VARCHAR(30),
  return_book_name VARCHAR(80),
  return_date DATE,
  return_book_isbn VARCHAR(50),
  FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);
```

---

## 🧹 Data Cleaning Operations
```sql
-- Insert a new book
INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Update member address
UPDATE members SET member_address = '125 Oak St' WHERE member_id = 'C103';

-- Delete record from issued status
DELETE FROM issued_status WHERE issued_id = 'IS121';
```

---

## 📊 Key Analytical Queries

### 1️⃣ Members with Multiple Book Issues
```sql
SELECT issued_emp_id, COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1;
```

### 2️⃣ Total Rental Income by Category
```sql
SELECT b.category, SUM(b.rental_price) AS total_income, COUNT(*) AS total_books
FROM issued_status ist
JOIN books b ON b.isbn = ist.issued_book_isbn
GROUP BY 1;
```

### 3️⃣ Overdue Books
```sql
SELECT m.member_name, bk.book_title, CURRENT_DATE - ist.issued_date AS overdue_days
FROM issued_status ist
JOIN members m ON m.member_id = ist.issued_member_id
JOIN books bk ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status rs ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS NULL AND (CURRENT_DATE - ist.issued_date) > 30;
```

### 4️⃣ Most Popular Books
```sql
SELECT b.book_title, COUNT(ist.issued_id) AS total_issues
FROM issued_status ist
JOIN books b ON ist.issued_book_isbn = b.isbn
GROUP BY b.book_title
ORDER BY total_issues DESC
LIMIT 5;
```

### 5️⃣ Branch Performance Summary
```sql
SELECT b.branch_id, b.manager_id,
       COUNT(ist.issued_id) AS total_books_issued,
       COUNT(rs.return_id) AS total_books_returned,
       SUM(bk.rental_price) AS total_revenue
FROM issued_status ist
JOIN employees e ON e.emp_id = ist.issued_emp_id
JOIN branch b ON e.branch_id = b.branch_id
LEFT JOIN return_status rs ON rs.issued_id = ist.issued_id
JOIN books bk ON ist.issued_book_isbn = bk.isbn
GROUP BY b.branch_id, b.manager_id;
```

---

## 🧠 Additional Analysis
| Analysis | Description |
|-----------|--------------|
| **Active Members** | Members who issued books recently |
| **Top Authors** | Authors with the most book issues |
| **Branch Revenue** | Total income and performance by branch |
| **Monthly Trends** | Number of issues each month |
| **Overdue Frequency** | Books that are often late |
| **Employee Efficiency** | Avg. time for book returns per employee |

---

## 🪄 CTAS Tables (Create Table As Select)
- `book_issued_cnt` — Count of issues per book  
- `expensive_books` — Books with price above threshold  
- `branch_reports` — Revenue & performance by branch  
- `active_members` — Members active in last 2 months  

---

## 📈 Business Insights
- Identify top-performing branches by revenue.
- Track the most issued books & popular authors.
- Analyze overdue patterns to improve policies.
- Evaluate employee performance by issue volume.
- Visualize monthly lending patterns for forecasting.

---

## 💻 Tech Stack
- **Database:** PostgreSQL / MySQL  
- **Tools:** pgAdmin / DBeaver  
- **Concepts:** Joins, Aggregates, Subqueries, CTEs, CTAS, Date & Interval functions  

---

## 🚀 Future Enhancements
- Add late-return fine calculations.
- Automate overdue reminders via triggers.
- Build a front-end dashboard (Power BI / Tableau).
- Create stored procedures for issue-return automation.

---

## ✍️ Author
**Name:** Virendra Amin  
**Focus:** SQL Projects, Data Analytics, and Business Intelligence  
**Goal:** Demonstrate SQL data modeling, analysis, and reporting skills.
