create or replace function set_collection (
  query_crs   SYS_REFCURSOR;
)
return sdo_geometry deterministic
as
  geom        sdo_geometry;
  geom_array  sdo_geometry;
begin
  geom_array := null;
  loop
    fetch query_crs into geom;
      exit when query_crs%notfound;
    if geom_array is null then
      geom_array := geom;
    else
      geom_array := sdo_util.append (geom_array, geom);
    end if;
  end loop;
  return geom_array;
end;
/
