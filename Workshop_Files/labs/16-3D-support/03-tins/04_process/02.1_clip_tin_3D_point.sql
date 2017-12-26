-- Create a block table to hold the results of the clipping
drop table clipped_tins_blocks;
create table clipped_tins_blocks as select * from mdsys.sdo_tin_blk_table;

declare
  clip_window sdo_geometry;
begin

  -- Get the clipping window
  clip_window := sdo_geometry (3001, 32617, sdo_point_type (289814.15, 4320978.61, 170.76), null, null);

  -- Find the matching tins
  for s in (
    select tin
    from   tins s
    where  sdo_anyinteract(s.tin.tin_extent, clip_window) = 'TRUE'
  )
  loop

    -- Clip out the desired subset from the selected tin
    insert into clipped_tins_blocks
      select * from table (
        sdo_tin_pkg.clip_tin (
          INP             =>  s.tin,
          QRY             =>  clip_window,
          QRY_MIN_RES     =>  null,
          QRY_MAX_RES     =>  null
        )
      );
  end loop;

end;
/
commit;

select count(*) from clipped_tins_blocks;

--
-- Define spatial metadata for the clip
--
delete from user_sdo_geom_metadata where table_name in ('CLIPPED_TINS_BLOCKS');

insert into user_sdo_geom_metadata (
  table_name, column_name, diminfo, srid
)
values (
  'CLIPPED_TINS_BLOCKS',
  'BLK_EXTENT',
   sdo_dim_array(
     sdo_dim_element('Easting',   200000,   300000, 0.05),
     sdo_dim_element('Northing', 4300000,  4400000, 0.05)
   ),
   32617
);
commit;

--
-- create spatial index
--
drop index clipped_tins_blocks_sx;
create index clipped_tins_blocks_sx
  on clipped_tins_blocks (blk_extent)
  indextype is mdsys.spatial_index;
