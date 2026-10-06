-- If tempdb won't shrink, the cause is almost always something still holding space inside the file.
-- A shrink can only release space at the end of the file that is unallocated, so first find out what is using it.

-- See how much is actually used

      USE tempdb;
      SELECT name,
             CAST(size * 8.0 / 1024 / 1024 AS DECIMAL(10,2)) AS file_gb,
             CAST(FILEPROPERTY(name, 'SpaceUsed') * 8.0 / 1024 / 1024 AS DECIMAL(10,2)) AS used_gb
      FROM tempdb.sys.database_files;

-- See what is using tempdb

    SELECT SUM(user_object_reserved_page_count) * 8 / 1024 AS user_objects_mb,
           SUM(internal_object_reserved_page_count) * 8 / 1024 AS internal_objects_mb,
           SUM(version_store_reserved_page_count) * 8 / 1024 AS version_store_mb,
           SUM(unallocated_extent_page_count) * 8 / 1024 AS free_mb
    FROM tempdb.sys.dm_db_file_space_usage;

-- user_objects_mb	Temp tables, table variables still in use
-- internal_objects_mb	Sorts, hash spills, spools from running queries
-- version_store_mb	Row versions held by snapshot isolation / RCSI, often by a long open transaction

-- Find the sessions responsible

    SELECT TOP 10 s.session_id, s.login_name, s.host_name, s.status,
           (u.user_objects_alloc_page_count - u.user_objects_dealloc_page_count) * 8 / 1024 AS user_mb,
           (u.internal_objects_alloc_page_count - u.internal_objects_dealloc_page_count) * 8 / 1024 AS internal_mb
    FROM sys.dm_db_session_space_usage u
    JOIN sys.dm_exec_sessions s ON s.session_id = u.session_id
    ORDER BY ((u.user_objects_alloc_page_count - u.user_objects_dealloc_page_count)
        + (u.internal_objects_alloc_page_count - u.internal_objects_dealloc_page_count)) DESC;

-- Check for open transactions (version store)

    DBCC OPENTRAN('tempdb');
    
    SELECT TOP 5 transaction_id, elapsed_time_seconds, session_id
    FROM sys.dm_tran_active_snapshot_database_transactions
    ORDER BY elapsed_time_seconds DESC;
