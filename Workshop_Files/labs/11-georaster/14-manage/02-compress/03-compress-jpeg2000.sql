delete from us_rasters where georid between 3000 and 3999;
 
insert into us_rasters (georid, source_file, description, georaster)
  values (
   3001,
   'sf1.tif',
   'Aerial photo San Francisco 1 - compressed jpeg2000',
   sdo_geor.init('US_RASTERS_RDT_01', 3001)
  );
insert into us_rasters (georid, source_file, description, georaster)
  values (
   3002,
   'sf2.tif',
   'Aerial photo San Francisco 2 - compressed jpeg2000',
   sdo_geor.init('US_RASTERS_RDT_01', 3002)
  );
insert into us_rasters (georid, source_file, description, georaster)
  values (
   3004,
   'sf4.tif',
   'Aerial photo San Francisco 4 - compressed jpeg2000',
   sdo_geor.init('US_RASTERS_RDT_01', 3004)
  );
insert into us_rasters (georid, source_file, description, georaster)
  values (
   3005,
   'sf5.tif',
   'Aerial photo San Francisco 5 - compressed jpeg2000',
   sdo_geor.init('US_RASTERS_RDT_01', 3005)
  );
commit;


DECLARE
  geor_compressed SDO_GEORASTER;
BEGIN
  for r in (select * from us_rasters where georid < 1000 order by georid)
  loop
    SELECT georaster INTO geor_compressed FROM us_rasters WHERE georid = 3000+r.georid;
    SDO_GEOR.changeFormatCopy(r.georaster, 'compress=jp2-f, ratio=20', geor_compressed);
    UPDATE us_rasters SET georaster=geor_compressed WHERE georid = 3000+r.georid;
    commit;
  end loop;
END;
/
