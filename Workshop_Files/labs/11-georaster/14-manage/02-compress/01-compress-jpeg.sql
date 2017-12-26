delete from us_rasters where georid between 2000 and 2999;
 
insert into us_rasters (georid, source_file, description, georaster)
  values (
   2001,
   'sf1.tif',
   'Aerial photo San Francisco 1 - compressed jpeg',
   sdo_geor.init('US_RASTERS_RDT_01', 2001)
  );
insert into us_rasters (georid, source_file, description, georaster)
  values (
   2002,
   'sf2.tif',
   'Aerial photo San Francisco 2 - compressed jpeg',
   sdo_geor.init('US_RASTERS_RDT_01', 2002)
  );
insert into us_rasters (georid, source_file, description, georaster)
  values (
   2004,
   'sf4.tif',
   'Aerial photo San Francisco 4 - compressed jpeg',
   sdo_geor.init('US_RASTERS_RDT_01', 2004)
  );
insert into us_rasters (georid, source_file, description, georaster)
  values (
   2005,
   'sf5.tif',
   'Aerial photo San Francisco 5 - compressed jpeg',
   sdo_geor.init('US_RASTERS_RDT_01', 2005)
  );
commit;


DECLARE
  geor_compressed SDO_GEORASTER;
BEGIN
  for r in (select * from us_rasters where georid < 1000 order by georid)
  loop
    SELECT georaster INTO geor_compressed FROM us_rasters WHERE georid = 2000+r.georid;
    SDO_GEOR.changeFormatCopy(r.georaster, 'compress=jpeg-b, quality=75', geor_compressed);
    UPDATE us_rasters SET georaster=geor_compressed WHERE georid = 2000+r.georid;
    commit;
  end loop;
END;
/

