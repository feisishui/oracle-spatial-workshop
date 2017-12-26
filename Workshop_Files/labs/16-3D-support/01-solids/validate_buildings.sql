col status for a60
with t as (
  select building_id, sdo_geom.validate_geometry_with_context(geom, 0.5) status, geom
  from buildings
)
select *
from t
where status <> 'TRUE'
order by building_id;
