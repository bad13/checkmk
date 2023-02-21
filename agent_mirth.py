#!/usr/bin/env python
# Mirth Datasource Program (Special Agent) for Check_MK
# Tested on Check_MK CEE 1.5 and 1.6
# Author : ricardo.ribeiro@axians.com
# -*- coding: utf-8 -*-

import requests
import json
import getopt
import sys
import xmltodict
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

opt_host = None
opt_user = None
opt_secret = None
opt_port = None
opt_follow = None

def usage():
    sys.stderr.write("""Check_MK Mirth Stats Collector
USAGE: agent_mirth [OPTIONS] HOST
       agent_mirth -h

ARGUMENTS:
  HOST                                                  Host name or IP address of Mirth system

OPTIONS:
  -h, --help                                            Show this help message and exit
  -u USER, --user USER                                  Username for Mirth API login (if used)
  -s SECRET, --secret PASSWORD                          Password for Mirth API login (if used)
  -p PORT, --port PORT                                  Port for Mirth API login
""")

short_options = "hh:u:s:p:"
long_options = [ "help", "user=", "secret=", "port=" ]

try:
    opts, args = getopt.getopt( sys.argv[1:], short_options, long_options )
except getopt.GetoptError as err:
    sys.stderr.write("%s\n" % err)
    sys.exit(1)

for opt, arg in opts:
 if opt in ['-h', '--help']:
  usage()
  sys.exit(0)
 elif opt in ["-u", "--user"]:
  opt_user = arg
 elif opt in ["-s", "--secret"]:
  opt_secret = arg
 elif opt in ["-p", "--port"]:
  opt_port = arg
 elif not opt:
  usage()
  sys.exit(0)

if len(args) == 1:
    opt_host = args[0]
elif not args:
    sys.stderr.write("ERROR: No host given.\n")
    sys.exit(1)
else:
    sys.stderr.write("ERROR: Please specify exactly one host.\n")
    sys.exit(1)

def composeURL(mirth_hostname, mirth_port, mirth_channel=False):
    channel_status_api_url = "https://%s:%s/api/channels/%s/status" % (mirth_hostname, mirth_port, mirth_channel)
    names_api_url = "https://%s:%s/api/channels/idsAndNames" % (mirth_hostname, mirth_port)
    stats_api_url = "https://%s:%s/api/channels/statistics" % (mirth_hostname, mirth_port)
    return names_api_url, stats_api_url, channel_status_api_url

def convertXMLtoJSON(xml_dump):
    data_dict = xmltodict.parse(xml_dump)
    json_data = json.loads(json.dumps(data_dict))
    return json_data

try:
    mirthURLs=composeURL(opt_host, opt_port)
    sys.stdout.write("<<<mirth_stats>>>\n")

    # Mirth Channels names and IDs

    names = requests.get(mirthURLs[0], verify=False, auth=(opt_user, opt_secret))
    namesLoad = convertXMLtoJSON(names.content)
    for item in namesLoad:
        for entry in namesLoad[item]:
            finalDict  = { line["string"][0] : line["string"][1] for line in namesLoad[item][entry]}

    # Mirth Channel Statistics

    stats = requests.get(mirthURLs[1], verify=False, auth=(opt_user, opt_secret))
    statsLoad = convertXMLtoJSON(stats.content)
    for item in statsLoad:
        for list in statsLoad[item]:
            for channel in statsLoad[item][list]:
                if channel['channelId'] in finalDict:

                                        # Mirth Channels Status

                                        channel_status = requests.get(composeURL(opt_host, opt_port,channel['channelId'])[2], verify=False, auth=(opt_user, opt_secret))
                                        statusLoad=convertXMLtoJSON(channel_status.content)
                                        for item in statusLoad:
                                            for subitem in statusLoad[item]:
                                                if subitem == "state":
                                                    channelState=statusLoad[item][subitem]
                                                    print("%s %s %s %s %s %s %s" % ( finalDict[channel['channelId']], channelState, channel['received'], channel['error'], channel['filtered'], channel['queued'], channel['sent']))

except Exception as  e:
    sys.stderr.write(str(e))