==========================================================
Loading from WKT using external tables
==========================================================

1) Grant the necessary rights

  (Run as SYSTEM or SYS)

  01_GRANT_RIGHTS.SQL

  Grants the right to SCOTT to create any directory

2) Define the directory that contains the external table

  02_CREATE_DIRECTORY.SQL

3) Define the external table

  03_CREATE_EXTERNAL_TABLE_xxxxx.SQL

4) Load data from the external tables

  04_LOAD_DATA_xxxxxx.SQL

5) Drop the directory and external table

  05_CLEANUP.SQL
