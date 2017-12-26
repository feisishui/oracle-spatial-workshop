set serveroutput on

-- exec sdo_router_ws.set_trace('TRUE');

/*
-- Route between two geographical locations, default options
select sdo_router_ws.get_route (
  sdo_geometry(2001,4326,sdo_point_type(-122.4014128, 37.7841193, null), null, null),
  sdo_geometry(2001,4326,sdo_point_type(-122.4183326, 37.8059999, null), null, null)
) from dual;

-- Route between two geographical locations, time and distance only
select sdo_router_ws.get_route (
  sdo_geometry(2001,4326,sdo_point_type(-122.4014128, 37.7841193, null), null, null),
  sdo_geometry(2001,4326,sdo_point_type(-122.4183326, 37.8059999, null), null, null),
  sdo_keywordarray (
    'route_preference="fastest"',
    'distance_unit="km"',
    'time_unit="second"'
  )
) from dual;

-- Route between two geographical locations, with driving directions
select sdo_router_ws.get_route (
  sdo_geometry(2001,4326,sdo_point_type(-122.4014128, 37.7841193, null), null, null),
  sdo_geometry(2001,4326,sdo_point_type(-122.4183326, 37.8059999, null), null, null),
  sdo_keywordarray (
    'route_preference="fastest"',
    'return_driving_directions="true"',
    'distance_unit="km"',
    'time_unit="second"'
  )
) from dual;

-- Route between two geographical locations, with road geometry
select sdo_router_ws.get_route (
  sdo_geometry(2001,4326,sdo_point_type(-122.4014128, 37.7841193, null), null, null),
  sdo_geometry(2001,4326,sdo_point_type(-122.4183326, 37.8059999, null), null, null),
  sdo_keywordarray (
    'route_preference="fastest"',
    'return_route_geometry="true"',
    'distance_unit="km"',
    'time_unit="second"'
  )
) from dual;

-- Route between two addresses, time and distance only
select sdo_router_ws.get_route (
  sdo_keywordarray (
    '747 Howard Street',
    'San Francisco, CA',
    'US'
  ),
  sdo_keywordarray (
    '1300 Columbus',
    'San Francisco, CA',
    'US'
  ),
  sdo_keywordarray (
    'route_preference="fastest"',
    'distance_unit="km"',
    'time_unit="second"'
  )
) from dual;

-- Route between two geocoded addresses, time and distance only
select sdo_router_ws.get_route (
  sdo_gcdr.geocode(user, sdo_keywordarray ('747 Howard Street','San Francisco, CA'),'US','default'),
  sdo_gcdr.geocode(user, sdo_keywordarray ('1300 Columbus','San Francisco, CA'),'US','default'),
  sdo_keywordarray (
    'route_preference="fastest"',
    'distance_unit="km"',
    'time_unit="second"'
  )
) from dual;
*/
-- Route between two geocoded addresses, time and distance only
select sdo_router_ws.get_route (
  sdo_gcdr_ws.geocode(sdo_keywordarray ('747 Howard Street','San Francisco, CA'),'US','default'),
  sdo_gcdr_ws.geocode(sdo_keywordarray ('1300 Columbus','San Francisco, CA'),'US','default'),
  sdo_keywordarray (
    'route_preference="fastest"',
    'distance_unit="km"',
    'time_unit="second"'
  )
) from dual;
