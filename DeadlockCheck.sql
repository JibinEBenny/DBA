------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Reads deadlock graphs captured automatically by SQL Server
        
SELECT 
    XEventData.XEvent.value('(event/data/value)[1]', 'varchar(max)') AS DeadlockGraph
FROM (
    SELECT CAST(target_data AS XML) AS TargetData
    FROM sys.dm_xe_session_targets st
    JOIN sys.dm_xe_sessions s 
        ON s.address = st.event_session_address
    WHERE s.name = 'system_health'
) AS Data
CROSS APPLY TargetData.nodes('//RingBufferTarget/event[@name="xml_deadlock_report"]') AS XEventData(XEvent);

-- By using SSMS
-- Go to Management → Extended Events → Sessions → system_health
-- Click View Target Data
-- Click Filter (funnel icon)
-- You can filter by Event name = xml_deadlock_report
------------------------------------------------------------------------------------------------------------------------------------------------------------------
