-- (Run as SYSTEM)

-- Drop the Access Control List (ACL)
begin
  dbms_network_acl_admin.drop_acl (
    acl             => 'sdo_gcdr_ws.xml'
  );
end;
/
commit;
