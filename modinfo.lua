local CHINESE_CODE = {
    ["zh"]=true,
    ["zhr"]=true,
    ["zht"]=true,
    ["chs"]=true,
}
local function KK_SETSTRING(chs, en)
    return CHINESE_CODE[locale] and chs or en
end

name = "自律人偶-K_K"
description = KK_SETSTRING([[
	画师:无影水镜
	代码:HPMY（Rainbow）
	Ver:1.0.6

	残破不堪的自律人偶，试图将人格模块更改为自己的制造者。
]], [[
	Scripts:HPMY(rainbow)
	Arts:无影水镜
	Ver:1.0.6

	Broken self-discipline doll, trying to change the personality module into its own maker.
]])
author = "无影水镜&HPMY(rainbow)"
version = "1.0.6"

forumthread = ""

api_version = 10

dst_compatible = true

dont_starve_compatible = false
reign_of_giants_compatible = false

all_clients_require_mod = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = {
	"character",
	"k_k",
}

--[[configuration_options = {
	{
		name="",
		label="",
		hover="",
		options=
		{
			{description="",data=},

		},
		default=240,
	},
}]]