#!/bin/bash
echo Starting Clients

q ~/kxconscripts/client.q  -size 1 -gw ::5559 -t 4000 &

q ~/kxconscripts/client.q  -size 1 -t 2000 &

q ~/kxconscripts/client.q  -size 2 -gw ::5559 -t 2000 &

q ~/kxconscripts/client.q  -size 1 -t 3000 &

q ~/kxconscripts/client.q -service REPORT_SERVER -size 2 -t 5000 &

q ~/kxconscripts/client.q -service REPORT_SERVER -size 2 -t 5000 -gw ::5559 &

