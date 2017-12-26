declare
  req CLOB :=
'<?xml version="1.0" standalone="yes"?>
<XLS version="1.1"
  xmlns="http://www.opengis.net/xls"
  xmlns:gml="http://www.opengis.net/gml"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.opengis.net/xls">
  <RequestHeader clientName="USERNAME" clientPassword="PASSWORD"/>
  <Request methodName="PortrayMapRequest"
    requestID="456" version="1.1">
    <PortrayMapRequest>
      <Output
        width="800" height="600"
        content="Data" BGcolor="#ffffff"
        format="jpg_url">
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
