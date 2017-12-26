/* $Header: sdo/demo/network/examples/java/src/lod/drive_time_polygons/WCPolygonsWithAddressInput.java /main/3 2012/12/10 11:18:29 begeorge Exp $ */

/* Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved. */

/*
   DESCRIPTION
    <short description of component this file declares/defines>

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    begeorge    02/24/12 - Creation
 */

/**
 *  @version $Header: sdo/demo/network/examples/java/src/lod/drive_time_polygons/WCPolygonsWithAddressInput.java /main/3 2012/12/10 11:18:29 begeorge Exp $
 *  @author  begeorge
 *  @since   release specific (what release of product did this appear in)
 */

package polygons;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import oracle.sql.STRUCT;
import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.LinkCostCalculator;
import oracle.spatial.network.lod.NetworkIO;
import oracle.spatial.network.lod.PointOnNet;
import oracle.spatial.util.Logger;
import oracle.spatial.network.lod.config.LODConfig;
import oracle.spatial.geocoder.client.GeocoderAddress;
import oracle.spatial.router.engine.Network;
import oracle.spatial.router.util.RouterDataSource;
import oracle.spatial.network.NetworkMetadata;
import oracle.spatial.geometry.JGeometry;

public class WCPolygonsWithAddressInput
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

  private static boolean tableExists(Connection conn, String tableName)
  {
       boolean result = false;
       try {
             String sqlStr = "SELECT COUNT(*) FROM TAB WHERE TNAME = '" + tableName.toUpperCase() + "'";
             PreparedStatement stmt = conn.prepareStatement(sqlStr);
             ResultSet rs   = stmt.executeQuery();

             if ( rs.next() ) {
                int no = rs.getInt(1);
             if ( no != 0 )
                result = true;
             }
            rs.close();
            stmt.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return result;
  }
  
public static void main(String[] args) throws Exception
  {
    String configXmlFile = "polygons/LODConfigs.xml";
    String logLevel    =    "ERROR"; 
    
    String dbUrl       = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser      = "";
    String dbPassword  = "";
    String networkName = "NAVTEQ_SF";

    String outputTableName = "TEST_OUTPUT_POLYGONS";
    int linkLevel      = 1;  //default link level
    char drivingSide = 'R';    
    double costThreshold = 300;  // 600;
    
    //String inputString = "29 Andres Bello, Mexico City,  Mexico, 11560" ;
    String inputString = "1940 Taraval St, San Francisco, United States, 94116";
    // String inputString = "3643 Balboa St, 94121";
    // String inputString = "29 Andres Bello, Mexico City,  Mexico, 11560";
    //String inputString  ="70 Av. Juarez Colonia Centro, Mexico City, Mexico, 06010";
    //String inputString = "-703632040@1.0";
    
    Connection conn = null;
    
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
       else if(args[i].equalsIgnoreCase("-outputTableName"))
          outputTableName = args[i+1];
       else if(args[i].equalsIgnoreCase("-costThreshold"))
          costThreshold = Double.parseDouble(args[i+1]);
       else if(args[i].equalsIgnoreCase("-inputString"))
          inputString = args[i+1];
    }
    JGeometry resultPolygon;  
    // opening connection
    conn = LODNetworkManager.getConnection(dbUrl, dbUser, dbPassword);

    System.out.println("Network analysis for "+networkName);

    InputStream config = ClassLoader.getSystemResourceAsStream(configXmlFile);
    LODNetworkManager.getConfigManager().loadConfig(config);

    LODConfig c = LODNetworkManager.getConfigManager().getConfig(networkName);
    long t1 = System.currentTimeMillis();
    NetworkMetadata metadata = LODNetworkManager.getNetworkMetadata(
                                    conn, networkName, networkName);
    
    //get network input/output object
    networkIO = LODNetworkManager.getCachedNetworkIO(
                                    conn, networkName, networkName, null);
    long t2 = System.currentTimeMillis();
      System.out.println("Network IO time "+(t2-t1)/1000+" sec.");
      analyst = LODNetworkManager.getNetworkAnalyst(networkIO);

     try {
       InputParser parser = new InputParser(dbUrl, dbUser, dbPassword, networkName, networkIO);
       parser.init();

       LinkCostCalculator[] oldlccs = analyst.getLinkCostCalculators();

       InputParser.Locations locations = parser.parseInputLocations(inputString);
       PointOnNet[][] points = locations.getPoints();
    
       PreparedStatement stmt1 = null;
       ResultSet rs1 = null;
       STRUCT struct = null;
       String insertStr = "INSERT /*+ APPEND */ INTO "+ outputTableName +
                          " (id, type, cost_in_sec, polygon) "+
                          " VALUES (?, ?, ?, ?) ";
       
       System.out.println("** Start : Walking Polygons");
       long startTime = System.currentTimeMillis();
       LinkCostCalculator[] lccs = {new WalkingSpeedLinkCostCalculator(3*1600/3600)};
       // Constraint to exclude highways while walking
       ExcludeHighwaysConstraint constraint = new ExcludeHighwaysConstraint();
       //Set link cost to link travel time = link length/walking speed
       analyst.setLinkCostCalculators(lccs);
       int iter = 1;
        for (int i=0; i<points.length; i++) {
           for (int j=0; j<points[i].length; j++) {
               long wicpStart = System.currentTimeMillis();
               PointOnNet startPoint = points[i][j];
               PointOnNet[] startPoints = {startPoint};

               // compute within cost concave polygon
               resultPolygon = analyst.withinCostPolygon(startPoints,
                                      costThreshold, constraint, null);
               if (resultPolygon != null) {
                   struct = JGeometry.store((JGeometry)resultPolygon, conn);
               }
               
               stmt1 = conn.prepareStatement(insertStr);
               stmt1.setInt(1, iter++);
               stmt1.setString(2, "WALK");
               stmt1.setDouble(3, costThreshold);
               stmt1.setObject(4, struct);
               rs1 = stmt1.executeQuery();
               conn.commit();
               long wicpEnd = System.currentTimeMillis();
               System.out.println((i+1)+"***"+(wicpEnd-wicpStart)/1000+" sec.");
               //String resultStr = resultPolygon.toStringFull();
               //System.out.println(resultStr);
               rs1.close();
               stmt1.close();
           }
        }
        long endTime = System.currentTimeMillis();
        System.out.println("Time taken to compute walking polygons = "+(endTime-startTime)/1000+" sec.");
        analyst.setLinkCostCalculators(oldlccs);
        System.out.println("** End : Walking Polygons");
        
        System.out.println("** Start : Driving Polygons"); 
        startTime = System.currentTimeMillis();
        //Link cost calculator computes travel time based on driving speed limit in link table 
        LinkCostCalculator[] lccs1 = {new DrivingSpeedLinkCostCalculator()};
        // Set link cost calculator to compute link travel time
        analyst.setLinkCostCalculators(lccs1);
        struct = null;
        stmt1 = null;
        rs1 = null;
        startTime = System.currentTimeMillis();
        iter = 1;
        for (int i=0; i<points.length; i++) {
           for (int j=0; j<points[i].length; j++) {
              long wicpStart = System.currentTimeMillis();
              PointOnNet startPoint = points[i][j];
              PointOnNet[] startPoints = {startPoint};
              
                                                                             
              resultPolygon = analyst.withinCostPolygon(startPoints,
                                     costThreshold, null, null);
              if (resultPolygon != null) {
                  struct = JGeometry.store((JGeometry)resultPolygon, conn);
              }
              
              stmt1 = conn.prepareStatement(insertStr);
              stmt1.setInt(1, iter++);
              stmt1.setString(2, "DRIVE");
              stmt1.setDouble(3, costThreshold);
              stmt1.setObject(4, struct);
              rs1 = stmt1.executeQuery();
              conn.commit();
              long wicpEnd = System.currentTimeMillis();
              //String resultStr = resultPolygon.toStringFull();
              //System.out.println(resultStr);
              System.out.println((i+1)+"***"+(wicpEnd-wicpStart)/1000+" sec.");
              rs1.close();
              stmt1.close();
            }
          }
          endTime = System.currentTimeMillis();
          System.out.println("Time taken to compute driving polygons = "+(endTime-startTime)/1000+" sec.");
          analyst.setLinkCostCalculators(oldlccs);
        System.out.println("*****END: testWithinCostPolygon*****");
        
    }
    catch (Exception e)
    {
        e.printStackTrace();
    }
  }
}
