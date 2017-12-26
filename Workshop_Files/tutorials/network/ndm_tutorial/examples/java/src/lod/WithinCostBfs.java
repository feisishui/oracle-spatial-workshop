/* $Header: sdo/demo/network/examples/java/src/lod/WithinCostBfs.java /main/4 2012/12/10 11:18:29 begeorge Exp $ */

/* Copyright (c) 2011, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   DESCRIPTION
    <short description of component this file declares/defines>

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    jcwang      01/19/11 - Creation
 */

/**
 *  @version $Header: sdo/demo/network/examples/java/src/lod/WithinCostBfs.java /main/4 2012/12/10 11:18:29 begeorge Exp $
 *  @author  jcwang
 *  @since   release specific (what release of product did this appear in)
 */

package lod;

import java.io.InputStream;

import java.sql.Connection;

import java.text.DecimalFormat;
import java.text.NumberFormat;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.ListIterator;

import oracle.spatial.network.lod.CachedNetworkIO;
import oracle.spatial.network.lod.LODNetworkException;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.util.Logger;
import oracle.spatial.network.lod.LogicalNetLink;
import oracle.spatial.network.lod.LogicalNetNode;
import oracle.spatial.network.lod.NetworkExplorer;
import oracle.spatial.network.lod.config.LODConfig;

/**
 * This class shows how to construct a Bread-First Search (BFS) using Oracle NDM
 */
public class WithinCostBfs {
  private static final NumberFormat formatter = new DecimalFormat("#.######");

  NetworkExplorer ne; // network explorer
  int linkLevel; //wchih network link level to be searched

  private static void setLogLevel(String logLevel) {
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


  /**
   * Returns the BFS search tree. The maximun number of levels (noofLevels) is the primary search constraint
   * and the maximum cost(maxCost) is the second search constraint.
   * @param startNodeID start Node ID for BFS
   * @param linkLevel link level the search to be conducted
   * @param noOfLevels no of levels(hops) of the BFS
   * @param maxCost maximun cost allowed in the BFS
   * @param searchForward search forward or backward
   * @return BFS search tree
   * @throws LODNetworkException
   */
  public BfsTree findBfsPaths(long startNodeID, int linkLevel, int noOfLevels,
                              double maxCost,
                              boolean searchForward) throws LODNetworkException {
    ArrayList<ArrayList<BfsNode>> list = new ArrayList<ArrayList<BfsNode>>();
    BfsNode startBfsNode =
      new BfsNode(startNodeID, -1, startNodeID, 0, 0, null);
    LogicalNetNode startNode =
      ne.getNetNode(startNodeID, linkLevel, null, null);
    ArrayList<BfsNode> nList = new ArrayList<BfsNode>();
    nList.add(startBfsNode); // add the 0 level arraylist which is the start node itself
    list.add(0, nList);
    int numNodes = 1;
    for (int searchLevel = 1; searchLevel <= noOfLevels; searchLevel++) {
      ArrayList<BfsNode> levelList = new ArrayList<BfsNode>();
      ArrayList<BfsNode> prevLevelList = list.get(searchLevel - 1);

      for (Iterator<BfsNode> it = prevLevelList.iterator(); it.hasNext(); ) {
        BfsNode prevNode = it.next();

        LogicalNetNode levelStartNode =
          ne.getNetNode(prevNode.getNodeID(), linkLevel, null, null);
        LogicalNetLink[] childLinks;
        LogicalNetLink childLink;

        long childNodeID;
        long prevNodeID = prevNode.getNodeID();
        int level = prevNode.getLevel() + 1;
        double cost = prevNode.getCost();

        if (searchForward)
          childLinks = levelStartNode.getOutLinks(true);
        else
          childLinks = levelStartNode.getInLinks(true);

        if (childLinks != null) {
          for (int i = 0; i < childLinks.length; i++) {
            childLink = childLinks[i];

            if (childLink.getStartNodeId() == prevNodeID)
              childNodeID = childLink.getEndNodeId();
            else
              childNodeID = childLink.getStartNodeId();

            if (prevNode.pathContainsNode(childNodeID)) // a cycle
              continue;

            cost = prevNode.getCost() + childLink.getCost();
            if (cost > maxCost)
              continue;
            BfsNode n =
              new BfsNode(prevNodeID, childLink.getId(), childNodeID, cost,
                          level, prevNode);
            numNodes++;

            levelList.add(n);
          }
        }

      }
      list.add(searchLevel, levelList);
    }
    return new BfsTree(list, searchForward);
  }

  public WithinCostBfs(NetworkExplorer ne, int linkLevel) {
    this.ne = ne;
    this.linkLevel = linkLevel;
  }

  public static void main(String[] args) throws Exception {
    String configXmlFile = "lod/LODConfigs.xml";
    String logLevel = "ERROR";
    String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser = "";
    String dbPassword = "";

    String networkName = "NAVTEQ_SF";
    long startNodeID = 199355550;

    int linkLevel = 1; // default link level
    Connection conn = null;

    //get input parameters
    for (int i = 0; i < args.length; i++) {
      if (args[i].equalsIgnoreCase("-dbUrl"))
        dbUrl = args[i + 1];
      else if (args[i].equalsIgnoreCase("-dbUser"))
        dbUser = args[i + 1];
      else if (args[i].equalsIgnoreCase("-dbPassword"))
        dbPassword = args[i + 1];
      else if (args[i].equalsIgnoreCase("-networkName") && args[i + 1] != null)
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

    System.out.println("Network analysis for " + networkName);

    setLogLevel(logLevel);

    //load user specified LOD configuration (optional),
    //otherwise default configuration will be used
    InputStream config = ClassLoader.getSystemResourceAsStream(configXmlFile);
    LODNetworkManager.getConfigManager().loadConfig(config);
    LODConfig c = LODNetworkManager.getConfigManager().getConfig(networkName);

    //get network reader
    CachedNetworkIO reader =
      LODNetworkManager.getCachedNetworkIO(conn, networkName, networkName,
                                           null);
    //get network explorer
    NetworkExplorer ne = new NetworkExplorer(reader);

    WithinCostBfs wcBfs = new WithinCostBfs(ne, linkLevel);


    int noOfLevels = 10; // max hops to search
    double maxCost = 1000000; // a large cost
    boolean searchForward = true;
    try {
      // BFS search
      BfsTree tree =
        wcBfs.findBfsPaths(startNodeID, linkLevel, noOfLevels, maxCost,
                           searchForward);

      if (tree != null) {
        System.out.println("\nBfsTree with startNode: " + startNodeID +
                           " contains total " + tree.getNumberOfLevels() +
                           " levels and total " + tree.getNumberOfNodes() +
                           " nodes with search dir.:" +
                           (tree.isSearchForward() ? " forward " :
                            " backword "));
        for (int level = 0; level <= tree.getNumberOfLevels(); level++) {
          System.out.println("\nLevel:" + level + " contains " +
                             tree.getNumberOfNodes(level) + " nodes...");

          // print out BFS nodes/paths at the maximun level
          if (level == noOfLevels) {
            ArrayList<BfsNode> list = tree.getNodes(level);
            for (Iterator<BfsNode> it = list.iterator(); it.hasNext(); ) {
              BfsNode bn = it.next(); // BFS nodes at specific level
              System.out.println(bn.toBfsPath(searchForward));
            }
            System.out.println("\n");
          }

        }
        // seacrh for specific node in the BFS tree
        // i.e. find all paths between start node and target node up to max. no of levels
        long targetNodeID = 199933649;
        ArrayList<BfsNode> list = tree.getNodes(targetNodeID);
        System.out.println("\n" +
            list.size() + " BFS Paths with targetNodeID:" + targetNodeID +
            "\n");
        for (Iterator<BfsNode> it = list.iterator(); it.hasNext(); ) {
          System.out.println(it.next().toBfsPath(searchForward));
        }
        System.out.println("\n");


        // print out BFS cycle paths at the maximun level
        int maxNoOfLinks = 6;
        int minNoOfLinks = 3;
        System.out.println("\n" +
            " BFS Cycles at level = " + noOfLevels +
            " with noOfLinks between " + minNoOfLinks + " and " +
            maxNoOfLinks + "\n");
        ArrayList<BfsNode> nList = tree.getNodes(noOfLevels);

        for (BfsNode bn : nList) {
          ArrayList<BfsPath> cList =
            bn.toBfsCycles(ne, minNoOfLinks, maxNoOfLinks);
          Collections.sort(cList);
          for (BfsPath cycle : cList) {
            System.out.println(cycle);
          }
          if (cList.size() > 0)
            System.out.println("\n");
        }
        System.out.println("\n");


      }


    } catch (Exception e) {
      e.printStackTrace();
    }


    if (conn != null)
      try {
        conn.close();
      } catch (Exception ignore) {
      }

  }

  /**
   * This class defines a BFS node in BFS
   */
  public class BfsNode implements Comparable {
    private long nodeID;
    private long prevLinkID;
    private long prevNodeID;
    private double cost;
    private int level;
    private BfsNode prevBfsNode;

    BfsNode(long prevNodeID, long prevLinkID, long nodeID, double cost,
            int level, BfsNode prevBfsNode) {
      this.nodeID = nodeID;
      this.prevLinkID = prevLinkID;
      this.prevNodeID = prevNodeID;
      this.cost = cost;
      this.level = level;
      this.prevBfsNode = prevBfsNode;
    }

    public long getNodeID() {
      return nodeID;
    }

    public long getPrevLinkID() {

      return prevLinkID;
    }

    public long getPrevNodeID() {
      return prevNodeID;
    }

    public double getCost() {
      return cost;
    }

    public int getLevel() {
      return level;
    }

    public BfsNode getPrevBfsNode() {
      return prevBfsNode;
    }

    public boolean isStarBfstNode() {
      return (nodeID == prevNodeID);
    }

    public boolean pathContainsNode(long nID) {
      if (nID == nodeID)
        return true;
      BfsNode n = prevBfsNode;
      while (n != null) {
        if (n.getNodeID() == nID)
          return true;
        n = n.getPrevBfsNode();
      }
      return false;
    }

    /**
     * Creates a BFS path from a BFS node
     * @param searchForward
     * @return BFS Path
     */
    public BfsPath toBfsPath(boolean searchForward) {
      ArrayList<BfsNode> list = new ArrayList<BfsNode>();
      BfsNode node = this;
      //list.add(node);
      double cost = node.getCost();
      int level = node.getLevel();
      while (node != null) {
        list.add(0, node);
        node = node.getPrevBfsNode();
      }

      long[] nids = new long[list.size()];
      long[] lids = new long[list.size() - 1];
      int count = 0;
      for (ListIterator<BfsNode> it = list.listIterator(); it.hasNext(); ) {
        BfsNode n = it.next();
        nids[count] = n.getNodeID();
        if (count >= 1)
          lids[count - 1] = n.getPrevLinkID();

        count++;
      }

      if (!searchForward) { // needs to reverse the arrays
        long temp;
        for (int start = 0, end = nids.length - 1; start < end;
             start++, end--) {
          //swap numbers
          temp = nids[start];
          nids[start] = nids[end];
          nids[end] = temp;
        }
        for (int start = 0, end = lids.length - 1; start < end;
             start++, end--) {
          //swap numbers
          temp = lids[start];
          lids[start] = lids[end];
          lids[end] = temp;
        }
      }

      return new BfsPath(nids, lids, cost, level);

    }
    // check if the path contains a cycle adding a node at the end
    // a cycle can be a part of the BFS path (no need to include start node or all nodes

    public boolean containsCycle(NetworkExplorer ne,
                                 long nodeID) throws Exception {

      if (this.pathContainsNode(nodeID))
        return true;
      else
        return false;
    }

    public ArrayList<BfsPath> toBfsCycles(NetworkExplorer ne, int minNoOfLinks,
                                          int maxNoOfLinks) throws Exception {

      int linkLevel = 1;
      ArrayList<BfsPath> aList = new ArrayList<BfsPath>();
      if (maxNoOfLinks < minNoOfLinks) //error handling
        return aList;
      LogicalNetNode levelStartNode =
        ne.getNetNode(this.nodeID, linkLevel, null, null);
      LogicalNetLink[] childLinks;
      LogicalNetLink childLink;
      long childNodeID;
      HashSet<String> cSet = new HashSet<String>();
      childLinks = levelStartNode.getOutLinks(true);
      if (childLinks != null) {
        for (int i = 0; i < childLinks.length; i++) {
          childLink = childLinks[i];
          if (childLink.getStartNodeId() == nodeID)
            childNodeID = childLink.getEndNodeId();
          else
            childNodeID = childLink.getStartNodeId();

          // from each BFSnode->Bfspoath->BfsCycle
          if (this.containsCycle(ne, childNodeID)) { // a cycle
            BfsPath path = this.toBfsPath(true);
            BfsPath cycle = path.toCycle(ne, childNodeID, childLink.getId());

            // add cycle to the list if it contains links equal or more than minNoOfLinks
            if (cycle.getLinkIDs().length >= minNoOfLinks &&
                cycle.getLinkIDs().length <= maxNoOfLinks)
              aList.add(cycle);

          }
        }
      }


      return aList;

    }

    public String toString() {
      StringBuffer buffer = new StringBuffer();
      buffer.append(" (NodeID:" + nodeID + " PrevNodeID:" + prevNodeID +
                    " PrevLinkID:" + prevLinkID + " Level: " + level +
                    " Cost: " + cost + ")");
      return buffer.toString();
    }

    /**
     *Sorts BFS nodes based on level and cost
     */
    public int compareTo(Object o) {
      BfsNode n = (BfsNode)o;
      if (nodeID > n.getNodeID())
        return 1;
      else if (nodeID < n.getNodeID())
        return -1;
      else {

        if (cost > n.getCost())
          return 1;
        else if (cost < n.getCost())
          return -1;
        else
          return 0;
      }
    }

  }

  /**
   * This class defines a path in BFS
   */
  public class BfsPath implements Comparable {
    private long[] nodeIDs;
    private long[] linkIDs;
    double cost;
    int level;

    public BfsPath(long[] nodeIDs, long[] linkIDs, double cost, int level) {
      this.nodeIDs = new long[nodeIDs.length];
      System.arraycopy(nodeIDs, 0, this.nodeIDs, 0, nodeIDs.length);
      this.linkIDs = new long[linkIDs.length];
      System.arraycopy(linkIDs, 0, this.linkIDs, 0, linkIDs.length);
      this.cost = cost;
      this.level = level;
    }

    public BfsPath(BfsNode endBfsNode, boolean searchForward) {
      ArrayList<BfsNode> list = new ArrayList<BfsNode>();
      list.add(endBfsNode);
      BfsNode node = endBfsNode;
      double cost = node.getCost();
      int level = node.getLevel();
      while (!node.isStarBfstNode()) {
        list.add(0, node);
        node = node.getPrevBfsNode();
      }
      long[] nids = new long[list.size()];
      long[] lids = new long[list.size() - 1];
      int count = 0;
      for (ListIterator<BfsNode> it = list.listIterator(); it.hasNext(); ) {
        BfsNode n = it.next();
        nids[count] = n.getNodeID();
        if (count >= 1)
          lids[count - 1] = n.getPrevLinkID();
        count++;
      }
      if (!searchForward) { // needs to reverse the arrays
        long temp;
        for (int start = 0, end = nids.length - 1; start < end;
             start++, end--) {
          //swap numbers
          temp = nids[start];
          nids[start] = nids[end];
          nids[end] = temp;
        }
        for (int start = 0, end = lids.length - 1; start < end;
             start++, end--) {
          //swap numbers
          temp = lids[start];
          lids[start] = lids[end];
          lids[end] = temp;
        }

      }

      this.nodeIDs = new long[nids.length];
      System.arraycopy(nids, 0, this.nodeIDs, 0, nids.length);
      this.linkIDs = new long[lids.length];
      System.arraycopy(lids, 0, this.linkIDs, 0, lids.length);
      this.cost = cost;
      this.level = level;

    }

    public long getNode(int index) {
      return nodeIDs[index];
    }

    public long getLink(int index) {
      return linkIDs[index];
    }

    public double getCost() {
      return cost;
    }

    public int getLevel() {
      return level;
    }

    public long[] getNodeIDs() {
      return nodeIDs;
    }

    public long[] getLinkIDs() {
      return linkIDs;
    }

    //adding a node and  a link will form a cycle somewhere along the path

    public boolean containsCycle(long newNodeID) {
      if (nodeIDs != null)
        for (long id : nodeIDs)
          if (id == newNodeID)
            return true;
      return false;
    }
    // if adding a node and a link makes a cycle, return the cycle as a path

    public BfsPath toCycle(NetworkExplorer ne, long newNodeID,
                           long newLinkID) throws Exception {

      int start = -1;
      int linkLevel = 1;
      if (nodeIDs != null) {
        for (int i = 0; i < nodeIDs.length; i++)
          if (nodeIDs[i] == newNodeID) {
            start = i;
            break;
          }
      }

      if (start != -1) {
        int nodeNo = nodeIDs.length - start;
        long[] nodeArray = new long[nodeNo + 1];
        long[] linkArray = new long[nodeNo];
        int pLevel = this.level++;

        System.arraycopy(this.nodeIDs, start, nodeArray, 0, nodeNo);
        nodeArray[nodeNo] = newNodeID;
        System.arraycopy(this.linkIDs, start, linkArray, 0, nodeNo - 1);
        linkArray[nodeNo - 1] = newLinkID;
        double pCost = 0;
        int[] pid = new int[nodeNo];
        for (int i = 0; i < linkArray.length; i++) {
          long nodeId = nodeArray[i];
          pid[i] =
              ne.getNetNode(nodeId, linkLevel, null, null).getPartitionId();
        }
        for (int i = 0; i < linkArray.length; i++) {
          long linkId = linkArray[i];
          pCost +=
              ne.getNetLink(linkId, linkLevel, pid[i], null, null).getCost();
        }
        return new BfsPath(nodeArray, linkArray, pCost, pLevel);
      }
      return null;
    }

    //add a node and link at the end of the path

    public void append(long nodeID, long linkID, double cost) {
      long[] nArray = new long[nodeIDs.length + 1];
      long[] lArray = new long[linkIDs.length + 1];
      System.arraycopy(this.nodeIDs, 0, nArray, 0, nodeIDs.length);
      nArray[nodeIDs.length] = nodeID;
      System.arraycopy(this.linkIDs, 0, lArray, 0, linkIDs.length);
      lArray[linkIDs.length] = linkID;
      this.nodeIDs = nArray;
      this.linkIDs = lArray;
      this.level++;
      this.cost += cost;
    }
    //check if a path is a cycle

    public boolean isCycle() {
      return nodeIDs[0] == nodeIDs[nodeIDs.length - 1];
    }

    public String toString() {
      StringBuffer buffer = new StringBuffer();
      if (this.isCycle())
        buffer.append("BFS Cycle [" + linkIDs.length + " Links]: ( ");
      else
        buffer.append("BFS Path  [" + linkIDs.length + " Links]: ( ");
      for (int i = 0; i < nodeIDs.length; i++) {
        buffer.append(nodeIDs[i]);
        if (i < linkIDs.length)
          buffer.append(" (" + linkIDs[i] + ") ");
      }
      buffer.append(" ):" + " Cost: " + cost + " Level:" + level);
      return buffer.toString();
    }

    /**
     *Sorts BFS path based on cost and no of links
     */
    public int compareTo(Object o) {
      BfsPath p = (BfsPath)o;
      if (this.cost > p.getCost())
        return 1;
      else if (this.cost < p.getCost())
        return -1;
      else {

        if (this.nodeIDs.length > p.getNodeIDs().length)
          return 1;
        else if (this.nodeIDs.length < p.getNodeIDs().length)
          return -1;
        else
          return 0;
      }
    }

    public String toSortedLinkIDs() {
      StringBuffer buffer = new StringBuffer();
      buffer.append(this.linkIDs.length + ":"); // no of Links
      for (long lid : this.linkIDs)
        buffer.append(lid + ":");
      return buffer.toString();
    }

  }

  /**
   * This class defines a BFS search tree. A BFS search tree starts with a target start node
   * and search either forward or backward. All nodes found during the search is stored based
   * on the level(hop) they are found. This exhausted search approach could  generate a lot of nodes
   * in the search tree. A network with average degrees N can contains O(N^L) nodes at level L.
   * Each BFS node in the tree contains the node ID, level, cost and previous BFS node information.
   * A BFS path can be generated from any given BFS node in the tree using toBfsPath method.
   * By default,
   * level 0 contains the start node itself
   * level 1 contains nodes that can reache or can be reached by 1 hop from start node
   * level n contains nodes can reach(forward search) or can be reached(backward search) by n hops from start node
   */
  public class BfsTree {
    private ArrayList<ArrayList<BfsNode>> list; //tree stored as an ArrayList
    private boolean searchForward = true; // search direction

    public BfsTree(ArrayList<ArrayList<BfsNode>> aList,
                   boolean searchForward) {
      this.list = aList;
      this.searchForward = searchForward;
    }

    /**
     *Returns the BFS tree as an ArrayList of an ArrayList of BFSNode
     * @return
     */
    public ArrayList<ArrayList<BfsNode>> getList() {
      return list;
    }

    /**
     *Returns all BFS nodfes at specific level in an ArrayList
     * @param level
     * @return
     */
    public ArrayList<BfsNode> getNodes(int level) {
      return list.get(level);
    }

    public BfsNode getStartNode() {
      return list.get(0).get(0);
    }

    /**
     *Returns total BFS nodes in the BFS tree
     * @return
     */
    public int getNumberOfNodes() {
      int no = 0;
      for (Iterator<ArrayList<BfsNode>> it = list.listIterator(); it.hasNext();
      )
        no += it.next().size();
      return no;
    }

    /**
     * Returns total BFS nodes at specific level(hop)
     * @param level
     * @return
     */
    public int getNumberOfNodes(int level) {
      int no = 0;
      ArrayList<BfsNode> aList = list.get(level);
      if (aList != null)
        no = aList.size();
      return no;
    }

    /**
     *Returns total number of levels/hops of the BFS tree
     * @return
     */
    public int getNumberOfLevels() {
      int no = 0;
      if (list != null)
        no = list.size() - 1; // minus level 0
      return no;
    }

    /**
     *Retunrs BFS nodes with specific Node ID at specific level from the BFS tree
     * @param nodeID targte node ID
     * @param level target level
     * @return an ArrayList of BFSNode
     */
    public ArrayList<BfsNode> getNodes(long nodeID, int level) {
      ArrayList<BfsNode> newList = new ArrayList<BfsNode>();
      ArrayList<BfsNode> aList = list.get(level);
      if (aList != null) {
        for (int i = 0; i < aList.size(); i++)
          if (aList.get(i).getNodeID() == nodeID)
            newList.add(aList.get(i));
      }
      return newList;
    }

    /**
     *Retunrs all BFS nodes of specifc Node ID from the BFS tree
     * @param nodeID target node ID
     * @return
     */
    public ArrayList<BfsNode> getNodes(long nodeID) {
      ArrayList<BfsNode> newList = new ArrayList<BfsNode>();
      for (int level = 0; level < list.size(); level++) {
        ArrayList<BfsNode> aList = list.get(level);
        if (aList != null) {
          for (int i = 0; i < aList.size(); i++)
            if (aList.get(i).getNodeID() == nodeID)
              newList.add(aList.get(i));
        }
      }
      return newList;
    }

    /**
     *Seacrhes forward or backward from the start node
     * @return
     */
    public boolean isSearchForward() {
      return searchForward;
    }

    public void clear() {
      for (Iterator<ArrayList<BfsNode>> it = list.listIterator(); it.hasNext();
      ) {
        ArrayList<BfsNode> aList = it.next();
        aList.clear();
      }
      list.clear();
    }
  }
}
