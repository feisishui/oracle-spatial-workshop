declare
  req CLOB :=
'<XLS
  xmlns="http://www.opengis.net/xls"
  xmlns:gml="http://www.opengis.net/gml"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.opengis.net/xls"
  version="1.1">
  <RequestHeader clientName="someName" clientPassword="password"/>
  <Request
    maximumResponses="1"
    methodName="PortrayMapRequest"
    requestID="456"
    version="1.1">
    <PortrayMapRequest>
      <Output
        BGcolor="#a6cae0"
        content="URL"
        format="GIF_URL"
        height="600"
        transparent="false"
        width="800">
        <CenterContext SRS="8307">
          <CenterPoint srsName="8307">
            <gml:pos>-122.2615 37.5266</gml:pos>
          </CenterPoint>
          <Radius unit="M">50000</Radius>
        </CenterContext>
      </Output>
      <Basemap filter="Include">
        <Layer name="mvdemo.demo_map.THEME_DEMO_COUNTIES"/>
        <Layer name="mvdemo.demo_map.THEME_DEMO_HIGHWAYS"/>
      </Basemap>
      <Overlay zorder="1">
        <POI
          ID="123"
          description="description"
          phoneNumber="1234"
          POIName="Books at Post Str (point)">
          <gml:Point srsName="4326">
            <gml:pos>-122.4083257 37.788208</gml:pos>
          </gml:Point>
        </POI>
      </Overlay>
      <Overlay zorder="2">
        <POI
          ID="456"
          description="description"
          phoneNumber="1234"
          POIName="Books at Winston Dr (address)">
          <Address countryCode="US">
            <StreetAddress>
              <Building number="233"/>
              <Street>Winston Drive</Street>
            </StreetAddress>
            <Place type="CountrySubdivision">CA</Place>
            <Place type="CountrySecondarySubdivision"/>
            <Place type="Municipality">San Francisco</Place>
            <Place type="MunicipalitySubdivision"/>
            <PostalCode>94132</PostalCode>
          </Address>
        </POI>
      </Overlay>
      <Overlay zorder="3">
        <Position levelOfConf="1">
          <gml:Point gid="a boat (point)" srsName="4326">
            <gml:pos>-122.8053965 37.388208</gml:pos>
          </gml:Point>
        </Position>
      </Overlay>
    </PortrayMapRequest>
  </Request>
</XLS>
';
  response CLOB;
begin
  response := mdsys.sdo_ols.makeOpenLSClobRequest(req);
  dbms_output.put_line (response);
end;
/
