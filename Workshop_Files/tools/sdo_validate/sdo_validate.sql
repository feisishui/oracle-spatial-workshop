create or replace package sdo_validate authid current_user as

/*

The procedures in this package help validating geometries in spatial tables

You can validate a single table (VALIDATE_TABLE), all tables in a schema
(VALIDATE_SCHEMA) or all tables in all schemas (VALIDATE_ALL).

The errors are written in a "log" table, with the following structure:

  owner           varchar2(30)   Name of the owner of the spatial table
  table_name      varchar2(30)   Name of the spatial table
  column_name     varchar2(30)   Name of the spatial column
  obj_rowid       rowid          ROWID of the row that contains the geometry
  geometry        sdo_geometry   A copy of the geometry
  tolerance       number         Tolerance used for the validation
  metadata_exists char(1)        Whether geometry metadata exists ('Y' or 'N')
  index_exists    char(1)        Whether a spatial index exists ('Y' or 'N')
  error_code      char(5)        The error code
  error_message   varchar2(256)  Error message
  error_context   varchar2(256)  Error context

You can create the log table manually, or call procedure CREATE_VALIDATION_LOG.

Before you can use any of the VALIDATION procedures, you must specify the name
of the validation log table to use, by calling USE_VALIDATION_TABLE.

The steps for using the validation functions are the following:

1) If necessary, create the validation log table:

   EXEC SDO_VALIDATE.CREATE_VALIDATION_LOG(<log_table_name>)

   If you do not specify any name, the table will be called GEOMETRY_ERRORS

2) Specify the name of the validation log table to use for the validation calls

   EXEC SDO_VALIDATE.USE_VALIDATION_LOG (<owner>, <log_table_name>)
   or
   EXEC SDO_VALIDATE.USE_VALIDATION_LOG (<log_table_name>) if the table is in the current schema.

3) To validate all tables in all schemas

   EXEC SDO_VALIDATE.VALIDATE_ALL()

   This will validate all spatial tables (i.e. tables that contain one or more columns of type
   SDO_GEOMETRY), in all tables that are accessible by the executing user.

4) To validate all tables in a schema

   EXEC SDO_VALIDATE.VALIDATE_SCHEMA(<schema_name>)

   If no schema is specified, then the function validates the spatial tables in the current schema.

   You can also "switch" to the schema to be validated, then validate that schema:

   ALTER SESSION SET CURRENT_SCHEMA=USER2;
   EXEC SDO_VALIDATE.VALIDATE_SCHEMA();

   When validating another schema, only those tables on which the executing user has the SELECT
   privilege will be processed.

5) To validate a single table

   EXEC SDO_VALIDATE.VALIDATE_TABLE(<schema_name>, <table_name>, <column_name>)

   If the table is in the current schema, then you can ommit the schema name.

   EXEC SDO_VALIDATE.VALIDATE_TABLE(<table_name>, <column_name>)

USAGE NOTES

1) NULL geometries are reported as errors. For those geometries, the validation log contains the following:
   - ERROR_CODE and ERROR_CONTEXT are null
   - ERROR_MESSAGE contains the string "NULL".

2) When spatial metadata (USER_SDO_GEOM_METADATA) then it is used for validation, and geometries
   that fall outside the bounds will be reported as errors. If no metadata exists, then this check
   is not performed, and we will use a default tolerance setting of 0.0000005.


USING THE ERROR LOG:

1) Summary of errors per table

SQL> select table_name, count(*) from geometry_errors group by rollup(table_name);

TABLE_NAME                       COUNT(*)
------------------------------ ----------
COMANDANCIAS                           75
IDRBAC3                               546
PASCOLI_WGS                          4039
POINTSZ                              5292
POINT_TEST                              2
REGIONS                                23
SEAS_TEST_BDW_01_NOFIX                  5
TOWERSZ                                97
                                    10079

9 rows selected.

2) Summary of errors per error code

SQL> select error_code, count(*) from geometry_errors group by rollup(error_code);

ERROR   COUNT(*)
----- ----------
13349       4664
13351          1
13356         22
13367          1
54668       5389
NULL           2
           10079

3) Summary of errors per table and error code

SQL> select table_name, error_code, count(*)
  2  from geometry_errors
  3  group by error_code, table_name
  4  order by table_name, error_code;

TABLE_NAME                     ERROR   COUNT(*)
------------------------------ ----- ----------
COMANDANCIAS                   13349         75
IDRBAC3                        13349        546
PASCOLI_WGS                    13349       4039
POINTSZ                        54668       5292
POINT_TEST                     NULL           2
REGIONS                        13356         22
REGIONS                        13367          1
SEAS_TEST_BDW_01_NOFIX         13349          4
SEAS_TEST_BDW_01_NOFIX         13351          1
TOWERSZ                        54668         97

10 rows selected.
*/

procedure create_validation_log(p_log_table_name varchar2 := 'GEOMETRY_ERRORS');
/*
  NAME:
    CREATE_VALIDATION_LOG

  DESCRIPTION:
    This procedure creates the validation log.

 ARGUMENTS:
    p_log_table_name:
      the name of the validation log table. If no name is given, then the table will be called GEOMETRY_ERRORS.

  RETURNS
    none
*/

procedure use_validation_log(p_log_table_name varchar2);
procedure use_validation_log(p_owner varchar2, p_log_table_name varchar2);
/*
  NAME:
    USE_VALIDATION_LOG

  DESCRIPTION:
    Use this procedure to specify the name of the validation log to us for
    all subsequent calls to the VALIDATE_xxx functions..

 ARGUMENTS:
    p_owner
      the name of the owner of the validation log table. If not specified, then the table is assumed to be
      in the current schema.
    p_log_table_name:
      the name of the validation log table.

  RETURNS
    none
*/

function get_validation_log return varchar2;
/*
  NAME:
    GET_VALIDATION_LOG

  DESCRIPTION:
    Use this procedure to find out the name of the current validation log table (as set by USE_VALIDATION_LOG)

 ARGUMENTS:
    p_owner
      the name of the owner of the validation log table. If not specified, then the table is assumed to be
      in the current schema.
    p_log_table_name:
      the name of the validation log table.

  RETURNS
    none
*/

procedure validate_all;
/*
  NAME:
    VALIDATE_ALL

  DESCRIPTION:
    This procedure finds and validates all the spatial tables in all schemas, that are accessible to the current
    user (i.e. the current user must have SELECT access to those tables).
    A spatial table is a table that contains one or more columns of type SDO_GEOMETRY
    .

 ARGUMENTS:
    none

  RETURNS
    none
*/

procedure validate_schema;
procedure validate_schema (p_owner varchar2);
/*
  NAME:
    VALIDATE_SCHEMA

  DESCRIPTION:
    This procedure finds and validates all the spatial tables in a specified schema. The current user must have
    SELECT access to those tables.
    If no schema is specified, then the tables in the current schema are validated.

 ARGUMENTS:
    p_owner
      the name of the owner of the spatial tables to validate.. If not specified, then the table in the current
      schema are validated.

  RETURNS
    none
*/

procedure validate_table (p_owner varchar2, p_table_name varchar2, p_column_name varchar2);
procedure validate_table (p_table_name varchar2, p_column_name varchar2);
/*
  NAME:
    VALIDATE_TABLE

  DESCRIPTION:
    This procedure validates all geometries in a spatial table. .

 ARGUMENTS:
    p_owner
      the name of the owner of the table to validate. If not specified, then the table is assumed to be
      in the current schema.
    p_table_name:
      the name of the spatial table.to validate
    p_column_name
      the name of the spatial column to validate

  RETURNS
    none
*/


end;
/
show error
