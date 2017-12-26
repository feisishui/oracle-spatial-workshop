ALTER TABLE us_counties
  ADD smpl_geom sdo_geometry;
begin
  SDO_SAM.SIMPLIFY_LAYER(
    theme_tablename       => 'US_COUNTIES',
    theme_colname         => 'GEOM',
    smpl_geom_colname     => 'SMPL_GEOM',
    commit_interval       => 100,
    pct_area_change_limit => 15
  );
end;
/
