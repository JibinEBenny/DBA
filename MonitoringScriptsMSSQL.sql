EXEC sp_who2;
EXEC sp_who2 active;
EXEC sp_whoisactive;   --Info includes full SQL queries, query plans, hardware usage, temp DB allocations, blocks and more.
EXEC sp_WhoIsActive @get_plans = 1;  -- To get execution plans

DBCC INPUTBUFFER(<SPID>);  --find SPID and run,Shows the query executed by a session:
DBCC SQLPERF(LOGSPACE); --Shows log/data space usage
---------------------------------------------------------------------------------------------------------------------------------------------------------
--track all running operations (backup, restore, DBCC) in Microsoft SQL Server(automatically shows any operation with progress)
--If no rows returned then No long-running operation currently

SELECT 
    r.session_id,
    DB_NAME(r.database_id) AS database_name,
    r.command,
    r.percent_complete,
    r.start_time,
    r.total_elapsed_time / 1000 AS elapsed_seconds,
    r.estimated_completion_time / 1000 AS remaining_seconds
FROM sys.dm_exec_requests r
WHERE r.percent_complete > 0;  

--The bleow query will show the percentage of the particular session (very usefull while index REBUILD,REORGANZE)

SELECT 
    session_id, 
    percent_complete, 
    command, 
    status, 
    wait_type 
FROM sys.dm_exec_requests 
WHERE session_id = <session ID>;
---------------------------------------------------------------------------------------------------------------------------------------------------------
--List databases with size info
---------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
    DB.name,
    SUM(CASE WHEN [type] = 0 THEN MF.size * 8 / 1024 ELSE 0 END) AS DataFileSizeMB,
    SUM(CASE WHEN [type] = 1 THEN MF.size * 8 / 1024 ELSE 0 END) AS LogFileSizeMB
FROM
    sys.master_files MF
    JOIN sys.databases DB ON DB.database_id = MF.database_id
WHERE DB.source_database_id is null -- Exclude snapshots
GROUP BY DB.name
ORDER BY DataFileSizeMB DESC
---------------------------------------------------------------------------------------------------------------------------------------------------------
--TO CHECK THE LOG, DIFF, FULL BACKUPS
---------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT  top 115 a.server_name, a.database_name, backup_finish_date, a.backup_size,
CASE a.[type] -- Let's decode the three main types of backup here
 WHEN 'D' THEN 'Full'
 WHEN 'I' THEN 'Differential'
 WHEN 'L' THEN 'Transaction Log'
 ELSE a.[type]
END as BackupType
 ,b.physical_device_name
from msdb.dbo.backupset a join msdb.dbo.backupmediafamily b
  on a.media_set_id = b.media_set_id
where a.database_name Like 'S%' and a.[type] in ('L')
order by a.backup_finish_date desc
