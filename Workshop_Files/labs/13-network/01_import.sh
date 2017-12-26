#!/bin/bash
cd "`dirname "$0"`"

imp scott/tiger file=../../data/13-network/net_data.dmp tables="(net_nodes,net_links)"

read -p "Hit return to continue... "
