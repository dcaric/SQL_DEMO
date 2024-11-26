use AdventureWorksENG


--LO1( VIEWS AND TRIGGERS)


--EX01

/*1. Create a view that will return information on how many invoices do not
have an associated salesman who issued them. Write a command to
remove the view.*/


select * from Invoice


create view v1 
as
select 
	count(i.IDInvoice) as NumOfInvoices
from Invoice  as i
where i.SalesmanID is NULL
group by i.SalesmanID

select * from v1


drop view v1



--EX02

/*
Create a view that will return the invoice IDs for invoices issued in the
year 2002. Utilize the view to provide the user with the following
columns: invoice number, issue date, and the total amount(price) on the
invoice. Write a command to remove the view.*/


select * from Invoice
select * from InvoiceItem


create view v2 
as
select
	i.IDInvoice,
	i.InvoiceNumber,
	i.InvoiceDate,
    count(ii.Totalprice) as NumOfInvoices,
	sum(ii.Totalprice) as Totalprice
from Invoice as i
inner join InvoiceItem as ii on i.IDInvoice=ii.InvoiceID
where year(i.InvoiceDate) = 2002
group by 
	i.IDInvoice,
    i.InvoiceNumber,
    i.InvoiceDate


select * from v2
drop view v2

--EX03
/*
Create a view that returns all categories with the name Bicycles or Parts.
Users who use the view might add a category using the mentioned view,but later
they cannot find that category using the view. Modify the view 
to prevent such a problem.
*/

select * from Category
select * from Subcategory

create view v3
as
select 
	c.Name as CategoryName,
	s.Name as SubName
from Category as c
inner join Subcategory as s on s.CategoryID= c.IDCategory
where s.CategoryID = 1 or s.CategoryID = 2
with check option

select * from v3
drop view v3



--EX04
/*
Create a view that returns city names, countries, and the number of
customers living in each city. Utilize the view to retrieve the city with the
highest number of customers. It is possible that someone removes the
'City' table from the database, causing an error for users when using the
view, stating that it cannot find the table. Write commands to prevent
this kind of problem.
*/


select * from City
select * from State
select * from Customer

create view v4
as
select
	count(*) as NumOfCustomers,
	cc.Name as CityName,
	s.Name as Country
from Customer as c
inner join City as cc on cc.IDCity=c.CityID
inner join State as s on s.IDState=cc.StateID
group by 
	cc.Name,
	s.Name


select * from v4

alter view v4
as
select top 1
	count(*) as NumOfCustomers,
	cc.Name as CityName,
	s.Name as Country
from Customer as c
inner join City as cc on cc.IDCity=c.CityID
inner join State as s on s.IDState=cc.StateID
group by 
	cc.Name,
	s.Name
order by NumOfCustomers desc



alter view v4 with schemabinding
as
select top 1
	count(*) as NumOfCustomers,
	cc.Name as CityName,
	s.Name as Country
from dbo.Customer as c
inner join dbo.City as cc on cc.IDCity=c.CityID
inner join dbo.State as s on s.IDState=cc.StateID
group by 
	cc.Name,
	s.Name
order by NumOfCustomers desc


drop view v4

--EX05
/*Create a new table Log with columns LogID and Content. Create a
trigger on the Invoice table and associate it with all three events. In the
trigger, determine which event invoked it, and write that information to
Log in one of the forms, for example:
"A new record has been inserted into the Invoice table"
"A record has been deleted from the Invoice table"
"A record in the Invoice table has been changed
*/


select * from Log

drop table Log


CREATE TABLE Log
(
	LogID int IDENTITY(1,1) PRIMARY KEY,
	Content nvarchar(max),
)
GO


drop trigger t1 


create trigger t1 on Invoice
after insert, update, delete
as
if EXISTS(select * from inserted) and NOT EXISTS(select * from deleted)
begin
	insert into Log (Content) values ('A new record has been inserted into the Invoice table')
end
else if NOT EXISTS(select * from inserted) and EXISTS(select * from deleted)
begin
	insert into Log (Content) values ('A new record has been deleted into the Invoice table')
end
else if EXISTS(select * from inserted) and EXISTS(select * from deleted)
begin
		insert into Log (Content) values ('A new record in the Invoice table has been changed')
end
GO


select * from Invoice
INSERT INTO Invoice(InvoiceDate, InvoiceNumber,CustomerID) VALUES (getdate(), 'SO88888',378)

select * from Log


drop trigger t1


--EX06

/*
Create a new trigger and associate it with the INSERT and UPDATE
events on the Subcategory table. If an UPDATE event occurs, assume
that the Name field will be modified. Let the trigger behave as follows: If
a row is inserted, write to the Log: "A new row has been inserted into the
Subcategory table." If more than one row is changed, write to the Log:
"Multiple subcategory names have been changed." If only one row is
changed, write to the Log a message with the subcategory ID, along with
the old and new values of the Name field in the following format:
"Change for subcategory IDSubcategory. Old name: Name, new name:
Name."*/


select * from Subcategory


CREATE TRIGGER t6 ON Subcategory
AFTER INSERT, UPDATE
AS 
BEGIN
  IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		INSERT INTO Log (Content) VALUES ('A new row has been inserted into the Subcategory table.')
	END
  ELSE IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
	BEGIN
	IF (SELECT COUNT(*) FROM INSERTED) > 1
		BEGIN
			INSERT INTO Log (Content) VALUES ('Multiple subcategory names have been changed.')
		END
	ELSE 
		BEGIN
			INSERT INTO Log (Content)
            SELECT    
                'Change for subcategory ID ' + CAST(D.IDSubcategory AS VARCHAR) +
                '. Old name: ' + D.Name + ', new name: ' + I.Name
            FROM INSERTED I
            JOIN DELETED D on  I.IDSubcategory = D.IDSubcategory
		END
	END
END
go


select * from Subcategory

insert into Subcategory (CategoryID, Name) values (1, 'Bike 1')
insert into Subcategory (CategoryID, Name) values (1, 'Bike 3')


select * from Log

update  Subcategory set Name = 'Bike 4' where Name = 'Bike 2'
update  Subcategory set Name = 'Bike 33' where Name = 'Bike 3'

drop trigger t6