-- vim: sw=2 sts=2 et
local eh = CreateFrame("Frame", "TBars", UIParent)
eh:RegisterEvent("ADDON_LOADED")

function eh:UpdateUnprotectedVisibility()
  local frames = { MicroButtonAndBagsBar }
  for _, f in ipairs(frames) do
    if f:IsProtected() then
      print("ToggleBars error: " .. f:GetName() .. " is protected")
    else
      f:SetShown(MainMenuBarArtFrame:IsShown())
    end
  end
end

function eh:SetDefaults()
  MainMenuBarArtFrame:Hide()
  MicroButtonAndBagsBar:Hide()
  -- MultiBarLeft:Hide() called from here may not actually hide it; most likely
  -- something else shows it afterward. and because Blizzard, MultiBarLeft is
  -- actually not contained in VerticalMultiBarsContainer. So just hook
  -- MultiActionBar_Update to set visibility on both.
  hooksecurefunc("MultiActionBar_Update", function()
    local show = MainMenuBarArtFrame:IsShown()
    MultiBarLeft:SetShown(show)
    VerticalMultiBarsContainer:SetShown(show)
  end)
end

function eh:InitAddon(ev, addon)
  if not (ev == "ADDON_LOADED" and addon == "ToggleBars") then return end
  eh:SetDefaults()
  -- MainMenuBarArtFrame is protected, so we have to use
  -- SecureHandlerClickTemplate to show/hide it
  eh.togglebutton = CreateFrame("BUTTON", "ToggleBarsButton", StatusTrackingBarManager, "SecureHandlerClickTemplate")
  eh.togglebutton.texture = eh.togglebutton:CreateTexture()
  eh.togglebutton.texture:SetAllPoints()
  eh.togglebutton.texture:SetColorTexture(0, 0, 0, 0.4)
  eh.togglebutton:SetWidth(16)
  eh.togglebutton:SetHeight(16)
  eh.togglebutton:SetPoint("TOPLEFT", MainMenuBar, "BOTTOMLEFT", 0, 0)
  eh.togglebutton:SetFrameRef("main", MainMenuBarArtFrame)
  eh.togglebutton:SetFrameRef("right", VerticalMultiBarsContainer)
  eh.togglebutton:SetFrameRef("left", MultiBarLeft)
  eh.togglebutton.unprivfunc = eh.UpdateUnprotectedVisibility
  eh.togglebutton:SetAttribute("_onclick", [[
  local toggleframes = newtable("main", "left", "right")
  local main = self:GetFrameRef("main")
  local show = not main:IsShown()
  for _, ref in ipairs(toggleframes) do
    local f = self:GetFrameRef(ref)
    if show then f:Show() else f:Hide() end
  end
  owner:CallMethod("unprivfunc")
  ]])
end
eh:SetScript("OnEvent", eh.InitAddon)
