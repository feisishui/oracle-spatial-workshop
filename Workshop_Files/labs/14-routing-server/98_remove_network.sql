--------------------------------------------------------------
-- Delete the network
--------------------------------------------------------------
 
-- Drop the node indexes
drop index EDGE_FUNC_CLASS_IDX;
drop index EDGE_LEVEL_IDX;

-- Drop the views
drop view ROUTE_SF_NODE$;
drop view ROUTE_SF_LINK$;
drop view ROUTE_SF_PART$;
drop view ROUTE_SF_PBLOB$;

-- Remove the network metadata
delete from USER_SDO_NETWORK_METADATA where network = 'ROUTE_SF';
delete from USER_SDO_NETWORK_USER_DATA where network = 'ROUTE_SF';
commit;
