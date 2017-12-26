/*
 * @(#)SdoLoadCityGML.java 2.0 12-Nov-2008
 *
 * This program reads a CityGML document and loads it into a database table.
 * It breaks the input GML document into individual fragments, one fragment
 * for each building (cityObjectMember). Each fragment (= each building) is
 * loaded as a separate table row.
 *
 * Each row will contain the 3D geometry of the building, as well as a copy
 * the XML element for that building.
 *
 * Arguments:
 *
 *     -host      name of the server that hosts the database (default: localhost)
 *     -port      database listener port (default: 1521)
 *     -sid       database name (default: orcl)
 *     -driver    kind of JDBC driver to use (default: thin)
 *     -user      user name
 *     -password  password for that user
 *     -geomtable name of the table to load into.
 *     -geomcol   name of the geometry column (default: GEOM)
 *     -xmlcol    name of xml column (default: XML)
 *     -idcol     name of the identification column (default: ID)
 *     -gmlidcol  name of the name column (default: GMLID)
 *     -inpfile   name of the input file
 *     -commit    commmit frequency (default is 0 = commit once at the end)
 *
 * The program will create the database table (and drop it it already exists).
 *
 */

import java.io.*;
import java.util.*;
import oracle.jdbc.*;
import java.sql.*;
import oracle.spatial.util.*;
import oracle.spatial.geometry.*;
import oracle.sql.*;
import oracle.xml.parser.v2.*;
import org.w3c.dom.*;
import org.xml.sax.*;

public class SdoLoadCityGML
{

  private static String   host        = "localhost";
  private static String   port        = "1521";
  private static String   sid         = "orcl";
  private static String   driver      = "thin";
  private static String   user        = "scott";
  private static String   password    = "tiger";
  private static String   geomTable   = "geometries";
  private static String   geomCol     = "geom";
  private static String   xmlCol      = "xml";
  private static String   idCol       = "id";
  private static String   gmlidCol    = "gmlid";
  private static String   inpfile     = "CityGMLToSDO.gml";
  private static int      srid        = 0;
  private static int      commit      = 0;
  private static boolean  verbose     = false;
  private static Connection connection = null;

  /*************************************************************************/
  /*  Display program usage                                                */
  /*************************************************************************/
  static private String usage() {
    return
        "Usage: java SdoLoadCityGML \n" +
        "  -host <host name> [localhost]\n" +
        "  -port <port number> [1521]\n" +
        "  -sid <database SID> [orcl]\n" +
        "  -driver <type of jdbc driver> [thin]\n" +
        "  -user <user name> [scott]\n" +
        "  -password <password> [tiger]\n" +
        "  -geomtable <name of table to load into>\n" +
        "  -geomcol <name of geometry column> [geom]\n" +
        "  -srid <coordinate system of result geometry column> [null]\n" +
        "  -xmlcol <name of xml column> [xml]\n" +
        "  -idcol <name of id column> [id]\n" +
        "  -gmlidcol <name of gmlid column> [gmlid]\n" +
        "  -inpfile <name of input file>\n" +
        "  -commit <commmit frequency> [O]";
  }

  /*************************************************************************/
  /*  Parse command line arguments                                         */
  /*************************************************************************/
  private static void processCmdLineArgs(String[] args)
  {
    if ( args.length > 0  )   {
      for ( int i = 0 ; i < args.length ;i++ ) {
        if ( args[i].equalsIgnoreCase("-host") )
          host = args[++i];
        else if ( args[i].equalsIgnoreCase("-port") )
          port = args[++i];
        else if ( args[i].equalsIgnoreCase("-sid") )
          sid = args[++i];
        else if ( args[i].equalsIgnoreCase("-driver") )
          driver = args[++i];
        else if ( args[i].equalsIgnoreCase("-user") )
          user = args[++i];
        else if ( args[i].equalsIgnoreCase("-password") )
          password = args[++i];
        else if ( args[i].equalsIgnoreCase("-file") )
          inpfile = args[++i];
        else if ( args[i].equalsIgnoreCase("-table") )
          geomTable = args[++i];
        else if ( args[i].equalsIgnoreCase("-geomcol") )
          geomCol = args[++i];
        else if ( args[i].equalsIgnoreCase("-srid") )
          srid = Integer.valueOf(args[++i]);
        else if ( args[i].equalsIgnoreCase("-xmlcol") )
          xmlCol = args[++i];
        else if ( args[i].equalsIgnoreCase("-idcol") )
          idCol = args[++i];
        else if ( args[i].equalsIgnoreCase("-gmlidcol") )
          gmlidCol = args[++i];
        else if ( args[i].equalsIgnoreCase("-commit") )
          commit = Integer.parseInt(args[++i]);
        else if ( args[i].equalsIgnoreCase("-v") )
          verbose = true;
        else if ( args[i].equalsIgnoreCase("-h") )
        {
           System.out.println(usage());
           System.exit(0);
        }
      }
    }
    else {
     System.out.println(usage());
     System.exit(0);
    }
  }
  /*************************************************************************/
  /*  Establish database connection                                        */
  /*************************************************************************/
  public static void setConnection(String driver, String host, String port, String sid, String user, String password) {
    String connectString =
        "jdbc:oracle:" + driver + ":@"
      + "(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(HOST="
      +  host + ")"
      + "(PROTOCOL=tcp)(PORT="
      + port + ")))"
      + "(CONNECT_DATA=(SID="
      + sid + ")))";

    try {
      System.out.println ("Connecting to database " + connectString);
      DriverManager.registerDriver(new OracleDriver());
      connection = DriverManager.getConnection(
                     connectString, user, password);

    }
    catch (Throwable t) {
      System.out.println(t.toString() + ": \n" + t.getMessage() + "Error attempting to connect to database");
      System.out.println("Exiting");
      System.exit(-1);
    }
  }

  public static Connection getConnection() { return connection; }

  /*************************************************************************/
  /*  Create or replace database table                                     */
  /*************************************************************************/
  private static void createTable (String geomTable, String idCol, String gmlidCol, String geomCol, String xmlCol)
    throws SQLException
  {
    final Connection conn = getConnection();

    // Drop existing table first
    System.out.println ("Dropping old table...");
    PreparedStatement stmt;
    try {
      stmt = conn.prepareStatement("DROP TABLE "+geomTable);
      stmt.execute();
    }
    catch (SQLException e) {
      // If table does not exist, ignore the exception
      if (e.getErrorCode() != 942)
        throw (e);
    }

    // Construct the "CREATE TABLE" statement
    String createTableSql =
      "CREATE TABLE " + geomTable + "(" +
        idCol + " NUMBER PRIMARY KEY," +
        gmlidCol + " VARCHAR2(30)," +
        geomCol + " SDO_GEOMETRY," +
        xmlCol + " XMLTYPE" +
      ")";
    // Create the table
    System.out.println ("Creating new table...");
    if (verbose)
      System.out.println (createTableSql);
    stmt = conn.prepareStatement(createTableSql);
    stmt.execute();
    }

  /*************************************************************************/
  /*  Convert XML document to a CLOB                                       */
  /*************************************************************************/
  private static CLOB getCLOB(XMLDocument d, Connection conn) throws SQLException{
        CLOB tempClob = null;
        String xmlData;
        try{
          // If the temporary CLOB has not yet been created, create new
          tempClob = CLOB.createTemporary(conn, true, CLOB.DURATION_SESSION);

          // Open the temporary CLOB in readwrite mode to enable writing
          tempClob.open(CLOB.MODE_READWRITE);
          // Get the output stream to write
          Writer tempClobWriter = null;
          tempClobWriter = tempClob.getCharacterOutputStream(0);
          // Write the data into the temporary CLOB
          d.print(tempClobWriter);
          //tempClobWriter.write(xmlData);

          // Flush and close the stream
          tempClobWriter.flush();
          tempClobWriter.close();

          // Close the temporary CLOB
          tempClob.close();
        } catch(SQLException sqlexp){
          tempClob.freeTemporary();
          sqlexp.printStackTrace();
        } catch(Exception exp){
          tempClob.freeTemporary();
          exp.printStackTrace();
        }
        return tempClob;
      }

  /*************************************************************************/
  /*  Write one geometry to the database table                             */
  /*************************************************************************/
  public static void writeGeometry (int rowNumber, String gmlId, JGeometry gm, XMLDocument d)
    throws IOException
  {
    final Connection conn = getConnection();
    PreparedStatement  stmt = null;
    String sqlStr = " insert into "+ geomTable + " values (?, ?, ?, XMLTYPE(?))";
    try
    {
      if (verbose)
        System.out.println(sqlStr);

      stmt = conn.prepareCall(sqlStr);
      STRUCT dbobj = JGeometry.store(gm, conn);
      CLOB clob = getCLOB(d, conn);

      stmt.setInt (1, rowNumber);
      stmt.setString (2, gmlId);
      stmt.setObject (3, dbobj);
      stmt.setObject(4, clob);
      stmt.executeUpdate();

      // Commit if needed
      if (commit > 0)
        if (rowNumber % commit == 0) {
          System.out.println (rowNumber + " rows inserted");
          conn.commit();
        }
    }
    catch ( SQLException e1 ) {
      System.out.println("Error: "+e1.getMessage());
    }
    finally {
      try {
        if (stmt !=null) {
          stmt.close(); stmt = null;
        }
      }
      catch ( SQLException e ) {}
    }
  }

  /*************************************************************************/
  /*  Parsing helper functions                                             */
  /*************************************************************************/
  private static  boolean match(String ndName, String geometryTypes[]) {

    int len = geometryTypes.length;
    for(int i=0; i< len; i++)
      if (ndName.equalsIgnoreCase(geometryTypes[i]))
        return true;
    return false;
  }

  public static Vector getGeometry(
    Node    start,
    String  geometryTypes[])
  {
    Vector<Node> result = new Vector<Node>();
    getGeometry(start, geometryTypes, result);
    return result;
  }

  public static void getGeometry(
    Node    start,
    String  geometryTypes[],
    Vector<Node>  result)
  {
    for(Node child = start.getFirstChild();
         child != null;
         child = child.getNextSibling())
     {
       String str = new String(child.getNodeName());
       //System.out.println(str);
       if(match(str, geometryTypes))
       //normalize(child.getNodeName()).equalsIgnoreCase(path[posInPath]))
       {
           result.add(child);
       }
       else
         getGeometry(child, geometryTypes, result);
     }
  }

  public static XMLDocument getXMLDocFromNode(Node nd) throws IOException {
    XMLDocument d =  new XMLDocument();
    Node dRoot = d.importNode(nd, true);
    d.appendChild(dRoot);
    return d;
  }

  /*************************************************************************/
  /*  Main                                                                 */
  /*************************************************************************/
  public static void main(String args[])
    throws FileNotFoundException, SQLException, IOException, SAXException {

    String gmlId = null;

    processCmdLineArgs(args);

    setConnection (driver, host, port, sid, user, password);

    createTable (geomTable, idCol, gmlidCol, geomCol, xmlCol);

    DOMParser parser = new DOMParser();
    parser.parse(new FileInputStream(inpfile));
    XMLDocument doc = parser.getDocument();
    NodeList ndlst =  doc.getElementsByTagName("cityObjectMember");

    int ndlen = ndlst.getLength(); // ndlen: number of cityObjectMembers

    System.out.println ("Loading " + ndlen + " objects");

    for(int i=0; i<ndlen; i++)
    {
      // Get cityObjectMember node
      Node nd = (Node) ndlst.item(i);

      // Get the Building element
      XMLDocument d0 = getXMLDocFromNode(nd);
      NodeList ndlst0 =  d0.getElementsByTagName("Building");
      Node nd0 = (Node) ndlst0.item(0);

      // Extract gml:id attribute
      boolean b = nd0.hasAttributes();
      NamedNodeMap n = nd0.getAttributes();
      for (int k=0; k<n.getLength(); k++) {
        Node sn = n.item(k);
        gmlId = sn.getNodeValue();
      }

      XMLDocument d = getXMLDocFromNode(nd);

      Vector v = getGeometry(nd, new String[] {"gml:Solid", "gml:MultiSurface", "gml:Polygon"});

      for(int j=0; j<v.size(); j++) {
        Node descNd = (Node) v.get(j);

        XMLDocument d2 = getXMLDocFromNode(descNd);
        JGeometry gm = null;
        try {
          gm = oracle.spatial.util.GML3g.fromNodeToGeometry(descNd);
        } catch (Exception ex) {ex.printStackTrace();}

        if (srid > 0)
          gm.setSRID(srid);

        writeGeometry(i+1, gmlId, gm, d);
      }
    }

    System.out.println (ndlen + " rows inserted");
    Connection conn = getConnection();
    conn.commit();

    conn.close();

  }
}
