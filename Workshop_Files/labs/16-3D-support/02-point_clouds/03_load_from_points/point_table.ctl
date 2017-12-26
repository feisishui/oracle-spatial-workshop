LOAD DATA
  TRUNCATE
  INTO TABLE points
  FIELDS TERMINATED BY ',' (
    x,  
    y,  
    z,  
    intensity,  
    return_number,  
    number_of_returns,  
    scan_direction,  
    edge_of_flight_line,  
    classification,  
    scan_angle,  
    user_data,  
    point_source_id,  
    gpstime                  
 )

