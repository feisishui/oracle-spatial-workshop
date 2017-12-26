/* $Header: sdo/demo/network/examples/java/src/inmemory/SubPathAnalysis.java /main/3 2012/12/10 11:18:30 begeorge Exp $ */

/* Copyright (c) 2007, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   DESCRIPTION
    This test class demonstrates how to find shortest path with start and/or end
    point on a link using the in-memory network data model.

   MODIFIED    (MM/DD/YY)
    hgong       03/16/07 - change percentage range to [0,1]
    hgong       02/13/07 - Creation
 */

package inmemory;

import java.sql.SQLException;

import java.text.DecimalFormat;
import java.text.NumberFormat;

import oracle.jdbc.OracleConnection;
import oracle.jdbc.pool.OracleDataSource;

import oracle.spatial.network.Network;
import oracle.spatial.network.NetworkFactory;
import oracle.spatial.network.NetworkManager;
import oracle.spatial.network.Path;
import oracle.spatial.network.SubPath;

/**
 * This test class demonstrates how to find shortest path with start and/or end
 * point on a link using the in-memory network data model.
 * 
 * @version $Header: sdo/demo/network/examples/java/src/inmemory/SubPathAnalysis.java /main/3 2012/12/10 11:18:30 begeorge Exp $
 * @author  hgong   
 * @since   11g
 */
public class SubPathAnalysis {
  
  private static final NumberFormat formatter = new DecimalFormat("#.######");
  
  public static OracleConnection getConnection(String dbURL,
    String user, String password) throws SQLException
  {
    OracleConnection conn = null;
    OracleDataSource ds   = new OracleDataSource();
    ds.setURL(dbURL);
    ds.setUser(user);
    ds.setPassword(password);
    conn = (OracleConnection)ds.getConnection();    
    conn.setAutoCommit(false);
    return conn;
  }
  
  public static void printPath(Path path) {
    if ( path!= null ) 
    {
      String msg = " Path["+ path.getID() +"] (Node[" + 
                        path.getStartNode().getID() + "]-> Node[" + 
                        path.getEndNode().getID() + "], Link[" + 
                        path.getLinkAt(0).getID() + "]-> Link[" + 
                        path.getLinkAt(path.getNoOfLinks()-1).getID() + "], Cost: " +
                        path.getCost() + ", NumLinks: " +
                        path.getNoOfLinks();
      if (!path.isSimple())
        msg += " [Complex]" ;  
      msg += ")\n";
      System.out.print(msg);
    }     
    else
    {
      System.out.println("Path is null.");
    } 
  }
  
  
  private static void printSubPath(SubPath subPath)
  {
    if ( subPath == null )  
    {
      System.out.println("SubPath is null.");
      return ;
    }
    Path path = subPath.getReferencePath();
    if ( path!= null ) 
    {
      double cost = subPath.getCost();
      int startLinkID = path.getLinkAt(subPath.getStartLinkIndex()).getID();
      int endLinkID = path.getLinkAt(subPath.getEndLinkIndex()).getID();
      String msg = " SubPath: (Path Start Node[" +
                        path.getStartNode().getID() + "]-> End Node[" + 
                        path.getEndNode().getID() + "])\n " +
                        " Start Link:" +
                        startLinkID + "[" + formatter.format(subPath.getStartPercentage()*100) + "%]" +
                        ", End Link:" + 
                        endLinkID + "[" + formatter.format(subPath.getEndPercentage()*100) +
                        "%], Cost:" + formatter.format(cost) + ", NumLinks: " +
                        path.getNoOfLinks() +  "\n";

      System.out.print(msg);
    }
    System.out.println("  Is Valid? :" + subPath.isValid() +   
                    ", Is Full Path? :" + subPath.isFullPath());
  }
  
  public static void main(String [] args) { 
    //Get input parameters
    String dbUrl      = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser     = "";
    String dbPassword = "";
    
    String networkName = "HILLSBOROUGH_NETWORK";
    int startNodeId    = 1533;
    int endNodeId      = 10043;
    int startLinkId    = 145486327;
    int endLinkId      = 145479737;
    double startPercentage = 0.5;
    double endPercentage = 0.5;
     
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
      else if(args[i].equalsIgnoreCase("-startLinkId"))
        startLinkId = Integer.parseInt(args[i+1]);
      else if(args[i].equalsIgnoreCase("-endLinkId"))
        endLinkId = Integer.parseInt(args[i+1]);
      else if(args[i].equalsIgnoreCase("-startPercentage"))
        startPercentage = Double.parseDouble(args[i+1]);
      else if(args[i].equalsIgnoreCase("-endPercentage"))
        endPercentage = Double.parseDouble(args[i+1]);
    }
            
    OracleConnection conn = null;
    Network network = null;
    Path path = null;  
    SubPath subPath = null;

    try {
      // get jdbc connection
      conn = getConnection(dbUrl, dbUser, dbPassword);
      
      // read in network
      network = NetworkManager.readNetwork(conn,networkName);

      // perform shortest path analysis
      // classical shortest path
      path = NetworkManager.shortestPath(network, startNodeId, endNodeId);
      printPath(path);
      
      // create subpath from a path
      subPath =  NetworkFactory.createSubPath(path,0,startPercentage,
                                  path.getNoOfLinks()-1,endPercentage);
      printSubPath(subPath);
      
      // shortest path with start point on link
      subPath = NetworkManager.shortestPath(network, startLinkId, startPercentage, endNodeId, null);
      printSubPath(subPath);

      // shortest path with end point on link
      subPath = NetworkManager.shortestPath(network, startNodeId, endLinkId, endPercentage, null);
      printSubPath(subPath);

      // shortest path with both start and end points on link
      subPath = NetworkManager.shortestPath(network, startLinkId, startPercentage, endLinkId, endPercentage,null);
      printSubPath(subPath); 

    } catch ( Exception e) {
      e.printStackTrace();
    }
    finally
    {
      if(conn!=null)
      {
        try{ conn.close(); } catch(Exception ex){}
      }
    }
  }  

}
