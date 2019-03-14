/*============================================================
// Source via Bradley Ball :: braball@micrsoft.com
// References: Paul Randal :: http://bit.ly/e3wgxX
//MSDN Blogs > SQL Server Storage Engine > How to use DBCC PAGE >How to use DBCC PAGE >by Paul Randal
// MIT License
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ""Software""), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: 
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
==============================================================*/

USE demoCOMPRESSION_Partition
GO

/*
Create a Heap Table
*/
IF EXISTS(SELECT * FROM sys.tables WHERE name='heap1')
BEGIN
	DROP TABLE dbo.heap1
END
CREATE TABLE heap1(myID int, myChar CHAR(8000));
GO

/*
Insert Some Records
*/
SET NOCOUNT ON;
DECLARE @i INT
SET @i=0

BEGIN TRAN
	WHILE (@i<3000)
		BEGIN
			SET @i = @i +1
			INSERT INTO dbo.heap1(myID, mychar)
			VALUES(@i,'myData');
			

		END
COMMIT TRAN

/*
View the Records 
a little out of order
*/

SELECT
	*
FROM
	dbo.heap1

/*
view difference between heap performance and clustered index performance
Turn on Execution Plan
*/
dbcc dropcleanbuffers
go
set statistics io on
select
	*
from
	dbo.heap1 
where myid=500
	
/*
Build a Clustered Index
*/
set statistics io off
go
CREATE CLUSTERED INDEX clx_pw_heap ON dbo.heap1(myid)
	

/*
View the in order
*/
SELECT
	*
FROM
	dbo.heap1
go

/*
view the difference in record retrieval performance
*/
dbcc dropcleanbuffers
go
set statistics io on
go
SELECT
	*
FROM
	dbo.heap1
where myid=500	


/*
Create a Heap Table
*/
set statistics io off
go
IF EXISTS(SELECT * FROM sys.tables WHERE name='myTable2')
BEGIN
	DROP TABLE dbo.myTable2
END
CREATE TABLE myTable2(
	myID int IDENTITY(1,1)
	,myChar CHAR(800)
	,PRIMARY KEY CLUSTERED(myID) );
GO

/*
Insert Some Records
*/
DECLARE @i INT
SET @i=0

BEGIN TRAN
	WHILE (@i<10)
		BEGIN
			INSERT INTO dbo.myTable2(mychar)
			VALUES('myData');
			SET @i = @i +1

		END
COMMIT TRAN


DBCC IND(demoCOMPRESSION_Partition, 'myTable2', 1)
go

DBCC TRACEON(3604)
go
/*
Set Trace 3604 On So We
Get Output to SSMS
Then take a look at the Page

dbcc page ( {'dbname' | dbid}, filenum, pagenum [, printopt={0|1|2|3} ])
0 - print just the page header 
1 - page header plus per-row hex dumps and a dump of the page slot array (unless its a page that doesn't have one, like allocation bitmaps) 
2 - page header plus whole page hex dump 
3 - page header plus detailed per-row interpretation
*/
--look at a data page
DBCC PAGE('demoCOMPRESSION_Partition', 1, 376, 3)
go 
--look at an index non-leaf page
DBCC PAGE('demoCOMPRESSION_Partition', 1, 377, 3)
go 


/*
Now let's take a looking using a DMV
instead of using DBCCIND
*/
SELECT
	*
FROM
	sys.dm_db_database_page_allocations(db_id(), object_id('mytable2'), 1, 1, 'DETAILED')

SELECT
	pa.extent_file_id
	,pa.extent_page_id
	,pa.allocated_page_iam_file_id
	,pa.allocated_page_iam_page_id
	,pa.[object_id]
	,pa.index_id
	,pa.[partition_id]
	,pa.allocation_unit_type_desc
	,pa.page_type
	,pa.page_level
	,pa.next_page_file_id
	,pa.next_page_page_id
	,pa.previous_page_file_id
	,pa.previous_page_page_id
FROM
	sys.dm_db_database_page_allocations(db_id(), object_id('mytable2'), 1, 1, 'DETAILED') pa

/*
add more rows
use the DMV to find Page Type 1's and Page Type 2's
*/
DECLARE @i INT
SET @i=0

BEGIN TRAN
	WHILE (@i<3000)
		BEGIN
			INSERT INTO dbo.myTable2(mychar)
			VALUES('myData');
			SET @i = @i +1

		END
COMMIT TRAN
/*
find page type 2's
*/
SELECT
	pa.extent_file_id
	,pa.extent_page_id
	,pa.allocated_page_iam_file_id
	,pa.allocated_page_iam_page_id
	,pa.[object_id]
	,pa.index_id
	,pa.[partition_id]
	,pa.allocation_unit_type_desc
	,pa.page_type
	,pa.page_level
	,pa.next_page_file_id
	,pa.next_page_page_id
	,pa.previous_page_file_id
	,pa.previous_page_page_id
FROM
	sys.dm_db_database_page_allocations(db_id(), object_id('mytable2'), 1, 1, 'DETAILED') pa
WHERE
	pa.page_type=2 and pa.page_level>0

/*
Find all Data pages
Type 1
*/
SELECT
	pa.extent_file_id
	,pa.extent_page_id
	,pa.allocated_page_iam_file_id
	,pa.allocated_page_iam_page_id
	,pa.[object_id]
	,pa.index_id
	,pa.[partition_id]
	,pa.allocation_unit_type_desc
	,pa.page_type
	,pa.page_level
	,pa.next_page_file_id
	,pa.next_page_page_id
	,pa.previous_page_file_id
	,pa.previous_page_page_id
FROM
	sys.dm_db_database_page_allocations(db_id(), object_id('mytable2'), 1, 1, 'DETAILED') pa
WHERE
	pa.page_type=1 and pa.page_level=0