declare
  req CLOB :=
'<?xml version="1.0" standalone="yes"?>
<xls:XLS xmlns:xls="http://www.opengis.net/xls" xmlns:gml="http://www.opengis.net/gml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.opengis.net/xls http://schemas.opengis.net/ols/1.1.0/LocationUtilityService.xsd" version="1.1">
  <xls:RequestHeader/>
  <xls:Request methodName="GeocodeRequest" requestID="123456789" version="1.1">
    <xls:GeocodeRequest>
      <xls:Address countryCode="FI">
        <xls:StreetAddress>
          <xls:Street>Orioninkatu</xls:Street>
          <xls:Building number="9"/>
        </xls:StreetAddress>
        <xls:PostalCode>00550</xls:PostalCode>
        <xls:Place type="Municipality">Helsinki</xls:Place>
      </xls:Address>
    </xls:GeocodeRequest>
  </xls:Request>
</xls:XLS>';
  response CLOB;
begin
  response := sdo_ols.makeOpenLSClobRequest(req);
  dbms_output.put_line (response);
end;
/
