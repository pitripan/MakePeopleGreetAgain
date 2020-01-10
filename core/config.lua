local L = LibStub("AceLocale-3.0"):GetLocale("MakePeopleGreetAgain")
--local mpgaLDB = LibStub("LibDataBroker-1.1"):GetDataObjectByName("MakePeopleGreetAgain")

local _DefaultLayout = "Default"
local _SingleRowLayout = "SingleRow"
local _SingleColumnLayout = "SingleColumn"
local _TwoColumnsLayout = "TwoColumns"


------------------------------------------
--https://authors.curseforge.com/forums/world-of-warcraft/tips-faqs-and-guides/215632-guide-using-uidropdownmenu-in-your-addon
--https://wow.gamepedia.com/Using_UIDropDownMenu
------------------------------------------


--------------------------------------------------
-- UI Widget Functions
--------------------------------------------------
local function createSlider(parent, name, label, description, minVal, maxVal, valStep, onValueChanged, onShow)
	local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
	local editbox = CreateFrame("EditBox", name.."EditBox", slider, "InputBoxTemplate")

	slider:SetMinMaxValues(minVal, maxVal)
	slider:SetValue(minVal)
	slider:SetValueStep(1)
	slider.text = _G[name.."Text"]
	slider.text:SetText(label)
	slider.textLow = _G[name.."Low"]
	slider.textHigh = _G[name.."High"]
	slider.textLow:SetText(floor(minVal))
	slider.textHigh:SetText(floor(maxVal))
	slider.textLow:SetTextColor(0.4,0.4,0.4)
	slider.textHigh:SetTextColor(0.4,0.4,0.4)
  slider.tooltipText = label
  slider.tooltipRequirement = description

	editbox:SetSize(50,30)
	editbox:SetNumeric(true)
	editbox:SetMultiLine(false)
	editbox:SetMaxLetters(5)
	editbox:ClearAllPoints()
	editbox:SetPoint("TOP", slider, "BOTTOM", 0, -5)
	editbox:SetNumber(slider:GetValue())
	editbox:SetCursorPosition(0);
	editbox:ClearFocus();
	editbox:SetAutoFocus(false)
  editbox.tooltipText = label
  editbox.tooltipRequirement = description

	slider:SetScript("OnValueChanged", function(self,value)
		self.editbox:SetNumber(floor(value))
		if(not self.editbox:HasFocus()) then
			self.editbox:SetCursorPosition(0);
			self.editbox:ClearFocus();
		end
    onValueChanged(self, value)
	end)

  slider:SetScript("OnShow", function(self,value)
    onShow(self, value)
  end)

	editbox:SetScript("OnTextChanged", function(self)
		local value = self:GetText()

		if tonumber(value) then
			if(floor(value) > maxVal) then
				self:SetNumber(maxVal)
			end

			if floor(self:GetParent():GetValue()) ~= floor(value) then
				self:GetParent():SetValue(floor(value))
			end
		end
	end)

	editbox:SetScript("OnEnterPressed", function(self)
		local value = self:GetText()
		if tonumber(value) then
			self:GetParent():SetValue(floor(value))
				self:ClearFocus()
		end
	end)

	slider.editbox = editbox
	return slider
end

local function createCheckbox(parent, name, label, description, hideLabel, onClick)
  local check = CreateFrame("CheckButton", name, parent, "InterfaceOptionsCheckButtonTemplate")
  check.label = _G[check:GetName() .. "Text"]
  if not hideLabel then
		check.label:SetText(label)
		check:SetFrameLevel(8)
	end
  check.tooltipText = label
  check.tooltipRequirement = description

  -- events
  check:SetScript("OnClick", function(self)
    local tick = self:GetChecked()
    onClick(self, tick and true or false)
  end)

  return check
end

local function createEditbox(parent, name, tooltipTitle, tooltipDescription, width, height, multiline, onTextChanged)
	local editbox	 = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
	editbox:SetSize(width, height)
	editbox:SetMultiLine(multiline)
	editbox:SetFrameLevel(9)
	editbox:ClearFocus()
	editbox:SetAutoFocus(false)
	editbox:SetScript("OnTextChanged", function(self)
		onTextChanged(self)
	end)
	editbox:SetScript("OnEnter", function(self, motion)
		MakePeopleGreetAgain_ShowTooltip(self, tooltipTitle, tooltipDescription)
	end)
	editbox:SetScript("OnLeave", function(self, motion)
		MakePeopleGreetAgain_HideTooltip(self)
	end)

  return editbox
end

local function createLabel(parent, name, text)
	local label = parent:CreateFontString(name, "ARTWORK", "GameFontNormal")
	label:SetText(text)
  return label
end

--------------------------------------------------
-- Genereal
--------------------------------------------------
function MPGAAddon_SetupOptionsUI()
  MPGAAddon.optionsFrame = CreateFrame("Frame", "MPGA_Options", InterfaceOptionsFramePanelContainer)
  MPGAAddon.optionsFrame.name = L["MPGA_Title"]
	MPGAAddon.optionsFrame:SetAllPoints()
	HideUIPanel(MPGAAddon.optionsFrame)

  local title = MPGAAddon.optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 10, -10)
	title:SetText(L["MPGA_Title"])

	-- layout
	do
		local layoutLabel = createLabel(MPGAAddon.optionsFrame, "layoutLabel", L["MPGA_SetLayout"])
		layoutLabel:SetPoint("TOPLEFT", title, 0, -30)

		MPGAAddon.layoutDropdown = CreateFrame("Frame", "MPGALayoutDropdown", MPGAAddon.optionsFrame, "UIDropDownMenuTemplate")
		MPGAAddon.layoutDropdown:SetPoint("TOPLEFT", layoutLabel, -16, -14)
		UIDropDownMenu_SetWidth(MPGAAddon.layoutDropdown, 150)
		UIDropDownMenu_Initialize(MPGAAddon.layoutDropdown, function(frame, level, menuList)
			local info = UIDropDownMenu_CreateInfo()
			info.func = MPGAAddon_SetLayout
			info.text, info.arg1 = L["MPGA_Layout_Default"], _DefaultLayout
			UIDropDownMenu_AddButton(info)
			info.text, info.arg1 = L["MPGA_Layout_SingleRow"], _SingleRowLayout
			UIDropDownMenu_AddButton(info)
			info.text, info.arg1 = L["MPGA_Layout_SingleColumn"], _SingleColumnLayout
			UIDropDownMenu_AddButton(info)
			info.text, info.arg1 = L["MPGA_Layout_TwoColumns"], _TwoColumnsLayout
			UIDropDownMenu_AddButton(info)
		end)
		UIDropDownMenu_SetText(MPGAAddon.layoutDropdown, L["MPGA_Layout_"..MPGAAddon.db.profile.config.layout])
	end

	-- Minimap Button
	do
		local minimapButtonCheckbox = createCheckbox(
	    MPGAAddon.optionsFrame,
	    "MPGA_MinimapButton_Checkbox",
	    L["MPGA_MinimapButton"],
	    L["MPGA_MinimapButton_Desc"],
			false,
	    function(self, value)
	      MPGAAddon:ToggleMinimapButton()
	    end
		)
		minimapButtonCheckbox:SetChecked(not MPGAAddon.db.profile.minimapButton.hide)
	  minimapButtonCheckbox:SetPoint("TOPLEFT", layoutLabel, 300, 0)
	end

	-- guild greeting
	do
		local guildGreetingLabel = createLabel(MPGAAddon.optionsFrame, "guildGreetingLabel", L["MPGA_GuildGreeting"])
		guildGreetingLabel:SetPoint("TOPLEFT", layoutLabel, 0, -70)

	  local guildGreetingCheckbox = createCheckbox(
	    MPGAAddon.optionsFrame,
	    "MPGA_GuildGreeting_Checkbox",
	    L["MPGA_GuildGreeting"],
	    L["MPGA_EnableButton_Desc"],
			true,
	    function(self, value)
	      MPGAAddon.db.profile.config.guild.greeting = value
	      MPGAAddon.needReload = true
	    end
		)
	  guildGreetingCheckbox:SetChecked(MPGAAddon.db.profile.config.guild.greeting)
	  guildGreetingCheckbox:SetPoint("TOPLEFT", guildGreetingLabel, 0, -14)

		local guildGreetingEditBox = createEditbox(
			MPGAAddon.optionsFrame,
			"MPGA_GuildGreeting_EditBox",
			L["MPGA_GuildGreeting"],
			L["MPGA_GuildGreeting_Desc"],
			240,
			30,
			false,
			function(self)
				MPGAAddon.db.profile.messages.guild.greeting = self:GetText()
			end
		)
		guildGreetingEditBox:SetText(MPGAAddon.db.profile.messages.guild.greeting)
		guildGreetingEditBox:SetPoint("TOPLEFT", guildGreetingCheckbox, 30, 3)
	end

	-- guild farewell
	do
		local guildFarewellLabel = createLabel(MPGAAddon.optionsFrame, "guildFarewellLabel", L["MPGA_GuildFarewell"])
		guildFarewellLabel:SetPoint("TOPLEFT", guildGreetingLabel, 300, 0)

		local guildFarewellCheckbox = createCheckbox(
			MPGAAddon.optionsFrame,
			"MPGA_GuildFarewell_Checkbox",
			L["MPGA_GuildFarewell"],
			L["MPGA_EnableButton_Desc"],
			true,
			function(self, value)
				MPGAAddon.db.profile.config.guild.farewell = value
				MPGAAddon.needReload = true
			end
		)
		guildFarewellCheckbox:SetChecked(MPGAAddon.db.profile.config.guild.farewell)
		guildFarewellCheckbox:SetPoint("TOPLEFT", guildFarewellLabel, 0, -14)

		local guildFarewellEditBox = createEditbox(
			MPGAAddon.optionsFrame,
			"MPGA_GuildFarewell_EditBox",
			L["MPGA_GuildFarewell"],
			L["MPGA_GuildFarewell_Desc"],
			240,
			30,
			false,
			function(self)
				MPGAAddon.db.profile.messages.guild.farewell = self:GetText()
			end
		)
		guildFarewellEditBox:SetText(MPGAAddon.db.profile.messages.guild.farewell)
		guildFarewellEditBox:SetPoint("TOPLEFT", guildFarewellCheckbox, 30, 3)
	end

	-- guild congratulations
	do
		local guildCongratulationsLabel = createLabel(MPGAAddon.optionsFrame, "guildCongratulationsLabel", L["MPGA_GuildCongratulations"])
		guildCongratulationsLabel:SetPoint("TOPLEFT", guildGreetingLabel, 0, -50)

	  local guildCongratulationsCheckbox = createCheckbox(
	    MPGAAddon.optionsFrame,
	    "MPGA_GuildCongratulations_Checkbox",
	    L["MPGA_GuildCongratulations"],
	    L["MPGA_EnableButton_Desc"],
			true,
	    function(self, value)
	      MPGAAddon.db.profile.config.guild.congratulations = value
	      MPGAAddon.needReload = true
	    end
		)
	  guildCongratulationsCheckbox:SetChecked(MPGAAddon.db.profile.config.guild.congratulations)
	  guildCongratulationsCheckbox:SetPoint("TOPLEFT", guildCongratulationsLabel, 0, -14)

		local guildCongratulationsEditBox = createEditbox(
			MPGAAddon.optionsFrame,
			"MPGA_GuildCongratulations_Editbox",
			L["MPGA_GuildCongratulations"],
			L["MPGA_GuildCongratulations_Desc"],
			240,
			30,
			false,
			function(self)
				MPGAAddon.db.profile.messages.guild.congratulations = self:GetText()
			end
		)
		guildCongratulationsEditBox:SetText(MPGAAddon.db.profile.messages.guild.congratulations)
		guildCongratulationsEditBox:SetPoint("TOPLEFT", guildCongratulationsCheckbox, 30, 3)
	end

	-- guild thanks
	do
		local guildThanksLabel = createLabel(MPGAAddon.optionsFrame, "guildThanksLabel", L["MPGA_GuildThanks"])
		guildThanksLabel:SetPoint("TOPLEFT", guildCongratulationsLabel, 300, 0)

		local guildThanksCheckbox = createCheckbox(
			MPGAAddon.optionsFrame,
			"MPGA_GuildThanks_Checkbox",
			L["MPGA_GuildThanks"],
			L["MPGA_EnableButton_Desc"],
			true,
			function(self, value)
				MPGAAddon.db.profile.config.guild.thanks = value
				MPGAAddon.needReload = true
			end
		)
		guildThanksCheckbox:SetChecked(MPGAAddon.db.profile.config.guild.thanks)
		guildThanksCheckbox:SetPoint("TOPLEFT", guildThanksLabel, 0, -14)

		local guildThanksEditBox = createEditbox(
			MPGAAddon.optionsFrame,
			"MPGA_GuildThanks_Editbox",
			L["MPGA_GuildThanks"],
			L["MPGA_GuildThanks_Desc"],
			240,
			30,
			false,
			function(self)
				MPGAAddon.db.profile.messages.guild.thanks = self:GetText()
			end
		)
		guildThanksEditBox:SetText(MPGAAddon.db.profile.messages.guild.thanks)
		guildThanksEditBox:SetPoint("TOPLEFT", guildThanksCheckbox, 30, 3)
	end


	-- party greeting
	do
		local partyGreetingLabel = createLabel(MPGAAddon.optionsFrame, "partyGreetingLabel", L["MPGA_PartyGreeting"])
		partyGreetingLabel:SetPoint("TOPLEFT", guildCongratulationsLabel, 0, -70)

	  local partyGreetingCheckbox = createCheckbox(
	    MPGAAddon.optionsFrame,
	    "MPGA_PartyGreeting_Checkbox",
	    L["MPGA_PartyGreeting"],
	    L["MPGA_EnableButton_Desc"],
			true,
	    function(self, value)
	      MPGAAddon.db.profile.config.party.greeting = value
	      MPGAAddon.needReload = true
	    end
		)
	  partyGreetingCheckbox:SetChecked(MPGAAddon.db.profile.config.party.greeting)
	  partyGreetingCheckbox:SetPoint("TOPLEFT", partyGreetingLabel, 0, -14)

		local partyGreetingEditBox = createEditbox(
			MPGAAddon.optionsFrame,
			"MPGA_PartyGreeting_EditBox",
			L["MPGA_PartyGreeting"],
			L["MPGA_PartyGreeting_Desc"],
			240,
			30,
			false,
			function(self)
				MPGAAddon.db.profile.messages.party.greeting = self:GetText()
			end
		)
		partyGreetingEditBox:SetText(MPGAAddon.db.profile.messages.party.greeting)
		partyGreetingEditBox:SetPoint("TOPLEFT", partyGreetingCheckbox, 30, 3)
	end

	-- party farewell
	do
		local partyFarewellLabel = createLabel(MPGAAddon.optionsFrame, "partyFarewellLabel", L["MPGA_PartyFarewell"])
		partyFarewellLabel:SetPoint("TOPLEFT", partyGreetingLabel, 300, 0)

		local partyFarewellCheckbox = createCheckbox(
			MPGAAddon.optionsFrame,
			"MPGA_PartyFarewell_Checkbox",
			L["MPGA_PartyFarewell"],
			L["MPGA_EnableButton_Desc"],
			true,
			function(self, value)
				MPGAAddon.db.profile.config.party.farewell = value
				MPGAAddon.needReload = true
			end
		)
		partyFarewellCheckbox:SetChecked(MPGAAddon.db.profile.config.party.farewell)
		partyFarewellCheckbox:SetPoint("TOPLEFT", partyFarewellLabel, 0, -14)

		local partyFarewellEditBox = createEditbox(
			MPGAAddon.optionsFrame,
			"MPGA_PartyFarewell_EditBox",
			L["MPGA_PartyFarewell"],
			L["MPGA_PartyFarewell_Desc"],
			240,
			30,
			false,
			function(self)
				MPGAAddon.db.profile.messages.party.farewell = self:GetText()
			end
		)
		partyFarewellEditBox:SetText(MPGAAddon.db.profile.messages.party.farewell)
		partyFarewellEditBox:SetPoint("TOPLEFT", partyFarewellCheckbox, 30, 3)
	end


	-- instance greeting
	do
		local instanceGreetingLabel = createLabel(MPGAAddon.optionsFrame, "instanceGreetingLabel", L["MPGA_InstanceGreeting"])
		instanceGreetingLabel:SetPoint("TOPLEFT", partyGreetingLabel, 0, -70)

	  local instanceGreetingCheckbox = createCheckbox(
	    MPGAAddon.optionsFrame,
	    "MPGA_InstanceGreeting_Checkbox",
	    L["MPGA_InstanceGreeting"],
	    L["MPGA_EnableButton_Desc"],
			true,
	    function(self, value)
	      MPGAAddon.db.profile.config.instance.greeting = value
	      MPGAAddon.needReload = true
	    end
		)
	  instanceGreetingCheckbox:SetChecked(MPGAAddon.db.profile.config.instance.greeting)
	  instanceGreetingCheckbox:SetPoint("TOPLEFT", instanceGreetingLabel, 0, -14)

		local instanceGreetingEditBox = createEditbox(
			MPGAAddon.optionsFrame,
			"MPGA_InstanceGreeting_EditBox",
			L["MPGA_InstanceGreeting"],
			L["MPGA_InstanceGreeting_Desc"],
			240,
			30,
			false,
			function(self)
				MPGAAddon.db.profile.messages.instance.greeting = self:GetText()
			end
		)
		instanceGreetingEditBox:SetText(MPGAAddon.db.profile.messages.instance.greeting)
		instanceGreetingEditBox:SetPoint("TOPLEFT", instanceGreetingCheckbox, 30, 3)
	end

	-- instance farewell
	do
		local instanceFarewellLabel = createLabel(MPGAAddon.optionsFrame, "instanceFarewellLabel", L["MPGA_InstanceFarewell"])
		instanceFarewellLabel:SetPoint("TOPLEFT", instanceGreetingLabel, 300, 0)

		local instanceFarewellCheckbox = createCheckbox(
			MPGAAddon.optionsFrame,
			"MPGA_InstanceFarewell_Checkbox",
			L["MPGA_InstanceFarewell"],
			L["MPGA_EnableButton_Desc"],
			true,
			function(self, value)
				MPGAAddon.db.profile.config.instance.farewell = value
				MPGAAddon.needReload = true
			end
		)
		instanceFarewellCheckbox:SetChecked(MPGAAddon.db.profile.config.instance.farewell)
		instanceFarewellCheckbox:SetPoint("TOPLEFT", instanceFarewellLabel, 0, -14)

		local instanceFarewellEditBox = createEditbox(
			MPGAAddon.optionsFrame,
			"MPGA_InstanceFarewell_EditBox",
			L["MPGA_InstanceFarewell"],
			L["MPGA_InstanceFarewell_Desc"],
			240,
			30,
			false,
			function(self)
				MPGAAddon.db.profile.messages.instance.farewell = self:GetText()
			end
		)
		instanceFarewellEditBox:SetText(MPGAAddon.db.profile.messages.instance.farewell)
		instanceFarewellEditBox:SetPoint("TOPLEFT", instanceFarewellCheckbox, 30, 3)
	end


	-- add to interface options
  InterfaceOptions_AddCategory(MPGAAddon.optionsFrame);
end

function MPGAAddon_SetLayout(newValue)
	MPGAAddon.db.profile.config.layout = newValue.arg1
	MPGAAddon.needReload = true
	UIDropDownMenu_SetText(MPGAAddon.layoutDropdown, newValue.value)
	CloseDropDownMenus()
end

function MPGAAddon_ApplyLayout(layout)
  if layout == _SingleRowLayout then
    -- set database values
    MPGAAddon.db.profile.config.layout = _SingleRowLayout
    MPGAAddon.db.profile.config.buttonsPerRow = 8
    -- change layout settings
    MakePeopleGreetAgain_Title:SetText(L["MPGA_Title"])
    MakePeopleGreetAgain:SetSize(416, 72)
  elseif layout == _SingleColumnLayout then
    -- set database values
    MPGAAddon.db.profile.config.layout = _SingleColumnLayout
    MPGAAddon.db.profile.config.buttonsPerRow = 1
    -- change layout settings
    MakePeopleGreetAgain_Title:SetText(L["MPGA_Title_Short"])
    MakePeopleGreetAgain:SetSize(80, 240)
  elseif layout == _TwoColumnsLayout then
    -- set database values
    MPGAAddon.db.profile.config.layout = _TwoColumnsLayout
    MPGAAddon.db.profile.config.buttonsPerRow = 2
    -- change layout settings
    MakePeopleGreetAgain_Title:SetText(L["MPGA_Title_Short"])
    MakePeopleGreetAgain:SetSize(128, 144)
  else -- DEFAULT
    -- set database values
    MPGAAddon.db.profile.config.layout = _DefaultLayout
    MPGAAddon.db.profile.config.buttonsPerRow = 4
    -- change layout settings
    MakePeopleGreetAgain_Title:SetText(L["MPGA_Title"])
    MakePeopleGreetAgain:SetSize(224, 96)
  end
end
