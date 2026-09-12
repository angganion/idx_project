RESTORE DATABASE sample
FROM DISK = '/backup/sample.bak'
WITH REPLACE,
     MOVE 'sample'     TO '/var/opt/mssql/data/sample.mdf',
     MOVE 'sample_log' TO '/var/opt/mssql/data/sample_log.ldf';