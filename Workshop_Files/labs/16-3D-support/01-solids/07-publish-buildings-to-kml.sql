--
-- 1) Create function SNAP_TO_GROUND() (if necessary)
--
create or replace function snap_to_ground (geom sdo_geometry, ground_height number)
  return sdo_geometry
  deterministic
is
  i number;
  g sdo_geometry;
  current_ground_height number;
  offset number;
begin
  g := geom;
  current_ground_height :=  sdo_geom.sdo_min_mbr_ordinate(g,3);
  offset := current_ground_height - ground_height;
  i := 0;
  while i < g.sdo_ordinates.count loop
    g.sdo_ordinates(i+3) := g.sdo_ordinates(i+3) - offset;
    i := i + 3;
  end loop;
  return g;
end;
/
show errors

--
-- 2) Create a folder in the XDB repository (if necessarey)
--
declare
  result boolean;
begin
  if not dbms_xdb.existsresource ('/public/Buildings') then
    result := dbms_xdb.createFolder('/public/Buildings');
    if not result then
      raise_application_error (-20000, 'Failed to create folder');
    end if;
  end if;
end;
/
commit;

--
-- 3) Convert the buildings to KML
--
declare
  result boolean;
  kmldoc xmltype;
begin
  SELECT  xmlelement ( "kml",
            xmlattributes ('http://www.opengis.net/kml/2.2' as "xmlns"),
            xmlelement ("Document",
              xmlelement ("Style",
                xmlattributes('BuildingStyle' as "id"),
                xmlelement ("LineStyle", xmlelement ("width", '1'), xmlelement ("color", 'ffffffff')),
                xmlelement ("PolyStyle", xmlelement ("color", 'bfc0c0c0')),
                xmlelement ("BalloonStyle", xmlelement ("text", '$[name]'))
              ),
              xmlagg (
                xmlelement ("Placemark",
                  xmlelement ("name", 'Building '|| gmlid),
                  xmlelement ("styleUrl", '#BuildingStyle'),
                  xmltype (
                    sdo_util.to_kmlgeometry (
                      snap_to_ground (
                        sdo_cs.transform(geom,4327), 0
                      )
                    )
                  )
                )
              )
            )
          )
  INTO kmldoc
  FROM buildings;

--
-- 4) Publish to the repository
--

  -- If already in repository, then delete it
  if dbms_xdb.existsresource ('/public/Buildings/buildings.kml') then
    dbms_xdb.deleteresource('/public/Buildings/buildings.kml');
  end if;

  -- Load into the repository
  result := dbms_xdb.createResource ('/public/Buildings/buildings.kml', kmldoc);
  if not result then
    raise_application_error (-20000, 'Failed to create resource');
  end if;
end;
/
commit;

--
-- 5) Check results
--

-- Lists the document(s) just loaded
col document_name for a20
col full_path for a40
select path(1) document_name,
       any_path full_path,
       length(dbms_xdb.getContentClob(any_path)) bytes
  from resource_view
 where under_path(res, '/public/Buildings',1) = 1;
