-- (Run as SYSTEM or MDSYS)

UPDATE mdsys.openlsservices
SET url = 'http://localhost:8888/mapviewer/omserver'
WHERE service = 'Presentation Service';
COMMIT;
