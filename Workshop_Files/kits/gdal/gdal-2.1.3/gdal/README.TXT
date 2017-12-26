1. Folder content

  bin - binary executables
  lib - libraries
  data - spatial reference data files
  gdal_linux.x64.zip - zip package for Linux x64
  gdal_windows.x64.zip - zip package for Windows x64 
  setup_gdal.conf - setup script
  LICENSE.TXT - GDAL license
  README.TXT - this file

2. Requirements

  Oracle OCI shared libraries.

    That could be found on Oracle server or Instant Client installation.

3. Setting up GDAL

  The script 'setup_gdal.conf' will prepare the environment variables
  for the use of GDAL tools on the current user's command line session.

  Execute the command:

    source setup_gdal.conf

  Test if GDAL is working properly:

    gdalinfo --version
    gdalinfo --format georaster

  In case of errors verify if all requirements are met. See examples
  on 'setup_gdal.conf'.

4. Installing GDAL on a different machine

  Copy the ZIP package according to the target machine operating system.

  On the target machine, expand the ZIP package and follow the 
  instruction on README.TXT.

  For other operating system, follow the instruction on how to 
  download and compile the GDAL source code at GDAL website. 

5. GDAL documentation

  More information on GDAL at www.gdal.org.

