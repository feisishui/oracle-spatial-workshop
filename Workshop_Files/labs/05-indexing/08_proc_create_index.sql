create or replace procedure create_index (
  table_name      varchar2,
  column_name     varchar2,
  srid            number := null,
  diminfo         sdo_dim_array := null
)
is
  v_diminfo       sdo_dim_array;
  v_srid          number;
  t varchar2(30);
begin
  -- Note on privileges.
  -- 1) To execute this procedure, the requesting user must have the CREATE TABLE and CREATE SEQUENCE rights
  -- Those must be granted directly to the user (not via a role!)
  -- For example: GRANT CREATE TABLE, CREATE SEQUENCE TO scott;
  -- 2) To invoke this procedure from another schema

  select table_name into t from user_tables where table_name = 'US_CITIES';
  dbms_output.put_line ('USER_TABLES:'||t);
  v_diminfo := diminfo;
  if v_diminfo is null then
    v_diminfo := sdo_dim_array (
      sdo_dim_element ('Longitude', -180, 180, 0.05),
      sdo_dim_element ('Latitude', -90, 90, 0.05)
    );
  end if;

  v_srid := srid;
  if v_srid is null then
    v_srid := 8307;
  end if;

  insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
  values (upper (table_name), upper(column_name), v_diminfo, v_srid);

  execute immediate 'create index '||table_name||'_SX on '||table_name|| ' (' || column_name || ') indextype is mdsys.spatial_index';

end;
/
show errors
