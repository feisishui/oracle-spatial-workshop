-- --------------------------------------------------------------------------
-- 7) Collect statistics on topology tables and feature tables
-- --------------------------------------------------------------------------
exec dbms_stats.gather_table_stats (user, 'us_land_use_node$');
exec dbms_stats.gather_table_stats (user, 'us_land_use_edge$');
exec dbms_stats.gather_table_stats (user, 'us_land_use_face$');
exec dbms_stats.gather_table_stats (user, 'us_land_use_relation$');
exec dbms_stats.gather_table_stats (user, 'us_counties_topo');
exec dbms_stats.gather_table_stats (user, 'us_states_topo');
