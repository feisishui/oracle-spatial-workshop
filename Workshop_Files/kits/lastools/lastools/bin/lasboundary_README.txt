****************************************************************

  lasboundary:

  reads LIDAR from LAS/LAZ/ASCII format and computes a boundary
  polygon for the points. By default this is a *concave* hull
  of the points. For this it Delaunay triangulates the points
  into a TIN, deletes triangles with large edges from the
  boundary, and outputs the resulting boundary polygon (always
  a single polygon).

  Optionally a *disjoint hull* is computed with the -disjoint
  flag. This can lead to multiple hulls in case of islands.
  Islands the size of one or two LIDAR points are too small to
  form a triangle and are "lost".

  The tool can also compute *interior* holes in the data via
  the -holes flag. It not only finds holes but also islands in
  the holes.

  The controlling value is the "concavity" that can be specified
  in the command line. The default is 50, meaning that triangles
  with edges longer than 50 units are considered part of the
  exterior or part of an interior hole.

  It can directly output in KML format for easy viewing in GE.
  In case there is no projection information in the LAS file it
  can be specified in the command line.
                 
  Please license from martin.isenburg@gmail.com to use lasboundary
  commercially.

  For updates check the website or join the LAStools mailing list.

  http://www.cs.unc.edu/~isenburg/lastools/
  http://groups.google.com/group/lastools/
  https://lidarbb.cr.usgs.gov/index.php?showtopic=7799
  http://twitter.com/lastools/
  http://facebook.com/lastools/

  Martin @lastools

****************************************************************

example usage:

>> las2boundary -i *.las -oshp

computes the boundaries of all LAS file '*.las' and stores
the result to ESRI's Shapefiles '*.shp'.

>> las2boundary -i lidar1.las lidar2.las -merged -o lidar_boundary.shp

computes the boundary of the LAS file created from merging 'lidar1.las'
and 'lidar2.las' and stores the result to 'lidar_boundary.shp'.

>> las2boundary -i lidar1.las lidar2.las -otxt

the same but without merging and storing the results to ASCII files.

>> las2boundary -i lidar1.las lidar2.las -oshp -concavity 100

the same but with creating less detailed concavities. the default
value for concavities is 50 (meaning edges along the convex hull
that are shorter than 50 units get "pushed" inwards)

>> las2boundary -i lidar.las -o lidar_boundary.kml -utm 10T -disjoint

computes a disjoint hull instead of a concave hull and uses a utm
projeciton 10T to store the boundary in geo-referenced KML format

>> las2boundary -i lidar.las -o lidar_holes.kml -disjoint -holes

same as before but assumes geo-referencing is in the KML file. it
also computes holes in the interior of the boundary.

C:\lastools\bin>lasboundary -h
usage:
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
Supported Line Outputs
  -o lines.shp
  -o boundary.wkt
  -o contours.kml
  -o output.txt
  -oshp -owkt -okml -otxt
  -stdout (pipe to stdout)
Optional Settings
  -only_2d
  -kml_absolute
  -kml_elevation_offset 17.5
usage:
lasboundary -i *.las -oshp
lasboundary -i *.laz -owkt -concave 100 (default is 50)
lasboundary -i flight???.las -oshp -disjoint
lasboundary -i USACE_Merrick_lots_of_VLRs.las -o USACE.kml
lasboundary -i Serpent.las -o boundary.kml -disjoint -holes
lasboundary -i *.las -okml -disjoint -utm 17S
lasboundary -i lidar.las -o boundary.kml -latlon -concave 0.00002
lasboundary -i lidar.las -o boundary.kml -lonlat -concave 0.00005
lasboundary -i *.las -otxt -first_only
lasboundary -i lidar.las -keep_class 2 3 9 -o boundary.shp
lasboundary -h

other possible transformations for KML generation:
-sp83 IA_N
-sp27 IA_S

---------------

if you find bugs let me (martin.isenburg@gmail.com) know.
