drop table yellow_pages_part;

-- Create partitioned table using CATEGORY as partitioning key
-- Populate the table at the same time

create table yellow_pages_part
partition by list (category) (
  partition p1 values (1),
  partition p2 values (2),
  partition p3 values (3),
  partition p4 values (4),
  partition p5 values (5),
  partition p6 values (6)
)
as select id,
          name,
          category,
          location
from yellow_pages;

-- Add a primary key constraint on ID
alter table yellow_pages_part
  add constraint yellow_pages_part_pk primary key (id);

-- Check the partitioning scheme
col pname for a20
col high_value for a20
select  partition_name pname,
        partition_position pos,
        high_value
from user_tab_partitions
where table_name= 'YELLOW_PAGES_PART'
order by partition_position;

-- Check data distribution
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
;
