-- ----------------------------------------------
-- Create indexes
-- ----------------------------------------------

-- OLS_DIR_BUSINESSES

CREATE INDEX OLS_DIR_BUSINESSES_1 ON OLS_DIR_BUSINESSES (
  COUNTRY,
  COUNTRY_SUBDIVISION,
  MUNICIPALITY
);

CREATE INDEX OLS_DIR_BUSINESSES_2 ON OLS_DIR_BUSINESSES (
  COUNTRY,
  POSTAL_CODE
);

CREATE INDEX OLS_DIR_BUSINESSES_3 ON OLS_DIR_BUSINESSES (
  BUSINESS_NAME
);

INSERT INTO USER_SDO_GEOM_METADATA (table_name, column_name, diminfo, srid)
VALUES (
  'OLS_DIR_BUSINESSES',
  'GEOM',
  SDO_DIM_ARRAY(
    SDO_DIM_ELEMENT('Longitude', -180, 180, 10),
    SDO_DIM_ELEMENT('Latitude',   -90,  90, 10)),
  8307
);
commit;

CREATE INDEX OLS_DIR_BUSINESSES_4 ON OLS_DIR_BUSINESSES (GEOM)
  INDEXTYPE IS MDSYS.SPATIAL_INDEX;

-- OLS_DIR_CATEGORIZATIONS

CREATE INDEX OLS_DIR_CATEGORIZATIONS_1 ON OLS_DIR_CATEGORIZATIONS (
  BUSINESS_ID
);

CREATE INDEX OLS_DIR_CATEGORIZATIONS_2 ON OLS_DIR_CATEGORIZATIONS (
  CATEGORY_ID,
  CATEGORY_TYPE_ID
);

-- OLS_DIR_SYNONYMS

CREATE INDEX OLS_DIR_SYNONYMS_1 ON OLS_DIR_SYNONYMS (
  STANDARD_NAME,
  CATEGORY
);

CREATE INDEX OLS_DIR_SYNONYMS_2 ON OLS_DIR_SYNONYMS (
  AKA,
  CATEGORY
);
