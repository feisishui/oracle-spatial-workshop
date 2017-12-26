col table_name for a10
col column_name for a12
SELECT l.table_name, l.column_name, l.segment_name, l.index_name, l.securefile, l.compression, s.bytes/1024/1024 mb
FROM user_lobs l, user_segments s
WHERE l.table_name = 'TIN_BLK_01'
AND l.column_name in ('POINTS', 'TRIANGLES')
AND s.segment_name = l.segment_name;