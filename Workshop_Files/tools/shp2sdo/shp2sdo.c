/* Shp2SDO -
*  convert an ESRI shapefile to SQL*Loader control file formatted for
*  Oracle Spatial in the object/relational format
*
*  The results of this application are a number of files
*
*      <prefix>.sql     - creates the table (with the geometry column)
*      <prefix>_sx.sql  - creates the spatial index (rtree)
*      <prefix>.ctl     - control file for the table
*      <prefix>.dat     - data file for the table (only if the data
*                         is in a separate file from the control file)
*
*  Usage : shp2sdo -o shapefile layer -v version -g geom_col -i id_col -n start_nr -p -d -f n
*
* Revision 4.7  20-Feb-2005 Albert Godfrind
*                         -- Implement support for datatype D (date) in DBF file
*                         -- Added documentation on supported datatypes
* Revision 4.6  07-Apr-2004 Albert Godfrind
*                         -- Implement support for datatype F in DBF file
* Revision 4.5  15-Mar-2004 Albert Godfrind
*                         -- Documentation changes only
*                         -- Added documentation on decimal separator
*                         -- Added documentation on character sets
*                         -- Added documentation on reserved words
* Revision 4.4  26-Oct-2003 Albert Godfrind
*                         -- Corrected handling of null (blank) numeric attributes
*                            (see dbfopen.c - DBFReadAttribute() )
*                         -- Added support for null geometries
*                         -- Added support for multi-points
* Revision 4.3  26-Jul-2003 Albert Godfrind
*                         -- Add name to primary key constraint on ID column
*                         -- Changed default database version to 9.2
* Revision 4.2   8-May-2003 Albert Godfrind
*                         -- Fix bug in DetermineRingOrientation
* Revision 4.1  14-Mar-2003 Albert Godfrind
*                         -- Identify outer and inner rings of polygons
*                         -- Orient inner and outer rings following the Oracle Spatial convention.
*                         -- Identify polygon with voids as single-element polygons (type 3)
*                         -- Code cleanup
* Revision 4.0  26-Feb-03 Albert Godfrind
*                         -- Removed support for relational model
*                         -- Generate index creation script
*                         -- Fix handling of long integer attributes
*                            (see dbfopen.c - DBFReadAttribute() )
* Revision 3.2  14-Dec-01 Albert Godfrind
*                         -- Add -t option to control tolerance
*                         -- Changed default database version to 9.0.1
* Revision 3.1  12-Dec-01 Albert Godfrind
*                         -- Output number generation: use %f instead of %g
* Revision 3.0  08-Aug-01 Albert Godfrind
*                         -- Implemented support for 9i
*                         -- Remove workaround for sql*loader bug when loading multi-record varray for 9.0.1
*                         -- Add -l option to control SQL Loader processing mode
*                            (INSERT, APPEND, REPLACE, or TRUNCATE)
* Revision 2.10 07-Aug-01 Albert Godfrind
*                         -- Corrected flag usage: -f for decimals instead of -d
*                         -- Do not print trailing 0 decimals
* Revision 2.9  06-Aug-01 Albert Godfrind
*                         -- Generate 4-digit GTYPES (200x)
*                         -- control precision of ordinates in output data file
* Revision 2.8  01-May-01 Dan Abugov / Albert Godfrind
*                         -- implement -s for srid field (both geom and user_sdo_geom_metadata)
*                         -- implement 8.1.6 support (metadata)
* Revision 2.7  01-Nov-99 Albert Godfrind
*                         -- implement 64K limit per physical record in control file
*                         -- compensate for sql*loader bug when loading multi-record varray
* Revision 2.6  26-Oct-99 Albert Godfrind
*                         -- corrected generation of point data in SDO_ORDINATES
* Revision 2.5  24-Oct-99 Albert Godfrind
*                         -- corrected uppercasing (table names only)
*                         -- added "TRAILING NULLCOLS" to all control files
* Revision 2.4  12-Oct-99 Albert Godfrind
*                         -- added 'verbose' and 'debug' options
*                         -- separate data from control files
*                         -- added option to control point storage for object format
*                         -- create files with geometry as last column
*                         -- automatic generation of ID columns
*                         -- rewrote argument parsing and prompting
*                         -- removed SQLPLUS-specifics from generated SQL scripts
* Revision 2.3  13-Jul-99 Albert Godfrind
*                         -- corrected generation of SDO_GTYPE for compound structures
* Revision 2.2  01-Jul-99 Albert Godfrind
*                         -- Uppercase output table and column name for object model
*                         -- Added prompting for parameters
*                         -- Allow overriding of dimension information
* Revision 2.1  04-May-99 Albert Godfrind
*                         -- Added multi-line output for object model
* Revision 2.0  01-May-99 Albert Godfrind
*                         -- Implemented support for Oracle8i object model
* Revision 1.9  03-Dec-98 Albert Godfrind
*                         -- Ported to NT and Digital OpenVMS
*                         -- Added tracing and debugging messages
*                         -- Added checks on malloc() and realloc()
* Revision 1.8  08-Jan-98 Dan Geringer
*                         -- Removed _ATT suffix from attribute table
* Revision 1.7  17-Dec-97 Dan Geringer
*                         -- Change C++ comment to C comment
*                         -- Removed all trailing blanks from VARCHAR attributes
* Revision 1.6  05-Dec-97 Dan Geringer
*                         -- Added starting GID
*                         -- Fixed geometry extraction and coordinate wrap
*                         -- Removed MAXCODE
*                         -- Integrated DBF file
*                         -- Added APPEND to control files
*                         -- Added NULLIF column_name = BLANKS to control files
*                         -- Added ability to store attributes in _SDOGEOM table
*                         -- .shp, .dbf and .dbx extensions can be lower or upper case
*                         -- Fix point coordinate extraction
* Revision 1.5  07-Aug-97 John F. Keaveney
*                         -- Wrote Version 1 of the utility
*
* Copyright 1997 Oracle Corporation
*  All Rights Reserved
*
*  NOTE: This code was adapted from shpdump.c - a public domain utilitiy.
*  Credits Below.
*
* Copyright (c) 1995 Frank Warmerdam
*
* This code is in the public domain.
*
* $Log: shpdump.c,v $
* Revision 1.4  1995/10/21  03:14:49  warmerda
* Changed to use binary file access.
*
* Revision 1.3  1995/08/23  02:25:25  warmerda
* Added support for bounds.
*
* Revision 1.2  1995/08/04  03:18:11  warmerda
* Added header.
*
*/
#include <time.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "shapefil.h"
#define MAX_DATA_RECORD_LENGTH 65535
#define TRUE 1
#define FALSE 0
#define UNKNOWN -1
#define DEFAULT_DATABASE_VERSION "9.2"
int debug = FALSE;
int verbose = FALSE;

/******************************************************************************
**
**                Macros
**
******************************************************************************/
/******************************************************************************
**
** Routine:     strupr
**
** Description: Make a string upper case.
**
** Parameters:
**      p         - string to process
**
** Returns        - pointer to modified string
**
******************************************************************************/
char *strupr(char *p)
{
  char *q, *v;
  v = q = malloc (strlen(p)+1);
  strcpy (q, p);
  while (*q)
     *(q++) = toupper(*q);
  return v;
}

/******************************************************************************
**
** Routine:     OpenDbfFile
**
** Description: Open dbf file and return handle.
**
** Parameters:
**      shapefile    - Name of shapefile
**
******************************************************************************/
static DBFHandle OpenDbfFile (char *shapefile)
{
  DBFHandle   dbf_fp;
  char        filename[50];
  sprintf (filename, "%s.dbf", shapefile);
  dbf_fp = DBFOpen (filename, "rb");
  if ( dbf_fp == NULL )
  {
     sprintf (filename, "%s.DBF", shapefile);
     dbf_fp = DBFOpen (filename, "rb");
     if ( dbf_fp == NULL )
     {
        printf( "Unable to open:%s\n", filename );
        perror( "Error" );
        exit( 1 );
     }
  }
  return dbf_fp;
}

/******************************************************************************
**
** Routine:     OpenShpFile
**
** Description: Open shape file and return shape file info.
**
** Parameters:
**      shapefile         - Name of shapefile
**      nShapeType        - (out) type of data in the shape file
**      nEntities         - (out) number of geometries in ths shape file
**      adBounds[4]       - (out) bounds of the shape file
**      nGeometryType     - (out) SDO geometry type
**
******************************************************************************/
static SHPHandle OpenShpFile  (
  char  *shapefile,
  int    *nShapeType,
  int    *nEntities,
  double *adBounds,
  int    *nGeometryType
            )
{
  SHPHandle   hSHP;
  char        shp_filename[50];
  sprintf (shp_filename, "%s.shp", shapefile);

  /* Open the shapefile */
  hSHP = SHPOpen( shp_filename, "rb" );
  if( hSHP == NULL )
  {
     printf( "Unable to open:%s\n", shp_filename );
     perror( "Error" );
     exit(1);
  }

  /* Get the type of data in the spape file */
  SHPGetInfo( hSHP, nEntities, nShapeType );

  /* Translate the shapefile object type to an SDO Element Type */
  switch( *nShapeType )
  {
     case SHPT_POINT:
     case SHPT_MULTIPOINT:
        *nGeometryType  = 1 ;
        break ;
     case SHPT_ARC :
        *nGeometryType  = 2 ;
        break ;
     case SHPT_POLYGON :
        *nGeometryType  = 3 ;
        break ;
     default :
        printf( "Unknown Shape Type %d", nShapeType ) ;
        exit( 1 ) ;
  }

  /* Get the bounds of the shape file */
  SHPReadBounds( hSHP, -1, adBounds );
  return hSHP;
}

/******************************************************************************
**
** Routine:     AttributesToSQLScript
**
** Description: Write the attribute columns and types to the SQL script.
**
** Parameters:
**      dbf_fp    - File pointer for DBF file
**      fp        - SQL script file pointer
**
******************************************************************************/
static void AttributesToSQLScript (DBFHandle dbf_fp, FILE *fp)
{
  int          j,
  width,
  decimals;
  char         field_name[50];
  DBFFieldType field_type;

  for (j = 0; j < DBFGetFieldCount (dbf_fp); j++)
  {
     field_type = DBFGetFieldInfo(dbf_fp, j, field_name, &width, &decimals);
     if (verbose)
       printf ("    %16s [%d] Type:%d Size:%d Decimals:%d\n", field_name, j, field_type, width, decimals);
     fprintf (fp, "  %s \t", field_name);
     if (field_type == FTString)
        fprintf (fp, "VARCHAR2(%d), \n", width);
     else if ((field_type == FTInteger) || (field_type == FTDouble))
        fprintf (fp, "NUMBER, \n");
     else if (field_type == FTDate)
        fprintf (fp, "DATE, \n");
     else
        printf ("**ERROR** Field: %s - unrecognized data type %d\n",
               field_name, field_type);
  }
}

/******************************************************************************
**
** Routine:     CreateSQLScript
**
** Description: Create SQL script to create a spatial layer
**              Using the object model:
**               - create the data table with a geometry column
**               - Populate the spatial metadata.
**
** Parameters:  pszPrefix  - prefix for layer name, and SQL script name
**              pszVersion - Oracle version
**              pszGeom    - name of the geometry column
**              pszId      - name of the id column
**              adBounds   - lower and upper bound for x & y in _SDODIM table
**              srid       - the srid field
**              dbf_fp     - DBF file pointer
**
******************************************************************************/
static void CreateSQLScript (
  char* pszPrefix,
  char* pszVersion,
  char* pszGeom,
  char* pszId,
  double* adBounds,
  double tolerance,
  int   srid,
  DBFHandle dbf_fp)
{
  FILE*   pFileHandle ;
  char    szOutFile[ 256 ] ;
  int     i ;
  double  dXTol, dYTol ;
  time_t  timer ;
  char    *szTableName = strupr (pszPrefix);
  char    *szMetadata;

  dXTol = dYTol = tolerance;

  /* Create the SQL file to create tables etc */
  sprintf( szOutFile, "%s.sql", pszPrefix ) ;
  if( ( pFileHandle = fopen( szOutFile, "w" ) ) == NULL )
  {
     printf( "Unable to create \"%s\"\n", szOutFile ) ;
     perror( "Error" );
     exit( 1 ) ;
  }

  fprintf( pFileHandle,
         "-- File: %s.sql - Oracle version: %s\n"
         "--\n"
         "--   This script creates the spatial layer and populates the spatial metadata.\n"
         "--\n"
         "--   To load the table, run SQL*Loader with these parameters:\n"
         "--       USERID=username/password CONTROL=%s.ctl\n"
         "--\n"
         "--   After the data is loaded in the %s table, \n"
         "--   create the spatial index by running script %s_sx.sql\n"
         "--\n", pszPrefix, pszVersion, pszPrefix, pszPrefix, pszPrefix ) ;
  time( &timer );
  fprintf( pFileHandle, "-- Creation Date : %s", ctime( &timer ) ) ;
  fprintf( pFileHandle, "-- Copyright 2003 Oracle Corporation\n" ) ;
  fprintf( pFileHandle, "-- All rights reserved\n" ) ;
  fprintf( pFileHandle, "--\n" ) ;
  fprintf( pFileHandle, "DROP TABLE %s;\n", szTableName ) ;
  fprintf( pFileHandle, "\n" ) ;
  fprintf( pFileHandle, "CREATE TABLE %s (\n", szTableName ) ;

  /* Add the id column */
  if (strlen (pszId) != 0)
     fprintf( pFileHandle, "  %s \tNUMBER \n\t\tCONSTRAINT %s_PK PRIMARY KEY, \n", pszId, szTableName);

  /* Add attribute columns  */
  if (dbf_fp != NULL)
    AttributesToSQLScript (dbf_fp, pFileHandle);

  /* Add the geometry column */
  fprintf( pFileHandle, "  %s \tMDSYS.SDO_GEOMETRY", pszGeom);
  fprintf( pFileHandle, ");\n\n" ) ;

  /* Populate the spatial metadata */
  if (strcmp(pszVersion,"8.1.5") == 0)
    szMetadata = "SDO_GEOM_METADATA";
  else
    szMetadata = "USER_SDO_GEOM_METADATA";
  fprintf( pFileHandle,
         "DELETE FROM %s \n"
         "  WHERE TABLE_NAME = '%s' AND COLUMN_NAME = '%s' ;\n\n",
         szMetadata, szTableName, pszGeom ) ;

  if (srid == UNKNOWN)
    fprintf( pFileHandle,
         "INSERT INTO %s (TABLE_NAME, COLUMN_NAME, DIMINFO) \n"
         "  VALUES ('%s', '%s', \n"
         "    MDSYS.SDO_DIM_ARRAY \n"
         "      (MDSYS.SDO_DIM_ELEMENT('X', %f, %f, %.9f), \n"
         "       MDSYS.SDO_DIM_ELEMENT('Y', %f, %f, %.9f)  \n"
         "      ) \n"
         "     ); \n",
         szMetadata,
         szTableName, pszGeom,
         adBounds[ 0 ], adBounds[ 2 ], dXTol,
         adBounds[ 1 ], adBounds[ 3 ], dYTol) ;
  else
    fprintf( pFileHandle,
         "INSERT INTO %s (TABLE_NAME, COLUMN_NAME, DIMINFO, SRID) \n"
         "  VALUES ('%s', '%s', \n"
         "    MDSYS.SDO_DIM_ARRAY \n"
         "      (MDSYS.SDO_DIM_ELEMENT('X', %f, %f, %.9f), \n"
         "       MDSYS.SDO_DIM_ELEMENT('Y', %f, %f, %.9f)  \n"
         "      ), %d \n"
         "     ); \n",
         szMetadata,
         szTableName, pszGeom,
         adBounds[ 0 ], adBounds[ 2 ], dXTol,
         adBounds[ 1 ], adBounds[ 3 ], dYTol,
         srid) ;
  fprintf( pFileHandle,  "COMMIT;\n");
  fclose( pFileHandle ) ;
}

/******************************************************************************
**
** Routine:     CreateSQLScriptIndex
**
** Description: Create SQL script to create a spatial index
**
** Parameters:
**              pszPrefix  - prefix for layer name, and SQL script name
**              pszVersion - Oracle version
**              pszGeom    - name of the geometry column
**
******************************************************************************/
static void CreateSQLScriptIndex (
  char* pszPrefix,
  char* pszVersion,
  char* pszGeom)
{
  FILE*   pFileHandle ;
  char    szOutFile[ 256 ] ;
  int     i ;
  time_t  timer ;
  char    *szTableName = strupr (pszPrefix);

  /* Create the SQL file to create the spatial index */
  sprintf( szOutFile, "%s_sx.sql", pszPrefix ) ;
  if( ( pFileHandle = fopen( szOutFile, "w" ) ) == NULL )
  {
     printf( "Unable to create \"%s\"\n", szOutFile ) ;
     perror( "Error" );
     exit( 1 ) ;
  }

  fprintf( pFileHandle,
         "-- File: %s_sx.sql - Oracle version: %s\n"
         "--\n"
         "--   This script creates the spatial index.\n"
         "--\n", pszPrefix, pszVersion ) ;
  time( &timer );
  fprintf( pFileHandle, "-- Creation Date : %s", ctime( &timer ) ) ;
  fprintf( pFileHandle, "-- Copyright 2003 Oracle Corporation\n" ) ;
  fprintf( pFileHandle, "-- All rights reserved\n" ) ;
  fprintf( pFileHandle, "--\n" ) ;
  fprintf( pFileHandle, "DROP INDEX %s_SX;\n", szTableName ) ;
  fprintf( pFileHandle, "\n" ) ;
  fprintf( pFileHandle, "CREATE INDEX %s_SX ON %s ( %s ) "
                        "INDEXTYPE IS MDSYS.SPATIAL_INDEX;\n", szTableName, szTableName, pszGeom ) ;
  fclose( pFileHandle ) ;
}

/******************************************************************************
**
** Routine:     OneAttributeValueToDataFile
**
** Description: Print one attribute value to the data file
**
** Parameters:
**              dbf_fp    - DBF file pointer
**              fp        - Output file (data or control) pointer
**              row       - Row that contains attribute value
**              col       - Col that contains attribute value
**
******************************************************************************/
static void OneAttributeValueToDataFile (
  DBFHandle dbf_fp,
  FILE *fp,
  int row,
  int col)
{
  char         field_name[50];
  DBFFieldType field_type;
  int          width,
               decimals,
               index,
               char_found,
               i;
  int          *integer_val;
  double       *double_val;
  char         string_val[3000];

  /* Initialize buffer to blanks */
  for (i = 0; i < 3000; i++)
    string_val[i] = ' ';

  field_type = DBFGetFieldInfo(dbf_fp, col, field_name, &width, &decimals);

  if (field_type == FTString) {
    strcpy (string_val, DBFReadStringAttribute(dbf_fp, row, col));
    char_found = 0;
    for (index = width - 1; index >= 0 && !char_found; index--)
      char_found = !(string_val[index] == ' ' || string_val[index] == '\0');
    if (char_found)
      string_val[index + 2] = '\0';
    fprintf (fp, "%s", string_val);
  }
  else if (field_type == FTInteger || field_type == FTDate) {
    if (width <= 9) {
      integer_val = DBFReadIntegerAttribute(dbf_fp, row, col);
      if (integer_val != NULL)
        fprintf (fp, "%d", *integer_val);
    }
    else {
      double_val = DBFReadDoubleAttribute(dbf_fp, row, col);
      if (double_val != NULL)
        fprintf (fp, "%.*f", decimals, *double_val);
    }
  }
  else if (field_type == FTDouble) {
    double_val = DBFReadDoubleAttribute(dbf_fp, row, col);
      if (double_val != NULL)
        fprintf (fp, "%.*f", decimals, *double_val);
  }
  else
     printf ("**ERROR** INVALID TYPE\n");
}

/******************************************************************************
**
** Routine:     AttributesToControlFile
**
** Description: Print attribute names to the control file
**
** Parameters:
**              dbf_fp    - DBF file pointer
**              fp        - Control file pointer
**
******************************************************************************/
static void AttributesToControlFile (
  DBFHandle dbf_fp,
  FILE *fp)
{
 DBFFieldType field_type;
 char         field_name[50];
 int          j,
 width,
 decimals;
 for (j = 0; j < DBFGetFieldCount (dbf_fp); j++)
 {
   field_type = DBFGetFieldInfo(dbf_fp, j, field_name, &width, &decimals);
   fprintf (fp, "   %s", field_name);
   if (field_type == FTString)
     fprintf (fp, " \tNULLIF %s = BLANKS", field_name);
   else if (field_type == FTDate)
     fprintf (fp, "  DATE \"YYYYMMDD\"");
   fprintf (fp,",\n");
 }
}

/******************************************************************************
**
** Routine:     CreateControlFile
**
** Description: Create control file for loading an object layer
**
** Parameters:
**              pszPrefix     - prefix for layer name, and SQL script name
**              nShapeType    - type of shapes in that shape file
**              pszGeom       - name of the geometry column
**              pszId         - name of the id column
**              bPoint        - store points in SDO_POINT
**              bDataInCtl    - keep data in control file
**              srid          - SRID to use
**              loading_mode  - Loading mode for SQL*Loader
**              dbf_fp        - DBF file pointer
**
** Returns:     file pointer for data generation. Can be the control file or
**              a separate data file
**
******************************************************************************/
FILE* CreateControlFile(
  char*       pszPrefix,
  int         nShapeType,
  const char* pszGeom,
  const char* pszId,
  int         bPoint,
  int         bDataInCtl,
  int         srid,
  const char* loading_mode,
  DBFHandle   dbf_fp)
{
  char        szFileName[ 256 ];
  FILE*       pFileHandle ;
  int         i;
  char        *szTableName = strupr (pszPrefix);

  sprintf( szFileName, "%s.ctl", pszPrefix ) ;
  if( ( pFileHandle = fopen( szFileName, "w" ) ) == NULL )
     return NULL ;

  fprintf( pFileHandle, "LOAD DATA \n" ) ;
  if ( bDataInCtl )
     fprintf( pFileHandle, " INFILE *\n" ) ;
  else
     fprintf( pFileHandle, " INFILE %s.dat\n", pszPrefix);
  if (strlen(loading_mode) > 0)
    fprintf( pFileHandle, " %s\n", loading_mode ) ;
  fprintf( pFileHandle, " CONTINUEIF NEXT(1:1) = '#'\n" ) ;
  fprintf( pFileHandle, " INTO TABLE %s\n", szTableName ) ;
  fprintf( pFileHandle, " FIELDS TERMINATED BY '|'\n" ) ;
  fprintf( pFileHandle, " TRAILING NULLCOLS" ) ;
  fprintf( pFileHandle, " (\n" ) ;

  /* ID column */
  if (strlen(pszId) != 0)
     fprintf( pFileHandle, "   %s INTEGER EXTERNAL,\n", pszId);

  /* Attribute */
  AttributesToControlFile (dbf_fp, pFileHandle);

  /* Geometry column */
  fprintf( pFileHandle, "   %s COLUMN OBJECT NULLIF %s.SDO_GTYPE = '*'\n", pszGeom, pszGeom ) ;
  fprintf( pFileHandle, "   (\n");
  fprintf( pFileHandle, "     SDO_GTYPE       INTEGER EXTERNAL, \n" ) ;

  /* Add sdo_srid if wanted */
  if (srid != -1)
     fprintf( pFileHandle, "     SDO_SRID        INTEGER EXTERNAL, \n" ) ;
  if (nShapeType == SHPT_POINT && bPoint)
  {
     fprintf( pFileHandle, "     SDO_POINT COLUMN OBJECT\n" ) ;
     fprintf( pFileHandle, "       (X            FLOAT EXTERNAL, \n" ) ;
     fprintf( pFileHandle, "        Y            FLOAT EXTERNAL) \n" ) ;
  }
  else
  {
     fprintf( pFileHandle, "     SDO_ELEM_INFO   VARRAY TERMINATED BY '|/' \n" ) ;
     fprintf( pFileHandle, "       (X            FLOAT EXTERNAL), \n" ) ;
     fprintf( pFileHandle, "     SDO_ORDINATES   VARRAY TERMINATED BY '|/' \n" ) ;
     fprintf( pFileHandle, "       (X            FLOAT EXTERNAL) \n" ) ;
  }
  fprintf( pFileHandle, "   )");
  fprintf( pFileHandle, "\n)\n" ) ;
  if (bDataInCtl)

  /* data goes in the control file */
     fprintf( pFileHandle, "BEGINDATA\n" ) ;
  else
  {
      /* data goes in its separate file */
     fclose (pFileHandle);
     sprintf( szFileName, "%s.dat", pszPrefix ) ;
     pFileHandle = fopen( szFileName, "w" );
  }

  /* Return handle of file to receive data - control file or new file */
  return pFileHandle ;
}

/******************************************************************************
**
** Routine:     DetermineRingOrientation
**
** Description: Determines the orientation of a polygon ring
**
** Parameters:  padVertices   - ordinates array (2 entries per vertex)
**              nFirstVertex  - number of first vertex of that ring
**              nLastVertex   - number of last vertex of that ring
**
** Return:      nOrientation  - ring orientation
**                -1 = clockwise
**                +1 = counter clockwise
**
** Note:        The vertex array contains two entries per vertex. So the
**              vertex numbered i uses entries i/2 (for the X value) and
**              i/2+1 (for the Y value).
**
******************************************************************************/

static int DetermineRingOrientation (
  double *padVertices,
  int    nFirstVertex,
  int    nLastVertex)
{
  double dOrientation;
  int nImin, nIprev, nInext;
  double dXmin,  dYmin;
  double dXprev, dYprev;
  double dXnext, dYnext;
  int i;

  /* Find the rightmost lowest vertex of the polygon */

  nImin = nFirstVertex*2;
  dXmin = padVertices[nFirstVertex*2];
  dYmin = padVertices[nFirstVertex*2+1];
  for (i=nFirstVertex*2+2; i<nLastVertex*2; i=i+2) {
    if (padVertices[i+1] <= dYmin) {
      if (padVertices[i+1] < dYmin || padVertices[i] > dXmin) {
        nImin = i;
        dXmin = padVertices[i];
        dYmin = padVertices[i+1];
      }
    }
  }

  /* Get X,Y of vertex that precedes this vertex */
  if (nImin == (nFirstVertex*2))
    nIprev = (nLastVertex-1)*2;
  else
    nIprev = nImin-2;
  dXprev = padVertices[nIprev];
  dYprev = padVertices[nIprev+1];

  /* Get X,Y of vertex that follows this vertex */
  nInext = nImin+2;
  dXnext = padVertices[nInext];
  dYnext = padVertices[nInext+1];

  dOrientation = (dXmin - dXprev) * (dYnext - dYprev) - (dXnext - dXprev) * (dYmin - dYprev);

  if (dOrientation == 0) {
    printf( "Panic: Unable to determine ring orientation\n");
    exit( 1 );
  }

  if (debug)
    printf ("Orientation: %f\n", dOrientation);
  if (dOrientation < 0)
    return (-1);
  else
    return (1);
}

/******************************************************************************
**
** Routine:     InvertRingOrientation
**
** Description: Inverts the order of vertices for a polygon ring
**
** Parameters:  padVertices   - ordinates array (2 entries per vertex)
**              nFirstVertex  - number of first vertex of that ring
**              nLastVertex   - number of last vertex of that ring
**
** Note:        The vertex array contains two entries per vertex. So the
**              vertex numbered i uses entries i/2 (for the X value) and
**              i/2+1 (for the Y value).
**
******************************************************************************/

static void InvertRingOrientation (
  double *padVertices,
  int    nFirstVertex,
  int    nLastVertex)
{
  double dX, dY;
  int i,j,k;
  for (i = 1; i < (nLastVertex-nFirstVertex+1)/2; i++) {
    j = (nFirstVertex+i)*2;
    k = (nLastVertex-i)*2;
    dX = padVertices[j];
    dY = padVertices[j+1];
    padVertices[j] = padVertices[k];
    padVertices[j+1] = padVertices[k+1];
    padVertices[k] = dX;
    padVertices[k+1] = dY;
  }
}

/******************************************************************************
**
** Routine:     OneShapeToDataFile
**
** Description: Writes the coordinates of one shape to the date file.
**              Handles multi element geometries.
**
** Parameters:  hSHP          - shape file pointer
**              item          - Nth shape to convert
**              pFileHandle   - Output file pointer (control or data)
**              nShapeType    - Shape type (from shapefile structure)
**              nGeometryType - Geometry type (1 = point, 2 = line, 3 = polygon)
**              gtype_prefix  - GTYPE prefix
**              pszId         - the name of the ID column
**              bPoint        - store points in SDO_POINT
**              srid          - SRID to use
**              nr_decimals   - number of decimals for output coordinates
**              sqlldr_bug    - if TRUE, need to compensate for SQL*loader bug
**              dbf_fp        - DBF file pointer
**
******************************************************************************/
static void OneShapeToDataFile (
  SHPHandle hSHP,
  int       item,
  FILE      *pFileHandle,
  int       gid,
  int       nShapeType,
  int       nGeometryType,
  int       gtype_prefix,
  char      *pszId,
  int       bPoint,
  int       srid,
  int       nr_decimals,
  int       sqlldr_bug,
  DBFHandle dbf_fp)
{
  int    i, j, k, l, p;
  int    nElements;
  int    nFirstVertex;
  int    nLastVertex;
  int    nOrientation;
  int    nRingType;
  int    nElemType;
  int    nInterp;
  int    nVertices, nParts, *panParts;
  int    *panPartOrient = NULL;
  int    nGType;
  char   string[64];
  char   szDataRecord[MAX_DATA_RECORD_LENGTH+1];
  double *padVertices;

  /* Get the vertices of the shape */
  padVertices = SHPReadVertices( hSHP, item, &nVertices, &nParts, &panParts );

  if (debug)
    printf ("DBG: Item:%d Points:%d Parts:%d\n", item, nVertices, nParts);

  fprintf (pFileHandle, " ");

  /* Id column */
  if (strlen (pszId) != 0)
     fprintf (pFileHandle, "%d|", gid);

  /* Attributes */
  if (dbf_fp != NULL)
     for (j = 0; j < DBFGetFieldCount (dbf_fp); j++)
     {
        OneAttributeValueToDataFile (dbf_fp, pFileHandle, item, j);
        fprintf (pFileHandle, "|");
     }

  /* Geometry */

  if (nVertices == 0) {
    /* Geometry is null */
    fprintf( pFileHandle, "*\n");
  }
  else {

    if (nShapeType == SHPT_POINT)
    {
        nGType = gtype_prefix + 1;
        /* Output SDO_GTYPE */
        fprintf( pFileHandle, "%d|", nGType);
        /* If necessary, output SDO_SRID */
        if (srid != UNKNOWN)
          fprintf( pFileHandle, "%d|", srid);

        /* Output point */
        if (bPoint)
            /* This is a single point, stored in SDO_POINT */
            if (nr_decimals == UNKNOWN)
              /* No decimals specified */
              fprintf( pFileHandle, "%f|%f|\n",
                padVertices[0],
                padVertices[1]);
            else
              /* Round to the number of decimals specified */
              fprintf( pFileHandle, "%.*f|%.*f|\n",
                nr_decimals, padVertices[0],
                nr_decimals, padVertices[1]);
         else
            /* This is a single point, stored in SDO_ORDINATES */
            if (nr_decimals == UNKNOWN)
              /* No decimals specified */
              fprintf( pFileHandle, " 1|%d|1|/ %f|%f|/\n",
                nGeometryType,
                padVertices[0],
                padVertices[1]);
            else
              /* Round to the number of decimals specified */
              fprintf( pFileHandle, " 1|%d|1|/ %.*f|%.*f|/\n",
                nGeometryType,
                nr_decimals, padVertices[0],
                nr_decimals, padVertices[1]);
    }
    else
    {
       nElements = nParts;

       if (nShapeType == SHPT_POLYGON) {

       /* For a polygon, determine the orientation of each ring
          Outer rings are oriented in a clockwise direction (negative value)
          Inner rings are oriented in a counter-clockwise direction (positive value)
          Use the count of outer rings as count of elements
          Invert the orientation */

       /* Allocate space for the ring orientation  vector */
         panPartOrient = (int *) malloc(nParts * sizeof(int));

         nElements = 0;

         /* For each ring */
         for (p=0; p< nParts; p++) {

           /* Get number of first vertex for this ring */
           nFirstVertex = panParts[p];

           /* Get number of last vertex */
           if (p == nParts - 1)
             nLastVertex = nVertices - 1;
           else
             nLastVertex = panParts[p+1] - 1;

           /* Get the orientation of this ring */
           nOrientation = DetermineRingOrientation (padVertices, nFirstVertex, nLastVertex);

           /* Count outer rings (clockwise in shape file, negative orientation)
              to determine if this is a single element or multi-element polygon */
           if (nOrientation < 0)
             nElements = nElements + 1;

           /* Save ring orientation in the orientation vector */
           panPartOrient[p] = nOrientation;

           /* Invert the orientation of the ring */
           InvertRingOrientation (padVertices, nFirstVertex, nLastVertex);
         }
       }

       /* Output SDO_GTYPE */
       /* Note that this needs to be set correctly for multi objects
          1 = single point
          2 = single line string
          3 = single polygon
          4 = heterogeneous collection (not used)
          5 = multi point
          6 = multi line string
          7 = multi polygon
       */

       if (nElements > 1 || nShapeType == SHPT_MULTIPOINT)
          nGType = gtype_prefix + nGeometryType + 4;
       else
          nGType = gtype_prefix + nGeometryType;
       fprintf( pFileHandle, "\n#%d|", nGType);

       /* If necessary, output SDO_SRID */
       if (srid != UNKNOWN)
         fprintf( pFileHandle, "%d|", srid);

       /* Element Info Array */
       if (nShapeType == SHPT_MULTIPOINT)
         fprintf( pFileHandle, "%d|%d|%d|", 1, 1, nVertices);
       else
         for (j = 0; j < nParts; j++) {
           if (nShapeType == SHPT_POLYGON)
             if (panPartOrient[j] < 0)
               /* clockwise (negative) orientation in shapefile -> outer ring */
               nElemType = 1003;
             else
               /* counterclockwise (positive) orientation in shapefile -> inner ring */
               nElemType = 2003;
           else
             nElemType = nGeometryType;
           fprintf( pFileHandle, "%d|%d|%d|", abs(panParts[j])*2+1, nElemType, 1);
         }
       fprintf( pFileHandle, "/\n");

       /* Ordinates Array */
       i = 0; /* indexes into the padVertices[] array */
       k = 0; /* counts the number of physical records */
       l = 1; /* counts the length of the current physical record */
       strcpy(szDataRecord, "#");
       for (j = 0; j < nVertices; j++)
       {
           if (nr_decimals == UNKNOWN)
             /* No decimals specified */
             sprintf (string, "%f|%f|",padVertices[i], padVertices[i+1]);
           else
             /* Round to the specified number of decimals */
             sprintf (string, "%.*f|%.*f|", nr_decimals, padVertices[i], nr_decimals, padVertices[i+1]);
           if (l + strlen(string) >= MAX_DATA_RECORD_LENGTH)
           {
               if (k == 0 && sqlldr_bug)
                   /* This is the first of a set of physical records
                   Bug 1078976 prevents SQL*Loader from working correctly when a VARRAY is broken
                   down into multiple physical records. The converter automatically compensates for
                   that problem by inserting a dummy record ("#+) before the first physical record
                   of each VARRAY that needs multiple physical records.
                   Only do this for versions prior to 9.0 */
                 fprintf( pFileHandle, "#+\n");
               /* Write the physical record */
               fprintf( pFileHandle, "%s\n", szDataRecord);
               /* Start new record */
               strcpy(szDataRecord, "#");
               l = 1;
               k++;
           }
           strcat (szDataRecord, string);
           l = l + strlen(string);
           i = i + 2;
       }

       /* Write the last (or only) physical record */
       fprintf( pFileHandle, "%s/\n", szDataRecord);
    }
  }

  if (debug)
  {
     printf ("DBG: item: %d\n", item);
     printf ("DBG: nShapeType: %d\n", nShapeType);
     printf ("DBG: nGeometryType: %d\n", nGeometryType);
     printf ("DBG: nVertices: %d\n", nVertices);
     printf ("DBG: nParts: %d\n", nParts);
     for (i = 0; i < nParts; i++) {
        printf ("DBG: panParts[%d]: %d\n", i, panParts[i]);
        if (nGeometryType == 3)
          printf ("DBG: panPartOrient[%d]: %d\n", i, panPartOrient[i]);
     }
     printf ("\n");
  }

  if (panPartOrient != NULL)
    free (panPartOrient);

}

/******************************************************************************
**
** Routine:     PrintCompletionMessage
**
** Description: Prints a message that the shp2sdo utility has completed.
**
** Parameters:
**              nShapeType             - type of data in the shape file
**              shapes_processed       - Number of shapes processed
**              file_prefix            - Prefix for the .sql and .ctl files
**              data_in_control_file   - data in the control file ?
**
******************************************************************************/
static void PrintCompletionMessage (
  int nShapeType,
  int shapes_processed,
  char *file_prefix,
  int data_in_control_file)
{
  printf( "Conversion complete : %ld ", shapes_processed ) ;
  switch( nShapeType )
  {
     case SHPT_POINT:
     case SHPT_MULTIPOINT:
        printf( "points" ) ;
        break ;
     case SHPT_ARC :
        printf( "linestrings" ) ;
        break ;
     case SHPT_POLYGON :
        printf( "polygons" ) ;
        break ;
  }
  printf( " processed\n" ) ;
  printf ("The following files have been created:\n");;
  printf( "  %s.sql : \t\tSQL script to create the table\n", file_prefix ) ;
  printf( "  %s_sx.sql : \tSQL script to create the spatial index\n", file_prefix ) ;
  printf( "  %s.ctl : \t\tControl file for loading the table\n", file_prefix ) ;
  if (!data_in_control_file)
     printf( "  %s.dat : \t\tData file\n", file_prefix ) ;
}

/******************************************************************************
**
** Routine:     ProcessGeometries
**
** Description: Create SQL scripts and .CTL files for SDO schema that will
**              contain the shape file coordinates
**
** Parameters:
**              shapefile             - Shape filename without any suffix
**              outprefix             - Prefix for the .sql and .ctl files
**              geo_column            - name of geometry column
**              id_column             - name of id column
**              gid                   - start sdo_gid
**              override_bounds       - 0 if using the actual bounds stored in the shape
**              data_in_control_files - 0 if storing in separate .DAT file
**                                      file. 1 if bounds are overriden by the user
**              Xmin, Xmax            - X dimension bounds
**              Ymin, Ymax            - Y dimension bounds
**              tolerance             - Tolerance setting
**              srid                  - SRID to use
**              nr_decimals           - Number of decimals for output coordinates
**              loading_mode          - Loading mode for SQL*Loader
**              sqlldr_bug            - If TRUE, compensate for SQL*Loader bug
******************************************************************************/
static void ProcessGeometries (
  char   *shapefile,
  char   *outprefix,
  char   *version,
  char   *geo_column,
  char   *id_column,
  int    gid,
  int    data_in_control_file,
  int    optimized_points,
  int    override_bounds,
  double Xmin,
  double Xmax,
  double Ymin,
  double Ymax,
  double tolerance,
  int    srid,
  int    nr_decimals,
  char   *loading_mode,
  int    sqlldr_bug)
{
  FILE        *pFileHandle ;
  SHPHandle   hSHP;
  DBFHandle   dbf_fp;
  int     nShapeType;
  int     nEntities;
  int     i, status;
  int     nGeometryType  = 0;
  double  adBounds[ 4 ];
  int     gtype_prefix;

  /* open shapefile and get file details */
  hSHP = OpenShpFile (shapefile, &nShapeType, &nEntities, adBounds, &nGeometryType);
  if (override_bounds)
  {
     adBounds[0] = Xmin;
     adBounds[1] = Ymin;
     adBounds[2] = Xmax;
     adBounds[3] = Ymax;
  }
  if (verbose)
     printf ("  Bounds used: X=[%f,%f] Y=[%f,%f]\n",
            adBounds[0], adBounds[2], adBounds[1], adBounds[3]);


  /* For version 8.1.5, force dimensions to 0. For other versions, force it to 2
     The number of dimensions will be used as prefix to the GTYPEs */
  if (strcmp(version, "8.1.5") == 0)
    gtype_prefix = 0;
  else
    gtype_prefix = 2000;
  if (verbose)
    printf ("  GTYPE prefix: %d\n", gtype_prefix);

  /* Open DBF file */
  dbf_fp = OpenDbfFile (shapefile);

  /* Generate the SQL script which creates the table */
  CreateSQLScript( outprefix, version, geo_column, id_column, adBounds, tolerance, srid, dbf_fp);

  /* Generate the SQL script which creates the spatial index */
  CreateSQLScriptIndex( outprefix, version, geo_column);

  /* Create and write control file */
  pFileHandle = CreateControlFile (
       outprefix, nShapeType , geo_column, id_column, optimized_points, data_in_control_file, srid, loading_mode, dbf_fp );
  if(pFileHandle == NULL)
  {
     printf( "Error Creating Control File" ) ;
     exit( 1 ) ;
  }

  /* Iterate over all the objects, writing to the control or data file */
  for( i = 0; i < nEntities; i++, gid++ )
  {
     if(verbose && !( i % 100 ) && i > 0 )
       printf("Processing Object %d of %d...\n", i, nEntities);
     OneShapeToDataFile (
       hSHP, i, pFileHandle, gid, nShapeType, nGeometryType , gtype_prefix, id_column, optimized_points,
       srid, nr_decimals, sqlldr_bug, dbf_fp);
  }
  if (verbose)
     printf("Processing Object %d of %d...\n", i, nEntities);

  fclose( pFileHandle ) ;
  SHPClose( hSHP );
  DBFClose (dbf_fp);

  /*
  ** Display names of files created with instructions
  */
  PrintCompletionMessage (nShapeType , i, outprefix, data_in_control_file);
}

/******************************************************************************
**
** Routine:     ShowUsageAndExit
**
** Description: Displays the valid syntax for the program and exit
**
** Parameters:  -
**
******************************************************************************/
void ShowUsageAndExit()
{
  printf("USAGE: shp2sdo <shapefile> <outlayer> -g <geometry column>\n"
         "               -v <version> \n"
         "               -i <id column> -n <start_id> -p -d -f <nr_decimals>\n"
         "               -x (xmin,xmax) -y (ymin,ymax) -t <tolerance> -s <srid>\n"
         "               -l <loading mode>\n");
  printf("    shapefile           - name of input shape file \n"
         "                          (Do not include suffix .shp .dbf or .shx)\n");
  printf("    outlayer            - spatial table name\n"
         "                          if not specified: same as input file name\n");
  printf("  Options:\n");
  printf("    -g geometry column  - Name of the column used for the SDO_GEOMETRY object\n"
         "                          if not specified: GEOM\n");
  printf("    -i id_column        - Name of the column used for numbering the geometries\n"
         "                          if not specified, no key column will be generated\n"
         "                          if specified without name, use ID\n");
  printf("    -n start_id         - Start number for IDs\n"
         "                          if not specified, start at 1\n");
  printf("    -p                  - Store points in the SDO_ORDINATES array\n"
         "                          if not specified, store in SDO_POINT\n");
  printf("    -s                  - Load SRID field in geometry and metadata \n"
         "                          if not specified, SRID field is NULL\n");
  printf("    -v version          - Oracle version to use\n"
         "                          if not specified, use 8.1.7\n");
  printf("    -d                  - store data in the control file\n"
         "                          if not specified: keep data in separate files\n");
  printf("    -x                  - bounds for the X dimension\n");
  printf("    -y                  - bounds for the Y dimension\n");
  printf("    -t tolerance        - Specify the tolerance setting for the layer.\n"
         "                          if not specified: 0.00000005 will be used.\n");
  printf("    -f nr_decimals      - number of decimals for output coordinates\n"
         "                          if not specified: use platform defaults\n");
  printf("    -l loading_mode     - Loading mode to be used by SQL*Loader \n"
         "                          as one of INSERT, APPEND, REPLACE, or TRUNCATE\n"
         "                          If none specified, then sql*loader uses INSERT by default\n");
  printf("    -V                  - verbose output\n");
  printf("    -h or -?            - print this message\n");
  exit( 1 );
}

/******************************************************************************
**
** Routine:     ParseArgumentList
**
** Description: extracts options from the argument list
**
******************************************************************************/
void ParseArgumentList (
  int argc,
  char *argv[],
  char *input_file,
  char *output_layer,
  char *version,
  int  *data_in_control_file,
  char *geo_column,
  char *id_column,
  int  *optimized_points,
  int  *start_gid,
  int  *override_bounds,
  double *Xmin,
  double *Xmax,
  double *Ymin,
  double *Ymax,
  double *tolerance,
  int  *srid,
  int  *nr_decimals,
  char *loading_mode)
{
  char *invalid;
  #define  NO_ERROR              ""
  #define  UNKNOWN_FLAG          "Unknown flag"
  #define  DUPLICATE_FLAG        "Duplicate flag"
  #define  MISSING_FLAG_VALUE    "Missing value for flag"
  #define  BAD_FLAG_VALUE        "Bad value for flag"
  #define  CONFLICTING_FLAGS     "Conflicting option"
  #define  FLAG_VALUE_FORBIDDEN  "Flag does not take a value"
  #define  TOO_MANY_ARGUMENTS    "Too many arguments"
  int  i;
  int  rSeen = FALSE,
       dSeen = FALSE,
       gSeen = FALSE,
       iSeen = FALSE,
       pSeen = FALSE,
       nSeen = FALSE,
       xSeen = FALSE,
       ySeen = FALSE,
       tSeen = FALSE,
       vSeen = FALSE,
       sSeen = FALSE,
       fSeen = FALSE,
       lSeen = FALSE;
  int  arg_counter = 0;
  char *option;
  char *value;
  invalid = NO_ERROR;
  i = 1;
  while (i < argc)
  {
     if (*(argv[i]) == '-')
     {
        /* This is an option flag - isolate the flag letter */
        option = argv[i++]+1;
        /* Get the value associated with the flag - if any */
        if (i < argc && *(argv[i]) != '-')
           value = argv[i++];
        else
           value = "";
     }
     else
     {
        /* This is a positional argument. Set dummy option flag */
        option = "";
        value = argv[i++];
        arg_counter++;
     }
     switch (option[0])
     {
        case 'h':
        case 'H':
        case '?':
           ShowUsageAndExit();
           break;
        case '\0': /* Positional argument */
           switch (arg_counter)
           {
              case 1: /* input file */
                 strcpy(input_file, value);
                 break;
              case 2: /* output layer */
                 strcpy(output_layer, value);
                 break;
              default:
                 invalid = TOO_MANY_ARGUMENTS;
                 break;
           }
           break;
        case 'v': /* Oracle version: value required */
           if (strlen(value) == 0)
              invalid = MISSING_FLAG_VALUE;
           strcpy(version, strupr(value));
           if (vSeen)
              invalid = DUPLICATE_FLAG;
           vSeen = TRUE;
           break;
        case 'd': /* data in control file: value forbidden */
           if (strlen(value) != 0)
              invalid = FLAG_VALUE_FORBIDDEN;
           *data_in_control_file = TRUE;
           if (dSeen)
              invalid = DUPLICATE_FLAG;
           dSeen = TRUE;
           break;
        case 'g': /* geometry column: value required */
           if (strlen(value) == 0)
              invalid = MISSING_FLAG_VALUE;
           strcpy(geo_column, strupr(value));
           if (gSeen)
              invalid = DUPLICATE_FLAG;
           gSeen = TRUE;
           break;
        case 'i': /* key column: value optional */
           if (strlen(value) != 0)
              strcpy(id_column, strupr(value));
           else
              strcpy(id_column, "ID");
           if (iSeen)
              invalid = DUPLICATE_FLAG;
           iSeen = TRUE;
           break;
        case 'p': /* point layer: value forbidden */
           if (strlen(value) != 0)
              invalid = FLAG_VALUE_FORBIDDEN;
           *optimized_points = FALSE;
           if (pSeen)
              invalid = DUPLICATE_FLAG;
           pSeen = TRUE;
           break;
        case 'n': /* start gid number: value required */
           if (strlen(value) == 0)
              invalid = MISSING_FLAG_VALUE;
           *start_gid = atoi(value);
           if (nSeen)
              invalid = DUPLICATE_FLAG;
           nSeen = TRUE;
           break;
        case 'x': /* X dimension bounds: value required */
           if (strlen(value) == 0)
              invalid = MISSING_FLAG_VALUE;
           sscanf ( value, "(%lf,%lf)", Xmin, Xmax);
           if (xSeen)
              invalid = DUPLICATE_FLAG;
           xSeen = TRUE;
           break;
        case 'y': /* Y dimension bounds: value required */
           if (strlen(value) == 0)
              invalid = MISSING_FLAG_VALUE;
           sscanf ( value, "(%lf,%lf)", Ymin, Ymax);
           if (ySeen)
              invalid = DUPLICATE_FLAG;
           ySeen = TRUE;
           break;
        case 't': /* Tolerance setting: value required */
           if (strlen(value) == 0)
              invalid = MISSING_FLAG_VALUE;
           sscanf ( value, "%lf", tolerance);
           if (tSeen)
              invalid = DUPLICATE_FLAG;
           tSeen = TRUE;
           break;
        case 's': /* srid: value required */
           if (strlen(value) == 0)
              invalid = MISSING_FLAG_VALUE;
           *srid = atoi(value);
           if (sSeen)
              invalid = DUPLICATE_FLAG;
           sSeen = TRUE;
           break;
        case 'f': /* number of decimals: value required */
           if (strlen(value) == 0)
              invalid = MISSING_FLAG_VALUE;
           *nr_decimals = atoi(value);
           if (fSeen)
              invalid = DUPLICATE_FLAG;
           fSeen = TRUE;
           break;
        case 'l': /* Loading mode: value required */
           if (strlen(value) == 0)
              invalid = MISSING_FLAG_VALUE;
           strcpy(loading_mode, strupr(value));
           if (lSeen)
              invalid = DUPLICATE_FLAG;
           if (strcmp (loading_mode, "INSERT") != 0 &
               strcmp (loading_mode, "APPEND") != 0 &
               strcmp (loading_mode, "REPLACE") != 0 &
               strcmp (loading_mode, "TRUNCATE") != 0)
              invalid = BAD_FLAG_VALUE;
           lSeen = TRUE;
           break;

        case 'V': /* verbose output */
           verbose = TRUE;
           break;
        case 'X': /* debug output */
           debug = TRUE;
           break;
        default :
           invalid = UNKNOWN_FLAG;
     }
     if (strlen(invalid) != 0)
     {
        printf ("**** error: %s %s %s\n", invalid, option, value);
        printf( "-- use -h for detailed syntax\n");
        exit(1);
     }
     /* Value was ignored: backtrack one token in the argument list*/
     if (!value)
        i--;
  }

  /* Process missing arguments */

  /* Input file not specified: fail */
  if (strlen(input_file) == 0)
  {
     printf ("**** no input shape file specified\n");
     printf( "-- use -h for detailed syntax\n");
     exit(1);
  }
  /* Output layer not specified: same as input file name */
  if (strlen(output_layer) == 0)
     strcpy (output_layer, input_file);
  /* Oracle version not specified: use the default version */
  if (*version == '\0')
     strcpy (version, "9.2");
  /* Data location not specified: use separate file */
  if (*data_in_control_file == UNKNOWN)
     *data_in_control_file = FALSE;
  /* Geometry column not specified: use GEOM */
  if (*geo_column == '\0')
     strcpy (geo_column, "GEOM");
  /* Id column not specified:this is OK */
  if (*id_column == '\0')
     strcpy (id_column, "");
  /* Point storage mode not specified - assume optimized points */
  if (*optimized_points == UNKNOWN)
     *optimized_points = TRUE;
  /* Start GID not specified: assume 1 */
  if (*start_gid == UNKNOWN)
     *start_gid = 1;
  /* Bounds override: must specify both -x and -y */
  if (xSeen && ySeen)
     *override_bounds = TRUE;
  else
     if (xSeen || ySeen)
     {
        printf ("**** must specify both X and Y bounds\n");
        printf( "-- use -h for detailed syntax\n");
        exit(1);
     }
     else
        *override_bounds = FALSE;
  /* Tolerance not specified: assume 0.00000005 */
  if (*tolerance == UNKNOWN)
     *tolerance = 0.00000005;
}

/******************************************************************************
**
** Routine:     PromptArguments
**
** Description: Prompt user for arguments
**
******************************************************************************/
void PromptArguments (
  char *input_file,
  char *output_layer,
  char *version,
  int  *data_in_control_file,
  char *geo_column,
  char *id_column,
  int  *optimized_points,
  int  *start_gid,
  int  *override_bounds,
  double *Xmin,
  double *Xmax,
  double *Ymin,
  double *Ymax,
  double *tolerance,
  int  *srid,
  int  *nr_decimals,
  char *loading_mode)
{
 int        i, invalid;
 char       string[32] = "";
 SHPHandle  shp_fp;
 int        nShapeType,
            nEntities,
            nGeometryType  = 0;
 double     adBounds[ 4 ];
 int        ordcount_default;

 invalid = FALSE;

 /* Input file */
 printf ("Input shapefile (no extension): ");
 gets(input_file);
 if (strlen(input_file)==0)
   exit(1);

 /* Open shape file and get content info */
 shp_fp = OpenShpFile (input_file, &nShapeType, &nEntities, adBounds, &nGeometryType );
 printf ("   Shape file %s.shp contains %d ",
        input_file, nEntities);
 switch( nShapeType )
 {
   case SHPT_POINT:
     printf( "points" ) ;
     break ;
   case SHPT_MULTIPOINT:
     printf( "multi-points" ) ;
     break ;
   case SHPT_ARC :
     printf( "linestrings" ) ;
     break ;
   case SHPT_POLYGON :
     printf( "polygons" ) ;
     break ;
 }
 printf ("\n");

 /* Output layer */
 printf ("Output layer [%s]: ", input_file);
 gets(string);
 if (strlen(string) == 0)
   strcpy (output_layer, input_file);
 else
   strcpy (output_layer, string);

 /* Get Oracle version */
 printf ("Oracle version [" DEFAULT_DATABASE_VERSION "]: ");
 gets (string);
 if (strlen(string) == 0)
   strcpy (version, DEFAULT_DATABASE_VERSION);
 else
   strcpy (version, strupr(string));

 /* Get geometry column name */
 printf ("Geometry column [GEOM]: ");
 gets (string);
 if (strlen(string) == 0)
   strcpy (geo_column, "GEOM");
 else
   strcpy (geo_column, strupr(string));

 /* Get ID column name */
 printf ("ID column []: ");
 gets (string);
 if (strlen(string) != 0)
   strcpy (id_column, strupr(string));

 /* Get start number for id column */
 if (strlen(id_column) != 0)
 {
   printf ("Starting number [1]: ");
   gets (string);
   if (strlen(string) == 0)
     *start_gid = 1;
   else
     *start_gid = atoi(string);
 }

 /* Get points storage mode */
 if (nShapeType == SHPT_POINT)
 {
   printf ("Points stored in SDO_POINT_TYPE ? [Y]: ");
   gets (string);
   if (strlen(string) == 0)
     string[0] = 'Y';
   if (string[0] == 'Y' || string[0] == 'y')
     *optimized_points = TRUE;
   else
     *optimized_points = FALSE;
 }

 /* Get SRID if needed */
 printf ("Use a spatial reference system ID (SRID) ? [N]: ");
 gets (string);
 if (strlen(string) == 0)
   string[0] = 'N';
 if (string[0] == 'Y' || string[0] == 'y')
 {
   printf ("Please enter an SRID value: ");
   gets (string);
   if (strlen(string) == 0)
     *srid = UNKNOWN;
   else
     *srid = atoi(string);
 }

 /* Data generation */
 printf ("Generate data inside control files ? [N]: ");
 gets(string);
 if (strlen(string) == 0)
   string[0] = 'N';
 if (string[0] == 'Y' || string[0] == 'y')
   *data_in_control_file = TRUE;
 else
   *data_in_control_file = FALSE;
 printf ("Loading mode for SQL*Loader ? (INSERT, APPEND, REPLACE, TRUNCATE) [INSERT]: ");
 gets(string);
 if (strlen(string) > 0)
   strcpy (loading_mode, strupr(string));

 /* Get start number for id column */
 printf ("Number of decimals in output []: ");
 gets (string);
 if (strlen(string) == 0)
   *nr_decimals = UNKNOWN;
 else
   *nr_decimals = atoi(string);

 /* Bounds overrides */
 printf ("Bounds: X=[%f,%f] Y=[%f,%f]\n",
        adBounds[0], adBounds[2], adBounds[1], adBounds[3]);
 printf ("Override ? [N]: ");
 gets(string);
 if (strlen(string) == 0)
   string[0] = 'N';
 if (string[0] == 'Y' || string[0] == 'y')
   *override_bounds = TRUE;
 else
   *override_bounds = FALSE;
 if (*override_bounds)
 {

   /* Get Xmin */
   printf ("Xmin [%lf]: ",adBounds[0]);
   gets (string);
   if (strlen(string) == 0)
     *Xmin = adBounds[0];
   else
     sscanf(string,"%lf", Xmin);

   /* Get Xmax */
   printf ("Xmax [%lf]: ",adBounds[2]);
   gets (string);
   if (strlen(string) == 0)
     *Xmax = adBounds[2];
   else
     sscanf(string,"%lf", Xmax);

   /* Get Ymin */
   printf ("Ymin [%lf]: ",adBounds[1]);
   gets (string);
   if (strlen(string) == 0)
     *Ymin = adBounds[1];
   else
     sscanf(string,"%lf", Ymin);

   /* Get Ymax */
   printf ("Ymax [%lf]: ",adBounds[3]);
   gets (string);
   if (strlen(string) == 0)
     *Ymax = adBounds[3];
   else
     sscanf(string,"%lf", Ymax);
  }

  /* Get tolerance setting */
  printf ("Tolerance [0.00000005]: ");
  gets (string);
  if (strlen(string) == 0)
    *tolerance = 0.00000005;
  else
    sscanf(string,"%lf", tolerance);
}

/******************************************************************************
**
** Routine:     DumpArguments
**
** Description: dump arguments for debugging
**
******************************************************************************/
void DumpArguments (
  char *input_file,
  char *output_layer,
  char *version,
  int  data_in_control_file,
  char *geo_column,
  char *id_column,
  int  optimized_points,
  int  start_gid,
  int  override_bounds,
  double Xmin,
  double Xmax,
  double Ymin,
  double Ymax,
  double tolerance,
  int  srid,
  int  nr_decimals,
  char *loading_mode)
{
  printf ("DBG:      [input_file]            = [%s]\n", input_file);
  printf ("DBG:      [output_layer]          = [%s]\n", output_layer);
  printf ("DBG: -v   [version]               = [%s]\n", version);
  printf ("DBG: -d   [data_in_control_file]  = [%d]\n", data_in_control_file);
  printf ("DBG: -g   [geo_column]            = [%s]\n", geo_column);
  printf ("DBG: -i   [id_column]             = [%s]\n", id_column);
  printf ("DBG: -p   [optimized_points]      = [%d]\n", optimized_points);
  printf ("DBG: -n   [start_gid]             = [%d]\n", start_gid);
  printf ("DBG: -x   [Xmin,Xmax]             = [%lf,%f]\n", Xmin, Xmax);
  printf ("DBG: -y   [Ymin,Ymax]             = [%lf,%f]\n", Ymin, Ymax);
  printf ("DBG: -x/y [override_bounds]       = [%d]\n", override_bounds);
  printf ("DBG: -s   [srid]                  = [%d]\n", srid);
  printf ("DBG: -t   [tolerance]             = [%.9f]\n", tolerance);
  printf ("DBG: -f   [nr_decimals]           = [%d]\n", nr_decimals);
  printf ("DBG: -l   [loading_mode]          = [%s]\n", loading_mode);
  printf ("DBG: -V   [verbose]               = [%d]\n", verbose);
  printf ("DBG: -X   [debug]                 = [%d]\n", debug);
}

/******************************************************************************
**
** Routine:     Main
**
** Description: Program main
**
******************************************************************************/
int main( int argc, char ** argv )
{
  char input_file[32] = "";
  char output_layer[32] = "";
  char version[32] = "";
  int  data_in_control_file = UNKNOWN;
  char geo_column[32] = "";
  char id_column[32] = "";
  int  optimized_points = UNKNOWN;
  int  start_gid = UNKNOWN;
  int  srid = UNKNOWN;
  int  nr_decimals = UNKNOWN;
  char loading_mode[32] = "";
  double  Xmin =0, Xmax =0 , Ymin = 0, Ymax = 0;
  double tolerance = UNKNOWN;
  int  override_bounds = UNKNOWN;
  int  sqlldr_bug = FALSE;
  debug = FALSE;
  verbose = FALSE;

  printf( "\nshp2sdo - Shapefile(r) To Oracle Spatial Converter\n" ) ;
  printf( "Version 4.7 20-Feb-2005\n" ) ;
  printf( "Copyright 2004, 2005 Oracle Corporation\n\n" ) ;

  if (argc > 1)
     ParseArgumentList (
       argc, argv,
       input_file,
       output_layer,
       version,
       &data_in_control_file,
       geo_column,
       id_column,
       &optimized_points,
       &start_gid,
       &override_bounds,
       &Xmin, &Xmax,
       &Ymin, &Ymax,
       &tolerance,
       &srid,
       &nr_decimals,
       loading_mode
     );
  else
     PromptArguments (
       input_file,
       output_layer,
       version,
       &data_in_control_file,
       geo_column,
       id_column,
       &optimized_points,
       &start_gid,
       &override_bounds,
       &Xmin, &Xmax,
       &Ymin, &Ymax,
       &tolerance,
       &srid,
       &nr_decimals,
       loading_mode
     );

  if (debug)
     DumpArguments (
       input_file,
       output_layer,
       version,
       data_in_control_file,
       geo_column,
       id_column,
       optimized_points,
       start_gid,
       override_bounds,
       Xmin, Xmax,
       Ymin, Ymax,
       tolerance,
       srid,
       nr_decimals,
       loading_mode
     );

  printf ("Processing shapefile %s into spatial table %s \n",
    input_file, strupr(output_layer));
  printf ("  Oracle version is %s \n", version);
  printf ("  Geometry column is %s \n", geo_column);
  if (strlen (id_column) != 0)
  {
     printf ("  Id column is %s \n", id_column);
     printf ("  Numbered from %d\n", start_gid);
  }
  if (optimized_points)
     printf ("  Points stored in SDO_POINT attributes\n");
  else
     printf ("  Points stored in SDO_ORDINATES array\n");
  if (srid == UNKNOWN)
     printf ("  No SRID specified\n");
  else
     printf ("  SRID used is %d\n", srid);

  /* Need to compensate for SQL*Loader bug ? */
  if (version[0] == '8')
  {
     sqlldr_bug = TRUE;
     printf ("  **** Compensating for SQL*Loader bug ****\n");
  }
  if (data_in_control_file)
     printf ("  Data is in the control file\n");
  else
     printf ("  Data is in a separate file\n");
  if (strlen(loading_mode) == 0)
     printf ("  No loading mode specified. Will use SQL*Loader default of INSERT\n");
  else
     printf ("  Loading mode for SQL*Loader is %s\n", loading_mode);
  if (nr_decimals != UNKNOWN)
     printf ("  Output coordinates have %d decimals\n", nr_decimals);
  if (override_bounds)
     printf ("  Bounds set to X=[%g,%g] Y=[%g,%g]\n", Xmin, Xmax, Ymin, Ymax);
  printf ("  Tolerance: %.9f\n", tolerance);

  /*
  ** Create SQL scripts and .CTL files for SDO schema that will
  **   contain the shape file coordinates
  */

  ProcessGeometries (
    input_file,
    output_layer,
    version,
    geo_column,
    id_column,
    start_gid,
    data_in_control_file,
    optimized_points,
    override_bounds,
    Xmin, Xmax, Ymin, Ymax,
    tolerance,
    srid,
    nr_decimals,
    loading_mode,
    sqlldr_bug
  );
}
