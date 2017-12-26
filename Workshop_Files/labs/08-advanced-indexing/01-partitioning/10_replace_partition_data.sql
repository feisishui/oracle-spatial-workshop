-- Partition exchange scenario 2: replace data in a partition

-- Get new restaurants
DROP TABLE restaurants;
CREATE TABLE restaurants (
  restaurant_id     NUMBER  PRIMARY KEY,
  restaurant_name   VARCHAR2(50),
  location          SDO_GEOMETRY
);
INSERT INTO restaurants
SELECT id+1000000, name || ' M', location
FROM yellow_pages
WHERE category = 1;
COMMIT;

-- Create a table with the same structure as the YELLOW_PAGES_PART table
DROP TABLE yellow_pages_part_tmp;
CREATE TABLE yellow_pages_part_tmp AS
  SELECT * FROM yellow_pages_part WHERE 1=0;

-- Add a primary key
alter table yellow_pages_part_tmp
  add primary key (id);

-- Load the table with new data
INSERT INTO yellow_pages_part_tmp
SELECT restaurant_id, restaurant_name, 1, location
FROM restaurants;
COMMIT;

-- Add the spatial index
delete from user_sdo_geom_metadata
  where table_name = 'YELLOW_PAGES_PART_TMP' and column_name = 'LOCATION' ;
insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
values (
  'YELLOW_PAGES_PART_TMP',
  'LOCATION',
  sdo_dim_array (
    sdo_dim_element('x', -180.0, 180.0, 0.1),
    sdo_dim_element('y', -90.0, 90.0, 0.1)
  ),
  8307
);
commit;
drop index yellow_pages_part_tmp_sidx;
create index yellow_pages_part_tmp_sidx on yellow_pages_part_tmp (location)
  indextype is mdsys.spatial_index;

-- Exchange partition
alter table yellow_pages_part
  exchange partition p1 with table yellow_pages_part_tmp;


