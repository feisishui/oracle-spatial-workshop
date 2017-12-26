declare
  req CLOB :=
'<?xml version="1.0" standalone="yes"?>
<XLS
  xmlns="http://www.opengis.net/xls"
  xmlns:gml="http://www.opengis.net/gml"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.opengis.net/xls"
  version="1.0">
  <RequestHeader clientName="someName" clientPassword="password"/>
  <Request
    maximumResponses="10"
    methodName="GeocodeRequest"
    requestID="123"
    version="1.0">
    <GeocodeRequest>
      <Address countryCode="US">
        <StreetAddress>
          <Building number="400"/>
          <Street>Post Street</Street>
        </StreetAddress>
        <Place type="CountrySubdivision">CA</Place>
        <Place type="Municipality">San Francisco</Place>
        <PostalCode>94102</PostalCode>
      </Address>
      <Address countryCode="US">
        <StreetAddress>
          <Building number="233"/>
          <Street>Winston Drive</Street>
        </StreetAddress>
        <Place type="CountrySubdivision">CA</Place>
        <Place type="Municipality">San Francisco</Place>
        <PostalCode>94132</PostalCode>
      </Address>
    </GeocodeRequest>
  </Request>
</XLS>';
  response CLOB;
begin
  response := sdo_ols.makeOpenLSClobRequest(req);
  dbms_output.put_line (response);
end;
/
