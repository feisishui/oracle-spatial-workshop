-- List all edges that cross from one partition to another
select e.edge_id, e.start_node_id, e.end_node_id, e.partition_id start_partition, n.partition_id end_partition
from edge e, node n
where n.node_id = e.end_node_id
and e.partition_id <> n.partition_id
order by abs(e.edge_id), sign(e.edge_id) desc;

-- Count outgoing and incoming edges for each partition
with edge_counts as (
  select e.edge_id, e.start_node_id, e.end_node_id, e.partition_id start_partition, n.partition_id end_partition
  from edge e, node n
  where n.node_id = e.end_node_id
  and e.partition_id <> n.partition_id
)
select partition, outgoing_edge_count, incoming_edge_count
from
(
  select start_partition partition, count(*) outgoing_edge_count
  from edge_counts
  group by start_partition
) natural join
(
  select end_partition partition, count(*) incoming_edge_count
  from edge_counts
  group by end_partition
) incoming
order by partition;

-- This is the same as
select partition_id, NUM_OUTGOING_BOUNDARY_EDGES, NUM_INCOMING_BOUNDARY_EDGES
from partition
order by partition_id;
