#!/usr/bin/bash

#roma
cd ~/Git
mkdir -p rtd2821
cd rtd2821
git clone git@gitlab-partner.tools.roku.com:rtd2821/bootcode.git
git clone git@gitlab-partner.tools.roku.com:rtd2821/platform.git
git clone git@gitlab-partner.tools.roku.com:rtd2821/rokuOS.git

#reno
cd ~/Git
mkdir -p rtd2873
cd rtd2873
git clone git@gitlab-partner.tools.roku.com:rtd2873/bootcode.git
git clone git@gitlab-partner.tools.roku.com:rtd2873/platform.git
git clone git@gitlab-partner.tools.roku.com:rtd2873/rokuOS.git
git clone git@gitlab-partner.tools.roku.com:rtd2873/uboot.git

#rokumfg
cd ~/Git
mkdir -p rokumfg
cd rokumfg
git clone git@gitlab.eng.roku.com:rokumfg/mfg-apps.git

#ooba-data
cd ~/Git
mkdir -p web-product
cd web-product
git clone git@gitlab.eng.roku.com:web-product/ooba-data.git
