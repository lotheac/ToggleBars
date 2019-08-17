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

function eh:InitAddon(ev, addon)
  if not (ev == "ADDON_LOADED" and addon == "ToggleBars") then return end
  -- MainMenuBarArtFrame is protected, so we have to use
  -- SecureHandlerClickTemplate to show/hide it
  eh.togglebutton = CreateFrame("BUTTON", "ToggleBarsButton", StatusTrackingBarManager, "SecureHandlerClickTemplate")
  --- Hide frames by default; unprotected ones we can just :Hide() here
  MicroButtonAndBagsBar:Hide()
  -- for the protected frames we need to be more creative to not cause taint.
  -- set up a child for MultiBarLeft with an _onshow handler that always hides
  -- the protected frames we want to hide, *but* remove that handler when the
  -- toggle button is clicked.
  -- the reason we use MultiBarLeft for this is that it gets shown multiple
  -- times on login, even after PLAYER_ENTERING_WORLD.
  eh.multihider = CreateFrame("Frame", "ToggleBarsMultiHider", MultiBarLeft, "SecureHandlerShowHideTemplate")
  eh.multihider:SetFrameRef("main", MainMenuBarArtFrame)
  eh.multihider:SetFrameRef("right", VerticalMultiBarsContainer)
  eh.multihider:SetFrameRef("left", MultiBarLeft)
  eh.multihider:SetAttribute("_onshow", [[
  for _, ref in ipairs(newtable("main", "right", "left")) do
    local f = self:GetFrameRef(ref)
    f:Hide()
  end
  ]])
  function eh.togglebutton:removehider()
    eh.multihider:SetAttribute("_onshow", nil)
  end
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
  owner:CallMethod("removehider")
  for _, ref in ipairs(toggleframes) do
    local f = self:GetFrameRef(ref)
    if show then f:Show() else f:Hide() end
  end
  owner:CallMethod("unprivfunc")
  ]])
end
eh:SetScript("OnEvent", eh.InitAddon)
