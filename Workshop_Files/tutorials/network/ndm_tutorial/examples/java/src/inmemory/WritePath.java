/* $Header: sdo/demo/network/examples/java/src/inmemory/WritePath.java /main/2 2012/12/10 11:18:30 begeorge Exp $ */

/* Copyright (c) 2007, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   DESCRIPTION
    This sample program shows how to write a computed path back to a database.

   MODIFIED    (MM/DD/YY)
    hgong       02/12/07 - Creation
 */

package inmemory;
import oracle.jdbc.OracleConnection;
import oracle.jdbc.pool.OracleDataSource;

import oracle.spatial.network.Network;
import oracle.spatial.network.NetworkManager;
import oracle.spatial.network.Path;

/**
 *  This sample program shows how to write a computed path back to a database.
 *  @version $Header: sdo/demo/network/examples/java/src/inmemory/WritePath.java /main/2 2012/12/10 11:18:30 begeorge Exp $
 *  @author  hgong
 *  @since   release specific (what release of product did this appear in)
 */
public class WritePath
{

  public static void main(String[] args)
  {
    String dbUrl       = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser      = "";
    String dbPassword  = "";

    String networkName = "HILLSBOROUGH_NETWORK";
    int startNodeId = 230;
    int endNodeId = 872;

    //get input parameters
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

      Network net =
        NetworkManager.readNetwork(con, networkName, true);
      System.out.println("The network is loaded");

      Path sPath =
        NetworkManager.shortestPath(net, startNodeId, endNodeId);
      sPath.computeGeometry(0.05);
      net.addPath(sPath);

      NetworkManager.writeNetwork(con, net);
      System.out.println("Check the HILLSBOROUGH_NETWORK_PATH$ for the resultant path");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }
}
