create or replace package body sdo_router_ws
as

router_url    varchar2(256) := 'http://elocation.oracle.com/elocation/lbs';
router_proxy  varchar2(256) := null;
router_trace  boolean := false;

NUMERIC_FORMAT varchar2(50) := '9999999999999999999.999999999999999999';

----------------------------------------------------------------------------------
-- Private functions and procedures
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Call the server passing an XML request, then return the XML response
----------------------------------------------------------------------------------
function call_server (
  xml_request   clob
)
return clob
is
  http_req      utl_http.req;
  http_resp     utl_http.resp;
  post_content  clob;
  xml_response  clob;  
  response_line varchar2(32767);
  i             number;
begin
  -- Make sure we know what service to call
  if router_url is null then
    raise_application_error (-20000, 'routing service URL not set');
  end if; 
  
  -- Set proxy is needed
  if router_proxy is not null then
    utl_http.set_proxy(router_proxy);
  end if; 
  
  -- Build the content to post. Don't forget to escape it
  -- This is necessary because some address elements may contain restricted
  -- characters ('&', '#', ...)
  post_content := 'xml_request=' || utl_url.escape(xml_request,true);
 
  -- Trace request if needed
  if (router_trace) then
    dbms_output.put_line ('% Invoking '||router_url);
    if (router_proxy is not null) then
      dbms_output.put_line ('% Using proxy '||router_proxy);
    end if;
    dbms_output.put_line ('% Request:');
    dbms_output.put_line (xml_request);
    dbms_output.put_line ('% ');
  end if;

  -- Setup the http request
  http_req := utl_http.begin_request(router_url, 'POST', 'HTTP/1.0');
  utl_http.set_header(http_req, 'Content-Type', 'application/x-www-form-urlencoded');
  utl_http.set_header(http_req, 'Content-Length', length(post_content));
  utl_http.write_text(http_req, post_content);
  
  -- Get the http response
  http_resp := utl_http.get_response(http_req);
    
  -- Read the response content
  begin
    xml_response := '';
    i := 0;
    loop
      utl_http.read_line(http_resp, response_line, true);
      i := i + 1;
      xml_response := xml_response || response_line;
    end loop;
  exception
    when utl_http.end_of_body then
      utl_http.end_response(http_resp);
  end;
  
  -- Trace response
  if (router_trace) then
    dbms_output.put_line ('% resp.status_code='||http_resp.status_code);
    dbms_output.put_line ('% resp.reason_phrase='||http_resp.reason_phrase);
    dbms_output.put_line ('% resp.http_version='||http_resp.http_version);
    dbms_output.put_line ('% Response:');
    dbms_output.put_line (xml_response);
    dbms_output.put_line ('% ');
  end if;
  
  return xml_response;
end;

----------------------------------------------------------------------------------
-- Parse an XML response into a route
----------------------------------------------------------------------------------
function parse_response (
  xml_response   clob
)
return sdo_route
is
  xml xmltype;
  route sdo_route := sdo_route(0,0,null,null);
  i number;
begin

  /*
  -- A routing response looks like this:
  <route_response>
    <route id="1" mbr="-122.41837,37.78151,-122.4016,37.80598" 
      step_count="6" 
      distance="2.291574024808923" distance_unit="mile" 
      time="5.5876215616861975" time_unit="minute" 
      start_location="1" end_location="2">
      <route_geometry>
        <LineString>
          <coordinates>
          -122.4016,37.78415 -122.4016,37.78415 -122.40187,37.78394 -122.40205,37.78379 -122.4021,37.78375 -122.40221,37.78366 -122.40234,37.78355 -122.40256,37.78338 -122.4027,37.78327 -122.40493,37.78151 -122.40546,37.78195 -122.40592,37.7823 -122.40649,37.78274 -122.407,37.78316 -122.40719,37.78331 -122.40723,37.78334 -122.40746,37.78351 -122.40806,37.784 -122.40821,37.78411 -122.40843,37.78429 -122.40847,37.78434 -122.4085,37.7844 -122.40852,37.7845 -122.40866,37.78543 -122.40946,37.78533 -122.41113,37.7851 -122.41132,37.78602 -122.41151,37.78695 -122.41157,37.78723 -122.41161,37.7874 -122.4117,37.78786 -122.41175,37.78815 -122.41181,37.78848 -122.41188,37.78881 -122.41207,37.78976 -122.41225,37.79066 -122.41246,37.79161 -122.41256,37.79211 -122.41264,37.79255 -122.41273,37.79298 -122.41283,37.79344 -122.41301,37.79433 -122.41317,37.7952 -122.41336,37.79609 -122.41344,37.79653 -122.41352,37.79693 -122.41354,37.79703 -122.41368,37.79777 -122.41371,37.79793 -122.41372,37.79797 -122.41373,37.79802 -122.41376,37.79817 -122.41378,37.79828 -122.41393,37.7989 -122.41395,37.79896 -122.41403,37.79937 -122.41414,37.79983 -122.41423,37.8003 -122.41431,37.80076 -122.41436,37.80102 -122.41439,37.80118 -122.4144,37.80124 -122.41449,37.8017 -122.41462,37.80235 -122.41467,37.80262 -122.41484,37.80335 -122.41488,37.80355 -122.41547,37.80396 -122.41556,37.80402 -122.41607,37.80441 -122.41657,37.80475 -122.41681,37.80492 -122.4172,37.80519 -122.4178,37.8056 -122.41837,37.80598 -122.41837,37.80598
          </coordinates>
        </LineString>
      </route_geometry>
      <segment sequence="1" instruction="Start out on Howard St (Going Southwest)" distance="0.2576523998129889" time="0.6282424370447794"/>
      <segment sequence="2" instruction="Turn RIGHT onto 5th St (Going Northwest)" distance="0.24263344238893764" time="0.5916212111711502"/>
      <segment sequence="3" instruction="Stay STRAIGHT to go onto Cyril Magnin St (Going Northwest)" distance="0.10874914336306753" time="0.26516667008399963"/>
      <segment sequence="4" instruction="Turn LEFT onto Ellis St (Going West)" distance="0.13683588607163247" time="0.3336514949798584"/>
      <segment sequence="5" instruction="Turn RIGHT onto Taylor St (Going North)" distance="1.291623682363315" time="3.1494090740879375"/>
      <segment sequence="6" instruction="Turn SLIGHT LEFT onto Columbus Ave (Going Northwest)" distance="0.2540794154006995" time="0.6195303122202556"/>
    </route>
  </route_response>  
  */
  
  /*
  -- Failed requests returns something like this:
  <generic_error>java.lang.NumberFormatException: .... </generic_error>
  or
  <elocation_error>Error processing route request</elocation_error>
  */
  
  -- Convert the response into an XMLTYPE so we can parse it
  xml := XMLType (xml_response);
  
  -- Make sure we have a usable result
  if xml.existsnode('/route_response/route') = 0 then 
    return NULL;
  end if; 

  -- Extract time and distance
  route.distance := xml.extract('/route_response/route/@distance').getnumberval();
  route.time := xml.extract('/route_response/route/@time').getnumberval();

  -- Extract driving directions if they exist
  if xml.existsnode('/route_response/route/segment') > 0 then  
    route.directions := sdo_route_segments();
    i := 1;
    for r in (
      select 
         ExtractValue(Value(p),'//@sequence')     as sequence,
         ExtractValue(Value(p),'//@instruction')  as instruction,
         ExtractValue(Value(p),'//@distance')     as distance,
         ExtractValue(Value(p),'//@time')         as time        
      from table(XMLSequence(Extract(xml,'/route_response/route/segment'))) p
    )
    loop
      route.directions.extend();
      route.directions(i) := sdo_route_segment(r.sequence,r.instruction,r.distance,r.time);
      i := i + 1;
    end loop;
  end if;
  
  -- Extract route geometry
  if xml.existsnode('/route_response/route/route_geometry') > 0 then  
    route.geometry := sdo_util.from_gmlgeometry(xml.extract('/route_response/route/route_geometry/LineString').getclobval());
    route.geometry.sdo_srid := 4326;
  end if;
  
  return route;
end;

----------------------------------------------------------------------------------
-- Public functions and procedures
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Enable / disable tracing
----------------------------------------------------------------------------------
procedure set_trace (
  enabled                        varchar2
)
is
begin
  if upper(enabled) = 'TRUE' then
    router_trace := true;
  else 
    router_trace := false;
  end if;
end;

----------------------------------------------------------------------------------
-- Set the URL of the routing service to call
----------------------------------------------------------------------------------
procedure set_url (
  url                            varchar2
)
is 
begin
  router_url := url;
end;

----------------------------------------------------------------------------------
-- Get the URL of the routing service to call
----------------------------------------------------------------------------------
function get_url 
return varchar2
is
begin
  return router_url;
end;

----------------------------------------------------------------------------------
-- Set the host of the proxy to use
----------------------------------------------------------------------------------
procedure set_proxy (
  proxy_host                     varchar2
)
is begin
  router_proxy := proxy_host;
end;

----------------------------------------------------------------------------------
-- Get the host of the proxy to use
----------------------------------------------------------------------------------
function get_proxy 
return varchar2
is
begin
  return router_proxy;
end;

----------------------------------------------------------------------------------
-- Get a route between two geographic locations
----------------------------------------------------------------------------------
function get_route (
  origin        sdo_geometry,
  destination   sdo_geometry,
  options       sdo_keywordarray
)
return sdo_route
is
  request clob;
  response clob;
  route sdo_route;
begin
  -- A routing request between two geographic locations looks like this
  /*
    <route_request 
      route_preference="fastest"
      return_driving_directions="true"
      distance_unit="mile" 
      time_unit="minute">
      <start_location>
        <input_location id="1"
          longitude="-122.4014128" latitude="37.7841193" srid="4326"/>
      </start_location>
      <end_location>
        <input_location id="2"
          longitude="-122.41833266666666" latitude="37.805999" srid="4326"/>
      </end_location>
    </route_request>
  */
     
  -- Construct the routing request
  request := '';
  request := request||'<route_request ';  
  -- Options
  if options is not null then
    for i in 1..options.count() loop
      request := request||options(i)||' ';
    end loop;
  end if;
  request := request||'>';
  -- Start location
  request := request||'<start_location>';
  request := request||'<input_location id="1" ';
  request := request||'longitude="'||origin.sdo_point.x||'" ';
  request := request||'latitude="'||origin.sdo_point.y||'" ';
  request := request||'srid="'||origin.sdo_srid||'"/>';
  request := request||'</start_location>';
  -- End location
  request := request||'<end_location>';
  request := request||'<input_location id="2" ';
  request := request||'longitude="'||destination.sdo_point.x||'" ';
  request := request||'latitude="'||destination.sdo_point.y||'" ';
  request := request||'srid="'||destination.sdo_srid||'"/>';
  request := request||'</end_location>';  
  request := request||'</route_request>';

  -- Issue the request
  response := call_server (request);
  
  -- Parse the response into an route response
  route := parse_response (response);
  
  -- Return the resulting array
  return route;
end;

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
is
  request clob;
  response clob;
  route sdo_route;
begin

  -- A routing request between two addresses looks like this
  /*
    <route_request id="1" route_preference="fastest"
      return_driving_directions="false"
      distance_unit="mile" time_unit="minute">
      <start_location>
        <input_location id="1" >
          <input_address>
            <unformatted country="US" >
              <address_line value="747 Howard Street" />
              <address_line value="San Francisco, CA" />
            </unformatted >
          </input_address>
        </input_location>
      </start_location>
      <end_location>
        <input_location id="2" >
          <input_address>
            <unformatted country="US" >
              <address_line value="1300 Columbus" />
              <address_line value="San Francisco, CA" />
            </unformatted >
          </input_address>
        </input_location>
      </end_location>
    </route_request>
  */
     
  -- Construct the routing request
  request := '';
  request := request||'<route_request ';  
  -- Options
  if options is not null then
    for i in 1..options.count() loop
      request := request||options(i)||' ';
    end loop;
  end if;
  request := request||'>';
  -- Start location
  request := request||'<start_location>';
  request := request||'<input_location id="1"> ';
  request := request||'<input_address>';
  request := request||'<unformatted country="'||origin(origin.last)||'">';
  for i in 1..origin.count()-1 loop
    request := request||'<address_line value="'||origin(i)||'" />';
  end loop;
  request := request||'</unformatted>';
  request := request||'</input_address>';
  request := request||'</input_location>';
  request := request||'</start_location>';
  -- End location
  request := request||'<end_location>';
  request := request||'<input_location id="2">';
  request := request||'<input_address>';
  request := request||'<unformatted country="'||destination(destination.last)||'">';
  for i in 1..destination.count()-1 loop
    request := request||'<address_line value="'||destination(i)||'" />';
  end loop;
  request := request||'</unformatted>';
  request := request||'</input_address>';
  request := request||'</input_location>';
  request := request||'</end_location>';  
  request := request||'</route_request>';

  -- Issue the request
  response := call_server (request);
  
  -- Parse the response into an route response
  route := parse_response (response);
  
  -- Return the resulting array
  return route;
end;

----------------------------------------------------------------------------------
-- Get a route between two geocoded addresses
----------------------------------------------------------------------------------
function get_route (
  origin        sdo_geo_addr,
  destination   sdo_geo_addr,
  options       sdo_keywordarray default null
)
return sdo_route
is
  request clob;
  response clob;
  route sdo_route;
begin
  -- A routing request between two geocoded locations looks like this
  /*
    <route_request id="1" route_preference="fastest"
      return_driving_directions="true"
      distance_unit="mile" time_unit="minute"
      pre_geocoded_locations="true">
      <start_location>
        <pre_geocoded_location id="1">
          <edge_id>23607005</edge_id>
          <percent>0.53</percent>
          <side>R</side>
        </pre_geocoded_location>
      </start_location>
      <end_location>
        <pre_geocoded_location id="2">
          <edge_id>23601015</edge_id>
          <percent>0.33</percent>
          <side>R</side>
        </pre_geocoded_location>
      </end_location>
    </route_request>
  */
  
  -- Construct the routing request
  request := '';
  request := request||'<route_request ';  
  -- Options
  if options is not null then
    for i in 1..options.count() loop
      request := request||options(i)||' ';
    end loop;
  end if;
  request := request||'pre_geocoded_locations="true"';
  request := request||'>';
  -- Start location
  request := request||'<start_location>';
  request := request||'<pre_geocoded_location id="1">';
  request := request||'<edge_id>'||origin.edgeid||'</edge_id>';
  request := request||'<percent>'||origin.percent||'</percent>';
  request := request||'<side>'||origin.side||'</side>';
  request := request||'</pre_geocoded_location>';
  request := request||'</start_location>';
  -- End location
  request := request||'<end_location>';
  request := request||'<pre_geocoded_location id="2">';
  request := request||'<edge_id>'||destination.edgeid||'</edge_id>';
  request := request||'<percent>'||destination.percent||'</percent>';
  request := request||'<side>'||destination.side||'</side>';
  request := request||'</pre_geocoded_location>';
  request := request||'</end_location>';  
  request := request||'</route_request>';

  -- Issue the request
  response := call_server (request);
  
  -- Parse the response into an route response
  route := parse_response (response);
  
  -- Return the resulting array
  return route;
end;

end;
/
show error
