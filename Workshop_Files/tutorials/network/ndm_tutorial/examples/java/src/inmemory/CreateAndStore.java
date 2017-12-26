/*
 * CreateAndStore.java
 *
 * Vishal Rao
 * Oracle Corporation
 * 21 May 2003
 *
 * This program shows how to use Oracle Network Data Model's Java API.
 * Specifically, it shows how to create a network and store it
 * in the database.
 *
 */

package inmemory;

import oracle.jdbc.OracleConnection;

import oracle.jdbc.pool.OracleDataSource;

import oracle.spatial.network.*;

public class CreateAndStore
{

  /**********************************************************************/
  private static void printNetwork(Network n)
  {
    System.out.println("Network " + n.getName() + ":");
    System.out.println("\tNodes: ");
    Node[] nodeArray = n.getNodeArray();
    for (int i = 0; i < nodeArray.length; i++)
      System.out.println("\t\tNode id " + nodeArray[i].getID());
    System.out.println("\tLinks: ");
    Link[] linkArray = n.getLinkArray();
    for (int i = 0; i < linkArray.length; i++)
      System.out.println("\t\tLink id " + linkArray[i].getID() + "   (" +
                         linkArray[i].getStartNode().getID() + " --> " +
                         linkArray[i].getEndNode().getID() + ")");
    System.out.println("\tPaths: ");
    Path[] pathArray = n.getPathArray();
    for (int i = 0; i < pathArray.length; i++)
      System.out.println("\t\tPath id " + pathArray[i].getID());
  }

  /**********************************************************************/
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

      String networkName = "TMP_NET";
      // Drop the network if it exists
      NetworkManager.dropNetwork(connection, networkName);
      Network network =
        NetworkFactory.createLogicalNetwork(networkName, 1, true);
      // create logical nodes
      for (int i = 1; i <= 4; i++)
        network.addNode(NetworkFactory.createLogicalNode(i, "N_" + i));
      // create links
      network.addLink(NetworkFactory.createLogicalLink(1, "L_1",
                                                       network.getNode(1),
                                                       network.getNode(2),
                                                       1.0));
      network.addLink(NetworkFactory.createLogicalLink(2, "L_2",
                                                       network.getNode(2),
                                                       network.getNode(3),
                                                       1.0));
      network.addLink(NetworkFactory.createLogicalLink(3, "L_3",
                                                       network.getNode(1),
                                                       network.getNode(4),
                                                       2.0));
      network.addLink(NetworkFactory.createLogicalLink(4, "L_4",
                                                       network.getNode(4),
                                                       network.getNode(3),
                                                       2.0));

      // add a path
      Path path = NetworkManager.shortestPath(network, 1, 3);
      path.setID(1);
      network.addPath(path);
      path = NetworkManager.shortestPath(network, 1, 2);
      path.setID(2);
      network.addPath(path);
      System.out.println("Network before writing to database: ");
      printNetwork(network);
      // save network to database
      NetworkManager.writeNetwork(connection, network);

      // read network back from database
      network = NetworkManager.readNetwork(connection, networkName);
      System.out.println("Network after reading in from database: ");
      printNetwork(network);

      // modify network
      network.deleteNode(3);
      // save back to database again
      System.out.println("Network before writing to database (node 3 deleted!): ");
      printNetwork(network);
      // save network to database
      NetworkManager.writeNetwork(connection, network);

      network = NetworkManager.readNetwork(connection, networkName);
      System.out.println("Network after reading in from database (node 3 deleted!):");
      printNetwork(network);

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
