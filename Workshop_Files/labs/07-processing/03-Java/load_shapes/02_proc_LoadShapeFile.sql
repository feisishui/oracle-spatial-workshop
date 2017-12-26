CREATE OR REPLACE PROCEDURE LoadShapeFile (
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
/
show error
