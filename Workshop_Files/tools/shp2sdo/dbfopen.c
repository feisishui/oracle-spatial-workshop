/*
 * Copyright (c) 1995 Frank Warmerdam
 *
 * This code is in the public domain.
 *
 * $Log: dbfopen.c,v $
 * Revision 1.11 2003/08/10 00:00:00  Albert Godfrind - Oracle Corp
 * Corrected parsing of blank (null) numbers (see DBFReadAttribute())
 *
 * Revision 1.10 2003/02/26 00:00:00  Albert Godfrind - Oracle Corp
 * Added support for long integers (see DBFReadAttribute())
 *
 * Revision 1.9  1998/12/03 00:00:00  Albert Godfrind - Oracle Corp
 * Added checks for malloc() and realloc() failures
 *
 * Revision 1.7  1997/03/06 14:02:10  warmerda
 * Ensure bUpdated is initialized.
 *
 * Revision 1.6  1996/02/12 04:54:41  warmerda
 * Ensure that DBFWriteAttribute() returns TRUE if it succeeds.
 *
 * Revision 1.5  1995/10/21  03:15:12  warmerda
 * Changed to use binary file access, and ensure that the
 * field name field is zero filled, and limited to 10 chars.
 *
 * Revision 1.4  1995/08/24  18:10:42  warmerda
 * Added use of SfRealloc() to avoid pre-ANSI realloc() functions such
 * as on the Sun.
 *
 * Revision 1.3  1995/08/04  03:15:16  warmerda
 * Fixed up header.
 *
 * Revision 1.2  1995/08/04  03:14:43  warmerda
 * Added header.
 */

   static char rcsid[] =
   "$Id: dbfopen.c,v 1.7 1997/03/06 14:02:10 warmerda Exp $";

#include "shapefil.h"

#include <math.h>

/* Added 12/15/97 JK for 'clean' compile under VC++ 5.0 under NT 4.0 sp3 */
#include <stdlib.h>
#include <string.h>

   typedef unsigned char uchar;

#ifndef FALSE
#  define FALSE   0
#  define TRUE    1
#endif

   extern int debug;
   extern int verbose;

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

      if( pMem == NULL )
         pNewMem = (void *) malloc(nNewSize);
      else
         pNewMem = (void *) realloc(pMem,nNewSize);
      if( pNewMem == NULL)
      {
         printf ("*** Error re-allocating %d bytes of memory\n", nNewSize);
         exit (1);
      }
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
      return (pNewMem);
   }

/************************************************************************/
/*                           DBFWriteHeader()                           */
/*                                                                      */
/*      This is called to write out the file header, and field          */
/*      descriptions before writing any actual data records.  This      */
/*      also computes all the DBFDataSet field offset/size/decimals     */
/*      and so forth values.                                            */
/************************************************************************/

   static void DBFWriteHeader(DBFHandle psDBF)

   {
      uchar abyHeader[32];
      int   i;

      if( !psDBF->bNoHeader )
         return;

      psDBF->bNoHeader = FALSE;

   /* -------------------------------------------------------------------- */
   /* Initialize the file header information.       */
   /* -------------------------------------------------------------------- */
      for( i = 0; i < 32; i++ )
         abyHeader[i] = 0;

      abyHeader[0] = 0x03;    /* memo field? - just copying   */

    /* date updated on close, record count preset at zero */

      abyHeader[8] = psDBF->nHeaderLength % 256;
      abyHeader[9] = psDBF->nHeaderLength / 256;

      abyHeader[10] = psDBF->nRecordLength % 256;
      abyHeader[11] = psDBF->nRecordLength / 256;

   /* -------------------------------------------------------------------- */
   /*      Write the initial 32 byte file header, and all the field        */
   /*      descriptions.                                                   */
   /* -------------------------------------------------------------------- */
      fseek( psDBF->fp, 0, 0 );
      fwrite( abyHeader, 32, 1, psDBF->fp );
      fwrite( psDBF->pszHeader, 32, psDBF->nFields, psDBF->fp );
   }

/************************************************************************/
/*                           DBFFlushRecord()                           */
/*                                                                      */
/*      Write out the current record if there is one.                   */
/************************************************************************/

   static void DBFFlushRecord( DBFHandle psDBF )

   {
      int   nRecordOffset;

      if( psDBF->bCurrentRecordModified && psDBF->nCurrentRecord > -1 )
      {
         psDBF->bCurrentRecordModified = FALSE;

         nRecordOffset = psDBF->nRecordLength * psDBF->nCurrentRecord
                         + psDBF->nHeaderLength;

         fseek( psDBF->fp, nRecordOffset, 0 );
         fwrite( psDBF->pszCurrentRecord, psDBF->nRecordLength, 1, psDBF->fp );
      }
   }

/************************************************************************/
/*                              DBFOpen()                               */
/*                                                                      */
/*      Open a .dbf file.                                               */
/************************************************************************/

   DBFHandle DBFOpen( const char * pszFilename, const char * pszAccess )

   {
      DBFHandle   psDBF;
      uchar   *pabyBuf;
      int     nFields, nRecords, nHeadLen, nRecLen, iField ;
   /*, i; UNREFERENCED 12/15/97 JK*/

   /* -------------------------------------------------------------------- */
   /*      We only allow the access strings "rb" and "r+".                 */
   /* -------------------------------------------------------------------- */
      if( strcmp(pszAccess,"r") != 0 && strcmp(pszAccess,"r+") != 0
        && strcmp(pszAccess,"rb") != 0 && strcmp(pszAccess,"rb+") != 0 )
         return( NULL );

      psDBF = (DBFHandle) calloc( 1, sizeof(DBFInfo) );
      psDBF->fp = fopen( pszFilename, pszAccess );
      if( psDBF->fp == NULL )
         return( NULL );

      psDBF->bNoHeader = FALSE;
      psDBF->nCurrentRecord = -1;
      psDBF->bCurrentRecordModified = FALSE;

   /* -------------------------------------------------------------------- */
   /*  Read Table Header info                                              */
   /* -------------------------------------------------------------------- */
      pabyBuf = (uchar *) SfMalloc(500);
      fread( pabyBuf, 32, 1, psDBF->fp );

      psDBF->nRecords = nRecords =
                        pabyBuf[4] + pabyBuf[5]*256 + pabyBuf[6]*256*256 + pabyBuf[7]*256*256*256;

      psDBF->nHeaderLength = nHeadLen = pabyBuf[8] + pabyBuf[9]*256;
      psDBF->nRecordLength = nRecLen = pabyBuf[10] + pabyBuf[11]*256;

      psDBF->nFields = nFields = (nHeadLen - 32) / 32;
      if (verbose)
      {
         printf ("Attribute file:\n");
         printf ("  Number of records : %d\n", psDBF->nRecords);
         printf ("  Number of attributes : %d\n", psDBF->nFields);
         printf ("  Header length : %d\n", psDBF->nHeaderLength);
         printf ("  Record length : %d\n", psDBF->nRecordLength);
      }
      psDBF->pszCurrentRecord = (char *) SfMalloc(nRecLen);

   /* -------------------------------------------------------------------- */
   /*  Read in Field Definitions                                           */
   /* -------------------------------------------------------------------- */

      pabyBuf = (uchar *) SfRealloc(pabyBuf,nHeadLen);
      psDBF->pszHeader = (char *) pabyBuf;

      fseek( psDBF->fp, 32, 0 );
      fread( pabyBuf, nHeadLen, 1, psDBF->fp );

      psDBF->panFieldOffset = (int *) SfMalloc(sizeof(int) * nFields);
      psDBF->panFieldSize = (int *) SfMalloc(sizeof(int) * nFields);
      psDBF->panFieldDecimals = (int *) SfMalloc(sizeof(int) * nFields);
      psDBF->pachFieldType = (char *) SfMalloc(sizeof(char) * nFields);

      for( iField = 0; iField < nFields; iField++ )
      {
      /*        char            *pszTitle; UNREFERENCED 12/15/97 JK*/
      /*        int             nType; UNREFERENCED 12/15/97 JK*/
         uchar    *pabyFInfo;

         pabyFInfo = pabyBuf+iField*32;

         /* Added support for F (float) type 07-Apr-2004 AG */
         if( pabyFInfo[11] == 'N' || pabyFInfo[11] == 'F')
         {
            psDBF->panFieldSize[iField] = pabyFInfo[16];
            psDBF->panFieldDecimals[iField] = pabyFInfo[17];
         }
         else
         {
            psDBF->panFieldSize[iField] = pabyFInfo[16] + pabyFInfo[17]*256;
            psDBF->panFieldDecimals[iField] = 0;
         }

         psDBF->pachFieldType[iField] = (char) pabyFInfo[11];
         if( iField == 0 )
            psDBF->panFieldOffset[iField] = 1;
         else
            psDBF->panFieldOffset[iField] =
               psDBF->panFieldOffset[iField-1] + psDBF->panFieldSize[iField-1];
      }

      return( psDBF );
   }

/************************************************************************/
/*                              DBFClose()                              */
/************************************************************************/

   void DBFClose(DBFHandle psDBF)
   {
   /* -------------------------------------------------------------------- */
   /*      Write out header if not already written.                        */
   /* -------------------------------------------------------------------- */
      if( psDBF->bNoHeader )
         DBFWriteHeader( psDBF );

      DBFFlushRecord( psDBF );

   /* -------------------------------------------------------------------- */
   /*      Update last access date, and number of records if we have  */
   /* write access.                         */
   /* -------------------------------------------------------------------- */
      if( psDBF->bUpdated )
      {
         uchar    abyFileHeader[32];

         fseek( psDBF->fp, 0, 0 );
         fread( abyFileHeader, 32, 1, psDBF->fp );

         abyFileHeader[1] = 95;     /* YY */
         abyFileHeader[2] = 7;      /* MM */
         abyFileHeader[3] = 26;     /* DD */

         abyFileHeader[4] = psDBF->nRecords % 256;
         abyFileHeader[5] = (psDBF->nRecords/256) % 256;
         abyFileHeader[6] = (psDBF->nRecords/(256*256)) % 256;
         abyFileHeader[7] = (psDBF->nRecords/(256*256*256)) % 256;

         fseek( psDBF->fp, 0, 0 );
         fwrite( abyFileHeader, 32, 1, psDBF->fp );
      }

   /* -------------------------------------------------------------------- */
   /*      Close, and free resources.                                      */
   /* -------------------------------------------------------------------- */
      fclose( psDBF->fp );

      if( psDBF->panFieldOffset != NULL )
      {
         free( psDBF->panFieldOffset );
         free( psDBF->panFieldSize );
         free( psDBF->panFieldDecimals );
         free( psDBF->pachFieldType );
      }

      free( psDBF->pszHeader );
      free( psDBF->pszCurrentRecord );

      free( psDBF );
   }

/************************************************************************/
/*                             DBFCreate()                              */
/*                                                                      */
/*      Create a new .dbf file.                                         */
/************************************************************************/

   DBFHandle DBFCreate( const char * pszFilename )

   {
      DBFHandle psDBF;
      FILE  *fp;

   /* -------------------------------------------------------------------- */
   /*      Create the file.                                                */
   /* -------------------------------------------------------------------- */
      fp = fopen( pszFilename, "wb" );
      if( fp == NULL )
         return( NULL );

      fputc( 0, fp );
      fclose( fp );

      fp = fopen( pszFilename, "rb+" );
      if( fp == NULL )
         return( NULL );

   /* -------------------------------------------------------------------- */
   /*     Create the info structure.                                       */
   /* -------------------------------------------------------------------- */
      psDBF = (DBFHandle) SfMalloc(sizeof(DBFInfo));

      psDBF->fp = fp;
      psDBF->nRecords = 0;
      psDBF->nFields = 0;
      psDBF->nRecordLength = 1;
      psDBF->nHeaderLength = 32;

      psDBF->panFieldOffset = NULL;
      psDBF->panFieldSize = NULL;
      psDBF->panFieldDecimals = NULL;
      psDBF->pachFieldType = NULL;
      psDBF->pszHeader = NULL;

      psDBF->nCurrentRecord = -1;
      psDBF->bCurrentRecordModified = FALSE;
      psDBF->pszCurrentRecord = NULL;

      psDBF->bNoHeader = TRUE;

      return( psDBF );
   }

/************************************************************************/
/*                            DBFAddField()                             */
/*                                                                      */
/*      Add a field to a newly created .dbf file before any records     */
/*      are written.                                                    */
/************************************************************************/

   int  DBFAddField(DBFHandle psDBF, const char * pszFieldName,
                    DBFFieldType eType, int nWidth, int nDecimals )

   {
      char  *pszFInfo;
      int   i;

   /* -------------------------------------------------------------------- */
   /*      Do some checking to ensure we can add records to this file.     */
   /* -------------------------------------------------------------------- */
      if( psDBF->nRecords > 0 )
         return( FALSE );

      if( !psDBF->bNoHeader )
         return( FALSE );

      if( eType != FTDouble && nDecimals != 0 )
         return( FALSE );

   /* -------------------------------------------------------------------- */
   /*      SfRealloc all the arrays larger to hold the additional field    */
   /*      information.                                                    */
   /* -------------------------------------------------------------------- */
      psDBF->nFields++;

      psDBF->panFieldOffset = (int *)
                           SfRealloc( psDBF->panFieldOffset, sizeof(int) * psDBF->nFields );

      psDBF->panFieldSize = (int *)
                           SfRealloc( psDBF->panFieldSize, sizeof(int) * psDBF->nFields );

      psDBF->panFieldDecimals = (int *)
                           SfRealloc( psDBF->panFieldDecimals, sizeof(int) * psDBF->nFields );

      psDBF->pachFieldType = (char *)
                           SfRealloc( psDBF->pachFieldType, sizeof(char) * psDBF->nFields );

   /* -------------------------------------------------------------------- */
   /*      Assign the new field information fields.                        */
   /* -------------------------------------------------------------------- */
      psDBF->panFieldOffset[psDBF->nFields-1] = psDBF->nRecordLength;
      psDBF->nRecordLength += nWidth;
      psDBF->panFieldSize[psDBF->nFields-1] = nWidth;
      psDBF->panFieldDecimals[psDBF->nFields-1] = nDecimals;

      if( eType == FTString )
         psDBF->pachFieldType[psDBF->nFields-1] = 'C';
      else
         psDBF->pachFieldType[psDBF->nFields-1] = 'N';

   /* -------------------------------------------------------------------- */
   /*      Extend the required header information.                         */
   /* -------------------------------------------------------------------- */
      psDBF->nHeaderLength += 32;
      psDBF->bUpdated = FALSE;

      psDBF->pszHeader = (char *) SfRealloc(psDBF->pszHeader,psDBF->nFields*32);

      pszFInfo = psDBF->pszHeader + 32 * (psDBF->nFields-1);

      for( i = 0; i < 32; i++ )
         pszFInfo[i] = '\0';

      if( strlen(pszFieldName) < 10 )
         strncpy( pszFInfo, pszFieldName, strlen(pszFieldName));
      else
         strncpy( pszFInfo, pszFieldName, 10);

      pszFInfo[11] = psDBF->pachFieldType[psDBF->nFields-1];

      if( eType == FTString )
      {
         pszFInfo[16] = nWidth % 256;
         pszFInfo[17] = nWidth / 256;
      }
      else
      {
         pszFInfo[16] = nWidth;
         pszFInfo[17] = nDecimals;
      }

   /* -------------------------------------------------------------------- */
   /*      Make the current record buffer appropriately larger.            */
   /* -------------------------------------------------------------------- */
      psDBF->pszCurrentRecord = (char *) SfRealloc(psDBF->pszCurrentRecord,
                                             psDBF->nRecordLength);

      return( TRUE );
   }

/************************************************************************/
/*                          DBFReadAttribute()                          */
/*                                                                      */
/*      Read one of the attribute fields of a record.                   */
/************************************************************************/

   static void *DBFReadAttribute(DBFHandle psDBF, int hEntity, int iField )
   {
      int   nRecordOffset ; /* i, j; UNREFERENCED JK 12/15/97 */
      int   i;
      uchar *pabyRec;
    /* char *pszSField;   UNREFERENCED JK 12/15/97 */
      void  *pReturnField = NULL;

      static double dDoubleField;
      static char * pszStringField = NULL;
      static int  nStringFieldLen = 0;

   /* -------------------------------------------------------------------- */
   /*     Have we read the record?                                         */
   /* -------------------------------------------------------------------- */
      if( hEntity < 0 || hEntity >= psDBF->nRecords )
         return( NULL );

      if( psDBF->nCurrentRecord != hEntity )
      {
         DBFFlushRecord( psDBF );

         nRecordOffset = psDBF->nRecordLength * hEntity + psDBF->nHeaderLength;

         fseek( psDBF->fp, nRecordOffset, 0 );
         fread( psDBF->pszCurrentRecord, psDBF->nRecordLength, 1, psDBF->fp );

         psDBF->nCurrentRecord = hEntity;
      }

      pabyRec = (uchar *) psDBF->pszCurrentRecord;

   /* -------------------------------------------------------------------- */
   /*     Ensure our field buffer is large enough to hold this buffer.     */
   /* -------------------------------------------------------------------- */
      if( psDBF->panFieldSize[iField]+1 > nStringFieldLen )
      {
         nStringFieldLen = psDBF->panFieldSize[iField]*2 + 10;
         pszStringField = (char *) SfRealloc(pszStringField,nStringFieldLen);
      }

   /* -------------------------------------------------------------------- */
   /*     Extract the requested field.                                     */
   /* -------------------------------------------------------------------- */

      /* Type cast (const char *) for clean compile 12/17/97 DG */
      strncpy( pszStringField,
             (const char *) pabyRec+psDBF->panFieldOffset[iField],
             psDBF->panFieldSize[iField] );
      pszStringField[psDBF->panFieldSize[iField]] = '\0';

      if (debug)
        printf ("DBG: Row:%d Col:%d Length: %d [%s]\n",
          hEntity, iField, strlen(pszStringField), pszStringField);

      pReturnField = pszStringField;

   /* -------------------------------------------------------------------- */
   /*      Decode the field.                                               */
   /* -------------------------------------------------------------------- */
   /* Added support for F (float) type 07-Apr-2004 AG */
      if( psDBF->pachFieldType[iField] == 'N'
        || psDBF->pachFieldType[iField] == 'D'
        || psDBF->pachFieldType[iField] == 'F' )
      {
         /* 26-Feb-03 AG:
            Always use SSCANF even if no decimals. This makes it possible
            to process long integer values (more than 9 digits
            Removed following code :

         if( psDBF->panFieldDecimals[iField] == 0 )
            dDoubleField = atoi(pszStringField);
         else
            sscanf( pszStringField, "%lf", &dDoubleField );

         */

         /* 10-Aug-2003 AG:
            If input string is empty (all blanks) then return a null
            pointer. This will be used by the caller to determine that
            there is no value for this field.
         */

         i=0;
         while (i<strlen(pszStringField) && pszStringField[i] == '*')
           i++;
         while (i<strlen(pszStringField) && pszStringField[i] == ' ')
           i++;
         if (i < strlen(pszStringField)) {
           dDoubleField = 0.0;
           sscanf( pszStringField, "%lf", &dDoubleField );
           if (debug)
             printf ("DBG: %f\n", dDoubleField);
           pReturnField = &dDoubleField;
         }
         else
           pReturnField = NULL;
      }

      return( pReturnField );
   }

/************************************************************************/
/*                        DBFReadIntAttribute()                         */
/*                                                                      */
/*      Read an integer attribute.                                      */
/************************************************************************/

   /* 10-Aug-2003 AG:
      Change this function to return an int* instead of an int. A null
      pointer will be used to indicate that the requested attribute
      has no value in the DBF file (the original string value is all
      blanks)
   */

   int *DBFReadIntegerAttribute( DBFHandle psDBF, int iRecord, int iField )

   {
      double  *pdValue;
      static int piValue;

      pdValue = (double *) DBFReadAttribute( psDBF, iRecord, iField );

      if (pdValue == NULL)
        return (NULL);

      piValue = (int) *pdValue;
      return( &piValue );

   }

/************************************************************************/
/*                        DBFReadDoubleAttribute()                      */
/*                                                                      */
/*      Read a double attribute.                                        */
/************************************************************************/

   /* 10-Aug-2003 AG:
      Change this function to return an int* instead of an int. A null
      pointer will be used to indicate that the requested attribute
      has no value in the DBF file (the original string value is all
      blanks)
   */

   double *DBFReadDoubleAttribute( DBFHandle psDBF, int iRecord, int iField )

   {
      double  *pdValue;

      pdValue = (double *) DBFReadAttribute( psDBF, iRecord, iField );

      return( pdValue );
   }

/************************************************************************/
/*                        DBFReadStringAttribute()                      */
/*                                                                      */
/*      Read a string attribute.                                        */
/************************************************************************/

   const char *DBFReadStringAttribute( DBFHandle psDBF, int iRecord, int iField )

   {
      return( (const char *) DBFReadAttribute( psDBF, iRecord, iField ) );
   }

/************************************************************************/
/*                          DBFGetFieldCount()                          */
/*                                                                      */
/*      Return the number of fields in this table.                      */
/************************************************************************/

   int  DBFGetFieldCount( DBFHandle psDBF )

   {
      return( psDBF->nFields );
   }

/************************************************************************/
/*                         DBFGetRecordCount()                          */
/*                                                                      */
/*      Return the number of records in this table.                     */
/************************************************************************/

   int  DBFGetRecordCount( DBFHandle psDBF )

   {
      return( psDBF->nRecords );
   }

/************************************************************************/
/*                          DBFGetFieldInfo()                           */
/*                                                                      */
/*      Return any requested information about the field.               */
/************************************************************************/

   DBFFieldType DBFGetFieldInfo( DBFHandle psDBF, int iField, char * pszFieldName,
                     int * pnWidth, int * pnDecimals )

   {
      if( iField < 0 || iField >= psDBF->nFields )
         return( FTInvalid );

      if( pnWidth != NULL )
         *pnWidth = psDBF->panFieldSize[iField];

      if( pnDecimals != NULL )
         *pnDecimals = psDBF->panFieldDecimals[iField];

      if( pszFieldName != NULL )
      {
         int  i;

         strncpy( pszFieldName, (char *) psDBF->pszHeader+iField*32, 11 );
         pszFieldName[11] = '\0';
         for( i = 10; i > 0 && pszFieldName[i] == ' '; i-- )
            pszFieldName[i] = '\0';
      }

      /* Added support for F (float) type 07-Apr-2004 AG */
      if( psDBF->pachFieldType[iField] == 'N'
        || psDBF->pachFieldType[iField] == 'F' )
      {
         if( psDBF->panFieldDecimals[iField] > 0 )
            return( FTDouble );
         else
            return( FTInteger );
      }
      /* Added support for D (date) type 20-Feb-2005 AG */
      if( psDBF->pachFieldType[iField] == 'D')
         return( FTDate );
      else
         return( FTString );
   }

/************************************************************************/
/*                         DBFWriteAttribute()                          */
/*                  */
/*  Write an attribute record to the file.        */
/************************************************************************/

   static int DBFWriteAttribute(DBFHandle psDBF, int hEntity, int iField,
                     void * pValue )

   {
      int         nRecordOffset, i, j;
      uchar *pabyRec;
      char  szSField[40], szFormat[12];

   /* -------------------------------------------------------------------- */
   /* Is this a valid record?           */
   /* -------------------------------------------------------------------- */
      if( hEntity < 0 || hEntity > psDBF->nRecords )
         return( FALSE );

      if( psDBF->bNoHeader )
         DBFWriteHeader(psDBF);

   /* -------------------------------------------------------------------- */
   /*      Is this a brand new record?                                     */
   /* -------------------------------------------------------------------- */
      if( hEntity == psDBF->nRecords )
      {
         DBFFlushRecord( psDBF );

         psDBF->nRecords++;
         for( i = 0; i < psDBF->nRecordLength; i++ )
            psDBF->pszCurrentRecord[i] = ' ';

         psDBF->nCurrentRecord = hEntity;
      }

   /* -------------------------------------------------------------------- */
   /*      Is this an existing record, but different than the last one     */
   /*      we accessed?                                                    */
   /* -------------------------------------------------------------------- */
      if( psDBF->nCurrentRecord != hEntity )
      {
         DBFFlushRecord( psDBF );

         nRecordOffset = psDBF->nRecordLength * hEntity + psDBF->nHeaderLength;

         fseek( psDBF->fp, nRecordOffset, 0 );
         fread( psDBF->pszCurrentRecord, psDBF->nRecordLength, 1, psDBF->fp );

         psDBF->nCurrentRecord = hEntity;
      }

      pabyRec = (uchar *) psDBF->pszCurrentRecord;

   /* -------------------------------------------------------------------- */
   /*      Assign all the record fields.                                   */
   /* -------------------------------------------------------------------- */
      switch( psDBF->pachFieldType[iField] )
      {
         case 'D':
         case 'N':
            if( psDBF->panFieldDecimals[iField] == 0 )
            {
               sprintf( szFormat, "%%%dd", psDBF->panFieldSize[iField] );
               sprintf(szSField, szFormat, (int) *((double *) pValue) );
               if( strlen(szSField) > psDBF->panFieldSize[iField] )
                  szSField[psDBF->panFieldSize[iField]] = '\0';
               strncpy((char *) (pabyRec+psDBF->panFieldOffset[iField]),
                      szSField, strlen(szSField) );
            }
            else
            {
               sprintf( szFormat, "%%%d.%df",
                      psDBF->panFieldSize[iField],
                      psDBF->panFieldDecimals[iField] );
               sprintf(szSField, szFormat, *((double *) pValue) );
               if( strlen(szSField) > psDBF->panFieldSize[iField] )
                  szSField[psDBF->panFieldSize[iField]] = '\0';
               strncpy((char *) (pabyRec+psDBF->panFieldOffset[iField]),
                      szSField, strlen(szSField) );
            }
            break;

         default:
            if( strlen((char *) pValue) > psDBF->panFieldSize[iField] )
               j = psDBF->panFieldSize[iField];
            else
               j = strlen((char *) pValue);

            strncpy((char *) (pabyRec+psDBF->panFieldOffset[iField]),
                   (char *) pValue, j );
            break;
      }

      psDBF->bCurrentRecordModified = TRUE;
      psDBF->bUpdated = TRUE;

      return( TRUE );
   }

/************************************************************************/
/*                      DBFWriteDoubleAttribute()                       */
/*                                                                      */
/*      Write a double attribute.                                       */
/************************************************************************/

   int DBFWriteDoubleAttribute( DBFHandle psDBF, int iRecord, int iField,
                     double dValue )

   {
      return( DBFWriteAttribute( psDBF, iRecord, iField, (void *) &dValue ) );
   }

/************************************************************************/
/*                      DBFWriteIntegerAttribute()                      */
/*                                                                      */
/*      Write a integer attribute.                                      */
/************************************************************************/

   int DBFWriteIntegerAttribute( DBFHandle psDBF, int iRecord, int iField,
                     int nValue )

   {
      double  dValue = nValue;

      return( DBFWriteAttribute( psDBF, iRecord, iField, (void *) &dValue ) );
   }

/************************************************************************/
/*                      DBFWriteStringAttribute()                       */
/*                                                                      */
/*      Write a string attribute.                                       */
/************************************************************************/

   int DBFWriteStringAttribute( DBFHandle psDBF, int iRecord, int iField,
                     const char * pszValue )

   {
      return( DBFWriteAttribute( psDBF, iRecord, iField, (void *) pszValue ) );
   }
