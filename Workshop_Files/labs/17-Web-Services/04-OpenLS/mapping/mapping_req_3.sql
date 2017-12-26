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
        <CenterContext SRS="54004">
          <CenterPoint srsName="54004">
            <gml:pos>-13610088 4486734.46</gml:pos>
          </CenterPoint>
          <Radius unit="M">50000</Radius>
        </CenterContext>
      </Output>
      <Basemap filter="Include">
        <Layer name="elocation_mercator.WORLD_MAP.T_OCEANS_S01"/>
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
