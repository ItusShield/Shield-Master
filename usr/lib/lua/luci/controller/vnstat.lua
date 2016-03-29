module("luci.controller.vnstat", package.seeall)

function index()

	-- DANIEL EDITS BEGIN
--	io.input("/etc/itus/advanced.conf")
--	line = io.read("*line")
--	if line == "yes" then	

	entry({"admin", "status", "vnstat"}, alias("admin", "status", "vnstat", "graphs"), _("Traffic Monitor"), 90)
	entry({"admin", "status", "vnstat", "graphs"}, template("vnstat"), _("Graphs"), 1)
	entry({"admin", "status", "vnstat", "config"}, cbi("vnstat"), _("Configuration"), 2)

	entry({"mini", "network", "vnstat"}, alias("mini", "network", "vnstat", "graphs"), _("Traffic Monitor"), 90)
	entry({"mini", "network", "vnstat", "graphs"}, template("vnstat"), _("Graphs"), 1)
	entry({"mini", "network", "vnstat", "config"}, cbi("vnstat"), _("Configuration"), 2)

--	end
	-- DANIEL EDITS END

end
