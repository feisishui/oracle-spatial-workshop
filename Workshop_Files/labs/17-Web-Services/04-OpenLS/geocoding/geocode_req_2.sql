declare
  req CLOB :=
'<?xml version="1.0" standalone="yes"?>
<XLS version="1.1"
  xmlns="http://www.opengis.net/xls"
  xmlns:gml="http://www.opengis.net/gml"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.opengis.net/xls">
  <RequestHeader clientName="USERNAME" clientPassword="PASSWORD"/>
  <Request methodName="GeocodeRequest"
    maximumResponses="10"
    requestID="123" version="1.0">
    <GeocodeRequest>
      <Address countryCode="FR">
        <StreetAddress>
          <Building number="150"/>
          <Street>Boulevard Hausman</Street>
        </StreetAddress>
        <Place type="Municipality">Paris</Place>
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
