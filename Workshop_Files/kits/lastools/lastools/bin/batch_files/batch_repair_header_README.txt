****************************************************************

  batch_repair_header.bat

  run this batch script either by double click or in the command
  line to change the version of the LAS/LAZ files. this tool will
  repair the header of all LAS files by setting the bounding box
  to the actual extend and by correcting other missing or wrong
  entries in the header, namely the point count, the histogram of
  returns, and the bounding box. under the hood the batch script
  uses lasinfo.exe.

  created on March 13th, 2009 for geomatics-group.co.uk
  
  (c) copyright 2009, martin.isenburg@gmail.com
  
****************************************************************

example usage:

>> batch_repair_header.bat data\test000.las

repairs the header of file 'data\test000.las'

>> batch_repair_header.bat data\*.las

repairs the header  of all '*.las' files in directory 'data'

>> batch_repair_header.bat data\flight\flight*.las

repairs the header of all 'flight*.las' files in directory 'data\flight'

>> batch_repair_header.bat 
>> input file (or wildcard): data\*.las

repairs the header of all '*.las' files in directory 'data'

----

if you find bugs let me (martin.isenburg@gmail.com) know.