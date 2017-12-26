create user scott identified by tiger
  default tablespace users
  temporary tablespace temp;
grant resource, connect to scott;
grant create view, alter session to scott;
