create or replace view counties_topo_v as
 select ID,
        COUNTY,
        FIPSSTCO,
        STATE,
        STATE_ABRV,
        FIPSST,
        LANDSQMI,
        TOTPOP,
        POPPSQMI,
        t.FEATURE.get_geometry() feature
  from counties_topo t;

delete from user_sdo_geom_metadata
  where table_name = 'COUNTIES_TOPO_V' and column_name = 'FEATURE' ;
insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
  values ('COUNTIES_TOPO_V', 'FEATURE',
    mdsys.sdo_dim_array
      (mdsys.sdo_dim_element('x', -180, 180, 1),
       mdsys.sdo_dim_element('y', -90, 90, 1)
      ), 8307
     );
commit;

create or replace view states_topo_v as
 select ID,
        STATE,
        STATE_ABRV,
        t.FEATURE.get_geometry() feature
  from states_topo t;

delete from user_sdo_geom_metadata
  where table_name = 'STATES_TOPO_V' and column_name = 'FEATURE' ;
insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
  values ('STATES_TOPO_V', 'FEATURE',
    mdsys.sdo_dim_array
      (mdsys.sdo_dim_element('x', -180, 180, 1),
       mdsys.sdo_dim_element('y', -90, 90, 1)
      ), 8307
     );
commit;
