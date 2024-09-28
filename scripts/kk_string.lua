----------------------------------------------------------------
local GetDescription_AddSpecialCases_old = GetDescription_AddSpecialCases
_G.GetDescription_AddSpecialCases = function(ret, charactertable, inst, item, modifier)
    if type(inst) == "table" and inst.prefab == "k_k" and modifier == "BURNT" and not item:HasTag("tree") then
        return KK_SETSTRING("又是这样......", "으음... 다시......", "Again......")
    end
    if type(inst) == "table" and inst.prefab == "k_k" and item:HasTag("chess") then
        local leader = item.components and item.components.follower and item.components.follower:GetLeader()
        local forever = leader and item.components.follower:GetLoyaltyPercent() == 0
        if leader ~= nil and leader.prefab == "xxx_wuma" and forever then
            return KK_SETSTRING("我也想要这么忠诚的帮手...", "저도 절 도와줄 사람이 필요해요.", "I also want such a loyal helper...")
        end
    end
    return GetDescription_AddSpecialCases_old(ret, charactertable, inst, item, modifier)
end
----------------------------------------------------------------
STRINGS.NAMES.KK_DLC = KK_SETSTRING("动力锤", "동력망치", "Power hammer")
STRINGS.RECIPE_DESC.KK_DLC = KK_SETSTRING("咚!咚!咚!", "얍! 얍! 얍!", "Chop!chop!chop!")
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KK_DLC = {
    GENERIC = KK_SETSTRING("如果我能早点拥有这样的力量......", "제가 이 힘을 좀 더 일찍 가졌더라면......", "If I could have such power earlier......"),
    OFF = KK_SETSTRING("依然趁手", "여전히 쓸만해요", "Still usable"),
}

STRINGS.NAMES.KK_HOLYSWORD = KK_SETSTRING("物理学圣剑", "물리학 성검", "The holy sword of physics")
STRINGS.RECIPE_DESC.KK_HOLYSWORD = KK_SETSTRING("简单粗暴", "단순하고 조잡합니다.", "Simple and Crude")
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KK_HOLYSWORD = KK_SETSTRING("对棋子使用撬棍吧", "훌륭한 대화수단", "Use crowbar on chess")

STRINGS.NAMES.KK_TRANSMITTER = KK_SETSTRING("发条召唤器", "전파송신기", "Transmitter")
STRINGS.RECIPE_DESC.KK_TRANSMITTER = KK_SETSTRING("召唤世界上游荡的发条们", "...", "...")
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KK_TRANSMITTER = KK_SETSTRING("出来吧,我的援军", "...", "...")

STRINGS.ACTIONS.CASTAOE.KK_DLC = KK_SETSTRING("动力锤", "동력망치", "Power hammer")

STRINGS.NAMES.KK_WRECKAGE = KK_SETSTRING("残破的躯体", "망가진 동체", "Broken body")
STRINGS.RECIPE_DESC.KK_WRECKAGE = KK_SETSTRING("\"铭记伤痕,然后变强\"", "\"이 아픔을 기억하고, 더 강해져야해요.\"", "\"Remember the scars, and then become stronger\"")
STRINGS.CHARACTERS.K_K.DESCRIBE.KK_WRECKAGE = KK_SETSTRING("\"我\"?", "\"이게 나\"?", "\"Me\"?")

STRINGS.NAMES.KK_REPAIRE = KK_SETSTRING("修复", "수리", "Repaire")
STRINGS.RECIPE_DESC.KK_REPAIRE = KK_SETSTRING("恢复出厂设置", "새것처럼 복구해 줍니다", "Restore factory settings")

STRINGS.NAMES.KK_DEREPAIRE = KK_SETSTRING("拆解", "해체", "Disassemble")
STRINGS.RECIPE_DESC.KK_DEREPAIRE = STRINGS.RECIPE_DESC.KK_WRECKAGE

STRINGS.NAMES.KK_MAINTAIN = KK_SETSTRING("维护系统", "유지보수", "Maintain")
STRINGS.RECIPE_DESC.KK_MAINTAIN = KK_SETSTRING("紧急维护", "긴급수리", "Emergency maintenance")

STRINGS.NAMES.KK_WORKSPACE = KK_SETSTRING("机械工坊", "기계 작업대", "Mechanical workshop")
STRINGS.RECIPE_DESC.KK_WORKSPACE = KK_SETSTRING("可以加工一些简陋的机械", "간단한 기계장치 정도는 만들 수 있습니다.", "Can process some simple machines")
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KK_WORKSPACE = {
    GENERIC = KK_SETSTRING("它本来可以有更多功能", "좀 더 많은 걸 할 수 있을 거예요", "It could have more functions"),
    LOWPOWER = KK_SETSTRING("它快没电了", "거의 방전된 것 같네요.", "It's almost dead"),
    OFF = KK_SETSTRING("没有能源可无法让它工作", "에너지가 없으면 작동하지 않아요.", "It can't work without energy"),
    BURNING = KK_SETSTRING("糟了", "어, 이런...", "Oh, no"),
    BURNT = KK_SETSTRING("又是这样......", "다시 한 번......", "Again......"),
}

STRINGS.NAMES.KK_WCTOPHAT = KK_SETSTRING("水冷高礼帽", "수냉식 실크햇", "Water-cooled tophat")
STRINGS.RECIPE_DESC.KK_WCTOPHAT = KK_SETSTRING("这个造型很机械师,非常适合她", "기계적으로 생긴 형태,그녀에게 잘 어울릴 것 같습니다", "This shape is very mechanical, very suitable for her")
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KK_WCTOPHAT = KK_SETSTRING("或许我可以再加一个风扇散热......", "아마 쿨러를 하나 더 추가할 수 있을 것 같아요......", "Maybe I can add another fan for cooling......")

STRINGS.NAMES.KK_CANE = KK_SETSTRING("统领者权杖", "충격 지팡이", "Shocking Staff")
STRINGS.RECIPE_DESC.KK_CANE = KK_SETSTRING("目光所及之处，即为发条所向之处", "다친 비숍은 없습니다.", "No bishop was hurt")
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KK_CANE = {
    GENERIC = KK_SETSTRING("远古遗迹是我双手的延伸", "벌이에요!", "Punish!"),
    OFF = KK_SETSTRING("没事,它还能敲人", "괜찮아요. 이걸로 기절시킬 수 있을거예요.", "It's okay. It can knock people"),
}

STRINGS.NAMES.KK_DORMANCY = KK_SETSTRING("休眠舱", "안식처", "Dormancy cabin")
STRINGS.RECIPE_DESC.KK_DORMANCY = KK_SETSTRING("活物禁止入内!", "생명체 출입금지!", "No live creatures!")
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KK_DORMANCY = {
    GENERIC = KK_SETSTRING("嗨，休眠仓先生~", "안녕하세요，저의 보금자리씨~", "Hi, MR.Dormancy"),
    OFF = KK_SETSTRING("现在你不能把人抓进去了", "이제 아무도 들어갈 수 없어요.", "Now you can't get people in"),
    BURNING = STRINGS.CHARACTERS.GENERIC.DESCRIBE.KK_WORKSPACE.BURNING,
    BURNT = STRINGS.CHARACTERS.GENERIC.DESCRIBE.KK_WORKSPACE.BURNT,
}

STRINGS.NAMES.KK_BATTERY = KK_SETSTRING("蓄电池", "충전지", "Storage battery")
STRINGS.RECIPE_DESC.KK_BATTERY = KK_SETSTRING("不可食用", "식음불가", "Not edible")
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KK_BATTERY = KK_SETSTRING("远离热源", "불을 멀리하세요.", "Keep away from heat sources")

STRINGS.NAMES.KK_IRONPLATE = KK_SETSTRING("厚重铁片", "무거운 쇳조각", "Heavy iron sheet")
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KK_IRONPLATE = KK_SETSTRING("上面有撞击的痕迹", "충격을 받은 흔적이 있어요.", "There are impact marks on it")

STRINGS.NAMES.KK_MECHANICAL_EYE = KK_SETSTRING("电子眼", "전자 렌즈", "Electronic eye")
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KK_MECHANICAL_EYE = KK_SETSTRING("巨大的眼睛", "커다란 눈", "Big eyes")
STRINGS.CHARACTERS.K_K.DESCRIBE.KK_MECHANICAL_EYE = KK_SETSTRING("我也想要可以发射出电球的眼睛", "저도 빔을 쏠 수 있는 눈이 갖고 싶어요.", "I also want eyes that can emit electric balls")

STRINGS.NAMES.KK_MECHANICAL_LEG = KK_SETSTRING("机械肢", "다리 파츠", "Mechanical limb")
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KK_MECHANICAL_LEG = KK_SETSTRING("巨大的机械肢", "커다란 다리 파츠", "Big limbs")
STRINGS.CHARACTERS.K_K.DESCRIBE.KK_MECHANICAL_LEG = KK_SETSTRING("装上它会不会只能斜着走?", "이걸로 옆으로 걸을 수 있을까요?", "Will you have to walk sideways with it?")

--STRINGS.RECIPE_DESC.BLOODCUP = "Drink less."
STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.BUILD.KK_ONLYBROKEN = KK_SETSTRING("只能在未修复下进行", "이미 수리했어요", "Already repaired")
STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.BUILD.KK_ONLYREPAIRED = KK_SETSTRING("只能在修复后进行", "수리가 먼저예요.", "Only after repair")

STRINGS.NAMES.KK_COATING_HUMANLIKE = KK_SETSTRING("仿生涂装", "생체코팅", "Bionic coating")
STRINGS.RECIPE_DESC.KK_COATING_HUMANLIKE = KK_SETSTRING("像个人一样去生活,这是她的愿望", "사람처럼 사는 것이 그녀의 바램입니다.", "It's her wish to live like a person")
STRINGS.NAMES.KK_COATING_NIGHTMARE = KK_SETSTRING("噩梦涂装", "악몽코팅", "Nightmare coating")
STRINGS.RECIPE_DESC.KK_COATING_NIGHTMARE = KK_SETSTRING("彻底疯狂!", "완전한 광기!", "Completely crazy!")

STRINGS.KK_COATING_CAUTION = KK_SETSTRING("涂层快要脱落了!", "코팅이 벗겨질 것 같아요!", "The coating is about to fall off!")

STRINGS.SKIN_NAMES.k_k_humanlike = STRINGS.NAMES.KK_COATING_HUMANLIKE 
STRINGS.SKIN_NAMES.k_k_nightmare = STRINGS.NAMES.KK_COATING_NIGHTMARE

if STRINGS.RECIPE_DESC.GEARS == nil then
    STRINGS.RECIPE_DESC.GEARS = KK_SETSTRING("拆除可用部分......", "사용 가능한 부품 분리......", "Dismantle the usable parts......")
end