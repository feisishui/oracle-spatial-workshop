/* $Header: sdo/demo/network/examples/java/src/router/DirectionsGeneration.java /main/2 2012/12/10 11:18:29 begeorge Exp $ */

/* Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved. */

/*
   DESCRIPTION
    <short description of component this file declares/defines>

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    hgong       07/11/12 - Creation
 */

package router;
 
import java.io.InputStream;

import java.sql.Connection;

import java.util.Locale;

import oracle.spatial.network.lod.DefaultNodeCostCalculator;
import oracle.spatial.network.lod.Dijkstra;
import oracle.spatial.network.lod.LODNetworkConstraint;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.LinkCostCalculator;
import oracle.spatial.network.lod.LogicalSubPath;
import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.NetworkIO;
import oracle.spatial.network.lod.NodeCostCalculator;
import oracle.spatial.network.lod.PointOnNet;
import oracle.spatial.network.lod.ShortestPath;
import oracle.spatial.network.lod.util.PrintUtility;
import oracle.spatial.router.ndm.FastestLinkCostCalculator;
import oracle.spatial.network.apps.router.Leg;
import oracle.spatial.router.ndm.ProhibitedTurnConstraint;
import oracle.spatial.network.apps.router.Route;
import oracle.spatial.network.apps.router.RouterDirectionsGenerator;
import oracle.spatial.router.ndm.ShortestLinkCostCalculator;
import oracle.spatial.util.Logger;

/**
 *  @version $Header: sdo/demo/network/examples/java/src/router/DirectionsGeneration.java /main/2 2012/12/10 11:18:29 begeorge Exp $
 *  @author  hgong   
 *  @since   12.1
 */
public class DirectionsGeneration
{
  //private static final Logger logger = Logger.getLogger("DirectionsGeneration");
  
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

  public static void main(String[] args) throws Exception
  {
    String configXmlFile = "lod/LODConfigs.xml";
    String logLevel    =    "ERROR";

    String dbUrl       = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser      = "";
    String dbPassword  = "";

    String networkName = "NAVTEQ_SF";
    long startNodeId   = 199629863;
    long middleNodeId  = 199928810;
    long endNodeId     = 199610261;

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
      else if(args[i].equalsIgnoreCase("-configXmlFile"))
        configXmlFile = args[i+1];
      else if(args[i].equalsIgnoreCase("-logLevel"))
        logLevel = args[i+1];
      else if(args[i].equalsIgnoreCase("-startNodeId"))
        startNodeId = Long.parseLong(args[i+1]);
      else if(args[i].equalsIgnoreCase("-endNodeId"))
        endNodeId = Long.parseLong(args[i+1]);
    }
    
    setLogLevel(logLevel);
    InputStream configXml = ClassLoader.getSystemResourceAsStream(configXmlFile);
    LODNetworkManager.getConfigManager().loadConfig(configXml);
    Connection conn = LODNetworkManager.getConnection(dbUrl, dbUser, dbPassword);
    NetworkIO nio = LODNetworkManager.getCachedNetworkIO(conn, networkName, networkName, null);
    NetworkAnalyst analyst = LODNetworkManager.getNetworkAnalyst(nio);
    PointOnNet[] startPoints = {new PointOnNet(startNodeId)};
    PointOnNet[] middlePoints = {new PointOnNet(middleNodeId)};
    PointOnNet[] endPoints = {new PointOnNet(endNodeId)};
    LinkCostCalculator[] lccs = {new ShortestLinkCostCalculator(), new FastestLinkCostCalculator()};
    NodeCostCalculator[] nccs = {new DefaultNodeCostCalculator(), new DefaultNodeCostCalculator()};
    ShortestPath d = new Dijkstra(
      analyst.getNetworkExplorer(), 
      lccs, 
      nccs,
      analyst.getLinkLevelSelector());
    LogicalSubPath subPath1 = analyst.shortestPath(startPoints, middlePoints, null, d);
    LogicalSubPath subPath2 = analyst.shortestPath(middlePoints, endPoints, null, d);
    LogicalSubPath[] subPaths = {subPath1, subPath2};
    
    System.out.println("Test single-leg directions for the first path:");
    Route directions = RouterDirectionsGenerator.generateDirections
      (subPath1, Leg.Mode.CAR, true, false,  
       Route.DetailLevel.HIGH, Route.DistanceUnit.MILE, 
       Route.TimeUnit.MINUTE, new Locale("en"), nio);
    System.out.println(directions.toString("mi", "min", true, true));
    
    System.out.println("Test multi-leg directions:");
    Leg.Mode[] legModes = {Leg.Mode.CAR, Leg.Mode.CAR};
    directions = RouterDirectionsGenerator.generateDirections
      (subPaths, legModes, false, false, 
       Route.DetailLevel.HIGH, Route.DistanceUnit.MILE, 
       Route.TimeUnit.MINUTE, new Locale("en"), nio);
    System.out.println(directions.toString("mi", "min", true, true));
    
  }
}

