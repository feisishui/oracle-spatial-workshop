-- (Run as SYSTEM)

-- Create the new role
CREATE ROLE ols_usr_role;

-- Grant access to the OpenLS system tables
GRANT SELECT ON mdsys.OpenLSServices TO ols_usr_role;
GRANT SELECT ON mdsys.OpenLS_Nodes TO ols_usr_role;
GRANT SELECT ON mdsys.OpenLS_XPaths TO ols_usr_role;
GRANT SELECT ON mdsys.OpenLS_Classifications TO ols_usr_role;
GRANT SELECT ON mdsys.OpenLS_Namespaces TO ols_usr_role;

-- Grant the new role to the anonymous web user
GRANT ols_usr_role TO spatialwsxmluser;

-- Also to any user that will call OpenLS services
GRANT ols_usr_role TO scott;
