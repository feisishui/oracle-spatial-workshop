create or replace procedure grant_rights (
  p_username          varchar2,
  p_allow_updates     varchar2 default 'FALSE'
) AUTHID current_user
is
  grant_stmt varchar2(256);
begin
  for f in (
    select featuretypeid,
           substr(dataPointer, 1, instr(dataPointer,'.')-1) owner,
           substr(dataPointer, instr(dataPointer,'.')+1) table_name,
           namespacePrefix || ':' || featureTypeName featureTypeName
    from   mdsys.WFS_FeatureType$
    order  by owner, table_name
  )
  loop
    grant_stmt := 'GRANT SELECT';
    if upper(p_allow_updates) = 'TRUE' then
      grant_stmt := grant_stmt || ', INSERT, UPDATE, DELETE';
    end if;
    grant_stmt := grant_stmt || ' ON ' || f.owner || '.' || f.table_name || ' TO ' || p_username;
    dbms_output.put_line (grant_stmt);
    execute immediate grant_stmt;
  end loop;
end;
/
