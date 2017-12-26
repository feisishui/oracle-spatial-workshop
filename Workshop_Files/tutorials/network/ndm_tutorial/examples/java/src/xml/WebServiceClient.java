/* $Header: WebServiceClient.java 26-jun-2007.11:12:17 hgong Exp $ */

/* Copyright (c) 2007, Oracle. All rights reserved.  */

/*
   DESCRIPTION
    <short description of component this file declares/defines>

   PRIVATE CLASSES
    <list of private classes defined - with one-line descriptions>

   NOTES
    <other useful comments, qualifications, etc.>

   MODIFIED    (MM/DD/YY)
    hgong       06/26/07 - add package xml
    hgong       06/01/07 - Creation
 */

package xml;

import java.io.BufferedReader;
import java.io.DataOutputStream;

import java.io.InputStream;
import java.io.InputStreamReader;

import java.net.HttpURLConnection;
import java.net.URL;

import oracle.spatial.util.Logger;

/**
 *  This class demonstrates how to call NDM XML API as a web service client.
 *  
 *  @version $Header: WebServiceClient.java 26-jun-2007.11:12:17 hgong Exp $
 *  @author  hgong
 *  @since   11gR1
 */

public class WebServiceClient 
{  
  URL url = null;
  
  public WebServiceClient(String ndmServerUrl) throws Exception
  {
    url = new URL(ndmServerUrl);
  }

  private void testWebServiceRequest(String requestXmlFile)
  {
    HttpURLConnection conn = null;
    try{
      InputStream in = ClassLoader.getSystemResourceAsStream(requestXmlFile);
      BufferedReader br = new BufferedReader(new InputStreamReader(in));
      StringBuffer sb = new StringBuffer();
      String line;
      for(line=br.readLine(); line!=null; line=br.readLine())
      {
        sb.append(line).append('\n');
      }
      String request = sb.toString();
      
      System.out.println("Request = \n"+request);
      
      //send request
      conn = (HttpURLConnection)url.openConnection();
      conn.setRequestMethod("POST");
      conn.setUseCaches(false);
      conn.setDoInput(true);
      conn.setDoOutput(true);
      conn.setRequestProperty("CONTENT-TYPE", "text/xml");
      conn.setRequestProperty("Content-Length", "" + request.getBytes().length);
      DataOutputStream out = new DataOutputStream( conn.getOutputStream() );
      out.writeBytes(request);
      out.flush();
      out.close();
      
      //get response
      BufferedReader reader = new BufferedReader( new InputStreamReader(
                                                  conn.getInputStream() ) );
      System.out.println("Response = \n");
      for(String responseln = reader.readLine(); 
          responseln!=null; 
          responseln = reader.readLine())      
      {
        System.out.println( responseln );
      }
    }
    catch(Exception ex)
    {
      ex.printStackTrace();
    }
    if(conn!=null)
      conn.disconnect();
  }
  
  public static void main(String[] args)
  {
    String host        = "localhost";
    int port           = 8888;
    String requestXmlFile = "xml/shortestPathRequest.xml";

    //get input parameters
    for(int i=0; i<args.length; i++)
    {
      if(args[i].equalsIgnoreCase("-host"))
        host = args[i];
      else if(args[i].equalsIgnoreCase("-port"))
        port = Integer.parseInt(args[i+1]);
      else if(args[i].equalsIgnoreCase("-requestXmlFile"))
        requestXmlFile = args[i+1];
    }
    
    try
    {
      Logger.setGlobalLevel(Logger.LEVEL_WARN);
      String ndmServerUrl = "http://"+host+":"+port+
          "/SpatialWS-SpatialWS-context-root/SpatialWSXmlServlet";
      WebServiceClient tester = new WebServiceClient(ndmServerUrl);
      
      tester.testWebServiceRequest(requestXmlFile);
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
  }

}
