ECHO OFF
ECHO usage:
ECHO   run "batch_fix_las_files.bat" and then enter the
ECHO   argument when prompted or provide the argument
ECHO   in the command line. here are some example runs:
ECHO   C:\bin) batch_fix_las_files.bat *.las
ECHO   C:\bin) batch_fix_las_files.bat tiles*1.las
ECHO   C:\bin) batch_fix_las_files.bat test000*.las
ECHO   C:\bin) batch_fix_las_files.bat flight*.las
ECHO   the results will be in a subdirectory called
ECHO   fixed with the same name
IF "%1%" == "" GOTO GET_ALL
IF "%2%" == "" GOTO ACTION
IF "%3%" == "" GOTO ERROR
IF "%4%" == "" GOTO ERROR
IF "%5%" == "" GOTO ERROR
:GET_ALL
SET /P F=input file (or wildcard):
IF NOT EXIST fixed mkdir fixed
FOR %%D in (%F%) DO START /wait lasfix -i %%D -o fixed\%%D
FOR %%D in (%F%) DO ECHO lasfix -i %%D -o fixed\%%D
GOTO END
:ACTION
ECHO OFF
IF NOT EXIST fixed mkdir fixed
FOR %%D in (%1) DO START /wait lasfix -i %%D -o fixed\%%D
FOR %%D in (%1) DO ECHO lasfix -i %%D -o fixed\%%D
GOTO END
:ERROR
ECHO ERROR: wrong usage
GOTO END
:END
SET /P F=done. press ENTER
