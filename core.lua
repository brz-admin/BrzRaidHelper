BRH = {};
BRH.syncPrefix = "BRH_Sync"
BRH.build = "700"

BRH.BS = AceLibrary("Babble-Spell-2.3")

local _, localClass = UnitClass("player")

BRH.MainFrame = CreateFrame("Frame", "BRH_MainFrame")
BRH.MainFrame:RegisterEvent("ADDON_LOADED")
BRH.MainFrame:SetScript("OnEvent", function()
	-- load or set savedvariables
	if (event == "ADDON_LOADED" and arg1 == "BrzRaidHelper") then 

		BRH.pClass = string.lower(localClass)
		BRH.pName = UnitName("player")

		BRH_config = BRH_config or {}

		for name, mod in pairs(BRH) do
			if (type(mod) == "table") then
				if (name ~= "BS" and mod.init ~= nil and type(mod.init) == "function") then
					mod.init()
				end
			end
		end

		BRH.util.print("Thank you for using [\124cff64fc8aBrz\124r\124cffffffffraid\124r\124cffb0fc64Helper\124r]")
	end



end)