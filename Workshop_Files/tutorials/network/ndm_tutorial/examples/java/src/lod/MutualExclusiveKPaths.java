/* $Header: sdo/demo/network/examples/java/src/lod/MutualExclusiveKPaths.java /main/4 2012/12/10 11:18:29 begeorge Exp $ */

/* Copyright (c) 2009, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   DESCRIPTION
    This test class demonstrates how to use the Load-On-Demand (LOD) API to  
    conduct k mutually exclusive (links and nodes) shortest path analysis on NAVTEQ_SF network.


   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    jcwang      11/19/09 - Creation
 */

/**
 *  @version $Header: sdo/demo/network/examples/java/src/lod/MutualExclusiveKPaths.java /main/4 2012/12/10 11:18:29 begeorge Exp $
 *  @author  jcwang  
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
import java.util.Set;
import java.util.Arrays;
import java.util.HashSet;
import java.util.ArrayList;
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
import oracle.spatial.network.lod.KShortestPaths;
import oracle.spatial.network.lod.LODAnalysisInfo;
import oracle.spatial.network.lod.LODGoalNode;
import oracle.spatial.network.lod.LODNetworkConstraint;
import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.LinkCostCalculator;
import oracle.spatial.network.lod.LinkLevelSelector;
import oracle.spatial.network.lod.NetworkIO;
import oracle.spatial.network.lod.LogicalSubPath;
import oracle.spatial.network.lod.LogicalPath;
import oracle.spatial.network.lod.PointOnNet;
import oracle.spatial.network.lod.util.PrintUtility;
import oracle.spatial.network.lod.YenDeviation;
import oracle.spatial.util.Logger;

import oracle.spatial.network.lod.LogicalLightPath;
import oracle.spatial.network.lod.LogicalLink;
import oracle.spatial.network.lod.LogicalNetLink;
import oracle.spatial.network.lod.LogicalNetNode;
import oracle.spatial.network.lod.LogicalPath;
import oracle.spatial.network.lod.NetworkBuffer;
import oracle.spatial.network.lod.NetworkExplorer;
import oracle.spatial.network.lod.NodeCostCalculator;
import oracle.spatial.network.lod.OrderedLongSet;
import oracle.spatial.network.lod.SpatialPath;
import oracle.spatial.network.lod.SpatialSubPath;

import oracle.spatial.network.lod.ShortestPath;
import oracle.spatial.network.lod.AStar;
import oracle.spatial.network.lod.TSP;
import oracle.spatial.network.lod.TspAnalysisInfo;
import oracle.spatial.network.lod.TspPath;
import oracle.spatial.network.lod.UserData;
import oracle.spatial.network.lod.config.ConfigManager;
import oracle.spatial.network.lod.config.LODConfig;

public class MutualExclusiveKPaths
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
    String networkName = "NAVTEQ_SF";
    long startNodeId        = 199535084;
    long endNodeId          = 199866645;
    
    int linkLevel      = 1;  //default link level
    
    int k=3; //k (mtually exclusive)shortest path analysis
    double costThreshold = 5000;
    double costMultiplier = 1.5;
    int numHighLevelNeighbors = 8;
    
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
            
    PointOnNet[] startPoint = {new PointOnNet(startNodeId)};
    PointOnNet[] endPoint = {new PointOnNet(endNodeId)};
      

    // opening connection
    conn = LODNetworkManager.getConnection(dbUrl, dbUser, dbPassword);
    
    System.out.println("Analysis for "+networkName+" Network");

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

    ArrayList<LogicalSubPath> pathList = new ArrayList<LogicalSubPath>(); 
    // k shortest paths without mutual exclusive constraints 
      try
      {

      System.out.println("\n*****BEGIN: testKShortestPathsDijkstra*****");
      LogicalSubPath[] paths =
        analyst.kShortestPaths(startPoint, endPoint, k, null, null);

      PrintUtility.print(System.out, paths, true, 20, 0);
      pathList.addAll(Arrays.asList(paths));
      System.out.println("\n*****MutualExclusiveTest:[ " + isMutualExclusive(pathList)+" ] *****");
      System.out.println("*****END: testKShortestPathsDijkstra*****");
 

      System.out.println("\n*****BEGIN: testKShortestPathsAStar*****");

      int xUserDataIndex = 0;
      int yUserDataIndex = 1;

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
      ShortestPath spAlgorithm = new AStar(ne, lccs, nccs, astarCostFunction, lls);
      KShortestPaths kspAlgorithm = new YenDeviation(ne, lccs, nccs, spAlgorithm);

      paths =
        analyst.kShortestPaths(startPoint, endPoint, k, null, kspAlgorithm);

      PrintUtility.print(System.out, paths, true, 20, 0);
      pathList.addAll(Arrays.asList(paths));
      System.out.println("\n*****MutualExclusiveTest:[ " + isMutualExclusive(pathList)+" ] *****");
      System.out.println("*****END: testKShortestPathsAStar*****");

      }
      catch (Exception e)
	  {
	      e.printStackTrace();
	  }

      // k mutual exclusive shortest paths
      
      try
	  {
	      
      System.out.println("\n*****BEGIN: testMutualExclusiveKShortestPathsDijkstra*****");
	      
      pathList.clear();
      
      for (int i = 0; i < k; i++) {
	  LogicalSubPath subPath =
              analyst.shortestPathDijkstra(startPoint, 
					   endPoint,
					   1,
					   new MustAvoidPathElems(pathList));
	  if ( subPath != null)
	      pathList.add(subPath) ;
	  
      }

      PrintUtility.print(System.out, (LogicalSubPath[])pathList.toArray(new LogicalSubPath[0]), true, 20, 0);
      System.out.println("\n*****MutualExclusiveTest:[ " + isMutualExclusive(pathList)+" ] *****");
      System.out.println("*****END: testMutualExclusiveKShortestPathsDijkstra*****");
      

      System.out.println("\n*****BEGIN: testMutualExclusiveKShortestPathsAStar*****");

      int xUserDataIndex = 0;
      int yUserDataIndex = 1;

      NetworkExplorer ne = new NetworkExplorer(networkIO);
      LinkCostCalculator[] lccs = analyst.getLinkCostCalculators();
      NodeCostCalculator[] nccs = analyst.getNodeCostCalculators();
      HeuristicCostFunction hcf =
        new GeodeticCostFunction(
        UserDataMetadata.DEFAULT_USER_DATA_CATEGORY,
        xUserDataIndex, yUserDataIndex, -1);
      LinkLevelSelector lls = new DynamicLinkLevelSelector(
        analyst, linkLevel, hcf, costThresholds,
        numHighLevelNeighbors, costMultiplier, null);
      
      pathList.clear();
      for ( int i = 0; i < k ;i++) {
	  LogicalSubPath subPath =
	      analyst.shortestPathAStar(startPoint, endPoint,new MustAvoidPathElems(pathList) , hcf, lls);
	  if ( subPath != null)
	      pathList.add(subPath);
      }
      
      PrintUtility.print(System.out, (LogicalSubPath[])pathList.toArray(new LogicalSubPath[0]), true, 20, 0);
      System.out.println("\n*****MutualExclusiveTest:[ " + isMutualExclusive(pathList)+" ] *****");
      System.out.println("*****END: testMutaulExclusiveKShortestPathsAStar*****");
      
	  }
      catch (Exception e)
	  {
	      e.printStackTrace();
	  }
      



      if(conn!=null)
	try{conn.close();} catch(Exception ignore){}

  }

// make sure all paths are mutually (links and nodes) exclusive
  private static boolean isMutualExclusive(ArrayList <LogicalSubPath> pathList) {

      if ( pathList == null || pathList.size() == 0)
	  return true;
      Set <Long> setL = new HashSet<Long>();
      Set <Long> setN = new HashSet<Long>();


      for ( LogicalSubPath lsp : pathList ) {
	      if ( lsp != null ) {
		  LogicalPath lp = lsp.getReferencePath();
		  long [] pathLinkIDs = lp.getLinkIds();
		  // redundant link check
		  if ( pathLinkIDs != null )
		      for (long l :pathLinkIDs) {
			  int prevSize = setL.size();
			  setL.add(new Long(l));
			  if ( setL.size() == prevSize )
			      return false;
		  
		      }
		  // redundant node check
		  long [] pathNodeIds = lp.getNodeIds();
		  if ( pathNodeIds != null )
		      for (int i = 1; i < pathNodeIds.length-1;i++) {
			  // exclude start and end node
			  int prevSize = setN.size();
			  setN.add(new Long(pathNodeIds[i]));
			  if ( setN.size() == prevSize )
			      return false;
		  
		      }

		  
	      }
      }

      return true;
  
  }
  
  /**
   *  A simple constraint that avoids all links in the give path array 
   */
  private static class MustAvoidPathElems implements LODNetworkConstraint
  {  
    
      private ArrayList<LogicalSubPath> list = new ArrayList<LogicalSubPath>();

      // construct prohibited turns information
      public MustAvoidPathElems(ArrayList<LogicalSubPath> pathList) {
	  if ( pathList != null )
	      list = new ArrayList<LogicalSubPath>(pathList);
      }
      public boolean isSatisfied(LODAnalysisInfo info) { 
	  
	  LogicalLink nextLink    = info.getNextLink();
	  LogicalNetNode nextNode    = info.getNextNode();

	  for ( LogicalSubPath lsp : list ) {
	      if ( lsp != null ) {
		  LogicalPath lp = lsp.getReferencePath();
		  if ( lp != null && lp.indexOfLink(nextLink.getId()) != -1 ) // next link id in previous path result
		      return false;
		  long [] nodeIds = lp.getNodeIds();
		  // next Node id in previous path result,exclude start and end node of previous paths
		  if ( lp != null &&
		       nextNode.getId() != lp.getEndNodeId() &&
		       lp.indexOfNode(nextNode.getId()) != -1 ) 

		      return false;

	      }
	  }
	  return true;
      }
      
      public int getNumberOfUserObjects(){ return 0; }
      
      public boolean isCurrentNodePartiallyExpanded(LODAnalysisInfo info){ return false;}
      
      public boolean isNextNodePartiallyExpanded(LODAnalysisInfo info){ return false; }
      
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
