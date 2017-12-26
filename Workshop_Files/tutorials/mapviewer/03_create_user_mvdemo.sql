-- Run as SYSTEM or SYS
create user mvdemo identified by mvdemo;
grant resource, connect, create view, unlimited tablespace to mvdemo;
grant read,write on directory data_pump_dir to mvdemo;
