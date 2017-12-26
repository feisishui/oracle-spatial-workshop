create or replace package body sdo_gcdr_remote as

function geocode (
  username                       varchar2,
  addr_lines                     sdo_keywordarray,
  country                        varchar2,
  match_mode                     varchar2
)
return sdo_geo_addr
is
  g sdo_geo_addr := sdo_geo_addr();
begin
  sdo_gcdr_wrapper.geocode@gcdb (
    username,
    addr_lines(1),
    addr_lines(2),
    country,
    match_mode,
    g.id,
    g.placename,
    g.streetname,
    g.intersectstreet,
    g.secunit,
    g.settlement,
    g.municipality,
    g.region,
    g.country,
    g.postalcode,
    g.postaladdoncode,
    g.fullpostalcode,
    g.pobox,
    g.housenumber,
    g.basename,
    g.streettype,
    g.streettypebefore,
    g.streettypeattached,
    g.streetprefix,
    g.streetsuffix,
    g.side,
    g.percent,
    g.edgeid,
    g.errormessage,
    g.matchcode,
    g.matchmode,
    g.longitude,
    g.latitude,
    g.matchvector
  );
  return g;
end;

function geocode_addr (
  gc_username                    varchar2,
  address                        sdo_geo_addr
)
return sdo_geo_addr
is
  g sdo_geo_addr := sdo_geo_addr();
begin
  sdo_gcdr_wrapper.geocode_addr@gcdb (
    gc_username,
    address.id,
    address.placename,
    address.streetname,
    address.intersectstreet,
    address.secunit,
    address.settlement,
    address.municipality,
    address.region,
    address.country,
    address.postalcode,
    address.postaladdoncode,
    address.fullpostalcode,
    address.pobox,
    address.housenumber,
    address.basename,
    address.streettype,
    address.streettypebefore,
    address.streettypeattached,
    address.streetprefix,
    address.streetsuffix,
    address.side,
    address.percent,
    address.edgeid,
    address.errormessage,
    address.matchcode,
    address.matchmode,
    address.longitude,
    address.latitude,
    address.matchvector,
    g.id,
    g.placename,
    g.streetname,
    g.intersectstreet,
    g.secunit,
    g.settlement,
    g.municipality,
    g.region,
    g.country,
    g.postalcode,
    g.postaladdoncode,
    g.fullpostalcode,
    g.pobox,
    g.housenumber,
    g.basename,
    g.streettype,
    g.streettypebefore,
    g.streettypeattached,
    g.streetprefix,
    g.streetsuffix,
    g.side,
    g.percent,
    g.edgeid,
    g.errormessage,
    g.matchcode,
    g.matchmode,
    g.longitude,
    g.latitude,
    g.matchvector
  );
  return g;
end;

function reverse_geocode (
  username                       varchar2,
  location                       sdo_geometry,
  country                        varchar2
)
return sdo_geo_addr
is
  g sdo_geo_addr := sdo_geo_addr();
begin
  sdo_gcdr_wrapper.reverse_geocode@gcdb (
    username,
    location.sdo_srid,
    location.sdo_point.x,
    location.sdo_point.y,
    country,
    g.id,
    g.placename,
    g.streetname,
    g.intersectstreet,
    g.secunit,
    g.settlement,
    g.municipality,
    g.region,
    g.country,
    g.postalcode,
    g.postaladdoncode,
    g.fullpostalcode,
    g.pobox,
    g.housenumber,
    g.basename,
    g.streettype,
    g.streettypebefore,
    g.streettypeattached,
    g.streetprefix,
    g.streetsuffix,
    g.side,
    g.percent,
    g.edgeid,
    g.errormessage,
    g.matchcode,
    g.matchmode,
    g.longitude,
    g.latitude,
    g.matchvector
  );
  return g;
end;

end;
/
show error

