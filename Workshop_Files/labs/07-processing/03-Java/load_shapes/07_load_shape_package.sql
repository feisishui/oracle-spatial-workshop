-- Only specify the name of the input file, projection and destination table
-- All other parameters are set to default values specified in the package
set serveroutput on
call dbms_java.set_output (10000000);
begin
  shape_files.load (
    shpfilename     => 'D:\Courses\Spatial11g-Workshop\data\04-loading\shape\world_countries',
    srid            => 8307,
    tablename       => 'WORLD_COUNTRIES',
    idcolumn        => 'ID',
    verbose         => 1
  );
end;
/