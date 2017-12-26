create or replace view us_interstates_lrs_condition as
select i.interstate,
       sdo_lrs.clip_geom_segment (
         i.geom,
         p.from_measure,
         p.to_measure) geom,
       p.condition
from   us_interstates_lrs i,
       us_road_conditions p
where  i.interstate = p.interstate;

-- Must setup metadata - needed by Mapviewer.
delete from user_sdo_geom_metadata where table_name = 'US_INTERSTATES_LRS_CONDITION';
insert into user_sdo_geom_metadata 
select 'US_INTERSTATES_LRS_CONDITION', column_name, diminfo, srid
from user_sdo_geom_metadata where table_name = 'US_INTERSTATES_LRS';
commit;
