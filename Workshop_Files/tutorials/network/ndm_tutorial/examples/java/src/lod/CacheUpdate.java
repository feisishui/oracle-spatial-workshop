/* $Header: sdo/demo/network/examples/java/src/lod/CacheUpdate.java /main/7 2012/12/10 11:18:29 begeorge Exp $ */

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
    hgong       06/26/07 - add package lod
    hgong       05/21/07 - Creation
 */

package lod;

import java.io.InputStream;

import java.sql.Connection;
import java.sql.PreparedStatement;

import oracle.spatial.geometry.JGeometry;
import oracle.spatial.network.NetworkMetadata;
import oracle.spatial.network.lod.CachedNetworkIO;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.LogicalSubPath;
import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.NetworkUpdate;
import oracle.spatial.network.lod.PointOnNet;
import oracle.spatial.network.lod.SpatialLink;
import oracle.spatial.network.lod.util.PrintUtility;

import oracle.spatial.util.Logger;

/**
 *  This class demonstrates how to update the LOD network cache after the 
 *  network has been updated in the database.
 *  
 *  @version $Header: sdo/demo/network/examples/java/src/lod/CacheUpdate.java /main/7 2012/12/10 11:18:29 begeorge Exp $
 *  @author  hgong   
 *  @since   11gR1
 */
public class CacheUpdate
{ 
  private static Connection conn;
  private static NetworkAnalyst analyst;
  private static CachedNetworkIO networkIO;
  private static int linkLevel = 1;
  
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

  public static void testShortestPath(long startNodeId, long endNodeId)
  {
    try
    {
      LogicalSubPath path =
        analyst.shortestPathDijkstra(new PointOnNet(startNodeId), 
          new PointOnNet(endNodeId), null);

      PrintUtility.print(System.out, path, false, 0, 1);
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
  
  public static void modifyNetworkInactivateLink(
    long linkId, boolean active)
  {
    PreparedStatement stmt = null;
    try
    {
      NetworkMetadata metadata = networkIO.getNetworkMetadata();
      String tabName = metadata.getLinkTableName(true);
      String activeFlag = "Y";
      if(!active)
        activeFlag = "N";
      String sqlStr = "UPDATE "+tabName+
                      " SET ACTIVE = ? " +
                      " WHERE LINK_ID = ?";
      stmt = conn.prepareStatement(sqlStr);
      stmt.setString(1, activeFlag);
      stmt.setLong(2, linkId);
      stmt.execute();
      conn.commit();
    }
    catch(Exception ex)
    {
      ex.printStackTrace();
    }    
  }

  public static void modifyNetworkReassignLink(
    long linkId, long endNodeId)
  {
    PreparedStatement stmt = null;
    try
    {
      NetworkMetadata metadata = networkIO.getNetworkMetadata();
      String tabName = metadata.getLinkTableName(true);
      String sqlStr = "UPDATE "+tabName+
                      " SET END_NODE_ID = ? " +
                      " WHERE LINK_ID = ?";
      stmt = conn.prepareStatement(sqlStr);
      stmt.setLong(1, endNodeId);
      stmt.setLong(2, linkId);
      stmt.execute();
      conn.commit();
    }
    catch(Exception ex)
    {
      ex.printStackTrace();
    }
  }

  public static void modifyNetworkReassignNodePartition(
    long nodeId, int newPartitionId)
  {
    PreparedStatement stmt = null;
    try
    {
      NetworkMetadata metadata = networkIO.getNetworkMetadata();
      String tabName = metadata.getPartitionTableName(true);
      String sqlStr = "UPDATE "+tabName+
                      " SET PARTITION_ID = ? " +
                      " WHERE NODE_ID = ? AND LINK_LEVEL = ?";
      stmt = conn.prepareStatement(sqlStr);
      stmt.setInt(1, newPartitionId);
      stmt.setLong(2, nodeId);
      stmt.setLong(3, linkLevel);
      stmt.execute();
      conn.commit();
    }
    catch(Exception ex)
    {
      ex.printStackTrace();
    }
  }

  //delete a link
  public static void modifyNetworkDeleteLink(
    long linkId)
  {
    PreparedStatement stmt = null;
    try
    {
      NetworkMetadata metadata = networkIO.getNetworkMetadata();
      String tabName = metadata.getLinkTableName(true);
      String sqlStr = "DELETE FROM "+tabName+
                      " WHERE LINK_ID = ?";
      stmt = conn.prepareStatement(sqlStr);
      stmt.setLong(1, linkId);
      stmt.execute();
      conn.commit();
    }
    catch(Exception ex)
    {
      ex.printStackTrace();
    }
  }

  //add a link
  public static void modifyNetworkAddLink(
    SpatialLink link)
  {
    PreparedStatement stmt = null;
    try
    {
      NetworkMetadata metadata = networkIO.getNetworkMetadata();
      String tabName = metadata.getLinkTableName(true);
      String sqlStr = "INSERT INTO "+tabName+
                      " ( LINK_ID, START_NODE_ID, END_NODE_ID, " + 
                      "   ACTIVE, LINK_LEVEL, GEOMETRY, COST )" +
                      " VALUES ( ?, ?, ?, ?, ?, ?, ? )";
      stmt = conn.prepareStatement(sqlStr);
      int idx = 0;
      stmt.setLong(++idx, link.getId());
      stmt.setLong(++idx, link.getStartNodeId());
      stmt.setLong(++idx, link.getEndNodeId());
      String activeFlag = "Y";
      if(!link.isActive())
        activeFlag = "N";
      stmt.setString(++idx, activeFlag);
      stmt.setInt(++idx, link.getLevel());

      Object struct = null;
      JGeometry geom = link.getGeometry();
      if(geom!=null)
        struct = JGeometry.storeJS(geom, conn);
      stmt.setObject(++idx, struct);

      stmt.setDouble(++idx, link.getCost());
      stmt.execute();
      conn.commit();
    }
    catch(Exception ex)
    {
      ex.printStackTrace();
    }
  }
  
  public static void updateNetworkCache(long linkId)
  {
    try{
      long[] changedNodeIds = {};
      long[] changedLinkIds = {linkId};
      NetworkUpdate nu = networkIO.readNetworkUpdate(
        linkLevel, changedNodeIds, changedLinkIds, null);
      networkIO.updateNetworkCache(linkLevel, nu);
    }
    catch(Exception ex)
    {
      ex.printStackTrace();
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

    String networkName = "HILLSBOROUGH_NETWORK";    
    long startNodeId   = 3169;
    long endNodeId     = 1501;
    long linkId        = 145476456;
    long linkEndNodeIdNew = 3203;
    
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
      else if(args[i].equalsIgnoreCase("-linkEndNodeId"))
        linkEndNodeIdNew = Long.parseLong(args[i+1]);
      else if(args[i].equalsIgnoreCase("-configXmlFile"))
        configXmlFile = args[i+1];
      else if(args[i].equalsIgnoreCase("-logLevel"))
        logLevel = args[i+1];
    }
    
    try{
      setLogLevel(logLevel);
      
      //load user specified LOD configuration (optional), otherwise default configuration will be used
      InputStream config = ClassLoader.getSystemResourceAsStream(configXmlFile);
      LODNetworkManager.getConfigManager().loadConfig(config);

      //get jdbc connection 
      conn = LODNetworkManager.getConnection(dbUrl, dbUser, dbPassword);
      
      //get network input/output object
      networkIO = LODNetworkManager.getCachedNetworkIO(
        conn, networkName, networkName, null);
            
      //get network analyst
      analyst = LODNetworkManager.getNetworkAnalyst(networkIO);
      
      //read original link first
      SpatialLink link = networkIO.readSpatialLink(linkId, null);

      //////////////////////////////////////////////////////
      // Test updating network cache by inactivating a link
      //////////////////////////////////////////////////////
      System.out.println("////////////////////");
      System.out.println("// Test updating network cache by inactivating a link");
      System.out.println("////////////////////");
      
      //test shortest path before modifying the DB or updating network cache
      System.out.println("Shortest path before modifying the network in the database");
      testShortestPath(startNodeId, endNodeId);
      
      //modify network in DB
      System.out.println("Modify the network in the database: inactivate link "+linkId);
      modifyNetworkInactivateLink(linkId, false);

      //test shortest path again before updating network cache
      System.out.println("Shortest path before updating network cache");
      testShortestPath(startNodeId, endNodeId);
      
      //update network cache
      System.out.println("Update network cache");
      updateNetworkCache(linkId);
      
      //test shortest path after updating network cache
      System.out.println("Shortest path after updating network cache");
      testShortestPath(startNodeId, endNodeId);
      
      //modify network in DB back to original
      System.out.println("Modify the network in the database back to its original state: activate link "+linkId);
      modifyNetworkInactivateLink(linkId, true);

      //update network cache
      System.out.println("Update network cache back to original state");
      updateNetworkCache(linkId);

      ///////////////////////////////////////////////////////////////////
      // Test updating network cache by reassigning end node of a link
      ///////////////////////////////////////////////////////////////////
      System.out.println("////////////////////");
      System.out.println("// Test updating network cache by reassigning end node of a link");
      System.out.println("////////////////////");
      
      //modify the network in DB: reassign end node id
      long linkEndNodeIdOri = link.getEndNodeId();
      System.out.println("Modify the network in the database: " +
        "reassign end node id of link "+linkId+" to "+linkEndNodeIdNew);
      modifyNetworkReassignLink(linkId, linkEndNodeIdNew);
      
      //test shortest path again before updating network cache
      System.out.println("Shortest path before updating network cache");
      testShortestPath(startNodeId, endNodeId);
      
      //update network cache
      System.out.println("Update network cache");
      updateNetworkCache(linkId);
      
      //test shortest path after updating network cache
      System.out.println("Shortest path after updating network cache");
      testShortestPath(startNodeId, endNodeId);
      
      //modify network in DB back to original
      System.out.println("Modify the network in the database back to its original state: " +
        "reassign end node of link "+linkId+" back to "+linkEndNodeIdOri);
      modifyNetworkReassignLink(linkId, linkEndNodeIdOri);

      //update network cache
      System.out.println("Update network cache back to original state");
      updateNetworkCache(linkId);

      ///////////////////////////////////////////////////////////////////
      // Test updating network cache by deleting a link
      ///////////////////////////////////////////////////////////////////
      System.out.println("////////////////////");
      System.out.println("// Test updating network cache by deleting a link");
      System.out.println("////////////////////");
      
      //modify the network in DB: delete a link
      System.out.println("Modify the network in the database: delete link "+linkId);
      modifyNetworkDeleteLink(linkId);
      
      //test shortest path again before updating network cache
      System.out.println("Shortest path before updating network cache");
      testShortestPath(startNodeId, endNodeId);
      
      //update network cache
      System.out.println("Update network cache");
      updateNetworkCache(linkId);
      
      //test shortest path after updating network cache
      System.out.println("Shortest path after updating network cache");
      testShortestPath(startNodeId, endNodeId);
      
      //modify network in DB back to original
      System.out.println("Modify the network in the database back to its " +
        "original state: add link "+link.getId());
      modifyNetworkAddLink(link);

      //test shortest path again before updating network cache
      System.out.println("Shortest path before updating network cache");
      testShortestPath(startNodeId, endNodeId);

      //update network cache
      System.out.println("Update network cache");
      updateNetworkCache(linkId);
      
      //test shortest path after updating network cache
      System.out.println("Shortest path after updating network cache");
      testShortestPath(startNodeId, endNodeId);
      
    }
    catch(Exception ex)
    {
      ex.printStackTrace();
    }
  }
}

