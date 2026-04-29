EXEC sp_who2;
EXEC sp_who2 active;
DBCC INPUTBUFFER(<SPID>);  --find SPID and run,Shows the query executed by a session:
DBCC SQLPERF(LOGSPACE); --Shows log/data space usage
------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
------------------------------------------------------------------------------------------------------------------------------------------------------------------
