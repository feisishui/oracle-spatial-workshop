/* $Header: sdo/demo/network/examples/java/src/inmemory/ProhibitedTurn.java /main/6 2012/12/10 11:18:30 begeorge Exp $ */

/* Copyright (c) 2004, 2012, Oracle and/or its affiliates. 
All rights reserved. */

/*
   DESCRIPTION
     Constructs a set of prohibited turns as a network constraint; then returns
     the shortest path between two nodes, first without applying the constraint and 
     then applying the constraint. 

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    hgong       02/12/07 - Change NYC_NET to HILLSBOROUGH_NETWORK
    ningan      02/15/05 - Add comments
    jcwang      06/17/04 - fix DB connection 
    jcwang      03/12/04 - jcwang_improve_cache 
    jcwang      03/09/04 - Creation
 */

/**
 *  @version $Header: sdo/demo/network/examples/java/src/inmemory/ProhibitedTurn.java /main/6 2012/12/10 11:18:30 begeorge Exp $
 *  @author  jcwang  
 *  @since   release specific (what release of product did this appear in)
 */


package inmemory;

import java.util.HashMap;
import java.util.Iterator;

import java.util.Set;

import oracle.jdbc.OracleConnection;

import oracle.jdbc.pool.OracleDataSource;

import oracle.spatial.network.AnalysisInfo;
import oracle.spatial.network.Link;
import oracle.spatial.network.Network;
import oracle.spatial.network.NetworkConstraint;
import oracle.spatial.network.NetworkManager;
import oracle.spatial.network.Path;
 
// construct prohibited turns as (start link, end link) pairs
// can be from a database table, a file, or constructed in memory
// use a hashMap to represent prohibited turns
// startLink IDs as keys and a set of prohibited end Links ID as values
public class ProhibitedTurn implements NetworkConstraint 
{
    // map that contains prohibited turns information
    private HashMap pTurnMap = null; 
    
    // construct prohibited turns information
    public ProhibitedTurn() {
        pTurnMap = new HashMap();
        // add prohibited turns as 
        // start link : prohibited end links
        int [] startLinkIDs = {145482278,145482600,145481401};
        int [][] prohibitedEndLinkIDs = {{145485139},{145482600},{145480459} };
        
        for ( int i = 0; i < startLinkIDs.length ;i++)
          pTurnMap.put(new Integer(startLinkIDs[i]),prohibitedEndLinkIDs[i]);
    }
    
    // check if the given turn (start link ID, end link ID) is allowed
    private boolean validTurn(int startLinkID, int endLinkID) {
      if ( pTurnMap == null ) // no prohibited turns
        return true;
      else {        
        int [] prohibitedEndLinks = (int[])pTurnMap.get(new Integer(startLinkID));
        if ( prohibitedEndLinks == null )
          return true;
        else {
          for ( int i = 0; i < prohibitedEndLinks.length;i++) {
            if ( prohibitedEndLinks[i] == endLinkID)
              return false; // prohibited found
          }
          return true; // OK
        }
      }
    }

    public String toString() {
      if ( pTurnMap != null ) {
        StringBuffer buffer = new StringBuffer();
        Set keys = pTurnMap.keySet();
        
        for ( Iterator it = keys.iterator() ;it.hasNext(); ) {
          Integer StartLinkID = (Integer)it.next();
          int startLinkID = StartLinkID.intValue();
          buffer.append("\n Prohibited Turns:");
          int [] endLinkIDs = (int []) pTurnMap.get(StartLinkID);
          for ( int i = 0; i < endLinkIDs.length;i++) 
            buffer.append("\t(" + startLinkID + " -> " +endLinkIDs[i] + ")"); 
        }
        return buffer.toString();
      } else
        return "No Prohibited Turns!";

    }

    // Methods to be implemented by user for interface NetworkConstraint
    
    public boolean requiresPathLinks() { return false ; } // path link info. not needed

    public boolean isSatisfied(AnalysisInfo info) { 
      Link currentLink = info.getCurrentLink();
      if ( currentLink == null ) 
        return true; // start node, current link == null
      Link nextLink    = info.getNextLink();
      return validTurn(currentLink.getID(),nextLink.getID());
    }


    // test program
    public static void main(String[] args)
    {
        //Get input parameters
        String dbUrl    = "jdbc:oracle:thin:@localhost:1521:orcl";
        String dbUser     = "";
        String dbPassword = "";
  
        String networkName = "HILLSBOROUGH_NETWORK";
        int startNodeId    = 1533;
        int endNodeId      = 10043;
         
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
          else if(args[i].equalsIgnoreCase("-startNodeId"))
            startNodeId = Integer.parseInt(args[i+1]);
          else if(args[i].equalsIgnoreCase("-endNodeId"))
            endNodeId = Integer.parseInt(args[i+1]);
        }

        try
        {
            // get jdbc connection
            OracleConnection con = null;
            OracleDataSource ds = new OracleDataSource();
            ds.setURL(dbUrl);
            ds.setUser(dbUser);
            ds.setPassword(dbPassword);
            con = (OracleConnection)ds.getConnection();    
            con.setAutoCommit(false);

            // Load networks from database
            Network network = NetworkManager.readNetwork(con, networkName);
        
            // Close the database connection
            con.close();
            
            // shortest path with no state turned off
            Path path = NetworkManager.shortestPath(network,startNodeId,endNodeId);
            if ( path != null )
              System.out.println("Shortest Path (Node[1](Link[1])Node[2]...(Link[n-1])N[n]) WITHOUT prohibited turns : " + path);
            network.addPath(path);            

            // construct prohibited turns information
            ProhibitedTurn turnConstraint= new ProhibitedTurn();
            // shortest path with prohibited turns
            path = NetworkManager.shortestPath(network,startNodeId,endNodeId,turnConstraint);
            System.out.println("Prohibited Turn Info: " + turnConstraint);
            network.addPath(path);
             
            if ( path != null )
              System.out.println("Shortest Path (Node[1](Link[1])Node[2]...(Link[n-1])N[n]) WITH prohibited turns: " + path);
        }
        catch (Exception e)
        {
            System.err.println(e.getMessage());
            e.printStackTrace();
        }
    }    
    
}
