-- Create table US_ROAD_CONDITIONS,
-- with a foreign key to the US_INTERSTATES_LRS table.
-- Populate the table with road conditions along
-- each interstate.

-- Create the table
drop table us_road_conditions;
create table us_road_conditions (
  id             number primary key,
  interstate     varchar2(35)
    references us_interstates_lrs,
  from_measure   number,
  to_measure     number,
  condition      varchar2(6));

-- Populate the table
insert into us_road_conditions values ( 1, 'I25',      0, 150000, 'good');
insert into us_road_conditions values ( 2, 'I25', 150000, 170000, 'poor');
insert into us_road_conditions values ( 3, 'I25', 170000, 340000, 'fair');
insert into us_road_conditions values ( 4, 'I25', 340000, 481426, 'good');

insert into us_road_conditions values ( 5, 'I70',      0, 300000, 'good');
insert into us_road_conditions values ( 6, 'I70', 300000, 450000, 'poor');
insert into us_road_conditions values ( 7, 'I70', 450000, 650000, 'good');
insert into us_road_conditions values ( 8, 'I70', 650000, 726930, 'fair');

insert into us_road_conditions values ( 9, 'I76',      0, 120000, 'poor');
insert into us_road_conditions values (10, 'I76', 120000, 200000, 'good');
insert into us_road_conditions values (11, 'I76', 200000, 240000, 'fair');
insert into us_road_conditions values (12, 'I76', 240000, 296381, 'good');

insert into us_road_conditions values (13, 'I225',     0,   9500, 'good');
insert into us_road_conditions values (14, 'I225',  9500,  19566, 'poor');
commit;

-- Create an index on the interstate column
create index us_road_conditions_idx on us_road_conditions (interstate);
