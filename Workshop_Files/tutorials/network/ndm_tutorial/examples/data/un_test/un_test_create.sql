
-- CONNECT mdnetwork/mdnetwork;


DELETE
FROM user_sdo_network_metadata
WHERE network = 'UN_TEST';

INSERT INTO user_sdo_network_metadata
    (network,
     network_category,
     geometry_type,
     node_table_name,
     node_geom_column,
     link_table_name,
     link_geom_column,
     link_direction,
     link_cost_column)
VALUES
    ('UN_TEST',
     'SPATIAL',
     'SDO_GEOMETRY',
     'UN_TEST_NODE$',
     'GEOMETRY',
     'UN_TEST_LINK$',
     'GEOMETRY',
     'UNDIRECTED',
     'COST');

SELECT sdo_net.validate_network('UN_TEST')
FROM dual;
