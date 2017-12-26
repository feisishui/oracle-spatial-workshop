col principal for a30
col host for a30
col acl for a30
select a.object_value acl_xml
from   resource_view r, xdb.xdb$acl a
where  ref(a) = extractvalue(r.res, '/Resource/XMLRef')
and    equals_path(r.res, '/sys/acls/openls-services.xml') = 1;

select principal, PRIVILEGE, is_grant
from   dba_network_acl_privileges
where  ACL='/sys/acls/openls-services.xml';

select host, lower_port, upper_port
from   dba_network_acls
where  ACL='/sys/acls/openls-services.xml';

select *
from (
  select a.host, a.lower_port, a.upper_port, a.acl,
         u.username,
         decode(
           dbms_network_acl_admin.check_privilege_aclid(
             a.aclid,  u.username, 'connect'
           ),
           1, 'GRANTED',
           0, 'DENIED',
           null, 'DENIED'
         ) privilege
  from   dba_network_acls a,
         dba_users u
)
where privilege = 'GRANTED'
order  by host, username;
