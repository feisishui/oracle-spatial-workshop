/*
 * Copyright (c) 1995 Frank Warmerdam
 *
 * This code is in the public domain.
 *
 * $Log: shpopen.c,v $
 *
 * Revision 1.9  1998/12/03  00:00:00  Albert Godfrind Oracle Corp
 * Ported to Digital OpenVMS Alpha. Fixed the detection and support of endian-ness
 * on that platform. Added tracing and debugging. Added checks for malloc() and
 * realloc() failures
 *
 * Revision 1.8  1997/12/12  00:00:00  Dan Geringer Oracle Corp.
 * .shp, .dbf and .dbx extensions can be lower or upper case
 *
 * Revision 1.7  1995/10/21  03:15:58  warmerda
 * Added support for binary file access, the magic cookie 9997
 * and tried to improve the int32 selection logic for 16bit systems.
 *
 * Revision 1.6  1995/09/04  04:19:41  warmerda
 * Added fix for file bounds.
 *
 * Revision 1.5  1995/08/25  15:16:44  warmerda
 * Fixed a couple of problems with big endian systems ... one with bounds
 * and the other with multipart polygons.
 *
 * Revision 1.4  1995/08/24  18:10:17  warmerda
 * Switch to use SfRealloc() to avoid problems with pre-ANSI realloc()
 * functions (such as on the Sun).
 *
 * Revision 1.3  1995/08/23  02:23:15  warmerda
 * Added support for reading bounds, and fixed up problems in setting the
 * file wide bounds.
 *
 * Revision 1.2  1995/08/04  03:16:57  warmerda
 * Added header.
 *
 */

   static char rcsid[] =
   "$Id: shpopen.c,v 1.7 1995/10/21 03:15:58 warmerda Exp $";

#include "shapefil.h"

#include <math.h>
#include <limits.h>

/* Added 08/07/97 John F. Keaveney Oracle Corp */

#include <stdlib.h>

/* Added 03-dec-1998 Albert Godfrind Oracle Corp */
#include <string.h>

   typedef unsigned char uchar;

#if UINT_MAX == 65535
typedef long       int32;
#else
   typedef int       int32;
#endif

#ifndef FALSE
#  define FALSE  0
#  define TRUE  1
#endif

#define ByteCopy( a, b, c ) memcpy( b, a, c )
#ifndef MAX
#  define MIN(a,b)      ((a<b) ? a : b)
#  define MAX(a,b)      ((a>b) ? a : b)
#endif

   static int bBigEndian;
   extern int debug;
   extern int verbose;

/************************************************************************/
/*                              SwapWord()                              */
/*                                                                      */
/*      Swap a 2, 4 or 8 byte word.                                     */
/************************************************************************/

   static void SwapWord( int length, void * wordP )

   {
      int  i;
      uchar temp;

      for( i=0; i < length/2; i++ )
      {
         temp = ((uchar *) wordP)[i];
         ((uchar *)wordP)[i] = ((uchar *) wordP)[length-i-1];
         ((uchar *) wordP)[length-i-1] = temp;
      }
   }

/************************************************************************/
/*                             SfRealloc()                              */
/*                                                                      */
/*      A realloc cover function that will access a NULL pointer as     */
/*      a valid input.                                                  */
/************************************************************************/

   static void * SfRealloc( void * pMem, int nNewSize )

   {
      void * pNewMem;

   /* Modified 03-dec-1998 Albert Godfrind Oracle Corp */
   /* Make sure we fail gracefully in case a memory allocation fails ! */

      if (debug)
         printf ("DBG: SfRealloc: %0X reallocating - %d bytes\n", pMem, nNewSize);

      if( pMem == NULL )
         pNewMem = (void *) malloc(nNewSize);
      else
         pNewMem = (void *) realloc(pMem,nNewSize);
      if( pNewMem == NULL)
      {
         printf ("*** Error re-allocating %d bytes of memory\n", nNewSize);
         exit (1);
      }
      if (debug)
         printf ("DBG: SfRealloc: %0X reallocated to %0X - %d bytes\n", pMem, pNewMem, nNewSize);
      return (pNewMem);
   }

/************************************************************************/
/*                             SfMalloc()                               */
/*                                                                      */
/*      A malloc cover function that will verify that the allocation    */
/*      completed successfully                                          */
/************************************************************************/

   static void * SfMalloc( int nNewSize )

   {
      void * pNewMem;

      pNewMem = (void *) malloc(nNewSize);
      if( pNewMem == NULL)
      {
         printf ("*** Error allocating %d bytes of memory\n", nNewSize);
         exit (1);
      }
      if (debug)
         printf ("DBG: SfMalloc: %0X allocated - %d bytes\n", pNewMem, nNewSize);
      return (pNewMem);
   }

/************************************************************************/
/*                          SHPWriteHeader()                            */
/*                                                                      */
/*      Write out a header for the .shp and .shx files as well as the */
/* contents of the index (.shx) file.    */
/************************************************************************/

   static void SHPWriteHeader( SHPHandle psSHP )

   {
      uchar      abyHeader[100];
      int  i;
      int32 i32;
      double dValue;
      int32 *panSHX;

   /* -------------------------------------------------------------------- */
   /*      Prepare header block for .shp file.                             */
   /* -------------------------------------------------------------------- */
      for( i = 0; i < 100; i++ )
         abyHeader[i] = 0;

      abyHeader[2] = 0x27;    /* magic cookie */
      abyHeader[3] = 0x0a;

      i32 = psSHP->nFileSize/2;    /* file size */
      ByteCopy( &i32, abyHeader+24, 4 );
      if( !bBigEndian ) SwapWord( 4, abyHeader+24 );

      i32 = 1000;      /* version */
      ByteCopy( &i32, abyHeader+28, 4 );
      if( bBigEndian ) SwapWord( 4, abyHeader+28 );

      i32 = psSHP->nShapeType;    /* shape type */
      ByteCopy( &i32, abyHeader+32, 4 );
      if( bBigEndian ) SwapWord( 4, abyHeader+32 );

      dValue = psSHP->adBoundsMin[0];   /* set bounds */
      ByteCopy( &dValue, abyHeader+36, 8 );
      if( bBigEndian ) SwapWord( 8, abyHeader+36 );

      dValue = psSHP->adBoundsMin[1];
      ByteCopy( &dValue, abyHeader+44, 8 );
      if( bBigEndian ) SwapWord( 8, abyHeader+44 );

      dValue = psSHP->adBoundsMax[0];
      ByteCopy( &dValue, abyHeader+52, 8 );
      if( bBigEndian ) SwapWord( 8, abyHeader+52 );

      dValue = psSHP->adBoundsMax[1];
      ByteCopy( &dValue, abyHeader+60, 8 );
      if( bBigEndian ) SwapWord( 8, abyHeader+60 );

   /* -------------------------------------------------------------------- */
   /*      Write .shp file header.                                         */
   /* -------------------------------------------------------------------- */
      fseek( psSHP->fpSHP, 0, 0 );
      fwrite( abyHeader, 100, 1, psSHP->fpSHP );

   /* -------------------------------------------------------------------- */
   /*      Prepare, and write .shx file header.                            */
   /* -------------------------------------------------------------------- */
      i32 = (psSHP->nRecords * 2 * sizeof(int32) + 100)/2;   /* file size */
      ByteCopy( &i32, abyHeader+24, 4 );
      if( !bBigEndian ) SwapWord( 4, abyHeader+24 );

      fseek( psSHP->fpSHX, 0, 0 );
      fwrite( abyHeader, 100, 1, psSHP->fpSHX );

   /* -------------------------------------------------------------------- */
   /*      Write out the .shx contents.                                    */
   /* -------------------------------------------------------------------- */
      panSHX = (int32 *) SfMalloc(sizeof(int32) * 2 * psSHP->nRecords);

      for( i = 0; i < psSHP->nRecords; i++ )
      {
         panSHX[i*2  ] = psSHP->panRecOffset[i]/2;
         panSHX[i*2+1] = psSHP->panRecSize[i]/2;
         if( !bBigEndian ) SwapWord( 4, panSHX+i*2 );
         if( !bBigEndian ) SwapWord( 4, panSHX+i*2+1 );
      }

      fwrite( panSHX, sizeof(int32) * 2, psSHP->nRecords, psSHP->fpSHX );

      free( panSHX );
   }

/************************************************************************/
/*                              SHPOpen()                               */
/*                                                                      */
/*      Open the .shp and .shx files based on the basename of the       */
/*      files or either file name.                                      */
/************************************************************************/

   SHPHandle SHPOpen( const char * pszLayer, const char * pszAccess )

   {
      char  *pszFullname, *pszBasename;
      SHPHandle  psSHP;

      uchar  *pabyBuf;
      int   iField, i;
      double  dValue;

   /* -------------------------------------------------------------------- */
   /*      Ensure the access string is one of the legal ones.              */
   /* -------------------------------------------------------------------- */
      if( strcmp(pszAccess,"r") != 0 && strcmp(pszAccess,"r+") != 0
        && strcmp(pszAccess,"rb") != 0 && strcmp(pszAccess,"rb+") != 0 )
         return( NULL );

   /* -------------------------------------------------------------------- */
   /* Establish the byte order on this machine.   */
   /* -------------------------------------------------------------------- */
      i = 1;
      if( *((uchar *) &i) == 1 )
      {
         if (debug)
            printf ("DBG: This is a LITTLE-ENDIAN system\n");
         bBigEndian = FALSE;
      }
      else
      {
         if (debug)
            printf ("DBG: This is a BIG-ENDIAN system\n");
         bBigEndian = TRUE;
      }


   /* -------------------------------------------------------------------- */
   /* Initialize the info structure.     */
   /* -------------------------------------------------------------------- */
      psSHP = (SHPHandle) SfMalloc(sizeof(SHPInfo));

      psSHP->bUpdated = FALSE;

   /* -------------------------------------------------------------------- */
   /* Compute the base (layer) name.  If there is any extension */
   /* on the passed in filename we will strip it off.   */
   /* -------------------------------------------------------------------- */
      pszBasename = (char *) SfMalloc(strlen(pszLayer)+5);
      strcpy( pszBasename, pszLayer );
      for( i = strlen(pszBasename)-1;
         i > 0 && pszBasename[i] != '.' && pszBasename[i] != '/'
         && pszBasename[i] != '\\';
         i-- ) {}

      if( pszBasename[i] == '.' )
         pszBasename[i] = '\0';

   /* -------------------------------------------------------------------- */
   /* Open the .shp and .shx files.  Note that files pulled from */
   /* a PC to Unix with upper case filenames won't work!  */
   /* -------------------------------------------------------------------- */
      pszFullname = (char *) SfMalloc(strlen(pszBasename) + 5);
      sprintf( pszFullname, "%s.shp", pszBasename );
      psSHP->fpSHP = fopen(pszFullname, pszAccess );
      if( psSHP->fpSHP == NULL )
      {
         sprintf( pszFullname, "%s.SHP", pszBasename );
         psSHP->fpSHP = fopen(pszFullname, pszAccess );
         if( psSHP->fpSHP == NULL )
            return( NULL );
      }

      sprintf( pszFullname, "%s.shx", pszBasename );
      psSHP->fpSHX = fopen(pszFullname, pszAccess );
      if( psSHP->fpSHX == NULL )
      {
         sprintf( pszFullname, "%s.SHX", pszBasename );
         psSHP->fpSHX = fopen(pszFullname, pszAccess );
         if( psSHP->fpSHX == NULL )
            return( NULL );
      }

      free( pszFullname );

   /* -------------------------------------------------------------------- */
   /*  Read the file size from the SHP file.    */
   /* -------------------------------------------------------------------- */
      pabyBuf = (uchar *) SfMalloc(100);
      fread( pabyBuf, 100, 1, psSHP->fpSHP );

      psSHP->nFileSize = (pabyBuf[24] * 256 * 256 * 256
                         + pabyBuf[25] * 256 * 256
                         + pabyBuf[26] * 256
                         + pabyBuf[27]) * 2;
      if (verbose)
         printf ("Shape File:\n  Size : %d bytes\n", psSHP->nFileSize);

   /* -------------------------------------------------------------------- */
   /*  Read SHX file Header info                                           */
   /* -------------------------------------------------------------------- */
      fread( pabyBuf, 100, 1, psSHP->fpSHX );

      if( pabyBuf[0] != 0
        || pabyBuf[1] != 0
        || pabyBuf[2] != 0x27
        || (pabyBuf[3] != 0x0a && pabyBuf[3] != 0x0d) )
      {
         fclose( psSHP->fpSHP );
         fclose( psSHP->fpSHX );
         free( psSHP );

         printf ("*** Shapefile header not recognized\n");
         return( NULL );
      }

      psSHP->nRecords = pabyBuf[27] + pabyBuf[26] * 256
                        + pabyBuf[25] * 256 * 256 + pabyBuf[24] * 256 * 256 * 256;
      psSHP->nRecords = (psSHP->nRecords*2 - 100) / 8;
      if (verbose)
         printf ("  Number of shapes : %d\n", psSHP->nRecords);

      psSHP->nShapeType = pabyBuf[32];
      if (verbose)
      {
         printf ("  Shape type : %d = ", psSHP->nShapeType);
         switch( psSHP->nShapeType )
         {
            case SHPT_POINT:
               printf( "SHPT_POINT" ) ;
               break ;
            case SHPT_MULTIPOINT:
               printf( "SHPT_MULTIPOINT" ) ;
               break ;
            case SHPT_ARC :
               printf( "SHPT_ARC" ) ;
               break ;
            case SHPT_POLYGON :
               printf( "SHPT_POLYGON" ) ;
               break ;
         }
         printf ("\n");
      }

      if( bBigEndian ) SwapWord( 8, pabyBuf+36 );
      memcpy( &dValue, pabyBuf+36, 8 );
      psSHP->adBoundsMin[0] = dValue;

      if( bBigEndian ) SwapWord( 8, pabyBuf+44 );
      memcpy( &dValue, pabyBuf+44, 8 );
      psSHP->adBoundsMin[1] = dValue;

      if( bBigEndian ) SwapWord( 8, pabyBuf+52 );
      memcpy( &dValue, pabyBuf+52, 8 );
      psSHP->adBoundsMax[0] = dValue;

      if( bBigEndian ) SwapWord( 8, pabyBuf+60 );
      memcpy( &dValue, pabyBuf+60, 8 );
      psSHP->adBoundsMax[1] = dValue;
      if (verbose)
         printf ("  Bounds : X=[%f,%f] Y=[%f,%f]\n",
                psSHP->adBoundsMin[0], psSHP->adBoundsMax[0],
                psSHP->adBoundsMin[1], psSHP->adBoundsMax[1]);
      free( pabyBuf );

   /* -------------------------------------------------------------------- */
   /* Read the .shx file to get the offsets to each record in  */
   /* the .shp file.       */
   /* -------------------------------------------------------------------- */
      psSHP->nMaxRecords = psSHP->nRecords;

      psSHP->panRecOffset = (int *) SfMalloc(sizeof(int) * psSHP->nMaxRecords );
      psSHP->panRecSize = (int *) SfMalloc(sizeof(int) * psSHP->nMaxRecords );

      pabyBuf = (uchar *) SfMalloc(8 * psSHP->nRecords );
      fread( pabyBuf, 8, psSHP->nRecords, psSHP->fpSHX );

      for( i = 0; i < psSHP->nRecords; i++ )
      {
         int32  nOffset, nLength;

         memcpy( &nOffset, pabyBuf + i * 8, 4 );
         if( !bBigEndian ) SwapWord( 4, &nOffset );

         memcpy( &nLength, pabyBuf + i * 8 + 4, 4 );
         if( !bBigEndian ) SwapWord( 4, &nLength );

         psSHP->panRecOffset[i] = nOffset*2;
         psSHP->panRecSize[i] = nLength*2;
      }

      return( psSHP );
   }

/************************************************************************/
/*                              SHPClose()                              */
/*                */
/* Close the .shp and .shx files.     */
/************************************************************************/

   void SHPClose(SHPHandle psSHP )

   {
   /* -------------------------------------------------------------------- */
   /* Update the header if we have modified anything.   */
   /* -------------------------------------------------------------------- */
      if( psSHP->bUpdated )
      {
         SHPWriteHeader( psSHP );
      }

   /* -------------------------------------------------------------------- */
   /*      Free all resources, and close files.                            */
   /* -------------------------------------------------------------------- */
      free( psSHP->panRecOffset );
      free( psSHP->panRecSize );

      fclose( psSHP->fpSHX );
      fclose( psSHP->fpSHP );

      free( psSHP );
   }

/************************************************************************/
/*                             SHPGetInfo()                             */
/*                                                                      */
/*      Fetch general information about the shape file.                 */
/************************************************************************/

   void SHPGetInfo(SHPHandle psSHP, int * pnEntities, int * pnShapeType )

   {
      if( pnEntities != NULL )
         *pnEntities = psSHP->nRecords;

      if( pnShapeType != NULL )
         *pnShapeType = psSHP->nShapeType;
   }

/************************************************************************/
/*                             SHPCreate()                              */
/*                                                                      */
/*      Create a new shape file and return a handle to the open         */
/*      shape file with read/write access.                              */
/************************************************************************/

   SHPHandle SHPCreate( const char * pszLayer, int nShapeType )

   {
      char *pszBasename, *pszFullname;
      int  i;
      FILE *fpSHP, *fpSHX;
      uchar      abyHeader[100];
      int32 i32;
      double dValue;
      int32 *panSHX;

   /* -------------------------------------------------------------------- */
   /*      Establish the byte order on this system.                        */
   /* -------------------------------------------------------------------- */
      i = 1;
      if( *((uchar *) &i) == 1 )
         bBigEndian = FALSE;
      else
         bBigEndian = TRUE;

   /* -------------------------------------------------------------------- */
   /* Compute the base (layer) name.  If there is any extension */
   /* on the passed in filename we will strip it off.   */
   /* -------------------------------------------------------------------- */
      pszBasename = (char *) SfMalloc(strlen(pszLayer)+5);
      strcpy( pszBasename, pszLayer );
      for( i = strlen(pszBasename)-1;
         i > 0 && pszBasename[i] != '.' && pszBasename[i] != '/'
         && pszBasename[i] != '\\';
         i-- ) {}

      if( pszBasename[i] == '.' )
         pszBasename[i] = '\0';

   /* -------------------------------------------------------------------- */
   /*      Open the two files so we can write their headers.               */
   /* -------------------------------------------------------------------- */
      pszFullname = (char *) SfMalloc(strlen(pszBasename) + 5);
      sprintf( pszFullname, "%s.shp", pszBasename );
      fpSHP = fopen(pszFullname, "wb" );
      if( fpSHP == NULL )
      {
         sprintf( pszFullname, "%s.SHP", pszBasename );
         fpSHP = fopen(pszFullname, "wb" );
         if( fpSHP == NULL )
            return( NULL );
      }

      sprintf( pszFullname, "%s.shx", pszBasename );
      fpSHX = fopen(pszFullname, "wb" );
      if( fpSHX == NULL )
      {
         sprintf( pszFullname, "%s.SHX", pszBasename );
         fpSHX = fopen(pszFullname, "wb" );
         if( fpSHX == NULL )
            return( NULL );
      }

      free( pszFullname );

   /* -------------------------------------------------------------------- */
   /*      Prepare header block for .shp file.                             */
   /* -------------------------------------------------------------------- */
      for( i = 0; i < 100; i++ )
         abyHeader[i] = 0;

      abyHeader[2] = 0x27;    /* magic cookie */
      abyHeader[3] = 0x0a;

      i32 = 50;      /* file size */
      ByteCopy( &i32, abyHeader+24, 4 );
      if( !bBigEndian ) SwapWord( 4, abyHeader+24 );

      i32 = 1000;      /* version */
      ByteCopy( &i32, abyHeader+28, 4 );
      if( bBigEndian ) SwapWord( 4, abyHeader+28 );

      i32 = nShapeType;     /* shape type */
      ByteCopy( &i32, abyHeader+32, 4 );
      if( bBigEndian ) SwapWord( 4, abyHeader+32 );

      dValue = 0.0;     /* set bounds */
      ByteCopy( &dValue, abyHeader+36, 8 );
      ByteCopy( &dValue, abyHeader+44, 8 );
      ByteCopy( &dValue, abyHeader+52, 8 );
      ByteCopy( &dValue, abyHeader+60, 8 );

   /* -------------------------------------------------------------------- */
   /*      Write .shp file header.                                         */
   /* -------------------------------------------------------------------- */
      fwrite( abyHeader, 100, 1, fpSHP );

   /* -------------------------------------------------------------------- */
   /*      Prepare, and write .shx file header.                            */
   /* -------------------------------------------------------------------- */
      i32 = 50;      /* file size */
      ByteCopy( &i32, abyHeader+24, 4 );
      if( !bBigEndian ) SwapWord( 4, abyHeader+24 );

      fwrite( abyHeader, 100, 1, fpSHX );

   /* -------------------------------------------------------------------- */
   /*      Close the files, and then open them as regular existing files.  */
   /* -------------------------------------------------------------------- */
      fclose( fpSHP );
      fclose( fpSHX );

      return( SHPOpen( pszLayer, "rb+" ) );
   }

/************************************************************************/
/*                           _SHPSetBounds()                            */
/*                                                                      */
/*      Compute a bounds rectangle for a shape, and set it into the     */
/*      indicated location in the record.                               */
/************************************************************************/

   static void _SHPSetBounds( uchar * pabyRec, int nVCount,
                     double * padVertices  )

   {
      double dXMin, dXMax, dYMin, dYMax;
      int  i;

      if( nVCount == 0 )
      {
         dXMin = dYMin = dXMax = dYMax = 0.0;
      }
      else
      {
         dXMin = dXMax = padVertices[0];
         dYMin = dYMax = padVertices[1];

         for( i = 1; i < nVCount; i++ )
         {
            dXMin = MIN(dXMin,padVertices[i*2  ]);
            dXMax = MAX(dXMax,padVertices[i*2  ]);
            dYMin = MIN(dYMin,padVertices[i*2+1]);
            dYMax = MAX(dYMax,padVertices[i*2+1]);
         }
      }

      if( bBigEndian ) SwapWord( 8, &dXMin );
      if( bBigEndian ) SwapWord( 8, &dYMin );
      if( bBigEndian ) SwapWord( 8, &dXMax );
      if( bBigEndian ) SwapWord( 8, &dYMax );

      ByteCopy( &dXMin, pabyRec +  0, 8 );
      ByteCopy( &dYMin, pabyRec +  8, 8 );
      ByteCopy( &dXMax, pabyRec + 16, 8 );
      ByteCopy( &dYMax, pabyRec + 24, 8 );
   }

/************************************************************************/
/*                          SHPWriteVertices()                          */
/*                                                                      */
/*      Write out the vertices of a new structure.  Note that it is     */
/*      only possible to write vertices at the end of the file.         */
/************************************************************************/

   int SHPWriteVertices(SHPHandle psSHP, int nVCount, int nPartCount,
                     int * panParts, double * padVertices )

   {
      int         nRecordOffset, i, j, nRecordSize;
      uchar *pabyRec;
      int32 i32;

      psSHP->bUpdated = TRUE;

   /* -------------------------------------------------------------------- */
   /*      Add the new entity to the in memory index.                      */
   /* -------------------------------------------------------------------- */
      psSHP->nRecords++;
      if( psSHP->nRecords > psSHP->nMaxRecords )
      {
         psSHP->nMaxRecords = psSHP->nMaxRecords * 1.3 + 100;

         psSHP->panRecOffset = (int *)
                              SfRealloc(psSHP->panRecOffset,sizeof(int) * psSHP->nMaxRecords );
         psSHP->panRecSize = (int *)
                             SfRealloc(psSHP->panRecSize,sizeof(int) * psSHP->nMaxRecords );
      }

   /* -------------------------------------------------------------------- */
   /*      Initialize record.                                              */
   /* -------------------------------------------------------------------- */
      psSHP->panRecOffset[psSHP->nRecords-1] = nRecordOffset = psSHP->nFileSize;

      pabyRec = (uchar *) SfMalloc(nVCount * 2 * sizeof(double)
                                  + nPartCount * 4 + 128);

   /* -------------------------------------------------------------------- */
   /*  Extract vertices for a Polygon or Arc.    */
   /* -------------------------------------------------------------------- */
      if( psSHP->nShapeType == SHPT_POLYGON || psSHP->nShapeType == SHPT_ARC )
      {
         int32  nPoints, nParts;
         int      i;

         nPoints = nVCount;
         nParts = nPartCount;

         _SHPSetBounds( pabyRec + 12, nVCount, padVertices );

         if( bBigEndian ) SwapWord( 4, &nPoints );
         if( bBigEndian ) SwapWord( 4, &nParts );

         ByteCopy( &nPoints, pabyRec + 40 + 8, 4 );
         ByteCopy( &nParts, pabyRec + 36 + 8, 4 );

         ByteCopy( panParts, pabyRec + 44 + 8, 4 * nPartCount );
         for( i = 0; i < nPartCount; i++ )
         {
            if( bBigEndian ) SwapWord( 4, pabyRec + 44 + 8 + 4*i );
         }

         for( i = 0; i < nVCount; i++ )
         {
            ByteCopy( padVertices+i*2,
                    pabyRec + 44 + 4*nPartCount + 8 + i * 16, 8 );
            ByteCopy( padVertices+i*2+1,
                    pabyRec + 44 + 4*nPartCount + 8 + i * 16 + 8, 8 );

            if( bBigEndian ) SwapWord( 8, pabyRec + 44+4*nPartCount+8+i*16 );
            if( bBigEndian ) SwapWord( 8, pabyRec + 44+4*nPartCount+8+i*16+8 );
         }

         nRecordSize = 44 + 4*nPartCount + 16 * nVCount;
      }

      /* -------------------------------------------------------------------- */
      /*  Extract vertices for a MultiPoint.     */
      /* -------------------------------------------------------------------- */
      else if( psSHP->nShapeType == SHPT_MULTIPOINT )
      {
         int32  nPoints;
         int      i;

         nPoints = nVCount;

         _SHPSetBounds( pabyRec + 12, nVCount, padVertices );

         if( bBigEndian ) SwapWord( 4, &nPoints );
         ByteCopy( &nPoints, pabyRec + 44, 4 );

         for( i = 0; i < nVCount; i++ )
         {
            ByteCopy( padVertices+i*2, pabyRec + 48 + i*16, 8 );
            ByteCopy( padVertices+i*2+1, pabyRec + 48 + i*16 + 8, 8 );

            if( bBigEndian ) SwapWord( 8, pabyRec + 48 + i*16 );
            if( bBigEndian ) SwapWord( 8, pabyRec + 48 + i*16 + 8 );
         }

         nRecordSize = 40 + 16 * nVCount;
      }

      /* -------------------------------------------------------------------- */
      /*      Extract vertices for a point.                                   */
      /* -------------------------------------------------------------------- */
      else if( psSHP->nShapeType == SHPT_POINT )
      {
         ByteCopy( padVertices+0, pabyRec + 12, 8 );
         ByteCopy( padVertices+1, pabyRec + 20, 8 );

         if( bBigEndian ) SwapWord( 8, pabyRec + 12 );
         if( bBigEndian ) SwapWord( 8, pabyRec + 20 );

         nRecordSize = 20;
      }

   /* -------------------------------------------------------------------- */
   /*      Set the shape type, record number, and record size.             */
   /* -------------------------------------------------------------------- */
      i32 = psSHP->nRecords-1+1;     /* record # */
      if( bBigEndian ) SwapWord( 4, &i32 );
      ByteCopy( &i32, pabyRec, 4 );

      i32 = nRecordSize/2;    /* record size */
      if( bBigEndian ) SwapWord( 4, &i32 );
      ByteCopy( &i32, pabyRec + 4, 4 );

      i32 = psSHP->nShapeType;    /* shape type */
      if( bBigEndian ) SwapWord( 4, &i32 );
      ByteCopy( &i32, pabyRec + 8, 4 );

   /* -------------------------------------------------------------------- */
   /*      Write out record.                                               */
   /* -------------------------------------------------------------------- */
      fseek( psSHP->fpSHP, nRecordOffset, 0 );
      fwrite( pabyRec, nRecordSize+8, 1, psSHP->fpSHP );
      free( pabyRec );

      psSHP->panRecSize[psSHP->nRecords-1] = nRecordSize;
      psSHP->nFileSize += nRecordSize + 8;

   /* -------------------------------------------------------------------- */
   /* Expand file wide bounds based on this shape.   */
   /* -------------------------------------------------------------------- */
      if( psSHP->nRecords == 1 )
      {
         psSHP->adBoundsMin[0] = psSHP->adBoundsMax[0] = padVertices[0];
         psSHP->adBoundsMin[1] = psSHP->adBoundsMax[1] = padVertices[1];
      }

      for( i = 0; i < nVCount; i++ )
      {
         psSHP->adBoundsMin[0] = MIN(psSHP->adBoundsMin[0],padVertices[i*2]);
         psSHP->adBoundsMin[1] = MIN(psSHP->adBoundsMin[1],padVertices[i*2+1]);
         psSHP->adBoundsMax[0] = MAX(psSHP->adBoundsMax[0],padVertices[i*2]);
         psSHP->adBoundsMax[1] = MAX(psSHP->adBoundsMax[1],padVertices[i*2+1]);
      }

      return( psSHP->nRecords - 1 );
   }

/************************************************************************/
/*                          SHPReadVertices()                           */
/*                                                                      */
/*      Read the vertices for one shape from the shape file.            */
/************************************************************************/

   double * SHPReadVertices( SHPHandle psSHP, int hEntity, int * pnVCount,
                     int * pnPartCount, int ** ppanParts )

   {
      int          nRecordOffset, i, j;
      static uchar *pabyRec = NULL;
      static double  *padVertices = NULL;
      static int  nVertMax = 0, nPartMax = 0, *panParts = NULL;
      static int  nBufSize = 0;
      int nShapeType;

   /* -------------------------------------------------------------------- */
   /*      Validate the record/entity number.                              */
   /* -------------------------------------------------------------------- */
      if( hEntity < 0 || hEntity >= psSHP->nRecords )
         return( NULL );

   /* -------------------------------------------------------------------- */
   /*      Ensure our record buffer is large enough.                       */
   /* -------------------------------------------------------------------- */

      if( psSHP->panRecSize[hEntity]+8 > nBufSize )
      {
         nBufSize = psSHP->panRecSize[hEntity]+8;
         pabyRec = (uchar *) SfRealloc(pabyRec,nBufSize);
      }

   /* -------------------------------------------------------------------- */
   /*      Read the record.                                                */
   /* -------------------------------------------------------------------- */
      fseek( psSHP->fpSHP, psSHP->panRecOffset[hEntity], 0 );
      fread( pabyRec, psSHP->panRecSize[hEntity]+8, 1, psSHP->fpSHP );

      /* Extract shape type */
      memcpy( &nShapeType, pabyRec + 8, 4 );

      if (debug)
        printf ("DBG: Shape:%d Offset:%d Size:%d Type:%d\n",
          hEntity,
          psSHP->panRecOffset[hEntity],
          psSHP->panRecSize[hEntity]+8,
          nShapeType);

      if( pnPartCount != NULL )
         *pnPartCount = 0;

      if( ppanParts != NULL )
         *ppanParts = NULL;

      *pnVCount = 0;

      if( nShapeType == 0 )
         return( NULL );

   /* -------------------------------------------------------------------- */
   /*  Extract vertices for a Polygon or Arc.    */
   /* -------------------------------------------------------------------- */
      if( psSHP->nShapeType == SHPT_POLYGON || psSHP->nShapeType == SHPT_ARC )
      {
         int32  nPoints, nParts;
         int      i;

         memcpy( &nPoints, pabyRec + 40 + 8, 4 );
         memcpy( &nParts, pabyRec + 36 + 8, 4 );

         if( bBigEndian ) SwapWord( 4, &nPoints );
         if( bBigEndian ) SwapWord( 4, &nParts );

         *pnVCount = nPoints;
         *pnPartCount = nParts;

      /* -------------------------------------------------------------------- */
      /*      Copy out the part array from the record.                        */
      /* -------------------------------------------------------------------- */
         if( nPartMax < nParts )
         {
            nPartMax = nParts;
            panParts = (int *) SfRealloc(panParts, nPartMax * sizeof(int) );
         }

         memcpy( panParts, pabyRec + 44 + 8, 4 * nParts );
         for( i = 0; i < nParts; i++ )
         {
            if( bBigEndian ) SwapWord( 4, panParts+i );
         }

      /* -------------------------------------------------------------------- */
      /*      Copy out the vertices from the record.                          */
      /* -------------------------------------------------------------------- */
         if( nVertMax < nPoints )
         {
            nVertMax = nPoints;
            padVertices = (double *) SfRealloc(padVertices,
                                            nVertMax * 2 * sizeof(double) );
         }

         for( i = 0; i < nPoints; i++ )
         {
            memcpy(&(padVertices[i*2]),
                  pabyRec + 44 + 4*nParts + 8 + i * 16,
                  8 );

            memcpy(&(padVertices[i*2+1]),
                  pabyRec + 44 + 4*nParts + 8 + i * 16 + 8,
                  8 );

            if( bBigEndian ) SwapWord( 8, padVertices+i*2 );
            if( bBigEndian ) SwapWord( 8, padVertices+i*2+1 );
         }
      }

      /* -------------------------------------------------------------------- */
      /*  Extract vertices for a MultiPoint.     */
      /* -------------------------------------------------------------------- */
      else if( psSHP->nShapeType == SHPT_MULTIPOINT )
      {
         int32  nPoints;
         int      i;

         memcpy( &nPoints, pabyRec + 44, 4 );
         if( bBigEndian ) SwapWord( 4, &nPoints );

         *pnVCount = nPoints;
         if( nVertMax < nPoints )
         {
            nVertMax = nPoints;
            padVertices = (double *) SfRealloc(padVertices,
                                            nVertMax * 2 * sizeof(double) );
         }

         for( i = 0; i < nPoints; i++ )
         {
            memcpy(padVertices+i*2,   pabyRec + 48 + 16 * i, 8 );
            memcpy(padVertices+i*2+1, pabyRec + 48 + 16 * i + 8, 8 );

            if( bBigEndian ) SwapWord( 8, padVertices+i*2 );
            if( bBigEndian ) SwapWord( 8, padVertices+i*2+1 );
         }
      }

      /* -------------------------------------------------------------------- */
      /*      Extract vertices for a point.                                   */
      /* -------------------------------------------------------------------- */
      else if( psSHP->nShapeType == SHPT_POINT )
      {
         *pnVCount = 1;
         if( nVertMax < 1 )
         {
            nVertMax = 1;
            padVertices = (double *) SfRealloc(padVertices,
                                            nVertMax * 2 * sizeof(double) );
         }

         memcpy( padVertices, pabyRec + 12, 8 );
         memcpy( padVertices+1, pabyRec + 20, 8 );

         if( bBigEndian ) SwapWord( 8, padVertices );
         if( bBigEndian ) SwapWord( 8, padVertices+1 );
      }

      *ppanParts = panParts;

      return( padVertices );
   }

/************************************************************************/
/*                           SHPReadBounds()                            */
/*                                                                      */
/*      Read the bounds for one shape, or for the whole shapefile.      */
/************************************************************************/

   void SHPReadBounds( SHPHandle psSHP, int hEntity, double * padBounds )

   {
   /* -------------------------------------------------------------------- */
   /*      Validate the record/entity number.                              */
   /* -------------------------------------------------------------------- */
      if( hEntity < -1 || hEntity >= psSHP->nRecords )
      {
         padBounds[0] = 0.0;
         padBounds[0] = 0.0;
         padBounds[0] = 0.0;
         padBounds[0] = 0.0;

         return;
      }

   /* -------------------------------------------------------------------- */
   /* If the entity is -1 we fetch the bounds for the whole file. */
   /* -------------------------------------------------------------------- */
      if( hEntity == -1 )
      {
         padBounds[0] = psSHP->adBoundsMin[0];
         padBounds[1] = psSHP->adBoundsMin[1];
         padBounds[2] = psSHP->adBoundsMax[0];
         padBounds[3] = psSHP->adBoundsMax[1];
      }

      /* -------------------------------------------------------------------- */
      /*      Extract bounds for any record but a point record.               */
      /* -------------------------------------------------------------------- */
      else if( psSHP->nShapeType != SHPT_POINT )
      {
         fseek( psSHP->fpSHP, psSHP->panRecOffset[hEntity]+12, 0 );
         fread( padBounds, sizeof(double)*4, 1, psSHP->fpSHP );

         if( bBigEndian )
         {
            SwapWord( 8, padBounds );
            SwapWord( 8, padBounds+1 );
            SwapWord( 8, padBounds+2 );
            SwapWord( 8, padBounds+3 );
         }
      }

      /* -------------------------------------------------------------------- */
      /*      For points we fetch the point, and duplicate it as the          */
      /*      minimum and maximum bound.                                      */
      /* -------------------------------------------------------------------- */
      else
      {
         fseek( psSHP->fpSHP, psSHP->panRecOffset[hEntity]+12, 0 );
         fread( padBounds, sizeof(double)*2, 1, psSHP->fpSHP );

         if( bBigEndian )
         {
            SwapWord( 8, padBounds );
            SwapWord( 8, padBounds+1 );
         }

         memcpy( padBounds+2, padBounds, 2*sizeof(double) );
      }
   }
