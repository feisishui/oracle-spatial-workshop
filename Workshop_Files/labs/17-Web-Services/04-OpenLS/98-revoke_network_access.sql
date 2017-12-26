-- (Run as SYSTEM)

-- Unassign the Access Control List from the Network Hosts
begin
  -- local host, port 8888
  dbms_network_acl_admin.unassign_acl (
    acl             => 'openls-services.xml',
    host            => 'localhost',
    lower_port      => 8888,
    upper_port      => 8888
  );
  -- elocation, port 80
  dbms_network_acl_admin.unassign_acl (
    acl             => 'openls-services.xml',
    host            => 'elocation.oracle.com',
    lower_port      => 80,
    upper_port      => 80
  );
end;
/

-- Drop the Access Control List (ACL)
begin
  dbms_network_acl_admin.drop_acl (
    acl             => 'openls-services.xml'
  );
end;
/

commit;
