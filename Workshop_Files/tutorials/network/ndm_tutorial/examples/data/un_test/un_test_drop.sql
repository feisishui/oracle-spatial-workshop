
EXECUTE sdo_net.drop_network('UN_TEST');

DROP TABLE UN_TEST_NODE$;

DROP TABLE UN_TEST_LINK$;

DELETE FROM user_sdo_geom_metadata where table_name = 'UN_TEST_NODE$';

DELETE FROM user_sdo_geom_metadata where table_name = 'UN_TEST_LINK$';
