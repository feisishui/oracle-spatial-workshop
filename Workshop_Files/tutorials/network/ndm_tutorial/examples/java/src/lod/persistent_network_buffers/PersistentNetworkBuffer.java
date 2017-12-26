/* $Header: sdo/demo/network/examples/java/src/lod/persistent_network_buffers/PersistentNetworkBuffer.java /main/2 2012/12/10 11:18:29 begeorge Exp $ */

/* Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved. */

/*
   DESCRIPTION
    <short description of component this file declares/defines>

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    begeorge    04/12/12 - Creation
 */

/**
 *  @version $Header: sdo/demo/network/examples/java/src/lod/persistent_network_buffers/PersistentNetworkBuffer.java /main/2 2012/12/10 11:18:29 begeorge Exp $
 *  @author  begeorge
 *  @since   release specific (what release of product did this appear in)
 */

package nbuffer;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.LinkCostCalculator;
import oracle.spatial.network.lod.NetworkIO;
import oracle.spatial.network.lod.PointOnNet;
import oracle.spatial.network.lod.util.PrintUtility;
import oracle.spatial.util.Logger;
import oracle.spatial.network.lod.NetworkBuffer;
import oracle.spatial.network.lod.NodeCostCalculator;
import oracle.spatial.network.lod.config.ConfigManager;
import oracle.spatial.network.lod.config.LODConfig;

public class PersistentNetworkBuffer
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
             Statement stmt = conn.createStatement();
             String sqlStr = "SELECT COUNT(*) FROM TAB WHERE TNAME = '" + tableName.toUpperCase() + "'";
             ResultSet rs   = stmt.executeQuery(sqlStr); 
          
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
    //String configXmlFile = "LODConfigs.xml";
    String configXmlFile = "nbuffer/LODConfigs.xml";
    String logLevel    =   "ERROR";
        
    String dbUrl       = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser      = "";
    String dbPassword  = "";

    String networkName = "NAVTEQ_SF";

    long startNodeId = 199908767;
                       //1269694768, 199557397, 199470205, 199526589,
                       //199500278, 199919135,199838095, 199521037, 199613833;

    long linkId = 199038896;
    double percent = 0;
    int linkLevel      = 1;  //default link level
    double cost= 30*1600;    // 30 miles converted to meters
    //double cost = 30*60;   // 30 minutes converted to seconds
    String tableNamePrefix = "navteq_sf_30miles";
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
        else if(args[i].equalsIgnoreCase("-startNodeId"))
          startNodeId = Long.parseLong(args[i+1]);
        else if(args[i].equalsIgnoreCase("-cost:"))
          cost = Double.parseDouble(args[i]);
        else if(args[i].equalsIgnoreCase("-tableNamePrefix"))
          tableNamePrefix = args[i+1];
        else if(args[i].equalsIgnoreCase("-configXmlFile"))
          configXmlFile = args[i+1];
        else if(args[i].equalsIgnoreCase("-logLevel"))
          logLevel = args[i+1];
      }

      // opening connection
      conn = LODNetworkManager.getConnection(dbUrl, dbUser, dbPassword);

      Statement stmt = conn.createStatement();
    
      System.out.println("Network analysis for "+networkName);

      setLogLevel(logLevel);
    
      //load user specified LOD configuration (optional), 
      //otherwise default configuration will be used
      InputStream config = ClassLoader.getSystemResourceAsStream(configXmlFile);
      LODNetworkManager.getConfigManager().loadConfig(config);
      LODConfig c = LODNetworkManager.getConfigManager().getConfig(networkName);
      //get network input/output object
      networkIO = LODNetworkManager.getCachedNetworkIO(
                                    conn, networkName, networkName, null);
    
      //get network analyst
      analyst = LODNetworkManager.getNetworkAnalyst(networkIO);
  
      try
      {
        
        System.out.println("*****BEGIN: Network Buffer*****");
        
        PointOnNet[] startPoint = {new PointOnNet(startNodeId)};
        long startTime = System.currentTimeMillis();
        NetworkBuffer buffer = analyst.reachingNetworkBuffer(startPoint, cost, null);
        long t1 = System.currentTimeMillis();
        networkIO.writeNetworkBuffer(buffer, tableNamePrefix);
        long endTime = System.currentTimeMillis();
        System.out.println("Run times : "+" Total = "+(endTime-startTime) +" msec."+
                           " Analysis = "+(t1-startTime)+" msec."+" Persistence = "+
                           (endTime-t1)+" msec.");
         //PrintUtility.print(System.out, buffer, true, 20, 20, 0);
/*
        //Network Buffer computation with travel time as link cost

        LinkCostCalculator[] oldlccs = analyst.getLinkCostCalculators();
        LinkCostCalculator[]  lccs = {new LinkTravelTimeCalculator()};
        analyst.setLinkCostCalculators(lccs);
        PointOnNet[] startPoint = {new PointOnNet(startNodeId)};
        long startTime = System.currentTimeMillis();
        NetworkBuffer buffer = analyst.reachingNetworkBuffer(startPoint, cost, null);      
        long t1 = System.currentTimeMillis();
        networkIO.writeNetworkBuffer(buffer, tableNamePrefix);
        long endTime = System.currentTimeMillis();
        System.out.println("Run times : "+" Total = "+(endTime-startTime) +" msec."+
                           " Analysis = "+(t1-startTime)+" msec."+" Persistence = "+
                           (endTime-t1)+" msec.");
        //PrintUtility.print(System.out, buffer, true, 20, 20, 0);
        //Reset link cost calculator to default 
        analyst.setLinkCostCalculators(oldlccs);
*/
        System.out.println("*****END: Network Buffer");

/////////////////////////////////////////////////////////////////////////////////////////////////
      }
      catch (Exception e)
      {
        e.printStackTrace();
      }


    if(conn!=null)
      try{conn.close();} catch(Exception ignore){}

  }
}
