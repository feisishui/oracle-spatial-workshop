Rem
Rem $Header: native_compile.sql 20-oct-2005.21:01:15 ningan Exp $
Rem
Rem native_compile.sql
Rem
Rem Copyright (c) 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      native_compile.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ningan      10/20/05 - add comment
Rem    ningan      10/13/05 - ningan_native_compile
Rem    ningan      10/12/05 - Created
Rem

-------------------------------------------------------------------------------
-- You can use "Natively Compiled Code" method offered by Oracle to speed up
-- the NDM PL/SQL wrapper performance.  The following script illustrates the 
-- steps to do so.  For more information about "Natively Compiled Code" method,
-- please see Section 10.1 Natively Compiled Code in Oracle Database Java
-- Developer's Guild 10g Release 1.
-------------------------------------------------------------------------------

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100


-------------------------------------------------------------------------------
-- Here we assume you can log in as mdsys and its password is mdsys
-------------------------------------------------------------------------------

-- 1. Grant mdsys the following role and security permissions
SQL>GRANT JAVA_DEPLOY TO MDSYS;
SQL>GRANT JAVASYSPRIV TO MDSYS;

-- 2. Compile Deployable Accelerating JAR file
$cd $ORACLE_HOME/md/jlib
$mkdir tmp
$ncomp -user mdsys/mdsys -d $ORACLE_HOME/md/jlib/tmp -noDeploy -force sdonm.jar
-- you will see sdonm_depl.jar under $ORACLE_HOME/md/jlib/tmp directory.


-- 3. Load Acceleating JAR file
SQL>connect mdsys/mdsys
SQL>dbms_java.loadjava('-resolve -force -synonym -schema MDSYS -grant PUBLIC md/jlib/tmp/sdonm_depl.jar');
-- upon loading JAR file successfully, executing the following SQL statement
--# select timestamp, status, dll_name  from jaccelerator$dlls order by dll_name
-- you will get result like the following one
--2005-10-20 11:53:49 installed /libjox10_1070f56f7a6_mdsys_oracle_spatial_network.so

-- 4. Switch back to the interprted execution mode
SQL>connect mdsys/mdsys
SQL>dbms_java.loadjava('-resolve -force -synonym -schema MDSYS -grant PUBLIC md/jlib/sdonm.jar');
-- you can alterate between the native compilation mode and interpreted mode by executing the above two
-- dbms_java.loadjava functioni alternatively

-- 5. If you choose, you can revoke the role and security permission
SQL>REVOKE JAVA_DEPLOY FROM MDSYS; 
SQL>REVOKE JAVASYSPRIV FROM MDSYS;







