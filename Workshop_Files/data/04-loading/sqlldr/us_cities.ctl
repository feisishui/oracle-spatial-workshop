LOAD DATA
 TRUNCATE
 INTO TABLE us_cities
 FIELDS TERMINATED BY '|' (
   id,
   city,
   state_abrv,
   pop90,
   rank90,
   location COLUMN OBJECT (
     sdo_gtype       CONSTANT 2001,
     sdo_srid        CONSTANT 8307,
     sdo_point COLUMN OBJECT (
        x            FLOAT EXTERNAL,
        y            FLOAT EXTERNAL
     )
   )
)
