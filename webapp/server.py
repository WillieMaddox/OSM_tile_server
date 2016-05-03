#!/usr/bin/env python

import BaseHTTPServer
import CGIHTTPServer
import cgitb

cgitb.enable()  ## This line enables CGI error reporting

server = BaseHTTPServer.HTTPServer
handler = CGIHTTPServer.CGIHTTPRequestHandler
server_address = ("gis.local.osm", 8050)
# handler.cgi_directories = ["/"]
httpd = server(server_address, handler)
print '*******************************'
print '** Server: {}   **'.format(server_address[0])
print '** Port:   {}              **'.format(server_address[1])
print '*******************************'
print 'Ready...'
httpd.serve_forever()