****************************************************************

  lasclip:

  takes as input a LAS/LAZ/TXT file and a SHP/TXT file with one
  or many polygons (e.g. building footprints), clips away all the
  points that fall outside all polygons (or inside some polygons),
  and stores the surviving points to the output LAS/LAZ/TXT file.

  Instead of clipping the points they can also be classified.

  The input SHP/TXT file *must* contain clean polygons or polylines
  that are free of self-intersections, duplicate points, and/or
  overlaps and they must all form closed loops (e.g. last point
  and first point are identical).

  There is an example SHP file called "TO_city_hall.shp" that
  can be used together with the TO_core_last_zoom.las or the
  TO_core_last.las data set to clip away the Toronto city hall.

  Please license from martin.isenburg@gmail.com to use lasclip
  commercially.

  For updates check the website or join the LAStools mailing list.

  http://www.cs.unc.edu/~isenburg/lastools/
  http://groups.google.com/group/lastools/
  https://lidarbb.cr.usgs.gov/index.php?showtopic=11881
  http://twitter.com/lastools/
  http://facebook.com/lastools/

  Martin @lastools

****************************************************************

example usage:

>> lasclip -i *.las -poly polygon.shp -verbose

clips all the LAS files matching "*.las" against the polygon(s) in 
"polygon.shp" and stores each result to a LAS file called "*_1.las".

>> lasclip -i *.txt -iparse xyzt -poly polygon.shp -otxt -oparse xyzt

same but for ASCII input/output that gets parsed with "xyzt".

>> lasclip -i TO_core_last_zoom.laz -poly TO_city_hall.shp -o output.laz -inside -verbose

clips the points falling *inside* the polygon that describes the building
footprint of the toronto city hall from the file TO_core_last_zoom.laz
and stores the result to output.laz.

>> lasclip -i TO_core_last_zoom.laz -poly TO_city_hall.shp -o output.laz -verbose

same as above but now it clips points falling *outside* of the polygon.

>> lasclip -i TO_core_last_zoom.laz -poly TO_city_hall.shp -o output.laz -classify 6 -inside -verbose

classifies the points falling *inside* the polygon as "Building".

>> lasclip -i city.las -poly buildings.txt -inside -o city_without_buildings.las

clips the points from the inside of the buildings footprints specified
in 'buildings.txt' out of the LAS file 'city.las' and stores the other
points to 'city_without_buildings.las'. The text file should have the
following format:

757600 3.6927e+006
757432 3.69264e+006
757400 3.69271e+006
757541 3.69272e+006
757600 3.6927e+006
#
757800 3.6917e+006
757632 3.69164e+006
757600 3.69171e+006
757741 3.69172e+006
757800 3.6917e+006
[...]


for more info:

C:\lastools\bin>lasclip -h
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
Supported LAS Outputs
  -o lidar.las
  -o lidar.laz
  -o xyzta.txt -oparse xyzta (on-the-fly to ASCII)
  -olas -olaz -otxt (specify format)
  -stdout (pipe to stdout)
  -nil    (pipe to NULL)
LAStools (by martin.isenburg@gmail.com) version 110521 (unlicensed)
usage:
lasclip -i *.las -poly polygon.shp -verbose
lasclip -i *.txt -iparse xyzt -poly polygon.shp -otxt -oparse xyzt
lasclip -i lidar.las -poly footprint.shp -o lidar_clipped.laz -verbose
lasclip -i lidar.laz -poly buildings.shp -o lidar_clipped.laz -inside -verbose
lasclip -i lidar.laz -poly swath.shp -o lidar_overlap.laz -classify 12 -verbose
lasclip -h

---------------

if you find bugs let me (martin.isenburg@gmail.com) know.
