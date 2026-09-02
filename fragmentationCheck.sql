--BEFORE CHECKING THE FRAGMENTAION IT IS BETTER TO KNOW THE LARGEST TABLE IN THE DB

----------------------------------------------------------------------------------------------------------------------------------------------------
-- This query checks for the table and their sizes in descending order for the particular db 
----------------------------------------------------------------------------------------------------------------------------------------------------
SELECT TOP 10 
    CONCAT(SCHEMA_NAME(t.schema_id), '.', t.name) AS [table],
    CAST(SUM(a.used_pages * 8) / 1024.0 AS NUMERIC(36, 2)) AS used_mb,
    CAST(SUM(a.total_pages * 8) / 1024.0 AS NUMERIC(36, 2)) AS allocated_mb
FROM sys.tables AS t
JOIN sys.indexes AS i 
    ON t.object_id = i.object_id
JOIN sys.partitions AS p 
    ON i.object_id = p.object_id 
    AND i.index_id = p.index_id
JOIN sys.allocation_units AS a 
    ON p.partition_id = a.container_id
GROUP BY CONCAT(SCHEMA_NAME(t.schema_id), '.', t.name)
ORDER BY SUM(a.used_pages) DESC;

-- This query checks for the table size of a particular table
----------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
    t.name AS TableName,
    SUM(a.total_pages) * 8 / 1024 AS TotalSizeMB,
    SUM(a.used_pages) * 8 / 1024 AS UsedSizeMB,
    SUM(a.data_pages) * 8 / 1024 AS DataSizeMB
FROM sys.tables t
INNER JOIN sys.indexes i 
    ON t.object_id = i.object_id
INNER JOIN sys.partitions p 
    ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a 
    ON p.partition_id = a.container_id
WHERE t.name = 'YourTableName'  -- Replace with your table name
GROUP BY t.name;

----------------------------------------------------------------------------------------------------------------------------------------------------
-- Query to check fragmentation for the particular table
----------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
    OBJECT_NAME(ips.object_id) AS table_name,
    i.name AS index_name,
    ips.index_type_desc,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.YourTableName'), NULL, NULL, 'DETAILED') AS ips
JOIN sys.indexes AS i
    ON ips.object_id = i.object_id
   AND ips.index_id = i.index_id
ORDER BY ips.avg_fragmentation_in_percent DESC;

--LIMITED     Scans only the parent-level pages of the B-tree; leaf pages are not read. For a heap, it examines PFS/IAM pages and scans the data pages.
--SAMPLED   --It returns statistics based on a 1 percent sample of all the pages in the index or heap
--DETAILED   –-It scans all pages and returns all statistics.

----------------------------------------------------------------------------------------------------------------------------------------------------
-- Query to check fragmentation for the particular DB .Check index fragmentation for all indexes in the current database
----------------------------------------------------------------------------------------------------------------------------------------------------
SELECT  
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.index_type_desc,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'DETAILED') AS ips
JOIN sys.indexes AS i
    ON ips.object_id = i.object_id
    AND ips.index_id = i.index_id
WHERE ips.database_id = DB_ID()
  AND ips.index_id > 0 -- Exclude heaps
  AND ips.page_count > 100 -- Ignore very small indexes
ORDER BY ips.avg_fragmentation_in_percent DESC;
