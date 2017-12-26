delete from user_sdo_network_metadata where network in ('NET_SF');
delete from user_sdo_network_user_data where network in ('NET_SF');

delete from user_sdo_geom_metadata where table_name in ('NET_LINKS', 'NET_NODES', 'NET_PATHS');
commit;

drop table net_links purge;
drop table net_nodes purge;
drop table net_paths purge;
drop table net_path_links purge;
drop table net_partitions purge;
drop table net_partitions_blobs purge;

drop directory net_log_dir;
