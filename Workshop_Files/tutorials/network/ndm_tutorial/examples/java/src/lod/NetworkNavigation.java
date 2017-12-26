/* $Header: sdo/demo/network/examples/java/src/lod/NetworkNavigation.java /main/6 2012/12/10 11:18:29 begeorge Exp $ */

/* Copyright (c) 2007, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   DESCRIPTION
    <short description of component this file declares/defines>

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    hgong       07/10/07 - Creation
 */

package lod;

import java.io.InputStream;

import java.sql.Connection;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;

import oracle.spatial.network.lod.CachedNetworkIO;
import oracle.spatial.network.lod.LODNetworkException;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.LogicalLink;
import oracle.spatial.network.lod.LogicalNetLink;
import oracle.spatial.network.lod.LogicalNetNode;
import oracle.spatial.network.lod.NetworkExplorer;
import oracle.spatial.util.Logger;

/**
 *  This class demonstrates how to use NetworkExplorer to navigate through a 
 *  network.
 *  
 *  @version $Header: sdo/demo/network/examples/java/src/lod/NetworkNavigation.java /main/6 2012/12/10 11:18:29 begeorge Exp $
 *  @author  hgong   
 *  @since   11gR2
 */
public class NetworkNavigation {
  NetworkExplorer ne;
  int linkLevel;
  
  public NetworkNavigation(NetworkExplorer ne, int linkLevel)
  {
    this.ne = ne;
    this.linkLevel = linkLevel;
  }
  
  /**
   * Finds the IDs of the nodes reachable within two hops from the specified
   * node.
   * @param startNodeId node to start the search
   * @return
   * @throws LODNetworkException
   */
  public long[] findNodesWithinTwoHops(long startNodeId)
    throws LODNetworkException
  {
    HashSet<Long> connectedNodes = new HashSet<Long>();
    //get the network node for the start node ID, which contains references to
    //its adjacent links.
    LogicalNetNode startNode = ne.getNetNode(startNodeId, linkLevel, null, null);
    long[] children, grandChildren;
    long child;
    LogicalNetNode childNode;
    children = startNode.getNextNodeIds(true);
    if(children!=null)
    {
      for(int i=0; i<children.length; i++)
      {
        child = children[i];
        connectedNodes.add(child);
        childNode = ne.getNetNode(child, linkLevel, null, null);
        grandChildren = childNode.getNextNodeIds(true);
        if(grandChildren!=null)
        {
          for(int j=0; j<grandChildren.length; j++)
          {
            if(grandChildren[j]!=startNodeId)
              connectedNodes.add(grandChildren[j]);
          }
        }
      }
    }
    long[] rt = new long[connectedNodes.size()];
    int i=0;
    for(Iterator<Long> it = connectedNodes.iterator(); it.hasNext(); )
      rt[i++] = it.next();
    return rt;
  }

  /**
   * Finds the standalone link objects within two hops away from the specified
   * node.
   * @param startNodeId node to start the search
   * @return
   * @throws LODNetworkException
   */
  public LogicalLink[] findLinksWithinTwoHops(long startNodeId)
    throws LODNetworkException
  {
    HashMap<Long, LogicalLink> connectedLinks = new HashMap<Long, LogicalLink>();
    //get the network node for the start node ID, which contains references to
    //its adjacent links.
    LogicalNetNode startNode = ne.getNetNode(startNodeId, linkLevel, null, null);
    LogicalNetLink[] childLinks, grandChildLinks;
    LogicalNetLink childLink;
    LogicalLink standAloneLink;
    LogicalNetNode childNode;
    long childNodeId;
    childLinks = startNode.getOutLinks(true);
    if(childLinks!=null)
    {
      for(int i=0; i<childLinks.length; i++)
      {
        childLink = childLinks[i];
        //IMPORTANT: To avoid memory leak, do NOT reference the network link.
        //Instead, create a starndalone link from the network link and reference
        //the standalone link. It is important to release the reference to the
        //network links as soon as possible, so that java garbage collector
        //can reclaim the memory consumed by the corresponding partition in time.
        standAloneLink = childLink.toStandAloneLink();
        connectedLinks.put(standAloneLink.getId(), standAloneLink);
        if(childLink.getStartNodeId()==startNodeId)
          childNode = childLink.getEndNode();
        else
          childNode = childLink.getStartNode();
        childNodeId = childNode.getId();
        
        //IMPORTANT: If the childLink is a boundary link in the start 
        //nodes's partition, the child node got from childLink.getEndNode() or 
        //childLink.getStartNode() becomes an external node in the start node's 
        //partition, thus may not contain all the references to its
        //adjacent links.
        //Therefore, you should always ask NetworkExplorer to get the child node  
        //object using the child node ID, to ensure that the returned child node 
        //object is an internal node in its containing partition, thus contains
        //reference to all its adjacent links. 
        childNode = ne.getNetNode(childNodeId, linkLevel, null, null);
        
        grandChildLinks = childNode.getOutLinks(true);
        if(grandChildLinks!=null)
        {
          for(int j=0; j<grandChildLinks.length; j++)
          {
            standAloneLink = grandChildLinks[j].toStandAloneLink();
            connectedLinks.put(standAloneLink.getId(), standAloneLink);
          }
        }
      }
    }
    LogicalLink[] rt = new LogicalLink[connectedLinks.size()];
    connectedLinks.values().toArray(rt);
    return rt;
  }

  private static void setLogLevel(String logLevel)
  {
    if("FATAL".equalsIgnoreCase(logLevel))
        Logger.setGlobalLevel(Logger.LEVEL_FATAL);
    else if("ERROR".equalsIgnoreCase(logLevel))
        Logger.setGlobalLevel(Logger.LEVEL_ERROR);
    else if("WARN".equalsIgnoreCase(logLevel))
        Logger.setGlobalLevel(Logger.LEVEL_WARN);
    else if("INFO".equalsIgnoreCase(logLevel))
        Logger.setGlobalLevel(Logger.LEVEL_INFO);
    else if("DEBUG".equalsIgnoreCase(logLevel))
        Logger.setGlobalLevel(Logger.LEVEL_DEBUG);
    else if("FINEST".equalsIgnoreCase(logLevel))
        Logger.setGlobalLevel(Logger.LEVEL_FINEST);
    else  //default: set to ERROR
        Logger.setGlobalLevel(Logger.LEVEL_ERROR);
  }

  public static void main(String[] args)
  {
    //Get input parameters
    String configXmlFile    = "lod/LODConfigs.xml";
    String logLevel    = "ERROR";

    String dbUrl    = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser     = "";
    String dbPassword = "";
    
    String networkName = "HILLSBOROUGH_NETWORK";
    long startNodeId   = 1533;
    int linkLevel = 1;

    for(int i=0; i<args.length; i++)
    {
      if(args[i].equalsIgnoreCase("-dbUrl"))
        dbUrl = args[i+1];
      else if(args[i].equalsIgnoreCase("-dbUser"))
        dbUser = args[i+1];
      else if(args[i].equalsIgnoreCase("-dbPassword"))
        dbPassword = args[i+1];
      else if(args[i].equalsIgnoreCase("-networkName"))
        networkName = args[i+1].toUpperCase();
      else if(args[i].equalsIgnoreCase("-startNodeId"))
        startNodeId = Long.parseLong(args[i+1]);
      else if(args[i].equalsIgnoreCase("-linkLevel"))
        startNodeId = Integer.parseInt(args[i+1]);
      else if(args[i].equalsIgnoreCase("-configXmlFile"))
        configXmlFile = args[i+1];
      else if(args[i].equalsIgnoreCase("-logLevel"))
        logLevel = args[i+1];
    }

    try
    {
      System.out.println("Test Network Navigation");
      
      setLogLevel(logLevel);

      //set LOD configuration
      InputStream config = ClassLoader.getSystemResourceAsStream(configXmlFile);
      LODNetworkManager.getConfigManager().loadConfig(config);

      //get connection
      Connection conn = LODNetworkManager.getConnection(dbUrl, dbUser, dbPassword);
      //get network reader
      CachedNetworkIO reader = LODNetworkManager.getCachedNetworkIO(
        conn, networkName, networkName, null);
      //get network explorer
      NetworkExplorer ne = new NetworkExplorer(reader);
      
      NetworkNavigation test = new NetworkNavigation(ne, linkLevel);
      //test get nodes within two tops
      long[] nodes = test.findNodesWithinTwoHops(startNodeId);
      System.out.println(nodes.length+" nodes are within two hops away: ");
      for(int i=0; i<nodes.length; i++)
      {
        System.out.print(" "+nodes[i]);
      }
      System.out.println('\n');

      //test get links within two hops
      LogicalLink[] links = test.findLinksWithinTwoHops(startNodeId);
      LogicalLink link;
      System.out.println(nodes.length+" links are within two hops away: ");
      for(int i=0; i<links.length; i++)
      {
        link = links[i];
        System.out.println(" "+link.getId()+": "+
          link.getStartNodeId()+ 
          (link.isBidirected()?" <-> ":" -> ")+
          link.getEndNodeId()+" "+
          "costs "+link.getCost());
      }
      System.out.println('\n');
    }
    catch (Exception e)
    {
      System.err.println(e.getMessage());
      e.printStackTrace();
    }
  }    
}
