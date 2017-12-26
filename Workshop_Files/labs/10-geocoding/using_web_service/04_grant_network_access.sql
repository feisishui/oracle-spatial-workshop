-- (Run as SYSTEM)

-- Create a new Access Control List (ACL) and grant access to the proper user
begin
  dbms_network_acl_admin.create_acl (
    acl         => 'sdo_gcdr_ws.xml',
    description => 'Controls access to external HTTP services',
    principal   => 'SCOTT',
    is_grant    => TRUE,
    privilege   => 'connect'
  );
end;
/

-- Allow unrestricted access to all hosts
begin
  dbms_network_acl_admin.assign_acl (
    acl         => 'sdo_gcdr_ws.xml',
    host        => '*'
  );
end;
/

commit;
