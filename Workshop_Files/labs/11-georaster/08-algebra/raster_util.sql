create type cell as object (
  row_number     number,
  column_number  number,
  band_number    number,
  cell_value     number
);
/
create type cell_table as table of cell;
/

create or replace package raster_util as

function getCellGeom (
  georaster sdo_georaster, 
  pyramidlevel number, 
  modelGeom sdo_geometry
)
return sdo_geometry;

function getModelGeom (
  georaster sdo_georaster, 
  pyramidlevel number, 
  cellGeom sdo_geometry
)
return sdo_geometry;

function get_cells (
  raster        sdo_georaster,
  window        sdo_geometry,
  bands         varchar2,
  pyramidLevel  number default 0
)
return cell_table pipelined;
 
function get_cells (
  raster        sdo_georaster,
  window        sdo_number_array,
  bands         varchar2,
  pyramidLevel  number default 0
)
return cell_table pipelined;

end;
/
show errors
