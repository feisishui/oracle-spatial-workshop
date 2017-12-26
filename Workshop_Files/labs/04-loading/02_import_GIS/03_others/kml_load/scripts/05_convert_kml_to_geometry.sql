-- Extract the polygons from the KML and convert them to a geometry object
-- Make them 2D (KML geometries are 3D)
-- The process is like this:
-- 1) Cast the kml column (a string) into an XMLType: 
--    xmltype(kml)
-- 2) Extract the <Polygon> element from the XML:
--    xmltype(kml).extract('//Polygon','xmlns="http://www.opengis.net/kml/2.2')
-- 3) Turn the result back into a string (that is what from_kmlgeometry() expects
--    xmltype(kml).extract(...).getclobval()
-- 4) Convert that string into a geometry object
--    sdo_util.from_kmlgeometry (...)
-- 5) Make the result 2D (the input KML is 3D)
--    sdo_cs.make_2d(...)
      
update fields
set geometry =
  sdo_cs.make_2d (
    sdo_util.from_kmlgeometry(
      xmltype(kml).extract('//Polygon','xmlns="http://www.opengis.net/kml/2.2').getclobval()
    )
  );
  
-- Add the proper coordinate system (4326 = WGS84 2D)
update fields f
set f.geometry.sdo_srid=4326;
commit;
