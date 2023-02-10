#!/bin/bash
# create by Dennis Suhl
# version 1.0 (18.01.2022) create
# version 1.1 (24.08.2022) add omd cleanup
# version 1.2 (26.08.2022) add omd backup

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDXVVPX8gdhrlJ1mvEqpYr2ivOzn8bGOkzFHxzK9aJpYjzi9IJNVGRkZ7F043uDU7K05yAU53w1grKt0lXlyOmHQ3dScJ62UNX0tc/Cg5q5zkYSo9cHxYTE4kj7CN9pGmkBFu6T8uj6uN73C4jTZVrYFGaj+GQOKm3WWADBnPeRWAAKZYlAky0KByKz2+KiEBfAOy4i+T3ciKse0fjhE3pM1MYB6my8o20P6zc8GVSs0CA6CdpgaYSj7O6XoNCt2xv3BsfTwNRZbcUF+vLqJg3vNTnledzPf1/Hy1CvE7xhdEfA9jqa7PNWnyUXnrxSyAIG8Trc3pMRs1QK6Y9alO/78wAT4YTK6bZ9cSrYQhbkF+yGHvK0kqkQBSZK2jzLrCkGSFJOaykTDIoQMLSqOzhDvkLMqX5Snl2J4dKBBIdY68loicXhrAotQ+bpflYDiLVBBWfeKbKmPNmRG9rCjQTfrJJCbOqm6/yd6vLb5g8nIPZ3bACZY1FjKr58lWB6z/8= ansible-user

# check the installed release and codename, define variables to build the url-string
#current_release="$(lsb_release -rs)"# rs = release in short description
current_codename="$(lsb_release -cs)"_amd64.deb # cs = codename in short description
site=$(omd sites --bare)
current_version=$(omd version --bare)

# giving some short infos
echo -e
echo -e "\e[1;46m INFO: Auf diesem Server läuft die Site $site in der Version $current_version\e[0m"
echo -e

# doing a backup before update
echo -e "\e[1;42m DOING A BACKUP \e[0m"
date=$(date +%d%m%y_%H:%M:%S)
sudo touch backup-cmk-$current_version-$date
sudo omd stop $site
sudo omd backup $site backup-cmk-$current_version-${date}
sudo omd start $site
#sudo mv backup-cmk-$current_version-$date backup-cmk-$current_version-$date_latest

# set patchlevel and sublevel for setting download urls
patchlevel=20 # set this to your desired patchlevel
subpatchlevel=_0 # set this to your desired subpatchlevel - normally always _0

# download the desired cmk-server-version from cmk-website
echo -e "\e[1;42m DOWNLOAD CHECKMK-SERVER \e[0m"
wget https://download.checkmk.com/checkmk/2.1.0p$patchlevel/check-mk-raw-2.1.0p$patchlevel$subpatchlevel.$current_codename

# installation cmk-server raw edition
echo -e "\e[1;42m INSTALL CHECKMK-SERVER \e[0m"
sudo apt install -y ./check-mk-raw-2.1.0p$patchlevel$subpatchlevel.$current_codename

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
patchlevel=20
cd /opt/omd/versions/$new_version/share/check_mk/agents
sudo apt install -y ./check-mk-agent_2.1.0p$patchlevel-1_all.deb

# cleanup installations
sudo omd cleanup

# giving some short infos
echo -e
echo -e "\e[1;46m INFO: Die Site $site läuft jetzt in der Version: $new_version \e[0m"
echo -e
