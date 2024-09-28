local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

local KK_Badge = Class(Badge, function(self, owner, build, colour)
    Badge._ctor(self, nil, owner, colour or {255/255, 204/255, 51/255, 1}, build or "status_kk_humanlike", nil, nil, true)

    if self.circleframe ~= nil then
        self.circleframe:GetAnimState():Hide("frame")
    else
        self.anim:GetAnimState():Hide("frame")
    end

    self.circleframe2 = self.underNumber:AddChild(UIAnim())
    self.circleframe2:GetAnimState():SetBank("status_meter")
    self.circleframe2:GetAnimState():SetBuild(build or "status_kk_humanlike")
    self.circleframe2:GetAnimState():PlayAnimation("frame")
    self.circleframe2:GetAnimState():Hide("icon")
    self.circleframe2:GetAnimState():AnimateWhilePaused(false)

    self.arrow = self.underNumber:AddChild(UIAnim())
    self.arrow:GetAnimState():SetBank("sanity_arrow")
    self.arrow:GetAnimState():SetBuild("sanity_arrow")
    self.arrow:GetAnimState():PlayAnimation("neutral")
    self.arrow:SetClickable(false)
    self.arrow:GetAnimState():AnimateWhilePaused(false)

    self:Hide()
    self:StartUpdating()
end)

function KK_Badge:OnUpdate(dt)
end

function KK_Badge:SetPercent(val, max, timeleft)
    Badge.SetPercent(self, val, max)
    local min = math.ceil(math.floor(timeleft/60))
    local time = ((min > 0 and tostring(min).."min") or "")..tostring(math.ceil(timeleft%60)).."s"
    self.num:SetString(time)
end

return KK_Badge
