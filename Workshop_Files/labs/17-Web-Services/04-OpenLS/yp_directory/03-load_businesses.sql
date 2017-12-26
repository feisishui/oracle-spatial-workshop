/*

  Populate the business table from the points of interests
  used by the geocoder.

  - some POIs exist in multiple copies (same POI_ID). Only retain one of them
  - only retain the POIs with a populated street name.
  - description is set to the feature code of the business

*/

insert into ols_dir_businesses (
  business_id,
  business_name,
  description,
  phone,
  country,
  country_subdivision,
  municipality,
  postal_code,
  street,
  building,
  geom
)
select
  poi_id,
  name,
  feature_code,
  telephone_number,
  country_code_2,
  region_name,
  municipality_name,
  postal_code,
  street_name,
  house_number,
  sdo_geometry (2001, 8307, sdo_point_type (loc_long, loc_lat, null), null, null)
from gc_poi_us
where rowid in (select min(rowid) from gc_poi_us group by poi_id)
and street_name is not null;

insert into ols_dir_businesses (
  business_id,
  business_name,
  description,
  phone,
  country,
  country_subdivision,
  municipality,
  postal_code,
  street,
  building,
  geom
)
select
  poi_id,
  name,
  feature_code,
  telephone_number,
  country_code_2,
  region_name,
  municipality_name,
  postal_code,
  street_name,
  house_number,
  sdo_geometry (2001, 8307, sdo_point_type (loc_long, loc_lat, null), null, null)
from GC_POI_BE
where rowid in (select min(rowid) from GC_POI_BE group by poi_id)
and street_name is not null;

insert into ols_dir_businesses (
  business_id,
  business_name,
  description,
  phone,
  country,
  country_subdivision,
  municipality,
  postal_code,
  street,
  building,
  geom
)
select
  poi_id,
  name,
  feature_code,
  telephone_number,
  country_code_2,
  region_name,
  municipality_name,
  postal_code,
  street_name,
  house_number,
  sdo_geometry (2001, 8307, sdo_point_type (loc_long, loc_lat, null), null, null)
from GC_POI_DE
where rowid in (select min(rowid) from GC_POI_DE group by poi_id)
and street_name is not null;

insert into ols_dir_businesses (
  business_id,
  business_name,
  description,
  phone,
  country,
  country_subdivision,
  municipality,
  postal_code,
  street,
  building,
  geom
)
select
  poi_id,
  name,
  feature_code,
  telephone_number,
  country_code_2,
  region_name,
  municipality_name,
  postal_code,
  street_name,
  house_number,
  sdo_geometry (2001, 8307, sdo_point_type (loc_long, loc_lat, null), null, null)
from GC_POI_FR
where rowid in (select min(rowid) from GC_POI_FR group by poi_id)
and street_name is not null;

insert into ols_dir_businesses (
  business_id,
  business_name,
  description,
  phone,
  country,
  country_subdivision,
  municipality,
  postal_code,
  street,
  building,
  geom
)
select
  poi_id,
  name,
  feature_code,
  telephone_number,
  country_code_2,
  region_name,
  municipality_name,
  postal_code,
  street_name,
  house_number,
  sdo_geometry (2001, 8307, sdo_point_type (loc_long, loc_lat, null), null, null)
from GC_POI_UK
where rowid in (select min(rowid) from GC_POI_UK group by poi_id)
and street_name is not null;

insert into ols_dir_businesses (
  business_id,
  business_name,
  description,
  phone,
  country,
  country_subdivision,
  municipality,
  postal_code,
  street,
  building,
  geom
)
select
  poi_id,
  name,
  feature_code,
  telephone_number,
  country_code_2,
  region_name,
  municipality_name,
  postal_code,
  street_name,
  house_number,
  sdo_geometry (2001, 8307, sdo_point_type (loc_long, loc_lat, null), null, null)
from GC_POI_NL
where rowid in (select min(rowid) from GC_POI_NL group by poi_id)
and street_name is not null;

commit;
