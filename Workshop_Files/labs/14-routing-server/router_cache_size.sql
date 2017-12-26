create or replace function router_cache_size (
  HeapSize            number,
  AvgNodesPartition   number := 26000,
  NodesPartition0     number := 15000000,
  NodesPerGigabyte    number := 15000000
)
return number

/*

* Heapsize is the size of the heap for the JVM where the router is running 
  (in Gigabytes)

* AvgNodesPartition is the average number of nodes per local partition. This 
  does not include the highway partition 0.  
  For the North American data set, the AvgNodesPartition value is around 26000. 
  You can check the actual average nodes per partition by using the following 
  query:

  SELECT AVG(num_nodes)
  FROM partition 
  WHERE partition_id > 0;
  
* NodesPartition0 is the number of nodes in partition 0 (the highway partition).
  For the North American data set the value is 15000000 (1.5 million). You can
  find the actual number using the following query:
  
  SELECT num_nodes
  FROM partition 
  WHERE partition_id = 0;
  
* NodesPerGigabyte is the number of nodes per gigabyte. (This value should not
  change. In the data sets as of December 2013, this value is 15000000, 
  that is, 1.5 million.)

*/ 

is

  PartitionCacheSize number;

begin

  PartitionCacheSize := 
    NodesPerGigabyte/AvgNodesPartition * 
    (HeapSize-(NodesPartition0/NodesPerGigabyte));
  
  return floor(PartitionCacheSize);

end;
/
show errors