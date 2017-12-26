create or replace procedure enable_geocoding (
   p_owner varchar2,
   p_username varchar2
) AUTHID current_user AS
begin
  for t in (
    select table_name from all_tables where owner = upper(p_owner) and table_name like 'GC%'
  )
  loop
    dbms_output.put_line ('create or replace synonym mdsys.'||t.table_name|| ' for '||p_owner||'.'||t.table_name);
    execute immediate 'create or replace synonym mdsys.'||t.table_name|| ' for '||p_owner||'.'||t.table_name;
    dbms_output.put_line ('grant select on ' || p_owner||'.'||t.table_name|| ' to '||p_username);
    execute immediate 'grant select on ' || p_owner||'.'||t.table_name|| ' to '||p_username;
  end loop;
end;
/
show errors
