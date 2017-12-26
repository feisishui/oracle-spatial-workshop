UPDATE mdsys.openlsservices
SET url = 'http://localhost:8888/routeserver/servlet/RouteServerServlet'
WHERE service = 'Route Service';
COMMIT;
