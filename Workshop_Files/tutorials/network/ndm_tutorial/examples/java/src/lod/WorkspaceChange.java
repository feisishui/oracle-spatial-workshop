/* $Header: sdo/demo/network/examples/java/src/lod/WorkspaceChange.java /main/6 2012/12/10 11:18:29 begeorge Exp $ */

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

import java.sql.CallableStatement;
import java.sql.Connection;

import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.sql.Statement;
import java.sql.Types;

import oracle.spatial.network.NetworkMetadata;
import oracle.spatial.network.lod.CachedNetworkIOWM;
import oracle.spatial.network.lod.LODNetworkException;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.LogicalLink;
import oracle.spatial.network.lod.LogicalSubPath;
import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.PointOnNet;
import oracle.spatial.network.lod.util.PrintUtility;
import oracle.spatial.util.Logger;

/**
 *  This class demonstrates how to update network cache after switching to
 *  a different workspace.
 *  @version $Header: sdo/demo/network/examples/java/src/lod/WorkspaceChange.java /main/6 2012/12/10 11:18:29 begeorge Exp $
 *  @author  hgong
 *  @since   11gR1
 */
public class WorkspaceChange
{
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
  
  public static void testShortestPath(NetworkAnalyst analyst, 
    long startNodeId, long endNodeId)
  {
    try
    {
      LogicalSubPath path =
        analyst.shortestPathDijkstra(new PointOnNet(startNodeId), 
          new PointOnNet(endNodeId), null);

      System.out.println("Shortest path: ");
      PrintUtility.print(System.out, path, true, 10000, 1);
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }

  //////////////////////////////////////
  // Workspace Related functions 
  //////////////////////////////////////
  private static void rollbackWorkspace(Connection conn, String workspace)
    throws SQLException
  {

    CallableStatement cstmt = null;
    try
    {
      cstmt =
          conn.prepareCall("begin  DBMS_WM.rollbackWorkspace(?); end; ");
      cstmt.setString(1, workspace);
      cstmt.execute();
    }
    finally
    {
      if (cstmt != null)
        cstmt.close();
    }
  }

  private static boolean workspaceExists(Connection conn, String workspace)
  {
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    int no = 0;
    try
    {

      String sqlStr =
        " Select count(*) from all_workspaces  " + " Where workspace = ? ";

      pstmt = conn.prepareStatement(sqlStr);
      pstmt.setString(1, workspace);

      rs = pstmt.executeQuery();
      if (rs.next())
        no = rs.getInt(1);
    }
    catch (SQLException ex)
    {
      ;
    }
    finally
    {
      try
      {
        if (rs != null)
          rs.close();
        if (pstmt != null)
          pstmt.close();
      }
      catch (Exception ignore){}
    }
    return (no > 0);

  }

  private static void removeWorkspace(Connection conn, String workspace)
    throws SQLException
  {

    CallableStatement cstmt = null;
    try
    {
      cstmt = conn.prepareCall("begin  DBMS_WM.removeWorkspace(?); end; ");
      cstmt.setString(1, workspace);
      cstmt.execute();
    }
    finally
    {
      if (cstmt != null)
        cstmt.close();
    }
  }
  
  private static void versionTable(Connection conn, String tableName)
  {

    CallableStatement cstmt = null;
    try
    {
      cstmt = conn.prepareCall("begin DBMS_WM.enableVersioning(?); end; ");
      cstmt.setString(1, tableName);
      cstmt.execute();
    }
    catch(SQLException ex)
    {
      ex.printStackTrace();
    }
    finally
    {
      if (cstmt != null)
        try{ cstmt.close(); } catch(Exception ignore){}
    }
  }  

  private static void versionNetwork(Connection conn, String networkName)
    throws SQLException, LODNetworkException
  {
    NetworkMetadata meta =
      LODNetworkManager.getNetworkMetadata(conn, networkName, null);

    String nodeTableName = meta.getNodeTableName(true);
    String linkTableName = meta.getLinkTableName(true);
    String partTableName = meta.getPartitionTableName(true);

    versionTable(conn, nodeTableName);
    versionTable(conn, linkTableName);
    if(partTableName!=null)
      versionTable(conn, partTableName);
    if (meta.getPathGeomMetadata() != null)
    {
      String pathTableName = meta.getPathTableName(true);
      String plinkTableName = meta.getPathLinkTableName(true);
      if (pathTableName != null && plinkTableName != null)
      {
        versionTable(conn, pathTableName);
        versionTable(conn, plinkTableName);
      }
    }
    if (meta.getSubPathGeomMetadata() != null)
    {
      String subPathTableName = meta.getPathTableName(true);
      if (subPathTableName != null)
      {
        versionTable(conn, subPathTableName);
      }
    }
  }

  // Check if the table is version enabled
  private static boolean isTableVersioned(Connection conn, String owner,
                                  String tableName)
    throws SQLException
  {
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    boolean result = false;
    if (owner == null || tableName == null)
      return result;
    try
    {

      String sqlStr =
        " Select count(*) from all_wm_versioned_tables " + " Where owner = ? and table_name = ?";

      pstmt = conn.prepareStatement(sqlStr);
      pstmt.setString(1, owner.toUpperCase());
      pstmt.setString(2, tableName.toUpperCase());
      rs = pstmt.executeQuery();
      int no = 0;
      if (rs.next())
        no = rs.getInt(1);
      if (no != 0)
        result = true;
    }
    catch (SQLException ex)
    {
      throw ex;
    }
    finally
    {
      if (rs != null)
        rs.close();
      if (pstmt != null)
        pstmt.close();
    }
    return result;
  }
  // cehck if all tables of a network are version enabled

  private static boolean isNetworkVersioned(Connection conn, 
                                    String networkName)
    throws SQLException, LODNetworkException
  {
    NetworkMetadata meta =
      LODNetworkManager.getNetworkMetadata(conn, networkName, null);
    return meta.isVersioned();
  }
  // return parent workspace name

  private static String getParentWorkspace(Connection conn, String owner,
                                   String workspace)
    throws SQLException
  {
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String parentWorkspace = null;
    try
    {

      String sqlStr =
        " Select parent_workspace from all_workspaces  " + 
        " Where workspace = ? and owner = ?";

      pstmt = conn.prepareStatement(sqlStr);
      pstmt.setString(1, workspace);
      pstmt.setString(2, owner.toUpperCase());
      rs = pstmt.executeQuery();
      if (rs.next())
        parentWorkspace = rs.getString(1);
    }
    catch (SQLException ex)
    {
      throw ex;
    }
    finally
    {
      if (rs != null)
        rs.close();
      if (pstmt != null)
        pstmt.close();
    }
    return parentWorkspace;
  }
  // return current workspace name

  private static String getWorkspace(Connection conn)
    throws SQLException
  {
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String workspace = null;
    try
    {

      String sqlStr = " Select DBMS_WM.getWorkspace() From Dual ";

      pstmt = conn.prepareStatement(sqlStr);
      rs = pstmt.executeQuery();
      if (rs.next())
        workspace = rs.getString(1);
    }
    catch (SQLException ex)
    {
      throw ex;
    }
    finally
    {
      if (rs != null)
        rs.close();
      if (pstmt != null)
        pstmt.close();
    }
    return workspace;
  }

  private static void gotoWorkspace(Connection conn, String workspace)
    throws SQLException
  {

    CallableStatement cstmt = null;
    try
    {

      cstmt = conn.prepareCall("begin DBMS_WM.gotoWorkspace(?); end; ");
      cstmt.setString(1, workspace);
      cstmt.execute();

    }
    finally
    {
      if (cstmt != null)
        cstmt.close();
    }
  }

  private static void gotoSavepoint(Connection conn, String savepoint)
    throws SQLException
  {

    CallableStatement cstmt = null;
    try
    {

      cstmt = conn.prepareCall("begin DBMS_WM.gotoSavepoint(?); end; ");
      cstmt.setString(1, savepoint);
      cstmt.execute();

    }
    finally
    {
      if (cstmt != null)
        cstmt.close();
    }
  }

  private static void createWorkspace(Connection conn, String workspace)
    throws SQLException
  {

    CallableStatement cstmt = null;
    try
    {
      cstmt = conn.prepareCall("begin DBMS_WM.createWorkspace(?); end; ");
      cstmt.setString(1, workspace);
      cstmt.execute();
    }
    finally
    {
      if (cstmt != null)
        cstmt.close();
    }
  }

  // return current savepoint

  private static String getSavepoint(Connection conn)
    throws SQLException
  {
    CallableStatement cstmt = null;
    String workspace = null;
    String context = null;
    String contextType = null;
    try
    {

      cstmt =
          conn.prepareCall("begin  DBMS_WM.GetSessionInfo(?,?,?); end; ");
      cstmt.registerOutParameter(1, Types.VARCHAR);
      cstmt.registerOutParameter(2, Types.VARCHAR);
      cstmt.registerOutParameter(3, Types.VARCHAR);
      cstmt.execute();
      workspace = new String(cstmt.getString(1));
      context = new String(cstmt.getString(2));
      contextType = new String(cstmt.getString(3));

    }
    finally
    {
      if (cstmt != null)
        cstmt.close();
    }
    return context;
  }
  
  private static void deleteElements(Connection con, String networkName, long nodeId)
  {
    Statement stmt = null;
    try
    {
      NetworkMetadata meta =
        LODNetworkManager.getNetworkMetadata(con, networkName, null);
      String nodeTableName = meta.getNodeTableName(true);
      String linkTableName = meta.getLinkTableName(true);
      String sqlString = null;

      stmt = con.createStatement();
      sqlString = "DELETE from " + nodeTableName + " WHERE NODE_ID = "+nodeId;
      stmt.execute(sqlString);
      sqlString =
          "DELETE from " + linkTableName + " WHERE START_NODE_ID = "+nodeId +
          " OR END_NODE_ID = "+nodeId;
      stmt.execute(sqlString);
      System.out.println("Delete Node: " + nodeId +
                         " and Links connecting Node:" + nodeId + " ...");

    }
    catch (Exception ex)
    {
      ex.printStackTrace();
    }
    finally
    {
      try
      {
        if (stmt != null)
          stmt.close();
      }
      catch (Exception ignore){}
    }

  }

  private static void addElements(Connection con, String networkName, 
    long linkToUpdate, long linkStartNodeId, long linkEndNodeId)
  {

    PreparedStatement pstmt = null;
    try
    {
      NetworkMetadata meta =
        LODNetworkManager.getNetworkMetadata(con, networkName, null);
      String nodeTableName = meta.getNodeTableName(true);
      String linkTableName = meta.getLinkTableName(true);

      String sqlString = null;
      long nodeID = 1000;   //new node
      long linkID1 = 1000;  //new link
      long linkID2 = 1001;  //new link
      double cost = 1.0;

      sqlString = "INSERT INTO " + nodeTableName + "(NODE_ID) VALUES (?)";
      pstmt = con.prepareStatement(sqlString);
      pstmt.setLong(1, nodeID);
      pstmt.executeUpdate();

      if (pstmt != null)
        pstmt.close();

      sqlString =
          "INSERT INTO " + linkTableName + 
          " (LINK_ID, START_NODE_ID, END_NODE_ID, COST) VALUES (?,?,?,?)";

      pstmt = con.prepareStatement(sqlString);
      pstmt.setLong(1, linkID1);
      pstmt.setLong(2, linkStartNodeId);
      pstmt.setLong(3, nodeID);
      pstmt.setDouble(4, cost);

      pstmt.executeUpdate();

      if (pstmt != null)
        pstmt.close();

      sqlString =
          "INSERT INTO " + linkTableName + 
          " (LINK_ID, START_NODE_ID, END_NODE_ID, COST) VALUES (?,?,?,?)";

      pstmt = con.prepareStatement(sqlString);
      pstmt.setLong(1, linkID2);
      pstmt.setLong(2, nodeID);
      pstmt.setLong(3, linkEndNodeId);
      pstmt.setDouble(4, cost);

      pstmt.executeUpdate();

      if (pstmt != null)
        pstmt.close();

      sqlString =
          "UPDATE " + linkTableName + " SET COST = ? WHERE LINK_ID = ?";
      pstmt = con.prepareStatement(sqlString);
      //long linkID3 = linkToUpdate;   //node 1-4
      double newCost = 10000.0;
      pstmt.setDouble(1, newCost);
      pstmt.setLong(2, linkToUpdate);
      pstmt.executeUpdate();

      System.out.println("Add Node:" + nodeID + " and link:" + linkID1 +
                         "(" + linkStartNodeId + "->" + nodeID + ") " +
                         " and link:" + linkID2 +
                               "(" + nodeID + "->" + linkEndNodeId + ") " +
                         " Update cost of Link: " + linkToUpdate + " to " +
                         newCost +
                         " ...");
    }
    catch (Exception ex)
    {
      ex.printStackTrace();
    }
    finally
    {
      try
      {
        if (pstmt != null)
          pstmt.close();
      }
      catch (Exception ignore){}
    }
  }

  private static void printWorkspaceInfo(Connection con)
  {
    try
    {
      System.out.println("Current WorkSpace:" + getWorkspace(con) +
                         "\nCurrent Savepoint:" + getSavepoint(con) );
    }
    catch (Exception ex)
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

    String networkName = "UN_LOGICAL";    
    int linkLevel      = 1;
    long startNodeId   = 1;
    long endNodeId     = 7;
    long linkToUpdate  = 2;
    long nodeToDelete  = 4;
    
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
      else if(args[i].equalsIgnoreCase("-linkToUpdate"))
        linkToUpdate = Long.parseLong(args[i+1]);
      else if(args[i].equalsIgnoreCase("-nodeToDelete"))
        nodeToDelete = Long.parseLong(args[i+1]);
      else if(args[i].equalsIgnoreCase("-configXmlFile"))
        configXmlFile = args[i+1];
      else if(args[i].equalsIgnoreCase("-logLevel"))
        logLevel = args[i+1];
    }

    try
    {
      System.out.println("Test updating network cache after switching workspace...");
      setLogLevel(logLevel);
      
      //load user specified LOD configuration (optional), otherwise default configuration will be used
      InputStream config = ClassLoader.getSystemResourceAsStream(
                             configXmlFile);
      LODNetworkManager.getConfigManager().loadConfig(config);

      // get jdbc connection
      Connection conn = null;
      Class.forName("oracle.jdbc.OracleDriver");
      conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
      printWorkspaceInfo(conn);
      boolean isVersioned = isNetworkVersioned(conn, networkName);

      if (!isVersioned)
      {
        versionNetwork(conn, networkName);
        isVersioned = isNetworkVersioned(conn, networkName);
      }

      System.out.println("Network:" + networkName + " is Versioned ? " +
                         isVersioned);
      String live = "LIVE";
      String ws1 = dbUser+"_ws1";
      String ws2 = dbUser+"_ws2";
      boolean ws1Exists = workspaceExists(conn, ws1);
      boolean ws2Exists = workspaceExists(conn, ws2);
      
      CachedNetworkIOWM networkIO = LODNetworkManager.getCachedNetworkIOWM(
        conn, networkName, networkName, null);
      NetworkAnalyst analyst = LODNetworkManager.getNetworkAnalyst(networkIO);
      //Network net = null;
      
      // need to go to the LIVE WS,or there will be some active sessions in the following workspaces
      gotoWorkspace(conn, live);
      //remove workspace ws1 ws2
      if (workspaceExists(conn, ws1))
        removeWorkspace(conn, ws1);
      if (workspaceExists(conn, ws2))
        removeWorkspace(conn, ws2);

      createWorkspace(conn, ws1);
      createWorkspace(conn, ws2);
      
      //go to workspace ws1 and add elements
      gotoWorkspace(conn, ws1);
      printWorkspaceInfo(conn);
      LogicalLink link = networkIO.readLogicalLink(linkToUpdate, null);
      addElements(conn, networkName, linkToUpdate, 
        link.getStartNodeId(), link.getEndNodeId());
      
      //go to workspace ws2 and delete elements
      gotoWorkspace(conn, ws2);
      printWorkspaceInfo(conn);
      deleteElements(conn, networkName, nodeToDelete);
      
      // go to LIVE
      gotoWorkspace(conn, live);
      printWorkspaceInfo(conn);
      //test shortest in LIVE
      testShortestPath(analyst, startNodeId, endNodeId);
      
      // go to WS1
      gotoWorkspace(conn, ws1);
      printWorkspaceInfo(conn);
      //update cache
      networkIO.updateNetworkCacheForWorkspaceChange(
        linkLevel, live, null, ws1, null);
      //test shortest in ws1
      testShortestPath(analyst, startNodeId, endNodeId);

      // go to WS2
      gotoWorkspace(conn, ws2);
      printWorkspaceInfo(conn);
      //update cache
      networkIO.updateNetworkCacheForWorkspaceChange(
        linkLevel, ws1, null, ws2, null);
      //test shortest in ws2
      testShortestPath(analyst, startNodeId, endNodeId);

      // go back to LIVE
      gotoWorkspace(conn, live);
      printWorkspaceInfo(conn);
      
      //clean up, restore original state
      if (!ws1Exists)
        removeWorkspace(conn, ws1);
      if (!ws2Exists)
        removeWorkspace(conn, ws2);

      conn.close();
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }

}

