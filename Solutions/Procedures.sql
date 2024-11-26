--PROCEDURES + CRUD

/*
In a procedure, declare the variables @a and @b and give them the
values 50 and 0. Inside the TRY block, calculate @a / @b. Inside the
CATCH block, print information about the error that occurred.*/create proc p1 (	@a int,	@b int,	@c int output)asbegin try	set @c = @a / @bend trybegin catch	set  @c = 0	print error_message()end catchgodeclare @Result intexec p1 50, 5 , @Result outputprint @Result/*Create a table Type that has columns IDType (primary key, but not
IDENTITY) and TypeName. Create a procedure that receives IDType
and TypeName and inserts them into a table. Call the procedure twice
with the values 1 and "Penguin".
• Implement TRY/CATCH outside the procedure and call it.
• Implement TRY/CATCH inside the procedure and call it
*/


create table Type(

	ID int primary key,
	TypeName nvarchar(50)
)
go


create proc p2 (
	@IDType int,
	@TypeName nvarchar (50)
)
as
insert into Type (ID,TypeName) values (@IDType,@TypeName)
go


exec p2 1, 'Paola' 
select * from Type


begin try
	exec p2 1, 'Paola' 
	exec p2 1, 'Caric' 
end try
begin catch
	print error_message()
end catch
go


ALTER PROC p2 
	@IDType int,
	@TypeName nvarchar(50)
AS
BEGIN TRY
	INSERT INTO Type (ID, TypeName) VALUES (@IDType, @TypeName)
END TRY
BEGIN CATCH
	PRINT 'Error: ' + ERROR_MESSAGE()
	PRINT 'Type is not inserted.'
END CATCH
GO

EXEC p2 20, 'Penguin'
GO

drop table Type


/*
Create procedures 
that perform CRUD operations on the Student table by assigning a separate
procedure to each operation. Use procedures to create, update, retrieve,
and delete records.*/


create table student (

	ID int primary key identity,
	FirstName nvarchar(50),
	LastName nvarchar(50),
	JMBAG nvarchar(11)
)

go

drop proc pC 
create proc pC (
	@id int output,
	@fName nvarchar(50),
	@lName nvarchar (50),
	@jmbag nvarchar (11)
)
as 
insert into student(FirstName,LastName,JMBAG) values (@fName,@lName,@jmbag)
set @id = SCOPE_IDENTITY()
go

drop proc pC

DECLARE @NewIDStudent int
EXEC pC @id = @NewIDStudent OUTPUT, 
	@fName = 'Ana', @lName = 'Anić', @jmbag = '11224451253'
PRINT @NewIDStudent



create proc pR(
	@Name nvarchar(50)
)
as
select * from student where FirstName = @Name
go
drop proc pR


create proc pU(
	@id int output,
	@fName nvarchar(50),
	@lName nvarchar (50),
	@jmbag nvarchar (11)
)
as
update student
set FirstName = @fName, LastName =  @lName, JMBAG = @jmbag
where ID = @id
go


EXEC pU 1, 'Ana', 'Anić Mirić', '11224451253'
select * from student
drop proc pU


CREATE PROC pD(
	@id int
)
AS
DELETE FROM Student WHERE ID = @id
GO

EXEC pD 1
drop proc pD


-----------------------

/*
Create procedures that perform CRUD operations on the Student table by 
performing create, update,
and delete operations in one procedure and retrieval in another. 
Use procedures to create, update,
retrieve, and delete records.*/


CREATE PROC ChangeStudent(
	@Operation char(1),
	@id int OUTPUT, 
	@fName nvarchar(50), 
	@lName nvarchar(50), 
	@jmbag char(11)
)
AS 
if @Operation = 'U'
	update student
	set FirstName = @fName, LastName =  @lName, JMBAG = @jmbag
	where ID = @id
else if @Operation = 'C' begin
	insert into student(FirstName,LastName,JMBAG) values (@fName,@lName,@jmbag)
	set @id = SCOPE_IDENTITY()
	end	
else if @Operation = 'D'
	delete from student
	where ID = @id
go

DECLARE @NewIDStudent int
EXEC ChangeStudent 'C', @NewIDStudent OUTPUT, 'Ana', 'Anić', '11224451253'
PRINT @NewIDStudent

select * from student
drop proc ChangeStudent