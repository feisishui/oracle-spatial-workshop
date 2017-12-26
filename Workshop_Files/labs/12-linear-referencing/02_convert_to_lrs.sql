-- Convert US_INTERSTATES_LRS to LRS geometries

-- Note: Make sure there are no spatial indexes when this
-- operation is done
declare
  status varchar2(32);
begin
  status := sdo_lrs.convert_to_lrs_layer(
    'US_INTERSTATES_LRS',
    'GEOM',
    0,
    1000000,
    0.5
  );
end;
/
commit;

-- create a spatial index
create index us_interstates_lrs_sx on us_interstates_lrs (geom) indextype is mdsys.spatial_index;
