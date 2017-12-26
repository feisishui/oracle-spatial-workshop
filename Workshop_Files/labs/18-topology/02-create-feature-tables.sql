-- --------------------------------------------------------------------------
-- 2) Create base feature tables
-- --------------------------------------------------------------------------

--
-- Create feature table for US_COUNTIES
--

DROP TABLE US_COUNTIES_TOPO;
CREATE TABLE US_COUNTIES_TOPO (
  ID         NUMBER PRIMARY KEY,
  COUNTY     VARCHAR2(31),
  FIPSSTCO   VARCHAR2(5),
  STATE      VARCHAR2(30),
  STATE_ABRV VARCHAR2(2),
  FIPSST     VARCHAR2(2),
  LANDSQMI   NUMBER,
  TOTPOP     NUMBER,
  POPPSQMI   NUMBER,
  FEATURE    SDO_TOPO_GEOMETRY
);

--
-- Register the feature layer with the topology
--

BEGIN
  SDO_TOPO.ADD_TOPO_GEOMETRY_LAYER(
    'US_LAND_USE',
    'US_COUNTIES_TOPO',
    'FEATURE',
    'POLYGON');
END;
/

-- The first time this function is called for a topology, it creates table RELATION$
-- Table RELATION has a primary key (TG_LAYER_ID, TG_ID, TOPO_ID, TOPO_TYPE) and a secondary index on (TOPO_ID, TOPO_TYPE)
-- This is a partitionned table (one partition per feature table)

-- Creates a spatial (topology) index on the SDO_TOPO_GEOMETRY column (called <topology_name>_<layer_id>_IDX)
-- Index table is MDTP_<code>$.
-- Index is defined in USER_SDO_INDEX_INFO as type T

--
-- Create feature table for US_CITIES
--

DROP TABLE US_CITIES_TOPO;
CREATE TABLE US_CITIES_TOPO (
  ID         NUMBER PRIMARY KEY,
  CITY       VARCHAR2(42),
  STATE_ABRV VARCHAR2(2),
  POP90      NUMBER,
  RANK90     NUMBER,
  FEATURE    SDO_TOPO_GEOMETRY
);

--
-- Register the feature layer with the topology
--

BEGIN
  SDO_TOPO.ADD_TOPO_GEOMETRY_LAYER(
    'US_LAND_USE',
    'US_CITIES_TOPO',
    'FEATURE',
    'POINT');
END;
/

--
-- Create feature table for US_INTERSTATES
--

DROP TABLE US_INTERSTATES_TOPO;
CREATE TABLE US_INTERSTATES_TOPO (
  ID         NUMBER PRIMARY KEY,
  INTERSTATE VARCHAR2(35),
  FEATURE    SDO_TOPO_GEOMETRY
);

--
-- Register the feature layer with the topology
--

BEGIN
  SDO_TOPO.ADD_TOPO_GEOMETRY_LAYER(
    'US_LAND_USE',
    'US_INTERSTATES_TOPO',
    'FEATURE',
    'LINE');
END;
/

