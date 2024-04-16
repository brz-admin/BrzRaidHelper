BRH.raidHelper = {}
local RH = BRH.raidHelper
local util = BRH.util
local parser = BRH.parser

strlow = string.lower;
local playerName = UnitName("player");

-------- SAPPER COUNT DOWN -----------

-- This module allow simultaneous cast of Sapper while stopping parsing from addons in order to diminish game freezes
RH.sapperCoolDown = {}
local scd = RH.sapperCoolDown

scd.canCast = false;
scd.startCountDown = false;
scd.countDown = 0;
scd.sapperPos = {
	["bag"] = nil,
	["slot"] = nil,
};

function scd.GetSapper()
	scd.sapperPos.bag, scd.sapperPos.slot = util.GetItemInBag("Sapper", "sapeur")
end

-- Already get the sapper position
scd.GetSapper();

function scd.doStartCountdown(timeInSec)
	scd.GetSapper();
	scd.startCountDown = true;
	scd.countDown = GetTime() + timeInSec;
	util.unregAddons()
end

scd.frame = CreateFrame("Frame", "BRH_SapperCountDown")
scd.frame:RegisterEvent("CHAT_MSG_ADDON");

scd.frame:SetScript("OnEvent", function() 
    local sender = arg4
    local data = util.strsplit(";;;", arg2)
	local cmd = data[1]
	local datas = data[2]

    if (cmd == "start" and util.PlayerIsPromoted(sender)) then
        scd.doStartCountdown(datas);
    end

end)

scd.frame:SetScript("OnUpdate", function() 
    if (scd.startCountDown) then
		if (scd.countDown + 3 <= GetTime() ) then
			scd.canCast = false;
			util.regAddons()
			scd.startCountDown = false;
		elseif (countDown <= GetTime()) then
			scd.canCast = true;
		end
	end
end)

function scd.cmdHandle(msg)
	strsplit(" ", msg)
	local cmd = util.strsplit(" ", msg)[1]
	local arg = util.strsplit(" ", msg)[2]

	if cmd then
		if (strlow(cmd) == "start") then
			if (not arg) then
				util.print("You have to set a timer");
				return;
			end
			doStartCountdown(arg);
			util.addonCom("start", arg);
			if (BigWigsPulltimer ~= nil) then
				BigWigsPulltimer:BigWigs_PullCommand(arg)
			end
		elseif (strlow(cmd) == "sapper") then
			if (scd.canCast) then
				UseContainerItem(scd.sapperPos.bag, scd.sapperPos.slot);
			end
		else
			util.print("Commands :\n/SCD start TIME\n/SCD sapper");
		end
	else
		util.print("Commands :\n/SCD start TIME\n/SCD sapper");
	end
end

SLASH_SCD1 = "/SCD"
SlashCmdList["SCD"] = scd.cmdHandle


-------- plsBop & plsInfu -----------
-- Allow Players in raid to ask for a BOP or an INFU and paladin/priest to cast it before casting anything else

---------- PLSINFU ----------
RH.plsInfu = {}
local plsInfu = RH.plsInfu
plsInfu.askedInfu = nil;
plsInfu.infuUpTimer = nil;

function plsInfu.Handle(msg)
	util.addonCom("plsInfu", msg)
end

local infu = "Power Infusion"
if GetLocale() == "frFR" then
	infu = "Infusion de puissance"	
end

function plsInfu.infuIfCan(msg)
	if (plsInfu.askedInfu ~= nil) then
		local infuCD = util.getSpellCD(infu)

		-- don't try to cast if it's on CD
		if (infuCD == nil) then return end;

		TargetByName(plsInfu.askedInfu, true);
		CastSpellByName(infu)
		TargetLastTarget();
		util.print("Infu envoyée sur "..askedInfu)
		plsInfu.askedInfu = nil;
		plsInfu.infuUpTimer = GetTime() + 180
	end
end

plsInfu.frame = CreateFrame("Frame", "BRH_plsInfu")
plsInfu.frame:RegisterEvent("CHAT_MSG_ADDON");
plsInfu.frame:SetScript("OnEvent", function() 
    local sender = arg4
    local data = util.strsplit(";;;", arg2)
	local cmd = data[1]
	local datas = data[2]

    if (cmd == "plsInfu" and datas == UnitName("Player")) then
        plsInfu.askedInfu = sender
        util.print(sender.." a demandé une infu !");
    end
end)

SlashCmdList["PLSINFU"] = plsInfu.Handle
SlashCmdList["INFUIFCAN"] = plsInfu.infuIfCan
SLASH_PLSINFU1 = "/plsInfu"
SLASH_INFUIFCAN1 = "/infuIfCan"

---------- PLSBOP ----------
RH.plsbop = {}
local plsbop = RH.plsbop

plsbop.askedBOP = nil;
plsbop.BOPUpTimer = nil;

function plsbop.Handle(msg)
	util.addonCom("plsBOP", msg)
end

local bop = "Blessing of Protection"
if GetLocale() == "frFR" then
	bop = "Bénédiction de protection"	
end

function plsbop.BOPIfCan(msg)
	if (plsbop.askedBOP ~= nil) then
		local bopCD = util.getSpellCD(bop)

		-- don't try to cast if it's on CD
		if (bopCD == nil) then return end;

		TargetByName(plsbop.askedBOP, true);
		CastSpellByName(bop)
		TargetLastTarget();
		plsbop.askedBOP = nil;
		plsbop.BOPUpTimer = GetTime() + 180
	end
end

plsbop.frame = CreateFrame("Frame", "BRH_plsBOP")
plsbop.frame:RegisterEvent("CHAT_MSG_ADDON");
plsbop.frame:SetScript("OnEvent", function() 
    local sender = arg4
    local data = util.strsplit(";;;", arg2)
	local cmd = data[1]
	local datas = data[2]

    if (cmd == "plsBOP" and datas == UnitName("Player")) then
        askedBOP = sender
        util.print(sender.." a demandé une BOP !")
    end

end)

SlashCmdList["PLSBOP"] = plsbop.Handle
SlashCmdList["BOPIFCAN"] = plsbop.BOPIfCan
SLASH_PLSBOP1 = "/plsbop"
SLASH_BOPIFCAN1 = "/BOPIfCan"


---------- Raid Helper ----------

---------- CHECK ----------
local hasAddon = 0;
local checkStop = 0;
local checking = false;
local raidMembers = {};

---------- LOOT VACUME ----------
local vacumeName = nil;
local vacumeLegend = nil;


--------- FRAMES ---------
BRH_RaidInfo = CreateFrame("Frame", "BRH_RaidInfo")
BRH_RaidInfo:ClearAllPoints();
BRH_RaidInfo:SetPoint("CENTER", "UIParent", "CENTER")
BRH_RaidInfo:RegisterEvent("CHAT_MSG_ADDON");
BRH_RaidInfo:RegisterEvent("START_LOOT_ROLL");
BRH_RaidInfo:RegisterEvent("CONFIRM_LOOT_ROLL");
--------- SCRIPTS ---------
BRH_RaidInfo:SetScript("OnUpdate", function() 

	if (infuUpTimer ~= nil and infuUpTimer <= GetTime()) then
		BRH.msgToAll("Infu de "..playerName.." Up !")
		infuUpTimer = nil;
	end

	if (BOPUpTimer ~= nil and BOPUpTimer <= GetTime()) then
		BRH.msgToAll("BOP de "..playerName.." Up !")
		BOPUpTimer = nil;
	end

	if (checking) then 
		if (checkStop <= GetTime()) then
			checking = false;
			local noAddon = "";
			for name, hasAddon in pairs(raidMembers) do
				if not hasAddon then
					noAddon = noAddon..name..", ";
				end
			end
			util.print(hasAddon.." Players in raid have the addon.")
			if (noAddon ~= "") then
				util.print("Players without it : "..noAddon);
			end
		end
	end

	if (engineerCheckTimer ~= nil) then
		if (engineerCheckTimer <= GetTime()) then
			engineerCheckTimer = nil;
			util.print("There is "..engineerNumber.." Engineers in the raid")
		end
	end



end)

BRH_RaidInfo:SetScript("OnEvent", function() 
	if (event == "CHAT_MSG_ADDON" and arg1 == BRH.syncPrefix) then
		BRH.HandleAddonMSG(arg4, arg2);
	elseif (event == "START_LOOT_ROLL") then
		if (vacumeName ~= nil) then
			local _, _, _, quality = GetLootRollItemInfo(arg1);
			if (strlow(UnitName("Player")) == strlow(vacumeName) and quality < 5) then
				RollOnLoot(arg1, 1);
			elseif (quality == 5 and strlow(UnitName("Player")) == strlow(vacumeLegend)) then
				RollOnLoot(arg1, 1);
			else
				RollOnLoot(arg1, 0);
			end
		end
	elseif (event == "CONFIRM_LOOT_ROLL") then
		if (vacumeName ~= nil) then
			local _, _, _, quality = GetLootRollItemInfo(arg1);
			if (strlow(UnitName("Player")) == strlow(vacumeName) and quality < 5) then
				ConfirmLootRoll(arg1, 1)
			end
		end
	end
end)
---------------------

-----FUNCTIONS-------



function BRH.msgToAll(msg)
	util.addonCom("msgToAll", msg);
end

function BRH.HandleAddonMSG(sender, data)
	local split = util.strsplit(";;;", data)
	local cmd = split[1]
	local datas = split[2]

if (checking and cmd == "okCheck") then
		raidMembers[sender] = true;
		if (datas ~= BRH.build) then
			outDated[sender] = datas;
			util.print(sender.." has outdated version "..datas)
		end
		hasAddon = hasAddon + 1;
		return;
	elseif (engineerCheckTimer ~= nil and cmd == "IamEngineer") then
		engineerNumber = engineerNumber + 1;
	elseif (cmd == "msgToAll") then
		util.print(datas);
	end

	-- commands below that can only be sent by promoted players
	if (not util.PlayerIsPromoted(sender)) then return end

	if (cmd == "Check") then
		util.addonCom("okCheck", BRH.build)
	elseif (cmd == "vacume") then
		if (datas == "") then
			vacumeName = nil
		else
			vacumeName = datas;
		end
	elseif (cmd == "vacumeLegend") then
		if (datas == "") then
			vacumeLegend = nil
		else
			vacumeLegend = datas;
		end
	elseif (cmd == "stopvacume") then
		vacumeName = nil
	elseif (cmd == "checkEngineer") then
		for skillIndex = 1, GetNumSkillLines() do 
			if (GetSkillLineInfo(skillIndex) == "Engineering" or GetSkillLineInfo(skillIndex) == "Ingénierie") then
				util.addonCom("IamEngineer", "")
				return;
			end
		end
	end

end

local function BRHcmdHandle(msg)
	strsplit(" ", msg)
	local cmd = util.strsplit(" ", msg)[1]
	local arg = util.strsplit(" ", msg)[2]
	if cmd then
		if (IsRaidOfficer() or IsRaidLeader()) then
			if (strlow(cmd) == "check") then
				if UnitInRaid("Player") then
					util.print("Checking who doesn't have the addon...")
					util.addonCom("Check", "");
					checkStop = GetTime() + 10;
					checking = true;
					hasAddon = 0;
					for raidIndex=1, MAX_RAID_MEMBERS do
						name, _, _, _, _, _, _, online = GetRaidRosterInfo(raidIndex);
						if (name and online ~= nil) then
							raidMembers[name] = false;
						end
					end
				end
			elseif (strlow(cmd) == "vacume" and strlow(arg) ~= nil) then
				vacumeName = arg;
				util.addonCom(cmd, arg);
				SetLootMethod("group", 1);
				util.print(arg.." est maintenant l'aspirateur à loots !")
			elseif (strlow(cmd) == "vacumelegend" and strlow(arg) ~= nil) then
				vacumeLegend = arg;
				util.addonCom(cmd, arg);
				util.print(arg.." prendra les loots légendaires !")
			elseif (strlow(cmd) == "stopvacume") then
				vacumeName = nil;
				util.addonCom(cmd, "");
				SetLootMethod("freeforall");
				util.print("Aspirateur à loot arrêté !")
			elseif (strlow(cmd) == "checkinge") then
				util.print("Checking Engineer number...")
				util.addonCom("checkEngineer", "")
				engineerCheckTimer = GetTime() + 10;
				engineerNumber = 0;
			end
		end
	end
end






SLASH_BRH1 = "/BRH"
SlashCmdList["BRH"] = BRHcmdHandle