
local parser = BRH.parser
local util = BRH.util

BRH.igniteTracker = {}
local igniteTracker = BRH.igniteTracker

igniteTracker.lastCritSource = "";
igniteTracker.lastCritDamage = 0;
igniteTracker.lastCritSpell = "";
igniteTracker.IgniteTrackLastTick = GetTime();

IGNITE = "Ignite"
if (GetLocale() == "frFR") then 
	IGNITE = "Enflammer"
end

local rollingIgnite = {}
--[[ table that Contain the ignite objects
{
	remaining = 0,
	stack = 1,
	target = "targetName",
	damage = 0,
	source = 0,
	procDMG = {
		player = "playername",
		spell = "spellName",
		dmg = "spellDamage"
	}
}
]]

-- Main frame
igniteTracker.main = CreateFrame("Frame", "igniteTracker_main")
igniteTracker.main:SetPoint("CENTER", "UIParent", "CENTER")
igniteTracker.main:SetWidth(150)
igniteTracker.main:SetHeight(15)
--igniteTracker.main:RegisterAllEvents();
igniteTracker.main:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE");
igniteTracker.main:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER");
igniteTracker.main:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE");
igniteTracker.main:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE");
igniteTracker.main:SetMovable(true);
igniteTracker.main:EnableMouse(true);
igniteTracker.main:RegisterForDrag("LeftButton");
igniteTracker.main:SetScript("OnDragStart", function() this:StartMoving() end);
igniteTracker.main:SetScript("OnDragStop", function() this:StopMovingOrSizing() end);

-- Bckground
igniteTracker.bg = CreateFrame("Frame", "igniteTracker_bg", igniteTracker.main);
igniteTracker.bg:SetAllPoints("igniteTracker_main");
igniteTracker.bg:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 0});
igniteTracker.bg:SetBackdropColor(0,0,0,0.5);
igniteTracker.bg:SetFrameStrata("BACKGROUND")

-- Name of the module
igniteTracker.fName = igniteTracker.main:CreateFontString( "igniteTrackerframefName", "OVERLAY", "GameFontWhite")
igniteTracker.fName:SetPoint("BOTTOMLEFT", "igniteTracker_main", "TOPLEFT", 0, 0);
igniteTracker.fName:SetText("IGNITE");
igniteTracker.fName:SetFont("Fonts\\FRIZQT__.TTF", 6)
igniteTracker.fName:SetTextColor(1, 1, 1, 1);

-- contain the CD and main texts
igniteTracker.frame = CreateFrame("Frame", "igniteTrackerframe", igniteTracker.main)
igniteTracker.frame:SetPoint("BOTTOMLEFT", "igniteTracker_main", "BOTTOMLEFT", 0, 0)
igniteTracker.frame:SetWidth(150)
igniteTracker.frame:SetHeight(15)
igniteTracker.frame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 5});
igniteTracker.frame:SetBackdropColor(0,0,0,0.25);
igniteTracker.frame:EnableMouse();

-- icon frame
igniteTracker.frame.icon = CreateFrame("Frame",  "igniteTrackerframeicon", igniteTracker.frame);
igniteTracker.frame.icon:SetPoint("LEFT",  "igniteTrackerframe", "LEFT", 3, 0)
igniteTracker.frame.icon:SetWidth(15)
igniteTracker.frame.icon:SetHeight(15)

-- icon texture
igniteTracker.frame.icontex = igniteTracker.frame:CreateTexture( "igniteTrackerframe_icon_texture", "OVERLAY")
igniteTracker.frame.icontex:SetAllPoints(igniteTracker.frame.icon);
igniteTracker.frame.icontex:SetTexture("Interface\\Icons\\spell_fire_incinerate")
igniteTracker.frame.icontex:SetTexCoord(0.1,0.9,0.1,0.9)

-- textzone, not sure if realy needed right now but used for text placing
igniteTracker.frame.textZone = CreateFrame("Frame",  "igniteTrackerframetextZone", igniteTracker.frame.icon);
igniteTracker.frame.textZone:SetPoint("RIGHT",  "igniteTrackerframe", "RIGHT", -2, 0)
igniteTracker.frame.textZone:SetWidth(130)
igniteTracker.frame.textZone:SetHeight(15)

-- cd, show lasting duration on the ignite as text
igniteTracker.frame.cd = igniteTracker.frame:CreateFontString( "igniteTrackerframecd", "OVERLAY", "GameFontWhite")
igniteTracker.frame.cd:SetPoint("RIGHT", "igniteTrackerframetextZone", "RIGHT", -2, 0);
igniteTracker.frame.cd:SetText(4);
igniteTracker.frame.cd:SetFont("Fonts\\FRIZQT__.TTF", 10)
igniteTracker.frame.cd:SetTextColor(1, 1, 1, 1);

-- name of the player who get ignite damages
igniteTracker.frame.source = igniteTracker.frame:CreateFontString( "igniteTrackerframesource", "OVERLAY", "GameFontWhite")
igniteTracker.frame.source:SetPoint("TOP", "igniteTrackerframetextZone", "TOP", 0, 5);
igniteTracker.frame.source:SetText("");
igniteTracker.frame.source:SetFont("Fonts\\FRIZQT__.TTF", 8)
igniteTracker.frame.source:SetTextColor(1, 1, 1, 1);

-- damages of the rolling ignite
igniteTracker.frame.dmg = igniteTracker.frame:CreateFontString( "igniteTrackerframedmg", "OVERLAY", "GameFontWhite")
igniteTracker.frame.dmg:SetPoint("LEFT", "igniteTrackerframetextZone", "RIGHT", 4, 0);
igniteTracker.frame.dmg:SetText("");
igniteTracker.frame.dmg:SetFont("Fonts\\FRIZQT__.TTF", 10)
igniteTracker.frame.dmg:SetTextColor(1, 1, 0, 1);

-- show lasting duration as a progress bar
igniteTracker.frame.bar = CreateFrame("Frame", "igniteTracker_barframe", igniteTracker.frame);
igniteTracker.frame.bar:SetPoint("LEFT", "igniteTrackerframe", "LEFT", 20, 0);
igniteTracker.frame.bar:SetHeight(15);
igniteTracker.frame.bar:SetWidth(130);
igniteTracker.frame.bar:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 0});
igniteTracker.frame.bar:SetBackdropColor(1,0,0,1);
igniteTracker.frame.bar:SetFrameStrata("LOW")

-- show list of damages that contributed to the ignite
igniteTracker.frame.dmgList = CreateFrame("Frame", "igniteTrackerframeDmgList", igniteTracker.frame)
igniteTracker.frame.dmgList:SetPoint("TOP", "igniteTrackerframe", "BOTTOM")
igniteTracker.frame.dmgList:SetWidth(150)
igniteTracker.frame.dmgList:SetHeight(0)
igniteTracker.frame.dmgList:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 5});
igniteTracker.frame.dmgList:SetBackdropColor(0,0,0,0.25);
igniteTracker.frame.dmgList:SetFrameStrata("BACKGROUND")
igniteTracker.frame.dmgList:Hide()

-- each damage is detailed ( how much it contributed, by whom and what spell it was )
for i=1,5 do
	igniteTracker.frame.dmgList[i] = CreateFrame("Frame", "igniteTrackerframeDmgList"..i, igniteTracker.frame.dmgList)
	if (i == 1) then
		igniteTracker.frame.dmgList[i]:SetPoint("TOP", "igniteTrackerframeDmgList", "TOP")
	else
		igniteTracker.frame.dmgList[i]:SetPoint("TOP", "igniteTrackerframeDmgList"..(i-1), "BOTTOM")
	end
	igniteTracker.frame.dmgList[i]:SetWidth(150)
	igniteTracker.frame.dmgList[i]:SetHeight(15)
	igniteTracker.frame.dmgList[i].PartDmg = igniteTracker.frame:CreateFontString( "igniteTrackerframeDmgListPartDmg"..i, "OVERLAY", "GameFontWhite")
	igniteTracker.frame.dmgList[i].PartDmg:SetPoint("LEFT", "igniteTrackerframeDmgList"..i, "LEFT", 2, 0);
	igniteTracker.frame.dmgList[i].PartDmg:SetText("");
	igniteTracker.frame.dmgList[i].PartDmg:SetFont("Fonts\\FRIZQT__.TTF", 8)
	igniteTracker.frame.dmgList[i].PartDmg:SetTextColor(1, 1, 0, 1);
	igniteTracker.frame.dmgList[i].pName = igniteTracker.frame:CreateFontString( "igniteTrackerframeDmgListPName"..i, "OVERLAY", "GameFontWhite")
	igniteTracker.frame.dmgList[i].pName:SetPoint("LEFT", "igniteTrackerframeDmgList"..i, "LEFT", 25, 0);
	igniteTracker.frame.dmgList[i].pName:SetText("");
	igniteTracker.frame.dmgList[i].pName:SetFont("Fonts\\FRIZQT__.TTF", 8)
	igniteTracker.frame.dmgList[i].pName:SetTextColor(1, 1, 1, 1);
	igniteTracker.frame.dmgList[i].spell = igniteTracker.frame:CreateFontString( "igniteTrackerframeDmgListSpell"..i, "OVERLAY", "GameFontWhite")
	igniteTracker.frame.dmgList[i].spell:SetPoint("RIGHT", "igniteTrackerframeDmgList"..i, "RIGHT", -2, 0);
	igniteTracker.frame.dmgList[i].spell:SetText("");
	igniteTracker.frame.dmgList[i].spell:SetFont("Fonts\\FRIZQT__.TTF", 8)
	igniteTracker.frame.dmgList[i].spell:SetTextColor(1, 1, 1, 1);
end

-- this function will help us update this frame as it only showed as a tooltip
igniteTracker.frame.dmgList.update = function(target)
	for i=1,5 do
		if (rollingIgnite[target] ~= nil and rollingIgnite[target].procDmg[i] ~= nil and igniteTracker.frame.dmgList:IsVisible())  then
			igniteTracker.frame.dmgList[i].PartDmg:SetText(math.ceil((rollingIgnite[target].procDmg[i].dmg*0.4)/2));
			igniteTracker.frame.dmgList[i].pName:SetText(rollingIgnite[target].procDmg[i].player);
			igniteTracker.frame.dmgList[i].spell:SetText(rollingIgnite[target].procDmg[i].spell.." ("..rollingIgnite[target].procDmg[i].dmg..")")
			igniteTracker.frame.dmgList:SetHeight(15 * i)
		else
			igniteTracker.frame.dmgList[i].PartDmg:SetText("");
			igniteTracker.frame.dmgList[i].pName:SetText("");
			igniteTracker.frame.dmgList[i].spell:SetText("")
			igniteTracker.frame.dmgList[i]:Hide();
		end
	end
end

-- only show damagelist on mouseover
igniteTracker.frame:SetScript("OnEnter", function() 
	local target = UnitName("target")
	if(rollingIgnite[target] == nil) then return end;
	this.dmgList:Show()
	igniteTracker.frame.dmgList.update(target)
end)
igniteTracker.frame:SetScript("OnLeave", function() 
	this.dmgList:Hide()
	igniteTracker.frame.dmgList.update(target)
end) 

-- handling of combatLog events
igniteTracker.main:SetScript("OnEvent", function()
	if (event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE") then
        -- fired when someone get a new ignite stack
		local auraAdded = string.gsub(AURAAPPLICATIONADDEDOTHERHARMFUL, "%%s", function(match) return "(.+)" end)
		auraAdded = string.gsub(auraAdded, "%(%%d%)", function(match) return "%((%d)%)" end)
		local auraNew = string.gsub(AURAADDEDOTHERHARMFUL, "%%s", function(match) return "(.+)" end)

		if (string.find(arg1, auraAdded)) then
			local _, _, target, spell, stack = string.find(arg1, auraAdded);
			if (spell ~= IGNITE) then return end;
			if (rollingIgnite[target] == nil) then return end; -- we didn't catch first proc so we might just skip this one
            -- update debuff duration and stack number (this last one is not shown yet)
			rollingIgnite[target].stack = rollingIgnite[target].stack + 1
			-- rollingIgnite[target].remaining  = math.min(rollingIgnite[target].remaining + 2, 4)
        -- fired at first proc of ignite
		elseif (string.find(arg1, auraNew)) then
            -- new ignite, let's do this
			local _, _, target, spell = string.find(arg1, auraNew);
			if (spell ~= IGNITE) then return end;
            -- as we record every fire crit data we can use this to get source and damage even tho we don't have it from combatlog yet
			rollingIgnite[target] = {
				remaining = 4,
				stack = 1,
				target = target,
				damage = math.floor((tonumber(igniteTracker.lastCritDamage) * 0.4)/2),
				source = igniteTracker.lastCritSource,
				procDmg = {}
			}
            -- we can aswell fill the first stack info
			rollingIgnite[target].procDmg[1] = {
				player = igniteTracker.lastCritSource,
				spell = igniteTracker.lastCritSpell,
				dmg = igniteTracker.lastCritDamage
			}
		else
            -- fired at ignite tick
			local target, damage, damageType, source, spellName = parser.periodicSpellDamage(arg1)
			if (spellName ~= IGNITE) then return end;
			if (rollingIgnite[target] == nil) then return end;
            -- not guessing anymore, make sure it's right
			rollingIgnite[target].source = source
			rollingIgnite[target].damage = damage
		end
	elseif (event == "CHAT_MSG_SPELL_AURA_GONE_OTHER") then
        -- fired at debuff fade, we can destroy our data
		local fadingString = string.gsub(AURAREMOVEDOTHER, "%%s", function(match) return "(.+)" end)
		if (string.find(arg1, fadingString)) then
			local _, _, spell, target = string.find(arg1, fadingString)
			if (spell ~= IGNITE) then return end;
			rollingIgnite[target] = nil
			igniteTracker.frame.dmg:SetText("");
			igniteTracker.frame.source:SetText("");
		end
	elseif (event == "CHAT_MSG_SPELL_PARTY_DAMAGE" or event == "CHAT_MSG_SPELL_SELF_DAMAGE") then
        -- fired at spell casted by party member
		local target, damage, damageSchool, source, spellName, damageType, sourceClass;
		if (event == "CHAT_MSG_SPELL_PARTY_DAMAGE") then
			target, damage, damageSchool, source, spellName, damageType = parser.partySpellDamage(arg1)
			if (source ~= nil) then
				TargetByName(source)
				sourceClass = UnitClass("target")
				TargetLastTarget()
			end
		elseif (event == "CHAT_MSG_SPELL_SELF_DAMAGE") then
			target, damage, damageSchool, source, spellName, damageType = parser.selfSpellDamage(arg1)
			sourceClass = BRH.pClass
		end
		if (sourceClass == nil) then return end;
        -- Not a mage, we don't care about you
		if (string.lower(sourceClass) ~= "mage") then return end;
		if (damageType == "crit" and (damageSchool == "Fire" or damageSchool == "Feu")) then
            -- we only are interested in theses spells
			if (rollingIgnite[target] == nil) then 
				-- no ignite right now, just store the data as it will be useful next
				igniteTracker.lastCritSource = source;
				igniteTracker.lastCritDamage = damage;
				igniteTracker.lastCritSpell = spellName;
				return;
			end;
			-- ignite is rolling but not full stack, let's store the data so we can show them
			if (rollingIgnite[target].stack < 5) then
				rollingIgnite[target].procDmg[rollingIgnite[target].stack + 1] = {
					player = source,
					spell = spellName,
					dmg = damage
				}
				rollingIgnite[target].damage = rollingIgnite[target].damage + math.floor((tonumber(damage) * 0.4)/2)
			end
			-- update remaining time, can't excess 4sec
			rollingIgnite[target].remaining = math.min(rollingIgnite[target].remaining + 2, 4)
		end
	end
end)

igniteTracker.main:SetScript("OnUpdate", function()
	-- Elapsed Time
	local elapsed = GetTime() - igniteTracker.IgniteTrackLastTick;

	--  get current Target name to know if we show or not
	local target = UnitName("target")

	-- update timings
	for key, ignite in pairs(rollingIgnite) do
		if (ignite.remaining ~= nil) then
			ignite.remaining = ignite.remaining - elapsed;
			if (ignite.remaining <= 0) then
				ignite.remaining = 0
			end
		end
	end

	-- check if target exist in our table
	if (rollingIgnite[target] ~= nil) then
		-- it does
		igniteTracker.frame:Show();
		-- update duration text
		igniteTracker.frame.cd:SetText(util.numberToOneDec(rollingIgnite[target].remaining));
		-- duration progress bar size
		igniteTracker.frame.bar:SetWidth((rollingIgnite[target].remaining / 4) * 130);

		-- we know who get the Ignite so we show it
		if (rollingIgnite[target].source ~= 0) then
			igniteTracker.frame.source:SetText(rollingIgnite[target].source);
		end

		-- we know what is the tick from it so we show it
		if (rollingIgnite[target].damage ~= 0) then
			igniteTracker.frame.dmg:SetText(rollingIgnite[target].damage)
		end

		-- update stack damages
		igniteTracker.frame.dmgList.update(target)
	else 
		-- our target doens't have ignite, ignore
		igniteTracker.frame:Hide();
	end

	igniteTracker.IgniteTrackLastTick = GetTime();
end)

function igniteTracker.init()

	BRH_config.igniteTracker = BRH_config.igniteTracker or { visible = false }

	-- visibility according to option
	if BRH_config.igniteTracker.visible then
		BRH.igniteTracker.main:Show();
	else
		BRH.igniteTracker.main:Hide()
	end
end

function igniteTracker.cmdHandle(msg)
	if (BRH_config.igniteTracker.visible) then
		BRH_config.igniteTracker.visible = false
		igniteTracker.main:Hide();
	else
		BRH_config.igniteTracker.visible = true
		igniteTracker.main:Show();
	end
end

SLASH_IGNITE1 = "/igniteTracker"
SlashCmdList["IGNITE"] = igniteTracker.cmdHandle