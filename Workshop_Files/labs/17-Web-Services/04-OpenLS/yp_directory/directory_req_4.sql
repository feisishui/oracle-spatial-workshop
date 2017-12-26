-- Search for the nearest restaurant from an address (DOES NOT WORK!)
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
    maximumResponses="1"
    methodName="DirectoryRequest">
    <DirectoryRequest>
      <POILocation>
        <Nearest nearestCriterion="Proximity">
          <Address countryCode="US">
            <StreetAddress>
              <Building number="400"/>
              <Street>Post Street</Street>
            </StreetAddress>
            <Place type="CountrySubdivision">CA</Place>
            <Place type="Municipality">San Francisco</Place>
            <PostalCode>94102</PostalCode>
          </Address>
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

