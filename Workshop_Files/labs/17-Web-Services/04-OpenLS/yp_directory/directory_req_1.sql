-- Search for a specific POI by name
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
      <POIProperties>
        <POIProperty name="POIName" value="MERCURE ROYAL MADELEINE"/>
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

