use AdventureWorksENG

--LO2, FUNCTIONS AND INDEXES

/*
1. Remove all non-clustered indexes from the Invoice table, if any. Within
the SQL script, write answers to the questions and commands to obtain
them:
How many data pages does the Invoice table use?
What is the value of the IDInvoice column for the first and last invoice on
the first data page?
On which page is the invoice with IDInvoice equal to 44104 located?
What is the length of the record where IDInvoice is equal to 43664?
*/


dbcc traceon (3604)

dbcc ind ('AdventureWorksENG','Invoice',-1)
--200 data pages

dbcc page ('AdventureWorksENG', 1, 928,3)
--IDInvoice = 43659
--IDInvoice last: 43816

-- DBCC INDEXDEFRAG ('database_name', 'table_name', 'index_name');



--????



/*
2. Remove all non-clustered indexes from the Customer table, if any.
Optimize the query as best as possible:
SELECT IDCustomer, FirstName, LastName
FROM Customer
WHERE PhoneNumber like '1%'
AND Email is not null
*/
go
set statistics io on 

select * from Customer

SELECT IDCustomer, FirstName, LastName
FROM Customer
WHERE PhoneNumber like '1%'
AND Email is not null
--340 logical reads before
--340 after, he decided  to not use the index

create nonclustered index i1 on Customer(PhoneNumber) include (Email)
drop index Customer.i1
go

set statistics io off
/*

3. Write a function that takes IDCreditCard as input and returns the
number of invoices paid with the selected credit card. Call the function
independently. Additionally, retrieve the number and type of credit
cards, and for each of them, print how many invoices were paid with
them. Modify the function to return 0 for credit cards with no paid
invoices. If necessary, add rows to the table to verify the correctness of
the function. Remove the function.
*/


select * from CreditCard
select * from Invoice where CreditCardID = 76

create function f1(
	@IDCard int
) returns int
as 
begin
	declare @NumOfInvoices int
	select @NumOfInvoices = count(*) from Invoice where CreditCardID = @IDCard
	return @NumOfInvoices
end
go
	
print dbo.f1(76)

drop function f1 
go



/*
4. Write a procedure that takes the subcategory name as input and checks
whether that subcategory exists in the database and if there is at least
one product belonging to that subcategory. If the subcategory does not
exist, the procedure should return -1 through the RETURN parameter. If
the subcategory exists but there is no product belonging to that
subcategory, the procedure must return 0 through the RETURN
parameter. If the subcategory exists and there is at least one product
belonging to that subcategory, the procedure should return 1 through
the RETURN parameter. Call the procedure three times to demonstrate
all the mentioned cases.
*/

select * from Subcategory
drop proc p1
create proc p1(
	@result int output,
	@sName nvarchar (50)
)
as
begin try
	select @result = count(*) from Subcategory
	inner join Product as p on p.SubcategoryID = Subcategory.IDSubcategory
	 where Subcategory.Name = @sName
	 if @result >= 1
	return 1
	else return 0
end try
begin catch
	set @result = -1
	return @result
end catch
	
exec p1 'Road Bikes'








