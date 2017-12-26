==========================================================
Spatial Queries
==========================================================

Perform the following spatial queries


* Spatial (topôlogy) searches

-- Which parks interact with the state of Wyoming ?
01_PARKS_INTERACT_WY.SQL

-- Which states does Yellowstone National Park overlap ?
02_STATES_INTERACT_YNP.SQL

-- Which counties belong to the states of Colorado, New Hampshire or New York
03_COUNTIES_IN_STATE.SQL

-- Get all cities outside California
04_DISJOINT.SQL


* "Within Distance" searches

-- Get the cities that are within 100 miles of Boston
05_CITIES_WD_CITY.SQL

-- Get the cities that are further than 15 miles from an interstate.
06_NOT_WITHIN_DISTANCE.SQL


* "Nearest Neighbours" searches

-- Get the five nearest cities to I170
07_CITIES_NN_I170.SQL

-- Get the five nearest cities to I170 with a population of over 300,000
08_CITIES_NN_I170_POP.SQL

-- Get the five nearest cities to the state of California
09_CITIES_NN_CA.SQL

-- Get the five cities nearest to Washington, DC, but within a chosen region 
10_CITIES_NN_GEOM.SQL


* Spatial joins

-- Perform various spatial joins
11_JOINS.SQL

-- Relate cities and counties
12_ASSOCIATE_CITIES_COUNTIES.SQL


* Combine spatial and text queries

-- Combine multiple predicates (spatial and non-spatial)
13_COMBINE.SQL
