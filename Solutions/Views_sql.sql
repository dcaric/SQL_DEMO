use AdventureWorksENG


--VIEWS---

--LABS 1--------------------------------

/*Create a view that will retrieve everything from the Customer table
a) Use the view to retrieve all records

*/


select * from Customer

create view vCustomer
as 
select * from Customer

select * from vCustomer

/*
b)Use the view to retrieve those customers whose first name starts with "L" and last name ends with "a"
*/

select *  from vCustomer where FirstName  LIKE 'L%' AND Lastname LIKE '%a'


/*
c) Use a view to print all city IDs and the number of people living in that city, descending by number of people (using grouping
and using subqueries)*/

select CityID, COUNT(*)  as NumberOfCustomers
from vCustomer
group by CityID
order by NumberOfCustomers desc


--subqueries
SELECT DISTINCT 
	CityID, 
	(SELECT COUNT(*) 
	 FROM vCustomer AS sq 
	 WHERE ISNULL(sq.CityID, '') = ISNULL(mq.CityID, '')) AS NumberOfCustomers
FROM vCustomer AS mq 
ORDER BY NumberOfCustomers DESC

/*
d) Use a view by writing the first and last name, and next to each one, write the name of the city and the name of the country
*/


select * from State
select 
	FirstName, 
	LastName,
	c.Name as 'City',
	s.Name as 'State'
from vCustomer 
inner join City as c on c.IDCity= vCustomer.CityID
inner join State as s on c.IDCity = s.IDState


--2. Change the view so that it does not include the Email, PhoneNumber and CityID columns

select * from vCustomer
alter view vCustomer
as
select IDCustomer, FirstName, LastName from Customer


drop view vCustomer


/*Create following reports in form of a views:
a) Print all customer names with an email, city name and state name
b) Print all states and how many customer belong to each state
c) Print all product names which were bought by more than 300 customers
d) Print the names and earnings of the 5 best-selling products
e) Remove all created views.*/

--a)


select * from Customer
create view v1 
as
select 
	FirstName,
	LastName,
	Email,
	c.Name as 'City',
	s.Name as 'State'
from Customer
inner join City as c on c.IDCity = Customer.CityID
inner join State as s on s.IDState= c.StateID

select * from v1
drop view v1

--b)

create view v2 
as
select 
	s.Name as State,
	COUNT(IDCustomer) as NumOfCustomers
from Customer
inner join City as c on c.IDCity = Customer.CityID
inner join State as s on s.IDState= c.StateID
group by s.Name

select * from v2

drop view v2


--c)

select * from Product
select * from Customer
select * from Invoice
select * from InvoiceItem

drop view v3
create view  v3 as
select
	p.Name,
	count(i.CustomerID) as Number
from InvoiceItem as ii
inner join Invoice as i on i.IDInvoice= ii.InvoiceID
inner join Product as p on p.IDProduct = ii.ProductID
inner join Customer as c  on c.IDCustomer= i.CustomerID
group by p.Name
having count(i.CustomerID) > 300

select * from v3


--d)

select * from v5

CREATE VIEW v5 AS
SELECT TOP 5
	p.Name,
	SUM(ii.totalprice) AS Earning
FROM Product AS p
INNER JOIN invoiceitem AS ii ON ii.productID = p.IDProduct
GROUP BY p.Name
ORDER BY Earning DESC

drop view v5


/*EX03

a.Create a view that returns the first and last names and e-mail addresses of all customers from Zagreb
b.Change the view so that it also fetches all customers from Split
c. Using the view, print the number of customers from Zagreb and the number of customers from Split
d. Remove the view.
*/


--a)


select * from Customer

create view  v1
as
select 
	FirstName,
	LastName,
	Email,
	city.Name as CityName
from Customer as c
inner join City on City.IDCity=c.CityID
where City.Name = 'Zagreb'

select * from v1
drop view v1


--b)

alter view v1
as
select
	FirstName,
	LastName,
	Email,
	city.Name as CityName
from Customer as c
inner join City on City.IDCity=c.CityID
where City.Name = 'Zagreb' or City.Name= 'Split'



--c)

select 
	CityName,
	count(FirstName) as NumOfPeople
from v1 
group by CityName


--d)

drop view v1


--LABS 2 (ENCRYPTION,SCHEMABININDG.....)--------------------


/*EX01

Create a view that will retrieve all columns and rows from the Category table
a) Print the names of categories, subcategories and products (use the created view).
b) Using the view, insert a category named “Alarms”.
c) Using the view, change the name of the "Alarms" category to "Active protection“.
d) Use the view to delete the "Active protection" category.
e) Remove the view.

*/




select * from Category


create view v1 
as
select * from Category


select * from v1
select * from Subcategory
select * from Product

--a)
select 
	v1.Name,
	s.Name as SubName,
	p.Name as ProductName
from Product as p
inner join Subcategory as s on s.IDSubcategory=p.SubcategoryID
inner join v1 on v1.IDCategory=s.CategoryID


--b)

insert into v1 (Name) values ('Alarm') 

--c)

UPDATE v1
SET Name = 'Active protection'
WHERE Name= 'Alarm'



--d)

delete from v1 where Name = 'Active protection'


--e)

drop view v1


/*EX02

Create a view that will retrieve the name of the city, the name of the country in which it is located and
all the customer data belonging to them (Tables City, State, Customer).
a) Try using the view to insert a new city. What happened?
b) Try using the view to insert a new state. What happened?
c) Try using the view to insert a new customer. What happened? Can you see the newly added customer
through the view? Does it exist in the table?
d) Remove the view.
*/


select * from Customer
select * from State
select * from City


create view v2 
as
select 
	cc.*,
	c.Name as CityName,
	s.Name as Country
from Customer as cc
inner join City as c on cc.CityID= c.IDCity
inner join State as s on c.StateID = s.IDState

select * from v2 where CityName= 'Split'


--a)

insert  into v2 (CityName) values ('Pitve')
select * from City where Name = 'Pitve'


drop view v2



/*EX03

Create a view that will retrieve all credit cards that are of Visa or MasterCard type (CreditCard table).
a) Insert an American Express credit card.
b) Retrieve the inserted row using a view. What happened? Was the row successfully inserted into the
table?
c) Change the view so that it doesn't allow inserting/modifying rows that won't be visible through it.
d) Insert a MasterCard credit card. What happened? Was the row successfully inserted into the table?
e) Change the view to allow inserting/modifying rows that won't be visible through it.
f) Remove the view.
*/



select * from CreditCard

create view v3
as
select * from CreditCard 
where CreditCard.Type = 'Visa' or CreditCard.Type= 'MasterCard'


select * from v3 where Type = 'American Express'


--a)


insert into v3 (Type,CardNumber,ExpirationMonth,ExpirationYear) values ('American Express', 55552127249720, 1, 1790)

select * from CreditCard where ExpirationYear = 1790

--c)

alter view v3
as
select * from CreditCard 
where CreditCard.Type = 'Visa' or CreditCard.Type= 'MasterCard'
with check option 


insert into v3 (Type,CardNumber,ExpirationMonth,ExpirationYear) values ('American Express', 55552127249700, 8, 1791)


insert into v3 (Type,CardNumber,ExpirationMonth,ExpirationYear) values ('MasterCard', 55552127249720, 1, 1790)


drop view v3



/*EX05

Create a view that retrieves the top 10 best-selling products. The columns returned by the view should
be ID and name and the total amount of products sold.
a) See the SELECT query view through the interface and using the sp_helptext system procedure.
b) Protect your view.
c) See the SELECT query view through the interface and using the sp_helptext system procedure.
d) Change the view so that it is protected and tightly bound to the tables.
e) Change the view so that it is protected, tightly bound to the tables, and does not allow changes that
will not be visible through the view.
f) Remove the view.
*/



select * from Product
select * from InvoiceItem

create view v5
as
select top 10
	p.IDProduct,
	p.Name as ProductName,
	sum(ii.TotalPrice) as Price,
	count(p.IDProduct) as NumOfProducts
from InvoiceItem as ii
inner join Product as p on p.IDProduct= ii.ProductID
group by p.Name, p.IDProduct
order by sum(ii.TotalPrice) desc


select * from v5

--a)


execute sp_helptext v5

--b)

alter view v5 with encryption 
as
select top 10
	p.IDProduct,
	p.Name as ProductName,
	sum(ii.TotalPrice) as Price,
	count(p.IDProduct) as NumOfProducts
from InvoiceItem as ii
inner join Product as p on p.IDProduct= ii.ProductID
group by p.Name, p.IDProduct
order by sum(ii.TotalPrice) desc


--d)

alter  view v5 with schemabinding
as
select top 10
	p.IDProduct,
	p.Name as ProductName,
	sum(ii.TotalPrice) as Price,
	count(p.IDProduct) as NumOfProducts
from dbo.InvoiceItem as ii
inner join dbo.Product as p on p.IDProduct= ii.ProductID
group by p.Name, p.IDProduct
order by sum(ii.TotalPrice) desc


--e)


alter  view v5 with schemabinding, encryption
as
select top 10
	p.IDProduct,
	p.Name as ProductName,
	sum(ii.TotalPrice) as Price,
	count(p.IDProduct) as NumOfProducts
from dbo.InvoiceItem as ii
inner join dbo.Product as p on p.IDProduct= ii.ProductID
group by p.Name, p.IDProduct
order by sum(ii.TotalPrice) desc
with check option



drop view v5

