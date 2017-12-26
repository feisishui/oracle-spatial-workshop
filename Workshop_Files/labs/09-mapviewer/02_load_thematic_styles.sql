/*

This script defines a set of styles, themes and maps to illustrate
thematic mapping. The styles use the demographic statistics available
in the US_STATES table.

1) Single-variable thematics:

They are based on the following stztistics:

MEDHHINC = median household income
AVGHHINC = average household income
ONFARMS  = population living on farms
TOTPOP   = total population

Variable  Style             Type              Buckets         Combined Style  Theme
--------  ----------------  ----------------  --------------  --------------  --------------------------
AVGHHINC  V.AVGHHINC_CS_E   Color Scheme      Equal Range                     US_STATES_V.AVGHHINC_CS_E
AVGHHINC  V.AVGHHINC_CS_V   Color Scheme      Variable Range                  US_STATES_V.AVGHHINC_CS_V
MEDHHINC  V.MEDHHINC_MC_E   Multi colors      Equal Range                     US_STATES_V.MEDHHINC_MC_E
MEDHHINC  V.MEDHHINC_MC_V   Multi colors      Variable Range                  US_STATES_V.MEDHHINC_MC_V
ONFARMS   V.ONFARMS_VS      Variable marker   Variable Range  V.ONFARMS_CO    US_STATES_V.ONFARMS_VS
TOTPOP    V.TOTPOP_DD       Dot density                       V.TOTPOP_CO     US_STATES_V.TOTPOP_DD

The "combined" styles associate the thematic style with the base style for the theme so that
they can be rendered as a single entity:

V.ONFARMS_CO combines  C.US_STATES and V.ONFARMS_VS
V.TOTPOP_CO  combines  C.US_STATES and V.TOTPOP_DD

2) Multi-variable thematics

They are all based on the population distribution statistics:

WHITE    = white pop
BLACK    = black pop
ASIANPI  = asian & pac islandr pop
AMINDIAN = am indian, esk, aleuts pop
HISPANIC = persons of hispanic origin

Style                 Type                Combined Style          Theme
--------------------  ------------------  ----------------------  ----------------
V.POPULATION_BAR      Bar chart           V.POPULATION_BAR_CO     US_STATES_V.POPULATION_BAR_CO
V.POPULATION_PIE      Pie chart           V.POPULATION_PIE_CO     US_STATES_V.POPULATION_PIE_CO
V.POPULATION_VARPIE   Variable pie chart  V.POPULATION_VARPIE_CO  US_STATES_V.POPULATION_VARPIE_CO

Like above, the "combined" styles associate the thematic style with the base style for the theme.

3) Heat Maps

The heat map is defined on the US_CITIES table. It is produced from the density of the
cities, displayed over a background provided by the US_STATES table.

Style                 Type          Theme                           Map
--------------------  ------------  ------------------------------  ---------------------
V.HEATMAP             Colored       US_CITIES_V.HEATMAP             US_HEAT_MAP
V.HEATMAP_GRAYSCALE   Gray scale    US_CITIES_V.HEATMAP_GRAYSCALE   US_HEAT_MAP_GRAYSCALE


HOW TO USE THEMATIC STYLES
==========================

Use the style definition assistant (data, choose table, right click, create advanced style)

- Choose the style type you want to produce,
- Give a name to your style
- pick the key column.
- choose the number of buckets
- choose equal or variable range
- choose the colors and / or bucket limits
- choose the name of the theme that will use this style


How to analyze the data (to determine data distribution)

Use SQL Analytic functions: see:
  "Oracle® Database Data Warehousing Guide 11g Release 1 (11.1) Part Number B28313-02"
  chapters 20 and 21.

Examples:

  select max(onfarms), count(*), quartile
  from (
    SELECT state_abrv, onfarms, NTILE(4) OVER (ORDER BY onfarms) AS quartile
    FROM us_states
    WHERE onfarms > 0
  )
  group by quartile
  order by quartile;

  select max(totpop), count(*), quartile
  from (
    SELECT state_abrv, totpop, NTILE(4) OVER (ORDER BY totpop) AS quartile
    FROM us_states
    WHERE totpop > 0
  )
  group by quartile
  order by quartile;

*/

set define off

delete from user_sdo_styles where type = 'ADVANCED' or name like 'C.MEDHHINC%' or name = 'M.DOT';
delete from user_sdo_themes where name like '%V.%';
delete from user_sdo_maps   where name like 'US_HEAT_MAP%';

-- --------------------------------------------------------------
-- Base styles
-- --------------------------------------------------------------
insert into user_sdo_styles (name, type, definition)
values (
'C.MEDHHINC_1',
'COLOR',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <desc></desc>
  <g class="color" style="stroke:#000000;fill:#FF0000">
    <rect width="50" height="50"/>
  </g>
</svg>'
);
insert into user_sdo_styles (name, type, definition)
values (
'C.MEDHHINC_2',
'COLOR',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <desc></desc>
  <g class="color" style="stroke:#000000;fill:#FFCC00">
    <rect width="50" height="50"/>
  </g>
</svg>'
);
insert into user_sdo_styles (name, type, definition)
values (
'C.MEDHHINC_3',
'COLOR',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <desc></desc>
  <g class="color" style="stroke:#000000;fill:#00FF00">
    <rect width="50" height="50"/>
  </g>
</svg>'
);

insert into user_sdo_styles (name, type, definition)
values (
'M.DOT',
'MARKER',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <desc/>
  <g class="marker" style="stroke:#FFFFFF;fill:#FF0000;width:9;height:9;font-family:Dialog;font-size:12;font-fill:#FF0000">
    <circle cx="0" cy="0" r="0"/>
  </g>
</svg>'
);

-- --------------------------------------------------------------
-- Single variable
-- --------------------------------------------------------------

-- Color scheme - Equal Range Bucket
-- V1 V.AVGHHINC_CS_E
insert into user_sdo_styles (name, type, definition)
values (
'V.AVGHHINC_CS_E',
'ADVANCED',
'<?xml version="1.0" standalone="yes"?>
<AdvancedStyle>
   <ColorSchemeStyle basecolor="#FFFFFF" strokecolor="#000000">
    <Buckets low="25000" high="55000" nbuckets="6"/>
   </ColorSchemeStyle>
</AdvancedStyle>'
);
-- Color scheme - Variable Range Bucket
-- v2 AVGHHINC_CS_V
insert into user_sdo_styles (name, type, definition)
values (
'V.AVGHHINC_CS_V',
'ADVANCED',
'<?xml version="1.0" standalone="yes"?>
<AdvancedStyle>
  <ColorSchemeStyle basecolor="#FFFFFF" strokecolor="#000000">
    <Buckets>
      <RangedBucket seq="0" label="&lt; 10000" low="-Infinity" high="30000" />
      <RangedBucket seq="1" label="30000 - 35000" low="30000" high="35000" />
      <RangedBucket seq="2" label="35000 - 40000" low="35000" high="40000" />
      <RangedBucket seq="3" label="40000 - 45000" low="40000" high="45000" />
      <RangedBucket seq="4" label="45000 - 50000" low="45000" high="50000" />
      <RangedBucket seq="5" label="&gt; 50000" low="50000" high="Infinity" />
    </Buckets>
  </ColorSchemeStyle>
</AdvancedStyle>'
);

-- Multi Colors - Equal Range Bucket
-- v3 MEDHHINC_MC_E
insert into user_sdo_styles (name, type, definition)
values (
'V.MEDHHINC_MC_E',
'ADVANCED',
'<?xml version="1.0" standalone="yes"?>
<AdvancedStyle>
  <BucketStyle>
    <Buckets low="20000" high="50000" nbuckets="3" styles="C.MEDHHINC_1,C.MEDHHINC_2,C.MEDHHINC_3"/>
  </BucketStyle>
</AdvancedStyle>'
);

-- Multi Colors - Variable Range Bucket
-- v4 MEDHHINC_MC_V
insert into user_sdo_styles (name, type, definition)
values (
'V.MEDHHINC_MC_V',
'ADVANCED',
'<?xml version="1.0" standalone="yes"?>
<AdvancedStyle>
   <BucketStyle>
    <Buckets>
      <RangedBucket seq="0" label="&lt; 25000" low="0" high="25000" style="C.MEDHHINC_1" />
      <RangedBucket seq="1" label="25000 - 40000" low="25000" high="40000" style="C.MEDHHINC_2" />
      <RangedBucket seq="2" label="&gt; 40000" low="40000" high="Infinity" style="C.MEDHHINC_3" />
    </Buckets>
   </BucketStyle>
</AdvancedStyle>'
);

-- Variable Marker Size - Variable Range Bucket
-- v5/v5b ONFARMS_VS
insert into user_sdo_styles (name, type, definition)
values (
'V.ONFARMS_VS',
'ADVANCED',
'<?xml version="1.0" standalone="yes"?>
<AdvancedStyle>
  <VariableMarkerStyle basemarker="M.DOT" startsize="10" increment="10">
    <Buckets>
      <RangedBucket seq="0" label="&lt; 15000" low="-Infinity" high="15000" />
      <RangedBucket seq="1" label="15000 - 60000" low="15000" high="60000" />
      <RangedBucket seq="2" label="60000 - 120000" low="60000" high="120000" />
      <RangedBucket seq="3" label="120000 - 200000" low="120000" high="200000"/>
      <RangedBucket seq="4" label="&gt; 200000" low="200000" high="Infinity" />
    </Buckets>
   </VariableMarkerStyle>
</AdvancedStyle>'
);
insert into user_sdo_styles (name, type, definition)
values (
'V.ONFARMS_CO',
'ADVANCED',
'<?xml version="1.0" standalone="yes"?>
<AdvancedStyle>
  <CollectionStyle>
    <style name="C.US_STATES"/>
    <style name="V.ONFARMS_VS"/>
  </CollectionStyle>
</AdvancedStyle>'
);

-- Dot density:
-- v6/v6b TOTPOP_DD TOTPOP/200000 (each dot represents 200,000 people)
insert into user_sdo_styles (name, type, definition)
values (
'V.TOTPOP_DD',
'ADVANCED',
'<?xml version="1.0" standalone="yes"?>
<AdvancedStyle>
    <DotDensityStyle MarkerStyle="M.DOT" DotWidth="3" DotHeight="3" />
</AdvancedStyle>'
);
insert into user_sdo_styles (name, type, definition)
values (
'V.TOTPOP_CO',
'ADVANCED',
'<?xml version="1.0" standalone="yes"?>
<AdvancedStyle>
  <CollectionStyle>
    <style name="C.US_STATES"/>
    <style name="V.TOTPOP_DD"/>
  </CollectionStyle>
</AdvancedStyle>'
);

-- --------------------------------------------------------------
-- Multiple variables
-- Examples use the population statistics from the States table
-- --------------------------------------------------------------

-- Bar chart
insert into user_sdo_styles (name, type, definition)
values (
'V.POPULATION_BAR',
'ADVANCED',
'<?xml version="1.0" ?>
<AdvancedStyle>
   <BarChartStyle width="40" height="60" share_scale="true">
     <Bar name="Amerindian" color="#000000" />
     <Bar name="Asian"      color="#FF0000" />
     <Bar name="Black"      color="#00FF00" />
     <Bar name="Hispanic"   color="#0000FF" />
     <Bar name="White"      color="#FFFF00" />
   </BarChartStyle>
</AdvancedStyle>'
);

insert into user_sdo_styles (name, type, definition)
values (
'V.POPULATION_BAR_CO',
'ADVANCED',
'<?xml version="1.0" standalone="yes"?>
<AdvancedStyle>
  <CollectionStyle>
    <style name="C.US_STATES"/>
    <style name="V.POPULATION_BAR"/>
  </CollectionStyle>
</AdvancedStyle>'
);

-- Pie Chart
insert into user_sdo_styles (name, type, definition)
values (
'V.POPULATION_PIE',
'ADVANCED',
'<?xml version="1.0" ?>
<AdvancedStyle>
  <PieChartStyle pieradius="50.0km">
    <PieSlice name="Amerindian" color="#000000" />
    <PieSlice name="Asian"      color="#FF0000" />
    <PieSlice name="Black"      color="#00FF00" />
    <PieSlice name="Hispanic"   color="#0000FF" />
    <PieSlice name="White"      color="#FFFF00" />
   </PieChartStyle>
</AdvancedStyle>'
);

insert into user_sdo_styles (name, type, definition)
values (
'V.POPULATION_PIE_CO',
'ADVANCED',
'<?xml version="1.0" standalone="yes"?>
<AdvancedStyle>
  <CollectionStyle>
    <style name="C.US_STATES"/>
    <style name="V.POPULATION_PIE"/>
  </CollectionStyle>
</AdvancedStyle>'
);

-- Variable Pie Chart
insert into user_sdo_styles (name, type, definition)
values (
'V.POPULATION_VARPIE',
'ADVANCED',
'<?xml version="1.0" ?>
<AdvancedStyle>
  <VariablePieChartStyle startradius="40.0kilometer" increment="10.0kilometer">
    <PieSlice name="Amerindian" color="#000000" />
    <PieSlice name="Asian"      color="#FF0000" />
    <PieSlice name="Black"      color="#00FF00" />
    <PieSlice name="Hispanic"   color="#0000FF" />
    <PieSlice name="White"      color="#FFFF00" />
    <Buckets>
      <RangedBucket seq="0" label="0 - 100" low="-Infinity" high="1200000"/>
      <RangedBucket seq="1" label="0 - 100" low="1200000"   high="3000000"/>
      <RangedBucket seq="2" label="0 - 100" low="3000000"   high="6000000"/>
      <RangedBucket seq="3" label="0 - 100" low="6000000"   high="20000000"/>
      <RangedBucket seq="4" label="0 - 100" low="20000000"  high="Infinity"/>
    </Buckets>
   </VariablePieChartStyle>
</AdvancedStyle>'
);

insert into user_sdo_styles (name, type, definition)
values (
'V.POPULATION_VARPIE_CO',
'ADVANCED',
'<?xml version="1.0" standalone="yes"?>
<AdvancedStyle>
  <CollectionStyle>
    <style name="C.US_STATES"/>
    <style name="V.POPULATION_VARPIE"/>
  </CollectionStyle>
</AdvancedStyle>'
);

-- --------------------------------------------------------------
-- Heat Maps
-- --------------------------------------------------------------

-- Heat map - Colored
insert into user_sdo_styles (name, type, definition)
values (
'V.HEATMAP',
'ADVANCED',
'<?xml version="1.0" standalone="yes"?>
<AdvancedStyle>
  <HeatMapStyle>
    <color_stops num_steps="200" alpha="128">
     FFFFFF,0000FF,00F800,FFFF00,FF0000
  </color_stops>
    <spot_light_radius>100</spot_light_radius>
    <grid_sample_factor>2.5</grid_sample_factor>
    <container_theme>US_STATES</container_theme>
  </HeatMapStyle>
</AdvancedStyle>'
);

-- Heat map - Grayscale
insert into user_sdo_styles (name, type, definition)
values (
'V.HEATMAP_GRAYSCALE',
'ADVANCED',
'<?xml version="1.0" standalone="yes"?>
<AdvancedStyle>
  <HeatMapStyle>
    <color_stops num_steps="200" alpha="128">
      FFFFFF,CCCCCC,666666,333333,000000
  </color_stops>
    <spot_light_radius>100</spot_light_radius>
    <grid_sample_factor>2.5</grid_sample_factor>
    <container_theme>US_STATES</container_theme>
  </HeatMapStyle>
</AdvancedStyle>'
);

-- --------------------------------------------------------------
-- Themes
-- --------------------------------------------------------------
insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_STATES_V.AVGHHINC_CS_E',
'US_STATES',
'GEOM',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule column="AVGHHINC">
    <features style="V.AVGHHINC_CS_E"> </features>
    <label column="STATE" style="T.US_STATES"> 1 </label>
  </rule>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_STATES_V.AVGHHINC_CS_V',
'US_STATES',
'GEOM',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule column="AVGHHINC">
    <features style="V.AVGHHINC_CS_V"> </features>
    <label column="STATE" style="T.US_STATES"> 1 </label>
  </rule>
</styling_rules>'
);
insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_STATES_V.MEDHHINC_MC_E',
'US_STATES',
'GEOM',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule column="MEDHHINC">
    <features style="V.MEDHHINC_MC_E"> </features>
    <label column="STATE" style="T.US_STATES"> 1 </label>
  </rule>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_STATES_V.MEDHHINC_MC_V',
'US_STATES',
'GEOM',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule column="MEDHHINC">
    <features style="V.MEDHHINC_MC_V"> </features>
    <label column="STATE" style="T.US_STATES"> 1 </label>
  </rule>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_STATES_V.ONFARMS_VS',
'US_STATES',
'GEOM',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule column="ONFARMS">
    <features style="V.ONFARMS_CO"> </features>
    <label column="STATE" style="T.US_STATES"> 1 </label>
  </rule>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_STATES_V.TOTPOP_DD',
'US_STATES',
'GEOM',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule column="TOTPOP/200000">
    <features style="V.TOTPOP_CO"> </features>
    <label column="STATE" style="T.US_STATES"> 1 </label>
  </rule>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_STATES_V.POPULATION_BAR',
'US_STATES',
'GEOM',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule column="AMINDIAN,ASIANPI,BLACK,HISPANIC,WHITE">
    <features style="V.POPULATION_BAR_CO"> </features>
    <label column="STATE" style="T.US_STATES"> 1 </label>
  </rule>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_STATES_V.POPULATION_PIE',
'US_STATES',
'GEOM',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule column="AMINDIAN,ASIANPI,BLACK,HISPANIC,WHITE">
    <features style="V.POPULATION_PIE_CO"> </features>
    <label column="STATE" style="T.US_STATES"> 1 </label>
  </rule>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_STATES_V.POPULATION_VARPIE',
'US_STATES',
'GEOM',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule column="AMINDIAN,ASIANPI,BLACK,HISPANIC,WHITE">
    <features style="V.POPULATION_VARPIE_CO"> </features>
    <label column="STATE" style="T.US_STATES"> 1 </label>
  </rule>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_CITIES_V.HEATMAP',
'US_CITIES',
'LOCATION',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule>
    <features style="V.HEATMAP"> </features>
  </rule>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_CITIES_V.HEATMAP_GRAYSCALE',
'US_CITIES',
'LOCATION',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule>
    <features style="V.HEATMAP_GRAYSCALE"> </features>
  </rule>
</styling_rules>'
);

-- -------------------------------------------------------------------
-- Maps
-- -------------------------------------------------------------------

insert into user_sdo_maps (name, definition)
values (
'US_HEAT_MAP',
'<?xml version="1.0" standalone="yes"?>
<map_definition>
  <theme name="US_STATES"             min_scale="150000000" max_scale="0" scale_mode="RATIO"/>
  <theme name="US_COUNTIES"           min_scale="8500000"   max_scale="0" scale_mode="RATIO"/>
  <theme name="US_CITIES_V.HEATMAP" />
  <theme name="US_CITIES"             min_scale="15000000"  max_scale="0" scale_mode="RATIO"/>
</map_definition>'
);

insert into user_sdo_maps (name, definition)
values (
'US_HEATMAP_GRAYSCALE',
'<?xml version="1.0" standalone="yes"?>
<map_definition>
  <theme name="US_STATES"             min_scale="150000000" max_scale="0" scale_mode="RATIO"/>
  <theme name="US_COUNTIES"           min_scale="8500000"   max_scale="0" scale_mode="RATIO"/>
  <theme name="US_CITIES_V.HEATMAP_GRAYSCALE" />
  <theme name="US_CITIES"             min_scale="15000000"  max_scale="0" scale_mode="RATIO"/>
</map_definition>'
);

commit;

