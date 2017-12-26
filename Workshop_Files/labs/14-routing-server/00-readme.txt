==========================================================
Routing Server
==========================================================

1) load routing data

01_IMPORT

Import file ROUTING_DATA.DMP. This will create and load the
following tables:

NODE                         59813 rows
EDGE                        149715 rows
SIGN_POST                      855 rows
PARTITION                        9 rows
SDO_ROUTER_DATA_VERSION          1 rows


2) Define the NDM network

02_DEFINE_NETWORK.SQL

This will define views over the EDGE, NODE and PARTITION tables, and define a network called ROUTE_SF. It uses the SDO_ROUTER_PARTITION.CREATE_ROUTER_NETWORK() procedure.

To run it, make sure to grant the CREATE ANY DIRECTORY and DROP ANY DIRECTORY rights to the executing user (SCOTT by defaut).

02_DEFINE_NETWORK_MANUAL.SQL

This is an alternate way of defining the network. It shows how you can create a network manually by creating the views and populating the network metadata yourself.


3) Deploy the route server application.

Deploy the routeserver.ear application into your application server.


4) Setup parameters for the route server

Update file web.xml with the connection details for your environment. You need to change parameter routeserver_schema_jdbc_connect_string to point to your database. For example:

jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=tcp)(HOST=127.0.0.1)(PORT=1521)))(CONNECT_DATA=(SID=orcl122)))</param-value>

You can leave the other settings unchanged

Copy files web.xml and weblogic.xml into the location you have deployed the routeserver application, i.e. xxx/applications/routeserver.ear/web.war/WEB-INF/

5) Restart the application server

This is required for the router to use the new parameters. Stopping and starting the routeserver application is not sufficient: the new parameters are only used when the complete server restarts.

6) Try some routes

Use one of the following HTML pages. They contain hard-coded URLs to either
your local OC4J server (port 8888) or your local web logic server (port 7001).

03_ROUTING_REQUESTS_LOCAL_GLASSFISH.HTML
03_ROUTING_REQUESTS_LOCAL_WLS.HTML


7) Try some routes on the elocation server

04_ROUTING_REQUESTS_ELOCATION.HTML


8) Re-partition the network

05_RE_PARTITION_NETWORK.SQL

This illustrates the use of the SDO_ROUTER_PARTITION.PARTITION_NETWORK() procedure.
The procedure will repartition the nodes and edges and recreate the partition
table. It will also redefine the network.


9) Restart the route server and try some routes again.
