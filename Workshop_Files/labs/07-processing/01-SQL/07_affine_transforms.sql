-- Enlarge county passaic around its centroid
SELECT
sdo_util.affinetransforms(
  geometry => geom,
  translation => 'FALSE',
    tx => 0.0,
    ty => 0.0,
    tz => 0.0,
  scaling => 'TRUE',
    psc1 => sdo_geom.sdo_centroid(c.geom, 0.5),
    sx => 2.0,
    sy => 2.0,
    sz => 0.0,
  rotation => 'FALSE',
    p1 => NULL,
    line1 => NULL,
    angle => 0,
    dir => 0,
  shearing => 'FALSE',
    shxy => 0.0,
    shyx => 0.0,
    shxz => 0.0,
    shzx => 0.0,
    shyz => 0.0,
    shzy => 0.0,
  reflection => 'FALSE',
    pref => NULL,
    lineR => NULL,
    dirR => 0,
    planeR => 'FALSE',
    n => SDO_NUMBER_ARRAY(0),
    bigD => SDO_NUMBER_ARRAY(0)
)
FROM  us_counties_p c
WHERE c.county = 'Passaic'
AND   c.state_abrv = 'NJ';
