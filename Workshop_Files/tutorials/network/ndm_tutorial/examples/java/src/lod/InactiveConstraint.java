/* $Header: sdo/demo/network/examples/java/src/lod/InactiveConstraint.java /main/2 2012/12/10 11:18:29 begeorge Exp $ */

/* Copyright (c) 2011, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   DESCRIPTION
    <short description of component this file declares/defines>

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)

 */

/**
 *  @version $Header: sdo/demo/network/examples/java/src/lod/InactiveConstraint.java /main/2 2012/12/10 11:18:29 begeorge Exp $
 *  @author  jcwang
 *  @since   release specific (what release of product did this appear in)
 */

package lod;

import java.io.InputStream;

import java.sql.Connection;
import java.sql.SQLException;

import java.util.HashSet;
import java.util.Iterator;

import oracle.jdbc.OracleConnection;
import oracle.jdbc.pool.OracleDataSource;

import oracle.spatial.network.lod.LODAnalysisInfo;
import oracle.spatial.network.lod.LODNetworkConstraint;
import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.LogicalPath;
import oracle.spatial.network.lod.NetworkIO;
import oracle.spatial.network.lod.LogicalSubPath;
import oracle.spatial.network.lod.PointOnNet;
import oracle.spatial.network.lod.util.PrintUtility;
import oracle.spatial.util.Logger;
import oracle.spatial.network.lod.config.LODConfig;

/**
 *  This class demonstrates how to use network constraint for inactive nodes/links during
 *  network analysis.
 *
 */

public class InactiveConstraint {
  private static NetworkAnalyst analyst;

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

  public static OracleConnection getConnection(String dbURL, String user,
                                               String password) throws SQLException {
    OracleConnection conn = null;
    OracleDataSource ds = new OracleDataSource();
    ds.setURL(dbURL);
    ds.setUser(user);
    ds.setPassword(password);
    conn = (OracleConnection)ds.getConnection();
    conn.setAutoCommit(false);
    return conn;
  }

  public static void main(String[] args) {
    //Get input parameters
    String configXmlFile = "lod/LODConfigs.xml";
    String logLevel = "ERROR";

    String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser = "";
    String dbPassword = "";


    String networkName = "NAVTEQ_SF";
    long startNodeId = 199535084;
    long endNodeId = 199852167;

    long[] inactiveNodeIDs = { 0 };
    long[] inactiveLinkIDs = { 0 };

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
      else if (args[i].equalsIgnoreCase("-startNodeId"))
        startNodeId = Long.parseLong(args[i + 1]);
      else if (args[i].equalsIgnoreCase("-endNodeId"))
        endNodeId = Long.parseLong(args[i + 1]);
      else if (args[i].equalsIgnoreCase("-configXmlFile"))
        configXmlFile = args[i + 1];
      else if (args[i].equalsIgnoreCase("-logLevel"))
        logLevel = args[i + 1];
    }

    System.out.println("Network analysis result for " + networkName);

    try {
      setLogLevel(logLevel);

      //load user specified LOD configuration (optional), otherwise default configuration will be used
      InputStream config =
        ClassLoader.getSystemResourceAsStream(configXmlFile);
      LODNetworkManager.getConfigManager().loadConfig(config);
      LODConfig c =
        LODNetworkManager.getConfigManager().getConfig(networkName);
      //get jdbc connection
      conn = getConnection(dbUrl, dbUser, dbPassword);
      //get network input/output object
      NetworkIO reader =
        LODNetworkManager.getCachedNetworkIO(conn, networkName, networkName,
                                             null);
      //get network analyst
      analyst = LODNetworkManager.getNetworkAnalyst(reader);



      // shortest path without inactive constraint
      LogicalSubPath path1 =
        analyst.shortestPathDijkstra(new PointOnNet(startNodeId),
                                     new PointOnNet(endNodeId), null);
      PrintUtility.print(System.out, path1, true, 20, 0);
      

      // pick a node and link from path 1
      LogicalPath p = path1.getReferencePath();
      int noOfLinksinPath = p.getNumberOfLinks();
      inactiveNodeIDs[0] = p.getNodeIds()[1]; // disable second node in path
      inactiveLinkIDs[0] = p.getLastLinkId(); // disable last link in path

      MyInactiveConstraint inactiveConstraint =
        new MyInactiveConstraint(inactiveNodeIDs, inactiveLinkIDs);
      

      System.out.println("\nPath with inactive nodes/links in constraint ? " +
                         inactiveConstraint.pathWithInactiveElements(path1));

      // shortest path with inactive constraint
      // print inactive constraint
      System.out.println("The 2nd node and the last link of previously found path are now disabled!") ;
      System.out.println("\nInactive constraint:\n" +
          inactiveConstraint);
      
      LogicalSubPath path2 =
        analyst.shortestPathDijkstra(new PointOnNet(startNodeId),
                                     new PointOnNet(endNodeId),
                                     inactiveConstraint);
      PrintUtility.print(System.out, path2, true, 20, 0);
      System.out.println("\nPath with inactive nodes/links in constraint ? " +
                         inactiveConstraint.pathWithInactiveElements(path2));
    } catch (Exception ex) {
      ex.printStackTrace();
    }
  }


  public static class MyInactiveConstraint implements LODNetworkConstraint {
    private static HashSet<Long> inactiveNodeIDSet = new HashSet<Long>();
    private static HashSet<Long> inactiveLinkIDSet = new HashSet<Long>();

    // construct inactive node and link IDs in a HashSet

    public MyInactiveConstraint(long[] inactiveNodeIDs,
                                long[] inactiveLinkIDs) {
      if (inactiveNodeIDs != null)
        for (int i = 0; i < inactiveNodeIDs.length; i++)
          inactiveNodeIDSet.add(inactiveNodeIDs[i]);

      if (inactiveLinkIDs != null)
        for (int i = 0; i < inactiveLinkIDs.length; i++)
          inactiveLinkIDSet.add(inactiveLinkIDs[i]);

    }

    public boolean isSatisfied(LODAnalysisInfo info) {
      Long nextLinkID = new Long(info.getNextLink().getId());
      Long nextNodeID = new Long(info.getNextNode().getId());
      if (inactiveNodeIDSet.contains(nextNodeID) ||
          inactiveLinkIDSet.contains(nextLinkID))
        return false;
      else
        return true;

    }


    public int getNumberOfUserObjects() {
      return 0;
    }

    public boolean isCurrentNodePartiallyExpanded(LODAnalysisInfo info) {
      return false;
    }

    public boolean isNextNodePartiallyExpanded(LODAnalysisInfo info) {
      return false;
    }

    public int[] getUserDataCategories() {
      return (int[])null;
    }

    public void reset() {
    }

    public void setNetworkAnalyst(NetworkAnalyst analyst) {
    }

    public String toString() {
      StringBuffer buf = new StringBuffer();
      if (!inactiveNodeIDSet.isEmpty()) {
        buf.append("\tInactive Node ID:(\n");
        for (Iterator it = inactiveNodeIDSet.iterator(); it.hasNext(); )
          buf.append("\t" + it.next() + "\n");
        buf.append(")\n");
      }
      if (!inactiveLinkIDSet.isEmpty()) {
        buf.append("\tInactive Link ID:(\n");
        for (Iterator it = inactiveLinkIDSet.iterator(); it.hasNext(); )
          buf.append("\t" +it.next() + "\n");
        buf.append(")\n");
      }
      return buf.toString();

    }

    public boolean pathWithInactiveElements(LogicalSubPath path) {
      long[] linkIDs = path.getReferencePath().getLinkIds();
      long[] nodeIDs = path.getReferencePath().getNodeIds();
      // check path links
      if (!inactiveLinkIDSet.isEmpty()) {
        for (int i = 0; i < linkIDs.length; i++)
          if (inactiveLinkIDSet.contains(new Long(linkIDs[i])))
            return true;
      }
      // check path nodes
      if (!inactiveNodeIDSet.isEmpty()) {
        for (int i = 0; i < nodeIDs.length; i++)
          if (inactiveNodeIDSet.contains(new Long(nodeIDs[i])))
            return true;
      }
      return false;
    }
  }

}
