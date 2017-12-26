create or replace procedure publish_features_in_schema (
  p_owner               varchar2,
  p_namespace_url       varchar2,
  p_namespace_alias     varchar2,
  p_tablename_pattern   varchar2 default '%'
) AUTHID current_user
is
  featureDescriptorXML  CLOB;
  num_features          number;
  num_features_nopk     number;
  pkey                  varchar2(512);
  type_name             varchar2(512);
begin

  -- Range over all spatial tables in a schema
  num_features := 0;
  num_features_nopk := 0;
  for t in (
    select g.owner, g.table_name, g.column_name, g.srid
    from all_sdo_geom_metadata g, all_tab_cols c
    where g.owner = p_owner
    and g.table_name like P_tablename_pattern
    and c.owner = g.owner
    and c.table_name = g.table_name
    and c.column_name = g.column_name
    and c.data_type = 'SDO_GEOMETRY'
    order by g.table_name
  )
  loop

    num_features := num_features + 1;

    -- Get the primary key column
    pkey := '';
    for k in (
      select cc.column_name
      from all_constraints c, all_cons_columns cc
      where cc.table_name = t.table_name
      and cc.owner = t.owner
      and c.constraint_type = 'P'
      and c.constraint_name = cc.constraint_name
      and c.owner = cc.owner
      order by cc.position
    )
    loop
       pkey := pkey || k.column_name || ',';
    end loop;
    pkey := substr (pkey,1, length(pkey)-1);

    if pkey is null then
      dbms_output.put_line ('*** Table '|| t.owner || '.' || t.table_name || ' - not published (missing primary key)');
      num_features_nopk := num_features_nopk + 1;
    else
      -- Construct the name of the type in camel case
      type_name := replace(initcap(t.table_name),'_','');

      -- First unpublish the feature
      begin
        SDO_WFS_PROCESS.dropFeatureType(p_namespace_url, type_name);
      exception
        when NO_DATA_FOUND then
          null;
        when others then
          raise;
      end;

      -- Construct feature descriptor
      featureDescriptorXML :=
      '<?xml version="1.0" ?>' ||
      '  <FeatureType xmlns:' || p_namespace_alias || '="' || p_namespace_url || '" xmlns="http://www.opengis.net/wfs">' ||
      '    <Name> ' || p_namespace_alias || ':' || type_name || '</Name>' ||
      '    <Title>Database Table ' || t.table_name || '</Title>' ||
      '    <SRS>SDO:' || t.srid || '</SRS>' ||
      '</FeatureType>';

      -- Publish the type
      SDO_WFS_PROCESS.publishFeatureType(
        dataSrc                 => t.owner || '.' || t.table_name,
        ftNsUrl                 => p_namespace_url,
        ftName                  => type_name,
        ftNsAlias               => p_namespace_alias ,
        featureDesc             => xmltype(featureDescriptorXML),
        schemaLocation          => null,
        pkeyCol                 => pkey,
        columnInfo              => MDSYS.StringList('GeometryCollectionType'),
        pSpatialCol             => t.column_name,
        featureMemberNs         => null,
        featureMemberName       => null,
        srsNs                   => null,
        srsNsAlias              => null
      );

      dbms_output.put_line ('Table '|| t.owner || '.' || t.table_name || ' published as '|| type_name || ' - Primary key=['||pkey||']');

      -- Tell the WFS about the new type
      SDO_WFS_PROCESS.InsertFtMDUpdated (p_namespace_url,type_name, sysdate);

    end if;

  end loop;

  commit;
  dbms_output.put_line (num_features || ' tables found');
  dbms_output.put_line ((num_features - num_features_nopk) || ' published (with primary key)');
  dbms_output.put_line (num_features_nopk || ' not published (without primary key)');
end;
/
show errors
