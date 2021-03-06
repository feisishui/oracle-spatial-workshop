CREATE TABLE OLS_DIR_BUSINESS_CHAINS (
  CHAIN_ID                    NUMBER          PRIMARY KEY,
  CHAIN_NAME                  VARCHAR2(128)
);

CREATE TABLE OLS_DIR_BUSINESSES (
  BUSINESS_ID                 NUMBER          PRIMARY KEY,
  BUSINESS_NAME               VARCHAR2(128)   NOT NULL,
  CHAIN_ID                    NUMBER,
  DESCRIPTION                 VARCHAR2(1024),
  PHONE                       VARCHAR2(64),
  COUNTRY                     VARCHAR2(64)    NOT NULL,
  COUNTRY_SUBDIVISION         VARCHAR2(128),
  COUNTRY_SECONDARY_SUBDIV    VARCHAR2(128),
  MUNICIPALITY                VARCHAR2(128),
  MUNICIPALITY_SUBDIVISION    VARCHAR2(128),
  POSTAL_CODE                 VARCHAR2(32)    NOT NULL,
  POSTAL_CODE_EXT             VARCHAR2(32),
  STREET                      VARCHAR2(128)   NOT NULL,
  INTERSECTING_STREET         VARCHAR2(128),
  BUILDING                    VARCHAR2(64),
  PARAMETERS                  XMLTYPE,
  GEOM                        SDO_GEOMETRY,
  CONSTRAINT OLSFK3 FOREIGN KEY (CHAIN_ID)
    REFERENCES OLS_DIR_BUSINESS_CHAINS(CHAIN_ID)
);

CREATE TABLE OLS_DIR_CATEGORY_TYPES (
  CATEGORY_TYPE_ID            NUMBER          PRIMARY KEY,
  CATEGORY_TYPE_NAME          VARCHAR2(128)   NOT NULL,
  PARAMETERS                  XMLTYPE
);
INSERT INTO OLS_DIR_CATEGORY_TYPES (CATEGORY_TYPE_ID, CATEGORY_TYPE_NAME)
  VALUES (1, 'SIC');
INSERT INTO OLS_DIR_CATEGORY_TYPES (CATEGORY_TYPE_ID, CATEGORY_TYPE_NAME)
  VALUES ( 2, 'NAICS');
COMMIT;

CREATE TABLE OLS_DIR_CATEGORIES (
  CATEGORY_ID                 VARCHAR2(32)    NOT NULL,
  CATEGORY_TYPE_ID            NUMBER          NOT NULL,
  CATEGORY_NAME               VARCHAR2(128)   NOT NULL,
  PARENT_ID                   VARCHAR2(32),
  PARAMETERS                  XMLTYPE,
  PRIMARY KEY (CATEGORY_ID, CATEGORY_TYPE_ID),
  CONSTRAINT olsfk1 FOREIGN KEY (PARENT_ID, CATEGORY_TYPE_ID)
    REFERENCES OLS_DIR_CATEGORIES (CATEGORY_ID, CATEGORY_TYPE_ID),
  CONSTRAINT olsfk2 FOREIGN KEY (CATEGORY_TYPE_ID)
    REFERENCES OLS_DIR_CATEGORY_TYPES (CATEGORY_TYPE_ID)
);

CREATE TABLE OLS_DIR_CATEGORIZATIONS (
  BUSINESS_ID                 NUMBER,
  CATEGORY_ID                 VARCHAR2(32),
  CATEGORY_TYPE_ID            NUMBER,
  CATEGORIZATION_TYPE         VARCHAR2(8) DEFAULT 'EXPLICIT',
  USER_SPECIFIC_CATEG         VARCHAR2(32) DEFAULT NULL,
  PARAMETERS                  XMLTYPE,
  CONSTRAINT OLSPK1 PRIMARY KEY(BUSINESS_ID, CATEGORY_ID, CATEGORY_TYPE_ID) USING INDEX,
  CONSTRAINT OLSCAT_TYPE_CONSTR CHECK(CATEGORIZATION_TYPE IN ('EXPLICIT', 'IMPLICIT')),
  CONSTRAINT OLSFK4 FOREIGN KEY (BUSINESS_ID) REFERENCES OLS_DIR_BUSINESSES(BUSINESS_ID),
  CONSTRAINT OLSFK5 FOREIGN KEY (CATEGORY_ID, CATEGORY_TYPE_ID) REFERENCES
    OLS_DIR_CATEGORIES(CATEGORY_ID, CATEGORY_TYPE_ID));

CREATE TABLE OLS_DIR_SYNONYMS (
  STANDARD_NAME               VARCHAR2(128),
  CATEGORY                    VARCHAR2(128),
  AKA                         VARCHAR2(128));
