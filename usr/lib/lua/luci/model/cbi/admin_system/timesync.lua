-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2011 Jo-Philipp Wich <jow@openwrt.org>
-- Licensed to the public under the Apache License 2.0.

local sys   = require "luci.sys"
local zones = require "luci.sys.zoneinfo"
local fs    = require "nixio.fs"
local conf  = require "luci.config"

local m, s, o
local has_ntpd = fs.access("/usr/sbin/ntpd")


m = Map("system", translate("Time"))
m:chain("luci")

s = m:section(SimpleSection)
s.anonymous = true
s.addremove = false

--s:tab("general",  translate("General Settings"))
--s:tab("logging",  translate("Logging"))
--s:tab("language", translate("Language and Style"))
s:tab("timesync", translate("Time"))

--o = s:taboption("timesync", Value, "hostname", translate("Hostname"))
--o.datatype = "hostname"


--
-- NTP
--

if has_ntpd then

	-- timeserver setup was requested, create section and reload page
	if m:formvalue("cbid.system._timeserver._enable") then
		m.uci:section("system", "timeserver", "ntp",
			{
			server = { "0.us.pool.ntp.org", "1.us.pool.ntp.org", "2.us.pool.ntp.org", "3.us.pool.ntp.org" }
			}
		)

		m.uci:save("system")
		luci.http.redirect(luci.dispatcher.build_url("admin/system", arg[1]))
		return
	end

	local has_section = false
	m.uci:foreach("system", "timeserver",
		function(s)
			has_section = true
			return false
	end)

	if not has_section then

		s = m:section(TypedSection, "timeserver", translate("Time Synchronization"))
		s.anonymous   = true
		s.cfgsections = function() return { "_timeserver" } end

		x = s:option(Button, "_enable")
		x.title      = translate("Time Synchronization is not configured yet.")
		x.inputtitle = translate("Set up Time Synchronization")
		x.inputstyle = "apply"

	else
		s = m:section(TypedSection, "timeserver", translate("Time Synchronization"))
		s.anonymous = true
		s.addremove = false

		o = s:option(Flag, "enable", translate("Enable NTP client"))
		o.rmempty = false

		function o.cfgvalue(self)
			return sys.init.enabled("sysntpd")
				and self.enabled or self.disabled
		end

		function o.write(self, section, value)
			if value == self.enabled then
				sys.init.enable("sysntpd")
				sys.call("env -i /etc/init.d/sysntpd start >/dev/null")
			else
				sys.call("env -i /etc/init.d/sysntpd stop >/dev/null")
				sys.init.disable("sysntpd")
			end
		end


		o = s:option(Flag, "enable_server", translate("Provide NTP server"))
		o:depends("enable", "1")


		o = s:option(DynamicList, "server", translate("NTP server candidates"))
		o.datatype = "host"
		o:depends("enable", "1")

		-- retain server list even if disabled
		function o.remove() end

	end
end

return m
