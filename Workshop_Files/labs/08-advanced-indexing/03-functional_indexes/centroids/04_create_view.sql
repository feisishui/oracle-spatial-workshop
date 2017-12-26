create or replace view us_counties_centroids as
select id, county, state_abrv, sdo_geom.sdo_centroid(geom,0.5) centroid
from   us_counties;


