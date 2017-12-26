-- Partition the network
-- This will create the NET_PARTITIONS table if it does not exist yet.
-- It replaces any existing information

-- Partition level 1 nodes
begin
  sdo_net.spatial_partition(
    network               => 'net_sf',
    partition_table_name  => 'net_partitions',
    link_level            => 1,
    max_num_nodes         => 5000,
    log_loc               => 'NET_LOG_DIR',
    log_file              => 'net_partitioning.log'
  );
end;
/

-- Partition level 2 nodes
begin
  sdo_net.spatial_partition(
    network               => 'net_sf',
    partition_table_name  => 'net_partitions',
    link_level            => 2,
    max_num_nodes         => 400,
    log_loc               => 'NET_LOG_DIR',
    log_file              => 'net_partitioning.log'
  );
end;
/

-- Check the partitioning results:

-- Number of partitions at each link level
select link_level, count(distinct partition_id) num_parts
from net_partitions
group by link_level
order by link_level;

-- Number of partitions at each link level and average number of nodes per partition
select link_level, count(*) num_parts, round(avg(nodes_per_part)) nodes_per_part
from (
  select count(*) nodes_per_part, link_level, partition_id
  from net_partitions
  group by link_level, partition_id
)
group by link_level
order by link_level;
