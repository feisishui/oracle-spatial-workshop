drop table world_countries_3857 purge;

create table world_countries_3857 as
select * from world_countries
where cntry_name <> 'Antarctica';

update world_countries_3857 set geom = sdo_cs.transform(geom,3857);
commit;

delete from user_sdo_geom_metadata where table_name in ('WORLD_COUNTRIES_3857');
insert into user_sdo_geom_metadata (
  table_name, column_name, diminfo, srid 
)
values (
  'WORLD_COUNTRIES_3857',
  'GEOM',
   sdo_dim_array(
     sdo_dim_element('X', -20000000, 20000000, 1),
     sdo_dim_element('Y', -20000000, 20000000, 1)
   ),
   3857
);
commit;

drop index world_countries_3857_sx;
create index world_countries_3857_sx
  on world_countries_3857 (geom)
  indextype is mdsys.spatial_index;

delete from user_sdo_themes where name = 'WORLD_COUNTRIES_3857';
insert into user_sdo_themes (NAME,BASE_TABLE,GEOMETRY_COLUMN,STYLING_RULES)
select 'WORLD_COUNTRIES_3857','WORLD_COUNTRIES_3857','GEOM',STYLING_RULES
from user_sdo_themes
where name = 'WORLD_COUNTRIES';
commit;

