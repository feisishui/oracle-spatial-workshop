/* $Header: sdo/demo/network/examples/java/src/lod/TspAnalysis.java /main/5 2012/12/10 11:18:29 begeorge Exp $ */

/* Copyright (c) 2009, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   DESCRIPTION
    This test class demonstrates how to use the Load-On-Demand (LOD) API to  
    conduct TSP (closed and open tour) analysis without constraints.

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    hgong       08/24/10 - remove tsp linkLevel
    begeorge    08/06/09 - Creation
    begeorge    09/04/09 - Add TSP with Astar 
 */

/**
 *  @version $Header: sdo/demo/network/examples/java/src/lod/TspAnalysis.java /main/5 2012/12/10 11:18:29 begeorge Exp $
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
import oracle.spatial.network.lod.DefaultPairwiseCostCalculator;
import oracle.spatial.network.lod.DefaultPairwiseShortestPaths;
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
import oracle.spatial.network.lod.PairwiseCostCalculator;

import oracle.spatial.network.lod.NetworkIO;
import oracle.spatial.network.lod.NetworkBuffer;
import oracle.spatial.network.lod.NetworkExplorer;
import oracle.spatial.network.lod.LogicalSubPath;
import oracle.spatial.network.lod.PointOnNet;
import oracle.spatial.network.lod.util.PrintUtility;
import oracle.spatial.util.Logger;
import oracle.spatial.network.lod.LogicalLightPath;
import oracle.spatial.network.lod.LogicalLink;
import oracle.spatial.network.lod.LogicalNetLink;
import oracle.spatial.network.lod.LogicalNetNode;
import oracle.spatial.network.lod.LogicalPath;
import oracle.spatial.network.lod.NodeCostCalculator;
import oracle.spatial.network.lod.OrderedLongSet;
import oracle.spatial.network.lod.SpatialPath;
import oracle.spatial.network.lod.SpatialSubPath;

import oracle.spatial.network.lod.ShortestPath;
import oracle.spatial.network.lod.AStar;
import oracle.spatial.network.lod.TSP;
import oracle.spatial.network.lod.TspOp2;
import oracle.spatial.network.lod.TspAnalysisInfo;
import oracle.spatial.network.lod.TspPath;
import oracle.spatial.network.lod.YenDeviation;
import oracle.spatial.network.lod.UserData;
import oracle.spatial.network.lod.config.ConfigManager;
import oracle.spatial.network.lod.config.LODConfig;

public class TspAnalysis
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

public static void main(String[] args) throws Exception
  {
    String configXmlFile = "lod/LODConfigs.xml";
    String logLevel    =   "ERROR"; 
        
    String dbUrl       = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser      = "";
    String dbPassword  = "";

   /*
   To run the test on Hillsborough network
   String networkName = "HILLSBOROUGH_NETWORK";
   long[] tspNodeIds = {1001,1506,2505,2703};

   To run test on Navteq_SD network
   String networkName = "NAVTEQ_SD";
   long startNodeId     = 204762893; 
   long endNodeId       = 359724269; 
   long[] tspNodeIds = {204762751,204762873,359724269,384589278};
   */
   String networkName = "NAVTEQ_SF";
   long [] tspNodeIds = {199444894,199626367,199628383,199355161};
    
    long startLinkId;
    long endLinkId;
    int numNeighbors   = 10;
    double withinCost  = 200;
    int linkLevel      = 1;  //default link level
    
    long [] links = null;
    long [] nodes = null;
    LogicalPath path;
    LogicalPath path_2;
    LogicalPath nnPath;
    long pathId;
    String pathName;
    String pathType;
    
    
    double costThreshold = 1550;
    int numHighLevelNeighbors = 8;
    double costMultiplier = 1.5;
    
    int xUserDataIndex = 0;
    int yUserDataIndex = 1;
    
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
         boolean isOpenTsp = false;
         PointOnNet[][] tspNodes = nodeIdsToPoints(tspNodeIds);

 /////////////////////////////////////////////////////////////////////////////////////                    
         System.out.println("*****BEGIN: testTSP (Dijkstra) without constraints*****");
         
        // Open TSP tour
         TSP.TourFlag tourFlag = TSP.TourFlag.OPEN;
         System.out.println("Open TSP tour without constraints");
         TspPath tspPath = analyst.tsp(tspNodes, tourFlag, null);
         PrintUtility.print(System.out, tspPath, tspNodes, true, 20, 0);
         
         // Closed TSP tour
         tourFlag = TSP.TourFlag.CLOSED;
         System.out.println("Closed TSP tour wihtout constraints");
         tspPath = analyst.tsp(tspNodes, tourFlag, null);
         PrintUtility.print(System.out, tspPath, tspNodes, true, 20, 0);
         
         System.out.println("*****END: testTSP (Dijkstra) without constraints*****");
///////////////////////////////////////////////////////////////////////////////////////

         System.out.println("*****BEGIN: testTSP (AStar) without constraints*****");
	       NetworkExplorer ne = new NetworkExplorer(networkIO);
         LinkCostCalculator[] lccs = analyst.getLinkCostCalculators();
         NodeCostCalculator[] nccs = analyst.getNodeCostCalculators();
         HeuristicCostFunction astarCostFunction =
           new GeodeticCostFunction(
                                    UserDataMetadata.DEFAULT_USER_DATA_CATEGORY,
                                    xUserDataIndex, yUserDataIndex, -1);

         LinkLevelSelector lls = new DynamicLinkLevelSelector(
                                     analyst, linkLevel, astarCostFunction, costThresholds,
                                     numHighLevelNeighbors, costMultiplier, null);
         ShortestPath astar = new AStar(ne, lccs, nccs, astarCostFunction, lls);

         PairwiseCostCalculator pwcc = new DefaultPairwiseCostCalculator
                                      (new DefaultPairwiseShortestPaths(ne, lccs, nccs, astar));
         TSP tspAlgorithm = new TspOp2(lccs, nccs, astar, pwcc);

	 // Open TSP tour
	 tourFlag = TSP.TourFlag.OPEN;
         System.out.println("Open TSP tour without constraints");
         tspPath = analyst.tsp(tspNodes, tourFlag, null, tspAlgorithm);
	 PrintUtility.print(System.out, tspPath, tspNodes, true, 20, 0);

        // Closed TSP tour
        tourFlag = TSP.TourFlag.CLOSED;
	System.out.println("Closed TSP tour without constraints");
	tspPath = analyst.tsp(tspNodes, tourFlag, null, tspAlgorithm);
	PrintUtility.print(System.out, tspPath, tspNodes, true, 20, 0);

        System.out.println("*****END: testTSP (AStar) without constraints*****");	 
////////////////////////////////////////////////////////////////////////////////////////////        
      }
      catch (Exception e)
      {
        e.printStackTrace();
      }


    if(conn!=null)
      try{conn.close();} catch(Exception ignore){}

  }
}
