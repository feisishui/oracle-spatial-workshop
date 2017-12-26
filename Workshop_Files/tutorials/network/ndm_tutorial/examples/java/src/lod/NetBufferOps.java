/* $Header: sdo/demo/network/examples/java/src/lod/NetBufferOps.java /main/3 2012/12/10 11:18:29 begeorge Exp $ */

/* Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved. */

/*
   DESCRIPTION
    <short description of component this file declares/defines>

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    jcwang      01/27/12 - Creation
 */

/**
 *  @version $Header: sdo/demo/network/examples/java/src/lod/NetBufferOps.java /main/3 2012/12/10 11:18:29 begeorge Exp $
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
import oracle.spatial.network.lod.LogicalNode;
import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.NetworkBuffer;
import oracle.spatial.network.lod.NetworkExplorer;
import oracle.spatial.network.lod.NetworkIO;
import oracle.spatial.network.lod.PointOnNet;
import oracle.spatial.network.lod.config.LODConfig;

/**
 * This class shows how to construct a Bread-First Search (BFS) using Oracle NDM
 */
public class NetBufferOps {
  private static final NumberFormat formatter = new DecimalFormat("#.######");
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
    long centerID1 = 915916949;
    long centerID2 = 199728858;
    NetworkBuffer buffer1 = null;
    NetworkBuffer buffer2 = null;
    ArrayList<HashSet<Long>> intersection = null;
    double cost1 = 2000;
    double cost2 = 2000;

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

    System.out.println("Network Buffer Intersection Test for " + networkName);

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

    // reachable buffers

    long startTime = System.currentTimeMillis();
    buffer1 =
        analyst.networkBuffer(new PointOnNet[] { new PointOnNet(centerID1) },
                              cost1, null);
    System.out.println("Buf1 generation took " +
                       (System.currentTimeMillis() - startTime) +
                       " msec...");
    startTime = System.currentTimeMillis();

    buffer2 =
        analyst.networkBuffer(new PointOnNet[] { new PointOnNet(centerID2) },
                              cost2, null);
    System.out.println("Buf2 generation took " +
                       (System.currentTimeMillis() - startTime) +
                       " msec...");
    startTime = System.currentTimeMillis();

    intersection = bufferIntersection(buffer1, buffer2);

    System.out.println("Buf Intersection  took " +
                       (System.currentTimeMillis() - startTime) +
                       " msec...\n");
    startTime = System.currentTimeMillis();
    printBufferIntersection(buffer1, buffer2, intersection, true, false);


    // reaching buffer (Parent Elements)
    buffer1 =
        analyst.reachingNetworkBuffer(new PointOnNet[] { new PointOnNet(centerID1) },
                                      cost1, null);
    System.out.println("Buf1 generation took " +
                       (System.currentTimeMillis() - startTime) +
                       " msec...");
    startTime = System.currentTimeMillis();
    
    buffer2 =
        analyst.reachingNetworkBuffer(new PointOnNet[] { new PointOnNet(centerID2) },
                                      cost2, null);
    System.out.println("Buf2 generation took " +
                       (System.currentTimeMillis() - startTime) +
                       " msec...");
    startTime = System.currentTimeMillis();

    intersection = bufferIntersection(buffer1, buffer2);
    System.out.println("Buf Intersection  took " +
                       (System.currentTimeMillis() - startTime) +
                       " msec...\n");

    printBufferIntersection(buffer1, buffer2, intersection, false, false);

  }
  // return the intersection of two network buffers
  // the first HashSet contains intersecting node IDs
  // and the second HashSet contains th eIDs of intersecting Link IDs

  public static ArrayList<HashSet<Long>> bufferIntersection(NetworkBuffer buf1,
                                                            NetworkBuffer buf2) {
    if (buf1 == null || buf2 == null)
      return null;
    NetworkBuffer.Elements elem1 = buf1.getElements();
    NetworkBuffer.Elements elem2 = buf2.getElements();

    HashSet<Long> nodeSet1 = new HashSet<Long>();
    HashSet<Long> nodeSet2 = new HashSet<Long>();
    HashSet<Long> linkSet1 = new HashSet<Long>();
    HashSet<Long> linkSet2 = new HashSet<Long>();
    HashSet<Long> nodeIntSet = new HashSet<Long>();
    HashSet<Long> linkIntSet = new HashSet<Long>();

    // generate buffer node and link hash sets
    for (LogicalNode node : elem1.getNodes())
      nodeSet1.add(node.getId());
    for (LogicalNode node : elem2.getNodes())
      nodeSet2.add(node.getId());

    for (NetworkBuffer.LinkIntervals interval : elem1.getLinkIntervals())
      linkSet1.add(interval.getLink().getId());

    for (NetworkBuffer.LinkIntervals interval : elem2.getLinkIntervals())
      linkSet2.add(interval.getLink().getId());

    // find set intersection, retainAll
    // find set union, allAll
    // find set subtraction, removeAll

    // find node intersection

    // use the larger set as the driving set
    if (nodeSet1.size() > nodeSet2.size()) {
      nodeIntSet = new HashSet<Long>(nodeSet1);
      nodeIntSet.retainAll(nodeSet2);
    } else {
      nodeIntSet = new HashSet<Long>(nodeSet2);
      nodeIntSet.retainAll(nodeSet1);
    }

    // find link intersection
    if (linkSet1.size() > linkSet2.size()) {
      linkIntSet = new HashSet<Long>(linkSet1);
      linkIntSet.retainAll(linkSet2);
    } else {
      linkIntSet = new HashSet<Long>(linkSet2);
      linkIntSet.retainAll(linkSet1);
    }
    
    // further check link interval intersection
    
    /*
     HashSet<Long> tmpLinkIntSet = new HashSet<Long>();
    if ( linkIntSet.size() > 0) {
      for ( Long linkId: linkIntSet) {
        NetworkBuffer.LinkIntervals  intv1 = buf1.getElements().getLinkIntervals(linkId) ;
        NetworkBuffer.LinkIntervals  intv2 = buf2.getElements().getLinkIntervals(linkId) ;
        NetworkBuffer.DoubleInterval dintv1 = intv1.getIntervals()[0];
        NetworkBuffer.DoubleInterval dintv2 = intv2.getIntervals()[0];
        double start1 = dintv1.getStart(), start2 = dintv2.getStart(),end1 = dintv1.getEnd(),end2=dintv2.getEnd();
        System.out.print("("+ start1+"," + end1+")-(" + start2+","+end2+")  ") ;
        // check if the two intervals overlap
        if ( (start1-start2) *(start2-end1) <= 0 ||
             (start1-end2) *(end2-end1) <= 0  ||
          (start2-start1) *(start1-end2) <= 0 ||
                       (start2-end1) *(end1-end2) <= 0 ) 
          continue;
        else
          tmpLinkIntSet.add(linkId);
        
        System.out.print("("+ start1+"," + end1+")-(" + start2+","+end2+")  ") ;
      }
    System.out.println("\n  Intersecting links to be Removed: " + tmpLinkIntSet.size() +"\n") ;
    }
    */

    ArrayList<HashSet<Long>> result = new ArrayList<HashSet<Long>>();
    

    result.add(nodeIntSet);
    result.add(linkIntSet);
    return result;


  }


  public static void printBufferIntersection(NetworkBuffer buffer1,
                                             NetworkBuffer buffer2,
                                             ArrayList<HashSet<Long>> intersection,
                                             boolean isReachable,
                                             boolean verbose) {
    String direction =
      isReachable ? new String("Reachable ") : new String("Reaching ");

    System.out.println(direction + "Buffer 1 contains " +
                       buffer1.getElements().getNumberOfNodes() + " Nodes, " +
                       buffer1.getElements().getNumberOfLinks() + " Links");
    System.out.println(direction + "Buffer 2 contains " +
                       buffer2.getElements().getNumberOfNodes() + " Nodes, " +
                       buffer2.getElements().getNumberOfLinks() + " Links");

    System.out.println(direction + "Buffer Intersection:");

    if (intersection != null) {
      System.out.println("No. Of Intersecting " + direction + "Nodes: " +
                         intersection.get(0).size() );

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
                           intersection.get(1).size() );
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
