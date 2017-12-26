-- Some styles exist in two copies. Remove one of them
delete from styles where name in (
  select name from styles group by name having count(*) > 1
) 
and rownum = 1;
commit;

insert into user_sdo_styles select * from styles;
insert into user_sdo_themes select * from themes;
insert into user_sdo_maps select * from basemaps;
insert into user_sdo_cached_maps select * from tilelayers;
insert into user_sdo_cached_maps select * from tiles;
commit;
