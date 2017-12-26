/* $Header: sdo/demo/network/examples/java/src/multimodal/MultimodalSPWithWalkConstraint.java /main/4 2012/12/10 11:18:29 begeorge Exp $ */

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
    begeorge    06/01/11 - Creation
 */

/**
 *  @version $Header: sdo/demo/network/examples/java/src/multimodal/MultimodalSPWithWalkConstraint.java /main/4 2012/12/10 11:18:29 begeorge Exp $
 *  @author  begeorge
 *  @since   release specific (what release of product did this appear in)
 */

package multimodalndm;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Vector;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;
import oracle.spatial.network.lod.DefaultNodeCostCalculator;
import oracle.spatial.network.lod.LODAnalysisInfo;
import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.LeveledNetworkCache;
import oracle.spatial.network.lod.LinkCostCalculator;
import oracle.spatial.network.lod.NetworkIO;
import oracle.spatial.network.lod.CachedNetworkIO;
import oracle.spatial.network.lod.LogicalSubPath;
import oracle.spatial.network.lod.PointOnNet;
import oracle.spatial.network.lod.util.PrintUtility;
import oracle.spatial.util.Logger;
import oracle.spatial.network.lod.LogicalLink;
import oracle.spatial.network.lod.LogicalNode;
import oracle.spatial.network.lod.NodeCostCalculator;
import oracle.spatial.network.lod.LODUserDataIO;
import oracle.spatial.network.lod.LODUserDataIOSDO;
import oracle.spatial.network.NetworkMetadata;
import oracle.spatial.network.UserDataMetadata;
import oracle.spatial.network.lod.DefaultLinkCostCalculator;
import oracle.spatial.network.lod.DummyNodeCostCalculator;
import oracle.spatial.network.lod.LODGoalNode;
import oracle.spatial.network.lod.LODNetworkConstraint;
import oracle.spatial.network.lod.LODNetworkException;
import oracle.spatial.network.lod.LeveledNetworkCache;
import oracle.spatial.network.lod.LogicalLightPath;
import oracle.spatial.network.lod.LogicalLightSubPath;
import oracle.spatial.network.lod.LogicalNetNode;
import oracle.spatial.network.lod.LogicalPath;
import oracle.spatial.network.lod.ConstraintOperator;
import oracle.spatial.network.lod.SpatialHeavyPath;
import oracle.spatial.network.lod.SpatialLink;
import oracle.spatial.network.apps.multimodal.MultimodalLinkCostCalculator;
import oracle.spatial.network.apps.multimodal.MultimodalNodeCostCalculator;
import oracle.spatial.network.apps.multimodal.MultimodalUserDataIO;
import oracle.spatial.network.apps.multimodal.MultimodalPrintUtility;
//import oracle.spatial.router.ndm.RouterUserDataIO;

/**
 *  @version $Header: sdo/demo/network/examples/java/src/multimodal/MultimodalSPWithWalkConstraint.java /main/4 2012/12/10 11:18:29 begeorge Exp $
 *  @author  begeorge
 *  @since   release specific (what release of product did this appear in)
 */
public class MultimodalSPWithWalkConstraint
{
  private static final NumberFormat formatter = new DecimalFormat("#.######");
  
  private static NetworkAnalyst analyst;
  private static CachedNetworkIO networkIO;
  private static final int[] userDataCategories = {0,1};
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

  public static Vector findNearestMMNodes(PointOnNet startLocation)  { 
     LogicalSubPath [] paths=null;
     LogicalSubPath startPath = null;
     Vector startPaths = new Vector();
     try {   
         NetworkAnalyst analyst = LODNetworkManager.getNetworkAnalyst(networkIO);
         String networkName = networkIO.getNetworkMetadata().getName();
         
         //Use default node cost calculator
         NodeCostCalculator[] nccs = {
             DefaultNodeCostCalculator.getNodeCostCalculator() };
         analyst.setNodeCostCalculators(nccs);
         //Use default link cost calculator
         LinkCostCalculator [] lccs ={
             DefaultLinkCostCalculator.getLinkCostCalculator()};
         analyst.setLinkCostCalculators(lccs);
         //Constraint for restructing links in withinCost computation to road links
         Vector linkTypes = new Vector();
         linkTypes.add(0);
         linkTypes.add(2);
         
         RestrictLinksToSpecifiedLinksConstraint roadLinksConstraint =
            new RestrictLinksToSpecifiedLinksConstraint(linkTypes);
         
         //Construct goal node filter; end nodes must be service nodes.
         GoalNodeFilter wcNodeFilter = new GoalNodeFilter();
         PointOnNet [] start = {startLocation};
         double distanceThreshold = 1000;
         paths = analyst.withinCost(start,distanceThreshold,1,1,roadLinksConstraint,wcNodeFilter,true);
         if (paths.length==0) {
             distanceThreshold=3000;
             paths = analyst.withinCost(start,distanceThreshold,1,1,roadLinksConstraint,wcNodeFilter, true);
         }
         
         if (paths.length==0) {
             return null;
         }
         
         double minStartCost = paths[0].getCosts()[0];
         int i=0;
         
         while (i < paths.length) {
             if (paths[i].getCosts()[0] == minStartCost) {
                 startPaths.add(paths[i]);
             }
             i++;
         }
     }
     catch (Exception e) {
         e.printStackTrace();
     }
     return startPaths;
  }
  
    public static Vector findNearestReachingMMNodes(PointOnNet endLocation) {
       LogicalSubPath [] paths=null;
       LogicalSubPath ePath = null;
       Vector endPaths = new Vector();
       try {                                     
           NetworkAnalyst analyst = LODNetworkManager.getNetworkAnalyst(networkIO);
           String networkName = networkIO.getNetworkMetadata().getName();
           
           //Use default node cost calculator
           NodeCostCalculator[] nccs = {
               DefaultNodeCostCalculator.getNodeCostCalculator() };
           analyst.setNodeCostCalculators(nccs);
           //Use default link cost calculator
           LinkCostCalculator [] lccs ={
               DefaultLinkCostCalculator.getLinkCostCalculator()}; 
           analyst.setLinkCostCalculators(lccs);
           //Constraint for restructing links in withinCost computation to road links
           Vector linkTypes = new Vector();
           linkTypes.add(0);
           linkTypes.add(2);
           
           RestrictLinksToSpecifiedLinksConstraint roadLinksConstraint =
              new RestrictLinksToSpecifiedLinksConstraint(linkTypes);
           
           //Construct goal node filter; end nodes must ne service nodes.
           GoalNodeFilter wcNodeFilter = new GoalNodeFilter();
           double distanceThreshold = 1000;
           
           paths = analyst.withinReachingCost(endLocation,distanceThreshold,roadLinksConstraint,
                                              wcNodeFilter);
           if (paths.length==0) {
               //increase threshold to 3000
               distanceThreshold=3000;
               paths = analyst.withinCost(endLocation,distanceThreshold,roadLinksConstraint,wcNodeFilter);
           }
           
           if (paths.length==0) {
               return null;
           }
            double minEndCost = paths[0].getCosts()[0];
            int i=0;
            
            while (i < paths.length) {
                if (paths[i].getCosts()[0] == minEndCost) {
                    endPaths.add(paths[i]);
                }
                i++;
            }
       }
       catch (Exception e) {
           e.printStackTrace();
       }
       return endPaths;
    }
  
    public static class GoalNodeFilter implements LODGoalNode {
        public GoalNodeFilter () {  
        }
        //End nodes must be service nodes
        public boolean isGoal(LogicalNetNode node) {
           boolean isNodeServiceNode = false;
           if (node == null) {
               return true;
           }
           if (node.getCategorizedUserData().
               getUserData(MultimodalUserDataIO.USER_DATA_CATEGORY_MULTIMODAL) == null) {
               isNodeServiceNode = false;
           }
           else {
               isNodeServiceNode =  true; 
           }
          return isNodeServiceNode;
        }
        
        public int[] getUserDataCategories() {
            return userDataCategories;
        }
        
        public void setNetworkAnalyst(NetworkAnalyst analyst) {
            
        }
    }
   
    public static boolean  isNodeAServiceNode(Connection conn, String networkName,
                                              long nodeId) {
        
        String origNetworkName = networkName.substring(0,(networkName.length()-3));
        String serviceNodeTable = networkName+"_SERVICE_NODE$";
        boolean isServiceNode = false;
        //String serviceNodeTable = "NAVTEQ_DC_SERVICE_NODE$";
        String sqlStr = "SELECT service_node_table_name FROM "+
                        " ndm_multimodal_metadata " + " WHERE "+
                        " upper(network_name) = ?";
        String queryStr = "SELECT count(*) FROM "+serviceNodeTable+
                          " WHERE node_id = ?";
        try {
            PreparedStatement pStmt = conn.prepareStatement(sqlStr);
            pStmt.setString(1, networkName.toUpperCase());
            ResultSet rs1 = pStmt.executeQuery();
            rs1.next();
            serviceNodeTable = rs1.getString(1);
            rs1.close();
            pStmt.close();

            PreparedStatement stmt = conn.prepareStatement(queryStr);
            stmt.setLong(1,nodeId);
            ResultSet rs = stmt.executeQuery();
            rs.next();
            int nCount = rs.getInt(1);
            if (nCount == 0) 
                isServiceNode = false;
            else
                isServiceNode = true;
            rs.close();
            stmt.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return isServiceNode;
    }  
 
 private static class RestrictLinksToSpecifiedLinksConstraint implements LODNetworkConstraint {
    Vector requiredLinkTypes = new Vector();
    public RestrictLinksToSpecifiedLinksConstraint (Vector linkTypesVector) {
        requiredLinkTypes.addAll(linkTypesVector);
    }
    
    public boolean isSatisfied(LODAnalysisInfo info) {
        boolean isLinkRoadlink = false;
        LogicalLink currentLink = info.getCurrentLink();
        
        if (currentLink == null) {
            return true;
        }
        int linkType = (Integer)currentLink.getCategorizedUserData().
                                    getUserData(MultimodalUserDataIO.USER_DATA_CATEGORY_MULTIMODAL).
                                    get(MultimodalUserDataIO.USER_DATA_INDEX_LINK_TYPE);
        isLinkRoadlink = requiredLinkTypes.contains(linkType);
        return isLinkRoadlink;
    }
    
    public boolean isCurrentNodePartiallyExpanded(LODAnalysisInfo info)
    {
       return false;
    }
    
    public boolean isNextNodePartiallyExpanded(LODAnalysisInfo info)
    {
       return false;
    }
    
    public int getNumberOfUserObjects() {
        return 0;
    }
    
    public int [] getUserDataCategories() {
        return userDataCategories;
    }
    
    public void setNetworkAnalyst(NetworkAnalyst analyst) {
        
    }
    
    public void reset() {
        
    }
}
  
 public static void main(String[] args) throws Exception
  {
    String configXmlFile = "LODConfigs.xml";
    String logLevel      = "ERROR";          
    SimpleDateFormat dFormat = new SimpleDateFormat("dd MMM yyyy HH:mm a"); 
    SimpleDateFormat finalFormat = new SimpleDateFormat("dd MMM yyyy HH:mm:ss a");
    TimeZone est = TimeZone.getTimeZone("US/Eastern");
    //Change these parameters suitably.
    String dbUrl       = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser      = "";
    String dbPassword  = "";
    String networkName = "NAVTEQ_DC_MM";
    
    long startNodeId     = 575590084;//781778295; //575645605; //575583025;//930171834; //575482278
    long endNodeId       = 575463159;//575569387; //575610791; //575571237;//575630552; //575657351
    int linkLevel        = 1;        // default link level
    
    Connection conn    = null;
    
    for(int i=0; i<args.length; i++) {
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


    //opening connection
    conn = LODNetworkManager.getConnection(dbUrl, dbUser, dbPassword);

    //get input parameters
    System.out.println("Network analysis for "+networkName);

    setLogLevel(logLevel);
    
    //load user specified LOD configuration (optional), 
    //otherwise default configuration will be used
    InputStream config = ClassLoader.getSystemResourceAsStream(configXmlFile);
    LODNetworkManager.getConfigManager().loadConfig(config);
    
    //Loading User Data
    NetworkMetadata metadata = LODNetworkManager.getNetworkMetadata(conn,networkName,networkName);
    LODUserDataIO [] networkUDIOs = new LODUserDataIO[2];
    networkUDIOs[0] = new LODUserDataIOSDO(conn,metadata,UserDataMetadata.DEFAULT_USER_DATA_CATEGORY);
    networkUDIOs[1] = new MultimodalUserDataIO(conn,MultimodalUserDataIO.USER_DATA_CATEGORY_MULTIMODAL,
                                              "NAVTEQ_DC_MM_USER_DATA");
    
    //get network input/output object
    networkIO = LODNetworkManager.getCachedNetworkIO(
                                    conn,networkName,networkName,metadata,networkUDIOs);

    //get network analyst
    analyst = LODNetworkManager.getNetworkAnalyst(networkIO);
    //LeveledNetworkCache cache = networkIO.getNetworkCache();
    try
    {
        String startTimeStr = "7 March 2011 10:00 AM";
        
        long initialStartTime = System.currentTimeMillis();
        
        
        //find MM start node id
        double costThreshold = 1000;
        boolean driveToStartNode = false;
        double speedLimitToStart = 1.333;
        
        double distanceToStartNode = 0;
        long mmStartNodeId = startNodeId;
        //printCache(cache); 
        long startRunTime = System.currentTimeMillis();
        preloadAllPartitions(networkIO, 2, true);
        long endRunTime = System.currentTimeMillis();
        System.out.println("Preload time = "+(endRunTime-startRunTime)+" milliseconds.");
        
        startRunTime = System.currentTimeMillis();
        Vector startingPaths = findNearestMMNodes(new PointOnNet(startNodeId));
        endRunTime = System.currentTimeMillis();
        
        if (startingPaths==null) {
                throw new LODNetworkException("No close by bus/train nodes to the start location; " +
                                              "Increase threshold!!");
        }
       
        startRunTime = System.currentTimeMillis();
        long singleStartNode = 0;
        Vector startPointsVector = new Vector();
        for (int i=0; i<startingPaths.size(); i++) {
            LogicalLightPath refPath = null;
            double startPercentage;
            long lastLinkId;
            if (startingPaths.elementAt(i) instanceof LogicalSubPath)
            {
                refPath = ((LogicalSubPath) startingPaths.elementAt(i)).getReferencePath();
            }
            else
            {
                refPath = ((LogicalLightSubPath) startingPaths.elementAt(i)).getReferenceLightPath();
            }
            if (((LogicalSubPath) startingPaths.elementAt(i)).getEndPercentage() != 1) { 
                startPercentage = ((LogicalSubPath) startingPaths.elementAt(i)).getEndPercentage();
                lastLinkId = refPath.getLastLinkId();
                startPointsVector.add(new PointOnNet(lastLinkId,startPercentage));
            }
            else {
                mmStartNodeId = refPath.getEndNodeId();
                startPointsVector.add(new PointOnNet(mmStartNodeId));
            }
            singleStartNode = mmStartNodeId;
            distanceToStartNode = ((LogicalSubPath) startingPaths.elementAt(i)).getCosts()[0];  
        }
        endRunTime = System.currentTimeMillis();
        //Checking whether the start node is a service node
        // In that case, it is added to the set of startPoints
        if (isNodeAServiceNode(conn,networkName,startNodeId)) {
            startPointsVector.add(new PointOnNet(startNodeId));
        }
        
        boolean driveFromEndNode = false;
        long mmEndNodeId = endNodeId;
        double distanceFromEndNode = 0;
        
        //Finding the nearest reaching nodes
        costThreshold = 1000;
        double speedLimitFromEnd = 1.333;
        startRunTime = System.currentTimeMillis();  
        Vector endingPaths = findNearestReachingMMNodes(new PointOnNet(endNodeId));
        endRunTime = System.currentTimeMillis();
        
        startRunTime = System.currentTimeMillis();
        long singleEndNode = 0;
        Vector endPointsVector = new Vector();
        for (int i=0; i<endingPaths.size(); i++) {  
            if (endingPaths == null){
                throw new LODNetworkException("No close by bus/train nodes to the end location; " +
                                            "Increase threshold!!");
            }
        
            LogicalLightPath refPath = null;
            if ((LogicalSubPath)endingPaths.elementAt(i) instanceof LogicalSubPath)
                refPath = ((LogicalSubPath)endingPaths.elementAt(i)).getReferencePath();
            else
                refPath = ((LogicalLightSubPath)endingPaths.elementAt(i)).getReferenceLightPath();
            if (((LogicalSubPath)endingPaths.elementAt(i)).getStartPercentage() != 0) { 
                double startPercentage = ((LogicalSubPath)endingPaths.elementAt(i)).getStartPercentage();
                long firstLinkId = refPath.getFirstLinkId();
                endPointsVector.add(new PointOnNet(firstLinkId,startPercentage));
            }
            else {
                mmEndNodeId = refPath.getStartNodeId();
                endPointsVector.add(new PointOnNet(mmEndNodeId));
            }
            distanceFromEndNode = ((LogicalSubPath)endingPaths.elementAt(0)).getCosts()[0];
            singleEndNode = mmEndNodeId;
            if (distanceFromEndNode > 1000) {
                driveFromEndNode = true;
            }
        }
        endRunTime = System.currentTimeMillis();
        System.out.println("Finding end service nodes = "+(endRunTime-startRunTime)+" milliseconds.");
        //Checking whether the end node is a service node
        // In that case, it is added to the set of endPoints
        if (isNodeAServiceNode(conn,networkName,endNodeId)) {
            endPointsVector.add(new PointOnNet(endNodeId));
            distanceFromEndNode = 0;
        }
        
        // Modifying start time; adding the time to reach the bus stop
        long timeToStartLoc = Math.round(distanceToStartNode/speedLimitToStart);
        Date startTime = dFormat.parse(startTimeStr);
        
        //Computing the travel 
        Calendar cStartTime = Calendar.getInstance(est,Locale.US);
        cStartTime.setTime(startTime);
    
        //Find the time to reach starting service node from the start node
        int numHours = ((int) timeToStartLoc)/(60*60);
        int numMinutes =(((int) timeToStartLoc)/60)-(numHours*60);
        int numSeconds = (int)(Math.round(timeToStartLoc - (numHours*60*60)-(numMinutes*60)));
        
        //Add the time to the given start time
        cStartTime.add(Calendar.HOUR,numHours);
        cStartTime.add(Calendar.MINUTE,numMinutes);
        cStartTime.add(Calendar.SECOND,numSeconds);
        
        int dayOfWeek = cStartTime.get(Calendar.DAY_OF_WEEK);
        int nodeScheduleIndex = MultimodalNodeCostCalculator.findNodeScheduleIndex(cStartTime);
        System.out.println("Day : "+dayOfWeek+" Node schedule index for "+startTimeStr+" is "+nodeScheduleIndex);
        
        String mmStartTimeStr = finalFormat.format(cStartTime.getTime());
        
        System.out.println("START TIME:"+mmStartTimeStr);
        
        //Set node cost calculator to multimodal node cost calculator
        NodeCostCalculator [] oldnccs = analyst.getNodeCostCalculators();
        NodeCostCalculator [] nccs = {new MultimodalNodeCostCalculator(mmStartTimeStr),
                                      new DummyNodeCostCalculator()};
        analyst.setNodeCostCalculators(nccs);
          
        //Set link cost calculator to multimodal link costcalculator
        int transferPenalty = 5;
        LinkCostCalculator [] oldlccs = analyst.getLinkCostCalculators();
        LinkCostCalculator[] lccs = {new MultimodalLinkCostCalculator(),
                                     new TransferLinkLengthCalculator()};
        analyst.setLinkCostCalculators(lccs);
            
        //Formulating link constraint
        Vector linkTypes = new Vector();
        linkTypes.add(1);
        linkTypes.add(3);
        RestrictLinksToSpecifiedLinksConstraint mmLinksConstraint = 
                    new RestrictLinksToSpecifiedLinksConstraint(linkTypes);

        PointOnNet [] startPoints = new PointOnNet[startPointsVector.size()];
        startPointsVector.toArray(startPoints);
        PointOnNet [] endPoints = new PointOnNet[endPointsVector.size()];
        endPointsVector.toArray(endPoints);
        startRunTime = System.currentTimeMillis();
        
        double maxWalkDistance = 50;
        System.out.println("Imposing Max Walk Distance (= "+maxWalkDistance+
                           " meters) Constraint..");
        
        RestrictWalkConstraint walkConstraint = 
                                         new RestrictWalkConstraint(maxWalkDistance);
        LODNetworkConstraint[] constraintArray = {mmLinksConstraint, walkConstraint};
        LODNetworkConstraint combinedConstraint = ConstraintOperator.and(constraintArray);
        LogicalSubPath subPath = analyst.shortestPathDijkstra(startPoints,endPoints,1,combinedConstraint);
        if (subPath == null) {
              System.out.println("No path exists!!");
        }
        else {
            LogicalLightPath lPath = subPath.getReferenceLightPath();
            LogicalPath fullPath = subPath.getReferencePath();
            LogicalLink [] lLinks = networkIO.readLogicalLinks(fullPath.getLinkIds(), true);
            System.out.println("Number of links = "+ lLinks.length);
            /*
            if (((LogicalPath) lPath).getLinkIds().length > 0) {
                PrintUtility.print(System.out, subPath, true, 100, 0);
            }
            */
            MultimodalPrintUtility.print(conn,networkIO,System.out,networkName,fullPath,
                                             distanceToStartNode,driveToStartNode,
                                             distanceFromEndNode,driveFromEndNode,
                                             mmStartTimeStr.substring(11,20),
                                             transferPenalty, nodeScheduleIndex,60);
            System.out.println("Primary Cost = "+subPath.getCosts()[0]+"\n"+
                               "Secondary Cost = "+subPath.getCosts()[1]);
        }
        
        System.out.println("*** Without Max Walk Distance Constraint ***");
        subPath = analyst.shortestPathDijkstra(startPoints,endPoints,1,mmLinksConstraint);
          if (subPath == null) {
                System.out.println("No path exists!!");
          }
          else {
              LogicalLightPath lPath = subPath.getReferenceLightPath();
              LogicalPath fullPath = subPath.getReferencePath();
              LogicalLink [] lLinks = networkIO.readLogicalLinks(fullPath.getLinkIds(), true);
              System.out.println("Number of links = "+ lLinks.length);
              /*
              if (((LogicalPath) lPath).getLinkIds().length > 0) {
                  PrintUtility.print(System.out, subPath, true, 100, 0);
              }
              */
              MultimodalPrintUtility.print(conn,networkIO,System.out,networkName,fullPath,
                                               distanceToStartNode,driveToStartNode,
                                               distanceFromEndNode,driveFromEndNode,
                                               mmStartTimeStr.substring(11,20),
                                               transferPenalty, nodeScheduleIndex,60);
              System.out.println("Primary Cost = "+subPath.getCosts()[0]+"\n"+
                                 "Secondary Cost = "+subPath.getCosts()[1]);
          }
        
        
        analyst.setNodeCostCalculators(oldnccs);    
        analyst.setLinkCostCalculators(oldlccs);
      }
      catch (Exception e)
      {
          e.printStackTrace();
      }    
   }
 
    //static void printCache(LeveledNetworkCache cache) throws Exception {
    //  System.out.println("\nCurrent Network Partition Cache:");
    //  for (int linkLevel = 1; linkLevel <= cache.getNumberOfLinkLevels();
    //       linkLevel++)
    //    System.out.println("\tLinkLevel: " + linkLevel + " contains " +
    //                       cache.getNumberOfPartitions(linkLevel) +
    //                       " partition(s)...");
    //  System.out.println("\n");
    //}
    
    static void preloadAllPartitions(CachedNetworkIO networkIO,
                                     int noOfLinkLevels,
                                     boolean readFromBlob) throws Exception {


      for (int linkLevel = 1; linkLevel <= noOfLinkLevels; linkLevel++) {
        // find out partition IDs on a linklevel
        int[] pids = networkIO.readPartitionIds(linkLevel);
        int[] userDataCategories = { 0,1 }; // userdata categories = 0, 1, 2 

        if (pids == null || pids.length == 0) { // whole network partition blob cases
          int pid = 0; // default partition Id for whole network partition blob
          networkIO.readLogicalPartition(pid, linkLevel, userDataCategories,
                                         readFromBlob);

        } else {
          networkIO.readLogicalPartitions(linkLevel, userDataCategories,
                                          readFromBlob);
        }

      }

    }
}
