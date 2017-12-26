==========================================================
Geocoding
==========================================================

1) load data

01_IMPORT

Import file GC_DATA.DMP. This creates and loads sample geocoding data sets
for several countries:

- geocoding metadata

  GC_COUNTRY_PROFILE       6 rows
  GC_PARSER_PROFILE        6 rows
  GC_PARSER_PROFILES    7941 rows

- United States: San Francisco, CA

  GC_AREA_US             177 rows
  GC_INTERSECTION_US   13919 rows
  GC_POI_US            15122 rows
  GC_POSTAL_CODE_US       68 rows
  GC_ROAD_US           10410 rows
  GC_ROAD_SEGMENT_US   28155 rows
  GC_ADDRESS_POINT_US 190884 rows

- France: a section of Paris

  GC_AREA_FR             113 rows
  GC_INTERSECTION_FR    2132 rows
  GC_POI_FR              779 rows
  GC_POSTAL_CODE_FR       12 rows
  GC_ROAD_FR             835 rows
  GC_ROAD_SEGMENT_FR    3052 rows

- Belgium: a section of Brussels

  GC_AREA_BE             113 rows
  GC_INTERSECTION_BE    4592 rows
  GC_POI_BE              235 rows
  GC_POSTAL_CODE_BE       29 rows
  GC_ROAD_BE            1299 rows
  GC_ROAD_SEGMENT_BE    5463 rows

- Germany: a section of Berlin

  GC_AREA_DE              54 rows
  GC_INTERSECTION_DE    1209 rows
  GC_POI_DE              312 rows
  GC_POSTAL_CODE_DE       13 rows
  GC_ROAD_DE             426 rows
  GC_ROAD_SEGMENT_DE    1771 rows

- Netherlands

  GC_AREA_NL              40 rows
  GC_INTERSECTION_NL    8277 rows
  GC_POI_NL              557 rows
  GC_POSTAL_CODE_NL       84 rows
  GC_ROAD_NL            3330 rows
  GC_ROAD_SEGMENT_NL   13626 rows


2) Load helper functions

02_PROC_FORMAT_GEO_ADDR.SQL

This script creates a few procedures that format the result of
geocoding queries in a more readable way.


3) Perform some geocoding searches

Use the following SQL template to perform the searches

set serveroutput on size 1000000
exec format_addr_array(sdo_gcdr.geocode_all (user, sdo_keywordarray('1500 Clay Street', 'San Francisco, CA'), 'US', 'default'))

NOTE: the first geocoding query may be slow due to the need to initialize a JVM in your session.

US: (03.1_GC_US.SQL)

  1500 Clay Street
  San Francisco, CA

FR: (03.2_GC_FR.SQL)

  12 rue de l'Arcade
  Paris

  150 Bd Hausman
  75009 Paris

BE: (03.3_GC_BE.SQL)

  Avenue du Bois Soleil 62
  Kraainem

  Zonneboslaan 62
  Kraainem

See also the provided scripts:


4) Deploy the geocoding web service

Deploy the geocoder.ear application into your application server.


5) Setup parameters for the geocoding server

Update file geocodercfg.xml with the connection details for your environment. For example:

       <geocoder>
         <database host="localhost"
                   port="1521"
                   sid="orcl122"
                   mode="thin"
                   user="scott"
                   password="tiger"
                   load_db_parser_profiles="true" />
        </geocoder>


Copy file geocodercfg.xml into the location you have deployed the routeserver application, i.e. xxx/applications/geocoder.ear/web.war/WEB-INF/config

5) Restart the geocoding server

This is required for the server to use the new parameters.


5) Perform geocoding searches against the web service

05_GEOCODING_REQUESTS_LOCAL.HTML


6) Perform geocoding searches against the elocation web service

06_GEOCODING_REQUESTS_ELOCATION.HTML
