set serveroutput on

accept verbose number default 0 prompt 'Enter verbose level (0,1,2) [0]: '

declare

  /*

  Copyright (c) Oracle Corporation All Right Reserved.

  NAME:
      is_spatial_used.sql

  LAST UPDATE
      03-FEB-2016

  DESCRIPTION:

      This script checks if Oracle Spatial is installed and used in a database

      The principle is to search for a footprint in the database that indicates if
      spatial is present and used. The script looks for the presence of tables
      that use spatial-specific data types, or tables that are specifically used
      by spatial features.

      The script is written for versions 11g and later (11.1, 11.2) but should work
      also for earlier versions (10.2).

      It needs to be run as SYSTEM or SYS. It does not modify anything in the
      database: it only queries dictionary views and some spatial/locator specific
      views.

      NOTES:

      1) The presence of data structures that are used by Oracle Spatial
      features does not mean that the customer is actually actively using those
      features. But it does give a good indication that they at least investigated
      and/or tried those features at some point.

      2) The absence of those structures does also NOT mean that the customer does not
      use spatial-specific functions. In 11gR2 and earlier, some functions (such as polygon
      overlays and spatial aggregations) are only allowed to be used with a spatial 
      licence, but are available also with the standard Locator feature. Starting with
      12c, this is no longer the case: those functions are available in Locator too.

  RESULTS

      At the end the script prints out a result like this:

      ========================================================================
      Checking Oracle Spatial usage
      ========================================================================
      Database: ORCL112
      Version: Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - Production
	    DBA_REGISTRY: SPATIAL key exists
      - version: 11.2.0.3.0
      - status: VALID
      - modified: 07-MAR-2012 22:30:47
      Date: 07-JUN-2012
      ========================================================================
      1.1. Checking the presence of the MDSYS schema
      -  the MDSYS schema is present
      1.2. Checking the presence of spatial-specific PL/SQL packages
      -  The following spatial-specific packages are present
      -  SDO_CSW_PROCESS
      -  SDO_GCDR
      -  SDO_GEOR
      -  SDO_LRS
      -  SDO_NET
      -  SDO_OLS
      -  SDO_PC_PKG
      -  SDO_SAM
      -  SDO_TIN_PKG
      -  SDO_TOPO
      -  SDO_WFS_PROCESS
      -  SDO_WS_PROCESS
      2.1. Checking the use of the locator or spatial-specific data types
      -  The following data types are used in one or more tables
      -  SDO_GEOMETRY is used by 464 tables in 22 schemas
      -  SDO_GEORASTER is used by 7 tables in 4 schemas
      -  SDO_PC is used by 4 tables in 2 schemas
      -  SDO_TIN is used by 1 tables in 1 schemas
      2.2. Checking the use of the spatial-specific metadata repositories
      -  ALL_SDO_GEOM_METADATA exists and is used (390 rows)
      -  ALL_SDO_INDEX_METADATA exists and is used (378 rows)
      -  ALL_INDEXES WHERE INDEX_TYPE = 'DOMAIN' AND ITYP_NAME = 'SPATIAL_INDEX'
      exists and is used (379 rows)
      -  ALL_SDO_NETWORK_METADATA exists and is used (7 rows)
      -  ALL_SDO_NETWORK_METADATA WHERE NETWORK = 'RDF' exists but is empty
      -  ALL_SDO_GEOR_SYSDATA exists and is used (7 rows)
      2.3. Checking the presence of tables used by the geocoder
      -  5 schemas contain geocoding tables
      2.4. Checking the presence of tables used by the route server
      -  15 schemas contain routing tables
      2.5. Checking the presence of any 3D spatial indexes
      -  1 3D spatial indexes exist
      2.6. Checking usage of spatial web services (WFS or CSW)
      -  MDSYS.WFS_FEATURETYPE$ exists and is used (1 rows)
      -  MDSYS.CSW_RECORD_TYPES$ exists but is empty
      ========================================================================
      Results
      ========================================================================
      Locator installed : Y
      Spatial installed : Y
      Locator used      : Y
      Spatial used      : Y
      -  Georaster    : Y
      -  Network      : Y
      -  Geocoder     : Y
      -  Router       : Y
      -  Topology     : N
      -  Point Clouds : Y
      -  3D           : Y
      -  TINs         : Y
      -  Web Services : Y
      -  Semantics    : N
      ========================================================================
      [6] (YES) Oracle Spatial is installed in this database and it is used
      ========================================================================

      There are several possible outcomes:

      1) If neither locator nor spatial are present

      Locator installed : N
      Locator used      : N
      Spatial installed : N
      Spatial used      : N

      2) If only locator is installed

      Locator installed : Y
      Locator used      : ?
      Spatial installed : N
      Spatial used      : N

      3) If spatial is installed but not used

      Spatial installed : Y
      Spatial used      : ? or N

      4) If spatial is installed and used

      Spatial installed : Y
      Spatial used      : Y
      - Georaster    : Y
      - Network      : Y
      - Geocoder     : Y
      - Router       : Y
      - Topology     : N
      - Point Clouds : Y
      - 3D           : Y
      - TINs         : N

      NOTES:

      - You may not see case (1) very often: it will be seen if the customer has
      created his/her databases in a fully custom way (not from a template) and
      explicitly disabled spatial.

      - Case (2) is for a customer that has done a default database creation:
      spatial will be present because the template we ship is preloaded with it.
      But is is clearly not used at all.

      - Case (3): For 11.2 and before this is a gray area The customer may be 
      using some features of Spatial that do not have a clear footprint - mostly 
      calling some functions in one of the PL/SQL packages that are also in Locator. 
      There is no real way to track that. My suspicion is more that they really are 
      not using Spatial, just Locator.
      
      From 12.1, there is no such ambiguity.

      - Case (4) clearly means that they are either using Spatial actively, or have
      looked at it. I include a finer breakdown of the spatial-specific features that
      they have used/tried. You can check the preceding messaqes that will tell you the
      number of suspicious tables and their size (number of rows).

  MODIFIED     (DD-MON-YYYY)  DESCRIPTION

  agodfrin		  03-Feb-2016   Since 12.1, SDO_GEOM is now fully in Locator
  agodfrin		  20-Mar-2013   SDO_LRS is actually also in Locator (not Spatial only)
  agodfrin		  20-Mar-2013   Add verbose option
  agodfrin		  20-Mar-2013   Show SDO key in DBA_REGISTRY
  agodfrin      10-Apr-2012   Clarify comments
  agodfrin      09-Apr-2012   Avoid counting tables owned by MDSYS proper
  agodfrin      29-Mar-2012   Check also the presence of spatial indexes
  agodfrin      26-Mar-2012   Provide simple and more accurate diagnostic
  agodfrin      26-Mar-2012   Show database version and registry data
  agodfrin      26-Mar-2012   Log full details of the checks and results
  agodfrin      22-Mar-2012   Rearranged comments, added history
  agodfrin      22-Mar-2012   Support for versions 10.2 and earlier
  agodfrin      22-Mar-2012   Return 'N' when a feature is detected as not used
  agodfrin      22-Mar-2012   Handle non-existent system tables and views
  agodfrin      23-Feb-2012   Created

  */

  table_does_not_exist EXCEPTION;
  PRAGMA EXCEPTION_INIT(table_does_not_exist, -00942);

  PREFIX varchar2(10) := '-  ';
  SEPARATOR varchar2(80) := '========================================================================';

  verbose               number := &verbose;
  
  locator_installed     char(1);
  locator_used          char(1);
  spatial_installed     char(1);
  spatial_used          char(1);
  spatial_georaster     char(1);
  spatial_network       char(1);
  spatial_geocoder      char(1);
  spatial_router        char(1);
  spatial_topology      char(1);
  spatial_point_clouds  char(1);
  spatial_3D            char(1);
  spatial_tins          char(1);
  spatial_ws            char(1);
  spatial_rdf           char(1);

  result_code           char(4);
  diagnostic            varchar2(256);

  counter               number;
  db_name               varchar2(30);
  db_version            varchar2(80);
  sdo_version           varchar2(80);
  sdo_status            varchar2(80);
  sdo_modified          varchar2(80);

  num_geom_tables       number := 0;
  num_geom_metadata     number := 0;
  num_index_metadata    number := 0;
  num_indexes           number := 0;

  procedure show_result is
  begin
    dbms_output.put_line (SEPARATOR);
    dbms_output.put_line ('Results');
    dbms_output.put_line (SEPARATOR);
    dbms_output.put_line ('Locator installed : ' || locator_installed);
    dbms_output.put_line ('Spatial installed : ' || spatial_installed);
    dbms_output.put_line ('Locator used      : ' || locator_used);
    dbms_output.put_line ('Spatial used      : ' || spatial_used);
    if spatial_used = 'Y' then
      dbms_output.put_line (PREFIX || 'Georaster    : ' || nvl(spatial_georaster, 'N'));
      dbms_output.put_line (PREFIX || 'Network      : ' || nvl(spatial_network, 'N'));
      dbms_output.put_line (PREFIX || 'Geocoder     : ' || nvl(spatial_geocoder, 'N'));
      dbms_output.put_line (PREFIX || 'Router       : ' || nvl(spatial_router, 'N'));
      dbms_output.put_line (PREFIX || 'Topology     : ' || nvl(spatial_topology, 'N'));
      dbms_output.put_line (PREFIX || 'Point Clouds : ' || nvl(spatial_point_clouds, 'N'));
      dbms_output.put_line (PREFIX || '3D           : ' || nvl(spatial_3d, 'N'));
      dbms_output.put_line (PREFIX || 'TINs         : ' || nvl(spatial_tins, 'N'));
      dbms_output.put_line (PREFIX || 'Web Services : ' || nvl(spatial_ws, 'N'));
      dbms_output.put_line (PREFIX || 'Semantics    : ' || nvl(spatial_rdf, 'N'));
    end if;

    /*
    ---- --------- --------- --------- --------- ------------------------------------------------------ -------
    case locator   spatial   locator   spatial
         installed installed used      used      diagnostic                                             spatial
    ---- --------- --------- --------- --------- ------------------------------------------------------ -------
    1    N         -         -         -         No traces (neither locator nor spatial are installed)  no
    2    Y         N         N         -         Locator only is installed but not used                 no
    3    Y         N         Y         -         Locator is installed and used                          no
    4    Y         Y         N         N         Spatial is installed but not used                      no
    5    Y         Y         Y         ?         Spatial is installed and may be used                   maybe
    6    Y         Y         Y         N         Spatial is installed and may be used                   no
    7    Y         Y         -         Y         Spatial is installed and used                          yes
    ---- --------- --------- --------- --------- ------------------------------------------------------ -------
    */

    dbms_output.put_line (SEPARATOR);
    result_code := locator_installed || spatial_installed || locator_used || spatial_used;
    case
      when result_code like 'N___' then diagnostic := '[1] (NO) Neither Oracle Locator nor Oracle Spatial are installed in this database';
      when result_code like 'YNN_' then diagnostic := '[2] (NO) Only Oracle Locator is installed in this database, but it is not used';
      when result_code like 'YNY_' then diagnostic := '[3] (NO) Only Oracle Locator is installed in this database,and it is used';
      when result_code like 'YYNN' then diagnostic := '[4] (NO) Oracle Spatial is installed in this database, but it is not used';
      when result_code like 'YYY?' then diagnostic := '[5] (?) Oracle Spatial is installed in this database, and it may be used';
      when result_code like 'YYYN' then diagnostic := '[6] (N) Oracle Spatial is installed in this database, but it is not used';
      when result_code like 'YY_Y' then diagnostic := '[7] (YES) Oracle Spatial is installed in this database and it is used';
      else diagnostic := 'No diagnostic';
    end case;
    dbms_output.put_line (diagnostic);
    dbms_output.put_line (SEPARATOR);

  end;

  function check_table (table_name varchar2) return number
  is
    counter number;
  begin
    begin
      execute immediate
        'SELECT COUNT(*) FROM '|| upper(table_name)
      into counter;
      if counter = 0 then
        dbms_output.put_line(PREFIX || upper(table_name) || ' exists but is empty');
      else
        dbms_output.put_line(PREFIX || upper(table_name) || ' exists and is used ('||counter||' rows)');
      end if;
    exception
      when table_does_not_exist then
        dbms_output.put_line(PREFIX || upper(table_name) || ' does not exist');
        counter := 0;
      when others then raise;
    end;
    return counter;
  end;

begin

  --------------------------------------------------------------------
  -- 0) Get context
  --------------------------------------------------------------------
  
  select name into db_name from v$database;
  select banner into db_version from v$version where rownum = 1;
  begin
    select version, status, modified 
    into sdo_version, sdo_status, sdo_modified
    from dba_registry
    where comp_id = 'SDO';
  exception
    when no_data_found then null;
    when others then raise;
  end;

  dbms_output.put_line (SEPARATOR);
  dbms_output.put_line ('Checking Oracle Spatial usage');
  dbms_output.put_line (SEPARATOR);
  dbms_output.put_line ('Database: ' || db_name);
  dbms_output.put_line ('Version: ' || db_version);
  if sdo_version is not null then
    dbms_output.put_line ('DBA_REGISTRY: SPATIAL key exists');
    dbms_output.put_line ('- version: ' || sdo_version);
    dbms_output.put_line ('- status: ' || sdo_status);
    dbms_output.put_line ('- modified: ' || sdo_modified);
  else
    dbms_output.put_line ('DBA_REGISTRY: SPATIAL key does not exist');
  end if;
  dbms_output.put_line ('Date: ' || to_char (current_date, 'DD-MON-YYYY'));
  dbms_output.put_line ('Verbose: ' || verbose);
  dbms_output.put_line (SEPARATOR);

  --------------------------------------------------------------------
  -- 1) Installation checks
  --------------------------------------------------------------------

  -- 1.1  Is there a user/schema called MDSYS ?

  dbms_output.put_line ('1.1. Checking the presence of the MDSYS schema');

  select count(*) into counter
  from dba_users
  where username = 'MDSYS';

  -- If not, stop: there are no traces of Locator or Spatial in that database
  if counter = 0 then
    dbms_output.put_line (PREFIX || 'the MDSYS schema does not exist');
    locator_installed := 'N';
    locator_used := 'N';
    spatial_installed := 'N';
    spatial_used := 'N';
    show_result;
    return;
  end if;
  dbms_output.put_line (PREFIX || 'the MDSYS schema is present');

  -- 1.2 Check for the presence of the spatial-specific packages in schema MDSYS
  -- NOTE: SDO_LRS is not a spatial-specific package (it also exists in Locator).
  
  dbms_output.put_line ('1.2. Checking the presence of spatial-specific PL/SQL packages');

  select count(*) into counter
  from dba_objects
  where owner = 'MDSYS'
  and object_type = 'PACKAGE'
  and object_name in (
    'SDO_GCDR',
    'SDO_GEOR',
    'SDO_NET' ,
    'SDO_TOPO',
    'SDO_SAM',
    'SDO_WS_PROCESS',
    'SDO_WFS_PROCESS',
    'SDO_CSW_PROCESS',
    'SDO_OLS',
    'SDO_TIN_PKG',
    'SDO_PC_PKG'
  );

  if counter = 0 then
    dbms_output.put_line (PREFIX || 'No spatial-specific packages found');
    locator_installed := 'Y';
    locator_used := '?';
    spatial_installed := 'N';
    spatial_used := 'N';
  else
    dbms_output.put_line (PREFIX || 'The following spatial-specific packages are present');
    for p in (
      select object_name
      from dba_objects
      where owner = 'MDSYS'
      and object_type = 'PACKAGE'
      and object_name in (
        'SDO_GCDR',
        'SDO_GEOR',
        'SDO_NET' ,
        'SDO_TOPO',
        'SDO_SAM',
        'SDO_WS_PROCESS',
        'SDO_WFS_PROCESS',
        'SDO_CSW_PROCESS',
        'SDO_OLS',
        'SDO_TIN_PKG',
        'SDO_PC_PKG'
      )
      order by object_name
    )
    loop
      dbms_output.put_line (PREFIX || ''||p.object_name);
    end loop;
    -- Now, we know that Oracle Spatial is installed in that database
    locator_installed := 'Y';
    spatial_installed := 'Y';
  end if;

  --------------------------------------------------------------------
  -- 2) Data checks
  --------------------------------------------------------------------

  -- 2.1  Is there any table that has a column of type SDO_GEOMETRY, SDO_GEORASTER, SDO_TOPO_GEOMETRY, SDO_PC or SDO_TIN
  -- (except of course tables owned by MDSYS)
  -- => If any of SDO_GEORASTER, SDO_TOPO_GEOMETRY, SDO_PC or SDO_TIN are present, then suspect spatial used (georaster, topology, point clouds, tins)
  -- => If SDO_GEOMETRY is used, then locator is used, and spatial may be used

  dbms_output.put_line ('2.1. Checking the use of the locator or spatial-specific data types');

  select count(*) into counter
  from dba_tab_cols
  where data_type in (
    'SDO_GEOMETRY',
    'SDO_GEORASTER',
    'SDO_TOPO_GEOMETRY',
    'SDO_PC',
    'SDO_TIN'
  )
  and owner <> 'MDSYS';

  -- If none of them is present, stop: this database uses no locator or spatial-specific data types
  if counter = 0 then
    dbms_output.put_line (PREFIX || 'No locator or spatial-specific data types used');
    locator_used := 'N';
    spatial_used := 'N';
    show_result;
    return;
  end if;

  dbms_output.put_line (PREFIX || 'The following data types are used in one or more tables');
  for d in (
    select data_type, count(*) num_tables, count (distinct owner) num_schemas
    from dba_tab_cols
    where data_type in (
      'SDO_GEOMETRY',
      'SDO_GEORASTER',
      'SDO_TOPO_GEOMETRY',
      'SDO_PC',
      'SDO_TIN'
    )
    and owner <> 'MDSYS'
    group by data_type
    order by data_type
  )
  loop
    case d.data_type
      when 'SDO_GEOMETRY'         then
        locator_used := 'Y';
        spatial_used := '?';
      when 'SDO_GEORASTER'        then
        spatial_used := 'Y';
        spatial_georaster := 'Y';
      when 'SDO_TOPO_GEOMETRY'    then
        spatial_used := 'Y';
        spatial_topology := 'Y';
      when 'SDO_PC'               then
        spatial_used := 'Y';
        spatial_point_clouds := 'Y';
      when 'SDO_TIN'              then
        spatial_used := 'Y';
        spatial_tins := 'Y';
    end case;
    dbms_output.put_line (PREFIX || d.data_type || ' is used by ' ||  d.num_tables || ' tables in ' || d.num_schemas || ' schemas');
    -- Show the schemas that use those types
    if verbose > 0 then
      for s in (
        select owner, count(*) num_tables
        from dba_tab_cols
        where data_type = d.data_type
        and owner <> 'MDSYS'
        group by owner
        order by owner
      )
      loop
        dbms_output.put_line (PREFIX || '  ' || s.owner || ' (' || s.num_tables || ' tables)' );
        -- Show the tables
        if verbose > 1 then
          for t in (
            select table_name
            from dba_tab_cols
            where data_type = d.data_type
            and owner = s.owner
            order by table_name
          )
          loop
            dbms_output.put_line (PREFIX || '    ' || t.table_name);
          end loop;
        end if;
      end loop;  
    end if;
  end loop;
  
  -- 2.2 Check the content of views ALL_SDO_GEOM_METADATA, ALL_SDO_NETWORK_METADATA, ALL_SDO_GEOR_SYSDATA
  -- => If any of ALL_SDO_NETWORK_METADATA, ALL_SDO_GEOR_SYSDATA is not empty, then suspect spatial used (network, georaster)

  dbms_output.put_line ('2.2. Checking the use of the spatial-specific metadata repositories');

  num_geom_metadata := check_table ('ALL_SDO_GEOM_METADATA');
  num_index_metadata := check_table ('ALL_SDO_INDEX_METADATA');
  num_indexes := check_table ('ALL_INDEXES WHERE INDEX_TYPE = ''DOMAIN'' AND ITYP_NAME = ''SPATIAL_INDEX''');
  if num_geom_metadata > 0 then
    locator_used := 'Y';
    spatial_used := '?';
  end if;

  if check_table ('ALL_SDO_NETWORK_METADATA') > 0 then
    spatial_used := 'Y';
    spatial_network := 'Y';
  end if;

  if check_table ('ALL_SDO_NETWORK_METADATA WHERE NETWORK = ''RDF''') > 0 then
    spatial_used := 'Y';
    spatial_rdf := 'Y';
  end if;

  if check_table ('ALL_SDO_GEOR_SYSDATA') > 0 then
    spatial_used := 'Y';
    spatial_georaster := 'Y';
  end if;

  -- 2.3 Check the presence of tables used by the geocoder
  -- => If a schema contains one or more of those tables, then suspect spatial used (geocoder)

  dbms_output.put_line ('2.3. Checking the presence of tables used by the geocoder');

  select count(distinct owner)
  into counter
  from dba_tables
  where table_name in ('GC_PARSER_PROFILES', 'GC_PARSER_PROFILEAFS', 'GC_COUNTRY_PROFILE')
  or table_name like'GC_AREA_%'
  or table_name like'GC_INTERSECTION_%'
  or table_name like'GC_POI_%'
  or table_name like'GC_POSTAL_CODE_%'
  or table_name like'GC_ROAD_SEGMENT_%'
  or table_name like'GC_ROAD_%';

  if counter > 0 then
    dbms_output.put_line (PREFIX || counter || ' schemas contain geocoding tables');
    spatial_used := 'Y';
    spatial_geocoder := 'Y';
  else
    dbms_output.put_line (PREFIX || 'geocoding tables are not used');
  end if;
  
  -- 2.4 Check the presence of tables used by the route server
  -- => If a schema contains one or more of those tables, then suspect spatial used (router)

  dbms_output.put_line ('2.4. Checking the presence of tables used by the route server');

  select count(*)
  into counter
  from dba_tables
  where table_name in ('EDGE', 'NODE', 'PARTITION');

  if counter > 0 then
    dbms_output.put_line (PREFIX || counter || ' schemas contain routing tables');
    spatial_used := 'Y';
    spatial_router := 'Y';
  else
    dbms_output.put_line (PREFIX || 'routing tables are not used');
  end if;

  -- 2.5 Check for the presence of any spatial index that is defined as 3D
  -- => If so, suspect spatial used (3D queries)

  dbms_output.put_line ('2.5. Checking the presence of any 3D spatial indexes');

  select count(*)
  into counter
  from dba_indexes
  where ityp_name = 'SPATIAL_INDEX'
  and upper(parameters) like '%SDO_INDX_DIMS=3%';

  if counter > 0 then
    dbms_output.put_line (PREFIX || counter || ' 3D spatial indexes exist');
    spatial_used := 'Y';
    spatial_3D := 'Y';
  else
    dbms_output.put_line (PREFIX || '3D spatial indexes are not used');
  end if;

  -- 2.6 Check the content of the WFS and CSW catalogs
  -- => If either contains data, then suspect spatial used (web services)

  dbms_output.put_line ('2.6. Checking usage of spatial web services (WFS or CSW)');

  if check_table ('mdsys.wfs_featuretype$')  > 0 then
    spatial_used := 'Y';
    spatial_ws := 'Y';
  end if;

  if check_table ('mdsys.csw_record_types$')  > 0 then
    spatial_used := 'Y';
    spatial_ws := 'Y';
  end if;

  -- Correct the result for 12.1. 
  if spatial_used = '?' and instr(db_version,'12c') > 0 then
     spatial_used := 'N';
  end if;
  
  --------------------------------------------------------------------
  -- Show final result
  --------------------------------------------------------------------

  show_result;
end;
/
