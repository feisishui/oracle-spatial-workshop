==========================================================
Loading from external tables
==========================================================

Note that this process is only possible for point data

1) Grant the necessary rights

  (Run as SYSTEM or SYS)

  01_GRANT_RIGHTS.SQL

  Grants the right to SCOTT to create any directory

2) Define the directory that contains the external table

  02_CREATE_DIRECTORY.SQL

3) Define the external table

  03_CREATE_EXTERNAL_TABLE.SQL

4) Load data from the external table

  04_LOAD_DATA.SQL

5) Drop the directory and existing table

  05_CLEANUP.SQL
