



BRH = {};
BRH.syncPrefix = "BRH_Sync"
BRH.build = "600"

if (BRH_Config == nil) then
	BRH_spellsToTrack = nil;
	BRH_spellsToTrack = {};
	BRH_Config = {
		["build"] = BRH.build
	} 
	BRH_TrackedSpells = nil
	BRH_CDTrackerConfig = {
		["show"] = false,
	}
	BRH_SpellCastCount = nil
end

BRH.BS = AceLibrary("Babble-Spell-2.2")




