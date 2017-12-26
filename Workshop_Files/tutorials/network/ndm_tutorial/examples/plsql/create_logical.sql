-- 
-- undirected logical network
--
  
-- node table
drop table UN_LOGICAL_NODE$;
exec  sdo_net.create_node_table('UN_LOGICAL_NODE$',NULL,NULL,NULL,1);
insert into UN_LOGICAL_NODE$(node_id) values (1);
insert into UN_LOGICAL_NODE$(node_id) values (2);
insert into UN_LOGICAL_NODE$(node_id) values (3);
insert into UN_LOGICAL_NODE$(node_id) values (4);
insert into UN_LOGICAL_NODE$(node_id) values (5);
insert into UN_LOGICAL_NODE$(node_id) values (6);
insert into UN_LOGICAL_NODE$(node_id) values (7);
                                        
-- link table                           
drop table UN_LOGICAL_LINK$;
exec  sdo_net.create_link_table('UN_LOGICAL_LINK$',NULL,NULL,'COST',1);
                                        
insert into UN_LOGICAL_LINK$(link_id,start_node_id,end_node_id,cost) 
values(1,1,2,2.0);
insert into UN_LOGICAL_LINK$(link_id,start_node_id,end_node_id,cost) 
values(2,1,4,1.0);
insert into UN_LOGICAL_LINK$(link_id,start_node_id,end_node_id,cost) 
values(3,3,1,4.0);
                                        
insert into UN_LOGICAL_LINK$(link_id,start_node_id,end_node_id,cost) 
values(4,2,4,3.0);
insert into UN_LOGICAL_LINK$(link_id,start_node_id,end_node_id,cost) 
values(5,2,5,10.0);
insert into UN_LOGICAL_LINK$(link_id,start_node_id,end_node_id,cost) 
values(6,4,3,2.0);


insert into UN_LOGICAL_LINK$(link_id,start_node_id,end_node_id,cost) 
values(7,3,6,5.0);
insert into UN_LOGICAL_LINK$(link_id,start_node_id,end_node_id,cost) 
values(8,4,5,2.0);
insert into UN_LOGICAL_LINK$(link_id,start_node_id,end_node_id,cost) 
values(9,4,6,8.0);

insert into UN_LOGICAL_LINK$(link_id,start_node_id,end_node_id,cost) 
values(10,4,7,4.0);
insert into UN_LOGICAL_LINK$(link_id,start_node_id,end_node_id,cost) 
values(11,5,7,6.0);
insert into UN_LOGICAL_LINK$(link_id,start_node_id,end_node_id,cost) 
values(12,7,6,1.0);
   
-- network metadata
delete from user_sdo_network_metadata
where network = 'UN_LOGICAL';

insert into user_sdo_network_metadata ( network,
                                        network_category,
                                        node_table_name,
                                        link_table_name,
                                        link_cost_column,
                                        link_direction )
                                      values
                                      ( 'UN_LOGICAL',
                                        'LOGICAL',
                                        'UN_LOGICAL_NODE$',
                                        'UN_LOGICAL_LINK$',
                                        'COST',  
                                        'UNDIRECTED');


-- validate the network
SELECT SDO_NET.VALIDATE_NETWORK('UN_LOGICAL')
FROM dual;
