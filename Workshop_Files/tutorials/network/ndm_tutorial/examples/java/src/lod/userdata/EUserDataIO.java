/* $Header: sdo/demo/network/examples/java/src/lod/userdata/EUserDataIO.java /main/1 2010/12/09 10:15:00 begeorge Exp $ */

/* Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved. */

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
 *  @version $Header: sdo/demo/network/examples/java/src/lod/userdata/EUserDataIO.java /main/1 2010/12/09 10:15:00 begeorge Exp $
 *  @author  begeorge
 *  @since   release specific (what release of product did this appear in)
 */

import java.io.ObjectInputStream;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import oracle.sql.*;
import oracle.spatial.network.lod.CategorizedUserData;
import oracle.spatial.network.lod.CategorizedUserDataImpl;
import oracle.spatial.network.lod.LODNetworkException;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.LODUserDataIO;
import oracle.spatial.network.lod.LODUserDataIOSDO;
import oracle.spatial.network.lod.LogicalNetLink;
import oracle.spatial.network.lod.LogicalNetNode;
import oracle.spatial.network.lod.LogicalPartition;
import oracle.spatial.network.lod.UserData;
import oracle.spatial.util.Logger;

public class EUserDataIO extends LODUserDataIOSDO implements LODUserDataIO
{
  private static final Logger logger = Logger.getLogger(EUserDataIO.class.getName());
  public static final int MAX_USER_DATA_CATEGORY            = 0;
  public static final int USER_DATA_DEFAULT_CATEGORY        = 0;
  //The following four indexes correspond to default category (category 0)
  //This user data is set in the user_sdo_network_user_data
  public static final int USER_DATA_INDEX_NODE_X            = 0;
  public static final int USER_DATA_INDEX_NODE_Y            = 1;
  public static final int USER_DATA_INDEX_LINKLEVEL         = 0;
  public static final int USER_DATA_INDEX_LINKSPEED         = 1;
  
  public static final int USER_DATA_CATEGORY_EXAMPLE        = 1;
  //The following two indexes correspond to category 1 user data.
  //The user data blobs in this case are user generated and stored in 
  //a separate table.
  public static final int USER_DATA_INDEX_NODETYPE          = 0;
  public static final int USER_DATA_INDEX_LINKTYPE          = 0;
 
  public static final String networkName = "EXAMPLE";
  private String userBlobTableName = null;
  

  public EUserDataIO(Connection conn, int categoryId, String userBlobTableName)
  {
    super.setConnection(conn);
    super.setCategoryId(categoryId);
    this.userBlobTableName = userBlobTableName;
  }
  
  public void readUserData(LogicalPartition partition)
  {
    int categoryId = getCategoryId();
    if(partition.isUserDataCategoryLoaded(categoryId))  {
      return;
    }
      
    if(categoryId == USER_DATA_CATEGORY_EXAMPLE)
    {
      readUserDataFromTable(partition);
      partition.addUserDataCategory(USER_DATA_CATEGORY_EXAMPLE);
    }
  }

  private void readUserDataFromTable(LogicalPartition partition)  {
    int partitionId = partition.getPartitionId();
    
    try {
        UserData nodeUserData;
        UserData linkUserData;
        BLOB niBlob = readBlob(partitionId);
        InputStream is = niBlob.getBinaryStream(); 
        ObjectInputStream ois = new ObjectInputStream(is);
         
        //read partition ID from the blob   
        int blobPartitionId = ois.readInt();
        if (partitionId != blobPartitionId) {
            System.out.println("PartitonId in the Blob ("+blobPartitionId+") is not the same as "+
                               "requested partition ID ("+partitionId+")");
            return;
        }
        //read number of nodes
        int numNodes = ois.readInt();
        // read node ID, node type for each node
        for (int i=0; i<numNodes; i++) {
            long nodeId = ois.readLong();
            int nodeType = ois.readInt();
            
            nodeUserData = new eNodeUserData(nodeType);
            LogicalNetNode node = partition.getNode(nodeId);
            
            if (node != null) {
                CategorizedUserData cud = node.getCategorizedUserData();
                if (cud == null) {
                    UserData [] userDataArray = {null,nodeUserData};
                    cud = new CategorizedUserDataImpl(userDataArray);
                    node.setCategorizedUserData(cud);
                }
                else {
                    cud.setUserData(USER_DATA_CATEGORY_EXAMPLE,nodeUserData);
                }
            }
        }
        
        int numLinks = ois.readInt();
        
        

        //Read link info for each link
        //  :::: Link Id
        //  :::: linkCostSeries (HashMap <index, cost>)
        
        for (int i=0; i<numLinks; i++)  {
            long linkId = ois.readLong();
            int linkType = ois.readInt();
            
            linkUserData = new eLinkUserData(linkType);
            LogicalNetLink link = partition.getLink(linkId);
            
            if (link != null) {
                CategorizedUserData cud = link.getCategorizedUserData();
                
                if (cud == null) {
                    UserData [] userDataArray = {null, linkUserData};
                    cud = new CategorizedUserDataImpl(userDataArray);
                    link.setCategorizedUserData(cud);
                }
                else    {
                    cud.setUserData(USER_DATA_CATEGORY_EXAMPLE,linkUserData);
                }
            }
        }
    }
    catch (Exception e) {
        e.printStackTrace();
    } 
  }
  
  private BLOB readBlob(int partitionId) throws LODNetworkException       {
    PreparedStatement pStmt=null;
    BLOB tBlob = null;
    ResultSet rs = null;
    try     {
       String queryStr = "SELECT blob FROM " + userBlobTableName +
                         " WHERE partition_id = ?";
       pStmt = conn.prepareStatement(queryStr);
       pStmt.setInt(1,partitionId);
       rs = pStmt.executeQuery();
       if (rs.next())   {
        tBlob = (oracle.sql.BLOB)rs.getBlob(1);
        if (tBlob == null)  {
            throw new LODNetworkException("No blob read for partition "+partitionId);
        }
       }
       pStmt.close();
       rs.close();
    }
    catch (Exception e)  {
        e.printStackTrace();
    }
    return tBlob;
  }
 public void writeUserData(LogicalPartition partition) {
     
    try {
        int partitionId = partition.getPartitionId();
    }
    catch (Exception e) {
         e.printStackTrace();
    }
 }
 
 private static class eLinkUserData implements UserData
    {
      private int linkType;

      protected eLinkUserData(int linkType)
      {
        this.linkType = linkType;
      }
      
      public Object get(int index)
      {
        switch(index)
        {
          default:
            return linkType;
        }
        
      }

      public void set(int index, Object userData)
      {
        switch(index)
        { 
          default:
            this.linkType = (Integer)userData;
        }
      }

      public int getNumberOfUserData()
      {
        return 1;
      }
      
      public Object clone()
      {
        return new eLinkUserData(linkType);
      }
    }
    
    private static class eNodeUserData implements UserData
    {
      private int nodeType;

      protected eNodeUserData(int nodeType)
      {
        this.nodeType = nodeType;
        
      }
      
      public Object get(int index)
      {
        switch(index)
        {
          default:
              return nodeType;
        }
      }

      public void set(int index, Object userData)
      {
        switch(index)
        {
          default:
            this.nodeType = (Integer) userData;
        }
      }

      public int getNumberOfUserData()
      {
        return 1;
      }
      
      public Object clone()
      {
        return new eNodeUserData(nodeType);
      }
    }
}
