#!/bin/bash
set -e

echo "Listing peers..."
peers=$(curl -s http://localhost:8080/snm-webapp/api/peer)
echo "Peers: $peers"

# Quick Hack: If empty array "[]", create peer
if [[ "$peers" == "[]" ]]; then
    echo "Creating peer 'tester'..."
    curl -s -X POST -d '{"name":"tester"}' http://localhost:8080/snm-webapp/api/peer
    echo ""
    peers=$(curl -s http://localhost:8080/snm-webapp/api/peer)
fi

# Extract peerId using jq if available, else python or grep.
# I'll use python3 for reliability since it's a mac.
peerId=$(echo "$peers" | python3 -c "import sys, json; print(json.load(sys.stdin)[0]['peerId'])")
echo "Using Peer ID: $peerId"

# Start Peer
echo "Starting peer..."
curl -s -X POST "http://localhost:8080/snm-webapp/api/start/$peerId"
echo ""

# Create Channel
echo "Creating channel '#curltest'..."
curl -s -X POST -H "Content-Type: application/json" -d '{"uri":"#curltest", "name":"Curl Test"}' http://localhost:8080/snm-webapp/api/messenger/channels
echo ""

# List Channels to get index
echo "Listing channels..."
channels=$(curl -s http://localhost:8080/snm-webapp/api/messenger/channels)
echo "$channels"

# Sending message
echo "Sending 'Hello CURL'..."
# Assuming we want to target #curltest. We need its index.
# Python to find index of uri #curltest
idx=$(echo "$channels" | python3 -c "import sys, json; 
data = json.load(sys.stdin)
for ch in data['channels']:
    if ch['uri'] == '#curltest':
        print(ch['index'])
        break
")

echo "Channel Index: $idx"

curl -s -X POST -H "Content-Type: application/json" -d "{\"content\":\"Hello CURL\", \"channelIndex\":$idx}" http://localhost:8080/snm-webapp/api/messenger/messages
echo ""

# List Messages
echo "Listing messages for #curltest..."
# # must be encoded as %23 for URL
curl -s "http://localhost:8080/snm-webapp/api/messenger/messages/%23curltest"
