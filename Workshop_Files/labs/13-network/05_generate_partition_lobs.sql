-- Generate partition lobs
-- This will create the NET_PARTITIONS_BLOBS table if it does not exist yet.
-- It replaces any existing information

-- Enable full tracing of all NDM operations (only if you are curious)
exec dbms_java.set_output(1000000);
exec sdo_net.set_logging_level(sdo_net.logging_level_finest);

-- Generate blobs for level 1 partitions
begin
  sdo_net.generate_partition_blobs (
    network                     => 'net_sf',
    partition_blob_table_name   => 'net_partitions_blobs',
    link_level                  => 1,
    include_user_data           => false,
    log_loc                     => 'NET_LOG_DIR',
    log_file                    => 'net_partitioning.log'
  );
end;
/

-- Generate blobs for level 2 partitions
begin
  sdo_net.generate_partition_blobs (
    network                     => 'net_sf',
    partition_blob_table_name   => 'net_partitions_blobs',
    link_level                  => 2,
    include_user_data           => false,
    log_loc                     => 'NET_LOG_DIR',
    log_file                    => 'net_partitioning.log'
  );
end;
/

-- Check results

-- Total number of partitions at each link level
select link_level, count(*), sum(length(blob)), sum(num_inodes)
from net_partitions_blobs
group by link_level
order by link_level;

-- Details of the partitions
select link_level, partition_id, length(blob), num_inodes
from net_partitions_blobs
order  by link_level, partition_id;

