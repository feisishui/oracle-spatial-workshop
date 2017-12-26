create or replace package body sdo_validate as

DEFAULT_TOLERANCE   number := 0.0000005;
COMMIT_FREQUENCY    number := 100;

g_log_table_owner     varchar2(30);
g_log_table_name      varchar2(30);

------------------------------------------------------------------------------
-- CREATE_VALIDATION_LOG
------------------------------------------------------------------------------
procedure create_validation_log(p_log_table_name varchar2)
as
begin
  -- Save the name and ovner of the log table
  g_log_table_name := upper(p_log_table_name);
  g_log_table_owner := sys_context('userenv', 'CURRENT_SCHEMA');

  -- Create the table
  execute immediate
    'create table '||g_log_table_name || '(' ||
    '  owner           varchar2(30), ' ||
    '  table_name      varchar2(30), ' ||
    '  column_name     varchar2(30), ' ||
    '  obj_rowid       rowid,        ' ||
    '  geometry        sdo_geometry, ' ||
    '  tolerance       number,       ' ||
    '  metadata_exists char(1),      ' ||
    '  index_exists    char(1),      ' ||
    '  error_code      char(5),      ' ||
    '  error_message   varchar2(256),' ||
    '  error_context   varchar2(256) ' ||
    ')';
end;

------------------------------------------------------------------------------
-- USE_VALIDATION_LOG
------------------------------------------------------------------------------
procedure use_validation_log(p_log_table_name varchar2)
as
begin
  g_log_table_name := upper(p_log_table_name);
  g_log_table_owner := sys_context('userenv', 'CURRENT_SCHEMA');
end;

procedure use_validation_log(p_owner varchar2, p_log_table_name varchar2)
as
begin
  g_log_table_name := upper(p_log_table_name);
  g_log_table_owner := upper(p_owner);
end;

------------------------------------------------------------------------------
-- GET_VALIDATION_LOG
------------------------------------------------------------------------------
function get_validation_log return varchar2
as
begin
  if g_log_table_name is not null then
    return g_log_table_owner || '.' || g_log_table_name;
  else
    return NULL;
  end if;
end;

------------------------------------------------------------------------------
-- VALIDATE_ALL
------------------------------------------------------------------------------
procedure validate_all
as
begin
  -- Find all schemas that contain spatial tables
  for t in (
    select distinct owner
    from   all_tab_columns
    where  data_type = 'SDO_GEOMETRY'
    order by owner
  )
  loop
    -- Validate the tables in that schema
    validate_schema (t.owner);
  end loop;
end;

------------------------------------------------------------------------------
-- VALIDATE_SCHEMA
------------------------------------------------------------------------------
procedure validate_schema
as
begin
  -- Process current schemaS
  validate_schema (sys_context('userenv', 'CURRENT_SCHEMA'));
end;

procedure validate_schema (p_owner varchar2)
as
begin
  -- Find all spatial tables for the schema
  for t in (
    select table_name, column_name
    from   all_tab_columns
    where  data_type = 'SDO_GEOMETRY'
    and    owner = upper(p_owner)
    and    (owner, table_name) not in (
      select owner, view_name
      from   all_views
    )
    order by table_name, column_name
  )
  loop
    -- Validate the table
    validate_table (p_owner, t.table_name, t.column_name);
    commit;
  end loop;

end;

------------------------------------------------------------------------------
-- VALIDATE_TABLE
------------------------------------------------------------------------------
procedure validate_table (p_owner varchar2, p_table_name varchar2, p_column_name varchar2)
as
  geom_cursor         sys_refcursor;
  v_diminfo           sdo_dim_array;
  v_srid              number;
  v_tolerance         number;
  v_rowid             rowid;
  v_geometry          sdo_geometry;
  v_num_rows          number;
  v_num_errors        number;
  v_error_code        char(5);
  v_error_message     varchar2(256);
  v_error_context     varchar2(256);
  v_status            varchar2(256);
  v_metadata_exists   char(1);
  v_index_exists      char(1);
  v_table_exists      char(1);

begin
  -- Make sure we know the name of the log table
  if g_log_table_name is null then
    raise_application_error (-20001, 'log table not defined. Call SDO_VALIDATE.CREATE_VALIDATION_LOG() or SDO_VALIDATE.USE_VALIDATION_LOG()');
  end if;

  -- Avoid validating the log table itself!
  if p_owner = g_log_table_owner and p_table_name = g_log_table_name then
    return;
  end if;
  
  -- Make sure the table and column exits
  -- and that it is a table (not a view)
  begin
    select 'Y'
    into   v_table_exists
    from   all_tab_columns
    where  data_type = 'SDO_GEOMETRY'
    and    owner = upper(p_owner)
    and    table_name = upper(p_table_name)
    and    column_name = upper(p_column_name)
    and    (owner, table_name) not in (
      select owner, view_name
      from   all_views
    );
  exception
    when no_data_found then
      v_table_exists := 'N';
  end;
  if (v_table_exists = 'N') then
    raise_application_error (-20002, 'table '|| upper(p_owner) || '.' || upper(p_table_name)  || '.' || upper(p_column_name)|| ' does not exist');
  end if;

  -- Get spatial metadata for that table
  begin
    select diminfo, srid
    into v_diminfo, v_srid
    from all_sdo_geom_metadata
    where owner = upper(p_owner)
    and table_name = upper(p_table_name)
    and column_name = upper(p_column_name);
  exception
    when no_data_found then
      v_diminfo := null;
      v_srid := null;
  end;

  -- If no metadata, then use the default tolerance
  if v_diminfo is null then
    v_tolerance := DEFAULT_TOLERANCE;
    v_metadata_exists := 'N';
  else
    v_tolerance := v_diminfo(1).sdo_tolerance;
    v_metadata_exists := 'Y';
  end if;

  -- Check is a spatial index is present
  begin
    select 'Y'
    into v_index_exists
    from all_sdo_index_info
    where table_owner = upper(p_owner)
    and table_name = upper(p_table_name)
    and column_name = upper(p_column_name);
  exception
    when no_data_found then
      v_index_exists := 'N';
  end;

  -- Process the geometries
  v_num_rows := 0;
  v_num_errors := 0;
  open geom_cursor for
    'select rowid,' || p_column_name || ' from ' || p_owner || '.'  || p_table_name;
  loop

    v_status := NULL;

    -- Fetch the geometry
    fetch geom_cursor into v_rowid, v_geometry;
      exit when geom_cursor%notfound;
    v_num_rows := v_num_rows + 1;

    -- Validate the geometry
    begin
      if v_diminfo is null then
        v_status := sdo_geom.validate_geometry_with_context (v_geometry, v_tolerance);
      else
        v_status := sdo_geom.validate_geometry_with_context (v_geometry, v_diminfo);
      end if;
    exception
      when others then
        v_status := to_char(abs(sqlcode),'FM00000') || ' ' || substr(sqlerrm,1,250);
    end;

    -- Log the error (if any)
    if v_status <> 'TRUE' then
      -- Count the errors
      v_num_errors := v_num_errors + 1;
      -- Format the error message
      if length(v_status) >= 5 then
        v_error_code := substr(v_status, 1, 5);
        v_error_message := sqlerrm(-v_error_code);
        v_error_context := substr(v_status,7);
      else
        v_error_code := v_status;
        v_error_message := null;
        v_error_context := null;
      end if;
      -- Write the error
      execute immediate 
        'insert into ' || g_log_table_owner || '.' || g_log_table_name || '(' ||
          'owner,' ||
          'table_name,' ||
          'column_name,' ||
          'obj_rowid,' ||
          'geometry,' ||
          'tolerance,' ||
          'metadata_exists,' ||
          'index_exists,' ||
          'error_code,' ||
          'error_message,' ||
          'error_context' ||
        ') ' ||
        'values (' ||
          ':owner,' ||
          ':table_name,' ||
          ':column_name,' ||
          ':obj_rowid,' ||
          ':geometry,' ||
          ':tolerance,' ||
          ':metadata_exists,' ||
          ':index_exists,' ||
          ':error_code,' ||
          ':error_message,' ||
          ':error_context' ||
        ')'
      using
        upper(p_owner),
        upper(p_table_name),
        upper(p_column_name),
        v_rowid,
        v_geometry,
        v_tolerance,
        v_metadata_exists,
        v_index_exists,
        v_error_code,
        v_error_message,
        v_error_context;
    end if;

    -- Commit as necessary
    if mod(v_num_rows,COMMIT_FREQUENCY) = 0 then
      commit;
    end if;

  end loop;

end;

procedure validate_table (p_table_name varchar2, p_column_name varchar2)
as
begin
  validate_table (sys_context('userenv', 'CURRENT_SCHEMA'), p_table_name, p_column_name);
end;

end;
/
show error
