-- Create type used as output from the function
CREATE OR REPLACE TYPE closest_points_type AS OBJECT (
  distance  NUMBER, 
  point_1   sdo_geometry,
  point_2   sdo_geometry,
  line      sdo_geometry
);
/
show errors

-- Create the wrapper function
CREATE OR REPLACE FUNCTION closest_points (
  p_geom1     IN sdo_geometry,
  p_geom2     IN sdo_geometry,
  p_tolerance IN NUMBER,
  p_unit      IN VARCHAR2 default NULL
)
RETURN closest_points_type
IS
  v_distance   NUMBER;
  v_point_1    sdo_geometry;
  v_point_2    sdo_geometry;
  v_line       sdo_geometry;
BEGIN
  sdo_geom.sdo_closest_points (
    geom1     => p_geom1,
    geom2     => p_geom2,
    tolerance => p_tolerance,
    unit      => p_unit,
    dist      => v_distance,
    geoma     => v_point_1,
    geomb     => v_point_2
  );
  v_line := sdo_geometry (2002, v_point_1.sdo_srid, null,
    sdo_elem_info_array (1,2,1),
    sdo_ordinate_array (
      v_point_1.sdo_point.x,
      v_point_1.sdo_point.y,
      v_point_2.sdo_point.x,
      v_point_2.sdo_point.y
    )
  );
  RETURN closest_points_type(v_distance, v_point_1, v_point_2, v_line);
END;
/
show errors

-- Find the closest points in counties Passaic and Hudson in New Jersey
select closest_points (c1.geom, c2.geom, 0.5, 'unit=km') cp
from us_counties c1, us_counties c2
where c1.state_abrv='NJ' and c1.county='Passaic'
and  c2.state_abrv='NJ' and c2.county='Hudson';

select t.cp.distance, t.cp.point_1, t.cp.point_2, t.cp.line
from (
  select closest_points (c1.geom, c2.geom, 0.5, 'unit=km') cp
  from us_counties c1, us_counties c2
  where c1.state_abrv='NJ' and c1.county='Passaic'
  and  c2.state_abrv='NJ' and c2.county='Hudson'
) t;

