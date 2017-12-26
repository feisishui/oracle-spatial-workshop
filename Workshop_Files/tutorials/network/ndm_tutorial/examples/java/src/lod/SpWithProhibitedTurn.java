/* $Header: sdo/demo/network/examples/java/src/lod/SpWithProhibitedTurn.java /main/8 2012/12/10 11:18:29 begeorge Exp $ */

/* Copyright (c) 2009, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   DESCRIPTION
    This test class demonstrates how to use the Load-On-Demand (LOD) API to
    conduct shortest path analysis with prohibited turns. Prohibited turn constraints
    consist of link id pairs, where a turn from the start link to the end link
    is not permitted.

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    begeorge    08/06/09 - Creation
 */

/**
 *  @version $Header: sdo/demo/network/examples/java/src/lod/SpWithProhibitedTurn.java /main/8 2012/12/10 11:18:29 begeorge Exp $
 *  @author  begeorge
 *  @since   release specific (what release of product did this appear in)
 */
package lod;

import java.io.InputStream;

import java.sql.Connection;

import java.text.DecimalFormat;
import java.text.NumberFormat;

import java.util.HashMap;
import java.util.Map;

import oracle.spatial.network.UserDataMetadata;
import oracle.spatial.network.lod.DynamicLinkLevelSelector;
import oracle.spatial.network.lod.GeodeticCostFunction;
import oracle.spatial.network.lod.HeuristicCostFunction;
import oracle.spatial.network.lod.LODAnalysisInfo;
import oracle.spatial.network.lod.LODNetworkConstraint;
import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.LinkLevelSelector;
import oracle.spatial.network.lod.NetworkIO;
import oracle.spatial.network.lod.LogicalSubPath;
import oracle.spatial.network.lod.PointOnNet;
import oracle.spatial.network.lod.util.PrintUtility;
import oracle.spatial.util.Logger;
import oracle.spatial.network.lod.LogicalLink;
import oracle.spatial.network.lod.LogicalNetLink;
import oracle.spatial.network.lod.LogicalNetNode;
import oracle.spatial.network.lod.VisitedNode;
import oracle.spatial.network.lod.config.LODConfig;

public class SpWithProhibitedTurn
{
  private static final NumberFormat formatter =
    new DecimalFormat("#.######");

  private static NetworkAnalyst analyst;
  private static NetworkIO networkIO;

  private static void setLogLevel(String logLevel)
  {
    if ("FATAL".equalsIgnoreCase(logLevel))
      Logger.setGlobalLevel(Logger.LEVEL_FATAL);
    else if ("ERROR".equalsIgnoreCase(logLevel))
      Logger.setGlobalLevel(Logger.LEVEL_ERROR);
    else if ("WARN".equalsIgnoreCase(logLevel))
      Logger.setGlobalLevel(Logger.LEVEL_WARN);
    else if ("INFO".equalsIgnoreCase(logLevel))
      Logger.setGlobalLevel(Logger.LEVEL_INFO);
    else if ("DEBUG".equalsIgnoreCase(logLevel))
      Logger.setGlobalLevel(Logger.LEVEL_DEBUG);
    else if ("FINEST".equalsIgnoreCase(logLevel))
      Logger.setGlobalLevel(Logger.LEVEL_FINEST);
    else //default: set to ERROR
      Logger.setGlobalLevel(Logger.LEVEL_ERROR);
  }

  public static void main(String[] args)
    throws Exception
  {
    String configXmlFile = "lod/LODConfigs.xml";
    String logLevel = "ERROR";

    String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser = "";
    String dbPassword = "";

    /*
    To run the test on Hillsborough network
    String networkName = "HILLSBOROUGH_NETWORK";
    long startNodeId     = 2589;
    long endNodeId       = 5579;

    To run test on Navteq_SD network
    String networkName = "NAVTEQ_SD";
    long startNodeId     = 204762893;
    long endNodeId       = 359724269;
    */
    String networkName = "NAVTEQ_SF";
    long startNodeId = 199630493;
    long endNodeId = 199508360;
    int linkLevel = 2;

    double[] costThresholds = {40000};
    int numHighLevelNeighbors = 8;
    double costMultiplier = 1.5;

    int geometryUserDataIndex = -1;
    int xCoordUserDataIndex = 0;
    int yCoordUserDataIndex = 1;

    Connection conn = null;

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
      else if (args[i].equalsIgnoreCase("-linkLevel"))
        linkLevel = Integer.parseInt(args[i + 1]);
      else if (args[i].equalsIgnoreCase("-configXmlFile"))
        configXmlFile = args[i + 1];
      else if (args[i].equalsIgnoreCase("-logLevel"))
        logLevel = args[i + 1];
    }

    // opening connection
    conn = LODNetworkManager.getConnection(dbUrl, dbUser, dbPassword);

    try
    {  
      System.out.println("Network analysis for " + networkName);
  
      setLogLevel(logLevel);
  
      //load user specified LOD configuration (optional),
      //otherwise default configuration will be used
      InputStream config =
        ClassLoader.getSystemResourceAsStream(configXmlFile);
      LODNetworkManager.getConfigManager().loadConfig(config);
      LODConfig c =
        LODNetworkManager.getConfigManager().getConfig(networkName);
  
      //get network input/output object
      networkIO =
          LODNetworkManager.getCachedNetworkIO(conn, networkName, networkName,
                                               null);
  
      //get network analyst
      analyst = LODNetworkManager.getNetworkAnalyst(networkIO);
    
      /////////////////
      // No Constraint
      /////////////////
      //dijkstra shortest path with no prohibited turns
      LogicalSubPath turnRestrictedPath =
        analyst.shortestPathDijkstra(new PointOnNet(startNodeId),
                                     new PointOnNet(endNodeId), null);
      System.out.println("Dijkstra Shortest Path WITHOUT prohibited turns : ");
      if (turnRestrictedPath != null)
      {
        PrintUtility.print(System.out, turnRestrictedPath, true,
                           Integer.MAX_VALUE, 0);
      }

      HeuristicCostFunction ascf =
        new GeodeticCostFunction(UserDataMetadata.DEFAULT_USER_DATA_CATEGORY,
                                 xCoordUserDataIndex, yCoordUserDataIndex,
                                 geometryUserDataIndex);
      LinkLevelSelector lls =
        new DynamicLinkLevelSelector(analyst, linkLevel, ascf,
                                     costThresholds, numHighLevelNeighbors,
                                     costMultiplier, null);

      // astar shortest path with no prohibited turns
      turnRestrictedPath =
          analyst.shortestPathAStar(new PointOnNet(startNodeId),
                                    new PointOnNet(endNodeId), null, ascf,
                                    lls);
      System.out.println("AStar Shortest Path WITHOUT prohibited turns : ");
      if (turnRestrictedPath != null)
      {
        PrintUtility.print(System.out, turnRestrictedPath, true,
                           Integer.MAX_VALUE, 0);
      }

      /////////////////////////
      // Two-Link Constraint
      /////////////////////////
      // construct two-linkprohibited turns constraint
      LODNetworkConstraint turnConstraint =
        new TwoLinkPTurnConstraint();

      // dijkstra shortest path with two-link prohibited turns
      turnRestrictedPath =
          analyst.shortestPathDijkstra(new PointOnNet(startNodeId),
                                       new PointOnNet(endNodeId),
                                       turnConstraint);
      System.out.println("Dijkstra Shortest Path WITH two-link prohibited turns : ");
      if (turnRestrictedPath != null)
      {
        PrintUtility.print(System.out, turnRestrictedPath, true,
                           Integer.MAX_VALUE, 0);
      }
      turnConstraint.reset();

      // astar shortest path with two-link prohibited turns
      lls = new DynamicLinkLevelSelector(analyst, linkLevel, ascf,
                                     costThresholds, numHighLevelNeighbors,
                                     costMultiplier, turnConstraint);

      turnRestrictedPath =
          analyst.shortestPathAStar(new PointOnNet(startNodeId),
                                    new PointOnNet(endNodeId),
                                    turnConstraint, ascf, lls);
      System.out.println("AStar Shortest Path WITH two-link prohibited turns : ");
      if (turnRestrictedPath != null)
      {
        PrintUtility.print(System.out, turnRestrictedPath, true,
                           Integer.MAX_VALUE, 0);
      }
      turnConstraint.reset();

      /////////////////////////
      // Three-Link Constraint
      /////////////////////////
      // construct three-link prohibited turns constraint
      turnConstraint =
        new MultiLinkPTurnConstraint();

      // dijkstra shortest path with three-link prohibited turns
      turnRestrictedPath =
          analyst.shortestPathDijkstra(new PointOnNet(startNodeId),
                                       new PointOnNet(endNodeId),
                                       turnConstraint);
      System.out.println("Dijkstra Shortest Path WITH three-link prohibited turns : ");
      if (turnRestrictedPath != null)
      {
        PrintUtility.print(System.out, turnRestrictedPath, true,
                           Integer.MAX_VALUE, 0);
      }
      turnConstraint.reset();

    }
    catch (Exception e)
    {
      e.printStackTrace();
    }


    if (conn != null)
      try
      {
        conn.close();
      }
      catch (Exception ignore)
      {
      }

  }

  /**
   *  This class shows how to implement prohibited turn constraint, whose 
   *  prohibited turn information consists of two links.
   *  The prohibited turn information can be from database, files or 
   *  constructed in memory.
   */
  private static class TwoLinkPTurnConstraint
    implements LODNetworkConstraint
  {
    // prohibited turns information
    private Map<Long, long[]> pTurnMap = new HashMap<Long, long[]>();

    // Partial expansion information is stored in a map
    // from node id to a boolean array of length equal to the number of
    // this node's outgoing links. For links that have NOT been expanded,
    // the boolean value is set to false,
    private Map<Long, boolean[]> partiallyExpandedNodes =
      new HashMap<Long, boolean[]>();

    // construct prohibited turns information
    public TwoLinkPTurnConstraint()
    {
      /*
        For Hillsborough network
        long [] startLinkIDs = {145477921};
        long [][] prohibitedEndLinkIDs = {{145477920}};
  
        For Navteq_SD network
        long [] startLinkIDs = {203744791,204094746};
        long [][] prohibitedEndLinkIDs = {{203882087},{204156943}};
        */

      // add prohibited turns as start link : prohibited end links
      long[] startLinkIDs = { -198643994 };
      long[][] prohibitedEndLinkIDs = { { -1265835372 } };

      for (int i = 0; i < startLinkIDs.length; i++)
        pTurnMap.put(startLinkIDs[i], prohibitedEndLinkIDs[i]);
    }

    /**
     * Clears the partially expanded node list.
     */
    public void reset()
    {
      partiallyExpandedNodes.clear();
    }

    // check if the given turn (start link ID, end link ID) is allowed

    private boolean isTurnValid(long startLinkID, long endLinkID)
    {
      if (pTurnMap.size()==0) // no prohibited turns
        return true;
      else
      {
        long[] prohibitedEndLinks = pTurnMap.get(startLinkID);
        if (prohibitedEndLinks == null)
          return true;
        else
        {
          for (int i = 0; i < prohibitedEndLinks.length; i++)
          {
            if (prohibitedEndLinks[i] == endLinkID)
              return false; // prohibited turn found
          }
          return true; // OK
        }
      }
    }

    public boolean isSatisfied(LODAnalysisInfo info)
    {
      boolean isTurnValid = false;
      LogicalLink currentLink = info.getCurrentLink();
      LogicalLink nextLink = info.getNextLink();
      if (currentLink == null)
        return true; // start node, current link == null
      else
        //check whether it is a valid turn
        isTurnValid = isTurnValid(currentLink.getId(), nextLink.getId());

      //update partiallyExpandedNodes
      LogicalNetNode currNode = info.getCurrentNode();
      boolean isCurrentLinkInMap =
        pTurnMap.containsKey(currentLink.getId());
      if (!isCurrentLinkInMap) //no pturn involved
        partiallyExpandedNodes.remove(currNode.getId());
      else
      {
        LogicalNetLink[] outLinks = currNode.getOutLinks(true);
        boolean[] isOutLinksExpanded =
          partiallyExpandedNodes.get(currNode.getId());
        if (isOutLinksExpanded == null)
        {
          isOutLinksExpanded = new boolean[currNode.getNumberOfOutLinks()];
          partiallyExpandedNodes.put(currNode.getId(), isOutLinksExpanded);
        }
        boolean isFullyExpanded = true;
        for (int i = 0; i < outLinks.length; i++)
        {
          if (outLinks[i].getId() == nextLink.getId())
          {
            if (isTurnValid)
            {
              isOutLinksExpanded[i] = true;
            }
          }
          isFullyExpanded = isFullyExpanded && isOutLinksExpanded[i];
        }
        if (isFullyExpanded)
          partiallyExpandedNodes.remove(currNode.getId());
      }
      return isTurnValid;
    }

    public int getNumberOfUserObjects()
    {
      return 0;
    }

    public boolean isCurrentNodePartiallyExpanded(LODAnalysisInfo info)
    {
      long currNodeId = info.getCurrentNode().getId();
      return partiallyExpandedNodes.containsKey(currNodeId);
    }

    public boolean isNextNodePartiallyExpanded(LODAnalysisInfo info)
    {
      long nextNodeId = info.getNextNode().getId();
      return partiallyExpandedNodes.containsKey(nextNodeId);
    }

    public int[] getUserDataCategories()
    {
      return null;
    }

    public void setNetworkAnalyst(NetworkAnalyst analyst)
    {
    }
  }
  
  /**
   *  This class shows how to implement prohibited turn constraint, whose 
   *  prohibited turn information consists of two or three links.
   *  The prohibited turn information can be from database, files or 
   *  constructed in memory.
   */
  private static class MultiLinkPTurnUsingUserObjects implements LODNetworkConstraint
  {  
    //Prohibited turns information is stored in a hashmap with end link ID as 
    //the keys and a set up prohibited previous link ID sequence as the values.
    private HashMap<Long, long[]> pTurnMap = new HashMap<Long, long[]>();

    // Partial expansion information is stored in a map
    // from node id to a boolean array of length equal to the number of
    // this node's outgoing links. For links that have NOT been expanded,
    // the boolean value is set to false,
    private Map<Long, boolean[]> partiallyExpandedNodes =
      new HashMap<Long, boolean[]>();
    
    private int maxNumLinksInConstraint;
    
    //Construct prohibited turns information.
    public MultiLinkPTurnUsingUserObjects(int maxNumLinksInConstraint) {
      //Hillsborough network
      //long [][] prohibitedStartLinkIDs = {{145486490,145486491}};
      //long [] endLinkIDs = {145475888};

      //navteq_sf network
      long[][] prohibitedStartLinkIDs = {{ 1266375409, -198643994 }};
      long[] endLinkIDs = { -1265835372 };

      for ( int i = 0; i < endLinkIDs.length ;i++)
        pTurnMap.put(endLinkIDs[i], prohibitedStartLinkIDs[i]);
      
      this.maxNumLinksInConstraint = maxNumLinksInConstraint;
    }

    // check if the given turn (start link IDs, end link ID) is allowed
    private boolean isTurnValid(long[] startLinkIDs, long endLinkID) {
      if ( pTurnMap.size()==0 ) // no prohibited turns
        return true;
      else {
        long [] prohibitedStartLinks =
          pTurnMap.get(endLinkID);
        if ( prohibitedStartLinks == null )
          return true;
        else {
          for ( int i=0; i<prohibitedStartLinks.length; i++) {
            if ( prohibitedStartLinks[prohibitedStartLinks.length-1-i]
                 != startLinkIDs[startLinkIDs.length-1-i])
              return true; // OK
          }
          return false; // prohibited turn found
        }
      }
    }

    public boolean isSatisfied(LODAnalysisInfo info) 
    {
      //This is how the next user object is passed to analysis info.
      info.setNextUserObject(new Long(info.getNextLink().getId()));
      
      Object[] currLinkObjects = info.getCurrentUserObjects();
      if(currLinkObjects==null || currLinkObjects.length==0)
        return true;

      long[] currLinks = new long[currLinkObjects.length];
      for(int i=0; i<currLinkObjects.length; i++)
        if(currLinkObjects[i]!=null)
          currLinks[i] = ((Long)currLinkObjects[i]).longValue();
        else
          currLinks[i] = Long.MIN_VALUE;  //use some invalid link id

      long nextLinkId = info.getNextLink().getId();
      
      boolean isTurnValid = isTurnValid(currLinks, nextLinkId);
      
      //update partiallyExpandedNodes
      LogicalNetNode currNode = info.getCurrentNode();
      
      boolean isNextLinkInMap =
        pTurnMap.containsKey(nextLinkId);
      if (!isNextLinkInMap) //no pturn involved
        partiallyExpandedNodes.remove(currNode.getId());
      else
      {
        LogicalNetLink[] outLinks = currNode.getOutLinks(true);
        boolean[] isOutLinksExpanded =
          partiallyExpandedNodes.get(currNode.getId());
        if (isOutLinksExpanded == null)
        {
          isOutLinksExpanded = new boolean[currNode.getNumberOfOutLinks()];
          partiallyExpandedNodes.put(currNode.getId(), isOutLinksExpanded);
        }
        boolean isFullyExpanded = true;
        for (int i = 0; i < outLinks.length; i++)
        {
          if (outLinks[i].getId() == nextLinkId)
          {
            if (isTurnValid)
            {
              isOutLinksExpanded[i] = true;
            }
          }
          isFullyExpanded = isFullyExpanded && isOutLinksExpanded[i];
        }
        if (isFullyExpanded)
          partiallyExpandedNodes.remove(currNode.getId());
      }
        
      return isTurnValid;
    }

    //For prohibited turns consisting of maxNumLinksInConstraint links, 
    //you need to remember previous maxNumLinksInConstraint-1 links, 
    //thus maxNumLinksInConstraint user objects.
    public int getNumberOfUserObjects()
    {
      return maxNumLinksInConstraint-1;
    }

    public boolean isCurrentNodePartiallyExpanded(LODAnalysisInfo info)
    {
      long currNodeId = info.getCurrentNode().getId();
      return partiallyExpandedNodes.containsKey(currNodeId);
    }

    public boolean isNextNodePartiallyExpanded(LODAnalysisInfo info)
    {
      long nextNodeId = info.getNextNode().getId();
      return partiallyExpandedNodes.containsKey(nextNodeId);
    }

    public int[] getUserDataCategories()
    {
      return null;
    }

    public void reset()
    {
      partiallyExpandedNodes.clear();
    }

    public void setNetworkAnalyst(NetworkAnalyst analyst)
    {
    }
  }

  /**
   *  This class shows how to implement prohibited turn constraint, whose 
   *  prohibited turn information consists of two or more links.
   *  The prohibited turn information can be from database, files or 
   *  constructed in memory.
   */
  private static class MultiLinkPTurnConstraint implements LODNetworkConstraint
  {  
    //Prohibited turns information is stored in a hashmap with end link ID as 
    //the keys and a set up prohibited previous link ID sequence as the values.
    private Map<Long, long[]> pTurnMap = new HashMap<Long, long[]>();

    // Partial expansion information is stored in a map
    // from node id to a boolean array of length equal to the number of
    // this node's outgoing links. For links that have NOT been expanded,
    // the boolean value is set to false,
    private Map<Long, boolean[]> openNodes =
      new HashMap<Long, boolean[]>();
        
    //Construct prohibited turns information.
    public MultiLinkPTurnConstraint() {
      //Hillsborough network
      //long [][] prohibitedStartLinkIDs = {{145486490,145486491}};
      //long [] endLinkIDs = {145475888};

      //navteq_sf network
      long[][] prohibitedStartLinkIDs = {{ 1266375409, -198643994 }};
      long[] endLinkIDs = { -1265835372 };

      for ( int i = 0; i < endLinkIDs.length ;i++)
        pTurnMap.put(endLinkIDs[i], prohibitedStartLinkIDs[i]);
    }

    // check if the given turn (start link IDs, end link ID) is allowed
    private boolean isTurnValid(VisitedNode expandedNode, long endLinkID) 
    {
      if ( pTurnMap.size()==0 ) // no prohibited turns
        return true;
      else 
      {
        long [] prohibitedStartLinks =
          pTurnMap.get(endLinkID);
        if ( prohibitedStartLinks == null )
          return true;
        else 
        {
          VisitedNode currNode = expandedNode;
          for ( int i=0; i<prohibitedStartLinks.length && currNode!=null; i++) 
          {
            long prevLink = currNode.getPrevLink();
            if(prevLink==Long.MIN_VALUE)
              break;
            if ( prohibitedStartLinks[prohibitedStartLinks.length-1-i]
                 != prevLink)
              return true; // OK
            currNode = currNode.getPrevNode();
          }
          return false; // prohibited turn found
        }
      }
    }

    public boolean isSatisfied(LODAnalysisInfo info) 
    {
      //This is how the next user object is passed to analysis info.
      //No longer needed. Use the expanded node in analysis info to trace back 
      //the previous links.
      //info.setNextUserObject(new Long(info.getNextLink().getId()));
      
      //Object[] currLinkObjects = info.getCurrentUserObjects();
      //if(currLinkObjects==null || currLinkObjects.length==0)
      //  return true;

      //long[] currLinks = new long[currLinkObjects.length];
      //for(int i=0; i<currLinkObjects.length; i++)
      //  if(currLinkObjects[i]!=null)
      //    currLinks[i] = ((Long)currLinkObjects[i]).longValue();
      //  else
      //    currLinks[i] = Long.MIN_VALUE;  //use some invalid link id

      long nextLinkId = info.getNextLink().getId();
      
      boolean isTurnValid = isTurnValid(info.getExpandedNode(), nextLinkId);
      
      //update partiallyExpandedNodes
      LogicalNetNode currNode = info.getCurrentNode();
      
      boolean isNextLinkInMap =
        pTurnMap.containsKey(nextLinkId);
      if (!isNextLinkInMap) //no pturn involved
        openNodes.remove(currNode.getId());
      else
      {
        LogicalNetLink[] outLinks = currNode.getOutLinks(true);
        boolean[] isOutLinksExpanded =
          openNodes.get(currNode.getId());
        if (isOutLinksExpanded == null)
        {
          isOutLinksExpanded = new boolean[currNode.getNumberOfOutLinks()];
          openNodes.put(currNode.getId(), isOutLinksExpanded);
        }
        boolean isFullyExpanded = true;
        for (int i = 0; i < outLinks.length; i++)
        {
          if (outLinks[i].getId() == nextLinkId)
          {
            if (isTurnValid)
            {
              isOutLinksExpanded[i] = true;
            }
          }
          isFullyExpanded = isFullyExpanded && isOutLinksExpanded[i];
        }
        if (isFullyExpanded)
          openNodes.remove(currNode.getId());
      }
        
      return isTurnValid;
    }

    //For prohibited turns consisting of maxNumLinksInConstraint links, 
    //you need to remember previous maxNumLinksInConstraint-1 links, 
    //thus maxNumLinksInConstraint user objects.
    public int getNumberOfUserObjects()
    {
      return 0;
    }

    public boolean isCurrentNodePartiallyExpanded(LODAnalysisInfo info)
    {
      long currNodeId = info.getCurrentNode().getId();
      return openNodes.containsKey(currNodeId);
    }

    public int[] getUserDataCategories()
    {
      return null;
    }

    public void reset()
    {
      openNodes.clear();
    }

    public void setNetworkAnalyst(NetworkAnalyst analyst)
    {
    }
  }                        
}
