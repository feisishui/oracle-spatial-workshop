create or replace function get_error_context (
  geom sdo_geometry,
  context varchar2
)
return sdo_geometry
deterministic
is
  error_code number;
  element_id number;
  ring_id number;
  point_id number;
  edge_1_id number;
  edge_2_id number;
  ring_1_id number;
  ring_2_id number;
  
begin
  /*
  
  Error context looks like this:
  
  1) ORA-13356: adjacent points in a geometry are redundant
  13356 [Element <1>] [Coordinate <3>][Ring <1>]
  
  Return: a line with the two points
  
  2) ORA-13349: polygon boundary crosses itself
  13349 [Element <1>] [Ring <1>][Edge <6>][Edge <3>]

  Return: a line with the two edges

  3) ORA-13350: two or more rings of a complex polygon touch
  13350 [Element <1>] [Rings 1, 2][Edge <8> in ring <1>][Edge <3> in ring <2>]
  
  Return: a line with the two edges

  */
  
  -- If no error or input geometry is null, do nothing (return NULL)
  if geom is null
  or context is null 
  or upper(context) = 'NULL'
  or upper(context) = 'TRUE' then
    return null;
  end if;
  
  -- extract error code
  error_code := substr(context,1,5);
  
  -- extract context information: look for all elements like "[word <number>]"
  -- where "word" can be "Element", "Ring", "Edge" or "Coordinate"
 
  -- construct geometry from the context information
  
  
end;
/
show errors
