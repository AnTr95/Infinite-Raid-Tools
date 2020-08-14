local f = CreateFrame("Frame");
local flasks = {307185,307187};
local RED = "\124cFFFF0000";
local YELLOW = "\124cFFFFFF00";
local GREEN = "\124cFF00FF00";
local raiders = {};
local buffSpellIDs = {
	["MAGE"] = 1459, 
	["PRIEST"] = 21562, 
	["WARRIOR"] = 6673,
};
local buffIconIDs = {
	["MAGE"] = 135932, 
	["PRIEST"] = 135987, 
	["WARRIOR"] = 132333,
};

f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("READY_CHECK");
f:RegisterEvent("UNIT_AURA");

local function updateConsumables()
	local flask, flaskIcon, _, _, _, flaskTime = EnRT_UnitBuff("player", GetSpellInfo(307185));
	for i = 1, #flasks do
		flask, flaskIcon, _, _, _, flaskTime = EnRT_UnitBuff("player", GetSpellInfo(flasks[i]));
		if (flask) then
			break;
		end
	end
	local food, foodIcon, _, _, _, foodTime = EnRT_UnitBuff("player", GetSpellInfo(297039)); -- Random Well Fed Buff
	local rune, runeIcon, _, _, _, runeTime = EnRT_UnitBuff("player", GetSpellInfo(270058));
	flaskIcon = flaskIcon and flaskIcon or 2057568;
	foodIcon = foodIcon and foodIcon or 136000;
	runeIcon = runeIcon and runeIcon or 519379;

	local blizzText = ReadyCheckFrameText:GetText();
	if (blizzText:find("%-")) then
		local head, tail, name = blizzText:find("([^-]*)");
		blizzText = name .. " initiated a ready check";
	else
		local head, tail, name = blizzText:find("([^%s]*)");
		blizzText = name .. " initiated a ready check";
	end
	local currTime = GetTime();
	flaskTime = flaskTime and math.floor((tonumber(flaskTime)-currTime)/60) or nil;
	if (flaskTime) then
		if (flaskTime > 15) then
			flaskTime = GREEN .. flaskTime .. " min ";
		elseif (flaskTime <= 15 and flaskTime > 8) then
			flaskTime = YELLOW .. flaskTime .. " min ";
		elseif (flaskTime <= 8) then
			flaskTime = RED .. flaskTime .. " min ";
		end
	else
		flaskTime = RED .. "Missing ";
	end
	local class = select(2, UnitClass("player"));
	if (class == "MAGE" or class == "PRIEST" or class == "WARRIOR") then
		ReadyCheckFrameText:SetSize(280, 40);
		local count = 0;
		local total = 0;
		local unit = nil;
		if (IsInRaid()) then
			for i = 1, GetNumGroupMembers() do
				unit = "raid"..i;
				if (UnitIsVisible(unit)) then
					total = total + 1;
					if (EnRT_UnitBuff(unit, GetSpellInfo(buffSpellIDs[class]))) then
						count = count + 1;
					end
				end
			end
		elseif (IsInGroup()) then
			for i = 1, GetNumGroupMembers()-1 do
				unit = "party"..i;
				if (UnitIsVisible(unit)) then
					total = total + 1;
					if (EnRT_UnitBuff(unit, GetSpellInfo(buffSpellIDs[class]))) then
						count = count + 1;
					end
				end
			end
			total = total + 1;
			if (EnRT_UnitBuff("player", GetSpellInfo(buffSpellIDs[class]))) then
				count = count + 1;
			end
		end
		ReadyCheckFrameText:SetText(blizzText .. "\n\n\124T"..flaskIcon .. ":16\124t" .. flaskTime .. "\124T" .. foodIcon .. ":16\124t" .. (food and (GREEN .. "Check ") or (RED .. "Missing ")) .. "\124T" .. runeIcon .. ":16\124t" .. (rune and (GREEN .. "Check ") or (RED .."Missing ")) .. "\124T" .. buffIconIDs[class] .. ":16\124t" .. (count == total and (GREEN .. count .. "/" ..total) or (RED .. count .. "/" .. total)));
	else
		ReadyCheckFrameText:SetText(blizzText .. "\n\n\124T"..flaskIcon .. ":16\124t " .. flaskTime .. "\124T" .. foodIcon .. ":16\124t " .. (food and (GREEN .. "Check ") or (RED .. "Missing ")) .. "\124T" .. runeIcon .. ":16\124t " .. (rune and (GREEN .. "Check ") or (RED .."Missing "))); 
	end
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (EnRT_ConsumableCheckEnabled == nil) then EnRT_ConsumableCheckEnabled = true; end
	elseif (event == "READY_CHECK" and EnRT_ConsumableCheckEnabled) then
		local sender = ...
		if (not UnitIsUnit(sender, UnitName("player")) and EnRT_ConsumableCheckEnabled) then
			updateConsumables();
		end
	elseif (event == "UNIT_AURA" and EnRT_ConsumableCheckEnabled and ReadyCheckFrame:IsShown()) then
		local unit = ...;
		if (UnitInRaid(unit) or UnitInParty(unit)) then
			updateConsumables();
		end
	end
end);