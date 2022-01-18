#!/bin/bash

# define variables
site=$(omd sites --bare)
version=$(omd version --bare)

echo -e "\e[1;42m COPY PLUGIN \e[0m"
sudo cp /opt/omd/versions/$version/share/check_mk/agents/plugins/mk_inventory.linux /opt/omd/sites/$site/local/share/check_mk/agents/plugins/
