DECLARE
  geor SDO_GEORASTER;
BEGIN
  for r in (select * from us_rasters where georid = 1 order by georid)
  loop
    geor := r.georaster;

    /*
    Given this TFW:

    VALUE               MEANING                COEFFICIENT
    ------------------  --------------------   -----------
    0.3048010000        (x pixel resolution)   A
    0.0000000000        (y rotation)           B
    0.0000000000        (x rotation)           D
    -0.3048010000       (y pixel resolution)   E
    1828468.0721379998  (x upper left)         C
    646446.1264909999   (y upper left)         F

    xCoefficients:
    A = 0.3048010000        (x pixel resolution)
    B = 0.0000000000        (y rotation)
    C = 1828468.0721379998  (x upper left)

    yCoefficients:
    D = 0.0000000000        (x rotation)
    E = -0.3048010000       (y pixel resolution)
    F = 646446.1264909999   (y upper left)

    */

    sdo_geor.geoReference (
      georaster               => geor,
      srid                    => sdo_geor.getModelSRID(geor),
      modelCoordinateLocation => case sdo_geor.getModelCoordLocation(geor)
                                   when 'CENTER' then 0
                                   when 'UPPERLEFT' then 1
                                 end,
      xCoefficients           => sdo_number_array(
        0.3048010000,         -- A = x pixel resolution
        0.0000000000,         -- B = y rotation
        1828468.0721379998    -- C = x upper left
      ),
      yCoefficients           => sdo_number_array(
        0.0000000000,         -- D = x rotation
        -0.3048010000,        -- E = y pixel resolution
        646446.1264909999     -- F = y upper left
      )
    );

    UPDATE us_rasters SET georaster = geor WHERE georid = r.georid ;
  end loop;
END;
/
