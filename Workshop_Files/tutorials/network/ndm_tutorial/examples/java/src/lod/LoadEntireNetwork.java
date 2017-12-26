/* $Header: sdo/demo/network/examples/java/src/lod/LoadEntireNetwork.java /main/3 2012/12/10 11:18:29 begeorge Exp $ */

/* Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved. */

/*
   DESCRIPTION
    <short description of component this file declares/defines>

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    hgong       11/28/12 - Creation
 */
package lod;

import java.io.InputStream;

import java.sql.Connection;

import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.LogicalBasicNetwork;
import oracle.spatial.network.lod.LogicalNetLink;
import oracle.spatial.network.lod.LogicalNetNode;
import oracle.spatial.network.lod.NetworkIO;
import oracle.spatial.network.lod.UserData;
import oracle.spatial.util.Logger;

/**
 *  This example shows how to load the entire network into memory.
 *  @version $Header: sdo/demo/network/examples/java/src/lod/LoadEntireNetwork.java /main/3 2012/12/10 11:18:29 begeorge Exp $
 *  @author  hgong   
 *  @since   release specific (what release of product did this appear in)
 */

public class LoadEntireNetwork
{
  public static void main(String[] args) throws Exception
  {
    String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser = "";
    String dbPassword = "";
    String networkName = "NAVTEQ_SF";
    String configXmlFile = "lod/LODConfigs.xml";

    //get input parameters
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
    }
    
    Logger.setGlobalLevel(Logger.LEVEL_ERROR);
    InputStream config = ClassLoader.getSystemResourceAsStream(configXmlFile);
    LODNetworkManager.getConfigManager().loadConfig(config);

    Connection conn = LODNetworkManager.getConnection(dbUrl, dbUser, dbPassword);
    NetworkIO nio = LODNetworkManager.getCachedNetworkIO(conn, networkName, networkName, null);
    
    //Load the entire network on the minimum link level 1, which includes
    //links and nodes of all levels.
    int[] userDataCategories = {0};  //load category 0 user data as well
    long startTime = System.currentTimeMillis();
    LogicalBasicNetwork network = nio.readLogicalNetwork(1, userDataCategories, null, false);
    System.out.println("Time to load the network is "+(System.currentTimeMillis()-startTime)/1000+"s.");
    //Now you can get the nodes and links in the network, and do whatever
    //you want with them.
    LogicalNetNode[] nodes = network.getNodes();
    System.out.println(nodes.length+" nodes");
    for(int i=0; i<2; i++)
    {
      LogicalNetNode node = nodes[i];
      long nodeId = node.getId();
      double cost = node.getCost();
      System.out.print(nodeId+" : "+cost);
      //use the following code only if you are interested in node properties
      UserData ud = node.getUserData(0);  //category 0 user data
      if(ud!=null)
      {
        //longitude
        double x = (Double)ud.get(0);
        //latitude
        double y = (Double)ud.get(1);
        System.out.print(", ("+x+", "+y+")");
      }
      System.out.println();
    }
    LogicalNetLink[] links = network.getLinks();
    System.out.println(links.length+" links");
    for(int i=0; i<2; i++)
    {
      LogicalNetLink link = links[i];
      long linkId = link.getId();
      long startNodeId = link.getStartNodeId();
      long endNodeId = link.getEndNodeId();
      double cost = link.getCost();
      System.out.print(linkId+" : "+startNodeId+" --> "+endNodeId+", "+cost);
      //use the following code only if you are interested in link properties
      UserData ud = link.getUserData(0);  //category 0 user data
      if(ud!=null)
      {
        //function class
        double functionClass = (Double)ud.get(0);
        //speed limit
        double speedLimit = (Double)ud.get(1);
        System.out.print(", "+functionClass+", "+speedLimit);
      }
      System.out.println();
    }
  }
}
