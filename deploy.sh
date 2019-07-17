#!/bin/env bash

git remote add upstream "https://${GH_TOKEN}@github.com/wsxxsy/v2ray-domain-list.git"

mkdir -p dat ip site

rm -rf dat/* ip/* site/*

#curl https://api.github.com/repos/v2ray/geoip/releases/latest | grep browser_download_url | awk -F'"' '{print $4}' | xargs -n 1 -t wget -O geoip.dat
#curl https://api.github.com/repos/v2ray/geoip/releases/latest | jq '.assets[0].browser_download_url' | xargs -t wget -O geoip.dat
wget -O geoip.dat https://github.com/v2ray/geoip/releases/latest/download/geoip.dat

#curl https://api.github.com/repos/v2ray/domain-list-community/releases/latest | grep browser_download_url | awk -F'"' '{print $4}' | xargs -n 1 -t wget -O geosite.dat
#curl https://api.github.com/repos/v2ray/domain-list-community/releases/latest | jq '.assets[0].browser_download_url' | xargs -t wget -O geosite.dat
wget -O geosite.dat https://github.com/v2ray/domain-list-community/releases/latest/download/dlc.dat

wget -O sr_top500_banlist_ad.conf https://raw.githubusercontent.com/h2y/Shadowrocket-ADBlock-Rules/master/sr_top500_banlist_ad.conf

cat sr_top500_banlist_ad.conf | grep Reject | grep IP-CIDR | awk -F, '{print $2}' > ip/ad
cat sr_top500_banlist_ad.conf | grep Reject | grep DOMAIN-SUFFIX | awk -F, '{print $2}' > site/ad

cat sr_top500_banlist_ad.conf | grep Proxy | grep IP-CIDR | awk -F, '{print $2}' > ip/gfw
cat sr_top500_banlist_ad.conf | grep Proxy | grep DOMAIN-SUFFIX | awk -F, '{print $2}' > site/gfw

#chmod +x ./v2ray-domain-list
#./v2ray-domain-list
go run main.go

rm -rf geoip.dat geosite.dat sr_top500_banlist_ad.conf

git add -A
git commit -m ':art: Daily build'
git push -u upstream HEAD:master
