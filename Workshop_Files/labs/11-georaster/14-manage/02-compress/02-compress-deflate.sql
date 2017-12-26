delete from us_rasters where georid between 1000 and 1999;
 
insert into us_rasters (georid, source_file, description, georaster)
  values (
   1001,
   'sf1.tif',
   'Aerial photo San Francisco 1 - compressed deflate',
   sdo_geor.init('US_RASTERS_RDT_01', 1001)
  );
insert into us_rasters (georid, source_file, description, georaster)
  values (
   1002,
   'sf2.tif',
   'Aerial photo San Francisco 2 - compressed deflate',
   sdo_geor.init('US_RASTERS_RDT_01', 1002)
  );
insert into us_rasters (georid, source_file, description, georaster)
  values (
   1004,
   'sf4.tif',
   'Aerial photo San Francisco 4 - compressed deflate',
   sdo_geor.init('US_RASTERS_RDT_01', 1004)
  );
insert into us_rasters (georid, source_file, description, georaster)
  values (
   1005,
   'sf5.tif',
   'Aerial photo San Francisco 5 - compressed deflate',
   sdo_geor.init('US_RASTERS_RDT_01', 1005)
  );
commit;


DECLARE
  geor_compressed SDO_GEORASTER;
BEGIN
  for r in (select * from us_rasters where georid < 1000 order by georid)
  loop
    SELECT georaster INTO geor_compressed FROM us_rasters WHERE georid = 1000+r.georid;
    SDO_GEOR.changeFormatCopy(r.georaster, 'compress=deflate', geor_compressed);
    UPDATE us_rasters SET georaster=geor_compressed WHERE georid = 1000+r.georid;
    commit;
  end loop;
END;
/
