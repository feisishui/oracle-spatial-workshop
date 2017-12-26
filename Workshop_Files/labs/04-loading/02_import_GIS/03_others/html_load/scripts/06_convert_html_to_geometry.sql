-- Extract the polygons from the HTML area map and convert them to geometry objects

/*
For each html document
  extract the <map> element
  for each <area> element in the map
    extract the "alt" attribute (provides the name of the area)
    extract the "coords" attribute
    convert it to an array of coordinates
    construct as geometry object
    affine transform (mirror it)     
    insert into the proper table

The html documenst look like this:

  <html>
    <head>
      <title>RegionsITM</title>
    </head>
    <body>
      <img src="" width="757" height="721" border="0" usemap="#myMap" />
      <map name="myMap">
        <area shape="poly" href="#N" alt="N" coords="275,0,273,1,...278,0,275,0">N</area>
        ...
        <area shape="poly" href="#SO" alt="SO" coords="269,316,275,318,...270,315,274,317"/>
      </map>
    </body>
  </html>

*/

declare
  i integer;
  j integer;
  k integer;
  v varchar2(50);
  geometry sdo_geometry;
  layer_mbr sdo_geometry;
  html xmltype;
  coords clob; 
begin
  for h in (select * from html_pages)
  loop
    -- Make the html text into an xml type.
    html := XMLType (h.html);
    dbms_output.put_line('Extracting areas from '||h.file_name||' into table '||h.table_name);
    -- Process areas one at the time
    for a in (
      select
         rownum as id, 
         p.extract('//@alt').getStringval() as area_name,
         p.extract('//@coords').getClobval() as coords
      from table(XMLSequence(Extract(html,'/html/body/map/area'))) p
    )
    loop
      coords := a.coords||',';
      
      -- Initialize the geometry object
      geometry := sdo_geometry(2003,262155,null,sdo_elem_info_array(1,1003,1), sdo_ordinate_array());
      
      -- Split the csv list of coordinates into the geometry object array
      i := 1;
      j := instr(coords,',');
      k := 0;
      while j > 0 loop
        v := substr(coords, i, j-1);
        k := k+1;
        geometry.sdo_ordinates.extend();
        geometry.sdo_ordinates(k) := v;
        i := i+j;
        j := instr(substr(coords,i),',');
      end loop;
      
      -- Close the polygon (repeat first point)
      geometry.sdo_ordinates.extend(2);
      geometry.sdo_ordinates(k+1) := geometry.sdo_ordinates(1);
      geometry.sdo_ordinates(k+2) := geometry.sdo_ordinates(2);
      
      -- Rectify the geometry (fix orientation and self-crossings)
      geometry := sdo_util.rectify_geometry(geometry, 0.05);
      
      -- Transform the geometry by reflection
      geometry := sdo_util.affinetransforms(
        geometry => geometry,
        reflection => 'TRUE', 
        lineR => sdo_geometry(2002,262155,null,sdo_elem_info_array(1,2,1),sdo_ordinate_array(0,0,100,0))
      );      
      
      -- Write the geometry into the output table
      execute immediate 'insert into '||h.table_name||' (id, area_name, geom) values (:1,:2,:3)'
      using a.id, a.area_name, geometry;
      
      -- Get the MBR of the output table
      execute immediate 'select sdo_aggr_mbr(geom) from '||h.table_name
      into layer_mbr;
      
      -- Update the input table with that MBR
      update html_pages set mbr = layer_mbr
      where id = h.id;
      
    end loop;
  end loop;
end;
/ 
show errors
commit;
