/*
===============================================================================

  FILE:  lasprecision.cpp
  
  CONTENTS:
  
    This tool computes statistics about the coordinates in a LAS/LAZ file that
    tell us whether the precision "advertised" in the header is really in the
    data. Often I find that the scaling factors in the header are miss-leading
    because they make it appear as if there was much more precision than there
    really is.

    The tool computes coordinate difference histograms that allow you to easily
    decide whether there is artificially high precision in the LAS/LAZ file. If
    you figured out the "correct" precision you can also resample the LAS/LAZ
    file to an appropriate level of precision. A big motivation to remove "fake"
    precision is that LAS files compress much better with laszip without this
    "fluff" in the low-order bits.

    For example you can find "fluff" in those examples:
     - Grass Lake Small.las
     - MARS_Sample_Filtered_LiDAR.las
     - Mount St Helens Oct 4 2004.las
     - IowaDNR-CloudPeakSoft-1.0-UTM15N.las
     - LAS12_Sample_withRGB_QT_Modeler.las
     - Lincoln.las
     - Palm Beach Pre Hurricane.las

  PROGRAMMERS:
  
    martin.isenburg@gmail.com
  
  COPYRIGHT:
  
    (c) 2010-11, Martin Isenburg, LASSO - tools to catch reality

    This is free software; you can redistribute and/or modify it under the
    terms of the GNU Lesser General Licence as published by the Free Software
    Foundation. See the COPYING file for more information.

    This software is distributed WITHOUT ANY WARRANTY and without even the
    implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  
  CHANGE HISTORY:
  
    30 November 2010 -- created spotting few paper cups at Starbuck's Offenbach
  
===============================================================================
*/

#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lasreader.hpp"
#include "lasfilter.hpp"
#include "laswriter.hpp"

static void quicksort_for_shorts(short* a, int i, int j)
{
  int in_i = i;
  int in_j = j;
  short key = a[(i+j)/2];
  short w;
  do
  {
    while ( a[i] < key ) i++;
    while ( a[j] > key ) j--;
    if (i<j)
    {
      w = a[i];
      a[i] = a[j];
      a[j] = w;
    }
  } while (++i<=--j);
  if (i == j+3)
  {
    i--;
    j++;
  }
  if (j>in_i) quicksort_for_shorts(a, in_i, j);
  if (i<in_j) quicksort_for_shorts(a, i, in_j);
}

static void quicksort_for_ints(int* a, int i, int j)
{
  int in_i = i;
  int in_j = j;
  int key = a[(i+j)/2];
  int w;
  do
  {
    while ( a[i] < key ) i++;
    while ( a[j] > key ) j--;
    if (i<j)
    {
      w = a[i];
      a[i] = a[j];
      a[j] = w;
    }
  } while (++i<=--j);
  if (i == j+3)
  {
    i--;
    j++;
  }
  if (j>in_i) quicksort_for_ints(a, in_i, j);
  if (i<in_j) quicksort_for_ints(a, i, in_j);
}

static void quicksort_for_doubles(double* a, int i, int j)
{
  int in_i = i;
  int in_j = j;
  double key = a[(i+j)/2];
  double w;
  do
  {
    while ( a[i] < key ) i++;
    while ( a[j] > key ) j--;
    if (i<j)
    {
      w = a[i];
      a[i] = a[j];
      a[j] = w;
    }
  } while (++i<=--j);
  if (i == j+3)
  {
    i--;
    j++;
  }
  if (j>in_i) quicksort_for_doubles(a, in_i, j);
  if (i<in_j) quicksort_for_doubles(a, i, in_j);
}

void usage(bool wait=false)
{
  fprintf(stderr,"usage:\n");
  fprintf(stderr,"lasprecision -i in.las\n");
  fprintf(stderr,"lasprecision -i in.las -number 1000000\n");
  fprintf(stderr,"lasprecision -i in.las -all -lines 50\n");
  fprintf(stderr,"lasprecision -i in.las -no_z\n");
  fprintf(stderr,"lasprecision -i in.las -diff_diff\n");
  fprintf(stderr,"lasprecision -i in.las -o out.las -rescale 0.01 0.01 0.001 -reoffset 300000 2000000 0\n");
  fprintf(stderr,"lasprecision -i in.las -o out.las -rescale 0.333333333 0.333333333 0.01\n");
  fprintf(stderr,"lasprecision -h\n");
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

int main(int argc, char *argv[])
{
  int i;
  bool verbose = false;
  bool report_diff = true;
  bool report_diff_diff = false;
  bool report_z = true;
  bool report_rgb = false;
  U32 report_lines = 20;
  U32 array_max = 5000000;

  LASreadOpener lasreadopener;
  LASwriteOpener laswriteopener;

  lasreadopener.set_merged(FALSE);
  lasreadopener.set_populate_header(FALSE);

  if (argc == 1)
  {
    fprintf(stderr,"lasprecision.exe is better run in the command line\n");
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
    else if ((strcmp(argv[i],"-diff_diff") == 0) || (strcmp(argv[i],"-diff_diff_only") == 0))
    {
      report_diff_diff = true;
      report_diff = false;
    }
    else if ((strcmp(argv[i],"-noz") == 0) || (strcmp(argv[i],"-no_z") == 0) || (strcmp(argv[i],"-xy_only") == 0))
    {
      report_z = false;
    }
    else if (strcmp(argv[i],"-number") == 0)
    {
      i++;
      array_max = atoi(argv[i]);
    }
    else if (strcmp(argv[i],"-lines") == 0)
    {
      i++;
      report_lines = atoi(argv[i]);
    }
    else if (strcmp(argv[i],"-all") == 0)
    {
      array_max = U32_MAX;
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
    fprintf(stderr, "ERROR: no input specified\n");
    byebye(argc==1);
  }

  LASreader* lasreader = lasreadopener.open();

  if (lasreader == 0)
  {
    fprintf(stderr, "ERROR: could not open lasreader\n");
    byebye(argc==1);
  }

  if (!laswriteopener.active())
  {
    // run presicion statistics across the first array_max points

    fprintf(stdout, "original scale factors: %g %g %g\n", lasreader->header.x_scale_factor,  lasreader->header.y_scale_factor,  lasreader->header.z_scale_factor);

    // create the arrays
    int* array_x = new int[array_max];
    int* array_y = new int[array_max];
    int* array_z = new int[array_max];

    short* array_r = 0;
    short* array_g = 0;
    short* array_b = 0;
    if (lasreader->point.have_rgb && report_rgb)
    {
      array_r = new short[array_max];
      array_g = new short[array_max];
      array_b = new short[array_max];
    }

    // do the first pass

    fprintf(stderr, "loading first %u of %u points\n", array_max, (U32)lasreader->npoints);

    // loop over points

    unsigned int array_count = 0;

    while ((lasreader->read_point()) && (array_count < array_max))
    {
      array_x[array_count] = lasreader->point.x;
      array_y[array_count] = lasreader->point.y;
      array_z[array_count] = lasreader->point.z;

      if (lasreader->point.have_rgb && report_rgb)
      {
        array_r[array_count] = lasreader->point.rgb[0];
        array_g[array_count] = lasreader->point.rgb[1];
        array_b[array_count] = lasreader->point.rgb[2];
      }

      array_count++;
    }

    array_max = array_count;

    // sort values
  
    quicksort_for_ints(array_x, 0, array_max-1);
    quicksort_for_ints(array_y, 0, array_max-1);
    quicksort_for_ints(array_z, 0, array_max-1);
  
    if (lasreader->point.have_rgb && report_rgb)
    {
      quicksort_for_shorts(array_r, 0, array_max-1);
      quicksort_for_shorts(array_g, 0, array_max-1);
      quicksort_for_shorts(array_b, 0, array_max-1);
    }

    // create differences

    for (array_count = 1; array_count < array_max; array_count++)
    {
      array_x[array_count-1] = array_x[array_count] - array_x[array_count-1];
      array_y[array_count-1] = array_y[array_count] - array_y[array_count-1];
      array_z[array_count-1] = array_z[array_count] - array_z[array_count-1];
    }

    if (lasreader->point.have_rgb && report_rgb)
    {
      for (array_count = 1; array_count < array_max; array_count++)
      {
        array_r[array_count-1] = array_r[array_count] - array_r[array_count-1];
        array_g[array_count-1] = array_g[array_count] - array_g[array_count-1];
        array_b[array_count-1] = array_b[array_count] - array_b[array_count-1];
      }
    }

    // sort differences

    quicksort_for_ints(array_x, 0, array_max-2);
    quicksort_for_ints(array_y, 0, array_max-2);
    quicksort_for_ints(array_z, 0, array_max-2);
  
    if (lasreader->point.have_rgb && report_rgb)
    {
      quicksort_for_shorts(array_r, 0, array_max-2);
      quicksort_for_shorts(array_g, 0, array_max-2);
      quicksort_for_shorts(array_b, 0, array_max-2);
    }

    // compute difference of differences, sort them, output histogram

    // first for X & Y & Z

    unsigned int count_lines, array_last, array_first;
  
    if (verbose || report_diff) fprintf(stdout, "X differences \n");
    for (count_lines = 0, array_first = 0, array_last = 0, array_count = 1; array_count < array_max; array_count++)
    {
      if (array_x[array_last] != array_x[array_count])
      {
        if ((verbose || report_diff) && (count_lines < report_lines)) {  count_lines++; fprintf(stdout, " %10d : %10d   %g\n", array_x[array_last], array_count - array_last, lasreader->header.x_scale_factor*array_x[array_last]); }
        array_x[array_first] = array_x[array_count] - array_x[array_last];
        array_last = array_count;
        array_first++;
      }
    }
    if (report_diff_diff)
    {
      fprintf(stdout, "X differences of differences\n");
      quicksort_for_ints(array_x, 0, array_first-1);
      for (array_last = 0, array_count = 1; array_count < array_first; array_count++)
      {
        if (array_x[array_last] != array_x[array_count])
        {
          if (verbose || report_diff_diff) fprintf(stdout, "  %10d : %10d\n", array_x[array_last], array_count - array_last);
          array_last = array_count;
        }
      }
    }

    if (verbose || report_diff) fprintf(stdout, "Y differences \n");
    for (count_lines = 0, array_first = 0, array_last = 0, array_count = 1; array_count < array_max; array_count++)
    {
      if (array_y[array_last] != array_y[array_count])
      {
        if ((verbose || report_diff) && (count_lines < report_lines)) { count_lines++; fprintf(stdout, " %10d : %10d   %g\n", array_y[array_last], array_count - array_last, lasreader->header.y_scale_factor*array_y[array_last]); }
        array_y[array_first] = array_y[array_count] - array_y[array_last]; 
        array_last = array_count;
        array_first++;
      }
    }
    if (report_diff_diff)
    {
      fprintf(stdout, "Y differences of differences\n");
      quicksort_for_ints(array_y, 0, array_first-1);
      for (array_last = 0, array_count = 1; array_count < array_first; array_count++)
      {
        if (array_y[array_last] != array_y[array_count])
        {
          if (verbose || report_diff_diff) fprintf(stdout, "  %10d : %10d\n", array_y[array_last], array_count - array_last);
          array_last = array_count;
        }
      }
    }

    if (report_z)
    {
      if (verbose || report_diff) fprintf(stdout, "Z differences \n");
      for (count_lines = 0, array_first = 0, array_last = 0, array_count = 1; array_count < array_max; array_count++)
      {
        if (array_z[array_last] != array_z[array_count])
        {
          if ((verbose || report_diff) && (count_lines < report_lines)) { count_lines++; fprintf(stdout, " %10d : %10d   %g\n", array_z[array_last], array_count - array_last, lasreader->header.z_scale_factor*array_z[array_last]); }
          array_z[array_first] = array_z[array_count] - array_z[array_last]; 
          array_last = array_count;
          array_first++;
        }
      }
      if (report_diff_diff)
      {
        fprintf(stdout, "Z differences of differences\n");
        quicksort_for_ints(array_z, 0, array_first-1);
        for (array_last = 0, array_count = 1; array_count < array_first; array_count++)
        {
          if (array_z[array_last] != array_z[array_count])
          {
            if (verbose || report_diff_diff) fprintf(stdout, "  %10d : %10d\n", array_z[array_last], array_count - array_last);
            array_last = array_count;
          }
        }
      }
    }

    // then for R & G & B

    if (lasreader->point.have_rgb && report_rgb)
    {
      if (verbose) fprintf(stdout, "R differences \n");
      for (array_first = 0, array_last = 0, array_count = 1; array_count < array_max; array_count++)
      {
        if (array_r[array_last] != array_r[array_count])
        {
          if (verbose) fprintf(stdout, "  %10d : %10d\n", array_r[array_last], array_count - array_last);
          array_r[array_first] = array_r[array_count] - array_r[array_last]; 
          array_last = array_count;
          array_first++;
        }
      }
      if (report_diff_diff)
      {
        fprintf(stdout, "R differences of differences\n");
        quicksort_for_shorts(array_r, 0, array_first-1);
        for (array_last = 0, array_count = 1; array_count < array_first; array_count++)
        {
          if (array_r[array_last] != array_r[array_count])
          {
            fprintf(stdout, "  %10d : %10d\n", array_r[array_last], array_count - array_last);
            array_last = array_count;
          }
        }
      }

      if (verbose) fprintf(stdout, "G differences \n");
      for (array_first = 0, array_last = 0, array_count = 1; array_count < array_max; array_count++)
      {
        if (array_g[array_last] != array_g[array_count])
        {
          if (verbose) fprintf(stdout, "  %10d : %10d\n", array_g[array_last], array_count - array_last);
          array_g[array_first] = array_g[array_count] - array_g[array_last]; 
          array_last = array_count;
          array_first++;
        }
      }
      if (report_diff_diff)
      {
        fprintf(stdout, "G differences of differences\n");
        quicksort_for_shorts(array_g, 0, array_first-1);
        for (array_last = 0, array_count = 1; array_count < array_first; array_count++)
        {
          if (array_g[array_last] != array_g[array_count])
          {
            fprintf(stdout, "  %10d : %10d\n", array_g[array_last], array_count - array_last);
            array_last = array_count;
          }
        }
      }

      if (verbose) fprintf(stdout, "B differences \n");
      for (array_first = 0, array_last = 0, array_count = 1; array_count < array_max; array_count++)
      {
        if (array_b[array_last] != array_b[array_count])
        {
          if (verbose) fprintf(stdout, "  %10d : %10d\n", array_b[array_last], array_count - array_last);
          array_b[array_first] = array_b[array_count] - array_b[array_last]; 
          array_last = array_count;
          array_first++;
        }
      }
      if (report_diff_diff)
      {
        fprintf(stdout, "B differences of differences\n");
        quicksort_for_shorts(array_b, 0, array_first-1);
        for (array_last = 0, array_count = 1; array_count < array_first; array_count++)
        {
          if (array_b[array_last] != array_b[array_count])
          {
            fprintf(stdout, "  %10d : %10d\n", array_b[array_last], array_count - array_last);
            array_last = array_count;
          }
        }
      }
    }
  }
  else
  {
    // check output

    fprintf(stdout, "new scale factors: %g %g %g\n", lasreader->header.x_scale_factor,  lasreader->header.y_scale_factor,  lasreader->header.z_scale_factor);

    if (!laswriteopener.active())
    {
      fprintf(stderr, "ERROR: no output specified\n");
      byebye(argc==1);
    }

    // open laswriter

    LASwriter* laswriter = laswriteopener.open(&lasreader->header);

    if (laswriter == 0)
    {
      fprintf(stderr, "ERROR: could not open laswriter\n");
      byebye(argc==1);
    }

    // loop over points
    while (lasreader->read_point())
    {
      laswriter->write_point(&lasreader->point);
      laswriter->update_inventory(&lasreader->point);
    }

    laswriter->update_header(&lasreader->header, TRUE);
    laswriter->close();
    delete laswriter;
  }

  lasreader->close();
  delete lasreader;

  byebye(argc==1);

  return 0;
}
