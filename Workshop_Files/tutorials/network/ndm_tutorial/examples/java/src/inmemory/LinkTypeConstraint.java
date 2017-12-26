/**
 * This class shows how a user constraint can be implemented
 * to guide the search for Oracle Network Network Data Model
 * The user constraint needs to implement the NetworkConstraint interface
 * which has two methods: requiresPathLinks and isSatisfied
 * The following example shows how link type can be used as a constraint
 * This constraint can be passed into any analysis functions
 * so that the results contain links with specific type
 * Example:
 * Network network = readNetwork(...) ;// read in a network
 * NetworkConstraint constraint = new LinkTypeConstraint("TYPE:A"); // create link type constraint
 * // search the shortest path that only contains links with specific type
 * Path path = NetworkManager.shortestPath(network,startNodeID,endNodeID,constraint);
 *
 */

package inmemory;

import java.util.*;

import oracle.jdbc.OracleConnection;

import oracle.jdbc.pool.OracleDataSource;

import oracle.spatial.network.*;

/**
 * This class shows how a user constraint can be implemented
 * to guide the search for Oracle Network Network Data Model
 * The user constraint needs to implement the NetworkConstraint interface
 * which has two methods: requiresPathLinks and isSatisfied
 * The following example shows how link type can be used as a constraint
 * This constraint can be passed into any analysis functions
 * so that the results contain links with specific type
 * Example:
 * Network network = readNetwork(...) ;// read in a network
 * NetworkConstraint constraint = new LinkTypeConstraint("TYPE:A"); // create link type constraint
 * // search the shortest path that only contains links with specific type
 * Path path = NetworkManager.shortestPath(network,startNodeID,endNodeID,constraint);
 *
 */
public class


LinkTypeConstraint
  implements NetworkConstraint
{
  String p_type; // specific link type

  public LinkTypeConstraint(String type)
  {
    p_type = type;
  }

  public boolean requiresPathLinks()
  {
    return false;
  } // path link info. not needed

  public boolean isSatisfied(AnalysisInfo info)
  {
    Link link = info.getNextLink();
    // only search links with specific type
    if (link != null && link.getType().equalsIgnoreCase(p_type))
      return true;
    else
      return false;
  }
  // test program

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
      Network network = NetworkManager.readNetwork(connection, "BI_TEST");

      // Close the database connection
      connection.close();


      // boundary nodes
      int[] boundaryNodes =
      { 1, 9, 4, 10, 3, 11, 5, 6, 2, 8, 7, 18, 29, 40, 51, 62, 73, 84, 95,
        106, 117, 118, 112, 116, 115, 121, 113, 120, 114, 119, 111, 100,
        89, 78, 67, 56, 45, 34, 23, 12 };

      Set boundaryNodeSet = new HashSet();
      for (int i = 0; i < boundaryNodes.length; i++)
        boundaryNodeSet.add(new Integer(boundaryNodes[i]));

      int startNodeID = 1;
      int endNodeID = 117;

      // shortest path without link type constraint
      Path path =
        NetworkManager.shortestPath(network, startNodeID, endNodeID);
      if (path != null)
        System.out.println("Shortest Path (Node[1](Link[1])Node[2]...(Link[n-1])N[n]) WITHOUT link type constraint: " +
                           path);

      // set the link type:
      // if the start node and end node are both boundary nodes
      // the link is a "Boundary" link, otherwise, an "Internal" link

      for (Iterator it = network.getLinks(); it.hasNext(); )
      {
        Link link = (Link) (it.next());
        int startNID = link.getStartNode().getID();
        int endNID = link.getEndNode().getID();
        if (boundaryNodeSet.contains(new Integer(startNID)) &&
            boundaryNodeSet.contains(new Integer(endNID)))
          link.setType("Boundary");
        else
          link.setType("Internal");
      }

      // construct link type constraint
      LinkTypeConstraint linkTypeConstraint =
        new LinkTypeConstraint("Boundary");
      // shortest path with prohibited turns
      path =
          NetworkManager.shortestPath(network, startNodeID, endNodeID, linkTypeConstraint);

      if (path != null)
      {
        // print out the boundary link IDs
        System.out.println("\nBoundary Links:");
        int count = 1;
        for (Iterator it = network.getLinks(); it.hasNext(); )
        {
          Link link = (Link) (it.next());
          if (!link.getType().equalsIgnoreCase("Boundary"))
            continue;
          count++;
          System.out.print(link.getID() + " ");
          if (count % 10 == 1)
            System.out.print("\n");
        }
        System.out.println("\nShortest Path  (Node[1](Link[1])Node[2]...(Link[n-1])N[n]) WITH links of type Boundary :" +
                           path);
      }

    }
    catch (Exception e)
    {
      System.err.println(e.getMessage());
      e.printStackTrace();
    }
  }
}
