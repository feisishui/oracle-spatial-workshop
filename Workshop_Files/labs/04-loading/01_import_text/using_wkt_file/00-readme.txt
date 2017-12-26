==========================================================
Loading from WKT
==========================================================

Note that this process is only possible for point data

1) Add a new text column to the tables to hold the WKT definition

  01_ADD_WKT_COLUMN.SQL

2) Load data from the external table

  02_LOAD_SQLLOADER.{BAT,SH}
