CREATE OR REPLACE FUNCTION make_polygon (
  query_crs     SYS_REFCURSOR,
  srid          number,
  close_polygon	varchar2 default 'TRUE'
)
RETURN SDO_GEOMETRY deterministic
AS
  geom        sdo_geometry;
  x	          number;
  y           number;
  xf          number;
  yf          number;
  i           number;
BEGIN
  geom := sdo_geometry(
  	2003,
  	srid,
  	null,
  	sdo_elem_info_array (1,1003,1),
  	sdo_ordinate_array ()
  );
  xf := null;
  yf := null;
  i := 1;
  LOOP
    FETCH query_crs into x, y;
      EXIT when query_crs%NOTFOUND ;
    if xf is null then
      xf := x;
      yf := y;
    end if;  
    geom.sdo_ordinates.extend(2);
    geom.sdo_ordinates(i) := x;
    geom.sdo_ordinates(i+1) := y;
    i := i + 2;
  END LOOP;
  if upper(close_polygon) = 'TRUE' then
    geom.sdo_ordinates.extend(2);
    geom.sdo_ordinates(i) := xf;
    geom.sdo_ordinates(i+1) := yf;
  end if;
  RETURN geom;
END;
/
show errors
