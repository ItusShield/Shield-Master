--[[

LuCI GeoIP module

Copyright (C) 2015, ITUS Networks Inc.

]]--


local fs = require "nixio.fs"
local sys = require "luci.sys"
require "ubus"

m = Map("geoip", translate("GeoIP Filter"), translate("Select the country you'd like to have traffic coming and going to blocked."))
m.on_after_commit = function() luci.sys.call("/etc/init.d/geoip restart && iptables -vL | grep geoip > /etc/itus/geoip.log") end

m.on_init = function()
end

s = m:section(TypedSection, "geoip")
s.anonymous = true
s.addremove = false

s:tab("tab_basic99", translate("GeoIP Filter"))
s:tab("tab_white1", translate("Logs"))

-- Basic settings Tab --

--local dummy2, Afghanistan, Australia, Austria, Bolivia, Brazil, Cambodia, Canada, China, Columbia, Denmark, Ecuador, Egypt, El_Salvador, Finland, France, Germany, Greece, Hong_Kong, India, Indonesia, Iran, Iraq, Ireland, Israel, Italy, Japan, Jordan, Kazakhstan, Kuwait, Lebanon, Libya, Lithuania, Luxembourg, Malaysia, Mexico, Mongolia, Morocco, Myanmar, Netherlands, New_Zealand, North_Korea, Pakistan, Palestine, Philippines, Poland, Qatar, Romania, Russia, Saudi_Arabia, South_Africa, South_Korea, Spain, Sudan, Sweden, Switzerland, Syria, Taiwan, Thailand, Tunisia, Turkey, Ukraine, United_Arab_Emirates, United_Kingdom, United_States, Vietnam, Yemen, Zimbabwe

local dummy2, AF, AU, AT, BO, BR, KH, CA, CN, CO, DK, EC, EG, SV, FI, FR, DE, GR, HK, IN, ID, IR, IQ, IE, IL, IT, JP, JO, KZ, KW, LB, LY, LT, LU, MY, MX, MN, MA, MM, NL, NZ, KP, PK, PS, PH, PL, QA, RO, RU, SA, ZA, KR, ES, SD, SE, CH, SY, TW, TH, TN, TR, UA, AE, GB, US, VN, YE, ZW

dummy2 = s:taboption("tab_basic99", DummyValue2, "dummy2", translate("<b>Country to Block: </b>"))

AF = s:taboption("tab_basic99", Flag, "country_AF", translate("Afhanistan"))
AF.default=AF.disabled
AF.rmempty = false

AU = s:taboption("tab_basic99", Flag, "country_AU", translate("Australia"))
AU.default=AU.disabled
AU.rmempty = false

AT = s:taboption("tab_basic99", Flag, "country_AT", translate("Austria"))
AT.default=AT.disabled
AT.rmempty = false

BO = s:taboption("tab_basic99", Flag, "country_BO", translate("Bolivia"))
BO.default=BO.disabled
BO.rmempty = false

BR = s:taboption("tab_basic99", Flag, "country_BR", translate("Brazil"))
BR.default=BR.disabled
BR.rmempty = false

KH = s:taboption("tab_basic99", Flag, "country_KH", translate("Cambodia"))
KH.default=KH.disabled
KH.rmempty = false

CA = s:taboption("tab_basic99", Flag, "country_CA", translate("Canada"))
CA.default=CA.disabled
CA.rmempty = false

CN = s:taboption("tab_basic99", Flag, "country_CN", translate("China"))
CN.default=CN.enabled
CN.rmempty = true

CO = s:taboption("tab_basic99", Flag, "country_CO", translate("Columbia"))
CO.default=CO.disabled
CO.rmempty = false

DK = s:taboption("tab_basic99", Flag, "country_DK", translate("Denmark"))
DK.default=DK.disabled
DK.rmempty = false

EC = s:taboption("tab_basic99", Flag, "country_EC", translate("Ecuador"))
EC.default=EC.disabled
EC.rmempty = false

EG = s:taboption("tab_basic99", Flag, "country_EG", translate("Egypt"))
EG.default=EG.disabled
EG.rmempty = false

SV = s:taboption("tab_basic99", Flag, "country_SV", translate("El Salvador"))
SV.default=SV.disabled
SV.rmempty = false

FI = s:taboption("tab_basic99", Flag, "country_FI", translate("Finland"))
FI.default=FI.disabled
FI.rmempty = false

FR = s:taboption("tab_basic99", Flag, "country_FR", translate("France"))
FR.default=FR.disabled
FR.rmempty = false

DE = s:taboption("tab_basic99", Flag, "country_DE", translate("Germany"))
DE.default=DE.disabled
DE.rmempty = false

GR = s:taboption("tab_basic99", Flag, "country_GR", translate("Greece"))
GR.default=GR.disabled
GR.rmempty = false

HK = s:taboption("tab_basic99", Flag, "country_HK", translate("Hong Kong"))
HK.default=HK.disabled
HK.rmempty = false

IN = s:taboption("tab_basic99", Flag, "country_IN", translate("India"))
IN.default=IN.disabled
IN.rmempty = false

ID = s:taboption("tab_basic99", Flag, "country_ID", translate("Indonesia"))
ID.default=ID.disabled
ID.rmempty = false

IR = s:taboption("tab_basic99", Flag, "country_IR", translate("Iran"))
IR.default=IR.disabled
IR.rmempty = false

IQ = s:taboption("tab_basic99", Flag, "country_IQ", translate("Iraq"))
IQ.default=IQ.disabled
IQ.rmempty = false

IE = s:taboption("tab_basic99", Flag, "country_IE", translate("Ireland"))
IE.default=IE.disabled
IE.rmempty = false

IL = s:taboption("tab_basic99", Flag, "country_IL", translate("Israel"))
IL.default=IL.disabled
IL.rmempty = false

IT = s:taboption("tab_basic99", Flag, "country_IT", translate("Italy"))
IT.default=IT.disabled
IT.rmempty = false

JP = s:taboption("tab_basic99", Flag, "country_JP", translate("Japan"))
JP.default=JP.disabled
JP.rmempty = false

JO = s:taboption("tab_basic99", Flag, "country_JO", translate("Jordan"))
JO.default=JO.disabled
JO.rmempty = false

KZ = s:taboption("tab_basic99", Flag, "country_KZ", translate("Kazakhstan"))
KZ.default=KZ.disabled
KZ.rmempty = false

KW = s:taboption("tab_basic99", Flag, "country_KW", translate("Kuwait"))
KW.default=KW.disabled
KW.rmempty = false

LB = s:taboption("tab_basic99", Flag, "country_LB", translate("Lebanon"))
LB.default=LB.disabled
LB.rmempty = false

LY = s:taboption("tab_basic99", Flag, "country_LY", translate("Libya"))
LY.default=LY.disabled
LY.rmempty = false

LT = s:taboption("tab_basic99", Flag, "country_LT", translate("Lithuania"))
LT.default=LT.disabled
LT.rmempty = false

LU = s:taboption("tab_basic99", Flag, "country_LU", translate("Luxembourg"))
LU.default=LU.disabled
LU.rmempty = false

MY = s:taboption("tab_basic99", Flag, "country_MY", translate("Malaysia"))
MY.default=MY.disabled
MY.rmempty = false

MX = s:taboption("tab_basic99", Flag, "country_MX", translate("Mexico"))
MX.default=MX.disabled
MX.rmempty = false

MN = s:taboption("tab_basic99", Flag, "country_MN", translate("Mongolia"))
MN.default=MN.disabled
MN.rmempty = false

MA = s:taboption("tab_basic99", Flag, "country_MA", translate("Morocco"))
MA.default=MA.disabled
MA.rmempty = false

MM = s:taboption("tab_basic99", Flag, "country_MM", translate("Myanmar"))
MM.default=MM.disabled
MM.rmempty = false

NL = s:taboption("tab_basic99", Flag, "country_NL", translate("Netherlands"))
NL.default=NL.disabled
NL.rmempty = false

NZ = s:taboption("tab_basic99", Flag, "country_NZ", translate("New Zealand"))
NZ.default=NZ.disabled
NZ.rmempty = false

KP = s:taboption("tab_basic99", Flag, "country_KP", translate("North Korea"))
KP.default=KP.disabled
KP.rmempty = false

PK = s:taboption("tab_basic99", Flag, "country_PK", translate("Pakistan"))
PK.default=PK.disabled
PK.rmempty = false

PS = s:taboption("tab_basic99", Flag, "country_PS", translate("Palestine"))
PS.default=PS.disabled
PS.rmempty = false

PH = s:taboption("tab_basic99", Flag, "country_PH", translate("Philippines"))
PH.default=PH.disabled
PH.rmempty = false

PL = s:taboption("tab_basic99", Flag, "country_PL", translate("Poland"))
PL.default=PL.disabled
PL.rmempty = false

QA = s:taboption("tab_basic99", Flag, "country_QA", translate("Qatar"))
QA.default=QA.disabled
QA.rmempty = false

RO = s:taboption("tab_basic99", Flag, "country_RO", translate("Romania"))
RO.default=RO.disabled
RO.rmempty = false

RU = s:taboption("tab_basic99", Flag, "country_RU", translate("Russia"))
RU.default=RU.enabled
RU.rmempty = true

SA = s:taboption("tab_basic99", Flag, "country_SA", translate("Saudi Arabia"))
SA.default=SA.disabled
SA.rmempty = false

ZA = s:taboption("tab_basic99", Flag, "country_ZA", translate("South Africa"))
ZA.default=ZA.disabled
ZA.rmempty = false

KR = s:taboption("tab_basic99", Flag, "country_KR", translate("South Korea"))
KR.default=KR.disabled
KR.rmempty = false

ES = s:taboption("tab_basic99", Flag, "country_ES", translate("Spain"))
ES.default=ES.disabled
ES.rmempty = false

SD = s:taboption("tab_basic99", Flag, "country_SD", translate("Sudan"))
SD.default=SD.disabled
SD.rmempty = false

SE = s:taboption("tab_basic99", Flag, "country_SE", translate("Sweden"))
SE.default=SE.disabled
SE.rmempty = false

CH = s:taboption("tab_basic99", Flag, "country_CH", translate("Switzerland"))
CH.default=CH.disabled
CH.rmempty = false

SY = s:taboption("tab_basic99", Flag, "country_SY", tranlsate("Syria"))
SY.default=SY.disabled
SY.rmempty = false

TW = s:taboption("tab_basic99", Flag, "country_TW", translate("Taiwan"))
TW.default=TW.disabled
TW.rmempty = false

TH = s:taboption("tab_basic99", Flag, "country_TH", translate("Thailand"))
TH.default=TH.disabled
TH.rmempty = false

TN = s:taboption("tab_basic99", Flag, "country_TN", translate("Tunisia"))
TN.default=TN.disabled
TN.rmempty = false

TR = s:taboption("tab_basic99", Flag, "country_TR", translate("Turkey"))
TR.default=TR.disabled
TR.rmempty = false

UA = s:taboption("tab_basic99", Flag, "country_UA", translate("Ukraine"))
UA.default=UA.disabled
UA.rmempty = false

AE = s:taboption("tab_basic99", Flag, "country_AE", translate("United Arab Emirates"))
AE.default=AE.disabled
AE.rmempty = false

GB = s:taboption("tab_basic99", Flag, "country_GB", translate("United Kingdom"))
GB.default=GB.disabled
GB.rmempty = false

US = s:taboption("tab_basic99", Flag, "country_US", translate("United States"))
US.default=US.disabled
US.rmempty = false

VN = s:taboption("tab_basic99", Flag, "country_VN", translate("Vitenam"))
VN.default=VN.disabled
VN.rmempty = false

YE = s:taboption("tab_basic99", Flag, "country_YE", translate("Yemen"))
YE.default=YE.disabled
YE.rmempty = false

ZW = s:taboption("tab_basic99", Flag, "country_ZW", translate("Zimbabwe"))
ZW.default=ZW.disabled
ZW.rmempty = false

--------------------- WhiteList Tab ------------------------

	config_file10 = s:taboption("tab_white1", TextValue, "text16", "")
	config_file10.wrap = "off"
	config_file10.rows = 25
	config_file10.rmempty = false

	function config_file10.cfgvalue()
		local uci = require "luci.model.uci".cursor_state()
		file10 = "/etc/itus/geoip.log"

		if file10 then
			return fs.readfile(file10) or ""
		else
			return ""
		end
	end

	function config_file10.write(self, section, value)
		if value then
			local uci = require "luci.model.uci".cursor_state()
			file = "/etc/itus/geoip.log"
			fs.writefile(file, value:gsub("\r\n", "\n"))
		end
	end

return m
