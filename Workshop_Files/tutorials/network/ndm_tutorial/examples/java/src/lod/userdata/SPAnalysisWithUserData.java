/* $Header: sdo/demo/network/examples/java/src/lod/userdata/SPAnalysisWithUserData.java /main/3 2012/12/10 11:18:30 begeorge Exp $ */

/* Copyright (c) 2010, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   DESCRIPTION
    <short description of component this file declares/defines>

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    begeorge    12/08/10 - Creation
 */

/**
 *  @version $Header: sdo/demo/network/examples/java/src/lod/userdata/SPAnalysisWithUserData.java /main/3 2012/12/10 11:18:30 begeorge Exp $
 *  @author  begeorge
 *  @since   release specific (what release of product did this appear in)
 */

import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.StringTokenizer;
import oracle.jdbc.OracleConnection;
import oracle.jdbc.pool.OracleDataSource;
import oracle.spatial.network.NetworkMetadata;
import oracle.spatial.network.UserDataMetadata;
import oracle.spatial.network.lod.DynamicLinkLevelSelector;
import oracle.spatial.network.lod.HeuristicCostFunction;
import oracle.spatial.network.lod.GeodeticCostFunction;
import oracle.spatial.network.lod.LODAnalysisInfo;
import oracle.spatial.network.lod.LODNetworkConstraint;
import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.LODUserDataIO;
import oracle.spatial.network.lod.LODUserDataIOSDO;
import oracle.spatial.network.lod.LinkCostCalculator;
import oracle.spatial.network.lod.LinkLevelSelector;
import oracle.spatial.network.lod.NetworkIO;
import oracle.spatial.network.lod.LogicalSubPath;
import oracle.spatial.network.lod.PointOnNet;
import oracle.spatial.network.lod.util.PrintUtility;
import oracle.spatial.util.Logger;
import oracle.spatial.network.lod.LogicalLink;
import oracle.spatial.network.lod.LogicalNetNode;
import oracle.spatial.network.lod.NetworkExplorer;
import oracle.spatial.network.lod.config.LODConfig;

public class SPAnalysisWithUserData
{
  private static final NumberFormat formatter = new DecimalFormat("#.######");
  
  private static NetworkAnalyst analyst;
  private static NetworkIO networkIO;
  
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
  
  private static OracleConnection getConnection(String dbURL,
    String user, String password) throws SQLException
  {
    OracleConnection conn = null;
    OracleDataSource ds = new OracleDataSource();
    ds.setURL(dbURL);
    ds.setUser(user);
    ds.setPassword(password);
    conn = (OracleConnection)ds.getConnection();    
    conn.setAutoCommit(false);
    return conn;
  }

private static PointOnNet[][] nodeIdsToPoints(long[] nodeIds)
{
    PointOnNet[][] points = new PointOnNet[nodeIds.length][1];
    for(int i=0; i<points.length; i++)
      points[i][0] = new PointOnNet(nodeIds[i]);
    return points;
}
  
private static long[] parseLongIds(String idString)
{
    if (idString != null )
      idString = idString.trim() ;
    else
      return null;
    StringTokenizer st = new StringTokenizer(idString,"+ ");
    int no = st.countTokens();
    long [] ids = new long[no];
    int count = 0;
    while (st.hasMoreTokens()) 
    {
      long id = Long.parseLong(st.nextToken());
      ids[count++] = id;
    }
    return ids;
}

public static void main(String[] args) throws Exception
  {
    String configXmlFile = "LODConfigs.xml";
    String logLevel    =   "DEBUG";          
        
    String dbUrl       = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser      = "";
    String dbPassword  = "";

    String networkName = "EXAMPLE";
    long startNodeId   = 6935;
    long endNodeId     = 6889;        
    int linkLevel      = 1;  //default link level
    
    Connection conn    = null;
    
    //get input parameters
    for(int i=0; i<args.length; i++)
    {
        if(args[i].equalsIgnoreCase("-dbUrl"))
          dbUrl = args[i+1];
        else if(args[i].equalsIgnoreCase("-dbUser"))
          dbUser = args[i+1];
        else if(args[i].equalsIgnoreCase("-dbPassword"))
          dbPassword = args[i+1];
        else if(args[i].equalsIgnoreCase("-networkName") && args[i+1]!=null)
          networkName = args[i+1].toUpperCase();
        else if(args[i].equalsIgnoreCase("-linkLevel"))
          linkLevel = Integer.parseInt(args[i+1]);
        else if(args[i].equalsIgnoreCase("-configXmlFile"))
          configXmlFile = args[i+1];
        else if(args[i].equalsIgnoreCase("-logLevel"))
          logLevel = args[i+1];
      }
      
      // opening connection
      conn = LODNetworkManager.getConnection(dbUrl, dbUser, dbPassword);

      Statement stmt = conn.createStatement();
    
    System.out.println("Analysis for "+networkName+" network");

    setLogLevel(logLevel);
    
    //load user specified LOD configuration (optional), 
    //otherwise default configuration will be used
    InputStream config = ClassLoader.getSystemResourceAsStream(configXmlFile);
    LODNetworkManager.getConfigManager().loadConfig(config);
    LODConfig c = LODNetworkManager.getConfigManager().getConfig(networkName);
    
    NetworkMetadata metadata =LODNetworkManager.getNetworkMetadata(conn, networkName, networkName);
    
    //Load User Data IOs
    LODUserDataIO[] networkUDIOs = new LODUserDataIO[2];
    networkUDIOs[0] = new LODUserDataIOSDO(conn,metadata,UserDataMetadata.DEFAULT_USER_DATA_CATEGORY); 
    networkUDIOs[1] = new EUserDataIO(conn, EUserDataIO.USER_DATA_CATEGORY_EXAMPLE, "EXAMPLE_USER_DATA");
    
    //get network input/output object
    networkIO = LODNetworkManager.getCachedNetworkIO(
                                      conn, networkName, networkName, metadata, networkUDIOs);
    //get network analyst
    analyst = LODNetworkManager.getNetworkAnalyst(networkIO);
    
    NetworkExplorer ne = analyst.getNetworkExplorer();
    LogicalSubPath subPath;
  
    try {
        System.out.println("*****BEGIN: testShortestPathDijkstra*****");
        
        LinkCostCalculator [] oldlccs = analyst.getLinkCostCalculators();
        
        
        //Shortest path without constraint
        System.out.println();
        System.out.println("Shortest Path Without Constraint");
        subPath = analyst.shortestPathDijkstra(new PointOnNet(startNodeId),
                                               new PointOnNet(endNodeId), null);
        if (subPath == null) {
            System.out.println("No path exists!!");
        }
        else {
            System.out.println("Is the returned subpath a full path? "+subPath.isFullPath());
            PrintUtility.print(System.out,subPath,true,20,0);
        }
        
        
        //Set link cost calculator to compute travel time as link cost
        //This LCC uses Category 0 user data, (ie) speed limit
        //Category 0 user data is registered in user_sdo_network_user_data_metadata
        System.out.println();
        System.out.println("Shortest Path With Travel Time as Link Cost");
        System.out.println("(Link Cost Calculator uses Category 0 (Link) User Data)");
        LinkCostCalculator [] tlccs = {new LinkTravelTimeCalculator()};
        analyst.setLinkCostCalculators(tlccs);
        subPath = analyst.shortestPathDijkstra(new PointOnNet(startNodeId),
                                               new PointOnNet(endNodeId),
                                               null);
        if (subPath == null) {
            System.out.println("No path exists!!");
        }
        else {
            System.out.println("Is the returned subpath a full path? "+subPath.isFullPath());
            PrintUtility.print(System.out,subPath,true,20,0);
        }
        //Restore to default link cost calculator
        analyst.setLinkCostCalculators(oldlccs);
        
        //Setting new link cost calculator based on link Type
        //This link cost calculator uses user data of category 1
        System.out.println();
        System.out.println("Shortest Path With Link Cost Calculator based on Link Type");
        System.out.println("(Link Cost Calculator uses Category 1 (Link) User Data)");
        LinkCostCalculator [] lccs = {new TypeBasedLinkCostCalculator()};
        analyst.setLinkCostCalculators(lccs);
        subPath = analyst.shortestPathDijkstra(new PointOnNet(startNodeId),
                                               new PointOnNet(endNodeId),null);
        if (subPath == null) {
            System.out.println("No path exists !!");
        }
        else {
            System.out.println("Is the returned subpath a full path? "+subPath.isFullPath());
            PrintUtility.print(System.out, subPath, true, 20, 0);
        }
        //Restore to default link cost calculator
        analyst.setLinkCostCalculators(oldlccs);
        
        //Shortest Path with link constraint
	//Link constraint implementation illustrates the use of Category 1 link user data 
        System.out.println();
        System.out.println("Shortest Path With Link Constraint");
        System.out.println("(Constraint uses Category 1 (Link) User Data)");
        LODNetworkConstraint LinkTypeConstraint = new LinkTypeConstraint();
        subPath = analyst.shortestPathDijkstra(new PointOnNet(startNodeId), 
                  new PointOnNet(endNodeId), LinkTypeConstraint);
        if (subPath == null) {
            System.out.println("With constraint, no path exists !!");  
        }
        else
        {
            System.out.println("Is the returned subpath a full path? "+subPath.isFullPath());
            PrintUtility.print(System.out, subPath, true, 20, 0);
        }
         
        //Shortest Path With Node Constraint
	//Node constraint implementation uses node user data of category 1
        System.out.println();
        System.out.println("Shortest Path With Node Constraint");
        System.out.println("(Constraint uses Category 1 (Node) User Data)");
        LODNetworkConstraint NodeTypeConstraint = new NodeTypeConstraint();
        subPath = analyst.shortestPathDijkstra(new PointOnNet(startNodeId),
                                               new PointOnNet(endNodeId),
                                               NodeTypeConstraint);
        if (subPath == null) {
            System.out.println("With constraint, no path exists!!");
        }
        else {
            System.out.println("Is the returned subpath a full path? "+subPath.isFullPath());
            PrintUtility.print(System.out, subPath, true, 20, 0);
        }
        System.out.println();
        System.out.println("*****END: testShortestPathDijkstra*****");
     
    }
    catch (Exception e)  {
        e.printStackTrace();
    }

    try {
        //Illustrates the usage of Category 0 node user data ((ie), x, y)
        System.out.println();
        System.out.println("*****BEGIN: testShortestPathAStar");
        System.out.println("(AStar analysis uses Category 0 node user data, X,Y)");
        int xUserDataIndex = EUserDataIO.USER_DATA_INDEX_NODE_X;
        int yUserDataIndex = EUserDataIO.USER_DATA_INDEX_NODE_Y;
        int numHighLevelNeighbors = 8;
        double costMultiplier = 1.5;
        double costThreshold = 1550;
        double [] costThresholds = {costThreshold};
        HeuristicCostFunction hcf =  new GeodeticCostFunction(
                                         UserDataMetadata.DEFAULT_USER_DATA_CATEGORY,
                                         xUserDataIndex,yUserDataIndex,-1);
        LinkLevelSelector lls = new DynamicLinkLevelSelector (analyst,linkLevel,hcf,
                                                              costThresholds,
                                                              numHighLevelNeighbors,
                                                              costMultiplier,null);
        subPath = analyst.shortestPathAStar(new PointOnNet(startNodeId),
                                            new PointOnNet(endNodeId),
                                            null, hcf, lls);
        if (subPath == null) {
            System.out.println("No path exists!!");
        }
        else {
            System.out.println("Is the returned subpath a full path? "+subPath.isFullPath());
            PrintUtility.print(System.out, subPath, true, 20, 0);
        }
        System.out.println();
        System.out.println("*****END: testShortestPathAStar");
    }
    catch (Exception e) {
        e.printStackTrace();
    }

    if(conn!=null)
      try{conn.close();} catch(Exception ignore){}

  }
  
  private static class TypeBasedLinkCostCalculator implements LinkCostCalculator {
      private static int[] userDataCategories = {EUserDataIO.USER_DATA_DEFAULT_CATEGORY,
                                                 EUserDataIO.USER_DATA_CATEGORY_EXAMPLE};
      public TypeBasedLinkCostCalculator () {
          
      }
      
      public double getLinkCost(LODAnalysisInfo analysisInfo) {
          LogicalLink link = analysisInfo.getNextLink();
          int linkType = (Integer) link.getCategorizedUserData().
                         getUserData(EUserDataIO.USER_DATA_CATEGORY_EXAMPLE).
                         get(EUserDataIO.USER_DATA_INDEX_LINKTYPE);
          double linkCost = link.getCost();
          if (linkType > 2) {
              linkCost = 2*linkCost;
          }
          return linkCost;
      }
      
      public int [] getUserDataCategories()  {
          return userDataCategories;
      }
  }
  
  private static class LinkTravelTimeCalculator implements LinkCostCalculator {
      private static int[] userDataCategories = {EUserDataIO.USER_DATA_DEFAULT_CATEGORY,
                                                 EUserDataIO.USER_DATA_CATEGORY_EXAMPLE};
                                                 
      public LinkTravelTimeCalculator () {
         
      }
      
      public double getLinkCost(LODAnalysisInfo analysisInfo) {
        LogicalLink link = analysisInfo.getNextLink();
        double linkSpeedLimit = (Double)link.getCategorizedUserData().
                                getUserData(EUserDataIO.USER_DATA_DEFAULT_CATEGORY).
                                get(EUserDataIO.USER_DATA_INDEX_LINKSPEED);
        //Link cost is the link length
        double linkCost = link.getCost();
        return linkCost/linkSpeedLimit;
      }
      
      public int [] getUserDataCategories()  {
          return userDataCategories;
      }
      
  }
  
  private static class LinkTypeConstraint implements LODNetworkConstraint
  {
      private static int[] userDataCategories = {EUserDataIO.USER_DATA_DEFAULT_CATEGORY,
                                                 EUserDataIO.USER_DATA_CATEGORY_EXAMPLE};
      
      public LinkTypeConstraint() {

      }

      public boolean isSatisfied(LODAnalysisInfo analysisInfo) {
        LogicalLink link = analysisInfo.getNextLink();
        boolean linkOfRequiredType = false;
        int linkType = (Integer)link.getCategorizedUserData().
                        getUserData(EUserDataIO.USER_DATA_CATEGORY_EXAMPLE).
                        get(EUserDataIO.USER_DATA_INDEX_LINKTYPE);
        if (linkType == 0 || linkType == 1 || linkType == 2 || linkType == 3) {
            linkOfRequiredType = true;
        }
        return linkOfRequiredType;
      }

      public int[] getUserDataCategories() {
        return userDataCategories;
      }

      public int getNumberOfUserObjects() {
        return 0;
      }

      public boolean isCurrentNodePartiallyExpanded(LODAnalysisInfo info) {
        return false;
      }

      public boolean isNextNodePartiallyExpanded(LODAnalysisInfo info) {
        return false;
      }

      public void reset() {
      }
      
      public void setNetworkAnalyst(NetworkAnalyst analyst) {
      }
    }
    
    private static class NodeTypeConstraint implements LODNetworkConstraint {
      private static int[] userDataCategories = {EUserDataIO.USER_DATA_DEFAULT_CATEGORY,
                                                 EUserDataIO.USER_DATA_CATEGORY_EXAMPLE};
      public NodeTypeConstraint () {
          
      }
      
      public boolean isSatisfied(LODAnalysisInfo analysisInfo) {
          boolean isNodeOfRequiredType = true;
          LogicalNetNode node = analysisInfo.getNextNode();
          int nodeType = (Integer) node.getCategorizedUserData().
                         getUserData(EUserDataIO.USER_DATA_CATEGORY_EXAMPLE).
                         get(EUserDataIO.USER_DATA_INDEX_NODETYPE);
          if (nodeType == 0) {
              isNodeOfRequiredType = false;
          }
          return isNodeOfRequiredType;
      }
      
      public int [] getUserDataCategories() {
         return userDataCategories;
      }
      
      public int getNumberOfUserObjects() {
          return 0;
      }
      
      public boolean isCurrentNodePartiallyExpanded(LODAnalysisInfo analysisInfo) {
         return false;   
      }
      
      public boolean isNextNodePartiallyExpanded(LODAnalysisInfo analysisInfo) {
         return false; 
      }
      
      public void reset() {
          
      }
      
      public void setNetworkAnalyst(NetworkAnalyst analyst) {
          
      }
    }
}
