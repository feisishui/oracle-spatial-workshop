var baseURL;
var map;
var tileLayer

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
    "us_base_map", 
    {dataSource:"scott", tileLayer:"us_base_map"}
  );
  map.addLayer(tileLayer); 

  // Setup vector layer
  dataLayer = new OM.layer.VectorLayer(
    "area_2_mosaic_sdp", 
    {
      def:{
          type:OM.layer.VectorLayer.TYPE_PREDEFINED, 
          dataSource:"scott", theme:"area_2_mosaic_sdp"
      }
    }
  );  
  map.addLayer(dataLayer) ;
  
  // Add navigation panel
  map.addNavigationPanelBar();
  
  // Add toolbar with all buttons
  var toolbar = new OM.control.ToolBar("toolbar",{builtInButtons:[OM.control.ToolBar.BUILTIN_ALL]});
  toolbar.setPosition(0.45,0.05);
  map.addToolBar(toolbar);
  
  // Add copyright notice
  var copyright = new OM.control.CopyRight({
    anchorPosition:5,
    textValue:"(C) 2016 Oracle and its affiliates"
  });
  map.addMapDecoration(copyright);

  // Add  scale bar
  var mapScaleBar = new OM.control.ScaleBar(
    {
      format:"BOTH",
      // 1:UPPER_LEFT,2:UPPER_CENTER,3:UPPER_RIGHT,4:LOWER_LEFT,5:LOWER_CENTER,6:LOWER_RIGHT
      anchorPosition:4, 
      style:{
        fontSize:"16",
        fontColor:"white",
        scaleBarColor:"#cccccc", // ignored!
        maxLength:50,
        boxShadow:"0px 0px 0px 4px #cccccc" // ignored!
      }
    }
  );
  map.addMapDecoration(mapScaleBar);

  // Show the map at the desired location
  map.setMapCenter(new OM.geometry.Point(37.2402057, 26.0190044,8307) );
  map.setMapZoomLevel(5);
  map.init() ;
}

function getMapXML() {
  map.getMapAsXML(
    'JPEG_URL',
    function(result){showMapXML(result)}
  );
}

function showMapXML (xmlReq) {
  alert ("Zoom level:"+map.getMapZoomLevel()+" XML Size:"+xmlReq.length);
  // alert (xmlReq);
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
