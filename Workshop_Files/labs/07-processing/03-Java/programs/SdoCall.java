/*
 * @(#)SdoCall.java 1.0 3-Sep-2003
 *
 * This program illustrates the way to call PL/SQL stored functions or
 * procedures, when those functions or procedures return SDO_GEOMETRY objects.
 *
 * It uses the Java API for Oracle Spatial supplied with
 * version 10.1 of the Oracle Server (class JGeometry)
 *
 * The program lets you specify connection parameters to a database:
 *   - a JDBC connect string (jdbc:oracle:thin:@server:port:sid)
 *   - a user name
 *   - a password
 * as well as the full syntax of the procedure to call, which is sent
 * directly for execution by the database. This call must be to a function
 * that returns an SDO_GEOMETRY object, or to a procedure with one output
 * parameter of type SDO_GEOMETRY.
 *
 * For example, assuming that the following procedures have been declared in
 * the database:

 *   CREATE OR REPLACE FUNCTION EXAMPLE_FUNC (P_COUNTY VARCHAR2) RETURN SDO_GEOMETRY AS
 *     G SDO_GEOMETRY;
 *   BEGIN
 *     SELECT GEOM INTO G FROM US_COUNTIES WHERE COUNTY = P_COUNTY;
 *     RETURN G;
 *   END;
 *
 *   CREATE OR REPLACE PROCEDURE EXAMPLE_PROC (P_COUNTY IN VARCHAR2, P_GEOM OUT SDO_GEOMETRY) AS
 *   BEGIN
 *     SELECT GEOM INTO P_GEOM FROM US_COUNTIES WHERE COUNTY = P_COUNTY;
 *   END;
 *
 * Both procedures perform the same operation: they fetch a geometry from a table and return
 * it to the caller.
 *
 * Here are some examples on how to use the above examples:
 *
 *   Procedure calls:
 *      SQL-92 syntax:  "{call example_proc ('Denver', ?)}"
 *      Oracle syntax:  "begin example_proc ('Denver', :1); end;"
 *
 *   Function calls:
 *      SQL-92 syntax:  "{? = call example_func ('Denver')}"
 *      SQL-92 syntax:  "begin :1 := example_func ('Denver'); end;"
 *
 */

import java.io.*;
import java.sql.*;
import java.util.*;
import oracle.jdbc.driver.*;
import oracle.sql.*;
import oracle.spatial.geometry.*;

public final class SdoCall
{

  public static void main(String args[]) throws Exception
  {

    System.out.println ("SdoCall - Oracle Spatial (SDO) procedure call tests");

    // Check and process command line arguments

    if (args.length != 4) {
      System.out.println ("Parameters:");
      System.out.println ("<Connection>:  JDBC connection string");
      System.out.println ("               e.g: jdbc:oracle:thin:@server:port:sid");
      System.out.println ("<User>:        User name");
      System.out.println ("<Password>:    User password");
      System.out.println ("<Procedure>:   Stored procedure to call");
      return;
    }

    String connectionString  = args[0];
    String userName          = args[1];
    String userPassword      = args[2];
    String procExec          = args[3];

    // Register the Oracle JDBC driver
    DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());

    // Get a connection to the database
    System.out.println ("Connecting to database '"+connectionString+"'");
    Connection dbConnection = DriverManager.getConnection(connectionString, userName, userPassword);
    System.out.println ("Got a connection: "+dbConnection.getClass().getName());
    System.out.println ("Using JDBC Driver Version: " + dbConnection.getMetaData().getDriverVersion());
    System.out.println ("Database Version:" + dbConnection.getMetaData().getDatabaseProductVersion());

    // Perform the database query
    callProcedure(dbConnection, procExec);

    // Close database connection
    dbConnection.close();
  }

  static void callProcedure(Connection dbConnection, String procExec)
    throws Exception
  {
    JGeometry geom;

    // Construct SQL query
    System.out.println ("Executing procedure: '"+procExec+"'");

    // Execute query
    CallableStatement stmt = dbConnection.prepareCall(procExec);

    // Register output parameters
    stmt.registerOutParameter(1, Types.STRUCT, "MDSYS.SDO_GEOMETRY");

    // Execute statement
    stmt.executeUpdate();

    // Extract JDBC object from record into structure
    STRUCT dbObject = (STRUCT) stmt.getObject(1);

    if (dbObject != null) {

      // Import from structure into Geometry object
      geom = JGeometry.load(dbObject);

      // Print out geometry info
      System.out.println ("Geometry info:");
      System.out.println (" Type:            " + geom.getType());
      System.out.println (" SRID:            " + geom.getSRID());
      System.out.println (" Dimensions:      " + geom.getDimensions());
      System.out.println (" NumPoints:       " + geom.getNumPoints());

      // Print out geometry in SDO_GEOMETRY format
      System.out.println (toStringGeom(geom));
    } else
      System.out.println ("Geometry is NULL");

    // Close statement
    stmt.close();
  }

 static String toStringGeom (JGeometry geom)
  {
    String fg;

    // extract details from jGeometry object
    int gType =               geom.getType();
    int gSRID =               geom.getSRID();
    int gDimensions =         geom.getDimensions();
    boolean isPoint =         geom.isPoint();
    // point
    double gPoint[]  =        geom.getPoint();
    // element info array
    int gElemInfo[] =         geom.getElemInfo();
    // ordinates array
    double gOrdinates[] =     geom.getOrdinatesArray();

    // Format jGeometry in SDO_GEOMETRY format
    int sdo_gtype = gDimensions * 1000 + gType;
    int sdo_srid  = gSRID;

    fg = "SDO_GEOMETRY(" + sdo_gtype + ", ";
    if (sdo_srid == 0)
      fg = fg + "NULL, ";
    else
      fg = fg + sdo_srid + ", ";
    if (gPoint == null)
      fg = fg + "NULL), ";
    else {
      fg = fg + "SDO_POINT_TYPE(" + gPoint[0]+", "+gPoint[1]+", ";
      if (gPoint.length < 3)
        fg = fg + "NULL), ";
      else if (java.lang.Double.isNaN(gPoint[2]))
        fg = fg + "NULL), ";
      else
        fg = fg + gPoint[2]+"), ";
    }
    if (!isPoint & gElemInfo != null) {
      fg = fg + "SDO_ELEM_INFO_ARRAY( ";
      for (int i=0; i<gElemInfo.length-1; i++)
        fg = fg +  gElemInfo[i]+", ";
      fg = fg +  gElemInfo[gElemInfo.length-1] + "), ";
    }
    else
      fg = fg + "NULL, ";
    if (!isPoint & gOrdinates != null) {
      fg = fg + "SDO_ORDINATE_ARRAY( ";
      for (int i=0; i<gOrdinates.length-1; i++)
        fg = fg +  gOrdinates[i]+", ";
      fg = fg +  gOrdinates[gOrdinates.length-1] + ")";
    }
    else
      fg = fg + "NULL";
    fg = fg + ")";

    return (fg);
  }

}
