ECHO OFF
ECHO usage:
ECHO   run "batch_zip.bat" and then enter the argument when
ECHO   prompted or provide the argument in the command line.
ECHO   here are some example runs:
ECHO   C:\bin) batch_zip.bat data\*.las
ECHO   C:\bin) batch_zip.bat data\test00?.las
ECHO   C:\bin) batch_zip.bat data\path\*.laz
ECHO   C:\bin) batch_zip.bat data\flight\flight00*.laz
IF "%1%" == "" GOTO GET_ALL
IF "%2%" == "" GOTO ACTION
:GET_ALL
SET /P F=input file (or wildcard):
FOR %%D in (%F%) DO START /wait laszip -i %%D
FOR %%D in (%F%) DO ECHO laszip -i %%D
GOTO END
:ACTION
ECHO OFF
FOR %%D in (%1) DO START /wait laszip -i %%D
FOR %%D in (%1) DO ECHO laszip -i %%D
:END
SET /P F=done. press ENTER
