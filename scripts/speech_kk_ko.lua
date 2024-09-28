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
            NOT_ENOUGH_CHARGE = "에너지가 부족해요.",
            CHARGE_FULL = "아직 충전이 필요하지 않아요.",
        },
        KK_DORMANCY = {
            OCCUPIED = "그건 이미 사용 중이예요.",
        },
    },

    ANNOUNCE_EAT =
    {
        PAINFUL = "저도 마찬가지예요.",
        SPOILED = "저도 마찬가지예요.",
        STALE = "저도 마찬가지예요.",
    },

    ANNOUNCE_HUNGRY = "에너지가 부족해요.",
    ANNOUNCE_COLD = "왠지 제 파츠들이 느려진 것 같아요.",
    ANNOUNCE_HOT = "경고, 구동체가 과열되었습니다!",
    ANNOUNCE_WORMHOLE = "제 파츠들이 둔해지는 것 같아요.",

    BATTLECRY =
    {
        GENERIC = "이쪽이예요!",
        PIG = "금방 처리할게요.",
        SPIDERS = "저리 가세요!",
        CHESS = "미안해요, 당신의 파츠가 필요해요.",
    },

    DESCRIBE = {
        MULTIPLAYER_PORTAL = "어떻게 만들어진 걸까요?",
        MULTIPLAYER_PORTAL_MOONROCK = "해석할 수 없어요.",
        TENT =
        {
            GENERIC = "이게 필요한 사람이 있을 거예요.",
            BURNT = "다시......",
        },
        SIESTAHUT =
        {
            GENERIC = "누군가는 이게 필요할 거예요",
            BURNT = "다시......",
        },
        NIGHTSTICK = "예쁜 무기네요.",
        CANE = "이걸 강화할 수 있을 것 같아요",
        TRINKET_6 = "혈관 역할을 할 수 없어요.",
        GEARS = "해봤지만, 제게 설치할 순 없어요",
        TRANSISTOR = "이걸로 사람 몸을 움직일 순 없어요, 적어도 저는 못할 것 같아요.",
        RESEARCHLAB =
        {
            GENERIC = "이걸 처음 봤을 때, 창과 방패가 달린 로봇인 줄 알았어요.",
            BURNT = "다시......",
        },
        RESEARCHLAB2 =
        {
            GENERIC = "좋아요, 이제 뭔지 조금씩 알 것 같아요.",
            BURNT = "다시......",
        },
        RESEARCHLAB3 =
        {
            GENERIC = "이해가 잘 안 가네요.",
            BURNT = "다시......",
        },
        RESEARCHLAB4 =
        {
            GENERIC = "절 부르고 있어요.",
            BURNT = "다시......",
        },
        ANCIENT_ALTAR = "고대 문명의 기술적 결정체를 담고 있어요.",
        ANCIENT_ALTAR_BROKEN = "이거 고칠 수 있는 분?",
        MINERHAT = "이걸 전기로 바꾸는 게 더 나을까요.",
        LANTERN = "여기선 생물 에너지가 흔하게 사용돼요.",
        WAFFLES = "그녀는 이걸 사용하는 걸 좋아했어요.",
        GHOST = "......당신인가요? 아, 아닌 것 같네요.",
        BISHOP = "기계장치도 신을 믿을까요.",
        ROOK = "왜 비숍을 전차와 합치지 않았을까요?\n어머, 이미 누가 해봤나요?",
        KNIGHT = "그녀가 전에 비슷한 일을 한 적이 있어요.",
        BISHOP_NIGHTMARE = "그림자가 기계 회로까지 좀 먹을 수 있어요.",
        ROOK_NIGHTMARE = "부서진 철에 겁먹지 않아요.",
        KNIGHT_NIGHTMARE = "저건 아파보여요.",
        WX78 =
        {
            GENERIC = "전 그가 싫어요.",
            ATTACKER = PLAYERS.ATTACKER,
            MURDERER = PLAYERS.MURDERER,
            REVIVER = PLAYERS.REVIVER,
            GHOST = PLAYERS.GHOST,
            FIRESTARTER = PLAYERS.FIRESTARTER,
        },
        K_K =
        {
            GENERIC = "어... 언니라고 불러야 할까요?",
            ATTACKER = PLAYERS.ATTACKER,
            MURDERER = PLAYERS.MURDERER,
            REVIVER = PLAYERS.REVIVER,
            GHOST = PLAYERS.GHOST,
            FIRESTARTER = PLAYERS.FIRESTARTER,
        },
        WINONA =
        {
            GENERIC = "안녕하세요, 정비사씨.",
            ATTACKER = PLAYERS.ATTACKER,
            MURDERER = PLAYERS.MURDERER,
            REVIVER = PLAYERS.REVIVER,
            GHOST = PLAYERS.GHOST,
            FIRESTARTER = PLAYERS.FIRESTARTER,
        },

        XXX_WUMA =
        {
            GENERIC = "익숙한 느낌... 당신도 정비사인가요?",
            ATTACKER = PLAYERS.ATTACKER,
            MURDERER = PLAYERS.MURDERER,
            REVIVER = PLAYERS.REVIVER,
            GHOST = PLAYERS.GHOST,
            FIRESTARTER = PLAYERS.FIRESTARTER,
        },

        XXX_WUMA_CY = "알 수 없는 에너지가 느껴져요.",
        XXX_WUMA_BOX = "뭔지 이해했는데...근데 왜 두 개가 되는 걸까요?",
        XXX_WUMA_LSD = "좋네요, 이제 파츠를 완전히 제거할 수 있도록...\n잠시만요, 왜 절 그렇게 보시는 거예요!",
        XXX_WUMA_YSQZ = "좋네요, 이제 파츠를 완전히 제거할 수 있도록...\n잠시만요, 왜 절 그렇게 보시는 거예요!",
        XXX_WUMA_TV = "한 번 더 만져봤나요?",
        XXX_WUMA_TV2 = "우마는 요리 프로그램 보는 걸 좋아하나요?",
        XXX_WUMA_TV_BUNDLE = "포장된 TV에요.",
        NL_ESSENCE_SHADOW = "정비사씨가... 이걸요?",
    },
}

for k,v in pairs({"DECIDUOUSTREE","EVERGREEN","EVERGREEN_SPARSE","TWIGGYTREE","MARSH_BUSH","MARSH_TREE","WINTER_TREE"}) do
    SPEECH.DESCRIBE[v] = {
        BURNT = "타고 남은 것들."
    }
end

for k,v in pairs({"SPIDER_MOON","SPIDER","SPIDER_WARRIOR"}) do
    SPEECH.DESCRIBE[v] = {
        GENERIC = "그녀는 저것들이 갇혀있지 않을 때 무서워하곤 했어요."
    }
end

for k,v in pairs({"SPIDER_DROPPER","SPIDER_HIDER","SPIDER_SPITTER"}) do
    SPEECH.DESCRIBE[v] = "그녀는 저것들이 갇혀있지 않을 때 무서워하곤 했어요."
end

for k,v in pairs({"CHESSJUNK1","CHESSJUNK2","CHESSJUNK3"}) do
    SPEECH.DESCRIBE[v] = "분명 쓸만한 게 들어있을 거예요."
end

if STRINGS.CHARACTERS.WX78 ~= nil then
    STRINGS.CHARACTERS.WX78.DESCRIBE.K_K = {
        GENERIC = "틀렸어요. 정정해주세요.",
        ATTACKER = STRINGS.CHARACTERS.WX78.DESCRIBE.PLAYER.ATTACKER,
        MURDERER = STRINGS.CHARACTERS.WX78.DESCRIBE.PLAYER.MURDERER,
        REVIVER = STRINGS.CHARACTERS.WX78.DESCRIBE.PLAYER.REVIVER,
        GHOST = STRINGS.CHARACTERS.WX78.DESCRIBE.PLAYER.GHOST,
        FIRESTARTER = STRINGS.CHARACTERS.WX78.DESCRIBE.PLAYER.FIRESTARTER,
    }
end

if STRINGS.CHARACTERS.WINONA ~= nil then
    STRINGS.CHARACTERS.WINONA.DESCRIBE.K_K = {
        GENERIC = "다른 사람보단 그녀가 나을 거예요.",
        ATTACKER = STRINGS.CHARACTERS.WINONA.DESCRIBE.PLAYER.ATTACKER,
        MURDERER = STRINGS.CHARACTERS.WINONA.DESCRIBE.PLAYER.MURDERER,
        REVIVER = STRINGS.CHARACTERS.WINONA.DESCRIBE.PLAYER.REVIVER,
        GHOST = STRINGS.CHARACTERS.WINONA.DESCRIBE.PLAYER.GHOST,
        FIRESTARTER = STRINGS.CHARACTERS.WINONA.DESCRIBE.PLAYER.FIRESTARTER,
    }
end

return SPEECH