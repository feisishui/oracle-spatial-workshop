-- This is an address in french
exec format_addr_array(sdo_gcdr.geocode_all (user, sdo_keywordarray('Avenue du Bois Soleil, 62', 'Kraainem'), 'BE', 'default'))
-- The exact same place, using the flemish name.
exec format_addr_array(sdo_gcdr.geocode_all (user, sdo_keywordarray('Zonneboslaan, 62', 'Kraainem'), 'BE', 'default'))
