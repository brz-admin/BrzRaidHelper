BRH = {};
BRH.syncPrefix = "BRH_Sync"
BRH.build = "700"

if (BRH_config == nil) then
	BRH_spellsToTrack = nil;
	BRH_spellsToTrack = {};
	BRH_config = {
		["build"] = BRH.build,
		["amTank"] = false
	} 
	BRH_TrackedSpells = nil
	BRH_CDTrackerConfig = {
		["show"] = false,
	}
	BRH_SpellCastCount = nil
end

BRH.BS = AceLibrary("Babble-Spell-2.2")