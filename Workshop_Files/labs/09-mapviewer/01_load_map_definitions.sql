/*

This script defines a set of styles and themes on your spatial data

Table             Style               Label Style         Theme
----------------  ------------------  ------------------  ----------------
WORLD_COUNTRIES   C.WORLD_COUNTRIES   T.WORLD_COUNTRIES   WORLD_COUNTRIES
US_STATES         C.US_STATES         T.US_STATES         US_STATES
US_COUNTIES       C.US_COUNTIES       T.US_COUNTIES       US_COUNTIES
US_PARKS          C.US_PARKS                              US_PARKS
US_INTERSTATES    L.US_INTERSTATES    M.US_INTERSTATES    US_INTERSTATES
US_CITIES         M.US_CITIES         T.US_CITIES         US_CITIES
US_STATES_P       C.US_STATES         T.US_STATES         US_STATES_P
US_COUNTIES_P     C.US_COUNTIES       T.US_COUNTIES       US_COUNTIES_P
US_PARKS_P        C.US_PARKS                              US_PARKS_P
US_INTERSTATES_P  L.US_INTERSTATES    M.US_INTERSTATES    US_INTERSTATES_P
US_CITIES_P       M.US_CITIES         T.US_CITIES         US_CITIES_P

It also defines two base maps (US_BASE_MAP and US_BASE_MAP_P) and a map cache (US_BASE_MAP) that
use those themes.

*/

delete from user_sdo_styles       where name like ('_.US%');
delete from user_sdo_styles where name like ('_.WORLD%');
delete from user_sdo_themes       where name like ('US%');
delete from user_sdo_themes where name like ('WORLD%');
delete from user_sdo_maps         where name like ('US%');
delete from user_sdo_cached_maps  where name like ('US%');

-- -------------------------------------------------------------------
-- Styles
-- -------------------------------------------------------------------
insert into user_sdo_styles (name, type, definition)
values (
'C.WORLD_COUNTRIES',
'COLOR',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <desc></desc>
  <g class="color" style="stroke:#000000;fill:#FFFFCC">
    <rect width="50" height="50"/>
  </g>
</svg>'
);

insert into user_sdo_styles (name, type, definition)
values (
'C.US_STATES',
'COLOR',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <desc></desc>
  <g class="color" style="stroke:#000000;fill:#FFFFCC">
    <rect width="50" height="50"/>
  </g>
</svg>'
);

insert into user_sdo_styles (name, type, definition)
values (
'C.US_COUNTIES',
'COLOR',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <desc></desc>
  <g class="color" style="stroke:#000000;fill:#FFFFCC">
    <rect width="50" height="50"/>
  </g>
</svg>'
);

insert into user_sdo_styles (name, type, definition)
values (
'C.US_PARKS',
'COLOR',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <desc></desc>
  <g class="color" style="stroke:#5DB603;stroke-opacity:112;fill:#66CC00;fill-opacity:119">
    <rect width="50" height="50"/>
  </g>
</svg>'
);

insert into user_sdo_styles (name, type, definition)
values (
'L.US_INTERSTATES',
'LINE',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <desc></desc>
  <g class="line" cased="true" style="fill:#DB883F;stroke-width:3;stroke-linecap:BUTT">
    <line class="base"/>
  </g>
</svg>'
);

insert into user_sdo_styles (name, type, definition, image)
values (
'M.US_INTERSTATES',
'MARKER',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <desc></desc>
  <g class="marker" style="width:25;height:28;font-family:SansSerif;font-size:9;font-weight:bold;font-fill:#FFFFFF;text-offset-y:-1">
    <image x="0" y="0" width="1" height="1" markerType="gif" href="dummy.gif"/>
  </g>
</svg>',
hextoraw('89504E470D0A1A0A0000000D49484452000000180000001C08060000007BE67FEE0000001974455874536F6674776172650041646F626520496D616765526561647971C9653C000003F74944415478DAB4964D681B4714C7677667579223C9AEDC3455B1EA4B9B283490500C76D2424A6829F4D2164A690D6973F0D18640293DF49883939C8AB10AA686D28B4C8F25D043DA53A813237C6849AC282E3D08092B75FC115BEB95F66BA6F3DFCCBAB2C1A521F28A27ADF6BDF77B336FE6CD5B2A8420877969E4902F8D524A2041104C4A595132B9DFF069F51177F7F27D7FC56BB785BDB424702F4547FA20F2DEC033E860A3F446875EDFAFDF93A24AA512E38E43FF9A9CDCF97D622258BD71232138AFC9917C24E503E17955B75C36B66666C8C6D5AB2DDCE31974B0812D7CE00B06586082CDF095CD66CF3F9E9F37DBF53A735656F46AA190DCB97BD748E6F3DF198C1151ABE9FE830766BB54225A7F7F9CAFAE6AECC40997E672DF7BBE4FAC4AC558BB752B065F30C0CA0E0F9F97E89B4CE5EF056F7D5D771A0D1DFF61D42816199339EC81681A31E2F170CAC275A90C14F324D0E69CD848919440A5040CB098644629A286619CB1CA65D6AA56D9B3EE1A30C002136C2C3316A876FBDEC3ECF15C86A4128C98328CC04795C89EDDD071453504B5DC33C4F50969B67CB25CDB20E74EBDD8608CE530624D1ABA63D76F0ABBED85244E35893709D7E344C4928499299288C7484FDC0881D28EB4DA0EF1DD26A18E45B4A00DBC04F1502FEDC4D20F175DB09122FD10EB4CD7A219984CEBDA99011698D10C0EF3B8080310D775578F658EF06E51C10273B7926DDBAE0F1E4BF9DD0A0016985100B1B9B9F9677E30E3752B005860821D0628954A77DE3A33E0BCDC85598001169851005E2814964F0E66FCB3AF65DD670D00065860828D1AA0F57A5DA784972F7DF2FE3BA5FB0FCDB56D474779084DD6213389A6C7080E3D833D2919CFE7F2880E080F5C4221C2978516907CAECFFBFAB3E1E6B7DF5C9B989B9B438AEC700638A3A6A6A6EEBF32D0E77F393AD4EC4FC79F7A47C107BE60800526D8BB012CCBDAEA4DA73FBEF07ACE99F9E2C2C6AB03BDFF7BD1610B1FF8820156670054306056ABD55A4B25939F2F2FFEF2E34F57DE5DBFFCE1C9A6A1D303C1D0C106B6F0812F186029A688BCF18B0ED48B3A410FCAE7F383D3D3D3EFE54F8F8CCCFDF6A8E7D77BDB89352B5C33F27C520BDE3E956E7DFAE651BBF2C7C2C2F8F8F8CFB28355A5AA21E56F29D10C04FDF7C8A55A4790A352D030324343432FCDDFBEF3D5E68ECFA84693E131CD85F5DC11E6BF71EEECB5C5C545F4DF0D29A8DC471D701E8D7CCFE987B34A0A407D583B04492412BDA3A3A3C7C7C6C64660343B3BBB502C1697653AB6147C5DCA63951A6CF5A8C1117AC0BB12FA047A644A4A5A05C3CC7A948DAD460AE8B694263A2D5E4EA291FF5780CED9182A5052054B449D51412D05F664AA83FD80F0DDE8A036A80CA89A91D92144A521122E3A9CF6B7D77F0418006C3B6108BEA0DC8F0000000049454E44AE426082')
);

insert into user_sdo_styles (name, type, definition)
values (
'M.US_CITIES',
'MARKER',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in">
  <desc/>
  <g class="marker" style="stroke:#FFFFFF;fill:#FF0000;width:9;height:9;font-family:Dialog;font-size:12;font-fill:#FF0000">
    <circle cx="0" cy="0" r="0"/>
  </g>
</svg>'
);

insert into user_sdo_styles (name, type, definition)
values (
'T.WORLD_COUNTRIES',
'TEXT',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in" >
  <desc></desc>
   <g class="text" float-width="4" float-color="#FFFFFF" style="font-style:plain;font-family:Dialog;font-size:18;font-weight:bold;text-align:center;fill:#003399"> Hello World!
     <opoint halign="center" valign="middle" />
     <text-along-path  valign="baseline" />
  </g>
</svg>'
);

insert into user_sdo_styles (name, type, definition)
values (
'T.US_STATES',
'TEXT',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in" >
  <desc></desc>
   <g class="text" float-width="4" float-color="#FFFFFF" style="font-style:plain;font-family:Dialog;font-size:18;font-weight:bold;text-align:center;fill:#003399"> Hello World!
     <opoint halign="center" valign="middle" />
     <text-along-path  valign="baseline" />
  </g>
</svg>'
);

insert into user_sdo_styles (name, type, definition)
values (
'T.US_COUNTIES',
'TEXT',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in" >
  <desc></desc>
    <g class="text" float-width="2" float-color="#FFFFFF" style="font-style:plain;font-family:Dialog;font-size:12;text-align:center;fill:#3366FF"> Hello World!
     <opoint halign="center" valign="middle" />
     <text-along-path  valign="baseline" />
  </g>
</svg>'
);

insert into user_sdo_styles (name, type, definition)
values (
'T.US_CITIES',
'TEXT',
'<?xml version="1.0" standalone="yes"?>
<svg width="1in" height="1in" >
  <desc></desc>
  <g class="text" float-width="2" float-color="#FFFFFF" style="font-style:plain;font-family:Dialog;font-size:12;font-weight:bold;text-align:center;fill:#000000"> Hello World!
    <opoint halign="center" valign="middle"/>
    <text-along-path valign="baseline"/>
  </g>
 </svg>'
);

-- -------------------------------------------------------------------
-- Themes on geodetic tables
-- -------------------------------------------------------------------
insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'WORLD_COUNTRIES',
'WORLD_COUNTRIES',
'GEOMETRY',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule>
    <features style="C.WORLD_COUNTRIES"> </features>
    <label column="CNTRY_NAME" style="T.WORLD_COUNTRIES"> 1 </label>
  </rule>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_STATES',
'US_STATES',
'GEOM',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
    <hidden_info>
        <field column="STATE" name=""/>
        <field column="STATE_ABRV" name=""/>
        <field column="TOTPOP" name=""/>
        <field column="POPPSQMI" name=""/>
  </hidden_info>
    <rule>
        <features style="C.US_STATES"> </features>
        <label column="STATE" style="T.US_STATES"> 1 </label>
  </rule>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_COUNTIES',
'US_COUNTIES',
'GEOM',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule>
    <features style="C.US_COUNTIES"> </features>
    <label column="COUNTY" style="T.US_COUNTIES"> 1 </label>
  </rule>
</styling_rules>'
);
insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_PARKS',
'US_PARKS',
'GEOM',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule>
    <features style="C.US_PARKS"> </features>
  </rule>
</styling_rules>'
);
insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_INTERSTATES',
'US_INTERSTATES',
'GEOM',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule>
    <features style="L.US_INTERSTATES"> </features>
    <label column="INTERSTATE" style="M.US_INTERSTATES"> 1 </label>
  </rule>
</styling_rules>'
);
insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_CITIES',
'US_CITIES',
'LOCATION',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule>
    <features style="M.US_CITIES"> </features>
    <label column="CITY" style="T.US_CITIES"> 1 </label>
  </rule>
</styling_rules>'
);

-- -------------------------------------------------------------------
-- Themes on projected tables
-- -------------------------------------------------------------------
insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_STATES_P',
'US_STATES_P',
'GEOM',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
    <hidden_info>
        <field column="STATE" name=""/>
        <field column="STATE_ABRV" name=""/>
        <field column="TOTPOP" name=""/>
        <field column="POPPSQMI" name=""/>
  </hidden_info>
    <rule>
        <features style="C.US_STATES"> </features>
        <label column="STATE" style="T.US_STATES"> 1 </label>
  </rule>
</styling_rules>'
);

insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_COUNTIES_P',
'US_COUNTIES_P',
'GEOM',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule>
    <features style="C.US_COUNTIES"> </features>
    <label column="COUNTY" style="T.US_COUNTIES"> 1 </label>
  </rule>
</styling_rules>'
);
insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_PARKS_P',
'US_PARKS_P',
'GEOM',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule>
    <features style="C.US_PARKS"> </features>
  </rule>
</styling_rules>'
);
insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_INTERSTATES_P',
'US_INTERSTATES_P',
'GEOM',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule>
    <features style="L.US_INTERSTATES"> </features>
    <label column="INTERSTATE" style="M.US_INTERSTATES"> 1 </label>
  </rule>
</styling_rules>'
);
insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'US_CITIES_P',
'US_CITIES_P',
'LOCATION',
'<?xml version="1.0" standalone="yes"?>
<styling_rules>
  <rule>
    <features style="M.US_CITIES"> </features>
    <label column="CITY" style="T.US_CITIES"> 1 </label>
  </rule>
</styling_rules>'
);


-- -------------------------------------------------------------------
-- Maps
-- -------------------------------------------------------------------

insert into user_sdo_maps (name, definition)
values (
'US_BASE_MAP',
'<?xml version="1.0" standalone="yes"?>
<map_definition>
  <theme name="WORLD_COUNTRIES"                                       scale_mode="RATIO"/>
  <theme name="US_STATES"         min_scale="150000000" max_scale="0" scale_mode="RATIO"/>
  <theme name="US_COUNTIES"       min_scale="8500000"   max_scale="0" scale_mode="RATIO"/>
  <theme name="US_PARKS"          min_scale="10000000"  max_scale="0" scale_mode="RATIO"/>
  <theme name="US_INTERSTATES"    min_scale="20000000"  max_scale="0" scale_mode="RATIO"/>
  <theme name="US_CITIES"         min_scale="15000000"  max_scale="0" scale_mode="RATIO"/>
</map_definition>'
);

insert into user_sdo_maps (name, definition)
values (
'US_BASE_MAP_P',
'<?xml version="1.0" standalone="yes"?>
<map_definition>
  <theme name="US_STATES_P"       min_scale="150000000" max_scale="0" scale_mode="RATIO"/>
  <theme name="US_COUNTIES_P"     min_scale="8500000"   max_scale="0" scale_mode="RATIO"/>
  <theme name="US_PARKS_P"        min_scale="10000000"  max_scale="0" scale_mode="RATIO"/>
  <theme name="US_INTERSTATES_P"  min_scale="20000000"  max_scale="0" scale_mode="RATIO"/>
  <theme name="US_CITIES_P"       min_scale="15000000"  max_scale="0" scale_mode="RATIO"/>
</map_definition>'
);

-- -------------------------------------------------------------------
-- Map Caches
-- -------------------------------------------------------------------
insert into user_sdo_cached_maps (name, is_online, is_internal, definition, base_map)
values (
'US_BASE_MAP',
'YES',
'YES',
'<map_tile_layer name="US_BASE_MAP" image_format="PNG" http_header_expires="168.0" concurrent_fetching_threads="3">
   <internal_map_source data_source="SCOTT" base_map="US_BASE_MAP" bgcolor="#33ccff"/>
   <tile_storage root_path="/tmp"/>
   <coordinate_system srid="8307" minX="-180.0" minY="-90.0" maxX="180.0" maxY="90.0"/>
   <tile_image width="256" height="256"/>
   <zoom_levels levels="20" min_scale="645309.0" max_scale="2.13103147E8"/>
</map_tile_layer>',
'US_BASE_MAP'
);

commit;
