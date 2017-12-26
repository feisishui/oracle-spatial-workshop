/* $Header: sdo/demo/network/examples/java/src/lod/SpWithTurnPenalties.java /main/5 2012/12/10 11:18:29 begeorge Exp $ */

/* Copyright (c) 2009, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   DESCRIPTION
    This test class demonstrates how to use the Load-On-Demand (LOD) API to  
    conduct shortest path analysis with turn penalties. Turn penalties are 
    associated with link pairs (start link Id, end Link Id). 

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    begeorge    08/06/09 - Creation
 */

/**
 *  @version $Header: sdo/demo/network/examples/java/src/lod/SpWithTurnPenalties.java /main/5 2012/12/10 11:18:29 begeorge Exp $
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

public class SpWithTurnPenalties
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

    
private static void addTurnPenaltiesToCost() {
      // set link cost calculators to add turn penalties wherever applicable
      LinkCostCalculator [] lccs = {new TurnPenaltyCalculator() };
      analyst.setLinkCostCalculators(lccs);
      // Use default node cost calculator
      NodeCostCalculator [] nccs = {
          DefaultNodeCostCalculator.getNodeCostCalculator() };
      analyst.setNodeCostCalculators(nccs);   
}
      
public static void main(String[] args) throws Exception
  {
    String configXmlFile = "lod/LODConfigs.xml";
    String logLevel    =    "ERROR"; 
        
    String dbUrl       = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser      = "";
    String dbPassword  = "";

    /*
    To run test on Hillsborough network
    String networkName = "HILLSBOROUGH_NETWORK";
    long  startNodeId = 2589;
    long  endNodeId   = 5579;

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
    int numHighLevelNeighbors = 8;
    double costMultiplier = 1.5;
    int geometryUserDataIndex = -1;
    int xCoordUserDataIndex = 0;
    int yCoordUserDataIndex = 1;
    
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
///////// Shortest Path with Turn Penalties///////////////////////

 System.out.println("*****Begin: Dijkstra Shortest Path with Turn Penalties for "+networkName);
 
 System.out.println("Dijkstra Shortest Path Analysis without Turn Penalties");
 LogicalSubPath turnPenaltyPath = analyst.shortestPathDijkstra(
                    new PointOnNet(startNodeId), new PointOnNet(endNodeId), null);
 PrintUtility.print(System.out, turnPenaltyPath, true, Integer.MAX_VALUE,0);
 
 System.out.println("Dijkstra Shortest Path Analysis WITH Turn Penalties.");
 addTurnPenaltiesToCost();
 turnPenaltyPath = analyst.shortestPathDijkstra(
                   new PointOnNet(startNodeId), new PointOnNet(endNodeId), null);
 PrintUtility.print(System.out, turnPenaltyPath, true, Integer.MAX_VALUE, 0);
 System.out.println("*****End: Dijkstra Shortest Path with Turn Penalties.");
//////////////////////////////////////////////////////////////////////

 System.out.println("*****Begin: Astar Shortest Path with Turn Penalties for "+networkName);
 HeuristicCostFunction ascf = new GeodeticCostFunction(
             UserDataMetadata.DEFAULT_USER_DATA_CATEGORY,
             xCoordUserDataIndex, yCoordUserDataIndex, geometryUserDataIndex);
 LinkLevelSelector lls = new DynamicLinkLevelSelector(analyst, linkLevel, ascf, costThresholds,
             numHighLevelNeighbors, costMultiplier, null);
 turnPenaltyPath = analyst.shortestPathAStar(new PointOnNet(startNodeId),
                                new PointOnNet(endNodeId), null, ascf, lls);
 PrintUtility.print(System.out, turnPenaltyPath, true, Integer.MAX_VALUE,0);
 System.out.println("*****End: Astar Shortest Path with Turn Penalties for "+networkName);
 
/////////////////////////////////////////////////////////////////////////
      }
      catch (Exception e)
      {
        e.printStackTrace();
      }


    if(conn!=null)
      try{conn.close();} catch(Exception ignore){}

  }
 
    /**
     *  Construct turns as (start link, end link) pairs
     *  use a hashMap to represent turns with penalties
     *  startLink IDs as keys and the pairs (end Link Id, penalty) as values
     */
         
    private static class TurnPenaltyCalculator implements LinkCostCalculator
    {  
      // prohibited turns information
       private Map<Long, long[]> pTurnPenaltyMap = new HashMap(); 
      
      // construct prohibited turns information
      // add start link and end links of turns with penalty

          /*
          For Hillsborough network
          long [] startLinkIDs = {145477921};
          long [][] endLinkIDPenalty = {{145477920,200}};

          For Navteq_SD network
          long [] startLinkIDs = {204156943,203965529};
          long [][] endLinkIDPenalty = {{204512368,10},{203889653,20}};
          */
          long [] startLinkIDs = {198752548};
          long [][] endLinkIDPenalty = {{198723516,20}};
          
        public double getLinkCost(LODAnalysisInfo analysisInfo)
       {
          for ( int i = 0; i < startLinkIDs.length ;i++)
            pTurnPenaltyMap.put(startLinkIDs[i], endLinkIDPenalty[i]);
      
      // check if the given turn (start link ID, end link ID) has a 
      // turn penalty; if so, return the penalty
       if (analysisInfo.getCurrentLink() != null) {
          LogicalLink Link = analysisInfo.getCurrentLink();
          long currentLinkId = Link.getId();
          LogicalLink NextLink = analysisInfo.getNextLink();
          long nextLinkId = NextLink.getId();
          double linkCost = NextLink.getCost();
          if ( pTurnPenaltyMap == null ) // no turn penalty
            return linkCost;
          else {        
            long [] turnPenalties = 
                    pTurnPenaltyMap.get(currentLinkId);
            if ( turnPenalties == null )
               return linkCost;
            else {
               for ( int i = 0; i < turnPenalties.length; i++) { 
                  if ( turnPenalties[i] == nextLinkId)
                      return linkCost+turnPenalties[i+1]; // return turn penalty
               }
               return linkCost;   
            }
        }
       }
       else    {
           LogicalLink NextLink = analysisInfo.getNextLink();
           double linkCost = NextLink.getCost();
           return linkCost;
       }
    }
      
      public int getNumberOfUserObjects() { return 0 ; }

      public int[] getUserDataCategories()
      {
        return null;
      }
    }
}
