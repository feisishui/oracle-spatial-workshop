/*

This script defines a theme on your local WFS

Theme: WFS US_CITIES

NOTE: The URL specified for the WFS uses port 7001 (it assumes you have deployed MapViewer in Weblogic).
Change it to 8080 if you are using Glassfish

*/

delete from user_sdo_themes       where name = 'WFS US_CITIES';
set define off

-- -------------------------------------------------------------------
-- Theme
-- -------------------------------------------------------------------
insert into user_sdo_themes (name, base_table, geometry_column, styling_rules)
values (
'WFS US_CITIES',
'USCITIES',
'LOCATION',
'<?xml version="1.0" standalone="yes"?>
<styling_rules theme_type="wfs" service_url="http://localhost:7001/SpatialWS-SpatialWS-context-root/xmlwfsservlet?" srs="SDO:8307">
  <hidden_info>
    <field column="CITY" name=""/>
    <field column="POP90" name=""/>
    <field column="RANK90" name=""/>
    <field column="STATE_ABRV" name=""/>
  </hidden_info>
    <rule column="CITY,ID,POP90,RANK90,STATE_ABRV">
      <features style="M.US_CITIES"> </features>
      <label column="CITY" style="T.CITY NAME"> 1 </label>
  </rule>
</styling_rules>'
);

commit;
