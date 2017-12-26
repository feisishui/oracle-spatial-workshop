create or replace function get_data_version (b blob)
return varchar2
is
  l number;
  n number;
  c char;
  version varchar2(256) := '';
begin
  -- The beginning of the bob looks like this:
  -- 0000000A00310032002E0031002E0030002E0032002E0030
  -- To be interpreted as
  -- 0000000A 0031 0032 002E 0031 002E 0030 002E 0032 002E 0030
  -- 0000000A = length of the version string
  -- 0031 = 1
  -- 0032 = 2
  -- 002E = .
  -- 0031 = 1
  -- 002E = .
  -- 0030 = 0
  -- 002E = .
  -- 0032 = 2
  -- 002E = .
  -- 0030 = 0
  -- The version string is '12.1.0.2.0'
  
  -- Extract string length
  l := utl_raw.cast_to_binary_integer(dbms_lob.substr(b,4,1));
  
  -- Extract the characters
  for i in 0..l-1 loop
    n := utl_raw.cast_to_binary_integer(dbms_lob.substr(b,2,i*2+5));
    c := chr(n);
    version := version || c;
  end loop;

  return version;
end;
/
show errors