Spatial utility functions
=========================

(Last updated by: Albert Godfrind on: 28-Aug-2015)

1. Warning
----------

The functions in this package are UNSUPPORTED.


2. Files included in this package
---------------------------------

   sdo_tools.sql                sdo_tools package
   sdo_tools_body.sql           sdo_tools package body
   sdo_tools_public.sql         defines a public synonym for the package (optional)

3. Description
--------------

This package provides a number of functions and procedures that aid in
manipulating SDO_GEOMETRY objects.

- constructors: shortcuts for constructing various geometries :
  geometry = point (x, y, z)
  geometry = rectangle (Xa, Ya, Xb, Yb)
  geometry = circle (X, Y, radius)
  geometry = circle (X1, Y1, X2, Y2, X3, Y3)

- inspectors: extract information from geometries in various formats :
  string = format (geometry)
  n = get_num_elements (geometry)
  n = get_num_ordinates (geometry)
  n = get_num_points (geometry)
  n = get_num_decimals (geometry)
  x = get_point_x (geometry)
  y = get_point_y (geometry)
  n = get_ordinate (geometry, n)
  point_geometry = get_point (geometry, n)
  point_geometry = get_first_point (geometry)
  point_geometry = get_last_point (geometry)
  geometry = get_element (geometry, n)
  string = get_element_type (geometry)
  n = get_orientation (geometry)
  get_elements (geometry)
  get_rings (geometry)

- setters: set and modify geometries in various ways :
  set_measure_at_point (geom, n, m)

- converters: transform geometries in various ways
  line_geometry = insert_point (line_geometry, point, index)
  line_geometry = insert_first_point (line_geometry, point)
  line_geometry = insert_last_point (line_geometry, point)
  line_geometry = remove_point (line_geometry, index)
  line_geometry = remove_first_point (line_geometry)
  line_geometry = remove_last_point (line_geometry)
  line_geometry = reverse_linestring (line_geometry)
  geometry = remove_duplicate_points (geometry)
  geometry = fix_orientation (polygon geometry)
  geometry = make_2d (geometry)
  geometry = make_3d (geometry, value)
  geometry = to_line (polygon geometry)
  geometry = to_polygon (line geometry)
  geometry = set_precision (geometry, nr_decimals)
  geometry = shift (geometry, x_shift, y_shift)
  geometry = cleanup (geometry, output_type, min_area, min_points)
  geometry = remove_voids (geometry)

- miscellaneous functions:
  geometry = quick_mbr (geometry)
  geometry = join (geometry, geometry)
  geometry = layer_extent (table_name, column_name, partition_name)
  string = validate_geometry (geometry) = validate and return error message (not code)
  string = validate_geometry_with_context (geometry) = validate and return error message (not code)
  diminfo = set_tolerance (diminfo, tolerance)
  decimal_degrees = to_dd (sexagesimal_degrees)
  dms_degrees = to_dms (decimal_degrees, direction)
  geometry = utm_zone_bounds (zone_number, orientation)

- miscellaneous procedures:
  dump (geometry)
  dump_rtree (table_name, column_name, output_table)

NOTES

  The functions only support geometries with long gtypes (4-digit gtypes).

 See the package source for further details

4. Installation notes
---------------------

   The sdo_tools package can be defined in any schema (including MDSYS).

Change history
--------------

MODIFIED     (DD-MON-YY)  DESCRIPTION

agodfrin      28-Aug-15   Removed unnecessary MDSYS prefixes.
agodfrin      27-Feb-14   Added INSERT_POINT(line, point) withjout index: project and insert
agodfrin      15-Jul-13   Added GET_ELEMENTS and GET_RINGS pipelined functions
agodfrin      04-Jun-12   Added REMOVE_VOIDS function
agodfrin      29-Jan-11   Renamed TO_2D() and TO_3D() to MAKE_2D() and MAKE_3D()
agodfrin      29-Jan-11   TO_2D() now supports LRS geometries
agodfrin      11-Oct-10   Fixed recursion loop in DUMP() function
agodfrin      23-Jun-10   Removed quadtree functions and procedures
agodfrin      05-Nov-09   Fixed errors in CLEANUP, JOIN and GET_ELEMENT procedures
agodfrin      20-Feb-09   Removed OFFSET function and procedure
agodfrin      19-Feb-09   Add minimum area and minimum points filtering to CLEANUP function
agodfrin      09-Dec-08   Add UTM_ZONE_BOUNDS function
agodfrin      21-Jul-08   Add GET_NUM_DECIMALS function
agodfrin      19-Apr-08   Correct SAME_GEOMETRIES() to only return TRUE or FALSE
agodfrin      15-Nov-07   Make CLEANUP also work with simple points
agodfrin      03-Jun-07   Make rounding the default for the SET_PRECISION function.
agodfrin      29-Mar-07   Modified function DUMP to display only start and end point of each element
agodfrin      10-Sep-06   Added LAYER_EXTENT function to compute layer extent from rtree index
agodfrin      13-Mar-06   Added to_3d function. Renamed "set_2d" to "to_2d"
agodfrin      05-Jul-05   Added DUMP_RTREE and related functions
agodfrin      21-Mar-05   Added REVERSE_LINESTRING function
agodfrin      18-Mar-05   Added QUICK_CENTER function
agodfrin      18-Mar-05   GET_MBR re-implemented as QUICK_MBR
agodfrin      25-Jan-05   GET_POINT() now also returns 3rd dimension (Z or M) if any
agodfrin      09-Jul-04   Added same_geometries() function
agodfrin      20-Apr-04   Added to_dms() function
agodfrin      13-Oct-03   Added shift() function to shift all ordinates by a given factor
agodfrin      21-Sep-03   Removed support of geometries with short (single-digit) gtypes.
agodfrin      09-Sep-03   Allow set_precision() to round or truncate coordinates
agodfrin      09-Sep-03   Added validate_geometry_with_context() function
agodfrin      18-Aug-03   Added insert_point() and remove_point() functions
agodfrin      17-Aug-03   get_point can use a negative point number. Add get_first_point() and get_last_point()
agodfrin      11-Aug-03   Added to_polygon function
agodfrin      01-Jul-03   Added to_line function
agodfrin      23-Apr-03   Added functions to get and correct polygon orientation
agodfrin      09-Jan-03   Added function to convert a coordinate from sexagesimal to decimal degrees
agodfrin      26-Aug-02   Simplified element counting algorithms
agodfrin      26-Aug-02   Added cleanup() function
agodfrin      10-Jul-02   Renamed package as SDO_TOOLS to avoid confict with SDO_UTIL
agodfrin      07-Apr-02   Added OFFSET function and procedure to shift a geometry
agodfrin      11-Feb-02   Added function to convert a row/column into a tilecode
agodfrin      04-Feb-02   Added quadtree_quality procedure
agodfrin      04-Feb-02   Added analyze_index procedure variant to use tablename/column nam
agodfrin      12-Dec-01   Added set_measure_at_point procedure
agodfrin      05-Dec-01   Added analyze_index procedure
agodfrin      15-Oct-01   Added set_2d function.
agodfrin      27-Dec-00   Corrected tile generation for 8.1.6/8.1.7
agodfrin      20-Oct-00   Added validation routine
agodfrin      10-Oct-00   Added function to remove duplicate points
agodfrin      27-Sep-00   Generate 815 or 816 format depending on user choice
agodfrin      02-Sep-00   Used SDO routine for MBR calculation
agodfrin      15-Aug-00   Upgraded to 8.1.6 (use 4-digit gtypes and etypes)
agodfrin      04-May-00   Added convert_816_to_815 function
agodfrin      02-Mar-00   Corrected MBR generation
agodfrin      12-Oct-99   Added constructor functions
agodfrin      10-Oct-99   Added tile extraction functions
agodfrin      27-Jul-99   Created
