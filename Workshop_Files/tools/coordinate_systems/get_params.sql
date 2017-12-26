col name for a30
col uom_name for a10
col id 9999
col uom 9999
select p.parameter_id id, p.parameter_name name, pv.parameter_value value, pv.uom_id uom, uom.unit_of_meas_name uom_name
from sdo_coord_op_param_vals pv, 
     sdo_units_of_measure uom,
     sdo_coord_op_params p
where coord_op_id = 3866
and p.parameter_id = pv.parameter_id
and pv.uom_id = uom.uom_id 
order by p.parameter_id;