REM Change the following to match your environment:
set ORACLE_HOME=D:\Oracle\ora111
REM   Should look like this:
REM   set ORACLE_HOME=...\app\<user>\product\11.1.0\db_1
REM   For example: C:\app\Oracle\product\11.1.0\db_1

set CLASSPATH=%ORACLE_HOME%/jdbc/lib/ojdbc5.jar;%ORACLE_HOME%/lib/xmlparserv2.jar;%ORACLE_HOME%/md/jlib/sdoapi.jar;%ORACLE_HOME%/md/jlib/sdoutl.jar;%ORACLE_HOME%/md/jlib/sdondme.jar;%ORACLE_HOME%/md/jlib/sdonm.jar

set JAVA_PARAMS=-Xms512M -Xmx512M

set EDITOR_CLASS=oracle.spatial.network.editor.NetworkEditor

%ORACLE_HOME%\jdk\bin\java %JAVA_PARAMS% -cp %CLASSPATH% %EDITOR_CLASS%
