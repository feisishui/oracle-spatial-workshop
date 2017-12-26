#!/usr/bin/python

import os
import sys
import csv
import httplib
import xml.dom.minidom

"""
/*

NAME:
    geocode.py

LAST UPDATE:
    22-Jul-2016

DESCRIPTION:

  The input file is CSV file with the following structure
  
  id, address line 1, address line 2, address line n, country
  
  For example:
  
  1,Clay Street,"San Francisco, CA",US
  2,1350 Clay Street,"San Francisco, CA",US
  3,"15 rue de la Paix", "Paris", "France"

  An unformatted geocoding request looks like this. It can
  contain any number of address lines

  <geocode_request>
    <address_list>
      <input_location id="1">
        <input_address match_mode="default">
          <unformatted country="US" >
            <address_line value="1300 Columbus" />
            <address_line value="San Francisco, CA" />
          </unformatted >
        </input_address>
      </input_location>
    </address_list>
  </geocode_request>

CHANGE HISTORY:

  MODIFIED     (DD-MON-YYYY)  DESCRIPTION
  agodfrin      22-Jul-2016   Created 
  
TODO:

*/
"""

#----------------------------------------------------------------
# Global variables
#----------------------------------------------------------------


#----------------------------------------------------------------
# Process one address
#----------------------------------------------------------------
def process_address(address):
  HOST = 'elocation.oracle.com'
  API_URL = '/elocation/lbs'
  DEBUG_LEVEL = 0
  
  xml_request = (
    '<geocode_request>'
    ' <address_list>'
    '  <input_location id="%s">'
    '   <input_address match_mode="default">'
    '    <unformatted country="%s" >'
    '      <address_line value="%s" />'
    '      <address_line value="%s" />'
    '     </unformatted >'
    '   </input_address>'
    '  </input_location>'
    ' </address_list>'
    '</geocode_request>'
  ) % (row[0], row[len(row)-1], row[1], row[2])
 
  print (xml_request)

  params = ("xml_request=%s" % (xml_request))
  headers = {"Content-type": "application/x-www-form-urlencoded","Accept": "text/plain"}
  conn = httplib.HTTPConnection(HOST)
  conn.set_debuglevel(DEBUG_LEVEL)
  conn.request("POST", API_URL, params, headers)
  response = conn.getresponse()
  data = response.read()
  xml_response = xml.dom.minidom.parseString(data)  
  
  print (xml_response.toprettyxml())
  
  conn.close()



#----------------------------------------------------------------
# Main process
#----------------------------------------------------------------

addresses = open('addresses.csv')
address_reader = csv.reader(addresses,skipinitialspace=True)
for row in address_reader:
  process_address(row)
addresses.close()