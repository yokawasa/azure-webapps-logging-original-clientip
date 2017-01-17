#!/bin/sh

HEADER_NAME="X-Forwarded-For"
#HEADER_NAME="Custom-Header-Name"
CLIENT_IP='192.168.0.1'
URL="http:///<appname>.azurewebsites.net"

curl -X GET -H "$HEADER_NAME: $CLIENT_IP" $URL
