/*
===============================================================================

  FILE:  laszip.cpp
  
  CONTENTS:
  
    This tool compresses and uncompresses LIDAR data in the LAS format to our
    losslessly compressed LAZ format.

  PROGRAMMERS:

    martin.isenburg@gmail.com

  COPYRIGHT:

    (c) 2007-2011, Martin Isenburg, LASSO - tools to catch reality

    This is free software; you can redistribute and/or modify it under the
    terms of the GNU Lesser General Licence as published by the Free Software
    Foundation. See the COPYING file for more information.

    This software is distributed WITHOUT ANY WARRANTY and without even the
    implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  
  CHANGE HISTORY:
  
    5 August 2011 -- possible to add/change projection info in command line
    23 June 2011 -- turned on LASzip version 2.0 compressor with chunking 
    17 May 2011 -- enabling batch processing with wildcards or multiple file names
    25 April 2011 -- added chunking for random access decompression
    23 January 2011 -- added LASreadOpener and LASwriteOpener 
    16 December 2010 -- updated to use the new library
    12 March 2009 -- updated to ask for input if started without arguments 
    17 September 2008 -- updated to deal with LAS format version 1.2
    14 February 2007 -- created after picking flowers for the Valentine dinner
  
===============================================================================
*/

#include <time.h>
#include <stdlib.h>

#include "lasreader.hpp"
#include "laswriter.hpp"
#include "geoprojectionconverter.hpp"

void usage(bool wait=false)
{
  fprintf(stderr,"usage:\n");
  fprintf(stderr,"laszip *.las\n");
  fprintf(stderr,"laszip *.laz\n");
  fprintf(stderr,"laszip *.txt -iparse xyztiarn\n");
  fprintf(stderr,"laszip lidar.las\n");
  fprintf(stderr,"laszip lidar.laz -v\n");
  fprintf(stderr,"laszip -i lidar.las -o lidar_zipped.laz\n");
  fprintf(stderr,"laszip -i lidar.laz -o lidar_unzipped.las\n");
  fprintf(stderr,"laszip -i lidar.las -stdout -olaz > lidar.laz\n");
  fprintf(stderr,"laszip -stdin -o lidar.laz < lidar.las\n");
  fprintf(stderr,"laszip -h\n");
  if (wait)
  {
    fprintf(stderr,"<press ENTER>\n");
    getc(stdin);
  }
  exit(1);
}

static void byebye(bool wait=false)
{
  if (wait)
  {
    fprintf(stderr,"<press ENTER>\n");
    getc(stdin);
  }
  exit(1);
}

static double taketime()
{
  return (double)(clock())/CLOCKS_PER_SEC;
}

int main(int argc, char *argv[])
{
  int i;
  bool dry = false;
  bool verbose = false;
  bool report_file_size = false;
  bool projection_was_set = false;
  double start_time = 0.0;

  LASreadOpener lasreadopener;
  GeoProjectionConverter geoprojectionconverter;
  LASwriteOpener laswriteopener;

  lasreadopener.set_merged(FALSE);
  lasreadopener.set_populate_header(FALSE);

  if (argc == 1)
  {
    fprintf(stderr,"laszip.exe is better run in the command line\n");
    char file_name[256];
    fprintf(stderr,"enter input file: "); fgets(file_name, 256, stdin);
    file_name[strlen(file_name)-1] = '\0';
    lasreadopener.set_file_name(file_name);
    fprintf(stderr,"enter output file: "); fgets(file_name, 256, stdin);
    file_name[strlen(file_name)-1] = '\0';
    laswriteopener.set_file_name(file_name);
  }
  else
  {
    if (!geoprojectionconverter.parse(argc, argv)) byebye();
    if (!lasreadopener.parse(argc, argv)) byebye();
    if (!laswriteopener.parse(argc, argv)) byebye();
  }

  for (i = 1; i < argc; i++)
  {
    if (argv[i][0] == '\0')
    {
      continue;
    }
    else if (strcmp(argv[i],"-h") == 0 || strcmp(argv[i],"-help") == 0)
    {
      fprintf(stderr, "LAStools (by martin.isenburg@gmail.com) version %d\n", LAS_TOOLS_VERSION);
      usage();
    }
    else if (strcmp(argv[i],"-v") == 0 || strcmp(argv[i],"-verbose") == 0)
    {
      verbose = true;
    }
    else if (strcmp(argv[i],"-version") == 0)
    {
      fprintf(stderr, "LAStools (by martin.isenburg@gmail.com) version %d\n", LAS_TOOLS_VERSION);
      byebye();
    }
    else if (strcmp(argv[i],"-dry") == 0)
    {
      dry = true;
    }
    else if (strcmp(argv[i],"-size") == 0)
    {
      report_file_size = true;
    }
    else if (argv[i][0] != '-')
    {
      lasreadopener.set_file_name(argv[i]);
    }
    else
    {
      fprintf(stderr, "ERROR: cannot understand argument '%s'\n", argv[i]);
      usage();
    }
  }

  // check input

  if (!lasreadopener.active())
  {
    fprintf(stderr,"ERROR: no input specified\n");
    usage(argc == 1);
  }

  // check if projection info was set in the command line

  int number_of_keys;
  GeoProjectionGeoKeys* geo_keys = 0;
  int num_geo_double_params;
  double* geo_double_params = 0;

  if (geoprojectionconverter.has_projection())
  {
    projection_was_set = geoprojectionconverter.get_geo_keys_from_projection(number_of_keys, &geo_keys, num_geo_double_params, &geo_double_params);
  }

  // possibly loop over multiple input files

  while (lasreadopener.active())
  {
    if (verbose) start_time = taketime();

    // open lasreader

    LASreader* lasreader = lasreadopener.open();

    if (lasreader == 0)
    {
      fprintf(stderr, "ERROR: could not open lasreader\n");
      byebye(argc==1);
    }

    if (report_file_size)
    {
      // maybe only report uncompressed file size
      I64 uncompressed_file_size = (I64)lasreader->header.number_of_point_records * (I64)lasreader->header.point_data_record_length + lasreader->header.offset_to_point_data;
      if (uncompressed_file_size == (I64)((U32)uncompressed_file_size))
        fprintf(stderr,"uncompressed file size is %u bytes or %.2f MB for '%s'\n", (U32)uncompressed_file_size, (F64)uncompressed_file_size/1024.0/1024.0, lasreadopener.get_file_name());
      else
        fprintf(stderr,"uncompressed file size is %.2f MB or %.2f GB for '%s'\n", (F64)uncompressed_file_size/1024.0/1024.0, (F64)uncompressed_file_size/1024.0/1024.0/1024.0, lasreadopener.get_file_name());
    }
    else if (dry)
    {
      // maybe only a dry read pass
      start_time = taketime();
      while (lasreader->read_point());
      fprintf(stderr,"needed %g secs to read '%s'\n", taketime()-start_time, lasreadopener.get_file_name());
    }
    else
    {
      // create output file name if no output was specified 
      if (!laswriteopener.active())
      {
        if (lasreadopener.get_file_name() == 0)
        {
          fprintf(stderr,"ERROR: no output specified\n");
          usage(argc == 1);
        }
        char* file_name_out = strdup(lasreadopener.get_file_name());
        int len = strlen(file_name_out);
        if (strstr(file_name_out, ".las"))
        {
          file_name_out[len-1] = 'z';
        }
        else if (strstr(file_name_out, ".laz"))
        {
          file_name_out[len-1] = 's';
        }
        else if (strstr(file_name_out, ".LAS"))
        {
          file_name_out[len-1] = 'Z';
        }
        else if (strstr(file_name_out, ".LAZ"))
        {
          file_name_out[len-1] = 'S';
        }
        else if (strstr(file_name_out, ".txt"))
        {
          file_name_out[len-3] = 'l';
          file_name_out[len-2] = 'a';
          file_name_out[len-1] = 'z';
        }
        else
        {
          fprintf(stderr,"ERROR: cannot guess output from input file name '%s'\n", file_name_out);
          usage(argc == 1);
        }
        laswriteopener.set_file_name(file_name_out);
        free(file_name_out);
      }

      if (projection_was_set)
      {
        lasreader->header.set_geo_keys(number_of_keys, (LASvlr_key_entry*)geo_keys);
        if (geo_double_params)
        {
          lasreader->header.set_geo_double_params(num_geo_double_params, geo_double_params);
        }
        lasreader->header.del_geo_ascii_params();
      }

      // open laswriter

      LASwriter* laswriter = laswriteopener.open(&lasreader->header);

      if (laswriter == 0)
      {
        fprintf(stderr, "ERROR: could not open laswriter\n");
        byebye(argc==1);
      }

      // loop over points

      if (lasreadopener.has_populated_header())
      {
        while (lasreader->read_point())
        {
          laswriter->write_point(&lasreader->point);
        }
      }
      else
      {
        while (lasreader->read_point())
        {
          laswriter->write_point(&lasreader->point);
          laswriter->update_inventory(&lasreader->point);
        }
        laswriter->update_header(&lasreader->header, TRUE);
      }

      U32 total_bytes = laswriter->close();
      delete laswriter;
  
#ifdef _WIN32
      if (verbose) fprintf(stderr,"%g secs to write %u bytes for '%s' with %I64d points of type %d\n", taketime()-start_time, total_bytes, laswriteopener.get_file_name(), lasreader->p_count, lasreader->header.point_data_format);
#else
      if (verbose) fprintf(stderr,"%g secs to write %u bytes for '%s' with %lld points of type %d\n", taketime()-start_time, total_bytes, laswriteopener.get_file_name(), lasreader->p_count, lasreader->header.point_data_format);
#endif

      laswriteopener.set_file_name(0);
    }
  
    lasreader->close();
    delete lasreader;
  }

  if (projection_was_set)
  {
    free(geo_keys);
    if (geo_double_params)
    {
      free(geo_double_params);
    }
  }

  byebye(argc==1);

  return 0;
}
