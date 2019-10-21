-- vim: sw=2 sts=2 et
local eh = CreateFrame("Frame", "ToggleBars", UIParent)
eh:RegisterEvent("ADDON_LOADED")

function eh:UpdateUnprotectedVisibility()
  local frames = { MicroButtonAndBagsBar }
  for _, f in ipairs(frames) do
    if f:IsProtected() then
      print("ToggleBars error: " .. f:GetName() .. " is protected")
    else
      f:SetShown(self.hider:GetAttribute("show"))
    end
  end
end

function eh:InitAddon(ev, addon)
  if not (ev == "ADDON_LOADED" and addon == "ToggleBars") then return end
  -- Hide frames by default; unprotected ones we can just :Hide() here
  MicroButtonAndBagsBar:Hide()
  -- for the protected frames we need to be more creative to not cause taint.
  -- set up a child for MultiBarLeft with an _onshow handler that hides the
  -- protected frames if necessary.
  -- the reason we use MultiBarLeft for this is that it gets shown separately
  -- from other bars, eg. multiple times on login, even after
  -- PLAYER_ENTERING_WORLD.
  eh.hider = CreateFrame("Frame", "ToggleBarsHider", MultiBarLeft, "SecureHandlerShowHideTemplate")
  eh.hider:SetAttribute("show", false)
  eh.hider:SetFrameRef("main", MainMenuBarArtFrame)
  eh.hider:SetFrameRef("right", VerticalMultiBarsContainer)
  eh.hider:SetFrameRef("left", MultiBarLeft)
  eh.hider:SetAttribute("_onshow", [[
  local show = self:GetAttribute("show")
  for _, ref in ipairs(newtable("main", "right", "left")) do
    local f = self:GetFrameRef(ref)
    if show then f:Show() else f:Hide() end
  end
  ]])
  eh.button = CreateFrame("Button", "ToggleBarsButton", StatusTrackingBarManager, "SecureHandlerClickTemplate")
  eh.button:SetFrameStrata("HIGH")
  eh.button.texture = eh.button:CreateTexture()
  eh.button.texture:SetAllPoints()
  eh.button.texture:SetColorTexture(0, 0, 0, 0.4)
  eh.button:SetWidth(16)
  eh.button:SetHeight(16)
  eh.button:SetPoint("TOPLEFT", MainMenuBar, "BOTTOMLEFT", 0, 0)
  eh.button:SetFrameRef("hider", eh.hider)
  eh.button.hider = eh.hider -- needed in UpdateUnprotectedVisibility
  eh.button.unprivfunc = eh.UpdateUnprotectedVisibility
  eh.button:SetAttribute("_onclick", [[
  local hider = self:GetFrameRef("hider")
  local show = not hider:GetAttribute("show")
  hider:SetAttribute("show", show)
  -- trigger _onshow to update frames
  hider:GetParent():Hide()
  hider:GetParent():Show()
  owner:CallMethod("unprivfunc")
  ]])
end
eh:SetScript("OnEvent", eh.InitAddon)
