-- Create test table
drop table nurbs purge;
create table nurbs (
  id      number primary key,
  description  varchar2(40),
  geom    sdo_geometry
);

-- Populate it
insert into nurbs (id, description, geom)
values (
  1,
  'A single nurb with 7 control points',
  SDO_GEOMETRY(
    2002,
    NULL,
    NULL,
    SDO_ELEM_INFO_ARRAY(
      1,            -- Offset in ordinates array
      2,            -- Element type 2 = SDO_ETYPE_CURVE
      3             -- Interpretation value 3 = NURBS curve
    ),  
    SDO_ORDINATE_ARRAY (
      3,            -- d = Degree of the NURBS curve
      7,            -- m = Number of weighted Control Points
      0, 0, 1,      -- Control point 1 (x,y,w)
      -0.5, 1, 1,   -- Control point 2
      0.2, 2, 1,    -- Control point 3
      0.5, 3.5, 1,  -- Control point 4
      0.8, 2, 1,    -- Control point 5
      0.9, 1, 1,    -- Control point 6
      0.3, 0, 1,    -- Control point 7
      11,           -- n= Number of knot values (d+m+1)
      0, 0, 0, 0,  0.25, 0.5, 0.75, 1.0, 1.0, 1.0, 1.0
    )
  )
);

insert into nurbs (id, description, geom)
values (
  2,
  'A single nurb with 6 control points',
  SDO_GEOMETRY(
    2002,
    NULL,
    NULL,
    SDO_ELEM_INFO_ARRAY(
      1,            -- Offset in ordinates array
      2,            -- Element type 2 = SDO_ETYPE_CURVE
      3             -- Interpretation value 3 = NURBS curve
    ),  
    SDO_ORDINATE_ARRAY (
      3,            -- d = Degree of the NURBS curve
      6,            -- m = Number of weighted Control Points
      2,   2, 1,    -- Control point 1 (x,y,w)
      2.5, 1, 1,    -- Control point 2
      2.2, 2, 1,    -- Control point 3
      2.5, 3, 1,    -- Control point 4
      2.7, 2, 1,    -- Control point 5
      2.9, 3, 1,    -- Control point 6
      10,           -- n= Number of knot values (d+m+1)
      0, 0, 0, 0, 0.25, 0.5, 1.0, 1.0, 1.0, 1.0
    )
  )
);

insert into nurbs (id, description, geom)
values (
  3,
  'A multi-curve that contains a NURB',
  SDO_GEOMETRY(
    2006,
    NULL,
    NULL,
    SDO_ELEM_INFO_ARRAY(
      1,2,1,        -- Simple line
      5,2,3,        -- NURB
      36,2,1        -- Simple line
    ),  
    SDO_ORDINATE_ARRAY (
      3,2, 4,2,     -- Simple line
      3,            -- NURB: d = Degree of the NURBS curve
      6,            --   m = Number of weighted Control Points
      4,   2, 1,    --   Control point 1 (x,y,w)
      4.5, 1, 1,    --   Control point 2
      4.2, 2, 1,    --   Control point 3
      4.5, 3, 1,    --   Control point 4
      4.7, 2, 1,    --   Control point 5
      4.9, 3, 1,    --   Control point 6
      10,           --   n= Number of knot values
      0, 0, 0, 0, 0.25, 0.5, 1.0, 1.0, 1.0, 1.0
      4.9,3, 5.5,3  -- Simple line
    )
  )
);

insert into nurbs (id, description, geom)
values (
  4,
  'A multi-curve that contains two NURBs',
  SDO_GEOMETRY(
    2006,
    NULL,
    NULL,
    SDO_ELEM_INFO_ARRAY(
      1,2,1,        -- Simple line
      5,2,3,        -- NURB
      36,2,1,       -- Simple line
      40,2,3        -- NURB 
    ),  
    SDO_ORDINATE_ARRAY (
      3,2, 4,2,     -- Simple line
      3,            -- NURB: d = Degree of the NURBS curve
      6,            --   m = Number of weighted Control Points
      4,   2, 1,    --   Control point 1 (x,y,w)
      4.5, 1, 1,    --   Control point 2
      4.2, 2, 1,    --   Control point 3
      4.5, 3, 1,    --   Control point 4
      4.7, 2, 1,    --   Control point 5
      4.9, 3, 1,    --   Control point 6
      10,           --   n= Number of knot values
      0, 0, 0, 0, 0.25, 0.5, 1.0, 1.0, 1.0, 1.0
      4.9,3, 5.5,3, -- Simple line
      3,            -- NURB: d = Degree of the NURBS curve
      7,            --   m = Number of weighted Control Points
      0, 0, 1,      --   Control point 1 (x,y,w)
      -0.5, 1, 1,   --   Control point 2
      0.2, 2, 1,    --   Control point 3
      0.5, 3.5, 1,  --   Control point 4
      0.8, 2, 1,    --   Control point 5
      0.9, 1, 1,    --   Control point 6
      0.3, 0, 1,    --   Control point 7
      11,           --   n= Number of knot values
      0, 0, 0, 0,  0.25, 0.5, 0.75, 1.0, 1.0, 1.0, 1.0
    )
  )
);


insert into nurbs (id, description, geom)
values (
  5,
  'A compound curve without any NURB',
  SDO_GEOMETRY(
    2002,
    NULL,
    NULL,
    SDO_ELEM_INFO_ARRAY(
      1,4,3,        -- Compound curve header
      1,2,1,        -- Simple line (straight)
      3,2,2,        -- Simple line (arc)
      7,2,1         -- Simple line (straight)
    ),  
    SDO_ORDINATE_ARRAY (
      3,2, 4,2,     -- Simple line
      4.9,3, 5.5,3, -- Simple line (arc)
      6.3,7         -- Simple line
    )
  )
);

insert into nurbs (id, description, geom)
values (
  6,
  'A multicurve without any NURB',
  SDO_GEOMETRY(
    2006,
    NULL,
    NULL,
    SDO_ELEM_INFO_ARRAY(
      1,2,1,        -- Simple line
      5,2,1         -- Simple line
    ),  
    SDO_ORDINATE_ARRAY (
      3,2, 4,2,     -- Simple line
      4.9,3, 5.5,3  -- Simple line
    )
  )
);
 
commit;

col status for a30
select id, sdo_geom.validate_geometry_with_context(geom,0.005) status from nurbs;

-- Setup spatial metadata and spatial index
delete from user_sdo_geom_metadata where table_name = 'NURBS';
insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
values (
  'NURBS',
  'GEOM',
  sdo_dim_array (
    sdo_dim_element ('X', -100, 100, 0.005),
    sdo_dim_element ('Y', -100, 100, 0.005)
  ),
  null
);
commit;

drop index nurbs_sx;
-- create index nurbs_sx on nurbs (geom) indextype is mdsys.spatial_index;

-- Create a table with explicit densification
drop table nurbs_d purge;
create table nurbs_d (
  id     number,
  type   char(1),
  geom   sdo_geometry
);
insert into nurbs_d  
select id, 'D', sdo_util.getNurbsApprox(geom, 0.005) geom
from nurbs
union all
select id, 'L', get_nurb_info(geom, 'L') geom
from nurbs
union all
select id, 'P', get_nurb_info(geom, 'P') geom
from nurbs;

-- Setup spatial metadata and spatial index
delete from user_sdo_geom_metadata where table_name = 'NURBS_D';
insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
values (
  'NURBS_D',
  'GEOM',
  sdo_dim_array (
    sdo_dim_element ('X', -100, 100, 0.005),
    sdo_dim_element ('Y', -100, 100, 0.005)
  ),
  null
);
commit;
drop index nurbs_d_sx;
create index nurbs_d_sx on nurbs_d (geom) indextype is mdsys.spatial_index;

/*
select sdo_util.to_wktgeometry(geom) wkt,
       sdo_util.getNurbsApprox(geom, 0.005) approximation,
       sdo_util.to_gml311geometry(geom) gml
from nurbs;

select * from nurbs where sdo_filter (geom, sdo_geometry(2003,null,null,sdo_elem_info_array(1,1003,3),sdo_ordinate_array (-10,-10,10,10))) = 'TRUE';
select * from nurbs_d where sdo_filter (geom, sdo_geometry(2003,null,null,sdo_elem_info_array(1,1003,3),sdo_ordinate_array (-10,-10,10,10))) = 'TRUE';
*/
