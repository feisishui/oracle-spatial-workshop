-- Themes with styles that do not exist
select theme_name, style_name
from user_sdo_themes_r
where style_name not in (select name from user_sdo_styles);

-- Themes with label styles that do not exist
select theme_name, label_style_name
from user_sdo_themes_r
where label_style_name not in (select name from user_sdo_styles);

-- Combine both checks
select t1.theme_name, t1.style_name, t2.label_style_name
from (
  select theme_name, style_name, null label_style_name
  from user_sdo_themes_r
  where style_name not in (select name from user_sdo_styles)
) t1
full outer join (
  select theme_name, null style_name, label_style_name
  from user_sdo_themes_r
  where label_style_name not in (select name from user_sdo_styles)
) t2
on t1.theme_name = t2.theme_name;

-- Unused styles (not used in any theme)
select name
from user_sdo_styles
where name not in (select style_name from user_sdo_themes_r)
union
select name
from user_sdo_styles
where name not in (select label_style_name from user_sdo_themes_r);
