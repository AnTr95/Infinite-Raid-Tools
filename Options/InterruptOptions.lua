local raidDatabase = {
	["Uldir"] = {
		["Taloc"] = 2144,
		["Mother"] = 2141,
		["Fetid Devourer"] = 2128,
		["Zek'voz"] = 2136,
		["Vectis"] = 2134,
		["Zul"] = 2145,
		["Mythrax"] = 2135,
		["G'huun"] = 2122,
		["No boss"] = 1,
	},
	["Battle of Dazar'alor"] = {
		["Champion Of Light"] = 0,
		["Grong, The Jungle Lord"] = 0,
		["Jadefire Masters"] = 0,
		["Opulence"] = 0,
		["Conclave of the Chosen"] = 0,
		["King Rastakhan"] = 0,
		["High Tinker Mekkatorque"] = 0,
		["Stormwall Blockade"] = 0,
		["Lady Jaina Proudmore"] = 0,
		["No boss"] = 1,
	},
};   
local GUI = nil;
local L = EnRTLocals;

EnRT_InterruptOptions = CreateFrame("Frame", "EnRT_InterruptOptionsFrame", InterfaceOptionsFramePanelContainer);
EnRT_InterruptOptions.name = "Interrupt Module";
EnRT_InterruptOptions.parent = "|cFFFFFF00General Modules";
EnRT_InterruptOptions:Hide();

local title = EnRT_InterruptOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
title:SetPoint("TOP", 0, -16);
title:SetText(L.OPTIONS_TITLE);
	
local tabinfo = EnRT_InterruptOptions:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
tabinfo:SetPoint("TOPLEFT", 16, -16);
tabinfo:SetText(L.OPTIONS_INTERRUPT_TITLE);

local author = EnRT_InterruptOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal");
author:SetPoint("TOPLEFT", 450, -20);
author:SetText(L.OPTIONS_AUTHOR);

local version = EnRT_InterruptOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
version:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -10)
version:SetText(L.OPTIONS_VERSION)

local info = EnRT_InterruptOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
info:SetPoint("TOPLEFT", 220, -10)
info:SetSize(350, 200)
info:SetText(L.OPTIONS_INTERRUPT_INFO)
info:SetWordWrap(true)

local enabledButton = CreateFrame("CheckButton", "EnRT_InterruptEnabledCheckButton", EnRT_InterruptOptions, "UICheckButtonTemplate")
enabledButton:SetSize(26, 26)
enabledButton:SetPoint("TOPLEFT", 30, -90)
enabledButton:HookScript("OnClick", function(self)
	if self:GetChecked() then
		EnRT_InterruptEnabled = true
		PlaySound(856)
	else
		EnRT_InterruptEnabled = false
		PlaySound(857)
	end
end)

local enabledText = EnRT_InterruptOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
enabledText:SetPoint("TOPLEFT", enabledButton, "TOPLEFT", 30, -7)
enabledText:SetText(L.OPTIONS_ENABLED)

local orderText = EnRT_InterruptOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
orderText:SetPoint("TOPLEFT", 30, -180)
orderText:SetText(L.OPTIONS_INTERRUPT_ORDER)

local function createRow()
	local row = #GUI+1;
	GUI[row] = {};
	local orderEdit = CreateFrame("EditBox", nil, EnRT_InterruptOptions, "InputBoxTemplate");
	orderEdit:SetPoint("TOPLEFT", orderText, "TOPLEFT", 0, -2-((row-1)*40));
	orderEdit:SetAutoFocus(false);
	orderEdit:SetSize(250, 45);
	orderEdit:SetText("");
	orderEdit:SetScript("OnEscapePressed", function(self)
		self:SetText("");
		self:ClearFocus();
	end)
	orderEdit:SetScript("OnEnterPressed", function(self)
		local input = self:GetText();
		input = input:gsub("^%l", string.upper);
		EnRT_NextInterrupt[row].NextInterrupter = input;
		GUI[row].orderEdit:SetText(input);
		self:ClearFocus();
	end)
	orderEdit:SetScript("OnTextChanged", function(self)
		local input = self:GetText();
		input = input:gsub("^%l", string.upper);
		EnRT_NextInterrupt[row].NextInterrupter = input;
	end)
	GUI[row].orderEdit = orderEdit;

	local dropDown = CreateFrame("FRAME", "EnRT_Interrupt_Dropdown" .. row, EnRT_InterruptOptions, "UIDropDownMenuTemplate");
	dropDown:SetPoint("TOPLEFT", orderText, "TOPLEFT", 270, -12-((row-1)*40));

	local function dropDown_OnClick (self, bossName, bossID, checked)
		EnRT_NextInterrupt[row].bossID = bossID;
		UIDropDownMenu_SetText(dropDown, "Boss: " .. bossName);
		--UIDROPDOWNMENU_OPEN_MENU can be used as a generic frame when we do not have direct access to it
		CloseDropDownMenus();
	end

	local function Initalize_dropDown(self, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
		if (level == 1) then
		  -- Display the groups
			for raidName, bossData in pairs(raidDatabase) do
				info.text = raidName;
				info.checked = false;
				info.menuList = raidName;
				info.hasArrow = true;
				UIDropDownMenu_AddButton(info);
			end
		elseif (menuList) then
			-- Display a nested group .
			info.func = dropDown_OnClick;
			local bossData = raidDatabase[menuList];
			for bossName, bossID in pairs(bossData) do
				info.text = bossName;
				info.arg1 = bossName;
				info.arg2 = bossID;
				info.checked = bossID == EnRT_NextInterrupt[row].bossID;
				UIDropDownMenu_AddButton(info, level);
			end
		end
	end

	UIDropDownMenu_SetWidth(dropDown, 200);
	UIDropDownMenu_Initialize(dropDown, Initalize_dropDown);
	UIDropDownMenu_SetText(dropDown, "Boss: No boss");
	GUI[row].dropDown = dropDown;
end

local showButtonRemove = CreateFrame("Button", "EnRT_RemoveButton", EnRT_InterruptOptions, "UIPanelButtonTemplate");
showButtonRemove:SetText("-");
showButtonRemove:SetSize(30, 25);
showButtonRemove:SetPoint("TOPLEFT", orderText, "TOPLEFT", 200, -2);
showButtonRemove:HookScript("OnClick", function(self)
	if #EnRT_NextInterrupt > 1 then
		GUI[#EnRT_NextInterrupt].dropDown:Hide();
		GUI[#EnRT_NextInterrupt].orderEdit:Hide(); 
		GUI[#EnRT_NextInterrupt] = nil;  
		EnRT_NextInterrupt[#EnRT_NextInterrupt] = nil;
	end
	showButtonRemove:SetPoint("TOPLEFT", orderText, "TOPLEFT", 200, -2-(#EnRT_NextInterrupt*40));
	EnRT_AddButton:SetPoint("TOPLEFT", orderText, "TOPLEFT", 100, -2-(#EnRT_NextInterrupt*40));
end)

local showButtonAdd = CreateFrame("Button", "EnRT_AddButton", EnRT_InterruptOptions, "UIPanelButtonTemplate")
showButtonAdd:SetText("+");
showButtonAdd:SetSize(30, 25);
showButtonAdd:SetPoint("TOPLEFT", orderText, "TOPLEFT", 100, -2);
showButtonAdd:HookScript("OnClick", function(self)
	if #EnRT_NextInterrupt < 9 then
		EnRT_NextInterrupt[#EnRT_NextInterrupt+1] = {bossID=1};
		createRow();
		showButtonAdd:SetPoint("TOPLEFT", orderText, "TOPLEFT", 100, -2-(#EnRT_NextInterrupt*40));
		showButtonRemove:SetPoint("TOPLEFT", orderText, "TOPLEFT", 200, -2-(#EnRT_NextInterrupt*40));
	end
end);

EnRT_InterruptOptions:SetScript("OnShow", function(self)
	if (GUI == nil) then
		GUI = {};
		for i=1, #EnRT_NextInterrupt do
			createRow();
		end
	end
	for i = 1, #EnRT_NextInterrupt do
		for raidName, bossData in pairs(raidDatabase) do
			for bossName, bossID in pairs(bossData) do
				if (EnRT_NextInterrupt[i].bossID == bossID and GUI[i].orderEdit and EnRT_NextInterrupt[i].NextInterrupter) then
					GUI[i].orderEdit:SetText(EnRT_NextInterrupt[i].NextInterrupter);
					UIDropDownMenu_SetText(GUI[i].dropDown, "Boss: " .. bossName);
				end
			end
		end
	end
	showButtonAdd:SetPoint("TOPLEFT", orderText, "TOPLEFT", 100, -2-(#EnRT_NextInterrupt*40));
	showButtonRemove:SetPoint("TOPLEFT", orderText, "TOPLEFT", 200, -2-(#EnRT_NextInterrupt*40));
	enabledButton:SetChecked(EnRT_InterruptEnabled);
end)



InterfaceOptions_AddCategory(EnRT_InterruptOptions)