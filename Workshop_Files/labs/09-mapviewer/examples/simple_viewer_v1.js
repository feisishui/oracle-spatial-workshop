// --------------------------------------------------------------------------------
// Global Variables
// --------------------------------------------------------------------------------

var mapviewerURL  = "/mapviewer";

// Base map
var baseMap       = "elocation_mercator.world_map";
var baseMapURL    = "http://elocation.oracle.com/mapviewer/mcserver";

// Dynamic theme
var themeName     = null;
var theme         = null;
var wholeImageThreshold = 10;
var clickableThreshold = 10;
// Initial center and zoom level
var mapSRID      = 4326;
var mapCenterX   = -0.13000;
var mapCenterY   = 51.49000;
var mapZoom      = 11;
// This is the difference between the overview map and the main map.
// For example, when the main map is zoomed in at zoom level 16, then the overview map is at zoom level 12.
var overviewZoom = 4;
// The main mapview object
var mapview      = null;

// --------------------------------------------------------------------------------
// loadMainMap()
//
// This is the main entry point of the application. All other functions are
// either called from here, or are called from events (mouse click, scale change, etc)
// --------------------------------------------------------------------------------

function loadMainMap()
{
  // Extract arguments from url
  getURLParameters();

  // Create a MVMapView instance to display the map
  mapview = new MVMapView(document.getElementById("MAP_PANEL"), mapviewerURL);

  // Define the base map to use
  baseLayer = new MVMapTileLayer(baseMap,baseMapURL);

  // Add the base map layer to the map view
  mapview.addMapTileLayer(baseLayer);

  // Setup dynamic theme
  if (themeName) {
    theme = new MVThemeBasedFOI(themeName, themeName);
    theme.setBoundingTheme(true);
    theme.enableAutoWholeImage(true, wholeImageThreshold, clickableThreshold);
    theme.setClickable(true);
    mapview.addThemeBasedFOI(theme);
  }

  // Set the initial map center and zoom level
  var center=MVSdoGeometry.createPoint(mapCenterX, mapCenterY, mapSRID);
  mapview.setCenter(center);
  mapview.setZoomLevel(mapZoom);

  // Add a navigation panel on the right side of the map
  mapview.setHomeMap(center, mapZoom);
  navigationPanel = new MVMapDecoration (new MVNavigationPanel(),0 ,0, null, null, 4, 40);
  mapview.addMapDecoration(navigationPanel);

  // Enable mouse wheel zoming
  mapview.setMouseWheelZoomEnabled(true)

  // Add a scale bar
  mapview.addScaleBar();

  // Add a copyright notice
  mapview.addCopyRightNote("Powered by Oracle Maps");

  // Setup an overview map as a collapsible decoration and add it to the map
  var ov = new MVMapDecoration(new MVOverviewMap(overviewZoom),null,null,160,120) ;
  ov.setCollapsible(true, true);
  mapview.addMapDecoration(ov);

  // Display the map
  mapview.display();
}

// --------------------------------------------------------------------------------
// getURLParameters()
// Parse the parameters passed to the HTML page
// Each parameter gets assigned to a variable called <parameter name>
//
// NOTE: parameter names are case sensitive, because JavaScript variables are case
// sensitive. Make sure to pass the names correctly: for example "baseLayerName" and
// not "baselayername"
// --------------------------------------------------------------------------------
function getURLParameters()
{
  var sURL = window.document.URL.toString();

  if (sURL.indexOf("?") > 0)
  {
    var arrParams = sURL.split("?");
    var arrURLParams = arrParams[1].split("&");
    var arrParamNames = new Array(arrURLParams.length);
    var arrParamValues = new Array(arrURLParams.length);
    var i = 0;
    for (var i=0;i<arrURLParams.length;i++)
    {
      var sParam =  arrURLParams[i].split("=");
      if (sParam[1] == "true" | sParam[1] == "false")
        eval (sParam[0] + "=" + sParam[1]);
      else if (isNumber(sParam[1]))
        eval (sParam[0] + "=" + sParam[1]);
      else
        eval (sParam[0] + "='" + sParam[1] + "'");
      // alert ("Parameter["+i+"] "+sParam[0]+" = "+sParam[1]);
    }
  }
}
function isNumber(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}
