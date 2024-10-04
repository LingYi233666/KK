GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
local IsServer = TheNet:GetIsServer()
local CHINESE_CODE = {
    ["zh"] = true,
    ["zhr"] = true,
    ["zht"] = true,
    ["chs"] = true,
}
GLOBAL.L_Chinese = CHINESE_CODE[LanguageTranslator.defaultlang]
GLOBAL.L_Korean = LanguageTranslator.defaultlang == "ko"

PrefabFiles = {
    "k_k",
    "k_k_none",
    "kk_dlc",
    "kk_wreckage",
    "kk_workspace",
    "kk_light",
    "kk_wctophat",
    "kk_cane",
    "kk_materials",
    "kk_shadow_fx",
    "kk_coating",
    "kk_dormancy",
    "kk_holysword",
    "kk_transmitter",

    "kk_nightmare_transform_fx",
}

Assets = {
    Asset("IMAGE", "images/saveslot_portraits/k_k.tex"),
    Asset("ATLAS", "images/saveslot_portraits/k_k.xml"),

    Asset("IMAGE", "images/selectscreen_portraits/k_k.tex"),
    Asset("ATLAS", "images/selectscreen_portraits/k_k.xml"),

    Asset("IMAGE", "images/selectscreen_portraits/k_k_silho.tex"),
    Asset("ATLAS", "images/selectscreen_portraits/k_k_silho.xml"),

    Asset("IMAGE", "bigportraits/k_k.tex"),
    Asset("ATLAS", "bigportraits/k_k.xml"),

    Asset("IMAGE", "images/map_icons/kk_map_icons.tex"),
    Asset("ATLAS", "images/map_icons/kk_map_icons.xml"),

    Asset("IMAGE", "images/avatars/avatar_k_k.tex"),
    Asset("ATLAS", "images/avatars/avatar_k_k.xml"),

    Asset("IMAGE", "images/avatars/avatar_ghost_k_k.tex"),
    Asset("ATLAS", "images/avatars/avatar_ghost_k_k.xml"),

    Asset("IMAGE", "images/avatars/self_inspect_k_k.tex"),
    Asset("ATLAS", "images/avatars/self_inspect_k_k.xml"),

    Asset("IMAGE", "images/names_k_k.tex"),
    Asset("ATLAS", "images/names_k_k.xml"),

    Asset("IMAGE", "bigportraits/k_k_none.tex"),
    Asset("ATLAS", "bigportraits/k_k_none.xml"),

    Asset("IMAGE", "bigportraits/k_k_humanlike.tex"),
    Asset("ATLAS", "bigportraits/k_k_humanlike.xml"),

    Asset("IMAGE", "images/inventoryimages/kk_inventoryimages.tex"),
    Asset("ATLAS", "images/inventoryimages/kk_inventoryimages.xml"),

    Asset("ANIM", "anim/kk_light.zip"),
    Asset("ANIM", "anim/status_kk_humanlike.zip"),
    Asset("ANIM", "anim/status_kk_nightmare.zip"),
    --Asset("ANIM", "anim/customanim.zip"),
}

GLOBAL.KK_IMAGES = "images/inventoryimages/kk_inventoryimages.xml"

GLOBAL.PREFAB_SKINS["k_k"] = {
    "k_k_none",
}

GLOBAL.KK_MODNAME = modname

GLOBAL.KK_SETSTRING = function(chs, ko, en)
    return L_Chinese and chs or (L_Korean and ko or en or "?")
end

-- The character select screen lines
STRINGS.CHARACTER_TITLES.k_k = KK_SETSTRING("拥有灵魂的机器人", "영혼이 담긴 로봇", "Robot with soul")
STRINGS.CHARACTER_NAMES.k_k = "K_K"
STRINGS.CHARACTER_DESCRIPTIONS.k_k = KK_SETSTRING("*拥有较为低效的食物转换能源系统\n*不接受治疗，只接受维修\n*可以与发条们结盟",
    "*비효율적인 음식효율\n*오직 유지보수로만 회복가능\n*태엽장치들이 우호적으로 인식합니다",
    "*Have a relatively inefficient food conversion energy system\n*Only accept maintenance\n*Can align with the clockwork")
STRINGS.CHARACTER_QUOTES.k_k = KK_SETSTRING("\"心智核心异常\"", "\"심층심리 이상감지\"", "\"Mental core abnormality\"")

-- Custom speech strings
if L_Chinese then
    STRINGS.CHARACTERS.K_K = require "speech_kk_ch"
elseif L_Korean then
    STRINGS.CHARACTERS.K_K = require "speech_kk_ko"
else
    STRINGS.CHARACTERS.K_K = require "speech_kk_en"
end

STRINGS.CHARACTER_SURVIVABILITY.k_k = KK_SETSTRING("严峻", "절망적임", "Grim")

TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.K_K = { "kk_wctophat_20_percent", "kk_battery", "lantern", "gears", "gears" }

TUNING.STARTING_ITEM_IMAGE_OVERRIDE["kk_battery"] = {
    atlas = KK_IMAGES,
    image = "kk_battery.tex",
}

TUNING.STARTING_ITEM_IMAGE_OVERRIDE["kk_wctophat_20_percent"] = {
    atlas = KK_IMAGES,
    image = "kk_wctophat.tex",
}

-- The character's name as appears in-game
STRINGS.NAMES.K_K = "K_K"
STRINGS.SKIN_NAMES.k_k_none = "K_K"

AddMinimapAtlas("images/map_icons/kk_map_icons.xml")
AddMinimapAtlas(KK_IMAGES)

local skin_modes = {
    {
        type = "ghost_skin",
        anim_bank = "ghost",
        idle_anim = "idle",
        scale = 0.75,
        offset = { 0, -25 }
    },
}

AddModCharacter("k_k", "FEMALE", skin_modes)

TUNING.K_K_HEALTH = 100
TUNING.K_K_HUNGER = 100
TUNING.K_K_SANITY = 100

_G.KK_IMAGES_CACHE = {}
local function RegisterImages(path, cache)
    local images_path = MODROOT .. path
    local file = io.open(images_path, "r")
    if not file then
        print("RegisterImages:Can not open file " .. images_path)
        return cache
    end
    local image_data = file:read("*a")
    file:close()
    image_data = image_data:gsub("%s+", " ")
    cache = cache or {}
    for image in image_data:gmatch("<Element name=\"(.-)\"") do
        RegisterInventoryItemAtlas(images_path, image)
        cache[image] = images_path
    end
    return cache
end

RegisterImages(KK_IMAGES, KK_IMAGES_CACHE)

GLOBAL.UpvalueHacker = require("upvaluehacker")

modimport("scripts/kk_skins.lua")
modimport("scripts/kk_string.lua")
modimport("scripts/kk_api.lua")
modimport("scripts/kk_actions.lua")
modimport("scripts/kk_recipes.lua")
