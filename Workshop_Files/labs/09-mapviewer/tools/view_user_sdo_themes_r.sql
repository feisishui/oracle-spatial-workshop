create or replace view user_sdo_themes_r as
select  t.name as theme_name,
        t.base_table as table_name,
        t.geometry_column as column_name,
        extractvalue(value(d),'/rule/features/@style') as style_name,
        extractvalue(value(d),'/rule/label/@column') as label_column_name,
        extractvalue(value(d),'/rule/label/@style') as label_style_name
from  user_sdo_themes t,
      table (
        xmlsequence (
          extract(
            xmltype(styling_rules),
            '/styling_rules/rule'
          )
        )
      ) d;
