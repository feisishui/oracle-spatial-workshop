/* $Header: sdo/demo/network/examples/java/src/lod/CreateAndAnalyze.java /main/5 2012/11/08 15:42:41 hgong Exp $ */

/* Copyright (c) 2007, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   DESCRIPTION
    <short description of component this file declares/defines>

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    hgong       10/12/07 - Creation
 */
package lod;

import oracle.spatial.network.lod.CategorizedUserData;
import oracle.spatial.network.lod.LODNetworkFactory;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.LogicalBasicNetwork;
import oracle.spatial.network.lod.LogicalSubPath;
import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.NetworkExplorer;
import oracle.spatial.network.lod.NetworkIO;
import oracle.spatial.network.lod.OrderedLongSet;
import oracle.spatial.network.lod.PointOnNet;
import oracle.spatial.network.lod.UserData;
import oracle.spatial.network.lod.util.PrintUtility;
import oracle.spatial.util.Logger;

/**
 *  This class demonstrates how to create an in-memory network and conduct
 *  network analysis on it.
 *  @version $Header: sdo/demo/network/examples/java/src/lod/CreateAndAnalyze.java /main/5 2012/11/08 15:42:41 hgong Exp $
 *  @author  hgong   
 *  @since   11gR2
 */

public class CreateAndAnalyze
{
  //private static final NumberFormat formatter = new DecimalFormat("#.######");
  
  private static NetworkIO networkIO;
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

  private static LogicalBasicNetwork createNetwork(String networkName)
  {
    //create empty network
    LogicalBasicNetwork network = 
      LODNetworkFactory.createLogicalBasicNetwork(
        networkName, NetworkExplorer.MIN_LINK_LEVEL, 4, 4);
    
    //add nodes
    for(int i=1; i<=4; i++)
      network.addNode(
        LODNetworkFactory.createLogicalNetNode(
          i, 0, 1, i, true, 1, 1, 1, (CategorizedUserData)null));
    
    //add links
    network.addLink(LODNetworkFactory.createLogicalNetLink(
      1, 1, network.getNode(1), network.getNode(2), 1.0, true, true, 
      (CategorizedUserData)null));
    network.addLink(LODNetworkFactory.createLogicalNetLink(
      2, 1, network.getNode(2), network.getNode(3), 1.0, true, true, 
      (CategorizedUserData)null));
    network.addLink(LODNetworkFactory.createLogicalNetLink(
      3, 1, network.getNode(1), network.getNode(4), 2.0, true, true, 
      (CategorizedUserData)null));
    network.addLink(LODNetworkFactory.createLogicalNetLink(
      4, 1, network.getNode(3), network.getNode(4), 2.0, true, true, 
      (CategorizedUserData)null));
    return network;
  }
    
  //find shortest path using Dijkstra algorithm
  public static void testShortestPathDijkstra(long startNodeId, long endNodeId)
  {
    try
    {
      System.out.println("*****BEGIN: testShortestPathDijkstra*****");
      LogicalSubPath subPath =
        analyst.shortestPathDijkstra(new PointOnNet(startNodeId), 
          new PointOnNet(endNodeId), null);

      System.out.println("Is the returned subpath a full path? "+subPath.isFullPath());
      PrintUtility.print(System.out, subPath, true, 20, 0);
      
      System.out.println("*****END: testShortestPathDijkstra*****");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
  
  //find nearest neighbors
  public static void testNearestNeighbors(long startNodeId,
                                   int numberOfNeighbors)
  {
    try
    {
      System.out.println("*****BEGIN: testNearestNeighbors*****");
      LogicalSubPath[] paths =
        analyst.nearestNeighbors(new PointOnNet(startNodeId),
          numberOfNeighbors, null, null);
      PrintUtility.print(System.out, paths, false, 0, 0);
      System.out.println("*****END: testNearestNeighbors*****");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }}
  
  //find nearest reaching neighbors
  public static void testNearestReachingNeighbors(long startNodeId,
                                           int numberOfNeighbors)
  {
    try
    {
      System.out.println("*****BEGIN: testNearestReachingNeighbors*****");
      LogicalSubPath[] paths =
        analyst.nearestReachingNeighbors(new PointOnNet(startNodeId),
          numberOfNeighbors, null, null);
      PrintUtility.print(System.out, paths, false, 0, 0);
      System.out.println("*****END: testNearestReachingNeighbors*****");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
  
  //find nodes within the specified cost
  public static void testWithinCost(long startNodeId,
                             double cost)
  {
    try
    {
      System.out.println("*****BEGIN: testWithinCost*****");
      LogicalSubPath[] paths = analyst.withinCost(new PointOnNet(startNodeId),
        cost, null, null);
      PrintUtility.print(System.out, paths, false, 0, 0);
      System.out.println("*****END: testWithinCost*****");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
  
  //find nodes within the specified reaching cost
  public static void testWithinReachingCost(long startNodeId,
                                     double cost)
  {
    try
    {
      System.out.println("*****BEGIN: testWithinReachingCost*****");
      LogicalSubPath[] paths = analyst.withinReachingCost(
        new PointOnNet(startNodeId), cost, null, null);
      PrintUtility.print(System.out, paths, false, 0, 0);
      System.out.println("*****END: testWithinReachingCost*****");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
  
  //find nodes and partial links within the specified cost
  public static void testTraceOut(long startNodeId, double cost)
  {
    try
    {
      System.out.println("*****BEGIN: testTraceOut*****");
      LogicalSubPath[] paths = analyst.traceOut(new PointOnNet(startNodeId), 
        cost, null, null);
      PrintUtility.print(System.out, paths, false, 0, 0);
      System.out.println("*****END: testTraceOut*****");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }

  //find nodes and partial links within the specified reaching cost  
  public static void testTraceIn(long startNodeId, double cost)
  {
    try
    {
      System.out.println("*****BEGIN: testTraceIn*****");
      LogicalSubPath[] paths = analyst.traceIn(
        new PointOnNet(startNodeId), cost, null, null);
      PrintUtility.print(System.out, paths, false, 0, 0);
      System.out.println("*****END: testTraceIn*****");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }

  //find connected nodes using breadth first search
  public static void testConnectedNodesBfs(long startNodeId, int linkLevel)
  {
    try
    {
      System.out.println("*****BEGIN: testConnectedNodesBfs*****");
      OrderedLongSet ids = analyst.findConnectedNodes(NetworkAnalyst.BREADTH_FIRST_SEARCH, startNodeId, linkLevel, null, null);
      PrintUtility.print(System.out, ids, true, 10, 0);
      System.out.println("*****END: testConnectedNodesBfs*****");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
  
  //find connected nodes using depth first search
  public static void testConnectedNodesDfs(long startNodeId, int linkLevel)
  {
    try
    {
      System.out.println("*****BEGIN: testConnectedNodesDfs*****");
      OrderedLongSet ids = analyst.findConnectedNodes(NetworkAnalyst.DEPTH_FIRST_SEARCH, startNodeId, linkLevel, null, null);
      PrintUtility.print(System.out, ids, true, 10, 0);
      System.out.println("*****END: testConnectedNodesDfs*****");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
  
  //find reachable nodes using breadth first search
  public static void testReachableNodesBfs(long startNodeId, int linkLevel)
  {
    try
    {
      System.out.println("*****BEGIN: testReachableNodesBfs*****");
      OrderedLongSet ids = analyst.findReachableNodes(NetworkAnalyst.BREADTH_FIRST_SEARCH, startNodeId, linkLevel, null, null);
      PrintUtility.print(System.out, ids, true, 10, 0);
      System.out.println("*****END: testReachableNodesBfs*****");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
  
  //find reachable nodes using depth first search
  public static void testReachableNodesDfs(long startNodeId, int linkLevel)
  {
    try
    {
      System.out.println("*****BEGIN: testReachableNodesDfs*****");
      OrderedLongSet ids = analyst.findReachableNodes(NetworkAnalyst.DEPTH_FIRST_SEARCH, startNodeId, linkLevel, null, null);
      PrintUtility.print(System.out, ids, true, 10, 0);
      System.out.println("*****END: testReachableNodesDfs*****");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
  
  //find reaching nodes using breadth first search
  public static void testReachingNodesBfs(long startNodeId, int linkLevel)
  {
    try
    {
      System.out.println("*****BEGIN: testReachingNodesBfs*****");
      OrderedLongSet ids = analyst.findReachingNodes(NetworkAnalyst.BREADTH_FIRST_SEARCH, startNodeId, linkLevel, null, null);
      PrintUtility.print(System.out, ids, true, 10, 0);
      System.out.println("*****END: testReachingNodesBfs*****");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
  
  //find reaching nodes using depth first search
  public static void testReachingNodesDfs(long startNodeId, int linkLevel)
  {
    try
    {
      System.out.println("*****BEGIN: testReachingNodesDfs*****");
      OrderedLongSet ids = analyst.findReachingNodes(NetworkAnalyst.DEPTH_FIRST_SEARCH, startNodeId, linkLevel, null, null);
      PrintUtility.print(System.out, ids, true, 10, 0);
      System.out.println("*****END: testReachingNodesDfs*****");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
  
  //find connected components
  public static void testConnectedComponents(int linkLevel)
  {
    try
    {
      System.out.println("*****BEGIN: testConnectedComponents*****");
      OrderedLongSet[] ids = analyst.findConnectedComponents(linkLevel);
      PrintUtility.print(System.out, ids, false, 0, 0);
      System.out.println("*****END: testConnectedComponents*****");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
  
  public static void main(String[] args)
  {
    String logLevel    = "ERROR";

    String networkName = "IN_MEMORY_NET";
    long startNodeId   = 1;
    long endNodeId     = 3;
    int numNeighbors   = 2;
    double withinCost  = 3;
    
    int linkLevel      = 1;
    
    //get input parameters
    for(int i=0; i<args.length; i++)
    {
      if(args[i].equalsIgnoreCase("-networkName"))
        networkName = args[i+1].toUpperCase();
      else if(args[i].equalsIgnoreCase("-startNodeId"))
        startNodeId = Long.parseLong(args[i+1]);
      else if(args[i].equalsIgnoreCase("-endNodeId"))
        endNodeId = Long.parseLong(args[i+1]);
      else if(args[i].equalsIgnoreCase("-numNeighbors"))
        numNeighbors = Integer.parseInt(args[i+1]);
      else if(args[i].equalsIgnoreCase("-cost"))
        withinCost = Double.parseDouble(args[i+1]);
      else if(args[i].equalsIgnoreCase("-logLevel"))
        logLevel = args[i+1];
    }
    
    System.out.println("Network analysis for "+networkName);
    try{
      setLogLevel(logLevel);
      
      //construct an in-memory network on the fly
      LogicalBasicNetwork network = createNetwork(networkName);
      LogicalBasicNetwork[] networks = {network};

      //get network input/output object for a in-memory network
      networkIO = LODNetworkManager.getNetworkIOForInMemoryNetwork(networks);
      
      //get network analyst
      analyst = LODNetworkManager.getNetworkAnalyst(networkIO);
    
      //perform various network analysis
      testShortestPathDijkstra(startNodeId, endNodeId);
      testNearestNeighbors(startNodeId, numNeighbors);
      testNearestReachingNeighbors(endNodeId, numNeighbors);
      testWithinCost(startNodeId, withinCost);
      testWithinReachingCost(endNodeId, withinCost);
      testTraceOut(startNodeId, withinCost);
      testTraceIn(endNodeId, withinCost);
      testConnectedNodesBfs(startNodeId, linkLevel);
      testReachableNodesBfs(startNodeId, linkLevel);
      testReachingNodesBfs(endNodeId, linkLevel);
      testConnectedNodesDfs(startNodeId, linkLevel);
      testReachableNodesDfs(startNodeId, linkLevel);
      testReachingNodesDfs(endNodeId, linkLevel);
      testConnectedComponents(linkLevel);
    }
    catch(Exception ex)
    {
      ex.printStackTrace();
    }
  }
}
