--
-- 1) Create a folder in the XDB repository (if it does not exist yet)
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
-- 2) Convert the buildings to CityGML and publish to the repository
--

declare
  result boolean;
  gmldoc xmltype;
begin
  -- Generate the GML document
  SELECT xmlelement( "CityModel",
           xmlattributes(
             'http://www.citygml.org/citygml/1/0/0' as "xmlns",
             'http://www.opengis.net/Buildings' as "xmlns:gml",
             'http://www.w3.org/1999/xlink' as "xmlns:xlink",
             'http://www.w3.org/2001/XMLSchema-instance' as "xmlns:xsi",
             'http://www.citygml.org/citygml/1/0/0/CityGML.xsd' as "xsi:schemaLocation"
           ),
         xmlagg (
           xmlelement ("cityObjectMember",
             xmlelement("GenericCityObject",
               xmlattributes (gmlid as "gml:id"),
               xmlforest(
                 'Building ' || gmlid as "gml:name",
                 height as "Height",
                 ground_height as "GroundHeight",
                 xmltype ( sdo_util.to_gml311geometry(geom) ) as "lod1Geometry"
               )
             )
           )
         )
       )
  INTO gmldoc
  FROM buildings_ext;

  -- If already in repository, then delete it
  if dbms_xdb.existsresource ('/public/Buildings/buildings_ext.xml') then
    dbms_xdb.deleteresource('/public/Buildings/buildings_ext.xml');
  end if;

  -- Load into the repository
  result := dbms_xdb.createResource ('/public/Buildings/buildings_ext.xml', gmldoc);
  if not result then
    raise_application_error (-20000, 'Failed to create resource');
  end if;

end;
/
commit;

--
-- 3) Check results
--

-- Lists the document(s) just loaded
col document_name for a20
col full_path for a40
select path(1) document_name,
       any_path full_path,
       length(dbms_xdb.getContentClob(any_path)) bytes
  from resource_view
 where under_path(res, '/public/Buildings',1) = 1;
