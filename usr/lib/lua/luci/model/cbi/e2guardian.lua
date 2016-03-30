--[[

LuCI E2Guardian module

Copyright (C) 2015, Itus Networks, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Author: Marko Ratkaj <marko.ratkaj@sartura.hr>
	Luka Perkov <luka.perkov@sartura.hr>

]]--

local fs = require "nixio.fs"
local sys = require "luci.sys"
require "ubus"

m = Map("e2guardian", translate("Web Filter"), translate("Changes may take up to 60 seconds to take effect. Web access may be interrupted during this time."))
m.on_after_commit = function() luci.sys.call("/etc/init.d/dnsmasq restart && sh /etc/itus/lists/log-gen.sh") end

m.on_init = function()
	luci.sys.call("sh /etc/itus/lists/log-gen.sh")
end

s = m:section(TypedSection, "e2guardian")
s.anonymous = true
s.addremove = false

s:tab("tab_basic", translate("Basic Settings"))
s:tab("tab_white", translate("White List"))
s:tab("tab_black", translate("Black List"))
s:tab("tab_logs", translate("Logs"))
s:tab("tab_block", translate("Block Page"))


----------------- Basic Settings Tab -----------------------

local dummy1, ads, blasphemy, drugs, gambling, piracy, porn, proxies, racism, sexuality, weapons

dummy1 = s:taboption("tab_basic", DummyValue, "dummy1", translate("<b>Content filtering: </b>"))

ads = s:taboption("tab_basic", Flag, "content_ads", translate("Ads"))
ads.default=ads.enabled
ads.rmempty = false

malicious = s:taboption("tab_basic", Flag, "content_malicious", translate("Malicious"))
malicious.default = malicious.disabled
malicious.rmempty = false

drugs = s:taboption("tab_basic", Flag, "content_drugs", translate("Drugs"))
drugs.default=drugs.disabled
drugs.rmempty = false

------DISABLE FUNCTIONS NOT UPDATED VIA FW_UPGRADE-----
if 1 == 2 then
blasphemy = s:taboption("tab_basic", Flag, "content_blasphemy", translate("Blasphemy"))
blasphemy.default=blasphemy.disabled
blasphemy.rmempty = false

dating = s:taboption("tab_basic", Flag, "content_dating", translate("Dating"))
dating.default = dating.disabled
dating.rmempty = false

gambling = s:taboption("tab_basic", Flag, "content_gambling", translate("Gambling"))
gambling.default=gambling.disabled
gambling.rmempty = false

illegal = s:taboption("tab_basic", Flag, "content_illegal", translate("Illegal"))
illegal.default = illegal.disabled
illegal.rmempty = false

malicious = s:taboption("tab_basic", Flag, "content_malicious", translate("Malicious"))
malicious.default = malicious.disabled
malicious.rmempty = false

piracy = s:taboption("tab_basic", Flag, "content_piracy", translate("Piracy"))
piracy.default=piracy.disabled
piracy.rmempty = false

porn = s:taboption("tab_basic", Flag, "content_porn", translate("Porn"))
porn.default=porn.disabled
porn.rmempty = false

proxies = s:taboption("tab_basic", Flag, "content_proxies", translate("Proxies"))
proxies.default=proxies.disabled
proxies.rmempty = false

racism = s:taboption("tab_basic", Flag, "content_racism", translate("Racism"))
racism.default=racism.disabled
racism.rmempty = false

social = s:taboption("tab_basic", Flag, "content_social", translate("Social"))
social.default=social.disabled
social.rmempty = false

end

-----ENDofDISABLE-----

--------------------- WhiteList Tab ------------------------

	config_file0 = s:taboption("tab_white", TextValue, "text6", "")
	config_file0.wrap = "off"
	config_file0.rows = 25
	config_file0.rmempty = false

	function config_file0.cfgvalue()
		local uci = require "luci.model.uci".cursor_state()
		file = "/etc/itus/lists/white.list"

		if file then
			return fs.readfile(file) or ""
		else
			return ""
		end
	end

	function config_file0.write(self, section, value)
		if value then
			local uci = require "luci.model.uci".cursor_state()
			file = "/etc/itus/lists/white.list"
			fs.writefile(file, value:gsub("\r\n", "\n"))
		end
	end

	---------------------- Custom Blacklist Tab ------------------------

	config_file2 = s:taboption("tab_black", TextValue, "text7", "")
	config_file2.wrap = "off"
	config_file2.rows = 25
	config_file2.rmempty = false

	function config_file2.cfgvalue()
		local uci = require "luci.model.uci".cursor_state()
		file = "/etc/itus/lists/black.list"
		if file then
			return fs.readfile(file) or ""
		else
			return ""
		end
	end

	function config_file2.write(self, section, value)
		if value then
			local uci = require "luci.model.uci".cursor_state()
			file = "/etc/itus/lists/black.list"
			fs.writefile(file, value:gsub("\r\n", "\n"))
		end
	end

---------------------------- Logs Tab -----------------------------

e2guardian_logfile = s:taboption("tab_logs", TextValue, "lines", "")
e2guardian_logfile.wrap = "off"
e2guardian_logfile.rows = 25
e2guardian_logfile.rmempty = true

function e2guardian_logfile.cfgvalue()
	local uci = require "luci.model.uci".cursor_state()
	file = "/tmp/dns.log"
	if file then
		return fs.readfile(file) or ""
	else
		return "Can't read log file"
	end
end

function e2guardian_logfile.write()
end

      ---------------------- Custom Block Page ------------------------
                                                                              
        config_file4 = s:taboption("tab_block", TextValue, "text9", "")
        config_file4.wrap = "off"
        config_file4.rows = 25
        config_file4.rmempty = false
                                 
        function config_file4.cfgvalue()
                local uci = require "luci.model.uci".cursor_state()
                file = "/www/block/index.html"
                if file then
                        return fs.readfile(file) or ""
                else
                        return ""
                end
        end

        function config_file4.write(self, section, value)
                if value then
                        local uci = require "luci.model.uci".cursor_state()
                        file = "/www/block/index.html"
                        fs.writefile(file, value:gsub("\r\n", "\n"))
                end
        end                  

return m
