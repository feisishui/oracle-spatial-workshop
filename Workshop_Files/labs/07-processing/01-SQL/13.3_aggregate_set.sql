-- Fast aggregation (11g)
-- Elapsed: 00:00:26.89 - with VPA: 00:00:03.94
CREATE OR REPLACE FUNCTION geometry_array (
  query_crs   SYS_REFCURSOR
)
RETURN SDO_GEOMETRY_ARRAY deterministic
AS
  geom        sdo_geometry;
  geom_array  sdo_geometry_array;
BEGIN
  geom_array := sdo_geometry_array();
  LOOP
    FETCH query_crs into geom;
      EXIT when query_crs%NOTFOUND ;
    geom_array.extend;
    geom_array(geom_array.count) := geom;
  END LOOP;
  RETURN geom_array;
END;
/

-- Elapsed: 00:00:26.89 - with VPA: 00:00:03.94
insert into aggregate_tests
select 4.1, sdo_aggr_set_union (
  geometry_array (
     cursor (select geom from us_counties)
  ),
  0.5
)
from dual;
