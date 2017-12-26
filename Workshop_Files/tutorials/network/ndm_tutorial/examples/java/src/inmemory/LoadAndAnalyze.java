/*
 * LoadAndAnalyze.java
 *
 * Vishal Rao
 * Oracle Corporation
 * 15 May 2003
 *
 * This program shows how to use Oracle Network Data Model's Java API.
 * Specifically, it shows how to load a network from the database and
 * run some analytics on it.
 *
 */

package inmemory;

import oracle.jdbc.OracleConnection;

import oracle.jdbc.pool.OracleDataSource;

import oracle.spatial.network.*;


public class LoadAndAnalyze
{

  /**********************************************************************/
  private static void runAccessibilityAnalysis(Network network, int nodeID)
  {
    try
    {
      Node[] nodeArray = null;

      System.out.println("*********************************************");
      nodeArray = NetworkManager.findReachingNodes(network, nodeID);
      System.out.println("All the nodes in network " +
                         network.getMetadata().getName() + "\n" +
                         " that can reach node " + nodeID + ": ");
      for (int i = 0; i < nodeArray.length; i++)
        System.out.println("\t" + "Node[" + nodeArray[i].getID() + "]");
      System.out.println("*********************************************");
      System.out.println("*********************************************");
      nodeArray = NetworkManager.findReachableNodes(network, nodeID);
      System.out.println("All the nodes in network " +
                         network.getMetadata().getName() + "\n" +
                         " that are reachable from node " + nodeID + ": ");
      for (int i = 0; i < nodeArray.length; i++)
        System.out.println("\t" + "Node[" + nodeArray[i].getID() + "]");
      System.out.println("*********************************************");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }

  /**********************************************************************/
  private static void runBoundedAccessibilityAnalysis(Network network,
                                                      int nodeID,
                                                      MBR boundRect)
  {
    try
    {
      Node[] nodeArray = null;

      System.out.println("*********************************************");
      nodeArray =
          NetworkManager.findReachingNodes(network, nodeID, boundRect);
      System.out.println("All the nodes in network " +
                         network.getMetadata().getName() +
                         " within bounding rectangle " + boundRect + "\n" +
                         " that can reach node " + nodeID + ": ");
      for (int i = 0; i < nodeArray.length; i++)
        System.out.println("\t" + "Node[" + nodeArray[i].getID() + "]");
      System.out.println("*********************************************");
      System.out.println("*********************************************");
      nodeArray =
          NetworkManager.findReachableNodes(network, nodeID, boundRect);
      System.out.println("All the nodes in network " +
                         network.getMetadata().getName() +
                         " within bounding rectangle " + boundRect + "\n" +
                         " that are reachable from node " + nodeID + ": ");
      for (int i = 0; i < nodeArray.length; i++)
        System.out.println("\t" + "Node[" + nodeArray[i].getID() + "]");
      System.out.println("*********************************************");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }

  /**********************************************************************/
  private static void runAllShortestPathsAnalysis(Network network,
                                                  int sourceNodeID)
  {
    try
    {
      Path[] pathArray =
        NetworkManager.shortestPaths(network, sourceNodeID);
      System.out.println("*********************************************");
      for (int i = 0; i < pathArray.length; i++)
      {
        Path p = pathArray[i];
        int endNodeID = p.getEndNode().getID();
        double cost = p.getCost();
        System.out.println("Shortest path cost from node " + sourceNodeID +
                           " to node " + endNodeID + " in network " +
                           network.getMetadata().getName() + ": " + cost);
      }
      System.out.println("*********************************************");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }

  /**********************************************************************/
  private static void runSingleShortestPathAnalysis(Network network,
                                                    int startNodeID,
                                                    int endNodeID)
  {
    try
    {
      Path path = null;
      Link[] linkArray = null;
      System.out.println("*********************************************");
      path =
          NetworkManager.shortestPathDijkstra(network, startNodeID, endNodeID);
      System.out.println("Shortest path cost from node " + startNodeID +
                         " to node " + endNodeID + " in network " +
                         network.getName() + "\n" +
                         " using Dijkstra's Algorithm: " + path.getCost());
      linkArray = path.getLinkArray();
      System.out.println("Here are the links along the path: ");
      for (int i = 0; i < linkArray.length; i++)
      {
        System.out.println("\t" + linkArray[i].getID());
      }
      System.out.println("*********************************************");
      path =
          NetworkManager.shortestPathAStar(network, startNodeID, endNodeID);
      System.out.println("Shortest path cost from node " + startNodeID +
                         " to node " + endNodeID + " in network " +
                         network.getName() + "\n" + " using A*Search: " +
                         path.getCost());
      linkArray = path.getLinkArray();
      System.out.println("Here are the links along the path: ");
      for (int i = 0; i < linkArray.length; i++)
      {
        System.out.println("\t" + linkArray[i].getID());
      }
      System.out.println("*********************************************");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }

  /**********************************************************************/
  private static void runMinimumCostSpanningTreeAnalysis(Network network)
  {
    Link[] linkArray = null;
    System.out.println("*********************************************");
    linkArray = NetworkManager.mcstLinkArray(network);
    System.out.println("Here are all the links that are part of the\n" +
                       " minimum cost spanning tree  of network " +
                       network.getName() + ": ");
    for (int i = 0; i < linkArray.length; i++)
    {
      System.out.println("\t" + linkArray[i].getID());
    }
    System.out.println("*********************************************");
  }

  /**********************************************************************/
  private static void runNearestNeighborsAnalysis(Network network,
                                                  int node_id,
                                                  int numOfNeighbors)
  {
    try
    {
      Path[] pathArray = null;
      System.out.println("*********************************************");
      pathArray =
          NetworkManager.nearestNeighbors(network, node_id, numOfNeighbors);
      System.out.println("Node " + node_id + "'s " + numOfNeighbors +
                         " nearest neighbors \n" + " in Network " +
                         network.getName() + ": ");
      for (int i = 0; i < pathArray.length; i++)
      {
        Path path = pathArray[i];
        System.out.println("\tNode " + path.getEndNode().getID() +
                           ", path cost " + path.getCost());
      }
      System.out.println("*********************************************");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }

  /**********************************************************************/
  private static void runWithinCostAnalysis(Network network, int node_id,
                                            double distanceBound)
  {
    try
    {
      Path[] pathArray = null;
      System.out.println("*********************************************");
      pathArray =
          NetworkManager.withinCost(network, node_id, distanceBound);
      System.out.println("Node " + node_id + "'s neighbors \n" +
                         " in Network " + network.getName() +
                         " that are within distance " + distanceBound +
                         ": ");
      for (int i = 0; i < pathArray.length; i++)
      {
        Path path = pathArray[i];
        System.out.println("\tNode " + path.getEndNode().getID() +
                           ", path cost " + path.getCost());
      }
      System.out.println("*********************************************");
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }

  /**********************************************************************/
  public static

  void main(String[] args)
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
      OracleConnection con = null;
      OracleDataSource ds = new OracleDataSource();
      ds.setURL(dbUrl);
      ds.setUser(dbUser);
      ds.setPassword(dbPassword);
      con = (OracleConnection) ds.getConnection();
      con.setAutoCommit(false);


      // Load networks from database
      Network undirectedNet =
        NetworkManager.readNetwork(con, "UN_TEST");
      Network directedNet =
        NetworkManager.readNetwork(con, "BI_TEST");

      // Close the database connection
      con.close();

      // Accessibility analysis
      int node_id = 66;
      double[] min =
      { 2, 2 };
      double[] max =
      { 6, 6 };
      MBR mbr = NetworkFactory.createMBR(min, max);
      runAccessibilityAnalysis(undirectedNet, node_id);
      runBoundedAccessibilityAnalysis(undirectedNet, node_id, mbr);
      runAccessibilityAnalysis(directedNet, node_id);
      runBoundedAccessibilityAnalysis(directedNet, node_id, mbr);

      // Shortest paths analysis
      runAllShortestPathsAnalysis(undirectedNet, 1);
      runAllShortestPathsAnalysis(directedNet, 1);
      runSingleShortestPathAnalysis(undirectedNet, 1, 117);
      runSingleShortestPathAnalysis(directedNet, 1, 117);

      // Minimum Cost Spanning Tree Analysis
      runMinimumCostSpanningTreeAnalysis(undirectedNet);

      // Nearest neighbor analysis
      runNearestNeighborsAnalysis(undirectedNet, 66, 10);
      runNearestNeighborsAnalysis(directedNet, 66, 10);

      // Within Distance Analysis
      runWithinCostAnalysis(undirectedNet, 66, 3.0);
      runWithinCostAnalysis(directedNet, 66, 3.0);

    }
    catch (Exception e)
    {
      System.err.println(e.getMessage());
      e.printStackTrace();
    }
  }
}
