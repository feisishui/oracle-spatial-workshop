/* $Header: sdo/demo/network/examples/java/src/lod/SpWithMultiLinkCosts.java /main/8 2012/12/10 11:18:29 begeorge Exp $ */

/* Copyright (c) 2009, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   DESCRIPTION
    This test class demonstrates how to use the Load-On-Demand (LOD) API to  
    conduct network analysis with multiple link costs. The test runs shortest path 
    analysis with link costs as (i) default cost (ii) travel time (iii) default cost
    as primary cost (iv) travel time as primary cost and (v) travel time as constraint
    cost (maximum travel time constraint).

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    begeorge    07/30/10 - Modify to read speed limit from user data
    begeorge    08/06/09 - Creation
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
import oracle.spatial.router.ndm.RouterPartitionBlobTranslator11gR2;
import oracle.spatial.network.lod.TSP;
import oracle.spatial.network.lod.TspAnalysisInfo;
import oracle.spatial.network.lod.TspPath;
import oracle.spatial.network.lod.UserData;
import oracle.spatial.network.lod.config.ConfigManager;
import oracle.spatial.network.lod.config.LODConfig;
import oracle.spatial.router.ndm.RouterPartitionBlobTranslator11gR2;

public class SpWithMultiLinkCosts
{
  private static final NumberFormat formatter = new DecimalFormat("#.######");
  
  private static NetworkAnalyst analyst;
  private static NetworkIO networkIO;
  
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
  
  private static OracleConnection getConnection(String dbURL,
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

private static PointOnNet[][] nodeIdsToPoints(long[] nodeIds)
{
    PointOnNet[][] points = new PointOnNet[nodeIds.length][1];
    for(int i=0; i<points.length; i++)
      points[i][0] = new PointOnNet(nodeIds[i]);
    return points;
}
  
private static long[] parseLongIds(String idString)
{
    if (idString != null )
      idString = idString.trim() ;
    else
      return null;
    StringTokenizer st = new StringTokenizer(idString,"+ ");
    int no = st.countTokens();
    long [] ids = new long[no];
    int count = 0;
    while (st.hasMoreTokens()) 
    {
      long id = Long.parseLong(st.nextToken());
      ids[count++] = id;
    }
    return ids;
}

    private static void setTravelTimeAsCost()
    {
      //set link cost calculator
      LinkCostCalculator[] lccs = { new TravelTimeCalculator() };
      analyst.setLinkCostCalculators(lccs);
      //Use default node cost calculator
      NodeCostCalculator[] nccs = {
        DefaultNodeCostCalculator.getNodeCostCalculator() };
      analyst.setNodeCostCalculators(nccs);
    }

    private static void setDefaultCostAsPrimaryCost()
    {
      //set link cost calculators
      LinkCostCalculator[] lccs = { 
        DefaultLinkCostCalculator.getLinkCostCalculator(),
        new TravelTimeCalculator() };
      analyst.setLinkCostCalculators(lccs);
      //set node cost calculators
      NodeCostCalculator[] nccs = {
        DefaultNodeCostCalculator.getNodeCostCalculator(), 
        new DummyNodeCostCalculator()};
      analyst.setNodeCostCalculators(nccs);
    }

    private static void setTravelTimeAsPrimaryCost()
    {
      //set link cost calculators
      LinkCostCalculator[] lccs = { 
        new TravelTimeCalculator(),
        DefaultLinkCostCalculator.getLinkCostCalculator() };
      analyst.setLinkCostCalculators(lccs);
      //set node cost calculators
       NodeCostCalculator[] nccs = {
         DefaultNodeCostCalculator.getNodeCostCalculator(), 
         new DummyNodeCostCalculator()};
      analyst.setNodeCostCalculators(nccs);
    }
    
    private static void testShortestPath(long startNodeId, long endNodeId,
      LODNetworkConstraint constraint)
    {
      try
      {
        System.out.println("*****BEGIN: testShortestPath(" + 
                           startNodeId +" -> " + endNodeId +
                           ")*****");
        LogicalSubPath subPath =
          analyst.shortestPathDijkstra(new PointOnNet(startNodeId), 
            new PointOnNet(endNodeId), constraint);

        PrintUtility.print(System.out, subPath, true, 20, 0);
        System.out.println("*****END: testShortestPath*****");
      }
      catch (Exception e)
      {
        e.printStackTrace();
      }
    }
  public static void main(String[] args) throws Exception
  {
    String configXmlFile = "lod/LODConfigs.xml";
    String logLevel    =    "ERROR"; 
        
    String dbUrl       = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser      = "";
    String dbPassword  = "";

    /* To run test on Hillsborough network
    String networkName = "HILLSBOROUGH_NETWORK";
    long startNodeId = 2589;
    long endNodeId   = 5579;

    To run test on Navteq_SD network
    String networkName = "NAVTEQ_SD";
    long startNodeId     = 204762893; 
    long endNodeId       = 359724269; 
    */
    String networkName = "NAVTEQ_SF";
    long startNodeId        = 199535084;
    long endNodeId          = 199926436;
    int linkLevel      = 1;  //default link level
    double costThreshold = 1550;
    
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
        else if(args[i].equalsIgnoreCase("-linkLevel"))
          linkLevel = Integer.parseInt(args[i+1]);
        else if(args[i].equalsIgnoreCase("-configXmlFile"))
          configXmlFile = args[i+1];
        else if(args[i].equalsIgnoreCase("-logLevel"))
          logLevel = args[i+1];
      }
 
    // opening connection
    conn = LODNetworkManager.getConnection(dbUrl, dbUser, dbPassword);

    Statement stmt = conn.createStatement();
    
    System.out.println("Network analysis for "+networkName);

    setLogLevel(logLevel);
    
    //load user specified LOD configuration (optional), 
    //otherwise default configuration will be used
    InputStream config = ClassLoader.getSystemResourceAsStream(configXmlFile);
    LODNetworkManager.getConfigManager().loadConfig(config);
    LODConfig c = LODNetworkManager.getConfigManager().getConfig(networkName);
    
    //get network input/output object
    networkIO = LODNetworkManager.getCachedNetworkIO(
                                    conn, networkName, networkName, null);
    
    //get network analyst
    analyst = LODNetworkManager.getNetworkAnalyst(networkIO);
  
    double[] costThresholds = {costThreshold}; 
  
      try
      {
//////////////////////////////////////////////////////////////////////////////////////////////
          System.out.println("*****Begin: Network analysis with multiple costs for "+networkName);
          
          double maxTravelTime = 400;
          System.out.println("Shortest path analysis using default cost as the only cost");
          testShortestPath(startNodeId, endNodeId, null);
          
          System.out.println("Shortest path analysis using travel time as the only cost");
          setTravelTimeAsCost();
          testShortestPath(startNodeId, endNodeId, null);

          System.out.println("Shortest path analysis using default cost as primary cost");
          setDefaultCostAsPrimaryCost();
          testShortestPath(startNodeId, endNodeId, null);

          System.out.println("Shortest path analysis using travel time as primary cost");
          setTravelTimeAsPrimaryCost();
          testShortestPath(startNodeId, endNodeId, null);
          
          System.out.println("Shortest path analysis using travel time as constraint cost");
          setDefaultCostAsPrimaryCost();
          LODNetworkConstraint constraint = new TravelTimeConstraint(maxTravelTime);
          testShortestPath(startNodeId, endNodeId, constraint);
          System.out.println("*****End: Network Analysis with Multiple Costs");
          
/////////////////////////////////////////////////////////////////////////////////////////////
      }
      catch (Exception e)
      {
        e.printStackTrace();
      }


    if(conn!=null)
      try{conn.close();} catch(Exception ignore){}

  }
 
    private static class TravelTimeCalculator implements LinkCostCalculator
    {
      int [] defaultUserDataCategories = {UserDataMetadata.DEFAULT_USER_DATA_CATEGORY};

      public TravelTimeCalculator () {
      }
      
      public double getLinkCost(LODAnalysisInfo analysisInfo)
      {
        LogicalLink link = analysisInfo.getNextLink();
 
       // speed in meters/second
       double speed = ((Double)link.getUserData(0).get
                      (RouterPartitionBlobTranslator11gR2.USER_DATA_INDEX_SPEED_LIMIT)).doubleValue();
       return (link.getCost()/speed);         // travel time in seconds
      }
      
      public int[] getUserDataCategories()
      {
        return defaultUserDataCategories;
      }
    }
    
    private static class TravelTimeConstraint implements LODNetworkConstraint
    {
      double maxTravelTime;
      
      TravelTimeConstraint(double maxTravelTime)
      {
        this.maxTravelTime = maxTravelTime;
      }
      
      public boolean isSatisfied(LODAnalysisInfo info)
      {
        double[] nextCosts = info.getNextCosts();
        if(nextCosts[1] <= maxTravelTime)
          return true;
        else
          return false;
      }
      
      public int getNumberOfUserObjects()
      {
        return 0;
      }
      
      public boolean isCurrentNodePartiallyExpanded(LODAnalysisInfo info)
      { 
        return false;
      }

      public boolean isNextNodePartiallyExpanded(LODAnalysisInfo info)
      {
        return false;
      }

      public int[] getUserDataCategories()
      {
        return null;
      }

      public void reset()
      {
      }

    public void setNetworkAnalyst(NetworkAnalyst analyst)
    {
    }
  }
}
