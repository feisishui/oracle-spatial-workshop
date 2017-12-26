create or replace package sdo_router_ws 
as

----------------------------------------------------------------------------------
-- Enable / disable tracing
----------------------------------------------------------------------------------
procedure set_trace (
  enabled        varchar2
);

----------------------------------------------------------------------------------
-- Get/set the URL of the routing service to call
----------------------------------------------------------------------------------
procedure set_url (
  url            varchar2
);

function get_url 
return varchar2;

----------------------------------------------------------------------------------
-- Get/set the host of the proxy to use
----------------------------------------------------------------------------------
procedure set_proxy (
  proxy_host     varchar2
);

function get_proxy 
return varchar2;

----------------------------------------------------------------------------------
-- Get a route between two geographic locations
----------------------------------------------------------------------------------
function get_route (
  origin        sdo_geometry,
  destination   sdo_geometry,
  options       sdo_keywordarray default null
)
return sdo_route
deterministic;

----------------------------------------------------------------------------------
-- Get a route between two addresses
-- The last line of each address contains the name or code of the country
----------------------------------------------------------------------------------
function get_route (
  origin        sdo_keywordarray,
  destination   sdo_keywordarray,
  options       sdo_keywordarray default null
)
return sdo_route
deterministic;

----------------------------------------------------------------------------------
-- Get a route between two geocoded addresses
----------------------------------------------------------------------------------
function get_route (
  origin        sdo_geo_addr,
  destination   sdo_geo_addr,
  options       sdo_keywordarray default null
)
return sdo_route
deterministic;


end;
/
show error