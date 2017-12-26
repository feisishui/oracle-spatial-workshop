CREATE OR REPLACE TYPE point AS OBJECT (
  x                     NUMBER,  -- X                     
  y                     NUMBER,  -- Y                     
  z                     NUMBER,  -- Z                     
  intensity             NUMBER,  -- i = Intensity             
  return_number         NUMBER,  -- r = Return Number         
  number_of_returns     NUMBER,  -- n = Number of Returns     
  scan_direction        NUMBER,  -- d = Scan Direction        
  edge_of_flight_line   NUMBER,  -- e = Flightline Edge       
  classification        NUMBER,  -- c = Classification        
  scan_angle            NUMBER,  -- a = Scan Angle Rank       
  user_data             NUMBER,  -- u = User Data             
  point_source_id       NUMBER,  -- p = Point Source ID       
  gpstime               NUMBER   -- t = Time                  
);
/

CREATE OR REPLACE TYPE points AS TABLE OF point;
/
