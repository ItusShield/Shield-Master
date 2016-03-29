-- Copyright 2015 ITUS Networks Inc.

local sys = require "luci.sys"

m = Map("geoip", translate("GeoIP-Block"),
	translate("GeoIP-Block is a blacklisting mechanism to block various traffic coming from or going to specific countries."))

s = m:section(NamedSection, "geoip", "settings", "Settings")
s.anonymous = true
s.addremove = false

en = s:option(Flag, "_enabled", translate("Enable GeoIP-Block"))
en.rmempty = false

function en.cfgvalue()
	return ( sys.init.enabled("geoip-lock") and "1" or "0" )
end

function en.write(self, section, val)
	if val == "1" then
		sys.init.enable("geoip")
	else
		sys.init.disable("geoip")
	end
end

s:option(DynamicList, "whitelist", translate("Whitelisted IPs"))

country = s:option(MultiValue, "Country", translate("Country to Block"))
country.widget = "checkbox"
country:value("AF", "Afghanistan")
country:value("AU", "Australia")
country:value("AT", "Austria")
country:value("BO", "Bolivia")
country:value("BR", "Brazil")
country:value("KH", "Cambodia")
country:value("CA", "Canada")
country:value("CN", "China")
country:value("CO", "Columbia")
country:value("DK", "Denmark")
country:value("EC", "Ecuador")
country:value("EG", "Egypt")
country:value("SV", "El Salvador")
country:value("FI", "Finland")
country:value("FR", "France")
country:value("DE", "Germany")
country:value("GR", "Greece")
country:value("HK", "Hong Kong")
country:value("IN", "India")
country:value("ID", "Indonesia")
country:value("IR", "Iran")
country:value("IQ", "Iraq")
country:value("IE", "Ireland")
country:value("IL", "Israel")
country:value("IT", "Italy")
country:value("JP", "Japan")
country:value("JO", "Jordan")
country:value("KZ", "Kazakhstan")
country:value("KW", "Kuwait")
country:value("LB", "Lebanon")
country:value("LY", "Libya")
country:value("LT", "Lithuania")
country:value("LU", "Luxembourg")
country:value("MY", "Malaysia")
country:value("MX", "Mexico")
country:value("MN", "Mongolia")
country:value("MA", "Morocco")
country:value("MM", "Myanmar")
country:value("NL", "Netherlands")
country:value("NZ", "New Zealand")
country:value("KP", "North Korea")
country:value("PK", "Pakistan")
country:value("PS", "Palestine")
country:value("PH", "Philippines")
country:value("PL", "Poland")
country:value("QA", "Qatar")
country:value("RO", "Romania")
country:value("RU", "Russia")
country:value("SA", "Saudi Arabia")
country:value("ZA", "South Africa")
country:value("KR", "South Korea")
country:value("ES", "Spain")
country:value("SD", "Sudan")
country:value("SE", "Sweden")
country:value("CH", "Switzerland")
country:value("SY", "Syria")
country:value("TW", "Taiwan")
country:value("TH", "Thailand")
country:value("TN", "Tunisia")
country:value("TR", "Turkey")
country:value("UA", "Ukraine")
country:value("AE", "United Arab Emirates")
country:value("GB", "United Kingdom")
country:value("US", "United States")
country:value("VN", "Vietnam")
country:value("YE", "Yemen")
country:value("ZW", "Zimbabwe")

return m
