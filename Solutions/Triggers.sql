use AdventureWorksENG

--TRIGGERS-----------

--LAB03

--exaample:

--Declare the variables @FirstName and @LastName and assign them some values.
--Display the assigned values.

declare @FirstName nvarchar(100)
declare @LastName nvarchar(100)
set @FirstName = 'Paola'
set @LastName = 'Caric'


PRINT @FirstName
PRINT @LastName
PRINT 'User: ' + @FirstName + ' ' + @LastName
go--prekine kod povise

--example2

declare @FirstName nvarchar(100)
declare @LastName nvarchar(100)

select @FirstName =FirstName, @LastName = LastName from Customer where IDCustomer = 16

print @FirstName
print @LastName
go

--example3

declare @FirstName nvarchar(100)
declare @LastName nvarchar(100)

select @FirstName =FirstName, @LastName = LastName from Customer 

print @FirstName
print @LastName
go


--TRIGGER EXAMPLES



/*create database LogBase
use LogBase


CREATE TABLE Log
(
	IDLog int IDENTITY(1,1) PRIMARY KEY,
	Message nvarchar(max),
	Time datetime DEFAULT getdate()
)
GO
*/

--EX

use AdventureWorksENG


CREATE TABLE Log
(
	IDLog int IDENTITY(1,1) PRIMARY KEY,
	Message nvarchar(max),
	Time datetime DEFAULT getdate()
)
GO

--1. Create a trigger that will write to the Log table whenever insert in the City table happens.create trigger t1 on City after insertas insert into Log (Message) values ('Insert into city')goINSERT INTO City (Name, StateID) VALUES ('City 1', 1)


select* from Log

--2. Change the trigger so that it logs the first name and last name of the inserted student.alter trigger t1 on City after  insertas declare @ID intdeclare @Name nvarchar(50)select @ID= IDCity, @Name = Name from insertedinsert into Log (Message) VALUES ('Insert into City. IDCity: ' + CAST(@ID as nvarchar(50)) + ', Name: ' + @Name)

INSERT INTO City (Name, StateID) VALUES ('City 2', 1)

select * from Log
go


--3. Change the trigger so that it binds to all events and writes the number of rows in the inserted and
--deleted tables to the Log table. Insert a new student, change all students’ last names and finally
--delete all students.



alter trigger t1 on City after  insert, update, delete
as
declare @i int
declare @d int
select @i = count(*) from inserted
select @d = count(*) from deleted
insert into Log (Message) VALUES ('Inserted: ' + CAST(@i as nvarchar(20)) + ', Delected: ' + cast(@d as nvarchar(20)))

INSERT INTO City (Name, StateID) VALUES ('City 3', 1)
INSERT INTO City (Name, StateID) VALUES ('City 4', 1)
SELECT * FROM Log

UPDATE City SET StateID = 2 WHERE Name LIKE 'City%'
SELECT * FROM Log

DELETE FROM City WHERE Name LIKE 'City%'
SELECT * FROM Log


--5
disable trigger t1 on  City

enable trigger t1 on City


--6. 
/*Add a new trigger to the City table and bind it to all three events. In the trigger, find out which
event is called it and write that information in the Log table. Do the insertion, modification, and
deletion.*/

create trigger t2 on City after insert, update, delete
as
IF EXISTS(SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted) BEGIN
	-- INSERT.	
	INSERT INTO Log (Message) VALUES ('INSERT happend')
END
 ELSE IF NOT EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted) BEGIN
	-- DELETE.
	INSERT INTO Log (Message) VALUES ('DELETE happend')
END
ELSE IF EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted) BEGIN
	-- UPDATE.
	INSERT INTO Log (Message) VALUES ('UPDATE happend')
END
go

INSERT INTO City (Name, StateID) VALUES ('City 5', 1)
SELECT * FROM Log

UPDATE City SET Name = 'Ilok' WHERE IDCity = 1
SELECT * FROM Log

DELETE FROM City WHERE IDCity = 76
SELECT * FROM Log
GO


disable trigger t2 on City


--7
/*Disable all triggers on the City table. Add a new trigger and bind it to the UPDATE event.
Define the trigger to record that an event occurred only if the Lastname column was changed.*/



create trigger t3 on City after update
as
if update(StateID) begin
	INSERT INTO Log (Message) VALUES ('StateID column updated')
end
go

UPDATE City SET Name = 'Šibenik' WHERE IDCity = 1
SELECT * FROM Log

UPDATE City SET StateID = 3 WHERE IDCity = 1
SELECT * FROM Log

disable trigger t3 on City


drop trigger t1
drop trigger t2
drop trigger t3

--8
/*. Remove all triggers on the City table. Add 4 new triggers that print “Hello from number n" to
the log after inserting a row. Insert a row. Arrange the trigger order so that it is 4, 2, 3, 1. Insert a
row. Restore the original order. Insert a row. Remove triggers.*/

DROP TRIGGER t1
DROP TRIGGER t2
DROP TRIGGER t3
DROP TRIGGER t4


create trigger t1 on City after insert
as
insert into Log(Message) values ('Hello from num 1')
go

CREATE TRIGGER t2 ON City AFTER INSERT AS
INSERT INTO Log (Message) VALUES ('Hello from number 2')
GO

CREATE TRIGGER t3 ON City AFTER INSERT AS
INSERT INTO Log (Message) VALUES ('Hello from number 3')
GO

CREATE TRIGGER t4 ON City AFTER INSERT AS
INSERT INTO Log (Message) VALUES ('Hello from number 4')
GO

INSERT INTO City (Name, StateID) VALUES ('City 6', 1)
SELECT * FROM Log
GO

EXEC sp_settriggerorder 't4', 'FIRST', 'INSERT'
EXEC sp_settriggerorder 't1', 'LAST', 'INSERT'
GO

INSERT INTO City (Name, StateID) VALUES ('City 7', 1)
SELECT * FROM Log
GO

EXEC sp_settriggerorder 't4', 'NONE', 'INSERT'
EXEC sp_settriggerorder 't1', 'NONE', 'INSERT'
GO

INSERT INTO City (Name, StateID) VALUES ('City 8', 1)
SELECT * FROM Log
GO


--9
/*
Create tables Tbl1 and Tbl2 with arbitrary columns. On Tbl1, create a trigger associated with
INSERT, which inserts a row in Tbl2 and in the Log table. On Tbl2, create a trigger related to
INSERT, which inserts a row in Tbl1 and in the Log table. What happened?
*/

CREATE TABLE Tbl1
(
	Column1 int PRIMARY KEY IDENTITY,
	Column2 nvarchar(50)
)

CREATE TABLE Tbl2
(
	Column1 int PRIMARY KEY IDENTITY,
	Column2 nvarchar(50)
)



create trigger t1 on Tbl1 after insert
as
insert into Log (Message) values ('Trigger 1 from table 1')
insert into Tbl2 values ('inserted into second table')
go

create trigger t2 on Tbl2 after insert
as
insert into Log (Message) values ('Trigger 2 from table 2')
insert into Tbl1 values ('inserted into first table')
go




INSERT INTO Tbl1 VALUES ('Insert into first table')
SELECT * FROM Log
GO

SELECT * FROM Tbl1
SELECT * FROM Tbl2
SELECT * FROM Log

--sistem se srusia


