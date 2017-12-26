set serveroutput on

-- Full address
exec format_geo_addr (SDO_GCDR.GEOCODE(user, SDO_KEYWORDARRAY('Alexanderplatz', 'D-10178 Berlin'), 'DE', 'DEFAULT'))
exec format_geo_addr (SDO_GCDR.GEOCODE(user, SDO_KEYWORDARRAY('Bernauerstrasse', 'Berlin'), 'DE', 'DEFAULT'))
exec format_geo_addr (SDO_GCDR.GEOCODE(user, SDO_KEYWORDARRAY('Bernauer strasse', 'Berlin'), 'DE', 'DEFAULT'))
exec format_geo_addr (SDO_GCDR.GEOCODE(user, SDO_KEYWORDARRAY('Bernauer-strasse', 'Berlin'), 'DE', 'DEFAULT'))
