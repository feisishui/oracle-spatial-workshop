CREATE OR REPLACE PACKAGE BODY sdo_tools AS

------------------------------------------------------------------------------
function point
  (x number,
   y number,
   z number
  )
  return sdo_geometry
is
  gtype number;
begin
  if z is null then
    gtype := 2001;
  else
    gtype := 3001;
  end if;
  return sdo_geometry (gtype, null, sdo_point_type (x, y, z), null, null);
end;
------------------------------------------------------------------------------
function rectangle
  (xll number,
   yll number,
   xur number,
   yur number
  )
  return sdo_geometry
is
begin
  --return sdo_geometry (
  --         2003, null, null,
  --         sdo_elem_info_array(1, 1003, 3),
  --         sdo_ordinate_array (xll, yll, xur, yur)
  --       );
  return sdo_geometry (
           2003, 8307, null,
           sdo_elem_info_array(1, 1003, 1),
           sdo_ordinate_array (xll, yll, xll, yur, xur, yur, xur, yll, xll, yll)
         );
end;
------------------------------------------------------------------------------
function circle
  (x number,
   y number,
   radius number
  )
  return sdo_geometry
is
begin
  return sdo_geometry (
     2003, null, null,
     sdo_elem_info_array(1, 1003, 4),
     sdo_ordinate_array (
       x-radius, y,
       x,        y+radius,
       x+radius, y)
  );
end;

function circle
  (x1 number, y1 number,
   x2 number, y2 number,
   x3 number, y3 number
  )
  return sdo_geometry
is
begin
  return sdo_geometry (
     2003, null, null,
     sdo_elem_info_array(1, 1003, 4),
     sdo_ordinate_array (
       x1, y1,
       x2, y2,
       x3, y3)
  );
end;
------------------------------------------------------------------------------
function format
  (geom sdo_geometry)
  return varchar2
is
  output_string varchar2(32767);
  MAX_LENGTH number := 3980;
begin
  if geom is null then
    return NULL;
  end if;
  -- Initialyze output string
  output_string := 'SDO_GEOMETRY(';
  -- Format SDO_GTYPE
  output_string := output_string || geom.sdo_gtype;
  output_string := output_string || ', ';
  -- Format SDO_SRID
  if geom.sdo_srid is not null then
    output_string := output_string || geom.sdo_srid;
  else
    output_string := output_string || 'NULL';
  end if;
  output_string := output_string || ', ';
  -- Format SDO_POINT
  if geom.sdo_point is not null then
    output_string := output_string || 'SDO_POINT_TYPE(';
    output_string := output_string || geom.sdo_point.x || ', ';
    output_string := output_string || geom.sdo_point.y || ', ';
    if geom.sdo_point.z is not null then
      output_string := output_string || geom.sdo_point.z || ')';
    else
      output_string := output_string || 'NULL)';
    end if;
  else
    output_string := output_string || 'NULL';
  end if;
  output_string := output_string || ', ';
  -- Format SDO_ELEM_INFO
  if geom.sdo_elem_info is not null then
    output_string := output_string || 'SDO_ELEM_INFO_ARRAY(';
    if geom.sdo_elem_info.count > 0 then
      for i in geom.sdo_elem_info.first..geom.sdo_elem_info.last loop
        if i > 1 then
          output_string := output_string || ', ';
        end if;
        output_string := output_string || geom.sdo_elem_info(i);
      end loop;
    end if;
    output_string := output_string || ')';
  else
    output_string := output_string || 'NULL';
  end if;
  output_string := output_string || ', ';
  -- Format SDO_ORDINATES
  if geom.sdo_ordinates is not null then
    output_string := output_string || 'SDO_ORDINATE_ARRAY(';
    if geom.sdo_ordinates.count > 0 then
      for i in geom.sdo_ordinates.first..geom.sdo_ordinates.last loop
        exit when length(output_string) > MAX_LENGTH;
        if i > 1 then
          output_string := output_string || ', ';
        end if;
        output_string := output_string || geom.sdo_ordinates(i);
      end loop;
      if length(output_string) > MAX_LENGTH then
        output_string := output_string || ' <...>';
      end if;
    end if;
    output_string := output_string || ')';
  else
    output_string := output_string || 'NULL';
  end if;
  output_string := output_string || ')';
  -- output_string := output_string || ' [' || length(output_string) || ']';
  -- Done - return formatted string
  return output_string;
end;
------------------------------------------------------------------------------
function get_num_elements (
  geom sdo_geometry
)
return number
is
  e_offset integer;              -- element offset (from elem_info array)
  e_type integer;                -- element type (from elem_info array)
  e_stype integer;               -- element type (single digit)
  e_interp integer;              -- element interpretation (from elem_info array)
  e_last integer;                -- index to last elem_info_array triplet for element
  e_count integer;               -- count of elements in input geometry
  i integer;

begin

  -- If input geometry is null, return null
  if geom is null then
    return 0;
  end if;

  -- Count of elements in input geometry
  e_count := 0;

  -- Main loop: process elements
  i := geom.sdo_elem_info.first;
  while i < geom.sdo_elem_info.last loop

    -- Count input elements
    e_count := e_count + 1;

    -- Extract element info
    e_offset := geom.sdo_elem_info(i);
    e_type := geom.sdo_elem_info(i+1);
    e_stype := substr(e_type, length(e_type), 1); -- convert to single-digit etype
    e_interp := geom.sdo_elem_info(i+2);

    -- Identify element number and type
    if e_stype <= 3 then
      -- Etype 1, 2, 3: this is a simple element
      e_last := i;                  -- Index to last elem_info triplet
    else
      -- Etype 4, 5: this is a compound element
      e_last := i+e_interp*3;       -- Index to last elem_info triplet
    end if;

    -- advance to next element
    i := e_last + 3;

   end loop;

  return e_count;
end;
------------------------------------------------------------------------------
function get_num_ordinates
  (geom sdo_geometry)
  return number
is
begin
  if geom is null then
    return null;
  end if;
  if geom.sdo_ordinates is not null then
    return geom.sdo_ordinates.count();
  else
    return NULL;
  end if;
end;
------------------------------------------------------------------------------
function get_num_points
  (geom sdo_geometry)
  return number
is
  dim_count integer;
begin
  -- If input geometry is null, return null
  if geom is null then
    return 0;
  end if;
  -- Get the number of dimensions from the gtype
  if length (geom.sdo_gtype) = 4 then
    dim_count := substr (geom.sdo_gtype, 1, 1);
  else
    -- Indicate failure
    raise_application_error (-20000, 'Unable to determine dimensionality from gtype');
  end if;
 if geom.sdo_ordinates is not null then
   return geom.sdo_ordinates.count() / dim_count;
 else
   return 1;
 end if;
end;
------------------------------------------------------------------------------
function get_num_decimals
  (geom sdo_geometry)
  return number
is
  dim_count integer;
  max_decimals number := 0;
  num_decimals number;
begin
  -- If input geometry is null, return null
  if geom is null then
    return null;
  end if;
  -- Get the number of dimensions from the gtype
  if length (geom.sdo_gtype) = 4 then
    dim_count := substr (geom.sdo_gtype, 1, 1);
  else
    -- Indicate failure
    raise_application_error (-20000, 'Unable to determine dimensionality from gtype');
  end if;
  if geom.sdo_ordinates is null then
    max_decimals := greatest (
      length(mod (geom.sdo_point.x,1))-1,
      length(mod (geom.sdo_point.y,1))-1,
      length(mod (nvl(geom.sdo_point.z,0),1))-1
    );
  else
    for i in geom.sdo_ordinates.first..geom.sdo_ordinates.last loop
      num_decimals := length(mod (geom.sdo_ordinates(i),1))-1;
      if num_decimals > max_decimals then
        max_decimals := num_decimals;
      end if;
    end loop;
  end if;
  return max_decimals;
end;
------------------------------------------------------------------------------
function get_point_x
  (geom sdo_geometry)
  return number
is
  gtype number;
begin
 gtype := geom.sdo_gtype;
 gtype := substr(gtype, length(gtype), 1); -- convert to single-digit gtype
 if gtype = 1 then
   if geom.sdo_ordinates is not null then
     return geom.sdo_ordinates(1);
   else
     return geom.sdo_point.x;
   end if;
 else
   return NULL;
 end if;
end;

------------------------------------------------------------------------------
function get_point_y
  (geom sdo_geometry)
  return number
is
  gtype number;
begin
 gtype := geom.sdo_gtype;
 gtype := substr(gtype, length(gtype), 1); -- convert to single-digit gtype
 if gtype = 1 then
   if geom.sdo_ordinates is not null then
     return geom.sdo_ordinates(2);
   else
     return geom.sdo_point.y;
   end if;
 else
   return NULL;
 end if;
end;

------------------------------------------------------------------------------
function get_ordinate
  (geom sdo_geometry,
   i number)
  return number
is
begin
 if geom.sdo_ordinates is not null and
    i <= geom.sdo_ordinates.count() then
     return geom.sdo_ordinates(i);
 else
   return NULL;
 end if;
end;

------------------------------------------------------------------------------
function get_point (
  geom sdo_geometry, point_number number default 1
) return sdo_geometry
is
  d  number;            -- Number of dimensions in geometry
  i  number;            -- Index into ordinates array
  px number;            -- X of extracted point
  py number;            -- Y of extracted point
  pz number;            -- Z of extracted point
begin
  -- Return if input geometry is null
  if geom is null then
    return null;
  end if;

  -- Get the number of dimensions from the gtype
  if length (geom.sdo_gtype) = 4 then
    d := substr (geom.sdo_gtype, 1, 1);
  else
    raise_application_error (-20000, 'Unable to determine dimensionality from gtype');
  end if;

  -- Get index into ordinates array. If negative, count backwards from the end of the array
  if point_number > 0 then
    i := (point_number-1) * d + 1;
  else
    i := point_number*d + geom.sdo_ordinates.count() + 1;
  end if;

  -- Verify that the point exists
  if i > geom.sdo_ordinates.last()
  or i < geom.sdo_ordinates.first() then
    raise_application_error (-20000, 'Invalid point number');
  end if;

  -- Extract the X and Y coordinates of the desired point
  px := geom.sdo_ordinates(i);
  py := geom.sdo_ordinates(i+1);
  if d >= 3 then
    pz := geom.sdo_ordinates(i+2);
  else
    pz := null;
  end if;

  -- Construct and return the point
  return
    sdo_geometry (
      d*1000+1,
      geom.sdo_srid,
      sdo_point_type (px, py, pz),
      null, null);
end;
------------------------------------------------------------------------------
function get_first_point (
  geom sdo_geometry
) return sdo_geometry
is
begin
  return get_point(geom, 1);
end;
------------------------------------------------------------------------------
function get_last_point (
  geom sdo_geometry
) return sdo_geometry
is
begin
  return get_point(geom, -1);
end;
------------------------------------------------------------------------------
function insert_point
  (line         sdo_geometry,
   point        sdo_geometry,
   insert_before number
 ) return sdo_geometry
is
  g   sdo_geometry;  -- Updated geometry
  d   number;              -- Number of dimensions in line geometry
  dp  number;              -- Number of dimensions in point geometry
  t   number;              -- Geometry type
  p   number;              -- Insertion point into ordinates array
  i   number;
begin
  -- Return NULL if any of the input geometries is null
  if line is null or point is null then
    return null;
  end if;

  -- Get the number of dimensions from the line geometry
  if length (line.sdo_gtype) = 4 then
    d := substr (line.sdo_gtype, 1, 1);
  else
    raise_application_error (-20000, 'Unable to determine dimensionality of line geometry');
  end if;

  -- Get the number of dimensions from the point geometry
  if length (point.sdo_gtype) = 4 then
    dp := substr (point.sdo_gtype, 1, 1);
  else
    raise_application_error (-20000, 'Unable to determine dimensionality of point geometry');
  end if;

  -- Verify gtype and number of elements of line geometry
  if substr (line.sdo_gtype, -1, 1) != 2 then
    raise_application_error (-20000, 'First argument not a line geometry');
  end if;

  -- Verify gtype and number of elements of point geometry
  if substr (point.sdo_gtype, -1, 1) != 1 then
    raise_application_error (-20000, 'Second argument not a point geometry');
  end if;

  -- Verify if the line and point geometries are compatible
  if d <> dp then
    raise_application_error (-20000, 'Line and point have different dimensions');
  end if;
  if (line.sdo_srid = point.sdo_srid)
  or (line.sdo_srid is null and point.sdo_srid is null) then
    null;
  else
    raise_application_error (-20000, 'Line and point have different coordinate systems');
  end if;

  if insert_before is null then
    -- We don't know where the point must be inserted
    -- 1) Determine the number of points in the line
    -- 2) Convert the input line into an LRS line (use point number as index)
    -- 3) Project the point onto the line
    -- 4) The measure of the point determines the insertion location
   null;
  end if;
  
  -- Determine insertion point into ordinates array.
  -- If negative, count backwards from the end of the array
  -- If zero, then insert at the end (after last point)
  case
    when insert_before > 0 then
      p := (insert_before-1) * d + 1;
    when insert_before < 0 then
      p := insert_before*d + line.sdo_ordinates.count() + 1;
    when insert_before = 0 then
      p := line.sdo_ordinates.count() + 1;
  end case;

  -- Verify that the insertion point exists
  if insert_before <> 0 then
    if p > line.sdo_ordinates.last()
    or p < line.sdo_ordinates.first() then
        RAISE_application_error (-20000, 'Invalid insertion point');
    end if;
  end if;

  -- Initialize output line with input line
  g := line;

  -- Extend the ordinates array
  g.sdo_ordinates.extend(d);

  -- Shift the ordinates up.
  for i in reverse p..g.sdo_ordinates.count()-d loop
    g.sdo_ordinates(i+d) := g.sdo_ordinates(i);
  end loop;

  -- Store the new point
  g.sdo_ordinates(p) := point.sdo_point.x;
  g.sdo_ordinates(p+1) := point.sdo_point.y;
  if dp = 3 then
    g.sdo_ordinates(p+2) := point.sdo_point.z;
  end if;

  -- Return new line string
  return g;
end;
------------------------------------------------------------------------------
function insert_first_point (
  line         sdo_geometry,
  point        sdo_geometry
) return sdo_geometry
is
begin
  return insert_point(line, point, 1);
end;
------------------------------------------------------------------------------
function insert_last_point (
  line         sdo_geometry,
  point        sdo_geometry
) return sdo_geometry
is
begin
  return insert_point(line, point, 0);
end;
------------------------------------------------------------------------------
function remove_point (
  line          sdo_geometry,
  point_number  number
) return sdo_geometry
is
  g sdo_geometry;  -- Updated geometry
  d number;              -- Number of dimensions in geometry
  p number;              -- Index into ordinates array
  i number;
begin

  -- Return if input geometry is null
  if line is null then
    return null;
  end if;

  -- Get the number of dimensions from the gtype
  if length (line.sdo_gtype) = 4 then
    d := substr (line.sdo_gtype, 1, 1);
  else
    raise_application_error (-20000, 'Unable to determine dimensionality from gtype');
  end if;

  -- Verify gtype and number of elements of line geometry
  if substr (line.sdo_gtype, -1, 1) != 2 then
    raise_application_error (-20000, 'First argument not a line geometry');
  end if;

  -- Get index into ordinates array. If negative, count backwards from the end of the array
  if point_number > 0 then
    p := (point_number-1) * d + 1;
  else
    p := point_number*d + line.sdo_ordinates.count() + 1;
  end if;

  -- Verify that the point exists
  if p > line.sdo_ordinates.last()
  or p < line.sdo_ordinates.first() then
    raise_application_error (-20000, 'Invalid point number');
  end if;

  -- Initialize output line with input line
  g := line;

  -- Shift the ordinates down
  for i in p..g.sdo_ordinates.count()-d loop
    g.sdo_ordinates(i) := g.sdo_ordinates(i+d);
  end loop;

  -- Trim the ordinates array
  g.sdo_ordinates.trim (d);

  -- Return new line string
  return g;

end;
------------------------------------------------------------------------------
function remove_first_point (
  line          sdo_geometry
) return sdo_geometry
is
begin
  return remove_point(line, 1);
end;
------------------------------------------------------------------------------
function remove_last_point (
  line          sdo_geometry
) return sdo_geometry
is
begin
  return remove_point(line, -1);
end;
------------------------------------------------------------------------------
function reverse_linestring (
  line          sdo_geometry
) return sdo_geometry
is
  g sdo_geometry;  -- Updated geometry
  d number;              -- Number of dimensions in geometry
  p number;              -- Index into ordinates array
  i integer;
  j integer;
  k integer;
  l integer;
begin

  -- Return if input geometry is null
  if line is null then
    return null;
  end if;

  -- Get the number of dimensions from the gtype
  if length (line.sdo_gtype) = 4 then
    d := substr (line.sdo_gtype, 1, 1);
  else
    raise_application_error (-20000, 'Unable to determine dimensionality from gtype');
  end if;

  -- Verify gtype and number of elements of line geometry
  if substr (line.sdo_gtype, -1, 1) != 2 then
    raise_application_error (-20000, 'First argument not a line geometry');
  end if;

  -- Initialize output line with input line
  g := line;

  -- Copy the ordinates in reverse order
  j := line.sdo_ordinates.last-d+1;         -- last point in input ordinate array
  k := 1;                                   -- first point in output ordinate array
  for i in reverse 1..line.sdo_ordinates.count()/d loop
    for l in 1..d loop
      g.sdo_ordinates(k+l-1) := line.sdo_ordinates(j+l-1);
    end loop;
    j := j - d;                             -- decrement input array
    k := k + d;                             -- increment output array
  end loop;
  -- Return new line string
  return g;

end;
------------------------------------------------------------------------------
function get_element
  (geom sdo_geometry,
   element_num number
  )
  return sdo_geometry
is
  out_geom sdo_geometry;   -- Resulting geometry
  dim_count integer;             -- number of dimensions in layer
  gtype integer;                 -- geometry type (single digit)
  e_offset integer;              -- element offset (from elem_info array)
  e_type integer;                -- element type (from elem_info array)
  e_stype integer;               -- element type (single digit)
  e_category integer;            -- element category (1, 2 or 3)
  e_multi boolean;               -- true if multi-geometry, false if not
  e_interp integer;              -- element interpretation (from elem_info array)
  e_first integer;               -- index to first elem_info_array triplet for element
  e_last integer;                -- index to last elem_info_array triplet for element
  e_index integer;               -- index into output elem_info_array
  e_count_in integer;            -- count of elements in input geometry
  e_count_out integer;           -- count of elements in output geometry
  o_first integer;               -- index to first ordinate in element
  o_last integer;                -- index to last ordinate in element
  o_offset integer;              -- offset into output ordinate array
  o_index integer;               -- index into output ordinate_array
  i integer;
  j integer;
  k integer;

begin

  -- If input geometry is null, return null
  if geom is null then
    return null;
  end if;

  -- Get the number of dimensions from the gtype
  if length (geom.sdo_gtype) = 4 then
    dim_count := substr (geom.sdo_gtype, 1, 1);
  else
    -- Indicate failure
    raise_application_error (-20000, 'Unable to determine dimensionality from gtype');
  end if;

  -- Get the single-digit gtype
  gtype := substr(gtype, length(gtype), 1);

  -- Construct output geometry
  out_geom := sdo_geometry (NULL, NULL, NULL,
    sdo_elem_info_array (), sdo_ordinate_array() );

  e_count_in := 0;     -- Count of elements in input geometry
  e_count_out := 0;    -- Count of elements in output geometry
  e_index := 1;        -- Index in output elem_info array
  o_index := 1;        -- Index in output ordinates array

  -- Main loop: process elements
  i := geom.sdo_elem_info.first;
  while i < geom.sdo_elem_info.last loop

    -- Count input elements
    e_count_in := e_count_in + 1;

    -- Extract element info
    e_offset := geom.sdo_elem_info(i);
    e_type := geom.sdo_elem_info(i+1);
    e_stype := substr(e_type, length(e_type), 1); -- convert to single-digit etype
    e_interp := geom.sdo_elem_info(i+2);
    e_multi := false;

    -- Identify element number and type
    if e_stype <= 3 then
      -- Etype 1, 2, 3: this is a simple element
      e_category := e_stype;        -- Category is 1, 2 or 3
      e_first    := i;              -- Index to first elem_info triplet
      e_last     := i;              -- Index to last elem_info triplet
      if e_stype = 1 and e_interp > 1 then
        e_multi := true;            -- This is a multi-point
      end if;
    else
      -- Etype 4, 5: this is a compound element
      e_category := e_stype - 2;    -- Category is 2 or 3
      e_first    := i;              -- Index to first elem_info triplet
      e_last     := i+e_interp*3;   -- Index to last elem_info triplet
    end if;

    if e_count_in = element_num then

      -- Count output element
      e_count_out := e_count_out + 1;

      -- Identify the first and last offset of the ordinates to copy
      o_first := e_offset;
      if e_last+3 > geom.sdo_elem_info.last then
        o_last:= geom.sdo_ordinates.last;
      else
        o_last := geom.sdo_elem_info(e_last+3) - 1;
      end if;
      o_offset := o_first - o_index;

      -- Copy elem_info into output geometry
      out_geom.sdo_elem_info.extend(e_last-e_first+3);
      j := e_first;
      while j <= e_last loop
        out_geom.sdo_elem_info (e_index)   := geom.sdo_elem_info (j) - o_offset;
        out_geom.sdo_elem_info (e_index+1) := geom.sdo_elem_info (j+1);
        out_geom.sdo_elem_info (e_index+2) := geom.sdo_elem_info (j+2);
        j := j + 3;
        e_index := e_index + 3;
      end loop;

      -- Copy ordinates into output geometry
      out_geom.sdo_ordinates.extend(o_last-o_first+1);
      k := o_first;
      while k <= o_last loop
        out_geom.sdo_ordinates (o_index)   := geom.sdo_ordinates (k);
        k := k + 1;
        o_index := o_index + 1;
      end loop;

      -- Loop is complete: we got the element we wanted
      exit;

    end if;

    -- advance to next element
    i := e_last + 3;

   end loop;

  -- If no elements retained, then return NULL
  if e_count_out = 0 then
    return null;
  end if;

  -- Set geometry type
  out_geom.sdo_gtype := e_category;
  if e_multi then
    out_geom.sdo_gtype := out_geom.sdo_gtype + 4;
  end if;

  -- Incorporate dimension count in gtype
  out_geom.sdo_gtype := dim_count * 1000 + out_geom.sdo_gtype;

  -- Set SRID: same as input
  out_geom.sdo_srid := geom.sdo_srid;

  return out_geom;
end;
------------------------------------------------------------------------------
function get_elements (
    geom sdo_geometry
) 
return sdo_geometry_table
pipelined
as
begin
  for i in 1..sdo_util.getnumelem(geom) loop
    pipe row (
      sdo_geometry_row (
        i,
        null,
        sdo_util.extract(geom,i)
      )
    );
  end loop;
  return;
end;
------------------------------------------------------------------------------
function get_rings (
    geom sdo_geometry
) 
return sdo_geometry_table
pipelined
as
  elem_geom sdo_geometry;
begin
  for i in 1..sdo_util.getnumelem(geom) loop
    elem_geom := sdo_util.extract(geom,i);
    for j in 1..sdo_tools.get_num_elements(elem_geom) loop
      pipe row (
        sdo_geometry_row (
          i,
          j,
          sdo_util.extract(elem_geom,1,j)
        )
      );
    end loop;
  end loop;
  return;
end;
------------------------------------------------------------------------------
function get_element_type
  (geom sdo_geometry
  )
  return varchar2
is
  etype_name varchar2(20);
  etype integer;                 -- element/section type (from elem_info array)
  interp integer;                -- element/section interpretation (from elem_info array)
  rtype integer;                 -- ring type for polygon (outer or inner)
begin
  if geom.sdo_elem_info is null then
    return NULL;
  end if;

  -- Extract element info (etype, ring type)
  etype := geom.sdo_elem_info(2);
  return etype;
  if length (etype) = 4 then
    rtype := substr (etype, 1, 1);
  else
    rtype := 0;
  end if;
  etype := substr(etype, length(etype), 1); -- convert to single-digit etype
  interp := geom.sdo_elem_info(3);

  -- Format element type
  if etype = 1 and interp = 1 then
    etype_name := 'POINT';
  elsif etype = 1 and interp > 1 then
    etype_name := 'POINT CLUSTER';
  elsif etype = 2 and interp = 1 then
    etype_name := 'LINE STRING';
  elsif etype = 2 and interp = 2 then
    etype_name := 'ARC STRING';
  elsif etype = 3 and interp = 1 then
    etype_name := 'POLYGON';
  elsif etype = 3 and interp = 2 then
    etype_name := 'ARC POLYGON';
  elsif etype = 3 and interp = 3 then
    etype_name := 'RECTANGLE';
  elsif etype = 3 and interp = 4 then
    etype_name := 'CIRCLE';
  elsif etype = 4 then
    etype_name := 'MIXED LINE STRING';
  elsif etype = 5 then
    etype_name := 'MIXED POLYGON';
  else
    etype_name := 'UNKNOWN';
  end if;

  -- Append ring type
  if rtype = 1 then
    etype_name := etype_name || ' (OUTER RING)';
  elsif rtype = 2 then
    etype_name := etype_name || ' (INNER RING)';
  end if;

  return etype_name;

end;
------------------------------------------------------------------------------
function quick_mbr
  (geom sdo_geometry)
  return sdo_geometry
is
  MAX_NUMBER number := 1*10**125;
  min_x number;
  min_y number;
  max_x number;
  max_y number;
  mbr_geom sdo_geometry;
  d number;
begin
  -- Return if input geometry is null
  if geom is null then
    return null;
  end if;

  -- Get the number of dimensions from the gtype
  if length (geom.sdo_gtype) = 4 then
    d := substr (geom.sdo_gtype, 1, 1);
  else
    raise_application_error (-20000, 'Unable to determine dimensionality from gtype');
  end if;

  -- Get the object's min and max X and Y values
  min_x := MAX_NUMBER;
  max_x := -MAX_NUMBER;
  min_y := +MAX_NUMBER;
  max_y := -MAX_NUMBER;
  for i in 1..geom.sdo_ordinates.count()/d loop
    if geom.sdo_ordinates(i*2-1) < min_x then
      min_x := geom.sdo_ordinates(i*2-1);
    end if;
    if geom.sdo_ordinates(i*2-1) > max_x then
      max_x := geom.sdo_ordinates(i*2-1);
    end if;
    if geom.sdo_ordinates(i*2) < min_y then
      min_y := geom.sdo_ordinates(i*2);
    end if;
    if geom.sdo_ordinates(i*2) > max_y then
      max_y := geom.sdo_ordinates(i*2);
    end if;
  end loop;

  -- Construct the bounding box rectangle
  mbr_geom := sdo_geometry (
    2003,                               -- Always 2D polygon
    geom.sdo_srid,                      -- Same SRID as input
    NULL,                               -- No point structure
    sdo_elem_info_array (         -- Outer ring, rectangle
       1, 1003, 3),
    sdo_ordinate_array (
      min_x, min_y,                     -- Lower left corner
      max_x, max_y                      -- Upper right corner
    )
  );
  return mbr_geom;
end;
------------------------------------------------------------------------------
function quick_center
  (geom sdo_geometry)
  return sdo_geometry
is
  mbr_geom sdo_geometry;
  min_x number;
  min_y number;
  max_x number;
  max_y number;
  center_geom sdo_geometry;
  d number;
begin
  -- Return if input geometry is null
  if geom is null then
    return null;
  end if;

  -- Get the number of dimensions from the gtype
  if length (geom.sdo_gtype) = 4 then
    d := substr (geom.sdo_gtype, 1, 1);
  else
    raise_application_error (-20000, 'Unable to determine dimensionality from gtype');
  end if;

  -- Get the bounding box rectangle
  mbr_geom := quick_mbr (geom);
  min_x := mbr_geom.sdo_ordinates(1);
  min_y := mbr_geom.sdo_ordinates(2);
  max_x := mbr_geom.sdo_ordinates(3);
  max_y := mbr_geom.sdo_ordinates(4);

  -- Construct the center point
  center_geom := sdo_geometry (
    2001,                               -- Always 2D point
    geom.sdo_srid,                      -- Same SRID as input
    sdo_point_type (
      (min_x + max_x)/2,                -- X of center
      (min_y + max_y)/2,                -- Y of center
      NULL                              -- No Z
    ),
    NULL,                               -- No sdo_elem_info structure
    NULL                                -- No sdo_ordinates structure
  );

  return center_geom;
end;
------------------------------------------------------------------------------
function join (
  geom_1 sdo_geometry,
  geom_2 sdo_geometry
)
return sdo_geometry
is
  output_geom sdo_geometry;
  i number;
  j number;
  k number;
  dimensionality number;
begin
  -- If one of the geometries is null, then just return the other
  if geom_1 is null then
    return geom_2;
  end if;
  if geom_2 is null then
    return geom_1;
  end if;
  -- if any geometry is an optimized point, just return NULL
  if (geom_1.sdo_gtype = 1 and geom_1.sdo_point is not null) or
     (geom_2.sdo_gtype = 1 and geom_2.sdo_point is not null) then
    return null;
  end if;
  -- Both geometries must have the same dimensionality
  if substr(geom_1.sdo_gtype,1,1) <> substr(geom_2.sdo_gtype,1,1) then
    raise_application_error (-20000, 'Geometries  have different dimensions');
  end if;
  dimensionality := substr(geom_1.sdo_gtype,1,1);
  -- Both geometries must have the same coordinate system
  if (geom_1.sdo_srid = geom_2.sdo_srid)
  or (geom_1.sdo_srid is null and geom_2.sdo_srid is null) then
    null;
  else
    raise_application_error (-20000, 'Geometries have different coordinate systems');
  end if;
  -- initialize output geometry with the first input geometry
  output_geom := geom_1;
  -- get the size of the output element info array
  i := output_geom.sdo_elem_info.last();
  -- get the size of the output ordinates array
  j := output_geom.sdo_ordinates.last();
  -- extend output elem info array
  output_geom.sdo_elem_info.extend( geom_2.sdo_elem_info.count() );
  -- copy element info array (adjust offsets)
  k := geom_2.sdo_elem_info.first();
  while k <= geom_2.sdo_elem_info.last() loop
    output_geom.sdo_elem_info(i+1) := geom_2.sdo_elem_info(k)+j;  -- offset
    output_geom.sdo_elem_info(i+2) := geom_2.sdo_elem_info(k+1);  -- elem type
    output_geom.sdo_elem_info(i+3) := geom_2.sdo_elem_info(k+2);  -- interp
    i := i + 3;
    k := k + 3;
  end loop;
  -- extend output ordinates array
  output_geom.sdo_ordinates.extend( geom_2.sdo_ordinates.count() );
  -- copy ordinates array
  for k in geom_2.sdo_ordinates.first()..geom_2.sdo_ordinates.last() loop
    j := j + 1;
    output_geom.sdo_ordinates(j) := geom_2.sdo_ordinates(k);
  end loop;
  -- setup gtype
  if geom_1.sdo_gtype = geom_2.sdo_gtype then
    -- gtypes are identical
    if geom_1.get_gtype() < 4 then
      -- two simple geometries: replace with equivalent multi type
      output_geom.sdo_gtype := geom_1.sdo_gtype + 4;
    else
      -- two multi geometries: keep unchanged
      output_geom.sdo_gtype := geom_1.sdo_gtype;
    end if;
  else
    if abs(geom_1.sdo_gtype - geom_2.sdo_gtype) = 4 then
      -- gtypes are compatible: replace with multi type (pick the largest)
      if geom_1.sdo_gtype > geom_2.sdo_gtype then
        output_geom.sdo_gtype := geom_1.sdo_gtype;
      else
        output_geom.sdo_gtype := geom_2.sdo_gtype;
      end if;
    else
      -- anything else: define as heterogeneous collection
      output_geom.sdo_gtype := dimensionality*1000+4;
    end if;
  end if;
  return output_geom;
end;
------------------------------------------------------------------------------
procedure dump
  (geom sdo_geometry,
   show_ordinates integer)
is
  i integer;
  j integer;
  k integer;
  f integer;
  l integer;
  n integer;
  p integer;
  elem_count integer;            -- counts the elements in a compound object
  sect_count integer;            -- counts the sub-elements or sections in a complex element
  dim_count integer;             -- number of dimensions in geometry
  gtype integer;                 -- single-digit gtype
  gtype_name varchar2(32);       -- interpreted geometry type
  etype_name varchar2(100);      -- interpreted element type
  start_offset integer;          -- offset for first point in that element or section
  end_offset integer;            -- offset for last point in element or section
  n_ordinates integer;           -- number of ordinates in section
  n_points integer;              -- number of points in section
  etype_full integer;            -- element/section type (from elem_info array)
  etype integer;                 -- element/section type (single-digit)
  rtype integer;                 -- ring type (first digit of element type)
  interp integer;                -- element/section interpretation (from elem_info array)
  n_sections integer;            -- number of sections (=sub-elements)  in complex element
  elem_info_type integer;        -- type of elem_info array entry
  elem_type integer;             -- type of element
  ELEM_SIMPLE integer := 1;      -- 1 = simple element
  ELEM_MIXED integer := 2;       -- 2 = mixed element (arcs and lines)
  elem_entry integer;            -- type of elem_info array entry
  ELEM_STANDALONE integer := 1;  -- 1 = standalone element
  ELEM_HEADER integer := 2;      -- 2 = header of a complex element
  ELEM_SECTION integer := 3;     -- 3 = a section or sub-element

begin
  if geom is null then
    dbms_output.put_line ('NULL');
    return;
  end if;

  -- Get the number of dimensions from the gtype
  if length (geom.sdo_gtype) = 4 then
    dim_count := substr (geom.sdo_gtype, 1, 1);
  else
    -- Indicate failure
    raise_application_error (-20000, 'Unable to determine dimensionality from gtype');
  end if;

  -- Process SDO_GTYPE (Geometry type)
  gtype := substr (geom.sdo_gtype, length (geom.sdo_gtype), 1);
  if gtype is null then
    gtype_name := 'NULL';
  elsif gtype = 0 then
    gtype_name := 'Unknown Geometry';
  elsif gtype = 1 then
    gtype_name := 'Point';
  elsif gtype = 2 then
    gtype_name := 'Line string';
  elsif gtype = 3 then
    gtype_name := 'Polygon';
  elsif gtype = 4 then
    gtype_name := 'Heterogeneous collection';
  elsif gtype = 5 then
    gtype_name := 'Multipoint';
  elsif gtype = 6 then
    gtype_name := 'Multiline';
  elsif gtype = 7 then
    gtype_name := 'Multipolygon';
  else
    gtype_name := '***** Invalid *****';
  end if;
  dbms_output.put_line ('Geometry type: '|| geom.sdo_gtype
     || ' = ' || gtype_name || ' (' || dim_count || 'D)');

  -- Process SDO_SRID (spatial reference system id)
  if geom.sdo_srid is not null then
    dbms_output.put_line ('Srid: ' || geom.sdo_srid);
  end if;

  -- Process SDO_POINT
  if geom.sdo_point is not null then
    dbms_output.put ('POINT: (' || geom.sdo_point.x || ', ' || geom.sdo_point.y);
    if geom.sdo_point.z is not null then
      dbms_output.put (', ' || geom.sdo_point.z);
    end if;
    dbms_output.put_line (')');
  end if;

  -- Display all elements in the geometry (if any)
  if geom.sdo_elem_info is not null then
    f := geom.sdo_elem_info.first;
    l := geom.sdo_elem_info.last;
    n := geom.sdo_elem_info.count;
    if f <> 1 and l <> n then
      dbms_output.put_line ('***** Error in SDO_ELEM_INFO structure ****');
      dbms_output.put_line ('***** sdo_elem_info.first = '||f);
      dbms_output.put_line ('***** sdo_elem_info.last  = '||l);
      dbms_output.put_line ('***** sdo_elem_info.count = '||n);
    end if;
    f := geom.sdo_ordinates.first;
    l := geom.sdo_ordinates.last;
    n := geom.sdo_ordinates.count;
    if f <> 1 and l <> n then
      dbms_output.put_line ('***** Error in SDO_ORDINATES structure ****');
      dbms_output.put_line ('***** sdo_ordinates.first = '||f);
      dbms_output.put_line ('***** sdo_ordinates.last  = '||l);
      dbms_output.put_line ('***** sdo_ordinates.count = '||n);
    end if;
    i := geom.sdo_elem_info.first;
    elem_count := 0;
    elem_entry := ELEM_STANDALONE;            -- assume first element is simple
    elem_type := ELEM_SIMPLE;
    while i < geom.sdo_elem_info.last loop

      -- Extract element info
      start_offset := geom.sdo_elem_info(i);
      etype_full := geom.sdo_elem_info(i+1);
      etype := substr (etype_full, length(etype_full), 1);
      interp := geom.sdo_elem_info(i+2);
      if length (etype_full) = 4 then
        rtype := substr (etype_full, 1, 1);
      else
        rtype := 0;
      end if;

      -- Identify element number and type
      if etype >= 4 then
        elem_entry := ELEM_HEADER;          -- this is the header of a mixed element
        elem_type  := ELEM_MIXED;
        n_sections := interp;               -- remember number of sections
        sect_count := 0;                    -- initialize section counter
      else
        if elem_type = ELEM_MIXED then      -- in a mixed element ?
          sect_count := sect_count + 1;     -- count sections
          if sect_count > n_sections then   -- all done ?
            elem_entry := ELEM_STANDALONE;  -- this is a new standalone element
            elem_type  := ELEM_SIMPLE;
          else                              -- not done yet
            elem_entry := ELEM_SECTION;     -- this is a section of a mixed element
          end if;
        end if;
      end if;

      -- Count elements
      if elem_entry = ELEM_HEADER or elem_entry = ELEM_STANDALONE then
         elem_count := elem_count + 1;
      end if;

      -- Format element type
      if etype = 1 and interp = 1 then
        etype_name := 'Point';
      elsif etype = 1 and interp > 1 then
        etype_name := 'Cluster of ' || interp || ' points';
      elsif etype = 2 and interp = 1 then
        etype_name := 'Line string';
      elsif etype = 2 and interp = 2 then
        etype_name := 'Arc string';
      elsif etype = 3 and interp = 1 then
        etype_name := 'Polygon';
      elsif etype = 3 and interp = 2 then
        etype_name := 'Arc polygon';
      elsif etype = 3 and interp = 3 then
        etype_name := 'Rectangle';
      elsif etype = 3 and interp = 4 then
        etype_name := 'Circle';
      elsif etype = 4 then
        etype_name := 'Mixed line string: ' || interp || ' sections';
      elsif etype = 5 then
        etype_name := 'Mixed polygon: ' || interp || ' sections';
      else
        etype_name := '???';
      end if;

      -- Append ring type
      if rtype = 1 then
        etype_name := etype_name || ' (Outer Ring)';
      elsif rtype = 2 then
        etype_name := etype_name || ' (Inner Ring)';
      end if;

      dbms_output.put (i ||': (' || start_offset || ',' || etype_full || ',' || interp
        || ') - ');

      if elem_entry = ELEM_STANDALONE then
         dbms_output.put ('Element ' || elem_count);
      elsif elem_entry = ELEM_HEADER then
         dbms_output.put ('Element ' || elem_count);
      elsif elem_entry = ELEM_SECTION then
         dbms_output.put ('Section ' || elem_count || '.' || sect_count);
      end if;

      dbms_output.put (' - ' || etype_name);

      if elem_entry <> ELEM_HEADER then
        if i+3 < geom.sdo_elem_info.last then
          end_offset := geom.sdo_elem_info(i+3) - 1;
        else
          end_offset := geom.sdo_ordinates.last;
        end if;
        n_ordinates := end_offset - start_offset + 1;
        n_points := n_ordinates / dim_count;
        if n_points > 1 then
          dbms_output.put (' - ' || n_points || ' points');
        end if;
        dbms_output.put (' - ' || n_ordinates || ' ordinates from offset ' || start_offset
          || ' to ' || end_offset);
        dbms_output.put_line(' ');

        -- display ordinates
        if show_ordinates >= 1 then
          p := 1;     -- Restart point count at 1 for each element
          j := start_offset;
          while j < end_offset loop
            -- Show all points if SHOW_ORDINATES = 1
            -- Show only first and last points if SHOW_ORDINATES = 2
            if show_ordinates = 1 or p = 1 or p = n_points then
              dbms_output.put ('- P:' || p || ' (' || j || ') [');
              for k in 1..dim_count loop
                if k > 1 then
                  dbms_output.put (', ');
                end if;
                if geom.sdo_ordinates(j+k-1) is not null then
                  dbms_output.put (geom.sdo_ordinates(j+k-1));
                else
                  dbms_output.put ('NULL');
                end if;
              end loop;
              dbms_output.put_line (']');
            end if;
            p := p + 1;   -- count points in element
            j := j + dim_count;
          end loop;
        end if;
      else
        dbms_output.put_line(' ');
      end if;

      -- advance to next element
      i := i + 3;
    end loop;
  end if;
end;
------------------------------------------------------------------------------
function dump (
  geom sdo_geometry,
  show_ordinates integer default 1
)
return number
is
  i number;
begin
  dump (geom, show_ordinates);
  return 1;
end;
------------------------------------------------------------------------------
function layer_extent (
   p_table_name         varchar2,
   p_column_name        varchar2,
   p_partition_name     varchar2 default null
)
return sdo_geometry
is
  layer_srid      number;
  layer_extent    sdo_geometry;
  index_name      varchar2(30);
  index_type      varchar2(10);
  num_partitions  number;
begin
  -- Get the SRID for the layer
  begin
    select srid
      into layer_srid
      from user_sdo_geom_metadata
     where table_name = upper(p_table_name)
       and column_name = upper(p_column_name);
  exception
    when NO_DATA_FOUND then
      raise_application_error (-20000, 'No information in USER_SDO_GEOM_METADATA for that table/column');
  end;
  -- Get the name, type and partitioning of the spatial index
  begin
    select index_name,
           sdo_index_type,
           count(*)
      into index_name, index_type, num_partitions
      from user_sdo_index_info
     where table_name = upper(p_table_name)
       and column_name = upper(p_column_name)
     group by index_name, sdo_index_type;
  exception
    when NO_DATA_FOUND then
      raise_application_error (-20000, 'No spatial index for this table/column');
  end;
  -- Is it a spatial rtree index ?
  if index_type <> 'RTREE' then
    raise_application_error (-20000, 'Spatial index is not an RTREE');
  end if;

  if p_partition_name is null then
    -- Get combined root MBR for all partitions
    -- Empty indexes / partitions have an MBR with an SDO_GTYPE set to 2000
    -- Skip those empty indexes. If all partitions are empty, then this returns NULL
    select sdo_aggr_mbr(sdo_root_mbr)
      into layer_extent
      from user_sdo_index_metadata si
     where sdo_index_name = upper(index_name)
       and substr(si.sdo_root_mbr.sdo_gtype,-1,1) = '3';
  else
    -- Get MBR for one specific partition ...
    -- Make sure index is partitionned
    if num_partitions = 1 then
      raise_application_error (-20000, 'Index is not partitionned');
    end if;
    -- Get the MBR for that partition
    begin
      select sdo_root_mbr
        into layer_extent
        from user_sdo_index_metadata si
       where sdo_index_name = upper(index_name)
         and sdo_index_partition = upper (p_partition_name);
    exception
      when NO_DATA_FOUND then
        raise_application_error (-20000, 'Partition does not exist for this table / column');
    end;
    -- Make sure the resulting MBR is not for an empty partition
    if substr(layer_extent.sdo_gtype,-1,1) <> '3' then
      layer_extent := null;
    end if;
  end if;

  -- Make sure we got an MBR
  if layer_extent is null then
    raise_application_error (-20000, 'Unable to determine extent from index');
  end if;

  -- Add the SRID to the MBR (it is always NULL in the index)
  layer_extent.sdo_srid := layer_srid;

  return layer_extent;
end;
------------------------------------------------------------------------------
function remove_duplicate_points
  (geom sdo_geometry,
   tolerance number)
  return sdo_geometry
is
  clean_geom sdo_geometry;
  i integer;
  j integer;
  k integer;
  l integer;
  m integer;
  n integer;
  elem_offset integer;           -- offset to entry in elem_info_entry
  dim_count integer;             -- number of dimensions in layer
  start_offset integer;          -- offset for first point in that element or section
  end_offset integer;            -- offset for last point in element or section
  etype integer;                 -- element/section type (from elem_info array)
  s_etype integer;               -- single-digit element/section type (from elem_info array)
  interp integer;                -- element/section interpretation (from elem_info array)
  type point_t is table of number;
  point point_t := point_t();    -- previous point for comparison
  duplicate_point boolean;
  section_count integer;         -- Number of sections in compound element
  section_nr integer;            -- Number of current section
begin

  -- Get the number of dimensions from the gtype
  if length (geom.sdo_gtype) = 4 then
    dim_count := substr (geom.sdo_gtype, 1, 1);
  else
    -- Indicate failure
    raise_application_error (-20000, 'Unable to determine dimensionality from gtype');
  end if;

  point.extend(dim_count);

  -- Construct and prepare the output geometry
  clean_geom := sdo_geometry (
    geom.sdo_gtype, geom.sdo_srid, geom.sdo_point,
    sdo_elem_info_array (), sdo_ordinate_array()
  );

  -- The process uses two nested loops. The outer loop walks the elem_info array
  -- element by element. The inner loop then extracts the element, removes
  -- duplicate points and copies the corrected element into the resulting geometry

  -- Outer loop: step through the elements
  section_count := 0;                       -- assume element is simple
  section_nr := 0;
  i := geom.sdo_elem_info.first;
  j := 1;                                   -- index into output elem_info array
  k := 1;                                   -- index into output ordinate array
  while i < geom.sdo_elem_info.last loop

    -- Extract element info
    start_offset := geom.sdo_elem_info(i);
    etype := geom.sdo_elem_info(i+1);
    s_etype := substr(etype, length(etype), 1); -- convert to single-digit etype
    interp := geom.sdo_elem_info(i+2);

    if i+3 < geom.sdo_elem_info.last then
      end_offset := geom.sdo_elem_info(i+3) - 1;
    else
      end_offset := geom.sdo_ordinates.last;
    end if;

    -- Write element info entry
    clean_geom.sdo_elem_info.extend(3);
    clean_geom.sdo_elem_info(j) := k;
    clean_geom.sdo_elem_info(j+1) := etype;
    clean_geom.sdo_elem_info(j+2) := interp;
    j := j + 3;

    -- For compound elements (i.e. elements of type 4 or 5, whose boundary is
    -- defined using multiple sub-elements, the elimination of duplicate points
    -- needs to span the sub-elements. The 'header' and all 'sub-elements' should
    -- be considered as one continuous set of ordinates.

    if s_etype = 4 or s_etype = 5 then  -- this is a header for a compound element
      section_count := interp;          -- remember the number of sections
      section_nr := -1;                 -- this is the header section
    end if;

    -- Copy the ordinates, removing duplicate points
    l := start_offset;
    while l < end_offset loop

      -- first time through for a new element ?
      if l = start_offset and section_nr <= 0 then
        duplicate_point := false;     -- yes - first point never a duplicate
      else
        duplicate_point := true;
        if tolerance is null then
          -- No tolerance specified: compare on exact match
          for m in 1..dim_count loop
            if geom.sdo_ordinates(l+m-1) <> point(m) then
              duplicate_point := false;
            end if;
          end loop;
        else
          -- Tolerance specified: use it
          for m in 1..dim_count loop
            if abs(geom.sdo_ordinates(l+m-1) - point(m)) > tolerance then
              duplicate_point := false;
            end if;
          end loop;
        end if;
      end if;

      if not duplicate_point then
        -- Extend output ordinates array
        clean_geom.sdo_ordinates.extend(dim_count);
        for m in 1..dim_count loop
          -- Copy the ordinate
          clean_geom.sdo_ordinates(k) := geom.sdo_ordinates(l+m-1);
          -- Save it for comparison with next point
          point (m) := geom.sdo_ordinates(l+m-1);
          -- Advance index into ordinates array
          k := k + 1;
        end loop;
      end if;
      l := l + dim_count;
    end loop;

    -- advance to next element
    i := i + 3;
    section_nr := section_nr + 1;
    if section_nr >= section_count then
      section_nr := 0;
      section_count := 1;
    end if;

  end loop; -- end of outer loop

  return clean_geom;
end;
------------------------------------------------------------------------------
function validate_geometry
  (geom sdo_geometry,
   diminfo sdo_dim_array
  )
  return VARCHAR2
is
  object_status varchar2(10);
  error_message varchar2(100);
begin
  object_status := sdo_geom.validate_geometry (geom, diminfo);
  if object_status <> 'TRUE' and object_status <> 'FALSE' and object_status <> 'NULL' then
    error_message := SQLERRM (-object_status);
  else
    error_message := object_status;
  end if;
  return error_message;
end;
------------------------------------------------------------------------------
function validate_geometry
  (geom sdo_geometry,
   tolerance number
  )
  return VARCHAR2
is
  object_status varchar2(10);
  error_message varchar2(100);
begin
  object_status := sdo_geom.validate_geometry (geom, tolerance);
  if object_status <> 'TRUE' and object_status <> 'FALSE' and object_status <> 'NULL' then
    error_message := SQLERRM (-object_status);
  else
    error_message := object_status;
  end if;
  return error_message;
end;
------------------------------------------------------------------------------
function validate_geometry_with_context
  (geom sdo_geometry,
   diminfo sdo_dim_array
  )
  return VARCHAR2
is
  object_status varchar2(128);
  error_code    varchar2(10);
  error_message varchar2(256);
  i             number;
begin
  object_status := sdo_geom.validate_geometry_with_context (geom, diminfo);
  if object_status <> 'TRUE' and object_status <> 'FALSE' and object_status <> 'NULL' then
    i := instr (object_status, ' ');
    if i = 0 then
      i := length(object_status)+1;
    end if;
    error_code := substr (object_status, 1, i-1);
    object_status := substr (object_status, i);
    error_message := SQLERRM (-error_code) || object_status;
  else
    error_message := object_status;
  end if;
  return error_message;
end;
------------------------------------------------------------------------------
function validate_geometry_with_context
  (geom sdo_geometry,
   tolerance number
  )
  return VARCHAR2
is
  object_status varchar2(128);
  error_code    varchar2(10);
  error_message varchar2(256);
  i             number;
begin
  object_status := sdo_geom.validate_geometry_with_context (geom, tolerance);
  if object_status <> 'TRUE' and object_status <> 'FALSE' and object_status <> 'NULL' then
    i := instr (object_status, ' ');
    if i = 0 then
      i := length(object_status)+1;
    end if;
    error_code := substr (object_status, 1, i-1);
    object_status := substr (object_status, i);
    error_message := SQLERRM (-error_code) || object_status;
  else
    error_message := object_status;
  end if;
  return error_message;
end;
------------------------------------------------------------------------------
function set_precision
  (geom sdo_geometry,
   nr_decimals number,
   rounding_mode varchar2
     default 'ROUND'
  )
  return sdo_geometry
is
  output_geom sdo_geometry;
  i number;
begin

  -- If the input geometry is null, then just return null
  if geom is null then
    return null;
  end if;

  -- initialize output geometry with the input geometry
  output_geom := geom;

  -- round or truncate the ordinates
  if upper(rounding_mode) = 'ROUND' then

    -- round the point ordinates
    if output_geom.sdo_point is not null then
      if output_geom.sdo_point.x is not null then
        output_geom.sdo_point.x := round(output_geom.sdo_point.x, nr_decimals);
      end if;
      if output_geom.sdo_point.y is not null then
        output_geom.sdo_point.y := round(output_geom.sdo_point.y, nr_decimals);
      end if;
      if output_geom.sdo_point.z is not null then
        output_geom.sdo_point.z := round(output_geom.sdo_point.z, nr_decimals);
      end if;
    end if;
    -- round the ordinates to the precision specified
    if output_geom.sdo_ordinates is not null then
      for i in output_geom.sdo_ordinates.first()..output_geom.sdo_ordinates.last() loop
        output_geom.sdo_ordinates(i) := round(output_geom.sdo_ordinates(i), nr_decimals);
      end loop;
    end if;

  elsif upper(rounding_mode) = 'TRUNCATE' then

    -- truncate the point ordinates
    if output_geom.sdo_point is not null then
      if output_geom.sdo_point.x is not null then
        output_geom.sdo_point.x := trunc(output_geom.sdo_point.x, nr_decimals);
      end if;
      if output_geom.sdo_point.y is not null then
        output_geom.sdo_point.y := trunc(output_geom.sdo_point.y, nr_decimals);
      end if;
      if output_geom.sdo_point.z is not null then
        output_geom.sdo_point.z := trunc(output_geom.sdo_point.z, nr_decimals);
      end if;
    end if;
    -- truncate the ordinates to the precision specified
    if output_geom.sdo_ordinates is not null then
      for i in output_geom.sdo_ordinates.first()..output_geom.sdo_ordinates.last() loop
        output_geom.sdo_ordinates(i) := trunc(output_geom.sdo_ordinates(i), nr_decimals);
      end loop;
    end if;

  else

    raise_application_error (-20000, 'Invalid rounding mode: must be TRUNCATE or ROUND');

  end if;

  return output_geom;
end;
------------------------------------------------------------------------------
function shift (
  geom      sdo_geometry,
  x_shift   number,
  y_shift   number
)
return sdo_geometry
is
  output_geom sdo_geometry;
  dim_count integer;
  n_points integer;
  i integer;
  j integer;
begin

  -- If the input geometry is null, then just return null
  if geom is null then
    return null;
  end if;

  -- Get the number of dimensions from the gtype
  if length (geom.sdo_gtype) = 4 then
    dim_count := substr (geom.sdo_gtype, 1, 1);
  else
    -- Indicate failure
    raise_application_error (-20000, 'Unable to determine dimensionality from gtype');
  end if;

  -- initialize output geometry with the input geometry
  output_geom := geom;

  -- shift the point structure if any
  if output_geom.sdo_point is not null then
    if output_geom.sdo_point.x is not null then
      output_geom.sdo_point.x := output_geom.sdo_point.x + x_shift;
    end if;
    if output_geom.sdo_point.y is not null then
      output_geom.sdo_point.y := output_geom.sdo_point.y + y_shift;
    end if;
  end if;

  -- shift the ordinates by the specified factor
  if output_geom.sdo_ordinates is not null then
    n_points := geom.sdo_ordinates.count / dim_count;
    j := 1;
    for i in 1..n_points loop
      output_geom.sdo_ordinates (j) := output_geom.sdo_ordinates (j) + x_shift;
      output_geom.sdo_ordinates (j+1) := output_geom.sdo_ordinates (j+1) + y_shift;
      j := j + dim_count;
    end loop;
  end if;

  return output_geom;
end;
------------------------------------------------------------------------------
function cleanup (
  geom          sdo_geometry,
  output_type   number,
  min_area      number,
  min_points    number
)
return sdo_geometry
is
  g       sdo_geometry;     -- Resulting geometry
  ne      number;                 -- Number of elements in input geometry
  ne_out  number;                 -- Number of elements in output geometry
  e       sdo_geometry;     -- Element
  np      number;                 -- Number of points in element
  ea      number;                 -- Element area
  et      number;                 -- Element type
begin

  -- If input geometry is null, return null
  if geom is null then
    return null;
  end if;

  -- Get number of elements
  ne := sdo_tools.get_num_elements (geom);

  -- Process each element
  ne_out := 0;
  for i in 1..ne loop

    -- Extract the element
    e := sdo_tools.get_element (geom, i);
    -- Get number of points in element
    np := sdo_tools.get_num_points (e);
    -- Compute element area
    ea := abs(sdo_geom.sdo_area (e, 0.0000005));
    -- Get the type of element
    et :=  substr(e.sdo_gtype,-1);

    -- Check if element should be retained
    if et = output_type and ea >= min_area and np >= min_points then
      ne_out := ne_out + 1;
      if ne_out = 1 then
        g := e;
      else
        g := sdo_tools.join (g, e);
      end if;
    end if;
  end loop;

  -- If no elements retained, then return NULL
  if ne_out = 0 and g.sdo_point is null then
    g := null;
  end if;

  return g;
end;
------------------------------------------------------------------------------
function remove_voids (
  geom          sdo_geometry
)
return sdo_geometry
is
  g         sdo_geometry;
  dim_count pls_integer;            -- number of dimensions in layer
  gtype     pls_integer;            -- geometry type (single digit)
  etype     pls_integer;            -- element type (single digit)
  ne        number;                 -- Number of elements in input geometry
  ne_out    number;                 -- Number of elements in output geometry
  e         sdo_geometry;     -- Element
  np        number;                 -- Number of points in element
  ea        number;                 -- Element area
  et        number;                 -- Element type
begin

  -- If the input geometry is null, just return null
  if geom is null then
    return (null);
  end if;

  -- Get the number of dimensions from the gtype
  if length (geom.sdo_gtype) = 4 then
    dim_count := substr (geom.sdo_gtype, 1, 1);
    gtype := substr (geom.sdo_gtype, 4, 1);
  else
    -- Indicate failure
    raise_application_error (-20000, 'Unable to determine dimensionality from gtype');
  end if;
  -- If geometry is anything but a polygon or multi-polygon indicate failure
  if gtype <> 3 and gtype <> 7 then
    raise_application_error (-20000,'Not a polygon geometry');
  end if;

  -- Get number of elements
  ne := sdo_tools.get_num_elements (geom);

  -- Process each element
  ne_out := 0;
  for i in 1..ne loop

    -- Extract the element
    e := sdo_tools.get_element (geom, i);

    -- Check if element is a void
    if substr(e.sdo_elem_info(2),1,1) <> 2 then
      ne_out := ne_out + 1;
      if ne_out = 1 then
        g := e;
      else
        g := sdo_tools.join (g, e);
      end if;
    end if;
  end loop;

  -- Return result
  return g;
end;
------------------------------------------------------------------------------
function set_tolerance (p_diminfo sdo_dim_array, p_tolerance number)
  return sdo_dim_array
is
  m_diminfo sdo_dim_array;
begin
  m_diminfo := p_diminfo;
  for i in m_diminfo.first() .. m_diminfo.last() loop
    m_diminfo(i).sdo_tolerance := p_tolerance;
  end loop;
  return m_diminfo;
end;
------------------------------------------------------------------------------
function to_line
  (geom sdo_geometry
  )
  return sdo_geometry
is
  geom_out sdo_geometry;
  i pls_integer;
  dim_count pls_integer;             -- number of dimensions in layer
  gtype pls_integer;                 -- geometry type (single digit)
  etype pls_integer;                 -- element type (single digit)
begin
  -- If the input geometry is null, just return null
  if geom is null then
    return (null);
  end if;
  -- Get the number of dimensions from the gtype
  if length (geom.sdo_gtype) = 4 then
    dim_count := substr (geom.sdo_gtype, 1, 1);
    gtype := substr (geom.sdo_gtype, 4, 1);
  else
    -- Indicate failure
    raise_application_error (-20000, 'Unable to determine dimensionality from gtype');
  end if;
  -- If geometry is anything but a polygon or multi-polygon indicate failure
  if gtype <> 3 and gtype <> 7 then
    raise_application_error (-20000,'Not a polygon geometry');
  end if;
  -- Copy input geometry
  geom_out := geom;
  -- Update gtype
  geom_out.sdo_gtype := geom_out.sdo_gtype - 1;
  -- Range over element info array and modify element types
  i := 1;
  while i <= geom_out.sdo_elem_info.last loop
    etype := geom_out.sdo_elem_info(i+1);
    etype := substr (etype, length(etype), 1);
    if etype = 3 then
      geom_out.sdo_elem_info(i+1) := 2;
      if geom_out.sdo_elem_info(i+2) = 3 -- Rectangle ?
      or geom_out.sdo_elem_info(i+2) = 4 -- Circle ?
      then
        raise_application_error (-20000,'polygon contains a circle or rectangle');
      end if;
    end if;
    if etype = 5 then
      geom_out.sdo_elem_info(i+1) := 4;
      if geom_out.sdo_elem_info(i+2) = 3 -- Rectangle ?
      or geom_out.sdo_elem_info(i+2) = 4 -- Circle ?
      then
        raise_application_error (-20000,'polygon contains a circle or rectangle');
      end if;
    end if;
    i := i + 3;
  end loop;
  -- Return new geometry
  return (geom_out);
end;
------------------------------------------------------------------------------
function to_polygon
  (geom sdo_geometry
  )
  return sdo_geometry
is
  geom_out sdo_geometry;
  i pls_integer;
  dim_count pls_integer;             -- number of dimensions in layer
  gtype pls_integer;                 -- geometry type (single digit)
  etype pls_integer;                 -- element type (single digit)
begin
  -- If the input geometry is null, just return null
  if geom is null then
    return (null);
  end if;
  -- Get the number of dimensions from the gtype
  if length (geom.sdo_gtype) = 4 then
    dim_count := substr (geom.sdo_gtype, 1, 1);
    gtype := substr (geom.sdo_gtype, 4, 1);
  else
    -- Indicate failure
    raise_application_error (-20000, 'Unable to determine dimensionality from gtype');
  end if;
  -- If geometry is anything but a line or multi-line indicate failure
  if gtype <> 2 and gtype <> 6 then
    -- Indicate failure
    raise_application_error (-20000,'Not a line geometry');
  end if;
  -- Copy input geometry
  geom_out := geom;
  -- Update gtype
  geom_out.sdo_gtype := geom_out.sdo_gtype + 1;
  -- Range over element info array and modify element types
  i := 1;
  while i <= geom_out.sdo_elem_info.last loop
    etype := geom_out.sdo_elem_info(i+1);
    etype := substr (etype, length(etype), 1);
    if etype = 2 then
      geom_out.sdo_elem_info(i+1) := 1003;
    end if;
    if etype = 4 then
      geom_out.sdo_elem_info(i+1) := 1005;
    end if;
    i := i + 3;
  end loop;
  -- Re-orient the rings
  geom_out := fix_orientation (geom_out);
  -- Return new geometry
  return (geom_out);
end;
------------------------------------------------------------------------------
function make_2d (
  geom sdo_geometry
  )
  return sdo_geometry
is
  geom_2d sdo_geometry;
  dim_count integer;             -- number of dimensions in layer
  gtype integer;                 -- geometry type (single digit)
  lrs_flag integer;              -- Number of ordinate containing measure
  n_points integer;              -- number of points in ordinates array
  n_ordinates integer;           -- number of ordinates
  i integer;
  j integer;
  k integer;
  offset integer;
begin
  -- If the input geometry is null, just return null
  if geom is null then
    return (null);
  end if;
  -- Get the number of dimensions from the gtype
  if length (geom.sdo_gtype) = 4 then
    dim_count := substr (geom.sdo_gtype, 1, 1);
    gtype := substr (geom.sdo_gtype, 4, 1);
  else
    -- Indicate failure
    raise_application_error (-20000, 'Unable to determine dimensionality from gtype');
  end if;

  -- Get LRS flag
  lrs_flag := substr (geom.sdo_gtype, 2, 1);

  -- Valid 3D input can be 30XX (X,Y,Z = 3D) or 44XX (X,Y,Z,M = 3D LRS)
  -- 33XX (X,Y,M = 2D LRS) is already 2D.
  if dim_count=2 or (dim_count=3 and lrs_flag=3) or (dim_count=4 and lrs_flag=3) then
    -- Nothing to do, geometry is already 2D
    return (geom);
  end if;

  -- Construct and prepare the output geometry
  geom_2d := sdo_geometry (
    null, geom.sdo_srid, geom.sdo_point,
    null, null
  );

  -- Set the proper gtype (considering LRS)
  geom_2d.sdo_gtype := (dim_count-1) * 1000 + gtype;
  if lrs_flag > 0 then
    geom_2d.sdo_gtype := geom_2d.sdo_gtype + (lrs_flag-1)*100;
  end if;

  -- Process the point structure
  if geom_2d.sdo_point is not null then
    geom_2D.sdo_point.z := null;
  end if;

  -- Process the ordinates array if any.

  if geom.sdo_ordinates is not null then

    -- Prepare the output array at the right size
    geom_2d.sdo_ordinates := sdo_ordinate_array();
    n_points := geom.sdo_ordinates.count / dim_count;
    n_ordinates := n_points * (dim_count-1);
    geom_2d.sdo_ordinates.extend(n_ordinates);

    -- Copy the ordinates array
    j := geom.sdo_ordinates.first;            -- index into input elem_info array
    k := 1;                                   -- index into output ordinate array
    for i in 1..n_points loop
      geom_2d.sdo_ordinates (k) := geom.sdo_ordinates (j);        -- copy X
      geom_2d.sdo_ordinates (k+1) := geom.sdo_ordinates (j+1);    -- copy Y
      if dim_count > 3 then
        geom_2d.sdo_ordinates (k+2) := geom.sdo_ordinates (j+3);  -- copy M or K
      end if;
      j := j + dim_count;
      k := k + (dim_count-1);
    end loop;

    -- Process the element info array

    -- Copy the input array into the output array
    geom_2d.sdo_elem_info := geom.sdo_elem_info;

    -- Adjust the offsets
    i := geom_2d.sdo_elem_info.first;
    while i < geom_2d.sdo_elem_info.last loop
      offset := geom_2d.sdo_elem_info(i);
      geom_2d.sdo_elem_info(i) := (offset-1)/dim_count*(dim_count-1)+1;
      i := i + 3;
    end loop;
  end if;

  return geom_2d;
end;
------------------------------------------------------------------------------
function make_3d (
  geom sdo_geometry,
  z_value number
  )
  return sdo_geometry
is
  geom_3d sdo_geometry;
  dim_count integer;             -- number of dimensions in layer
  gtype integer;                 -- geometry type (single digit)
  n_points integer;              -- number of points in ordinates array
  n_ordinates integer;           -- number of ordinates
  i integer;
  j integer;
  k integer;
  offset integer;
begin
  -- If the input geometry is null, just return null
  if geom is null then
    return (null);
  end if;
  -- Get the number of dimensions from the gtype
  if length (geom.sdo_gtype) = 4 then
    dim_count := substr (geom.sdo_gtype, 1, 1);
    gtype := substr (geom.sdo_gtype, 4, 1);
  else
    -- Indicate failure
    raise_application_error (-20000, 'Unable to determine dimensionality from gtype');
  end if;
  if dim_count > 2 then
    -- Fail if geometry is not 2D
    raise_application_error (-20001, 'Geometry is not 2D');
  end if;

  -- Construct and prepare the output geometry
  geom_3d := sdo_geometry (
    3000+gtype, geom.sdo_srid, geom.sdo_point, null, null
  );

  -- Process the point structure
  if geom_3d.sdo_point is not null then
    geom_3D.sdo_point.z := z_value;
  end if;

  -- Process the ordinates array if any.

  if geom.sdo_ordinates is not null then

    -- Prepare the output array at the right size
    geom_3d.sdo_ordinates := sdo_ordinate_array();
    n_points := geom.sdo_ordinates.count / dim_count;
    n_ordinates := n_points * 3;
    geom_3d.sdo_ordinates.extend(n_ordinates);

    -- Copy the ordinates array
    j := geom.sdo_ordinates.first;            -- index into input elem_info array
    k := 1;                                   -- index into output ordinate array
    for i in 1..n_points loop
      geom_3d.sdo_ordinates (k) := geom.sdo_ordinates (j);      -- copy X
      geom_3d.sdo_ordinates (k+1) := geom.sdo_ordinates (j+1);  -- copy Y
      geom_3d.sdo_ordinates (k+2) := z_value ;                  -- set value for Z
      j := j + dim_count;
      k := k + 3;
    end loop;

    -- Process the element info array

    -- Copy the input array into the output array
    geom_3d.sdo_elem_info := geom.sdo_elem_info;

    -- Adjust the offsets
    i := geom_3d.sdo_elem_info.first;
    while i < geom_3d.sdo_elem_info.last loop
      offset := geom_3d.sdo_elem_info(i);
      geom_3d.sdo_elem_info(i) := (offset-1)/dim_count*3+1;
      i := i + 3;
    end loop;
  end if;

  return geom_3d;
end;
------------------------------------------------------------------------------
procedure set_measure_at_point
  (geom in out sdo_geometry,
   n in integer,
   m in integer
   )
is
  pn integer;
  dim_count number;
  lrs_dim number;
  px number;
  py number;
  pz number;

begin
  -- Get the number of dimensions from the gtype
  if length (geom.sdo_gtype) = 4 then
    dim_count := substr (geom.sdo_gtype, 1, 1);
  else
    raise_application_error (-20000, 'GTYPE must be 4 digits');
  end if;

  -- Find the dimension holding the measure
  lrs_dim := substr (geom.sdo_gtype, 2, 1);
  if lrs_dim = 0 then
    -- LRS dimension not specified. Use last dimension
    lrs_dim := dim_count;
  end if;

  -- Make sure the requested point exists
  pn := n;
  if pn > 0 then
    if geom.sdo_ordinates is null or
      pn*dim_count > geom.sdo_ordinates.count() then
      raise_application_error (-20000, 'Point number out of range');
    end if;
  else
    -- We want the last point in the geometry
    pn := geom.sdo_ordinates.count() / dim_count;
  end if;

  -- Set measure of the desired point
  geom.sdo_ordinates((pn-1)*dim_count+lrs_dim) := m;
end;
------------------------------------------------------------------------------
function to_dd (sd number)
  return number
is
  sds varchar2(50);
  d number;  -- Degrees
  m number;  -- Minutes
  s number;  -- Seconds
  f number;  -- Fractions of a second
  n number;  -- Sign
  dd number; -- Decimal degrees
  i integer;
begin
  -- Extract sign
  if sd < 0 then
    n := -1;
  else
    n := 1;
  end if;
  -- Convert to string (without sign)
  sds := to_char (abs(sd), '0999.99999999999999999990');
  -- Locate decimal point
  i := instr (sds, '.');
  -- Get degrees (all digits before decimal point)
  d := substr (sds, 1, i-1);
  -- Get minutes
  m := substr (sds, i+1, 2);
  -- Get seconds
  s := substr (sds, i+3, 2);
  -- Get fractions of a second
  f := '0.' || substr (sds, i+5);
  -- Convert to decimal degrees
  dd := n * (d + m/60 + (s+f)/3600);
  return dd;
end;
------------------------------------------------------------------------------
function to_dd (sd varchar2)
  return number
is
  d number;  -- Degrees
  m number;  -- Minutes
  s number;  -- Seconds
  f number;  -- Fractions of a second
  o char(1); -- Orientation
  n number;  -- Sign
  dm number; -- Maximum value for degrees
  dd number; -- Decimal degrees
  i integer;
  l integer;
begin
  l := length (sd);
  -- Get orientation
  o := substr(sd,l,1);
  if o = 'N' then
    n := 1;
    dm := 90;
  elsif o = 'S' then
    n := -1;
    dm := 90;
  elsif o = 'E' then
    n := 1;
    dm := 180;
  elsif o = 'W' then
    n := -1;
    dm := 180;
  else
    raise_application_error (-20000, 'Invalid orientation: must be E, W, N or S');
  end if;
  -- Locate decimal point
  i := instr (sd, '.');
  -- Get degrees (all digits before decimal point)
  d := substr (sd, 1, i-1);
  if d > dm then
    raise_application_error (-20000, 'Degrees out of range');
  end if;
  -- Get minutes
  m := substr (sd, i+1, 2);
  if m >= 60 then
    raise_application_error (-20000, 'Minutes out of range');
  end if;
  -- Get seconds (if any)
  if i+3 < l then
    s := substr (sd, i+3, 2);
  else
    s := 0;
  end if;
  if s >= 60 then
    raise_application_error (-20000, 'Seconds out of range');
  end if;
  -- Get fractions of a second
  if i+5 < l then
    f := substr (sd, i+5, l-i-5) / (10 ** (l-i-5));
  else
    f := 0;
  end if;
  -- Convert to decimal degrees
  dd := n * (d + m/60 + (s+f)/3600);
  -- Final check
  if abs(dd) > dm then
    raise_application_error (-20000, 'Ordinate out of range');
  end if;
  return dd;
end;
------------------------------------------------------------------------------
function to_dms (dd number, direction varchar2)
  return varchar2
is
  sds varchar2(50);
  d number;  -- Degrees
  f number;  -- Fractions of a degree
  m number;  -- Minutes
  s number;  -- Seconds
  o char;    -- Orientation (N,S,E or W)
begin
  -- Check direction and degrees
  if upper(direction) = 'LAT' then
    if dd > 0 then
      o := 'N';
    else
      o := 'S';
    end if;
    if abs(dd) > 90 then
      raise_application_error (-20000, 'Invalid value for latitude');
    end if;
  elsif upper(direction) = 'LONG' then
    if dd > 0 then
      o := 'E';
    else
      o := 'W';
    end if;
    if abs(dd) > 180 then
      raise_application_error (-20000, 'Invalid value for longitude');
    end if;
  else
    raise_application_error (-20000, 'Invalid direction: must be LAT or LONG');
  end if;
  -- Get degrees (digits before decimal point)
  d := abs(trunc(dd));
  -- Get decimal part, convert to seconds
  f := abs(mod(dd, 1)) * 3600;
  -- Compute minutes
  m := trunc(f/60);
  -- Compute seconds
  s := mod (f, 60);
  -- Convert to string
  sds := d || ' ' || m || ' ' || s || ' ' || o;

  return sds;
end;
------------------------------------------------------------------------------
function utm_zone_bounds (zone_number number, orientation varchar2)
  return sdo_geometry
is
  bounds sdo_geometry;
  min_x  number;
  min_y  number;
  max_x  number;
  max_y  number;
begin

  -- Make sure the zone number is valid
  if mod(zone_number,1) <> 0 or zone_number < 1 or zone_number > 60 then
    raise_application_error (-20000, 'Invalid UTM zone number. Must be between 1 and 60');
  end if;

  -- Make sure the orientation is valid
  if upper(orientation) not in ('S','N') then
    raise_application_error (-20000, 'Invalid orientation. Must be ''N'' or ''S''');
  end if;

  --  UTM zones are 6 degrees wide and are valid up to 84 degrees of latitude
  --  (north or south). They start from the -180° meridian and are numbered
  --  from west to east.
  --  The center meridian for a zone is computed as (zone_number*6)-180-3
  --  For example: UTM zone 20 has a center meridian of (20*6)-180 = -63° and
  --  spans from -66° to -60°.
  min_x := (zone_number*6)-180-6;
  max_x := (zone_number*6)-180;
  if upper(orientation) = 'N' then
    min_y := 0;
    max_y := 84;
  else
    min_y := -84;
    max_y := 0;
  end if;

  bounds := sdo_geometry (
    2003, 8307, null,
    sdo_elem_info_array (1,1003,3),
    sdo_ordinate_array (min_x, min_y, max_x, max_y)
  );

  return bounds;
end;

------------------------------------------------------------------------------
function get_orientation (geom sdo_geometry) return number
is
  orientation number;
  dim         pls_integer;
  gtype       pls_integer;
  i           pls_integer;
  Imin        number;
  Xmin        number;
  Ymin        number;
  Iprev       number;
  Xprev       number;
  Yprev       number;
  INext       number;
  XNext       number;
  YNext       number;
begin
  if geom is null then
    return null;
  end if;
  if length (geom.sdo_gtype) <> 4 then
    raise_application_error (-20000, 'Unable to determine dimensionality from gtype');
  end if;
  gtype := substr(geom.sdo_gtype,4,1);
  dim := substr(geom.sdo_gtype,1,1);
  if gtype <> 3 then
    raise_application_error (-20000,'Not a simple polygon');
  end if;

  -- Find the rightmost lowest vertex of the polygon
  Imin := 1;
  Xmin := geom.sdo_ordinates(1);
  Ymin := geom.sdo_ordinates(2);
  i := 1+dim;
  while i <= geom.sdo_ordinates.last()-2*dim+1 loop
    if geom.sdo_ordinates(i+1) <= ymin then
      if geom.sdo_ordinates(i+1) < ymin or
         geom.sdo_ordinates(i) > xmin then
        Imin := i;
        Xmin := geom.sdo_ordinates(i);
        Ymin := geom.sdo_ordinates(i+1);
       end if;
    end if;
    i := i + dim;
  end loop;

  -- Get X,Y of vertex that precedes this vertex
  if Imin = 1 then
    Iprev := geom.sdo_ordinates.last()-2*dim+1;
  else
    Iprev := Imin-dim;
  end if;
  Xprev := geom.sdo_ordinates(Iprev);
  Yprev := geom.sdo_ordinates(Iprev+1);

  -- Get X,Y of vertex that follows this vertex
  Inext := Imin+dim;
  Xnext := geom.sdo_ordinates(Inext);
  Ynext := geom.sdo_ordinates(Inext+1);

  orientation := (Xmin - Xprev) * (Ynext - YPrev) - (Xnext - Xprev) * (Ymin - Yprev);

  if orientation = 0 then
    raise_application_error (-20000, 'Unable to determine orientation');
  end if;

  if orientation < 0 then
    return -1;
  else
    return 1;
  end if;
end;
------------------------------------------------------------------------------
function fix_orientation (geom sdo_geometry) return sdo_geometry
is
  out_geom      sdo_geometry;   -- Resulting geometry
  dim           pls_integer;          -- number of dimensions in layer
  gtype         pls_integer;          -- geometry type (single digit)
  e_offset      pls_integer;          -- element offset (from elem_info array)
  e_type        pls_integer;          -- element type (from elem_info array)
  e_rtype       pls_integer;          -- ring type (1 = outer, 2 = inner)
  e_stype       pls_integer;          -- element type (single digit)
  e_category    pls_integer;          -- element category (1, 2 or 3)
  e_interp      pls_integer;          -- element interpretation (from elem_info array)
  e_iscompound  boolean;              -- element is compound (1) or simple (0)
  e_first       pls_integer;          -- index to first elem_info_array triplet for element
  e_last        pls_integer;          -- index to last elem_info_array triplet for element
  o_first       pls_integer;          -- index to first point in element
  o_last        pls_integer;          -- index to last point in element
  i             pls_integer;
  j             pls_integer;
  k             pls_integer;
  l             pls_integer;
  n             pls_integer;
  Vmin          number;               -- index to first ordinate of rightmost lowest point
  Xmin          number;               -- X ordinate of that point
  Ymin          number;               -- Y ordinate of that point
  Xprev         number;               -- X ordinate of previous point
  Yprev         number;               -- Y ordinate of previous point
  XNext         number;               -- X ordinate of following point
  YNext         number;               -- Y ordinate of following point
  orientation   number;               -- Ring orientation (<0 = CW, >0 = CCW)
begin

  -- Return NULL if input geometry is null
  if geom is null then
    return null;
  end if;

  -- Fail if GTYPE does not contain the dimensionality
  if length (geom.sdo_gtype) <> 4 then
    raise_application_error (-20000, 'Unable to determine dimensionality from gtype');
  end if;

  gtype := substr(geom.sdo_gtype,4,1);
  dim := substr(geom.sdo_gtype,1,1);

  -- Fail if GTYPE is not a polygon or multi-polygon
  if gtype <> 3 and gtype <> 7 then
    raise_application_error (-20000,'Not a polygon');
  end if;

  -- Initialize output geometry
  out_geom := geom;

  -- Main loop: process elements
  i := geom.sdo_elem_info.first;
  while i < geom.sdo_elem_info.last loop

    -- Extract element info details
    e_offset := geom.sdo_elem_info(i);            -- Offset
    e_type := geom.sdo_elem_info(i+1);            -- 4-digit element type
    e_rtype := substr(e_type, 1, 1);              -- Ring type (1 or 2)
    e_stype := substr(e_type, length(e_type), 1); -- single-digit etype
    e_interp := geom.sdo_elem_info(i+2);          -- Interpretation

    -- Element type must be 4-digits (1003/2003 or 1005/2005)
    if length(e_type) <> 4 then
      raise_application_error (-20000, 'Invalid element type"'||e_type||'" in geometry');
    end if;

    -- Identify element type
    if e_stype = 3 then
      -- Etype 3: this is a simple element
      e_iscompound := false;        -- This is a simple element
      e_category := e_stype;        -- Category is 1, 2 or 3
      e_first := i;                 -- Index to first elem_info triplet
      e_last := i;                  -- Index to last elem_info triplet
    elsif e_stype = 5 then
      -- Etype 5: this is a compound element
      e_iscompound := true;         -- This is a compound element
      e_category := e_stype - 2;    -- Category is 2 or 3
      e_first := i;                 -- Index to first elem_info triplet
      e_last := i+e_interp*3;       -- Index to last elem_info triplet
    else
      raise_application_error (-20000, 'Invelid element type"'||e_type||'" in geometry');
    end if;

    -- Identify the first and last offset of the ordinates for the element
    o_first := e_offset;
    if e_last+3 > geom.sdo_elem_info.last then
      o_last:= geom.sdo_ordinates.last-dim+1;
    else
      o_last := geom.sdo_elem_info(e_last+3) - dim;
    end if;

    -- Find the rightmost lowest vertex of the polygon element
    Vmin := o_first;
    Xmin := geom.sdo_ordinates(Vmin);
    Ymin := geom.sdo_ordinates(Vmin+1);
    j := Vmin+dim;
    while j <= o_last-dim loop
      if geom.sdo_ordinates(j+1) <= ymin then
        if geom.sdo_ordinates(j+1) < ymin or
           geom.sdo_ordinates(j) > xmin then
          Vmin := j;
          Xmin := geom.sdo_ordinates(j);
          Ymin := geom.sdo_ordinates(j+1);
        end if;
      end if;
      j := j + dim;
    end loop;

    -- Get X,Y of vertex that precedes this vertex
    if Vmin = o_first then
      Xprev := geom.sdo_ordinates(o_last-dim);
      Yprev := geom.sdo_ordinates(o_last-dim+1);
    else
      Xprev := geom.sdo_ordinates(Vmin-dim);
      Yprev := geom.sdo_ordinates(Vmin-dim+1);
    end if;
    -- Get X,Y of vertex that follows this vertex
    Xnext := geom.sdo_ordinates(Vmin+dim);
    Ynext := geom.sdo_ordinates(Vmin+dim+1);

    -- Determine orientation
    orientation := (Xmin - Xprev) * (Ynext - YPrev) - (Xnext - Xprev) * (Ymin - Yprev);
    --  >0: ring orientation is counter-clockwise (= an outer ring)
    --  <0: the ring orientation is clockwise (= an inner ring)

    -- Fail if unable to determine (degenerate case)
    if orientation = 0 then
      raise_application_error (-20000, 'Unable to determine orientation');
    end if;

    -- Check if orientation is valid, i.e. matches the ring type:
    -- - for type 100X (outer ring), orientation should be >0 (counter-clockwise)
    -- - for type 200X (inner ring), orientation should be <0 (clockwise)
    -- If not matching, then reverse the orientation
    if e_rtype = 1 and orientation < 0
    or e_rtype = 2 and orientation > 0 then

      -- Invalid orientation: reverse point order

      -- If element is compound, need to reverse element info triplets
      -- except the first (header) triplet.
      if e_iscompound then

        k := e_first+3;
        l := e_last;
        n := o_first;
        -- Loop on each primitive element
        for m in 1..geom.sdo_elem_info(e_first+2) loop
          -- Set element offset
          out_geom.sdo_elem_info(k)   := n;
          -- Copy element type and interpretation
          out_geom.sdo_elem_info(k+1) := geom.sdo_elem_info(l+1);
          out_geom.sdo_elem_info(k+2) := geom.sdo_elem_info(l+2);
          -- Ordinate offset for next triplet
          n := o_last - geom.sdo_elem_info(l) + dim + 1;
          -- Next destination triplet
          k := k + 3;
          -- Next source triplet
          l := l - 3;
        end loop;

      end if;

      -- Copy ordinates into output geometry in reverse order
      k := o_first;
      l := o_last;
      while l >= o_first loop
        for n in 0..dim-1 loop
          out_geom.sdo_ordinates (k+n) := geom.sdo_ordinates (l+n);
        end loop;
        k := k + dim;
        l := l - dim;
      end loop;

    end if;

    -- advance to next element
    i := e_last + 3;

  end loop;

  return out_geom;
end;

function same_geometries (g1 sdo_geometry, g2 sdo_geometry, t number)
  return varchar2
is
begin

  -- Check gtype and srid
  if g1.sdo_gtype <> g2.sdo_gtype or
     g1.sdo_srid <> g2.sdo_srid then
    return 'FALSE';
  end if;

  -- Compare point structure (if any)
  if g1.sdo_point is not null and g2.sdo_point is not null then
    if g1.sdo_point.x <> g2.sdo_point.x
    or g1.sdo_point.y <> g2.sdo_point.y
    or g1.sdo_point.z <> g2.sdo_point.z then
      return case sdo_geom.relate (g1, 'EQUAL', g2, t) when 'EQUAL' then 'TRUE' else 'FALSE' end;
    end if;
  end if;

  -- Compare elem_info array (if any)
  if g1.sdo_elem_info is not null and g1.sdo_elem_info is not null then
    if g1.sdo_elem_info.count() <> g2.sdo_elem_info.count() then
      return case sdo_geom.relate (g1, 'EQUAL', g2, t) when 'EQUAL' then 'TRUE' else 'FALSE' end;
    end if;
    for i in 1..g1.sdo_elem_info.count() loop
      if g1.sdo_elem_info(i) <> g2.sdo_elem_info(i) then
        return case sdo_geom.relate (g1, 'EQUAL', g2, t) when 'EQUAL' then 'TRUE' else 'FALSE' end;
      end if;
    end loop;
  end if;

  -- Compare ordinates array (if any)
  if g1.sdo_ordinates is not null and g1.sdo_ordinates is not null then
    if g1.sdo_ordinates.count() <> g2.sdo_ordinates.count() then
      return case sdo_geom.relate (g1, 'EQUAL', g2, t) when 'EQUAL' then 'TRUE' else 'FALSE' end;
    end if;
    for i in 1..g1.sdo_ordinates.count() loop
      if g1.sdo_ordinates(i) <> g2.sdo_ordinates(i) then
        return case sdo_geom.relate (g1, 'EQUAL', g2, t) when 'EQUAL' then 'TRUE' else 'FALSE' end;
      end if;
    end loop;
  end if;

  return 'TRUE';
end;

end sdo_tools;
/
show error
