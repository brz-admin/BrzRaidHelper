local strlow = string.lower;
-- usefull Function used all over the addon

BRH.util = {}
local util = BRH.util
local parser = BRH.parser
--|cff64fc8aBrz|rRaid|cffb0fc64Helper|r
-- Print to chat frame, used for  debug mostly
function util.print(msg)
	if (msg == nil) then 
		DEFAULT_CHAT_FRAME:AddMessage("[\124cff64fc8aB\124r\124cffffffffr\124r\124cffb0fc64H\124r] >> ERROR : Print Argumenet is \124cffffffffnil\124r.", 0.75, 1, 0.75)
		return
	end
	DEFAULT_CHAT_FRAME:AddMessage("[\124cff64fc8aB\124r\124cffffffffr\124r\124cffb0fc64H\124r] >> "..msg, 0.75, 1, 0.75)
end

-- Send message to other BRH users  
function util.addonCom(comType, content)
	SendAddonMessage(BRH.syncPrefix, comType..";;;"..content, "RAID")
end

function util.PlayerIsPromoted(name)
	if not name then return false end

	for raidIndex=1, MAX_RAID_MEMBERS do
		tarName, rank = GetRaidRosterInfo(raidIndex);
		if (tarName and tarName == name and rank and rank > 0 ) then return true end
	end
	return false;
end

-- [ strsplit ]
-- Splits a string using a delimiter.
-- 'delimiter'  [string]        characters that will be interpreted as delimiter
--                              characters (bytes) in the string.
-- 'subject'    [string]        String to split.
-- return:      [list]         s array.
function util.strsplit(delimiter, subject)
	if not subject then return nil end
	local delimiter, fields = delimiter or ":", {}
	local pattern = string.format("([^%s]+)", delimiter)
	string.gsub(subject, pattern, function(c) fields[table.getn(fields)+1] = c end)
	return fields
end

-- return table length
function util.getTableLength(table)
	local count = 0
	for _ in ipairs(table) do
		count = count + 1
	end
	return count
end

-- format seconds in hour:min:sec format
function util.STC_MIN(seconds)
    local seconds = tonumber(seconds)
    local str;
    if seconds <= 0 then
        return "0";
    else
        hours = string.format("%02.f", math.floor(seconds/3600));
        mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
        secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
        str = secs.."s";
        if (math.floor(seconds/60) > 0) then
            str = mins..":"..secs
        elseif (math.floor(seconds/3600) > 0) then
            str = hours..":"..mins..":"..secs;
        end
        
        return str;
    end
end

function util.numberToOneDec(number)
    return string.format("%.1f", number)
end

util.spellsSlot = {};
function util.getSpellSlot(spellName)
	if (util.spellsSlot[spellName] == nil) then
		local numspells = 0
		-- getting total number of spells
		for i = 1, GetNumSpellTabs() do
			_, _, _, temp = GetSpellTabInfo(i)
			numspells = numspells + temp
		end
		-- for each spell check if it's the one we are looking for
		for i = 1, numspells do
			if strlow(GetSpellName(i, BOOKTYPE_SPELL)) == strlow(spellName) then
				-- it is the one, we store it's slotId
				util.spellsSlot[spellName] = i;
			end
		end

		return util.spellsSlot[spellName];
	else
		return util.spellsSlot[spellName];
	end
end

function util.hasBuffByIcon(buffTexture)
	for i=0, 32 do
		if (GetPlayerBuffTexture(GetPlayerBuff(i, "HELPFUL")) == "Interface\\Icons\\"..buffTexture) then
			return i;
		end
	end
	return false;
end

function util.getSpellCD(spellName)
	-- we need to get the slotID
	local spellSlot = util.getSpellSlot(spellName);
	-- we don't have spell, so let's just stop here
	if (spellSlot == nil) then return nil end;
	-- we got it's slot ID so we return the data we look for
	local start, spellCD = GetSpellCooldown(spellSlot, BOOKTYPE_SPELL)
	spellCD = math.max((start + spellCD) - GetTime(), 0);
	return spellCD;
end

function util.hasValue (tab, val)
    for key, value in pairs(tab) do
        if tonumber(value) == tonumber(val) then
            return true
        end
    end
    return false
end

function util.getKeyName(tab, key)
	for k,_ in pairs(tab) do
		if k == key then return k end
	end
end

function util.StripTextures(frame, hide, layer)
	for _,v in ipairs({frame:GetRegions()}) do
		if v.SetTexture then
			local check = true
			if layer and v:GetDrawLayer() ~= layer then check = false end

			if check then
				if hide then
					v:Hide()
				else
					v:SetTexture(nil)
				end
			end
		end
	end
end

function util.tableclone(org)
	return {unpack(org)}
end


function util.GetItemInBag(textEN,textFR)
	for bag=0,4 do
		for slot=1,GetContainerNumSlots(bag) do
			if (GetContainerItemLink(bag,slot)) then
				if (string.find(GetContainerItemLink(bag,slot), textEN)) or (string.find(GetContainerItemLink(bag,slot), textFR)) then
					return bag, slot;
				end
			end
		end
	end
end
  
-- Stop Combatlog parsing for DPSMate and KTM
function util.unregAddons()
	if (DPSMate ~= nil) then
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_COMBAT_PET_HITS")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_COMBAT_PET_MISSES")
		--DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_PET_BUFF")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_PET_DAMAGE")

		DPSMate.Parser:UnregisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE") --
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE") --
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_COMBAT_PARTY_HITS")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_COMBAT_PARTY_MISSES")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_COMBAT_FRIENDLYPLAYER_MISSES")

		DPSMate.Parser:UnregisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES")

		DPSMate.Parser:UnregisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE") 

		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_SELF_BUFF")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_PARTY_BUFF")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS")

		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_BREAK_AURA")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY")

		DPSMate.Parser:UnregisterEvent("CHAT_MSG_COMBAT_FRIENDLY_DEATH")
		DPSMate.Parser:UnregisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
		DPSMate.Parser:UnregisterEvent("PLAYER_AURAS_CHANGED")

		DPSMate.Parser:UnregisterEvent("PLAYER_LOGOUT")
		DPSMate.Parser:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end

	if (klhtm ~= nil) then
		-- register events. Strictly after all modules have been loaded.
		for key, subtable in klhtm do
			if type(subtable) == "table" and subtable.myevents then
				
				klhtm.events[key] = { }
				for _, event in subtable.myevents do
					klhtm.frame:UnregisterEvent(event)
					klhtm.events[key][event] = false 
				end
			end
		end
	end
end

-- Stop Restart parsing for DPSMate and KTM
function util.regAddons()
	if (DPSMate ~= nil) then
		DPSMate.Parser:RegisterEvent("CHAT_MSG_COMBAT_PET_HITS")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_COMBAT_PET_MISSES")
		--DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_PET_BUFF")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_PET_DAMAGE")

		DPSMate.Parser:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE") --
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE") --
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_COMBAT_PARTY_HITS")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_COMBAT_PARTY_MISSES")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLYPLAYER_MISSES")

		DPSMate.Parser:RegisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES")

		DPSMate.Parser:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE") 

		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_PARTY_BUFF")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS")

		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_BREAK_AURA")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY")

		DPSMate.Parser:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLY_DEATH")
		DPSMate.Parser:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
		DPSMate.Parser:RegisterEvent("PLAYER_AURAS_CHANGED")

		DPSMate.Parser:RegisterEvent("PLAYER_LOGOUT")
		DPSMate.Parser:RegisterEvent("PLAYER_ENTERING_WORLD")
	end

	if (klhtm ~= nil) then
		-- register events. Strictly after all modules have been loaded.
		for key, subtable in klhtm do
			if type(subtable) == "table" and subtable.myevents then
				
				klhtm.events[key] = { }
				for _, event in subtable.myevents do
					klhtm.frame:RegisterEvent(event)
					klhtm.events[key][event] = true 
				end
			end
		end
	end
end


----- Getting names from interface -----

util.BRH_ToolTipFrame = CreateFrame("GameTooltip", "BRH_ToolTipFrame", nil, "GameTooltipTemplate");
util.BRH_ToolTipFrame:SetOwner(UIParent, 'ANCHOR_NONE')

function util.getPlayerAuraName(idx)
	util.BRH_ToolTipFrame:ClearLines()
	util.BRH_ToolTipFrame:SetPlayerBuff(buffIndex)
	return BRH_ToolTipFrameTextLeft1:GetText(), BRH_ToolTipFrameTextLeft3:GetText()
end

function util.getUnitBuffName(unitId, idx)
	util.BRH_ToolTipFrame:ClearLines()
	util.BRH_ToolTipFrame:SetUnitBuff(unitId, idx)
	return BRH_ToolTipFrameTextLeft1:GetText(), BRH_ToolTipFrameTextLeft3:GetText()
end

function util.getUnitDebuffName(unitId, idx)
	util.BRH_ToolTipFrame:ClearLines()
	util.BRH_ToolTipFrame:SetUnitDebuff(unitId, idx)
	return BRH_ToolTipFrameTextLeft1:GetText(), BRH_ToolTipFrameTextLeft3:GetText()
end

function util.getUnitItemName(unitId, slot)
	util.BRH_ToolTipFrame:ClearLines()
	util.BRH_ToolTipFrame:SetInventoryItem(unitId, slot, true)
	return BRH_ToolTipFrameTextLeft1:GetText()
end

function util.getBagItemName(bag, slot)
	util.BRH_ToolTipFrame:ClearLines()
	util.BRH_ToolTipFrame:SetBagItem(bag, slot)
	return BRH_ToolTipFrameTextLeft1:GetText(), BRH_ToolTipFrameTextLeft2:GetText()
end

function util.getActionName(actionindex)
	util.BRH_ToolTipFrame:ClearLines()
	util.BRH_ToolTipFrame:SetAction(actionindex)
	return BRH_ToolTipFrameTextLeft1:GetText()
end

function util.getSpellCooldownInBook(spellBookId)
	util.BRH_ToolTipFrame:ClearLines()
	util.BRH_ToolTipFrame:SetSpell(spellBookId, BOOKTYPE_SPELL);
	if (BRH_ToolTipFrameTextRight3:GetText() == "" or BRH_ToolTipFrameTextRight3:GetText() == nil) then
		return 0
	else
		return parser.cdStringToSeconds(BRH_ToolTipFrameTextRight3:GetText())
	end
end