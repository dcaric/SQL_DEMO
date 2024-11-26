--LO3

use AdventureWorksENG

/*1. The administrator requested the creation of three procedures (one for
insertion, one for updating, and one for deletion) and one function in the
database for the purpose of CRUD operations on the InvoiceItem table.
In doing so, please ignore records from subordinate tables. Use the
created objects to create an example of inserting, updating, retrieving,
and deleting an InvoiceItem.
EXEC pCrud @id = @NewID OUTPUT, 
	@idInvoice = 43659, @q = 1, @pId = 776, @price= 888.99, @d = 00.00, @TotalP = 888.99000 
PRINT @NewID
go


database, specifically for the needs of the deletion CRUD operation in
the Invoice table. This procedure should consider records from
subordinate tables and delete them as well. Use the created procedure
to provide an example of deleting an invoice along with associated
records in subordinate tables.