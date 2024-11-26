use AdventureWorksENG

/*1. Write a function that receives a product ID and retrieves the number of copies sold.
Call the function independently.
Get the names and colors of all products and print out how many copies have been
sold next to each product. 
Change the function so that it returns 0 for those products that have not
sold a single copy. Remove the function.*/

select * from InvoiceItem
select * from Invoice
select * from Product

create function f1(
	@ID int
) returns int
as
begin
	declare @TotalCopiesSold int
	select @TotalCopiesSold = sum(Quantity) from InvoiceItem where ProductID = @ID
	return @TotalCopiesSold
end
go

DECLARE @Res int
SET @Res = dbo.f1(776)
PRINT @Res


---
select 
	Name,
	Color,
	dbo.f1(IDProduct) as ProductsSold
from Product

alter function f1(
	@ID int
)
returns int
as
begin 
	declare @TotalCopiesSold int
	select @TotalCopiesSold = sum(Quantity) from InvoiceItem where ProductID = @ID
	return case
			when @TotalCopiesSold is not null then @TotalCopiesSold
			else 0
		end
end
go


drop function f1


/* 2.Write a function that receives a string. 
If the number of characters in the string is less than 10, let the
function return the input string.
If not, let it return the first 7 characters followed by three periods.
Print the names of all products using the function you created.*/
		 
select * from Product
go
create function f2(
	@Message nvarchar(max)
)
returns nvarchar(10)
as
begin
	return case 
		when len(@Message) <= 10 then @Message
		else substring(@Message,1,7) + '...'
	end
end
go

PRINT dbo.f2('Zvonko')
PRINT dbo.f2('Zvonko Telefonko')

select 
	Name,
	dbo.f2(Name) as ShortNames
from Product

drop function f2
go

/*3. Write a function that returns the date of the most recent purchase 
for a given customer. 
Print all customers and at the end of each print the date of the most recent 
purchase. If necessary, optimize!*/

select * from Customer
select * from Invoice

create function f3(
	@IDCustomer int
)
returns datetime
as
begin
	declare @Date  datetime
	select top 1 @Date = InvoiceDate from dbo.Invoice 
	where CustomerID = @IDCustomer
	order by InvoiceDate desc
	return @Date
end
go


select
	*,
	dbo.f3(IDCustomer) as NewestBuy
from Customer

drop function f3

go


/* 4. Write a simple table function that returns the Customer ID,
first and last name of all persons whose
last name starts with the given string.
Use the function to retrieve all persons whose last name begins
with 'Zhu'. With each person, get the corresponding invoices.*/

select * from Invoice

create function f4(
	@s nvarchar(max)
)
returns table
as
return 
	select IDCustomer, FirstName, LastName from Customer
	where LastName like @s + '%'
go


select * from f4('Z')

select * from f4('Zhu') AS Persons
inner join Invoice as i on i.CustomerID= Persons.IDCustomer
go

drop function f4


/* 5. Write a simple table function that receives two dates. 
Let the function return the invoice number, date of issue,
first and last name of the customer for all invoices issued
between the given dates.
Use the function to retrieve the invoice between 01.06.2004. and 03.06.2004. 
Change the function so that the date is in Croatian format.*/

select * from Invoice

create function f5(
	@D1 datetime,
	@D2 datetime
)
returns table
as
return 
	select InvoiceNumber, InvoiceDate, c.FirstName, c.LastName from Invoice
	left join dbo.Customer as c on c.IDCustomer= Invoice.CustomerID
	where InvoiceDate between @D1 and @D2
go

select * from f5('20040601', '20040603')
go

drop function f5


/* 6. Write a complex table function that behaves like the function from task 5.
Use the function to retrieve
accounts between 06/01/2004. and 03.06.2004.*/

select * from Invoice	

create function f6(
	@D1 datetime,
	@D2 datetime
)
returns @Result table(InvNum nvarchar(255), InvDat datetime, fName nvarchar(255), lName nvarchar(255))
as
begin
	insert into @Result(InvNum,InvDat,fName,lName)
	select InvoiceNumber, InvoiceDate, c.FirstName, c.LastName from Invoice
	left join dbo.Customer as c on c.IDCustomer= Invoice.CustomerID
	where InvoiceDate between @D1 and @D2
	return
end
go


SELECT * FROM f6('20040601', '20040603')
drop function f6


/*7. Write a complex table function that receives a price.
If price is NULL, return the names and prices of
all products from the Product table. 
If not, return the names and prices of only those products whose
price is higher than the default price. 
Use a function with NULL and a price of 3000.
*/
go
select * from Product
create function f7(
	@Price money
)
returns @Result table (ProdName nvarchar(255), Price money)
as
begin
if @Price is null 
	begin
		insert into @Result (ProdName, Price)
		select Name, PriceWithoutVAT from Product
	end
else
	begin
		insert into @Result (ProdName, Price)
		select Name, PriceWithoutVAT from Product where PriceWithoutVAT > @Price
	end
	return
end
go

select * from f7(null)
select * from f7(3000)

drop function f7


/* 8. Write a compound table function that receives a single date and 
returns a single-column table containing the next 5 dates.
For example, if it is set to 03.12.2011, the function should return 04.12.,
05.12, 06.12, 07.12, 08.12.*/
	

create function f8(
	@D datetime
)
returns @Result table (Datum datetime)
as
begin
	declare @counter int = 1
	while @counter <= 5 begin
		insert @Result( Datum)
		values (dateadd(day, @counter, @D))
		set @counter += 1
	end
	return
end
go


select * from f8(GETDATE())
drop function f8