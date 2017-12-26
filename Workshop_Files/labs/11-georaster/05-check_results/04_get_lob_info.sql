SELECT table_name, column_name, segment_name, index_name, securefile, compression
FROM user_lobs 
WHERE table_name = 'US_RASTERS_RDT_01';