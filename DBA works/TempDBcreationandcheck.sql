-- To list the files for a database with name , physical name, type, state, size this will give the current tempDB and its details : 

      SELECT DB_NAME(database_id) AS db,
             name            AS logical_name,
             physical_name,
             type_desc,
             state_desc,
             size * 8 / 1024 AS size_mb
             CAST(size * 8.0 / 1024 / 1024 AS DECIMAL(10,2)) AS size_gb
      FROM sys.master_files
      ORDER BY db, type_desc;

-- To check the tempDB files

      SELECT DB_NAME(database_id) AS db,
             name            AS logical_name,
             physical_name,
             type_desc,
             state_desc,
            size * 8 / 1024 AS size_mb, 
            CAST(size * 8.0 / 1024 / 1024 AS DECIMAL(10,2)) AS size_gb
      FROM sys.master_files
      WHERE database_id = DB_ID('tempdb');

-- check the service account in which they run at

      SELECT servicename, service_account
      FROM sys.dm_server_services;

-- Configured size (what tempdb returns to at restart)
-- Current size (what it has grown to)

      SELECT name, CAST(size * 8.0 / 1024 / 1024 AS DECIMAL(10,2)) AS configured_gb
      FROM sys.master_files
      WHERE database_id = DB_ID('tempdb');

      SELECT name, CAST(size * 8.0 / 1024 / 1024 AS DECIMAL(10,2)) AS current_gb
      FROM tempdb.sys.database_files;

-- If you want a smaller size than the current one 
-- Say tempdb is currently 8 GB and you want 4 GB. MODIFY FILE with a smaller size gives an error. Your options:

      DBCC SHRINKFILE (tempdev, 4096); (size in MB)
      
-- which may not shrink fully if tempdb is busy.
-- Or restart SQL Server. Tempdb is rebuilt at the configured size, but you first need the configured size set to the smaller value, 
-- and MODIFY FILE rejects that while the file is larger. So shrink first, then set the size.
-----------------------------------------------------------------------------------------+
--                         Workload Typical tempdb size                                  |
-----------------------------------------------------------------------------------------+
--    Light OLTP	                                       |       1 to 2% of largest DB   |
--    Mixed OLTP + reporting	                           |       5 to 10%                |
--    Heavy analytics, large sorts, ETL	               |       10 to 25%               |
--    OLAP / data warehouse (relational SQL queries)     |       15 to 25%               |
-----------------------------------------------------------------------------------------+
            
-- Make the original file match 

      ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev, SIZE = 16GB, FILEGROWTH = 1GB);

-- All data files should be the same size and growth setting

      ALTER DATABASE tempdb ADD FILE (NAME = tempdev2, FILENAME = 'T:\TempDB\tempdb2.ndf', SIZE = 16GB, FILEGROWTH = 1GB);
      ALTER DATABASE tempdb ADD FILE (NAME = tempdev3, FILENAME = 'T:\TempDB\tempdb3.ndf', SIZE = 16GB, FILEGROWTH = 1GB);
      ALTER DATABASE tempdb ADD FILE (NAME = tempdev4, FILENAME = 'T:\TempDB\tempdb4.ndf', SIZE = 16GB, FILEGROWTH = 1GB);
