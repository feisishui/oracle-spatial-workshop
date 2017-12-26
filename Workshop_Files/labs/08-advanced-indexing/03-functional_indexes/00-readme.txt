==========================================================
Advanced Indexing / Functional Indexes
==========================================================

1) Create a copy of the cities table with X and Y columns.

  The table has the same attributes as the US_CITIES table, except the
  LOCATION column, which is replaced by two columns (LONGITUDE and
  LATITUDE)

  06_CREATE_CITIES_XY.SQL

2) Create function "get_point"

  That function takes two numbers and returns a geometry type that uses
  the two numbers as X and Y values. The coordinate system is 8307.

  07_CREATE_FUNCTION.SQL

3) Setup the metadata for the function index

  09_SET_METADATA.SQL

4) Create the function index

  09_CREATE_FUNCTION_INDEX.SQL

5) Perform queries on the CITIES_XY table

  - Get all cities in Colorado
  - Get all cities less than 200 km from Boston
  - Get all cities less than 200 km from Boston ordered by distance

  10-QUERIES.SQL
