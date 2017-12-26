=========================================================
Web Services - Installation
=========================================================

1) Install the web services application

Deploy the sdows.ear application into your application server.

2) Configure the database users

01_CONFIGURE_USERS.SQL

This script unlocks the MDSYS, SPATIAL_CSW_ADMIN_USR and SPATIAL_WFS_ADMIN_USR accounts.
It also creates the SPATIALWSXMLUSER account (used for anonymous access to the web services).

3) Setup the datasource definitions.

For WebLogic you must define the data sources manually using the administration console.

4) Configure generic web services parameters

Update file WEB-INF/conf/WSConfig.xml with the following code

02_WSCONFIG.XML
