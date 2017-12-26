-- Create the path and path link tables
create table net_paths (
  path_id         number,
  start_node_id   number,
  end_node_id     number,
  cost            number,
  simple          varchar2(1),
  geometry            sdo_geometry
);

create table net_path_links (
  path_id         number,
  link_id         number,
  seq_no          number,
  primary key (path_id, link_id, seq_no)
);

delete from user_sdo_geom_metadata where table_name in ('NET_PATHS');
insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
values (
  'NET_PATHS',
  'GEOMETRY',
  sdo_dim_array (
    sdo_dim_element ('Longitude', -180, 180, 0.5),
    sdo_dim_element ('Latitude', -90, 90, 0.5)
  ),
  8307
);
commit;

drop index net_links_sx;
create index net_paths_sx on net_paths (geometry) indextype is mdsys.spatial_index;
