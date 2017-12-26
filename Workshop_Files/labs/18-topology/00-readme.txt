==========================================================
Topology
==========================================================

IMPORTANT NOTE

Since 10gR2, the definition of the RESOURCE and CONNECT roles have changed.
In particular, they do no longer grant the CREATE VIEW privilege. This
privilege is required by the topology functions.

You must grant this privilege manually:

CONNECT SYSTEM
GRANT CREATE VIEW TO SCOTT;

1) Create topology LAND_USE

  01-CREATE-TOPOLOGY.SQL

2) Create feature tables

  02-CREATE-FEATURE-TABLES.SQL

  This creates the following tables:
  US_COUNTIES_TOPO
  US_CITIES_TOPO

3) Create feature table US_STATES_TOPO

  03-CREATE-FEATURE-TABLES-HIERARCHICAL.SQL

4) Topologically structure geometry tables

  04.1-LOAD-COUNTIES.SQL
  04.2-LOAD-CITIES.SQL
  04.3-LOAD-INTERSTATES.SQL

  Note: those scripts only load a subset if the data for a few states.
  To load all counties, cities and interstates remove the WHERE clause from the scrips.
  The processing time to load all data can be long:
    US_COUNTIES     00:10:10.24
    US_CITIES       00:00:24.04
    US_INTERSTATES  00:10:57.98

  To speed up the process, you can apply it to a subset of the counties and interstates.
  Just modify the above scripts to limit the data to process.
  
5) Topologically structure US States

  05-LOAD-STATES.SQL

6) Update topology metadata

  06-INITIALIZE_METADATA.SQL

7) Validate topology

  07-VALIDATE-TOPOLOGY.SQL

8) Perform topology and spatial queries

  08-1-TOPO-QUERIES.SQL
  08-2-SPATIAL-QUERIES.SQL
  08-3-TOPO-SPATIAL-QUERIES.SQL
  08-4-SPATIAL-TOPO-QUERIES.SQL

To remove all topology structures at any time, us either of the following
scripts:

  99-CLEANUP.SQL
  99-CLEANUP-ALL.SQL
