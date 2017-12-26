create or replace package body sdo_gcdr_ws
as

gc_url      varchar2(256) := 'http://elocation.oracle.com/elocation/lbs';
gc_proxy    varchar2(256) := null;
gc_trace    boolean := false;
gc_language varchar2(256) := null;

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
  if gc_url is null then
    raise_application_error (-20000, 'Geocoding service URL not set');
  end if; 
  
  -- Set proxy is needed
  if gc_proxy is not null then
    utl_http.set_proxy(gc_proxy);
  end if; 
  
  -- Build the content to post. Don't forget to escape it
  -- This is necessary because some address elements may contain restricted
  -- characters ('&', '#', ...)
  post_content := 'xml_request=' || utl_url.escape(xml_request,true);
 
  -- Trace request if needed
  if (gc_trace) then
    dbms_output.put_line ('% Invoking '||gc_url);
    if (gc_proxy is not null) then
      dbms_output.put_line ('% Using proxy '||gc_proxy);
    end if;
    dbms_output.put_line ('% Request:');
    dbms_output.put_line (xml_request);
    dbms_output.put_line ('% ');
  end if;

  -- Setup the http request
  http_req := utl_http.begin_request(gc_url, 'POST', 'HTTP/1.0');
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
  if (gc_trace) then
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
-- Parse an XML response into an address array
----------------------------------------------------------------------------------
function parse_response (
  xml_response   clob
)
return sdo_addr_array
is
  x xmltype;
  g sdo_addr_array := sdo_addr_array();
  i number;
begin

  -- A geocoding response looks like this. It can contain any number
  -- of <match> items. 
  /*
  <geocode_response>
    <geocode id="1" match_count="1">
      <match 
        sequence="0"                                    ID
        longitude="-122.41837"                          LONGITUDE
        latitude="37.80598"                             LATITUDE
        match_code="2"                                  MATCHCODE
        error_message="????#ENU??B281CP?"               ERRORMESSAGE
        match_vector="???10101410??004?"                MATCHVECTOR
        srid="4326"                                     SRID
      >
        <output_address 
          name=""                                       PLACENAME
          house_number="1300"                           HOUSENUMBER
          street="Columbus Ave"                         STREETNAME
          settlement="San Francisco"                    SETTLEMENT
          builtup_area="San Francisco"                   
          municipality="San Francisco"                  MUNICIPALITY
          order1_area="CA"                              REGION
          order8_area="" 
          country="US"                                  COUNTRY
          postal_code="94133"                           POSTALCODE
          postal_addon_code=""                          POSTALADDONCODE
          side="R"                                      SIDE
          percent="0.0"                                 PERCENT
          edge_id="23601015"                            EDGEID
        />
      </match>
    </geocode>
  </geocode_response>  
  */
  
  -- Convert the response into an XMLTYPE so we can parse it
  x := XMLType (xml_response);
  
  -- Extract the information from the XML response
  i := 1;
  for r in (
    select 
       ExtractValue(Value(p),'//@sequence')          as ID,
       ExtractValue(Value(p),'//@longitude')         as LONGITUDE,
       ExtractValue(Value(p),'//@latitude')          as LATITUDE,
       ExtractValue(Value(p),'//@match_code')        as MATCHCODE,
       ExtractValue(Value(p),'//@error_message')     as ERRORMESSAGE,
       ExtractValue(Value(p),'//@match_vector')      as MATCHVECTOR,
       ExtractValue(Value(p),'//@srid')              as SRID,
       ExtractValue(Value(p),'//@name')              as PLACENAME,
       ExtractValue(Value(p),'//@house_number')      as HOUSENUMBER,
       ExtractValue(Value(p),'//@street')            as STREETNAME,
       ExtractValue(Value(p),'//@settlement')        as SETTLEMENT,
       ExtractValue(Value(p),'//@municipality')      as MUNICIPALITY,
       ExtractValue(Value(p),'//@order1_area')       as REGION,
       ExtractValue(Value(p),'//@country')           as COUNTRY,
       ExtractValue(Value(p),'//@postal_code')       as POSTALCODE,
       ExtractValue(Value(p),'//@postal_addon_code') as POSTALADDONCODE,
       ExtractValue(Value(p),'//@side')              as SIDE,
       ExtractValue(Value(p),'//@percent')           as PERCENT,
       ExtractValue(Value(p),'//@edge_id')           as EDGEID        
    from table(XMLSequence(Extract(x,'/geocode_response/geocode/match'))) p
  )
  loop
    g.extend();
    g(i)                      := sdo_geo_addr();
    g(i).ID                   := r.ID;
    g(i).LONGITUDE            := to_number(r.LONGITUDE,NUMERIC_FORMAT);
    g(i).LATITUDE             := to_number(r.LATITUDE,NUMERIC_FORMAT);
    g(i).MATCHCODE            := r.MATCHCODE;
    g(i).ERRORMESSAGE         := r.ERRORMESSAGE;
    g(i).MATCHVECTOR          := r.MATCHVECTOR;
    -- g(i).SRID                 := r.SRID;   -- SRID only exists from 12.1.0.1
    g(i).PLACENAME            := r.PLACENAME;
    g(i).HOUSENUMBER          := r.HOUSENUMBER;
    g(i).STREETNAME           := r.STREETNAME;
    g(i).SETTLEMENT           := r.SETTLEMENT;
    g(i).MUNICIPALITY         := r.MUNICIPALITY;
    g(i).REGION               := r.REGION;
    g(i).COUNTRY              := r.COUNTRY;
    g(i).POSTALCODE           := r.POSTALCODE;
    g(i).POSTALADDONCODE      := r.POSTALADDONCODE;
    g(i).SIDE                 := r.SIDE;
    g(i).PERCENT              := to_number(r.PERCENT,NUMERIC_FORMAT); 
    g(i).EDGEID               := r.EDGEID;
    i := i + 1;      
  end loop;

  return g;
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
    gc_trace := true;
  else 
    gc_trace := false;
  end if;
end;

----------------------------------------------------------------------------------
-- Set the URL of the geocoding service to call
----------------------------------------------------------------------------------
procedure set_url (
  url                            varchar2
)
is 
begin
  gc_url := url;
end;

----------------------------------------------------------------------------------
-- Get the URL of the geocoding service to call
----------------------------------------------------------------------------------
function get_url 
return varchar2
is
begin
  return gc_url;
end;

----------------------------------------------------------------------------------
-- Set the host of the proxy to use
----------------------------------------------------------------------------------
procedure set_proxy (
  proxy_host                     varchar2
)
is begin
  gc_proxy := proxy_host;
end;

----------------------------------------------------------------------------------
-- Get the host of the proxy to use
----------------------------------------------------------------------------------
function get_proxy 
return varchar2
is
begin
  return gc_proxy;
end;

----------------------------------------------------------------------------------
-- Set the language to use for reverse geocodes
----------------------------------------------------------------------------------
procedure set_language (
  language_     varchar2
)
is begin
  gc_language := language_;
end;

----------------------------------------------------------------------------------
-- Get the language to use for reverse geocodes
----------------------------------------------------------------------------------

function get_language
return varchar2
is
begin
  return gc_language;
end;




----------------------------------------------------------------------------------
-- Perform the geocode_all() call. 
----------------------------------------------------------------------------------
function geocode_all (
  addr_lines                     sdo_keywordarray,
  country                        varchar2,
  match_mode                     varchar2
)
return sdo_addr_array
is
  request clob;
  response clob;
  g sdo_addr_array;
begin
  -- A unformatted geocoding request looks like this. It can
  -- contain any number of address lines
  /*
  <geocode_request>
    <address_list>
      <input_location id="1">
        <input_address match_mode="default">
          <unformatted country="US" >
            <address_line value="1300 Columbus" />
            <address_line value="San Francisco, CA" />
          </unformatted >
        </input_address>
      </input_location>
    </address_list>
  */
     
  -- Construct the geocoding request
  request := '';
  request := request||'<geocode_request>';
  request := request||'<address_list>';
  request := request||'<input_location id="1">';
  request := request||'<input_address match_mode="'||match_mode||'">';
  request := request||'<unformatted country="'||country||'">';
  for i in 1..addr_lines.count() loop
    request := request||'<address_line value="'|| addr_lines(i) ||'"/>';
  end loop;
  request := request||'</unformatted>';
  request := request||'</input_address>';
  request := request||'</input_location>';
  request := request||'</address_list>';
  request := request||'</geocode_request>';

  -- Issue the request
  response := call_server (request);
  
  -- Parse the response into an address array
  g := parse_response (response);
  
  -- Return the resulting array
  return g;
end;

----------------------------------------------------------------------------------
-- Perform the geocode() call. 
-- Call the geocode_all function and return only the first match
----------------------------------------------------------------------------------
function geocode (
  addr_lines                     sdo_keywordarray,
  country                        varchar2,
  match_mode                     varchar2
)
return sdo_geo_addr
is
  g sdo_addr_array;
begin
  g := geocode_all (addr_lines, country, match_mode);
  return g(1);
end;

----------------------------------------------------------------------------------
-- Perform the geocode_addr_all() call. 
----------------------------------------------------------------------------------
function geocode_addr_all (
  address                        sdo_geo_addr
)
return sdo_addr_array
is
  request clob;
  response clob;
  g sdo_addr_array;
begin
  -- A formatted geocoding request looks like this. 
  /*
  <geocode_request>
    <address_list>
      <input_location id="1">
        <input_address match_mode="default">
          <gen_form 
            street="1300 Howard Street" 
            city="San Francisco" 
            region="CA" 
            postal_code="94103"
            country="US"
          />
        </input_address>
      </input_location>
    </address_list>
  
    <xsd:attribute name="name" type="xsd:string"/>
    <xsd:attribute name="street" type="xsd:string"/>
    <xsd:attribute name="intersecting_street" type="xsd:string"/>
    <xsd:attribute name="sub_area" type="xsd:string"/>
    <xsd:attribute name="city" type="xsd:string"/>
    <xsd:attribute name="region" type="xsd:string"/>
    <xsd:attribute name="country" type="xsd:string"/>
    <xsd:attribute name="postal_code" type="xsd:string"/>
    <xsd:attribute name="postal_addon_code" type="xsd:string"/>
    
  */

  -- Construct the geocoding request
  request := '';
  request := request||'<geocode_request>';
  request := request||'<address_list>';
  request := request||'<input_location id="1">';
  request := request||'<input_address match_mode="'||address.matchmode||'">';
  request := request||'<gen_form';
  request := request||' street="'||address.streetname||'"';
  request := request||' intersecting_street="'||address.intersectstreet||'"';
  request := request||' sub_area="'||address.settlement||'"';
  request := request||' city="'||address.municipality||'"';
  request := request||' region="'||address.region||'"';
  request := request||' country="'||address.country||'"';
  request := request||' postal_code="'||address.postalcode||'"';
  request := request||' postal_addon_code="'||address.postaladdoncode||'"';
  request := request||'/>';
  request := request||'</input_address>';
  request := request||'</input_location>';
  request := request||'</address_list>';
  request := request||'</geocode_request>';

  -- Issue the request
  response := call_server (request);
  
  -- Parse the response into an address array
  g := parse_response (response);
  
  -- Return the resulting array
  return g;
end;

----------------------------------------------------------------------------------
-- Perform the geocode_addr() call. 
-- Call the geocode_addr_all() function and return only the first match
----------------------------------------------------------------------------------
function geocode_addr (
  address                        sdo_geo_addr
)
return sdo_geo_addr
is
  g sdo_addr_array;
begin
  g := geocode_addr_all (address);
  return g(1);
end;

----------------------------------------------------------------------------------
-- Perform the geocode_as_geometry() call. 
-- Call the geocode() function and return the result as a geometry object
----------------------------------------------------------------------------------

function geocode_as_geometry (
  addr_lines                     sdo_keywordarray,
  country                        varchar2
)
return sdo_geometry
is
  g sdo_geo_addr;
begin
  g := geocode (addr_lines, country, 'default');
  return sdo_geometry (
    2001,
    8307, 
    -- g.srid,               -- SRID only exists from 12.1.0.1
    sdo_point_type (
      g.longitude, g.latitude, null
    ),
    null,
    null
  );
end;

----------------------------------------------------------------------------------
-- Perform the reverse_geocode() call.
----------------------------------------------------------------------------------

  -- A reverse geocode request looks like this:
  /*
  
  <geocode_request>
    <address_list>
      <input_location 
        id="1"
        country="US"
        longitude="-122.41837" latitude="37.80598"
      />
    </address_list>
  </geocode_request>
  
  Note that the country code/name is optional.
  
  <xsd:attribute name="id" type="xsd:string"/>
  <xsd:attribute name="country" type="xsd:string"/>
  <xsd:attribute name="longitude" type="xsd:string"/>
  <xsd:attribute name="latitude" type="xsd:string"/>
  <xsd:attribute name="x" type="xsd:string"/>
  <xsd:attribute name="y" type="xsd:string"/>
  <xsd:attribute name="srid" type="xsd:string"/>
 
  */

-- Geometry, country
function reverse_geocode (
  location                       sdo_geometry,
  country                        varchar2
)
return sdo_geo_addr
is
  request clob;
  response clob;
  g sdo_addr_array;
begin
  -- Construct the geocoding request
  request := '';
  request := request||'<geocode_request>';
  request := request||'<address_list>';
  request := request||'<input_location';
  request := request||' id="1"';
  if country is not null then
    request := request||' country="'||country||'"';
  end if;
  request := request||' longitude="'||location.sdo_point.x||'"';
  request := request||' latitude="'||location.sdo_point.y||'"';
  request := request||' srid="'||location.sdo_srid||'"';
  if gc_language is not null then
    request := request||' language="'||gc_language||'"';
  end if;
  request := request||'/>';
  request := request||'</address_list>';
  request := request||'</geocode_request>';

  -- Issue the request
  response := call_server (request);
  
  -- Parse the response into an address array
  g := parse_response (response);
  
  -- Return the first or only match
  return g(1);
end;

-- Longitude, latitude, country
function reverse_geocode (
  longitude                      number,
  latitude                       number,
  country                        varchar2
)
return sdo_geo_addr
is
begin
  return reverse_geocode (
    sdo_geometry (2001, 8307, sdo_point_type (longitude, latitude, null), null, null),
    country
  );
end;

-- Longitude, latitude, srid, country
function reverse_geocode (
  longitude                      number,
  latitude                       number,
  srid                           number,
  country                        varchar2
)
return sdo_geo_addr
is
begin
  return reverse_geocode (
    sdo_geometry (2001, srid, sdo_point_type (longitude, latitude, null), null, null),
    country
  );
end;

end;
/
show error
