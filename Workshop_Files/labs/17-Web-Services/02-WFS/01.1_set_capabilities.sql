-- Run as MDSYS, SYSTEM or SYS

-- Load the capabilities from a PL/SQL variable
declare
  capabilitiesXML CLOB :=
'<WFS_Capabilities version="1.0.0" xmlns="http://www.opengis.net/wfs" xmlns:ogc="http://www.opengis.net/ogc" >
   <Service>
     <Name> Oracle WFS </Name>
     <Title> Oracle Web Feature Service </Title>
     <Abstract> Web Feature Service maintained by Oracle </Abstract>
     <OnlineResource> http://www.someserver.com/wfs/cwwfs.cgi? </OnlineResource>
   </Service>
   <Capability>
      <Request>
         <GetCapabilities>
            <DCPType>
               <HTTP>
                  <Get onlineResource="http://www.myserver.com/get?"/>
               </HTTP>
            </DCPType>
            <DCPType>
               <HTTP>
                  <Post onlineResource="http://www.myserver.com/post?"/>
               </HTTP>
            </DCPType>
         </GetCapabilities>
         <DescribeFeatureType>
            <SchemaDescriptionLanguage>
               <XMLSCHEMA/>
            </SchemaDescriptionLanguage>
            <DCPType>
               <HTTP>
                  <Post onlineResource="http://www.myserver.com/post?"/>
               </HTTP>
            </DCPType>
         </DescribeFeatureType>
         <GetFeature>
            <ResultFormat>
               <GML2/>
            </ResultFormat>
            <DCPType>
               <HTTP>
                  <Post onlineResource="http://www.myserver.com/post?"/>
               </HTTP>
            </DCPType>
         </GetFeature>
         <GetFeatureWithLock>
            <ResultFormat>
               <GML2/>
            </ResultFormat>
            <DCPType>
               <HTTP>
                  <Post onlineResource="http://www.myserver.com/post?"/>
               </HTTP>
            </DCPType>
         </GetFeatureWithLock>
         <Transaction>
            <DCPType>
               <HTTP>
                  <Post onlineResource="http://www.myserver.com/post?"/>
               </HTTP>
            </DCPType>
         </Transaction>
         <LockFeature>
            <DCPType>
               <HTTP>
                  <Post onlineResource="http://www.myserver.com/post?"/>
               </HTTP>
            </DCPType>
         </LockFeature>
      </Request>
   </Capability>
   <FeatureTypeList>
      <Operations>
         <Insert/>
         <Update/>
         <Delete/>
         <Query/>
         <Lock/>
      </Operations>
   </FeatureTypeList>
   <ogc:Filter_Capabilities>
      <ogc:Spatial_Capabilities>
         <ogc:Spatial_Operators>
            <ogc:BBOX/>
            <ogc:Equals/>
            <ogc:Disjoint/>
            <ogc:Intersect/>
            <ogc:Touches/>
            <ogc:Crosses/>
            <ogc:Within/>
            <ogc:Contains/>
            <ogc:Overlaps/>
            <ogc:Beyond/>
            <ogc:DWithin/>
         </ogc:Spatial_Operators>
      </ogc:Spatial_Capabilities>
      <ogc:Scalar_Capabilities>
         <ogc:Logical_Operators/>
         <ogc:Comparison_Operators>
            <ogc:Simple_Comparisons/>
            <ogc:Like/>
            <ogc:Between/>
            <ogc:NullCheck/>
         </ogc:Comparison_Operators>
         <ogc:Arithmetic_Operators>
            <ogc:Simple_Arithmetic/>
         </ogc:Arithmetic_Operators>
      </ogc:Scalar_Capabilities>
   </ogc:Filter_Capabilities>
</WFS_Capabilities>
';
begin
  SDO_WFS_PROCESS.insertCapabilitiesInfo (
    xmltype(capabilitiesXML));
end;
/

-- Commit the change
commit;
