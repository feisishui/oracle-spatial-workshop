/* $Header: sdo/demo/network/examples/java/src/inmemory/NetworkState.java /main/3 2012/12/10 11:18:30 begeorge Exp $ */

/* Copyright (c) 2004, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   DESCRIPTION
    This sample program shows how to turn on/off of network nodes and links

   MODIFIED    (MM/DD/YY)
    hgong       02/13/07 - change to HILLSBOROUGH_NETWORK
    jcwang      03/12/04 - jcwang_improve_cache
    jcwang      03/09/04 - Creation
 */

package inmemory;

import oracle.jdbc.OracleConnection;
import oracle.jdbc.pool.OracleDataSource;

import oracle.spatial.network.Link;
import oracle.spatial.network.Network;
import oracle.spatial.network.NetworkManager;
import oracle.spatial.network.Node;
import oracle.spatial.network.Path;

/**
 *  @version $Header: sdo/demo/network/examples/java/src/inmemory/NetworkState.java /main/3 2012/12/10 11:18:30 begeorge Exp $
 *  @author  jcwang
 *  @since   release specific (what release of product did this appear in)
 */

/**
 * This sample program shows how to turn on/off of network nodes and links
 * using setState(boolean state) method. Nodes and links that are inactive
 * will not be taken into account in network analysis.
 * The state of a node or link is indicated in the ACTIVE column in the node
 * and link table when it is loaded from database. The setState method will not
 * chnage the ACTIVE column in the database.
 */
public class NetworkState
{

  public static void main(String[] args)
  {
    //Get input parameters
    String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser = "";
    String dbPassword = "";

    String networkName = "HILLSBOROUGH_NETWORK";
    int startNodeId = 1533;
    int endNodeId = 10043;
    int[] inactiveNodes = { 1908, 2173 };
    int[] inactiveLinks = { 145485139, 145482599 };

    for (int i = 0; i < args.length; i++)
    {
      if (args[i].equalsIgnoreCase("-dbUrl"))
        dbUrl = args[i + 1];
      else if (args[i].equalsIgnoreCase("-dbUser"))
        dbUser = args[i + 1];
      else if (args[i].equalsIgnoreCase("-dbPassword"))
        dbPassword = args[i + 1];
      else if (args[i].equalsIgnoreCase("-networkName") &&
               args[i + 1] != null)
        networkName = args[i + 1].toUpperCase();
      else if (args[i].equalsIgnoreCase("-startNodeId"))
        startNodeId = Integer.parseInt(args[i + 1]);
      else if (args[i].equalsIgnoreCase("-endNodeId"))
        endNodeId = Integer.parseInt(args[i + 1]);
    }

    try
    {
      // get jdbc connection
      OracleConnection con = null;
      OracleDataSource ds = new OracleDataSource();
      ds.setURL(dbUrl);
      ds.setUser(dbUser);
      ds.setPassword(dbPassword);
      con = (OracleConnection) ds.getConnection();
      con.setAutoCommit(false);

      // Load networks from database
      Network network =
        NetworkManager.readNetwork(con, networkName);

      // Close the database connection
      con.close();
      // shortest path with no elements turned off
      Path path =
        NetworkManager.shortestPath(network, startNodeId, endNodeId);
      if (path != null)
        System.out.println("Shortest Path (Node[1](Link[1])Node[2]...(Link[n-1])N[n]) \nWITHOUT inactive elements: " +
                           path);

      // now turn off some nodes and links
      for (int i = 0; i < inactiveNodes.length; i++)
      {
        Node node = network.getNode(inactiveNodes[i]);
        node.setState(false);
      }

      for (int i = 0; i < inactiveLinks.length; i++)
      {
        Link link = network.getLink(inactiveLinks[i]);
        link.setState(false);
      }

      // shortest path with some inactive nodes/links
      path = NetworkManager.shortestPath(network, startNodeId, endNodeId);
      if (path != null)
      {
        System.out.println("Inactive Elements:");
        System.out.print("  Inactive Nodes:\n  ");
        for (int i = 0; i < inactiveNodes.length; i++)
          System.out.print(inactiveNodes[i] + " ");

        System.out.print("\n  Inactive Links:\n  ");
        for (int i = 0; i < inactiveLinks.length; i++)
          System.out.print(inactiveLinks[i] + " ");

        System.out.println("\n\nShortest Path (Node[1](Link[1])Node[2]...(Link[n-1])N[n]) WITH inactive elements:" +
                           path);
      }

      // re-set the element state if needed
      for (int i = 0; i < inactiveNodes.length; i++)
      {
        Node node = network.getNode(inactiveNodes[i]);
        node.setState(true);
      }
      for (int i = 0; i < inactiveLinks.length; i++)
      {
        Link link = network.getLink(inactiveLinks[i]);
        link.setState(true);
      }

    }
    catch (Exception e)
    {
      System.err.println(e.getMessage());
      e.printStackTrace();
    }
  }
}
