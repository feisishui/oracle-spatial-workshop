/*
==========================================================================================
Coordinate transformations
==========================================================================================
*/

-- From a geographic point to a cell
select sdo_geor.getCellCoordinate(raster,0,sdo_geometry(2001,4326,sdo_point_type(2.3,45.7,null),null,null)) from temperature_table where id=2;
-- SDO_NUMBER_ARRAY(76, 367)

-- From a geographic shape to a set of cells
select raster_util.getCellGeom(
          raster,
          0, 
          sdo_geometry(
            2001,4326,null,
            sdo_elem_info_array (1,1003,3),
            sdo_ordinate_array (2.3,45.7, 3.0,46.2)
          )
        )
from temperature_table 
where id=2;
-- SDO_GEOMETRY(2001, NULL, NULL, SDO_ELEM_INFO_ARRAY(1, 1003, 1), SDO_ORDINATE_ARRAY(76, 367, 76, 368, 75, 368, 75, 367, 76, 367))

-- Using an arbitrary geometric shape
select getCellGeom(raster, 0, s.geom)
from temperature_table t, us_states s 
where t.id=2
and s.state_abrv = 'NY';

-- From a cell to a geographic point
select sdo_geor.getModelCoordinate(raster,0,sdo_number_array(76,367)) from temperature_table where id=2;
-- SDO_GEOMETRY(2001, 4326, SDO_POINT_TYPE(2.25, 45.75, NULL), NULL, NULL)

-- From a cell shape to a geographic shape
select raster_util.getModelGeom(
          raster,
          0, 
          sdo_geometry(
            2001,null,null,
            sdo_elem_info_array (1,1003,1),
            sdo_ordinate_array (76, 367, 76, 368, 75, 368, 75, 367, 76, 367)
          )
        )
from temperature_table 
where id=2;
-- SDO_GEOMETRY(2001, 4326, NULL, SDO_ELEM_INFO_ARRAY(1, 1003, 1), SDO_ORDINATE_ARRAY(2.25, 45.75, 2.75, 45.75, 2.75, 46.25, 2.25, 46.25, 2.25, 45.75))

-- Between pyramid levels
select sdo_geor.getCellCoordinate(raster,0,sdo_number_array(76, 367),1) from temperature_table where id=2;
-- SDO_NUMBER_ARRAY(38, 183)

/*
==========================================================================================
Getting cell values
==========================================================================================
*/

-- Get the value of one cell in all bands
select sdo_geor.getcellvalue(raster,0,76,367,'') from temperature_table where id=2;

-- Same for selected bands
select sdo_geor.getcellvalue(raster,0,76,367,'0,1,2,3,4,5') from temperature_table where id=2;
select sdo_geor.getcellvalue(raster,0,76,367,'0-2,6-8') from temperature_table where id=2;

-- One band:
select sdo_geor.getcellvalue(raster,0,76,367,'11') from temperature_table where id=2;
select sdo_geor.getcellvalue(raster,0,76,367,11) from temperature_table where id=2;
			    
-- Using a geometric point:
select sdo_geor.getcellvalue(raster,0,sdo_geometry(2001,4326,sdo_point_type(2.3,45.7,null),null,null),'') from temperature_table where id=2;

-- Using an arbitrary geographic point
select sdo_geor.getcellvalue(t.raster,0,c.location,'') 
from temperature_table t, us_cities c
where t.id=2
and city='New York';

-- Fetching multiple cells
-- In a range of rows and columns
select * from table(select raster_util.get_cells (raster, sdo_number_array(75,367,76,368),'0-3') from temperature_table where id = 2);
-- In a geometry
select * from table(select raster_util.get_cells (raster, sdo_geometry(2001,4326,null,sdo_elem_info_array (1,1003,3),sdo_ordinate_array (2.3,45.7, 3.0,46.2)),'0-3') from temperature_table where id = 2);
-- In a geometry from a table
select  distinct c.row_number, c.column_number, c.band_number, c.cell_value 
from    temperature_table t,
        us_states s,
        table (
          raster_util.get_cells (t.raster, s.geom,'0-3')
        ) c
where   t.id = 2
and     s.state_abrv in ('CO','UT','NV','CA');

/*
==========================================================================================
Updating cells
==========================================================================================
*/

-- Replace values in bands 1 and 2 in a cell-space range
DECLARE
  gr sdo_georaster;
BEGIN
  SELECT raster INTO gr FROM temperature_table WHERE id=2 FOR UPDATE;
  sdo_geor.changeCellValue(
    gr, 
    sdo_number_array(75,367,76,368), 
    '1-2', 
    -1
  );
  UPDATE temperature_table SET raster=gr WHERE id=2;
END;
/

-- Same in a geographic space: must use layer ids (band nr +1)
DECLARE
  gr sdo_georaster;
BEGIN
  SELECT raster INTO gr FROM temperature_table WHERE id=2 FOR UPDATE;
  sdo_geor.changeCellValue(
    gr, 
    sdo_geometry(
      2001,4326,null,
      sdo_elem_info_array (1,1003,3),
      sdo_ordinate_array (2.3,45.7, 3.0,46.2)
    ),
    '2-3', 
    -1
  );
  UPDATE temperature_table SET raster=gr WHERE id=2;
END;
/

/*
==========================================================================================
Some statistics
==========================================================================================
*/

-- NOTE: the statistics must have first been computed and stored in the raster object
-- using sdo_geor.generateStatistics() !

-- Get the min and max values for all layers / bands

select sdo_geor.getrasterrange(raster) from temperature_table where id=2;
-- SDO_NUMBER_ARRAY(-9999, 60.4757652)

-- for one layer (= band + 1)
select sdo_geor.getrasterrange(raster,1) from temperature_table where id=2;
-- SDO_NUMBER_ARRAY(-9999, 51.3773003)


