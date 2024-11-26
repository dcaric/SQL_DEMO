---INDEXES

use AdventureWorksENG

--LECTURE 6

--for turning on the printing of DBCC messages
DBCC TRACEON(3604)


select * from Product
dbcc ind('AdventureWorksENG', 'Product',-1)
DBCC PAGE('AdventureWorksENG', 1, 80, 3) WITH TABLERESULTS

--Number of pages: count where PageType(data page) is 1
--Serial numbers of pages: PID
--How are pages sorted: PID


--TREES

/*Arrange the numbers from 1 to 20 into a B-tree where each node can
contain 2 elements. Describe the process of finding the numbers 7, 15
and 20. How many nodes must be visited to find each number?*/


--INDEX LECTURE 07

SET STATISTICS IO ON
--LOGICAL READ(STO MANJI BR TO BOLJE)

/*Optimize the query:
SELECT SubcategoryID FROM Product WHERE SubcategoryID = 12
a. How many data pages RDBMS use?
b. Create an index that optimizes the query
c. How many data pages RDBMS now use?
d. Remove the index*/

SELECT SubcategoryID FROM Product WHERE SubcategoryID = 12
--28 rows affected

--Table 'Product'. Scan count 1, 
--logical reads 10

create nonclustered index i1 on Product(SubcategoryID)
go

SELECT SubcategoryID FROM Product WHERE SubcategoryID = 12
drop index Product.i1
--logical reads 2

/*2. Optimize the query:
SELECT ProductID, SubcategoryID FROM Product WHERE SubcategoryID = 12*/



SELECT IDProduct, SubcategoryID FROM Product WHERE SubcategoryID = 12
---10 log reads


create nonclustered index i2 on Product(SubcategoryID)
go

--2 log reads
drop index Product.i2



/*3. Optimize the query:
SELECT IDProduct, Name, SubcategoryID FROM Product WHERE SubcategoryID = 12
Does the index from the previous example help us? What to do with the Name column?
*/

SELECT IDProduct, Name, SubcategoryID FROM Product WHERE SubcategoryID = 12
create nonclustered index i3 on Product(SubcategoryID)
drop index Product.i3
go


/*4. Optimize the query:
SELECT IDProduct, Name, SubcategoryID
FROM Product WHERE SubcategoryID = 12 AND Name LIKE 'ML%'
*/




SELECT IDProduct, Name, SubcategoryID
FROM Product WHERE SubcategoryID = 12 AND Name LIKE 'ML%'
--log reads 10

CREATE NONCLUSTERED INDEX i4 ON Product(SubcategoryID) INCLUDE (Name)
--2 log reads


drop index Product.i4
go

/*5. Optimize the query:
SELECT Color, COUNT(*) AS Cnt
FROM Product WHERE SubcategoryID = 12 GROUP BY Color ORDER BY Cnt DESC
*/

SELECT Color, COUNT(*) AS Cnt
FROM Product WHERE SubcategoryID = 12 GROUP BY Color ORDER BY Cnt DESC
--10 log reads

create nonclustered index i5 on Product(SubcategoryID) include(Color)
--2 log reads

drop index Product.i5
go

/*6. Optimize the query:
SELECT InvoiceDate FROM Invoice
WHERE InvoiceDate BETWEEN '20010702' AND '20010702 23:59:59'
*/


SELECT InvoiceDate FROM Invoice
WHERE InvoiceDate BETWEEN '20010702' AND '20010702 23:59:59'
--202 logical reads


create nonclustered index i6 on Invoice(InvoiceDate) 
--2 log reads

drop index Invoice.i6
go

/*7. Optimize the query:
SELECT IDInvoice, InvoiceDate FROM Invoice
WHERE InvoiceDate BETWEEN '20010702' AND '20010702 23:59:59'
*/

SELECT IDInvoice, InvoiceDate FROM Invoice
WHERE InvoiceDate BETWEEN '20010702' AND '20010702 23:59:59'
--202 logical reads


create nonclustered index i7 on Invoice(InvoiceDate) 
--2 log reads

drop index Invoice.i7
go


/*8. Optimize the query:
SELECT IDInvoice,InvoiceNumber, InvoiceDate FROM Invoice
WHERE InvoiceDate BETWEEN '20010702' AND '20010702 23:59:59'
*/

SELECT IDInvoice,InvoiceNumber, InvoiceDate FROM Invoice
WHERE InvoiceDate BETWEEN '20010702' AND '20010702 23:59:59'
--202 logical reads


create nonclustered index i8 on Invoice(InvoiceDate) 
--10 log reads

drop index Invoice.i8
go


/*9. Optimize the query:
SELECT IDInvoice FROM Invoice
WHERE InvoiceDate BETWEEN '20010702' AND '20010702 23:59:59'
AND InvoiceNumber LIKE 'S%'
*/

SELECT IDInvoice FROM Invoice
WHERE InvoiceDate BETWEEN '20010702' AND '20010702 23:59:59'
AND InvoiceNumber LIKE 'S%'
--202


create nonclustered index i9 on Invoice(InvoiceDate) include (InvoiceNumber)
--2 log reads


drop index Invoice.i9 
go

/*10. Optimize the query:
SELECT CustomerID, COUNT(*) AS Cnt FROM Invoice
WHERE InvoiceDate BETWEEN '20010702' AND '20010702 23:59:59'
GROUP BY CustomerID ORDER BY Cnt DESC
*/

set statistics io on

SELECT CustomerID, COUNT(*) AS Cnt FROM Invoice
WHERE InvoiceDate BETWEEN '20010702' AND '20010702 23:59:59'
GROUP BY CustomerID ORDER BY Cnt DESC
--202

create nonclustered index i10 on Invoice(InvoiceDate)
include (CustomerID)
--2 


drop index Invoice.i10


