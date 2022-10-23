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
GROUP BY d.dept_no, ti.title
ORDER BY d.dept_no ASC;

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
ORDER BY d.dept_no ASC, e.emp_no ASC, ti.to_date DESC;