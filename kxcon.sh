#!/bin/bash
echo Starting Network

q ~/kxconscripts/loadbalancer.q -p 1234 &

sleep 1

q ~/kxconscripts/kxcon.q &

