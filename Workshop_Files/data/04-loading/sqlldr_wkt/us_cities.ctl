LOAD DATA
 TRUNCATE
 INTO TABLE us_cities
 FIELDS TERMINATED BY '|' (
   id,
   city,
   state_abrv,
   pop90,
   rank90,
   wkt,
   location EXPRESSION "sdo_geometry (:wkt, 8307)"
 )
