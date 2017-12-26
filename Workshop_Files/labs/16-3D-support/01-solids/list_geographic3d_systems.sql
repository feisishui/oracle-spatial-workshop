col srid for 99999999
col name for a40
col h for a1
col up_down for a7
col unit for a20

select  c.srid,
        c.coord_ref_sys_name name,
        c.cmpd_horiz_srid hsrid,
        c.cmpd_vert_srid vsrid
from    sdo_coord_ref_system c
where   c.coord_ref_sys_kind = 'GEOGRAPHIC3D'
order by c.srid;

