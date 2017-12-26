-- Connect as WORK
-- (needs right CREATE DATABASE LINK)
create database link gcdb connect to scott identified by tiger using 'localhost:1521/orcl112';
