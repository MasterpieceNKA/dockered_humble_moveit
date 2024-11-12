#!/bin/bash

set -e

# Do all the needed sourcing in ~/.bashrc file 
#source /opt/ros/humble/setup.bash

echo "Provided arguments: $@"

exec $@