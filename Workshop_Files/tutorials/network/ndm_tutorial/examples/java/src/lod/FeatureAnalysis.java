/* $Header: sdo/demo/network/examples/java/src/lod/FeatureAnalysis.java /main/3 2012/12/10 11:18:29 begeorge Exp $ */

/* Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved. */

/*
   DESCRIPTION
    <short description of component this file declares/defines>

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    hgong       10/09/12 - add FeatureFilter example
    hgong       06/14/12 - Creation
 */
import java.sql.Connection;

import oracle.spatial.network.lod.DummyLinkLevelSelector;
import oracle.spatial.network.lod.Feature;
import oracle.spatial.network.lod.FeatureFilter;
import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.FeaturePath;
import oracle.spatial.network.lod.LODNetworkManager;
import oracle.spatial.network.lod.LinkLevelSelector;
import oracle.spatial.network.lod.NetworkIO;
import oracle.spatial.network.lod.PathFeature;
import oracle.spatial.network.lod.PointOnNet;
import oracle.spatial.network.lod.TSP;
import oracle.spatial.network.lod.TspPathFeature;
import oracle.spatial.util.Logger;

/**
 *  This class shows how to conduct feature analysis using NDM java API.
 *  @version $Header: sdo/demo/network/examples/java/src/lod/FeatureAnalysis.java /main/3 2012/12/10 11:18:29 begeorge Exp $
 *  @author  hgong   
 *  @since   release specific (what release of product did this appear in)
 */
public class FeatureAnalysis
{
  public static void main(String[] args) throws Exception
  {
    String dbUrl = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser = "";
    String dbPassword = "";
    String networkName = "GRID";

    //get input parameters
    for(int i=0; i<args.length; i++)
    {
      if(args[i].equalsIgnoreCase("-dbUrl"))
        dbUrl = args[i+1];
      else if(args[i].equalsIgnoreCase("-dbUser"))
        dbUser = args[i+1];
      else if(args[i].equalsIgnoreCase("-dbPassword"))
        dbPassword = args[i+1];
      else if(args[i].equalsIgnoreCase("-networkName"))
        networkName = args[i+1].toUpperCase();
    }
    
    Logger.setGlobalLevel(Logger.LEVEL_ERROR);

    Connection conn = LODNetworkManager.getConnection(dbUrl, dbUser, dbPassword);
    NetworkIO nio = LODNetworkManager.getCachedNetworkIO(conn, networkName, networkName, null);
    NetworkAnalyst analyst = LODNetworkManager.getNetworkAnalyst(nio);

    int hotelFeatureLayerId = 
        nio.getNetworkMetadata().getFeatureMetadata().
        getFeatureLayerMetadata("HOTEL").getFeatureLayerId();

    Feature[] hotels = nio.readFeatures(hotelFeatureLayerId, new long[]{1, 2, 3}, null);
    
    //shortest path between two features
    System.out.println("Shortest path between two features...");
    LinkLevelSelector lls = new DummyLinkLevelSelector(1);
    PathFeature path = analyst.shortestPathDijkstra(new Feature[]{hotels[0]}, 
                                                    new Feature[]{hotels[1]}, 
                                                    null, lls);
    System.out.println(path);

    //tsp 
    System.out.println("TSP among three features...");
    Feature[][] tspFeatures = {new Feature[]{hotels[0]},
                               new Feature[]{hotels[1]},
                               new Feature[]{hotels[2]}};
    TspPathFeature tspPathFeature = analyst.tsp(tspFeatures, TSP.TourFlag.CLOSED, null, null);
    System.out.println(tspPathFeature);
    
    //nearest 3 hotel features from a point on the network
    System.out.println("Nearest three hotel features from a point on the network...");
    FeaturePath[] nearestFeatures = 
        analyst.nearestFeatures(new PointOnNet[] {new PointOnNet(55)}, 3, 
                                new int[]{hotelFeatureLayerId}, null, null);
    for(int i=0; i<nearestFeatures.length; i++)
      System.out.println((i+1)+". "+nearestFeatures[i]+"\n");
    
    //hotel features within cost 4 from a point on the network
    System.out.println("Hotel features within cost 4 from a point on the network...");
    FeaturePath[] withinCostFeatures = 
        analyst.withinCostFeatures(new PointOnNet[] {new PointOnNet(55)}, 4, 
                                   new int[]{hotelFeatureLayerId}, null, null);
    for(int i=0; i<withinCostFeatures.length; i++)
      System.out.println((i+1)+". "+withinCostFeatures[i]+"\n");

    //Merry Berry hotel features within cost 4 from a point on the network, with FeatureFiler
    System.out.println("Hotel features within cost 4 from a point on the network, with FeatureFiler...");
    FeatureFilter filter = new HotelFeatureFilter("Merry Berry");
    withinCostFeatures = 
        analyst.withinCostFeatures(new PointOnNet[] {new PointOnNet(55)}, 4, 
                                   new int[]{hotelFeatureLayerId}, null, filter);
    for(int i=0; i<withinCostFeatures.length; i++)
      System.out.println((i+1)+". "+withinCostFeatures[i]+"\n");
  }
  
  static class HotelFeatureFilter implements FeatureFilter
  {
    int HOTEL_CHAIN_USER_DATA_INDEX = 0;
    private String hotelChain;
    public HotelFeatureFilter(String hotelChain)
    {
      this.hotelChain = hotelChain;
    }
    
    public boolean isValid(Feature feature)
    {
      String chain = (String)feature.getUserData(0).get(HOTEL_CHAIN_USER_DATA_INDEX);
      if(hotelChain.equalsIgnoreCase(chain))
        return true;
      else
        return false;
    }

    public int[] getUserDataCategories()
    {
      int[] categories = {0};
      return categories;
    }
  }
}

