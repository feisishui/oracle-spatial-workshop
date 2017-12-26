create or replace package sdo_gcdr_wrapper as

procedure geocode (
  i_username                in  varchar2,
  i_address_line_1          in  varchar2,
  i_address_line_2          in  varchar2,
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
);

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
);

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
);

end;
/
show error