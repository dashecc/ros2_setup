
#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

update() {
	sudo apt update && sudo apt upgrade -y
}


## Update and upgrade existing packages
update

## Check for UTF-8
if locale | grep -qi "UTF-8"; then
	echo -e "${GREEN}UTF-8 is enabled${RESET}"
else
	sudo apt install -y locales
	sudo locale-gen en_US en_US.UTF-8
	sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
	export LANG=en_US.UTF-8
    	export LC_ALL=en_US.UTF-8
	echo -e "${GREEN} UTF-8 enabled successfully{$RESET}"
fi

## Install required repositories

sudo apt install -y software-properties-common
sudo add-apt-repository -y universe

## Install ros2-apt source package

if [ -f /tmp/ros2-apt-source.deb ]; then
	echo "${GREEN}Package ros2-apt-source.deb exists, skipping download{$RESET}"
else
	sudo apt update && sudo apt install curl -y
	ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}')
	curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb"
fi

sudo dpkg -i /tmp/ros2-apt-source.deb

## Install development tools
sudo apt install -y ros-dev-tools

## Update apt repository caches
update

## Install ros2-jazzy-desktop
sudo apt install -y ros-jazzy-desktop

## Source the setup file and add it to .bashrc, so you don't have to manually do it everytime

echo "source /opt/ros/jazzy/setup.bash" >> "$HOME/.bashrc"

## Check that colcon is installed
sudo apt install -y python3-colcon-common-extensions


## Add workspaces
if [ -d "$HOME/ros2_ws/" ]; then
	echo "Workspace folder exists"
else
	echo "Creating workspace"
	mkdir -p "$HOME/ros2_ws/src"
fi

## Change directory to the root of the workspace
cd "$HOME/ros2_ws/"

## Allow the installed files to be changed by changing the files in the source space
colcon build --symlink-install

## Run test
colcon test

if [ -d "$HOME/ros2_ws/install" ]; then
	echo "Sourcing the environment"
	source "$HOME/ros2_ws/install/setup.bash"
	echo "source $HOME/ros2_ws/install/setup.bash" >> "$HOME/bash.rc"
else
	echo "Installation folder doesn't exist"
fi

echo "ROS 2 Jazzy installation is complete!"



