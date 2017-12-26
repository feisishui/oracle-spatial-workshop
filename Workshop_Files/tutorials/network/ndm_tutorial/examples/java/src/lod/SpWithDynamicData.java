/* $Header: sdo/demo/network/examples/java/src/lod/SpWithDynamicData.java /main/4 2012/12/10 11:18:29 begeorge Exp $ */

/* Copyright (c) 2009, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   DESCRIPTION
    This class demonstrates how to use dynamic network information during
    network analysis.

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    begeorge    08/06/09 - Creation
 */

/**
 *  @version $Header: sdo/demo/network/examples/java/src/lod/SpWithDynamicData.java /main/4 2012/12/10 11:18:29 begeorge Exp $
 *  @author  begeorge
 *  @since   release specific (what release of product did this appear in)
 */
package lod;

import java.io.InputStream;
import java.io.PrintStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.StringTokenizer;

import oracle.jdbc.OracleConnection;
import oracle.jdbc.pool.OracleDataSource;

import oracle.spatial.network.UserDataMetadata;
import oracle.spatial.network.lod.DefaultLinkCostCalculator;
import oracle.spatial.network.lod.DefaultNodeCostCalculator;
import oracle.spatial.network.lod.DummyNodeCostCalculator;
import oracle.spatial.network.lod.DynamicLinkLevelSelector;
import oracle.spatial.network.lod.GeodeticCostFunction;
import oracle.spatial.network.lod.HeuristicCostFunction;
import oracle.spatial.network.lod.LODAnalysisInfo;
import oracle.spatial.network.lod.LODGoalNode;
import oracle.spatial.network.lod.LODNetworkConstraint;
import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.LinkCostCalculator;
import oracle.spatial.network.lod.LinkLevelSelector;
import oracle.spatial.network.lod.NetworkIO;
import oracle.spatial.network.lod.NetworkUpdate;
import oracle.spatial.network.lod.LogicalSubPath;
import oracle.spatial.network.lod.PointOnNet;
import oracle.spatial.network.lod.util.PrintUtility;
import oracle.spatial.util.Logger;

import oracle.spatial.network.lod.LogicalLightPath;
import oracle.spatial.network.lod.LogicalLink;
import oracle.spatial.network.lod.LogicalNetLink;
import oracle.spatial.network.lod.LogicalNetNode;
import oracle.spatial.network.lod.LogicalPath;
import oracle.spatial.network.lod.NetworkBuffer;
import oracle.spatial.network.lod.NodeCostCalculator;
import oracle.spatial.network.lod.OrderedLongSet;
import oracle.spatial.network.lod.SpatialPath;
import oracle.spatial.network.lod.SpatialSubPath;


import oracle.spatial.network.lod.TSP;
import oracle.spatial.network.lod.TspAnalysisInfo;
import oracle.spatial.network.lod.TspPath;
import oracle.spatial.network.lod.UserData;
import oracle.spatial.network.lod.config.ConfigManager;
import oracle.spatial.network.lod.config.LODConfig;

/**
 *  This class demonstrates how to use dynamic network information during
 *  network analysis.
 *  
 */

public class SpWithDynamicData
{
  private static NetworkAnalyst analyst;
  
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

  public static OracleConnection getConnection(String dbURL,
    String user, String password) throws SQLException
  {
    OracleConnection conn = null;
    OracleDataSource ds = new OracleDataSource();
    ds.setURL(dbURL);
    ds.setUser(user);
    ds.setPassword(password);
    conn = (OracleConnection)ds.getConnection();    
    conn.setAutoCommit(false);
    return conn;
  }
  
  public static void testShortestPath(long startNodeId, long endNodeId, 
    NetworkUpdate networkUpdate)
  {
    try
    {
      System.out.println("*****BEGIN: testShortestPath(" + 
                         startNodeId +" -> " + endNodeId + 
                         ", with" + ((networkUpdate!=null)?"":"out")
                         + " dynamic data"+
                         ")*****");

      HashMap<Integer, NetworkUpdate> networkUpdates = new HashMap<Integer, NetworkUpdate>();
      networkUpdates.put(1, networkUpdate);
      analyst.setNetworkUpdates(networkUpdates);
      LogicalSubPath path = analyst.shortestPathDijkstra(
        new PointOnNet(startNodeId), new PointOnNet(endNodeId), null);

      PrintUtility.print(System.out, path, true, 20, 0);
      System.out.println("*****END: testShortestPath*****");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
  
  public static void main(String[] args)
  {
    //Get input parameters
    String configXmlFile    = "lod/LODConfigs.xml";
    String logLevel    = "ERROR";

    String dbUrl       = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser      = "";
    String dbPassword  = "";

    /*
    To run tests on Hillsborough network,
    String networkName = "HILLSBOROUGH_NETWORK";
    long startNodeId   = 2589;
    long endNodeId     = 5579;
    long linkid = 145477921;


    To run the test on Navteq_SD network,
    String networkName = "NAVTEQ_SD";    
    long startNodeId   = 204762893;
    long endNodeId     = 359724269;
    long linkId        = 2041156943;
    */

    String networkName = "NAVTEQ_SF";
    long startNodeId   = 199535084;
    long endNodeId     = 199926436;
    long linkId        = 198752548;
    
    Connection conn    = null;

    //get input parameters
    for(int i=0; i<args.length; i++)
    {
      if(args[i].equalsIgnoreCase("-dbUrl"))
        dbUrl = args[i+1];
      else if(args[i].equalsIgnoreCase("-dbUser"))
        dbUser = args[i+1];
      else if(args[i].equalsIgnoreCase("-dbPassword"))
        dbPassword = args[i+1];
      else if(args[i].equalsIgnoreCase("-networkName") && args[i+1]!=null)
        networkName = args[i+1].toUpperCase();
      else if(args[i].equalsIgnoreCase("-startNodeId"))
        startNodeId = Long.parseLong(args[i+1]);
      else if(args[i].equalsIgnoreCase("-endNodeId"))
        endNodeId = Long.parseLong(args[i+1]);
      else if(args[i].equalsIgnoreCase("-linkId"))
        linkId = Long.parseLong(args[i+1]);
      else if(args[i].equalsIgnoreCase("-configXmlFile"))
        configXmlFile = args[i+1];
      else if(args[i].equalsIgnoreCase("-logLevel"))
        logLevel = args[i+1];
    }
    
    System.out.println("Network analysis result for "+networkName);
    
    try{
      setLogLevel(logLevel);
      
      //load user specified LOD configuration (optional), otherwise default configuration will be used
      InputStream config = ClassLoader.getSystemResourceAsStream(configXmlFile);
      LODNetworkManager.getConfigManager().loadConfig(config);
      LODConfig c = LODNetworkManager.getConfigManager().getConfig(networkName);
      
      //get jdbc connection 
      conn = getConnection(dbUrl, dbUser, dbPassword);
      
      //get network input/output object
      NetworkIO reader = LODNetworkManager.getCachedNetworkIO(
                                      conn, networkName, networkName, null);
      
      int[] udc = {UserDataMetadata.DEFAULT_USER_DATA_CATEGORY};
      //construct dynamic data set
      NetworkUpdate networkUpdate = new NetworkUpdate();
      LogicalLink oldLink = reader.readLogicalLink(linkId, udc);
      LogicalLink newLink = (LogicalLink) oldLink.clone();
      newLink.setIsActive(false);
      int pid = reader.readNodePartitionId(newLink.getStartNodeId(), 1);
      networkUpdate.updateLink(newLink, pid);
      pid = reader.readNodePartitionId(newLink.getEndNodeId(), 1);
      networkUpdate.updateLink(newLink, pid);
      
      //get network analyst
      analyst = LODNetworkManager.getNetworkAnalyst(reader);
      
      testShortestPath(startNodeId, endNodeId, null);
      testShortestPath(startNodeId, endNodeId, networkUpdate);
    }
    catch(Exception ex)
    {
      ex.printStackTrace();
    }
    finally
    {
      if(conn!=null)
        try{conn.close();} catch(Exception ignore){}
    }
  }

}
