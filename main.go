package main

import (
	"io/ioutil"
	"path"
	"strings"

	"github.com/golang/protobuf/proto"
	"v2ray.com/core/app/router"
	"v2ray.com/core/common"
	"v2ray.com/ext/tools/conf"
)

const (
	DatPath  = "dat"
	IpPath   = "ip"
	SitePath = "site"

	SiteName = "geosite.dat"
	IpName   = "geoip.dat"
)

var (
	ruleDomains []*router.Domain
	ruleCIDRs   []*router.CIDR
)

func main() {
	GenIp(IpName)
	GenSite(SiteName)
}

func GenIp(fileName string) {
	geoIpList := ReadIp(fileName)

	ruleFiles, err := ioutil.ReadDir(IpPath)
	common.Must(err)

	for _, ruleFile := range ruleFiles {
		filename := ruleFile.Name()
		geoIpList.Entry = append(geoIpList.Entry, &router.GeoIP{
			CountryCode: strings.ToUpper(filename),
			Cidr:        FormatIp(path.Join(IpPath, filename)),
		})
	}

	bytes, err := proto.Marshal(geoIpList)
	common.Must(err)

	err = ioutil.WriteFile(path.Join(DatPath, IpName), bytes, 0777)
	common.Must(err)
}

func FormatIp(fileName string) []*router.CIDR {
	bytes, err := ioutil.ReadFile(fileName)
	common.Must(err)

	ips := strings.Split(string(bytes), "\n")

	ruleCIDRs = make([]*router.CIDR, 0, len(ips))
	for _, ip := range ips {
		if ip == "" {
			break
		}
		cidr, err := conf.ParseIP(ip)
		common.Must(err)
		ruleCIDRs = append(ruleCIDRs, cidr)
	}

	return ruleCIDRs
}

func ReadIp(fileName string) *router.GeoIPList {
	bytes, err := ioutil.ReadFile(fileName)
	common.Must(err)

	geoIpList := new(router.GeoIPList)
	err = proto.Unmarshal(bytes, geoIpList)
	common.Must(err)

	return geoIpList
}

func GenSite(fileName string) {
	geoSiteList := ReadSite(fileName)

	ruleFiles, err := ioutil.ReadDir(SitePath)
	common.Must(err)

	for _, ruleFile := range ruleFiles {
		filename := ruleFile.Name()
		geoSiteList.Entry = append(geoSiteList.Entry, &router.GeoSite{
			CountryCode: strings.ToUpper(filename),
			Domain:      FormatSite(path.Join(SitePath, filename)),
		})
	}

	bytes, err := proto.Marshal(geoSiteList)
	common.Must(err)

	err = ioutil.WriteFile(path.Join(DatPath, SiteName), bytes, 0777)
	common.Must(err)
}

func FormatSite(fileName string) []*router.Domain {
	bytes, err := ioutil.ReadFile(fileName)
	common.Must(err)

	domains := strings.Split(string(bytes), "\n")

	ruleDomains = make([]*router.Domain, 0, len(domains))
	for _, domain := range domains {
		if domain == "" {
			break
		}
		ruleDomains = append(ruleDomains, &router.Domain{
			Type:  router.Domain_Domain,
			Value: domain,
		})
	}

	return ruleDomains
}

func ReadSite(fileName string) *router.GeoSiteList {
	bytes, err := ioutil.ReadFile(fileName)
	common.Must(err)

	geoSiteList := new(router.GeoSiteList)
	err = proto.Unmarshal(bytes, geoSiteList)
	common.Must(err)

	return geoSiteList
}
