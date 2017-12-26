package ndmtraffic;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import java.text.DecimalFormat;
import java.text.NumberFormat;

import oracle.spatial.network.lod.DefaultNodeCostCalculator;
import oracle.spatial.network.lod.DynamicLinkLevelSelector;
import oracle.spatial.network.lod.GeodeticCostFunction;
import oracle.spatial.network.lod.HeuristicCostFunction;
import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.LinkCostCalculator;
import oracle.spatial.network.lod.LinkLevelSelector;
import oracle.spatial.network.lod.NetworkIO;
import oracle.spatial.network.lod.LogicalSubPath;
import oracle.spatial.network.lod.PointOnNet;
import oracle.spatial.network.lod.util.PrintUtility;
import oracle.spatial.util.Logger;
import oracle.spatial.network.lod.NodeCostCalculator;

public class TemporalShortestPath
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

  private static int findNumIntervals(Connection conn,String networkName, int samplingId) {

      String queryStr = "SELECT num_time_intervals FROM NDM_TRAFFIC_METADATA "+
                        " WHERE upper(network_name)=? AND "+
                        " sampling_id = ?";
      int numIntervals=1;
      try {
          PreparedStatement stmt = conn.prepareStatement(queryStr);
          stmt.setString(1,networkName.toUpperCase());
          stmt.setInt(2,samplingId);
          ResultSet rs = stmt.executeQuery();
          rs.next();
          numIntervals = rs.getInt(1);
      }
      catch (Exception e) {
          e.printStackTrace();
      }
      return numIntervals;
  }
    
  public static void main(String[] args) throws Exception
  {
      String configXmlFile = "ndmtraffic/LODConfigs.xml";
      String logLevel      = "ERROR";  
      String dbUrl         = "jdbc:oracle:thin:@localhost:1521:orcl";
      String dbUser        = "";
      String dbPassword    = "";
      String networkName   = "NAVTEQ_SF";
      int linkLevel = 1;
     
      String inputStr = "10 September 2012 10:00 PM EST";
      String startOfPeriod = "12:00 AM";
      String endOfPeriod = "11:45 PM";
    
    //get input parameters
    for (int i=0; i<args.length; i++)   {
        if (args[i].equalsIgnoreCase("-dbUrl"))
            dbUrl = args[i+1];
        else if (args[i].equalsIgnoreCase("-dbUser"))
            dbUser = args[i+1];
        else if (args[i].equalsIgnoreCase("-dbPassword"))
            dbPassword = args[i+1];
        else if (args[i].equalsIgnoreCase("networkName"))
            networkName = args[i+1];
        else if (args[i].equalsIgnoreCase("-configXmlFile"))
            configXmlFile = args[i+1];
        else if (args[i].equalsIgnoreCase("-logLevel"))
            logLevel = args[i+1];
        else if (args[i].equalsIgnoreCase("-linkLevel"))
            linkLevel = Integer.parseInt(args[i+1]);
    }
    //   Sample pairs; can be used to illustrate change in routes with start time.
    /* 
     // NAVTEQ_SF
       long startNodeId = 199617234;
       long endNodeId   = 199833056;
       
       long startNodeId = 199478095;
       long endNodeId   = 199419635;

       long startNodeId = 199350914;
       long endNodeId   = 199526049;

       long startNodeId = 1494931509;
       long endNodeId   = 199397559;

       long startNodeId = 199641816;
       long endNodeId   = 199866414;

       long startNodeId = 199482306;
       long endNodeId   = 199708661;  

       long startNodeId = 199614560;
       long endNodeId   = 199365752;

       long startNodeId = 199478095;
       long endNodeId   = 199639482; 
       
       long startNodeId = 199380142;
       long endNodeId   = 199544379;
    */
    /*
       //ODF_NA_Q309
       long startNodeId = 106518386; 
       long endNodeId   = 119411350;
    
       long startNodeId = 106518386;
       long endNodeId = 106528175;
    
       long startNodeId = 106518386;
       long endNodeId = 106465512;
     
       long startNodeId = 106518386;
       long endNodeId =  106442953;

       long startNodeId = 106518386;
       long endNodeId = 1467412340;
     */ 
      long startNodeId = 199578917;
      long endNodeId   = 199883068;
      int xUserDataIndex = 0;
      int yUserDataIndex = 1;
      double costThreshold = 1550;
      double[] costThresholds = {costThreshold};
      int numHighLevelNeighbors = 8;
      double costMultiplier = 1.5;
      //This parameter indicates the sampling interval
      //1 : 15 minute
      //2 : 1 hour
      int samplingId = 1; 
      
    Connection conn    = null;

    // opening connection
    conn = LODNetworkManager.getConnection(dbUrl, dbUser, dbPassword);

    System.out.println("Network analysis for "+networkName);
    setLogLevel(logLevel);
    
    //load user specified LOD configuration (optional), 
    //otherwise default configuration will be used
    InputStream config = ClassLoader.getSystemResourceAsStream(configXmlFile);
    LODNetworkManager.getConfigManager().loadConfig(config);

    //NetworkMetadata metadata =LODNetworkManager.getNetworkMetadata(conn, networkName, networkName);

    //Load User Data IOs. Not needed. Use user data IO configuration from the config xml.
    //LODUserDataIO[] networkUDIOs = new LODUserDataIO[5];
    //networkUDIOs[0] = new LODUserDataIOSDO(conn, metadata, UserDataMetadata.DEFAULT_USER_DATA_CATEGORY);
    //networkUDIOs[1] = new RouterUserDataIO(conn, TemporalUserDataIO.USER_DATA_CATEGORY_TRUCKING, "trucking_user_data");
    //networkUDIOs[2] = new TemporalUserDataIO(conn, TemporalUserDataIO.USER_DATA_CATEGORY_TEMPORAL,"TP_USER_DATA");
    //networkUDIOs[3] = new LODUserDataIOSDO(conn, metadata, TemporalUserDataIO.USER_DATA_CATEGORY_FEATURE);
    //networkUDIOs[4] = new TrafficTimezoneUserDataIO(conn, TrafficTimezoneUserDataIO.USER_DATA_CATEGORY_TIMEZONE,"TP_TZ_USER_DATA");
     
    //get network input/output object
    networkIO = LODNetworkManager.getCachedNetworkIO(
                                    conn, networkName, networkName, null);
    //networkIO.setUserDataIOs(networkUDIOs);
   
    //get network analyst
    analyst = LODNetworkManager.getNetworkAnalyst(networkIO);
  
    try
    {
        System.out.println("*****BEGIN: testShortestDijkstra*****");
        
        //set traffic link cost calculator as the link cost calculator
        LinkCostCalculator [] oldlccs = analyst.getLinkCostCalculators();
        int numIntervals = findNumIntervals(conn,networkName,samplingId);
        LinkCostCalculator[] lccs = { new TrafficTimezoneLinkCostCalculator(inputStr,
                                                                    numIntervals)}; 
        analyst.setLinkCostCalculators(lccs);
        
        //Use default node cost calculator
        NodeCostCalculator[] nccs = {
            DefaultNodeCostCalculator.getNodeCostCalculator() };
        analyst.setNodeCostCalculators(nccs);
          
            
            PointOnNet startPoint = new PointOnNet(startNodeId);
            PointOnNet endPoint = new PointOnNet(endNodeId);
            
            LogicalSubPath subPath =
               analyst.shortestPathDijkstra(startPoint, endPoint, null);
            
            System.out.println("Shortest path for start time "+inputStr+" ::");
            System.out.println("Is the returned subpath a full path? "+subPath.isFullPath());
            PrintUtility.print(System.out, subPath, true, 100, 0);
            //Restoring link cost calculator to the default (link cost = link length)
            analyst.setLinkCostCalculators(oldlccs);
        
            System.out.println("*****END: testShortestPathDijkstra*****");
      }
      catch (Exception e)
      {
          e.printStackTrace();
      }    
  }  
}
