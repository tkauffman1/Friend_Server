# Server operator quick reference

Plain-language notes for this AzerothCore server. After you change any config, **restart `worldserver.exe`** (and `authserver.exe` only if you changed `configs/authserver.conf`). Keep backups before editing.

---

## How to set XP rates (everyone on the server)

**File:** `configs/worldserver.conf`

Search for **`Rate.XP`**. These multiply experience:

| Setting | What it affects |
|--------|------------------|
| `Rate.XP.Kill` | XP from killing mobs |
| `Rate.XP.Quest` | XP from quests |
| `Rate.XP.Quest.DF` | XP from Dungeon Finder / LFG quests only |
| `Rate.XP.Explore` | XP for discovering new areas |
| `Rate.XP.Pet` | Pet XP |

**Example:** double quest XP only → set `Rate.XP.Quest = 2` (leave others at `1` if you want).

**Remember:** `1` = normal (Blizzlike multiplier). Values like `2` or `3` mean 2× or 3×.

Related global rates in the same file:

- **`Rate.Honor`** — honor from PvP
- **`Rate.Reputation.Gain`** — reputation
- **`Rate.Drop.Item.*`** — loot chance by quality (Poor through Artifact)
- **`Rate.Drop.Money`** — copper from creature loot
- **`Rate.Rest.*`** — how fast rested XP builds

---

## Per-level or per-player XP (optional modules)

If you use **dynamic XP by level band**, see **`configs/modules/dynamicxp.conf`**: enable `Dynamic.XP.Rate = 1` and set `Dynamic.XP.Rate.10-19`, `Dynamic.XP.Rate.20-29`, etc.

If you use **individual XP** (different rate per account/character), see **`configs/modules/individual_xp.conf`** and enable `IndividualXp.Enabled` — that system uses its own rules on top of world rates.

---

## How to change the level cap (Vanilla / TBC / WotLK feel)

**File:** `configs/worldserver.conf` → **`MaxPlayerLevel`**

| Goal | Typical value |
|------|----------------|
| Classic cap | `60` |
| TBC cap | `70` |
| Full WotLK | `80` |

**Individual Progression** (phased content) is separate: **`configs/modules/individualProgression.conf`**

- **`ProgressionLimit`** — stops players from advancing past a progression *stage* (`0` = no limit through endgame; your server used `7` to stay in the Vanilla phase per module docs).
- **`StartingProgression`** — snap *new* progression to a stage (testing or catch-up).
- Stages are defined in the module’s source (`IndividualProgression.h`), not in this repo. Your config comments mention **7** (Vanilla), **8** (TBC-related), **13** (WotLK / DK-related).

**Important:** progression is also stored in the **database**. Changing configs does not rewind players’ unlocked phases.

---

## How to tune random playerbots

**File:** `configs/modules/playerbots.conf`

| You want | Look at |
|----------|---------|
| How many bots in the world | `AiPlayerbot.MinRandomBots`, `AiPlayerbot.MaxRandomBots` |
| Max level bots can reach | `AiPlayerbot.RandomBotMaxLevel` (should not exceed `MaxPlayerLevel` in worldserver) |
| Bots only in Eastern Kingdoms + Kalimdor | `AiPlayerbot.RandomBotMaps = 0,1` |
| Include Outland + Northrend | add `530` and `571` → e.g. `0,1,530,571` |
| Bots start at level 1, not random levels | `AiPlayerbot.DisableRandomLevels = 1`, `AiPlayerbot.RandombotStartingLevel = 1` |
| Bot max level follows online players | `AiPlayerbot.SyncLevelWithPlayers = 1` |

**Randombot accounts** are excluded from Individual Progression when `ExcludeAccounts` is on, but level is still capped by **`IndividualProgression.ExcludedAccountsMaxLevel`** in `individualProgression.conf` — keep it equal to **`MaxPlayerLevel`** so bots do not outlevel players.

If you change bot rules heavily, you may need to re-randomize bots (see mod-playerbots docs for commands like rndbot init).

---

## How to reduce CPU load from bots (starting points)

Same file: `configs/modules/playerbots.conf`

Ideas that trade responsiveness for CPU:

- Lower **`AiPlayerbot.IterationsPerTick`**
- Raise **`AiPlayerbot.RandomBotUpdateInterval`** (seconds between manager runs)
- Lower **`AiPlayerbot.RandomBotsPerInterval`**
- Set **`AiPlayerbot.FastReactInBG = 0`**
- Fewer maps in **`AiPlayerbot.RandomBotMaps`** if you do not need bots in Outland/Northrend

**Worldserver** performance knobs (see comments in `worldserver.conf`): `MapUpdateInterval`, `MapUpdate.Threads`, `ThreadPool`, visibility distances, etc.

---

## How to set auth / realm settings

**File:** `configs/authserver.conf`

Ports, bind address, and login database connection. Change only if you know your network layout.

---

## Where everything else lives

- **One module = one file** under `configs/modules/` (e.g. transmog, solo LFG, auction bot). Open the file and read the comments at the top; most are self-describing.
- **Large defaults** for the world server are also in `configs/worldserver.conf.dist` — copy patterns from there if you reset a section.

---

## Quick checklist: our current custom tuning (summary)

| Topic | Where | What we set (approx.) |
|-------|--------|------------------------|
| Level cap | `worldserver.conf` | `MaxPlayerLevel = 60` |
| IP phase cap | `individualProgression.conf` | `ProgressionLimit = 7`, bot cap `ExcludedAccountsMaxLevel = 60` |
| Bots | `playerbots.conf` | 600 bots, max level 60, maps `0,1`, sync with players, some CPU tweaks |

---

## Regenerate the Word version of this guide

From the repo root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Build-OperatorGuideDocx.ps1
```

That updates `docs/Server_Operator_Guide.docx` from this Markdown file.
