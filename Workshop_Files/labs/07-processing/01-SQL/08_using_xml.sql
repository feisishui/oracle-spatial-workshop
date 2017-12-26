-- List all cities in one or more states
-- Multiple XML documents (one document per state)
SELECT  xmlelement ("Cities",
          xmlattributes(
            'http://www.opengis.net/gml' as "xmlns:gml",
            state_abrv as "State"
          ),
          xmlagg (
            xmlelement ( "City",
              xmlforest (
                city as "Name",
                pop90 as "Population",
                xmltype (sdo_util.to_gmlgeometry(location)) as "gml:geometryProperty"
              )
            )
          )
        )
       as GML
FROM us_cities
WHERE state_abrv in ('CO', 'CA', 'NV')
GROUP BY state_abrv;

-- List Cities in all states
-- Single XML document for all states
SELECT  xmlelement ("States",
          xmlattributes(
            'http://www.opengis.net/gml' as "xmlns:gml"
          ),
          xmlagg (
            xmlelement ("State",
              xmlattributes(
                s.id as "Id",
                s.state_abrv as "Code"
              ),
              xmlforest (
                s.state as "Name",
                s.totpop as "Population",
                (
                  select  xmlagg (
                            xmlelement ( "City",
                              xmlattributes(
                                s.id as "Id"
                              ),
                              xmlforest (
                                c.city as "Name",
                                c.pop90 as "Population",
                                xmltype (sdo_util.to_gmlgeometry(c.location)) as "gml:geometryProperty"
                              )
                            )
                          )
                  from us_cities c
                  where c.state_abrv = s.state_abrv
                ) as "Cities"
              )
            )
          )
        )
       as GML
FROM us_states s
ORDER BY s.state;

------------------------------------------------------------------------
Others
------------------------------------------------------------------------

-- For each state, extract the list of cities as an XML document
SELECT s.id, s.state_abrv, s.totpop, s.poppsqmi,
       (
         SELECT xmlelement ("Cities",
                   xmlagg (
                     xmlelement ("Name", c.city)
                   )
                 )
          FROM us_cities c
         WHERE c.state_abrv = s.state_abrv
      ) as cities_xml
 FROM us_states s
WHERE totpop > 5000000;

-- Same, but different syntax
SELECT state_abrv, num_cities, cities_xml,
       (SELECT geom FROM us_states WHERE rowid = state_rowid) geom
FROM (
  SELECT s.rowid state_rowid, s.state_abrv,
         count(*) num_cities,
         xmlelement ("Cities",
            xmlagg (
              xmlelement ("Name", c.city)
            )
          )
         as cities_xml
    FROM us_cities c,
         us_states s
   WHERE c.state_abrv = s.state_abrv
     AND s.totpop > 5000000
  GROUP BY s.rowid, s.state_abrv
)
ORDER BY state_abrv;

-- Using SDO_JOIN
SELECT b.state_abrv, b.county, count(*),
       xmlelement ("Cities",
          xmlagg (
            xmlelement ("City",
              xmlforest (
                a.city as "Name",
                a.pop90 as "Population"
              )
            )
          )
        )
       as cities
  FROM us_cities a,
       us_counties b,
       TABLE(SDO_JOIN(
             'US_CITIES', 'LOCATION',
             'US_COUNTIES', 'GEOM',
             'MASK=ANYINTERACT') ) j
WHERE j.rowid1 = a.rowid
  AND j.rowid2 = b.rowid
GROUP BY b.state_abrv, b.county
ORDER BY b.state_abrv, b.county;

-- XML plus geometries
SELECT state_abrv, county, num_cities, cities_xml,
       (SELECT geom FROM us_counties WHERE rowid = county_rowid) geom
FROM (
  SELECT b.rowid county_rowid, b.state_abrv, b.county,
         count(*) num_cities,
         xmlelement ("Cities",
            xmlagg (
              xmlelement ("Name", a.city)
            )
          )
         as cities_xml
    FROM us_cities a,
         us_counties b,
         TABLE(SDO_JOIN(
               'US_CITIES', 'LOCATION',
               'US_COUNTIES', 'GEOM',
               'MASK=ANYINTERACT') ) j
  WHERE j.rowid1 = a.rowid
    AND j.rowid2 = b.rowid
  GROUP BY b.rowid, b.state_abrv, b.county
)
ORDER BY state_abrv, county;
