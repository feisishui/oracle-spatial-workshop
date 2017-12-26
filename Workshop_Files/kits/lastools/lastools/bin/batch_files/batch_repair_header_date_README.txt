****************************************************************

  batch_repair_header_date.bat

  run this batch script either by double click or in the command
  line to change the version of the LAS files. this tool will
  repair the header of all LAS files by correcting missing or
  wrong entries in the header and by setting the creation date
  to the file creation date. under the hood the batch script
  uses lasinfo.exe.
 
  created on July 6th, 2009 for airborne1.com but was never
  paid for my efforts. careful with these guys.

  (c) copyright 2009, martin.isenburg@gmail.com
  
****************************************************************

example usage:

>> batch_repair_header_date.bat data\test001.las

repairs the header of file 'data\test000.las'

>> batch_repair_header_date.bat data\*.las

repairs the header  of all '*.las' files in directory 'data'

>> batch_repair_header_date.bat data\flight\flight*.las

repairs the header of all 'flight*.las' files in directory 'data\flight'

>> batch_repair_header_date.bat 
>> input file (or wildcard): data\*.las

repairs the header of all '*.las' files in directory 'data'

----

if you find bugs let me (martin.isenburg@gmail.com) know.