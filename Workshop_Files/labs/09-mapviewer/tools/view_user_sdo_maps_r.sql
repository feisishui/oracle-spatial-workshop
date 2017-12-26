create or replace view user_sdo_maps_r as
select  m.name as map_name,
        extractvalue(value(d),'/theme/@name') as theme_name,
        to_number(extract(value(d),'/theme/@min_scale')) as min_scale,
        to_number(extract(value(d),'/theme/@max_scale')) as max_scale,
        extractvalue(value(d),'/theme/@scale_mode') as scale_mode,
        to_number(extract(value(d),'/theme/@minimum_pixels')) as minimum_pixels,
        to_number(extract(value(d),'/theme/@fetch_size')) as fetch_size,
        extractvalue(value(d),'/theme/@allow_naked_points ') as allow_naked_points,
        extractvalue(value(d),'/theme/@no_repetitive_label ') as no_repetitive_label,
        extractvalue(value(d),'/theme/@label_always_on ') as label_always_on
from  user_sdo_maps m,
      table (
        xmlsequence (
          extract(
            xmltype(definition),
            '/map_definition/theme'
          )
        )
      ) d;
