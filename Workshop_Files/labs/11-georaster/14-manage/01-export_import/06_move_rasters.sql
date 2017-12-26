-- Create a new raster table
create table us_rasters_2011 (
  georid            number primary key,
  source_file       varchar2(80),
  description       varchar2(256),
  georaster         sdo_georaster,
  load_duration     number,
  pyramid_duration  number
);
 
-- Copy the rasters
declare
  gr sdo_georaster;
begin
  for g in (
    select *
    from us_rasters
    where georid <= 2
  )
  loop
    insert into us_rasters_2011 (georid, source_file, description, georaster)
    values (
      g.georid,
      g.source_file,
      g.description,
      sdo_geor.init (
        g.georaster.RASTERDATATABLE,
RASTERID
    gr := g.georaster;
    sdo_geor.deletePyramid(gr);
    update us_rasters
      set georaster=gr where georid=g.georid;
    commit;
  end loop;
end;
/


DECLARE
  gr1 sdo_georaster;
  gr2 sdo_georaster;
BEGIN
  INSERT INTO georaster_table VALUES (11, sdo_geor.init('RDT_11', 1))
    RETURNING georaster INTO gr2;
  SELECT georaster INTO gr1 from georaster_table WHERE georid=1;

  sdo_geor.copy(gr1, gr2);
  UPDATE georaster_table SET georaster=gr2 WHERE georid=11;
  COMMIT;
END;
/

