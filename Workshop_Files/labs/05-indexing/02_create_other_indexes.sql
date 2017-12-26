drop index us_cities_city_state;
drop index us_cities_state_city;
drop index us_counties_county_state;
drop index us_counties_state_county;
drop index us_interstates_name;
drop index us_parks_name;
drop index us_rivers_name;
drop index us_states_state;
drop index us_states_state_abrv;

drop index us_cities_p_city_state;
drop index us_cities_p_state_city;
drop index us_counties_p_county_state;
drop index us_counties_p_state_county;
drop index us_interstates_p_name;
drop index us_parks_p_name;
drop index us_rivers_p_name;
drop index us_states_p_state;
drop index us_states_p_state_abrv;

create unique index us_cities_city_state on us_cities (city, state_abrv);
create unique index us_cities_state_city on us_cities (state_abrv, city);
create unique index us_counties_county_state on us_counties (county, state);
create unique index us_counties_state_county on us_counties (state, county);
create unique index us_interstates_k on us_interstates (interstate);
create        index us_parks_name on us_parks (name);
create unique index us_rivers_name on us_rivers (name);
create unique index us_states_state on us_states (state);
create unique index us_states_state_abrv on us_states (state_abrv);

create unique index us_cities_p_city_state on us_cities_p (city, state_abrv);
create unique index us_cities_p_state_city on us_cities_p (state_abrv, city);
create unique index us_counties_p_county_state  on us_counties_p (county, state);
create unique index us_counties_p_state_county on us_counties_p (state, county);
create unique index us_interstates_p_name on us_interstates_p (interstate);
create        index us_parks_p_name on us_parks_p (name);
create unique index us_rivers_p_name on us_rivers_p (name);
create unique index us_states_p_state on us_states_p (state);
create unique index us_states_p_state_abrv on us_states_p (state_abrv);
