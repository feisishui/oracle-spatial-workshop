-- Return the point located 50 km down I25
select sdo_lrs.locate_pt(geom, 50000, 0)
from   us_interstates_lrs
where  interstate = 'I25';

-- Return the point located 50 km down I25, 200 m on the right
select sdo_lrs.locate_pt(geom, 50000, -200)
from   us_interstates_lrs
where  interstate = 'I25';

-- Return the point located 50 km down I25, 200 m on the left
select sdo_lrs.locate_pt(geom, 50000, 200)
from   us_interstates_lrs
where  interstate = 'I25';
