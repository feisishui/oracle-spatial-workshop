#!/bin/bash
cd "$(dirname "$0")"

las2oci --input ../../../../data/16-3D-support/02-point_clouds/Serpent_Mound_Model_LAS_Data.las --connection scott/tiger@localhost:1521/orcl112 --base-table-name LIDAR_SCENES --cloud-column-name POINT_CLOUD --block-table-name PC_BLK_01  --block-capacity 10000 --srid 32617 --verbose

read -p "Hit return to continue... "
