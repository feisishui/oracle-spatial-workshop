/* $Header: sdo/demo/network/examples/java/src/lod/PreloadPartitions.java /main/3 2012/12/10 11:18:29 begeorge Exp $ */

/* Copyright (c) 2010, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   DESCRIPTION
    <short description of component this file declares/defines>

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    jcwang      12/14/10 - Creation
 */
/**
 * This example dhows how to preload LOD network partitions into partition cache before analysis.
 * Prior to network analysis the partition cache is empty. Partitons are loaded into cache when needed.
 * This is assumed that the network can be fit into partiton cache completely.
 * Users should increase the maximum no of nodes in the LOD configuration file for the target network
 * to prevent unnecessary partition unloading and loading.
 * Without partition pre-loading, the analysis time will include partition loading time. With partition pre-loading,
 * since all paatitions are in cache, the analysis time will be usually much faster.
 */
/**
 *  @version $Header: sdo/demo/network/examples/java/src/lod/PreloadPartitions.java /main/3 2012/12/10 11:18:29 begeorge Exp $
 *  @author  jcwang
 *  @since   release specific (what release of product did this appear in)
 */

package lod;

import java.io.InputStream;

import java.sql.Connection;
import java.sql.Statement;

import oracle.spatial.network.lod.CachedNetworkIO;

import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.LeveledNetworkCache;

import oracle.spatial.network.lod.LogicalSubPath;
import oracle.spatial.network.lod.PointOnNet;
import oracle.spatial.network.lod.util.PrintUtility;
import oracle.spatial.util.Logger;

import oracle.spatial.network.lod.LogicalPartition;

import oracle.spatial.network.lod.config.LODConfig;

public class PreloadPartitions {

  private static NetworkAnalyst analyst;
  private static CachedNetworkIO networkIO;

  private static void setLogLevel(String logLevel) {
    if ("FATAL".equalsIgnoreCase(logLevel))
      Logger.setGlobalLevel(Logger.LEVEL_FATAL);
    else if ("ERROR".equalsIgnoreCase(logLevel))
      Logger.setGlobalLevel(Logger.LEVEL_ERROR);
    else if ("WARN".equalsIgnoreCase(logLevel))
      Logger.setGlobalLevel(Logger.LEVEL_WARN);
    else if ("INFO".equalsIgnoreCase(logLevel))
      Logger.setGlobalLevel(Logger.LEVEL_INFO);
    else if ("DEBUG".equalsIgnoreCase(logLevel))
      Logger.setGlobalLevel(Logger.LEVEL_DEBUG);
    else if ("FINEST".equalsIgnoreCase(logLevel))
      Logger.setGlobalLevel(Logger.LEVEL_FINEST);
    else //default: set to ERROR
      Logger.setGlobalLevel(Logger.LEVEL_ERROR);
  }


  public static void main(String[] args) throws Exception {
    String configXmlFile = "lod/LODConfigs.xml";
    String logLevel = "ERROR";


    String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser = "";
    String dbPassword = "";

    String networkName = "NAVTEQ_SF";
    long startNodeId = 199535084;
    long endNodeId = 199926436;
    int linkLevel = 1; //default link level


    Connection conn = null;
    //get input parameters
    for (int i = 0; i < args.length; i++) {
      if (args[i].equalsIgnoreCase("-dbUrl"))
        dbUrl = args[i + 1];
      else if (args[i].equalsIgnoreCase("-dbUser"))
        dbUser = args[i + 1];
      else if (args[i].equalsIgnoreCase("-dbPassword"))
        dbPassword = args[i + 1];
      else if (args[i].equalsIgnoreCase("-networkName") && args[i + 1] != null)
        networkName = args[i + 1].toUpperCase();
      else if (args[i].equalsIgnoreCase("-linkLevel"))
        linkLevel = Integer.parseInt(args[i + 1]);
      else if (args[i].equalsIgnoreCase("-configXmlFile"))
        configXmlFile = args[i + 1];
      else if (args[i].equalsIgnoreCase("-logLevel"))
        logLevel = args[i + 1];
    }

    // opening connection
    conn = LODNetworkManager.getConnection(dbUrl, dbUser, dbPassword);

    Statement stmt = conn.createStatement();

    System.out.println("Shortest path Analysis for Network:" + networkName);

    setLogLevel(logLevel);

    //load user specified LOD configuration (optional),
    //otherwise default configuration will be used
    InputStream config = ClassLoader.getSystemResourceAsStream(configXmlFile);
    LODNetworkManager.getConfigManager().loadConfig(config);
    LODConfig c = LODNetworkManager.getConfigManager().getConfig(networkName);

    // check network configuration
    System.out.println("Network:" + networkName + " XML Configuration:");
    System.out.println(c);

    //get network input/output object
    networkIO =
        LODNetworkManager.getCachedNetworkIO(conn, networkName, networkName,
                                             null);

    //get network analyst
    analyst = LODNetworkManager.getNetworkAnalyst(networkIO);

    // network partition cache
    LeveledNetworkCache cache = networkIO.getNetworkCache();

    long startTime = System.currentTimeMillis(); // set timer
    LogicalSubPath subPath = null;
    int noOfLinkLevels = 2; // linke levels to be pre-loaded

    try {

      System.out.println("SP with the Empty Cache ...");
      printCache(cache);
      subPath =
          analyst.shortestPathDijkstra(new PointOnNet(startNodeId), new PointOnNet(endNodeId),
                                       null);
      PrintUtility.print(System.out, subPath, false, 20, 0);
      System.out.println("----- 1st Analysis took " +
                         (System.currentTimeMillis() - startTime) +
                         " msec...\n");
      printCache(cache);
      startTime = System.currentTimeMillis(); // reset timer
      System.out.println("Clear Cache took " +
                         (System.currentTimeMillis() - startTime) +
                         " msec...\n");
      cache.clear();

      startTime = System.currentTimeMillis(); // reset timer
      boolean readFromBlob = true;

      preloadAllPartitions(networkIO, noOfLinkLevels,
                           readFromBlob); // preload all partitions from tables

      System.out.println("----- Preload Partitions from " +
                         (readFromBlob ? "Blobs" : "Tables") + "  took " +
                         (System.currentTimeMillis() - startTime) +
                         " msec...\n");
      printCache(cache);
      startTime = System.currentTimeMillis(); // reset timer
      subPath =
          analyst.shortestPathDijkstra(new PointOnNet(startNodeId), new PointOnNet(endNodeId),
                                       null);
      PrintUtility.print(System.out, subPath, false, 20, 0);
      System.out.println("----- 2nd Analysis took " +
                         (System.currentTimeMillis() - startTime) +
                         " msec...\n");
      cache.clear();

      /* if pre-load partitions from tables with Navteq ODF data, make sure the node_level_table is generated.
       * check node_level_table_name in user_sdo_network_metadata
       * in PLSQL sdo_net package
       *  PROCEDURE generate_node_levels(
       * network   in varchar2,
       * node_level_table_name in varchar2,
       * overwrite in boolean default false,
       * log_loc   IN VARCHAR2,
       * log_file  IN VARCHAR2,
       * open_mode IN VARCHAR2 DEFAULT 'a');
      */
      /*
      readFromBlob = false;
      preloadAllPartitions(networkIO,  noOfLinkLevels,readFromBlob); // preload all partitions from tables

      System.out.println("----- Preload Partitions from " + (readFromBlob ? "Blobs" : "Tables" ) + "  took " +
                         (System.currentTimeMillis() - startTime) +
                         " msec...\n");
      printCache(cache);
      startTime = System.currentTimeMillis(); // reset timer
      subPath =
          analyst.shortestPathDijkstra(new PointOnNet(startNodeId), new PointOnNet(endNodeId),
                                       null);
      PrintUtility.print(System.out, subPath, false, 20, 0);
      System.out.println("----- 3rd Analysis took " +
                         (System.currentTimeMillis() - startTime) +
                         " msec...\n");
*/
    } catch (Exception e) {
      e.printStackTrace();
    }


    if (conn != null)
      try {
        conn.close();
      } catch (Exception ignore) {
      }

  }

  static void printCache(LeveledNetworkCache cache) throws Exception {
    System.out.println("\nCurrent Network Partition Cache:");
    for (int linkLevel = 1; linkLevel <= cache.getNumberOfLinkLevels();
         linkLevel++)
      System.out.println("\tLinkLevel: " + linkLevel + " contains " +
                         cache.getNumberOfPartitions(linkLevel) +
                         " partition(s)...");
    System.out.println("\n");
  }


  static void preloadAllPartitions(CachedNetworkIO networkIO,
                                   int noOfLinkLevels,
                                   boolean readFromBlob) throws Exception {


    for (int linkLevel = 1; linkLevel <= noOfLinkLevels; linkLevel++) {
      // find out partition IDs on a linklevel
      int[] pids = networkIO.readPartitionIds(linkLevel);
      int[] userDataCategories = { 0 }; // userdata category = 0 only

      if (pids == null ||
          pids.length == 0) { // whole network partition blob cases
        int pid = 0; // default partition Id for whole network partition blob
        networkIO.readLogicalPartition(pid, linkLevel, userDataCategories,
                                       readFromBlob);

      } else {
        networkIO.readLogicalPartitions(linkLevel, userDataCategories,
                                        readFromBlob);
      }

    }

  }
}
