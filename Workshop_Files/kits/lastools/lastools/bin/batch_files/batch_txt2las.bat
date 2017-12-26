ECHO OFF
ECHO usage:
ECHO   either run "batch_txt2las.bat" and enter arguments when
ECHO   prompted or provide them as follows in the command line:
ECHO   "wild_card", "parse_string", and optional "skip_lines".
ECHO   here are some examples:
ECHO   C:\bin) batch_txt2las.bat data\*.las xyzt
ECHO   C:\bin) batch_txt2las.bat data\test00?.las sxyzia 3
ECHO   C:\bin) batch_txt2las.bat data\path\*.laz tsxyzrn
ECHO   C:\bin) batch_txt2las.bat data\flight\flight00*.laz xyzi
IF "%1%" == "" GOTO GET_ALL
IF "%2%" == "" GOTO GET_PARSE_STRING
IF "%3%" == "" GOTO ACTION
IF "%4%" == "" GOTO ACTION_WITH_SKIP
:GET_ALL
SET /P F=input file (or wild card):
SET /P V=parse string:
FOR %%D in (%F%) DO START /wait txt2las -parse %V% -i %%D
FOR %%D in (%F%) DO ECHO txt2las -parse %V% -i %%D
GOTO END
:GET_PARSE_STRING
SET /P V=parse string:
FOR %%D in (%1) DO START /wait txt2las -parse %V% -i %%D
FOR %%D in (%1) DO ECHO txt2las -parse %V% -i %%D
GOTO END
:ACTION
ECHO OFF
FOR %%D in (%1) DO START /wait txt2las -parse %2 -i %%D
FOR %%D in (%1) DO ECHO txt2las -parse %2 -i %%D
GOTO END
:ACTION_WITH_SKIP
ECHO OFF
FOR %%D in (%1) DO START /wait txt2las -parse %2 -skip %3 -i %%D
FOR %%D in (%1) DO ECHO txt2las -parse %2 -skip %3 -i %%D
:END
SET /P F=done. press ENTER
