SELECT 
tb_a.TABLE_NAME, tb_a.TABLE_SCHEMA, tb_c.CONSTRAINT_NAME, tb_c.CONSTRAINT_TYPE, -- this line can be dropped
 CASE
    WHEN tb_c.CONSTRAINT_TYPE IS NULL THEN concat('exec sys.sp_cdc_enable_table @source_schema = N''',tb_a.TABLE_SCHEMA,''', @source_name = N''', tb_a.TABLE_NAME,''', @role_name = NULL GO')
    WHEN tb_c.CONSTRAINT_TYPE='PRIMARY KEY' THEN concat('exec sys.sp_cdc_enable_table @source_schema = N''',tb_a.TABLE_SCHEMA,''', @source_name = N''', tb_a.TABLE_NAME,''', @role_name = NULL, @supports_net_changes = 1 GO')
    WHEN tb_c.CONSTRAINT_TYPE='UNIQUE' THEN concat('exec sys.sp_cdc_enable_table @source_schema = N''',tb_a.TABLE_SCHEMA,''', @source_name = N''', tb_a.TABLE_NAME,''', @index_name = N''', tb_c.CONSTRAINT_NAME, ''', @role_name = NULL, @supports_net_changes = 1 GO')
    END runner
FROM INFORMATION_SCHEMA.TABLES tb_a
LEFT JOIN (
        SELECT TABLE_NAME tb_name, CONSTRAINT_NAME, CONSTRAINT_TYPE FROM information_schema.table_constraints WHERE TABLE_SCHEMA='dbo' AND CONSTRAINT_TYPE IN ('unique', 'PRIMARY KEY')
    ) tb_c on tb_c.tb_name=tb_a.TABLE_NAME
WHERE TABLE_TYPE='BASE TABLE'
-- add other filters here if requered, example:
-- AND TABLE_SCHEMA='dbo'
ORDER BY CONSTRAINT_TYPE desc, TABLE_NAME -- just to have it clearer
