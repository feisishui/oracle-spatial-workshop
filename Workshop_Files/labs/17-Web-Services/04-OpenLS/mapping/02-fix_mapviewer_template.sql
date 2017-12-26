-- (Run as SYSTEM or MDSYS)

-- Remove title from maps
UPDATE mdsys.openls_nodes
SET openls = REPLACE (openls,'title="Oracle OpenLS Map"','')
WHERE name = 'Oracle Mapviewer request';
COMMIT;

-- Remove invalid schema location from map and router responses
UPDATE mdsys.openls_nodes
SET openls = REPLACE (openls,'xsi:schemaLocation="http://www.opengis.net/xls C:\WebServicesProject\OPENLS~2\PresentationService.xsd"','')
WHERE name in  ('map response', 'route response');
COMMIT;
