/* $Header: sdo/demo/network/examples/java/src/lod/PrecomputeConnectedComponents.java /main/5 2012/12/10 11:18:29 begeorge Exp $ */

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
    hgong       02/27/07 - Creation
 */

/**
 *  @version $Header: sdo/demo/network/examples/java/src/lod/PrecomputeConnectedComponents.java /main/5 2012/12/10 11:18:29 begeorge Exp $
 *  @author  hgong   
 *  @since   11gR1
 */


package lod;

import java.io.InputStream;

import java.sql.SQLException;

import oracle.jdbc.OracleConnection;

import oracle.jdbc.pool.OracleDataSource;

import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.LODNetworkWrapper;
import oracle.spatial.network.lod.LogicalPartition;
import oracle.spatial.network.lod.NetworkIO;
import oracle.spatial.network.lod.util.PrintUtility;
import oracle.spatial.util.Logger;

/**
 *  This class demonstrates how to generate or regenerate partition BLOBs using
 *  LOD java API. If your database version is 11gR1 and above, please do NOT
 *  use this example, but use the following PLSQL function instead:
 *    - SDO_NET.FIND_CONNECTED_COMPONENTS.
 *  
 *  Note that LOD java API does not provide methods to create connected 
 *  component tables or to update the network metadata in the database, nor does
 *  it provides methods to clean up previously computed connected compnent information, 
 *  therefore, the caller of the LOD partition BLOB generation methods must 
 *  ensure that the connected component tables already exist in the database, and
 *  the network metadata already points to the correction connected component
 *  table. If there previously computed connected component information stored
 *  in the component table, the caller must manually delete previous results 
 *  before running this program.
 *  
 *  @version $Header: sdo/demo/network/examples/java/src/lod/PrecomputeConnectedComponents.java /main/5 2012/12/10 11:18:29 begeorge Exp $
 *  @author  hgong
 *  @since   11gR1
 */
public class PrecomputeConnectedComponents
{
  private static void setLogLevel(String logLevel)
  {
    if("FATAL".equalsIgnoreCase(logLevel))
        LODNetworkWrapper.setLoggingLevel(LODNetworkWrapper.LEVEL_FATAL);
    else if("ERROR".equalsIgnoreCase(logLevel))
        LODNetworkWrapper.setLoggingLevel(LODNetworkWrapper.LEVEL_ERROR);
    else if("WARN".equalsIgnoreCase(logLevel))
        LODNetworkWrapper.setLoggingLevel(LODNetworkWrapper.LEVEL_WARN);
    else if("INFO".equalsIgnoreCase(logLevel))
        LODNetworkWrapper.setLoggingLevel(LODNetworkWrapper.LEVEL_INFO);
    else if("DEBUG".equalsIgnoreCase(logLevel))
        LODNetworkWrapper.setLoggingLevel(LODNetworkWrapper.LEVEL_DEBUG);
    else if("FINEST".equalsIgnoreCase(logLevel))
        LODNetworkWrapper.setLoggingLevel(LODNetworkWrapper.LEVEL_FINEST);
    else  //default: set to ERROR
        LODNetworkWrapper.setLoggingLevel(LODNetworkWrapper.LEVEL_ERROR);
  }

  public static OracleConnection getConnection(String dbURL,
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
  
  public static void main(String[] args)
  {
    String configXmlFile    = "lod/LODConfigs.xml";
    String logLevel    = "ERROR";
    
    String dbUrl       = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser      = "";
    String dbPassword  = "";

    String networkName    = "HILLSBOROUGH_NETWORK";
    String componentTable = "HILLSBOROUGH_NETWORK_COMP$";
    int linkLevel         = 1;
    
    OracleConnection conn = null;
    
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
      else if(args[i].equalsIgnoreCase("-componentTable"))
        componentTable = args[i+1];
      else if(args[i].equalsIgnoreCase("-linkLevel"))
        linkLevel = Integer.parseInt(args[i+1]);
      else if(args[i].equalsIgnoreCase("-configXmlFile"))
        configXmlFile = args[i+1];
      else if(args[i].equalsIgnoreCase("-logLevel"))
        logLevel = args[i+1];
    }
    
    System.out.println("Precompute connected components for "+networkName);
    try{
      setLogLevel(logLevel);
      
      //load user specified LOD configuration (optional), 
      //otherwise default configuration will be used
      InputStream config = ClassLoader.getSystemResourceAsStream(
                             configXmlFile);
      LODNetworkManager.getConfigManager().loadConfig(config);

      //get jdbc connection 
      conn = getConnection(dbUrl, dbUser, dbPassword);
      
      LODNetworkWrapper.setConnection(conn);
      
      System.out.println("Precomputing connected components ......");
      LODNetworkWrapper.findConnectedComponents(networkName, linkLevel, componentTable);
      System.out.println("Precomputing connected components done");

      NetworkIO nio = LODNetworkManager.getNetworkIO(conn, networkName, null, null);
      int numComponents = nio.readNumberOfConnectedComponents(linkLevel);
      System.out.println("Total number of connected components is "+numComponents);
    }
    catch(Exception ex)
    {
      ex.printStackTrace();
    }
    finally
    {
      if(conn!=null)
        try{conn.close();} catch(Exception ignore){}
    }

  }
}

