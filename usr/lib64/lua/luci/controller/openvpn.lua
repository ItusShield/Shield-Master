-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2008 Jo-Philipp Wich <jow@openwrt.org>
-- Licensed to the public under the Apache License 2.0.

module("luci.controller.openvpn", package.seeall)

function index()
	

	-- DANIEL EDITS BEGIN
	io.input("/etc/itus/advanced.conf")
	line = io.read("*line")
	if line == "yes" then	

	entry( {"admin", "services", "openvpn"}, cbi("openvpn"), _("SSLVPN") )
	entry( {"admin", "services", "openvpn", "basic"},    cbi("openvpn-basic"),    nil ).leaf = true
	entry( {"admin", "services", "openvpn", "advanced"}, cbi("openvpn-advanced"), nil ).leaf = true

	end
	-- DANIEL EDITS END

end
