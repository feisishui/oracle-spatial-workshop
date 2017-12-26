#!/bin/bash -x
ogrinfo -al -so OCI:scott/tiger@127.0.0.1:1521/orcl122:us_cities
ogrinfo -al -so OCI:scott/tiger@127.0.0.1:1521/orcl122:us_counties
ogrinfo -al -so OCI:scott/tiger@127.0.0.1:1521/orcl122:us_states
ogrinfo -al -so OCI:scott/tiger@127.0.0.1:1521/orcl122:us_interstates
ogrinfo -al -so OCI:scott/tiger@127.0.0.1:1521/orcl122:us_parks
ogrinfo -al -so OCI:scott/tiger@127.0.0.1:1521/orcl122:us_rivers
ogrinfo -al -so OCI:scott/tiger@127.0.0.1:1521/orcl122:world_countries
ogrinfo -al -so OCI:scott/tiger@127.0.0.1:1521/orcl122:world_continents
read -p "Hit return to continue... "

