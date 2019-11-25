.PHONY: all clean vendor parse build

all: build

clean:
	@rm -rf ip/* site/* tmp

vendor: clean
	@mkdir -p ip site tmp

	@wget -O tmp/sr_top500_banlist_ad.conf https://raw.githubusercontent.com/h2y/Shadowrocket-ADBlock-Rules/master/sr_top500_banlist_ad.conf

	@wget -O tmp/adblock.conf https://raw.githubusercontent.com/hq450/fancyss/master/rules/adblock.conf
	@wget -O tmp/gfwlist.conf https://raw.githubusercontent.com/hq450/fancyss/master/rules/gfwlist.conf

parse: vendor
	@cat tmp/sr_top500_banlist_ad.conf | grep Reject | grep IP-CIDR | awk -F, '{print $$2}' > ip/ad
	@cat tmp/sr_top500_banlist_ad.conf | grep Proxy | grep IP-CIDR | awk -F, '{print $$2}' > ip/gfw

	@cat tmp/sr_top500_banlist_ad.conf | grep Reject | grep DOMAIN-SUFFIX | awk -F, '{print $$2}' > site/ad
	@cat tmp/sr_top500_banlist_ad.conf | grep Proxy | grep DOMAIN-SUFFIX | awk -F, '{print $$2}' > site/gfw

	@cat tmp/adblock.conf | grep address | awk -F/ '{print $$2}' >> site/ad
	@cat tmp/gfwlist.conf | grep ipset | awk -F/ '{print $$2}' | sed 's/^.//g' >> site/gfw

build:
	@mkdir -p tmp
	@wget -O tmp/geoip.dat https://github.com/v2ray/geoip/releases/latest/download/geoip.dat
	@wget -O tmp/geosite.dat https://github.com/v2ray/domain-list-community/releases/latest/download/dlc.dat
	@go run main.go
	@rm -rf tmp