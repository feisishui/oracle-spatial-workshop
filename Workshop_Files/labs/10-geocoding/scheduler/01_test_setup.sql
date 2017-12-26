-- Create an address table and fill it with some 15000 addresses (US POIs)
drop table addresses purge;
create table addresses (
  id            number primary key,
  line_1        varchar2(80),
  line_2        varchar2(80),
  country_code  char(2),
  longitude     number,
  latitude      number,
  gc_result     sdo_geo_addr,
  accuracy      number
);

insert into addresses (id, line_1, line_2, country_code, longitude, latitude)
select rownum, 
       house_number||' '||street_name, 
       settlement_name||' '||region_name||' '||postal_code,
       country_code_2,
       loc_long, 
       loc_lat
from gc_poi_us;

commit;
