col srid for 9999
col name for a40
col h for a1
col up_down for a7
col unit for a20

select  c.srid,
        c.coord_ref_sys_name name,
        a.coord_axis_abbreviation h,
        a.coord_axis_orientation up_down,
        m.unit_of_meas_name unit
from    sdo_coord_ref_system c,
        sdo_coord_axes a,
        sdo_coord_axis_names an,
        sdo_units_of_measure m
where   c.coord_ref_sys_kind = 'VERTICAL'
and     c.coord_sys_id = a.coord_sys_id
and     a.coord_axis_name_id = an.coord_axis_name_id
and     m.uom_id = a.uom_id
order by c.srid;
