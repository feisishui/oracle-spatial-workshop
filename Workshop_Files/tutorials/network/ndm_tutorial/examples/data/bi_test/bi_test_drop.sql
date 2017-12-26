
EXECUTE sdo_net.drop_network('BI_TEST');

DROP TABLE BI_TEST_NODE$;

DROP TABLE BI_TEST_LINK$;

DELETE FROM user_sdo_geom_metadata where table_name = 'BI_TEST_NODE$';

DELETE FROM user_sdo_geom_metadata where table_name = 'BI_TEST_LINK$';
