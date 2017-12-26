
-- CONNECT mdnetwork/mdnetwork;



DELETE
FROM user_sdo_network_metadata
WHERE network = 'BI_TEST';

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
    ('BI_TEST',
     'SPATIAL',
     'SDO_GEOMETRY',
     'BI_TEST_NODE$',
     'GEOMETRY',
     'BI_TEST_LINK$',
     'GEOMETRY',
     'BIDIRECTED',
     'COST');

SELECT sdo_net.validate_network('BI_TEST')
FROM dual;
