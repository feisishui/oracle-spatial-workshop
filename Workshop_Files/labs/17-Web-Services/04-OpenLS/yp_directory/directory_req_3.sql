-- Search for the nearest restaurant from a geographical point
declare
  req CLOB :=
'<?xml version="1.0" standalone="yes"?>
<XLS version="1.1"
  xmlns="http://www.opengis.net/xls"
  xmlns:gml="http://www.opengis.net/gml"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.opengis.net/xls">
  <RequestHeader clientName="USERNAME" clientPassword="PASSWORD"/>
  <Request version="1.1"
    requestID="123"
    maximumResponses="10"
    methodName="DirectoryRequest">
    <DirectoryRequest>
      <POILocation>
        <Nearest nearestCriterion="Proximity">
         <Position>
          <gml:Point xmlns:gml="http://www.opengis.net/gml">
           <gml:pos dimension="2" srsName="4326">
             -122.4083257 37.788208
           </gml:pos>
          </gml:Point>
         </Position>
        </Nearest>
      </POILocation>
      <POIProperties>
        <POIProperty name="SIC_type" value="RESTAURANT"/>
      </POIProperties>
    </DirectoryRequest>
  </Request>
</XLS>';
  response CLOB;
begin
  response := sdo_ols.makeOpenLSClobRequest(req);
  dbms_output.put_line (response);
end;
/

