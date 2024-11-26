-- Title: Exercises 8 - Helper

-- USE AdventureWorksENG
USE AdventureWorksENG

select * from Invoice
/*Get the invoice numbers and issue dates for the customer with ID 378.
Format the invoice dates in
Croatian format.*/


SELECT InvoiceNumber, InvoiceDate FROM Invoice WHERE CustomerID = 378

-- CAST InvoiceDate, pretvori date u string
SELECT InvoiceNumber, CAST(InvoiceDate AS char(10)) AS InvoiceDate
FROM Invoice WHERE CustomerID = 378

-- COVERT InvoiceDate, convert into Croatian format
SELECT InvoiceNumber, CONVERT(char(10), InvoiceDate, 104) AS InvoiceDate
FROM Invoice WHERE CustomerID = 378

-----------------------------------------------------------
-----------------------------------------------------------

-- Using: CASE
/*Get the names of all products and print the
name of the subcategory next to each name. If
there is no subcategory, write "Not defined".
*/

select * from Product


SELECT 
	p.Name,
	CASE
		WHEN sc.Name IS NULL THEN 'Not defined'
		ELSE sc.Name
	END AS SubcategoryName
FROM Product AS p
left JOIN Subcategory AS sc ON p.SubcategoryID = sc.IDSubcategory
go 

/*
Get the name and prices of all products. For
prices below 1000, write "Cheap", between 1000
and 2000 write "Acceptable", for all others write
"Expensive".
*/

select 
	p.Name,
	case
		when p.PriceWithoutVAT < 1000 then  'Cheap'
		when p.PriceWithoutVAT between 1000 and 2000 then 'Acceptable'
		else  'Expensive'
	end as Price
from Product as p



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

/*Create a table Test with columns ID (primary key
and IDENTITY) and TestValue (int). In the
TestValue column, enter values between
10000 and 12000
*/


-- Create table: Test
CREATE TABLE Test ( ID int PRIMARY KEY IDENTITY, TestValue int )
GO

-- While
DECLARE @i int = 10000
WHILE @i <= 12000 BEGIN
	INSERT INTO Test VALUES (@i)
	SET @i += 1
END

SELECT * FROM Test
GO

--------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

-- Table: Type
CREATE TABLE Type 
(
	IDType int PRIMARY KEY,
	TypeName nvarchar(50)
)
GO

-- Proc: InsertType
CREATE PROC InsertType 
	@IDType int,
	@TypeName nvarchar(50)
AS
INSERT INTO Type (IDType, TypeName) VALUES (@IDType, @TypeName)
GO

-- Problem:
EXEC InsertType  20, 'Penguin'
EXEC InsertType  20, 'Penguin'

--
-- Solution 1: Outside TRY-CATCH
--
BEGIN TRY
	EXEC InsertType 20, 'Penguin'
	EXEC InsertType 20, 'Penguin'
END TRY
BEGIN CATCH
	PRINT 'Error message: ' + cast(ERROR_MESSAGE() as nvarchar(100))
	PRINT 'Error number: ' + cast(ERROR_NUMBER() as nvarchar(100))
	PRINT 'Error severity: ' + cast(ERROR_SEVERITY() as nvarchar(100))
	PRINT 'Error line ' + cast(ERROR_LINE() as nvarchar(100))
	PRINT 'Error procedure: ' + cast(ERROR_PROCEDURE() as nvarchar(100))
END CATCH
GO

--
-- Solution 2: InsertType
--
ALTER PROC InsertType 
	@IDType int,
	@TypeName nvarchar(50)
AS
BEGIN TRY
	INSERT INTO Type (IDType, TypeName) VALUES (@IDType, @TypeName)
END TRY
BEGIN CATCH
	PRINT 'Error: ' + ERROR_MESSAGE()
	PRINT 'Type is not inserted.'
END CATCH
GO

EXEC InsertType 20, 'Penguin'

/*
Presentation: DD-Practical_class-08-ENG.pptx
Slide: 9
Task: Our task
*/

-- Create: Customer
CREATE PROC spInsertCustomer
	@IDCustomer INT OUTPUT, 
	@FirstName NVARCHAR(50), 
	@LastName NVARCHAR(50)
AS
INSERT INTO Customer (FirstName, LastName) VALUES (@FirstName, @LastName)
SET @IDCustomer = SCOPE_IDENTITY()
GO

-- Retrieve: Customer
CREATE PROC spGetCustomer
	@IDCustomer int
AS
SELECT * FROM Customer WHERE IDCustomer = @IDCustomer
GO

-- Update: Customer
CREATE PROC spUpdateCustomer
	@IDCustomer INT, 
	@FirstName NVARCHAR(50), 
	@LastName NVARCHAR(50)
AS
UPDATE Customer SET FirstName = @FirstName, LastName = @LastName
WHERE IDCustomer = @IDCustomer
GO

-- Delete: Customer
CREATE PROC spDeleteCustomer
	@IDCustomer INT
AS
DELETE FROM Customer WHERE IDCustomer = @IDCustomer
GO

-- EXEC
-- C
DECLARE @NewIDCustomer int
EXEC spInsertCustomer @IDCustomer = @NewIDCustomer OUTPUT, 
@FirstName = 'John', @LastName = 'Doe'
PRINT @NewIDCustomer
-- R
EXEC spGetCustomer <IDCustomer>
-- U
EXEC spUpdateCustomer <IDCustomer>, 'John Johnny', 'Doe'
-- D
EXEC spDeleteCustomer <IDCustomer>

-- CRUD Procedure: CRUDCustomer
CREATE PROCEDURE spCRUDCustomer
	@_What CHAR,
	@_IDCustomer INT = NULL,
	@_FirstName NVARCHAR(50) = NULL, 
	@_LastName NVARCHAR(50) = NULL
AS 
	BEGIN TRY
		IF(@_What = 'C')
			BEGIN
				DECLARE @NewIDCustomer int
				EXEC spInsertCustomer @IDCustomer = @NewIDCustomer OUTPUT, 
				@FirstName = @_FirstName, @LastName = @_LastName
				PRINT @NewIDCustomer
			END
		ELSE IF (@_What = 'R')
			BEGIN
				EXEC spGetCustomer @_IDCustomer
			END
		ELSE IF (@_What = 'U')
			BEGIN
				EXEC spUpdateCustomer @_IDCustomer, @_FirstName, @_LastName
			END
		ELSE IF (@_What = 'D')
			BEGIN
				EXEC spDeleteCustomer @_IDCustomer
			END
		ELSE 
			BEGIN
				PRINT 'You sent a parameter that does not exist!'
			END
	END TRY
	BEGIN CATCH
		PRINT 'Error: ' + ERROR_MESSAGE()
	END CATCH
	GO
	
EXEC spCRUDCustomer 'C', @_FirstName='John', @_LastName='Doe'
EXEC spCRUDCustomer 'R', @_IDCustomer=<IDCustomer>
EXEC spCRUDCustomer 'U',  @_IDCustomer=<IDCustomer>, 
@_FirstName='John Johnny', @_LastName='Doe'

EXEC spCRUDCustomer 'R', @_IDCustomer=<IDCustomer>
EXEC spCRUDCustomer 'D',  @_IDCustomer=<IDCustomer>
EXEC spCRUDCustomer 'M',  @_IDCustomer=<IDCustomer>
EXEC spCRUDCustomer 'D',  @_IDCustomer=1

/* --------------------------------------------------------------------- */
-- Exam exercises
/* --------------------------------------------------------------------- */

/*
TASK 1 [VIEWS]:
Create a view that displays states and the number of customers from each state. 
The view should return the columns: StateName and NumberOfCustomers.
Use the view to retrieve the state with the most customers. Write the command to drop the view.
*/

select * from Customer

create view v1 
as
select 
	s.Name as StateName,
	count(*) as NumOfCustomers
from Customer
inner join City on City.IDCity = Customer.CityID
inner join State as s on s.IDState= City.StateID
group by s.Name

select * from v1
drop view v1
go

/*
TASK 2 [VIEWS]:
Create a view that returns a formatted date in Croatian style and the number of products sold in that period.
Use the view to retrieve the 3 months with the highest product sales. 
Devise additional measures to protect the definition from unauthorized viewing of the view's content. Write the command to drop the view.
*/

select * from Invoice	

create view v2 
as
select
	sum(ii.Quantity) as NumOfProducts,
	convert(char(10),InvoiceDate,104) as DateInvoice
from Invoice 
inner join InvoiceItem as ii on ii.InvoiceID = Invoice.IDInvoice
group by InvoiceDate

select * from v2

alter view v2 
as
select top 3
	sum(ii.Quantity) as NumOfProducts,
	convert(char(10),InvoiceDate,104) as DateInvoice
from Invoice 
inner join InvoiceItem as ii on ii.InvoiceID = Invoice.IDInvoice
group by InvoiceDate
order by NumOfProducts desc


alter view v2 with encryption
as
select top 3
	sum(ii.Quantity) as NumOfProducts,
	convert(char(10),InvoiceDate,104) as DateInvoice
from Invoice 
inner join InvoiceItem as ii on ii.InvoiceID = Invoice.IDInvoice
group by InvoiceDate
order by NumOfProducts desc

drop view v2

/*
TASK 3 [TRIGGERS]:
Create a new table called Log with columns IDLog, Message, and Time. 
Create a trigger on the City table that, on every INSERT, UPDATE, or DELETE event, 
inserts a new record with the appropriate message and time into the Log table.
Write the command to drop the trigger.
Example messages:
- INSERT: City has been added to the table.
- UPDATE: City has been updated in the table.
- DELETE: City has been deleted from the table.
*/


drop table Log 

create table Log(
	IDLog int primary key,
	Message nvarchar(255),
	Time datetime
)
go

create trigger t1 on City
after insert,update, delete
as
begin
	declare @Message nvarchar(255)
	if exists (select * from inserted) and not exists (select * from deleted)
		begin
			set @Message = 'City has been added to the table.'
		end
	else if exists (select * from inserted) and  exists (select * from deleted)
		begin
			set @Message = 'City has been updated in the table.'
		end
	else if not exists (select * from inserted) and  exists (select * from deleted)
		begin
			set @Message = 'City has been deleted from the table.'
		end
	insert into Log(Message) values (@Message)
end
go

drop trigger t1
/*
TASK 4 [DATA ANALYSIS ON DISK]:
Analyze the Customer table and answer the following questions:
1. On how many pages is the data from the Customer table stored?
2. Write the page numbers of the first 5 pages (PagePID) and the file numbers where the pages are stored (PageFID).
3. On which page is the customer with CustomerID = 35 located?
4. What is the length in bytes of CustomerID = 10?
*/

dbcc traceon (3604)
dbcc ind ('AdventureWorksENG','Customer',-1)
--338 data pages

dbcc page ('AdventureWorksENG',1,584,3)  WITH TABLERESULTS

/*
TASK 5 [INDEXES]:
Optimize the query as much as possible:
"""
SELECT II.IDInvoiceItem, II.InvoiceID, II.Quantity
FROM InvoiceItem AS II
WHERE II.Quantity<20 AND II.Discount>0.2
"""
Write the command to drop the index.
*/


set statistics io on
select * from InvoiceItem

SELECT II.IDInvoiceItem, II.InvoiceID, II.Quantity
FROM InvoiceItem AS II
WHERE II.Quantity<20 AND II.Discount>0.2
--847ž--


create nonclustered index i1 on InvoiceItem(Quantity) include(InvoiceID)
drop index i1 on InvoiceItem

create nonclustered index i1 on InvoiceItem(Discount) include(InvoiceID,Quantity)
--4 log reads after this

set statistics io off


/*
TASK 6 [FUNCTIONS]:
Write a complex table function that receives a price. If price is NULL, return the names and prices of all products from the Product table. 
If not, return the names and prices of only those products whose price is higher than the default price. 
Use a function with NULL and a price of 3000.​
*/



create function f1(
	@Price money
)
returns @Result table (Name nvarchar(50), Price money)
as
begin
	if @Price is null
	begin
		insert into @Result (Name,Price) 
		select Name, PriceWithoutVAT from Product
	end
	else 
	begin
		insert into @Result (Name,Price) 
		select Name, PriceWithoutVAT from Product where PriceWithoutVAT > @Price
	end
	return
end
go


select * from f1(3000)

drop function f1

/*
TASK 7 [PROCEDURES]:
Create procedures that perform CRUD operations on the City table so that you perform the create and update operations 
in one procedure and perform the other two operations in separate procedures. 
Use procedures to create, update, select, and delete records.
*/

/* --------------------------------------------------------------------- */


go
select * from City
drop proc p1

create proc p1(
	@op char,
	@id int = null,
	@name nvarchar(50),
	@sId int
)
as
begin
	if @op = 'C'
	begin
		insert into City(Name,StateID) values (@name,@sId) 
	end
	else if @op = 'R'
	begin
		select * from  City where IDCity = @id
	end
	else if @op = 'U'
	begin
		update  City set Name = @name, StateID = @sId where IDCity = @id
	end
	else if @op = 'D'
	begin
		delete from  City where IDCity = @id
	end
end
go




