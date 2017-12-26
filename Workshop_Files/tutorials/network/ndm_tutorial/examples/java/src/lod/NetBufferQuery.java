/* $Header: sdo/demo/network/examples/java/src/lod/NetBufferQuery.java /main/2 2012/12/10 11:18:29 begeorge Exp $ */

/* Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved. */

/*
   DESCRIPTION
    <short description of component this file declares/defines>

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    jcwang      05/22/12 - Creation
 */

/**
 *  @version $Header: sdo/demo/network/examples/java/src/lod/NetBufferQuery.java /main/2 2012/12/10 11:18:29 begeorge Exp $
 *  @author  jcwang
 *  @since   release specific (what release of product did this appear in)
 */

package lod;

import java.io.InputStream;

import java.sql.Connection;

import java.text.DecimalFormat;
import java.text.NumberFormat;

import java.util.ArrayList;
import java.util.HashSet;

import oracle.spatial.network.lod.CachedNetworkIO;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.util.Logger;
import oracle.spatial.network.lod.LogicalNode;
import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.NetworkBuffer;
import oracle.spatial.network.lod.NetworkExplorer;
import oracle.spatial.network.lod.NetworkIO;
import oracle.spatial.network.lod.PointOnNet;
import oracle.spatial.network.lod.config.LODConfig;

/**
 * This class shows how to create network buffers and conduct queries on them
 */
public class NetBufferQuery {
  private static final NumberFormat formatter =
    new DecimalFormat("######.######");
  private static NetworkIO networkIO;
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


  public static void main(String[] args) throws Exception {
    String configXmlFile = "lod/LODConfigs.xml";
    String logLevel = "ERROR";
    String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser = "";
    String dbPassword = "";

    String networkName = "NAVTEQ_SF";

    long[] centerIDs = { 915916949, 199728858, 199564410, 199815772 };

    ArrayList<HashSet<Long>> intersection = null;
    double[] costs = { 2000, 2000, 2000, 2000 }; // in meters


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


    System.out.println("Network Buffer Cost Query Test for " + networkName);
    for (int i = 0; i < centerIDs.length; i++)
      System.out.println("Buffer Center " + i + " : " + centerIDs[i] +
                         " Cost:" + costs[i]);

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
    //get network input/output object
    networkIO =
        LODNetworkManager.getCachedNetworkIO(conn, networkName, networkName,
                                             null);
    //get network analyst
    NetworkAnalyst analyst = LODNetworkManager.getNetworkAnalyst(networkIO);

    // reachable buffers : coverage from buffer centers  to reachable points
    long startTime = System.currentTimeMillis();


    ArrayList<NetworkBuffer> bufferList = new ArrayList<NetworkBuffer>();
    for (int i = 0; i < centerIDs.length; i++)
      bufferList.add(analyst.networkBuffer(new PointOnNet[] { new PointOnNet(centerIDs[i]) },
                                           costs[i], null));
    System.out.println("Buffer generation took " +
                       (System.currentTimeMillis() - startTime) + " msec...");


    startTime = System.currentTimeMillis();
    
    // generate intersection points
    intersection = bufferIntersection(bufferList);
    // query intersection points and their costs 
    testCostQuery(bufferList, toQueryPoints(intersection, 0.0, false));


    System.out.println("Buffer Cost query  took " +
                       (System.currentTimeMillis() - startTime) +
                       " msec...\n");
    // print out intersection points/links
    printBufferIntersection(bufferList, intersection, true, true);


    // reaching buffers: coverage from reaching points to buffer centers

    startTime = System.currentTimeMillis();
    bufferList.clear();
    for (int i = 0; i < centerIDs.length; i++)
      bufferList.add(analyst.reachingNetworkBuffer(new PointOnNet[] { new PointOnNet(centerIDs[i]) },
                                                   costs[i], null));
    System.out.println("Buffer generation took " +
                       (System.currentTimeMillis() - startTime) + " msec...");

    startTime = System.currentTimeMillis();
    intersection = bufferIntersection(bufferList);
    testCostQuery(bufferList, toQueryPoints(intersection, 1.0, false));


    System.out.println("Buffer Cost query took " +
                       (System.currentTimeMillis() - startTime) +
                       " msec...\n");
    // print out intersection points/links
    printBufferIntersection(bufferList, intersection, false, true);

  }

  // convert intersecting links to points on net with a fixed percentage
  private static PointOnNet[] toQueryPoints(ArrayList<HashSet<Long>> intersectingSet,
                                            double percentage,
                                            boolean useNodes) {
    HashSet<Long> set = null;
    if (useNodes)
      set = intersectingSet.get(0); // use intersecting nodes
    else
      set = intersectingSet.get(1); // use intersecting links

    PointOnNet[] array = new PointOnNet[set.size()];
    int i = 0;
    System.out.println("Total " + set.size() + " points tested...");
    for (Long l : set) {
      if (useNodes)
        array[i] = new PointOnNet(l.longValue()); // nodes
      else
        array[i] =
            new PointOnNet(l.longValue(), percentage); // link with percentage
      i++;
    }
    return array;
  }

  // main function to test query points to a list of buffers
  public static void testCostQuery(ArrayList<NetworkBuffer> bufferList,
                                   PointOnNet[] queryPoints) {
    System.out.println("Point Cost {");
    for (PointOnNet pt : queryPoints) {
      // handle point outside the buffer case, if returned null assume infinity cost
      for (int i = 0; i < bufferList.size(); i++) {
        NetworkBuffer buffer = bufferList.get(i);
        double cost =
          buffer.getCosts(pt) == null ? Double.POSITIVE_INFINITY : buffer.getCosts(pt)[0];
        System.out.println("Point:" + pt + "   \t\tcost to Buffer: " + i +
                           "  " + formatter.format(cost));

      }
      //System.out.println(" ");
      NetworkBuffer buf = nearestBuffer(bufferList, pt);

      if (buf != null) {
        double cost = buf.getCosts(pt)[0];
        ;
        System.out.println("---The Nearest Buffer: [center: " +
                           buf.getCentralPoints()[0] + " dir.:" +
                           (buf.getDirection() == 1 ? "Reachable" :
                            "Reaching") + " cost: " + formatter.format(cost) +
                           "] ");
      }
      System.out.println(" ");
    }
    System.out.println("}");
  }
  // generate intersection nodes/links from a list of network buffers
  public static ArrayList<HashSet<Long>> bufferIntersection(ArrayList<NetworkBuffer> list) {
    ArrayList<HashSet<Long>> nodeList = new ArrayList<HashSet<Long>>();
    ArrayList<HashSet<Long>> linkList = new ArrayList<HashSet<Long>>();
    for (NetworkBuffer buffer : list) {
      ArrayList<HashSet<Long>> bufList = bufferToHashSet(buffer);
      nodeList.add(bufList.get(0));
      linkList.add(bufList.get(1));
    }
    ArrayList<HashSet<Long>> result = new ArrayList<HashSet<Long>>();
    HashSet<Long> nodeSet = nodeList.get(0);
    HashSet<Long> linkSet = linkList.get(0);
    for (int i = 1; i < nodeList.size(); i++) {
      nodeSet = hashSetIntersection(nodeSet, nodeList.get(i));
      linkSet = hashSetIntersection(linkSet, linkList.get(i));
    }
    result.add(nodeSet);
    result.add(linkSet);
    return result;
  }


  // return the nearest covered network buffer for a given point w.r.t. to a list of network buffers
  // return null , if none of the buffers cover the point
  // a brute-force linear search approach
  public static NetworkBuffer nearestBuffer(ArrayList<NetworkBuffer> bufArray,
                                            PointOnNet point) {
    int id = -1;
    double cost = Double.MAX_VALUE;
    for (int i = 0; i < bufArray.size(); i++) {
      NetworkBuffer buf = bufArray.get(i);
      if (buf.getCosts(point) != null) {
        if (buf.getCosts(point)[0] < cost) {
          cost = buf.getCosts(point)[0]; // update min. cost and id
          id = i;
        }
      }
    }
    if (id == -1) // not found
      return null;
    else
      return bufArray.get(id);
  }

  // return the node and link ID intersection in HashSet<Long>
  private static ArrayList<HashSet<Long>> bufferToHashSet(NetworkBuffer buf) {
    if (buf == null)
      return null;
    NetworkBuffer.Elements elem = buf.getElements();
    HashSet<Long> nodeSet = new HashSet<Long>();
    HashSet<Long> linkSet = new HashSet<Long>();

    // generate buffer node and link hash sets
    for (LogicalNode node : elem.getNodes())
      nodeSet.add(node.getId());

    for (NetworkBuffer.LinkIntervals interval : elem.getLinkIntervals())
      linkSet.add(interval.getLink().getId());

    ArrayList<HashSet<Long>> result = new ArrayList<HashSet<Long>>();

    result.add(nodeSet); // first one is node IDs
    result.add(linkSet); // second one is the link IDs
    return result;

  }
  // intersection of two HashSet<Long> and return the intersection as HashSet<Long>
  private static HashSet<Long> hashSetIntersection(HashSet<Long> set1,
                                                   HashSet<Long> set2) {
    // use the larger set as the driving set
    if (set1 == null || set2 == null)
      return null;
    HashSet<Long> set = null;
    if (set1.size() > set2.size()) {
      set = new HashSet<Long>(set1);
      set.retainAll(set2);
    } else {
      set = new HashSet<Long>(set2);
      set.retainAll(set1);
    }
    return set;
  }
  // print out intersection ndoes/links of a list of buffers
  public static void printBufferIntersection(ArrayList<NetworkBuffer> list,
                                             ArrayList<HashSet<Long>> intersection,
                                             boolean isReachable,
                                             boolean verbose) {
    String direction =
      isReachable ? new String("Reachable ") : new String("Reaching ");

    for (int i = 0; i < list.size(); i++) {
      NetworkBuffer buffer = list.get(i);
      System.out.println(direction + " Buffer: " + i + " contains " +
                         buffer.getElements().getNumberOfNodes() + " Nodes, " +
                         buffer.getElements().getNumberOfLinks() + " Links");
    }

    System.out.println(direction + "Buffer Intersection:");

    if (intersection != null) {
      System.out.println("No. Of Intersecting " + direction + "Nodes: " +
                         intersection.get(0).size());

      int count = 1;
      if (verbose) {
        System.out.print("(\n");
        for (Long id : intersection.get(0)) {
          System.out.print(id + " ");
          count++;
          if (count > 10) {
            System.out.print("\n");
            count = 1;
          }
        }
        System.out.print(" \n)\n");
      }

      if (intersection.get(1) != null) {
        System.out.println("No. Of Intersecting " + direction + "Links: " +
                           intersection.get(1).size());
        count = 1;
        if (verbose) {
          System.out.print("(\n");
          for (Long id : intersection.get(1)) {
            System.out.print(id + " ");
            count++;
            if (count > 10) {
              System.out.print("\n");
              count = 1;
            }
          }
          System.out.print(" \n)\n");
        }
      }

    }
    System.out.print("\n");

  }
}
