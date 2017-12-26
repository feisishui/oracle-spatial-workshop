/* $Header: sdo/demo/network/examples/java/src/lod/PartitionBlobGenerator.java /main/8 2012/12/10 11:18:29 begeorge Exp $ */

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

package lod;

import java.io.InputStream;

import java.sql.SQLException;

import oracle.jdbc.OracleConnection;

import oracle.jdbc.pool.OracleDataSource;

import oracle.spatial.network.UserDataMetadata;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.LODNetworkWrapper;
import oracle.spatial.network.lod.LogicalPartition;
import oracle.spatial.network.lod.NetworkIO;
import oracle.spatial.network.lod.util.PrintUtility;

/**
 *  This class demonstrates how to generate or regenerate partition BLOBs using
 *  LOD java API. If your database version is 11gR1 and above, please do NOT
 *  use this example, but use the following PLSQL functions instead:
 *    - SDO_NET.GENERATE_PARTITION_BLOBS
 *    - SDO_NET.GENERATE_PARTITION_BLOB.
 *  
 *  Note that LOD java API does not provide methods to create 
 *  partition BLOB tables or to update the network metadata in the database, 
 *  therefore, the caller of the LOD partition BLOB generation methods must 
 *  ensure that the partition BLOB tables already exist in the database, and
 *  the network metadata already points to the correction partition BLOB table.
 *  
 *  @version $Header: sdo/demo/network/examples/java/src/lod/PartitionBlobGenerator.java /main/8 2012/12/10 11:18:29 begeorge Exp $
 *  @author  hgong
 *  @since   11gR1
 */
public class PartitionBlobGenerator
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

    String networkName        = "HILLSBOROUGH_NETWORK";
    String partitionBlobTable = "HILLSBOROUGH_NETWORK_PBLOB$";
    boolean includeUserData   = true;
    boolean commitForEachBlob = true;
    int partitionId           = -1;
    int linkLevel             = 1;
    
    OracleConnection conn     = null;
    
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
      else if(args[i].equalsIgnoreCase("-partitionBlobTable"))
        partitionBlobTable = args[i+1];
      else if(args[i].equalsIgnoreCase("-includeUserData"))
        includeUserData = Boolean.parseBoolean(args[i+1]);
      else if(args[i].equalsIgnoreCase("-commitForEachBlob"))
        commitForEachBlob = Boolean.parseBoolean(args[i+1]);
      else if(args[i].equalsIgnoreCase("-partitionId"))
        partitionId = Integer.parseInt(args[i+1]);
      else if(args[i].equalsIgnoreCase("-linkLevel"))
        linkLevel = Integer.parseInt(args[i+1]);
      else if(args[i].equalsIgnoreCase("-configXmlFile"))
        configXmlFile = args[i+1];
      else if(args[i].equalsIgnoreCase("-logLevel"))
        logLevel = args[i+1];
    }
    
    System.out.println("Generate Partition BLOBs for "+networkName);
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

      NetworkIO nio = LODNetworkManager.getNetworkIO(conn, networkName, null, null);

      LogicalPartition partition = null;
      
      if(partitionId==-1)
      {
        System.out.println("Generateing partition blobs ......");
        LODNetworkWrapper.generatePartitionBlobs(networkName, linkLevel, 
          partitionBlobTable, includeUserData, commitForEachBlob, false);
        System.out.println("Partition blobs generated");
        System.out.println("Toatl number of partitions: "+nio.readNumberOfPartitions(linkLevel));
      }
      else
      {
        System.out.println("Generateing partition blob for partition " + partitionId + "......");
        LODNetworkWrapper.generatePartitionBlob(networkName, linkLevel, 
          partitionId, includeUserData, false);
        System.out.println("Partition blob generated");

        int[] udc = null;
        if(includeUserData)
        {
          udc = new int[1];
          udc[0] = UserDataMetadata.DEFAULT_USER_DATA_CATEGORY;
        }
        partition = nio.readLogicalPartition(partitionId, linkLevel, udc, null, true);
        PrintUtility.print(System.out, partition, 1);
      } 
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

