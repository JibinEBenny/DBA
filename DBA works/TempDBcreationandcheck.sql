-- To list the files for a database with name , physical name, type, state, size this will give the current tempDB and its details : 


      SELECT DB_NAME(database_id) AS db,
             name            AS logical_name,
             physical_name,
             type_desc,
             state_desc,
             CAST(size * 8.0 / 1024 / 1024 AS DECIMAL(10,2)) AS size_gb
      FROM sys.master_files
      ORDER BY db, type_desc;


--
