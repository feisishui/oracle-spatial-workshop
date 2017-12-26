****************************************************************

  lastile:

  tiles a potentially very large amount of LAS points from one
  or many files into square non-overlapping tiles of a specified
  size and save them into LAS or LAZ format. The input file names
  can either be provided one by one or listed in a text file. The
  output file names are specified via a base name and their lower
  left coordinate.

  The square tiling used by lastile is chosen for two reasons:

  (a) it is by far the most common way that LAS files are tiled
      for archival or distribution

  (b) it will (eventually) be exploited by our "streaming TIN"
      generation code to seamlessly Delaunay triangulate large
      amounts of tiles in a highly memory-efficient fashion. For
      that purpose, lastile adds a small VLR to the header of
      each generated LAS/LAZ tile that stored its index or its
      "finalization tag" in the square quad tree.

  The tool can either operate in one or in two reading passes
  via a commandline switch (-extra_pass). The additional reading 
  pass is used to collect information about how many points fall 
  into each cell. This allows us to deallocate LASwriters for tiles
  that have seen all their points. This is *only* really needed 
  when writing LASzip compressed output of very large tilings
  to avoid having the LASwriters using LASzip compression for
  all tiles in memory at the same time.

  Please license from martin.isenburg@gmail.com to use LAStools
  commercially.

  For updates check the website or join the LAStools mailing list.

  http://www.cs.unc.edu/~isenburg/lastools/
  http://groups.google.com/group/lastools/
  https://lidarbb.cr.usgs.gov/index.php?showtopic=11845
  http://twitter.com/lastools/
  http://facebook.com/lastools/

  Martin @lastools

****************************************************************

example usage:

>> lastile -i *.las -o tiles

tiles all points from all files using the default tile size of 1000

>> lastile -i *.txt -iparse xyzti -o tiles

same but with on-the-fly converted ASCII input

>> lastile -i in1.las in2.las in3.las -o sydney -tile_size 500

tiles the points from the three LAS files with a tile size of 500. 

>> lastile -lof obx_files.txt -o outer_banks -tile_size 100 -keep_class 2 3

tiles all LAS/LAZ files listed in the text file with a tile size
of 100 keeping only points with classification 2 or 3

>> lastile -i file_list.txt -lof -o omaha -olaz -extra_pass

tiles all LAS/LAZ files listed in the text file into a LASzip
compressed tiling using the default tile size of 1000 and uses
an extra read pass in an attempt to use less memory.

>> lastile -i huge.laz -o toronto -last_only -olaz

tiles the last returns from huge.laz into compressed tiling.

for more info:

C:\lastools\bin>lastile -h
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
LAStools (by martin.isenburg@gmail.com) version 110521 (unlicensed)
usage:
lastile -i *.las -o tiles
lastile -i toronto.las -o toronto -tile_size 500 (default is 1000)
lastile -lof tahoe_files.txt -o tahoe -olaz -extra_pass -verbose
lastile -v -i file1.laz file2.laz file3.laz -o tiles -olaz
lastile -lof lidar_files.txt -o tiles -last_only -tile_size 100
lastile -i flight1*.laz flight2*.laz -o obx -keep_class 2 -tile_size 250 -olaz
lastile -h

---------------

if you find bugs let me (martin.isenburg@gmail.com) know.
