=========================================================
Web Services - WFS
=========================================================

The scripts in this directory illustrates the use of the WFS service

CONFIGURATION
=============

1) Setting the capabilities template

You can set the template from PL/SQL (the template is hard coded in a text structure)

  01.1_SET_CAPABILITIES.SQL

Or you can set the template from an XML file (WFScapabilitiesTemplate.xml).

  01.2_SET_CAPABILITIES_FROM_FILE.SQL

This requires the definition of a "directory" in Oracle, so you must have the
CREATE ANY DIRECTORY right.


To view the current capabilities template

  01.3_SHOW_CAPABILITIES.SQL


2) Enable the schemas

  02_ENABLE_SCHEMAS.SQL

This script enables the schema SCOTT. Once completed you will be able to publish
selected tables that are owned by SCOTT.


3) Publish tables as WFS feature types.

There are multiple examples:

Publish table US_CITIES only

  03.1_PUBLISH_FEATURE_TYPE.SQL

Publish all tables in the schema SCOTT

NOTES: Those must be run AS SYS or SYSTEM!

  03.2_PROC_PUBLISH_FEATURE_TYPES_IN_SCHEMA.SQL
    = creates procedure PUBLISH_FEATURES_IN_SCHEMA() that will publish all
    spatial tables contained in a schema

  03.3_PUBLISH_FEATURE_TYPES_IN_SCHEMA.SQL
    = uses the procedure to publish all spatial tables in SCOTT

List the published feature types

  03.4_SHOW_PUBLISHED_FEATURE_TYPES.SQL


4) Register tables for editing

This registers a set of spatial tables (from SCOTT) for editing

  04.1_REGISTER_TABLES_FOR_EDITING.SQL

Show which tables are registered for editing

  04.2_SHOW_REGISTERED_TABLES.SQL

5) Notify the WFS

When a new table is published, the running WFS needs to be notified, so it can
update the capabilities response.

  05_NOTIFY_WFS.SQL

This script shows how to notify the WFS about feature type "UsCities".

Note that the publication scripts in step (3) already notified the WFS, so you
do not need to run this script.


6) Grant access rights

The anonymous user (SPATIALWSXMLUSER) needs to be given the proper rights on the
tables we published.

First, define a procedure GRANT_RIGHTS. This procedure looks for all published
tables and grants the SELECT right on those tables to the specified user.
If necessary it will also grant update rights.

  06.1_PROC_GRANT_RIGHTS.SQL

Use the GRANT_RIGHTS procedure to grant select and update rights to SPATIALWSXMLUSER

  06.2_GRANT_RIGHTS.SQL


7) Configure generic web services parameters

Update file WEB-INF/conf/WSConfig.xml with the following code

  07_WSCONFIG.XML

This sets the cache sync interval to 1 minute from the default of 10 seconds.


USAGE
=====

* The following HTML pages show various WFS requests.

wfs_requests_OC4J.html
wfs_requests_WLS.html

Use one or the other depending on your application server (OC4J or WebLogic).

* Monitor locks:

The following script illustrates how you can check the locks placed by the
WFS as a result of update requests.

SHOW_LOCKS.SQL


CLEANUP
=======

See the Cleanup directory to undo everything:

01_UNPUBLISH_ALL_FEATURE_TYPES.SQL
02-UNREGISTER-FEATURE-TABLES.SQL
03-DISABLE-USERS.SQL
04-REMOVE-CAPABILITIES.SQL

TOOLS
=====

See the Tools directory. It contains a package, WFS_TOOLS that provides procedures and
functions to make it easier to publish spatial tables:

PUBLISH_TABLE()
  Publishes a specific table. Also registers the table for updates (if requested),
  grants the proper rights to the anonymous user, and notifies the WFS
PUBLISH_SCHEMA()
  Publishes all spatial tables in a schema
UNPUBLISH_TABLE()
  Unpublishes a table (also revokes rights and unregisters)
UNPUBLISH_SCHEMA()
  Unpublishes all spatial tables in a schema
IS_PUBLISHED()
  Determines if a table is published
IS_REGISTERED_FOR_UPDATES()
  Determines if a table is registered for updates