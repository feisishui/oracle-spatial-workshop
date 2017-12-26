/* $Header: sdo/demo/network/examples/java/src/lod/RunTimeConstraintExample.java /main/8 2012/12/10 11:18:29 begeorge Exp $ */

/* Copyright (c) 2008, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   DESCRIPTION
    <short description of component this file declares/defines>

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    hgong       05/09/08 - add package lod
    jcwang      01/02/08 - Creation
 */
package lod;

import java.io.InputStream;

import java.sql.Connection;

import oracle.spatial.network.lod.LODAnalysisInfo;
import oracle.spatial.network.lod.LODNetworkConstraint;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.LogicalSubPath;
import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.NetworkIO;
import oracle.spatial.network.lod.OrderedLongSet;
import oracle.spatial.network.lod.PointOnNet;
import oracle.spatial.network.lod.util.PrintUtility;
import oracle.spatial.util.Logger;

/**
 * This example shows how to construct a runtime constraint in NDM LOD API
 * This runtime constraint is implemented as an LODNetworkConstraint and can be passed
 * to LOD analysis functions that take a LODNetworkConstraint.
 * Users specify the maximum runtime allowed (in ms) for a certain analysis function.
 * When the total runtime from the start of an analysis function exceeds the maximum
 * runtime, the analysis stops and returns any ressult if any.
 * Users can also reset the start time of the runtime constraint for different analysis
 * The default start time of the runtime constraint is when the constrint is created
 *
 *  @version $Header: sdo/demo/network/examples/java/src/lod/RunTimeConstraintExample.java /main/8 2012/12/10 11:18:29 begeorge Exp $
 *  @author  jcwang  
 *  @since   11gR2
 */
public class RunTimeConstraintExample {
  public static void main(String[] args)
  {
    String dbUrl      = "jdbc:oracle:oci8:@";
    //String dbUrl    = "jdbc:oracle:thin:@localhost:11010:spatial";
    String dbUser     = "";
    String dbPassword = "";
    
    String networkName = "HILLSBOROUGH_NETWORK";
    int startNodeId    = 1533;
    int endNodeId      = 10043;

    String configXmlFile = "tmdnetlodcfg.xml";
    Connection conn = null;
    long maxRunTimeInMillis = 10; // 10 ms
    //Get input parameters
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
        startNodeId = Integer.parseInt(args[i+1]);
      else if(args[i].equalsIgnoreCase("-endNodeId"))
        endNodeId = Integer.parseInt(args[i+1]);
    }

    try
    {
      System.out.println("Run Time Constraint Test");
      
      Logger.setGlobalLevel(Logger.LEVEL_ERROR);
      
      InputStream config = ClassLoader.getSystemResourceAsStream(configXmlFile);
      LODNetworkManager.getConfigManager().loadConfig(config);
      
      conn = LODNetworkManager.getConnection(dbUrl, dbUser, dbPassword);
      NetworkIO nio = LODNetworkManager.getCachedNetworkIO(
        conn, networkName, networkName, null);
      NetworkAnalyst analyst = LODNetworkManager.getNetworkAnalyst(nio);
      
      //dijkstra shortest path with no run time constraint
      LogicalSubPath path = analyst.shortestPathDijkstra(new PointOnNet(startNodeId), 
        new PointOnNet(endNodeId), null);
      System.out.println("Dijkstra Shortest Path WITHOUT runtime constraint : ");
      if ( path != null )
      {
        PrintUtility.print(System.out, path, true, Integer.MAX_VALUE, 0);
      }
      



      System.out.println("Runtime constraint: " + maxRunTimeInMillis + " ms ");     

      // construct runtime constraint
      RunTimeConstraint constraint= new RunTimeConstraint(maxRunTimeInMillis);

      //dijkstra shortest path with run time constraint
      path = analyst.shortestPathDijkstra(new PointOnNet(startNodeId), 
        new PointOnNet(endNodeId), constraint);
      System.out.println("Dijkstra Shortest Path WITH runtime constraint : ");
      if ( path != null )
      {
        PrintUtility.print(System.out, path, true, Integer.MAX_VALUE, 0);
      }
      constraint.resetStartTime(); // reset the start time 
      // astar shortest path with no run time constraint
      path = analyst.shortestPathDijkstra(new PointOnNet(startNodeId), 
        new PointOnNet(endNodeId), null);
      System.out.println("AStar Shortest Path WITHOUT runtime constraint : ");
      if ( path != null )
      {
        PrintUtility.print(System.out, path, true, Integer.MAX_VALUE, 0);
      }
      constraint.resetStartTime(); // reset the start time 
      // astar shortest path with prohibited turns
      path = analyst.shortestPathDijkstra(new PointOnNet(startNodeId), 
        new PointOnNet(endNodeId), constraint);
      System.out.println("AStar Shortest Path WITH runtime constraint : ");
      if ( path != null )
      {
        PrintUtility.print(System.out, path, true, Integer.MAX_VALUE, 0);
      }

      //BFS reachability analysis with no run time constraint
      OrderedLongSet nodes = analyst.findReachableNodes(NetworkAnalyst.BREADTH_FIRST_SEARCH, startNodeId, 1, null, null);
      System.out.println("Reachability analysis BFS from "+startNodeId+" WITHOUT runtime constraint : ");
      if ( nodes != null )
      {
        PrintUtility.print(System.out, nodes, false, 0, 0);
      }
      constraint.resetStartTime(); // reset the start time 
      //BFS reachability analysis with runtime constraint
      nodes = analyst.findReachableNodes(NetworkAnalyst.BREADTH_FIRST_SEARCH, startNodeId, 1, constraint, null);
      System.out.println("Reachability analysis BFS from "+startNodeId+" WITH runtime constraint : ");
      if ( nodes != null )
      {
        PrintUtility.print(System.out, nodes, false, 0, 0);
      }
      
      //DFS reachability analysis with no runtime constraint
      nodes = analyst.findReachableNodes(NetworkAnalyst.DEPTH_FIRST_SEARCH, startNodeId, 1, null, null);
      System.out.println("Reachability analysis DFS from "+startNodeId+" WITHOUT runtime constraint : ");
      if ( nodes != null )
      {
        PrintUtility.print(System.out, nodes, false, 0, 0);
      }
      constraint.resetStartTime(); // reset the start time 
      //DFS reachability analysis with runtime constraint
      nodes = analyst.findReachableNodes(NetworkAnalyst.DEPTH_FIRST_SEARCH, startNodeId, 1, constraint, null);
      System.out.println("Reachability analysis DFS from "+startNodeId+" WITH runtime constraint : ");
      if ( nodes != null )
      {
        PrintUtility.print(System.out, nodes, false, 0, 0);
      }
    }
    catch (Exception e)
    {
      System.err.println(e.getMessage());
      e.printStackTrace();
    }
    if(conn!=null)
      try{ conn.close(); } catch(Exception ex){}
  }    
  
  /**
   *  A simple run-time constraint that only returns analysis result within the given max run time
   */
  public static class RunTimeConstraint implements LODNetworkConstraint
  {  
    private long startTimeInMillis;
    private long maxTimeInMillis;
    
    // construct prohibited turns information
    public RunTimeConstraint(long maxRunTimeInMillis) {
        maxTimeInMillis   = maxRunTimeInMillis;
        startTimeInMillis = System.currentTimeMillis();// default start time, when the constraint is created
    }
    // set start time, if not set, the start time is the time when the constraint is created 
    public void setStartTime(Long startTimeInMillis) {
        this.startTimeInMillis = startTimeInMillis;
    }
    // reset the start to current time
    public void resetStartTime() {
        startTimeInMillis = System.currentTimeMillis();
    }
    public boolean isSatisfied(LODAnalysisInfo info) { 
        long currentTimInMills = System.currentTimeMillis(); // find current time
        // if the 
        if ( (currentTimInMills - startTimeInMillis ) <= maxTimeInMillis )
            return true;
        else
            return false;
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
