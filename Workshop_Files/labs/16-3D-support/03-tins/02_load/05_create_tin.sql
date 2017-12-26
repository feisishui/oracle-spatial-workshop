declare
  tin         sdo_tin;
begin

  -- Initialize the TIN object
  tin := sdo_tin_pkg.init (
    basetable            => 'TINS',                 -- Table that has the SDO_TIN column defined
    basecol              => 'TIN',                  -- Column name of the SDO_TIN object
    blktable             => 'TIN_BLK_01',           -- Table to store blocks of the TIN
    ptn_params           => 'blk_capacity=12000',   -- max # of points per block
    tin_extent           =>
    sdo_geometry(3008, 32617, null,
      sdo_elem_info_array(1,1007,3),
      sdo_ordinate_array(
        289021, 4320940, 166,
        290106, 4323640, 216
      )
    ),                                            -- extent
    tin_tol              => 0.5,                    -- Tolerance
    tin_tot_dimensions   => 3                       -- Dimensions
  );

  -- Generate the TIN from point cloud. This will fill the TIN blocks table
  sdo_tin_pkg.create_tin (
    tin,              -- Initialized TIN object
    'INPUT_POINTS'    -- Name of input table containing the points
  );

  -- Write the TIN to he tTIN table
  insert into tins (id, tin)
  values (1, tin);
end;
/
