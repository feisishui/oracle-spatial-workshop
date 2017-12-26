LAStools for converting, filtering, viewing, processing, and compressing LIDAR

latest updates:    http://www.cs.unc.edu/~isenburg/lastools/
LAStools group:    http://groups.google.com/group/lastools/
general LAS forum: https://lidarbb.cr.usgs.gov/index.php?showforum=29
twitter feed:      http://twitter.com/lastools/

* lastool.exe provides a simple GUI for LAStools

* laszip.exe compresses the LAS files in a completely lossless manner
* lasinfo.exe prints out a quick overview of the contents of a LAS file
* lasindex.exe creates a spatial index LAX file for fast spatial queries
* txt2las.exe converts LIDAR data from ASCII text to binary LAS format
* las2txt.exe turns LAS into human-readable and easy-to-parse ASCII text
* lasmerge.exe merges several LAS files into one
* lasgrid.exe rasters very large LAS files into elevation or intensity grids
* lastile.exe tiles huge amounts of LAS points into square tiles
* lassort.exe sorts points into spatial proximity via a space filling curve
* lasclip.exe clips LAS points against building footprints / swath boundaries
* las2las.exe extracts last returns, clips, subsamples, translates, etc ...
* lasboundary.exe extracts a boundary polygon that encloses the points
* lasduplicate.exe removes duplicate points (with identical x and y) 
* lasheight.exe computes for each point its height above TIN of ground points
* lasthin.exe thins lowest / highest / random LAS points via a grid
* las2tin.exe triangulates the points of a LAS file into a TIN
* las2dem.exe rasters a temporary TIN with hillshade/elevation/intensity
* las2iso.exe extracts, optionally simplified, elevation contours
* lasview.exe visualizes a LAS file with a simple OpenGL viewer
* lasprecision.exe analyses the actual precision of the LIDAR points
* las2shp.exe turns binary LAS into ESRI's Shapefile format
* shp2las.exe turns an ESRI's Shapefile into binary LAS

For Windows all binaries are included. They can also be compiled from
the sources. You can find the MSVC6.0 project files there as well. For
Linux the makefiles and many sources are included. Simply go into the
root directory and run 'make':

unzip lastools.zip
cd lastools/
make

The compiled binary executables are or will be in the bin directory.

---

Please read the "LICENSE.txt" file for information on commerical use
and licensing of LAStools. I would really like it if you would send me
an email and tell me what you use LAStools for. 

(c) 2007-2011 martin.isenburg@gmail.com @lastools
