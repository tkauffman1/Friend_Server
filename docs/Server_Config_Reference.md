# Server Config Reference

Generated for this AzerothCore deployment. Edit configs under `configs/`, then restart worldserver (and authserver if needed).

## Table of contents
1. [Expansion era (Vanilla / TBC / WotLK)](#expansion-era-vanilla--tbc--wotlk)
2. [Our custom values (recap)](#our-custom-values-recap)
3. [Core: worldserver.conf & authserver.conf](#core-servers)
4. [Module configs (configs/modules/*.conf)](#module-configs)

## Expansion era (Vanilla / TBC / WotLK)

Expansion is controlled by **several layers** together:

| Layer | File | What to change |
|-------|------|----------------|
| Level cap | `configs/worldserver.conf` | `MaxPlayerLevel`: **60** (Vanilla), **70** (TBC), **80** (WotLK). |
| Individual Progression stages | `configs/modules/individualProgression.conf` | `ProgressionLimit` (0 = no cap through stage 18), `StartingProgression` (jump new characters to a stage). Stage **7** is documented as Vanilla lock; **8** is TBC-related (e.g. Draenei/BELF); **13** is WotLK/DK-related. Exact enum: **IndividualProgression.h** in the module source. |
| Randombots | `configs/modules/playerbots.conf` | `RandomBotMaxLevel`, `RandomBotMaps` (0,1 = Kalimdor/EK; add **530** Outland, **571** Northrend), `ExcludedAccountsMaxLevel` in IP must match `MaxPlayerLevel` for bot accounts. |

### Checklists

**Vanilla-focused**
- `MaxPlayerLevel = 60`
- `IndividualProgression.ProgressionLimit = 7` (example: stay in Vanilla content per module docs)
- `IndividualProgression.ExcludedAccountsMaxLevel = 60`
- `AiPlayerbot.RandomBotMaxLevel = 60`, `RandomBotMaps = 0,1` (optional)

**TBC era**
- `MaxPlayerLevel = 70`
- Raise or clear `ProgressionLimit` so players can reach TBC stages (see module enum; stage **8** marks TBC entry in conf examples)
- `ExcludedAccountsMaxLevel = 70`
- `AiPlayerbot.RandomBotMaxLevel = 70`, add **530** to `RandomBotMaps`

**Full WotLK**
- `MaxPlayerLevel = 80`
- `IndividualProgression.ProgressionLimit = 0` (no stage cap)
- `IndividualProgression.ExcludedAccountsMaxLevel = 80`
- `AiPlayerbot.RandomBotMaxLevel = 80`, `RandomBotMaps = 0,1,530,571`

> **Note:** Individual Progression stores progression in the **database**. Changing configs alone does not reset players' progression state.

## Our custom values (recap)

| Location | Setting | Value |
|----------|---------|-------|
| worldserver.conf | MaxPlayerLevel | 60 |
| worldserver.conf | ItemDelete.ItemLevel | 60 |
| individualProgression.conf | ProgressionLimit | 7 |
| individualProgression.conf | ExcludedAccountsMaxLevel | 60 |
| playerbots.conf | Min/MaxRandomBots | 600 |
| playerbots.conf | RandomBotMaxLevel | 60 |
| playerbots.conf | SyncLevelWithPlayers | 1 |
| playerbots.conf | DisableRandomLevels / RandombotStartingLevel | 1 / 1 |
| playerbots.conf | botActiveAloneSmartScaleWhenMaxLevel | 60 |
| playerbots.conf | RandomBotMaps | 0,1 |
| playerbots.conf | FastReactInBG | 0 |
| playerbots.conf | RandomBotUpdateInterval | 25 |
| playerbots.conf | RandomBotsPerInterval | 40 |
| playerbots.conf | IterationsPerTick | 8 |
| .gitignore | mysql/, *.pdb | ignored |

## Core servers

### worldserver.conf
Main game server: database connections, rates, maps, visibility, battlegrounds, LFG, logging, performance (`MapUpdateInterval`, `ThreadPool`, etc.).

### authserver.conf
Login server: realm list, ports, database connection for authentication.

## Module configs

The following summaries cover **`configs/modules/*.conf`** only. **`configs/worldserver.conf`** and **`configs/authserver.conf`** are described under [Core servers](#core-servers) above.

To regenerate this file and `Server_Config_Reference.docx`, run from the repo root: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Build-ServerConfigDocx.ps1`

### 1v1arena.conf
1V1 ARENA CONFIG
Arena.1v1.Enable
Description: Enable the 1v1 arena.
Default:     0 - (Disabled)
1 - (Enabled)
Arena1v1.Announcer

Sample keys: Arena1v1.Enable, Arena1v1.Announcer, Arena1v1.MinLevel, Arena1v1.Costs, Arena1v1.VendorRating, Arena1v1.ArenaPointsMulti, Arena1v1.ArenaPointsMinLevel, Arena1v1.PreventHealingTalents, Arena1v1.PreventTankTalents, Arena1v1.ForbiddenTalentsIDs, Arena1v1.ArenaSlotID, Arena1v1.EnableCommand, Arena1v1.CastDeserterOnAfk, Arena1v1.CastDeserterOnLeave.

### AutoBalance.conf
Add these lines to your worldserver.conf file to enable logging for AutoBalance.
Be sure to add them after the `Logger.module=4,Console Server` line.
4 = Info (Default), 5 = Debug
Logger.module.AutoBalance=4,Console Server
Logger.module.AutoBalance_CombatLocking=4,Console Server
Logger.module.AutoBalance_DamageHealingCC=4,Console Server

Sample keys: AutoBalance.Enable.Global, AutoBalance.Enable.5M, AutoBalance.Enable.10M, AutoBalance.Enable.15M, AutoBalance.Enable.20M, AutoBalance.Enable.25M, AutoBalance.Enable.40M, AutoBalance.Enable.OtherNormal, AutoBalance.Enable.5MHeroic, AutoBalance.Enable.10MHeroic, AutoBalance.Enable.25MHeroic, AutoBalance.Enable.OtherHeroic, AutoBalance.Disable.PerInstance, AutoBalance.MinPlayers.

### AutoRevive.conf
mod-auto-revive
AutoRevive.Enable
Description: Enable auto revive before die, only GM account.
Default: 1
AutoRevive.ZoneID
Description: Enable in a certain area, if it is 0, it means everywhere.

Sample keys: AutoRevive.Enable, AutoRevive.ZoneID.

### bgqueuechecker.conf
Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license: https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
BG Queue Checker Configuration
BGQueueChecker.Enable
Description: Enable/disable queue checking to ensure same faction queueing.
Default:     0 - Disabled
1 - Enabled

Sample keys: BGQueueChecker.Enable.

### breakingnews.conf
Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license: https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
Breaking News configuration
BreakingNews.Enable
Description: Enable the Breaking News message on the character screen.
Default:     0 - Disabled
1 - Enabled

Sample keys: BreakingNews.Enable, BreakingNews.Title, BreakingNews.HtmlPath, BreakingNews.Cache, BreakingNews.Verbose.

### CFBG.conf
Copyright (С) since 2019 Andrei Guluaev (Winfidonarleyan/Kargatum) https://github.com/Winfidonarleyan
Copyright (С) since 2019+ AzerothCore <www.azerothcore.org>
Licence MIT https://opensource.org/MIT
CFBG configuration system #
CFBG.Enable
Description: Enable mixed alliance and horde in one battleground

Sample keys: CFBG.Enable, CFBG.Battlefield.Enable, CFBG.BalancedTeams, CFBG.BalancedTeams.Class.LowLevel, CFBG.BalancedTeams.Class.MinLevel, CFBG.BalancedTeams.Class.MaxLevel, CFBG.BalancedTeams.Class.LevelDiff, CFBG.Include.Avg.Ilvl.Enable, CFBG.Players.Count.In.Group, CFBG.EvenTeams.Enabled, CFBG.EvenTeams.MaxPlayersThreshold, CFBG.ResetCooldowns, CFBG.Show.PlayerName, CFBG.RandomRaceSelection.

### challenge_modes.conf
Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license: https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
Copyright (c) 2025 AzoraNova https://github.com/AzoraNova (for changes made)
___                            _   _                       #
/ _ \    Config Update by      | \ | |                      #
/ /_\ \ ____  ___   _ __   __ _ |  \| |  ___  __   __  __ _  #
|  _  ||_  / / _ \ | '__| / _` || . ` | / _ \ \ \ / / / _` | #

Sample keys: ChallengeModes.Enable, Hardcore.Enable, Hardcore.TitleRewards, Hardcore.XPMultiplier, Hardcore.TalentRewards, Hardcore.ItemRewards, Hardcore.ItemRewardAmount, Hardcore.DisableLevel, Hardcore.AchievementReward, SemiHardcore.Enable, SemiHardcore.TitleRewards, SemiHardcore.XPMultiplier, SemiHardcore.TalentRewards, SemiHardcore.ItemRewards.

### desertion-warnings.conf

Sample keys: DesertionWarnings.Enabled, DesertionWarnings.WarningText.

### duelreset.conf
DuelReset.Cooldowns
Description: Reset all cooldowns before duel starts and restore them when duel ends.
Default:     1  - (Enabled)
0  - (Disabled)
DuelReset.HealthMana
Description: Reset health and mana before duel starts and restore them when duel ends.

Sample keys: DuelReset.Cooldowns, DuelReset.HealthMana, DuelReset.CooldownAge, DuelReset.Zones, DuelReset.Areas.

### dynamicxp.conf
Dynamic.XP.Rate
Description: You can setup the personal XP rate for different level ranges.
Dynamic.XP.Rate.Announce: 1 (Enable) Default
0 (Disable)
Dynamic.XP.Rate: 1 (Enable) Default
0 (Disable)

Sample keys: Dynamic.XP.Rate.Announce, Dynamic.XP.Rate.

### emblem_transfer.conf
Minimum amount of emblems to be transfered
default: 10
Penalty percentaje to apply
default: 0.1 (10%)
Allows to transfer Emblems of Frost
default: true

Sample keys: EmblemTransfer.minAmount, EmblemTransfer.penalty, EmblemTransfer.allowEmblemsFrost, EmblemTransfer.allowEmblemsTriumph, EmblemTransfer.allowEmblemsConquest, EmblemTransfer.allowEmblemsHeroism, EmblemTransfer.allowEmblemsValor.

### fly-anywhere.conf
FlyAnywhere.Enabled
Description: Enable or Disable flying in Eastern Kingdoms, Kalimdor (old world) and BC starter zones for all players with Expert Riding.
Example:
true (Flying is enabled in old world)
false (No flying is enable in old world, standard Blizz-like behaviour)
Default: true

Sample keys: FlyAnywhere.Enabled.

### individual_xp.conf
IndividualXp.Enabled
Description: Enable or Disable the IndividualXP Module.
Example:
true (The module is active for use)
false (No one can use the commands)
Default: true

Sample keys: IndividualXp.Enabled, IndividualXp.Announce, IndividualXp.AnnounceRatesOnLogin, IndividualXp.MaxXPRate, IndividualXp.DefaultXPRate.

### individualProgression.conf
Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license: https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
Individual Progression Configuration
IndividualProgression.Enable
Description: Enable Individual Progression Module
Please note that like all AzerothCore modules, database changes cannot be undone through config settings.
This means that world changes like restoring Vanilla quests and NPC stats will remain in place even if disabled.

Sample keys: IndividualProgression.Enable, IndividualProgression.EnforceGroupRules, IndividualProgression.VanillaPowerAdjustment, IndividualProgression.VanillaHealingAdjustment, IndividualProgression.TBCPowerAdjustment, IndividualProgression.TBCHealingAdjustment, IndividualProgression.QuestXPFix, IndividualProgression.RequireNaxxStrathEntrance, IndividualProgression.doableNaxx40Bosses, IndividualProgression.MoltenCore.ManualRuneHandling, IndividualProgression.MoltenCore.AqualEssenceCooldownReduction, IndividualProgression.SerpentshrineCavern.RequireAllBosses, IndividualProgression.TheEye.RequireAllBosses, IndividualProgression.FishingFix.

### instance-reset.conf
instanceReset.Enable
Descripcion: Enable the module.
Default: true
Value: true | false
instanceReset.Announcer
Descripcion: If true, announces the module to the player.

Sample keys: instanceReset.Enable, instanceReset.Announcer, instanceReset.NormalModeOnly, instanceReset.TransactionType, instanceReset.TokenID, instanceReset.TokenCount, instanceReset.MoneyCount.

### leech.conf
Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license: https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
Leech Config
Leech.Enable
Description: Enable the module
Default:     0 - Disabled
1 - Enabled

Sample keys: Leech.Enable, Leech.DungeonsOnly, Leech.Amount, Leech.RequiredItemId, Leech.PetDamage.

### low_level_rbg.conf
Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license: https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
LowLevelRBG.MinLevelRBG
Description: Set min level for players to be able to queue up for RBG using this module
Default:     10
LowLevelRBG.MaxLevelRBG
Description: Set max level for players to be able to queue up for RBG using this module

Sample keys: LowLevelRBG.MinLevelRBG, LowLevelRBG.MaxLevelRBG.

### mod_account_mount.conf
Account Mounts module
Enable the module? (1: true | 0: false)
Announce the module when the player logs in?
Excluded Spell IDs (comma-separated, no space). See example below
Account.Mounts.ExcludedSpellIDs = 470,578,6777
Limit race and class specific mounts? (1: true | 0: false)

Sample keys: Account.Mounts.Enable, Account.Mounts.Announce, Account.Mounts.ExcludedSpellIDs, Account.Mounts.LimitRace.

### mod_achievements.conf
Account Achievements module
Enable the module? (1: true | 0: false)
Announce the module when the player logs in?
List of achievement IDs to exclude (comma-separated)

Sample keys: Account.Achievements.Enable, Account.Achievements.Announce, Account.Achievements.Excluded.

### mod_ahbot.conf
AUCTION HOUSE BOT IN-GAME COMMANDS
Available GM commands:
.ahbot reload  - Reloads AuctionHouseBot configuration
.ahbot empty   - Clears all AuctionHouseBot auctions from all auction houses
.ahbot update  - Forces an immediate update cycle
AUCTION HOUSE BOT SETTINGS

Sample keys: AuctionHouseBot.DEBUG, AuctionHouseBot.DEBUG_FILTERS, AuctionHouseBot.MinutesBetweenBuyCycle, AuctionHouseBot.MinutesBetweenSellCycle, AuctionHouseBot.EnableSeller, AuctionHouseBot.ReturnExpiredAuctionItemsToBot, AuctionHouseBot.GUIDs, AuctionHouseBot.ItemsPerCycle, AuctionHouseBot.ListingExpireTimeInSecondsMin, AuctionHouseBot.ListingExpireTimeInSecondsMax, AuctionHouseBot.CompleteItemValueOverride.Enabled, AuctionHouseBot.CompleteItemValueOverride.Items, AuctionHouseBot.CompleteItemValueOverride.DoApplyBidVariations, AuctionHouseBot.CompleteItemValueOverride.DoApplyBuyoutVariations.

### mod_aq_war_effort.conf
Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license: https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
My module configuration
ModWarEffort.Enable
Description: Enables the module
Default:     0 - Disabled
1 - Enabled

Sample keys: ModWarEffort.Enable, ModWarEffort.Id, ModWarEffort.Goal.Horde.Bandages.01, ModWarEffort.Goal.Horde.Bandages.02, ModWarEffort.Goal.Horde.Bandages.03, ModWarEffort.Goal.Horde.Bandages.04, ModWarEffort.Goal.Horde.Bandages.05, ModWarEffort.Goal.Horde.Food.01, ModWarEffort.Goal.Horde.Food.02, ModWarEffort.Goal.Horde.Food.03, ModWarEffort.Goal.Horde.Food.04, ModWarEffort.Goal.Horde.Food.05, ModWarEffort.Goal.Horde.Herbs.01, ModWarEffort.Goal.Horde.Herbs.02.

### mod_boss_announcer.conf
Boss Announcer Module Configuration
Boss.Announcer.Enable
Description: Enable or disable the Boss Announcer module entirely.
Default:     1 (enabled)
Boss.Announcer.Announce
Description: Announce to players on login that the server

Sample keys: Boss.Announcer.Enable, Boss.Announcer.Announce, Boss.Announcer.RemoveAuraUponKill, Boss.Announcer.AnnounceWipe.

### mod_customserver.conf
CUSTOM SERVER
Announce the module when the player logs in?
Fireworks go off when the player levels up at specific intervals
Intervals: 5, 10, 20, 30, 40, 50, 60, 70, 80
Enable the module? (1: true | 0: false)

Sample keys: CustomServer.Announce, CustomServer.FireworkLevels.

### mod_dead_means_dead.conf
Dead Means Dead configuration
DeadMeansDead.Enable
Enable the module
Default: 1
DeadMeansDead.Announce
Announce the mod when players log in

Sample keys: DeadMeansDead.Enable, DeadMeansDead.Announce, DeadMeansDead.Enable.Dungeons, DeadMeansDead.Enable.Raids, DeadMeansDead.Enable.World, DeadMeansDead.RespawnTime.Multiplier.Global, DeadMeansDead.RespawnTime.Multiplier.Dungeons, DeadMeansDead.RespawnTime.Multiplier.Raids, DeadMeansDead.RespawnTime.Multiplier.World, DeadMeansDead.RespawnTime.Original.Min, DeadMeansDead.RespawnTime.Original.Max, DeadMeansDead.RespawnTime.Adjusted.Min, DeadMeansDead.RespawnTime.Adjusted.Max, DeadMeansDead.Filter.KilledByPlayer.

### mod_dungeon_master.conf
DUNGEON MASTER MODULE CONFIGURATION
Procedural dungeon challenge system for AzerothCore.
Players talk to the Dungeon Master NPC, choose difficulty / theme / dungeon,
then get teleported to an instance populated with level-appropriate themed
creatures.  Clear the dungeon and defeat the boss for rewards.
CORE SETTINGS

Sample keys: DungeonMaster.Enable, DungeonMaster.Debug, DungeonMaster.NpcEntry, DungeonMaster.Difficulty.1, DungeonMaster.Difficulty.2, DungeonMaster.Difficulty.3, DungeonMaster.Difficulty.4, DungeonMaster.Difficulty.5, DungeonMaster.Difficulty.6, DungeonMaster.Difficulty.7, DungeonMaster.Difficulty.8, DungeonMaster.Difficulty.9, DungeonMaster.Difficulty.10, DungeonMaster.Scaling.LevelBand.

### mod_dynamic_loot_rates.conf
DynamicLootRates configuration
DynamicLootRates.Enable
Description: Enables or disables the module
Default:     0 - Disabled
1 - Enabled
DynamicLootRates.Dungeon.Rate.GroupAmount

Sample keys: DynamicLootRates.Enable, DynamicLootRates.Dungeon.Rate.GroupAmount, DynamicLootRates.Dungeon.Rate.ReferencedAmount, DynamicLootRates.Raid.Rate.GroupAmount, DynamicLootRates.Raid.Rate.ReferencedAmount.

### mod_flightmaster_whistle.conf
Credits: silviu20092
Mod Flightmaster Whistle configuration
Flightmaster.Whistle.Enable
Description: Enable/disable the module
Default:     0 - Disabled
1 - Enabled

Sample keys: Flightmaster.Whistle.Enable, Flightmaster.Whistle.Timer, Flightmaster.Whistle.Preserve.Zone, Flightmaster.Whistle.LinkMainCities, Flightmaster.Whistle.MinPlayerLevel, Flightmaster.Whistle.OnlyKnown.

### mod_guildhouse.conf
CostGuildHouse
The amount of money to buy a guild house
default = 10000000 (1000g)
GuildHouseMailbox
The amount of money to buy a mail box for your guild house
default = 500000 (50g)

Sample keys: CostGuildHouse, GuildHouseMailbox, GuildHouseInnKeeper, GuildHouseBank, GuildHouseAuctioneer, GuildHouseTrainerCost, GuildHouseVendor, GuildHouseObject, GuildHousePortal, GuildHouseProf, GuildHouseSpirit, GuildHouseBuyRank, GuildHouseSellRank.

### mod_improved_bank.conf
Credits: silviu20092
Improved bank configuration
ImprovedBank.AccountWide
Description: Whether deposited items are account wide or not
Default:     0 - Disabled
1 - Enabled

Sample keys: ImprovedBank.AccountWide, ImprovedBank.Deposit.SearchBank, ImprovedBank.Deposit.AllReagents, ImprovedBank.Deposit.AllReagents.Bank, ImprovedBank.Deposit.AllReagents.BlacklistSubclass, ImprovedBank.Categorized.Item.Menu.Deposit, ImprovedBank.Categorized.Item.Menu.Withdraw.

### mod_learnspells.conf
Learn spells on level-up
Enable the module? (1: true | 0: false)
Announce the module when the player logs in?
Should the player receive all spells on first login?
Useful for instant leveling type of servers
(1: true | 0: false)

Sample keys: LearnSpells.Enable, LearnSpells.Announce, LearnSpells.OnFirstLogin, LearnSpells.MaxLevel.

### mod_moneyforkills.conf
MONEY FOR KILLS
Enable the module? (1: true | 0: false)
Default: 1
Announce the module when the player logs in?
Default: 0
Enable announcements to notify the server of a world boss kill

Sample keys: MFK.Enable, MFK.Announce, MFK.Announce.World.WorldBoss, MFK.Announce.World.Suicide, MFK.Announce.Guild.Suicide, MFK.Announce.Group.Suicide, MFK.Announce.World.PvP, MFK.Announce.Group.DungeonBoss, MFK.Bounty.KillingBlowOnly, MFK.Bounty.MoneyForNothing, MFK.PVP.CorpseLootPercent, MFK.Bounty.Kill.Multiplier, MFK.PVP.Kill.Multiplier, MFK.Bounty.WorldBoss.Multiplier.

### mod_mythic_plus.conf
Credits: silviu20092
Mythic Plus configuration
MythicPlus.Enable
Description: Enable or disable the system. This config is not hot-reloadable.
Default:     0 - Disabled
1 - Enabled

Sample keys: MythicPlus.Enable, MythicPlus.Penalty.OnDeath, MythicPlus.KeystoneBuyTimer, MythicPlus.DropKeystoneOnDungeonComplete.

### mod_no_hearthstone_cooldown.conf
Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license: https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
No Hearthstone cooldown module configuration
NoHearthstoneCooldownConfig.Enable
Description: Enable to skip the Hearthstone cooldown
Default:     1 - Enabled
0 - Disabled

Sample keys: NoHearthstoneCooldown.Enable, NoHearthstoneCooldown.Announce.

### mod_npc_beastmaster.conf
BEASTMASTER NPC MODULE CONFIGURATION
This file controls the Beastmaster NPC module, allowing players to adopt and manage pets.
Copy this file to mod_npc_beastmaster.conf and adjust settings as needed.
Enable or disable the Beastmaster module (default: 1)
Enable or disable the howl sound effect on interact (default: 1)
Show login notice about Beastmaster commands (default: 1)

Sample keys: BeastMaster.Enable, BeastMaster.Howls, BeastMaster.ShowLoginNotice, BeastMaster.LoginMessage, BeastMaster.HunterOnly, BeastMaster.AllowedClasses, BeastMaster.AllowedRaces, BeastMaster.MinLevel, BeastMaster.MaxLevel, BeastMaster.HunterBeastMasteryRequired, BeastMaster.AllowExotic, BeastMaster.KeepPetHappy, BeastMaster.TrackTamedPets, BeastMaster.MaxTrackedPets.

### mod_npc_free_professions.conf
mod-npc-free-professions
NpcFreeProfessions.Enable
Description: Enables the module
Default:    1 - Enabled, default
0 - Disabled
NpcFreeProfessions.GivenCraftLevel

Sample keys: NpcFreeProfessions.Enable, NpcFreeProfessions.GivenCraftLevel, NpcFreeProfessions.Enable.Alchemy, NpcFreeProfessions.Enable.Blacksmithing, NpcFreeProfessions.Enable.Leatherworking, NpcFreeProfessions.Enable.Tailoring, NpcFreeProfessions.Enable.Engineering, NpcFreeProfessions.Enable.Enchanting, NpcFreeProfessions.Enable.Jewelcrafting, NpcFreeProfessions.Enable.Inscription, NpcFreeProfessions.Enable.Herbalism, NpcFreeProfessions.Enable.Skinning, NpcFreeProfessions.Enable.Mining, NpcFreeProfessions.Enable.Cooking.

### mod_ollama_chat.conf
mod-ollama-chat configuration
CORE MODULE TOGGLES & DEBUGGING
OllamaChat.Enable
Description: Enable or disable the module.
Default:     1 (true)
OllamaChat.DebugEnabled

Sample keys: OllamaChat.Enable, OllamaChat.DebugEnabled, OllamaChat.DebugShowFullPrompt, OllamaChat.Url, OllamaChat.Model, OllamaChat.NumPredict, OllamaChat.Temperature, OllamaChat.TopP, OllamaChat.RepeatPenalty, OllamaChat.NumCtx, OllamaChat.NumThreads, OllamaChat.Stop, OllamaChat.SystemPrompt, OllamaChat.Seed.

### mod_phased_duels.conf
Phased Duels module
Enable the module? (1: true | 0: false)
Announce Module (1: true | 0: false)
SetMaxHP.Enable
Enable players to get Max HP after duel (1: true | 0: false)
ResetCoolDowns.Enable

Sample keys: PhasedDuels.Enable, PhasedDuelsAnnounce.Enable, SetMaxHP.Enable, ResetCoolDowns.Enable, RestorePower.Enable, RetorePowerForRogueOrWarrior.Enable, ReviveOrRestorPetHealth.Enable.

### mod_player_bot_guildhouse.conf
mod-player-bot-guildhouse configuration
PlayerbotGuildhouse.TeleportCycleFrequency
Description: How often (in seconds) the teleportation
cycle runs to evaluate entry and exit.
Default:     120
PlayerbotGuildhouse.StaggeredTeleport.BatchSize

Sample keys: PlayerbotGuildhouse.TeleportCycleFrequency, PlayerbotGuildhouse.StaggeredTeleport.BatchSize, PlayerbotGuildhouse.RequireRealPlayer, PlayerbotGuildhouse.EntryChancePercent, PlayerbotGuildhouse.ExitChancePercent, PlayerbotGuildhouse.DebugEnabled.

### mod_player_bot_level_brackets.conf
mod-player-bot-level-brackets configuration
BotLevelBrackets.Enabled
Description: Enables the module.
Default:     1 (enabled)
Valid values: 0 (off) / 1 (on)
BotLevelBrackets.FullDebugMode

Sample keys: BotLevelBrackets.Enabled, BotLevelBrackets.FullDebugMode, BotLevelBrackets.LiteDebugMode, BotLevelBrackets.CheckFrequency, BotLevelBrackets.CheckFlaggedFrequency, BotLevelBrackets.FlaggedProcessLimit, BotLevelBrackets.IgnoreGuildBotsWithRealPlayers, BotLevelBrackets.IgnoreArenaTeamBots, BotLevelBrackets.GuildTrackerUpdateFrequency, BotLevelBrackets.IgnoreFriendListed, BotLevelBrackets.ExcludeNames, BotLevelBrackets.NumRanges, BotLevelBrackets.Dynamic.UseDynamicDistribution, BotLevelBrackets.Dynamic.RealPlayerWeight.

### mod_player_bot_reset.conf
mod-player-bot-reset configuration
ResetBotLevel.MaxLevel
Description: The maximum level a bot can reach before being reset.
Default:     80
Valid range: 2-80 (or 0 to disable)
ResetBotLevel.ResetToLevel

Sample keys: ResetBotLevel.MaxLevel, ResetBotLevel.ResetToLevel, ResetBotLevel.SkipFromLevel, ResetBotLevel.SkipToLevel, ResetBotLevel.ResetChance, ResetBotLevel.ScaledChance, ResetBotLevel.RestrictTimePlayed, ResetBotLevel.MinTimePlayed, ResetBotLevel.PlayedTimeCheckFrequency, ResetBotLevel.DebugMode, ResetBotLevel.ExcludeNames, ResetBotLevel.IgnoreGuildBotsWithRealPlayers.

### mod_pvptitles.conf
Old School PvP Titles
Enable the module? (1: true | 0: false)
Announce the module when the player logs in?
Set Required honor kills for each rank

Sample keys: PvPTitles.Enable, PvPTitles.Announce, PvPTitles.Rank_1, PvPTitles.Rank_2, PvPTitles.Rank_3, PvPTitles.Rank_4, PvPTitles.Rank_5, PvPTitles.Rank_6, PvPTitles.Rank_7, PvPTitles.Rank_8, PvPTitles.Rank_9, PvPTitles.Rank_10, PvPTitles.Rank_11, PvPTitles.Rank_12.

### mod_weather_vibe.conf
WeatherVibe — baseline + auto-rotation profiles
States: 0=Fine, 1=Fog, 3=LightRain, 4=MediumRain, 5=HeavyRain, 6=LightSnow, 7=MediumSnow, 8=HeavySnow,
22=LightSandstorm, 41=MediumSandstorm, 42=HeavySandstorm, 86=Thunders
Toggle + debug
Season/dayparts (times can be tweaked; auto picks based on local server time)
Internal intensity ranges (per daypart/state) — keep caps ≲ 0.65 for routine play

Sample keys: WeatherVibe.Enable, WeatherVibe.Debug, WeatherVibe.Season, WeatherVibe.DayPart.Mode, WeatherVibe.DayPart.MORNING.Start, WeatherVibe.DayPart.AFTERNOON.Start, WeatherVibe.DayPart.EVENING.Start, WeatherVibe.DayPart.NIGHT.Start, WeatherVibe.Intensity.InternalRange.MORNING.Fine, WeatherVibe.Intensity.InternalRange.AFTERNOON.Fine, WeatherVibe.Intensity.InternalRange.EVENING.Fine, WeatherVibe.Intensity.InternalRange.NIGHT.Fine, WeatherVibe.Intensity.InternalRange.MORNING.Fog, WeatherVibe.Intensity.InternalRange.AFTERNOON.Fog.

### mod_weekendbonus.conf
Multiplier for experience gains on weekends
Multiplier for money looted and rewarded from quests on weekends
Multiplier for profession skill ups on weekends
Multiplier for reputation gains on weekends
Multiplier for weapons and defense skill ups on weekends
Multiplier for honor gains on weekends

Sample keys: WeekendBonus.Multiplier.Experience, WeekendBonus.Multiplier.Money, WeekendBonus.Multiplier.Professions, WeekendBonus.Multiplier.Reputation, WeekendBonus.Multiplier.Proficiencies, WeekendBonus.Multiplier.Honor.

### modarenatop.conf
Enable Hello World message at server start
default: false

Sample keys: MyCustom.enableHelloWorld.

### mod-changeablespawnrates.conf
Mod-ChangeableSpawnRates
Module.Enabled
Description: Enable/Disable the module
Default:     1 - Enabled
0 - Disabled
Module.RespawnMultiplicator

Sample keys: Module.Enable, Module.RespawnMultiplicator, Module.Announce.Enable, Module.DynamicSpawnrates.Enable, Module.DynamicSpawnrates.IgnoreMinimum, Module.DynamicSpawnrates.Minimum, Module.MinimumSpawntime.

### mod-junk-to-gold.conf
Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license: https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
Junk To Gold configuration
JunkToGold.Enable
Description: (Default: 1) Enable or Disable Module
Default:     0 - Disabled
1 - Enabled

Sample keys: JunkToGold.Enable, JunkToGold.Quality.0, JunkToGold.Quality.1, JunkToGold.Quality.2, JunkToGold.Quality.3, JunkToGold.Quality.4, JunkToGold.Quality.5, JunkToGold.Quality.6, JunkToGold.Quality.7, JunkToGold.SkipItems, JunkToGold.SkipItemsID, JunkToGold.Logging.Enable.

### mod-quest-loot-party.conf
QuestParty.Message
Description: Enable or Disable the Quest Loot Party Message.
Options: 0 or 1
Default: 1 (enabled)
QuestParty.Enable
Description: Enable or Disable the Quest Loot Party Module.

Sample keys: QuestParty.Message, QuestParty.Enable.

### mod-rdf-expansion.conf
Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license: https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
RDF.Expansion
Description: Allow setting which expansion can be used in LFG
2 - WOTLK (Default behaviour)
1 - TBC (if the player queues WOTLK RDF, join as TBC RDF)
0 - Classic  (if the player queues Wotlk or TBC RDF, join as Classic RDF)

Sample keys: RDF.Expansion.

### mod-time_is_time.conf
Azerothcore Module:     TimeIsTime
Author:                 Dunjeon
Contributing Author(s): lasyan3, vratam @ RegWorks
Version:                20250608
License:                GNU Affero General Public License v3.0
Announce

Sample keys: TimeIsTime.Announce, TimeIsTime.Enable, TimeIsTime.SpeedRate, TimeIsTime.TimeStart, TimeIsTime.HourOffset.

### morphsummon.conf
mod-morphsummon configuration
Enable or disable the module
Announce the module when the player logs in?
Allow new name for demons and ghouls
Model IDs for the summoned permanent creatures
List with alternative item IDs for the Felguard weapon

Sample keys: MorphSummon.Enabled, MorphSummon.Announce, MorphSummon.NewNameEnabled, MorphSummon.Warlock.Imp, MorphSummon.Warlock.Voidwalker, MorphSummon.Warlock.Succubus, MorphSummon.Warlock.Felhunter, MorphSummon.Warlock.Felguard, MorphSummon.DeathKnight.Ghoul, MorphSummon.Mage.WaterElemental, MorphSummon.Warlock.Felguard.Weapon, MorphSummon.RandomVisualEffectSpells, MorphSummon.MinTimeVisualEffect, MorphSummon.MaxTimeVisualEffect.

### npc_beastmaster.conf
BEASTMASTER NPC
Enable only for the hunter class?
Required level to adopt pets. (default: 10, 0 = disable)
Hunters are required to have Beast Mastery to adopt exotic pets. (default: 0)
Allow exotic pets for non-hunters (default: 1)
Keep pet always happy (default: 0)

Sample keys: BeastMaster.HunterOnly, BeastMaster.MinLevel, BeastMaster.HunterBeastMasteryRequired, BeastMaster.AllowExotic, BeastMaster.KeepPetHappy, BeastMaster.Pets, BeastMaster.ExoticPets, BeastMaster.RarePets, BeastMaster.RareExoticPets.

### npc_buffer.conf
Buff.Enable
Description: Enable or disable the module.
Default: 1 (Enable)
1 (Enable)
0 (Disable)
Buff.Announce

Sample keys: Buff.Enable, Buff.Announce, Buff.CureRes, Buff.ByLevel, Buff.MaxLevel, Buff.Spells, Buff.MessageTimer, Buff.NumPhrases, BF.P1, BF.P2, BF.P3, BF.P4, Buff.NumWhispers, BF.W1.

### npc_enchanter.conf
ENCHANTER NPC
Enable the module
Enable : 1
Disable: 0
Announce the module when the player logs in?
Enable : 1

Sample keys: Enchanter.Enable, Enchanter.Announce, Enchanter.MessageTimer, Enchanter.NumPhrases, EC.P1, EC.P2, EC.P3, Enchanter.EmoteSpell, Enchanter.EmoteCommand.

### npc_spectator.conf
NPC ARENA SPECTATOR
NpcArenaSpectator.Enable
Description: Enable system
Default: 1

Sample keys: NpcArenaSpectator.Enable, NpcArenaSpectator.ShowUnrated, NpcArenaSpectator.1v1.Enable, NpcArenaSpectator.1v1.SlotID, NpcArenaSpectator.1v1.ArenaType, NpcArenaSpectator.3v3soloQ.Enable, NpcArenaSpectator.3v3soloQ.SlotID, NpcArenaSpectator.3v3soloQ.ArenaType, NpcArenaSpectator.Enable5v5.

### npc_subclass.conf
Equipment Proficiency NPC
Announce the module when the player logs in?
default = 1
Enable random emotes for the NPC?
default = 1

Sample keys: SubClassNPC.Announce, SubClassNPC.EnableAI.

### npc_talent_template.conf
Npc Talent Template module configuration
NpcTalentTemplate.EnableResetTalents
Description: Enables Gossip Option to reset talents
Default:     1 - Enabled
0 - Disabled
NpcTalentTemplate.EnableRemoveAllGlyphs

Sample keys: NpcTalentTemplate.EnableResetTalents, NpcTalentTemplate.EnableRemoveAllGlyphs, NpcTalentTemplate.EnableDestroyEquippedGear, NpcTalentTemplate.AllianceMount, NpcTalentTemplate.HordeMount.

### playerbots.conf
PLAYERBOTS CONFIGURATION FILE                  #
Overview
"Randombot": randomly generated bots that log in separately from players and populate the world. Randombots may automatically grind, quest, level up, and upgrade equipment and can be invited to groups and given commands.
"AddClass bot": bots from the AddClassAccountPoolSize accounts. They are used for quickly adding a leveled and geared bot of any class to your party. They are recommended for a quick formation of a party.
"Altbot": characters created on player accounts, which may be logged in by the player and invited to groups and given commands like randombots. They are best suited for long-progression playthroughs.
Information about commands to control bots and set their strategies can be found on the wiki at https://github.com/mod-playerbots/mod-playerbots/wiki/Playerbot-Commands.

Sample keys: AiPlayerbot.Enabled, AiPlayerbot.RandomBotAutologin, AiPlayerbot.MinRandomBots, AiPlayerbot.MaxRandomBots, AiPlayerbot.RandomBotAccountCount, AiPlayerbot.DeleteRandomBotAccounts, AiPlayerbot.DisabledWithoutRealPlayer, AiPlayerbot.DisabledWithoutRealPlayerLoginDelay, AiPlayerbot.DisabledWithoutRealPlayerLogoutDelay, AiPlayerbot.MaxAddedBots, AiPlayerbot.AddClassCommand, AiPlayerbot.AddClassAccountPoolSize, AiPlayerbot.GroupInvitationPermission, AiPlayerbot.KeepAltsInGroup.

### QueueListCache.conf
Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license: https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
Copyright (C) 2021+ WarheadCore <https://github.com/WarheadCore>
This file is free software; as a special exception the author gives
unlimited permission to copy and/or distribute it, with or without
modifications, as long as this notice is preserved.
This program is distributed in the hope that it will be useful, but

Sample keys: QLC.Enable, QLC.Update.Delay.

### quick_teleport.conf
AzerothCore Quick Teleport System
The home and arena locations are searched for in the game_tele table in the world
database.  Check to make sure your location exists before adding it to this file.

Sample keys: QuickTeleport.enabled, QuickTeleport.homeLocation, QuickTeleport.arenaLocation.

### RacialTraitSwap.conf
Azerothcore Racial Trait Swap NPC  #
Azerothcore Racial Trait NPC Cost
For a cost, you can swap our you current racial traits for that of another.
Azerothcore.Racial.Trait.Swap.Announce.enable
Description: Announces Module when player logs in.
Default:    0 - (Disabled)

Sample keys: Azerothcore.Racial.Trait.Swap.Announce.enable, Racial.Traits.Swap.Gold.

### random_enchants.conf
RANDOM ENCHANTS OPTIONS
RandomEnchants.Enable
Enable or disable the module
Default:     1 (enabled)
RandomEnchants.AnnounceOnLogin
Announce a message on login for this module

Sample keys: RandomEnchants.Enable, RandomEnchants.AnnounceOnLogin, RandomEnchants.OnLoginMessage, RandomEnchants.OnLoot, RandomEnchants.OnCreate, RandomEnchants.OnQuestReward, RandomEnchants.OnGroupRoll, RandomEnchants.EnchantChance1, RandomEnchants.EnchantChance2, RandomEnchants.EnchantChance3.

### reagent_bank.conf
Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license: https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
Reagent Bank Config
ReagentBank.Enable
Description: Enable the reagent bank
Default:     0 - Disabled
1 - Enabled

Sample keys: ReagentBank.Enable.

### reward_system.conf
RewardSystemAnnounce
Description: Announce the reward system
Default:     1  - (Enabled)
RewardSystemEnable
Description: Enable the reward system
Default:     1  - (Enabled)

Sample keys: RewardSystem.Announce, RewardSystemEnable, RewardTime, MaxRoll.

### ServerAutoShutdown.conf
Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license: https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
Copyright (C) 2021+ WarheadCore <https://github.com/WarheadCore>
ServerAutoShutdown module configuration
ServerAutoShutdown.Enabled
Description: Enable to automatically shut down the server, so it can be restarted on a daily basis
Default:     0 - Disabled

Sample keys: ServerAutoShutdown.Enabled, ServerAutoShutdown.EveryDays, ServerAutoShutdown.Weekday, ServerAutoShutdown.Time, ServerAutoShutdown.PreAnnounce.Seconds, ServerAutoShutdown.PreAnnounce.Message, ServerAutoShutdown.StartEvents.

### skip_dk_module.conf
Skip Death Knight Starting Area
Enable this if you want to skip the Deathknight starting area
Start with level 58 DK with Runeforging.
Skip.Deathknight.Starter.Announce.enable
Description: Announces Module when player logs in.
Default:    0 - (Disabled)

Sample keys: Skip.Deathknight.Starter.Announce.enable, Skip.Deathknight.Starter.Enable, GM.Skip.Deathknight.Starter.Enable, Skip.Deathknight.Start.Level, Skip.Deathknight.Start.Trained, Skip.Deathknight.Optional.Enable, DeleteGold.Deathknight.Optional.Enable.

### SoloLfg.conf
SOLO LFG
SoloLFG.Enable
Description: Enable the module
Default:     1  - (Enabled)
0  - (Disabled)
SoloLFG.Announce

Sample keys: SoloLFG.Enable, SoloLFG.Announce, SoloLFG.FixedXP, SoloLFG.FixedXPRate.

### transmog.conf
Transmogrification config
SETTINGS
Transmogrification.Enable
Description: Enables/Disables transmog.
Players won't be able to see any transmogrified item while disabled, however, database data remains intact.
Default:     1

Sample keys: Transmogrification.Enable, Transmogrification.UseCollectionSystem, Transmogrification.UseVendorInterface, Transmogrification.AllowHiddenTransmog, Transmogrification.HiddenTransmogIsFree, Transmogrification.TrackUnusableItems, Transmogrification.RetroActiveAppearances, Transmogrification.ResetRetroActiveAppearancesFlag, Transmogrification.EnableTransmogInfo, Transmogrification.TransmogNpcText, Transmogrification.Allowed, Transmogrification.NotAllowed, Transmogrification.EnablePortable, Transmogrification.EnableSortByQualityAndName.

### who-logged.conf
PlayerLoginAnnounce
Description: This will show the console on what players are logged in
Default: 1
1 (Enabled)
0 (Disabled)
PlayerLogoutAnnounce

Sample keys: PlayerLoginAnnounce, PlayerLogoutAnnounce.

