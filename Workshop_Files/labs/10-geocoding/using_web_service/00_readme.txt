==============================================================================
Title: Using a geocoding web service from the database
Author: Albert Godfrind
Last updated on: 10–APR-2016
==============================================================================

1. Content
----------

readme.txt = this file.
package_sdo_gcdr_ws.sql = creates the SDO_GCDR_WS package
package_sdo_gcdr_ws_body.sql = creates the SDO_GCDR_WS package body
sdo_gcdr_ws_test.sql = a set of tests of the package functions
grant_nework_access.sql = enables access to external services
revoke_network_access.sal = disables that access

2. Description
--------------

Package SDO_GCDR_WS offers a basic geocoding API similar to that of the SDO_GCDR package. It formats the requests into XML, sends them to a geocoding web service using the UTL_HTTP package, then parses the result.

The package offers the following functions. They are identical to those of the SDO_GCDR package, except they do not include any username. Note also that in the

FUNCTION GEOCODE RETURNS SDO_GEO_ADDR
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 ADDR_LINES                     SDO_KEYWORDARRAY        IN
 COUNTRY                        VARCHAR2                IN
 MATCH_MODE                     VARCHAR2                IN

FUNCTION GEOCODE_ALL RETURNS SDO_ADDR_ARRAY
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 ADDR_LINES                     SDO_KEYWORDARRAY        IN
 COUNTRY                        VARCHAR2                IN
 MATCH_MODE                     VARCHAR2                IN

FUNCTION GEOCODE_ADDR RETURNS SDO_GEO_ADDR
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 ADDRESS                        SDO_GEO_ADDR            IN

FUNCTION GEOCODE_ADDR_ALL RETURNS SDO_ADDR_ARRAY
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 ADDRESS                        SDO_GEO_ADDR            IN

FUNCTION GEOCODE_AS_GEOMETRY RETURNS SDO_GEOMETRY
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 ADDR_LINES                     SDO_KEYWORDARRAY        IN
 COUNTRY                        VARCHAR2                IN

FUNCTION REVERSE_GEOCODE RETURNS SDO_GEO_ADDR
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 LOCATION                       SDO_GEOMETRY            IN
 COUNTRY                        VARCHAR2                IN

FUNCTION REVERSE_GEOCODE RETURNS SDO_GEO_ADDR
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 LONGITUDE                      NUMBER                  IN
 LATITUDE                       NUMBER                  IN
 COUNTRY                        VARCHAR2                IN

FUNCTION REVERSE_GEOCODE RETURNS SDO_GEO_ADDR
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 LONGITUDE                      NUMBER                  IN
 LATITUDE                       NUMBER                  IN
 SRID                           NUMBER                  IN
 COUNTRY                        VARCHAR2                IN

The package also contains the following procedure to set and get the URL of the geocoding service to use and the HTTP proxy to use"

PROCEDURE SET_URL
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 URL                            VARCHAR2                IN

FUNCTION GET_URL RETURNS VARCHAR2

PROCEDURE SET_PROXY
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 PROXY_HOST                     VARCHAR2                IN

FUNCTION GET_PROXY RETURNS VARCHAR2

Finally, you can set and get the language to be used for reverse geocoding calls:

PROCEDURE SET_LANGUAGE
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 LANGUAGE_                      VARCHAR2                IN

FUNCTION GET_LANGUAGE RETURNS VARCHAR2


The package is configured to use the Oracle elocation service by default (http://elocation.oracle.com/elocation/lbs).

3. Setup
--------

Since release 11g, access to external services from the database is disabled by default, and must be enabled via an ACL mechanism. Script GRANT_NETWORK_ACCESS enables that access. The script must be run by SYS or SYSTEM and performs the following:

-- Create a new Access Control List (ACL) and grant access to the proper user
begin
  dbms_network_acl_admin.create_acl (
    acl         => 'sdo_gcdr_ws.xml',
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
    acl         => 'sdo_gcdr_ws.xml',
    host        => '*'
  );
end;
/
commit;

You need to change the first statement to use the proper principal (= user) that will invoke the SDO_GCDR_WS package ("SCOTT" in the above example)

The second statement opens up access to all external hosts. If you want, you can specify a more restricted access to only the Oracle elocation service, like this:

begin
  dbms_network_acl_admin.assign_acl (
    acl         => 'sdo_gcdr_ws.xml',
    host        => 'elocation.oracle.com',
    lower_port  => 80,
    upper_port  => 80
  );
end;
/

If access is not properly setup, geocoding requests fail with:

ORA-29273: HTTP request failed
ORA-06512: at "SYS.UTL_HTTP", line 1130
ORA-24247: network access denied by access control list (ACL)

The script REVOKE_NETWORK_ACCESS disables the network access by removing the ACL:

begin
  dbms_network_acl_admin.drop_acl (
    acl         => 'sdo_gcdr_ws.xml'
  );
end;
/
commit;

4. Preparing to use the API
---------------------------

The first step is to setup the URL of the geocoding web service to use. Do this by invoking the SET_URL() procedure, like this:

SQL> exec sdo_gcdr_ws.set_url('http://elocation.oracle.com/elocation/lbs');

The setting is saved in a global variable of the package and will be used by subsequent geocoding requests. By default the URL is set to use the Oracle eLocation service (http://elocation.oracle.com/elocation/lbs).

If the URL is not set, then all requests fail with:

ORA-20000: Geocoding service URL not set
ORA-06512: at "SCOTT.SDO_GCDR_WS", line 28

The second step is (optionally) to set the name of the HTTP proxy to use, using the SET_PROXY() procedure. For example:

SQL> exec sdo_gcdr_ws.set_proxy('emea-proxy.uk.oracle.com:80');

Note that no proxy is set by default.


5. Using the API: some examples
-------------------------------

SQL> select sdo_gcdr_ws.geocode (sdo_keywordarray('Clay Street', 'San Francisco, CA'), 'US', 'default') from dual;

SDO_GEO_ADDR(0, NULL, NULL, 'Clay St', NULL, NULL, 'San Francisco', 'San Francisco', 'CA', 'US', '94115', NULL, NULL, NULL, '2798', NULL, NULL, NULL, NULL, NULL, NULL, 'L', 0, NULL, '????#ENUT?B281CP?', 1, NULL, -122.43914, 37.79008, '???14101010??004?', 8307)

SQL> select sdo_gcdr_ws.geocode (sdo_keywordarray('Zonneboslaan, 62', 'Kraainem'), 'BE', 'default') from dual;

SDO_GEO_ADDR(0, NULL, NULL, 'Zonneboslaan', NULL, NULL, 'Kraainem', 'Kraainem', 'VLAANDEREN', 'BE', '1950', NULL, NULL, NULL, '62', NULL, NULL, NULL, NULL, NULL, NULL, 'L', 0, NULL, '????#ENUT?B281CP?', 1, NULL, 4.47964, 50.83405, '???10101010??404?', 8307)

SQL> select sdo_gcdr_ws.geocode_as_geometry(sdo_keywordarray('1500 Clay Street', 'San Francisco, CA 94150'), 'US') from dual;

6. Debugging
------------

Use the SET_TRACE() function to enable or disable tracing of the XML requests sent to the geocoding service as well as the XML response received.

Example:

SQL> exec sdo_gcdr_ws.set_trace('true');
PL/SQL procedure successfully completed.

SQL> select sdo_gcdr_ws.geocode(sdo_keywordarray ('747 Howard Street','San Francisco, CA'),'US','default') from dual;

SDO_GCDR_WS.GEOCODE(SDO_KEYWORDARRAY('747HOWARDSTREET','SANFRANCISCO,CA'),'US',
-------------------------------------------------------------------------------
SDO_GEO_ADDR(0, NULL, NULL, 'Howard St', NULL, NULL, 'San Francisco', 'San Fran
cisco', 'CA', 'US', '94103', NULL, NULL, NULL, '747', NULL, NULL, NULL, NULL, N
ULL, NULL, 'R', 0, 724946195, '????#ENUT?B281CP?', 1, NULL, -122.4016, 37.78415
, '???10101010??004?', NULL)

1 row selected.

% Invoking http://elocation.oracle.com/elocation/lbs
% Request:
<geocode_request><address_list><input_location id="1"><input_address
match_mode="default"><unformatted country="US"><address_line value="747 Howard
Street"/><address_line value="San Francisco,
CA"/></unformatted></input_address></input_location></address_list></geocode_re
quest>
%
% resp.status_code=200
% resp.reason_phrase=OK
% resp.http_version=HTTP/1.1
% Response:
<?xml version="1.0" encoding="UTF-8"?><geocode_response><geocode id="1"
match_count="1"><match sequence="0" longitude="-122.4016" latitude="37.78415"
match_code="1"  error_message="????#ENUT?B281CP?"
match_vector="???10101010??004?" srid="8307"><output_address name=""
house_number="747" street="Howard St" settlement="San Francisco"
builtup_area="San Francisco" municipality="San Francisco" order1_area="CA"
order8_area="" country="US" postal_code="94103" postal_addon_code="" side="R"
percent="0.0" edge_id="724946195" /></match></geocode></geocode_response>
%