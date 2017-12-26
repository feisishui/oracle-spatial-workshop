create or replace function fast_intersection (
  geom1 sdo_geometry,
  geom2 sdo_geometry,
  tolerance number
) 
return sdo_geometry
deterministic
as
  relation varchar2(40);
  intersection_geom sdo_geometry;
begin
  -- determine how the two geometries relate
  relation := sdo_geom.relate (
    geom1, 'DETERMINE', geom2, tolerance
  );
  -- Only compute intersection when necessary
  intersection_geom := 
  case
     when relation in ('COVEREDBY', 'INSIDE')
       then geom1
     when relation in ('COVERS', 'CONTAINS')
       then geom2
     else
       sdo_geom.sdo_intersection (geom1, geom2, tolerance)            
   end;
   return intersection_geom;
end;
/
show errors

