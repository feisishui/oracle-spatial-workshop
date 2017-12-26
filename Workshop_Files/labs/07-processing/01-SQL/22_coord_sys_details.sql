-- Coordinate system
select srid, coord_ref_sys_name, coord_ref_sys_kind, coord_sys_id, source_geog_srid, projection_conv_id
from sdo_coord_ref_system
where srid = 7845;

-- Operation and method
select co.coord_op_id, co.coord_op_name, com.coord_op_method_id, com.coord_op_method_name
from sdo_coord_ops co, sdo_coord_op_methods com
where co.coord_op_method_id = com.coord_op_method_id
and co.coord_op_id in (
  select projection_conv_id
  from sdo_coord_ref_system
  where srid = 7845
)
and co.coord_op_method_id = com.coord_op_method_id;

-- Parameters
select p.parameter_id id, p.parameter_name, pv.parameter_value, pv.uom_id 
from sdo_coord_op_param_vals pv, sdo_coord_op_params p
where pv.parameter_id = p.parameter_id
and pv.coord_op_id in (
  select projection_conv_id
  from sdo_coord_ref_system
  where srid = 7845
)
order by p.parameter_id;

-- Single query
select crs.srid, crs.coord_ref_sys_name, crs.coord_ref_sys_kind, crs.coord_sys_id, crs.source_geog_srid, crs.projection_conv_id,
  cursor (
    select co.coord_op_id, co.coord_op_name, com.coord_op_method_id, com.coord_op_method_name
    from sdo_coord_ops co, sdo_coord_op_methods com
    where co.coord_op_method_id = com.coord_op_method_id
    and co.coord_op_id = crs.projection_conv_id
    and co.coord_op_method_id = com.coord_op_method_id
  ),
  cursor (
    select p.parameter_id id, p.parameter_name, pv.parameter_value, pv.uom_id 
    from sdo_coord_op_param_vals pv, sdo_coord_op_params p
    where pv.parameter_id = p.parameter_id
    and pv.coord_op_id = crs.projection_conv_id
    order by p.parameter_id
  )
from sdo_coord_ref_system crs
where crs.srid = 7845;
