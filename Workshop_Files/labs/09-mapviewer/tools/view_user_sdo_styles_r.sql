create or replace view user_sdo_styles_r as
select  t.name as adv_style_name,
        extractvalue(value(d),'//@style') as style_name,
        extractvalue(value(d),'//@label_style') as label_style_name
from  user_sdo_styles t,
      table (
        xmlsequence (
          extract(
            xmltype(definition),
            '//RangedBucket'
          )
        )
      ) d
where type = 'ADVANCED'
union
select  t.name as adv_style_name,
        extractvalue(value(d),'//@style') as style_name,
        extractvalue(value(d),'//@label_style') as label_style_name
from  user_sdo_styles t,
      table (
        xmlsequence (
          extract(
            xmltype(definition),
            '//CollectionBucket'
          )
        )
      ) d
where type = 'ADVANCED';