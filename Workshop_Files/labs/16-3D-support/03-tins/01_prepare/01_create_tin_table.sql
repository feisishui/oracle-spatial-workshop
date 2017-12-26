create table tins (
  id                number primary key,
  collection_ts     timestamp,
  description       clob,
  tin               sdo_tin
);
