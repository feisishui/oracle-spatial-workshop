/* $Header: sdo/demo/network/examples/java/src/lod/TspNodeOrder.java /main/6 2012/12/10 11:18:29 begeorge Exp $ */

/* Copyright (c) 2009, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   DESCRIPTION
    This test class demonstrates how to use the Load-On-Demand (LOD) API to  
    conduct TSP analysis with node order constraints. In the computed TSP tour,
    the nodes will be visited in the same order as the one specified in the constraint.

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    hgong       08/24/10 - remove tsp linkLevel
    begeorge    08/06/09 - Creation
 */

/**
 *  @version $Header: sdo/demo/network/examples/java/src/lod/TspNodeOrder.java /main/6 2012/12/10 11:18:29 begeorge Exp $
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
import oracle.spatial.network.lod.PairwiseCostCalculator;
import oracle.spatial.network.lod.DynamicLinkLevelSelector;
import oracle.spatial.network.lod.GeodeticCostFunction;
import oracle.spatial.network.lod.HeuristicCostFunction;
import oracle.spatial.network.lod.LODAnalysisInfo;
import oracle.spatial.network.lod.LODGoalNode;
import oracle.spatial.network.lod.LODNetworkConstraint;
import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.NetworkExplorer;
import oracle.spatial.network.lod.LinkCostCalculator;
import oracle.spatial.network.lod.LinkLevelSelector;
import oracle.spatial.network.lod.DefaultPairwiseCostCalculator;
import oracle.spatial.network.lod.DefaultPairwiseShortestPaths;
import oracle.spatial.network.lod.DynamicLinkLevelSelector;
import oracle.spatial.network.lod.GeodeticCostFunction;
import oracle.spatial.network.lod.HeuristicCostFunction;
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

public class TspNodeOrder
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
    String logLevel    =    "ERROR"; 
        
    String dbUrl       = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser      = "";
    String dbPassword  = "";

    /*
    To run the test on Hillsborough network
    String networkName = "HILLSBOROUGH_NETWORK";
    long[] tspNodeToVisit = {1001,1506,2505,2703};;
    long [] tspNodesInOrder1 = {1506,2703};

    To run test on Navteq_SD network
    String networkName = "NAVTEQ_SD";
    long startNodeId     = 204762893; 
    long endNodeId       = 359724269; 
    long [] tspNodesToVisit = {204762751,204762873,359724269,384589278};
    long [] tspNodesInOrder1 = {204762873,384589278}; //nodes visited in this order
    long[] tspNodesInOrder2 =  {359724269,384589278}; // nodes visited in this order
    */   
    String networkName = "NAVTEQ_SF";
    long [] tspNodesToVisit = {199444894,199626367,199628383,199355161};
    long [] tspNodesInOrder1 = {199626367,199355161};
    long [] tspNodesInOrder2 = {199628383,199444894};
    int linkLevel      = 1;  //default link level
    double costThreshold = 1550;
    int numHighLevelNeighbors = 8;
    double costMultiplier = 1.5;
    
    int xUserDataIndex = 0;
    int yUserDataIndex = 1;
    
    int k=10; //k-shortest path analysis
    
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
////////TSP with node order constraint///////////////////////////////////////////
 costMultiplier = 1;
 
 costThreshold = 10000;
 numHighLevelNeighbors = 4;
 
 linkLevel = 1;
                                                                                   
                                                                                   
 TSP.TourFlag tourFlag = TSP.TourFlag.OPEN;
 System.out.println("*****BEGIN: TSP (Astar) with Node Order Constraints ***** ");

            PointOnNet [][] tspNodePointsToVisit = nodeIdsToPoints(tspNodesToVisit);
            PointOnNet [][] tspNodePointsInOrder1 = nodeIdsToPoints(tspNodesInOrder1);
            
            PointOnNet [][] tspNodePointsInOrder2 = nodeIdsToPoints(tspNodesInOrder2);

            System.out.println("TSP tour on link level "+linkLevel+ " for points [");
            for (int i=0; i < tspNodePointsToVisit.length; i++) {
                System.out.print(tspNodePointsToVisit[i][0]+" ");
            }
            System.out.println("]");

            //construct tsp node order constraint 
            TspNodeOrderConstraint orderConstraint1 = new TspNodeOrderConstraint(
            tspNodePointsToVisit, tspNodePointsInOrder1);
            TspNodeOrderConstraint orderConstraint2 = new TspNodeOrderConstraint(
            tspNodePointsToVisit, tspNodePointsInOrder2);

	     //construct 2op tsp algorithm using A* shortest path to compute pairwise distance.
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

            System.out.println("Test open tsp tour without constraint");
            TspPath tspPath = analyst.tsp(tspNodePointsToVisit, TSP.TourFlag.OPEN,
            null, tspAlgorithm);
    	    PrintUtility.print(System.out,tspPath, tspNodePointsToVisit, true, 0, 0);
            System.out.println("End: Test open tsp tour without constraint");

	    System.out.println("Test open tsp tour WITH Constraint1 ");
            tspPath = analyst.tsp(tspNodePointsToVisit, TSP.TourFlag.OPEN,
            orderConstraint1, tspAlgorithm);
            PrintUtility.print(System.out,tspPath, tspNodePointsToVisit, true, 0, 0);
            System.out.println("End: Test open tsp tour WITH Constraint1"); 

	    System.out.println("Test open tsp tour WITH Constraint2 ");
            tspPath = analyst.tsp(tspNodePointsToVisit, TSP.TourFlag.OPEN,
            orderConstraint2, tspAlgorithm);
            PrintUtility.print(System.out,tspPath, tspNodePointsToVisit, true, 0, 0);
            System.out.println("End: Test open tsp tour WITH Constraint2");
            
            System.out.println("Test closed tsp tour without constraint");
            tspPath = analyst.tsp(tspNodePointsToVisit, TSP.TourFlag.CLOSED,
            null, tspAlgorithm);
            PrintUtility.print(System.out,tspPath, tspNodePointsToVisit, true, 0, 0);
            System.out.println("End: Test closed tsp tour without constraint");

	    System.out.println("Test closed tsp tour WITH Constraint1");
            tspPath = analyst.tsp(tspNodePointsToVisit, TSP.TourFlag.CLOSED,
            orderConstraint1, tspAlgorithm);
            PrintUtility.print(System.out,tspPath, tspNodePointsToVisit, true, 0, 0);
            System.out.println("End: Test closed tsp tour WITH Constraint1");

	    System.out.println("Test closed tsp tour WITH Constraint2");
            tspPath = analyst.tsp(tspNodePointsToVisit, TSP.TourFlag.CLOSED,
            orderConstraint2, tspAlgorithm);
            PrintUtility.print(System.out,tspPath, tspNodePointsToVisit, true, 0, 0);
            System.out.println("End: Test closed tsp tour WITH Constraint2"); 
            
            System.out.println("*****END : TSP (Astar) with Node Order Constraints ");
      }
      catch (Exception e)
      {
        e.printStackTrace();
      }


    if(conn!=null)
      try{conn.close();} catch(Exception ignore){}

  }
 
    /**
     *  Construct node order constraint as an ordered list of nodes
     *  The  TSP tour will maintain the specified order
     */ 
    private static class TspNodeOrderConstraint implements LODNetworkConstraint
        {
           Map<PointOnNet, Integer> inputNodePositionMap = new HashMap<PointOnNet, Integer>();
           Map<Integer, Integer> nodePositionMap = new HashMap<Integer, Integer>();
           PointOnNet[][] pointsToVisit;
           PointOnNet [][] nodeList;
           int [] nodePositions; 
           
           private TspNodeOrderConstraint(
             PointOnNet[][] pointsToVisit,
             PointOnNet [][] nodeList
             )
           {
             PointOnNet point;
             this.pointsToVisit = pointsToVisit;
             this.nodeList = nodeList; 
             
             nodePositions = new int[nodeList.length];
             
             for (int i=0; i<pointsToVisit.length; i++) 
             {
                inputNodePositionMap.put(pointsToVisit[i][0],i);
             }
             
             for (int i=0; i<nodeList.length; i++ ) 
             {
                point = nodeList[i][0];
                nodePositions[i] =  inputNodePositionMap.get(point); 
             }
             
           }

           public boolean isSatisfied(LODAnalysisInfo info)
           {
             
             if(!(info instanceof TspAnalysisInfo))
               return true;

             TspAnalysisInfo ai = (TspAnalysisInfo)info;

             int[] tspOrder = ai.getTspOrder();
        
             // node positions in the tsp results stored in hash map
             for(int i=0; i<tspOrder.length; i++)
             {
                nodePositionMap.put(tspOrder[i], i);
             }
             
               for(int i=1; i<nodePositions.length; i++)
               {
               if (nodePositionMap.containsKey(nodePositions[i-1]) && 
                   nodePositionMap.containsKey(nodePositions[i]))
               {
               if(nodePositionMap.get(nodePositions[i]) < 
                                   nodePositionMap.get(nodePositions[i-1]))
                 return false;
               }
               else
                 return true;
              }
            
             return true;
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

           public String toString()
           {
             StringBuffer sb = new StringBuffer();
             for(Iterator<Integer> it = nodePositionMap.keySet().iterator(); it.hasNext(); )
             {
               int point = it.next();
               int duration = nodePositionMap.get(point);
               sb.append(point+": ["+duration + "]\n");
             }
             return sb.toString();
           }

           public void reset()
           {
           }

    public void setNetworkAnalyst(NetworkAnalyst analyst)
    {
    }
  }
}
