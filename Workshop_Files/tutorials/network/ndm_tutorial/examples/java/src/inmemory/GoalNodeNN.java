package inmemory;

import oracle.jdbc.OracleConnection;
import oracle.jdbc.pool.OracleDataSource;

import oracle.spatial.network.GoalNode;
import oracle.spatial.network.Network;
import oracle.spatial.network.NetworkManager;
import oracle.spatial.network.Node;
import oracle.spatial.network.OraTst;
import oracle.spatial.network.Path;

/**
 * This java class demonstrates how to implement a GoalNode constraint for
 * NearestNeighbors Analsysis to return the specific number of nearest neighbors
 * that satisfy the user defined GaolNode constraint.
 * In this example, nodes that are of even node ID are considered as
 * candidate goal nodes.
 *
 */
class GoalNodeNN implements GoalNode {

  // only consider nodes with even node ID as goal nodes
  public boolean isGoal(Node node) {  
    if ( node.getID()%2 == 0 )
      return true;
    else
      return false;
  }

  public static void main(String [] args) 
  { 
    //Get input parameters
    String dbUrl    = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser     = "";
    String dbPassword = "";
    
    String networkName = "HILLSBOROUGH_NETWORK";
    int targetNodeId   = 4615;
    int numNeighbors   = 10;

    for(int i=0; i<args.length; i++)
    {
      if(args[i].equalsIgnoreCase("-dbUrl"))
        dbUrl = args[i+1];
      else if(args[i].equalsIgnoreCase("-dbUser"))
        dbUser = args[i+1];
      else if(args[i].equalsIgnoreCase("-dbPassword"))
        dbPassword = args[i+1];
      if(args[i].equalsIgnoreCase("-networkName") && args[i+1]!=null)
        networkName = args[i+1].toUpperCase();
      else if(args[i].equalsIgnoreCase("-targetNodeId"))
        targetNodeId = Integer.parseInt(args[i+1]);
      else if(args[i].equalsIgnoreCase("-numNeighbors"))
        numNeighbors = Integer.parseInt(args[i+1]);
    }

    try 
    {
      // get jdbc connection
      OracleConnection con = null;
      OracleDataSource ds = new OracleDataSource();
      ds.setURL(dbUrl);
      ds.setUser(dbUser);
      ds.setPassword(dbPassword);
      con = (OracleConnection)ds.getConnection();    
      con.setAutoCommit(false);

      // read in network
      Network network = NetworkManager.readNetwork(con,networkName);
      
      Path [] pathArray= null;
      GoalNodeNN goalFilter = new GoalNodeNN(); // goal nodes that have even node IDs

      pathArray = NetworkManager.nearestNeighbors(network,targetNodeId,
                                                  numNeighbors);

      OraTst.print("\n" + network.getMetadata().getName() 
                        + " Nearest Neighbors(" + numNeighbors 
                        + ") for Node[" + targetNodeId + "]: (NO Goal filter)\n");
      OraTst.print(pathArray);


      pathArray = NetworkManager.nearestNeighbors(network,targetNodeId,
                                                  numNeighbors,null,goalFilter);

      OraTst.print("\n" + network.getMetadata().getName() 
                        + " Nearest Neighbors(" + numNeighbors
                        + ") for Node[" + targetNodeId + "]:(Even Goal Node ID filter)\n");
      OraTst.print(pathArray);

      //close connection
      con.close();
    } catch ( Exception e) {
      e.printStackTrace();
    }

  }    
}
