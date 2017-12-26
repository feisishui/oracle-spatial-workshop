UPDATE mdsys.openlsservices
SET url = 'http://elocation.oracle.com/routeserver/servlet/RouteServerServlet'
WHERE service = 'Route Service';
COMMIT;
