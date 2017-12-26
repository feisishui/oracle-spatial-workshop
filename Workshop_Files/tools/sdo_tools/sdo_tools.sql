REM
REM Copyright (c) Oracle Corporation All Right Reserved.
REM
REM NAME:
REM    sdo_tools.sql
REM
REM LAST UPDATE
REM    27-Aug-2015
REM
REM DESCRIPTION:
REM
REM    This package provides a number of functions and procedures that aid in
REM    manipulating SDO_GEOMETRY objects.
REM
REM FUNCTIONS AND PROCEDURES
REM
REM    - constructors: shortcuts for constructing various geometries :
REM      geometry = point (x, y, z)
REM      geometry = rectangle (Xa, Ya, Xb, Yb)
REM      geometry = circle (X, Y, radius)
REM      geometry = circle (X1, Y1, X2, Y2, X3, Y3)
REM
REM    - inspectors: extract information from geometries in various formats :
REM      string = format (geometry)
REM      n = get_num_elements (geometry)
REM      n = get_num_ordinates (geometry)
REM      n = get_num_points (geometry)
REM      n = get_num_decimals (geometry)
REM      x = get_point_x (geometry)
REM      y = get_point_y (geometry)
REM      n = get_ordinate (geometry, n)
REM      point_geometry = get_point (geometry, n)
REM      point_geometry = get_first_point (geometry)
REM      point_geometry = get_last_point (geometry)
REM      geometry = get_element (geometry, n)
REM      string = get_element_type (geometry)
REM      n = get_orientation (geometry)
REM      get_elements (geometry)
REM      get_rings (geometry)
REM
REM    - setters: set and modify geometries in various ways :
REM      set_measure_at_point (geom, n, m)
REM
REM    - converters: transform geometries in various ways
REM      line_geometry = insert_point (line_geometry, point, index)
REM      line_geometry = insert_point (line_geometry, point)
REM      line_geometry = insert_first_point (line_geometry, point)
REM      line_geometry = insert_last_point (line_geometry, point)
REM      line_geometry = remove_point (line_geometry, index)
REM      line_geometry = remove_first_point (line_geometry)
REM      line_geometry = remove_last_point (line_geometry)
REM      line_geometry = reverse_linestring (line_geometry)
REM      geometry = remove_duplicate_points (geometry)
REM      geometry = fix_orientation (polygon geometry)
REM      geometry = make_2d (geometry)
REM      geometry = make_3d (geometry, value)
REM      geometry = to_line (polygon geometry)
REM      geometry = to_polygon (line geometry)
REM      geometry = set_precision (geometry, nr_decimals)
REM      geometry = shift (geometry, x_shift, y_shift)
REM      geometry = cleanup (geometry, output_type, min_area, min_points)
REM      geometry = remove_voids (geometry)
REM
REM    - miscellaneous functions:
REM      geometry = quick_mbr (geometry)
REM      geometry = join (geometry, geometry)
REM      geometry = layer_extent (table_name, column_name, partition_name)
REM      string = validate_geometry (geometry) = validate and return error message (not code)
REM      string = validate_geometry_with_context (geometry) = validate and return error message (not code)
REM      diminfo = set_tolerance (diminfo, tolerance)
REM      decimal_degrees = to_dd (sexagesimal_degrees)
REM      dms_degrees = to_dms (decimal_degrees, direction)
REM      geometry = utm_zone_bounds (zone, orientation)
REM
REM    - miscellaneous procedures:
REM      dump (geometry)
REM      dump_rtree (table_name, column_name, output_table)
REM
REM NOTES
REM
REM    The functions only support geometries with long gtypes (4-digit gtypes).
REM
REM    Those procedures are UNSUPPORTED
REM
REM
REM MODIFIED     (DD-MON-YY)  DESCRIPTION
REM
REM agodfrin      28-Aug-15   Removed unnecessary MDSYS prefixes.
REM agodfrin      27-Feb-14   Added INSERT_POINT(line, point) withjout index: project and insert
REM agodfrin      15-Jul-13   Added GET_ELEMENTS and GET_RINGS pipelined functions
REM agodfrin      04-Jun-12   Added REMOVE_VOIDS function
REM agodfrin      29-Jan-11   Renamed TO_2D() and TO_3D() to MAKE_2D() and MAKE_3D()
REM agodfrin      29-Jan-11   TO_2D() now supports LRS geometries
REM agodfrin      11-Oct-10   Fixed recursion loop in DUMP() function
REM agodfrin      23-Jun-10   Removed quadtree functions and procedures
REM agodfrin      05-Nov-09   Fixed errors in CLEANUP, JOIN and GET_ELEMENT procedures
REM agodfrin      20-Feb-09   Removed OFFSET function and procedure
REM agodfrin      19-Feb-09   Add minimum area and minimum points filtering to CLEANUP function
REM agodfrin      09-Dec-08   Add UTM_ZONE_BOUNDS function
REM agodfrin      21-Jul-08   Add GET_NUM_DECIMALS function
REM agodfrin      19-Apr-08   Correct SAME_GEOMETRIES() to only return TRUE or FALSE
REM agodfrin      15-Nov-07   Make CLEANUP also work with simple points
REM agodfrin      03-Jun-07   Make rounding the default for the SET_PRECISION function.
REM agodfrin      29-Mar-07   Modified function DUMP to display only start and end point of each element
REM agodfrin      10-Sep-06   Added LAYER_EXTENT function to compute layer extent from rtree index
REM agodfrin      13-Mar-06   Added to_3d function. Renamed "set_2d" to "to_2d"
REM agodfrin      05-Jul-05   Added DUMP_RTREE and related functions
REM agodfrin      21-Mar-05   Added REVERSE_LINESTRING function
REM agodfrin      18-Mar-05   GET_MBR re-implemented as QUICK_MBR
REM agodfrin      25-Jan-05   GET_POINT() now also returns 3rd dimension (Z or M) if any
REM agodfrin      20-Apr-04   Added to_dms() function
REM agodfrin      13-Oct-03   Added shift() function to shift all ordinates by a given factor
REM agodfrin      21-Sep-03   Removed support of geometries with short (single-digit) gtypes.
REM agodfrin      09-Sep-03   Allow set_precision() to round or truncate coordinates
REM agodfrin      09-Sep-03   Added validate_geometry_with_context() function
REM agodfrin      18-Aug-03   Added insert_point() and remove_point() functions
REM agodfrin      17-Aug-03   get_point can use a negative point number. Add get_first_point() and get_last_point()
REM agodfrin      11-Aug-03   Added to_polygon function
REM agodfrin      01-Jul-03   Added to_line function
REM agodfrin      23-Apr-03   Added functions to get and correct polygon orientation
REM agodfrin      09-Jan-03   Added function to convert a coordinate from sexagesimal to decimal degrees
REM agodfrin      26-Aug-02   Simplified element counting algorithms
REM agodfrin      26-Aug-02   Added cleanup() function
REM agodfrin      10-Jul-02   Renamed package as SDO_TOOLS to avoid confict with SDO_UTIL
REM agodfrin      07-Apr-02   Added OFFSET function and procedure to shift a geometry
REM agodfrin      11-Feb-02   Added function to convert a row/column into a tilecode
REM agodfrin      04-Feb-02   Added quadtree_quality procedure
REM agodfrin      04-Feb-02   Added analyze_index procedure variant to use tablename/column name
REM agodfrin      12-Dec-01   Added set_measure_at_point procedure
REM agodfrin      05-Dec-01   Added analyze_index procedure
REM agodfrin      15-Oct-01   Added set_2d function.
REM agodfrin      27-Dec-00   Corrected tile generation for 8.1.6/8.1.7
REM agodfrin      20-Oct-00   Added validation routine
REM agodfrin      10-Oct-00   Added function to remove duplicate points
REM agodfrin      27-Sep-00   Generate 815 or 816 format depending on user choice
REM agodfrin      02-Sep-00   Used SDO routine for MBR calculation
REM agodfrin      15-Aug-00   Upgraded to 8.1.6 (use 4-digit gtypes and etypes)
REM agodfrin      04-May-00   Added convert_816_to_815 function
REM agodfrin      02-Mar-00   Corrected MBR generation
REM agodfrin      12-Oct-99   Added constructor functions
REM agodfrin      10-Oct-99   Added tile extraction functions
REM agodfrin      27-Jul-99   Created

DROP TYPE sdo_geometry_table;
DROP TYPE sdo_geometry_row;

CREATE OR REPLACE TYPE sdo_geometry_row AS OBJECT (
  element_id    number,
  ring_id       number,
  element_geom  sdo_geometry
);
/

CREATE OR REPLACE TYPE sdo_geometry_table AS TABLE OF sdo_geometry_row;
/

CREATE OR REPLACE PACKAGE sdo_tools
  authid current_user
AS

type rectangle_type is record (minx number, maxx number, miny number, maxy number);

-- -----------------------------------------------------------------------
-- NAME:
--    POINT (X, Y, Z)
-- DESCRIPTION:
--    This constructor function returns a simple point geometry
-- ARGUMENTS:
--    x - the X ordinate (first dimension)
--    y - the Y ordinate (second dimension)
--    z - the Z ordinate (third dimension) - optional
-- RETURN
--    sdo_geometry
-- NOTES:
--    The point is stored in SDO_POINT
-- -----------------------------------------------------------------------

function point
  (x number,
   y number,
   z number default null
  )
  return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--    RECTANGLE (XLL, YLL, XUR, YUR)
-- DESCRIPTION:
--    This constructor returns a 2D rectangle geometry
-- ARGUMENTS:
--    xll, yll - the coordinates of the lower left corner
--    xur, yur - the coordinates of the upper right corner
-- RETURN
--    sdo_geometry
-- -----------------------------------------------------------------------

function rectangle
  (xll number,
   yll number,
   xur number,
   yur number
  )
  return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--    CIRCLE (X, Y, RADIUS)
-- DESCRIPTION:
--    This constructor returns a 2D circle from the center coordinates and the radius
-- ARGUMENTS:
--    x, y - the coordinates of center of the circle
--    radius - the radius of the circle
-- RETURN
--    sdo_geometry
-- -----------------------------------------------------------------------

function circle
  (x number,
   y number,
   radius number
  )
  return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--    CIRCLE (X1,Y1, X2,Y2, X3,Y3)
-- DESCRIPTION:
--    This constructor returns a 2D circle from three points on the circumference
-- ARGUMENTS:
--    xi, yi - the coordinates the three points
-- RETURN
--    sdo_geometry
-- -----------------------------------------------------------------------

function circle
  (x1 number, y1 number,
   x2 number, y2 number,
   x3 number, y3 number
  )
  return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--    FORMAT (GEOM)
-- DESCRIPTION:
--    This function returns the contents of an SDO_GEOMETRY object in the same
--    format as that used by SQL*PLUS.
-- ARGUMENTS:
--    geom - The geometry to format (sdo_geometry)
-- RETURN
--    VARCHAR2
-- NOTES:
--    Output is limited to 4000 characters (due to the size limit of the
--    VARCHAR2 datatype
-- -----------------------------------------------------------------------

function format
  (geom sdo_geometry)
  return varchar2;

-- -----------------------------------------------------------------------
-- NAME:
--    GET_NUM_ELEMENTS (GEOM)
-- DESCRIPTION:
--    This function returns the number of elements contained in a geometry
-- ARGUMENTS:
--    geom - The geometry to format (sdo_geometry)
-- RETURN
--    NUMBER
-- NOTES:
--    Returns NULL if the geometry only contains an optimized point (stored
--    in SDO_POINT)
-- RESTRICTIONS
--    This function counts the number of primitive elements that compose the geometry; for
--    polygons with voids, each ring (outer or inner) is counted as a separate element.
-- -----------------------------------------------------------------------

function get_num_elements
  (geom sdo_geometry)
  return number;

-- -----------------------------------------------------------------------
-- NAME:
--    GET_NUM_ORDINATES (GEOM)
-- DESCRIPTION:
--    This function returns the total number of ordinates in a geometry
-- ARGUMENTS:
--    geom - The geometry to format (sdo_geometry)
-- RETURN
--    NUMBER
-- NOTES:
--    Returns NULL if the geometry only contains an optimized point (stored
--    in SDO_POINT)
-- -----------------------------------------------------------------------

function get_num_ordinates
  (geom sdo_geometry)
  return number;

-- -----------------------------------------------------------------------
-- NAME:
--    GET_NUM_POINTS (GEOM)
-- DESCRIPTION:
--    This function returns the total number of points in a geometry
-- ARGUMENTS:
--    geom - The geometry to format (sdo_geometry)
-- RETURN
--    NUMBER
-- NOTES:
--    Returns NULL if the geometry only contains an optimized point (stored
--    in SDO_POINT)
-- -----------------------------------------------------------------------

function get_num_points
  (geom sdo_geometry)
  return number;

-- -----------------------------------------------------------------------
-- NAME:
--    GET_NUM_DECIMALS (GEOM)
-- DESCRIPTION:
--    This function returns the maximum number of decimals in a geometry
-- ARGUMENTS:
--    geom - The geometry to format (sdo_geometry)
-- RETURN
--    NUMBER
-- -----------------------------------------------------------------------

function get_num_decimals
  (geom sdo_geometry)
  return number;

-- -----------------------------------------------------------------------
-- NAME:
--    GET_POINT_X (GEOM)
-- DESCRIPTION:
--    This function returns the X ordinate of a single point geometry
-- ARGUMENTS:
--    geom - The geometry to format (sdo_geometry)
-- RETURN
--    NUMBER
-- NOTES:
--    Returns NULL if the geometry does not contain an single point
-- -----------------------------------------------------------------------

function get_point_x
  (geom sdo_geometry)
  return number;

-- -----------------------------------------------------------------------
-- NAME:
--    GET_POINT_Y (GEOM)
-- DESCRIPTION:
--    This function returns the Y ordinate of a single point geometry
-- ARGUMENTS:
--    geom - The geometry to format (sdo_geometry)
-- RETURN
--    NUMBER
-- NOTES:
--    Returns NULL if the geometry does not contain an single point
-- -----------------------------------------------------------------------

function get_point_y
  (geom sdo_geometry)
  return number;

-- -----------------------------------------------------------------------
-- NAME:
--    GET_ORDINATE (GEOM, I)
-- DESCRIPTION:
--    This function returns the Ith ordinate of a geometry
-- ARGUMENTS:
--    geom - The geometry to read (sdo_geometry)
--    i - The index of the ordinate to extract
-- RETURN
--    NUMBER
-- NOTES:
--    Returns NULL if the specified index value is outside the bounds of the ordinates array
--    or if the ordinates array is null
-- -----------------------------------------------------------------------

function get_ordinate
  (geom sdo_geometry,
   i number)
  return number;

-- -----------------------------------------------------------------------
-- NAME:
--    GET_POINT (GEOM, I)
-- DESCRIPTION:
--    This function returns the Ith point of a geometry
-- ARGUMENTS:
--    geom - The geometry to read (sdo_geometry)
--    i - The number of the point to extract (default is 1)
-- RETURN
--    GEOMETRY
-- NOTES:
--    Fails if the specified index value is outside the bounds of the ordinates array
--    or if the ordinates array is null
--    Fails if the object does not contain the dimensionality (i.e. if it uses a
--    single digit GTYPE.
--    The point number (I) is relative to the total number of points in the geometry, not
--    considering any multi-geometry implications. For example, consider a polygon with void
--    where the outer ring is 50 points, and the inner ring is 10 points, to get the 4th point
--    of the inner ring, you need to ask for point number 54.
--    If I is negative, then it represents a count from the end of the geometry, i.e. -1
--    means the last point in the geometry.
-- -----------------------------------------------------------------------

function get_point (
  geom sdo_geometry,
  point_number number default 1
) return sdo_geometry;

function get_first_point (
  geom sdo_geometry
) return sdo_geometry;

function get_last_point (
  geom sdo_geometry
) return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--    INSERT_POINT (LINE, POINT, [I])
-- DESCRIPTION:
--    This function inserts a point before the Ith point of a line geometry
-- ARGUMENTS:
--    line - The line geometry to update (SDO_GEOMETRY)
--    point - The point to add (SDO_GEOMETRY)
--    i - The position before which the point should be inserted.
--        1 = insert at the beginning of the line
--        0 = insert at the end of the line
--        null or ommitted: project the point on the line and insert the projected
--        point in the proper location.
-- RETURN
--    SDO_GEOMETRY - the updated line geometry
-- NOTES:
--    Returns NULL if either of the input geometries is null
--    Fails if the object does not contain the dimensionality (i.e. if it uses a
--    single digit GTYPE and is not a single line (gtype 2).
--    Fails if the point is not a simple point
--    Fails if the two geometries have different dimensions or coordinate system
--    If I is negative, then it represents a count from the end of the geometry, i.e. -1
--    means the last point in the geometry.
-- -----------------------------------------------------------------------

function insert_point (
  line          sdo_geometry,
  point         sdo_geometry,
  insert_before number default null
) return sdo_geometry;

function insert_first_point (
  line          sdo_geometry,
  point         sdo_geometry
) return sdo_geometry;

function insert_last_point (
  line          sdo_geometry,
  point         sdo_geometry
) return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--    REMOVE_POINT (LINE, I)
-- DESCRIPTION:
--    This function removes the Ith point of a geometry
-- ARGUMENTS:
--    line - The line geometry to update (SDO_GEOMETRY)
--    i - The position of the point to delete.
--        1 = remove first point
--        -0 = remove last point
-- RETURN
--    SDO_GEOMETRY - the updated line geometry
-- NOTES:
--    Returns NULL if the input geometry is null
--    Fails if the object does not contain the dimensionality (i.e. if it uses a
--    single digit GTYPE) and is not a single line (gtype 2).
--    If I is negative, then it represents a count from the end of the geometry, i.e. -1
--    means the last point in the geometry.
-- -----------------------------------------------------------------------

function remove_point (
  line          sdo_geometry,
  point_number  number
) return sdo_geometry;

function remove_first_point (
  line          sdo_geometry
) return sdo_geometry;

function remove_last_point (
  line          sdo_geometry
) return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--    REVERSE_LINESTRING (LINE)
-- DESCRIPTION:
--    This function reverses the order of all the points in a linestring
-- ARGUMENTS:
--    line - The line geometry to reverse (SDO_GEOMETRY)
-- RETURN
--    SDO_GEOMETRY - the updated line geometry
-- NOTES:
--    Returns NULL if the input geometry is null
--    Fails if the object does not contain the dimensionality (i.e. if it uses a
--    single digit GTYPE) and is not a single line (gtype 2).
-- -----------------------------------------------------------------------
function reverse_linestring (
  line          sdo_geometry
) return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--    GET_ELEMENT (GEOM, ELEMENT_NUM)
-- DESCRIPTION:
--    This function returns a selected element from a compound geometry
-- ARGUMENTS:
--    geom - The geometry to format (sdo_geometry)
--    element_num - the number of the element to extract
-- RETURN
--    sdo_geometry
-- NOTES:
--    Returns NULL if the geometry only contains an optimized point (stored
--    in SDO_POINT) or if the element number is larger than the number of elements
--    in the geometry.
-- RESTRICTIONS:
--    This function counts the number of primitive elements that compose the geometry; for
--    polygons with voids, each ring (outer or inner) is counted as a separate element.
--    It also returns a single primitive element. For a polygon vith a void (i.e. composed
--    of two primitive elements - an outer ring, then an inner ring), a request to get the
--    second element will return the void (the inner ring) as a single polygon. This single
--    polygon is returned as an outer ring.
-- -----------------------------------------------------------------------

function get_element (
    geom sdo_geometry,
    element_num number
)
return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--    GET_ELEMENTS (GEOM)
-- DESCRIPTION:
--    This function returns the list of elements from a compound geometry
-- ARGUMENTS:
--    geom - The geometry to process (sdo_geometry)
-- RETURN
--    sdo_geometry_table
-- EXAMPLE
--    select * from table(get_elements((select geom from us_states where state_abrv='CA')));
-- -----------------------------------------------------------------------
function get_elements (
    geom sdo_geometry
)
return sdo_geometry_table
pipelined;

-- -----------------------------------------------------------------------
-- NAME:
--    GET_RINGS (GEOM)
-- DESCRIPTION:
--    This function returns the list of rings from a compound geometry
-- ARGUMENTS:
--    geom - The geometry to process (sdo_geometry)
-- RETURN
--    sdo_geometry_table
-- EXAMPLE
--    select * from table(get_rings((select geom from us_states where state_abrv='CA')));
-- -----------------------------------------------------------------------
function get_rings (
    geom sdo_geometry
)
return sdo_geometry_table
pipelined;
-- -----------------------------------------------------------------------
-- NAME:
--    GET_ELEMENT_TYPE (GEOM)
-- DESCRIPTION:
--    This function returns the type of the first or only element in a geometry as a
--    character string.
-- ARGUMENTS:
--    geom - Input geometry  (sdo_geometry)
-- RETURN
--    VARCHAR2
-- NOTES:
--    The result will be one of the following values
--    elem_type  interpretation
--        1           1            POINT
--        1           n            POINT CLUSTER
--        2           1            LINE STRING
--        2           2            ARC STRING
--        3           1            POLYGON
--        3           2            ARC POLYGON
--        3           3            RECTANGLE
--        3           4            CIRCLE
--        4           n            MIXED LINE STRING
--        5           n            MIXED POLYGON
--    To get the type of an element other than the first, use the GET_ELEMENT
--    function first to extract the number the element.
--    Returns NULL if the geometry only contains an optimized point (stored
--    in SDO_POINT)

-- -----------------------------------------------------------------------

function get_element_type (geom sdo_geometry)
  return varchar2;

-- -----------------------------------------------------------------------
-- NAME:
--    QUICK_CENTER (GEOM)
-- DESCRIPTION:
--    This function returns the center of the rectangle that defines the
--    minimum bounding box of the input geometry
-- ARGUMENTS:
--    geom - the input geometry
-- RETURN
--    sdo_geometry
-- NOTES
--    The function uses a quick and simple algorithm: it extracts the minimum
--    and maximum values for the X and Y coordinates to build the MBR.
--    This will return incorrect results if the geometry contains any circular
--    arcs. It then computes the center point of this MBR.
--    The resulting MBR is always in 2D (even if the input geometry is 3D) and
--    is in the same SRID as the input geometry.
-- -----------------------------------------------------------------------

function quick_center
  (geom sdo_geometry)
  return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--    QUICK_MBR (GEOM)
-- DESCRIPTION:
--    This function returns a 2D rectangle that defines the minimum bounding box of
--    the input geometry
-- ARGUMENTS:
--    geom - the input geometry
-- RETURN
--    sdo_geometry
-- NOTES
--    The function uses a quick and simple algorithm: it extracts the minimum
--    and maximum values for the X and Y coordinates to build the MBR.
--    This will return incorrect results if the geometry contains any circular
--    arcs.
--    The resulting MBR is always in 2D (even if the input geometry is 3D) and
--    is in the same SRID as the input geometry.
-- -----------------------------------------------------------------------

function quick_mbr
  (geom sdo_geometry)
  return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--    JOIN (GEOM_1, GEOM_2)
-- DESCRIPTION:
--    This function returns a geometry constructed by "concatenating" the two input
--    geometries
-- ARGUMENTS:
--    geom_1 - the first input geometry
--    geom_2 - the second input geometry
-- RETURN
--    sdo_geometry
-- NOTES:
--    The function joins the input geometries by concatenating their internal structures
--    (element info array and ordinates array). It does not perform any geometry operations
--    on the individual elements. It could generate invalid geometries, for instance if
--    constructing a multi-polygon from overlapping polygons.
--    The function returns NULL if any of the input geometries is an optimized point
--    The two input geometries must have the same dimensions
-- -----------------------------------------------------------------------

function join
  (geom_1 sdo_geometry,
   geom_2 sdo_geometry)
  return sdo_geometry;


-- -----------------------------------------------------------------------
-- NAME:
--    DUMP (GEOM, SHOW_ORDINATES)
-- DESCRIPTION:
--    This procedure interprets the contents of an SDO_GEOMETRY object
-- ARGUMENTS:
--    geom - The geometry to format (sdo_geometry)
--    show_ordinates:
--      0 = do not display ordinates
--      1 = display all ordinates (default)
--      2 = display only first and last point of each element
-- NOTES:
--    Output is displayed using the DBMS_OUTPUT package.
-- -----------------------------------------------------------------------

procedure dump (
  geom sdo_geometry,
  show_ordinates integer default 1
);
function dump (
  geom sdo_geometry,
  show_ordinates integer default 1
)
return number;

-- -----------------------------------------------------------------------
-- NAME:
--   GEOMETRY = LAYER_EXTENT (TABLE_NAME, COLUMN_NAME, PARTITION_NAME)
-- DESCRIPTION:
--    This constructor returns a 2D rectangle that defines the bounds of a layer
--    based on its extend defined in the rtree index
-- ARGUMENTS:
--    table_name - the name of the spatial table
--    column_name - the name of the spatial column
--    partition_name - the name of the partition (optional)
-- RETURN
--    sdo_geometry
-- NOTES
--    This function looks up the MBR of the root of the rtree index on
--    the specified column. If no rtree index exists, then the function
--    returns NULL.
--    If the index is partitioned and no partition name is provided, then
--    the resulting geometry will be an MBR that encompasses the root MBR
--    of all partitions.
-- -----------------------------------------------------------------------

function layer_extent (
   p_table_name         varchar2,
   p_column_name        varchar2,
   p_partition_name     varchar2 default null
)
return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--    REMOVE_DUPLICATE_POINTS  (GEOM)
-- DESCRIPTION:
--    This function remove all duplicate points from a
--    geometry object
-- ARGUMENTS:
--    geom - The geometry to correct (sdo_geometry)
--    tolerance - tolerance factor used in point comparisons
-- NOTES
--    If no TOLERANCE is specified, then con secutive points are
--    compared for strict equality.
--    If a TOLERANCE is specified, then two consecutive points are
--    considered equal if their X and Y values differ by less than
--    the tolerance value.
-- RESTRICTIONS:
--    The tolerance value applies only to non-geodetic data.
-- -----------------------------------------------------------------------

function remove_duplicate_points
  (geom sdo_geometry,
   tolerance number default NULL)
  return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--    VALIDATE_GEOMETRY  (GEOM, DIMINFO or TOLERANCE)
-- DESCRIPTION:
--    This function calls the SDO_GEOM.VALIDATE function but
--    converts the error code into an error message
-- ARGUMENTS:
--    geom - The geometry to validate (sdo_geometry)
--    diminfo - the dimensions array for the geometry
--      or
--    tolerance - a tolerance setting
-- -----------------------------------------------------------------------

function validate_geometry
  (geom sdo_geometry,
   diminfo sdo_dim_array
  )
  return VARCHAR2;

function validate_geometry
  (geom sdo_geometry,
   tolerance number
  )
  return VARCHAR2;
function validate_geometry_with_context
  (geom sdo_geometry,
   diminfo sdo_dim_array
  )
  return VARCHAR2;

function validate_geometry_with_context
  (geom sdo_geometry,
   tolerance number
  )
  return VARCHAR2;

-- -----------------------------------------------------------------------
-- NAME:
--    SET_PRECISION  (GEOM, NR_DECIMALS, ROUNDING_MODE)
-- DESCRIPTION:
--    This function will round all ordinates to the chosen precision
-- ARGUMENTS:
--    geom - The geometry to process (sdo_geometry)
--    nr_decimals - the number of decimals to truncate or round to
--    rounding_mode - ROUND or TRUNCATE
-- RETURN
--    sdo_geometry
-- -----------------------------------------------------------------------

function set_precision
  (geom sdo_geometry,
   nr_decimals number,
   rounding_mode varchar2
     default 'ROUND'
  )
  return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--    SHIFT  (GEOM, X_SHIFT, Y_SHIFT)
-- DESCRIPTION:
--    Move a geometry by adding a fixed offset to the X and Y dimensions
-- ARGUMENTS:
--    geom - The geometry to modify (sdo_geometry)
--    x_shift - the value to add to the X values
--    y_shift - the value to add to the Y values
-- RETURN
--    sdo_geometry
-- NOTES
--    The geometry must have a 4-digit GTYPE
-- -----------------------------------------------------------------------

function shift (
  geom      sdo_geometry,
  x_shift   number,
  y_shift   number
)
return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--    CLEANUP (GEOM, GTYPE, MIN_AREA, MIN_POINTS)
-- DESCRIPTION:
--    This function "cleans up" a geometry
--    by removing all element types that do not match a chosen type.
-- ARGUMENTS:
--    geom - The geometry to format (sdo_geometry)
--    output_type - the element types to keep
--      1 = only keep point element types (etype 1)
--      2 = only keep line element types (etype 2 or 4)
--      3 = only keep area element types (etypes 3 or 5)
--      If no output_type is specified, then 3 is the default
--    min_area - for polygons, only elements larger than "min_area" are returned
--      The area is expressed in square meters. If not specified, then all areas are returned.
--    min_points - only elements with more than this number of points are returned
--      If not specified, then all elements are returned
-- RETURN
--    sdo_geometry
-- NOTES:
--    Returns NULL if the operation results in all elements
--    being removed from the geometry.
-- -----------------------------------------------------------------------

function cleanup (
  geom          sdo_geometry,
  output_type   number default 3,
  min_area      number default 0,
  min_points    number default 0
)
return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--    REMOVE_VOIDS (GEOM,)
-- DESCRIPTION:
--    This function removes all voids from 2D and 3D polygons
-- ARGUMENTS:
--    geom - The geometry to process (sdo_geometry)
-- RETURN
--    sdo_geometry
-- NOTES:
--    Fails if the input geometry is not a polygon
-- -----------------------------------------------------------------------

function remove_voids (
  geom          sdo_geometry
)
return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--    SET_TOLERANCE  (DIMINFO, TOLERANCDE)
-- DESCRIPTION:
--    Update the tolerance for all dimensions in a DIMINFO array
-- ARGUMENTS:
--    diminfo - the dimensions array to update (SDO_DIM_ARRAY)
--    tolerance - the tolerance to use
-- RETURN
--    SDO_DIM_ARRAY
-- NOTES:
--    The goal of this function is to make it easier to modify the tolerance
--    in spatial metadata. Example of use:
--    UPDATE USER_SDO_GEOM_METADATA
--       SET DIMINFO = sdo_tools.SET_TOLERANCE (DIMINFO, 0.005)
--     WHERE TABLE_NAME = ... AND COLUMN_NAME = ...;
-- -----------------------------------------------------------------------

function set_tolerance
  (p_diminfo sdo_dim_array,
   p_tolerance number
  )
  return sdo_dim_array;

-- -----------------------------------------------------------------------
-- NAME:
--    MAKE_2D  (GEOM)
-- DESCRIPTION:
--    This function will remove the 3rd and 4th dimension from all points
-- ARGUMENTS:
--    geom - The geometry to process (sdo_geometry)
-- RETURN
--    sdo_geometry
-- NOTES:
--    The function will return NULL if the input geometry is null,
--    It will fail if the geometry does not have a 4-digit GTYPE
--    It will return the input geometry unchanged if is is already 2D.
--    For optimized points, the function will just set the Z value to null.
--    The transformations concern 3D points, lines and polygons (not solids)
--    The geometries can also be 3D LRS
--
--    Input                   Output
--
--    20xx x,y      2D        20xx x,y      unchanged (already 2D)
--    33xx x,y,m    2D LRS    33xx x,y,m    unchanged (already 2D)
--    43xx x,y,m,k  2D LRS+K  43xx x,y,m,k  unchanged (already 2D)
--
--    30xx x,y,z    3D        20xx x,y      z removed
--    40xx x,y,z,k  3D+K      30xx x,y,k    z removed, k retained
--    44xx x,y,z,m  3D LRS    33xx x,y,m    z removed, m retained
-- -----------------------------------------------------------------------

function make_2d (geom sdo_geometry)
  return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--    MAKE_3D  (GEOM, Z_VALUE)
-- DESCRIPTION:
--    This function adds a 3rd dimension to any 2d object.
-- ARGUMENTS:
--    geom - The geometry to process (sdo_geometry)
--    z_value - the numeric value to use for the third dimension. Default is 0
-- RETURN
--    sdo_geometry
-- NOTES:
--    The function will return NULL if the input geometry is null,
--    It will fail if the geometry does not have a 4- digit GTYPE
--    or if it is not strictly 2D. I.e. it also fails if the
--    input geometry is a 2D LRS line (2D+measure)
--    For optimized points, the function will just set Z to the value provided..
-- -----------------------------------------------------------------------

function make_3d (geom sdo_geometry, z_value number default 0)
  return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--    to_line  (GEOM)
-- DESCRIPTION:
--    This function transforms a polygon geometry into a line geometry
-- ARGUMENTS:
--    geom - The geometry to process (sdo_geometry)
-- RETURN
--    sdo_geometry
-- NOTES:
--    The function will return NULL if the input geometry is null
--    It fails (generates an exception) if any of the following
--    conditions is true:
--    - it does not have a 4-digit GTYPE,
--    - it is anything but a polygon or multi-polygon (gtype 3 or 7).
--    - it contains a circle or optimized rectangle
-- -----------------------------------------------------------------------

function to_line (geom sdo_geometry)
  return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--    to_polygon  (GEOM)
-- DESCRIPTION:
--    This function transforms a line geometry into a polygon geometry
-- ARGUMENTS:
--    geom - The geometry to process (sdo_geometry)
-- RETURN
--    sdo_geometry
-- NOTES:
--    The function will return NULL if the input geometry is null
--    It fails (generates an exception) if any of the following
--    conditions is true:
--    - it does not have a 4-digit GTYPE,
--    - it is anything but a line or multi-line (gtype 2 or 6).
-- RESTRICTIONS:
--    The function assumes that the input line geometry represents the
--    contour of a polygon, possibly made of multiple rings. It makes
--    no attempt to distinguish outer from inner rings (all rings are
--    assumed to be outer rings). It will however orient the rings
--    correctly (counter clockwise).
--    The function also assumes that the rings are well-formed, i.e. that
--    they close, do not overlap and do not self-intersect. It makes no
--    attempt at closing rings or otherwise correcting geometries. It is
--    therefore possible that the function produces invalid geometries. You
--    should verify the resulting geomtry using the standard VALIDATE_GEOMETRY
--    function.
-- -----------------------------------------------------------------------

function to_polygon (geom sdo_geometry)
  return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--     SET_MEASURE_AT_POINT (GEOM, N, M)
-- DESCRIPTION:
--    This procedure sets the measure value at a chosen point in an LRS segment
-- ARGUMENTS:
--    geom - The geometry to update (sdo_geometry)
--    n - the sequence number of the point to set
--    m - the measure to set
-- -----------------------------------------------------------------------
procedure set_measure_at_point
  (geom in out sdo_geometry,
   n in integer,
   m in integer);

-- -----------------------------------------------------------------------
-- NAME:
--    TO_DD (SD)
-- DESCRIPTION:
--    Convert a coordinate value (lat or long) expressed in sexagedecimal degrees
--    into decimal degrees
-- ARGUMENTS:
--    sd (number) - a signed coordinate value in sexagedecimal notation
--      Format: dddddd.mmssfffff
--        ddddddd : degrees (any number of digits - decimal point is required)
--        mm : minutes (two digits) - required
--        ss : integer seconds (two digits)
--        fffff : fraction of seconds (any precision)
--    sd (string) - a coordinate value in sexagedecimal notation with E/W/N/S indication
--      Format: ddd.mmssfffffo
--        ddd : degrees (any number of digits, 0 to 90 or 180)
--        mm : minutes (two digits, 0 to 59)
--        ss : integer seconds (two digits, 0 to 59) - optional
--        fffff : fraction of seconds (any precision) - optional
--        o : letter E or W or N or S
-- RETURN
--    number - the coordinate value in decimal degrees
-- -----------------------------------------------------------------------

function to_dd (sd number)
  return number;

function to_dd (sd varchar2)
  return number;

-- -----------------------------------------------------------------------
-- NAME:
--    TO_DMS (DD, DIRECTION)
-- DESCRIPTION:
--    Convert a coordinate value (lat or long) expressed in decimal degrees
--    into degrees, minutes and seconds
-- ARGUMENTS:
--    dd (number) - a signed coordinate value in decimal degrees
--    direction (varchar2) - the string 'LAT' or 'LONG'
-- RETURN
--    a coordinate value in DMS notation with E/W/N/S indication
--      Format: ddd mm ss.fffff o
--        ddd : degrees (any number of digits, 0 to 90 or 180)
--        mm : minutes (two digits, 0 to 59)
--        ss : integer seconds (two digits, 0 to 59)
--        fffff : fraction of seconds (any precision)
--        o : letter E or W or N or S
-- -----------------------------------------------------------------------

function to_dms (dd number, direction varchar2)
  return varchar2;

-- -----------------------------------------------------------------------
-- NAME:
--    UTM_ZONE_BOUNDS (ZONE_NUMBER, ORIENTATION)
-- DESCRIPTION:
--    Generates the geodetic bounding box for a UTM zone
-- ARGUMENTS:
--    zone_number (number) - the number of the UTM zone (from 1 to 60)
--    orientation (varchar2) - the string 'N' or 'S'
-- RETURN
--    a geodetic rectangle
-- NOTES:
--    UTM zones are 6 degrees wide and are valid up to 84 degrees of latitude
--    (north or south). They start from the -180° meridian and are numbered
--    from west to east.
--    The center meridian for a zone is computed as (zone_number*6)-180-3
--    For example: UTM zone 20 has a center meridian of (20*6)-180 = -63° and
--    spans from -66° to -60°.
-- -----------------------------------------------------------------------

function utm_zone_bounds (zone_number number, orientation varchar2)
  return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--    GET_ORIENTATION  (GEOM)
-- DESCRIPTION:
--    This function determines the orientation (clockwise or counter-clockwise
--    of a simple (single-ring) polygon.
-- ARGUMENTS:
--    geom - The geometry to process (sdo_geometry)
-- RETURN
--    NUMBER
--      +1 if the ring orientation is counter-clockwise (= an outer ring)
--      -1 if the ring orientation is clockwise (= an inner ring)
-- NOTES:
--    The function will fail (generate an exception) if the geometry does
--    not have a 4-digit gtype, or if it is anything else but a simple
--    polygon with a single ring.
-- -----------------------------------------------------------------------

function get_orientation (geom sdo_geometry)
  return number;

-- -----------------------------------------------------------------------
-- NAME:
--    FIX_ORIENTATION  (GEOM)
-- DESCRIPTION:
--    This function corrects the orientation (clockwise or counter-clockwise
--    of all rings in a polygon.
-- ARGUMENTS:
--    geom - The geometry to process (sdo_geometry)
-- RETURN
--    sdo_geometry
-- NOTES:
--    The function will fail (generate an exception) if the geometry does
--    not have a 4-digit gtype, or if it is anything else but a polygon
--    or multi-polygon.
--    It first verifies if the orientation of a ring matches the ring type
--    (outer or inner). If it does not match, then it reverses the orientation
--    of that ring.
-- -----------------------------------------------------------------------

function fix_orientation (geom sdo_geometry)
  return sdo_geometry;

-- -----------------------------------------------------------------------
-- NAME:
--    SAME_GEOMETRIES  (GEOM1, GEOM2, tolerance)
-- DESCRIPTION:
--    This function compares two geometries. If they are the same
--    then it returns TRUE.
-- ARGUMENTS:
--    geom1, geom2 - The two geometries to compare (sdo_geometry)
--    tolerance - the tolerance to apply to the comparison
-- RETURN
--    VARCHAR2: a string containing 'TRUE' or 'FALSE'
-- NOTES:
--    The function compares the internal structure of the two objects: it
--    returns TRUE if those structures are identical.
--    If they are not strictly identical, then the function uses
--    SDO_GEOM.RELATE which does a geometric comparison.
--    SDO_GEOM.RELATE will detect that two geometries are identical even
--    when they are digitized differently (points in a different sequence)
--    or if they differ by a tolerance factor.
--    The function can also return FALSE if it detects with certainty that
--    the two geometries are different: they have different dimensionality,
--    incompatible GTYPES or different SRIDs.
-- -----------------------------------------------------------------------
function  same_geometries (g1 sdo_geometry, g2 sdo_geometry, t number)
  return varchar2;

end sdo_tools;
/
show error
