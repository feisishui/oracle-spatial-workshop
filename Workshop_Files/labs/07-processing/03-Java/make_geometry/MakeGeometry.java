/*
 * This class illustrates how to use java to generate geometries from a variety of inputs
 */

import java.io.*;
import java.sql.*;
import java.util.*;
import oracle.jdbc.driver.*;
import oracle.spatial.geometry.JGeometry;



public class MakeGeometry {

  public static void main(String args[]) throws Exception {
    Struct g = line (args[0], 0);
  }

  // Input is a pair of coordinates and a coordinate system identifier (SRID)
  // Output is a geometric point
  public static Struct point (
    float x,
    float y,
    int srid
  )
  throws Exception
  {
    // Construct new geometry
    JGeometry geometry = new JGeometry(x,y,srid);
    // Make it into a java.sql.Struct
    OracleDriver ora = new OracleDriver(); 
    Struct SDOgeometry = JGeometry.storeJS(geometry,ora.defaultConnection()); 
    // Return it
    return SDOgeometry;
  }
  
  // Input is a string that contains coordinates and a SRID.
  //   Each pairs of coordinates are separated by a comma (",")
  //   Coordinates in a pair are separated by a space (" ").
  //   Example: "-85.981201 42.812271, -85.983688 42.812271, -85.98645 42.812271"
  // Output is a 2D geometric line
  public static Struct line (
    String coordinates,
    int srid
  )
  throws Exception
  {
    // Parse input string into coordinate
    String[] l = coordinates.split(",|\\ ");
    double[] c = new double[l.length];
    for (int i=0;i<l.length;i++) {
      c[i] = Double.parseDouble(l[i]);
    }
    // Construct new geometry
    JGeometry geometry = JGeometry.createLinearLineString(c,2,srid);
    // Make it into a java.sql.Struct
    OracleDriver ora = new OracleDriver(); 
    Struct SDOgeometry = JGeometry.storeJS(geometry,ora.defaultConnection()); 
    // Return it
    return SDOgeometry;
  }
  
}
