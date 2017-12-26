-- Partition exchange scenario 1: rebuild spatial index with minimal impact

-- Copy all category 6 POIs into a separate table.
DROP TABLE yellow_pages_part_tmp;
CREATE TABLE yellow_pages_part_tmp AS
  SELECT * FROM yellow_pages_part PARTITION (p6);

-- Add a primary key
ALTER TABLE yellow_pages_part_tmp
  ADD PRIMARY KEY (id);

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
ALTER TABLE yellow_pages_part
  EXCHANGE PARTITION p6 WITH TABLE yellow_pages_part_tmp;

