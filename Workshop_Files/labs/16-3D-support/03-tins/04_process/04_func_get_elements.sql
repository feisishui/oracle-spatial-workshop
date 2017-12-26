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
  num_triangles number;
  triangle sdo_geometry;
begin
  num_triangles := g.sdo_elem_info (3);
  for i in 1..num_triangles loop
    triangle := sdo_geometry (3003, g.sdo_srid, null,
      sdo_elem_info_array (1, 1003, 1), sdo_ordinate_array());
    triangle.sdo_ordinates.extend(12);
    for j in 1..12 loop
      triangle.sdo_ordinates(j) := g.sdo_ordinates((i-1)*12+j);
    end loop;
    pipe row (sdo_geometry_row (i, triangle));
  end loop;
end;
/
show errors
