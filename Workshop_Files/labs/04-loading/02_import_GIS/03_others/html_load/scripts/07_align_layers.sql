declare

-- Align the data in the output tables

/*

The areas on the image maps do not align: the pixel coordinates are different. 
In order to show them on the same base map, we need to align them.

1) Merge the bounding boxes:
Get the bounding box for each table, then get the total bounding box of the result.

2) Align them:
Get the center of each bounding box, compute the offset from the center of the total bounding box
Use affine transform translate to align the geometries

3) Scale them
Get the with and height of the total bounding box
Get the with and height of each bounding box
Compute the X and Y scaling factors
Use affine transform scale to align the geometries

*/

  total_mbr sdo_geometry;
  total_center sdo_geometry;
  layer_mbr sdo_geometry;
  layer_center sdo_geometry;
  tx number;
  ty number;
  sx number;
  sy number;
  update_stmt varchar2(256);
  
begin
  -- Get the bounding box for the combination of all layers
  select sdo_aggr_mbr(mbr), sdo_geom.sdo_centroid(sdo_aggr_mbr(mbr),0.05)
  into total_mbr, total_center
  from html_pages;
  
  dbms_output.put_line ('TOTAL MBR: '||sdo_tools.format(total_mbr));
  dbms_output.put_line ('TOTAL CENTER: '||sdo_tools.format(total_center));

  -- Align each layer
  for h in (select * from html_pages)
  loop
    -- Get the bounding box and centroid of that layer
    layer_mbr := h.mbr;
    layer_center := sdo_geom.sdo_centroid(layer_mbr,0.05);
        
    -- Compute translation parameters
    tx := total_center.sdo_point.x - layer_center.sdo_point.x;
    ty := total_center.sdo_point.y - layer_center.sdo_point.y;
    
    -- Compute scaling parameters
    sx := (total_mbr.sdo_ordinates(3)-total_mbr.sdo_ordinates(1))/(layer_mbr.sdo_ordinates(3)-layer_mbr.sdo_ordinates(1));
    sy := (total_mbr.sdo_ordinates(4)-total_mbr.sdo_ordinates(2))/(layer_mbr.sdo_ordinates(4)-layer_mbr.sdo_ordinates(2));

    dbms_output.put_line ('*** Table '||h.table_name);
    dbms_output.put_line ('MBR: '||sdo_tools.format(layer_mbr));
    dbms_output.put_line ('CENTER: '||sdo_tools.format(layer_center));
    dbms_output.put_line ('TRANSLATION: tx='||tx|| ' ty='||ty);
    dbms_output.put_line ('SCALING: sx='||sx|| ' sy='||sy);

    -- Apply the transformations
    update_stmt := 'update '|| h.table_name||
      ' set geom = sdo_util.affinetransforms(' ||
      '   geometry => geom,'||
      '   translation => ''TRUE'','||
      '   tx => :tx,'||
      '   ty => :ty '||
      ' )';
    dbms_output.put_line (update_stmt);
    execute immediate update_stmt
    using tx, ty;      
    
    update_stmt := 'update '|| h.table_name||
      ' set geom = sdo_util.affinetransforms(' ||
      '   geometry => geom,'||
      '   scaling => ''TRUE'','||
      '   psc1 => :center,'||
      '   sx => :sx,'||
      '   sy => :sy '||
      ' )';
    dbms_output.put_line (update_stmt);
    execute immediate update_stmt
    using total_center, sx, sy;      
    
  end loop;

end;
/