create or replace type sdo_geometry_row as object (
  element_id    number,
  element_geom  sdo_geometry
);
/

create or replace type sdo_geometry_table as table of sdo_geometry_row;
/

create or replace function get_elements (g sdo_geometry) return sdo_geometry_table
pipelined
as
begin
  for i in 1..sdo_util.getnumelem(g) loop
    pipe row (
      sdo_geometry_row (
        i,
        sdo_util.extract(g,i)
      )
    );
  end loop;
  return;
end;
/
show errors
