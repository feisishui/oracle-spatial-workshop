-- --------------------------------------------------------------
-- Projected 3D (compound) to long/lat 3D
-- --------------------------------------------------------------

SELECT sdo_cs.transform (
         SDO_GEOMETRY (
           3001, 7405, SDO_POINT_TYPE (442249, 111480, 8),
           null,null
         ),
         4327
       )
FROM   dual;

-- --------------------------------------------------------------
-- Long/lat 3D to projected 3D (comppund)
-- --------------------------------------------------------------

SELECT sdo_cs.transform (
         SDO_GEOMETRY (
           3001, 4327, SDO_POINT_TYPE (-1.400562, 50.9012567, 55.0693992),
           null,null
         ),
         7405
       )
FROM   dual;



-- --------------------------------------------------------------
-- Projected 2D to long/lat 2D
-- --------------------------------------------------------------

SELECT sdo_cs.transform (
         SDO_GEOMETRY (
           2001, 27700, SDO_POINT_TYPE (442249, 111480, null),
           null,null
         ),
         4326
       )
FROM   dual;

-- --------------------------------------------------------------
-- Long/lat 2D to projected 2D
-- --------------------------------------------------------------

SELECT sdo_cs.transform (
         SDO_GEOMETRY (
           2001, 4326, SDO_POINT_TYPE (-1.400562, 50.9012567, null),
           null,null
         ),
         27700
       )
FROM   dual;
