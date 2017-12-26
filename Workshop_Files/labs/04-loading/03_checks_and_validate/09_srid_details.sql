set long 32000

select * from cs_srs where srid=3080;

col coord_op_name for a30
col coord_op_method_name for a30

select coord_op_id, coord_op_name, coord_op_method_id
from sdo_coord_ops 
where coord_op_id in (
  select projection_conv_id 
  from sdo_coord_ref_system where srid=3080
);


select coord_op_method_id, coord_op_method_name 
from sdo_coord_op_methods 
where coord_op_method_id in (
  select coord_op_method_id 
  from sdo_coord_ops
  where coord_op_id in (
    select projection_conv_id 
    from sdo_coord_ref_system where srid=3080
  )
);

col op for 99999
col method for 9999
col param for 9999
col parameter_name for a30
select pv.coord_op_id op, pv.coord_op_method_id method, pv.parameter_id param, pn.parameter_name, pv.parameter_value, pv.uom_id 
from sdo_coord_op_param_vals pv, sdo_coord_op_params pn
where pv.parameter_id = pn.parameter_id
and coord_op_id in (
  select projection_conv_id 
  from sdo_coord_ref_system 
  where srid=3080
);
