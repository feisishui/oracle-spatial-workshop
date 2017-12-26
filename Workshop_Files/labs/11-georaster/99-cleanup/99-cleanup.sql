drop table us_rasters purge;
drop table us_rasters_rdt_01 purge;

delete from user_sdo_geom_metadata where table_name = 'US_RASTERS';
commit;
