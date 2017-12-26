create table lidar_scenes(
  id                number primary key,
  collection_ts     timestamp,
  description       clob,
  header            blob,
  point_cloud       sdo_pc
);
