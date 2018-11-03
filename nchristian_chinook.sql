-- Part I – Working with an existing database

-- 1.0	Setting up Oracle Chinook
-- In this section you will begin the process of working with the Oracle Chinook database
-- Task – Open the Chinook_Oracle.sql file and execute the scripts within.
-- 2.0 SQL Queries
-- In this section you will be performing various queries against the Oracle Chinook database.
-- 2.1 SELECT
-- Task – Select all records from the Employee table.
SELECT * FROM employee;
-- Task – Select all records from the Employee table where last name is King.
SELECT * FROM employee
	WHERE lastname = 'King';
-- Task – Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
SELECT * FROM employee
	WHERE reportsto ISNULL;
-- 2.2 ORDER BY
-- Task – Select all albums in Album table and sort result set in descending order by title.
SELECT * FROM album
	ORDER BY title;
-- Task – Select first name from Customer and sort result set in ascending order by city
SELECT firstname FROM customer 
	ORDER BY city;
-- 2.3 INSERT INTO
-- Task – Insert two new records into Genre table
INSERT INTO genre (genreid, name) values (26, 'K Pop');
INSERT INTO genre (genreid, name) values (27, 'EDM');
-- Task – Insert two new records into Employee table
INSERT INTO employee
(employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, 
address, city, state, country, postalcode, phone, 
fax, email)
VALUES(9, 'Doe', 'John', 'IT Staff', 6, '1968-02-09 00:00:00', '2005-03-04 00:00:00', 
'123 Somewhere ST', 'Lethbridge', 'AB', 'Canada', 'T1H 1Y8', '+1 (403) 467-8774', 
'+1 (403) 467-8772', 'johndoe42@gmail.com'),
(10, 'Doe', 'Jane', 'IT Staff', 6, '1968-02-010 00:00:00', '2005-03-04 00:00:00', 
'123 Somewhere ST', 'Lethbridge', 'AB', 'Canada', 'T1H 1Y8', '+1 (403) 467-8775', 
'+1 (403) 467-8772', 'janedoe42@gmail.com');
-- Task – Insert two new records into Customer table
INSERT INTO customer
(customerid, firstname, lastname, company, address, city, state, country, postalcode, 
phone, fax, email, supportrepid)
VALUES(60, 'Tom', 'Brady', NULL, '69 Superbowl Lane', 'New York', 'NY', 'United States', '19001', 
'+12125550132', NULL, 'tom.brady@nfl.com', 3),
(61, 'Michael', 'Jordan', NULL, '23 Jumpman Street', 'Charlotte', 'NC', 'United States', '25634', 
'+17135554454', NULL, 'michael.jordan@nike.com', 4);
-- 2.4 UPDATE
-- Task – Update Aaron Mitchell in Customer table to Robert Walter
UPDATE customer
SET firstname='Robert', lastname='Walter'
WHERE customerid=32;
-- Task – Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
UPDATE artist
SET "name"='CCR'
WHERE artistid=76; 
-- 2.5 LIKE
-- Task – Select all invoices with a billing address like “T%”
SELECT * FROM invoice 
	WHERE billingaddress LIKE 'T%';
-- 2.6 BETWEEN
-- Task – Select all invoices that have a total between 15 and 50
SELECT * FROM invoice 
	WHERE total BETWEEN 10 AND 50;
-- Task – Select all employees hired between 1st of June 2003 and 1st of March 2004
SELECT * FROM employee 
	WHERE hiredate BETWEEN '2003-06-01 00:00:00' AND '2004-03-31 00:00:00';
-- 2.7 DELETE
-- Task – Delete a record in Customer table where the name is Robert Walter (There may be constraints that rely on this, find out how to resolve them).

/* Create view and delete invoiceline constraints first*/
CREATE VIEW del_id as
SELECT invoicelineid FROM invoiceline 
INNER JOIN invoice ON invoiceline.invoiceid = invoice.invoiceid
WHERE invoice.customerid = 32;

DELETE FROM invoiceline WHERE
invoicelineid IN (
	SELECT invoicelineid FROM del_id);
/*Now delete the customerid from invoice*/
DELETE FROM invoice WHERE customerid = 32;
/*Now remove the customer*/
DELETE FROM customer WHERE customerid = 32;

-- 3.0	SQL Functions
-- In this section you will be using the Oracle system functions, as well as your own functions, to perform various actions against the database
-- 3.1 System Defined Functions
-- Task – Create a function that returns the current time.
CREATE OR REPLACE FUNCTION get_time()
RETURNS TIME AS $$ --Delimiter 
	BEGIN -- start transaction
		RETURN CURRENT_TIME;
	END;
$$ LANGUAGE plpgsql;
-- Task – create a function that returns the length of a mediatype from the mediatype table
CREATE OR REPLACE FUNCTION get_mediatype_len(id INT) 
 RETURNS TABLE (
 mediatypeid INT4,
 len INT4
) 
AS $$
BEGIN
 RETURN QUERY SELECT mediatype.mediatypeid, Length(mediatype.name) as len
 FROM
 mediatype WHERE id = mediatype.mediatypeid;
END; $$ 
LANGUAGE 'plpgsql';

SELECT * FROM get_mediatype_len(2);
-- 3.2 System Defined Aggregate Functions
-- Task – Create a function that returns the average total of all invoices
CREATE OR REPLACE FUNCTION get_invoice_total() 
 RETURNS TABLE (
 total NUMERIC(10,2)
) 
AS $$
BEGIN
 RETURN QUERY SELECT SUM(invoice.total) as total
 FROM
 invoice;
END; $$ 
LANGUAGE 'plpgsql';

SELECT get_invoice_total();
-- Task – Create a function that returns the most expensive track
CREATE OR REPLACE FUNCTION get_pricey_track() 
 RETURNS TABLE (
 high NUMERIC(10,2)
) 
AS $$
BEGIN
 RETURN QUERY SELECT MAX(track.unitprice) as high
 FROM
 track;
END; $$ 
LANGUAGE 'plpgsql';

SELECT get_pricey_track();
-- 3.3 User Defined Scalar Functions
-- Task – Create a function that returns the average price of invoiceline items in the invoiceline table
CREATE OR REPLACE FUNCTION get_invoiceline_avg() 
 RETURNS TABLE (
 invoiceline_avg NUMERIC(10,2)
) 
AS $$
BEGIN
 RETURN QUERY SELECT AVG(invoiceline.unitprice) as invoiceline_avg
 FROM
 invoiceline;
END; $$ 
LANGUAGE 'plpgsql';

SELECT get_invoiceline_avg();
-- 3.4 User Defined Table Valued Functions
-- Task – Create a function that returns all employees who are born after 1968.
CREATE OR REPLACE FUNCTION emp_after68() 
 RETURNS TABLE (
 firstname VARCHAR,
 lastname VARCHAR,
 birthdate TIMESTAMP
) 
AS $$
BEGIN
 RETURN QUERY SELECT employee.firstname, employee.lastname, employee.birthdate
 FROM
 employee WHERE employee.birthdate > '1967-12-31 00:00:00';
END; $$ 
LANGUAGE 'plpgsql';

SELECT emp_after68();
-- 4.0 Stored Procedures
--  In this section you will be creating and executing stored procedures. You will be creating various types of stored procedures that take input and output parameters.
-- 4.1 Basic Stored Procedure
-- Task – Create a stored procedure that selects the first and last names of all the employees.

CREATE OR REPLACE FUNCTION get_names() 
 RETURNS TABLE (
 firstname VARCHAR,
 lastname VARCHAR
) 
AS $$
BEGIN
 RETURN QUERY SELECT employee.firstname, employee.lastname
	FROM employee ;
END; $$ 
LANGUAGE 'plpgsql';

SELECT get_names();
-- 4.2 Stored Procedure Input Parameters
-- Task – Create a stored procedure that updates the personal information of an employee.

CREATE OR REPLACE FUNCTION update_employee(id INT, new_title VARCHAR, new_address VARCHAR, new_city VARCHAR, new_state VARCHAR, new_country VARCHAR, new_zip VARCHAR, new_phone VARCHAR, new_fax VARCHAR, new_email VARCHAR  ) 
 RETURNS VOID AS $BODY$
BEGIN
 	UPDATE employee
		SET title=new_title, address=new_address, city=new_city, state = new_state, country=new_country, postalcode = new_zip, phone = new_phone, fax= new_fax, email = new_email
		WHERE employeeid=id;
END; $BODY$ 
LANGUAGE 'plpgsql';


SELECT update_employee(10, 'Tech Support', '123 Somewhere ST', 'Lethbridge', 'AB', 'Canada', 'T1H 1Y8', '+1 (403) 467-8775', '+1 (403) 467-8772','janedoe42@gmail.com' );

-- Task – Create a stored procedure that returns the managers of an employee.
--create view to merge title on on 
CREATE OR REPLACE VIEW chinook.bosses
AS SELECT employee.employeeid,
    employee.firstname,
    employee.title
   FROM employee;


CREATE OR REPLACE FUNCTION get_boss(id INT) 
 RETURNS TABLE (
	firstname VARCHAR,
 	boss VARCHAR
) 
AS $$
BEGIN
 RETURN QUERY SELECT  bosses.firstname, bosses.title boss 
 	FROM employee LEFT JOIN bosses ON (employee.reportsto=bosses.employeeid)
 	WHERE employee.employeeid = id;
END; $$ 
LANGUAGE 'plpgsql';

SELECT get_boss(2);
-- 4.3 Stored Procedure Output Parameters
-- Task – Create a stored procedure that returns the name and company of a customer.
CREATE OR REPLACE FUNCTION get_customer(id INT) 
 RETURNS TABLE (
	customer VARCHAR,
	company VARCHAR
) 
AS $$
BEGIN
 RETURN QUERY SELECT  customer.firstname, customer.company
 	FROM customer
 	WHERE customer.customerid = id;
END; $$ 
LANGUAGE 'plpgsql';

SELECT get_customer(1);
-- 5.0 Transactions
-- In this section you will be working with transactions. Transactions are usually nested within a stored procedure. You will also be working with handling errors in your SQL.
-- Task – Create a transaction that given a invoiceId will delete that invoice (There may be constraints that rely on this, find out how to resolve them).

CREATE OR REPLACE FUNCTION del_invoice (id int)  
 RETURNS VOID AS $$
BEGIN
 	DELETE FROM invoice WHERE 
END; $$ 
LANGUAGE 'plpgsql';


-- Task – Create a transaction nested within a stored procedure that inserts a new record in the Customer table


CREATE OR REPLACE FUNCTION new_customer(id INT) 
 RETURNS VOID AS $BODY$
BEGIN  
 	INSERT INTO customer VALUES (id, title='title', address='address', city= 'city', state = 'state', country='new country', postalcode = 'zip', phone = 'phone', fax= 'fax', email = 'email');
END; $BODY$ 
LANGUAGE 'plpgsql';

--determine next available id 
SELECT (MAX(customerid)+1) FROM customer;
--enter id into new_customer function to create new dummy record
new_customer(62)

-- 6.0 Triggers
-- In this section you will create various kinds of triggers that work when certain DML statements are executed on a table.
-- 6.1 AFTER/FOR
-- Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.

 CREATE TABLE employee_audit(
 	employeeid INT PRIMARY KEY,
 	lastname VARCHAR,
 	new_lastname VARCHAR,
 	firstname VARCHAR,
 	new_first VARCHAR,
 	title VARCHAR,
 	new_title VARCHAR,
 	reportsto INT,
 	new_reportsto INT,
 	birthdate TIMESTAMP,
 	new_birthdate TIMESTAMP,
 	hiredate TIMESTAMP,
 	new_hiredate TIMESTAMP,
 	address VARCHAR,
 	new_address VARCHAR,
 	city VARCHAR,
 	new_city VARCHAR,
 	state VARCHAR,
 	new_state VARCHAR,
 	country VARCHAR,
 	new_country VARCHAR,
 	postalcode VARCHAR,
 	new_postalcode VARCHAR,
 	phone VARCHAR,
 	new_phone VARCHAR,
 	fax VARCHAR,
 	new_fax VARCHAR,
 	email VARCHAR,
 	new_email VARCHAR
 );

 CREATE OR REPLACE FUNCTION employee_audit_trig_function()
 RETURNS TRIGGER AS $$
 BEGIN
 	IF(TG_OP = 'INSERT') THEN
 		INSERT INTO employee_audit (
 			employeeid,
 			new_lastname,
 			new_first,
 			new_title,
 			new_reportsto,
 			new_birthdate,
 			new_hiredate,
 			new_address,
 			new_city,
 			new_state,
 			new_country,
 			new_postalcode,
 			new_phone,
 			new_fax,
 			new_email
 		) VALUES (
 			NEW.employeeid,
 			NEW.lastname,
 			NEW.firstname,
 			NEW.title,
 			NEW.reportsto,
 			NEW.birthdate,
 			NEW.hiredate,
 			NEW.address,
 			NEW.city,
 			NEW.state,
 			NEW.country,
 			NEW.postalcode,
 			NEW.phone,
 			NEW.fax,
 			NEW.email
 		);
 	END IF;

 	RETURN NEW; -- return new so that it will put the data into the users table still
 END;
 $$ LANGUAGE plpgsql;

 CREATE TRIGGER employee_audit_trig
 AFTER INSERT ON employee
 FOR EACH ROW
 EXECUTE PROCEDURE employee_audit_trig_function();

INSERT INTO chinook.employee
(employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, address, city, state, country, postalcode, phone, fax, email)
VALUES(11, 'Banner', 'Bruce', 'Dr.', NULL, '1962-02-18 00:00:00', '2002-08-14 00:00:00', '1618  3 Ave SW', 'Edmonton', 'AB', 'Canada', 'T5K 2N1', '+1 (780) 428-9482', '+1 (780) 428-3457', 'hulksmash@marvel.com');

SELECT * FROM employee_audit;


-- Task – Create an after update trigger on the album table that fires after a row is inserted in the table

 CREATE TABLE album_audit(
 	albumid INT PRIMARY KEY,
 	new_ablumid INTEGER,
 	new_title VARCHAR,
 	new_artistid INT
 );

 CREATE OR REPLACE FUNCTION album_audit_trig_function()
 RETURNS TRIGGER AS $$
 BEGIN
 	IF(TG_OP = 'INSERT') THEN
 		INSERT INTO album_audit (
 			albumid,
 			new_title,
 			new_artistid
 		) VALUES (
 			NEW.albumid,
 			NEW.title,
 			NEW.artistid
 		);
 	END IF;
 	RETURN NEW; -- return new so that it will put the data into the users table still
 END;
 $$ LANGUAGE plpgsql;

 CREATE TRIGGER album_audit_trig
 AFTER INSERT ON album
 FOR EACH ROW
 EXECUTE PROCEDURE album_audit_trig_function();

INSERT INTO chinook.album
(albumid, title, artistid)
VALUES(349, 'I Like Music2', 1);

SELECT * FROM album_audit;

 --Task – Create an after delete trigger on the customer table that fires after a row is deleted from the table.

CREATE TABLE employee_del_audit(
 	employeeid INT PRIMARY KEY,
 	lastname VARCHAR,
 	firstname VARCHAR,
 	title VARCHAR,
 	reportsto INT,
 	hiredate TIMESTAMP,
 	birthdate TIMESTAMP,
 	address VARCHAR,
 	city VARCHAR,
 	state VARCHAR,
 	country VARCHAR,
 	postalcode VARCHAR,
 	phone VARCHAR,
 	fax VARCHAR,
 	email VARCHAR
 );

CREATE OR REPLACE FUNCTION employee_del_trig_function()
 RETURNS TRIGGER AS $$
 BEGIN
 	IF(TG_OP = 'DELETE') THEN
 		INSERT INTO employee_del_audit (
 			employeeid,
 			lastname,
 			firstname,
 			title,
 			reportsto,
 			birthdate,
 			hiredate,
 			address,
 			city,
 			state,
 			country,
 			postalcode,
 			phone,
 			fax,
 			email
 		) VALUES (
 			OLD.employeeid,
 			OLD.lastname,
 			OLD.firstname,
 			OLD.title,
 			OLD.reportsto,
 			OLD.birthdate,
 			OLD.hiredate,
 			OLD.address,
 			OLD.city,
 			OLD.state,
 			OLD.country,
 			OLD.postalcode,
 			OLD.phone,
 			OLD.fax,
 			OLD.email
 		);
 	END IF;

 	RETURN NEW; -- return new so that it will put the data into the users table still
 END;
 $$ LANGUAGE plpgsql;

 CREATE TRIGGER employee_del_trig
 AFTER DELETE ON employee
 FOR EACH ROW
 EXECUTE PROCEDURE employee_del_trig_function();

DELETE FROM employee WHERE employeeid = 11;

SELECT * FROM employee_del_audit;

-- 6.2 Before
-- Task – Create a before trigger that restricts the deletion of any invoice that is priced over 50 dollars.
--will save them into another table
 
CREATE TABLE save_invoice_gt50(
 	invoiceid INT PRIMARY KEY,
 	customerid INT,
 	invoicedate TIMESTAMP,
 	billingaddress VARCHAR,
 	billingcity VARCHAR,
 	billingstate VARCHAR,
 	billingcountry VARCHAR,
 	billingpostalcode VARCHAR,
 	total NUMERIC(10,2)
 );

 CREATE OR REPLACE FUNCTION save_invoice_gt50_function()
 RETURNS TRIGGER AS $$
 BEGIN
 	IF(TG_OP = 'DELETE') THEN
 		IF OLD.total > 50 THEN
 		INSERT INTO chinook.save_invoice_gt50
			(invoiceid, customerid, invoicedate, 
			billingaddress, billingcity, billingstate, 
			billingcountry, billingpostalcode, total)
		VALUES(OLD.invoiceid, OLD.customerid, OLD.invoicedate, 
			OLD.billingaddress, OLD.billingcity, OLD.billingstate, 
			OLD.billingcountry, OLD.billingpostalcode, OLD.total);

 		END IF;
 	END IF;
 	RETURN NEW; -- return new so that it will put the data into the users table still
 END;
 $$ LANGUAGE plpgsql;


 CREATE TRIGGER save_invoice_gt50_trig
 BEFORE DELETE ON invoice
 FOR EACH ROW
 EXECUTE PROCEDURE save_invoice_gt50_function();

--no invoices > 50 exists so make one
INSERT INTO chinook.invoice
(invoiceid, customerid, invoicedate, billingaddress, billingcity, billingstate, billingcountry, billingpostalcode, total)
VALUES(413, 2, '2009-01-01 00:00:00', 'Theodor-Heuss-Stra�e 34', 'Stuttgart', NULL, 'Germany', '70174', 51);

--verify entry
SELECT * FROM invoice WHERE total > 50;

--delete it
DELETE FROM invoice WHERE invoice.total > 50;
--verify deleted record save to recovery table
SELECT * FROM save_invoice_gt50;

-- 7.0 JOINS
-- In this section you will be working with combing various tables through the use of joins. You will work with outer, inner, right, left, cross, and self joins.
-- 7.1 INNER
-- Task – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.

SELECT 
	invoiceid as "Invoice ID", 
	firstname as "First Name", 
	lastname as "Last Name" 
FROM customer
	INNER JOIN invoice ON invoice.customerid = customer.customerid;  

-- 7.2 OUTER
-- Task – Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.

SELECT	
	customer.customerid as "Customer ID", 
	customer.firstname as "First Name", 
	customer.lastname as "Last Name",
	invoice.invoiceid as "Invoice Id",
	invoice.total as "Total"
FROM customer 
	FULL JOIN invoice ON invoice.customerid = customer.customerid;

-- 7.3 RIGHT
-- Task – Create a right join that joins album and artist specifying artist name and title.
SELECT 
	artist.name as "Artist", 
	album.title as "Title"
FROM album
	RIGHT JOIN artist ON album.artistid = artist.artistid;



-- 7.4 CROSS
-- Task – Create a cross join that joins album and artist and sorts by artist name in ascending order.

SELECT 
	artist.name as "Artist", 
	album.title as "Title"
FROM album
	CROSS JOIN artist 
	ORDER BY artist.name;


-- 7.5 SELF
-- Task – Perform a self-join on the employee table, joining on the reportsto column.

SELECT 
	t1.employeeid AS "Manager ID",
	t1.firstname AS "Manager Name",
	t2.employeeid AS "Employee ID", 
	t2.firstname AS "Employee Name"
FROM employee t1, employee t2
WHERE t1.employeeid = t2.reportsto
ORDER BY t1.employeeid;