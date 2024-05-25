# BrzRaidHelper
WoW Vanilla ( 1.12 ) Addon - Adds helper functions and macro usefull for high level raid

`/LipAOE`: Allows warriors to take an invulnerability potion AND then AOE taunt, which allows them to be invulnerable during the duration of the AOE taunt. Also, using the macro locks it for other warriors who use it for 5 seconds, which allows chaining them without overlap, theoretically enabling huge packs of mobs to be AOE'd with tanks chaining the AOE taunts to maintain aggro.

`/TauntIfCan`: Allows taunting ONLY if the mob is not already taunted or if it's not attacking a tank (or at least a warrior from group 1).

`/spamHS`: In the next version, an improved/optimized version of the macro that is already running and utilizes SP_Swingtimer.

`/dumpAggro`: A macro that can be added to any spell, allowing the use of a petrification potion if aggro is too high.

`/scd [sapper|start]`: Allows synchronizing the casting of sappers. `/scd sapper` will only authorize launching the sapper once the countdown started by `/scd start` is finished. Basically, the Raid Leader starts the timer, then the entire raid spams `/scd sapper`, and everyone's sapper goes off at the same time. Additionally, this macro disables DPSMate and KTM parsing to reduce client lag resulting from the sudden burst of damage.

`/plsInfu [PriestName]`: Asks the specified priest for a Power Infusion, used in conjunction with the following macro. It also pops a frame on the priest's end that allow him to use Power Infusion on the player that asked it by clicking on it.

`/infuIfCan`: A macro to add to the priest's spells, which automatically casts Power Infusion on a player if requested. It should be added to a frequently used spell to be effective.
`/infuIfCan show`: show the infuIfCan button to move it

`/plsbop [PaladinName]`: Same principle as `plsinfu` but for Paladin's Blessing of Protection (BoP).

`/BOPIfCan`: Similar to `infuIfCan` but for casting Blessing of Protection.
`/BOPIfCan show`: show the bopifcan button allowing to move it

`/iamtank` : if ON then if you are the target of target it will announce when you miss for the 5 first seconds of the fight


## For raid officers:

`/BRH [Check|checkEngineer]`: The first command checks who has the addon and in which version. The second command allows knowing how many engineers are in the raid (provided that all raid members have the addon).

`/BRH [vacume|vacumelegend|stopvacume]`: The vacume tool is used for loot management during a speedrun. Basically, `/BRH vacume [PLAYERNAME]` designates a loot vacuum. The raid is set to group loot mode, and each time loot drops, all raid members pass automatically except the designated player. The advantage is that it avoids having to click on anything, and no one wastes time looting. `/BRH vacumelegend [PLAYERNAME]` sends legendary loot to the designated player (vacume doesn't automatically pass legendary loot for obvious reasons). It's useful for assigning Atiesh shards to the right person. `stopvacume` stops this function. I plan to adjust this to allow raid leaders to designate recipients for certain loot when possible.

`/cdtracker [track|untrack] SPELLNAME`: Allow to track or untrack Cds ( if they are longer than 30s ). You can add any spell by putting it's name. You can also put items like Gobling Sapper Charge or dynamite. For potions CD tracking just put "potion" as an argument.
`/cdtracker [show|hide]`: hide or show the cdTracker
`/cdtracker ann`: puts a chat message everytime someone uses a CD (even if you don't track it)

`/igniteTracker`: Tracks Ignite, its damage, and who it's on.

`/vro [show/hide]`: Opens RaidOrganizer, an interface that allow you to save/prepare your groups ( including signs ) and to change with only a button. Need a bit more work to be perfect.
`/vro loatheb`: Takes players tagged as healers in your raid and create a heal rotation for Loatheb encounter.
`/vro raidinfo`: Do as XRS does and show raid Health, Mana, and take player you tagged as healers mana to show healers mana.
