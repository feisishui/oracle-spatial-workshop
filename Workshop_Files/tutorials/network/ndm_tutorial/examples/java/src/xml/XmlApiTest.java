/* $Header: sdo/demo/network/examples/java/src/xml/XmlApiTest.java /main/9 2013/01/24 13:47:59 hgong Exp $ */

/* Copyright (c) 2007, 2013, Oracle and/or its affiliates. 
All rights reserved. */

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
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;

import java.sql.SQLException;

import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import oracle.jdbc.OracleConnection;
import oracle.jdbc.pool.OracleDataSource;
import oracle.spatial.network.lod.util.XMLUtility;
import oracle.spatial.network.xml.XMLNetworkManager;
import oracle.spatial.util.Logger;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 *  This class demonstrates how to call NDM XML API directly on the server side.
 *  
 *  @version $Header: sdo/demo/network/examples/java/src/xml/XmlApiTest.java /main/9 2013/01/24 13:47:59 hgong Exp $
 *  @author  hgong   
 *  @since   11gR1
 */
public class XmlApiTest
{  
  private static final String NETWORK_ANALYSIS_SCHEMA = 
    "oracle/spatial/network/xml/network.xsd";

  OracleConnection conn = null;
  public XmlApiTest(OracleConnection conn) throws Exception
  {
    this.conn = conn;
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

  private void testXmlRequest(String requestXmlFile)
  {
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
      Element queryElem = XMLUtility.stringToDocument(request).getDocumentElement();
      Element response = 
        XMLNetworkManager.getXMLNetworkManager().performAnalysis(conn, queryElem);
      System.out.println("\nResponse = \n"+xml2String(response));
    }
    catch(Exception ex)
    {
      ex.printStackTrace();
    }
  }
  
  /*private Element stringToElement(String xml, String xsdPath) 
    throws Exception
  {
    URL url = ClassLoader.getSystemResource(xsdPath);
    XSDBuilder xsdBuilder = new XSDBuilder();
    XmlSchema xsd = xsdBuilder.build(url);

    DOMParser parser = new DOMParser();
    parser.setPreserveWhitespace(false);  
    parser.setValidationMode(DOMParser.SCHEMA_VALIDATION);
    parser.setXMLSchema(xsd);
    parser.setErrorStream(System.out);
    parser.parse(new InputSource(new StringReader(xml)));
    XMLDocument doc = parser.getDocument();
    NodeList nodes = doc.getChildNodes();
    Node node;
    for(int i=0; i<nodes.getLength(); i++)
    {
      node = nodes.item(i);
      if(node instanceof XMLElement)
      return (XMLElement)node;
    }
    return null;
  }*/
 
  private static String xml2String(Node node){
    try
    {
      Transformer transformer = TransformerFactory.newInstance().newTransformer();
      transformer.setOutputProperty(OutputKeys.INDENT, "yes");
      DOMSource source = new DOMSource(node);
      ByteArrayOutputStream out = new ByteArrayOutputStream();
      StreamResult result = new StreamResult(out);
      transformer.transform(source, result);
      return out.toString();
    } 
    catch(Exception e)
    {
       e.printStackTrace();
    }
    return null;
  }
 
  public static void main(String[] args)
  {
    String dbUrl       = "jdbc:oracle:thin:@localhost:1521:orcl";
    String dbUser      = "";
    String dbPassword  = "";
    String requestXmlFile = "xml/shortestPathRequest.xml";
        
    //get input parameters
    for(int i=0; i<args.length; i++)
    {
      if(args[i].equalsIgnoreCase("-dbUrl"))
        dbUrl = args[i+1];
      else if(args[i].equalsIgnoreCase("-dbUser"))
        dbUser = args[i+1];
      else if(args[i].equalsIgnoreCase("-dbPassword"))
        dbPassword = args[i+1];
      else if(args[i].equalsIgnoreCase("-requestXmlFile"))
        requestXmlFile = args[i+1];
    }
    
    OracleConnection conn = null;
    
    try
    {
      Logger.setGlobalLevel(Logger.LEVEL_WARN);
      conn = getConnection(dbUrl, dbUser, dbPassword);
      XmlApiTest tester = new XmlApiTest(conn);
      tester.testXmlRequest(requestXmlFile);
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
    finally
    {
      if(conn!=null)
        try{conn.close();} catch(Exception ignore){}
    }
  }

}

