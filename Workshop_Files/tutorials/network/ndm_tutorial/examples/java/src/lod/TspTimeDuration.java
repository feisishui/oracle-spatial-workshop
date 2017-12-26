/* $Header: sdo/demo/network/examples/java/src/lod/TspTimeDuration.java /main/6 2012/12/10 11:18:29 begeorge Exp $ */

/* Copyright (c) 2009, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   DESCRIPTION
    This test class demonstrates how to use the Load-On-Demand (LOD) API to  
    conduct TSP (closed and open tours) analysis with time duration constraints.
    The test tunr tsp without constraints first, followed by analysis with 
    constraints.

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    hgong       08/24/10 - remove tsp linkLevel
    begeorge    08/06/09 - Creation
 */

/**
 *  @version $Header: sdo/demo/network/examples/java/src/lod/TspTimeDuration.java /main/6 2012/12/10 11:18:29 begeorge Exp $
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
import oracle.spatial.network.lod.DefaultPairwiseCostCalculator;
import oracle.spatial.network.lod.PairwiseCostCalculator;
import oracle.spatial.network.lod.DefaultPairwiseShortestPaths;
import oracle.spatial.network.lod.GeodeticCostFunction;
import oracle.spatial.network.lod.HeuristicCostFunction;
import oracle.spatial.network.lod.LODAnalysisInfo;
import oracle.spatial.network.lod.LODGoalNode;
import oracle.spatial.network.lod.LODNetworkConstraint;
import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.NetworkExplorer;
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
import oracle.spatial.network.lod.ShortestPath;
import oracle.spatial.network.lod.AStar;
import oracle.spatial.network.lod.TSP;
import oracle.spatial.network.lod.TspOp2;
import oracle.spatial.network.lod.TspAnalysisInfo;
import oracle.spatial.network.lod.TspPath;
import oracle.spatial.network.lod.UserData;
import oracle.spatial.network.lod.config.ConfigManager;
import oracle.spatial.network.lod.config.LODConfig;

public class TspTimeDuration
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
    long[] nodesToVisit = {1001,1506,2505,2703};;
    long[] constraintNodeIds1 =  {1506};
    double[][] constraintDurations1 = { {500,1200} };
    long[] constraintNodeIds2 =  {1506,2505};
    double[][] constraintDurations2 = { {500,Double.POSITIVE_INFINITY},{0,4000}};

    To run test on Navteq_SD network
    String networkName = "NAVTEQ_SD";
    long [] nodesToVisit = {204762751,204762873,359724269,384589278};
    long[] constraintNodeIds1 =  {359724269};
    double[][] constraintDurations1 = { {500,1200} };
    long[] constraintNodeIds2 =  {359724269,384589278};
    double[][] constraintDurations2 = { {500,Double.POSITIVE_INFINITY},{0,4000}};
    */
    String networkName = "NAVTEQ_SF";
    long [] nodesToVisit = {199444894,199626367,199628383,199355161};
    long[] constraintNodeIds1 =  {199444894};
    double[][] constraintDurations1 = { {0,1200} };
    long[] constraintNodeIds2 =  {199626367,199628383};
    double[][] constraintDurations2 = { {500,Double.POSITIVE_INFINITY},{0,4000}};
    int linkLevel      = 1;  //default link level
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
////    TSP with time duration constraints   /////////////////////////

          costMultiplier = 1;
 
          costThreshold = 10000;
          numHighLevelNeighbors = 4;
                                        
          TSP.TourFlag tourFlag = TSP.TourFlag.OPEN;
          System.out.println("*****BEGIN: TSP (Astar) with Time Duration Constraints ***** ");

          
           Logger.setGlobalLevel(Logger.LEVEL_ERROR);

	  NetworkExplorer ne = new NetworkExplorer(networkIO);
           
           //set link/node cost calculators
           LinkCostCalculator[] lccs = new LinkCostCalculator[2];
           lccs[0] = DefaultLinkCostCalculator.getLinkCostCalculator();
           lccs[1] = new TravelTimeCalculator();
            
           NodeCostCalculator [] nccs = new NodeCostCalculator[2];
           nccs[0] = DefaultNodeCostCalculator.getNodeCostCalculator();
           nccs[1] = DefaultNodeCostCalculator.getNodeCostCalculator();
 	   HeuristicCostFunction astarCostFunction =
                                      new GeodeticCostFunction(
                                          UserDataMetadata.DEFAULT_USER_DATA_CATEGORY,
                                          xUserDataIndex, yUserDataIndex, -1);
            
           analyst.setLinkCostCalculators(lccs);
           analyst.setNodeCostCalculators(nccs);
           PointOnNet[][] nodePointsToVisit = nodeIdsToPoints(nodesToVisit);

           LinkLevelSelector lls = new DynamicLinkLevelSelector(
                                        analyst, linkLevel, astarCostFunction, costThresholds,
                                        numHighLevelNeighbors, costMultiplier, null);

           ShortestPath astar = new AStar(ne, lccs, nccs, astarCostFunction, lls);
         
           PairwiseCostCalculator pwcc = new DefaultPairwiseCostCalculator
                                      (new DefaultPairwiseShortestPaths(ne, lccs, nccs, astar));
           TSP tspAlgorithm = new TspOp2(lccs, nccs, astar, pwcc);
            

            //construct tsp duration constraint 1
            TspDurationConstraint constraint1 = new TspDurationConstraint(
              nodePointsToVisit, constraintNodeIds1, constraintDurations1);

            //construct tsp duration constraint 2
            TspDurationConstraint constraint2 = new TspDurationConstraint(
              nodePointsToVisit, constraintNodeIds2, constraintDurations2);
	
	    // testing open TSP tour
            System.out.println("Test open tsp tour without constraint");
            TspPath tspPath = 
                    analyst.tsp(nodePointsToVisit, tourFlag, null, tspAlgorithm);
            System.out.println("TSP tour on link level "+linkLevel+ " for points [");
            for (int i=0; i < nodePointsToVisit.length; i++) {
                System.out.print(nodePointsToVisit[i][0]+" ");
            }
            System.out.println("]");
            PrintUtility.print(System.out,tspPath, nodePointsToVisit, true, 0, 0);
            System.out.println("End: Test open tsp tour without constraint");
            
            System.out.println("Test open tsp tour with constraint 1");
            tspPath = 
                analyst.tsp(nodePointsToVisit, tourFlag, constraint1, tspAlgorithm);
            PrintUtility.print(System.out,tspPath, nodePointsToVisit, true, 0, 0);
            System.out.println("End: Test open tsp tour WITH Constraint1");
            
            System.out.println("Test open tsp tour with constraint 2");
            tspPath = 
                analyst.tsp(nodePointsToVisit, tourFlag, constraint2, tspAlgorithm);
            PrintUtility.print(System.out,tspPath, nodePointsToVisit, true, 0, 0);
            System.out.println("End: Test open tsp tour WITH Constraint2");
            
            // testing for closed tsp tour
            tourFlag = TSP.TourFlag.CLOSED;
            
            System.out.println("Test closed tsp tour without constraint");
            tspPath = 
                analyst.tsp(nodePointsToVisit, tourFlag, null, tspAlgorithm);
            PrintUtility.print(System.out,tspPath, nodePointsToVisit, true, 0, 0);
            System.out.println("End: Test CLOSED tsp tour without constraints");
            
            System.out.println("Test closed tsp tour with constraint 1");
            tspPath = 
                analyst.tsp(nodePointsToVisit, tourFlag, constraint1, tspAlgorithm);
            PrintUtility.print(System.out,tspPath, nodePointsToVisit, true, 0, 0);
            System.out.println("End: Test CLOSED tsp tour WITH Constraint1");
            
            System.out.println("Test closed tsp tour with constraint 2");
            tspPath = 
                analyst.tsp(nodePointsToVisit, tourFlag, constraint2, tspAlgorithm);
            PrintUtility.print(System.out,tspPath, nodePointsToVisit, true, 0, 0);
            System.out.println("End: Test CLOSED tsp tour WITH Constraint2");
            
            System.out.println("*****END : TSP (Astar) with Time Duration Constraints ");
      }
      catch (Exception e)
      {
        e.printStackTrace();
      }


    if(conn!=null)
      try{conn.close();} catch(Exception ignore){}

  }
 
private static class TspDurationConstraint implements LODNetworkConstraint
    {
       Map<PointOnNet, double[]> durationMap = new HashMap<PointOnNet, double[]>();
       PointOnNet[][] pointsToVisit;

       private TspDurationConstraint(
         PointOnNet[][] pointsToVisit,
         long[] nodeIds,
         double[][] nodeDurations)
       {
         this.pointsToVisit = pointsToVisit;
         for(int i=0; i<nodeIds.length; i++)
         {
           durationMap.put(new PointOnNet(nodeIds[i]), nodeDurations[i]);
         }
       }

       public boolean isSatisfied(LODAnalysisInfo info)
       {
         if(!(info instanceof TspAnalysisInfo))
           return true;

         TspAnalysisInfo ai = (TspAnalysisInfo)info;

         int[] tspOrder = ai.getTspOrder();
         for(int i=0; i<tspOrder.length; i++)
         {
           PointOnNet point = pointsToVisit[tspOrder[i]][0];
           double[] durationWindow = durationMap.get(point);
           if(durationWindow==null)
             continue;

           double[] tspCosts = ai.getTspCosts(tspOrder[i]);
           //second cost is duration
           double duration = tspCosts[1];
           if( duration < durationWindow[0] || duration > durationWindow[1] )
             return false;
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
         for(Iterator<PointOnNet> it = durationMap.keySet().iterator(); it.hasNext(); )
         {
           PointOnNet point = it.next();
           double[] duration = durationMap.get(point);
           sb.append(point+": ["+duration[0]+", "+duration[1]+"]\n");
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

    private static class TravelTimeCalculator implements LinkCostCalculator
    {
      double SPEED_LIMIT_1 = 30;
      double SPEED_LIMIT_2 = 60;
      
      public double getLinkCost(LODAnalysisInfo analysisInfo)
      {
        LogicalLink link = analysisInfo.getNextLink();
        int linkLevel= link.getLevel();
        double linkCost = link.getCost();
        switch(linkLevel)
        {
          case 2:
            return linkCost/SPEED_LIMIT_2;
          default:
            return linkCost/SPEED_LIMIT_1;
        }
      }
      
      public int[] getUserDataCategories()
      {
        return null;
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
