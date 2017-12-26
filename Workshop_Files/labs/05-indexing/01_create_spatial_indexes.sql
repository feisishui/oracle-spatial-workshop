set timing on
drop index us_cities_sx;
drop index us_counties_sx;
drop index us_states_sx;
drop index us_interstates_sx;
drop index us_parks_sx;
drop index us_rivers_sx;
drop index us_blockgroups_sx;
drop index world_continents_sx;
drop index world_countries_sx;
--
drop index us_cities_p_sx;
drop index us_counties_p_sx;
drop index us_states_p_sx;
drop index us_interstates_p_sx;
drop index us_parks_p_sx;
drop index us_rivers_p_sx;
--
create index us_cities_sx         on us_cities         (location)  indextype is mdsys.spatial_index;
create index us_counties_sx       on us_counties       (geom)      indextype is mdsys.spatial_index;
create index us_states_sx         on us_states         (geom)      indextype is mdsys.spatial_index;
create index us_interstates_sx    on us_interstates    (geom)      indextype is mdsys.spatial_index;
create index us_parks_sx          on us_parks          (geom)      indextype is mdsys.spatial_index;
create index us_rivers_sx         on us_rivers         (geom)      indextype is mdsys.spatial_index;
create index us_blockgroups_sx    on us_blockgroups    (geom)      indextype is mdsys.spatial_index;
create index world_continents_sx  on world_continents  (geometry)  indextype is mdsys.spatial_index;
create index world_countries_sx   on world_countries   (geometry)  indextype is mdsys.spatial_index;
--
create index us_cities_p_sx       on us_cities_p       (location)  indextype is mdsys.spatial_index;
create index us_counties_p_sx     on us_counties_p     (geom)      indextype is mdsys.spatial_index;
create index us_states_p_sx       on us_states_p       (geom)      indextype is mdsys.spatial_index;
create index us_interstates_p_sx  on us_interstates_p  (geom)      indextype is mdsys.spatial_index;
create index us_parks_p_sx        on us_parks_p        (geom)      indextype is mdsys.spatial_index;
create index us_rivers_p_sx       on us_rivers_p       (geom)      indextype is mdsys.spatial_index;


