insert into us_rasters (georid, source_file, description, georaster)
  values (1, 'sf1.tif', 'Aerial photo San Francisco 1', sdo_geor.init('US_RASTERS_RDT_01', 1));
insert into us_rasters (georid, source_file, description, georaster)
  values (2, 'sf2.tif', 'Aerial photo San Francisco 2', sdo_geor.init('US_RASTERS_RDT_01', 2));
insert into us_rasters (georid, source_file, description, georaster)
  values (3, 'sf3.tif', 'Aerial photo San Francisco 3', sdo_geor.init('US_RASTERS_RDT_01', 3));
insert into us_rasters (georid, source_file, description, georaster)
  values (4, 'sf4.tif', 'Aerial photo San Francisco 4', sdo_geor.init('US_RASTERS_RDT_01', 4));
commit;
