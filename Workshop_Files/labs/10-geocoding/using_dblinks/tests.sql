-- geocode
select sdo_gcdr_remote.geocode('SCOTT', sdo_keywordarray('150 Bd Hausman', '75009 Paris'), 'FR', 'default') from dual;

-- geocode_addr
select sdo_gcdr_remote.geocode_addr ('SCOTT', sdo_geo_addr ('FR','default','150 Bd Hausman', null, 'Paris', null, '75009')) from dual;

-- reverse_geocode
select sdo_gcdr_remote.reverse_geocode ('SCOTT', sdo_geometry(2001, 8307, sdo_point_type (2.31189, 48.87515, null), null, null), 'FR') from dual;
