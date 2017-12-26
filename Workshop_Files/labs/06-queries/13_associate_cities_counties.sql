alter table us_cities add county_id number;

-- Option 1: Using a loop on counties (Elapsed: 00:00:09.90 - with VPA: 00:00:03.71)
begin
  for co in (
    select * from us_counties
  )
  loop
    update us_cities ci
    set    county_id = co.id
    where  sdo_anyinteract (ci.location, co.geom) = 'TRUE';
  end loop;
end;
/

-- Option 2: Using a straight update (Elapsed: 00:00:01.42 - with VPA: 00:00:00.59)
update us_cities ci
set    county_id = (
  select id
  from us_counties co
  where sdo_anyinteract (co.geom, ci.location ) = 'TRUE'
);

-- Option 3: Using a spatial join (Elapsed: 00:00:00.21 - with VPA: same)
begin
  for j in (
    select *
    from table (
           sdo_join (
             'US_CITIES', 'LOCATION',
              'US_COUNTIES', 'GEOM',
              'MASK=ANYINTERACT'
           )
         )
  )
  loop
    update us_cities ci
    set    county_id = (
      select id
      from us_counties co
      where co.rowid = j.rowid2
    )
    where ci.rowid = j.rowid1;
  end loop;
end;
/
