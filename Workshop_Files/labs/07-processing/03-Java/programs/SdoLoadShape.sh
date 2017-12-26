@echo off
REM Change the following to match your environment:
set ORACLE_HOME=D:\oracle\ora1123
REM   Should look like this:
REM   set ORACLE_HOME=...\app\<user>\product\11.2.0\db_1
REM   For example: C:\app\Oracle\product\11.2.0\db_1
set DB_SERVER=127.0.0.1
set DB_PORT=1521
set DB_SID=orcl112
set DB_USER=scott
set DB_PASS=tiger

set SHAPE_FILES="..\..\..\..\data\04-loading\shape"

set JAVA=%ORACLE_HOME%\jdk\bin\java
set CLASSPATH=.;%ORACLE_HOME%/jdbc/lib/ojdbc5.jar;%ORACLE_HOME%/md/jlib/sdoutl.jar;%ORACLE_HOME%/md/jlib/sdoapi.jar;%ORACLE_HOME%/jlib/orai18n.jar
set LOADER_CLASS=SdoLoadShape

echo Loading shape files from %SHAPE_FILES%

for /r %SHAPE_FILES% %%g in (*.shp) do (
  echo Loading file: %%~nxg into table %%~ng
  %JAVA% -cp %CLASSPATH% %LOADER_CLASS% jdbc:oracle:thin:@%DB_SERVER%:%DB_PORT%:%DB_SID% %DB_USER% %DB_PASS%  %%~ng geometry id %%~dpng 8307 1 0 0 1
)
pause

