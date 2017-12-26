/* $Header: sdo/demo/network/examples/java/src/inmemory/EditNetwork.java /main/4 2012/12/10 11:18:30 begeorge Exp $ */

/* Copyright (c) 2004, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   DESCRIPTION
    <short description of component this file declares/defines>

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    hgong       02/08/07 -
    jcwang      01/04/05 - change dynamic to temporary
    jcwang      11/23/04 - jcwang_cookbook
    jcwang      11/17/04 - Creation
 */
package inmemory;

import oracle.jdbc.OracleConnection;

import oracle.jdbc.pool.OracleDataSource;

import oracle.spatial.network.*;

/**
 * This sample program shows how to edit a network by adding a node and two links
 * on a given link through the addNode(link,ratio,isTemporary) method.
 * ratio is a number between 0 and 1 that indicates the location along the given link.
 * The newly added elements can be temporary (controlled by isTemporary).
 * Temporary elements will not be written to the database.
 * The original given link is not affected after the operation.
 * IDs will be automatically assigned. Link costs will be linearly interpolated
 * based on the cost of the given link and ratio.
 * @version $Header: sdo/demo/network/examples/java/src/inmemory/EditNetwork.java /main/4 2012/12/10 11:18:30 begeorge Exp $
 * @author  jcwang
 * @since   release specific (what release of product did this appear in)
 */
public class EditNetwork
{
  public static void main(String[] args)
  {
    //Get connection parameters
    String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser = "";
    String dbPassword = "";

    for (int i = 0; i < args.length; i++)
    {
      if (args[i].equalsIgnoreCase("-dbUrl"))
        dbUrl = args[i + 1];
      else if (args[i].equalsIgnoreCase("-dbUser"))
        dbUser = args[i + 1];
      else if (args[i].equalsIgnoreCase("-dbPassword"))
        dbPassword = args[i + 1];
    }

    try
    {
      // get jdbc connection
      OracleConnection connection = null;
      OracleDataSource ds = new OracleDataSource();
      ds.setURL(dbUrl);
      ds.setUser(dbUser);
      ds.setPassword(dbPassword);
      connection = (OracleConnection) ds.getConnection();
      connection.setAutoCommit(false);

      // Load networks from database
      boolean readForUpdate = false;
      Network network =
        NetworkManager.readNetwork(connection, "BI_TEST", readForUpdate);

      // pick the target link to add new node and links
      Link link = network.getLink(1);
      double ratio = 0.5;
      boolean isTemporary = true;
      // add a new node at the middle of link 1
      // it also creates two new links
      Node newNode1 = network.addNode(link, ratio, isTemporary);
      System.out.println("First new node: " + newNode1);
      link = network.getLink(50);
      // add another node at the middle of link 50
      // it also creates two new links
      Node newNode2 = network.addNode(link, ratio, isTemporary);
      System.out.println("Second new node: " + newNode2);

      Node[] temporaryNodeArray = null;
      Link[] temporaryLinkArray = null;

      temporaryNodeArray = network.getTemporaryNodeArray();
      temporaryLinkArray = network.getTemporaryLinkArray();

      if (temporaryNodeArray != null)
      {
        System.out.println("Temporary Nodes:");
        for (int i = 0; i < temporaryNodeArray.length; i++)
          System.out.println(temporaryNodeArray[i]);

      }
      if (temporaryLinkArray != null)
      {
        System.out.println("Temporary Links:");
        for (int i = 0; i < temporaryLinkArray.length; i++)
          System.out.println(temporaryLinkArray[i]);

      }
      // find the shortest path between two newly added nodes
      Path path =
        NetworkManager.shortestPath(network, newNode1.getID(), newNode2.getID());
      if (path != null)
        System.out.println(path);
      network.addPath(path);
      System.out.println("Network has " + network.getNoOfPaths() +
                         " path(s)...");
      network.deleteNode(newNode1.getID());
      temporaryNodeArray = network.getTemporaryNodeArray();
      temporaryLinkArray = network.getTemporaryLinkArray();

      if (temporaryNodeArray != null)
      {
        System.out.println("Temporary Nodes After deleting Node:" +
                           newNode1.getID());
        for (int i = 0; i < temporaryNodeArray.length; i++)
          System.out.println(temporaryNodeArray[i]);

      }
      if (temporaryLinkArray != null)
      {
        System.out.println("Temporary Links After deleting Node:" +
                           newNode1.getID());
        for (int i = 0; i < temporaryLinkArray.length; i++)
          System.out.println(temporaryLinkArray[i]);

      }
      System.out.println("Network has " + network.getNoOfPaths() +
                         " path(s)...");
      // Close the database connection
      connection.close();

    }
    catch (Exception e)
    {
      System.err.println(e.getMessage());
      e.printStackTrace();
    }
  }
}
