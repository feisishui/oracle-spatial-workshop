-- (Run as SYSTEM or SYS)

declare
  -- Construct the XML descriptor
  featureDescriptorXML CLOB :=
    '<?xml version="1.0" ?>
       <FeatureType xmlns:scottns="http://www.myserver.com/scott" xmlns="http://www.opengis.net/wfs">
         <Name> scottns:US_CITIES</Name>
         <Title>U.S Cities</Title>
         <SRS>SDO:8307</SRS>
     </FeatureType>';
begin
  -- Publish the feature type
  SDO_WFS_PROCESS.publishFeatureType(
    dataSrc           => 'SCOTT.US_CITIES',
    ftNsUrl           => 'http://www.myserver.com/scott',
    ftName            => 'UsCities',
    ftNsAlias         => 'scottns' ,
    featureDesc       => xmltype(featureDescriptorXML),
    schemaLocation    => null,
    pkeyCol           => 'ID',
    columnInfo        => MDSYS.StringList('PointMemberType'),
    pSpatialCol       => 'LOCATION',
    featureMemberNs   => null,
    featureMemberName => null,
    srsNs             => null,
    srsNsAlias        => null
  );

  -- Tell the WFS about the change
  SDO_WFS_PROCESS.InsertFtMDUpdated('http://www.myserver.com/scott','UsCities', sysdate);
end;
/
commit;
