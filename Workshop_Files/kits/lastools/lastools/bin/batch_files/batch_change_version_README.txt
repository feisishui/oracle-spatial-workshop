****************************************************************

  batch_change_version.bat

  run this batch script either by double click or in the command
  line to change the version of the LAS/LAZ files. the tool allows
  you to change it to *any* version number (e.g. you can change
  the file to version 2.11). you may make your file unreadable
  if you change it to the wrong version. under the hood the batch
  script uses lasinfo.exe.

  created on February 2nd, 2009 for airborne1.com but was never
  paid for my efforts. careful with these guys.

  (c) copyright 2009, martin.isenburg@gmail.com

****************************************************************

example usage:

>> batch_change_version.bat data\test000.las 1.1

changes the version of file 'data\test000.las' to 1.1

>> batch_change_version.bat data\*.las 1.5

changes the version of all '*.las' files in directory 'data' to 1.5

>> batch_change_version.bat data\flight\flight*.las 1.1

changes the version of all 'flight*.las' files in directory 'data\flight' to 1.1

>> batch_change_version.bat 
>> input file (or wildcard): data\*.las
>> version: 1.1

changes the version of all '*.las' files in directory 'data' to 1.1

----

if you find bugs let me (martin.isenburg@gmail.com) know.