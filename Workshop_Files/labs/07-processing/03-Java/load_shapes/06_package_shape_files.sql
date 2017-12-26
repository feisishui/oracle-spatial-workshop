create or replace package shape_files as
  procedure load (
    shpFileName       VARCHAR2,
    srid              NUMBER,
    tableName         VARCHAR2,
    geoColumn         VARCHAR2  default 'GEOMETRY',
    idColumn          VARCHAR2  default 'ID',
    createTable       NUMBER    default 1,
    commitFrequency   NUMBER    default 1000,
    fastPickle        NUMBER    default 0,
    verbose           NUMBER    default 0
  );
end;
/
show errors

create or replace package body shape_files as
  -- -----------------------------------------------------
  -- PRIVATE
  -- -----------------------------------------------------
  -- Wrapper for java loader
  procedure load_java (
    shpFileName       VARCHAR2,
    srid              NUMBER,
    tableName         VARCHAR2,
    geoColumn         VARCHAR2,
    idColumn          VARCHAR2,
    createTable       NUMBER,
    commitFrequency   NUMBER,
    fastPickle        NUMBER,
    verbose           NUMBER
  )
   AS LANGUAGE JAVA
   NAME 'SdoLoadShape.loadShapeFile(java.lang.String, int, java.lang.String, java.lang.String, java.lang.String, int, int, int, int)';

  -- -----------------------------------------------------
  -- PUBLIC
  -- -----------------------------------------------------
  procedure load (
    shpFileName       VARCHAR2,
    srid              NUMBER,
    tableName         VARCHAR2,
    geoColumn         VARCHAR2  default 'GEOMETRY',
    idColumn          VARCHAR2  default 'ID',
    createTable       NUMBER    default 1,
    commitFrequency   NUMBER    default 1000,
    fastPickle        NUMBER    default 0,
    verbose           NUMBER    default 0
  )
  as
  begin
    load_java (
      tablename       => tablename,
      geoColumn       => geoColumn,
      idColumn        => idColumn,
      shpFilename     => shpFilename,
      srid            => srid,
      createtable     => createtable,
      commitfrequency => commitfrequency,
      fastpickle      => fastpickle,
      verbose         => verbose
    );
  end;

end;
/
show errors
