-- Create feature table for gaps and overlaps

DROP TABLE TOPO_ERRORS purge;
CREATE TABLE TOPO_ERRORS (
  ID          NUMBER PRIMARY KEY,
  TYPE        VARCHAR2(10),
  FEATURE     SDO_TOPO_GEOMETRY
);

BEGIN
  SDO_TOPO.ADD_TOPO_GEOMETRY_LAYER(
    'US_LAND_USE',
    'TOPO_ERRORS',
    'FEATURE',
    'POLYGON');
END;
/

-- Fill table with gaps (=all faces without any associated feature)
insert into TOPO_ERRORS
select face_id,
       'GAP',
       SDO_TOPO_GEOMETRY (
         'US_LAND_USE',
         'TOPO_ERRORS',
         'FEATURE',
         3,
         SDO_TOPO_OBJECT_ARRAY (SDO_TOPO_OBJECT(face_id,3))
       )
from   us_land_use_face$
where  face_id not in (
  select topo_id 
  from us_land_use_relation$ 
  where topo_type = 3
)
and    face_id >= 0
order  by face_id;

-- Fill table with overlaps (= all faces shared by several area features)
insert into TOPO_ERRORS
select face_id,
       'OVERLAP',
       SDO_TOPO_GEOMETRY (
         'US_LAND_USE',
         'TOPO_ERRORS',
         'FEATURE',
         3,
         SDO_TOPO_OBJECT_ARRAY (SDO_TOPO_OBJECT(face_id,3))
       )
from   US_LAND_USE_face$ f, US_LAND_USE_relation$ r
where  f.face_id = r.topo_id
and    r.topo_type = 3
group  by f.face_id
having count(*) > 1;

-- List errors: geometries and area
select id, type,
       sdo_geom.sdo_area(e.feature.get_geometry(),0.005,'unit=sq_km'),
       e.feature.get_geometry()
  from TOPO_ERRORS e
order  by id;
