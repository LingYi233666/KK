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
            NOT_ENOUGH_CHARGE = "Too little energy",
            CHARGE_FULL = "No need to charge now",
        },
        KK_DORMANCY = {
        	OCCUPIED = "It is occupied",
    	},
	},

	ANNOUNCE_EAT =
	{
		PAINFUL = "It's the same to me",
		SPOILED = "It's the same to me",
		STALE = "It's the same to me",
    },

	ANNOUNCE_HUNGRY = "Insufficient energy",
	ANNOUNCE_COLD = "I feel my parts become dull",
	ANNOUNCE_HOT = "Warning, the engine body has overheated!",
    ANNOUNCE_WORMHOLE = "I feel my parts become dull",

	BATTLECRY =
	{
		GENERIC = "Look here!",
		PIG = "It will be over soon",
		SPIDERS = "Go back!",
		CHESS = "Sorry, I need you",
	},

	DESCRIBE = {
		MULTIPLAYER_PORTAL = "What technology is it?",
		MULTIPLAYER_PORTAL_MOONROCK = "I don't understand",
		TENT =
		{
			GENERIC = "Let the people in need use it",
			BURNT = "Again......",
		},
		SIESTAHUT =
		{
			GENERIC = "Let the people in need use it",
			BURNT = "Again......",
		},
		NIGHTSTICK = "Beautiful weapon",
		CANE = "I can try to strengthen it",
		TRINKET_6 = "Can't act as a blood vessel",
		GEARS = "Unable to install, attempted",
		TRANSISTOR = "t cannot be used to drive the human body, at least I can't",
        RESEARCHLAB =
        {
            GENERIC = "The first time I saw it, I thought it was a robot with a spear and shield",
            BURNT = "Again......",
        },
        RESEARCHLAB2 =
        {
            GENERIC = "Great, I gradually understand everything",
            BURNT = "Again......",
        },
        RESEARCHLAB3 =
        {
            GENERIC = "I don't quite understand",
            BURNT = "Again......",
        },
        RESEARCHLAB4 =
        {
            GENERIC = "It's calling me",
            BURNT = "Again......",
        },
        ANCIENT_ALTAR = "It records the technological crystallization of ancient civilization",
        ANCIENT_ALTAR_BROKEN = "Who will repair it?",
        MINERHAT = "Would it be better to transform it into electricity",
        LANTERN = "Biological energy is widely used in this area",
        WAFFLES = "Miss 镜 used to love this",
        GHOST = "......Miss 镜?No, you're not",
        BISHOP = "Will mechanical creations also believe in gods",
        ROOK = "Why not combine the bishop with the chariot?\nWell, has someone done this already?",
        KNIGHT = "Miss 镜 has done similar things before",
		BISHOP_NIGHTMARE = "Shadows can erode even mechanical circuits",
		ROOK_NIGHTMARE = "The broken iron doesn't make it cowardly",
		KNIGHT_NIGHTMARE = "It feels painful",
        WX78 =
        {
            GENERIC = "I don't like him",
            ATTACKER = PLAYERS.ATTACKER,
            MURDERER = PLAYERS.MURDERER,
            REVIVER = PLAYERS.REVIVER,
            GHOST = PLAYERS.GHOST,
            FIRESTARTER = PLAYERS.FIRESTARTER,
        },
        K_K =
        {
            GENERIC = "......Should I call you sister?",
            ATTACKER = PLAYERS.ATTACKER,
            MURDERER = PLAYERS.MURDERER,
            REVIVER = PLAYERS.REVIVER,
            GHOST = PLAYERS.GHOST,
            FIRESTARTER = PLAYERS.FIRESTARTER,
        },
        WINONA =
        {
            GENERIC = "Hello, Miss Mechanic",
            ATTACKER = PLAYERS.ATTACKER,
            MURDERER = PLAYERS.MURDERER,
            REVIVER = PLAYERS.REVIVER,
            GHOST = PLAYERS.GHOST,
            FIRESTARTER = PLAYERS.FIRESTARTER,
        },

        XXX_WUMA =
        {
            GENERIC = "Familiar feeling... Are you also a mechanic?",
            ATTACKER = PLAYERS.ATTACKER,
            MURDERER = PLAYERS.MURDERER,
            REVIVER = PLAYERS.REVIVER,
            GHOST = PLAYERS.GHOST,
            FIRESTARTER = PLAYERS.FIRESTARTER,
        },

        XXX_WUMA_CY = "Unknown energy detected",
        XXX_WUMA_BOX = "I understand the truth... but why become two?",
        XXX_WUMA_LSD = "Good thing, so that more complete parts can be removed...\nWait, what are you looking at me!",
        XXX_WUMA_YSQZ = "Good thing, so that more complete parts can be removed...\nWait, what are you looking at me!",
        XXX_WUMA_TV = "Try to pat it twice?",
        XXX_WUMA_TV2 = "Does Wuma like to watch food programs?",
        XXX_WUMA_TV_BUNDLE = "Packed TV",
        NL_ESSENCE_SHADOW = "Can a mechanic... do this?",
	},
}

for k,v in pairs({"DECIDUOUSTREE","EVERGREEN","EVERGREEN_SPARSE","TWIGGYTREE","MARSH_BUSH","MARSH_TREE","WINTER_TREE"}) do
	SPEECH.DESCRIBE[v] = {
        BURNT = "The aftermath of the fire",
    }
end

for k,v in pairs({"SPIDER_MOON","SPIDER","SPIDER_WARRIOR"}) do
	SPEECH.DESCRIBE[v] = {
        GENERIC = "Miss 镜 used to be afraid of such things when they were not in the container"
    }
end

for k,v in pairs({"SPIDER_DROPPER","SPIDER_HIDER","SPIDER_SPITTER"}) do
	SPEECH.DESCRIBE[v] = "Miss 镜 used to be afraid of such things when they were not in the container"
end

for k,v in pairs({"CHESSJUNK1","CHESSJUNK2","CHESSJUNK3"}) do
	SPEECH.DESCRIBE[v] = "There must be something useful in it"
end

if STRINGS.CHARACTERS.WX78 ~= nil then
    STRINGS.CHARACTERS.WX78.DESCRIBE.K_K = {
        GENERIC = "Wrong, you should be corrected",
        ATTACKER = STRINGS.CHARACTERS.WX78.DESCRIBE.PLAYER.ATTACKER,
        MURDERER = STRINGS.CHARACTERS.WX78.DESCRIBE.PLAYER.MURDERER,
        REVIVER = STRINGS.CHARACTERS.WX78.DESCRIBE.PLAYER.REVIVER,
        GHOST = STRINGS.CHARACTERS.WX78.DESCRIBE.PLAYER.GHOST,
        FIRESTARTER = STRINGS.CHARACTERS.WX78.DESCRIBE.PLAYER.FIRESTARTER,
    }
end

if STRINGS.CHARACTERS.WINONA ~= nil then
    STRINGS.CHARACTERS.WINONA.DESCRIBE.K_K = {
        GENERIC = "She is more likeable than the other",
        ATTACKER = STRINGS.CHARACTERS.WINONA.DESCRIBE.PLAYER.ATTACKER,
        MURDERER = STRINGS.CHARACTERS.WINONA.DESCRIBE.PLAYER.MURDERER,
        REVIVER = STRINGS.CHARACTERS.WINONA.DESCRIBE.PLAYER.REVIVER,
        GHOST = STRINGS.CHARACTERS.WINONA.DESCRIBE.PLAYER.GHOST,
        FIRESTARTER = STRINGS.CHARACTERS.WINONA.DESCRIBE.PLAYER.FIRESTARTER,
    }
end

return SPEECH