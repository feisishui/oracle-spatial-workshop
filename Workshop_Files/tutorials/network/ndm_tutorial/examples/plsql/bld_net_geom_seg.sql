
------------------------------
-- Main steps for building a network from Spatial geometry
-- data that is already segmented into line strings. 
------------------------------
-- 1. Prepare the example for running.
-- 2. Verify the input geometry data.
-- 3. Construct utility functions.
-- 4. Construct the network.
-- 5. Verify the constructed network.
-- 6. Clean up.

-- This example is adapted from the Oracle Spatial Topology
-- and Network Data Models Developer's Guide, Section 5.13.


-- 1. Prepare the example for running.

create table road(id number, shape mdsys.sdo_geometry);
insert into road(id, shape) values(1, 
  sdo_geometry(2002, null, null, sdo_elem_info_array(1,2,1),  
    sdo_ordinate_array(1,1,15,1)));
insert into road(id, shape) values(2, 
  sdo_geometry(2002, null, null, sdo_elem_info_array(1,2,1),
     sdo_ordinate_array(15,1,9,4)));                
insert into road (id, shape) values(3, 
  sdo_geometry(2002, null, null, sdo_elem_info_array(1,2,1), 
     sdo_ordinate_array(9,4,1,1)));      

--
-- 2. Verify the input geometry data.
--

-- Some of the input data is not correct w.r.t. to the type.
-- This self union fixes those inconsistencies 
update road a
  set a.shape = sdo_geom.sdo_union(a.shape, a.shape, 0.005)
  where a.shape.sdo_gtype = 2006;

-- make sure there are no multi-line string in the road segment
select id from road a where a.shape.sdo_gtype=2006;     

--
-- 3. Construct utility functions.
--

-- This is a utility function to return the end point of a geometry.
-- The second parameter determines which end point to return:
-- 0 returns the start point and 1 returns the end point.
create or replace function
  get_end_point (geom mdsys.sdo_geometry, idx number)
return MDSYS.SDO_GEOMETRY DETERMINISTIC
as
  g MDSYS.SDO_GEOMETRY;
  ct number;
begin

g := MDSYS.SDO_GEOMETRY(2001, geom.sdo_srid,
            MDSYS.SDO_POINT_TYPE(null,null,null),null,null);

if (idx = 0) then
  ct := 1;
else
  ct := geom.sdo_ordinates.count-1;
end if;

g.sdo_point.x := geom.sdo_ordinates(ct);
g.sdo_point.y := geom.sdo_ordinates(ct+1);
g.sdo_point.z := NULL;

return g;
end;
/ 

-- Verify get_end_point.
select get_end_point(a.shape, 0) from road a where id = 1;
select get_end_point(a.shape, 1) from road a where id = 1;

-- Another utility function to reverse the geometry coordinates.
create or replace function reverse_geometry(geometry MDSYS.SDO_GEOMETRY)
return MDSYS.SDO_GEOMETRY DETERMINISTIC
IS
num_points INTEGER;
temp       NUMBER;
ordinates  MDSYS.SDO_ORDINATE_ARRAY;
g          MDSYS.SDO_GEOMETRY;
BEGIN
 ordinates := geometry.sdo_ordinates;
 num_points := ordinates.count / 4;
 FOR i in 1 .. num_points LOOP
     -- Swap first ordinate of 2D point.
    temp := ordinates(2*i - 1);
    ordinates(2*i - 1) :=
    ordinates(ordinates.count - 2*i + 1);
    ordinates(ordinates.count - 2*i + 1) := temp;
    -- Swap second ordinate of 2D point.
    temp := ordinates(2*i);
    ordinates(2*i) :=
        ordinates(ordinates.count - 2*i + 2);
        ordinates(ordinates.count -2*i + 2) := temp;
 END LOOP;

 g := MDSYS.SDO_GEOMETRY(geometry.sdo_gtype, geometry.sdo_srid, NULL,
                         geometry.sdo_elem_info, ordinates);

return g;

end;
/ 

-- Verify utility function reverse_geometry.
select a.shape, reverse_geometry(a.shape) from road a where rownum = 1;

--
-- 4. Construct the network.
--

-- Create a table to hold the end points of the road segments.
drop table temp_nodes;
create table temp_nodes 
  as select get_end_point(shape, 1) geom
  from road;
  
insert into temp_nodes
  select get_end_point(shape, 0) geom
  from road;
  
-- Construct the node table.
drop table road_node;
create table road_node(node_id number primary key, geometry mdsys.sdo_geometry, 
  partition_id number default NULL);
insert into road_node
  select rownum, mdsys.sdo_geometry(2001, srid,
      MDSYS.SDO_POINT_TYPE(x,y,null),null, null), NULL
  from ( select distinct sdo_util.truncate_number(a.geom.sdo_point.x, 1) X,
                sdo_util.truncate_number(a.geom.sdo_point.Y, 1) Y, 
                (a.geom.sdo_srid) srid
              from temp_nodes a); 
  
-- Construct the link table.
drop table road_link;
create table road_link(link_id number primary key , 
  start_node_id number, end_node_id   number, geometry mdsys.sdo_geometry);

-- Initialize road_link with existing road information.  Node information 
-- will be added later.
insert into road_link
  select id, null, null, shape
      from road;  

-- If all streets are bidirected, i.e. two-way, you can set BIDIRECTED to 'Y' in
-- user_sdo_network_metadata for network 'ROAD_NETWORK'.
-- Otherwise, you can add the reverse geometry with the negative value of the 
-- associated link id to the link table.
-- Assume here that link_id 1 is a two-way street.
insert into road_link
  select -link_id, null, null, reverse_geometry(geometry)
    from road_link
    where link_id=1;

-- Set up the geometry metadata.
delete from user_sdo_geom_metadata where table_name = 'ROAD_LINK';

insert into user_sdo_geom_metadata 
  values ('ROAD_LINK', 'GEOMETRY',
    mdsys.sdo_dim_array(
      mdsys.sdo_dim_element('X', -1000000,1000000, 0.05),
      mdsys.sdo_dim_element('Y', -1000000,1000000, 0.05)), 
     null); 

update user_sdo_geom_metadata
  set srid=
    (select a.geometry.sdo_srid from road_link a  where rownum=1)
  where table_name = 'ROAD_LINK';   

delete from user_sdo_geom_metadata where table_name = 'ROAD_NODE';
insert into user_sdo_geom_metadata values('ROAD_NODE', 'GEOMETRY',
  mdsys.sdo_dim_array(
    mdsys.sdo_dim_element('X', -1000000,1000000, 0.05),
    mdsys.sdo_dim_element('Y', -1000000,1000000, 0.05)), 
  null); 
  
update user_sdo_geom_metadata
  set srid=
    (select a.geometry.sdo_srid from road_node a  where rownum=1)
  where table_name = 'ROAD_NODE';     

-- Create indexes.
create index road_link_sidx on road_link(geometry)
  indextype is mdsys.spatial_index; 

create index road_node_sidx on road_node(geometry)
  indextype is mdsys.spatial_index; 

-- Test the start nodes.
-- If this comes back with rows, then there are some links that have more 
-- than one start/end node.  These links need to be fixed manually.  

select * from (
  select /*+ ordered */b.link_id, count(*) cnt
    from road_link b, road_node a
    where sdo_relate(a.geometry, get_end_point(b.geometry, 0),
        'mask=anyinteract' ) = 'TRUE'
    group by b.link_id)
where cnt > 1; 

select * from (
  select /*+ ordered */b.link_id, count(*) cnt
    from road_link b, road_node a
    where sdo_relate(a.geometry, get_end_point(b.geometry, 1),
        'mask=anyinteract' ) = 'TRUE'
    group by b.link_id)
where cnt > 1; 

-- Create start/end node tables.
drop table start_nodes;
create table start_nodes as
  select /*+ ordered */node_id, link_id
    from road_link b, road_node a
    where sdo_relate(a.geometry, get_end_point(b.geometry, 0),
       'mask=anyinteract' ) = 'TRUE';

drop table end_nodes;
create table end_nodes as
  select /*+ ordered */  node_id, link_id
    from road_link b, road_node a
    where sdo_relate(a.geometry, get_end_point(b.geometry, 1),
      'mask=anyinteract' ) = 'TRUE';
      
-- Create indexes to speed up the joins.
create index snode_lidx on start_nodes(link_id);
create index enode_lidx on end_nodes(link_id);

-- Update road_link table
update road_link a
  set a.start_node_id =
    (select min(node_id) 
        from start_nodes b
        where b.link_id = a.link_id);
 
update road_link a
  set a.end_node_id =
    (select min(node_id)
        from end_nodes b
        where b.link_id=a.link_id);

-- Update the network metadata, assuming this is a directed network.
insert into user_sdo_network_metadata(network, network_category, 
  node_table_name, link_table_name, link_direction)
  values('ROAD_NETWORK', 'SPATIAL', 'ROAD_NODE',
    'ROAD_LINK', 'DIRECTED');
  
--
-- 5. Verify the constructed network.
--
select sdo_net.validate_network('ROAD_NETWORK', 'TRUE') from dual;

--
-- 6. Clean up.
--
drop table end_nodes;
drop table start_nodes;
drop table temp_nodes;
