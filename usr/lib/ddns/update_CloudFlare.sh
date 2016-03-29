#.Distributed under the terms of the GNU General Public License (GPL) version 2.0
#.2014-2015 Christian Schoenebeck <christian dot schoenebeck at gmail dot com>
[ $use_https -eq 0 ] && write_log 14 "Cloudflare only support updates via Secure HTTP (HTTPS). Please correct configuration!"
[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing 'username'"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing 'password'"
local __RECID __URL __KEY __KEYS __FOUND __SUBDOM __DOMAIN __TLD
split_FQDN $domain __TLD __DOMAIN __SUBDOM
[ $? -ne 0 -o -z "$__DOMAIN" ] && \
	write_log 14 "Wrong Host/Domain configuration ($domain). Please correct configuration!"
__DOMAIN="$__DOMAIN.$__TLD"
. /usr/share/libubox/jshn.sh
grep -i "json_get_keys" /usr/share/libubox/jshn.sh >/dev/null 2>&1 || json_get_keys() {
	local __dest="$1"
	local _tbl_cur
	if [ -n "$2" ]; then
		json_get_var _tbl_cur "$2"
	else
		_json_get_var _tbl_cur JSON_CUR
	fi
	local __var="${JSON_PREFIX}KEYS_${_tbl_cur}"
	eval "export -- \"$__dest=\${$__var}\"; [ -n \"\${$__var+x}\" ]"
}
cleanup() {
	sed -i 's/^[ \t]*//;s/[ \t]*$//' $DATFILE
	sed -i '/^-$/d' $DATFILE
	sed -i '/^$/d' $DATFILE
	sed -i "#'##g" $DATFILE
}
__URL="https://www.cloudflare.com/api_json.html"
__URL="${__URL}?a=rec_load_all"
__URL="${__URL}&tkn=$password"
__URL="${__URL}&email=$username"
__URL="${__URL}&z=$__DOMAIN"
do_transfer "$__URL" || return 1
cleanup
json_load "$(cat $DATFILE)"
__FOUND=0
json_get_var __RES "result"
json_get_var __MSG "msg"
[ "$__RES" != "success" ] && {
	write_log 4 "'rec_load_all' failed with error: \n$__MSG"
	return 1
}
json_select "response"
json_select "recs"
json_select "objs"
json_get_keys __KEYS
for __KEY in $__KEYS; do
	local __ZONE __DISPLAY __NAME __TYPE
	json_select "$__KEY"
	json_get_var __NAME "name"
	json_get_var __TYPE "type"
	if [ "$__NAME" = "$domain" ]; then
		[ \( $use_ipv6 -eq 0 -a "$__TYPE" = "A" \) -o \( $use_ipv6 -eq 1 -a "$__TYPE" = "AAAA" \) ] && {
			__FOUND=1
			break
		}
	fi
	json_select ..
done
[ $__FOUND -eq 0 ] && {
	write_log 14 "No valid record found at Cloudflare setup. Please create first!"
}
json_get_var __RECID "rec_id"
json_cleanup
write_log 7 "rec_id '$__RECID' detected for host/domain '$domain'"
__URL="https://www.cloudflare.com/api_json.html"
__URL="${__URL}?a=rec_edit"
__URL="${__URL}&tkn=$password"
__URL="${__URL}&id=$__RECID"
__URL="${__URL}&email=$username"
__URL="${__URL}&z=$__DOMAIN"
[ $use_ipv6 -eq 0 ] && __URL="${__URL}&type=A"
[ $use_ipv6 -eq 1 ] && __URL="${__URL}&type=AAAA"
[ -n "$__SUBDOM" ] && __URL="${__URL}&name=$__SUBDOM"
[ -z "$__SUBDOM" ] && __URL="${__URL}&name=$__DOMAIN"
__URL="${__URL}&content=$__IP"
__URL="${__URL}&service_mode=0"
__URL="${__URL}&ttl=1"
do_transfer "$__URL" || return 1
cleanup
json_load "$(cat $DATFILE)"
json_get_var __RES "result"
json_get_var __MSG "msg"
[ "$__RES" != "success" ] && {
	write_log 4 "'rec_edit' failed with error:\n$__MSG"
	return 1
}
write_log 7 "Update of rec_id '$__RECID' successful"
return 0
