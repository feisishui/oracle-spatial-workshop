#!/usr/bin/python
import cx_Oracle
print "cx_Oracle version : "+cx_Oracle.version
con = cx_Oracle.connect('scott/tiger@localhost:1521/orcl122')
print con.version
con.close()
