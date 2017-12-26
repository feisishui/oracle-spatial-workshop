-- Search for all tourist offices in San Francisco
-- Search criteria are case-sensitive!
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
        <Address countryCode="US">
          <Place type="CountrySubdivision">CALIFORNIA</Place>
          <Place type="Municipality">SAN FRANCISCO</Place>
        </Address>
      </POILocation>
      <POIProperties>
        <POIProperty name="SIC_type" value="TOURIST INFORMATION"/>
      </POIProperties>
    </DirectoryRequest>
  </Request>
</XLS>';
  response CLOB;
begin
  response := mdsys.my_sdo_ols.makeOpenLSClobRequest(req);
  dbms_output.put_line (response);
end;
/

