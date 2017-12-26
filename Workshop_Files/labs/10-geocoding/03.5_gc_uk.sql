set serveroutput on
-- Incomplete address
exec format_geo_addr (SDO_GCDR.GEOCODE(user, SDO_KEYWORDARRAY('High Street', 'Maidenhead'), 'UK', 'DEFAULT'))

-- Full address
exec format_geo_addr (SDO_GCDR.GEOCODE(user, SDO_KEYWORDARRAY('Star House', '20 Grenfell Road', 'Maidenhead SL6 1EH'), 'GB', 'DEFAULT'))

-- Invalid postal code
exec format_geo_addr (SDO_GCDR.GEOCODE(user, SDO_KEYWORDARRAY('Star House', '20 Grenfell Road', 'Maidenhead SL8 1EH'), 'GB', 'DEFAULT'))

-- Spelling mistake
exec format_geo_addr (SDO_GCDR.GEOCODE(user, SDO_KEYWORDARRAY('20 Grenfal Rd', 'Maidenhead'), 'GB', 'DEFAULT'))

exec format_geo_addr (SDO_GCDR.GEOCODE(user, SDO_KEYWORDARRAY('Cowley Road', 'Cambridge', 'CB4 0WS'), 'GB', 'DEFAULT'))
exec format_geo_addr (SDO_GCDR.GEOCODE(user, SDO_KEYWORDARRAY('Barton Road', 'Barton', 'Cambridge', 'CB3'), 'GB', 'DEFAULT'))
exec format_geo_addr (SDO_GCDR.GEOCODE(user, SDO_KEYWORDARRAY('Barton Road', 'Cambridge', 'CB3'), 'GB', 'DEFAULT'))
