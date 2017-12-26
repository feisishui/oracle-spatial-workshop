****************************************************************

  lasinfo:

  Simply prints the header contents and a short summary of the
  points. when there are differences between header info and
  point content they are reported as a warning.

  The tool can also be used to modify entries in the header as
  described below.

  For updates check the website or join the LAStools mailing list.

  http://www.cs.unc.edu/~isenburg/lastools/
  http://groups.google.com/group/lastools/
  https://lidarbb.cr.usgs.gov/index.php?showforum=29
  http://twitter.com/lastools/
  http://facebook.com/lastools/

  Martin @lastools

****************************************************************

example usage:

>> lasinfo lidar.las

reports all information 

>> lasinfo *.las

reports all information for all files

>> lasinfo lidar1.las lidar2.las -merged

reports all information for a merged LAS file containing both
lidar1.las and lidar2.las

>> lasinfo -o lidar_info.txt -i lidar.las

reports all information to a text file called lidar_info.txt

>> lasinfo -i lidar.las -no_variable

avoids reporting the contents of the variable length records

>> lasinfo -i lidar.las -nocheck

omits reading over all the points. only reports header information

>> lasinfo -i lidar.las -repair

if there are missing or wrong entries in the header they are corrected

>> lasinfo -i lidar.las -auto_date

sets the file creation day/year in the header based on the creation date of the file

>> lasinfo -i lidar.las -repair_boundingbox

reads all points, computes their bounding box, and updates it in the header

>> lasinfo -i lidar.las -set_file_creation 8 2007

sets the file creation day/year in the header to 8/2007

>> lasinfo -i lidar.las -set_system_identifier "hello world!"

copies the first 31 characters of the string into the system_identifier field of the header 

>> lasinfo -i lidar.las -set_version 1.1 -quiet

changes the version of the lidar file to be 1.1 while suppressing all control output

>> lasinfo -i lidar.las -set_generating_software "this is a test (-:"

copies the first 31 characters of the string into the generating_software field of the header 

for more info:

C:\lastools\bin>lasinfo -h
Filter points based on their coordinates.
  -clip_tile 631000 4834000 1000 (ll_x, ll_y, size)
  -clip_circle 630250.00 4834750.00 100 (x, y, radius)
  -clip 630000 4834000 631000 4836000 (min_x, min_y, max_x, max_y)
  -clip_x_below 630000.50 (min_x)
  -clip_y_below 4834500.25 (min_y)
  -clip_x_above 630500.50 (max_x)
  -clip_y_above 4836000.75 (max_y)
  -clip_z 11.125 130.725 (min_z, max_z)
  -clip_z_below 11.125 (min_z)
  -clip_z_above 130.725 (max_z)
Filter points based on their return number.
  -first_only
  -last_only
  -keep_return 1 2 3
  -drop_return 3 4
  -single_returns_only
  -double_returns_only
  -triple_returns_only
  -quadruple_returns_only
  -quintuple_returns_only
Filter points based on the scanline flags.
  -drop_scan_direction 0
  -scan_direction_change_only
  -edge_of_flight_line_only
Filter points based on their intensity.
  -keep_intensity 20 380
  -drop_intensity_below 20
  -drop_intensity_above 380
  -drop_intensity_between 4000 5000
Filter points based on their classification.
  -keep_class 1 3 7
  -drop_class 4 2
Filter points based on their point source ID.
  -keep_point_source 3
  -keep_point_source_between 2 6
  -drop_point_source_below 6
  -drop_point_source_above 15
  -drop_point_source_between 17 21
Filter points based on their scan angle.
  -keep_scan_angle -15 15
  -drop_scan_angle_below -15
  -drop_scan_angle_above 15
  -drop_scan_angle_between -25 -23
Filter points based on their gps time.
  -keep_gps_time 11.125 130.725
  -drop_gps_time_below 11.125
  -drop_gps_time_above 130.725
  -drop_gps_time_between 22.0 48.0
Filter points with simple thinning.
  -keep_every_nth 2
  -keep_random_fraction 0.1
  -thin_with_grid 1.0
Transform coordinates.
  -translate_x -2.5
  -scale_z 0.3048
  -rotate_xy 15.0 620000 4100000 (angle + origin)
  -translate_xyz 0.5 0.5 0
  -translate_then_scale_y -0.5 1.001
  -clamp_z 70.5 72.5
Transform raw xyz integers.
  -translate_raw_z 20
  -translate_raw_xyz 1 1 0
  -clamp_raw_z 500 800
Transform intensity.
  -scale_intensity 2.5
  -translate_intensity 50
  -translate_then_scale_intensity 0.5 3.1
Transform scan_angle.
  -scale_scan_angle 1.944445
  -translate_scan_angle -5
  -translate_then_scale_scan_angle -0.5 2.1
Repair points with return number or pulse count of zero.
  -repair_zero_returns
Change classification by replacing one with another.
  -change_classification_from_to 2 4
Transform gps_time.
  -translate_gps_time 40.50
Transform RGB colors.
  -scale_rgb_down (by 256)
  -scale_rgb_up (by 256)
Supported LAS Inputs
  -i lidar.las
  -i lidar.laz
  -i lidar1.las lidar2.las lidar3.las -merged
  -i *.las
  -i flight0??.laz flight1??.laz -single
  -i lidar.txt -iparse xyzti (on-the-fly from ASCII)
  -i lidar.txt -iparse xyzi -itranslate_intensity 1024
  -lof file_list.txt
  -stdin (pipe from stdin)
  -rescale 0.1 0.1 0.1
  -reoffset 600000 4000000 0
usage:
lasinfo -i *.las
lasinfo -i lidar.las
lasinfo -nv -i lidar.las
lasinfo -nv -nc -stdout lidar.las
lasinfo -nv -nc -stdout *.las | grep version
lasinfo -i lidar.las -o lidar_info.txt
lasinfo -i lidar.las -repair
lasinfo -i lidar.las -repair_bounding_box -set_file_creation 8 2007
lasinfo -i lidar.las -set_version 1.2
lasinfo -i lidar.las -set_system_identifier "hello world!" -set_generating_software "this is a test (-:"

----

if you find bugs let me (martin.isenburg@gmail.com) know.
