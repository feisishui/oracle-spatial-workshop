col srid  for 99999
col name  for a45
col hsrid for 99999
col gsrid for 99999
col vsrid for 99999
col hkind for a12

select  c.srid,
        c.coord_ref_sys_name name,
        c.cmpd_horiz_srid hsrid,
        hc.source_geog_srid gsrid,
        c.cmpd_vert_srid vsrid
from    sdo_coord_ref_system c,
        sdo_coord_ref_system hc
where   c.coord_ref_sys_kind = 'COMPOUND'
and     hc.coord_ref_sys_kind  = 'PROJECTED'
and     hc.srid = c.cmpd_horiz_srid
order by c.srid;

