create or replace package body raster_util as

function getCellGeom (
  georaster sdo_georaster, 
  pyramidlevel number, 
  modelGeom sdo_geometry
)
return sdo_geometry
as
  cellGeom sdo_geometry;
begin
  sdo_geor.getCellCoordinate(
    georaster,
    pyramidLevel,
    modelGeom,
    cellGeom
  );
  return cellGeom;
end;

function getModelGeom (
  georaster sdo_georaster, 
  pyramidlevel number, 
  cellGeom sdo_geometry
)
return sdo_geometry
as
  modelGeom sdo_geometry;
begin
  sdo_geor.getModelCoordinate(
    georaster,
    pyramidLevel,
    cellGeom,
    modelGeom    
  );
  return modelGeom;
end;

function get_cells (
  raster        sdo_georaster,
  window        sdo_geometry,
  bands         varchar2,
  pyramidLevel  number default 0
)
return cell_table pipelined
as
  cell_window sdo_geometry;
  cell_mbr sdo_geometry;
  row_min number;
  row_max number;
  col_min number;
  col_max number;
  cells sdo_number_array;
begin
  if window.sdo_srid is null then
    cell_window := window;
  else
    sdo_geor.getCellCoordinate(
      raster,
      pyramidLevel,
      window,
      cell_window
    );
  end if;
  cell_mbr := sdo_geom.sdo_mbr(cell_window);
  row_min := cell_mbr.sdo_ordinates(1);
  col_min := cell_mbr.sdo_ordinates(2);
  row_max := cell_mbr.sdo_ordinates(3);
  col_max := cell_mbr.sdo_ordinates(4);
  for c in col_min..col_max loop
    for r in row_min..row_max loop
      cells := sdo_geor.getcellvalue(       
        georaster => raster, 
        pyramidLevel => pyramidlevel,
        rowNumber => r,
        colNumber => c,
        bands => bands
      );
      for b in 1..cells.count loop
        pipe row (
          cell (
            r, c, b-1, cells(b)
          )
        );
      end loop;
    end loop;
  end loop;
end;

function get_cells (
  raster        sdo_georaster,
  window        sdo_number_array,
  bands         varchar2,
  pyramidLevel  number default 0
)
return cell_table pipelined
as
  row_min number;
  row_max number;
  col_min number;
  col_max number;
  cells sdo_number_array;
begin
  row_min := window(1);
  col_min := window(2);
  row_max := window(3);
  col_max := window(4);
  for c in col_min..col_max loop
    for r in row_min..row_max loop
      cells := sdo_geor.getcellvalue(       
        georaster => raster, 
        pyramidLevel => pyramidlevel,
        rowNumber => r,
        colNumber => c,
        bands => bands
      );
      for b in 1..cells.count loop
        pipe row (
          cell (
            r, c, b-1, cells(b)
          )
        );
      end loop;
    end loop;
  end loop;
end;

end;
/
show errors
