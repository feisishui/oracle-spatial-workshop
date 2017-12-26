Rem
Rem $Header: sdo/demo/network/examples/plsql/ndmws.sql /main/2 2011/10/06 13:52:21 hgong Exp $
Rem
Rem ndmws.sql
Rem
Rem Copyright (c) 2010, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      ndmws.sql
Rem
Rem    DESCRIPTION
Rem      Example on how to call NDM Web Service from PLSQL client
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       10/14/10 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

SET SERVEROUTPUT ON

DECLARE
  ndmws_url varchar2(4000);
  xml_request varchar2(4000); 
  xml_response xmltype;
BEGIN
  ndmws_url := 'http://localhost:7001/SpatialWS-SpatialWS-context-root/SpatialWSXmlServlet';
  xml_request :=
'<?xml version="1.0" ?>
<networkAnalysisRequest
   xmlns="http://xmlns.oracle.com/spatial/network"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xmlns:gml="http://www.opengis.net/gml">
  <networkName>NAVTEQ_SF</networkName>
  <shortestPath>
    <startPoint>
      <nodeID>199520844</nodeID>
    </startPoint>
    <endPoint>
      <nodeID>199652792</nodeID>
    </endPoint>
    <constraint>
      <className>custom.ProhibitedZoneConstraint</className>
      <parameters>
        <prohibitedLinks>198948086 -198948086 198888450 -198888450 198855600 -198855600 -198839651 198839651 198855359 -198855359 198991077 -198843906 198843906 -198991077 -198784737 198784737 199002315 -199002315 -198774825 198774825 199112417 -199112417 915150608 -915150608 -199101044 199101044 915150609 -915150609 -199019754 198947228 -198947228 199019754 199069927 -199069927 199108382 -199108382 -199031133 199031133 198961680 -198961680 -198993224 198993224 198917460 -198917460 -198797704 -198933059 198933059 198797704 -198868150 -198884568 198868150 198884568 198647330 -198647330 198905052 -198905052 -199094290 199094290 -198610152 198610152 198943159 -198943159 199122328 -199122328 -198950504 198950504 -199042723 198883566 199042723 -198883566 </prohibitedLinks>
        <prohibitedNodes>199459625 199514127 199742411 199722431 199788589 199686046 199424489 199491652 915150607 199381179 199413306 199481657 199474081 199623184</prohibitedNodes>
      </parameters>
    </constraint>
    <subPathRequestParameter>
      <cost> true </cost>
      <isFullPath> true </isFullPath>
      <startLinkIndex> true </startLinkIndex>
      <startPercentage> true </startPercentage>
      <endLinkIndex> true </endLinkIndex>
      <endPercentage> true </endPercentage>
      <pathRequestParameter>
        <cost> true </cost>
        <isSimple> true </isSimple>
        <startNodeID>true</startNodeID>
        <endNodeID>true</endNodeID>
        <noOfLinks>true</noOfLinks>
        <linksRequestParameter>
          <onlyLinkID>true</onlyLinkID>
        </linksRequestParameter>
        <nodesRequestParameter>
          <onlyNodeID>true</onlyNodeID>
        </nodesRequestParameter>
      </pathRequestParameter>
    </subPathRequestParameter>
  </shortestPath>
</networkAnalysisRequest>
';
  xml_response := sdo_net.POST_XML(ndmws_url, XMLTYPE(xml_request));
  dbms_output.put_line(xml_response.getStringVal());
END;
/
show errors;

