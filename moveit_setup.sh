#!/bin/bash 

# Setup MoveIT 
colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml
colcon mixin update default

source /opt/ros/$ROS_DISTRO/setup.bash

export COLCON_WS=~/ws_moveit2
mkdir -p $COLCON_WS/src

# Setup MoveIT
cd $COLCON_WS/src
git clone -b $ROS_DISTRO https://github.com/moveit/moveit2.git 
for repo in moveit2/moveit2.repos $(f="moveit2/moveit2_$ROS_DISTRO.repos"; test -r $f && echo $f); do vcs import < "$repo"; done
rosdep install -r --from-paths . --ignore-src --rosdistro $ROS_DISTRO -y

cd $COLCON_WS
#colcon build --mixin release --event-handlers desktop_notification- status-  --executor sequential --cmake-args -DCMAKE_BUILD_TYPE=Release
colcon build --event-handlers desktop_notification- status-  --executor sequential --cmake-args -DCMAKE_BUILD_TYPE=Release

source $COLCON_WS/install/setup.bash

# Setup MoveIT Tutorials
cd $COLCON_WS/src
git clone  --recurse-submodule https://github.com/moveit/moveit2_tutorials.git -b $ROS_DISTRO
vcs import < moveit2_tutorials/moveit2_tutorials.repos --recursive
rosdep install -r --from-paths . --ignore-src --rosdistro $ROS_DISTRO -y 

cd $COLCON_WS
#colcon build --mixin release --event-handlers desktop_notification- status-  --executor sequential --cmake-args -DCMAKE_BUILD_TYPE=Release
colcon build --event-handlers desktop_notification- status-  --executor sequential --cmake-args -DCMAKE_BUILD_TYPE=Release

echo "source $COLCON_WS/install/setup.bash" >> ~/.bashrc 

source ~/.bashrc  


