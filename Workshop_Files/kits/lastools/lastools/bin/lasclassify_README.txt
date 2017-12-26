****************************************************************

  lasclassify:

  This is a tool for bare-earth extraction: it classifies LIDAR
  points into ground points (class = 2) and non-ground points
  (class = 1). This tools works best in natural environments
  such as mountains, forests, fields, hills, or other terrain
  with few man-made objects.

  The tool also produces results for town or cities but buildings
  larger than the step size can be problematic. The default step
  size is 5 meters, which is good for forest or mountains. For
  towns or flat terrains '-town' the step size is increased to
  10 meters. For cities or warehouses '-city' the step size is
  increased to 25 meters. You can set the step size in meters
  directly with '-step 7'.

  It is important to tell the tool whether the horizontal and
  vertical units are meters (which is assumed by default) or
  '-feet' or '-elevation_feet'. Should the LAS file contain
  projection information then there is no need to specify this
  explicitly.

  By default the tool only considers the last return. Earlier
  returns are considered non-ground. You can turn this off by
  requesting '-all_returns'.

  For very steep hills you can intensify the search for initial
  ground points with '-fine' or '-extra_fine' and similarly for
  flat terrains you can simplify the search with '-coarse' or
  '-extra_coarse' but try the default setting first. 

  The experienced user can fine-tune the algorithm by specifing
  the threshold at which spikes get removed '-spike 0.5', the
  maximal standard deviation for planar patches in centimeter
  '-stddev 10', and the maximal offset up to which points above
  the current ground estimate get included '-offset 0.1'.

  Please license from martin.isenburg@gmail.com to use lasclassify
  commercially. Please note that the unlicensed version will set
  intensity, gps_time, user data, and point source ID to zero,
  slightly change the LAS point order, and randomly add a tiny
  bit of white noise to the points coordinates. This is only the
  case for lasclassify. All other LAStools are full versions.

  For updates check the website or join the LAStools mailing list.

  http://www.cs.unc.edu/~isenburg/lastools/
  http://groups.google.com/group/lastools/
  https://lidarbb.cr.usgs.gov/index.php?showtopic=14179
  http://twitter.com/lastools/
  http://facebook.com/lastools/

  Martin @lastools

****************************************************************

example usage:

>> lasclassify -i terrain.las -o classified_terrain.las

classifies a terrain with the default settings.

>> lasclassify -i terrain.las -o classified_terrain.las -feet -elevation_feet

classifies a terrain where both horizontal and vertical units are
in feet instead of in meters (which is assumed by default unless
there is projection information in the LAS file saying otherwise).

>> lasclassify -i terrain.las -o classified_terrain.las -all_returns

classifies a terrain considering all points - not just the last
returns (as is the default behavior).

>> lasclassify -i *.las

classifies all LAS files with the default settings.

>> lasclassify -i *.las -town

the same as above but uses wider spacing to allow for small
buildings and other man-made structures.

>> lasclassify -i *.las -city

the same as above but uses even wider spacing to allow for
very large buildings.

for more info:

C:\lastools\bin>lasclassify -h

Please license from 'martin.isenburg@gmail.com' to use LAStools commercially.
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
  -keep_single -drop_single
  -keep_double -drop_double
  -keep_triple -drop_triple
  -keep_quadruple -drop_quadruple
  -keep_quintuple -drop_quintuple
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
  -clamp_z_min 70.5
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
Supported LAS Outputs
  -o lidar.las
  -o lidar.laz
  -o xyzta.txt -oparse xyzta (on-the-fly to ASCII)
  -olas -olaz -otxt (specify format)
  -stdout (pipe to stdout)
  -nil    (pipe to NULL)
LAStools (by martin.isenburg@gmail.com) version 110815 (unlicensed)
usage:
lasclassify -i in.las -o out.las
lasclassify -i in.las -o out.las -foot -elevation_foot
lasclassify -i in.las -o out.las -town
lasclassify -i in.las -o out.las -city
lasclassify -i in.las -o out.las -verbose -step 10 -spike 2 -offset 0.1
lasclassify -i *.las -verbose
lasclassify -i *.laz -verbose -city
lasclassify -h

---------------

if you find bugs let me (martin.isenburg@gmail.com) know.
