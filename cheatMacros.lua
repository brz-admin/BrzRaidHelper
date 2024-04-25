-- allow player to do some Macro to "cheat"
BRH.cheatMacro = {}
local macro = BRH.cheatMacro
local util = BRH.util
local parser = BRH.parser
local strlow = string.lower;

function macro.init() 
	BRH_config.amTank = BRH_config.amTank or false;
end
---------- LIP ROTA ----------
macro.LIPAOERota = {}
lipAOE = macro.LIPAOERota
lipAOE.canTaunt = true;
lipAOE.timer = nil;
lipAOE.annDone = false;
lipAOE.annTimer = nil
----------- FRAME ------------

lipAOE.frame = CreateFrame("Frame", "LIPAOE_Rotation")
lipAOE.frame:RegisterEvent("CHAT_MSG_ADDON");
lipAOE.frame:SetScript("OnUpdate", function() 
    if (not lipAOE.canTaunt) then
		if (lipAOE.timer ~= nil and lipAOE.timer <= GetTime()) then
			lipAOE.canTaunt = true;
		end
	end

	if (lipAOE.annTimer ~= nil and lipAOE.annTimer <= GetTime()) then
		lipAOE.annDone = false
		lipAOE.annTimer = nil
	end
end)

lipAOE.frame:SetScript("OnEvent", function() 
    local sender = arg4
    local data = util.strsplit(";;;", arg2)
	local cmd = data[1]
	local datas = data[2]

    if (cmd == "LIPROTA" and BRH.pName ~= sender) then
        lipAOE.canTaunt = false;
        lipAOE.timer = GetTime() + 6;
        return;
    end

end)

lipAOE.Handle = function(msg)

    if (UnitMana("Player") < 10) then 
        util.print("Not enought Rage for AOE taunt.")
        return;
    end

	local lipBag, lipSlot = util.GetItemInBag("Limited Invulnerability", "invulnérabilité limité")
    local haveLIP = (lipBag ~= nil and lipSlot ~= nil);
	if (not haveLIP) then
        util.print("Warning : You don't have any LIP in bag !!")
    end

	if (lipAOE.canTaunt) then

		if (haveLIP) then 
		    UseContainerItem(lipBag, lipSlot);
        end

		if (GetLocale() == "frFR") then
			CastSpellByName("Cri de défi")
		else
			CastSpellByName("Challenging Shout")
		end
		
		local chats = { "SAY", "YELL", "RAID_WARNING"}
		if not lipAOE.annDone then
			for idx, chatType in ipairs(chats) do
				SendChatMessage("-->> AOE TAUNT \124cfffc6c6c"..string.upper(UnitName('player')).."\124r <<--", chatType)
				if not haveLIP then SendChatMessage("-->> NO LIP PLS HEAL  <<--", chatType) end
			end

			lipAOE.annDone = true
			lipAOE.annTimer = GetTime() + 20;
		end

		util.addonCom("LIPROTA", "");
	end
end

SLASH_LIPAOE1  = "/LipAOE"
SlashCmdList["LIPAOE"] = lipAOE.Handle

---------- Taunt if Can ----------
-- Allow warriors to use taunt only if :
-- - ToT is not a tank ( warrior in group 1)
-- - Target is not taunted already

local function doTaunt()
	if (GetLocale() == "frFR") then
		CastSpellByName("Provocation")
	else
		CastSpellByName("Taunt")
	end
end

function macro.tauntIfCan()

	-- if no target just stop here
	if (UnitName("target") == nil) then return end;

	local TargetOfTarget = UnitName("playertargettarget");

	-- we are ToT why should we bother
	if (TargetOfTarget == BRH.pName) then return end;

	-- no ToT so we can taunt anyway
	if (TargetOfTarget == nil) then doTaunt() return end;

	local isTaunted = false;
	for i=1,16 do
		debuffTexture, debuffApplications = UnitDebuff("target", i);
		if (debuffTexture ~= nil and strlow(debuffTexture) == strlow("interface\\icons\\spell_nature_reincarnation")) then
			isTaunted = true;
		end
	end

	local totIsTank = false;
	for raidIndex=1, MAX_RAID_MEMBERS do
		local name, _, subgroup, _, pClass = GetRaidRosterInfo(raidIndex);
		if (name ~= nil) then
			-- if Taunted and ToT is Tank ( warrior from G1 ) do not taunt
			if (name == TargetOfTarget and subgroup == 1 and strlow(pClass) == "warrior") then
				totIsTank = true;
			end
		end
	end

	-- not taunted so it's ok
	if (not isTaunted and not totIsTank) then
		doTaunt();
	end
end

SLASH_TAUNTIFCAN1 = "/TauntIfCan"
SlashCmdList["TAUNTIFCAN"] = macro.tauntIfCan


---------- SPAM PETRI ----------

--- Allow player to spam Flask of Petrification without risking removeing it
function macro.spamPetri(msg)
	local petribuff = util.hasBuffByIcon("INV_Potion_26")
	local petriBag, petriSlot = util.GetItemInBag("Flask of Petrification", "Flacon de pétrification")
	if (petriBag ~= nil and petriSlot ~= nil) then
		petriBag, petriSlot = util.GetItemInBag("Flask of Petrification", "Potion de pétrification") -- just because Any broke the game
		if (petriBag == nil or petriSlot == nil) then util.print("Flask of Petrification not found in bag.") return end;
		if (not petribuff) then
			UseContainerItem(petriBag, petriSlot);
		end
	else
		util.print("Flask of Petrification not found in bag.")
	end
end

SLASH_SPAMPETRI1 = "/petri"
SlashCmdList["SPAMPETRI"] = macro.spamPetri

---------- DUMP AGGRO ----------
--- Allow player to automatically use Flask of Petrification if too high on aggro or having aggro
--- usefull for DPS players

function macro.doPetriIfTooHigh()
	-- no klhtm so we can't do anyway
	if (klhtm == nil) then return end
	local data, count, threat100 = KLHTM_GetRaidData()

	-- only one in Threatlist or first isn't us ? skip
	if (count < 2 or data[1].name ~= BRH.pName) then return end

	local threshold = 1.15
	if (BRH.pClass == "WARRIOR" or BRH.pClass == "ROGUE" or BRH.pClass == "DRUID") then
		threshold = 1.05
	end
	
	if (data[1].threat == threat100) -- we are tanking wtf ?
		or (data[1].threat > threshold) -- we are a bit high
		then macro.spamPetri() end
end

SLASH_DUMPAGGRO1 = "/dumpAggro"
SlashCmdList["DUMPAGGRO"] = macro.doPetriIfTooHigh


---------- HS SPAM (Warrior) ----------

function macro.spamHS()
	if (st_timer == nil) then return end;
	local bloodthirstCD = BRH.util.getSpellCD(BRH.BS["Bloodthirst"]);
	local isExecutable = UnitHealth("target")/UnitHealthMax("target") < 0.2
	local isWorldBoss = UnitClassification("target") == "worldboss"

	if (isWorldBoss and isExecutable and st_timer < 0.25) then
		SpellStopCasting(); 
	elseif (UnitMana("player") < 45 and (st_timer < 0.25 or bloodthirstCD < 1.5)) then
		SpellStopCasting(); 
	else 
		CastSpellByName(BRH.BS["Heroic Strike"]);
	end
end

SLASH_SPAMHS1 = "/spamHS"
SlashCmdList["SPAMHS"] = macro.spamHS