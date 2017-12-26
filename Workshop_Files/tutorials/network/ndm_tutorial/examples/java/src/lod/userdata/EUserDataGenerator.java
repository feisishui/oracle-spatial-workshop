/* $Header: sdo/demo/network/examples/java/src/lod/userdata/EUserDataGenerator.java /main/3 2012/12/10 11:18:29 begeorge Exp $ */

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
 *  @version $Header: sdo/demo/network/examples/java/src/lod/userdata/EUserDataGenerator.java /main/3 2012/12/10 11:18:29 begeorge Exp $
 *  @author  begeorge
 *  @since   release specific (what release of product did this appear in)
 */

import java.sql.Blob;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.ResultSet;
import java.io.OutputStream;
import java.io.ObjectOutputStream;
import java.util.Vector;
import oracle.spatial.util.Logger;
import oracle.spatial.network.lod.LODNetworkManager;

public class EUserDataGenerator {
    private static final Logger log = Logger.getLogger(EUserDataGenerator.class.getName());
    public EUserDataGenerator() {
            
    }
    
   private static Vector getNodesInPartition(Connection conn, String partitionTableName,
                                             String nodeTypesTable, int partitionId) {
      Vector nodeVec = new Vector();
      long nodeId = 0;
      try{
          if (!tableExists(conn,partitionTableName)) {
              log.error(partitionTableName+" does not exist!!");
          }
          else if (!tableExists(conn,nodeTypesTable)) {
              log.error(nodeTypesTable+" does not exist!!");
          }
          PreparedStatement stmt;
          String queryStr;
          
          queryStr = "SELECT n.node_id, n.node_type" +
                     " FROM " + nodeTypesTable + " n, " + partitionTableName + " p "+
                     " WHERE n.node_id = p.node_id AND p.partition_id = ?";
          stmt = conn.prepareStatement(queryStr);
          stmt.setInt(1,partitionId);
          ResultSet rs = stmt.executeQuery();
          while (rs.next()) {
              nodeId = rs.getLong(1);
              int nodeType = rs.getShort(2);
              nodeVec.add(new eNode(nodeId,nodeType));
          }
          stmt.close();
          rs.close();
      }
      catch (Exception e) {
          log.error("Error while collecting info for user data generation for node "+ nodeId+
                    " in Partition "+partitionId);
          e.printStackTrace();
      }
      return nodeVec;                                          
   }
    
  /*
   Method computes a vector for internal links for the given partition
  */
   private static Vector getInternalLinksInPartition(Connection conn,String linkTableName,
                                                      String partitionTableName,
                                                      String linkTypesTable,
                                                      int partitionId)
                                                      
   {
       Vector linkVec = new Vector();
       long linkId = 0;
       try  {
           if (!tableExists(conn,partitionTableName)) {
               log.error(partitionTableName+" does not exist!!");
           }
           else if (!tableExists(conn,linkTypesTable)) {
               log.error(linkTypesTable+" does not exist!!");
           }
           else if (!tableExists(conn,linkTableName)) {
               log.error(linkTableName+" does not exist!!");
           }
           
           PreparedStatement stmt;
           String queryStr;
           
           queryStr = "SELECT l.link_id,lt.link_type "+
                       " FROM "+linkTableName+ " l,"+
                       partitionTableName+" p1,"+partitionTableName+" p2, "+
                       linkTypesTable +" lt"+
                       " WHERE l.link_id = lt.link_id AND "+
                       " l.start_node_id=p1.node_id AND l.end_node_id=p2.node_id AND"+
                       " p1.partition_id=p2.partition_id AND p1.partition_id=?";
            
            stmt = conn.prepareStatement(queryStr);
            stmt.setInt(1,partitionId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                linkId = rs.getLong(1);
                int linkType = rs.getShort(2);
                
                linkVec.add(new eLink(linkId,linkType));
            }
            stmt.close();
            rs.close();
       }
       catch (Exception e)  {
           log.error("Error while collecting info for user data generation for internal link "+linkId+
                     " in Partition "+partitionId);
           e.printStackTrace();
       }
       return linkVec;
   }
   
/*
 * Computes vector of out-boundary links for the given partition
*/
 
    private static Vector getBoundaryOutLinksForPartition(Connection conn,String linkTableName,
                                                      String partitionTableName,
                                                      String linkTypesTable,
                                                      int partitionId) {
                                                    
        Vector linkVec = new Vector();
        long linkId = 0;
        try {
            if (!tableExists(conn,partitionTableName)) {
                log.error(partitionTableName+" does not exist!!");
            }
            else if (!tableExists(conn,linkTypesTable)) {
                log.error(linkTypesTable+" does not exist!!");
            }
            else if (!tableExists(conn,linkTableName)) {
                log.error(linkTableName+" doesnot exist!!");
            }
            PreparedStatement stmt;
            
            String queryStr = "SELECT l.link_id,lt.link_type "+
                              " FROM "+
                              linkTableName+" l,"+partitionTableName+" p1,"+ 
                              partitionTableName+" p2, "+linkTypesTable+" lt" +
                              " WHERE l.link_id = lt.link_id AND l.start_node_id = p1.node_id AND"+
                              " l.end_node_id=p2.node_id AND p1.partition_id<>p2.partition_id AND"+
                              " p1.partition_id=?";
            stmt = conn.prepareStatement(queryStr);
            stmt.setInt(1,partitionId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next())   {
                linkId = rs.getLong(1);
                int linkType = rs.getShort(2);
                linkVec.add(new eLink(linkId,linkType));
            }
            stmt.close();
            rs.close();
        }
        catch (Exception e) {
            log.error("Error while collecting info for user data generation for external link "+linkId+
                      " in partition "+partitionId);
            e.printStackTrace();
        }
        return linkVec;
    }
    
/*
 * computes the vector of in-boundary links for the given partition
 */
 private static Vector getBoundaryInLinksForPartition(Connection conn,String linkTableName,
                                                      String partitionTableName,
                                                      String linkTypesTable,
                                                      int partitionId) {
     Vector linkVec = new Vector();
     long linkId = 0;
     try {
         if (!tableExists(conn,partitionTableName)) {
             log.error(partitionTableName+" does not exist!!");
         }
         else if (!tableExists(conn,linkTypesTable)) {
             log.error(linkTypesTable+" does not exist!!");
         }
         else if (!tableExists(conn,linkTableName)) {
             log.error(linkTableName+" doesnot exist!!");
         }
         PreparedStatement stmt;
         
         String queryStr = "SELECT l.link_id,lt.link_type "+
                           " FROM "+
                           linkTableName+ " l,"+partitionTableName+" p1,"+
                           partitionTableName+" p2,"+
                           linkTypesTable+" lt"+
                           " WHERE l.link_id=lt.link_id AND l.end_node_id=p1.node_id AND"+
                           " l.start_node_id=p2.node_id AND p1.partition_id<>p2.partition_id AND"+
                           " p1.partition_id=?";
        
        stmt = conn.prepareStatement(queryStr);
        stmt.setInt(1,partitionId);
        ResultSet rs = stmt.executeQuery();
        
        while (rs.next())   {
            linkId = rs.getLong(1);
            int linkType = rs.getShort(2);
            
            linkVec.add(new eLink(linkId,linkType));
        }
        rs.close();
        stmt.close();
     }
     catch (Exception e) {
         log.error("Error while collecting info for user data generation for external link "+linkId+
                   " in partition "+partitionId);
         e.printStackTrace();
     }
     return linkVec;
    }
 
    public void writeNIUserData(Connection conn,String userDataTableName,
                                      String linkTableName,String partitionTableName,
                                      String nodeTypesTable,String linkTypesTable,int partitionId)
    {
       long linkId = 0;
       long nodeId = 0;
       try {
           PreparedStatement stmt;
           ResultSet rs;
           Vector internalLinkVector = new Vector();
           Vector outBoundaryLinkVector = new Vector();
           Vector inBoundaryLinkVector = new Vector();
           Vector nodeVector = new Vector();
           log.info("Generating User Data for Partition "+partitionId);
          
           nodeVector = getNodesInPartition(conn,partitionTableName,nodeTypesTable,partitionId);
           internalLinkVector = getInternalLinksInPartition(conn,linkTableName,
                                                            partitionTableName,
                                                            linkTypesTable,
                                                            partitionId);                                             
           outBoundaryLinkVector = getBoundaryOutLinksForPartition(conn,linkTableName,
                                                                   partitionTableName,
                                                                   linkTypesTable,
                                                                   partitionId);
           inBoundaryLinkVector = getBoundaryInLinksForPartition(conn,linkTableName,
                                                                 partitionTableName,
                                                                 linkTypesTable,
                                                                 partitionId);
           
           conn.setAutoCommit(false);

	   String insertStr = "INSERT INTO " + userDataTableName + 
			      " (partition_id, blob) " + " VALUES " + " (?, EMPTY_BLOB())" ;
                              
           PreparedStatement pStmt = conn.prepareStatement(insertStr);
           pStmt.setInt(1,partitionId);
           int n = pStmt.executeUpdate();
	   System.out.println(n+" row(s) updated in the user data table "+userDataTableName);
	   pStmt.close();

           //lock the row for blob update
           String lockRowStr = "SELECT blob FROM " + userDataTableName +
			       " WHERE partition_id = ? " + " FOR UPDATE";
           pStmt = conn.prepareStatement(lockRowStr);
	   pStmt.setInt(1,partitionId);
	   rs = pStmt.executeQuery();
	   
           rs.next();
	   oracle.sql.BLOB userDataBlob = (oracle.sql.BLOB) rs.getBlob(1);
           pStmt.close();

           OutputStream blobOut = ((oracle.sql.BLOB) userDataBlob).setBinaryStream(1);
	   ObjectOutputStream dout = new ObjectOutputStream(blobOut);

	   //write partition ID
           dout.writeInt(partitionId); 
           
           if (nodeVector == null || nodeVector.size() == 0) {
               log.error("No nodes in partition "+partitionId);
               throw new Exception("No nodes in partition " + partitionId);
           }
           
           if (internalLinkVector == null || internalLinkVector.size() == 0) {
               log.error("No internal links in partition "+partitionId);
               throw new Exception("No internal links in partition " + partitionId);
           }
           
           System.out.println("Partition ID : "+partitionId+
                              "; Nodes :: "+nodeVector.size()+
                              "; Internal links :: "+internalLinkVector.size() +
                              "; In-boundary Links :: "+inBoundaryLinkVector.size() +
                              "; Out-boundary links :: "+outBoundaryLinkVector.size()+";");
            
            //write the number of nodes
            int numNodes = nodeVector.size();
            dout.writeInt(numNodes);
            System.out.println("***Generating user data information for Nodes for partition "+
                               partitionId+"***");
            if (nodeVector.size() > 0) {
                for (int i=0; i<nodeVector.size(); i++) {
                    eNode node = (eNode) nodeVector.elementAt(i);
                    nodeId = node.getNodeId();
                    //write node ID, node type of each node
                    dout.writeLong(node.getNodeId());
                    dout.writeInt(node.getNodeType());
                }
                dout.flush();
            }
            // write the number of links
            int numLinks = internalLinkVector.size()+outBoundaryLinkVector.size()+
                           inBoundaryLinkVector.size();
            dout.writeInt(numLinks);
            
            //prepare the blob with link user data information
           
            //Link Information
            //    link id
            //    link type
            System.out.println("***Generating user data information for Links for partition " 
                               + partitionId + "***");
            if (internalLinkVector.size() > 0) {
               for (int i=0; i<internalLinkVector.size(); i++) {
                   eLink link = (eLink) internalLinkVector.elementAt(i);
                   linkId = link.getLinkId();
                   //write link ID, link type
                   dout.writeLong(link.getLinkId());
                   dout.writeInt(link.getLinkType());
               }
               dout.flush();
           }
           
           if (outBoundaryLinkVector.size() > 0) {
               for (int i=0; i<outBoundaryLinkVector.size(); i++) {
                   eLink link = (eLink) outBoundaryLinkVector.elementAt(i);
                   linkId = link.getLinkId();
                   //write link ID, link type
                   dout.writeLong(link.getLinkId());
                   dout.writeInt(link.getLinkType());
               }
               dout.flush();
           }
           
           if (inBoundaryLinkVector.size() > 0) {
               for (int i=0; i<inBoundaryLinkVector.size(); i++) {
                   eLink link = (eLink) inBoundaryLinkVector.elementAt(i);
                   linkId = link.getLinkId();
                   //write link ID, link type
                   dout.writeLong(link.getLinkId());
                   dout.writeInt(link.getLinkType());       
               }
               dout.flush();
           }
           blobOut.close();
           rs.close();
           conn.commit();
       }
       catch (Exception e)  {
          log.error("User Data Generation failed for partition "+partitionId+"; Check Link "+linkId+
                    " OR Node "+nodeId);
          e.printStackTrace();
       }
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
    
    public void writeNIUserDataForAllPartition(Connection conn, String networkName, 
                                               String userDataTableName)  {
        
        String network = "'"+networkName.toUpperCase()+"'";
        PreparedStatement stmt;
        ResultSet rs;
        
        Vector internalLinkVector = new Vector();
        Vector outBoundaryLinkVector = new Vector();
        Vector inBoundaryLinkVector = new Vector();
        
        try {
             if (tableExists(conn,userDataTableName)) {
                System.out.println("Dropping existing user data table "+userDataTableName);
                String dropStr = "DROP TABLE " + userDataTableName+" PURGE";
                stmt = conn.prepareStatement(dropStr);
                rs = stmt.executeQuery();
                conn.commit();
             }
             System.out.println("Creating User data table "+userDataTableName);
             String createStr = "CREATE TABLE " + userDataTableName  +
                                " (partition_id number, blob BLOB)";
             
             stmt = conn.prepareStatement(createStr);
             rs = stmt.executeQuery();
             conn.commit();
             
            // Get the partition table name, link table name
            String queryStr = "SELECT link_table_name,partition_table_name"+
                              " FROM "+" user_sdo_network_metadata "+
                              " WHERE network = "+network;
            stmt = conn.prepareStatement(queryStr);
            rs = stmt.executeQuery();
            rs.next();
            String linkTableName = rs.getString(1);
            String partitionTableName = rs.getString(2);
            rs.close();
            stmt.close();
            
            String linkTypesTable = "EXAMPLE_LINK_TYPE";
            String nodeTypesTable = "EXAMPLE_NODE_TYPE";
            // Read the partition IDs from the partition table 
            queryStr = "SELECT min(partition_id), max(partition_id) "+
                       " FROM "+ partitionTableName;
            stmt = conn.prepareStatement(queryStr);
            rs = stmt.executeQuery();
            rs.next();
            int minPid = rs.getInt(1);
            int maxPid = rs.getInt(2);
            rs.close();
            stmt.close();
            log.info("Min partition ID :: "+ minPid+"  Max partition ID :: "+maxPid);
            
            for (int i=minPid; i<=maxPid; i++)     {
            
                int partitionId = i;
                System.out.println("Creating user data for partition "+i);
                writeNIUserData(conn,userDataTableName,linkTableName,
                                partitionTableName,nodeTypesTable,
                                linkTypesTable,partitionId);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        } 
    }
    
    public static void main(String args []) {
        
       String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl";
       String dbUser = "";
       String dbPassword = "";
       String networkName = "EXAMPLE";
       String configXmlFile = "LODConfigs.xml";
       String logLevel    =    "ERROR";
       int linkLevel      = 1;

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
  
      String userDataTableName = "EXAMPLE_USER_DATA";
       try {
            
            Connection conn = null;
            conn = LODNetworkManager.getConnection(dbUrl,dbUser,dbPassword);
            EUserDataGenerator udWriter = new EUserDataGenerator();                                                         
            udWriter.writeNIUserDataForAllPartition(conn,networkName,userDataTableName);
       }
       catch (Exception e) {
            e.printStackTrace();
       }
    }
    
    private static class eNode {
      private long t_nodeID;
      private int t_nodeType;
      
      public eNode(long nodeID, int nodeType) 
      {
        t_nodeID = nodeID;
        t_nodeType = nodeType;
      }

      public long getNodeId()        { return t_nodeID;}
      public int getNodeType()     { return t_nodeType;}
    }
    
    private static class eLink {
      private long t_linkId;
      private int t_linkType;
      
      public eLink(long linkId, int linkType)  {
          t_linkId = linkId;
          t_linkType = linkType;
      }
        
      public long getLinkId()      { return t_linkId; }
      public int getLinkType()   { return t_linkType;}
    }
}
