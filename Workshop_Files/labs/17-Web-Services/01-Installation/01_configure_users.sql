-- Run as SYSTEM or SYS
connect system

-- --------------------------------------------------------
-- Setup the administration accounts
-- --------------------------------------------------------

-- Unlock the administration accounts
alter user mdsys account unlock;
alter user spatial_csw_admin_usr account unlock;
alter user spatial_wfs_admin_usr account unlock;

-- Set passwords for the administration accounts
alter user mdsys identified by mdsys;
alter user spatial_csw_admin_usr identified by spatial_csw_admin_usr;
alter user spatial_wfs_admin_usr identified by spatial_wfs_admin_usr;

-- --------------------------------------------------------
-- Setup the SPATIALWSXMLUSER account used for anonymous requests
-- --------------------------------------------------------

-- Create the account
create user spatialwsxmluser identified by some_password;
-- Must be able to connect through this account
grant create session to spatialwsxmluser;
-- Account uses proxy authentication via MDSYS
alter user spatialwsxmluser grant connect through mdsys;
-- Make sure the account can be used for WFS and CSW requests
grant wfs_usr_role to spatialwsxmluser;
grant csw_usr_role to spatialwsxmluser;
-- List users that are authorised to connect via proxy users
select * from proxy_users;

-- --------------------------------------------------------
-- Remove the security from the roles
-- --------------------------------------------------------

alter role wfs_usr_role not identified;
alter role csw_usr_role not identified;
alter role spatial_wfs_admin not identified;
alter role spatial_csw_admin not identified;

disconnect;
