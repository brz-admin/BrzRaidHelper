local strlow = string.lower;

BRH.cdTracker = {}
local tracker = BRH.cdTracker
local util = BRH.util

tracker.isBuilt = false;

function tracker.trackSpell(icon, name)


	if (BRH_spellsToTrack == nil) then
		BRH_spellsToTrack = {}
	end

	name = strlow(name);
	if (BRH_spellsToTrack[name] == nil) then
		BRH_spellsToTrack[name] = {
			["icon"] = icon,
			["tracked"] = true, -- If the player using the addon track it ?
			["onCD"] = {}, -- players in cd fromated [playerName] = time when it's up or false.
			["CD"] = 0
		}
	end
	BRH_spellsToTrack[name].tracked = true;

	tracker.buildTrackedSpellsGUI()
end

function tracker.unTrackSpell(icon, name)

	if (BRH_spellsToTrack == nil) then
		BRH_spellsToTrack = {}
	end

	name = strlow(icon);
	if (BRH_spellsToTrack[name] == nil) then
		BRH_spellsToTrack[name] = {
			["tracked"] = true, -- If the player using the addon track it ?
			["onCD"] = {}, -- players in cd fromated [playerName] = time when it's up or false.
		}
	end
	BRH_spellsToTrack[name].tracked = false;

	tracker.buildTrackedSpellsGUI()
end

------ GUI STUFF ------
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
BRH_CDTracker.main:RegisterEvent("CHAT_MSG_ADDON")
BRH_CDTracker.main:SetMovable(true);
BRH_CDTracker.main:EnableMouse(true);
BRH_CDTracker.main:RegisterForDrag("LeftButton");
BRH_CDTracker.main:SetScript("OnDragStart", function() this:StartMoving() end);
BRH_CDTracker.main:SetScript("OnDragStop", function() this:StopMovingOrSizing() end);

function tracker.buildTrackedSpellsGUI()
	local precedentFrame = nil;
		for spell, datas in pairs(BRH_spellsToTrack) do
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
	tracker.isBuilt = true;
	tracker.updateGUI();
end

function tracker.updateGUI()

	if (not tracker.isBuilt) then
		return
	end

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

		for spell, datas in pairs(BRH_spellsToTrack) do
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
						elseif (cd ~= "-1" and tonumber(cd) <= GetTime()) then 
							BRH_spellsToTrack[spell].onCD[player] = false;
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
							BRH_CDTracker[spell].playersFrames[player].textZone:Hide();
							BRH_CDTracker[spell].playersFrames[player].playerName:Hide();
							BRH_CDTracker[spell].playersFrames[player].cdBG:Hide();
							BRH_CDTracker[spell].playersFrames[player].cd:Hide();
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

function tracker.getMyCds()
	local i = 1
	while true do
		local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
		if not spellName then
			break
		end
		local start, duration = GetSpellCooldown(i, BOOKTYPE_SPELL);
		local up = 0;

		if start > 0 and duration > 0 then
			up = start + duration
		end
		
		local myspell = spellName .. '::' .. up;
		-- use spellName and spellRank here
		util.addonCom("myCds", myspell)
		i = i + 1
	end

	for bag = 0, 4 do
		if GetContainerNumSlots(bag) > 0 then
			for slot = 0, GetContainerNumSlots(bag) do
				local itemName = util.getBagItemName(bag, slot)
				if (itemName ~= nil) then
					local start, duration = GetContainerItemCooldown(bag, slot)
					local up = 0;
	
					if start > 0 and duration > 0 then
						up = start + duration
					end
	
					local myspell = itemName .. '::' .. up;
					-- use spellName and spellRank here
					util.addonCom("myCds", myspell)
				end
			end
		end
	end
end

function tracker.getTrackedSpellsInRaid()
	-- not in raid, nothing to do here
	if (not UnitInRaid("Player")) then
		return
	end
	util.addonCom("getTrackedSpells", "")
end

function tracker.setTrackedSpellOnCD(sender, spell, time)
	spell = strlow(spell);

	local sentBySelf = strlow(UnitName("Player")) == strlow(sender);
	if (BRH_spellsToTrack ~= nil and BRH_spellsToTrack[spell] ~= nil) then
		BRH_spellsToTrack[spell]["onCD"][sender] = time;
	end

	-- if self we can just send it
	if (sentBySelf) then
		util.addonCom("trackedSpellUsed", spell..":"..time)
	end
end

function tracker.handleTrackedSpellUsed(sender, datas)
	-- we don't wanna get our own updates as we already handled them
	if (strlow(sender) == strlow(UnitName("Player"))) then
		return
	end

	local split = util.strsplit(":", datas)
	local spell = split[1];
	local duration = split[2];
	tracker.setTrackedSpellOnCD(sender, spell, duration);
end

--[[
This code hooks UseAction
]]

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

	local actionName = 	util.getActionName(actionindex);
	if (actionName) then
		tracker.setActionCheck(actionindex);
	end

   savedUseAction(actionindex, x, y)   

end
UseAction = newUseAction

tracker.actionsToCheck = {}
tracker.doCheckActions = false;

function tracker.setActionCheck(actionindex)
	tracker.actionsToCheck[actionindex] = true;
	-- set to true anywau so we know we have actions to check
	tracker.doCheckActions = true
end

function tracker.checkActions()
	-- no action to check
	if not tracker.doCheckActions then return end

	for actionIdx, doCheck in pairs(tracker.actionsToCheck) do
		if (doCheck) then
			local start, cd, enable = GetActionCooldown(actionIdx);
			if (enable) then
				local aName = util.getActionName(actionIdx);
				local time = start + cd
				tracker.setTrackedSpellOnCD(UnitName("player"), aName, time)
			end
		end
	end
	tracker.actionsToCheck = {}
	tracker.doCheckActions = false;
end

--[[
This code hooks CastSpellByName()
]]
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

	tracker.setSpellCheck(spellSlot);
	
    -- Call the original function then
	savedCastSpellByName(name, onself)
end
CastSpellByName = newCastSpellByName

tracker.spellsToCheck = {}
tracker.doCheckSpells = false;

function tracker.setSpellCheck(spellSlot)
	tracker.spellsToCheck[spellSlot] = true;
	-- set to true anywau so we know we have actions to check
	tracker.doCheckSpells = true
end

function tracker.checkSpells()
	-- no action to check
	if not tracker.doCheckSpells then return end

	for spellSlot, doCheck in pairs(tracker.spellsToCheck) do
		if (doCheck) then
			local start, cd, enable = GetSpellCooldown(slot, BOOKTYPE_SPELL);
			if (enable) then
				local sName = GetSpellName(lot, BOOKTYPE_SPELL);
				local time = start + cd
				tracker.setTrackedSpellOnCD(UnitName("player"), sName, time)
			end
		end
	end
	tracker.spellsToCheck = {}
	tracker.doCheckSpells = false
end

--[[
This code hooks UseInventoryItem()
]]
savedUseInventoryItem = UseInventoryItem
newUseInventoryItem = function(slot)
	-- Check for CD
	local _, duration = GetInventoryItemCooldown("player", slot)
	if (duration > 0) then
		-- action is on CD so ...
		savedUseInventoryItem(slot)   
		return;
	end

	local ivItemName = util.getUnitItemName("player", slot)
	if (ivItemName) then
		tracker.setIventItemCheck(slot)
	end

	savedUseInventoryItem(slot)
end
UseInventoryItem = newUseInventoryItem

tracker.inventItemToCheck = {}
tracker.doCheckInventItem = false;

function tracker.setIventItemCheck(slot)
	tracker.inventItemToCheck[slot] = true;
	-- set to true anywau so we know we have actions to check
	tracker.doCheckInventItem = true
end

function tracker.checkIventItems()
	-- no action to check
	if not tracker.doCheckInventItem then return end

	for slot, doCheck in pairs(tracker.inventItemToCheck) do
		if (doCheck) then
			local start, cd, enable = GetInventoryItemCooldown("player", slot);
			if (enable) then
				local aName = util.getActionName(actionIdx);
				local time = start + cd
				tracker.setTrackedSpellOnCD(UnitName("player"), aName, time)
			end
		end
	end
	tracker.inventItemToCheck = {}
	tracker.doCheckInventItem = false;
end

--[[GetContainerItemCooldown
This code hooks UseContainerItem()
]]
savedUseContainerItem = UseContainerItem
newUseContainerItem = function(bag, slot, onSelf)

		-- Check for CD
		local _, duration = GetContainerItemCooldown(bag, slot)
		if (duration > 0) then
			-- action is on CD so ...
			savedUseContainerItem(bag, slot, onSelf)   
			return;
		end
	
		local name = util.getBagItemName(bag, slot)
		if (name) then
			tracker.setContainItemCheck(bag.."."..slot)
		end
	
		savedUseContainerItem(bag, slot, onSelf) 

end
UseContainerItem = newUseContainerItem

tracker.containItemToCheck = {}
tracker.doCheckContainItem = false;

function tracker.setContainItemCheck(slot)
	tracker.containItemToCheck[slot] = true;
	-- set to true anywau so we know we have actions to check
	tracker.doCheckContainItem = true
end

function tracker.checkContainItem()
	-- no action to check
	if not tracker.doCheckContainItem then return end

	for slotStr, doCheck in pairs(tracker.containItemToCheck) do
		if (doCheck) then
			local split = util.strsplit(".", slotStr)
			local bag = split[1]
			local slot = split[2]
			local start, cd, enable = GetContainerItemCooldown(bag, slot)
			if (enable) then
				local aName = getBagItemName(bag, slot)
				local time = start + cd
				tracker.setTrackedSpellOnCD(UnitName("player"), aName, time)
			end
		end
	end
	tracker.containItemToCheck = {}
	tracker.doCheckContainItem = false;
end

-- We save here our tickrate, then initialise nextTick.
BRH_CDTracker.tickRate = 1;
BRH_CDTracker.nextTick = GetTime() + BRH_CDTracker.tickRate;

BRH_CDTracker.main:SetScript("OnUpdate", function() 
	if (BRH_CDTracker.nextTick and BRH_CDTracker.nextTick <= GetTime()) then
		--tracker.updateSpellsOnCD()
		if (not tracker.isBuilt) then
			tracker.buildTrackedSpellsGUI();
		end
		
		if (BRH_CDTrackerConfig and BRH_CDTrackerConfig.show) then
			tracker.updateGUI()
		end
		tracker.checkActions()
		tracker.checkIventItems()
		tracker.checkContainItem()
		tracker.checkSpells()
		BRH_CDTracker.nextTick = GetTime() + BRH_CDTracker.tickRate;
	end
end)

BRH_CDTracker.main:SetScript("OnEvent", function()
	if (event == "ADDON_LOADED" and arg1 == "BlastRaidHelper") then 
		BRH_CDTrackerConfig = BRH_CDTrackerConfig or {
			["show"] = false
		}

		if (BRH_spellsToTrack == nil) then
			BRH_spellsToTrack = {}
		end

		for spell, data in pairs(BRH_spellsToTrack) do
			BRH_spellsToTrack[spell].onCD = nil;
			BRH_spellsToTrack[spell].onCD = {};
		end

		tracker.buildTrackedSpellsGUI();
	elseif (event == "RAID_ROSTER_UPDATE") then
		tracker.getTrackedSpellsInRaid();
	elseif (event == "CHAT_MSG_ADDON" and arg1 == BRH.syncPrefix) then
		tracker.HandleAddonMSG(arg4, arg2);
	end

end)

function tracker.HandleAddonMSG(sender, data)
	local split = util.strsplit(";;;", data)
	local cmd = split[1]
	local datas = split[2]
	if (cmd == "trackedSpellUsed") then
		local spellData = util.strsplit(":", datas)
		local spellname = strlow(spellData[1])
		if (strlow(sender) ~= strlow(UnitName("Player"))) then
			tracker.setTrackedSpellOnCD(sender, spellname, spellData[2])
		end
	elseif (cmd == "getTrackedSpells") then
		tracker.getMyCds()
	elseif (cmd == "myCds" and sender ~= UnitName("Player")) then
		local spellData = util.strsplit("::", datas)
		local spellname = strlow(spellData[1])
		if (BRH_spellsToTrack[spellname]) then
			if (spellData[2] == 0) then
				BRH_spellsToTrack[spellname].onCd[sender] = false
			else
				tracker.setTrackedSpellOnCD(sender, spellname, spellData[2])
			end
		elseif (GetLocale() == "frFR") then 
			if (BRH.BS[spellData[1]] ~= nil) then
				spellName = strlow(BRH.BS[spellData[1]])
				if (spellData[2] == 0) then
					BRH_spellsToTrack[spellname].onCd[sender] = false
				else
					tracker.setTrackedSpellOnCD(sender, spellname, spellData[2])
				end
			end
		else 
			BRH.BS:SetLocale("frFR");
			if (BRH.BS:HasReverseTranslation(spellData[1])) then
				spellName = strlow(BRH.BS:GetReverseTranslation(spellData[1]))
				if (spellData[2] == 0) then
					BRH_spellsToTrack[spellname].onCd[sender] = false
				else
					tracker.setTrackedSpellOnCD(sender, spellname, spellData[2])
				end
			end
			BRH.BS:SetLocale(GetLocale());
		end 
	end
end

local function CDTrackerHandle(msg)
	
	local split = util.strsplit(" ", msg)
	local cmd = split[1]
	tremove(split, 1)
	local arg = table.concat(split, " ");

	if (cmd == "track" or cmd == "untrack") then
		if (not arg or arg == "") then
			util.print("/cdtracker (un)track Nom du sort");
			return
		end

		local spellName = arg;

		if (not spellName or spellName == "") then
			util.print("/cdtracker (un)track Nom du sort");
			return
		end 

		spellName = strlow(spellName)
		
		-- and we work for him...
		local icon = BRH.BS:GetSpellIcon(spellName);
		if not icon then
			util.print("Le Nom du sort doit être Exacte et dans la langue de votre jeu !");
			util.print("/cdtracker (un)track Nom du sort");
			return;
		end

		if (cmd == "track") then
			tracker.trackSpell(icon, spellName)
		elseif (cmd == "untrack") then
			tracker.unTrackSpell(icon, spellName)
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