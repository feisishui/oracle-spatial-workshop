-- Show output
set serveroutput on
call dbms_java.set_output(1000000);

-- Must use all parameters
begin
  loadshapefile(
    shpfilename     => 'D:\Courses\Spatial11g-Workshop\data\04-loading\shape\world_countries',
    srid            => 8307,
    tablename       => 'WORLD_COUNTRIES',
    geocolumn       => 'GEOMETRY',
    idcolumn        => 'ID',
    createtable     => 1,
    commitfrequency => 100,
    fastpickle      => 1,
    verbose         => 0
  );
end;
/