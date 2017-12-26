LOAD DATA
 TRUNCATE
 INTO TABLE input_points
 FIELDS TERMINATED BY ',' (
   rid sequence,
   val_d1,
   val_d2,
   val_d3
)

