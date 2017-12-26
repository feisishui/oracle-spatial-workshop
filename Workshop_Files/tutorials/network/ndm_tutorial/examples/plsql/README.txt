/ README.txt
/
/ Copyright (c) 2008, Oracle Corporation. All Rights Reserved.

bld_net_geom_seg.sql: shows how to build a network from Spatial geometry
    data that is already segmented into line strings.

bld_net_geom_topo.sql: shows how to build a network from Spatial geometry
    data through Spatial Topology.

bld_sample.sql: build sample data to test geom2net procedure

create_logical.sql demonstrates how to create a network using 
    Oracle Network Data Model's PL/SQL API.  The type of
    network created is a logical network (i.e. no spatial 
    information is associated with the network elements).

geom2net.sql: create a procedure geom2net to build a network from Spatial 
    geometry data through Spatial Topology

native_compile.sql: demonstrates how to native compile NDM
    Java to be used by NDM PL/SQL Wrapper.

logical_partition.sql demonstrates how to partition logical networks

logical_powerlaw_partition.sql illustrates how to partition logical networks
    whose degree distribution display the power law property

Directory lrs_network contains sample SQL scripts to create lrs tables and
   corresponding network tables. For more details, refer to the README file 
   in the directory. 
