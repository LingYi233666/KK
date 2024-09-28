local PLAYERS = {
	ATTACKER = STRINGS.CHARACTERS.GENERIC.DESCRIBE.PLAYER.ATTACKER,
    MURDERER = STRINGS.CHARACTERS.GENERIC.DESCRIBE.PLAYER.MURDERER,
    REVIVER = STRINGS.CHARACTERS.GENERIC.DESCRIBE.PLAYER.REVIVER,
    GHOST = STRINGS.CHARACTERS.GENERIC.DESCRIBE.PLAYER.GHOST,
    FIRESTARTER = STRINGS.CHARACTERS.GENERIC.DESCRIBE.PLAYER.FIRESTARTER,
}

local SPEECH = {
	ACTIONFAIL =
	{
		CHARGE_FROM = {
            NOT_ENOUGH_CHARGE = "能量太少了",
            CHARGE_FULL = "现在无需充能",
        },
        KK_DORMANCY = {
        	OCCUPIED = "被占用了",
    	},
	},

	ANNOUNCE_EAT =
	{
		PAINFUL = "都一样",
		SPOILED = "都一样",
		STALE = "都一样",
    },

	ANNOUNCE_HUNGRY = "能源不足",
	ANNOUNCE_COLD = "我感到我的零件变得迟钝了",
	ANNOUNCE_HOT = "警告,机体已经过热!",
    ANNOUNCE_WORMHOLE = "我感到我的零件变迟钝了",

	BATTLECRY =
	{
		GENERIC = "看这里!",
		PIG = "很快就会结束",
		SPIDERS = "退后!",
		CHESS = "抱歉,我需要你们",
	},

	DESCRIBE = {
		MULTIPLAYER_PORTAL = "这是什么技术?",
		MULTIPLAYER_PORTAL_MOONROCK = "我不理解",
		TENT =
		{
			GENERIC = "让需要的人用吧",
			BURNT = "又是这样......",
		},
		SIESTAHUT =
		{
			GENERIC = "让需要的人用吧",
			BURNT = "又是这样......",
		},
		NIGHTSTICK = "漂亮的武器",
		CANE = "我可以试试强化它",
		TRINKET_6 = "无法充当血管",
		GEARS = "无法安装，已经尝试",
		TRANSISTOR = "它无法用于驱动人体......至少我做不到",
        RESEARCHLAB =
        {
            GENERIC = "我第一次看到它还以为是一个手持长矛和盾牌的机器人",
            BURNT = "又是这样......",
        },
        RESEARCHLAB2 =
        {
            GENERIC = "太好了,我逐渐理解一切",
            BURNT = "又是这样......",
        },
        RESEARCHLAB3 =
        {
            GENERIC = "我不太能理解",
            BURNT = "又是这样......",
        },
        RESEARCHLAB4 =
        {
            GENERIC = "它在呼唤我",
            BURNT = "又是这样......",
        },
        ANCIENT_ALTAR = "这里记录着古老文明的技术结晶",
        ANCIENT_ALTAR_BROKEN = "谁来修一下?",
        MINERHAT = "把它改造成用电的会不会更好",
        LANTERN = "生物能在这个地方得到广泛的运用",
        WAFFLES = "镜小姐以前很爱吃这个",
        GHOST = "......镜小姐?不,你不是",
        BISHOP = "机械造物也会信奉神明吗",
        ROOK = "为什么不把主教和战车结合在一起呢?额,已经有人这么做了?",
        KNIGHT = "镜小姐以前做过类似的东西",
		BISHOP_NIGHTMARE = "暗影连机械的电路也能侵蚀",
		ROOK_NIGHTMARE = "残破的铁块没有让它怯懦半分",
		KNIGHT_NIGHTMARE = "它感到痛苦",
        WX78 =
        {
            GENERIC = "我不喜欢他",
            ATTACKER = PLAYERS.ATTACKER,
            MURDERER = PLAYERS.MURDERER,
            REVIVER = PLAYERS.REVIVER,
            GHOST = PLAYERS.GHOST,
            FIRESTARTER = PLAYERS.FIRESTARTER,
        },
        K_K =
        {
            GENERIC = "......我应该叫你姐妹吗?",
            ATTACKER = PLAYERS.ATTACKER,
            MURDERER = PLAYERS.MURDERER,
            REVIVER = PLAYERS.REVIVER,
            GHOST = PLAYERS.GHOST,
            FIRESTARTER = PLAYERS.FIRESTARTER,
        },
        WINONA =
        {
            GENERIC = "你好啊,机械师小姐",
            ATTACKER = PLAYERS.ATTACKER,
            MURDERER = PLAYERS.MURDERER,
            REVIVER = PLAYERS.REVIVER,
            GHOST = PLAYERS.GHOST,
            FIRESTARTER = PLAYERS.FIRESTARTER,
        },

        XXX_WUMA =
        {
            GENERIC = "熟悉的感觉...你也是机械师吗?",
            ATTACKER = PLAYERS.ATTACKER,
            MURDERER = PLAYERS.MURDERER,
            REVIVER = PLAYERS.REVIVER,
            GHOST = PLAYERS.GHOST,
            FIRESTARTER = PLAYERS.FIRESTARTER,
        },

        XXX_WUMA_CY = "检测到不明能量",
        XXX_WUMA_BOX = "道理我都懂...但是为什么会变成两个?",
        XXX_WUMA_LSD = "好东西,这样就可以拆下更多完整的零件了…等等,你看着我干什么!",
        XXX_WUMA_YSQZ = "好东西,这样就可以拆下更多完整的零件了…等等,你看着我干什么!",
        XXX_WUMA_TV = "试试拍两下?",
        XXX_WUMA_TV2 = "雾码喜欢看美食节目吗?",
        XXX_WUMA_TV_BUNDLE = "打包的电视机",
        NL_ESSENCE_SHADOW = "机械师...也会做这个吗?",
	},
}

for k,v in pairs({"DECIDUOUSTREE","EVERGREEN","EVERGREEN_SPARSE","TWIGGYTREE","MARSH_BUSH","MARSH_TREE","WINTER_TREE"}) do
	SPEECH.DESCRIBE[v] = {
        BURNT = "大火后的残局",
    }
end

for k,v in pairs({"SPIDER_MOON","SPIDER","SPIDER_WARRIOR"}) do
	SPEECH.DESCRIBE[v] = {
        GENERIC = "镜小姐以前很怕这种东西,当它们不在容器内时"
    }
end

for k,v in pairs({"SPIDER_DROPPER","SPIDER_HIDER","SPIDER_SPITTER"}) do
	SPEECH.DESCRIBE[v] = "镜小姐以前很怕这种东西,当它们不在容器内时"
end

for k,v in pairs({"CHESSJUNK1","CHESSJUNK2","CHESSJUNK3"}) do
	SPEECH.DESCRIBE[v] = "里面一定还有能用的"
end

if STRINGS.CHARACTERS.WX78 ~= nil then
    STRINGS.CHARACTERS.WX78.DESCRIBE.K_K = {
        GENERIC = "错误的,你应当得到纠正",
        ATTACKER = STRINGS.CHARACTERS.WX78.DESCRIBE.PLAYER.ATTACKER,
        MURDERER = STRINGS.CHARACTERS.WX78.DESCRIBE.PLAYER.MURDERER,
        REVIVER = STRINGS.CHARACTERS.WX78.DESCRIBE.PLAYER.REVIVER,
        GHOST = STRINGS.CHARACTERS.WX78.DESCRIBE.PLAYER.GHOST,
        FIRESTARTER = STRINGS.CHARACTERS.WX78.DESCRIBE.PLAYER.FIRESTARTER,
    }
end

if STRINGS.CHARACTERS.WINONA ~= nil then
    STRINGS.CHARACTERS.WINONA.DESCRIBE.K_K = {
        GENERIC = "她比另一个更讨人喜欢",
        ATTACKER = STRINGS.CHARACTERS.WINONA.DESCRIBE.PLAYER.ATTACKER,
        MURDERER = STRINGS.CHARACTERS.WINONA.DESCRIBE.PLAYER.MURDERER,
        REVIVER = STRINGS.CHARACTERS.WINONA.DESCRIBE.PLAYER.REVIVER,
        GHOST = STRINGS.CHARACTERS.WINONA.DESCRIBE.PLAYER.GHOST,
        FIRESTARTER = STRINGS.CHARACTERS.WINONA.DESCRIBE.PLAYER.FIRESTARTER,
    }
end

return SPEECH