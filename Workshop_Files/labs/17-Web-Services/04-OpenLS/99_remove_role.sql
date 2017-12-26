-- (Run as SYSTEM)

-- Revoke the role from the users
REVOKE ols_usr_role FROM spatialwsxmluser;
REVOKE ols_usr_role FROM scott;

-- Revoke access from the OpenLS system tables
REVOKE SELECT ON mdsys.OpenLSServices FROM ols_usr_role;
REVOKE SELECT ON mdsys.OpenLS_Nodes FROM ols_usr_role;
REVOKE SELECT ON mdsys.OpenLS_XPaths FROM ols_usr_role;
REVOKE SELECT ON mdsys.OpenLS_Classifications FROM ols_usr_role;
REVOKE SELECT ON mdsys.OpenLS_Namespaces FROM ols_usr_role;

-- Drop the  role
drop ROLE ols_usr_role;

