/*

This script defines a set of styles and themes that illustrate some
advanced techniques.

*/

delete from user_sdo_styles where name like 'L.COUNTIES_LINE%';
delete from user_sdo_styles where name like 'C.COUNTIES_FILL%';
delete from user_sdo_styles where name like 'V.COUNTIES_DASHED%';

delete from user_sdo_styles where name like 'A.COUNTIES_COMBINED%';
delete from user_sdo_styles where name like 'V.COUNTIES_COMBINED%';

delete from user_sdo_themes where name in ('US_COUNTIES_DASHED', 'US_COUNTIES_COMBINED');

---------------------------------------------------------------------
-- Styles
---------------------------------------------------------------------

-- Base styles: line and color

insert into user_sdo_styles (name, type, definition)
values (
'L.COUNTIES_LINE_1',
'LINE',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <g class="line" style="fill:#FFFFFF;stroke-width:1">
    <line class="base" style="fill:#FF0000;stroke-width:2" dash="10.0,10.0" />
  </g>
</svg>'
);

insert into user_sdo_styles (name, type, definition)
values (
'L.COUNTIES_LINE_2',
'LINE',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <g class="line" style="fill:#FFFFFF;stroke-width:1">
    <line class="base" style="fill:#00FF00;stroke-width:2" dash="10.0,10.0" />
  </g>
</svg>'
);

insert into user_sdo_styles (name, type, definition)
values (
'L.COUNTIES_LINE_3',
'LINE',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <g class="line" style="fill:#FFFFFF;stroke-width:1">
    <line class="base" style="fill:#0000FF;stroke-width:2" dash="10.0,10.0" />
  </g>
</svg>'
);

insert into user_sdo_styles (name, type, definition)
values (
'C.COUNTIES_FILL_1',
'COLOR',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <g class="color" style="fill:#FF000D;fill-opacity:127">
    <rect width="50" height="50"/>
  </g>
</svg>'
);

insert into user_sdo_styles (name, type, definition)
values (
'C.COUNTIES_FILL_2',
'COLOR',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <g class="color" style="fill:#00FF00;fill-opacity:127">
    <rect width="50" height="50"/>
  </g>
</svg>'
);

insert into user_sdo_styles (name, type, definition)
values (
'C.COUNTIES_FILL_3',
'COLOR',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <g class="color" style="fill:#0000FC;fill-opacity:127">
    <rect width="50" height="50"/>
  </g>
</svg>'
);

-- Collection styles

insert into user_sdo_styles (name, type, definition)
values (
'V.COUNTIES_DASHED_1',
'ADVANCED',
'<?xml version="1.0" ?>
<AdvancedStyle>
  <CollectionStyle>
    <style name="C.COUNTIES_FILL_1"/>
    <style name="L.COUNTIES_LINE_1"/>
  </CollectionStyle>
</AdvancedStyle>'
);

insert into user_sdo_styles (name, type, definition)
values (
'V.COUNTIES_DASHED_2',
'ADVANCED',
'<?xml version="1.0" ?>
<AdvancedStyle>
  <CollectionStyle>
    <style name="C.COUNTIES_FILL_2"/>
    <style name="L.COUNTIES_LINE_2"/>
  </CollectionStyle>
</AdvancedStyle>'
);

insert into user_sdo_styles (name, type, definition)
values (
'V.COUNTIES_DASHED_3',
'ADVANCED',
'<?xml version="1.0" ?>
<AdvancedStyle>
  <CollectionStyle>
    <style name="C.COUNTIES_FILL_3"/>
    <style name="L.COUNTIES_LINE_3"/>
  </CollectionStyle>
</AdvancedStyle>'
);

-- Base styles - Combined

insert into user_sdo_styles (name, type, definition)
values (
'A.COUNTIES_COMBINED_1',
'AREA',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <g class="area" style="fill:#FF0000;fill-opacity:127;line-style:L.COUNTIES_LINE_1">
    <rect width="50" height="50"/>
  </g>
</svg>'
);

insert into user_sdo_styles (name, type, definition)
values (
'A.COUNTIES_COMBINED_2',
'AREA',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <g class="area" style="fill:#00FF00;fill-opacity:127;line-style:L.COUNTIES_LINE_2">
    <rect width="50" height="50"/>
  </g>
</svg>'
);

insert into user_sdo_styles (name, type, definition)
values (
'A.COUNTIES_COMBINED_3',
'AREA',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <g class="area" style="fill:#0000FF;fill-opacity:127;line-style:L.COUNTIES_LINE_3">
    <rect width="50" height="50"/>
  </g>
</svg>'
);

-- Bucket collection style

insert into user_sdo_styles (name, type, definition)
values (
'V.COUNTIES_DASHED',
'ADVANCED',
'<?xml version="1.0" ?>
<AdvancedStyle>
  <BucketStyle>
    <Buckets>
      <CollectionBucket seq="0" keep_white_space="true" type="integer" style="V.COUNTIES_DASHED_1">3</CollectionBucket>
      <CollectionBucket seq="1" keep_white_space="true" type="integer" style="V.COUNTIES_DASHED_2">2</CollectionBucket>
      <CollectionBucket seq="2" keep_white_space="true" type="integer" style="V.COUNTIES_DASHED_3">1</CollectionBucket>
    </Buckets>
   </BucketStyle>
</AdvancedStyle>'
);

insert into user_sdo_styles (name, type, definition)
values (
'V.COUNTIES_COMBINED',
'ADVANCED',
'<?xml version="1.0" ?>
<AdvancedStyle>
  <BucketStyle>
    <Buckets>
      <CollectionBucket seq="0" keep_white_space="true" type="integer" style="A.COUNTIES_COMBINED_1">3</CollectionBucket>
      <CollectionBucket seq="1" keep_white_space="true" type="integer" style="A.COUNTIES_COMBINED_2">2</CollectionBucket>
      <CollectionBucket seq="2" keep_white_space="true" type="integer" style="A.COUNTIES_COMBINED_3">1</CollectionBucket>
    </Buckets>
   </BucketStyle>
</AdvancedStyle>'
);

---------------------------------------------------------------------
-- Themes
---------------------------------------------------------------------
insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_COUNTIES_DASHED',
'US_COUNTIES',
'GEOM',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule column="MOD(TOTPOP,3)+1">
    <features style="V.COUNTIES_DASHED"> </features>
    <label column="COUNTY" style="T.US_COUNTIES"> 1 </label>
  </rule>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_COUNTIES_COMBINED',
'US_COUNTIES',
'GEOM',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule column="MOD(TOTPOP,3)+1">
    <features style="V.COUNTIES_COMBINED"> </features>
    <label column="COUNTY" style="T.US_COUNTIES"> 1 </label>
  </rule>
</styling_rules>'
);


commit;
