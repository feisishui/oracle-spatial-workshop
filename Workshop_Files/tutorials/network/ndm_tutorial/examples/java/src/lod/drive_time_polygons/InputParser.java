/* $Header: sdo/demo/network/examples/java/src/lod/drive_time_polygons/InputParser.java /main/2 2012/03/22 05:41:12 begeorge Exp $ */

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
 *  @version $Header: sdo/demo/network/examples/java/src/lod/drive_time_polygons/InputParser.java /main/2 2012/03/22 05:41:12 begeorge Exp $
 *  @author  begeorge
 *  @since   release specific (what release of product did this appear in)
 */

package polygons;

import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.StringTokenizer;
import oracle.spatial.network.lod.NetworkAnalyst;
import oracle.spatial.network.lod.NetworkIO;
import oracle.spatial.network.lod.PointOnNet;
import oracle.spatial.geocoder.client.GeocoderAddress;
import oracle.spatial.router.engine.Network;
import oracle.spatial.router.util.RouterDataSource;
import oracle.spatial.network.lod.SpatialLink;
import oracle.spatial.network.lod.UserDataImpl;
import oracle.spatial.network.lod.util.JGeometryUtility;
import oracle.spatial.geocoder.client.ThinClientGeocoder;
import oracle.spatial.geocoder.common.CountryNameTable;

public class InputParser
{
  private static final NumberFormat formatter = new DecimalFormat("#.######");
  
  private static NetworkAnalyst analyst;
  private static NetworkIO networkIO;
  private static String dbUrl;
  private static String userName;
  private static String password;
  private static String networkName;
  
  private static RouterDataSource routerDataSource=null;
  private static ThinClientGeocoder geocoder = null;
  
  public InputParser (){
      
  }
  
  public InputParser(String dbUrl, String userName, String password, String networkName, NetworkIO networkIO) {
      this.dbUrl = dbUrl;
      this.userName = userName;
      this.password = password;
      this.networkName = networkName; 
      this.networkIO = networkIO;
  }
  
  public void init () {
      try {
        this.routerDataSource = new RouterDataSource(dbUrl, userName, password, 3, 100);
        String[] geocoderConnParameters = parseGeocoderConnInputs(dbUrl);
        this.geocoder = new ThinClientGeocoder(geocoderConnParameters[0],
                                               geocoderConnParameters[1],
                                               geocoderConnParameters[2],
                                               userName, password,"thin");
        
      }
      catch (Exception e) {
          System.out.println("Error while creating router data source/ geocoder");
          e.printStackTrace();
      }
  }
  
  public  String[] splitInputLocations(String inputLocations) 
  throws Exception {
    if(inputLocations.indexOf(',')>=0 || inputLocations.indexOf(';')>=0)
    {
      return splitAddresses(inputLocations);
    }
    else if(inputLocations.indexOf('@')>=0) //input must be link ids
    {
      return splitNodesOrLinks(inputLocations);
    }
    else
    {
      return splitNodesOrLinks(inputLocations);
    }
  }
      
  private String[] splitAddresses(String addresses)
  throws Exception
  {
    ArrayList<String> addressArray = new ArrayList<String>();
    StringTokenizer st = new StringTokenizer(addresses, ";");
    while(st.hasMoreTokens())
    {
      String address = st.nextToken();
      if(address!=null && address.trim().length()>0)
        addressArray.add(address);
    }
    return addressArray.toArray(new String[0]);
  } 
  
  private String[] splitNodesOrLinks(String locations)
  {
    if (locations == null )
      return new String[0];
    StringTokenizer st = new StringTokenizer(locations,"+ \t\n\r");
    ArrayList<String> nodeArray = new ArrayList<String>();
    while (st.hasMoreTokens())
    {
      String node = st.nextToken();
      if(node!=null && node.trim().length()>0)
        nodeArray.add(node);
    }
    return nodeArray.toArray(new String[0]);
  }

  public Locations parseInputLocations(String inputLocations)
  throws Exception
  {
    if(inputLocations.indexOf(',')>=0)
    {
      String[] inputLocationArray = splitAddresses(inputLocations);
      return parseAddresses(inputLocationArray);
    }
    else if(inputLocations.indexOf('@')>=0) //input must be link ids
    {
      String[] inputLocationArray = splitNodesOrLinks(inputLocations);
      return new Locations(toDoubleArray(parseLinkIdPercentages(inputLocationArray)), null);
    }
    else
    {
      String[] inputLocationArray = splitNodesOrLinks(inputLocations);
      return new Locations(toDoubleArray(parseNodeIds(inputLocationArray)), null);
    }
  }

  private PointOnNet[] parseNodeIds(String[] nodeIds)
  {
    long[] longNodeIds = new long[nodeIds.length];
    for(int i=0; i<nodeIds.length; i++)
      longNodeIds[i] = Long.parseLong(nodeIds[i]);
    PointOnNet[] points = new PointOnNet[longNodeIds.length];
    for(int i=0; i<points.length; i++)
      points[i] = new PointOnNet(longNodeIds[i]);
    return points;
  }

  private PointOnNet[] parseLinkIdPercentages(String[] linkIdPercentStrs)
  {
    PointOnNet[] points = new PointOnNet[linkIdPercentStrs.length];
    int count = 0;
    for(int i=0; i<linkIdPercentStrs.length; i++)
      points[count++] = parseLinkIdPercentage(linkIdPercentStrs[i]);
    return points;
  }

  private PointOnNet parseLinkIdPercentage(String linkIdPercentStr)
  {
    int idx = linkIdPercentStr.indexOf('@');
    long linkId = Long.parseLong(linkIdPercentStr.substring(0, idx));
    double percentage = Double.parseDouble(linkIdPercentStr.substring(idx+1));
    PointOnNet point = new PointOnNet(linkId, percentage);
    //get lat, lon
    try
    {
      SpatialLink link = networkIO.readSpatialLink(linkId, null);
      double[] pointGeom =
        JGeometryUtility.getPointOnLineString(link.getGeometry(), percentage);
      Object[] udObjects = {pointGeom[0], pointGeom[1]};
      point.setUserData(new UserDataImpl(udObjects));
    }
    catch(Exception ex)
    {
     ex.printStackTrace();
    }
    return point;
  }
  
  private Locations parseAddresses(String[] addresses)
    throws Exception
  {
    ArrayList<GeocoderAddress> inputAddresses = new ArrayList<GeocoderAddress>();
    
    for(int i=0; i<addresses.length; i++)
    {
      GeocoderAddress ga = parseAddress(addresses[i]);
      inputAddresses.add(ga);
      
    }
      
    ArrayList outputAddresses = geocoder.batchGeocode(inputAddresses);
    
    ArrayList<GeocoderAddress> geocodedAddresses = new ArrayList<GeocoderAddress>();
    int iter =0;
    for(Iterator it=outputAddresses.iterator(); it.hasNext(); )
    {
      ArrayList addressList = (ArrayList)it.next();
        if(addressList!=null && addressList.size()>0) {
            geocodedAddresses.add((GeocoderAddress)addressList.get(0));
            iter++;
        }
    }  
    PointOnNet [][] points = Network.computeLoci(geocodedAddresses, 'R',
                                this.routerDataSource, networkName);
    
    for(int i=0; i<points.length; i++) {
        System.out.println("Points On Net (linkID@percent) ");
        for (int j=0; j<points[i].length; j++) {
           System.out.println(points[i][j]);
        }
    }
    
    String[] addressStrings = new String[geocodedAddresses.size()];
    for(int i=0; i<addressStrings.length; i++)
    {
      GeocoderAddress geocoderAddress = geocodedAddresses.get(i);
      double[] coordinates = geocoderAddress.getCoordinates();
        System.out.println("Coordinates");
        for (int k=0; k<coordinates.length; k++) {
            System.out.print(coordinates[k]+" ; ");
        }
        System.out.println();
          
      addressStrings[i] = geocoderAddress.getHouseNumber()+" "+
                          geocoderAddress.getStreet()+", "+
                          //geocoderAddress.getSettlement()+", "+
                          //geocoderAddress.getOrder1()+" "+
                          geocoderAddress.getPostalCode();
    }
    return new Locations(points, addressStrings);
  }

  private GeocoderAddress parseAddress(String address)
  {
    if(isStreetAddress(address)) {
      return parseStreetAddressDetailed(address);
    }
    else {
      return parseCoordinates(address);
    }
  }

  private boolean isStreetAddress(String address)
  {
    char[] chars = address.toCharArray();
    for(int i=0; i<chars.length; i++)
    {
      if('a'<chars[i] && chars[i]<'z' ||
         'A'<chars[i] && chars[i]<'Z')
        return true;
    }
    return false;
  }

   private GeocoderAddress parseStreetAddress(String address)
  {
    GeocoderAddress ga = new GeocoderAddress();
    StringTokenizer st = new StringTokenizer(address, ",");
    //street number and name
    if(st.hasMoreTokens())
      ga.setStreet(st.nextToken());
    String lastLine = null;
    if(st.hasMoreTokens())
      lastLine = st.nextToken();
    while(st.hasMoreTokens())
      lastLine += ", " + st.nextToken();
    ga.setLastLine(lastLine);
    return ga;
  }

  private GeocoderAddress parseStreetAddressDetailed(String address) {
      GeocoderAddress ga = new GeocoderAddress();
      StringTokenizer st = new StringTokenizer(address, ",");
      String str = null;
      //street number and street name
      if (st.hasMoreTokens()) {
          str = st.nextToken();
          ga.setStreet(str);
      }
      //City name
      if (st.hasMoreTokens()) {
          str = st.nextToken();
          ga.setSettlement(str);
      }
      //Country name
      if (st.hasMoreTokens()) {
          str = st.nextToken();
          String countryCode2 = CountryNameTable.getCountryCode2(str);
          ga.setCountry(countryCode2);
      }
      //Postal code
      if(st.hasMoreTokens()) {
          str = st.nextToken();
          ga.setPostalCode(str);
      }
      
      return ga;
  }

  private GeocoderAddress parseCoordinates(String address)
  {
    if(address==null || address.trim().length()==0)
      return null;
    GeocoderAddress ga = new GeocoderAddress();
    StringTokenizer st = new StringTokenizer(address, ",\t ");
    double lat=0, lon=0;  //lon,lat; //x,y;
    if(st.hasMoreTokens())
      lon = Double.parseDouble(st.nextToken());
    if(st.hasMoreTokens())
      lat = Double.parseDouble(st.nextToken());
    ga.setCoordinates(lon, lat);
    return ga;
  }    
  
  public static class Locations
  {
    private PointOnNet[][] points;
    private String[] addresses;

    public Locations(PointOnNet[][] points, String[] addresses)
    {
      this.points = points;
      this.addresses = addresses;
    }

    public PointOnNet[][] getPoints()
    {
      return points;
    }

    public String[] getAddresses()
    {
      return addresses;
    }
  } 

    /**
   * Returns an Nx1 double array.
   * @param points
   */
  public static PointOnNet[][] toDoubleArray(PointOnNet[] points)
  {
    PointOnNet[][] da = new PointOnNet[points.length][1];
    for(int i=0; i<points.length; i++)
      da[i][0] = points[i];
    return da;
  }
  
  //Separates dbUrl into host name, port, sid in that order;
  private String[] parseGeocoderConnInputs(String dbUrl) {
  
    String[] geocoderConnInputs = new String[3];
    String str = null;
    StringTokenizer inputUrl = new StringTokenizer(dbUrl,":@");
    if (inputUrl.hasMoreTokens()) 
        str = inputUrl.nextToken();
    if (inputUrl.hasMoreTokens())
        str = inputUrl.nextToken();
    if (inputUrl.hasMoreTokens()) 
        str = inputUrl.nextToken();
    if (inputUrl.hasMoreTokens()) 
        geocoderConnInputs[0] = inputUrl.nextToken();
    if (inputUrl.hasMoreTokens())
        geocoderConnInputs[1] = inputUrl.nextToken();
    if (inputUrl.hasMoreTokens())
        geocoderConnInputs[2] = inputUrl.nextToken();

    return geocoderConnInputs;    
  }
  
}
