/* $Header: sdo/demo/network/examples/java/src/lod/drive_time_polygons/ConvexDriveTimePolygons.java /main/3 2012/12/10 11:18:29 begeorge Exp $ */

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
 *  @version $Header: sdo/demo/network/examples/java/src/lod/drive_time_polygons/ConvexDriveTimePolygons.java /main/3 2012/12/10 11:18:29 begeorge Exp $
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
import oracle.spatial.geocoder.client.ThinClientGeocoder;
import oracle.spatial.network.lod.LogicalSubPath;
import oracle.spatial.network.lod.SpatialSubPath;
import oracle.spatial.network.lod.util.JGeometryUtility;

public class ConvexDriveTimePolygons
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
  
public static void main(String[] args) throws Exception
  {
    String configXmlFile = "polygons/LODConfigs.xml";
    String logLevel    =    "ERROR"; 
        
    String dbUrl       = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser      = "";
    String dbPassword  = "";

    String networkName = "NAVTEQ_SF";

    double longitude = -122.45;
    double latitude = 37.7706;
    int linkLevel      = 1;  //default link level
    char drivingSide = 'R';
    String inputTableName = "TEST_INPUT_POINTS";
    String outputTableName = "TEST_OUTPUT_POLYGONS";
    //double costThreshold = 600;
    double costThreshold = 300;
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
        else if(args[i].equalsIgnoreCase("-inputTableName"))
           inputTableName = args[i+1];
        else if(args[i].equalsIgnoreCase("-outputTableName"))
            outputTableName = args[i+1];
        else if(args[i].equalsIgnoreCase("-costThreshold"))
            costThreshold = Double.parseDouble(args[i+1]);
      }
      
    JGeometry resultPolygon;
    
    // opening connection
    conn = LODNetworkManager.getConnection(dbUrl, dbUser, dbPassword);

    System.out.println("Network analysis for "+networkName);
    
    setLogLevel(logLevel);
    
    //load user specified LOD configuration (optional), 
    //otherwise default configuration will be used
    long t1 = System.currentTimeMillis();
    InputStream config = ClassLoader.getSystemResourceAsStream(configXmlFile);
    LODNetworkManager.getConfigManager().loadConfig(config);
    long t2 = System.currentTimeMillis();
    
    LODConfig c = LODNetworkManager.getConfigManager().getConfig(networkName);
    t1 = System.currentTimeMillis();
    NetworkMetadata metadata = LODNetworkManager.getNetworkMetadata(
                                    conn, networkName, networkName);
 
    //get network input/output object
    networkIO = LODNetworkManager.getCachedNetworkIO(
                                    conn, networkName, networkName, null);
    t2 = System.currentTimeMillis();
    System.out.println("Get Network IO : "+(t2-t1)/1000+" sec.");
    
    //get network analyst 
    analyst = LODNetworkManager.getNetworkAnalyst(networkIO);
      try
      {
/////////////////////////////////////////////////////////////////////////////////////////////////
        RouterDataSource routerDataSource = new RouterDataSource(dbUrl, dbUser, dbPassword, 3, 100);
        ArrayList<GeocoderAddress> inputAddresses = new ArrayList<GeocoderAddress>();  
          
        int numberOfRows = 0;
        String queryStr = "SELECT count(*) FROM "+inputTableName;
        PreparedStatement stmt = conn.prepareStatement(queryStr);
        ResultSet rs = stmt.executeQuery();
        if (rs.next())
          numberOfRows = rs.getInt(1);
        rs.close();
        stmt.close();
        System.out.println("Number of inputs = "+numberOfRows); 
        queryStr = "SELECT id, longitude, latitude FROM "+
                          inputTableName+ 
                          " ORDER BY id ";
        stmt = conn.prepareStatement(queryStr);
        rs = stmt.executeQuery();
        int[] ids = new int[numberOfRows];
        int iter=0;
        while (rs.next()) {
            int id = rs.getInt(1);
            longitude = rs.getDouble(2);
            latitude = rs.getDouble(3);
            ids[iter++] = id;
            GeocoderAddress geocoderAddress = new GeocoderAddress(longitude, latitude);  
            inputAddresses.add(geocoderAddress);
        }
        rs.close();
        stmt.close();
        
        System.out.println("*****BEGIN: testWithinCostPolygon*****");
        
        long startTime = System.currentTimeMillis();
        
        PointOnNet[][] points = Network.computeLoci(inputAddresses, drivingSide, routerDataSource, networkName);
        
        long endTime = System.currentTimeMillis();
        LinkCostCalculator[] oldlccs = analyst.getLinkCostCalculators();
        PreparedStatement stmt1 = null;
        ResultSet rs1 = null;
        STRUCT struct = null;
        String insertStr = "INSERT /*+ APPEND */ INTO "+ outputTableName +
                            " (id, type, cost_in_sec, polygon) "+
                         " VALUES (?, ?, ?, ?) ";
         
           
        System.out.println("** Start : Walking Polygons");
       
        //Link Cost Calculator computes link travel time based on walking speed
        LinkCostCalculator lcc = new WalkingSpeedLinkCostCalculator(3*1600/3600);
        // Constraint to exclude highways while walking
        ExcludeHighwaysConstraint constraint = new ExcludeHighwaysConstraint();
            
        startTime = System.currentTimeMillis();
        //ConvexPolygons convexPolygon = new ConvexPolygons(networkIO);
        for (int i=0; i<points.length; i++) {
          for (int j=0; j<1; j++) {
	    PointOnNet startPoint = points[i][j];
	    PointOnNet[] startPoints = {startPoint};
            
            // compute within cost concave polygon with link cost calculator lcc                                                           
            resultPolygon = computeConvexHull(conn, networkIO, startPoint, costThreshold, lcc);
            if (resultPolygon != null) {
                struct = JGeometry.store((JGeometry)resultPolygon, conn);
            }
            
            stmt1 = conn.prepareStatement(insertStr);
            stmt1.setInt(1, ids[i]);
            stmt1.setString(2, "WALK");
            stmt1.setDouble(3, costThreshold);
            stmt1.setObject(4, struct);
            rs1 = stmt1.executeQuery();
            conn.commit();
            rs1.close();
            stmt1.close();
            System.out.println((i+1)+"***");
            //String resultStr = resultPolygon.toStringFull();
            //System.out.println(resultStr);
            
         }
        }
        
        endTime = System.currentTimeMillis();
        System.out.println("Time taken to compute walking polygons = "+(endTime-startTime)/1000+" sec.");
        analyst.setLinkCostCalculators(oldlccs);
        System.out.println("** END : Walking Polygons");
        
        System.out.println("** Start : Driving Polygons"); 
        startTime = System.currentTimeMillis();
        //Link cost calculator computes travel time based on driving speed limit in link table 
        LinkCostCalculator lcc1 = new DrivingSpeedLinkCostCalculator();
        struct = null;
        stmt1 = null;
        rs1 = null;
        startTime = System.currentTimeMillis();
        for (int i=0; i<points.length; i++) {
           for (int j=0; j<1; j++) {
              long wicpStart = System.currentTimeMillis();
              PointOnNet startPoint = points[i][j];
              PointOnNet[] startPoints = {startPoint};
              //Compute polygon with link cost calculator lcc1                                              
              resultPolygon = computeConvexHull(conn, networkIO, startPoint, costThreshold, lcc1);
              if (resultPolygon != null) {
                  struct = JGeometry.store((JGeometry)resultPolygon, conn);
              }
              
              stmt1 = conn.prepareStatement(insertStr);
              stmt1.setInt(1, ids[i]);
              stmt1.setString(2, "DRIVE");
              stmt1.setDouble(3, costThreshold);
              stmt1.setObject(4, struct);
              rs1 = stmt1.executeQuery();
              conn.commit();
              long wicpEnd = System.currentTimeMillis();
              
              System.out.println((i+1)+"***"+(wicpEnd-wicpStart)/1000+" sec.");
              rs1.close();
              stmt1.close();
              //String resultStr = resultPolygon.toStringFull();
              //System.out.println(resultStr);
            }
          }
          endTime = System.currentTimeMillis();
          System.out.println("Time taken to compute driving polygons = "+(endTime-startTime)/1000+" sec.");
          analyst.setLinkCostCalculators(oldlccs);
        System.out.println("*****END: testWithinCostPolygon*****");

/////////////////////////////////////////////////////////////////////////////////////////////////

      }
      catch (Exception e)
      {
        e.printStackTrace();
      }

      if(conn!=null)
         try{conn.close();} catch(Exception ignore){}

  }

  public  static JGeometry computeConvexHull(Connection conn, NetworkIO networkIO,PointOnNet startPoint, double cost, LinkCostCalculator lcc) {
    JGeometry convexHull = null;
    double tolerance = 0.0005;
    try {
        JGeometry multiPointGeom = computeEndPoints(networkIO, startPoint, cost, lcc);
        
        String queryStr = "SELECT sdo_geom.sdo_convexhull(?, ?) "+
                          " FROM dual";
        PreparedStatement stmt = conn.prepareStatement(queryStr);
        STRUCT struct = JGeometry.store(multiPointGeom, conn);
        stmt.setObject(1, struct);
        stmt.setDouble(2, tolerance);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
           Object obj = rs.getObject(1);
           if (obj!=null) {
               convexHull = JGeometry.load((oracle.sql.STRUCT)obj);
           }
        }
    }
    catch (Exception e) {
        e.printStackTrace();
    }
    return convexHull;
  }
  
  private static JGeometry computeEndPoints(NetworkIO networkIO, PointOnNet startPoint, 
                                              double cost, LinkCostCalculator linkCostCalculator) {
      JGeometry pointsGeom = null;
      LogicalSubPath[] subPaths = null;
      try {
          NetworkAnalyst analyst = LODNetworkManager.getNetworkAnalyst(networkIO);
          LinkCostCalculator[] oldlccs = analyst.getLinkCostCalculators();
          LinkCostCalculator[] lccs = {linkCostCalculator};
          analyst.setLinkCostCalculators(lccs);
          PointOnNet[] startPoints = {startPoint};
          // compute trace out
          subPaths = analyst.traceOut(startPoints, cost, 1, 1, null, null, false);
       
          if (subPaths != null && subPaths.length>0) {
              SpatialSubPath[] spatialSubPaths = networkIO.readSpatialSubPaths(subPaths);
              ArrayList<double[]> pointArray = new ArrayList<double[]>();
              
              JGeometry geom = spatialSubPaths[0].getGeometry();
              int dim = geom.getDimensions();
              int srid = geom.getSRID();
              addPointToArray(geom, pointArray, dim, true);
              for (int i=0; i<spatialSubPaths.length; i++) {
                  geom = spatialSubPaths[i].getGeometry();
                  addPointToArray(geom, pointArray, dim, false);
              }
              double[][] points = pointArray.toArray(new double[0][]);
              pointsGeom = JGeometry.createMultiPoint(points, dim, srid);
          }
          analyst.setLinkCostCalculators(oldlccs);
      }
      catch (Exception e) {
          e.printStackTrace();
    }  
      return pointsGeom;
  }
    
  private static void addPointToArray(JGeometry geom, ArrayList<double[]> pointArray,
                                     int dim, boolean isStartPoint) {
    double[] endPoint = null;
    if(JGeometryUtility.isLineStringGeometry(geom))
    {
      double[] ordinates = geom.getOrdinatesArray();
      endPoint = new double[dim];
      int startIndex = 0;
      if(!isStartPoint)
        startIndex = ordinates.length-dim;
      System.arraycopy(ordinates, startIndex, endPoint, 0, dim);
    }
    else if(geom.isPoint())
    {
      endPoint = geom.getPoint();
    }
    pointArray.add(endPoint);
  }
}
