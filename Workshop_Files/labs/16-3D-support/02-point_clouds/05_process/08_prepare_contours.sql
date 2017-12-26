drop table contours purge;

create table contours (
  id number primary key,
  elevation number,
  contour sdo_geometry
);

delete from user_sdo_geom_metadata where table_name = 'CONTOURS';
insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
values (
  'CONTOURS',
  'CONTOUR',
   sdo_dim_array(
     sdo_dim_element('Easting',   200000,   300000, 0.05),
     sdo_dim_element('Northing', 4300000,  4400000, 0.05)
   ),
   32617
);

create index contours_sx on contours (contour) 
indextype is mdsys.spatial_index;
