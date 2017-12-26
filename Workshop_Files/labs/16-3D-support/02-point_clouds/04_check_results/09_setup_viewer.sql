delete from USER_SDO_3DTHEMES where name = 'LIDAR_SCENES_THEME';
delete from USER_SDO_SCENES where name = 'LIDAR_SCENES_SCENE';
delete from USER_SDO_VIEWFRAMES where name = 'LIDAR_SCENES_VIEWFRAME';
delete from USER_SDO_ANIMATIONS where name = 'LIDAR_SCENES_ANIMATION';

insert into USER_SDO_3DTHEMES (
  name,
  base_table,
  theme_column,
  style_column,
  theme_type,
  definition
)
values (
  'LIDAR_SCENES_THEME',
  'LIDAR_SCENES',
  'POINT_CLOUD',
  ' ',
  'SDO_PC',
  '<theme3d themeType="SDO_PC" xmlns="http://xmlns.oracle.com/spatial/vis3d/2011/sdovis3d.xsd">
  <lod>
    <themeLOD>0</themeLOD>
    <generalization activationDistance="100"/>
  </lod>
  <defaultStyle>
    <elevationColor interpolateColors="true">
      <colorAtElevation elevation="100" color="0000FF"></colorAtElevation>
      <colorAtElevation elevation="300" color="FF0000"></colorAtElevation>
    </elevationColor>
    <normals>
      <generateNormals>FALSE</generateNormals>
    </normals>
  </defaultStyle>
  <typeSpecificMD>
    <SDO themeTable="LIDAR_SCENES" geometryColumn="POINT_CLOUD">
      <SDO_PC>
        <blockTable>PC_BLOCKS</blockTable>
      </SDO_PC>
    </SDO>
  </typeSpecificMD>
</theme3d>'
);

insert into USER_SDO_SCENES (
  name,
  definition
)
values (
  'LIDAR_SCENES_SCENE',
  '<scene3d xmlns="http://xmlns.oracle.com/spatial/vis3d/2011/sdovis3d.xsd">
    <theme display="true" pickable="false">LIDAR_SCENES_THEME</theme>
   </scene3d>'
);

insert into USER_SDO_VIEWFRAMES (
  name,
  scene_name,
  definition
)
values (
  'LIDAR_SCENES_VIEWFRAME',
  'LIDAR_SCENES',
  '<viewFrame3d xmlns="http://xmlns.oracle.com/spatial/vis3d/2011/sdovis3d.xsd">
    <sceneName>LIDAR_SCENES_SCENE</sceneName>
    <viewPoint3d >
      <eye    x="289566.244" y="4322296.85" z="500"/>
      <center x="289566.244" y="4322296.85" z="600"/>
      <up     x="0" y="1" z="0"/>
    </viewPoint3d>
    <defaultStyle/>
   </viewFrame3d>'
);

commit;
