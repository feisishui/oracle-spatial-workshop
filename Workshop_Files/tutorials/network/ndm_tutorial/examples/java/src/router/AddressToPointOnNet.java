/* $Header: sdo/demo/network/examples/java/src/router/AddressToPointOnNet.java /main/2 2012/12/10 11:18:29 begeorge Exp $ */

/* Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved. */

/*
   DESCRIPTION
    <short description of component this file declares/defines>

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    hgong       07/11/12 - Creation
 */
package router;

import java.io.InputStream;

import java.sql.Connection;

import java.util.ArrayList;
import java.util.Iterator;

import java.util.StringTokenizer;

import oracle.spatial.geocoder.client.GeocoderAddress;
import oracle.spatial.geocoder.client.HttpClientGeocoder;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.NetworkIO;
import oracle.spatial.network.lod.PointOnNet;
import oracle.spatial.network.apps.router.RouterUtil;
import oracle.spatial.util.Logger;

/**
 *  This example shows how to call router utility java API to convert an array
 *  of geocoded addresses to PointOnNet objects.
 *  @version $Header: sdo/demo/network/examples/java/src/router/AddressToPointOnNet.java /main/2 2012/12/10 11:18:29 begeorge Exp $
 *  @author  hgong   
 *  @since   12.1
 */
public class AddressToPointOnNet
{
  private static final Logger logger = Logger.getLogger("AddressToPointOnNet");
  
  private static void setLogLevel(String logLevel)
  {
    if("FATAL".equalsIgnoreCase(logLevel))
        Logger.setGlobalLevel(Logger.LEVEL_FATAL);
    else if("ERROR".equalsIgnoreCase(logLevel))
        Logger.setGlobalLevel(Logger.LEVEL_ERROR);
    else if("WARN".equalsIgnoreCase(logLevel))
        Logger.setGlobalLevel(Logger.LEVEL_WARN);
    else if("INFO".equalsIgnoreCase(logLevel))
        Logger.setGlobalLevel(Logger.LEVEL_INFO);
    else if("DEBUG".equalsIgnoreCase(logLevel))
        Logger.setGlobalLevel(Logger.LEVEL_DEBUG);
    else if("FINEST".equalsIgnoreCase(logLevel))
        Logger.setGlobalLevel(Logger.LEVEL_FINEST);
    else  //default: set to ERROR
        Logger.setGlobalLevel(Logger.LEVEL_ERROR);
  }

  public static HttpClientGeocoder getGeocoder(String geocoderUrl)
  {
    String proxyHost = null;
    int proxyPort = -1;
    return new HttpClientGeocoder(geocoderUrl, proxyHost, proxyPort);
  }
  
  private static GeocoderAddress parseStreetAddress(String address)
  {
    GeocoderAddress ga = new GeocoderAddress();
    StringTokenizer st = new StringTokenizer(address, ",");
    //street number and name
    if(st.hasMoreTokens())
      ga.setStreet(st.nextToken());
    String lastLine = null;
    if(st.hasMoreTokens())
      lastLine = st.nextToken();
    while(st.hasMoreTokens())
      lastLine += ", " + st.nextToken();
    ga.setLastLine(lastLine);
    return ga;
  }

  private static ArrayList<GeocoderAddress> geocodeAddresses(String[] addresses, String geocoderUrl)
    throws Exception
  {
    HttpClientGeocoder geocoder = new HttpClientGeocoder(
      geocoderUrl, null, -1);
    ArrayList<GeocoderAddress> inputAddresses = new ArrayList<GeocoderAddress>();
    for(int i=0; i<addresses.length; i++)
    {
      GeocoderAddress ga = parseStreetAddress(addresses[i]);
      inputAddresses.add(ga);
    }
    logger.info("BEGIN: Calling batchGeocode...");
    ArrayList outputAddresses = geocoder.batchGeocode(inputAddresses);
    logger.info("END: Calling batchGeocode.");
    
    ArrayList<GeocoderAddress> geocodedAddresses = new ArrayList<GeocoderAddress>();
    for(Iterator it=outputAddresses.iterator(); it.hasNext(); )
    {
      ArrayList addressList = (ArrayList)it.next();
      if(addressList!=null && addressList.size()>0)
        geocodedAddresses.add((GeocoderAddress)addressList.get(0));
    }
    return geocodedAddresses;
  }

  public static void main(String[] args) throws Exception
  {
    String configXmlFile = "lod/LODConfigs.xml";
    String logLevel    =    "ERROR";

    String dbUrl       = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser      = "";
    String dbPassword  = "";
    
    String geocoderUrl = "http://localhost:7001/geocoder/gcserver";

    String networkName = "NAVTEQ_SF";
    String startAddress = "747 Howard St,san francisco, ca";
    String endAddress = "100 flower st,san francisco, ca";

    //get input parameters
    for(int i=0; i<args.length; i++)
    {
      if(args[i].equalsIgnoreCase("-dbUrl"))
        dbUrl = args[i+1];
      else if(args[i].equalsIgnoreCase("-dbUser"))
        dbUser = args[i+1];
      else if(args[i].equalsIgnoreCase("-dbPassword"))
        dbPassword = args[i+1];
      else if(args[i].equalsIgnoreCase("-networkName"))
        networkName = args[i+1].toUpperCase();
      else if(args[i].equalsIgnoreCase("-configXmlFile"))
        configXmlFile = args[i+1];
      else if(args[i].equalsIgnoreCase("-logLevel"))
        logLevel = args[i+1];
      else if(args[i].equalsIgnoreCase("-startAddress"))
        startAddress = args[i+1];
      else if(args[i].equalsIgnoreCase("-endAddress"))
        endAddress = args[i+1];
    }
    
    setLogLevel(logLevel);
    InputStream configXml = ClassLoader.getSystemResourceAsStream(configXmlFile);
    LODNetworkManager.getConfigManager().loadConfig(configXml);
    Connection conn = LODNetworkManager.getConnection(dbUrl, dbUser, dbPassword);
    NetworkIO nio = LODNetworkManager.getCachedNetworkIO(conn, networkName, networkName, null);
    String[] addresses = {startAddress, endAddress};
    ArrayList<GeocoderAddress> geocodedAddresses = geocodeAddresses(addresses, geocoderUrl);
    //Call router utility API to map geocoded addresses to points on the network.
    PointOnNet[][] points = RouterUtil.addressToPointOnNet(geocodedAddresses, 'R', nio);    
    //Now you can call NDM analysis functions with the above points.
    //...
  }
}

