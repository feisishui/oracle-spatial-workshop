==============================================================================
Title: Using a routing web service from the database
Author: Albert Godfrind
Last updated on: 29-JUL-2015
==============================================================================

1. Content
----------

readme.txt = this file.
types.sql = defines the SDO_ROUTE, SDO_ROUTE_SEGMENT and SDO_ROUTE_SEGMENTS
package_sdo_router_ws.sql = creates the SDO_ROUTER_WS package
package_sdo_routerr_ws_body.sql = creates the SDO_ROUTER_WS package body
sdo_router_ws_test.sql = a set of tests of the package functions
grant_nework_access.sql = enables access to external services
revoke_network_access.sal = disables that access

2. Description
--------------

Package SDO_ROUTER_WS offers a basic routing API. It formats the requests into XML, sends them to a routing web service using the UTL_HTTP package, then parses the response and returns the result as an SDO_ROUTE object.

The package offers the following functions:

* Get a route between two geographic locations:

FUNCTION GET_ROUTE RETURNS SDO_ROUTE
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 ORIGIN                         SDO_GEOMETRY            IN
 DESTINATION                    SDO_GEOMETRY            IN
 OPTIONS                        SDO_KEYWORDARRAY        IN     DEFAULT

* Get a route between two addresses. The last address line contains the name of the country.

FUNCTION GET_ROUTE RETURNS SDO_ROUTE
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 ORIGIN                         SDO_KEYWORDARRAY        IN
 DESTINATION                    SDO_KEYWORDARRAY        IN
 OPTIONS                        SDO_KEYWORDARRAY        IN     DEFAULT

* Get a route between two geocoded addresses. Each address is passed as the result from a geocode request.

FUNCTION GET_ROUTE RETURNS SDO_ROUTE
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 ORIGIN                         SDO_GEO_ADDR            IN
 DESTINATION                    SDO_GEO_ADDR            IN
 OPTIONS                        SDO_KEYWORDARRAY        IN     DEFAULT

The functions return the route as an SDO_ROUTE object:

SQL> desc sdo_route
 Name                                     Null?    Type
 ---------------------------------------- -------- ----------------------------
 DISTANCE                                          NUMBER
 TIME                                              NUMBER
 DIRECTIONS                                        SDO_ROUTE_SEGMENTS
 GEOMETRY                                          SDO_GEOMETRY

SQL> desc sdo_route_segments
 sdo_route_segments VARRAY(32768) OF SDO_ROUTE_SEGMENT
 Name                                     Null?    Type
 ---------------------------------------- -------- ----------------------------
 SEQUENCE                                          NUMBER
 INSTRUCTION                                       VARCHAR2(256)
 DISTANCE                                          NUMBER
 TIME                                              NUMBER


The package also contains the following procedure to set and get the URL of the routing service to use and the HTTP proxy to use"

PROCEDURE SET_URL
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 URL                            VARCHAR2                IN

PROCEDURE SET_PROXY
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 PROXY_HOST                     VARCHAR2                IN

FUNCTION GET_URL RETURNS VARCHAR2

FUNCTION GET_PROXY RETURNS VARCHAR2

The package is configured to use the Oracle elocation service by default (http://elocation.oracle.com/elocation/lbs).

3. Setup
--------

Since release 11g, access to external services from the database is disabled by default, and must be enabled via an ACL mechanism. Script GRANT_NETWORK_ACCESS enables that access. The script must be run by SYS or SYSTEM and performs the following:

-- Create a new Access Control List (ACL) and grant access to the proper user
begin
  dbms_network_acl_admin.create_acl (
    acl         => 'sdo_router_ws.xml',
    description => 'Controls access to external HTTP services',
    principal   => 'SCOTT',
    is_grant    => TRUE,
    privilege   => 'connect'
  );
end;
/

-- Allow unrestricted access to all hosts
begin
  dbms_network_acl_admin.assign_acl (
    acl         => 'sdo_router_ws.xml',
    host        => '*'
  );
end;
/
commit;

You need to change the first statement to use the proper principal (= user) that will invoke the sdo_router_ws package ("SCOTT" in the above example)

The second statement opens up access to all external hosts. If you want, you can specify a more restricted access to only the Oracle elocation service, like this:

begin
  dbms_network_acl_admin.assign_acl (
    acl         => 'sdo_router_ws.xml',
    host        => 'elocation.oracle.com',
    lower_port  => 80,
    upper_port  => 80
  );
end;
/

If access is not properly setup, routing requests fail with:

ORA-29273: HTTP request failed
ORA-06512: at "SYS.UTL_HTTP", line 1130
ORA-24247: network access denied by access control list (ACL)

The script REVOKE_NETWORK_ACCESS disables the network access by removing the ACL:

begin
  dbms_network_acl_admin.drop_acl (
    acl         => 'sdo_router_ws.xml'
  );
end;
/
commit;

4. Preparing to use the API
---------------------------

The first step is to setup the URL of the routing web service to use. Do this by invoking the SET_URL() procedure, like this:

SQL> exec sdo_router_ws.set_url('http://elocation.oracle.com/elocation/lbs');

The setting is saved in a global variable of the package and will be used by subsequent routing requests. By default the URL is set to use the Oracle eLocation service (http://elocation.oracle.com/elocation/lbs).

If the URL is not set, then all requests fail with:

ORA-20000: Routing service URL not set
ORA-06512: at "SCOTT.SDO_ROUTER_WS", line 28

The second step is (optionally) to set the name of the HTTP proxy to use, using the SET_PROXY() procedure. For example:

SQL> exec sdo_router_ws.set_proxy('emea-proxy.uk.oracle.com:80');

Note that no proxy is set by default.


5. Using the API: some examples
-------------------------------

-- Route between two geographical locations, time and distance only

select sdo_router_ws.get_route (
  sdo_geometry(2001,4326,sdo_point_type(-122.4014128, 37.7841193, null), null, null),
  sdo_geometry(2001,4326,sdo_point_type(-122.4183326, 37.8059999, null), null, null),
  sdo_keywordarray (
    'route_preference="fastest"',
    'distance_unit="km"',
    'time_unit="second"'
  )
) from dual;

-- Route between two geographical locations, with driving directions

select sdo_router_ws.get_route (
  sdo_geometry(2001,4326,sdo_point_type(-122.4014128, 37.7841193, null), null, null),
  sdo_geometry(2001,4326,sdo_point_type(-122.4183326, 37.8059999, null), null, null),
  sdo_keywordarray (
    'route_preference="fastest"',
    'return_driving_directions="true"',
    'distance_unit="km"',
    'time_unit="second"'
  )
) from dual;

-- Route between two addresses, time and distance only

select sdo_router_ws.get_route (
  sdo_keywordarray (
    '747 Howard Street',
    'San Francisco, CA',
    'US'
  ),
  sdo_keywordarray (
    '1300 Columbus',
    'San Francisco, CA',
    'US'
  ),
  sdo_keywordarray (
    'route_preference="fastest"',
    'distance_unit="km"',
    'time_unit="second"'
  )
) from dual;

-- Route between two geocoded addresses, time and distance only

select sdo_router_ws.get_route (
  sdo_gcdr.geocode(user, sdo_keywordarray ('747 Howard Street','San Francisco, CA'),'US','default'),
  sdo_gcdr.geocode(user, sdo_keywordarray ('1300 Columbus','San Francisco, CA'),'US','default'),
  sdo_keywordarray (
    'route_preference="fastest"',
    'distance_unit="km"',
    'time_unit="second"'
  )
) from dual;


6. Debugging
------------

Use the SET_TRACE() function to enable or disable tracing of the XML requests sent to the routing service as well as the XML response received.

Example:

SQL> exec sdo_router_ws.set_trace('true');
PL/SQL procedure successfully completed.

SQL> select sdo_router_ws.get_route (
  sdo_geometry(2001,4326,sdo_point_type(-122.4014128, 37.7841193, null), null, null),
  sdo_geometry(2001,4326,sdo_point_type(-122.4183326, 37.8059999, null), null, null),
  sdo_keywordarray (
    'route_preference="fastest"',
    'distance_unit="km"',
    'time_unit="second"'
  )
) from dual;

SDO_ROUTER_WS.GET_ROUTE(SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(-122.4014128,37.7
-------------------------------------------------------------------------------
SDO_ROUTE(3.77056299, 352.716736, NULL, NULL)

1 row selected.

% Invoking http://elocation.oracle.com/elocation/lbs
% Request:
<route_request route_preference="fastest" distance_unit="km" time_unit="second"
><start_location><input_location id="1" longitude="-122.4014128"
latitude="37.7841193"
srid="4326"/></start_location><end_location><input_location id="2"
longitude="-122.4183326" latitude="37.8059999"
srid="4326"/></end_location></route_request>
%
% resp.status_code=200
% resp.reason_phrase=OK
% resp.http_version=HTTP/1.1
% Response:
<?xml version="1.0" encoding="UTF-8" ?><!-- Oracle Routeserver version
12.2.0.0.1 (data version 12.1.0.2.0) --><route_response>   <route id="0"
step_count="0" distance="3.77056298828125" distance_unit="km"
time="352.71673583984375" time_unit="second" start_location="1"
end_location="2"/></route_response>
%
