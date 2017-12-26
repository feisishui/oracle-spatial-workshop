delete from user_sdo_styles where name like ('_.US_INTERSTATES_%');
delete from user_sdo_themes where name in ('US_INTERSTATES_LRS');

-- -------------------------------------------------------------------
-- Styles
-- -------------------------------------------------------------------

-- Lines

insert into user_sdo_styles (name, type, definition)
values (
'L.US_INTERSTATES_GOOD',
'LINE',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <desc></desc>
  <g class="line" cased="true" style="fill:#00FF00;stroke-width:6;stroke-linecap:BUTT">
    <line class="base"/>
  </g>
</svg>'
);

insert into user_sdo_styles (name, type, definition)
values (
'L.US_INTERSTATES_FAIR',
'LINE',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <desc></desc>
  <g class="line" cased="true" style="fill:#FFE300;stroke-width:6;stroke-linecap:BUTT">
    <line class="base"/>
  </g>
</svg>'
);

insert into user_sdo_styles (name, type, definition)
values (
'L.US_INTERSTATES_POOR',
'LINE',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <desc></desc>
    <g class="line" cased="true" style="fill:#FF0000;stroke-width:6;stroke-linecap:BUTT">
    <line class="base"/>
  </g>
</svg>'
);

-- Advanced (thematic)
insert into user_sdo_styles (name, type, definition)
values (
'V.US_INTERSTATES_LRS',
'ADVANCED',
'<?xml version="1.0" standalone="yes"?>
<AdvancedStyle>
  <BucketStyle>
    <Buckets default_style="L.US_INTERSTATES">
      <CollectionBucket seq="0" label="Poor" keep_white_space="false" type="string" style="L.US_INTERSTATES_POOR">poor</CollectionBucket>
      <CollectionBucket seq="1" label="Fair" keep_white_space="false" type="string" style="L.US_INTERSTATES_FAIR">fair</CollectionBucket>
      <CollectionBucket seq="2" label="Good" keep_white_space="false" type="string" style="L.US_INTERSTATES_GOOD">good</CollectionBucket>
    </Buckets>
  </BucketStyle>
</AdvancedStyle>'
);


-- -------------------------------------------------------------------
-- Themes
-- -------------------------------------------------------------------
insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_INTERSTATES_LRS_CONDITION',
'US_INTERSTATES_LRS_CONDITION',
'GEOM',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule column="CONDITION">
    <features asis="true" style="V.US_INTERSTATES_LRS">
    </features>
  </rule>
</styling_rules>'
);

-- -------------------------------------------------------------------
-- Maps
-- -------------------------------------------------------------------

insert into user_sdo_maps (name, definition)
values (
'US_LRS_MAP',
'<?xml version="1.0" standalone="yes"?>
<map_definition>
  <theme name="US_STATES"           min_scale="150000000" max_scale="0" scale_mode="RATIO"/>
  <theme name="US_INTERSTATES"      min_scale="20000000"  max_scale="0" scale_mode="RATIO"/>
  <theme name="US_INTERSTATES_LRS_CONDITION" min_scale="20000000"  max_scale="0" scale_mode="RATIO"/>
  <theme name="US_CITIES"           min_scale="15000000"  max_scale="0" scale_mode="RATIO"/>
</map_definition>'
);


commit;
