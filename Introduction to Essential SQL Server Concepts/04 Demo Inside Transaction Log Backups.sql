/*============================================================
// Source via Bradley Ball :: braball@micrsoft.com
// MIT License
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ""Software""), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: 
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY

==============================================================*/
/*
--Full Recovery and the transaction log
1. perform a full backup
2. perform a log backup
3. look at the log using dbcc sqlperf & dbcc loginfo
4. do an index rebuild
5. backup the log file
6. Look at the size of the log file & dbcc sqlperf
7. do an index rebuild
8. look at the used space in the using sqlperf
9. do a checkpoint
10. look at the used space using sql perf
11. do a full backup
12. look at the used space using sql perf
13. do a log backup
14. start a transaction to insert some rows
15. look at the log space using sql perf
16. do a log backup
17. look at sql perf again
18. commit the tran
19. look at sql perf
20. do a log backup
--Piecemeal recovery
1. do a full backup
2. restore fgs primary, 1, 2,3, 4
3. do a query that hits fg1, fg2, fg3, fg4,& fg5
4. finish the restore
*/

/*
Let's Take a full backup of
our Database in Full Recovery
and then take a log backup
*/
BACKUP DATABASE demoInternals_Partition TO DISK=N'/var/opt/mssql/data/demoInternals_Partition.bak' WITH INIT, stats=10
GO
BACKUP LOG demoInternals_Partition TO DISK=N'/var/opt/mssql/data/demoInternals_Partition1.trn' WITH INIT, stats=10
GO
/*
Look at the log
*/
DBCC SQLPERF(LOGSPACE)
GO
USE demoInternals_Partition
GO
DBCC LOGINFO
/*
Let's rebuild an index and create some logged records
*/
USE demoInternals_Partition
GO
DBCC SQLPERF(LOGSPACE)
GO
ALTER INDEX PK_myTable1_myID ON dbo.myTable1 REBUILD
GO
DBCC SQLPERF(LOGSPACE)
GO
/*
Backup the Log and check the sqlperf stats
*/
BACKUP LOG demoInternals_Partition TO DISK=N'/var/opt/mssql/data/demoInternals_Partition2.trn' WITH INIT, stats=10
GO
DBCC SQLPERF(LOGSPACE)
GO
/*
Rebuild the index and try a checkpoint
*/
ALTER INDEX PK_myTable1_myID ON dbo.myTable1 REBUILD
GO
DBCC SQLPERF(LOGSPACE)
GO
/*
let's see if a checkpoint will clear the log
*/
CHECKPOINT
GO
DBCC SQLPERF(LOGSPACE)
GO
/*
do I really need to to transaction log
backups can't I just do a full backup on the DB in full 
recovery model and that will clear the log?
*/
BACKUP DATABASE demoInternals_Partition TO DISK=N'/var/opt/mssql/data/demoInternals_Partition.bak' WITH INIT, stats=10
GO
DBCC SQLPERF(LOGSPACE)
GO
/*
Backup our Log
*/
BACKUP LOG demoInternals_Partition TO DISK=N'/var/opt/mssql/data/demoInternals_Partition3.trn' WITH INIT, stats=10
GO
DBCC SQLPERF(LOGSPACE)
GO
/*
--EXECUTE IN ANOTHER WINDOW
--Imitate inserts or long running index rebuilds
DECLARE @i INT
SET @i=0

BEGIN TRAN
WHILE (@i<20000)
	BEGIN
		INSERT INTO myTable1 DEFAULT VALUES;
		SET @i = @i +1

	END
--COMMIT TRAN
*/
DBCC SQLPERF(LOGSPACE)
GO
BACKUP LOG demoInternals_Partition TO DISK=N'/var/opt/mssql/data/demoInternals_Partition3.trn' WITH INIT, stats=10
GO
DBCC SQLPERF(LOGSPACE)
GO
dbcc loginfo
/*
Commit the transaction on the 
Other window
*/
DBCC SQLPERF(LOGSPACE)
GO
BACKUP LOG demoInternals_Partition TO DISK=N'/var/opt/mssql/data/demoInternals_Partition3.trn' WITH INIT, stats=10
GO
DBCC SQLPERF(LOGSPACE)
GO