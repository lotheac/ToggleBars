-- vim: sw=2 sts=2 et
local eh = CreateFrame("Frame", "TBars", UIParent)
eh:RegisterEvent("ADDON_LOADED")

local shown

function eh:HideBars()
  SHOW_MULTI_ACTIONBAR_1 = nil
  SHOW_MULTI_ACTIONBAR_2 = nil
  SHOW_MULTI_ACTIONBAR_3 = nil
  SHOW_MULTI_ACTIONBAR_4 = nil
  InterfaceOptions_UpdateMultiActionBars()
  -- MainMenuBarArtframe includes action buttons etc., but not the exp bar
  MainMenuBarArtFrame:Hide()
  MicroButtonAndBagsBar:Hide()
  shown = false
end
function eh:ShowBars()
  SHOW_MULTI_ACTIONBAR_1 = "1"
  SHOW_MULTI_ACTIONBAR_2 = "1"
  SHOW_MULTI_ACTIONBAR_3 = "1"
  SHOW_MULTI_ACTIONBAR_4 = "1"
  InterfaceOptions_UpdateMultiActionBars()
  MainMenuBarArtFrame:Show()
  MicroButtonAndBagsBar:Show()
  shown = true
end
function eh:ToggleBars()
  if InCombatLockdown() then
    print("Cannot toggle bars in combat")
    return
  end
  if shown then
    eh:HideBars()
  else
    eh:ShowBars()
  end
end

function eh:InitAddon(ev, addon)
  if not (ev == "ADDON_LOADED" and addon == "ToggleBars") then
    return
  end
  eh:HideBars()
  eh.togglebutton = CreateFrame("Button", "ToggleBarsButton", StatusTrackingBarManager)
  eh.togglebutton.texture = eh.togglebutton:CreateTexture()
  eh.togglebutton.texture:SetAllPoints()
  eh.togglebutton.texture:SetColorTexture(0, 0, 0, 0.4)
  eh.togglebutton:SetWidth(16)
  eh.togglebutton:SetPoint("TOPLEFT", StatusTrackingBarManager.SingleBarSmall, "TOPLEFT")
  eh.togglebutton:SetPoint("BOTTOMLEFT", StatusTrackingBarManager.SingleBarSmall, "BOTTOMLEFT")
  eh.togglebutton:SetScript("OnClick", eh.ToggleBars)
end
eh:SetScript("OnEvent", eh.InitAddon)
