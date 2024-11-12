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
RUN echo "export ROS_LOCALHOST_ONLY=0" >> ~/.bashrc
RUN echo "export ROS_DOMAIN_ID=1" >> ~/.bashrc
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
RUN echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc

# Install MoveIT
COPY moveit_setup.sh /moveit_setup.sh
RUN sudo chmod +x /moveit_setup.sh
RUN sudo chown $USERNAME /moveit_setup.sh
RUN /moveit_setup.sh

################################
## ADD ANY CUSTOM SETUP BELOW ##
################################
COPY entrypoint.sh /entrypoint.sh
RUN sudo chmod +x /entrypoint.sh
RUN sudo chown $USERNAME /entrypoint.sh
ENTRYPOINT ["/bin/bash", "/entrypoint.sh" ] 
CMD ["bash"] 

