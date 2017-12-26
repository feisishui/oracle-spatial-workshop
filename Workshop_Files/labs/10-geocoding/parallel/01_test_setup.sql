-- Create an address table and fill it with some 10000 addresses (US POIs)
-- Note that some 5000 POIs are in municipalities absent from the address data set. We
-- ignore those
drop table addresses purge;
create table addresses (
  id            number primary key,
  line_1        varchar2(80),
  line_2        varchar2(80),
  country_code  char(2),
  longitude     number,
  latitude      number
);

insert into addresses
select rownum, 
       house_number||' '||street_name, 
       settlement_name||', '||region_name||' '||postal_code,
       country_code_2,
       loc_long, 
       loc_lat
from gc_poi_us
where settlement_id in (
  select settlement_id from gc_road_us where settlement_id is not null
);
commit;

-- Create the table to receive the results
drop table gc_results purge;
create table gc_results (
  id            number primary key,
  gc_result     sdo_geo_addr,
  accuracy      number
);
