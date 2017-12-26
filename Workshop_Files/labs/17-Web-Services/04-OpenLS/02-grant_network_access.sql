-- (Run as SYSTEM)

-- Create a new Access Control List (ACL)
-- and grant access to the role OLS_USR_ROLE
begin
  dbms_network_acl_admin.create_acl (
    acl             => 'openls-services.xml',
    description     => 'Controls access to extrernal HTTP services by OpenLS services',
    principal       => 'OLS_USR_ROLE',
    is_grant        => TRUE,
    privilege       => 'connect'
  );
end;
/

-- Assign the Access Control List to Network Hosts
begin
  -- local host, port 8888
  dbms_network_acl_admin.assign_acl (
    acl             => 'openls-services.xml',
    host            => 'localhost',
    lower_port      => 8888,
    upper_port      => 8888
  );
  -- elocation, port 80
  dbms_network_acl_admin.assign_acl (
    acl             => 'openls-services.xml',
    host            => 'elocation.oracle.com',
    lower_port      => 80,
    upper_port      => 80
  );
end;
/
commit;
