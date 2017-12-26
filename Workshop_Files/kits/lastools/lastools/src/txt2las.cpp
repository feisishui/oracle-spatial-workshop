/*
===============================================================================

  FILE:  txt2las.cpp
  
  CONTENTS:
  
    This tool parses LIDAR data as it is typically stored in standard ASCII
    formats and converts it into the more efficient binary LAS format. If 
    the LAS/LAZ output goes into a file the tool operates in one pass and
    updtes the header in the end. If the LAS/LAZ output is piped the tool
    operates in two passes because it has to precompute the information that
    is stored in the LAS header. The first pass counts the points, measures
    their bounding box, and - if applicable - creates the histogram for the
    number of returns. The second pass writes the points.

  PROGRAMMERS:
  
    martin.isenburg@gmail.com
  
  COPYRIGHT:
  
    (c) 2007-11, Martin Isenburg, LASSO - tools to catch reality

    This is free software; you can redistribute and/or modify it under the
    terms of the GNU Lesser General Licence as published by the Free Software
    Foundation. See the COPYING file for more information.

    This software is distributed WITHOUT ANY WARRANTY and without even the
    implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  
  CHANGE HISTORY:
  
    22 April 2011 -- added command-line flags to specify the projection VLRs
    20 March 2011 -- added capability to read *.zip, *.rar, and *.7z directly
    22 February 2011 -- added option to scale the intensity and scan_angle
    19 Juni 2009 -- added option to skip a number of lines in the text file
    12 March 2009 -- updated to ask for input if started without arguments 
    17 September 2008 -- updated to deal with LAS format version 1.2
    13 July 2007 -- single pass if output is to file by using fopen("rb+" ...) 
    25 June 2007 -- added warning in case that quantization causes a sign flip
    13 June 2007 -- added 'e' and 'd' for the parse string
    26 February 2007 -- created sitting in the SFO lounge waiting for LH 455
  
===============================================================================
*/

#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
#include <windows.h>
#endif

#include "laswriter.hpp"
#include "geoprojectionconverter.hpp"

void usage(bool wait=false)
{
  fprintf(stderr,"Supported ASCII Inputs:\n");
  fprintf(stderr,"  -i lidar.txt\n");
  fprintf(stderr,"  -i lidar.txt.gz\n");
  fprintf(stderr,"  -i lidar.zip\n");
  fprintf(stderr,"  -i lidar.rar\n");
  fprintf(stderr,"  -i lidar.7z\n");
  fprintf(stderr,"  -stdin (pipe from stdin)\n");
  fprintf(stderr,"usage:\n");
  fprintf(stderr,"txt2las -parse tsxyz -i lidar.txt.gz\n");
  fprintf(stderr,"txt2las -parse xyzairn -i lidar.zip -utm 17T -olaz -quiet\n");
  fprintf(stderr,"unzip -p lidar.zip | txt2las -parse xyz -stdin -o lidar.las -longlat -elevation_survey_feet\n");
  fprintf(stderr,"txt2las -i lidar.zip -parse txyzar -scale_scan_angle 57.3 -o lidar.laz\n");
  fprintf(stderr,"txt2las -skip 5 -parse xyz -i lidar.rar -set_file_creation 28 2011 -o lidar.las\n");
  fprintf(stderr,"txt2las -parse xyzsst -verbose -set_scale 0.001 0.001 0.001 -i lidar.txt\n");
  fprintf(stderr,"txt2las -parse xsysz -set_scale 0.1 0.1 0.01 -i lidar.txt.gz -sp83 OH_N -feet\n");
  fprintf(stderr,"las2las -parse tsxyzRGB -i lidar.txt -set_version 1.2 -scale_intensity 65535 -o lidar.las\n");
  fprintf(stderr,"txt2las -h\n");
  fprintf(stderr,"---------------------------------------------\n");
  fprintf(stderr,"The '-parse tsxyz' flag specifies how to interpret\n");
  fprintf(stderr,"each line of the ASCII file. For example, 'tsxyzssa'\n");
  fprintf(stderr,"means that the first number is the gpstime, the next\n");
  fprintf(stderr,"number should be skipped, the next three numbers are\n");
  fprintf(stderr,"the x, y, and z coordinate, the next two should be\n");
  fprintf(stderr,"skipped, and the next number is the scan angle.\n");
  fprintf(stderr,"The other supported entries are i - intensity,\n");
  fprintf(stderr,"n - number of returns of given pulse, r - number\n");
  fprintf(stderr,"of return, c - classification, u - user data, and\n");
  fprintf(stderr,"p - point source ID, e - edge of flight line flag, and\n");
  fprintf(stderr,"d - direction of scan flag, R - red channel of RGB\n");
  fprintf(stderr,"color, G - green channel, B - blue channel\n");
  fprintf(stderr,"---------------------------------------------\n");
  fprintf(stderr,"Other parameters are\n");
  fprintf(stderr,"'-set_scale 0.05 0.05 0.001'\n");
  fprintf(stderr,"'-set_offset 500000 2000000 0'\n");
  fprintf(stderr,"'-set_file_creation 67 2011'\n");
  fprintf(stderr,"'-set_system_identifier \"Riegl 500,000 Hz\"'\n");
  fprintf(stderr,"'-set_generating_software \"LAStools\"'\n");
  fprintf(stderr,"'-utm 14T'\n");
  fprintf(stderr,"'-sp83 CA_I -feet -elevation_survey_feet'\n");
  fprintf(stderr,"'-longlat -elevation_feet'\n");
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

static inline void VecUpdateMinMax3dv(double min[3], double max[3], const double v[3])
{
  if (v[0]<min[0]) min[0]=v[0]; else if (v[0]>max[0]) max[0]=v[0];
  if (v[1]<min[1]) min[1]=v[1]; else if (v[1]>max[1]) max[1]=v[1];
  if (v[2]<min[2]) min[2]=v[2]; else if (v[2]>max[2]) max[2]=v[2];
}

static inline void VecCopy3dv(double v[3], const double a[3])
{
  v[0] = a[0];
  v[1] = a[1];
  v[2] = a[2];
}

static float translate_intensity = 0;
static float scale_intensity = 0;
static float scale_scan_angle = 0;

static bool parse(const char* parse_string, const char* line, double* xyz, LASpoint* point)
{
  int temp_i;
  float temp_f;
  const char* p = parse_string;
  const char* l = line;

  while (p[0])
  {
    if (p[0] == 'x') // we expect the x coordinate
    {
      while (l[0] && (l[0] == ' ' || l[0] == ',' || l[0] == '\t')) l++; // first skip white spaces
      if (l[0] == 0) return false;
      if (sscanf(l, "%lf", &(xyz[0])) != 1) return false;
      while (l[0] && l[0] != ' ' && l[0] != ',' && l[0] != '\t') l++; // then advance to next white space
    }
    else if (p[0] == 'y') // we expect the y coordinate
    {
      while (l[0] && (l[0] == ' ' || l[0] == ',' || l[0] == '\t')) l++; // first skip white spaces
      if (l[0] == 0) return false;
      if (sscanf(l, "%lf", &(xyz[1])) != 1) return false;
      while (l[0] && l[0] != ' ' && l[0] != ',' && l[0] != '\t') l++; // then advance to next white space
    }
    else if (p[0] == 'z') // we expect the x coordinate
    {
      while (l[0] && (l[0] == ' ' || l[0] == ',' || l[0] == '\t')) l++; // first skip white spaces
      if (l[0] == 0) return false;
      if (sscanf(l, "%lf", &(xyz[2])) != 1) return false;
      while (l[0] && l[0] != ' ' && l[0] != ',' && l[0] != '\t') l++; // then advance to next white space
    }
    else if (p[0] == 't') // we expect the gps time
    {
      while (l[0] && (l[0] == ' ' || l[0] == ',' || l[0] == '\t')) l++; // first skip white spaces
      if (l[0] == 0) return false;
      if (sscanf(l, "%lf", &(point->gps_time)) != 1) return false;
      while (l[0] && l[0] != ' ' && l[0] != ',' && l[0] != '\t') l++; // then advance to next white space
    }
    else if (p[0] == 'R') // we expect the red channel of the RGB field
    {
      while (l[0] && (l[0] == ' ' || l[0] == ',' || l[0] == '\t')) l++; // first skip white spaces
      if (l[0] == 0) return false;
      if (sscanf(l, "%d", &temp_i) != 1) return false;
      point->rgb[0] = (short)temp_i;
      while (l[0] && l[0] != ' ' && l[0] != ',' && l[0] != '\t') l++; // then advance to next white space
    }
    else if (p[0] == 'G') // we expect the green channel of the RGB field
    {
      while (l[0] && (l[0] == ' ' || l[0] == ',' || l[0] == '\t')) l++; // first skip white spaces
      if (l[0] == 0) return false;
      if (sscanf(l, "%d", &temp_i) != 1) return false;
      point->rgb[1] = (short)temp_i;
      while (l[0] && l[0] != ' ' && l[0] != ',' && l[0] != '\t') l++; // then advance to next white space
    }
    else if (p[0] == 'B') // we expect the blue channel of the RGB field
    {
      while (l[0] && (l[0] == ' ' || l[0] == ',' || l[0] == '\t')) l++; // first skip white spaces
      if (l[0] == 0) return false;
      if (sscanf(l, "%d", &temp_i) != 1) return false;
      point->rgb[2] = (short)temp_i;
      while (l[0] && l[0] != ' ' && l[0] != ',' && l[0] != '\t') l++; // then advance to next white space
    }
    else if (p[0] == 's') // we expect a string or a number that we don't care about
    {
      while (l[0] && (l[0] == ' ' || l[0] == ',' || l[0] == '\t')) l++; // first skip white spaces
      if (l[0] == 0) return false;
      while (l[0] && l[0] != ' ' && l[0] != ',' && l[0] != '\t') l++; // then advance to next white space
    }
    else if (p[0] == 'i') // we expect the intensity
    {
      while (l[0] && (l[0] == ' ' || l[0] == ',' || l[0] == '\t')) l++; // first skip white spaces
      if (l[0] == 0) return false;
      if (sscanf(l, "%f", &temp_f) != 1) return false;
      if (translate_intensity) temp_f = temp_f+translate_intensity;
      if (scale_intensity) temp_f = temp_f*scale_intensity;
      if (temp_f < 0.0f || temp_f >= 65535.5f) fprintf(stderr, "WARNING: intensity %g is out of range of unsigned short\n", temp_f);
      point->intensity = (unsigned short)(temp_f+0.5f);
      while (l[0] && l[0] != ' ' && l[0] != ',' && l[0] != '\t') l++; // then advance to next white space
    }
    else if (p[0] == 'a') // we expect the scan angle
    {
      while (l[0] && (l[0] == ' ' || l[0] == ',' || l[0] == '\t')) l++; // first skip white spaces
      if (l[0] == 0) return false;
      if (sscanf(l, "%f", &temp_f) != 1) return false;
      if (scale_scan_angle) temp_f = temp_f*scale_scan_angle;
      if (temp_f < -128.0f || temp_f > 127.0f) fprintf(stderr, "WARNING: scan angle %g is out of range of char\n", temp_f);
      point->scan_angle_rank = (char)temp_f;
      while (l[0] && l[0] != ' ' && l[0] != ',' && l[0] != '\t') l++; // then advance to next white space
    }
    else if (p[0] == 'n') // we expect the number of returns of given pulse
    {
      while (l[0] && (l[0] == ' ' || l[0] == ',' || l[0] == '\t')) l++; // first skip white spaces
      if (l[0] == 0) return false;
      if (sscanf(l, "%d", &temp_i) != 1) return false;
      if (temp_i < 0 || temp_i > 7) fprintf(stderr, "WARNING: return number %d is out of range of three bits\n", temp_i);
      point->number_of_returns_of_given_pulse = temp_i & 7;
      while (l[0] && l[0] != ' ' && l[0] != ',' && l[0] != '\t') l++; // then advance to next white space
    }
    else if (p[0] == 'r') // we expect the number of the return
    {
      while (l[0] && (l[0] == ' ' || l[0] == ',' || l[0] == '\t')) l++; // first skip white spaces
      if (l[0] == 0) return false;
      if (sscanf(l, "%d", &temp_i) != 1) return false;
      if (temp_i < 0 || temp_i > 7) fprintf(stderr, "WARNING: return number %d is out of range of three bits\n", temp_i);
      point->return_number = temp_i & 7;
      while (l[0] && l[0] != ' ' && l[0] != ',' && l[0] != '\t') l++; // then advance to next white space
    }
    else if (p[0] == 'c') // we expect the classification
    {
      while (l[0] && (l[0] == ' ' || l[0] == ',' || l[0] == '\t')) l++; // first skip white spaces
      if (l[0] == 0) return false;
      if (sscanf(l, "%d", &temp_i) != 1) return false;
      if (temp_i < 0 || temp_i > 255) fprintf(stderr, "WARNING: classification %d is out of range of unsigned char\n", temp_i);
      point->classification = (unsigned char)temp_i;
      while (l[0] && l[0] != ' ' && l[0] != ',' && l[0] != '\t') l++; // then advance to next white space
    }
    else if (p[0] == 'u') // we expect the user data
    {
      while (l[0] && (l[0] == ' ' || l[0] == ',' || l[0] == '\t')) l++; // first skip white spaces
      if (l[0] == 0) return false;
      if (sscanf(l, "%d", &temp_i) != 1) return false;
      if (temp_i < 0 || temp_i > 255) fprintf(stderr, "WARNING: user data %d is out of range of unsigned char\n", temp_i);
      point->user_data = temp_i & 255;
      while (l[0] && l[0] != ' ' && l[0] != ',' && l[0] != '\t') l++; // then advance to next white space
    }
    else if (p[0] == 'p') // we expect the point source ID
    {
      while (l[0] && (l[0] == ' ' || l[0] == ',' || l[0] == '\t')) l++; // first skip white spaces
      if (l[0] == 0) return false;
      if (sscanf(l, "%d", &temp_i) != 1) return false;
      if (temp_i < 0 || temp_i > 65535) fprintf(stderr, "WARNING: point source ID %d is out of range of unsigned short\n", temp_i);
      point->point_source_ID = temp_i & 65535;
      while (l[0] && l[0] != ' ' && l[0] != ',' && l[0] != '\t') l++; // then advance to next white space
    }
    else if (p[0] == 'e') // we expect the edge of flight line flag
    {
      while (l[0] && (l[0] == ' ' || l[0] == ',' || l[0] == '\t')) l++; // first skip white spaces
      if (l[0] == 0) return false;
      if (sscanf(l, "%d", &temp_i) != 1) return false;
      if (temp_i < 0 || temp_i > 1) fprintf(stderr, "WARNING: edge of flight line flag %d is out of range of boolean flag\n", temp_i);
      point->edge_of_flight_line = (temp_i ? 1 : 0);
      while (l[0] && l[0] != ' ' && l[0] != ',' && l[0] != '\t') l++; // then advance to next white space
    }
    else if (p[0] == 'd') // we expect the direction of scan flag
    {
      while (l[0] && (l[0] == ' ' || l[0] == ',' || l[0] == '\t')) l++; // first skip white spaces
      if (l[0] == 0) return false;
      if (sscanf(l, "%d", &temp_i) != 1) return false;
      if (temp_i < 0 || temp_i > 1) fprintf(stderr, "WARNING: direction of scan flag %d is out of range of boolean flag\n", temp_i);
      point->scan_direction_flag = (temp_i ? 1 : 0);
      while (l[0] && l[0] != ' ' && l[0] != ',' && l[0] != '\t') l++; // then advance to next white space
    }
    else
    {
      fprintf(stderr, "ERROR: next symbol '%s' unknown in parse control string\n", p);
    }
    p++;
  }
  return true;
}

static double taketime()
{
  return (double)(clock())/CLOCKS_PER_SEC;
}

extern "C" FILE* fopen_compressed(const char* filename, const char* mode, bool* piped=0);

int main(int argc, char *argv[])
{
  int i;
  bool verbose = false;
  bool quiet = false;
  int skip_first_lines = 0;
  char* parse_string = strdup("xyz");
  int file_creation_day = -1;
  int file_creation_year = -1;
  F64* set_scale_factor = 0;
  F64* set_offset = 0;
  int set_version_major = -1;
  int set_version_minor = -1;
  char* set_system_identifier = 0;
  char* set_generating_software = 0;
  char* file_name_in = 0;
  bool use_stdin = false;
#define MAX_CHARACTERS_PER_LINE 512
  char line[MAX_CHARACTERS_PER_LINE];
  LASpoint point;
  F64 xyz[3];
  F64 xyz_min[3];
  F64 xyz_max[3];
  I64 npoints = 0;
  U32 number_of_points_by_return[8] = {0,0,0,0,0,0,0,0};
  double start_time = 0.0;

  GeoProjectionConverter geoprojectionconverter;
  LASwriteOpener laswriteopener;

  if (argc == 1)
  {
    fprintf(stderr,"txt2las.exe is better run in the command line\n");
    file_name_in = new char[256];
    fprintf(stderr,"enter input file: "); fgets(file_name_in, 256, stdin);
    file_name_in[strlen(file_name_in)-1] = '\0';
    char file_name_out[256];
    fprintf(stderr,"enter output file: "); fgets(file_name_out, 256, stdin);
    file_name_out[strlen(file_name_out)-1] = '\0';
    laswriteopener.set_file_name(file_name_out);
  }
  else
  {
    if (!geoprojectionconverter.parse(argc, argv)) byebye();
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
    else if (strcmp(argv[i],"-quiet") == 0)
    {
      quiet = true;
    }
    else if (strcmp(argv[i],"-i") == 0)
    {
      i++;
      file_name_in = argv[i];
    }
    else if (strcmp(argv[i],"-stdin") == 0)
    {
      use_stdin = true;
    }
    else if (strcmp(argv[i],"-parse") == 0)
    {
      i++;
      parse_string = argv[i];
    }
    else if (strcmp(argv[i],"-skip") == 0)
    {
      i++;
      skip_first_lines = atoi(argv[i]);
    }
    else if (strcmp(argv[i],"-scale_intensity") == 0)
    {
      i++;
      scale_intensity = atof(argv[i]);
    }
    else if (strcmp(argv[i],"-translate_intensity") == 0)
    {
      i++;
      translate_intensity = atof(argv[i]);
    }
    else if (strcmp(argv[i],"-translate_then_scale_intensity") == 0)
    {
      i++;
      translate_intensity = atof(argv[i]);
      i++;
      scale_intensity = atof(argv[i]);
    }
    else if (strcmp(argv[i],"-scale_scan_angle") == 0)
    {
      i++;
      scale_scan_angle = atof(argv[i]);
    }
    else if (strcmp(argv[i],"-set_scale") == 0)
    {
      set_scale_factor = new F64[3];
      i++;
      sscanf(argv[i], "%lf", &(set_scale_factor[0]));
      i++;
      sscanf(argv[i], "%lf", &(set_scale_factor[1]));
      i++;
      sscanf(argv[i], "%lf", &(set_scale_factor[2]));
    }
    else if (strcmp(argv[i],"-set_offset") == 0)
    {
      set_offset = new F64[3];
      i++;
      sscanf(argv[i], "%lf", &(set_offset[0]));
      i++;
      sscanf(argv[i], "%lf", &(set_offset[1]));
      i++;
      sscanf(argv[i], "%lf", &(set_offset[2]));
    }
    else if (strcmp(argv[i],"-set_file_creation") == 0 || strcmp(argv[i],"-file_creation") == 0)
    {
      i++;
      sscanf(argv[i], "%d", &file_creation_day);
      i++;
      sscanf(argv[i], "%d", &file_creation_year);
    }
    else if (strcmp(argv[i],"-set_system_identifier") == 0 || strcmp(argv[i],"-system_identifier") == 0 || strcmp(argv[i],"-sys_id") == 0)
    {
      i++;
      set_system_identifier = argv[i];
    }
    else if (strcmp(argv[i],"-set_generating_software") == 0 || strcmp(argv[i],"-generating_software") == 0 || strcmp(argv[i],"-gen_soft") == 0)
    {
      i++;
      set_generating_software = argv[i];
    }
    else if (strcmp(argv[i],"-set_version") == 0 || strcmp(argv[i],"-version") == 0)
    {
      i++;
      if (sscanf(argv[i],"%d.%d",&set_version_major,&set_version_minor) != 2)
      {
        fprintf(stderr, "ERROR: cannot understand argument '%s' of '%s'\n", argv[i], argv[i-1]);
        usage();
      }
    }
    else if (argv[i][0] != '-')
    {
      file_name_in = argv[i];
    }
    else
    {
      fprintf(stderr, "ERROR: cannot understand argument '%s'\n", argv[i]);
      usage();
    }
  }

  // make sure we have input

  if (file_name_in == 0 && use_stdin == false)
  {
    fprintf(stderr, "ERROR: no input specified\n");
    usage(argc==1);
  }

  // make sure that input and output are not *both* piped

  if (file_name_in == 0 && laswriteopener.piped())
  {
    fprintf(stderr, "ERROR: input and output cannot both be pipes\n");
    usage(argc==1);
  }

  // create output file name if none specified and no piped output

  if (!laswriteopener.active())
  {
    laswriteopener.make_file_name(file_name_in);
  }

  if (verbose) start_time = taketime();

  // populate header as much as possible (missing: bounding box, number of points, number of returns)

  LASheader lasheader;

  if (set_system_identifier) {
    strncpy(lasheader.system_identifier, set_system_identifier, 32);
    lasheader.system_identifier[31] = '\0';
  }
  else {
    strncpy(lasheader.system_identifier, "LAStools (c) by Martin Isenburg", 32);
    lasheader.system_identifier[31] = '\0';
  }
  if (set_generating_software) {
    strncpy(lasheader.generating_software, set_generating_software, 32);
    lasheader.generating_software[31] = '\0';
  }
  else {
    char temp[64];
    sprintf(temp, "txt2las (version %d)", LAS_TOOLS_VERSION);
    strncpy(lasheader.generating_software, temp, 32);
    lasheader.generating_software[31] = '\0';
  }
#ifdef _WIN32
  if (file_name_in && file_creation_day == -1 && file_creation_year == -1)
  {
    WIN32_FILE_ATTRIBUTE_DATA attr;
	  SYSTEMTIME creation;
    GetFileAttributesEx(file_name_in, GetFileExInfoStandard, &attr);
	  FileTimeToSystemTime(&attr.ftCreationTime, &creation);
    int startday[13] = {-1, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334};
    file_creation_day = startday[creation.wMonth] + creation.wDay;
    file_creation_year = creation.wYear;
    // leap year handling
    if ((((creation.wYear)%4) == 0) && (creation.wMonth > 2)) file_creation_day++;
  }
#endif
  if (file_creation_day == -1 && file_creation_year == -1)
  {
    lasheader.file_creation_day = (U16)111;
    lasheader.file_creation_year = (U16)2011;
  }
  else
  {
    lasheader.file_creation_day = (U16)file_creation_day;
    lasheader.file_creation_year = (U16)file_creation_year;
  }
  if (strstr(parse_string,"t"))
  {
    if (strstr(parse_string,"R") || strstr(parse_string,"G") || strstr(parse_string,"B"))
    {
      lasheader.point_data_format = 3;
      lasheader.point_data_record_length = 34;
    }
    else
    {
      lasheader.point_data_format = 1;
      lasheader.point_data_record_length = 28;
    }
  }
  else
  {
    if (strstr(parse_string,"R") || strstr(parse_string,"G") || strstr(parse_string,"B"))
    {
      lasheader.point_data_format = 2;
      lasheader.point_data_record_length = 26;
    }
    else
    {
      lasheader.point_data_format = 0;
      lasheader.point_data_record_length = 20;
    }
  }
  if (set_version_major != -1) lasheader.version_major = (U8)set_version_major;
  if (set_version_minor != -1) lasheader.version_minor = (U8)set_version_minor;
  if (set_scale_factor)
  {
    lasheader.x_scale_factor = set_scale_factor[0];
    lasheader.y_scale_factor = set_scale_factor[1];
    lasheader.z_scale_factor = set_scale_factor[2];
  }
  if (set_offset)
  {
    lasheader.x_offset = set_offset[0];
    lasheader.y_offset = set_offset[1];
    lasheader.z_offset = set_offset[2];
  }

  // maybe we should add projection information

  if (geoprojectionconverter.has_projection())
  {
    int number_of_keys;
    GeoProjectionGeoKeys* geo_keys = 0;
    int num_geo_double_params;
    double* geo_double_params = 0;
    if (geoprojectionconverter.get_geo_keys_from_projection(number_of_keys, &geo_keys, num_geo_double_params, &geo_double_params))
    {
      lasheader.set_geo_keys(number_of_keys, (LASvlr_key_entry*)geo_keys);
      if (geo_double_params)
      {
        lasheader.set_geo_double_params(num_geo_double_params, geo_double_params);
      }
      lasheader.del_geo_ascii_params();
    }
  }

  // initialize the point

  point.init(&lasheader, lasheader.point_data_format, lasheader.point_data_record_length);

  // here we make *ONE* big switch. that replicates some code but makes it simple.

  if (laswriteopener.piped())
  {
    // because the output goes to a pipe we have to precompute the header
    // information with an additional pass. the input must be a file.

    // open input file for first pass

    FILE* file_in = fopen_compressed(file_name_in, "r");

    if (file_in == 0)
    {
      fprintf(stderr, "ERROR: could not open '%s' for first pass\n", file_name_in);
      usage(argc==1);
    }

    // create a cheaper parse string that only looks for 'x' 'y' 'z' and 'r'

    char* parse_less = strdup(parse_string);
    for (i = 0; i < (int)strlen(parse_string); i++)
    {
      if (parse_less[i] != 'x' && parse_less[i] != 'y' && parse_less[i] != 'z' && parse_less[i] != 'r') 
      {
        parse_less[i] = 's';
      }
    }
    do
    {
      parse_less[i] = '\0';
      i--;
    } while (parse_less[i] == 's');

    // first pass to figure out the bounding box and number of returns

    if (verbose) { fprintf(stderr, "first pass over file '%s' with parse '%s'\n", file_name_in, parse_less); }

    // skip lines if we have to

    for (i = 0; i < skip_first_lines; i++) fgets(line, sizeof(char) * MAX_CHARACTERS_PER_LINE, file_in);

    // read the first line

    while (fgets(line, sizeof(char) * MAX_CHARACTERS_PER_LINE, file_in))
    {
      if (parse(parse_less, line, xyz, &point))
      {
        // init the bounding box
        VecCopy3dv(xyz_min, xyz);
        VecCopy3dv(xyz_max, xyz);
        // mark that we found the first point
        npoints = 1;
        // create return histogram
        number_of_points_by_return[point.return_number]++;
        // we can stop this loop
        break;
      }
      else
      {
        line[strlen(line)-1] = '\0';
        if (!quiet) fprintf(stderr, "WARNING: cannot parse '%s' with '%s'. skipping ...\n", line, parse_less);
      }
    }

    // did we manage to parse a line

    if (npoints != 1)
    {
      fprintf(stderr, "ERROR: could not parse any lines with '%s'\n", parse_less);
      usage(argc==1);
    }

    // loop over the remaining lines

    while (fgets(line, sizeof(char) * MAX_CHARACTERS_PER_LINE, file_in))
    {
      if (parse(parse_less, line, xyz, &point))
      {
        // update bounding box
        VecUpdateMinMax3dv(xyz_min, xyz_max, xyz);
        // count points
        npoints++;
        // create return histogram
        number_of_points_by_return[point.return_number]++;
      }
      else
      {
        line[strlen(line)-1] = '\0';
        if (!quiet) fprintf(stderr, "WARNING: cannot parse '%s' with '%s'. skipping ...\n", line, parse_less);
      }
    }

    // output some stats
    
    if (verbose)
    {
      fprintf(stderr,"took %g sec.\n", taketime()-start_time); start_time = taketime();
#ifdef _WIN32
      fprintf(stderr, "npoints %I64d min %g %g %g max %g %g %g\n", npoints, xyz_min[0], xyz_min[1], xyz_min[2], xyz_max[0], xyz_max[1], xyz_max[2]);
#else
      fprintf(stderr, "npoints %lld min %g %g %g max %g %g %g\n", npoints, xyz_min[0], xyz_min[1], xyz_min[2], xyz_max[0], xyz_max[1], xyz_max[2]);
#endif
      fprintf(stderr, "return histogram %d %d %d %d %d %d %d %d\n", number_of_points_by_return[0], number_of_points_by_return[1], number_of_points_by_return[2], number_of_points_by_return[3], number_of_points_by_return[4], number_of_points_by_return[5], number_of_points_by_return[6], number_of_points_by_return[7]);
    }

    // close the input file
    
    fclose(file_in);

    // if not specified in the command line, set a reasonable scale_factor
    if (set_scale_factor == 0)
    {
      if (xyz_min[0] > -360 && xyz_min[1] > -360 && xyz_max[0] < 360 && xyz_max[1] < 360) // do we have longitude / latitude coordinates
      {
        lasheader.x_scale_factor = 1e-7;
        lasheader.y_scale_factor = 1e-7;
      }
      else // then we assume utm or mercator / lambertian projections
      {
        lasheader.x_scale_factor = 0.01;
        lasheader.y_scale_factor = 0.01;
      }
      lasheader.z_scale_factor = 0.01;
    }

    // if not specified in the command line, set a reasonable offset
    if (set_offset == 0)
    {
      if (xyz_min[0] > -360 && xyz_min[1] > -360 && xyz_max[0] < 360 && xyz_max[1] < 360) // do we have longitude / latitude coordinates
      {
        lasheader.x_offset = 0;
        lasheader.y_offset = 0;
      }
      else // then we assume utm or mercator / lambertian projections
      {
        lasheader.x_offset = ((I32)((xyz_min[0] + xyz_max[0])/200000))*100000;
        lasheader.y_offset = ((I32)((xyz_min[1] + xyz_max[1])/200000))*100000;
      }
      lasheader.z_offset = 0;
    }

    // compute quantized bounding box

    I32 xyz_min_quant[3];
    I32 xyz_max_quant[3];
    xyz_min_quant[0] = lasheader.get_x(xyz_min[0]);
    xyz_max_quant[0] = lasheader.get_x(xyz_max[0]);
    xyz_min_quant[1] = lasheader.get_y(xyz_min[1]);
    xyz_max_quant[1] = lasheader.get_y(xyz_max[1]);
    xyz_min_quant[2] = lasheader.get_z(xyz_min[2]);
    xyz_max_quant[2] = lasheader.get_z(xyz_max[2]);

    // compute unquantized bounding box

    F64 xyz_min_dequant[3];
    F64 xyz_max_dequant[3];
    xyz_min_dequant[0] = lasheader.get_x(xyz_min_quant[0]);
    xyz_max_dequant[0] = lasheader.get_x(xyz_max_quant[0]);
    xyz_min_dequant[1] = lasheader.get_y(xyz_min_quant[1]);
    xyz_max_dequant[1] = lasheader.get_y(xyz_max_quant[1]);
    xyz_min_dequant[2] = lasheader.get_z(xyz_min_quant[2]);
    xyz_max_dequant[2] = lasheader.get_z(xyz_max_quant[2]);

    // make sure there is not sign flip

#define log_xor !=0==!

    for (i = 0; i < 3; i++)
    {
      if ((xyz_min[i] > 0) log_xor (xyz_min_dequant[i] > 0))
      {
        fprintf(stderr, "WARNING: quantization sign flip for %s min coord %g -> %g.\n", (i ? (i == 1 ? "y" : "z") : "x"), xyz_min[i], xyz_min_dequant[i]);
        fprintf(stderr, "         use '-set_scale' to set a higher scale factor for %s\n", (i ? (i == 1 ? "y" : "z") : "x"));
      }
      if ((xyz_max[i] > 0) log_xor (xyz_max_dequant[i] > 0))
      {
        fprintf(stderr, "WARNING: quantization sign flip for %s max coord %g -> %g. use --set_scale\n", (i ? (i == 1 ? "y" : "z") : "x"), xyz_max[i], xyz_max_dequant[i]);
        fprintf(stderr, "         use '-set_scale' to set a higher scale factor for %s\n", (i ? (i == 1 ? "y" : "z") : "x"));
      }
    }

#undef log_xor

    // populate the rest of the header

    lasheader.number_of_point_records = (U32)npoints;
    lasheader.min_x = xyz_min_dequant[0];
    lasheader.min_y = xyz_min_dequant[1];
    lasheader.min_z = xyz_min_dequant[2];
    lasheader.max_x = xyz_max_dequant[0];
    lasheader.max_y = xyz_max_dequant[1];
    lasheader.max_z = xyz_max_dequant[2];
    lasheader.number_of_points_by_return[0] = number_of_points_by_return[1];
    lasheader.number_of_points_by_return[1] = number_of_points_by_return[2];
    lasheader.number_of_points_by_return[2] = number_of_points_by_return[3];
    lasheader.number_of_points_by_return[3] = number_of_points_by_return[4];
    lasheader.number_of_points_by_return[4] = number_of_points_by_return[5];

    // reopen input file for the second pass

    file_in = fopen_compressed(file_name_in, "r");

    if (file_in == 0)
    {
      fprintf(stderr, "ERROR: could not open '%s' for second pass\n",file_name_in);
      usage(argc==1);
    }

    // open the output pipe

    LASwriter* laswriter = laswriteopener.open(&lasheader);

    if (laswriter == 0)
    {
      fprintf(stderr, "ERROR: could not open laswriter\n");
      usage(argc==1);
    }

    if (verbose) fprintf(stderr, "second pass over file '%s' with parse '%s' writing to 'stdout'\n", file_name_in, parse_string);

    // skip lines if we have to

    for (i = 0; i < skip_first_lines; i++) fgets(line, sizeof(char) * MAX_CHARACTERS_PER_LINE, file_in);

    // loop over points

    while (fgets(line, sizeof(char) * MAX_CHARACTERS_PER_LINE, file_in))
    {
      if (parse(parse_string, line, xyz, &point))
      {
        // compute the quantized x, y, and z values
        point.x = lasheader.get_x(xyz[0]);
        point.y = lasheader.get_y(xyz[1]);
        point.z = lasheader.get_z(xyz[2]);
        // write the point
        laswriter->write_point(&point);
        npoints--;
      }
      else
      {
        line[strlen(line)-1] = '\0';
        if (!quiet) fprintf(stderr, "WARNING: cannot parse '%s' with '%s'. skipping ...\n", line, parse_string);
      }
    }

    // close input file

    fclose(file_in);

    if (npoints)
    {
#ifdef _WIN32
      fprintf(stderr, "WARNING: second pass has different number of points (%I64d instead of %I64d)\n", laswriter->p_count, laswriter->p_count + npoints);
#else
      fprintf(stderr, "WARNING: second pass has different number of points (%lld instead of %lld)\n", laswriter->p_count, laswriter->p_count + npoints);
#endif
    }

    // close and delete the laswriter

    laswriter->close();
    delete laswriter;

    if (verbose) fprintf(stderr,"took %g sec.\n", taketime()-start_time);
  }
  else
  {
    // because the output goes to a file we can do everything in a single pass
    // and compute the header information along the way and set it at the end 

    // open input file

    FILE* file_in = 0;

    if (file_name_in)
    {
      file_in = fopen_compressed(file_name_in, "r");
      if (file_in == 0)
      {
        fprintf(stderr, "ERROR: could not open input file '%s'\n", file_name_in);
        usage(argc==1);
      }
    }
    else if (use_stdin)
    {
      file_in = stdin;
    }
    else
    {
      fprintf(stderr, "ERROR: no input specified.\n");
      usage(argc==1);
    }

    // we will open the laswriter after we read the first point
    LASwriter* laswriter;

    if (verbose) fprintf(stderr, "scanning '%s' with parse '%s' writing to '%s'\n", file_name_in ? file_name_in : "stdin" , parse_string, laswriteopener.get_file_name());

    // skip lines if we have to

    for (i = 0; i < skip_first_lines; i++) fgets(line, sizeof(char) * MAX_CHARACTERS_PER_LINE, file_in);

    // read the first line

    while (fgets(line, sizeof(char) * MAX_CHARACTERS_PER_LINE, file_in))
    {
      if (parse(parse_string, line, xyz, &point))
      {
        // init the bounding box
        VecCopy3dv(xyz_min, xyz);
        VecCopy3dv(xyz_max, xyz);
        // we found the first point
        npoints = 1;
        // create return histogram
        number_of_points_by_return[point.return_number]++;
        // if not specified in the command line, set a reasonable scale_factor
        if (set_scale_factor == 0)
        {
          if (xyz_min[0] > -360 && xyz_min[1] > -360 && xyz_max[0] < 360 && xyz_max[1] < 360) // do we have longitude / latitude coordinates
          {
            lasheader.x_scale_factor = 1e-7;
            lasheader.y_scale_factor = 1e-7;
          }
          else // then we assume utm or mercator / lambertian projections
          {
            lasheader.x_scale_factor = 0.01;
            lasheader.y_scale_factor = 0.01;
          }
          lasheader.z_scale_factor = 0.01;
        }

        // if not specified in the command line, set a reasonable offset
        if (set_offset == 0)
        {
          if (xyz_min[0] > -360 && xyz_min[1] > -360 && xyz_max[0] < 360 && xyz_max[1] < 360) // do we have longitude / latitude coordinates
          {
            lasheader.x_offset = 0;
            lasheader.y_offset = 0;
          }
          else // then we assume utm or mercator / lambertian projections
          {
            lasheader.x_offset = ((I32)(xyz_min[0]/100000))*100000;
            lasheader.y_offset = ((I32)(xyz_min[1]/100000))*100000;
          }
          lasheader.z_offset = 0;
        }

        laswriter = laswriteopener.open(&lasheader);

        if (laswriter == 0)
        {
          fprintf(stderr, "ERROR: could not open laswriter\n");
          usage(argc==1);
        }

        // compute the quantized x, y, and z values
        point.x = lasheader.get_x(xyz[0]);
        point.y = lasheader.get_y(xyz[1]);
        point.z = lasheader.get_z(xyz[2]);
        // write the first point
        laswriter->write_point(&point);
        // we can stop this loop
        break;
      }
      else
      {
        line[strlen(line)-1] = '\0';
        if (!quiet) fprintf(stderr, "WARNING: cannot parse '%s' with '%s'. skipping ...\n", line, parse_string);
      }
    }

    // did we manage to parse a line

    if (npoints != 1)
    {
      fprintf(stderr, "ERROR: could not parse any lines with '%s'\n", parse_string);
      exit(1);
    }

    // loop over the remaining lines

    while (fgets(line, sizeof(char) * MAX_CHARACTERS_PER_LINE, file_in))
    {
      if (parse(parse_string, line, xyz, &point))
      {
        // update bounding box
        VecUpdateMinMax3dv(xyz_min, xyz_max, xyz);
        // count points
        npoints++;
        // create return histogram
        number_of_points_by_return[point.return_number]++;
        // compute the quantized x, y, and z values
        point.x = lasheader.get_x(xyz[0]);
        point.y = lasheader.get_y(xyz[1]);
        point.z = lasheader.get_z(xyz[2]);
        // write the remaining points
        laswriter->write_point(&point);
      }
      else
      {
        line[strlen(line)-1] = '\0';
        if (!quiet) fprintf(stderr, "WARNING: cannot parse '%s' with '%s'. skipping ...\n", line, parse_string);
      }
    }

    // done reading the text file

    if (file_in != stdin) fclose(file_in);

    // compute quantized bounding box

    I32 xyz_min_quant[3];
    I32 xyz_max_quant[3];
    xyz_min_quant[0] = lasheader.get_x(xyz_min[0]);
    xyz_max_quant[0] = lasheader.get_x(xyz_max[0]);
    xyz_min_quant[1] = lasheader.get_y(xyz_min[1]);
    xyz_max_quant[1] = lasheader.get_y(xyz_max[1]);
    xyz_min_quant[2] = lasheader.get_z(xyz_min[2]);
    xyz_max_quant[2] = lasheader.get_z(xyz_max[2]);

    // compute unquantized bounding box

    F64 xyz_min_dequant[3];
    F64 xyz_max_dequant[3];
    xyz_min_dequant[0] = lasheader.get_x(xyz_min_quant[0]);
    xyz_max_dequant[0] = lasheader.get_x(xyz_max_quant[0]);
    xyz_min_dequant[1] = lasheader.get_y(xyz_min_quant[1]);
    xyz_max_dequant[1] = lasheader.get_y(xyz_max_quant[1]);
    xyz_min_dequant[2] = lasheader.get_z(xyz_min_quant[2]);
    xyz_max_dequant[2] = lasheader.get_z(xyz_max_quant[2]);

    // make sure there is not sign flip

#define log_xor !=0==!

    for (i = 0; i < 3; i++)
    {
      if ((xyz_min[i] > 0) log_xor (xyz_min_dequant[i] > 0))
      {
        fprintf(stderr, "WARNING: quantization sign flip for %s min coord %g -> %g. use offset or scale up\n", (i ? (i == 1 ? "y" : "z") : "x"), xyz_min[i], xyz_min_dequant[i]);
        fprintf(stderr, "         use '-set_scale' to set a higher scale factor for %s\n", (i ? (i == 1 ? "y" : "z") : "x"));
      }
      if ((xyz_max[i] > 0) log_xor (xyz_max_dequant[i] > 0))
      {
        fprintf(stderr, "WARNING: quantization sign flip for %s max coord %g -> %g. use offset or scale up\n", (i ? (i == 1 ? "y" : "z") : "x"), xyz_max[i], xyz_max_dequant[i]);
        fprintf(stderr, "         use '-set_scale' to set a higher scale factor for %s\n", (i ? (i == 1 ? "y" : "z") : "x"));
      }
    }

#undef log_xor

    // rewrite the header

    lasheader.number_of_point_records = (U32)npoints;
    lasheader.number_of_points_by_return[0] = number_of_points_by_return[1];
    lasheader.number_of_points_by_return[1] = number_of_points_by_return[2];
    lasheader.number_of_points_by_return[2] = number_of_points_by_return[3];
    lasheader.number_of_points_by_return[3] = number_of_points_by_return[4];
    lasheader.number_of_points_by_return[4] = number_of_points_by_return[5];
    lasheader.max_x = xyz_max_dequant[0];
    lasheader.min_x = xyz_min_dequant[0];
    lasheader.max_y = xyz_max_dequant[1];
    lasheader.min_y = xyz_min_dequant[1];
    lasheader.max_z = xyz_max_dequant[2];
    lasheader.min_z = xyz_min_dequant[2];

    laswriter->update_header(&lasheader);

    // close and delete the laswriter

    laswriter->close();
    delete laswriter;

    // output some stats
    
    if (verbose)
    {
      fprintf(stderr,"took %g sec.\n", taketime()-start_time);
#ifdef _WIN32
      fprintf(stderr, "npoints %I64d min %g %g %g max %g %g %g\n", npoints, xyz_min[0], xyz_min[1], xyz_min[2], xyz_max[0], xyz_max[1], xyz_max[2]);
#else
      fprintf(stderr, "npoints %lld min %g %g %g max %g %g %g\n", npoints, xyz_min[0], xyz_min[1], xyz_min[2], xyz_max[0], xyz_max[1], xyz_max[2]);
#endif
      fprintf(stderr, "return histogram %u %u %u %u %u %u %u %u\n", number_of_points_by_return[0], number_of_points_by_return[1], number_of_points_by_return[2], number_of_points_by_return[3], number_of_points_by_return[4], number_of_points_by_return[5], number_of_points_by_return[6], number_of_points_by_return[7]);
    }
  }

  byebye(argc==1);

  return 0;
}
