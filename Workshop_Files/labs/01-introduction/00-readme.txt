==========================================================
Introduction
==========================================================

No exercises for this lesson

NOTES:

1) All lab exercises are set to use the SCOTT account by default.

If the SCOTT account is locked, unlock it first:

SQL> connect system ...
SQL> alter user scott account unlock;
SQL> alter user scott identified by tiger;

2) Several lab exercises need a Java JDK 1.5 or later.

You can use the JDK provided with the Oracle installation in
$ORACLE_HOME/jdk/bin.

To use this JDK by default, include this reference in your path:
%ORACLE_HOME%\jdk\bin or $ORACLE_HOME/jdk/bin.

3) Use 99-CLEANUP-USER-SCOTT.SQL to remove all tables and other
objects created during the labs.
