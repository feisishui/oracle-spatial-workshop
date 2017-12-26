create or replace package body sdo_gcdr_wrapper as

-------------------------------------------------------------------
procedure geocode (
  i_username                in  varchar2,
  i_addr_line_1             in  varchar2,
  i_addr_line_2             in  varchar2,
  i_country                 in  varchar2,
  i_match_mode              in  varchar2,
  o_id                      out number,
  o_placename               out varchar2,
  o_streetname              out varchar2,
  o_intersectstreet         out varchar2,
  o_secunit                 out varchar2,
  o_settlement              out varchar2,
  o_municipality            out varchar2,
  o_region                  out varchar2,
  o_country                 out varchar2,
  o_postalcode              out varchar2,
  o_postaladdoncode         out varchar2,
  o_fullpostalcode          out varchar2,
  o_pobox                   out varchar2,
  o_housenumber             out varchar2,
  o_basename                out varchar2,
  o_streettype              out varchar2,
  o_streettypebefore        out varchar2,
  o_streettypeattached      out varchar2,
  o_streetprefix            out varchar2,
  o_streetsuffix            out varchar2,
  o_side                    out varchar2,
  o_percent                 out number,
  o_edgeid                  out number,
  o_errormessage            out varchar2,
  o_matchcode               out number,
  o_matchmode               out varchar2,
  o_longitude               out number,
  o_latitude                out number,
  o_matchvector             out varchar2
)
as
  g sdo_addr_array;
begin
  g := sdo_gcdr.geocode_all(
    i_username,
    sdo_keywordarray(
      i_addr_line_1,
      i_addr_line_2
    ),
    i_country,
    i_match_mode
  );
  if g is not null then
    o_id                        := g(1).id;
    o_placename                 := g(1).placename;
    o_streetname                := g(1).streetname;
    o_intersectstreet           := g(1).intersectstreet;
    o_secunit                   := g(1).secunit;
    o_settlement                := g(1).settlement;
    o_municipality              := g(1).municipality;
    o_region                    := g(1).region;
    o_country                   := g(1).country;
    o_postalcode                := g(1).postalcode;
    o_postaladdoncode           := g(1).postaladdoncode;
    o_fullpostalcode            := g(1).fullpostalcode;
    o_pobox                     := g(1).pobox;
    o_housenumber               := g(1).housenumber;
    o_basename                  := g(1).basename;
    o_streettype                := g(1).streettype;
    o_streettypebefore          := g(1).streettypebefore;
    o_streettypeattached        := g(1).streettypeattached;
    o_streetprefix              := g(1).streetprefix;
    o_streetsuffix              := g(1).streetsuffix;
    o_side                      := g(1).side;
    o_percent                   := g(1).percent;
    o_edgeid                    := g(1).edgeid;
    o_errormessage              := g(1).errormessage;
    o_matchcode                 := g(1).matchcode;
    o_matchmode                 := g(1).matchmode;
    o_longitude                 := g(1).longitude;
    o_latitude                  := g(1).latitude;
    o_matchvector               := g(1).matchvector;

    if g.count > 1 then
      o_matchcode := 0;
    end if;
  end if;

end;

-------------------------------------------------------------------
procedure geocode_addr (
  i_gc_username             in  varchar2,
  i_id                      in  number,
  i_placename               in  varchar2,
  i_streetname              in  varchar2,
  i_intersectstreet         in  varchar2,
  i_secunit                 in  varchar2,
  i_settlement              in  varchar2,
  i_municipality            in  varchar2,
  i_region                  in  varchar2,
  i_country                 in  varchar2,
  i_postalcode              in  varchar2,
  i_postaladdoncode         in  varchar2,
  i_fullpostalcode          in  varchar2,
  i_pobox                   in  varchar2,
  i_housenumber             in  varchar2,
  i_basename                in  varchar2,
  i_streettype              in  varchar2,
  i_streettypebefore        in  varchar2,
  i_streettypeattached      in  varchar2,
  i_streetprefix            in  varchar2,
  i_streetsuffix            in  varchar2,
  i_side                    in  varchar2,
  i_percent                 in  number,
  i_edgeid                  in  number,
  i_errormessage            in  varchar2,
  i_matchcode               in  number,
  i_matchmode               in  varchar2,
  i_longitude               in  number,
  i_latitude                in  number,
  i_matchvector             in  varchar2,
  o_id                      out number,
  o_placename               out varchar2,
  o_streetname              out varchar2,
  o_intersectstreet         out varchar2,
  o_secunit                 out varchar2,
  o_settlement              out varchar2,
  o_municipality            out varchar2,
  o_region                  out varchar2,
  o_country                 out varchar2,
  o_postalcode              out varchar2,
  o_postaladdoncode         out varchar2,
  o_fullpostalcode          out varchar2,
  o_pobox                   out varchar2,
  o_housenumber             out varchar2,
  o_basename                out varchar2,
  o_streettype              out varchar2,
  o_streettypebefore        out varchar2,
  o_streettypeattached      out varchar2,
  o_streetprefix            out varchar2,
  o_streetsuffix            out varchar2,
  o_side                    out varchar2,
  o_percent                 out number,
  o_edgeid                  out number,
  o_errormessage            out varchar2,
  o_matchcode               out number,
  o_matchmode               out varchar2,
  o_longitude               out number,
  o_latitude                out number,
  o_matchvector             out varchar2
)
is
  g sdo_addr_array;
begin
  g := sdo_gcdr.geocode_addr_all(
    i_gc_username,
    sdo_geo_addr (
      i_id,
      null,
      i_placename,
      i_streetname,
      i_intersectstreet,
      i_secunit,
      i_settlement,
      i_municipality,
      i_region,
      i_country,
      i_postalcode,
      i_postaladdoncode,
      i_fullpostalcode,
      i_pobox,
      i_housenumber,
      i_basename,
      i_streettype,
      i_streettypebefore,
      i_streettypeattached,
      i_streetprefix,
      i_streetsuffix,
      i_side,
      i_percent,
      i_edgeid,
      i_errormessage,
      i_matchcode,
      i_matchmode,
      i_longitude,
      i_latitude,
      i_matchvector
    )
  );
  if g is not null then
    o_id                        := g(1).id;
    o_placename                 := g(1).placename;
    o_streetname                := g(1).streetname;
    o_intersectstreet           := g(1).intersectstreet;
    o_secunit                   := g(1).secunit;
    o_settlement                := g(1).settlement;
    o_municipality              := g(1).municipality;
    o_region                    := g(1).region;
    o_country                   := g(1).country;
    o_postalcode                := g(1).postalcode;
    o_postaladdoncode           := g(1).postaladdoncode;
    o_fullpostalcode            := g(1).fullpostalcode;
    o_pobox                     := g(1).pobox;
    o_housenumber               := g(1).housenumber;
    o_basename                  := g(1).basename;
    o_streettype                := g(1).streettype;
    o_streettypebefore          := g(1).streettypebefore;
    o_streettypeattached        := g(1).streettypeattached;
    o_streetprefix              := g(1).streetprefix;
    o_streetsuffix              := g(1).streetsuffix;
    o_side                      := g(1).side;
    o_percent                   := g(1).percent;
    o_edgeid                    := g(1).edgeid;
    o_errormessage              := g(1).errormessage;
    o_matchcode                 := g(1).matchcode;
    o_matchmode                 := g(1).matchmode;
    o_longitude                 := g(1).longitude;
    o_latitude                  := g(1).latitude;
    o_matchvector               := g(1).matchvector;

    if g.count > 1 then
      o_matchcode := 0;
    end if;
  end if;

end;

-------------------------------------------------------------------
procedure reverse_geocode (
  i_username                in  varchar2,
  i_location_srid           in  number,
  i_location_point_x        in  number,
  i_location_point_y        in  number,
  i_country                 in  varchar2,
  o_id                      out number,
  o_placename               out varchar2,
  o_streetname              out varchar2,
  o_intersectstreet         out varchar2,
  o_secunit                 out varchar2,
  o_settlement              out varchar2,
  o_municipality            out varchar2,
  o_region                  out varchar2,
  o_country                 out varchar2,
  o_postalcode              out varchar2,
  o_postaladdoncode         out varchar2,
  o_fullpostalcode          out varchar2,
  o_pobox                   out varchar2,
  o_housenumber             out varchar2,
  o_basename                out varchar2,
  o_streettype              out varchar2,
  o_streettypebefore        out varchar2,
  o_streettypeattached      out varchar2,
  o_streetprefix            out varchar2,
  o_streetsuffix            out varchar2,
  o_side                    out varchar2,
  o_percent                 out number,
  o_edgeid                  out number,
  o_errormessage            out varchar2,
  o_matchcode               out number,
  o_matchmode               out varchar2,
  o_longitude               out number,
  o_latitude                out number,
  o_matchvector             out varchar2
)
is
  g sdo_geo_addr;
begin

  g := sdo_gcdr.reverse_geocode(
    i_username,
    sdo_geometry (
      2001,
      i_location_srid,
      sdo_point_type (
        i_location_point_x,
        i_location_point_y,
        null
      ),
      null,
      null
    ),
    i_country
  );

  o_id                        := g.id;
  o_placename                 := g.placename;
  o_streetname                := g.streetname;
  o_intersectstreet           := g.intersectstreet;
  o_secunit                   := g.secunit;
  o_settlement                := g.settlement;
  o_municipality              := g.municipality;
  o_region                    := g.region;
  o_country                   := g.country;
  o_postalcode                := g.postalcode;
  o_postaladdoncode           := g.postaladdoncode;
  o_fullpostalcode            := g.fullpostalcode;
  o_pobox                     := g.pobox;
  o_housenumber               := g.housenumber;
  o_basename                  := g.basename;
  o_streettype                := g.streettype;
  o_streettypebefore          := g.streettypebefore;
  o_streettypeattached        := g.streettypeattached;
  o_streetprefix              := g.streetprefix;
  o_streetsuffix              := g.streetsuffix;
  o_side                      := g.side;
  o_percent                   := g.percent;
  o_edgeid                    := g.edgeid;
  o_errormessage              := g.errormessage;
  o_matchcode                 := g.matchcode;
  o_matchmode                 := g.matchmode;
  o_longitude                 := g.longitude;
  o_latitude                  := g.latitude;
  o_matchvector               := g.matchvector;
end;
-------------------------------------------------------------------

end;
/
show error

