/* $Header: sdo/demo/network/examples/java/src/inmemory/PathOperation.java /main/2 2012/12/10 11:18:30 begeorge Exp $ */

/* Copyright (c) 2007, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   DESCRIPTION
    This test class demonstrates how to perform path operations in the in-memory 
    network data model.

   MODIFIED    (MM/DD/YY)
    hgong       02/13/07 - Creation
 */

package inmemory;
 
import java.sql.SQLException;

import java.text.DecimalFormat;
import java.text.NumberFormat;

import java.util.ArrayList;

import oracle.jdbc.OracleConnection;

import oracle.jdbc.pool.OracleDataSource;

import oracle.spatial.network.Link;
import oracle.spatial.network.Network;
import oracle.spatial.network.NetworkFactory;
import oracle.spatial.network.NetworkManager;
import oracle.spatial.network.Node;
import oracle.spatial.network.Path;

/**
 * This test class demonstrates how to perform path operations in the in-memory 
 * network data model.
 * 
 * @version $Header: sdo/demo/network/examples/java/src/inmemory/PathOperation.java /main/2 2012/12/10 11:18:30 begeorge Exp $
 * @author  hgong   
 * @since   release specific (what release of product did this appear in)
 */
public class PathOperation {
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
  
  private static int[] getPathLinkIds(Path path)
  {
    Link[] links = path.getLinkArray();
    int[] linkIds = new int[links.length];
    for(int i=0; i<links.length; i++)
    {
      linkIds[i] = links[i].getID();
    }
    return linkIds;
  }
  
  private static Path createPathFromPathLinkIds(Network network,
    int startNodeId, int endNodeId, int[] pathLinkIds)
  {
    Path path = null;
    try{
      Link [] pathLinks = null; 
      pathLinks = new Link[pathLinkIds.length];
      for ( int i = 0; i < pathLinks.length; i++)
        pathLinks[i] = network.getLink(pathLinkIds[i]) ;
      
      Node startNode = network.getNode(startNodeId) ;
      Node endNode = network.getNode(endNodeId);
  
      path = NetworkFactory.createPath(1, startNode, endNode, pathLinks);
    }
    catch(Exception e)
    {
      e.printStackTrace();
    }
    return path;
  }
  
  public static void main(String [] args) { 
    //Get input parameters
    String dbUrl      = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser     = "";
    String dbPassword = "";
    
    String networkName = "HILLSBOROUGH_NETWORK";
    int startNodeId    = 1533;
    int endNodeId      = 10043;
     
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
  
    OracleConnection conn = null;
    Network network = null;
    Path path = null, subPath = null, revPath = null, 
         subP1 = null, subP2 = null, subP3 = null, subP4 = null;

    try {
      // get jdbc connection
      conn = getConnection(dbUrl, dbUser, dbPassword);
      
      // read in network
      network = NetworkManager.readNetwork(conn,networkName);

      // perform shortest path analysis
      // classical shortest path
      path = NetworkManager.shortestPath(network, startNodeId, endNodeId);
      printPath(path);
      
      // get path link IDs
      int[] pathLinkIds = getPathLinkIds(path);
      
      // recreate path from path link IDs
      path = createPathFromPathLinkIds(network, startNodeId, endNodeId, pathLinkIds);
      printPath(path);
      
      // get sub path
      subPath = path.getSubPath(1, path.getNoOfLinks()-1);
      System.out.println("\nSubPath:") ;
      printPath(subPath);
      
      // subtract the subPath from the original path
      ArrayList list = path.subtract(subPath);
      System.out.println("Path contains subPath: " + path.contains(subPath)) ;
      System.out.println("Path contains Path: " + path.contains(path)) ;
      System.out.println("subPath contains Path: " + subPath.contains(path)) ;
      System.out.println("subPath contains subPath: " + subPath.contains(subPath)) ;
      System.out.println("Path, subPath have same direction: " + 
                         path.isSameDirection(subPath));

      System.out.println("\nPath, Path getCommonPaths") ;
      list = path.getCommonSubPaths(path);
      System.out.println(list);
      System.out.println("\nPath, SubPath getCommonPaths") ;
      list = path.getCommonSubPaths(subPath);
      System.out.println(list);
      
      // reverse path  
      // exception is thrown when the path has no reverse path
      try{
        revPath = path.reverse();
        System.out.println("\nReverse path:");
        System.out.println(revPath);
        revPath.validate();
        System.out.println("Path,revPath have same direction: " + path.isSameDirection(revPath)) ;
        System.out.println("Path, revPath Common links:\n" + path.getCommonLinks(revPath)) ;
        System.out.println("Path, revPath Common nodes:\n" + path.getCommonNodes(revPath).size()) ;
      }
      catch(Exception ex) {
        System.out.println("\n"+ex.getMessage());
      }
      
      // add path
      subP1 = path.getSubPath(0,2);
      subP2 = path.getSubPath(1,3);
      subP3 = path.getSubPath(2,5);
      subP4 = path.getSubPath(6,8);
      
      System.out.println("\nsub path1(0,2) " + subP1);
      System.out.println("\nsub path2(1,3) " + subP2);
      System.out.println("\nsub path3(2,5) " + subP3);
      System.out.println("\nsub path4(6,8) " + subP4);

      //add path
      System.out.println("\nAdd  sub path1, sub path1 :\n" + subP1.add(subP1));
      System.out.println("\nAdd  sub path1, sub path2 :\n" + subP1.add(subP2)); 
      System.out.println("\nAdd  sub path2, sub path1 :\n" + subP2.add(subP1)); 
      System.out.println("\nAdd  sub path2, sub path3 :\n" + subP2.add(subP3)); 
      System.out.println("\nAdd  sub path3, sub path2 :\n" + subP3.add(subP2)); 
      System.out.println("\nAdd  sub path1, sub path3 :\n" + subP1.add(subP3));
      System.out.println("\nAdd  sub path3, sub path1 :\n" + subP3.add(subP1)); 
      System.out.println("\nAdd  sub path1, sub path4 :\n" + subP1.add(subP4));
      System.out.println("\nAdd  sub path4, sub path1 :\n" + subP4.add(subP1)); 
      //add a list of paths
      ArrayList aList = new ArrayList();
      aList.clear();
      aList.add(subP2);
      aList.add(subP3) ;
      System.out.println("\nAdd sub path2 path3 to sub path1: \n" + subP1.add(aList));
      aList.clear();
      aList.add(subP3);
      aList.add(subP2) ;
      System.out.println("\nAdd sub path3 path2 to sub path1: \n" + subP1.add(aList)); 
      aList.clear();
      aList.add(subP1);
      aList.add(subP3);
      System.out.println("\nAdd sub path1 path3 to sub path2: \n" + subP2.add(aList)); 
      aList.clear();
      aList.add(subP3);
      aList.add(subP1) ;
      System.out.println("\nAdd sub path3 path1 to sub path2: \n" + subP2.add(aList)); 
      aList.clear();
      aList.add(subP3);
      aList.add(subP1) ;
      aList.add(subP2) ;
      System.out.println("\nAdd sub path3 path1 path 2 to sub path4: \n" + subP4.add(aList));
      aList.clear();
      aList.add(subP4);
      aList.add(subP1) ;
      aList.add(subP2) ;
      System.out.println("\nAdd sub path4 path1 path 2 to sub path3: \n" + subP3.add(aList)); 
      System.out.println("subP1, subP2 has the same direction:" + subP1.isSameDirection(subP2));           
    } catch ( Exception e) 
    {
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
