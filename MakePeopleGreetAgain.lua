MPGAAddon = LibStub("AceAddon-3.0"):NewAddon("MakePeopleGreetAgain", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("MakePeopleGreetAgain")
local mpgaLDB = LibStub("LibDataBroker-1.1"):NewDataObject("MakePeopleGreetAgain", {
  type = "data source",
  text = L["MPGA_MMBTooltipTitle"],
  icon = "Interface\\Icons\\Achievement_GuildPerk_EverybodysFriend",
  OnTooltipShow = function(tooltip)
       tooltip:SetText(L["MPGA_MMBTooltipTitle"])
       tooltip:AddLine(L["MPGA_MMBTooltipInfo"], 1, 1, 1)
       tooltip:Show()
  end,
  OnClick = function(self, button)
    if button == "LeftButton" then
      MPGAAddon:ToggleMainFrame()
    elseif button == "RightButton" then
      MPGAAddon:ShowOptionsFrame()
    end
  end})
local MPGAMiniMapButton = LibStub("LibDBIcon-1.0")
--
local _Colors = MPGAAddon_GetColors()
local _defaultConfig = MPGAAddon_GetDefaultConfig()


--[[
ToDo-List:
  - slash commands für Aktionen zur "Steuerung"
  - showHelp Funktion für Ausgabe der möglichen Befehle implementieren

ToCome / Ideos List:
  - Buttons mit (auswählbaren) Icons zum Klicken?
  - Button-Texte konfigurierbar machen

]]


--------------------------------------------------
-- Variable definitions
--------------------------------------------------
local _OffsetX = 16
local _OffsetX_Default = 16
local _OffsetX_Step = 48
local _OffsetY = -32
local _OffsetY_Step = -24


--------------------------------------------------
-- General Functions
--------------------------------------------------
local function addButton(container, identifier, chatType, chatChannel, font, buttonCount)
  local button = CreateFrame("Button", "MPGA_"..identifier.."_Button", container, "MPGA_UIPanelButtonTemplate");
  button:SetPoint("TOPLEFT", container, "TOPLEFT", _OffsetX, _OffsetY)
  button:SetText(L["MPGA_"..identifier.."_Button"])
  button:SetScript("OnClick", function(self)
      MPGAAddon_SendMessage(identifier, chatType, chatChannel)
  end)
  button:SetNormalFontObject(font);
  button:SetHighlightFontObject(font);

  if buttonCount % MPGAAddon.db.profile.config.buttonsPerRow == 0 then
    _OffsetY = _OffsetY + _OffsetY_Step
    _OffsetX = _OffsetX_Default
  else
    _OffsetX = _OffsetX + _OffsetX_Step
  end
end

function MPGAAddon_SendMessage(identifier, chatType, channel)
  local messages

  if identifier == "GuildGreeting" then
    messages = {strsplit(",", MPGAAddon.db.profile.messages.guild.greeting)}
  elseif identifier == "GuildFarewell" then
    messages = {strsplit(",", MPGAAddon.db.profile.messages.guild.farewell)}
  elseif identifier == "GuildCongratulations" then
    messages = {strsplit(",", MPGAAddon.db.profile.messages.guild.congratulations)}
  elseif identifier == "GuildThanks" then
    messages = {strsplit(",", MPGAAddon.db.profile.messages.guild.thanks)}
  elseif identifier == "PartyGreeting" then
    messages = {strsplit(",", MPGAAddon.db.profile.messages.party.greeting)}
  elseif identifier == "PartyFarewell" then
    messages = {strsplit(",", MPGAAddon.db.profile.messages.party.farewell)}
  elseif identifier == "InstanceGreeting" then
    messages = {strsplit(",", MPGAAddon.db.profile.messages.instance.greeting)}
  elseif identifier == "InstanceFarewell" then
    messages = {strsplit(",", MPGAAddon.db.profile.messages.instance.farewell)}
  end

  SendChatMessage(strtrim(messages[math.random(#messages)]), chatType, nil, channel)
end

function MPGAAddon_SetupPopupDialogs()
  -- perform reload when needed
  StaticPopupDialogs["MPGA_PerformReload"] = {
    text = L["MPGA_PerformReload"],
    button1 = L["MPGA_Yes"],
    button2 = L["MPGA_No"],
    OnAccept = function()
      ReloadUI()
    end,
    OnCancel = function()
      MPGAAddon:Print(L["MPGA_NotReloaded"])
    end,
    timeout = 0,
    whileDead = false,
    hideOnEscape = true,
    preferredIndex = 3
  }
end

function MPGAAddon_SetupGUI()
  local buttonCount = 0

  local buttonsFrame = CreateFrame("Frame", "MPGA_ButtonsFrame", MakePeopleGreetAgain);
  buttonsFrame:SetAllPoints()

  -- GUILD
  local infoGuild = ChatTypeInfo["GUILD"]
  local fontGuild = CreateFont("fontGuild")
  fontGuild:SetTextColor(infoGuild.r, infoGuild.g, infoGuild.b, 1)

  if MPGAAddon.db.profile.config.guild.greeting then
    buttonCount = buttonCount + 1
    addButton(buttonsFrame, "GuildGreeting", "GUILD", "g", fontGuild, buttonCount)
  end
  if MPGAAddon.db.profile.config.guild.farewell then
    buttonCount = buttonCount + 1
    addButton(buttonsFrame, "GuildFarewell", "GUILD", "g", fontGuild, buttonCount)
  end
  if MPGAAddon.db.profile.config.guild.congratulations then
    buttonCount = buttonCount + 1
    addButton(buttonsFrame, "GuildCongratulations", "GUILD", "g", fontGuild, buttonCount)
  end
  if MPGAAddon.db.profile.config.guild.thanks then
    buttonCount = buttonCount + 1
    addButton(buttonsFrame, "GuildThanks", "GUILD", "g", fontGuild, buttonCount)
  end

  -- PARTY
  local infoParty = ChatTypeInfo["PARTY"]
  local fontParty = CreateFont("fontParty")
  fontParty:SetTextColor(infoParty.r, infoParty.g, infoParty.b, 1)

  if MPGAAddon.db.profile.config.party.greeting then
    buttonCount = buttonCount + 1
    addButton(buttonsFrame, "PartyGreeting", "PARTY", "p", fontParty, buttonCount)
  end
  if MPGAAddon.db.profile.config.party.farewell then
    buttonCount = buttonCount + 1
    addButton(buttonsFrame, "PartyFarewell", "PARTY", "p", fontParty, buttonCount)
  end

  -- INSTANCE
  local infoInstance = ChatTypeInfo["INSTANCE_CHAT"]
  local fontInstance = CreateFont("fontInstance")
  fontInstance:SetTextColor(infoInstance.r, infoInstance.g, infoInstance.b, 1)

  if MPGAAddon.db.profile.config.instance.greeting then
    buttonCount = buttonCount + 1
    addButton(buttonsFrame, "InstanceGreeting", "INSTANCE_CHAT", "i", fontInstance, buttonCount)
  end
  if MPGAAddon.db.profile.config.instance.farewell then
    buttonCount = buttonCount + 1
    addButton(buttonsFrame, "InstanceFarewell", "INSTANCE_CHAT", "i", fontInstance, buttonCount)
  end
end


--------------------------------------------------
-- Interface Events & Functions
--------------------------------------------------
function MakePeopleGreetAgain_Button_OnEnter(self, motion)
  if self then
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:SetText(L[self:GetName().."_Tooltip"])
    GameTooltip:Show()
  end
end

function MakePeopleGreetAgain_Button_OnLeave(self, motion)
  GameTooltip:Hide()
end

function MakePeopleGreetAgain_ShowTooltip(self, title, description)
  if self then
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:SetText(title)
    GameTooltip:AddLine(description, 1, 1, 1, true)
    GameTooltip:Show()
  end
end

function MakePeopleGreetAgain_HideTooltip(self)
  GameTooltip:Hide()
end


--------------------------------------------------
-- Functions
--------------------------------------------------
function MPGAAddon:ToggleMainFrame()
  if MakePeopleGreetAgain:IsVisible() then
    HideUIPanel(MakePeopleGreetAgain)
  else
    ShowUIPanel(MakePeopleGreetAgain)
  end
end

function MPGAAddon:ShowOptionsFrame()
  -- double call to open the correct interface options panel
  InterfaceOptionsFrame_OpenToCategory(L["MPGA_Title"])
  InterfaceOptionsFrame_OpenToCategory(L["MPGA_Title"])
end

function MPGAAddon:ToggleMinimapButton()
  self.db.profile.minimapButton.hide = not self.db.profile.minimapButton.hide
  if self.db.profile.minimapButton.hide then
    MPGAMiniMapButton:Hide("MakePeopleGreetAgain")
  else
    MPGAMiniMapButton:Show("MakePeopleGreetAgain")
  end
end

function MPGAAddon:PrintColored(msg, color)
  MPGAAddon:Print("|cff" .. color .. msg .. "|r")
end

function MPGAAddon:OnOptionHide()
   if (self.needReload) then
     self.needReload = false
     StaticPopup_Show("MPGA_PerformReload")
   end
end

function MPGAAddon:DoReload()
  self.needReload = false
  StaticPopup_Show("MPGA_PerformReload")
end


--------------------------------------------------
-- Register Slash Commands
--------------------------------------------------
SLASH_RELOADUI1 = "/rl";
SlashCmdList.RELOADUI = ReloadUI;

function MPGAAddon:ChatCommands(msg)
	local msg, msgParam = strsplit(" ", msg, 2)

  MPGAAddon:ShowOptionsFrame()

  -- if msg == "toggle" then
  -- 		if msgParam then
  --       MPGAAddon:ToggleMainFrame()
  -- 		end
  -- elseif msg == "minimapbutton" then
  -- 		if msgParam then
  --       MPGAAddon:ToggleMinimapButton()
  -- 		end
	-- else
  --   showHelp()
	-- end
end


--------------------------------------------------
-- Main Events
--------------------------------------------------
function MakePeopleGreetAgain_OnLoad(self) -- 1
  self:RegisterForDrag("LeftButton");

  -- register first events
  self:RegisterEvent("ADDON_LOADED")

  --MPGAAddon:Print("OnLoad done.")
end

function MPGAAddon:OnInitialize() -- 2
  -- register database
  self.db = LibStub("AceDB-3.0"):New("MakePeopleGreetAgainDB", _defaultConfig, true) -- by default all chars use default profile
  self.needReload = false

  self.db.RegisterCallback(self, "OnProfileChanged", "DoReload");
  self.db.RegisterCallback(self, "OnProfileCopied", "DoReload");
  self.db.RegisterCallback(self, "OnProfileReset", "DoReload");

  -- setup options frame
  MPGAAddon_SetupOptionsUI();
  MPGAAddon:SecureHookScript(self.optionsFrame, "OnHide", "OnOptionHide")

  -- setup profile options
  profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
  LibStub("AceConfig-3.0"):RegisterOptionsTable("MPGAProfiles", profileOptions)
  profileSubMenu = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MPGAProfiles", "Profiles", L["MPGA_Title"])

  -- register minimap button
  MPGAMiniMapButton:Register("MakePeopleGreetAgain", mpgaLDB, self.db.profile.minimapButton)

  -- register slash commands
  MPGAAddon:RegisterChatCommand("mpga", "ChatCommands")
  MPGAAddon:RegisterChatCommand("makepeoplegreetagain", "ChatCommands")

  -- setup GUI popup dialogs
  MPGAAddon_SetupPopupDialogs()

  --MPGAAddon:Print("OnInitialize done.")
end

function MakePeopleGreetAgain_OnEvent(self, event, ...)
  if event == "ADDON_LOADED" and ... == "MakePeopleGreetAgain" then -- 3
    --MPGAAddon:Print("ADDON_LOADED done.")

    self:RegisterEvent("PLAYER_LOGIN")
    self:UnregisterEvent("ADDON_LOADED")
  elseif event == "PLAYER_LOGIN" then
    -- setup main frame
    MPGAAddon_ApplyLayout(MPGAAddon.db.profile.config.layout)
    MPGAAddon_SetupGUI()
  end
end
