---------------------------------------------------------------------------------------------------------------------------------------------------------
-- REORGANIZE
---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Run with reorganize only on DEV & TEST environments because it will take time according to the size 

ALTER INDEX IDX_ERROR_DETAIL_ErrorGUID ON dbo.ERROR_DETAIL REORGANIZE;

-- Use REORGANIZE for moderate fragmentation (≈5–30%) when minimal blocking is required.
-- Reorganize is always an online operation. This means long-term object-level locks aren't held and queries or updates to the underlying table

---------------------------------------------------------------------------------------------------------------------------------------------------------
-- REBUID
---------------------------------------------------------------------------------------------------------------------------------------------------------
ALTER INDEX IX_Employee_LastName ON HumanResources.Employee REBUILD;

-- Use REBUILD for heavy fragmentation (>30%) or when you need updated statistics and faster completion on large indexes.
-- It can be online or offline . If online it will not affect the underlaying table else it will affect the table it will not be able to read or write
-- Requires enough disk space to hold both old and new index copies during the process.
