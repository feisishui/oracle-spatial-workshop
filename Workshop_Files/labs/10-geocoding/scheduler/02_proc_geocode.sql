create or replace procedure geocode (
  start_id number,
  end_id number
)
is
begin
  dbms_output.put_line('Geocoding addresses from '||start_id||' to '||end_id);
  update addresses 
  set gc_result = 
    sdo_gcdr.geocode (
      user, 
      sdo_keywordarray(line_1, line_2), 
      country_code, 
      'default'
    )
  where id between start_id and end_id;
  commit;
end;
/
show errors
