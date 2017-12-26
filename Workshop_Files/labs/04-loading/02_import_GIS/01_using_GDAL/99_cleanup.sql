drop table world_continents purge;
drop table world_countries purge;
drop table us_cities purge;
drop table us_counties purge;
drop table us_states purge;
drop table us_interstates purge;
drop table us_parks purge;
drop table us_rivers purge;
drop table us_blockgroups purge;

delete from user_sdo_geom_metadata 
where table_name like 'WORLD%' 
or table_name like 'US%';
commit;

