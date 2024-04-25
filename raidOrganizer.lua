local util = BRH.util

-- Useful icons coords
CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS or {
	["WARRIOR"]     = {0, 0.25, 0, 0.25},
	["MAGE"]        = {0.25, 0.49609375, 0, 0.25},
	["ROGUE"]       = {0.49609375, 0.7421875, 0, 0.25},
	["DRUID"]       = {0.7421875, 0.98828125, 0, 0.25},
	["HUNTER"]      = {0, 0.25, 0.25, 0.5},
	["SHAMAN"]      = {0.25, 0.49609375, 0.25, 0.5},
	["PRIEST"]      = {0.49609375, 0.7421875, 0.25, 0.5},
	["WARLOCK"]     = {0.7421875, 0.98828125, 0.25, 0.5},
	["PALADIN"]     = {0, 0.25, 0.5, 0.75},
	["DEATHKNIGHT"] = {0.25, .5, 0.5, .75},
	["GM"]          = {0.5, 0.73828125, 0.5, .75},
  }

-- module initialisation
BRH.VanillaRaidOrganizer = {};
local vro = BRH.VanillaRaidOrganizer

vro.syncPrefix = "VRO_Sync"

-- used fonction pre-loading, faster they say
strlow = string.lower;
strfor = string.format;
tinsert = table.insert;
GetRaidRosterInfo = GetRaidRosterInfo;
SwapRaidSubgroup = SwapRaidSubgroup;

-- module variables
vro.dbug = false;
vro.dbuglvl = 3;
vro.assignedPlayers = {};
vro.CurrentSetup = nil;
vro.gui = {}
vro.gui.selected = nil;
if (vro.gui.groups == nil) then
	vro.gui.groups = {}
	for g = 1,8 do
		vro.gui.groups[g] = {}
		for p = 1,5 do
			vro.gui.groups[g][p] = {
				["sign"] = 0,
				["class"] = nil,
				["role"] = nil,
				["name"] = nil,
			}
		end
	end
end

vro.CurrentRoster = nil;
vro.roleList = {
	["tank"] = nil,
	["heal"] = nil,
	["melee"] = nil,
	["range"] = nil,
	["caster"] = nil,
};

---------- UTIL ----------
function vro.dLog(msg, lvl, force)
	force = force or false;
	lvl = lvl or 3;
	if (vro.dbug and lvl <= vro.dbuglvl) or force then
		util.print("DEBUG_RAIDORG: "..msg)
	end
end

function vro.tprint(tab)
	for key, value in pairs(tab) do
		if value then value = 1 else value = 0 end
		vro.dLog(key.."="..value, 3);
	end
end

function vro.print(msg)
	util.print("RaidOrg: "..msg)
end

--------- FRAMES ---------

VRO_MainFrame = CreateFrame("Frame", "VRO_MainFrame", FriendsFrame)
VRO_MainFrame:SetPoint("LEFT", "FriendsFrame", "RIGHT", -20, 25)
VRO_MainFrame:SetWidth(250)
VRO_MainFrame:SetHeight(340)
VRO_MainFrame:SetScale(1.25)
VRO_MainFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 5});
VRO_MainFrame:SetBackdropColor(0,0,0,0.7);


VRO_MainFrame_Title = CreateFrame("Frame", "VRO_MainFrame_Title", VRO_MainFrame);
VRO_MainFrame_Title:SetPoint("TOP", "VRO_MainFrame", 0, -0);
VRO_MainFrame_Title:SetPoint("LEFT", "VRO_MainFrame", 0, -0);
VRO_MainFrame_Title:SetPoint("RIGHT", "VRO_MainFrame", 0, -0);
VRO_MainFrame_Title:SetHeight(20);

VRO_MainFrame_Title_text = VRO_MainFrame_Title:CreateFontString("VRO_MainFrame_Title", "ARTWORK", "GameFontWhite")
VRO_MainFrame_Title_text:SetPoint("TOP", "VRO_MainFrame_Title", 0, -5);
VRO_MainFrame_Title_text:SetText("Raid Organiser");
VRO_MainFrame_Title_text:SetFont("Fonts\\FRIZQT__.TTF", 10)
VRO_MainFrame_Title_text:SetTextColor(0.5, 1, 1, 1);

VRO_MainFrame_Menu = CreateFrame("Frame", "VRO_MainFrame_Menu", VRO_MainFrame);
VRO_MainFrame_Menu:SetPoint("TOP", "VRO_MainFrame_Title", "BOTTOM", 0, 0);
VRO_MainFrame_Menu:SetPoint("LEFT", "VRO_MainFrame", 0, -0);
VRO_MainFrame_Menu:SetPoint("RIGHT", "VRO_MainFrame", 0, -0);
VRO_MainFrame_Menu:SetHeight(30)
VRO_MainFrame_Menu:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 5});
VRO_MainFrame_Menu:SetBackdropColor(0,0,0,0.7);

VRO_MainFrame_Save = CreateFrame("Frame", "VRO_MainFrame_Save", VRO_MainFrame);
VRO_MainFrame_Save:SetPoint("TOPRIGHT", "VRO_MainFrame", "BOTTOMRIGHT", 0, 0);
VRO_MainFrame_Save:SetHeight(20);
VRO_MainFrame_Save:SetWidth(100);
VRO_MainFrame_Save:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 5});
VRO_MainFrame_Save:SetBackdropColor(0,0,0,0.7);
VRO_MainFrame_Save:Show();

VRO_MainFrame_Save.EditBox = CreateFrame("EditBox", "VRO_MainFrame_Save_EditBox", VRO_MainFrame_Save)
VRO_MainFrame_Save.EditBox:SetPoint("TOPLEFT", VRO_MainFrame_Save, "TOPLEFT", 2.5,-2.5);
VRO_MainFrame_Save.EditBox:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 5});
VRO_MainFrame_Save.EditBox:SetBackdropColor(0,0,0,0.7);
VRO_MainFrame_Save.EditBox:SetWidth(67.5)
VRO_MainFrame_Save.EditBox:SetHeight(15)
VRO_MainFrame_Save.EditBox:SetAutoFocus(false)
VRO_MainFrame_Save.EditBox:SetMaxLetters(20)
VRO_MainFrame_Save.EditBox:SetFontObject(GameFontWhite)
VRO_MainFrame_Save.EditBox:SetFont("Fonts\\FRIZQT__.TTF", 8)
VRO_MainFrame_Save.EditBox:Hide()
VRO_MainFrame_Save.EditBox:SetScript("OnEnterPressed", function() 
	VRO_MainFrame_Save.Button:Click();
end)
VRO_MainFrame_Save.EditBox:SetScript("OnEscapePressed", function() 
	this:ClearFocus()
end)
VRO_MainFrame_Save.EditBox:SetScript("OnTabPressed", function() 
	this:ClearFocus()
end)

VRO_MainFrame_Save.Button = CreateFrame("Button", "VRO_MainFrame_Save_Button", VRO_MainFrame_Save);
VRO_MainFrame_Save.Button:SetFont("Fonts\\FRIZQT__.TTF", 8)
VRO_MainFrame_Save.Button:SetTextColor(1, 1, 1, 1);
VRO_MainFrame_Save.Button:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 5});
VRO_MainFrame_Save.Button:SetBackdropColor(0,0,0,0.7);
VRO_MainFrame_Save.Button:SetPoint("RIGHT", VRO_MainFrame_Save, "RIGHT", -2.5,0);
VRO_MainFrame_Save.Button:SetWidth(25)
VRO_MainFrame_Save.Button:SetHeight(15)
VRO_MainFrame_Save.Button:SetText("Save")
VRO_MainFrame_Save.Button:SetFrameStrata("DIALOG")
VRO_MainFrame_Save.Button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
VRO_MainFrame_Save.Button:Hide();
VRO_MainFrame_Save.Button:SetScript("OnClick", function () 
	if vro.saveCurrentSet(VRO_MainFrame_Save.EditBox:GetText()) then
		vro.gui.selected = VRO_MainFrame_Save.EditBox:GetText()
		UIDropDownMenu_SetSelectedName(VRO_MainFrame_Menu_SetsDD, VRO_MainFrame_Save.EditBox:GetText(), VRO_MainFrame_Save.EditBox:GetText())
		VRO_MainFrame_Save.EditBox:SetText("")
		VRO_MainFrame_Save.EditBox:ClearFocus()
		VRO_MainFrame_Save.Button:Hide()
		VRO_MainFrame_Save.EditBox:Hide()
		VRO_MainFrame_Save.editButton:Show()
		VRO_MainFrame_Save.delButton:Show()
		vro.SetEditable(false);
	end
end)

VRO_MainFrame_Save.editButton = CreateFrame("Button", "VRO_MainFrame_Save_editButton", VRO_MainFrame_Save);
VRO_MainFrame_Save.editButton:SetFont("Fonts\\FRIZQT__.TTF", 8)
VRO_MainFrame_Save.editButton:SetTextColor(1, 1, 1, 1);
VRO_MainFrame_Save.editButton:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 5});
VRO_MainFrame_Save.editButton:SetBackdropColor(0,0,0,0.7);
VRO_MainFrame_Save.editButton:SetAllPoints(VRO_MainFrame_Save.EditBox)
VRO_MainFrame_Save.editButton:SetText("EDIT")
VRO_MainFrame_Save.editButton:SetFrameStrata("DIALOG")
VRO_MainFrame_Save.editButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
VRO_MainFrame_Save.editButton:SetScript("OnClick", function () 
	this:Hide()
	VRO_MainFrame_Save.delButton:Hide()
    VRO_MainFrame_Save.Button:Show()
    VRO_MainFrame_Save.EditBox:Show()
	if (vro.gui.selected ~= "Current") then
		VRO_MainFrame_Save.EditBox:SetText(vro.gui.selected)
	end
    vro.SetEditable(true);
end)

VRO_MainFrame_Save.delButton = CreateFrame("Button", "VRO_MainFrame_Save_editButton", VRO_MainFrame_Save);
VRO_MainFrame_Save.delButton:SetFont("Fonts\\FRIZQT__.TTF", 8)
VRO_MainFrame_Save.delButton:SetTextColor(1, 1, 1, 1);
VRO_MainFrame_Save.delButton:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 5});
VRO_MainFrame_Save.delButton:SetBackdropColor(0,0,0,0.7);
VRO_MainFrame_Save.delButton:SetAllPoints(VRO_MainFrame_Save.Button)
VRO_MainFrame_Save.delButton:SetText("DEL")
VRO_MainFrame_Save.delButton:SetFrameStrata("DIALOG")
VRO_MainFrame_Save.delButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
VRO_MainFrame_Save.delButton:SetScript("OnClick", function () 
    vro.delCurrentSet();
end)

VRO_MainFrame_Menu_SetsDD = CreateFrame("Frame", "VRO_MainFrame_Menu_SetsDD", VRO_MainFrame, "UIDropDownMenuTemplate")

function vro.init()
	
	BRH_RaidOrganizer = BRH_RaidOrganizer or {}
	BRH_RaidOrganizer.sets = BRH_RaidOrganizer.sets or {};
	BRH_RaidOrganizer.members = BRH_RaidOrganizer.members or {};
	BRH_RaidOrganizer.conf = BRH_RaidOrganizer.conf or {};
	BRH_RaidOrganizer.conf.show = BRH_RaidOrganizer.conf.show or false;

	if BRH_RaidOrganizer.conf.show then 
		VRO_MainFrame:Show() 
	else 
		VRO_MainFrame:Hide() 
	end

	if not BRH_RaidOrganizer.conf.riShow then
		VRO_RaidInfo:Hide();
	else
		VRO_RaidInfo:Show();
	end

	UIDropDownMenu_Initialize(VRO_MainFrame_Menu_SetsDD, function()
		UIDropDownMenu_AddButton({
			text="Current",
			checked=vro.gui.selected == "Current",
			func = function ()
				vro.gui.selected = "Current"
				vro.loadSetInGUI("Current")
				UIDropDownMenu_SetSelectedName(VRO_MainFrame_Menu_SetsDD, "Current", "Current")
			end
		})
		if (BRH_RaidOrganizer.sets and type(BRH_RaidOrganizer.sets) == "table") then
			for set,_ in pairs(BRH_RaidOrganizer.sets) do
				UIDropDownMenu_AddButton({
					text=set,
					checked=vro.gui.selected == set,
					arg1 = set,
					func = function (set)
						vro.gui.selected = set
						vro.loadSetInGUI(set)
						UIDropDownMenu_SetSelectedName(VRO_MainFrame_Menu_SetsDD, set, set)
					end
				})
			end
		end
		UIDropDownMenu_SetWidth(30, VRO_MainFrame_Menu_SetsDD)
		UIDropDownMenu_SetButtonWidth(30, VRO_MainFrame_Menu_SetsDD)
		UIDropDownMenu_SetText("Sets", VRO_MainFrame_Menu_SetsDD)
		VRO_MainFrame_Menu_SetsDD:SetPoint("LEFT", VRO_MainFrame_Menu, "LEFT", 10,0);
		VRO_MainFrame_Menu_SetsDD:SetHeight(20)
		VRO_MainFrame_Menu_SetsDD:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 5});
		VRO_MainFrame_Menu_SetsDD:SetBackdropColor(0,0,0,0.5);
		VRO_MainFrame_Menu_SetsDD:SetBackdropBorderColor(1, 1, 1, 1)
		VRO_MainFrame_Menu_SetsDDButton:SetAllPoints(VRO_MainFrame_Menu_SetsDD)
		VRO_MainFrame_Menu_SetsDDText:SetPoint("LEFT", VRO_MainFrame_Menu_SetsDD, "LEFT", 5, 0)
	end, "MENU"
	)
end


VRO_MainFrame_Menu_Loadbutton = CreateFrame("Button", "VRO_MainFrame_Menu_Loadbutton", VRO_MainFrame_Menu);
VRO_MainFrame_Menu_Loadbutton:SetText("Apply Set");
VRO_MainFrame_Menu_Loadbutton:SetFont("Fonts\\FRIZQT__.TTF", 8)
VRO_MainFrame_Menu_Loadbutton:SetTextColor(1, 1, 1, 1);
VRO_MainFrame_Menu_Loadbutton:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 5});
VRO_MainFrame_Menu_Loadbutton:SetBackdropColor(0,0,0,0.7);
VRO_MainFrame_Menu_Loadbutton:SetPoint("LEFT", VRO_MainFrame_Menu_SetsDD, "RIGHT", 10,0);
VRO_MainFrame_Menu_Loadbutton:SetWidth(50)
VRO_MainFrame_Menu_Loadbutton:SetHeight(20)
VRO_MainFrame_Menu_Loadbutton:SetFrameStrata("DIALOG")
VRO_MainFrame_Menu_Loadbutton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
VRO_MainFrame_Menu_Loadbutton:SetScript("OnClick", function () 
	if (vro.gui.selected and vro.gui.selected ~= "Current") then
		vro.sortRaid(vro.gui.selected);
	end
end)

VRO_MainFrame_Menu_CurrSetup_Text = VRO_MainFrame_Menu:CreateFontString("VRO_MainFrame_Menu", "ARTWORK", "GameFontWhite");
VRO_MainFrame_Menu_CurrSetup_Text:SetPoint("RIGHT", VRO_MainFrame_Menu,"RIGHT",-10,0);
VRO_MainFrame_Menu_CurrSetup_Text:SetText("No Raid setup")
VRO_MainFrame_Menu_CurrSetup_Text:SetFont("Fonts\\FRIZQT__.TTF", 8)
VRO_MainFrame_Menu_CurrSetup_Text:SetTextColor(1, 1, 1, 1);

VRO_MainFrame_Content_LEFT = CreateFrame("Frame", "VRO_MainFrame_Content_LEFT", VRO_MainFrame);
VRO_MainFrame_Content_LEFT:SetPoint("TOP",VRO_MainFrame_Menu,"BOTTOM", -10, 0)
VRO_MainFrame_Content_LEFT:SetPoint("BOTTOM", VRO_MainFrame, "BOTTOM", 0, 0);
VRO_MainFrame_Content_LEFT:SetPoint("LEFT", VRO_MainFrame, "LEFT", 0, 0);
VRO_MainFrame_Content_LEFT:SetWidth(VRO_MainFrame:GetWidth()/2)
VRO_MainFrame_Content_LEFT:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 5});
VRO_MainFrame_Content_LEFT:SetBackdropColor(0,0,0,0.25);

VRO_MainFrame_Content_RIGHT = CreateFrame("Frame", "VRO_MainFrame_Content_RIGHT", VRO_MainFrame);
VRO_MainFrame_Content_RIGHT:SetPoint("TOP",VRO_MainFrame_Menu,"BOTTOM", -10, 0)
VRO_MainFrame_Content_RIGHT:SetPoint("BOTTOM", VRO_MainFrame, "BOTTOM", 0, 0);
VRO_MainFrame_Content_RIGHT:SetPoint("LEFT", VRO_MainFrame_Content_LEFT, "RIGHT", 0, 0);
VRO_MainFrame_Content_RIGHT:SetWidth(VRO_MainFrame:GetWidth()/2)
VRO_MainFrame_Content_RIGHT:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 5});
VRO_MainFrame_Content_RIGHT:SetBackdropColor(0,0,0,0.25);

VRO_MainFrame_Content_group = {};
for group = 1, 8 do
	local side = math.mod(group, 2) ~= 0 and "LEFT" or "RIGHT"
	local parent = math.mod(group, 2) ~= 0 and VRO_MainFrame_Content_LEFT or VRO_MainFrame_Content_RIGHT
	local pheight = 290 --parent:GetHeight()
	local cheight = (pheight/4)-5
	local order = {
		[1] = 0,
		[2] = 0,
		[3] = 1,
		[4] = 1,
		[5]	= 2,
		[6]	= 2,
		[7] = 3,
		[8] = 3
	}
	local offst = (2.5+(2.5*(order[group]))+((order[group])*cheight))
	VRO_MainFrame_Content_group[group] = CreateFrame("Frame", "VRO_MainFrame_Content_G"..group, parent)
	VRO_MainFrame_Content_group[group]:SetPoint("TOPLEFT",parent,"TOPLEFT", 2.5, -offst)
	VRO_MainFrame_Content_group[group]:SetPoint("RIGHT",parent,"RIGHT", -2.5, 0)
	VRO_MainFrame_Content_group[group]:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 5});
	VRO_MainFrame_Content_group[group]:SetBackdropColor(0,0,0,0.25);
	VRO_MainFrame_Content_group[group]:SetHeight(cheight)
	VRO_MainFrame_Content_group[group].name = VRO_MainFrame_Content_group[group]:CreateFontString("VRO_MainFrame_Content_G"..group, "ARTWORK", "GameFontWhite")
	VRO_MainFrame_Content_group[group].name:SetPoint("TOP", VRO_MainFrame_Content_group[group],"TOP",0,0);
	VRO_MainFrame_Content_group[group].name:SetText("Group "..group)
	VRO_MainFrame_Content_group[group].name:SetFont("Fonts\\FRIZQT__.TTF", 8)
	VRO_MainFrame_Content_group[group].name:SetTextColor(1, 1, 1, 1);
	VRO_MainFrame_Content_group[group].player = {}
	for plyr = 1,5 do
		local poffst = plyr*(VRO_MainFrame_Content_group[group]:GetHeight()/6)

		VRO_MainFrame_Content_group[group].player[plyr] = CreateFrame("Frame", "VRO_MainFrame_Content_G"..group.."_P"..plyr, VRO_MainFrame_Content_group[group])
		VRO_MainFrame_Content_group[group].player[plyr]:SetPoint("TOPLEFT",VRO_MainFrame_Content_group[group],"TOPLEFT", 0, -poffst)
		VRO_MainFrame_Content_group[group].player[plyr]:SetPoint("RIGHT",VRO_MainFrame_Content_group[group],"RIGHT", 0, 0)
		VRO_MainFrame_Content_group[group].player[plyr]:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 5});
		VRO_MainFrame_Content_group[group].player[plyr]:SetBackdropColor(1,1,1,0.25);
		VRO_MainFrame_Content_group[group].player[plyr]:SetID(group*10+plyr);
		VRO_MainFrame_Content_group[group].player[plyr]:EnableMouse(false);
		VRO_MainFrame_Content_group[group].player[plyr]:SetHeight(VRO_MainFrame_Content_group[group]:GetHeight()/6)
		VRO_MainFrame_Content_group[group].player[plyr]:SetScript("OnDragStart", function() this:StartMoving() end);
		VRO_MainFrame_Content_group[group].player[plyr]:SetScript("OnDragStop", function() 
			local OGgp, OGpl;
			OGgp = tonumber(string.sub(tostring(this:GetID()),1,1));
			OGpl = tonumber(string.sub(tostring(this:GetID()),2,2));
			-- if the frame we move doesn't have a player we just don't do a thing
			if not this.nameBox:GetText() or this.nameBox:GetText() == "" then return end;
			local movedPlayer = this.nameBox:GetText();

			local TARgp, TARpl;
			for gp = 1,8 do
				for pl = 1,5 do
					if (VRO_MainFrame_Content_group[gp].player[pl]:GetName() ~= this:GetName() and MouseIsOver(VRO_MainFrame_Content_group[gp].player[pl])) then
						TARgp = tonumber(string.sub(tostring(VRO_MainFrame_Content_group[gp].player[pl]:GetID()),1,1));
						TARpl = tonumber(string.sub(tostring(VRO_MainFrame_Content_group[gp].player[pl]:GetID()),2,2));
					end
				end
			end

			if TARgp and TARpl then
				-- We should have the right datas or we stop here
				if (TARgp > 8 or TARgp < 1 or TARpl > 5 or TARpl < 1) then return end;

				-- If We get a name then we should swap, if we don't get any name then we just move the player
				if (VRO_MainFrame_Content_group[TARgp].player[TARpl].nameBox:GetText() and VRO_MainFrame_Content_group[TARgp].player[TARpl].nameBox:GetText() ~= "") then
					vro.SwapByName(VRO_MainFrame_Content_group[TARgp].player[TARpl].nameBox:GetText(), movedPlayer);
				else
					vro.MoveByName(movedPlayer, TARgp)
				end
			end

			local offst = OGpl*(VRO_MainFrame_Content_group[OGgp]:GetHeight()/6)
			this:SetPoint("TOPLEFT",VRO_MainFrame_Content_group[OGgp],"TOPLEFT", 0, -offst)
			this:StopMovingOrSizing();
			this:SetUserPlaced(false);
		end)
		VRO_MainFrame_Content_group[group].player[plyr].sign = CreateFrame("Button", "VRO_MainFrame_Content_G"..group.."_P"..plyr.."_SIGN", VRO_MainFrame_Content_group[group].player[plyr]);
		VRO_MainFrame_Content_group[group].player[plyr].sign:SetID(group*10+plyr);
		VRO_MainFrame_Content_group[group].player[plyr].sign:RegisterForClicks("LeftButtonDown");
		VRO_MainFrame_Content_group[group].player[plyr].sign:SetPoint("LEFT", VRO_MainFrame_Content_group[group].player[plyr], "LEFT", 0,0);
		VRO_MainFrame_Content_group[group].player[plyr].sign:SetWidth(VRO_MainFrame_Content_group[group]:GetHeight()/6)
		VRO_MainFrame_Content_group[group].player[plyr].sign:SetHeight(VRO_MainFrame_Content_group[group]:GetHeight()/6)
		VRO_MainFrame_Content_group[group].player[plyr].sign:SetFrameStrata("TOOLTIP")
		VRO_MainFrame_Content_group[group].player[plyr].sign.texture = VRO_MainFrame_Content_group[group].player[plyr].sign:CreateTexture("VRO_MainFrame_Content_G"..group.."_P"..plyr.."_SIGN_TEXTURE", "ARTWORK")
		VRO_MainFrame_Content_group[group].player[plyr].sign.texture:SetTexture(nil)
		VRO_MainFrame_Content_group[group].player[plyr].sign.texture:SetAllPoints(VRO_MainFrame_Content_group[group].player[plyr].sign);
		VRO_MainFrame_Content_group[group].player[plyr].sign:SetScript("OnClick", function() 
			gp = tonumber(string.sub(tostring(this:GetID()),1,1));
			pl = tonumber(string.sub(tostring(this:GetID()),2,2));
			if (this.texture:GetTexture() == nil and vro.returnFreeSign()) then
				local newSign = vro.returnFreeSign()
				vro.setSign(this.texture, newSign)
				vro.gui.groups[gp][pl].sign = newSign
			elseif (this.texture:GetTexture() and vro.gui.groups[gp][pl].sign == 8) then
				vro.gui.groups[gp][pl].sign = 0
				this.texture:SetTexture(nil)
			elseif (this.texture:GetTexture()) then
				for l=vro.gui.groups[gp][pl].sign+1,8 do
					if vro.nobodyHasSignInSetup(l) then
						vro.setSign(this.texture, l)
						vro.gui.groups[gp][pl].sign = l
						break;
					end
					if l == 8 then
						vro.gui.groups[gp][pl].sign = 0
						this.texture:SetTexture(nil)
					end
				end
			end
		end)

		VRO_MainFrame_Content_group[group].player[plyr].classIcon = CreateFrame("Button", "VRO_MainFrame_Content_G"..group.."_P"..plyr.."_CLASSICON", VRO_MainFrame_Content_group[group].player[plyr]);
		VRO_MainFrame_Content_group[group].player[plyr].classIcon:SetID(group*10+plyr);
		VRO_MainFrame_Content_group[group].player[plyr].classIcon:RegisterForClicks("LeftButtonDown");
		VRO_MainFrame_Content_group[group].player[plyr].classIcon:SetPoint("LEFT", VRO_MainFrame_Content_group[group].player[plyr].sign, "RIGHT", 0,0);
		VRO_MainFrame_Content_group[group].player[plyr].classIcon:SetWidth(VRO_MainFrame_Content_group[group]:GetHeight()/6)
		VRO_MainFrame_Content_group[group].player[plyr].classIcon:SetHeight(VRO_MainFrame_Content_group[group]:GetHeight()/6)
		VRO_MainFrame_Content_group[group].player[plyr].classIcon:SetFrameStrata("TOOLTIP")
		VRO_MainFrame_Content_group[group].player[plyr].classIcon:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 5});
		VRO_MainFrame_Content_group[group].player[plyr].classIcon:SetBackdropColor(0,0,0,0.25);
		VRO_MainFrame_Content_group[group].player[plyr].classIcon.texture = VRO_MainFrame_Content_group[group].player[plyr].classIcon:CreateTexture("VRO_MainFrame_Content_G"..group.."_P"..plyr.."_CLASSICON_TEXTURE", "OVERLAY")
		VRO_MainFrame_Content_group[group].player[plyr].classIcon.texture:SetTexture(nil)
		VRO_MainFrame_Content_group[group].player[plyr].classIcon.texture:SetAllPoints(VRO_MainFrame_Content_group[group].player[plyr].classIcon);
		VRO_MainFrame_Content_group[group].player[plyr].classIcon:SetScript("OnClick", function() 
			gp = tonumber(string.sub(tostring(this:GetID()),1,1));
			pl = tonumber(string.sub(tostring(this:GetID()),2,2));
			if (this.texture:GetTexture() ~= nil) then
				local className;
				if (vro.gui.groups[gp][pl].class == "WARRIOR") then
					className = "ROGUE"
				elseif (vro.gui.groups[gp][pl].class == "ROGUE") then
					className = "MAGE"
				elseif (vro.gui.groups[gp][pl].class == "MAGE") then
					className = "DRUID"
				elseif (vro.gui.groups[gp][pl].class == "DRUID") then
					className = "HUNTER"
				elseif (vro.gui.groups[gp][pl].class == "HUNTER") then
					className = "PRIEST"
				elseif (vro.gui.groups[gp][pl].class == "PRIEST") then
					className = "WARLOCK"
				elseif (vro.gui.groups[gp][pl].class == "WARLOCK") then
					if (UnitFactionGroup("player") == "Alliance") then
						className = "PALADIN"
					else
						className = "SHAMAN"
					end
				else 
					this.texture:SetTexture(nil);
					vro.gui.groups[gp][pl].class = nil
				end
				
				if className then
					vro.gui.groups[gp][pl].class = className;
					this.texture:SetTexCoord(CLASS_ICON_TCOORDS[className][1],CLASS_ICON_TCOORDS[className][2],CLASS_ICON_TCOORDS[className][3],CLASS_ICON_TCOORDS[className][4])
				end
			else
				
				if (not vro.gui.groups[gp]) then
					vro.gui.groups[gp] = {}
				end
	
				if (not vro.gui.groups[gp][pl]) then
					vro.gui.groups[gp][pl] = {}
				end
				
				vro.gui.groups[gp][pl].class = "WARRIOR";
				this.texture:SetTexture("Interface\\AddOns\\VanillaRaidOrg\\classicons")
				this.texture:SetTexCoord(CLASS_ICON_TCOORDS[vro.gui.groups[gp][pl].class][1],CLASS_ICON_TCOORDS[vro.gui.groups[gp][pl].class][2],CLASS_ICON_TCOORDS[vro.gui.groups[gp][pl].class][3],CLASS_ICON_TCOORDS[vro.gui.groups[gp][pl].class][4])
			end
		end)

		VRO_MainFrame_Content_group[group].player[plyr].nameBox = CreateFrame("EditBox", "VRO_MainFrame_Content_G"..group.."_P"..plyr.."_nameBox", VRO_MainFrame_Content_group[group].player[plyr]);
		VRO_MainFrame_Content_group[group].player[plyr].nameBox:SetID(group*10+plyr);
		VRO_MainFrame_Content_group[group].player[plyr].nameBox:SetPoint("LEFT", VRO_MainFrame_Content_group[group].player[plyr].classIcon, "RIGHT", 0,0);
		VRO_MainFrame_Content_group[group].player[plyr].nameBox:SetWidth(65)
		VRO_MainFrame_Content_group[group].player[plyr].nameBox:SetHeight(VRO_MainFrame_Content_group[group]:GetHeight()/6)
		VRO_MainFrame_Content_group[group].player[plyr].nameBox:SetAutoFocus(false)
		VRO_MainFrame_Content_group[group].player[plyr].nameBox:SetMaxLetters(20)
		VRO_MainFrame_Content_group[group].player[plyr].nameBox:SetFontObject(GameFontWhite)

		VRO_MainFrame_Content_group[group].player[plyr].nameBox:SetFont("Fonts\\FRIZQT__.TTF", 8)
		VRO_MainFrame_Content_group[group].player[plyr].nameBox:SetScript("OnEnterPressed", function()
			gp = tonumber(string.sub(tostring(this:GetID()),1,1));
			pl = tonumber(string.sub(tostring(this:GetID()),2,2));
			this:ClearFocus()
			if not (vro.gui.groups[gp]) then
				vro.gui.groups[gp] = {}
			end

			if not (vro.gui.groups[gp][pl]) then
				vro.gui.groups[gp][pl] = {}
			end

			vro.gui.groups[gp][pl].name = this:GetText()

			if (BRH_RaidOrganizer.members[vro.gui.groups[gp][pl].name]) then
				if BRH_RaidOrganizer.members[vro.gui.groups[gp][pl].name].role then
					vro.gui.groups[gp][pl].role = BRH_RaidOrganizer.members[vro.gui.groups[gp][pl].name].role
					VRO_MainFrame_Content_group[gp].player[pl].role:SetText(BRH_RaidOrganizer.members[vro.gui.groups[gp][pl].name].role)
				end

				if BRH_RaidOrganizer.members[vro.gui.groups[gp][pl].name].class then
					vro.gui.groups[gp][pl].class = BRH_RaidOrganizer.members[vro.gui.groups[gp][pl].name].class
					VRO_MainFrame_Content_group[gp].player[pl].classIcon.texture:SetTexture("Interface\\AddOns\\VanillaRaidOrg\\classicons")
					VRO_MainFrame_Content_group[gp].player[pl].classIcon.texture:SetTexCoord(CLASS_ICON_TCOORDS[vro.gui.groups[gp][pl].class][1],CLASS_ICON_TCOORDS[vro.gui.groups[gp][pl].class][2],CLASS_ICON_TCOORDS[vro.gui.groups[gp][pl].class][3],CLASS_ICON_TCOORDS[vro.gui.groups[gp][pl].class][4])
				end
			end
		end)
		VRO_MainFrame_Content_group[group].player[plyr].nameBox:SetScript("OnEscapePressed", function()
			gp = tonumber(string.sub(tostring(this:GetID()),1,1));
			pl = tonumber(string.sub(tostring(this:GetID()),2,2));
			if not (vro.gui.groups[gp]) then
				vro.gui.groups[gp] = {}
			end

			if not (vro.gui.groups[gp][pl]) then
				vro.gui.groups[gp][pl] = {}
			end
			this:ClearFocus()
			vro.gui.groups[gp][pl].name = this:GetText()
		end)
		VRO_MainFrame_Content_group[group].player[plyr].nameBox:SetScript("OnTabPressed", function()
			gp = tonumber(string.sub(tostring(this:GetID()),1,1));
			pl = tonumber(string.sub(tostring(this:GetID()),2,2));
			if not (vro.gui.groups[gp]) then
				vro.gui.groups[gp] = {}
			end

			if not (vro.gui.groups[gp][pl]) then
				vro.gui.groups[gp][pl] = {}
			end
			this:ClearFocus()
			vro.gui.groups[gp][pl].name = this:GetText()
			if (pl < 5) then
				VRO_MainFrame_Content_group[gp].player[pl+1].nameBox:SetFocus();
			elseif (pl == 5) and (gp < 8) then
				VRO_MainFrame_Content_group[gp+1].player[1].nameBox:SetFocus();
			end
		end)

		VRO_MainFrame_Content_group[group].player[plyr].role = CreateFrame("Button", "VRO_MainFrame_Content_G"..group.."_P"..plyr.."_ROLE", VRO_MainFrame_Content_group[group].player[plyr]);
		VRO_MainFrame_Content_group[group].player[plyr].role:SetID(group*10+plyr);
		VRO_MainFrame_Content_group[group].player[plyr].role:RegisterForClicks("LeftButtonDown");
		VRO_MainFrame_Content_group[group].player[plyr].role:SetPoint("LEFT", VRO_MainFrame_Content_group[group].player[plyr].nameBox, "RIGHT", 0,0);
		VRO_MainFrame_Content_group[group].player[plyr].role:SetWidth(35)
		VRO_MainFrame_Content_group[group].player[plyr].role:SetHeight(VRO_MainFrame_Content_group[group]:GetHeight()/6)
		VRO_MainFrame_Content_group[group].player[plyr].role:SetFrameStrata("TOOLTIP")
		VRO_MainFrame_Content_group[group].player[plyr].role:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 5});
		VRO_MainFrame_Content_group[group].player[plyr].role:SetBackdropColor(0,0,0,0.25);
		VRO_MainFrame_Content_group[group].player[plyr].role:SetFont("Fonts\\FRIZQT__.TTF", 8)
		VRO_MainFrame_Content_group[group].player[plyr].role:SetScript("OnClick", function() 
			gp = tonumber(string.sub(tostring(this:GetID()),1,1));
			pl = tonumber(string.sub(tostring(this:GetID()),2,2));

			if (not vro.gui.groups[gp]) then
				vro.gui.groups[gp] = {}
			end

			if (not vro.gui.groups[gp][pl]) then
				vro.gui.groups[gp][pl] = {}
			end

			if (vro.gui.groups[gp][pl].role) then
				if (vro.gui.groups[gp][pl].role == "tank") then
					this:SetText("melee")
					vro.gui.groups[gp][pl].role = "melee"
				elseif (vro.gui.groups[gp][pl].role == "melee") then
					this:SetText("range")
					vro.gui.groups[gp][pl].role = "range"
				elseif (vro.gui.groups[gp][pl].role == "range") then
					this:SetText("caster")
					vro.gui.groups[gp][pl].role = "caster"
				elseif (vro.gui.groups[gp][pl].role == "caster") then
					this:SetText("heal")
					vro.gui.groups[gp][pl].role = "heal"
				else
					this:SetText("")
					vro.gui.groups[gp][pl].role = nil
				end
			else
				vro.gui.groups[gp][pl].role = "tank"
				this:SetText("tank")
			end

			if vro.gui.groups[gp][pl].name and BRH_RaidOrganizer.members[vro.gui.groups[gp][pl].name] then
				BRH_RaidOrganizer.members[vro.gui.groups[gp][pl].name].role = vro.gui.groups[gp][pl].role
			end
		end)
	end
end
---------------------
VRO_RaidInfo = CreateFrame("Frame", "VRO_RaidInfo")
VRO_RaidInfo:ClearAllPoints();
VRO_RaidInfo:SetPoint("CENTER", "UIParent", "CENTER")
VRO_RaidInfo:SetWidth(100)
VRO_RaidInfo:SetHeight(50)
VRO_RaidInfo:SetScale(1)
VRO_RaidInfo:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeSize = 5});
VRO_RaidInfo:SetBackdropColor(0,0,0,0);
VRO_RaidInfo:SetMovable(true);
VRO_RaidInfo:RegisterForDrag("LeftButton");
VRO_RaidInfo:EnableMouse();
VRO_RaidInfo:SetScript("OnDragStart", function() this:StartMoving() end);
VRO_RaidInfo:SetScript("OnDragStop", function() this:StopMovingOrSizing() end);


VRO_RaidInfo_RaidHP_title = VRO_RaidInfo:CreateFontString("VRO_RaidInfo_RaidHP_title", "ARTWORK", "GameFontWhite")
VRO_RaidInfo_RaidHP_title:SetPoint("TOPLEFT", "VRO_RaidInfo", "TOPLEFT",  0, -5);
VRO_RaidInfo_RaidHP_title:SetText("R. Health :");
VRO_RaidInfo_RaidHP_title:SetFont("Fonts\\FRIZQT__.TTF", 10)
VRO_RaidInfo_RaidHP_title:SetTextColor(1, 1, 1, 1);
VRO_RaidInfo_RaidHP_number = VRO_RaidInfo:CreateFontString("VRO_RaidInfo_RaidHP_number", "ARTWORK", "GameFontWhite")
VRO_RaidInfo_RaidHP_number:SetPoint("TOPRIGHT", "VRO_RaidInfo", "TOPRIGHT", 0, -5);
VRO_RaidInfo_RaidHP_number:SetText(" ");
VRO_RaidInfo_RaidHP_number:SetFont("Fonts\\FRIZQT__.TTF", 10)
VRO_RaidInfo_RaidHP_number:SetTextColor(0, 1, 0, 1);

VRO_RaidInfo_HealMana_title = VRO_RaidInfo:CreateFontString("VRO_RaidInfo_HealMana_title", "ARTWORK", "GameFontWhite")
VRO_RaidInfo_HealMana_title:SetPoint("TOPLEFT", "VRO_RaidInfo_RaidHP_title", "BOTTOMLEFT",  0, -5);
VRO_RaidInfo_HealMana_title:SetText("H. Mana :");
VRO_RaidInfo_HealMana_title:SetFont("Fonts\\FRIZQT__.TTF", 10)
VRO_RaidInfo_HealMana_title:SetTextColor(1, 1, 1, 1);
VRO_RaidInfo_HealMana_number = VRO_RaidInfo:CreateFontString("VRO_RaidInfo_HealMana_number", "ARTWORK", "GameFontWhite")
VRO_RaidInfo_HealMana_number:SetPoint("TOPRIGHT", "VRO_RaidInfo_RaidHP_number", "BOTTOMRIGHT", 0, -5);
VRO_RaidInfo_HealMana_number:SetText(" ");
VRO_RaidInfo_HealMana_number:SetFont("Fonts\\FRIZQT__.TTF", 10)
VRO_RaidInfo_HealMana_number:SetTextColor(0, 1, 0, 1);

VRO_RaidInfo_CasterMana_title = VRO_RaidInfo:CreateFontString("VRO_RaidInfo_CasterMana_title", "ARTWORK", "GameFontWhite")
VRO_RaidInfo_CasterMana_title:SetPoint("TOPLEFT", "VRO_RaidInfo_HealMana_title", "BOTTOMLEFT",  0, -5);
VRO_RaidInfo_CasterMana_title:SetText("C. Mana :");
VRO_RaidInfo_CasterMana_title:SetFont("Fonts\\FRIZQT__.TTF", 10)
VRO_RaidInfo_CasterMana_title:SetTextColor(1, 1, 1, 1);
VRO_RaidInfo_CasterMana_number = VRO_RaidInfo:CreateFontString("VRO_RaidInfo_CasterMana_number", "ARTWORK", "GameFontWhite")
VRO_RaidInfo_CasterMana_number:SetPoint("TOPRIGHT", "VRO_RaidInfo_HealMana_number", "BOTTOMRIGHT", 0, -5);
VRO_RaidInfo_CasterMana_number:SetText(" ");
VRO_RaidInfo_CasterMana_number:SetFont("Fonts\\FRIZQT__.TTF", 10)
VRO_RaidInfo_CasterMana_number:SetTextColor(0, 1, 0, 1);


VRO_RaidInfo:SetScript("OnUpdate", function() 
	if not vro.CurrentRoster then
		vro.CurrentRoster = vro.getCurrentRaid()
	end
	--- Healers Mana
	local healers = vro.GetRoleList("heal")
	if healers then
		local healersMana, healersMaxMana = 0, 0;
		for _,datas in pairs(healers) do
			healersMana = healersMana + UnitMana("raid"..datas.raidIndex);
			healersMaxMana = healersMaxMana + UnitManaMax("raid"..datas.raidIndex);
		end
		if healersMaxMana ~= 0 then
			local hManaPerc = math.floor((healersMana/healersMaxMana) * 100)
			VRO_RaidInfo_HealMana_number:SetText(hManaPerc.."%");
			VRO_RaidInfo_HealMana_number:SetTextColor((1-(healersMana/healersMaxMana)), (healersMana/healersMaxMana), 0, 1);
		end
	else
		VRO_RaidInfo_HealMana_number:SetText("");
		VRO_RaidInfo_HealMana_number:SetTextColor(0, 1, 0, 1);
	end
	--- Casters Mana
	local casters = vro.GetRoleList("caster")
	local range = vro.GetRoleList("range")

	local castersMana, castersMaxMana = 0, 0;

	if casters then
		for _,datas in pairs(casters) do
			castersMana = castersMana + UnitMana("raid"..datas.raidIndex);
			castersMaxMana = castersMaxMana + UnitManaMax("raid"..datas.raidIndex);
		end
	end

	if range then
		for _,datas in pairs(range) do
			castersMana = castersMana + UnitMana("raid"..datas.raidIndex);
			castersMaxMana = castersMaxMana + UnitManaMax("raid"..datas.raidIndex);
		end
	end

	if castersMaxMana ~= 0 then
		local hManaPerc = math.floor((castersMana/castersMaxMana) * 100)
		VRO_RaidInfo_CasterMana_number:SetText(hManaPerc.."%");
		VRO_RaidInfo_CasterMana_number:SetTextColor((1-(castersMana/castersMaxMana)), (castersMana/castersMaxMana), 0, 1);
	else
		VRO_RaidInfo_CasterMana_number:SetText("");
		VRO_RaidInfo_CasterMana_number:SetTextColor(0, 1, 0, 1);
	end
	--- Raid Health
	local raidHealth, raidMaxHealth = 0,0
	for raidIndex=1, MAX_RAID_MEMBERS do
		raidHealth = raidHealth + UnitHealth("raid"..raidIndex);
		raidMaxHealth = raidMaxHealth + UnitHealthMax("raid"..raidIndex);
	end

	if raidMaxHealth ~= 0 then
		local raidHealthPerc = math.floor((raidHealth/raidMaxHealth) * 100)
		VRO_RaidInfo_RaidHP_number:SetText(raidHealthPerc.."%");
		VRO_RaidInfo_RaidHP_number:SetTextColor((1-(raidHealth/raidMaxHealth)), (raidHealth/raidMaxHealth), 0, 1);
	end
end)
---------------------
VRO_MainFrame:RegisterEvent("CHAT_MSG_ADDON");
VRO_MainFrame:RegisterEvent("RAID_ROSTER_UPDATE");
VRO_MainFrame:SetScript("OnEvent", function() 
	if (event == "CHAT_MSG_ADDON" and arg1 == vro.syncPrefix) then
		vro.HandleAddonMSG(arg4, arg2);
	elseif (event == "RAID_ROSTER_UPDATE") then
		for k,_ in pairs(vro.roleList) do
			vro.GetRoleList(k);
		end
		
		if vro.gui.selected == "Current" then
			vro.loadSetInGUI("Current")
		end
    end
 end)

-----FUNCTIONS-------

function vro.addonCom(comType, content)
	SendAddonMessage(vro.syncPrefix, comType..";;;"..content, "RAID")
end

function vro.HandleAddonMSG(sender, data)
	-- check if we accept the call
	if not util.PlayerIsPromoted(sender) or BRH.pName == sender or not IsRaidLeader() then return end
	-- separate the type of command of it's datas
	local split = util.strsplit(";;;", data)
	local cmd = split[1]
	local datas = split[2]

	if strlow(cmd) == "promote" then
		PromoteToAssistant(datas)
	elseif strlow(cmd) == "sendComp" then
		-- We are gonna recieve the comp with one msg by player
		-- message looks like this => COMPNAME:GROUP:PLAYERID:SIGN:CLASS:ROLE:NAME
		-- we split the message again to separate every info
		local dataSplit =  util.strsplit(":", datas)
		local compName = dataSplit[1]
		local group = dataSplit[2]
		local player = dataSplit[3]
		local sign = vro.nilIsNil(dataSplit[4])
		local class = vro.nilIsNil(dataSplit[5])
		local role = vro.nilIsNil(dataSplit[6])
		local name = vro.nilIsNil(dataSplit[7])

		if not BRH_RaidOrganizer.sets[compName] then
			BRH_RaidOrganizer.sets[compName] = {}
		end

		if not BRH_RaidOrganizer.sets[compName][group] then
			BRH_RaidOrganizer.sets[compName][group] = {}
		end

		BRH_RaidOrganizer.sets[compName][group][player] = {
			["sign"] = sign,
			["class"] = class,
			["role"] = role,
			["name"] = name,
		}
	end
end

function vro.SetEditable(editable)
    --editable = editable or true;

    for group=1,8 do
		for plyr=1,5 do
			if editable then
				VRO_MainFrame_Content_group[group].player[plyr].sign:Enable()
				VRO_MainFrame_Content_group[group].player[plyr].classIcon:Enable()
				VRO_MainFrame_Content_group[group].player[plyr]:RegisterForDrag();
				VRO_MainFrame_Content_group[group].player[plyr]:SetMovable(false);
			else
				VRO_MainFrame_Content_group[group].player[plyr].sign:Disable()
				VRO_MainFrame_Content_group[group].player[plyr].classIcon:Disable()
				VRO_MainFrame_Content_group[group].player[plyr]:RegisterForDrag("LeftButton");
				VRO_MainFrame_Content_group[group].player[plyr]:SetMovable(true);
			end
			VRO_MainFrame_Content_group[group].player[plyr].nameBox:EnableKeyboard(editable)
			VRO_MainFrame_Content_group[group].player[plyr].nameBox:EnableMouse(editable)
        end
    end
end
vro.SetEditable(false)

function vro.GetRoleList(thisRole, reset)

	if vro.roleList[thisRole] and not reset then
		return vro.roleList[thisRole]
	end

	if (reset) then
		for k in pairs(vro.roleList[thisRole]) do
			vro.roleList[thisRole][k] = nil
		end
	end

	if not vro.CurrentRoster then
		vro.CurrentRoster = vro.getCurrentRaid()
	end

	if not vro.roleList[thisRole] then
		vro.roleList[thisRole] = {};
	end

	if vro.CurrentRoster then
		for groupe,members in pairs(vro.CurrentRoster) do	
			for member,data in pairs(members) do
				if type(data) == "table" then
				 	if data.role == thisRole then
						tinsert(vro.roleList[thisRole], {
							["name"] = data.name,
							["raidIndex"] = data.raidIndex
						});
					end
				end
			end
		end
		return vro.roleList[thisRole];
	end
	return nil;
end

function vro.nilIsNil(val)
	if val == "nil" then
		return nil
	else
		return val
	end
end

function vro.RemoveByName(pName)
	local raid = vro.getCurrentRaid()
   
    for group,members in pairs(raid) do
        for member,datas in pairs(members) do
            if strlow(datas.name) == strlow(pName) then idx = datas.raidIndex end
        end
    end
    
	if idx then 
		UninviteFromRaid(idx) 
	end
end

function vro.SwapByName(name1, name2)
    local idx1, idx2;
    for group,members in pairs(vro.getCurrentRaid()) do
        for member,datas in pairs(members) do
			if type(datas) == "table" then
				if strlow(datas.name) == strlow(name1) then idx1 = datas.raidIndex
				elseif strlow(datas.name) == strlow(name2) then idx2 = datas.raidIndex
				end
			end
        end
    end
    
    if idx1 and idx2 then
		SwapRaidSubgroup(idx1, idx2)
	end
end

function vro.MoveByName(pName, group)
    local raid = vro.getCurrentRaid()
    if raid[group] and raid[group].full then return end
   
    for group,members in pairs(raid) do
		for member,datas in pairs(members) do
			if type(datas) == "table" then
				if datas.name then
					if strlow(datas.name) == strlow(pName) then idx = datas.raidIndex end
				end
			end
        end
    end
    
	if idx then 
		SetRaidSubgroup(idx, group) 
	end
end

function vro.WypeGui()
	if (vro.gui.groups) then
		for g = 1,8 do
			vro.gui.groups[g] = {}
			for p = 1,5 do
				vro.gui.groups[g][p] = {
					["sign"] = 0,
					["class"] = nil,
					["role"] = nil,
					["name"] = nil,
				}

				VRO_MainFrame_Content_group[g].player[p].sign.texture:SetTexture(nil)
				VRO_MainFrame_Content_group[g].player[p].classIcon.texture:SetTexture(nil)
				VRO_MainFrame_Content_group[g].player[p].nameBox:SetText("")
				VRO_MainFrame_Content_group[g].player[p].role:SetText("")
			end
		end
	end
	
end

function vro.nobodyHasSignInSetup(signID)
	for g=1,8 do
		if vro.gui.groups[g] then
			for p=1,5 do
				if vro.gui.groups[g][p] and vro.gui.groups[g][p].sign and vro.gui.groups[g][p].sign == signID then return false end
			end
		end
	end
	return true;
end

function vro.returnFreeSign()
	for s=1,8 do
		if (vro.nobodyHasSignInSetup(s)) then
			return s;
		end
	end
	return nil;
end

function vro.setSign(texture, signID)
	if (signID and signID > 0 and signID < 9) then
		texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
		if (signID == 1) then texture:SetTexCoord(0,0.25,0,0.25)
		elseif (signID == 2) then texture:SetTexCoord(0.25,0.50,0,0.25)
		elseif (signID == 3) then texture:SetTexCoord(0.50,0.75,0,0.25)
		elseif (signID == 4) then texture:SetTexCoord(0.75,1.00,0,0.25)
		elseif (signID == 5) then texture:SetTexCoord(0.00,0.25,0.25,0.50)
		elseif (signID == 6) then texture:SetTexCoord(0.25,0.50,0.25,0.50)
		elseif (signID == 7) then texture:SetTexCoord(0.50,0.75,0.25,0.50)
		elseif (signID == 8) then texture:SetTexCoord(0.75,1.00,0.25,0.50)
		end
	end
end

function vro.loadSetInGUI(set)
	vro.WypeGui();
	set = set or "Current";

	vro.dLog(set, 3)
	if set == "Current" then
		vro.gui.groups = vro.getCurrentRaid()
	else
		vro.gui.groups = {}
		for g=1,8 do
			if (BRH_RaidOrganizer.sets[set][g]) then
				vro.gui.groups[g] = {}
				for p=1,5 do
					if (BRH_RaidOrganizer.sets[set][g][p]) then
						vro.gui.groups[g][p] = {}
						vro.gui.groups[g][p].sign = BRH_RaidOrganizer.sets[set][g][p].sign
						vro.gui.groups[g][p].class = BRH_RaidOrganizer.sets[set][g][p].class
						vro.gui.groups[g][p].name = BRH_RaidOrganizer.sets[set][g][p].name
						vro.gui.groups[g][p].role = BRH_RaidOrganizer.sets[set][g][p].role
					end
				end
			end
		end
	end

	for group=1,8 do
		for player=1,5 do
			if (vro.gui.groups[group] and vro.gui.groups[group][player] and type(vro.gui.groups[group][player]) == "table") then
				if vro.gui.groups[group][player].sign then
					vro.setSign(VRO_MainFrame_Content_group[group].player[player].sign.texture, vro.gui.groups[group][player].sign)
				end

				if vro.gui.groups[group][player].class then
					VRO_MainFrame_Content_group[group].player[player].classIcon.texture:SetTexture("Interface\\AddOns\\VanillaRaidOrg\\classicons")
					VRO_MainFrame_Content_group[group].player[player].classIcon.texture:SetTexCoord(CLASS_ICON_TCOORDS[vro.gui.groups[group][player].class][1],CLASS_ICON_TCOORDS[vro.gui.groups[group][player].class][2],CLASS_ICON_TCOORDS[vro.gui.groups[group][player].class][3],CLASS_ICON_TCOORDS[vro.gui.groups[group][player].class][4])
				end

				if vro.gui.groups[group][player].name then
					VRO_MainFrame_Content_group[group].player[player].nameBox:SetText(vro.gui.groups[group][player].name)
				end

				if vro.gui.groups[group][player].role then
					VRO_MainFrame_Content_group[group].player[player].role:SetText(vro.gui.groups[group][player].role)
				end
			end
			if set == "Current" and (IsRaidLeader() or IsRaidOfficer()) then
				if (VRO_MainFrame_Content_group[group].player[player].nameBox:GetText() ~= nil and VRO_MainFrame_Content_group[group].player[player].nameBox:GetText() ~= "") then
					VRO_MainFrame_Content_group[group].player[player]:RegisterForDrag("LeftButton");
					VRO_MainFrame_Content_group[group].player[player]:EnableMouse(true);
					VRO_MainFrame_Content_group[group].player[player]:SetMovable(true);
				else
					VRO_MainFrame_Content_group[group].player[player]:RegisterForDrag();
					VRO_MainFrame_Content_group[group].player[player]:SetMovable(false);
					VRO_MainFrame_Content_group[group].player[player]:EnableMouse(false);
				end
			end
		end
	end

	VRO_MainFrame_Save.EditBox:SetText("")
	VRO_MainFrame_Save.EditBox:ClearFocus()
	VRO_MainFrame_Save.Button:Hide()
	VRO_MainFrame_Save.EditBox:Hide()
	VRO_MainFrame_Save.editButton:Show()
	VRO_MainFrame_Save.delButton:Show()
	vro.SetEditable(false);
	
end
--------------------------
function vro.getCurrentRaid()
    local roster = {};
    
    local groupIndex = {
        [1] = 1,
        [2] = 1,
        [3] = 1,
        [4] = 1,
        [5] = 1,
        [6] = 1,
        [7] = 1,
        [8] = 1
	}
	
	if BRH_RaidOrganizer.members == nil  then
		BRH_RaidOrganizer.members = {}
	end

    for raidIndex=1, MAX_RAID_MEMBERS do
    	name, rank,subgroup, _, _, class, _, _, _ = GetRaidRosterInfo(raidIndex);
		if name and rank and subgroup and class then 
			vro.assignedPlayers[name] = false;
			if not roster[subgroup] then
				roster[subgroup] = {}
			end

			roster[subgroup][groupIndex[subgroup]] = {
					["raidIndex"] = raidIndex,
					["name"] = name,
					["class"] = class,
					["rank"] = rank,
					["sign"] = GetRaidTargetIndex("raid"..raidIndex),
				}

			vro.dLog(name.."("..class..") -> "..subgroup.."("..groupIndex[subgroup]..") = "..raidIndex, 2);
			
			-- role assignement
			-- tank, heal, melee, caster, not sure if I should put equi/feral and co...
			if (BRH_RaidOrganizer.members and BRH_RaidOrganizer.members[name] ~= nil) then
				-- take last assigned role, usualy doesn't change
				roster[subgroup][groupIndex[subgroup]].role = BRH_RaidOrganizer.members[name].role
			else
				-- We are assuming basic roles
				if class == "PRIEST" or class == "PALADIN" or class == "DRUID" or class == "SHAMAN" then
					roster[subgroup][groupIndex[subgroup]].role = "heal";
				elseif class == "WARRIOR" or class == "ROGUE" then
					roster[subgroup][groupIndex[subgroup]].role = "melee";
				elseif class == "HUNTER" then 
				    roster[subgroup][groupIndex[subgroup]].role = "range";
				else
					roster[subgroup][groupIndex[subgroup]].role = "caster";
				end

				BRH_RaidOrganizer.members[name] = {
					["class"] = class,
					["role"] = roster[subgroup][groupIndex[subgroup]].role,
				}
			end
			
			groupIndex[subgroup] = groupIndex[subgroup] +1;
			if groupIndex[subgroup] == 6 then
				roster[subgroup].full = true;
				vro.dLog(strfor("%d is full", subgroup));
			end
		end
    end
    return roster;
end

function vro.getPlayerByName(roster, pName)
	vro.dLog("vro.getPlayerByName : "..pName)
	for group,members in pairs(roster) do 
		for member,datas in pairs(members) do
			if type(datas) == "table" then
				if strlow(datas.name) == strlow(pName) then
					vro.dLog(strfor("%s found as raidIndex %d", pName, datas.raidIndex))
					return datas.raidIndex
				end
			end
		end

	end
	vro.dLog(strfor("%s was not found", pName))
	return nil
end

function vro.getUnAssignedPlayerInGroup(group)
	vro.dLog("getUnassignedPlayerInGroup")
	for member, datas in pairs(vro.CurrentRoster[group]) do
		if type(datas) == "table" then
			if datas.raidIndex and not vro.assignedPlayers[data.name] then
				vro.dLog(strfor("%s(%d) not assigned",datas.name, datas.raidIndex))
				return datas.raidIndex; 
			end
		end
	end
	vro.dLog("no unassigned player in group, skip")
	return nil;
end

function vro.getUAPlayerWithRoleAndClass(role, class, raid)

	local correctRoleidx = nil;
	for groupe,members in pairs(raid) do
		for member,data in pairs(members) do
			if type(data) == "table" then
				if not vro.assignedPlayers[data.name] and data.role == role then 
					if class and data.class == class then
						-- if he is not assignated, has the correct role and the correct class we can stop here
						vro.dLog(strfor("%s(%d) is not assigned and has correct role and class", data.name, data.raidIndex))
						return data.raidIndex 
					else
						-- else we can just store his index if there is none storred, so we can return it if we found nobody with the correct class with that role that is free
						correctRoleidx = nil and data.raidIndex or correctRoleidx
						vro.dLog(strfor("%s(%d) has the correct role but not class so we store it", data.name, data.raidIndex))
					end
				end
			end
		end
	end
	if (correctRoleIdx ~= nil) then
		vro.dLog(strfor("returning %d as correct role ( but not correct class )"));
	else
		vro.dLog("no unassigned player with role and class");
	end
	return correctRoleidx;
end

function vro.assignPlayer(playerIdx, currGroup, full)
	vro.dLog(strfor("vro.assignPlayer %d", playerIdx))
	-- the player normally assigned is in the raid, we now want to know his group
	local pName, _, thisPlayerGroup = GetRaidRosterInfo(playerIdx);
	if thisPlayerGroup == currGroup then
		vro.dLog("Player already in the group")
		-- yay he is already here, we assign him and pass to the next
		vro.assignedPlayers[pName] = true;
		vro.tprint(vro.assignedPlayers);
		return playerIdx;
	else
		vro.dLog("Player not in the group")
		-- he is not in this group so if the group is full we need to find a player in this group that we can swap out
		if (full) then
			local UAplayer = vro.getUnAssignedPlayerInGroup(currGroup)
			if UAplayer then
				-- we got one so here we go and we can assign him
				vro.dLog(strfor("swapping %d with %d", UAplayer, playerIdx))
				SwapRaidSubgroup(UAplayer, playerIdx)
				vro.assignedPlayers[pName] = true;
				vro.tprint(vro.assignedPlayers);
				return playerIdx;
			end
		else
			-- not full, just get him in here
			vro.dLog(strfor("getting %d into %d", playerIdx, currGroup))
			SetRaidSubgroup(playerIdx, currGroup)
			vro.assignedPlayers[pName] = true;
			vro.tprint(vro.assignedPlayers);
			return playerIdx;
		end
	end
	vro.dLog("Nobody to swap, skip")
	return nil
end

vro.sortRaidVar = {}
vro.sortRaidVar.tick = 0.2
vro.sortRaidVar.nextTick = GetTime() + vro.sortRaidVar.tick
vro.sortRaidVar.currRost = {}
vro.sortRaidVar.org = nil
vro.sortRaidVar.group = nil
vro.sortRaidVar.ongoing = false;

function vro.sortRaid(org)
	vro.dLog("sorting raid with org ", 3)

	-- reset vro.CurrentRoster
	if (type(vro.CurrentRoster) == "table") then
		for k in pairs(vro.CurrentRoster) do
			vro.CurrentRoster[k] = nil
		end
	end
	vro.CurrentRoster = vro.getCurrentRaid()
	vro.sortRaidVar.currRost = vro.CurrentRoster

	-- empty the assignated players list
	for pName, assigned in pairs (vro.assignedPlayers) do
		assigned = false;
	end

	-- remove every signs
	for i=1,40 do SetRaidTarget("raid"..i, 9) end

	vro.sortRaidVar.org = org
	vro.sortRaidVar.group = 1
	vro.sortRaidVar.ongoing = true
	vro.sortRaidVar.nextTick = GetTime() + vro.sortRaidVar.tick

	vro.CurrentSetup = org;
	VRO_MainFrame_Menu_CurrSetup_Text:SetText(org)
end

function vro.sortGroup(group)
	vro.dLog("sorting group "..group, 3)

	if (type(BRH_RaidOrganizer.sets[vro.sortRaidVar.org][group]) == "table") then
		for member,datas in pairs(BRH_RaidOrganizer.sets[vro.sortRaidVar.org][group]) do
			if type(datas) == "table" then
				thisPlayer = nil
				-- we got a player name, we use it
				if (datas.name) then
					vro.dLog("looking for "..datas.name, 3)
					thisPlayer = vro.getPlayerByName(vro.CurrentRoster, datas.name);
				end

				-- no name assigned or the player is not here so we are looking for another player with the role and class (if precised) we are looking for
				if (not thisPlayer) then
					thisPlayer = vro.getUAPlayerWithRoleAndClass(datas.role, datas.class, vro.CurrentRoster)
				end
				
				-- still nobody ? skip, elle we got it
				if (thisPlayer) then
					local full = vro.CurrentRoster[group] and vro.CurrentRoster[group].full or fasle;
					datas.raidIndex = vro.assignPlayer(thisPlayer, group, full)

					if datas.role == "tank" and datas.name then
						PromoteToAssistant(datas.name);
					end

					if (datas.sign and datas.raidIndex) then
						SetRaidTarget("raid"..datas.raidIndex, datas.sign) 
					end
				end


			end
		end
	end

	if (group < 8) then
		vro.sortRaidVar.group = group + 1
	else
		vro.sortRaidVar.org = nil
		vro.sortRaidVar.group = nil
		vro.sortRaidVar.ongoing = false;
	end
	vro.sortRaidVar.nextTick = GetTime() + vro.sortRaidVar.tick
end

VRO_MainFrame:SetScript("OnUpdate", function() 
	if (vro.sortRaidVar.ongoing) then
		if (vro.sortRaidVar.nextTick <= GetTime()) then
			vro.sortGroup(vro.sortRaidVar.group)
		end
	end
end)

function vro.delCurrentSet()
	if vro.gui.selected == "Current" then return end

	BRH_RaidOrganizer.sets[vro.gui.selected] = nil;
	vro.WypeGui();
	UIDropDownMenu_SetSelectedName(VRO_MainFrame_Menu_SetsDD, nil, nil)
end

function vro.saveCurrentSet(setName)
	if (not setName or setName == "") then return false end

	local newOrg = {}
	if BRH_RaidOrganizer.sets == nil then
		BRH_RaidOrganizer.sets = {}
	end

	if (vro.gui.groups) then
		BRH_RaidOrganizer.sets[setName] = {}
		for g =1,8 do
			if vro.gui.groups[g] then
				BRH_RaidOrganizer.sets[setName][g] = {}
				for p=1,5 do
					if vro.gui.groups[g][p] then
						BRH_RaidOrganizer.sets[setName][g][p] = {}
						BRH_RaidOrganizer.sets[setName][g][p].sign = vro.gui.groups[g][p].sign or nil
						BRH_RaidOrganizer.sets[setName][g][p].class = vro.gui.groups[g][p].class or nil
						BRH_RaidOrganizer.sets[setName][g][p].name = vro.gui.groups[g][p].name or nil
						BRH_RaidOrganizer.sets[setName][g][p].role = vro.gui.groups[g][p].role or nil
					end
				end
			end
		end
		return true
	else
		return false
	end

end

--COMPNAME:GROUP:PLAYERID:SIGN:CLASS:ROLE:NAME
function vro.SendComp(setName)
	for group,members in pairs(BRH_RaidOrganizer.sets[setName]) do
		for member,datas in pairs(members) do
			if type(datas) == "table" then
				local sign = datas.sign or "nil";
				local class = datas.class or "nil"
				local role = datas.role or "nil"
				local name = datas.name or "nil"
				local pDATA = setName..":"..group..":"..member..":"..sign..":"..class..":"..role..":"..name;
				vro.addonCom("sendComp",pDATA)
			end
		end
	end
end

function vro.GetHealForLoatheb(force)
    force = force or false;
	if not vro.Healerstring or force then 
    	local healers = vro.GetRoleList("heal")
	    
	    vro.Healerstring = ""
    	for idx,datas in pairs(healers) do
    		vro.Healerstring = vro.Healerstring..datas.name
    		if healers[idx+1] then
    			vro.Healerstring = vro.Healerstring.." => "
    		end
    	end
	end
	
    if IsRaidLeader() or IsRaidOfficer() then
    	SendChatMessage(vro.Healerstring, "RAID_WARNING");
  	else
    	SendChatMessage(vro.Healerstring, "RAID");
	end
end

SLASH_VRO1 = "/rc"
SLASH_VRO2 = "/vro"

function vro.cmdHandle(msg)
	util.strsplit(" ", msg)
	local cmd = util.strsplit(" ", msg)[1]
	local arg = util.strsplit(" ", msg)[2]
	if cmd then
		if (strlow(cmd) == "promote") then
			PromoteToAssistant(arg)
		elseif (strlow(cmd) == "kick") then
			vro.RemoveByName(arg)
		elseif (strlow(cmd) == "loatheb") then
			vro.GetHealForLoatheb()
		elseif (strlow(cmd) == "show") then
			BRH_RaidOrganizer.conf.show = true;
			VRO_MainFrame:Show();
		elseif (strlow(cmd) == "hide") then
			BRH_RaidOrganizer.conf.show = false;
			VRO_MainFrame:Hide();	
		elseif (strlow(cmd) == "raidinfos") then
			if not BRH_RaidOrganizer.conf.riShow then
				BRH_RaidOrganizer.conf.riShow = true
				VRO_RaidInfo:Show();
			else 
				BRH_RaidOrganizer.conf.riShow = false
				VRO_RaidInfo:Hide();
			end
		end
	else
		vro.print("Commands :\n/vro promote NAME\n/vro kick NAME\n/vro loatheb\n/vro show\n/vro hide\n/vro raidinfos");
	end
end

SlashCmdList["VRO"] = vro.cmdHandle