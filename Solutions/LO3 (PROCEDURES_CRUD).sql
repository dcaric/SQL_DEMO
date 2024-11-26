--LO3

use AdventureWorksENG

/*1. The administrator requested the creation of three procedures (one for
insertion, one for updating, and one for deletion) and one function in the
database for the purpose of CRUD operations on the InvoiceItem table.
In doing so, please ignore records from subordinate tables. Use the
created objects to create an example of inserting, updating, retrieving,
and deleting an InvoiceItem.*/goselect * from InvoiceItemcreate proc pCrud(	@id int output ,	@idInvoice int,	@q int,	@pId int,	@price money,	@d money,	@TotalP numeric)asinsert into InvoiceItem(InvoiceID,Quantity,ProductID,InitialPrice,Discount,TotalPrice)values (@idInvoice,@q,@pId,@price,@d,@TotalP)set @id = SCOPE_IDENTITY()godrop proc pCrudDECLARE @NewID int
EXEC pCrud @id = @NewID OUTPUT, 
	@idInvoice = 43659, @q = 1, @pId = 776, @price= 888.99, @d = 00.00, @TotalP = 888.99000 
PRINT @NewID
go

/*The administrator has requested the creation of a procedure in the
database, specifically for the needs of the deletion CRUD operation in
the Invoice table. This procedure should consider records from
subordinate tables and delete them as well. Use the created procedure
to provide an example of deleting an invoice along with associated
records in subordinate tables.*/select * from InvoiceItemcreate proc pD(	@Id int)asdelete from Invoicewhere IDInvoice = @Idgodrop proc pD