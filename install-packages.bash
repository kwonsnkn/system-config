#!/usr/bin/bash

# add the git ppa to get the latest git
sudo add-apt-repository -y ppa:git-core/ppa

# Packages required by the RokuOS firmware build
# keep in alphabetical order
sudo apt-get update
sudo apt install -y \
  automake \
  bc \
  bison \
  bsdmainutils \
  build-essential \
  chrpath \
  clang \
  cmake \
  cpio \
  curl \
  device-tree-compiler \
  diffstat \
  dos2unix \
  doxygen \
  flex \
  fuse3 \
  gawk \
  gcc-multilib \
  gettext \
  git \
  gperf \
  graphviz \
  g++-multilib \
  help2man \
  imagemagick \
  kmod \
  libboost-all-dev \
  libflac-dev \
  libncurses5-dev \
  libperl4-corelibs-perl \
  libssh-dev \
  libthread-queue-perl \
  libtool-bin \
  libzstd1 \
  locales \
  netpbm \
  ninja-build \
  nodejs \
  python2 \
  python-cryptography \
  python-is-python3 \
  python3 \
  python3-cryptography \
  python3-pip \
  pkgconf \
  rsync \
  squashfs-tools \
  subversion \
  sudo \
  texinfo \
  unzip \
  vim \
  wget \
  xutils-dev \
  zip \
  zlib1g-dev

sudo locale-gen en_US.UTF-8

sudo dpkg --add-architecture i386

sudo apt-get update
sudo apt install -y \
  libc6:i386 \
  libstdc++-10-dev:i386 \
  zlib1g-dev:i386

sudo pip3 install \
  flatbuffers \
  Mako \
  meson \
  dohq-artifactory \
  pyyaml \
  wget

# set python3 default
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1

#create /opt directory:
sudo chmod a+rw /opt

# packages that are good to have but not required by build
sudo apt-get update
sudo apt install -y \
  ccache \
  colormake \
  ccze \
  git-lfs \
  icecc \
  openssh-server \
  lbzip2 \
  net-tools \
  remake \
  rlwrap \
  screen \
  tftpd-hpa \
  tmux

# docker
sudo apt-get -y remove docker docker-engine docker.io containerd runrc
sudo apt-get update
sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Grand Central Packages
#sudo apt-get update
#sudo apt install -y \
#  npm
#
#npm install -g pkg


# luks2crypt
#apt install -y golang-go
#apt install -y libcryptsetup-dev
#
#apt-get clean

#ETC Packages
sudo apt install -y \
  ctags \
  cscope \
  default-jre \
  fonts-powerline \
  gnuplot \
  jq \
  meld \
  moreutils \
  synaptic \
  tigervnc-standalone-server \
  wmctrl \
  grabserial

# Network traffic monitor
sudo apt install -y iftop bmon tcptrack

#QT
sudo apt install -y qt5-default qt5-doc-html qtbase5-doc-html qtcreator

#Screen capture
sudo apt install -y deepin-screenshot

# VS Code
sudo snap install code --classic
sudo apt-get install -y gdb-multiarch
sudo apt-get install -y expect

#Display manager 
sudo apt install -y lightdm

#minicom
sudo apt install -y minicom

#tftp
sudo apt-get install -y tftpd-hpa tftp-hpa
mkdir -p ~/tftp
chmod 777 -R ~/tftp
sudo chown tftp:tftp ~/tftp

#edit /etc/default/tftpd-hpa
sudo mv /etc/default/tftpd-hpa /etc/default/tftpd-hpa.backup
sudo echo -e "# /etc/default/tftpd-hpa" | sudo tee -a /etc/default/tftpd-hpa
sudo echo -e "TFTP_USERNAME=\"nobody\"" | sudo tee -a /etc/default/tftpd-hpa
sudo echo -e "TFTP_DIRECTORY=\"${HOME}/tftp\"" | sudo tee -a /etc/default/tftpd-hpa
sudo echo -e "TFTP_ADDRESS=\":69\"" | sudo tee -a /etc/default/tftpd-hpa
sudo echo -e "TFTP_OPTIONS=\"--secure --create\"" | sudo tee -a /etc/default/tftpd-hpa

sudo service tftpd-hpa restart

#NFS
sudo apt update
sudo apt-get update
sudo apt-get install -y --install-suggests --show-progress nfs-common nfs-kernel-server
NFS_DIR="${HOME}/nfs"
mkdir -p ${NFS_DIR}
chmod 777 -R ${NFS_DIR}
sudo cp /etc/exports /etc/exports.backup
echo -e "\n\n${NFS_DIR}    *(rw,no_root_squash,sync,no_subtree_check,insecure)\n" | sudo tee -a /etc/exports
sudo ufw disable
sudo exportfs -a
sudo systemctl restart nfs-kernel-server
sudo showmount -e

# Add p4 command line client
# Adds p4 command line
#wget -qO - https://package.perforce.com/perforce.pubkey | sudo apt-key add -
#echo "deb http://package.perforce.com/apt/ubuntu focal release" > /etc/apt/sources.list.d/perforce.list
#apt-get update && apt-get install -y helix-cli

#Rokucommander

#Synergy

#Perforce

#Beyond Compare
