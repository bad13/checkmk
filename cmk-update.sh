#!/bin/bash
# create by Dennis Suhl
# version 0.1 (11.10.21)

# define variables
site=$(omd sites --bare)
current_version=$(omd version --bare)

# giving some short infos
echo -e
echo -e "\e[1;46m INFO: Auf diesem Server läuft die Site $site in der Version $current_version\e[0m"
echo -e

# set patchlevel and sublevel for setting download urls
patchlevel=15 # set this to your desired patchlevel
subpatchlevel=_0 # set this to your desired subpatchlevel - normally always _0

# download the desired cmk-server-version from cmk-website
echo -e "\e[1;42m DOWNLOAD CHECKMK-SERVER \e[0m"
wget https://download.checkmk.com/checkmk/2.0.0p$patchlevel/check-mk-raw-2.0.0p$patchlevel$subpatchlevel.focal_amd64.deb

# installation cmk-server raw edition
echo -e "\e[1;42m INSTALL CHECKMK-SERVER \e[0m"
apt install -y ./check-mk-raw-2.0.0p$patchlevel$subpatchlevel.focal_amd64.deb

# stop the current running cmk-site
echo -e "\e[1;42m STOP SITE \e[0m" $site
omd stop $site

# update the current stopped cmk-site
echo -e "\e[1;42m UPDATE SITE \e[0m" $site
omd -f update --conflict=install $site 

# start the cmk-site
echo -e "\e[1;42m START SITE \e[0m" $site
omd start $site

# download the agent from the master-site in azure
echo -e "\e[1;42m DOWNLOAD CHECKMK-AGENT \e[0m"
wget https://mon.azure.pkd.haus/azure/check_mk/agents/check-mk-agent_2.0.0p$patchlevel-1_all.deb

# installation cmk-agent
echo -e "\e[1;42m INSTALL CHECKMK-AGENT \e[0m"
apt install -y ./check-mk-agent_2.0.0p$patchlevel-1_all.deb

# define variables
new_version=$(omd version --bare)

# giving some short infos
echo -e
echo -e "\e[1;46m INFO: Die Site $site läuft jetzt in der Version: $new_version \e[0m"
echo -e