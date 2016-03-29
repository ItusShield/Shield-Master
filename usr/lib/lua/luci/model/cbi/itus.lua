--[[

LuCI ITUS module

Copyright (C) 2015, Itus Networks, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

Author: Daniel

]]--

local fs = require "nixio.fs"
local sys = require "luci.sys"
require "ubus"

m = Map("itus", translate("ITUS Settings"), translate("System Update runs automatically every day. Factory reset takes effect immediately. Do not disconnect power from Shield when performing a factory reset. After the factory reset completes, your Shield will automatically start. Please allow 10 minutes for the process to complete."))
m.on_after_commit = function() luci.sys.call("if `grep -qs yes /etc/config/itus` ; then echo yes > /etc/itus/advanced.conf ; else echo no > /etc/itus/advanced.conf; fi") end

m.on_init = function()
	luci.sys.call("sh /etc/itus/fw-log.sh")
end

s = m:section(TypedSection, "itus")
s.anonymous = true
s.addremove = false

s:tab("tab_ITUS1", translate("Advanced Settings"))
s:tab("tab_ITUS3", translate("ITUS Update Log"))
s:tab("tab_ITUS5", translate("Remove Banners"))
s:tab("tab_ITUS2", translate("Update Shield"))
s:tab("tab_ITUS6", translate("Reboot Shield"))
s:tab("tab_ITUS4", translate("Factory Reset"))

advanced = s:taboption("tab_ITUS1",ListValue, "advanced", translate("Show Advanced Mode:"))
advanced:value("no","no")
advanced:value("yes","yes")
advanced.default="no"

io.input("/etc/itus/advanced.conf")
line = io.read("*line")


fwlog = s:taboption("tab_ITUS3",TextValue,"fwlog","")                                      
fwlog.wrap = "off"                                                                         
fwlog.rows = 25                                                                            
fwlog.rmempty = false                                                                      
        function fwlog.cfgvalue()
        local uci = require "luci.model.uci".cursor_state()
        local file = "/etc/itus/fw.log"
                if file then
                        return fs.readfile(file) or ""
                else
                        return ""
                end
        end


buttonzero = s:taboption("tab_ITUS5",Button,"banners", translate("System Notification Banners:"))                                         
buttonzero.inputtitle = "Remove"                                                                                                          
        function buttonzero.write(self, section,value)                                                                                    
                sys.call("sh /etc/itus/remove_banners.sh &>/dev/null")                                                                                
        end 


if line == "yes" then

buttonone = s:taboption("tab_ITUS2",Button, "update", translate("Run System Update:"))                                                    
buttonone.inputtitle = "Start"                                                                                                            
        function buttonone.write(self, section,value)                                                                                     
                sys.call("sh /sbin/fw_upgrade &>/dev/null")                                                                                
        end  


buttonthree = s:taboption("tab_ITUS6",Button, "restart", translate("Reboot Shield:"))                
buttonthree.inputtitle = "Restart"
        function buttonthree.write(self, section,value)                                            
                sys.call("reboot -f &>/dev/null")                             
        end  

buttontwo = s:taboption("tab_ITUS4",Button, "reset", translate("Factory Reset:"))
buttontwo.inputtitle = "Start"
	function buttontwo.write(self, section,value)
		sys.call("sh /etc/itus/factory_reset.sh &>/dev/null")
	end      

end

return m
