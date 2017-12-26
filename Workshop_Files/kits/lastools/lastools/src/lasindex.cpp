/*
===============================================================================

  FILE:  lasindex.cpp
  
  CONTENTS:
  
    This tool creates a *.lax file for a given *.las or *.laz file that contains
    a spatial indexing. When this LAX file is present it will be used to speed up
    access to the relevant areas of the LAS/LAZ file whenever a spatial queries
    of the type
    
      -inside_tile ll_x ll_y size
      -inside_circle center_x center_y radius
      -inside_rectangle min_x min_y max_x max_y  (or simply -inside)

     appears in the command line of any LAStools invocation. This acceleration is
     also available to users of the LASlib API. The LASreader class has three new
     functions called

     BOOL inside_tile(const F32 ll_x, const F32 ll_y, const F32 size);
     BOOL inside_circle(const F64 center_x, const F64 center_y, const F64 radius);
     BOOL inside_rectangle(const F64 min_x, const F64 min_y, const F64 max_x, const F64 max_y);

     if any of these functions is called the LASreader will only return the points
     that fall inside the specified region and use - when available - the spatial
     indexing information in the LAX file created by lasindex.

  PROGRAMMERS:
  
    martin.isenburg@gmail.com
  
  COPYRIGHT:
  
    (c) 2011, Martin Isenburg, LASSO - tools to catch reality

    This is free software; you can redistribute and/or modify it under the
    terms of the GNU Lesser General Licence as published by the Free Software
    Foundation. See the COPYING file for more information.

    This software is distributed WITHOUT ANY WARRANTY and without even the
    implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  
  CHANGE HISTORY:
  
    17 May 2011 -- enabling batch processing with wildcards or multiple file names
    29 April 2011 -- created after cable outage during the royal wedding (-:
  
===============================================================================
*/

#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lasreader.hpp"
#include "lasindex.hpp"
#include "lasquadtree.hpp"

void usage(bool wait=false)
{
  fprintf(stderr,"usage:\n");
  fprintf(stderr,"lasindex lidar.las\n");
  fprintf(stderr,"lasindex *.las\n");
  fprintf(stderr,"lasindex flight1*.las flight2*.las -verbose\n");
  fprintf(stderr,"lasindex -h\n");
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
  bool verbose = false;
  U32 tile_size = 100;
  U32 threshold = 1000;
  U32 minimum_points = 100000;
  I32 maximum_intervals = -20;
  double start_time = 0;

  LASreadOpener lasreadopener;

  lasreadopener.set_merged(FALSE);
  lasreadopener.set_populate_header(FALSE);

  if (argc == 1)
  {
    fprintf(stderr,"lasindex.exe is better run in the command line\n");
    char file_name[256];
    fprintf(stderr,"enter input file: "); fgets(file_name, 256, stdin);
    file_name[strlen(file_name)-1] = '\0';
    lasreadopener.set_file_name(file_name);
  }
  else
  {
    if (!lasreadopener.parse(argc, argv)) byebye();
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
    else if (strcmp(argv[i],"-tile") == 0 || strcmp(argv[i],"-size") == 0)
    {
      i++;
      tile_size = atoi(argv[i]);
    }
    else if (strcmp(argv[i],"-maximum") == 0)
    {
      i++;
      maximum_intervals = atoi(argv[i]);
    }
    else if (strcmp(argv[i],"-minimum") == 0)
    {
      i++;
      minimum_points = atoi(argv[i]);
    }
    else if (strcmp(argv[i],"-threshold") == 0)
    {
      i++;
      threshold = atoi(argv[i]);
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

/*
  // lasquadtree test

  LASquadtree quadtree;
  quadtree.setup(0, 99, 0, 99, 10);
  quadtree.intersect_rectangle(10, 10, 20, 20);
  quadtree.get_intersected_cells();
  while (quadtree.has_intersected_cells())
  {
    F32 min[2],max[2];
    quadtree.get_cell_bounding_box(quadtree.intersected_cell, min, max);
    fprintf(stderr," checking tile %d with %g/%g %g/%g\n", quadtree.intersected_cell, min[0], min[1], max[0], max[1]);
  }
  quadtree.intersect_tile(10, 10, 10);
  quadtree.get_intersected_cells();
  while (quadtree.has_intersected_cells())
  {
    F32 min[2],max[2];
    quadtree.get_cell_bounding_box(quadtree.intersected_cell, min, max);
    fprintf(stderr," checking tile %d with %g/%g %g/%g\n", quadtree.intersected_cell, min[0], min[1], max[0], max[1]);
  }
  fprintf(stderr,"intersect circle\n");
  quadtree.intersect_circle(10, 10, 10);
  quadtree.get_intersected_cells();
  while (quadtree.has_intersected_cells())
  {
    F32 min[2],max[2];
    quadtree.get_cell_bounding_box(quadtree.intersected_cell, min, max);
    fprintf(stderr," checking tile %d with %g/%g %g/%g\n", quadtree.intersected_cell, min[0], min[1], max[0], max[1]);
  }
*/

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

    // setup the quadtree
    LASquadtree* lasquadtree = new LASquadtree;
    lasquadtree->setup(lasreader->header.min_x, lasreader->header.max_x, lasreader->header.min_y, lasreader->header.max_y, tile_size);

    // create index and add points
    LASindex lasindex;
    lasindex.prepare(lasquadtree, threshold);
    while (lasreader->read_point()) lasindex.add(&lasreader->point, (U32)(lasreader->p_count-1));
  
    // adaptive coarsening
    lasindex.complete(minimum_points, maximum_intervals);
    // write to file
    lasindex.write(lasreadopener.get_file_name());

    lasreader->close();
    delete lasreader;
  }
  
  byebye(argc==1);

  return 0;
}
