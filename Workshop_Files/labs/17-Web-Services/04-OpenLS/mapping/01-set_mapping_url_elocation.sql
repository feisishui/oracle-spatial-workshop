-- (Run as SYSTEM or MDSYS)

UPDATE mdsys.openlsservices
SET url = 'http://elocation.oracle.com/mapviewer/omserver'
WHERE service = 'Presentation Service';
COMMIT;
