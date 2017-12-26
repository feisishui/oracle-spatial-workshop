/*
===============================================================================

  FILE:  las2txt.cpp
  
  CONTENTS:
  
    This tool converts LIDAR data from the binary LAS format to a human
    readable ASCII format. The tool can create different formattings for
    the textual representation that are controlable via the 'parse' and
    'sep' commandline flags. Optionally the header can be placed at the
    beginning of the file each line preceeded by some comment symbol.

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
  
    17 May 2011 -- enabling batch processing with wildcards or multiple file names
    13 May 2011 -- moved indexing, filtering, transforming into LASreader
    15 March 2011 -- added the 'E' option to place an '-extra STRING' 
    26 January 2011 -- added the LAStransform to modify before output 
     4 January 2011 -- added the LASfilter to clip or eliminate points 
     1 January 2011 -- added LAS 1.3 waveforms while homesick for Livermore
     1 December 2010 -- support output of raw unscaled XYZ coordinates
    12 March 2009 -- updated to ask for input if started without arguments 
    17 September 2008 -- updated to deal with LAS format version 1.2
    13 June 2007 -- added 'e' and 'd' for the parse string and fixed 'n'
     6 June 2007 -- added lidardouble2string() after Vinton Valentine's bug report
     4 May 2007 -- completed one month later because my mother passed away
     4 April 2007 -- created in the ICE from Frankfurt Airport to Wuerzburg

===============================================================================
*/
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lasreader.hpp"

void usage(bool wait=false)
{
  fprintf(stderr,"usage:\n");
  fprintf(stderr,"las2txt -i *.las -parse xyzt\n");
  fprintf(stderr,"las2txt -i flight1*.las flight2*.las -parse xyziarn\n");
  fprintf(stderr,"las2txt -i *.las -parse xyzrn -sep comma -verbose\n");
  fprintf(stderr,"las2txt -i lidar.las -parse xyztE -extra 99 -o ascii.txt\n");
  fprintf(stderr,"las2txt -h\n");
  fprintf(stderr,"---------------------------------------------\n");
  fprintf(stderr,"The '-parse txyz' flag specifies how to format each\n");
  fprintf(stderr,"each line of the ASCII file. For example, 'txyzia'\n");
  fprintf(stderr,"means that the first number of each line should be the\n");
  fprintf(stderr,"gpstime, the next three numbers should be the x, y, and\n");
  fprintf(stderr,"z coordinate, the next number should be the intensity\n");
  fprintf(stderr,"and the next number should be the scan angle.\n");
  fprintf(stderr,"The supported entries are a - scan angle, i - intensity,\n");
  fprintf(stderr,"n - number of returns for given pulse, r - number of\n");
  fprintf(stderr,"this return, c - classification, u - user data,\n");
  fprintf(stderr,"p - point source ID, e - edge of flight line flag, and\n");
  fprintf(stderr,"d - direction of scan flag, R - red channel of RGB color,\n");
  fprintf(stderr,"G - green channel of RGB color, B - blue channel of RGB color,\n");
  fprintf(stderr,"M - the index for each point\n");
  fprintf(stderr,"X, Y, and Z - the unscaled, raw LAS integer coordinates\n");
  fprintf(stderr,"w and W - for the wavepacket information (LAS 1.3 only)\n");
  fprintf(stderr,"V - for the waVeform from the *.wpd file (LAS 1.3 only)\n");
  fprintf(stderr,"E - for an extra string. specify it with '-extra <string>'\n");
  fprintf(stderr,"---------------------------------------------\n");
  fprintf(stderr,"The '-sep space' flag specifies what separator to use. The\n");
  fprintf(stderr,"default is a space but 'tab', 'comma', 'colon', 'hyphen',\n");
  fprintf(stderr,"'dot', or 'semicolon' are other possibilities.\n");
  fprintf(stderr,"---------------------------------------------\n");
  fprintf(stderr,"The '-header pound' flag results in the header information\n");
  fprintf(stderr,"being printed at the beginning of the ASCII file in form of\n");
  fprintf(stderr,"a comment that starts with the special character '#'. Also\n");
  fprintf(stderr,"possible are 'percent', 'dollar', 'comma', 'star',\n");
  fprintf(stderr,"'colon', or 'semicolon' as that special character.\n");
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

static void lidardouble2string(char* string, double value)
{
  int len;
  len = sprintf(string, "%.15f", value) - 1;
  while (string[len] == '0') len--;
  if (string[len] != '.') len++;
  string[len] = '\0';
}

static void lidardouble2string(char* string, double value, double precision)
{
  if (precision == 0.1)
    sprintf(string, "%.1f", value);
  else if (precision == 0.01)
    sprintf(string, "%.2f", value);
  else if (precision == 0.001)
    sprintf(string, "%.3f", value);
  else if (precision == 0.0001)
    sprintf(string, "%.4f", value);
  else if (precision == 0.00001)
    sprintf(string, "%.5f", value);
  else if (precision == 0.000001)
    sprintf(string, "%.6f", value);
  else if (precision == 0.0000001)
    sprintf(string, "%.7f", value);
  else if (precision == 0.00000001)
    sprintf(string, "%.8f", value);
  else if (precision == 0.000000001)
    sprintf(string, "%.9f", value);
  else
    lidardouble2string(string, value);
}

static void output_waveform(FILE* file_out, char separator_sign, FILE* file_wdp, LASwavepacket* wavepacket, LASvlr_wave_packet_descr** vlr_wave_packet_descr_array, U64 start_of_waveform_data_packet_record)
{
  U32 i;
  LASvlr_wave_packet_descr* vlr_wave_packet_descr = vlr_wave_packet_descr_array[wavepacket->getIndex()];
  if (vlr_wave_packet_descr == 0)
  {
    fprintf(stderr, "ERROR: wavepacket descriptor with index %d does not exist\n", wavepacket->getIndex());
    return;
  }
  long seekpos = (long) start_of_waveform_data_packet_record + (long) wavepacket->getOffset();
  fseek(file_wdp, seekpos, SEEK_SET);
  fprintf(file_out, "%d", vlr_wave_packet_descr->getBitsPerSample());
  fprintf(file_out, "%c%d", separator_sign, vlr_wave_packet_descr->getNumberOfSamples());
  for (i = 0; i < vlr_wave_packet_descr->getNumberOfSamples(); i++)
  {
    if (vlr_wave_packet_descr->getBitsPerSample() == 8)
    {
      U8 sample;
      fread(&sample, 1, 1, file_wdp);
      fprintf(file_out, "%c%d", separator_sign, sample);
    }
    else if (vlr_wave_packet_descr->getBitsPerSample() == 16)
    {
      U16 sample;
      fread(&sample, 1, 2, file_wdp);
      fprintf(file_out, "%c%d", separator_sign, sample);
    }
    else if (vlr_wave_packet_descr->getBitsPerSample() == 32)
    {
      U32 sample;
      fread(&sample, 1, 4, file_wdp);
      fprintf(file_out, "%c%d", separator_sign, sample);
    }
  }
}

int main(int argc, char *argv[])
{
  int i;
  bool otxt = false;
  bool diff = false;
  bool need_waveform_file = false;
  bool verbose = false;
  char* file_name_wdp = 0;
  char* file_name_out = 0;
  char separator_sign = ' ';
  char header_comment_sign = '\0';
  char* parse_string = strdup("xyz");
  char* extra_string = 0;
  char printstring[512];
  double start_time = 0.0;

  LASreadOpener lasreadopener;

  lasreadopener.set_merged(FALSE);
  lasreadopener.set_populate_header(FALSE);

  if (argc == 1)
  {
    fprintf(stderr,"las2txt.exe is better run in the command line\n");
    char file_name_in[256];
    fprintf(stderr,"enter input file: "); fgets(file_name_in, 256, stdin);
    file_name_in[strlen(file_name_in)-1] = '\0';
    lasreadopener.set_file_name(file_name_in);
    file_name_out = new char[256];
    fprintf(stderr,"enter output file: "); fgets(file_name_out, 256, stdin);
    file_name_out[strlen(file_name_out)-1] = '\0';
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
    else if (strcmp(argv[i],"-parse") == 0)
    {
      i++;
      parse_string = argv[i];
    }
    else if (strcmp(argv[i],"-parse_all") == 0)
    {
      i++;
      parse_string = strdup("xyzirndecaupt");
    }
    else if (strcmp(argv[i],"-extra") == 0)
    {
      i++;
      extra_string = argv[i];
    }
    else if (strcmp(argv[i],"-sep") == 0)
    {
      i++;
      if (strcmp(argv[i],"comma") == 0 || strcmp(argv[i],"komma") == 0)
      {
        separator_sign = ',';
      }
      else if (strcmp(argv[i],"tab") == 0)
      {
        separator_sign = '\t';
      }
      else if (strcmp(argv[i],"dot") == 0 || strcmp(argv[i],"period") == 0)
      {
        separator_sign = '.';
      }
      else if (strcmp(argv[i],"colon") == 0)
      {
        separator_sign = ':';
      }
      else if (strcmp(argv[i],"semicolon") == 0)
      {
        separator_sign = ';';
      }
      else if (strcmp(argv[i],"hyphen") == 0 || strcmp(argv[i],"minus") == 0)
      {
        separator_sign = '-';
      }
      else if (strcmp(argv[i],"space") == 0)
      {
        separator_sign = ' ';
      }
      else
      {
        fprintf(stderr, "ERROR: unknown seperator '%s'\n",argv[i]);
        usage();
      }
    }
    else if ((strcmp(argv[i],"-header") == 0 || strcmp(argv[i],"-comment") == 0))
    {
      i++;
      if (strcmp(argv[i],"comma") == 0 || strcmp(argv[i],"komma") == 0)
      {
        header_comment_sign = ',';
      }
      else if (strcmp(argv[i],"colon") == 0)
      {
        header_comment_sign = ':';
      }
      else if (strcmp(argv[i],"scolon") == 0 || strcmp(argv[i],"semicolon") == 0)
      {
        header_comment_sign = ';';
      }
      else if (strcmp(argv[i],"pound") == 0 || strcmp(argv[i],"hash") == 0)
      {
        header_comment_sign = '#';
      }
      else if (strcmp(argv[i],"percent") == 0)
      {
        header_comment_sign = '%';
      }
      else if (strcmp(argv[i],"dollar") == 0)
      {
        header_comment_sign = '$';
      }
      else if (strcmp(argv[i],"star") == 0)
      {
        header_comment_sign = '*';
      }
      else
      {
        fprintf(stderr, "ERROR: unknown header comment symbol '%s'\n",argv[i]);
        usage();
      }
    }
    else if (strcmp(argv[i],"-otxt") == 0 || strcmp(argv[i],"-stdout") == 0)
    {
      otxt = true;
    }
    else if (strcmp(argv[i],"-o") == 0)
    {
      i++;
      file_name_out = strdup(argv[i]);
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

    // check requested fields and print warnings of necessary
    i = 0;
    while (parse_string[i])
    {
      switch (parse_string[i])
      {
      case 'x': // the x coordinate
      case 'y': // the y coordinate
      case 'z': // the z coordinate
      case 'X': // the unscaled raw integer X coordinate
      case 'Y': // the unscaled raw integer Y coordinate
      case 'Z': // the unscaled raw integer Z coordinate
      case 'i': // the intensity
      case 'a': // the scan angle
      case 'r': // the number of the return
      case 'c': // the classification
      case 'u': // the user data
      case 'n': // the number of returns of given pulse
      case 'p': // the point source ID
      case 'e': // the edge of flight line flag
      case 'd': // the direction of scan flag
      case 'M': // the index of the point
        break;
      case 't': // the gps-time
        if (lasreader->point.have_gps_time == false)
          fprintf (stderr, "WARNING: requested 't' but points do not have gps time\n");
        break;
      case 'R': // the red channel of the RGB field
        if (lasreader->point.have_rgb == false)
          fprintf (stderr, "WARNING: requested 'R' but points do not have rgb\n");
        break;
      case 'G': // the green channel of the RGB field
        if (lasreader->point.have_rgb == false)
          fprintf (stderr, "WARNING: requested 'G' but points do not have rgb\n");
        break;
      case 'B': // the blue channel of the RGB field
        if (lasreader->point.have_rgb == false)
          fprintf (stderr, "WARNING: requested 'B' but points do not have rgb\n");
        break;
      case 'w': // the wavepacket index
        if (lasreader->point.have_wavepacket == false)
          fprintf (stderr, "WARNING: requested 'w' but points do not have wavepacket\n");
        break;
      case 'W': // all wavepacket attributes
        if (lasreader->point.have_wavepacket == false)
          fprintf (stderr, "WARNING: requested 'W' but points do not have wavepacket\n");
        break;
      case 'V': // the waveform data
        if (lasreader->point.have_wavepacket == false)
        {
          fprintf (stderr, "WARNING: requested 'V' but points do not have wavepacket\n");
          need_waveform_file = false;
        }
        else
          need_waveform_file = true;
        break;
      case '0':
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9':
        diff = true;
        break;
      case 'E':
        if (extra_string == 0)
        {
          fprintf (stderr, "WARNING: requested 'E' but no '-extra' specified\n");
          parse_string[i] = 's';
        }
        break;
      default:
        fprintf (stderr, "WARNING: requested unknown parse item '%c'\n", parse_string[i]);
      }
      i++;
    }

    // do we need to access the waveforms
    FILE* file_wdp = 0;
    if (need_waveform_file)
    {
      if (lasreader->header.global_encoding & 4)
      {
        if (verbose) fprintf(stderr, "Waveform Data External\n");
        file_name_wdp = strdup(lasreadopener.get_file_name());
        int len = strlen(file_name_wdp);
        file_name_wdp[len-3] = 'w';
        file_name_wdp[len-2] = 'd';
        file_name_wdp[len-1] = 'p';
      }
      else if (lasreader->header.global_encoding & 2)
      {
        if (verbose) fprintf(stderr, "Waveform Data Internal\n");
        file_name_wdp = strdup(lasreadopener.get_file_name());
      }
      else
      {
        fprintf(stderr, "WARNING: file does not specify internal or external.\n");
        if (lasreader->header.start_of_waveform_data_packet_record < lasreader->header.offset_to_point_data)
        {
          fprintf(stderr, "         but start_of_waveform_data_packet_record is small. assuming external.\n");
          file_name_wdp = strdup(lasreadopener.get_file_name());
          int len = strlen(file_name_wdp);
          file_name_wdp[len-3] = 'w';
          file_name_wdp[len-2] = 'd';
          file_name_wdp[len-1] = 'p';
        }
        else
        {
          fprintf(stderr, "         but start_of_waveform_data_packet_record is large. assuming internal.\n");
          file_name_wdp = strdup(lasreadopener.get_file_name());
        }
      }

      // open the wavedatapacket file

      file_wdp = fopen(file_name_wdp, "rb");

      if (file_wdp == 0)
      {
        fprintf(stderr, "ERROR: could not open '%s' for read\n", file_name_wdp);
        usage(argc==1);
      }
    }

    // open output file
  
    FILE* file_out;

    if (otxt)
    {
      file_out = stdout;
    }
    else
    {
      // create output file name if needed 

      if (file_name_out == 0)
      {
        if (lasreadopener.get_file_name() == 0)
        {
          fprintf(stderr, "ERROR: no output file specified\n");
          usage(argc==1);
        }
        file_name_out = strdup(lasreadopener.get_file_name());
        int len = strlen(file_name_out);
        file_name_out[len-3] = 't';
        file_name_out[len-2] = 'x';
        file_name_out[len-1] = 't';
      }

      // open output file

      file_out = fopen(file_name_out, "w");

      // fail if output file does not open

      if (file_out == 0)
      {
        fprintf(stderr, "ERROR: could not open '%s' for write\n", file_name_out);
        usage(argc==1);
      }

      free(file_name_out);
      file_name_out = 0;
    }

    // output header info

    if (header_comment_sign)
    {
      LASheader* header = &(lasreader->header);
      fprintf(file_out, "%c file signature:            '%.4s'\012", header_comment_sign, header->file_signature);
      fprintf(file_out, "%c file source ID:            %d\012", header_comment_sign, header->file_source_id);
      fprintf(file_out, "%c reserved (global encoding):%d\012", header_comment_sign, header->global_encoding);
      fprintf(file_out, "%c project ID GUID data 1-4:  %d %d %d '%.8s'\012", header_comment_sign, header->project_ID_GUID_data_1, header->project_ID_GUID_data_2, header->project_ID_GUID_data_3, header->project_ID_GUID_data_4);
      fprintf(file_out, "%c version major.minor:       %d.%d\012", header_comment_sign, header->version_major, header->version_minor);
      fprintf(file_out, "%c system_identifier:         '%.32s'\012", header_comment_sign, header->system_identifier);
      fprintf(file_out, "%c generating_software:       '%.32s'\012", header_comment_sign, header->generating_software);
      fprintf(file_out, "%c file creation day/year:    %d/%d\012", header_comment_sign, header->file_creation_day, header->file_creation_year);
      fprintf(file_out, "%c header size                %d\012", header_comment_sign, header->header_size);
      fprintf(file_out, "%c offset to point data       %u\012", header_comment_sign, header->offset_to_point_data);
      fprintf(file_out, "%c number var. length records %u\012", header_comment_sign, header->number_of_variable_length_records);
      fprintf(file_out, "%c point data format          %d\012", header_comment_sign, header->point_data_format);
      fprintf(file_out, "%c point data record length   %d\012", header_comment_sign, header->point_data_record_length);
      fprintf(file_out, "%c number of point records    %u\012", header_comment_sign, header->number_of_point_records);
      fprintf(file_out, "%c number of points by return %u %u %u %u %u\012", header_comment_sign, header->number_of_points_by_return[0], header->number_of_points_by_return[1], header->number_of_points_by_return[2], header->number_of_points_by_return[3], header->number_of_points_by_return[4]);
      fprintf(file_out, "%c scale factor x y z         %g %g %g\012", header_comment_sign, header->x_scale_factor, header->y_scale_factor, header->z_scale_factor);
      fprintf(file_out, "%c offset x y z               ", header_comment_sign); lidardouble2string(printstring, header->x_offset); fprintf(file_out, "%s ", printstring);  lidardouble2string(printstring, header->y_offset); fprintf(file_out, "%s ", printstring);  lidardouble2string(printstring, header->z_offset); fprintf(file_out, "%s\012", printstring);
      fprintf(file_out, "%c min x y z                  ", header_comment_sign); lidardouble2string(printstring, header->min_x, header->x_scale_factor); fprintf(file_out, "%s ", printstring); lidardouble2string(printstring, header->min_y, header->y_scale_factor); fprintf(file_out, "%s ", printstring); lidardouble2string(printstring, header->min_z, header->z_scale_factor); fprintf(file_out, "%s\012", printstring);
      fprintf(file_out, "%c max x y z                  ", header_comment_sign); lidardouble2string(printstring, header->max_x, header->x_scale_factor); fprintf(file_out, "%s ", printstring); lidardouble2string(printstring, header->max_y, header->y_scale_factor); fprintf(file_out, "%s ", printstring); lidardouble2string(printstring, header->max_z, header->z_scale_factor); fprintf(file_out, "%s\012", printstring);
    }

    // in case diff is requested

    int last_XYZ[3] = {0,0,0};
    unsigned short last_RGB[3] = {0,0,0};
    double last_GPSTIME = 0;

    // read and convert the points to ASCII

#ifdef _WIN32
    if (verbose) fprintf(stderr,"processing %I64d points with '%s'.\n", lasreader->npoints, parse_string);
#else
    if (verbose) fprintf(stderr,"processing %lld points with '%s'.\n", lasreader->npoints, parse_string);
#endif

    while (lasreader->read_point())
    {
      i = 0;
      while (true)
      {
        switch (parse_string[i])
        {
        case 'x': // the x coordinate
          lidardouble2string(printstring, lasreader->point.get_x(), lasreader->header.x_scale_factor); fprintf(file_out, "%s", printstring);
          break;
        case 'y': // the y coordinate
          lidardouble2string(printstring, lasreader->point.get_y(), lasreader->header.y_scale_factor); fprintf(file_out, "%s", printstring);
          break;
        case 'z': // the z coordinate
          lidardouble2string(printstring, lasreader->point.get_z(), lasreader->header.z_scale_factor); fprintf(file_out, "%s", printstring);
          break;
        case 'X': // the unscaled raw integer X coordinate
          fprintf(file_out, "%d", lasreader->point.x);
          break;
        case 'Y': // the unscaled raw integer Y coordinate
          fprintf(file_out, "%d", lasreader->point.y);
          break;
        case 'Z': // the unscaled raw integer Z coordinate
          fprintf(file_out, "%d", lasreader->point.z);
          break;
        case 't': // the gps-time
          lidardouble2string(printstring,lasreader->point.gps_time); fprintf(file_out, "%s", printstring);
          break;
        case 'i': // the intensity
          fprintf(file_out, "%d", lasreader->point.intensity);
          break;
        case 'a': // the scan angle
          fprintf(file_out, "%d", lasreader->point.scan_angle_rank);
          break;
        case 'r': // the number of the return
          fprintf(file_out, "%d", lasreader->point.return_number);
          break;
        case 'c': // the classification
          fprintf(file_out, "%d", lasreader->point.classification);
          break;
        case 'u': // the user data
          fprintf(file_out, "%d", lasreader->point.user_data);
          break;
        case 'n': // the number of returns of given pulse
          fprintf(file_out, "%d", lasreader->point.number_of_returns_of_given_pulse);
          break;
        case 'p': // the point source ID
          fprintf(file_out, "%d", lasreader->point.point_source_ID);
          break;
        case 'e': // the edge of flight line flag
          fprintf(file_out, "%d", lasreader->point.edge_of_flight_line);
          break;
        case 'd': // the direction of scan flag
          fprintf(file_out, "%d", lasreader->point.scan_direction_flag);
          break;
        case 'R': // the red channel of the RGB field
          fprintf(file_out, "%d", lasreader->point.rgb[0]);
          break;
        case 'G': // the green channel of the RGB field
          fprintf(file_out, "%d", lasreader->point.rgb[1]);
          break;
        case 'B': // the blue channel of the RGB field
          fprintf(file_out, "%d", lasreader->point.rgb[2]);
          break;
        case 'M': // the index of the point
#ifdef _WIN32
          fprintf(file_out, "%I64d", lasreader->p_count);
#else
          fprintf(file_out, "%lld", lasreader->p_count);
#endif
          break;
        case '0': // the raw integer X difference to the last point
          fprintf(file_out, "%d", lasreader->point.x-last_XYZ[0]);
          break;
        case '1': // the raw integer Y difference to the last point
          fprintf(file_out, "%d", lasreader->point.y-last_XYZ[1]);
          break;
        case '2': // the raw integer Z difference to the last point
          fprintf(file_out, "%d", lasreader->point.z-last_XYZ[2]);
          break;
        case '3': // the gps-time difference to the last point
          lidardouble2string(printstring,lasreader->point.gps_time-last_GPSTIME); fprintf(file_out, "%s", printstring);
          break;
        case '4': // the R difference to the last point
          fprintf(file_out, "%d", lasreader->point.rgb[0]-last_RGB[0]);
          break;
        case '5': // the G difference to the last point
          fprintf(file_out, "%d", lasreader->point.rgb[1]-last_RGB[1]);
          break;
        case '6': // the B difference to the last point
          fprintf(file_out, "%d", lasreader->point.rgb[2]-last_RGB[2]);
          break;
        case '7': // the byte-wise R difference to the last point
          fprintf(file_out, "%d%c%d", (lasreader->point.rgb[0]>>8)-(last_RGB[0]>>8), separator_sign, (lasreader->point.rgb[0]&255)-(last_RGB[0]&255));
          break;
        case '8': // the byte-wise G difference to the last point
          fprintf(file_out, "%d%c%d", (lasreader->point.rgb[1]>>8)-(last_RGB[1]>>8), separator_sign, (lasreader->point.rgb[1]&255)-(last_RGB[1]&255));
          break;
        case '9': // the byte-wise B difference to the last point
          fprintf(file_out, "%d%c%d", (lasreader->point.rgb[2]>>8)-(last_RGB[2]>>8), separator_sign, (lasreader->point.rgb[2]&255)-(last_RGB[2]&255));
          break;
        case 'w': // the wavepacket index
          fprintf(file_out, "%d", lasreader->point.wavepacket.getIndex());
          break;
        case 'W': // all wavepacket attributes
          fprintf(file_out, "%d%c%d%c%d%c%g%c%g%c%g%c%g", lasreader->point.wavepacket.getIndex(), separator_sign, (U32)lasreader->point.wavepacket.getOffset(), separator_sign, lasreader->point.wavepacket.getSize(), separator_sign, lasreader->point.wavepacket.getLocation(), separator_sign, lasreader->point.wavepacket.getXt(), separator_sign, lasreader->point.wavepacket.getYt(), separator_sign, lasreader->point.wavepacket.getZt());
          break;
        case 'V': // the waVeform
          output_waveform(file_out, separator_sign, file_wdp, &lasreader->point.wavepacket, lasreader->header.vlr_wave_packet_descr, lasreader->header.start_of_waveform_data_packet_record);
          break;
        case 'E': // the extra string
          fprintf(file_out, "%s", extra_string);
          break;
        }
        i++;
        if (parse_string[i])
        {
          fprintf(file_out, "%c", separator_sign);
        }
        else
        {
          fprintf(file_out, "\012");
          break;
        }
      }
      if (diff)
      {
        last_XYZ[0] = lasreader->point.x;
        last_XYZ[1] = lasreader->point.y;
        last_XYZ[2] = lasreader->point.z;
        last_GPSTIME = lasreader->point.gps_time;
        last_RGB[0] = lasreader->point.rgb[0];
        last_RGB[1] = lasreader->point.rgb[1];
        last_RGB[2] = lasreader->point.rgb[2];
      }
    }

#ifdef _WIN32
    if (verbose) fprintf(stderr,"converting %I64d points of '%s' took %g sec.\n", lasreader->p_count, lasreadopener.get_file_name(), taketime()-start_time);
#else
    if (verbose) fprintf(stderr,"converting %lld points of '%s' took %g sec.\n", lasreader->p_count, lasreadopener.get_file_name(), taketime()-start_time);
#endif

    // close the reader
    lasreader->close();
    delete lasreader;

    // close the files

    if (file_wdp) fclose(file_wdp);
    if (file_out != stdout) fclose(file_out);
  }

  byebye(argc==1);

  return 0;
}
