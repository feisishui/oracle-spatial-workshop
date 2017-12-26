CREATE OR REPLACE TYPE gc_result as object (
  id number,
  geo_addr sdo_geo_addr,
  accuracy number
);
/
show errors

CREATE OR REPLACE TYPE gc_result_table AS TABLE OF gc_result;
/
show errors
