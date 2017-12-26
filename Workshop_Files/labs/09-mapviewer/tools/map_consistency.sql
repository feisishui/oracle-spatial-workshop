-- Maps with themes that do not exist
select map_name, theme_name
from user_sdo_maps_r
where theme_name not in (select name from user_sdo_themes);

-- Unused themes (not used in any map)
select name
from user_sdo_themes
where name not in (select theme_name from user_sdo_maps_r);