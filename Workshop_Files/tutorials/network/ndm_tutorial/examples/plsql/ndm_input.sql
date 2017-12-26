Rem
Rem $Header: sdo/demo/network/examples/plsql/ndm_input.sql /main/1 2012/03/29 10:48:17 jcwang Exp $
Rem
Rem ndm_input.sql
Rem
Rem Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      ndm_input.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jcwang      03/26/12 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 200
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
SET SERVEROUTPUT ON


---
--- Sample scripts/functions to generate NDM input, PointOnNet(link_id@percent) from an address or a longitude/latitude pair
--- The Input can be addresses, longitude/latitude (GPS)
--- The NDM PointOnNet(link_ID,Percent) information can be obtained using either Oracle GeoCoder or Oracle Spatial Index/operator  
--- 


---
--- Covert an address or latitude/longitude into an NDM PointOnNet representation
--- Oracle Geocoder tables must be defined and populated 
--


---
--- Sample input table, 
--- Input :the input can be an address(as a SDO_KEYWORDARRAY) or a longitude/latitude pair
--- output: NDM PointOnNet information using function geocode_ndm
--- 



-- drop input table if exists
drop table address_table;

-- create a sample address input table 
create table address_table
(id number primary key, --location id, PK
 address_type varchar(4),-- 'ADDR' for address or 'LOC' for longitude/Latitude
 address_lines SDO_KEYWORDARRAY,
 country varchar(128), -- country name  or ISO country code
 srid      number,
 longitude number,
 latitude  number,
 edgeid    number, -- NDM PointOnNet (link_id)
 percent   number  -- NDM PointOnNet [0,1.0] 	   	
);

--
-- address input (with SDO_KEYWORDARRAY)
--

insert into address_table (id, address_type,address_lines,country) values (1,'ADDR',sdo_keywordarray('1 Carlton B Goodlett Pl','San Francisco, CA 94102'),'US');

--
-- longitude/latitude input (with SRID and Country Code)
--

insert into address_table (id, address_type, srid, longitude,latitude,country) values (2,'LOC',8307,-122.41815,37.7784183,'US') ;

---
--- Utility function to generate an SDO_GEO_ADDR object(geocoder object type) from an address or (lon./la)
--- The NDM PointOnNet information (link-id, percent) can be obtained as
--- link_id = addr_obj.edgeid and percent = addr_obj.percent
--


CREATE or REPLACE FUNCTION geocode_ndm( user_name     in varchar2,
					address_type  in varchar2,
				        address_lines in sdo_keywordarray,
                                        country       in varchar2,
                                        match_mode    in varchar2,
                  			srid          in number,
		                        longitude     in number,
                                        latitude      in number) RETURN sdo_geo_addr DETERMINISTIC 

IS
addr sdo_geo_addr ;
BEGIN
	IF ( NLS_UPPER(address_type) = 'ADDR' ) THEN
	   return sdo_gcdr.geocode(user_name,address_lines,country,match_mode);
        ELSIF (NLS_UPPER(address_type) = 'LOC' ) THEN
           return sdo_gcdr.reverse_geocode( user_name,sdo_geometry(2001,srid,sdo_point_type(longitude,latitude,null),NULL,NULL),country) ;
        ELSE
           return null; -- unknown address type
        END IF;
END ;
/ 


--
-- SQL query to generate the NDM PointOnNet information for an address table (with Oracle Geocoder) 
-- Requires NAVTEQ_SF uyser and NAVTEQ_SF network (NAVTEQ San Francisco saample network)
--

select a.id,a.addr_obj.edgeid,a.addr_obj.percent from address_table b, 
(select id, geocode_ndm('NAVTEQ_SF',address_type,address_lines,country,'RELAX_BASE_NAME',srid,longitude,latitude) as addr_obj from address_table ) a
where b.id = a.id ;



--
-- PL/SQL procedure to populate/persist PointOnNet (link_id,percent) info. based on address/(longitude/latitude) info.
--

DECLARE
addr_obj sdo_geo_addr;
v_addr address_table%rowtype;
cursor c1 is select  * from address_table;
BEGIN  
  OPEN c1;
  LOOP
  FETCH  c1 into v_addr;
  EXIT when c1%NOTFOUND;
  -- compute edgeid,percent information
  addr_obj := geocode_ndm('NAVTEQ_SF',v_addr.address_type,v_addr.address_lines,v_addr.country,'RELAX_BASE_NAME',v_addr.srid,v_addr.longitude,v_addr.latitude) ;
  -- update the address table with edgeid,percent information
  UPDATE address_table 
  set edgeid = addr_obj.edgeid,
      percent = addr_obj.percent,
      country = addr_obj.country      
      where id = v_addr.id;
  END loop;
  CLOSE c1;
COMMIT;

END;
/



--
-- Utility function to return longitude/latitude from NDM PointOnNet info.
-- This is purely based on link table and Oracle Geocoder is NOT required.
-- 

CREATE OR REPLACE FUNCTION get_location(link_geom in sdo_geometry, percent in number)
               return SDO_GEOMETRY DETERMINISTIC
is
lrs_geom sdo_geometry ;
lrs_pt   sdo_geometry ;
begin
    IF ( link_geom is not null and percent is not null ) then
	if ( percent >= 0 and percent <= 1.0 ) THEN -- percent [0,1]
         -- use LRS package
	 lrs_geom := sdo_lrs.convert_to_lrs_geom(link_geom,0,1.0) ;
         lrs_pt := sdo_lrs.locate_pt(lrs_geom,percent);
         RETURN sdo_lrs.convert_to_std_geom(lrs_pt); -- return the lon/lat in an SDO point geometry
        END IF;
    END IF;	
    RETURN null; -- error
end;
/


--
-- Query to return longitude/latitude (sdo_point_type in an SDO POINT GEOMETRY) from a link geometry and percent
-- 0. start point, 0.5, mid point, and 1.0 end point on the link geometry
--


select 0 percent, a.geom.sdo_point.x,a.geom.sdo_point.y from
(select get_location( sdo_geometry(2002,8307,null, sdo_elem_info_array(1,2,1), sdo_ordinate_array(-122.41815,37.7784183,-122.42815,37.7884183)),0) as geom from dual) a ; 


select 0.5 percent, a.geom.sdo_point.x,a.geom.sdo_point.y from
(select get_location( sdo_geometry(2002,8307,null, sdo_elem_info_array(1,2,1), sdo_ordinate_array(-122.41815,37.7784183,-122.42815,37.7884183)),0.5) as geom from dual) a ; 


select 1.0 percent, a.geom.sdo_point.x,a.geom.sdo_point.y from
(select get_location( sdo_geometry(2002,8307,null, sdo_elem_info_array(1,2,1), sdo_ordinate_array(-122.41815,37.7784183,-122.42815,37.7884183)),1.0) as geom from dual) a ; 



--
-- Utility function to return percent information of the nearest point on the  link geometry from a given point (longitude/latitude) 
-- This is basically a snapping function 
-- The nearest link_geometry can be found using sdo_nn operator against the link table
-- Then the get_percent function can be applied to find the percent information of the nearest link geometry
--


--
-- Query to return the nearest LINK id and geometry w.r.t. a given point(srid,longitude,latitude) GPS info.
-- spatial index must be built on link table geometry
--

select a.link_id, a.geometry from NAVTEQ_SF_LINK$ a
where sdo_nn(a.geometry,
             sdo_geometry(2001,8307, sdo_point_type(-122.41815,37.70784183,null),null,null),
             'sdo_num_res=1') = 'TRUE';




--
-- Query to return the nearest NODE id and geometry w.r.t. a given point(srid,longitude,latitude) GPS info.
-- spatial index must be built on node table geometry
--

select a.node_id, a.geometry from NAVTEQ_SF_NODE$ a
where sdo_nn(a.geometry,
             sdo_geometry(2001,8307, sdo_point_type(-122.41815,37.70784183,null),null,null),
             'sdo_num_res=1') = 'TRUE';




--
-- query to return the more than one nearest LINK geometry sorted based on their distances to the given point
-- the example below returns 4 nearest LINK id/geometry
--


select a.link_id, a.geometry,sdo_nn_distance(1) from NAVTEQ_SF_LINK$ a
where sdo_nn(a.geometry,
             sdo_geometry(2001,8307, sdo_point_type(-122.41815,37.70784183,null),null,null),
             'sdo_num_res=4',1) = 'TRUE'
             order by 3;



--
-- query to return the more than one nearest NODE geometry sorted based on their distances to the given point
-- the example below returns 4 nearest NODE id/geometry
--


select a.node_id, a.geometry,sdo_nn_distance(1) from NAVTEQ_SF_NODE$ a
where sdo_nn(a.geometry,
             sdo_geometry(2001,8307, sdo_point_type(-122.41815,37.70784183,null),null,null),
             'sdo_num_res=4',1) = 'TRUE'
             order by 3;



--
-- Utility function to return the percent information on a given link geometry (nearest) based on longitude/latitude information
--

CREATE OR REPLACE FUNCTION get_percent(link_geom in sdo_geometry, longitude in number, latitude in number)
               return NUMBER DETERMINISTIC
is
lrs_geom sdo_geometry ;
pt_geom  sdo_geometry;
lrs_pt   sdo_geometry ;
begin
    IF ( link_geom is not NULL and (longitude is not NULL and latitude is not NULL)) then
         pt_geom := sdo_geometry(2001,link_geom.sdo_srid,sdo_point_type(longitude,latitude,NULL),NULL,NULL);
	 lrs_geom := sdo_lrs.convert_to_lrs_geom(link_geom,0,1.0) ;
         RETURN sdo_lrs.find_measure(lrs_geom,pt_geom,0.05); -- return the percent(measure) information of the projected pt
    END IF;	
    RETURN null; -- error
end;
/


--
-- 1. find the nearest link id and geometry from the link table
-- 
select a.link_id, a.geometry from navteq_sf_link$ a
where sdo_nn(a.geometry,
             sdo_geometry(2001,8307, sdo_point_type(-122.41815,37.70784183,null),null,null),
             'sdo_num_res=1') = 'TRUE';

--
-- 2. find the percent of the nearest point on the nearest link geometry
--

select get_percent(l.geometry,-122.41815,37.70784183) from navteq_sf_link$ l
where link_id = 198751976 ;

--
-- 3. find the location of the nearest point of the nearest link geometry and percent
--

select get_location(l.geometry,get_percent(l.geometry,-122.41815,37.70784183)) from 
navteq_sf_link$ l
where link_id = 198751976 ;

--
-- 4.Compare the difference in meters between the given location and the projected location 
--
select sdo_geom.sdo_distance(sdo_geometry(2001,8307, sdo_point_type(-122.41815,37.70784183,null),null,null),
			    (select get_location(l.geometry,get_percent(l.geometry,-122.41815,37.70784183)) 
				from navteq_sf_link$ l where link_id = 198751976) ,0.05) 
       from dual;	                             




