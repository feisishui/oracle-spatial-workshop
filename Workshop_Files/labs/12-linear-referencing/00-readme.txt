==========================================================
Linear Referencing
==========================================================

1) Create table US_INTERSTATES_LRS

  This table will contain the geometries of all the interstates
  that are partly or fully in Colorado

  01_CREATE_INTERSTATES_LRS.SQL

2) Convert the US_INTERSTATES_LRS to LRS geometries

  02_CONVERT_TO_LRS.SQL

3) Create table US_ROAD_CONDITIONS

  That table contains rows that define the condition of
  the surface of interstate sections.

  03_CREATE_ROAD_CONDITION_TABLE.SQL

4) Get interstate sections in "poor" condition

  04_CLIP_SEGMENTS.SQL

5) Create a view that encapsuletes the clipping

  05_CREATE_ROAD_CONDITION_VIEW.SQL

6) Load mapviewer styles for road contitions

  06-LOAD_MAP_DEFINITIONS.SQL

  This defines a set of line styles for the basic conditions (poor, fair, goodà as
  well as an advanced style that combines them. It also defines a theme and map.

7) Locate a point on I25

  - Locate the point located 50 km down I25
  - Locate the point located 50 km down I25, 200 m on the left
  - Locate the point located 50 km down I25, 200 m on the right

  07_LOCATE_POINT.SQL

8) Project a point on I95
  - Project point (-104.60663, 37.3906514) on I25
  - Get measure and offset of point (-104.60663, 37.3906514) on I25

  08_PROJECT_POINT.SQL

9) Report on road conditions

  Report the number of kilometers per condition per road

  09_REPORT_ROAD_CONDITIONS.SQL
