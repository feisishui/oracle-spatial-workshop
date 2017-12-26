/*
  Each row in the table corresponds to one input file and contains the following:
  
  Unique identifier
  Full path and name of the input file
  Full path and name of the input file
  Type of vector file (derived from the file type)
  Name of vector table
  Timestamp when the load started
  Size (in bytes) of the input file
  Status of the file, as one of: new (not loaded yet), loaded, or failed
  Duration of the load (in seconds)
  Full standard output
  Full error output
*/

create table vector_catalog (
  id              number generated always as identity primary key,
  file_path       varchar2(256),
  file_name       varchar2(80),
  file_type       varchar2(10),
  file_size       number,
  status          char(1) check (status in ('N','L','F')) not null,
  table_name      varchar2(30),
  vector_table    varchar2(30),
  load_timestamp  timestamp,
  load_duration   number,
  load_output     clob,
  load_error      clob,
  unique (file_path,file_name)
);
