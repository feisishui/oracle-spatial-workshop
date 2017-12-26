/*
 * @(#)SdoTest.java 1.0 06-Aug-2003
 *
 * This class implements a number of geometry testing functions. Those
 * functions are designed to be used as stored procedures inside an Oracle
 * database.

   boolean  hasCircularArcs()              Checks if this geometry is a compound one.
   boolean  isCircle()                     Checks if this geometry represents a circle.
   boolean  isGeodeticMBR()                Checks if this geometry represents a geodetic MBR.
   boolean  isLRSGeometry()                Checks if this is a LRS (Linear Reference System) geometry.
   boolean  isPoint()                      Checks if this geometry is of point type.
   boolean  isMultiPoint()                 Checks if this geometry is of Multi-Point type.
   boolean  isOrientedPoint()              Checks if this geometry is of point type and oriented.
   boolean  isOrientedMultiPoint()         Checks if this geometry is of Multi-Point type and oriented.
   boolean  isRectangle()                  Checks if this geometry represents a rectangle.

 */

import java.io.*;
import java.sql.*;
import java.util.*;
import oracle.jdbc.driver.*;
import oracle.sql.*;
import oracle.spatial.geometry.JGeometry;

public class SdoTest {

  public static String hasCircularArcs (STRUCT sdoGeometry)
    throws Exception
  {
    // Import geometry object from the input structure
    JGeometry geometry = JGeometry.load(sdoGeometry);
    // Test the geometry
    boolean b = geometry.hasCircularArcs();
    if (b)
      return "TRUE";
    else
      return "FALSE";
  }

  public static String isCircle (STRUCT sdoGeometry)
    throws Exception
  {
    // Import geometry object from the input structure
    JGeometry geometry = JGeometry.load(sdoGeometry);
    // Test the geometry
    boolean b = geometry.isCircle();
    if (b)
      return "TRUE";
    else
      return "FALSE";
  }

  public static String isGeodeticMBR (STRUCT sdoGeometry)
    throws Exception
  {
    // Import geometry object from the input structure
    JGeometry geometry = JGeometry.load(sdoGeometry);
    // Test the geometry
    boolean b = geometry.isGeodeticMBR();
    if (b)
      return "TRUE";
    else
      return "FALSE";
  }

  public static String isLRSGeometry (STRUCT sdoGeometry)
    throws Exception
  {
    // Import geometry object from the input structure
    JGeometry geometry = JGeometry.load(sdoGeometry);
    // Test the geometry
    boolean b = geometry.isLRSGeometry();
    if (b)
      return "TRUE";
    else
      return "FALSE";
  }

  public static String isPoint (STRUCT sdoGeometry)
    throws Exception
  {
    // Import geometry object from the input structure
    JGeometry geometry = JGeometry.load(sdoGeometry);
    // Test the geometry
    boolean b = geometry.isPoint();
    if (b)
      return "TRUE";
    else
      return "FALSE";
  }

  public static String isMultiPoint (STRUCT sdoGeometry)
    throws Exception
  {
    // Import geometry object from the input structure
    JGeometry geometry = JGeometry.load(sdoGeometry);
    // Test the geometry
    boolean b = geometry.isMultiPoint();
    if (b)
      return "TRUE";
    else
      return "FALSE";
  }

  public static String isOrientedPoint (STRUCT sdoGeometry)
    throws Exception
  {
    // Import geometry object from the input structure
    JGeometry geometry = JGeometry.load(sdoGeometry);
    // Test the geometry
    boolean b = geometry.isOrientedPoint();
    if (b)
      return "TRUE";
    else
      return "FALSE";
  }

  public static String isOrientedMultiPoint (STRUCT sdoGeometry)
    throws Exception
  {
    // Import geometry object from the input structure
    JGeometry geometry = JGeometry.load(sdoGeometry);
    // Test the geometry
    boolean b = geometry.isOrientedMultiPoint();
    if (b)
      return "TRUE";
    else
      return "FALSE";
  }

  public static String isRectangle (STRUCT sdoGeometry)
    throws Exception
  {
    // Import geometry object from the input structure
    JGeometry geometry = JGeometry.load(sdoGeometry);
    // Test the geometry
    boolean b = geometry.isRectangle();
    if (b)
      return "TRUE";
    else
      return "FALSE";
  }

}
