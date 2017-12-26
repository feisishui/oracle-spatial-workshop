Rem
Rem $Header: sdo/demo/network/examples/data/util/daee/demo.sql /main/1 2012/03/08 05:58:44 begeorge Exp $
Rem
Rem demo.sql
Rem
Rem Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      demo.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    begeorge    03/07/12 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

-- Grant read access to the node and link tables to the ndmdemo user.
-- Login as daee
grant select on DAEE_NODE$ to ndmdemo;
grant select on DAEE_LINK$ to ndmdemo;
commit;

