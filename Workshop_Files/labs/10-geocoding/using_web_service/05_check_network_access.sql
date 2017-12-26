-- (Run as SYSTEM or SYS)

-- List all privileges granted to user SCOTT
SELECT host, lower_port, upper_port, acl,
  DECODE (
    DBMS_NETWORK_ACL_ADMIN.CHECK_PRIVILEGE_ACLID(aclid, 'SCOTT', 'connect'),
    1, 'GRANTED', 0, 'DENIED', null
  ) privilege
FROM dba_network_acls
WHERE host IN (
  SELECT * 
  FROM
  TABLE(DBMS_NETWORK_ACL_UTILITY.DOMAINS('www.us.oracle.com'))
)
ORDER BY DBMS_NETWORK_ACL_UTILITY.DOMAIN_LEVEL(host) desc, lower_port, upper_port;
