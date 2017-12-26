-- Add one more category (7)
-- Split partition P6 into P6 and P7
alter table yellow_pages_part
  split partition p6
  at (7)
  into (partition p6, partition p7);

-- Check the partitioning
col pname for a20
col high_value for a20
select  partition_name pname,
        partition_position pos,
        high_value
from user_tab_partitions
where table_name= 'YELLOW_PAGES_PART'
order by partition_position;

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

