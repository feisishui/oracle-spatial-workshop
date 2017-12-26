select *
from dba_java_policy
where grantee in ('SCOTT','MDSYS')
and type_name = 'java.io.FilePermission'
and enabled = 'ENABLED';
