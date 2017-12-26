declare
   table_or_view_does_not_exist EXCEPTION;
   PRAGMA EXCEPTION_INIT (table_or_view_does_not_exist, -00942);
begin
  -- Range over topologies
  for t in (select distinct topology from user_sdo_topo_info) loop
    -- Range over features for that topology - in hierarchial order
    for f in (
      select *
      from user_sdo_topo_info
      where topology = t.topology
      and table_name is not null
      order by tg_layer_level desc)
    loop
      dbms_output.put_line ('Deregistering: '|| t.topology || ' ' || f.table_name || ' ' || f.column_name);
      begin
        -- Deregister the feature layer
        sdo_topo.delete_topo_geometry_layer (
          t.topology,
          f.table_name,
          f.column_name
        );
      exception
        -- Ignore the error if the table was already deregistered
        when table_or_view_does_not_exist then
          dbms_output.put_line ('Table '|| f.table_name || ' was already deregistered');
      end;
    end loop;
    -- Drop the topology
    dbms_output.put_line ('Dropping topology: '|| t.topology);
    sdo_topo.drop_topology (t.topology);
  end loop;
end;
/
