DROP TABLE us_cities_ext;
CREATE TABLE us_cities_ext (
  id              NUMBER,
  city            VARCHAR2(42),
  state_abrv      VARCHAR2(2),
  pop90           NUMBER,
  rank90          NUMBER,
  wkt             CLOB
)
ORGANIZATION EXTERNAL (
  TYPE ORACLE_LOADER
  DEFAULT DIRECTORY data_files
  ACCESS PARAMETERS (
    FIELDS TERMINATED BY "|" (
      id,
      city,
      state_abrv,
      pop90,
      rank90,
      wkt
    )
  )
  LOCATION ('us_cities.dat')
);
