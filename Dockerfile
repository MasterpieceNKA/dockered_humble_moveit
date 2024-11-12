FROM osrf/ros:humble-desktop-full

# Add ubuntu user with same UID and GID as your host system, if it doesn't already exist
# Since Ubuntu 24.04, a non-root user is created by default with the name vscode and UID=1000
ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN if ! id -u $USER_UID >/dev/null 2>&1; then \
        groupadd --gid $USER_GID $USERNAME && \
        useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME; \
    fi
# Add sudo support for the non-root user
RUN apt-get update && \
    apt-get install -y sudo && \
    echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Switch from root to user
USER $USERNAME

# Add user to video group to allow access to webcam
RUN sudo usermod --append --groups video $USERNAME

# Update all packages
RUN sudo apt update && sudo apt upgrade -y

# Install Git
RUN sudo apt install -y \
    build-essential \
    cmake \
    git \
    nano \
    ntp \
    python3-colcon-common-extensions \
    python3-colcon-mixin \
    python3-flake8 \
    python3-rosdep \
    python3-setuptools \
    python3-vcstool \
    ros-humble-rmw-cyclonedds-cpp \
    wget

# Update all packages
RUN sudo apt update && sudo apt dist-upgrade -y && sudo apt upgrade -y

# Rosdep update
RUN rosdep update

# Source the ROS setup file
RUN echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >> ~/.bashrc
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
RUN echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc

# Install MoveIT
ARG SETUP_FILE=./moveit2_humble_setup.sh
RUN sudo wget 'https://gist.githubusercontent.com/MasterpieceNKA/28e10beee8f10c2a41228d8a7fb8348d/raw/8091094222c342e331adf2ed9da2710274749335/moveit2_humble_setup.sh' 
RUN sudo chmod +x $SETUP_FILE
RUN sudo chown $USERNAME $SETUP_FILE
RUN $SETUP_FILE

################################
## ADD ANY CUSTOM SETUP BELOW ##
################################
#RUN sudo wget \
#    "https://gist.githubusercontent.com/MasterpieceNKA/1d8fd9ddc2e9d7bad3aa0102667fd7cd/raw/d98413fcd7ede9ed9551e3f0a974ca7d64abe890/docker_ros2_entrypoint.sh" \
#    -O /docker_ros2_entrypoint.sh
#RUN sudo chmod +x /docker_ros2_entrypoint.sh
#RUN sudo chown $USERNAME /docker_ros2_entrypoint.sh
ENTRYPOINT ["/bin/bash", "/entrypoint.sh" ] 
CMD ["bash"] 

