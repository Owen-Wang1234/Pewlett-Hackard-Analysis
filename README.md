# Pewlett-Hackard-Analysis

## Project Overview

A large long-running company requested an analysis of the internal employee database to plan for future retirements. The company particularly wants to know how many employees will be retiring soon and how many positions will need to be filled as a result.

## Resources

### Data Sources:

1. departments.csv
2. dept_emp.csv
3. dept_manager.csv
4. employees.csv
5. salaries.csv
6. titles.csv

### Software:

1. pgAdmin 4 6.12
2. PostgreSQL 14.5

## Data Processing

After a cursory glance through each CSV file provided, an Entity Relationship Diagram (ERD) is sketched to map all the files and how they relate to each other. The Conceptual, Logical, and Physical layers are stacked respectively to form the map below:

![The ERD of the company database in this project](https://github.com/Owen-Wang1234/Pewlett-Hackard-Analysis/blob/main/EmployeeDB.png)

There are six tables are Departments, Employees, Managers, Dept_Emp, Salaries, and Titles. The key icons point out that the primary keys in all the tables are the department number (dept_no) and the employee number (emp_no); Departments and Employees hold the unique identifiers for departments and employees respectively (there should be no null or duplicate values), so the other tables will have a many-to-one relationship with these two based on those parameters. One thing to note is that the Titles table sets the emp_no as a foreign key, but not as a primary key because there are repetitions of some values, violating the constraints of the primary key.

A new database is created, and the `schema` script in the Queries folder creates the tables with their columns, sets the parameters (whether the column is some sort of key, what type of data goes into each column, etc.), and determines which keys are foreign keys referencing the primary keys of another table. With the tables ready, all the data are imported from the CSV files into the proper tables.

With the database ready, a battery of SQL queries was conducted to analyze the data. The queries were logged in the `queries` script, and the results were exported into CSV files which were included in the Data folder. The first queries looked for employees who are approaching retirement age (born between 1952 and 1955) and are eligible (hired between 1985 and 1988). Another round of queries linked these employees to their departments and sought out only those still currently employed.

- Export 1: retirement_info.csv
- Export 2: current_emp.csv

The next set of queries counts up these employees by department, tabulates the employee information (containing the full name, number, gender, and salary), lists the current department managers, and lists out the current employees with their corresponding departments.

- Export 3: emp_by_dept.csv
- Export 4: emp_info.csv
- Export 5: manager_info.csv
- Export 6: dept_info.csv

One more query creates a table holding the employee info for the Sales and Development departments at their request.

- Export 7: sales_dev_emp.csv

One last group of queries was carried out for the Module 7 Challenge and is recorded in the `Employee_Database_challenge` script. They list out the employees eligible for retirement with their job titles, filter to only include those still currently with the company, count up the those employees by job title, and then list out the employees eligible for the new mentorship program (currently with the company and born in the year 1965).

- Deliverable 1:

	1. retirement titles.csv
	2. unique_titles.csv
	3. retiring_titles.csv

- Deliverable 2: mentorship_eligibility.csv

## Results

Looking at the exported CSV files in the Challenge Deliverables, some incredible observations stand out:

1. The top two job titles in potential retirement numbers are "Senior Engineer" (25,916) and "Senior Staff" (24,926), which could result in a potentially severe talent gap unless promotions and hires fill in for the departing senior ranks.

2. There are only two managers that are eligible for retirement, but considering how few managers are in the company, losing any can bring serious ramifications if there is no replacement ready.

3. Given the conditions for eligibility for retirement (born between 1952 and 1955 and then hired between 1985 and 1988) as well as the progression of titles, the fact that there are 7,636 Staff and 1,090 Assistant Engineers among the numbers brings alarming implications about how these employees remained at these ranks for almost their entire career duration.

4. Looking at the Deliverable 2 CSV file, a good number of the staff eligible for mentorship are in more experienced ranks (Engineer, Senior Engineer, Senior Staff, and Technique Leader), but there are some that are not senior rank, although they may aid in mentorship with new hires.

## Summary

As Deliverable 1 shows, if every employee eligible for retirement chooses to retire the company will lose:

| Job Title | Employees |
| --- | ---: |
| Senior Engineer | 25,916 |
| Senior Staff | 24,926 |
| Engineer | 9,285 |
| Staff	| 7,636 |
| Technique Leader | 3,603 |
| Assistant Engineer | 1,090 |
| Manager | 2 |
| **TOTAL** | **72,458** |

One count query of employees still currently employed with the company yields a count of 240,124, so that means *almost **30%** of the currently active workforce is eligible for retirement*.

As the query for Deliverable 2 was set up for outputting into a new table, a quick side query afterwards to count up the numbers showed this:

| Job Title | Employees |
| --- | ---: |
| Assistant Engineer | 78 |
| Engineer | 501 |
| Senior Engineer | 169 |
| Senior Staff	| 568 |
| Staff | 156 |
| Technique Leader | 77 |
| **TOTAL** | **1,549** |

The mentorship eligibility count showed that more than 500 are in the Engineering and Senior Staff roles each with more than 150 in the Senior Engineering and Staff roles with the rest in the Assistant Engineer and Technique Leader roles; none of the managers are eligible for mentorship. Considering that **up to 72,458 employees** may retire, it is very unlikely that the number of eligible mentors will be anywhere near sufficient *even if every employee eligible for mentorship **agrees** to become a mentor*.

These three queries (included in the `extra_queries` script) examine the workforce distribution and retirement-ready percentage by department and by job title and the distribution of job titles across the departments:

```
-- See the distribution of retirement-ready employees across departments.
SELECT d.dept_name AS "Department",
	d.dept_no AS "Dept. No.",
	COUNT(e.emp_no) AS "Active Employees",
	COUNT(ce.emp_no) AS "Retirement-Ready Employees",
	ROUND((COUNT(ce.emp_no) * 1.00/COUNT(e.emp_no) * 100), 2) AS "Retirement-Ready Percentage"
INTO dept_dist
FROM employees AS e
	FULL OUTER JOIN current_emp AS ce
		ON (e.emp_no = ce.emp_no)
	INNER JOIN dept_emp AS de
		ON (e.emp_no = de.emp_no)
	INNER JOIN departments AS d
		ON (de.dept_no = d.dept_no)
WHERE (de.to_date = '9999-01-01')
GROUP BY d.dept_no
ORDER BY d.dept_no ASC;

-- See the distribution of retirement-ready employees across job titles.
SELECT ti.title AS "Job Title",
	COUNT(e.emp_no) AS "Active Employees",
	COUNT(ut.emp_no) AS "Retirement-Ready Employees",
	ROUND((COUNT(ut.emp_no) * 1.00/COUNT(e.emp_no) * 100), 2) AS "Retirement-Ready Percentage"
INTO title_dist
FROM employees AS e
	INNER JOIN titles AS ti
		ON (e.emp_no = ti.emp_no)
	FULL OUTER JOIN unique_titles AS ut
		ON (e.emp_no = ut.emp_no)
WHERE (ti.to_date = '9999-01-01')
GROUP BY ti.title
ORDER BY COUNT(e.emp_no) DESC;

-- See the distribution of job titles across departments.
SELECT d.dept_name AS "Department",
	d.dept_no AS "Dept. No.",
	ti.title AS "Job Title",
	COUNT(e.emp_no) AS "Active Count",
	COUNT(ut.emp_no) AS "Retirement-Ready Count",
	ROUND((COUNT(ut.emp_no) * 1.00/COUNT(e.emp_no) * 100), 2) AS "Retirement-Ready Percentage"
INTO dept_title
FROM employees AS e
	INNER JOIN dept_emp AS de
		ON e.emp_no = de.emp_no
	INNER JOIN departments AS d
		ON d.dept_no = de.dept_no
	INNER JOIN titles AS ti
		ON e.emp_no = ti.emp_no
	FULL OUTER JOIN unique_titles AS ut
		ON (e.emp_no = ut.emp_no)
WHERE (de.to_date = '9999-01-01')
AND (ti.to_date = '9999-01-01')
GROUP BY d.dept_no,
	ti.title
ORDER BY d.dept_no ASC;
```

The results (illustrated below) are exported for easy access.

- Export 8: dept_dist.csv

![Employee distribution by department](https://github.com/Owen-Wang1234/Pewlett-Hackard-Analysis/blob/main/Data/dept_dist.png)

- Export 9: title_dist.csv

![Employee distribution by title](https://github.com/Owen-Wang1234/Pewlett-Hackard-Analysis/blob/main/Data/title_dist.png)

- Export 10: dept_title.csv

![Title distribution in departments](https://github.com/Owen-Wang1234/Pewlett-Hackard-Analysis/blob/main/Data/dept_title.png)

All show that the employees eligible for retirement appear evenly distributed across every department and across almost every job title. However, losing department managers is significant, especially when it appears that each department only has one active manager. The two managers that could depart soon are in Sales and Research.

Having only one active manager per department is completely shocking considering that each department has many thousands of active employees. Calling back to the manager info table in the earlier stages of the project, the five employees in the table are currently employed and eligible for retirement, but despite drawing from the department managers table only two of them are currently managers while the others stopped being managers at some point. The next query below (also included in the `extra_queries` script) gathers any relevant data (employee number, full name, date of hire, department, title, and the start and end dates) in an attempt to investigate this. The query focuses only on currently active employees and `INNER JOIN`'s with the department manager table so that the focus will be on current employees who had spent time as managers.

```
-- Track the employees in the managers table
SELECT e.emp_no,
	e.last_name,
	e.first_name,
	e.hire_date,
	d.dept_name,
	ti.title,
	ti.from_date,
	ti.to_date
INTO manager_tracking
FROM employees AS e
	INNER JOIN dept_emp AS de
		ON e.emp_no = de.emp_no
	INNER JOIN departments AS d
		ON de.dept_no = d.dept_no
	INNER JOIN dept_manager AS dm
		ON e.emp_no = dm.emp_no
	INNER JOIN titles AS ti
		ON e.emp_no = ti.emp_no
WHERE de.to_date = '9999-01-01'
ORDER BY d.dept_no ASC,
	e.emp_no ASC,
	ti.to_date DESC;
```

- Export 11: manager_tracking.csv

![The management carousel](https://github.com/Owen-Wang1234/Pewlett-Hackard-Analysis/blob/main/Data/manager_tracking.png)

The result shows that employees appear to do some time in management and then step down into a different role while another fills in for a period until one stays a manager up to today; this is particularly pronounced in Production, Quality, and Customer Service where multiple employees take turns as manager. If the manager role is going to be considered a temporary role that is rotated among qualified employees, then expanding the management team can make leadership easier since one manager does not have to lead and direct the entire department. This may also help mitigate the issue of lack of mobility seen with some of the retirement-ready employees not in senior roles despite their long duration of employment.

The issue of mentorship is investigated with this query below (added in the `extra_queries` script). It is similar to the one used to create Export 10, but adjusted to use the mentorship eligiblity table. Some extra edits can focus on departments and titles.

```
-- See the distribution of potential mentors by job title and department.
SELECT d.dept_name AS "Department",
	d.dept_no AS "Dept. No.",
	me.title AS "Job Title",
	COUNT(me.emp_no) AS "Potential Mentors"
INTO mentor_dist
FROM mentorship_eligibility AS me
	INNER JOIN dept_emp AS de
		ON me.emp_no = de.emp_no
	INNER JOIN departments AS d
		ON de.dept_no = d.dept_no
GROUP BY d.dept_no,
	me.title
ORDER BY d.dept_no ASC;
```

- Export 12: mentor_dist.csv

![Potential mentor distribution](https://github.com/Owen-Wang1234/Pewlett-Hackard-Analysis/blob/main/Data/mentor_dist.png)

![Distribution by dept](https://github.com/Owen-Wang1234/Pewlett-Hackard-Analysis/blob/main/Data/mentor_dept.png)

The result shows plenty of senior-ranked potential mentors in every department, but the number of potential mentors is weighted towards Production and Development and Sales which is consistent with the number of current personnel.

One particular question still remaining revolves around the salary of the workforce; the salary situation can have a very significant impact on how the company will fare in preparing for the future. A quick check of the salaries table proved very alarming after seeing that the **LATEST UPDATES in salaires were on FEB-01-2000**. A more detailed query (included in the `extra_queries` script) will calculate the average salaries and find the max and min salaries by department and title. A Common Table Expression (CTE) filters the salaries table to take only the latest salary from only those currently employed.

```
-- See how salary looks by job title and department.
WITH latest_salary AS (SELECT DISTINCT ON (s.emp_no) s.emp_no,
					   s.salary
					   FROM salaries AS s
					   INNER JOIN dept_emp AS de
					   	ON s.emp_no = de.emp_no
					   WHERE de.to_date = '9999-01-01'
					   ORDER BY s.emp_no,
					   s.to_date DESC)
SELECT d.dept_name AS "Department",
	d.dept_no AS "Dept. No.",
	ti.title AS "Job Title",
	ROUND(AVG(ls.salary)) AS "Avg. Salary",
	MIN(ls.salary) AS "Min. Salary",
	MAX(ls.salary) AS "Max. Salary"
INTO salary_dist
FROM employees AS e
	INNER JOIN dept_emp AS de
		ON e.emp_no = de.emp_no
	INNER JOIN departments AS d
		ON de.dept_no = d.dept_no
	INNER JOIN titles AS ti
		ON e.emp_no = ti.emp_no
	INNER JOIN latest_salary AS ls
		ON e.emp_no = ls.emp_no
WHERE (ti.to_date = '9999-01-01')
GROUP BY d.dept_no,
	ti.title
ORDER BY d.dept_no ASC;
```

- Export 13: salary_dist.csv

![Salary distribution](https://github.com/Owen-Wang1234/Pewlett-Hackard-Analysis/blob/main/Data/salary_dist.png)

The most immediately alarming observation is that most of the average salaries fall below $50,000 per year; the three departments with average salaries above this are Marketing, Finance, and Sales.

It is also jarring to see that despite filtering to get the latest salary for each employee, the minimum salary is still $40,000 per year, and especially for **FOUR DEPARTMENT MANAGERS** (Human Resources, Development, Production, and Customer Service)! This is followed by noticing that the only the Marketing department has the manager salary greater than the average salary of the other job titles.

Not only is the number of potential mentors much less than the number of employees that may retire, but the fact the salaries have not been updated since the year 2000 will make employee retention a difficult matter if non-retiring employees decide to ply their skills and experience with another employer that pays more **AND** actually provides regular raises. Employees eligible for mentorship may be particularly recalcitrant about staying to become mentors if the salary situation is not remedied immediately, especially when checking the salaries of these employees.