/*============================================================
// Source via Bradley Ball :: braball@micrsoft.com
// MIT License
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ""Software""), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: 
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY

==============================================================*/

USE demoCOMPRESSION_Partition
GO

/*
Copy To Another Window
USE demoCOMPRESSION_Partition
GO
SELECT
	*
FROM
	dbo.mytable1
*/

BEGIN TRANSACTION

UPDATE dbo.myTable1
SET productName='Microsoft Isolation Level Demo'
WHERE myid=400

ROLLBACK TRANSACTION        


/*
DMV's
Copy To Another Windows
SELECT 
der.session_id
,DB_NAME(der.database_id)
,der.blocking_session_id
,der.command
,der.status
,der.wait_type
,der.wait_resource
FROM sys.dm_exec_requests der
left join sys.dm_exec_sessions es
on der.session_id=es.session_id
WHERE DB_NAME(der.database_id)='demoCOMPRESSION_Partition'
and es.is_user_process=1


SELECT 
	session_id,
	status
FROM 
	sys.dm_exec_sessions 
WHERE 
	session_id=52

*/

/*
Copy To Another Window

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

USE demoCOMPRESSION_Partition
GO
SELECT
	*
FROM
	dbo.mytable1
WHERE
	myID=400
*/

ALTER DATABASE MyDatabase
SET ALLOW_SNAPSHOT_ISOLATION ON

ALTER DATABASE MyDatabase
SET READ_COMMITTED_SNAPSHOT ON

/*
q-how does the is_read_commited_snapshot_on differ
*/

select d.name,
d.snapshot_isolation_state, d.snapshot_isolation_state_desc, d.is_read_committed_snapshot_on 
from sys.databases d


