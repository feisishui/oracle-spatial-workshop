==========================================================
MapViewer
==========================================================

Scripts in this directory:


1) Load map definitions

01_LOAD_MAP_DEFINITIONS.SQL

This script defines a set of styles and themes on your spatial data

Table             Style               Label Style         Theme
----------------  ------------------  ------------------  ----------------
WORLD_COUNTRIES   C.WORLD_COUNTRIES   T.WORLD_COUNTRIES   WORLD_COUNTRIES
US_STATES         C.US_STATES         T.US_STATES         US_STATES
US_COUNTIES       C.US_COUNTIES       T.US_COUNTIES       US_COUNTIES
US_PARKS          C.US_PARKS                              US_PARKS
US_INTERSTATES    L.US_INTERSTATES    M.US_INTERSTATES    US_INTERSTATES
US_CITIES         M.US_CITIES         T.US_CITIES         US_CITIES

It also defines a base map US_BASE_MAP and a map cache (US_BASE_MAP) that
use those themes.


2) Load thematic styles

02_LOAD_THEMATIC_STYLES.SQL

This script defines a set of styles, themes and maps to illustrate
thematic mapping. The styles use the demographic statistics available
in the US_STATES table.

* Single-variable thematics:

They are based on the following statistics:

MEDHHINC = median household income
AVGHHINC = average household income
ONFARMS  = population living on farms
TOTPOP   = total population

Variable  Style             Type              Buckets         Combined Style  Theme
--------  ----------------  ----------------  --------------  --------------  --------------------------
AVGHHINC  V.AVGHHINC_CS_E   Color Scheme      Equal Range                     US_STATES_V.AVGHHINC_CS_E
AVGHHINC  V.AVGHHINC_CS_V   Color Scheme      Variable Range                  US_STATES_V.AVGHHINC_CS_V
MEDHHINC  V.MEDHHINC_MC_E   Multi colors      Equal Range                     US_STATES_V.MEDHHINC_MC_E
MEDHHINC  V.MEDHHINC_MC_V   Multi colors      Variable Range                  US_STATES_V.MEDHHINC_MC_V
ONFARMS   V.ONFARMS_VS      Variable marker   Variable Range  V.ONFARMS_CO    US_STATES_V.ONFARMS_VS
TOTPOP    V.TOTPOP_DD       Dot density                       V.TOTPOP_CO     US_STATES_V.TOTPOP_DD

The "combined" styles associate the thematic style with the base style for the theme so that
they can be rendered as a single entity:

V.ONFARMS_CO combines  C.US_STATES and V.ONFARMS_VS
V.TOTPOP_CO  combines  C.US_STATES and V.TOTPOP_DD

* Multi-variable thematics

They are all based on the population distribution statistics:

WHITE    = white pop
BLACK    = black pop
ASIANPI  = asian & pac islandr pop
AMINDIAN = am indian, esk, aleuts pop
HISPANIC = persons of hispanic origin

Style                 Type                Combined Style          Theme
--------------------  ------------------  ----------------------  ----------------
V.POPULATION_BAR      Bar chart           V.POPULATION_BAR_CO     US_STATES_V.POPULATION_BAR_CO
V.POPULATION_PIE      Pie chart           V.POPULATION_PIE_CO     US_STATES_V.POPULATION_PIE_CO
V.POPULATION_VARPIE   Variable pie chart  V.POPULATION_VARPIE_CO  US_STATES_V.POPULATION_VARPIE_CO

Like above, the "combined" styles associate the thematic style with the base style for the theme.

* Heat Maps

The heat map is defined on the US_CITIES table. It is produced from the density of the
cities, displayed over a background provided by the US_STATES table.

Style                 Type          Theme                           Map
--------------------  ------------  ------------------------------  ---------------------
V.HEATMAP             Colored       US_CITIES_V.HEATMAP             US_HEAT_MAP
V.HEATMAP_GRAYSCALE   Gray scale    US_CITIES_V.HEATMAP_GRAYSCALE   US_HEAT_MAP_GRAYSCALE


3) Load advanced styles

03_MORE_ADVANCED_STYLES.SQL


4) Load themes, maps and map caches for your local WMS

04_USING_WMS_THEMES.SQL

This script defines a theme, map and map cache on your local WMS (MapViewer) installation,

Theme: WMS US_BASE_MAP
Map:   WMS US_BASE_MAP
Cache: WMS US_BASE_MAP

NOTE: The URL specified for the WMS uses port 7001 (it assumes you have deployed MapViewer in Weblogic).
Chance it to 8888 if you are using OC4J


5) Load themes, maps and map caches for an external public WMS

05.1_USING_WMS_THEMES_EXTERNAL_CARTOCIUDAD.SQL

This script defines a theme, map and map cache on a public WMS, provided by
the national mapping agency of Spain

Theme: WMS IGN CARTOCIUDAD
Map:   WMS IGN CARTOCIUDAD
Cache: WMS IGN CARTOCIUDAD

05.2_USING_WMS_THEMES_EXTERNAL_OSM.SQL

This script defines a theme, map and map cache on a public WMS, provided by
Terrestris GmbH (http://ows.terrestris.de/)

Theme: WMS_OSM
Map:   WMS_OSM
Cache: WMS_OSM


6) Load themes, maps and map caches for your local WFS

06_USING_WFS_THEMES.SQL

This script defines a theme on your local WFS

Theme: WFS US_CITIES

NOTE: The URL specified for the WFS uses port 7001 (it assumes you have deployed MapViewer in Weblogic).
Change it to 8080 if you are using Glassfish

7) Define Google-compatible tile layers

07_TILE_LAYERS.SQL

This script defines a tile layer US_BASE_MAP_G over base map US_BASE_MAP in such a way as to make it compatible with Google Maps.

8) Define themes on GIS files

08_THEMES_ON_FILES.SQL

This script defines a set of themes on shape files. It uses the styles
previously defined for table-based themes.

Theme            File name
---------------- ---------------------------------------------------------
WORLD_COUNTRIES  world_countries.shp
US_STATES        us_states.shp
US_COUNTIES      us_counties.shp
US_PARKS         us_parks.shp
US_INTERSTATES   us_interstates.shp
US_CITIES        us_cities.shp

It also defines a base map (US_BASE_MAP.SHP) and a map cache (US_BASE_MAP_SHP) that
use those themes.

