local strlow = string.lower;

BRH.cdTracker = {}
local tracker = BRH.cdTracker
local util = BRH.util

function BRH.trackSpell(class, icon, name)

	class = strlow(class)
	if (BRH_spellsToTrack[class] == nil) then
		BRH_spellsToTrack[class] = {}
	end

	name = strlow(name);
	if (BRH_spellsToTrack[class][name] == nil) then
		BRH_spellsToTrack[class][name] = {
			["icon"] = icon,
			["tracked"] = true, -- If the player using the addon track it ?
			["onCD"] = {}, -- players in cd fromated [playerName] = time when it's up or false.
			["CD"] = 0
		}
	end

	BRH_spellsToTrack[class][name].tracked = true;

	BRH.buildTrackedSpellsGUI()
end

function BRH.unTrackSpell(class, icon, name)
	class = strlow(class)
	if (BRH_spellsToTrack[class] == nil) then
		BRH_spellsToTrack[class] = {}
	end

	icon = strlow(icon);
	if (BRH_spellsToTrack[class][icon] == nil) then
		BRH_spellsToTrack[class][icon] = {
			["tracked"] = true, -- If the player using the addon track it ?
			["onCD"] = {}, -- players in cd fromated [playerName] = time when it's up or false.
		}
	end
	BRH_spellsToTrack[class][icon].tracked = false;

	BRH.buildTrackedSpellsGUI()
end


BRH_CDTracker = {}
BRH_CDTracker.main = CreateFrame("Frame", "BRH_CDTracker_main")
--BRH_CDTracker.main:ClearAllPoints();
BRH_CDTracker.main:SetPoint("CENTER", "UIParent", "CENTER")
BRH_CDTracker.main:SetWidth(55)
BRH_CDTracker.main:SetHeight(5)
BRH_CDTracker.main:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 5});
BRH_CDTracker.main:SetBackdropColor(0,0,0,0.5);
BRH_CDTracker.main:RegisterEvent("RAID_ROSTER_UPDATE")
BRH_CDTracker.main:RegisterEvent("ADDON_LOADED")
BRH_CDTracker.main:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS");
BRH_CDTracker.main:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE");
BRH_CDTracker.main:SetMovable(true);
BRH_CDTracker.main:EnableMouse(true);
BRH_CDTracker.main:RegisterForDrag("LeftButton");
BRH_CDTracker.main:SetScript("OnDragStart", function() this:StartMoving() end);
BRH_CDTracker.main:SetScript("OnDragStop", function() this:StopMovingOrSizing() end);
function BRH.buildTrackedSpellsGUI()
	local precedentFrame = nil;
	for class, spells in pairs(BRH_spellsToTrack) do
		for spell, datas in pairs(spells) do
			if datas.tracked then
				if (BRH_CDTracker[spell] ~= nil) then
					BRH_CDTracker[spell]:Hide()
					BRH_CDTracker[spell] = nil;
				end
				BRH_CDTracker[spell] = CreateFrame("Frame", "BRH_CDTracker_"..spell, BRH_CDTracker.main);
				if (precedentFrame == nil) then
					BRH_CDTracker[spell]:SetPoint("BOTTOMLEFT", "BRH_CDTracker_main", "BOTTOMLEFT", 2, 2)
				else 
					BRH_CDTracker[spell]:SetPoint("BOTTOMLEFT", precedentFrame, "TOPLEFT")
				end
				precedentFrame = "BRH_CDTracker_"..spell;
				BRH_CDTracker[spell]:SetWidth(50)
				BRH_CDTracker[spell]:SetHeight(20)
				BRH_CDTracker.main:SetHeight(BRH_CDTracker.main:GetHeight() + 20)
				BRH_CDTracker[spell]:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 5});
				BRH_CDTracker[spell]:SetBackdropColor(0,0,0,0.5);
				BRH_CDTracker[spell]:EnableMouse();
				BRH_CDTracker[spell].icon = CreateFrame("Frame", "BRH_CDTracker_"..spell.."icon", BRH_CDTracker[spell]);
				BRH_CDTracker[spell].icon:SetPoint("LEFT", "BRH_CDTracker_"..spell, "LEFT")
				BRH_CDTracker[spell].icon:SetWidth(20)
				BRH_CDTracker[spell].icon:SetHeight(20)
				BRH_CDTracker[spell].icontex = BRH_CDTracker[spell]:CreateTexture("BRH_CDTracker_"..spell.."_icon_texture", "OVERLAY")
				BRH_CDTracker[spell].icontex:SetAllPoints(BRH_CDTracker[spell].icon );
				BRH_CDTracker[spell].icontex:SetTexture(datas.icon)
				BRH_CDTracker[spell].icontex:SetTexCoord(0.1,0.9,0.1,0.9)
				BRH_CDTracker[spell].textZone = CreateFrame("Frame", "BRH_CDTracker_"..spell.."textZone", BRH_CDTracker[spell]);
				BRH_CDTracker[spell].textZone:SetPoint("RIGHT", "BRH_CDTracker_"..spell, "RIGHT", -2, 0)
				BRH_CDTracker[spell].textZone:SetWidth(30)
				BRH_CDTracker[spell].textZone:SetHeight(20)
				BRH_CDTracker[spell].text = BRH_CDTracker[spell]:CreateFontString("BRH_CDTracker_"..spell.."count", "ARTWORK", "GameFontWhite")
				BRH_CDTracker[spell].text:SetAllPoints("BRH_CDTracker_"..spell.."textZone");
				BRH_CDTracker[spell].text:SetText("/");
				BRH_CDTracker[spell].text:SetFont("Fonts\\FRIZQT__.TTF", 8)
				BRH_CDTracker[spell].text:SetTextColor(1, 1, 1, 1);
				BRH_CDTracker[spell].playersFrame = CreateFrame("Frame", "BRH_CDTracker_"..spell.."_PlayerFrame", BRH_CDTracker[spell]);
				BRH_CDTracker[spell].playersFrame:SetPoint("TOPLEFT", "BRH_CDTracker_"..spell, "TOPRIGHT", 5, 0);
				BRH_CDTracker[spell].playersFrame:SetWidth(80) 
				BRH_CDTracker[spell].playersFrame:SetHeight(10)
				BRH_CDTracker[spell].playersFrame:Hide();
				BRH_CDTracker[spell].playersFrames = {}
				BRH_CDTracker[spell]:SetScript("OnEnter", function() this.playersFrame:Show() end)
				BRH_CDTracker[spell]:SetScript("OnLeave", function() this.playersFrame:Hide() end)
			else
				if (BRH_CDTracker[spell] ~= nil) then
					BRH_CDTracker[spell]:Hide();
				end
			end
		end
	end
	BRH.updateGUI();
end

function BRH.getTrackedSpellsInRaid()
	-- not in raid, nothing to do here
	if (not UnitInRaid("Player")) then
		return
	end
	util.addonCom("getTrackedSpells", "")
end

function BRH.updateGUI()

	if (BRH_CDTrackerConfig) then
		if (BRH_CDTrackerConfig.show and UnitInRaid("Player")) then
			BRH_CDTracker.main:Show()
		else
			BRH_CDTracker.main:Hide()
		end
	end

	local currRoster = {};

	for raidIndex=1, MAX_RAID_MEMBERS do
		local name = GetRaidRosterInfo(raidIndex);
		if (name ~= nil) then
			currRoster[name] = true;
		end
	end


	for class, spells in pairs(BRH_spellsToTrack) do
		for spell, datas in pairs(spells) do
			if datas.tracked then
				local up, max = 0, 0;
				for player, cd in pairs(datas.onCD) do
					if (currRoster[player] ~= nil) then
						if (BRH_CDTracker[spell].playersFrames[player] == nil) then
							BRH_CDTracker[spell].playersFrames[player] = {}; 
							BRH_CDTracker[spell].playersFrames[player].textZone = CreateFrame("Frame", "BRH_CDTracker_"..spell.."_playersFrames_"..player.."_textZone", BRH_CDTracker[spell].playersFrame);
							BRH_CDTracker[spell].playersFrames[player].textZone:SetPoint("TOPLEFT", "BRH_CDTracker_"..spell.."_PlayerFrame", "TOPLEFT", 0, -(10*max))
							BRH_CDTracker[spell].playersFrames[player].textZone:SetWidth(80)
							BRH_CDTracker[spell].playersFrames[player].textZone:SetHeight(10)
							BRH_CDTracker[spell].playersFrames[player].textZone:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 5});
							BRH_CDTracker[spell].playersFrames[player].textZone:SetBackdropColor(0,0,0,1);
							BRH_CDTracker[spell].playersFrames[player].playerName = BRH_CDTracker[spell].playersFrames[player].textZone:CreateFontString("BRH_CDTracker_"..spell.."_playersFrames_"..player.."_Name", "ARTWORK", "GameFontWhite")
							BRH_CDTracker[spell].playersFrames[player].playerName:SetPoint("LEFT", "BRH_CDTracker_"..spell.."_playersFrames_"..player.."_textZone", "LEFT", 2, 0);
							BRH_CDTracker[spell].playersFrames[player].playerName:SetText(player);
							BRH_CDTracker[spell].playersFrames[player].playerName:SetFont("Fonts\\FRIZQT__.TTF", 6)
							BRH_CDTracker[spell].playersFrames[player].playerName:SetTextColor(1, 1, 1, 1);
							BRH_CDTracker[spell].playersFrames[player].cdBG = CreateFrame("Frame", "BRH_CDTracker_"..spell.."_playersFrames_"..player.."_cdBG", BRH_CDTracker[spell].playersFrame);
							BRH_CDTracker[spell].playersFrames[player].cdBG:SetPoint("TOPLEFT", "BRH_CDTracker_"..spell.."_PlayerFrame", "TOPLEFT", 		15, -(10*max))
							BRH_CDTracker[spell].playersFrames[player].cdBG:SetHeight(10)
							BRH_CDTracker[spell].playersFrames[player].cdBG:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 5});
							BRH_CDTracker[spell].playersFrames[player].cdBG:SetBackdropColor(255,255,0,1);
							BRH_CDTracker[spell].playersFrames[player].cd = BRH_CDTracker[spell].playersFrames[player].textZone:CreateFontString("BRH_CDTracker_"..spell.."_playersFrames_"..player.."_cd", "ARTWORK", "GameFontWhite")
							BRH_CDTracker[spell].playersFrames[player].cd:SetPoint("RIGHT", "BRH_CDTracker_"..spell.."_playersFrames_"..player.."_textZone", "RIGHT", -2, 0);
							BRH_CDTracker[spell].playersFrames[player].cd:SetText("Up !");
							BRH_CDTracker[spell].playersFrames[player].cd:SetFont("Fonts\\FRIZQT__.TTF", 6)
							BRH_CDTracker[spell].playersFrames[player].cd:SetTextColor(1, 1, 1, 1);
						end
						if (not cd) then 
							BRH_CDTracker[spell].playersFrames[player].cdBG:SetWidth(0)
							up = up+1 
						elseif (cd ~= "-1" and cd <= GetTime()) then 
							BRH_spellsToTrack[class][spell].onCD[player] = false;
							BRH_CDTracker[spell].playersFrames[player].cd:SetText("Up !");
							BRH_CDTracker[spell].playersFrames[player].cdBG:SetWidth(0)
							up = up+1 
						else
							local timer = cd-GetTime()
							BRH_CDTracker[spell].playersFrames[player].cd:SetText(util.STC_MIN(timer));
							local scale = 65 * (1-(timer/datas.CD));
							BRH_CDTracker[spell].playersFrames[player].cdBG:SetWidth(scale)
						end
						max = max +1
					else
						if (BRH_CDTracker[spell].playersFrames[player] ~= nil) then
							BRH_CDTracker[spell].playersFrames[player] = nil
						end
					end
				end
				if (BRH_CDTracker[spell] ~= nil and BRH_CDTracker[spell].text ~= nil ) then 
					BRH_CDTracker[spell].text:SetText(up.."/"..max);
				end
			end
		end
	end
end
--[[
function BRH.getMyTrackedSpells()
	local playerName = UnitName("player")

	-- check action bars
	for actionindex = 1, 120 do
		-- avoid macros
		if (GetActionText(actionindex) == nil and GetActionTexture(actionindex) ~= nil and IsConsumableAction(actionindex)) then 
			-- Check for CD
			local _, cd = GetActionCooldown(actionindex)
			local icon = strlow(GetActionTexture(actionindex));

			if (cd and cd > 0) then
				BRH.setTrackedSpellOnCD("all", playerName, icon, cd);
				spellOnCDCheck.item[icon] = false;
			else
				BRH.setTrackedSpellUp("all", playerName, icon);
			end
		end
	end

	-- bag items 
	for bag=0,4 do
		for slot=1,GetContainerNumSlots(bag) do
			if (GetContainerItemLink(bag,slot)) then
				local _, cd = GetContainerItemCooldown(bag, slot)
				local icon = GetContainerItemInfo(bag, slot);
				
				if (cd and cd > 0) then
					BRH.setTrackedSpellOnCD("all", playerName, icon, cd);
					spellOnCDCheck.item[icon] = false;
				else
					BRH.setTrackedSpellUp("all", playerName, icon);
				end
			end
		end
	end

	-- Inventory Items
	for slotId = 0, 19 do
		local icon = GetInventoryItemTexture("Player", slotId)
		if (icon) then
			local _, cd = GetInventoryItemCooldown("Player", slotId)
			if (cd and cd > 0) then
				BRH.setTrackedSpellOnCD("all", playerName, icon, cd);
				spellOnCDCheck.item[icon] = false;
			else
				BRH.setTrackedSpellUp("all", playerName, icon);
			end
		end
	end

	-- check spells
	local _, myclass = UnitClass("player")
	myclass = strlow(myclass);

	-- getting total number of spells
	local numspells = 0;
	for i = 1, GetNumSpellTabs() do
		_, _, _, temp = GetSpellTabInfo(i)
		numspells = numspells + temp
	end
	
	for i = 1, numspells do
		local icon = strlow(GetSpellTexture(i, BOOKTYPE_SPELL))
		local cd = util.getSpellCDByIcon(icon)

		if (cd and cd > 0) then
			BRH.setTrackedSpellOnCD(myclass, playerName, icon, cd);
			spellOnCDCheck.spell[icon] = false;
		else
			BRH.setTrackedSpellUp(myclass, playerName, icon);
		end
	end
end

function BRH.setTrackedSpellOnCD(class, sender, spell, duration)
	spell = strlow(spell);

	local sentBySelf = strlow(UnitName("Player")) == strlow(sender);
	local type = "spell";
	if (class == "all") then
		type = "item"
	end

	if (BRH_spellsToTrack[class] ~= nil and BRH_spellsToTrack[class][spell] ~= nil) then
		if duration == "-1" then
			BRH_spellsToTrack[class][spell]["onCD"][sender] = duration;
		elseif (BRH_spellsToTrack[class][spell]["onCD"][sender] == "-1") then
			BRH_spellsToTrack[class][spell]["onCD"][sender] = GetTime() + duration;
		end
	end

	if BRH_SpellCastCount[sender] == nil then
		BRH_SpellCastCount[sender] = {}
	end

	if (BRH_SpellCastCount[sender][spell] == nil) then
		BRH_SpellCastCount[sender][spell] = 1
	else
		BRH_SpellCastCount[sender][spell] = BRH_SpellCastCount[sender][spell] + 1
	end
	
	if (sentBySelf and duration == "-1" and not spellOnCDCheck[type][spell]) then
		spellOnCDCheck[type][spell] = true;
		BRH_CDTracker.nextTick = GetTime() + BRH_CDTracker.tickRate;
		util.addonCom("trackedSpellUsed", class..":"..spell..":"..duration)
	elseif (sentBySelf and spellOnCDCheck[type][spell] and duration ~= "-1") then
		spellOnCDCheck[type][spell] = false;
		util.addonCom("trackedSpellUsed", class..":"..spell..":"..duration)
	end

end

function BRH.setTrackedSpellUp(class, sender, spell)
	spell = strlow(spell);

	if (strlow(UnitName("Player")) == strlow(sender)) then
		util.addonCom("trackedSpellUp", class..":"..spell);
	end

	if (BRH_spellsToTrack[class] == nil) then
		return
	end

	if (BRH_spellsToTrack[class][spell] == nil) then
		if (BRH_spellsToTrack["all"][spell] ~= nil) then
			BRH_spellsToTrack["all"][spell]["onCD"][sender] = false;
		end
		return
	end

	BRH_spellsToTrack[class][spell]["onCD"][sender] = false;
end

local function handleTrackedSpellUsed(sender, datas)
	-- we don't wanna get our own updates as we already handled them
	if (strlow(sender) == UnitName("Player")) then
		return
	end

	local split = util.strsplit(":", datas)
	local senderClass = split[1];
	local spell = split[2];
	local duration = split[3];
	BRH.setTrackedSpellOnCD(senderClass, sender, spell, duration);
end

local function handleTrackedSpellUp(sender, datas)
	-- we don't wanna get our own updates as we already handled them
	if (strlow(sender) == UnitName("Player")) then
		return
	end

	local split = util.strsplit(":", datas)
	local senderClass = split[1];
	local spell = split[2];

	BRH.setTrackedSpellUp(senderClass, sender, spell);
end
]]
function BRH.updateSpellsOnCD()

	for spell, doCheck in pairs(spellOnCDCheck.spell) do
		local playerName = UnitName("player")
		local _, myclass = UnitClass("player")
		myclass = strlow(myclass);
		local cd = util.getSpellCDByIcon(spell)

		if (cd and cd > 0) then
			BRH.setTrackedSpellOnCD(myclass, playerName, spell, cd);
		else
			BRH.setTrackedSpellUp(myclass, playerName, spell);
		end
	end

	for spell, doCheck in pairs(spellOnCDCheck.item) do
		for actionindex = 1, 120 do
			-- avoid macros and check if it's our item
			if (GetActionText(actionindex) == nil and GetActionTexture(actionindex) and IsConsumableAction(actionindex) and strlow(GetActionTexture(actionindex)) == spell) then 
				_, cd = GetActionCooldown(actionindex)

				if (cd and cd > 0) then
					BRH.setTrackedSpellOnCD("all", playerName, spell, cd);
				else
					BRH.setTrackedSpellUp("all", playerName, spell);
				end
			end
		end
	end

end
--[[
This code hooks UseAction
]]
--[[
savedUseAction = UseAction

newUseAction = function(actionindex, x, y)
	-- macro, we don't track it here
	if (GetActionText(actionindex) ~= nil) then 
		savedUseAction(actionindex, x, y)   
		return;
	end

	-- first we check for cost
	local isUsable, notEnoughMana = IsUsableAction(actionindex)
	if (not isUsable or notEnoughMana) then
		-- action is not usable for x reason or player doesn't have enough mana so stop here
		savedUseAction(actionindex, x, y)   
		return;
	end

	-- Check for CD
	local _, duration = GetActionCooldown(actionindex)
	if (duration > 0) then
		-- action is on CD so ...
		savedUseAction(actionindex, x, y)   
		return;
	end

	local actionTexture = GetActionTexture(actionindex);
	if (actionTexture) then
		local playerName = UnitName("Player")
		local _, myclass = UnitClass("player")
		myclass = strlow(myclass);
		-- if it has count is a
		if (IsConsumableAction(actionindex)) then myclass = "all" end;
		BRH.setTrackedSpellOnCD(myclass, playerName, actionTexture, "-1");
	end

   savedUseAction(actionindex, x, y)   

end
UseAction = newUseAction
]]
--[[
This code hooks CastSpellByName()
]]
--[[
savedCastSpellByName = CastSpellByName
newCastSpellByName = function(name, onself)

	-- pretty much the same as before
	local spellSlot = util.getSpellSlot(name);
	if (spellSlot == nil) then
		-- spell not in spellbook
		-- Call the original function then
		savedCastSpellByName(name, onself)
		return
	end

	-- then for CD
	local _, duration = GetSpellCooldown(spellSlot, BOOKTYPE_SPELL)
	if (duration > 0) then
		-- spell is on CD so ...
		savedCastSpellByName(name, onself)
		return;
	end

	local spellTexture = strlow(GetSpellTexture(spellSlot, BOOKTYPE_SPELL));
	if (spellTexture) then
		-- ok so, is usable, have enough mana, is in range. It's pretty sure we are gonna be able to use it. Only server can say no then but we are not gonna check that
		local playerName = UnitName("Player")
		local _, myclass = UnitClass("player")
		myclass = strlow(myclass);
		BRH.setTrackedSpellOnCD(myclass, playerName, spellTexture, "-1");
	end
	
    -- Call the original function then
	savedCastSpellByName(name, onself)
end
CastSpellByName = newCastSpellByName
]]
--[[
This code hooks UseInventoryItem()
]]
--[[
savedUseInventoryItem = UseInventoryItem
newUseInventoryItem = function(unit, slot)

	-- Check for CD
	local _, duration = GetInventoryItemCooldown(unit, slot)
	if (duration > 0) then
		-- action is on CD so ...
		savedUseInventoryItem(unit, slot)   
		return;
	end

	local texture = GetInventoryItemTexture(unit, slot);
	if (texture) then
		local playerName = UnitName("Player");
		local myclass = "all";
		BRH.setTrackedSpellOnCD(myclass, playerName, texture, "-1");
	end

	savedUseInventoryItem(unit, slot) 

end
UseInventoryItem = newUseInventoryItem
]]
--[[GetContainerItemCooldown
This code hooks UseContainerItem()
]]
--[[
savedUseContainerItem = UseContainerItem
newUseContainerItem = function(bag, slot, onSelf)

		-- Check for CD
		local _, duration = GetContainerItemCooldown(bag, slot)
		if (duration > 0) then
			-- action is on CD so ...
			savedUseContainerItem(bag, slot, onSelf)   
			return;
		end
	
		local texture = GetContainerItemInfo(bag, slot);
		if (texture) then
			local playerName = UnitName("Player");
			local myclass = "all";
			BRH.setTrackedSpellOnCD(myclass, playerName, texture, "-1");
		end
	
		savedUseContainerItem(bag, slot, onSelf) 

end
UseContainerItem = newUseContainerItem
]]
-- We save here our tickrate, then initialise nextTick.
BRH_CDTracker.tickRate = 1;
BRH_CDTracker.nextTick = GetTime() + BRH_CDTracker.tickRate;

BRH_CDTracker.main:SetScript("OnUpdate", function() 
	if (BRH_CDTracker.nextTick and BRH_CDTracker.nextTick <= GetTime()) then
		--BRH.updateSpellsOnCD()
		if (BRH_CDTrackerConfig and BRH_CDTrackerConfig.show) then
			BRH.updateGUI()
		end
		BRH_CDTracker.nextTick = GetTime() + BRH_CDTracker.tickRate;
	end
end)

BRH_CDTracker.main:SetScript("OnEvent", function()

	if (event == "CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS" or event == "CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE")  then
		if BRH_spellsToTrack ~= nil then 
			for class, spells in pairs(BRH_spellsToTrack) do
				for spell, data in pairs(spells) do
					if (string.find(strlow(arg1), strlow(spell))) then
						BRH_spellsToTrack[class][spell].onCD[util.strsplit(" ", arg1)[1]] = GetTime() + (spellDuration[strlow(spell)] / 1000);
						BRH_spellsToTrack[class][spell].CD = spellDuration[strlow(spell)] / 1000;
					end
				end
			end
		end
	end


	if (event == "ADDON_LOADED" and arg1 ~= "BlastRaidHelper") then return end;

	if (event == "ADDON_LOADED" and arg1 == "BlastRaidHelper") then 

		BRH_CDTrackerConfig = BRH_CDTrackerConfig or {
			["show"] = false
		}
		
		BRH_spellsToTrack = BRH_spellsToTrack or {}
		
		spellOnCDCheck = {
			["spell"] = {},
			["item"] = {}
		};
		
		if BRH_SpellCastCount == nil then
			BRH_SpellCastCount = {}
		end

		for class, spells in pairs(BRH_spellsToTrack) do
			for spell, data in pairs(spells) do
				BRH_spellsToTrack[class][spell].onCD = nil;
				BRH_spellsToTrack[class][spell].onCD = {};
			end
		end
		BRH.buildTrackedSpellsGUI();
	end;

	BRH.getTrackedSpellsInRaid();
end)

--[[ ADDON MSG HANDLING
	elseif (cmd == "trackedSpellUsed") then
		-- handleTrackedSpellUsed(sender, datas);
	elseif (cmd == "trackedSpellUp" and UnitName("Player") ~= sender) then
		-- handleTrackedSpellUp(sender, datas)
	elseif (cmd == "getTrackedSpells") then
		--BRH.getMyTrackedSpells();
]]

local function CDTrackerHandle(msg)
	
	local split = util.strsplit(" ", msg)
	local cmd = split[1]
	tremove(split, 1)
	local arg = table.concat(split, " ");

	if (cmd == "track" or cmd == "untrack") then
		if (not arg or arg == "") then
			util.print("/cdtracker (un)track Classe Nom du sort");
			return
		end

		local split2 = util.strsplit(" ", arg)
		local class = split2[1]
		tremove(split2, 1)
		local spellName = table.concat(split2, " ");

		if (not spellName or spellName == "" or not class or class == "") then
			util.print("/cdtracker (un)track Classe Nom du sort");
			return
		end 

		class = strlow(class)

		-- user might be dumb
		if (class == "guerrier") then class = "warrior"
		elseif (class == "voleur") then class = "roguer"
		elseif (class == "druide") then class = "druid"
		elseif (class == "chasseur") then class = "hunter"
		elseif (class == "démoniste" or class == "demoniste") then class = "warlock"
		elseif (class == "prêtre" or class == "pretre") then class = "priest"
		elseif (class == "chaman") then class = "shaman"
		end

		spellName = strlow(spellName)
		
		-- and we work for him...
		local icon = BRH.BS:GetSpellIcon(spellName);
		if not icon then
			util.print("Le Nom du sort doit être Exacte et dans la langue de votre jeu !");
			util.print("/cdtracker (un)track Classe Nom du sort");
			return;
		end

		if (cmd == "track") then
			BRH.trackSpell(class, icon, spellName)
		elseif (cmd == "untrack") then
			BRH.unTrackSpell(class, icon, spellName)
		end
	elseif (cmd == "show") then
		BRH_CDTrackerConfig.show = true
		BRH_CDTracker.main:Show();
	elseif (cmd == "hide") then
		BRH_CDTrackerConfig.show = false
		BRH_CDTracker.main:Hide();
	end
end



SLASH_CDTRACK1 = "/cdtracker"
SlashCmdList["CDTRACK"] = CDTrackerHandle