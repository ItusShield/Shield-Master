--[[

LuCI Snort module

Copyright (C) 2015, Itus Networks, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Author: Luka Perkov <luka@openwrt.org>

]]--

local fs = require "nixio.fs"
local sys = require "luci.sys"
require "ubus"

m = Map("snort", translate("Intrusion Prevention"), translate("Changes may take up to 90 seconds to take effect, service may be interrupted during that time. The IPS engine will restart each time you click the Save & Apply or On/Off button."))

m.on_init = function()
	luci.sys.call("sed '1!G;h$!d' /tmp/snort/alert > /tmp/snort/alert2")
end

m.reset = false
m.submit = false

s = m:section(NamedSection, "snort")
s.anonymous = true
s.addremove = false

s:tab("tab_basic", translate("Basic Settings"))
s:tab("tab_snort7", translate("Snort7 Config"))
s:tab("tab_snort8", translate("Snort8 Config"))
s:tab("tab_threshold", translate("Threshold Config"))
s:tab("tab_custom", translate("Custom Rules"))
s:tab("tab_rules", translate("Exclude Rules"))
s:tab("tab_logs", translate("IPS Logs"))


--------------------- Basic Tab ------------------------

local status="not running"
require "ubus"
local conn = ubus.connect()
if not conn then
        error("Failed to connect to ubusd")
end

for k, v in pairs(conn:call("service", "list", { name="snort" })) do
        status="running"
end

button = s:taboption("tab_basic",Button, "start", translate("Status: "))
if status == "running" then
        button.inputtitle = "ON"
else
        button.inputtitle = "OFF"
end
button.write = function(self, section)
        if status == "not running" then
                sys.call("/etc/init.d/snort start >/dev/null")
                button.inputtitle = "ON"
                button.title = "Status: "
        else
                sys.call("/etc/init.d/snort stop >/dev/null")
                button.inputtitle = "OFF"
                button.title = "Status: "
        end
end

--profile = s:taboption("tab_basic", ListValue, "profile", translate("Profile: "))
--profile:value("snort",  translate("snort"))
--profile.default = "snort"


--------------------- Snort Instance #1 Tab -----------------------

io.input("/etc/itus/advanced.conf")
line = io.read("*line")

if line == "yes" then

	config_file1 = s:taboption("tab_snort7", TextValue, "text1", "")
	config_file1.wrap = "off"
	config_file1.rows = 25
	config_file1.rmempty = false

	function config_file1.cfgvalue()
		local uci = require "luci.model.uci".cursor_state()
		file = "/etc/snort/snort7.conf"
		if file then
			return fs.readfile(file) or ""
		else
			return ""
		end
	end

	function config_file1.write(self, section, value)
		if value then
			local uci = require "luci.model.uci".cursor_state()
			file = "/etc/snort/snort7.conf"
			fs.writefile(file, value:gsub("\r\n", "\n"))
			luci.sys.call("/etc/init.d/snort restart")
		end
	end

	---------------------- Snort Instance #2 Tab ------------------------

	config_file2 = s:taboption("tab_snort8", TextValue, "text2", "")
	config_file2.wrap = "off"
	config_file2.rows = 25
	config_file2.rmempty = false

	function config_file2.cfgvalue()
		local uci = require "luci.model.uci".cursor_state()
		file = "/etc/snort/snort8.conf"
		if file then
			return fs.readfile(file) or ""
		else
			return ""
		end
	end

	function config_file2.write(self, section, value)
		if value then
			local uci = require "luci.model.uci".cursor_state()
			file = "/etc/snort/snort8.conf"
			fs.writefile(file, value:gsub("\r\n", "\n"))
			luci.sys.call("/etc/init.d/snort restart")
		end
	end

	---------------------- Threshold Config Tab ------------------------

	config_file2 = s:taboption("tab_threshold", TextValue, "threshold", "")
	config_file2.wrap = "off"
	config_file2.rows = 25
	config_file2.rmempty = false

	function config_file2.cfgvalue()
		local uci = require "luci.model.uci".cursor_state()
		file = "/etc/snort/threshold.conf"
		if file then
			return fs.readfile(file) or ""
		else
			return ""
		end
	end

	function config_file2.write(self, section, value)
		if value then
			local uci = require "luci.model.uci".cursor_state()
			file = "/etc/snort/threshold.conf"
			fs.writefile(file, value:gsub("\r\n", "\n"))
			luci.sys.call("/etc/init.d/snort restart")
		end
	end

	---------------------- Custom Rules Tab ------------------------

	config_file2 = s:taboption("tab_custom", TextValue, "text3", "")
	config_file2.wrap = "off"
	config_file2.rows = 25
	config_file2.rmempty = false

	function config_file2.cfgvalue()
		local uci = require "luci.model.uci".cursor_state()
		file = "/etc/snort/rules/local.rules"
		if file then
			return fs.readfile(file) or ""
		else
			return ""
		end
	end

	function config_file2.write(self, section, value)
		if value then
			local uci = require "luci.model.uci".cursor_state()
			file = "/etc/snort/rules/local.rules"
			fs.writefile(file, value:gsub("\r\n", "\n"))
			luci.sys.call("/etc/init.d/snort restart")
		end
	end

 end

	--------------------- Exclude Rules Tab ------------------------

	config_file5 = s:taboption("tab_rules", TextValue, "text4", "")
	config_file5.wrap = "off"
	config_file5.rows = 25
	config_file5.rmempty = false

	function config_file5.cfgvalue()
		local uci = require "luci.model.uci".cursor_state()
		file = "/etc/snort/rules/exclude.rules"
		if file then
			return fs.readfile(file) or ""
		else
			return ""
		end
	end

	function config_file5.write(self, section, value)
		if value then
			local uci = require "luci.model.uci".cursor_state()
			file = "/etc/snort/rules/exclude.rules"
			fs.writefile(file, value:gsub("\r\n", "\n"))
			luci.sys.call("/etc/init.d/snort restart")
		end
	end

	--------------------- Logs Tab ------------------------

	snort_logfile = s:taboption("tab_logs", TextValue, "logfile", "")
	snort_logfile.wrap = "off"
	snort_logfile.rows = 25
	snort_logfile.rmempty = false

	function snort_logfile.cfgvalue()
        local uci = require "luci.model.uci".cursor_state()
        local file = "/tmp/snort/alert2"
        	if file then
        	        return fs.readfile(file) or ""
        	else
        	        return ""
        	end
	end


return m
