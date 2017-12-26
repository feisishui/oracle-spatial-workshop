create or replace package body wfs_tools is

g_anonymous_user      varchar2(30)  := 'SPATIALWSXMLUSER';
--g_namespace_url       varchar2(256) := 'http://www.oracle.com/wfs';
--g_namespace_alias     varchar2(256) := 'oraclewfs';
g_namespace_url       varchar2(256) := 'http://www.myserver.com/scott';
g_namespace_alias     varchar2(256) := 'scottns';

-------------------------------------------------------------------------------
-- set_anonymous_user
-------------------------------------------------------------------------------
procedure set_anonymous_user (
  p_anonymous_user    varchar2
)
is
begin
  g_anonymous_user := p_anonymous_user;
end;

-------------------------------------------------------------------------------
-- set_namespace
-------------------------------------------------------------------------------
procedure set_namespace (
  p_namespace_url     varchar2,
  p_namespace_alias   varchar2
)
is
begin
  g_namespace_url := p_namespace_url;
  g_namespace_alias := p_namespace_alias;
end;

-------------------------------------------------------------------------------
-- publish_table
-------------------------------------------------------------------------------
procedure publish_table (
  p_owner               varchar2,
  p_table_name          varchar2,
  p_updatable           varchar2 := 'FALSE',
  p_geometry_column     varchar2 := NULL,
  p_feature_name        varchar2 := NULL,
  p_feature_desc        varchar2 := NULL,
  p_namespace_url       varchar2 := NULL,
  p_namespace_alias     varchar2 := NULL
)
is
  v_owner               varchar2(30);
  v_table_name          varchar2(30);
  v_featureDescriptor   CLOB;
  v_pkey                varchar2(512);
  v_feature_name        varchar2(512);
  v_geometry_column     varchar2(30);
  v_srid                number;
  v_srid_namespace      varchar2(10);
  v_namespace_url       varchar2(256);
  v_namespace_alias     varchar2(256);
  v_feature_desc        varchar2(256);
begin

  v_owner := upper(p_owner);
  v_table_name := upper(p_table_name);

  -- Get the name of the spatial column if not specified
  if p_geometry_column is null then
    begin
      select column_name
      into v_geometry_column
      from all_tab_cols
      where owner = v_owner
      and table_name = v_table_name
      and data_type = 'SDO_GEOMETRY';
    exception
      when NO_DATA_FOUND then
        raise_application_error (-20001, 'Table '|| v_owner || '.' || v_table_name || ' has no SDO_GEOMETRY column');
      when TOO_MANY_ROWS then
        raise_application_error (-20002, 'Table '|| v_owner || '.' || v_table_name || ' has multiple SDO_GEOMETRY columns');
    end;
  else
    v_geometry_column := p_geometry_column;
  end if;

  -- Get the SRID for the spatial column
  begin
    select srid
    into v_srid
    from all_sdo_geom_metadata
    where owner = v_owner
    and table_name like v_table_name
    and column_name = v_geometry_column;
  exception
    when NO_DATA_FOUND then
      raise_application_error (-20003, 'Unable to determine SRID for table '|| v_owner || '.' || v_table_name);
  end;

  -- Determine the name space for the SRID
  select case is_legacy when 'TRUE' then 'SDO' else 'EPSG' end
  into v_srid_namespace
  from sdo_coord_ref_system
  where srid = v_srid;

  -- Get the primary key column of the table
  -- Must be a single numeric column
  v_pkey := '';
  for k in (
    select cc.column_name
    from all_constraints c, all_cons_columns cc
    where cc.table_name = v_table_name
    and cc.owner = v_owner
    and c.constraint_type = 'P'
    and c.constraint_name = cc.constraint_name
    and c.owner = cc.owner
    order by cc.position
  )
  loop
     v_pkey := v_pkey || k.column_name || ';';
  end loop;
  v_pkey := substr (v_pkey,1, length(v_pkey)-1);

  if v_pkey is null then
    raise_application_error (-20004, 'Table '|| v_owner || '.' || v_table_name || ' has no acceptable primary key)');
  end if;

  -- Construct feature name if not specified
  if p_feature_name is null then
    -- Construct the feature type name from the name of the table in camel case
    v_feature_name := replace(initcap(v_table_name),'_','');
  else
    v_feature_name := p_feature_name;
  end if;

  -- Construct feature description if not specified
  if p_feature_desc is null then
    -- Construct the feature description from the name of the table
    v_feature_desc := 'Database table '||v_table_name;
  else
    v_feature_desc := p_feature_desc;
  end if;

  -- Determine namespace
  v_namespace_url := nvl (p_namespace_url, g_namespace_url);
  v_namespace_alias := nvl (p_namespace_alias, g_namespace_alias);

  -- Construct feature descriptor
  v_featureDescriptor :=
  '<?xml version="1.0" ?>' ||
  '  <FeatureType xmlns:' || v_namespace_alias || '="' || v_namespace_url || '" xmlns="http://www.opengis.net/wfs">' ||
  '    <Name>' || v_namespace_alias || ':' || v_feature_name || '</Name>' ||
  '    <Title>' || v_feature_desc || '</Title>' ||
  '    <SRS>' || v_srid_namespace ||':' || v_srid || '</SRS>' ||
  '</FeatureType>';

  -- Publish the type
  SDO_WFS_PROCESS.publishFeatureType(
    dataSrc                 => v_owner || '.' || v_table_name,
    ftNsUrl                 => v_namespace_url,
    ftName                  => v_feature_name,
    ftNsAlias               => v_namespace_alias ,
    featureDesc             => xmltype(v_featureDescriptor),
    schemaLocation          => null,
    pkeyCol                 => v_pkey,
    columnInfo              => MDSYS.StringList('GeometryCollectionType'),
    pSpatialCol             => v_geometry_column,
    featureMemberNs         => null,
    featureMemberName       => null,
    srsNs                   => null,
    srsNsAlias              => null
  );

  -- Register the table for updating
  if upper(p_updatable) = 'TRUE' then
    SDO_WFS_LOCK.registerFeatureTable(v_owner, v_table_name);
  end if;

  -- Tell the WFS about the new type
  SDO_WFS_PROCESS.InsertFtMDUpdated (v_namespace_url, v_feature_name, sysdate);

  -- Grant the proper privileges to the anonymous user
  execute immediate 'GRANT SELECT ON '||v_owner || '.' || v_table_name || ' to '|| g_anonymous_user;
  if upper(p_updatable) = 'TRUE' then
      execute immediate 'GRANT UPDATE,INSERT,DELETE ON '||v_owner || '.' || v_table_name || ' to '|| g_anonymous_user;
  end if;

  dbms_output.put_line ('Table '|| v_owner || '.' || v_table_name || '(' || v_geometry_column || ') published as '|| v_namespace_alias || ':' || v_feature_name || ' - Primary key=['||v_pkey||']');

end;

-------------------------------------------------------------------------------
-- publish_schema
-------------------------------------------------------------------------------
procedure publish_schema (
  p_owner               varchar2,
  p_updatable           varchar2 := 'FALSE',
  p_namespace_url       varchar2 := NULL,
  p_namespace_alias     varchar2 := NULL
)
is
begin
  for t in (
    select distinct table_name
    from all_tab_cols
    where owner = upper(p_owner)
    and data_type = 'SDO_GEOMETRY'
    order by table_name
  )
  loop
    begin
      publish_table (
        p_owner => p_owner,
        p_table_name => t.table_name,
        p_updatable => p_updatable,
        p_namespace_url => p_namespace_url,
        p_namespace_alias => p_namespace_alias
      );
    exception
      when others then
        dbms_output.put_line (sqlerrm);
    end;
  end loop;
end;

-------------------------------------------------------------------------------
-- unpublish_table
-------------------------------------------------------------------------------
procedure unpublish_table (
  p_owner               varchar2,
  p_table_name          varchar2
)
is
begin
  for f in (
    select featureTypeId, featureTypeName, dataPointer, namespaceURL
    from mdsys.WFS_FeatureType$
    where dataPointer = upper(p_owner)||'.'||upper(p_table_name)
  )
  loop

    -- Drop the feature type
    SDO_WFS_PROCESS.dropFeatureType(f.namespaceURL, f.featureTypeName);

    -- Also unregister the table
    if is_registered_for_updates (p_owner, p_table_name) = 'TRUE' then
      SDO_WFS_LOCK.unregisterFeatureTable(upper(p_owner), upper(p_table_name));
    end if;

    -- Remove privileges granted to the anonymous user
    execute immediate 'REVOKE ALL ON '|| p_owner || '.' || p_table_name || ' FROM '|| g_anonymous_user;

    dbms_output.put_line ('Table '|| f.dataPointer || ' unpublished');
  end loop;
end;

-------------------------------------------------------------------------------
-- unpublish_schema
-------------------------------------------------------------------------------
procedure unpublish_schema (
  p_owner               varchar2
)
is
  k number;
begin
  for t in (
    select datapointer from mdsys.wfs_featuretype$ where datapointer like upper(p_owner)||'.%'
  )
  loop
    k := instr(t.datapointer,'.');
    unpublish_table (
      p_owner => substr(t.datapointer,1,k-1),
      p_table_name => substr(t.datapointer,k+1)
    );
  end loop;
end;


-------------------------------------------------------------------------------
-- is_published
-------------------------------------------------------------------------------
function is_published (
  p_owner               varchar2,
  p_table_name          varchar2
)
return varchar2
is
  v_is_published        varchar2(10);
begin
  select case count_result when 0 then 'FALSE' else 'TRUE' end
  into v_is_published
  from (
    select count(*) count_result
    from mdsys.WFS_FeatureType$
    where dataPointer = upper(p_owner)||'.'||upper(p_table_name)
  );
  return v_is_published;
end;

-------------------------------------------------------------------------------
-- is_registered_for_updates
-------------------------------------------------------------------------------
function is_registered_for_updates (
  p_owner               varchar2,
  p_table_name          varchar2
)
return varchar2
is
  v_is_registered       varchar2(10);
begin
  -- Determine if the table has the locking triggers defined
  select case count_result when 0 then 'FALSE' else 'TRUE' end
  into v_is_registered
  from (
    select count(*) count_result
    from all_triggers
    where owner = upper(p_owner)
    and table_name = upper(p_table_name)
    and trigger_name in (
      upper(p_table_name) || '_UL',
      upper(p_table_name) || '_DL',
      upper(p_table_name) || '_CUL',
      upper(p_table_name) || '_CDL'
    )
  );
  return v_is_registered;
end;

end;
/
show errors
