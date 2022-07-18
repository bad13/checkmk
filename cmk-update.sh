#!/bin/bash
# create by me
# version 1.1 (30.01.2022)

# check the installed release and codename, define variables to build the url-string
# current_release="$(lsb_release -rs)"# rs = release in short description
current_codename="$(lsb_release -cs)"_amd64.deb # cs = codename in short description
site=$(omd sites --bare)
current_version=$(omd version --bare)

# giving some short infos
echo -e
echo -e "\e[1;46m INFO: Auf diesem Server läuft die Site $site in der Version $current_version\e[0m"
echo -e

# set patchlevel and sublevel for setting download urls
patchlevel=6 # set this to your desired patchlevel
subpatchlevel=_0 # set this to your desired subpatchlevel - normally always _0

# download the desired cmk-server-version from cmk-website
echo -e "\e[1;42m DOWNLOAD CHECKMK-SERVER \e[0m"
wget https://download.checkmk.com/checkmk/2.1.0p$patchlevel/check-mk-raw-2.1.0p$patchlevel$subpatchlevel.$current_codename

# installation cmk-server raw edition
echo -e "\e[1;42m INSTALL CHECKMK-SERVER \e[0m"
apt install -y ./check-mk-raw-2.1.0p$patchlevel$subpatchlevel.$current_codename

# stop the current running cmk-site
echo -e "\e[1;42m STOP SITE \e[0m" $site
omd stop $site

# update the current stopped cmk-site
echo -e "\e[1;42m UPDATE SITE \e[0m" $site
omd -f update --conflict=install $site 

# start the cmk-site
echo -e "\e[1;42m START SITE \e[0m" $site
omd start $site

# define variables
new_version=$(omd version --bare)

# installation cmk-agent
echo -e "\e[1;42m INSTALL CHECKMK-AGENT \e[0m"
patchlevel=6 # set this to your desired patchlevel
cd /opt/omd/versions/$new_version/share/check_mk/agents
sudo apt install -y ./check-mk-agent_2.1.0p$patchlevel-1_all.deb

# giving some short infos
echo -e
echo -e "\e[1;46m INFO: Die Site $site läuft jetzt in der Version: $new_version \e[0m"
echo -e
