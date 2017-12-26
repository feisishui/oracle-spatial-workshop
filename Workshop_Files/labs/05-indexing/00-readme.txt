==========================================================
Indexing
==========================================================

1) Create spatial indexes on all tables

  01_CREATE_SPATIAL_INDEXES.SQL

  This script creates a spatial index on all tables loaded sofar

  US_CITIES
  US_COUNTIES
  US_INTERSTATES
  US_PARKS
  US_RIVERS
  US_STATES
  WORLD_CONTINENTS
  WORLD_COUNTRIES

  US_CITIES_P
  US_COUNTIES_P
  US_INTERSTATES_P
  US_PARKS_P
  US_RIVERS_P
  US_STATES_P

2) Create non-spatial indexes on all tables

  02_CREATE_OTHER_INDEXES.SQL

3) Estimate the size of indexes

  03_ESTIMATE_INDEX_SIZE.SQL

  This will estimate the size (in MB) of the spatial indexes for all spatial tables

4) Estimate the size of a planned index

  04_ESTIMATE_PLANNED_INDEXES_SIZE.SQL

5) Show the actual size of spatial indexes

  05_SHOW_INDEX_SIZE.SQL

6) Verify that all tables have a spatial index and that the indexes are all valid

  06_CHECK_SPATIAL.SQL
