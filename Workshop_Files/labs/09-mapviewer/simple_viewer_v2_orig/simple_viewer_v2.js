var baseURL;
var map;
var tileLayer
var dataLayer;

function showMap()
{
  // Setup map environment
  baseURL = "/mapviewer";
  map = new OM.Map(
    document.getElementById('map'),
    {
        mapviewerURL: baseURL
    }
  );
  
  // Setup base tile layer
  tileLayer = new OM.layer.TileLayer(
    "baseMap", 
    {dataSource:"scott", tileLayer:"us_base_map"}
  );
  map.addLayer(tileLayer) ; 
  
  // Setup vector layer
  dataLayer = new OM.layer.VectorLayer(
    "cities", 
    {
      def:{
          type:OM.layer.VectorLayer.TYPE_PREDEFINED, 
          dataSource:"scott", theme:"us_cities"
      }
    }
  );  
  map.addLayer(dataLayer) ;

  // Add copyright notice
  var copyright = new OM.control.CopyRight({
    anchorPosition:5,
    textValue:"(C) 2016 Oracle and its affiliates"
  });
  map.addMapDecoration(copyright);

  // Add  scale bar
  var mapScaleBar = new OM.control.ScaleBar({format:"BOTH",maxWidth:165});
  map.addMapDecoration(mapScaleBar);

  // Show the map at the desired location
  map.setMapCenter(new OM.geometry.Point(-122.45,37.6706,8307) );
  map.setMapZoomLevel(4);
  map.init() ;
}

function printMap() {
  map.print();
}

function printWindow() {
  window.print();
}

function getMapImage() {
  map.getMapAsServerImage(
    function(result){getMapURL(result)},
    0,
    0,
    {navigationPanelBar:false, scaleBar:true, copyRight:true}
  )
}

function getMapURL(urlStr){
  var w = window.open(urlStr);
  w.print();
}