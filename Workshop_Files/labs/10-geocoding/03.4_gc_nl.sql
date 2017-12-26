-- Wrong postal code
exec format_addr_array(sdo_gcdr.geocode_all(user,  SDO_KEYWORDARRAY('Kennedy Laan', '3451 Utrecht'),  'NL', 'DEFAULT'))
-- Full address 
exec format_addr_array(sdo_gcdr.geocode_all(user,  SDO_KEYWORDARRAY('Multatulistraat 45', 'NL-3451 Utrecht'),  'NL', 'DEFAULT'))
