-- Update values in order to move rows
-- Will fail: ORA-14402: updating partition key column would cause a partition change
update yellow_pages_part
set category = 7
where name like 'SAAB%' or name like 'BMW%';

-- Enable row movements
alter table yellow_pages_part enable row movement;

-- Update values in order to move rows: succeeds
update yellow_pages_part
set category = 7
where name like 'SAAB%' or name like 'BMW%';

-- Check data distribution after update
select category, count(*)
from yellow_pages_part
group by category;

-- Check actual data distribution in partitions
select 'P1' partition, category, count(*)
from yellow_pages_part partition (p1)
group by category
union
select 'P2' partition, category, count(*)
from yellow_pages_part partition (p2)
group by category
union
select 'P3' partition, category, count(*)
from yellow_pages_part partition (p3)
group by category
union
select 'P4' partition, category, count(*)
from yellow_pages_part partition (p4)
group by category
union
select 'P5' partition, category, count(*)
from yellow_pages_part partition (p5)
group by category
union
select 'P6' partition, category, count(*)
from yellow_pages_part partition (p6)
group by category
union
select 'P7' partition, category, count(*)
from yellow_pages_part partition (p7)
group by category
;
