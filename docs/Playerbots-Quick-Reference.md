# Playerbots quick reference (AzerothCore + mod-playerbots)

Short commands, account linking, macros, and **how to create a new game account** on the server.

---

## Create a new game account

Use one of these (your build may only support some of them):

- **Authserver or worldserver console** (the terminal running the server process), type:
  ```text
  account create <accountName> <password>
  ```
  If that is unknown, try the same on the **other** process (auth vs world), or check your `worldserver` / `authserver` help output.

- **In-game (GM / RBAC)** — if enabled on your realm:
  ```text
  .account create <accountName> <password>
  ```

- **MySQL** — possible by inserting into `acore_auth.account` with a proper **SRP** password (not plain text). Prefer console commands unless you know the schema. **Backup first.**

After creating accounts, you can use **linking** below so the main account can control altbots on other accounts.

**Character slot limits** are in `configs/worldserver.conf`: `CharactersPerRealm`, `CharactersPerAccount` (account-wide must be ≥ per-realm). Restart `worldserver` after changes.

---

## Config prerequisites (server)

- **Trusted altbots from other accounts:** `configs/modules/playerbots.conf`  
  - `AiPlayerbot.AllowTrustedAccountBots = 1`  
- **Alts on same account auto-log as bots when you log in (optional):**  
  - `AiPlayerbot.BotAutologin = 0` (no auto-login; use `.playerbots bot add` when you want them). Set `1` if you want every alt on the account to log in as a bot with you.  
- Restart **worldserver** after editing.

Full command list (upstream): [Playerbot Commands](https://github.com/mod-playerbots/mod-playerbots/wiki/Playerbot-Commands)

---

## Account linking (altbot control across accounts)

Requires **`AllowTrustedAccountBots = 1`**.

1. On the account that **defines the key** (e.g. main), in-game:
   ```text
   .playerbots account setKey YourSecretHere
   ```
   Setting a new key **overwrites** the old one.

2. On the **other** account (e.g. dedicated bot account), in-game (replace with real names):
   ```text
   .playerbots account link MainAccountLoginName YourSecretHere
   ```
   - `MainAccountLoginName` = **account login** (not character name) for the account that ran `setKey`.  
   - `YourSecretHere` = the **same** secret as in step 1 (this proves trust).

3. List links:
   ```text
   .playerbots account linkedAccounts
   ```

4. Remove a link (both sides):
   ```text
   .playerbots account unlink OtherAccountLoginName
   ```

---

## Altbots: log in / out

- By character name:
  ```text
  .playerbots bot add Name1,Name2,Name3
  ```

- **Entire account** (e.g. after linking):
  ```text
  .playerbots bot addaccount SomeAccountLoginName
  ```

- All altbots that are in **party/raid**:
  ```text
  .playerbots bot add *
  .playerbots bot remove *
  ```

- Remove by name:
  ```text
  .playerbots bot remove Name1
  ```

- **AddClass** (pool randombots, good for quick tests — not a long-term “roster”):
  ```text
  .playerbots bot addclass warrior
  ```
  (Use class names per wiki; death knight is often `dk`.)

- **Alt maintenance / gear** (whisper, party, or raid; often):
  - `maintenance`  
  - `autogear`  
  - `talents spec list` / `talents spec <name>`

---

## Hand-made alts: level 60 + autogear (you created every character)

The mod does **not** level characters for you by itself; you either use **GM**, **init=auto** (sync to *your* level), or play/quest.

### 1) Get them to level 60

**A — GM (fast, on live or offline chars)**  
Use your server’s level command (RBAC 2+), often like:

```text
.character level BotCharacterName 60
```

(Exact name may be `.char level` or `.level` — see [GM commands](https://www.azerothcore.org/wiki/gm-commands).)  
Repeat per character, or target each bot in turn if your build supports that.

**B — Match your own level (you are 60)**  
On your **60** main, add the bots, then (per [mod wiki](https://github.com/mod-playerbots/mod-playerbots/wiki/Playerbot-Commands)) try:

```text
.playerbots bot init=auto Char1,Char2,Char3
```

That re-initializes those bots to align with your level/gear (read the in-game / wiki warning: heavy reset–style; back up or test on one toon first).

**C — Play normally** (slow): group and quest with shared XP.

### 2) Autogear + spells after they are 60

1. **Party:** `/p autogear` (or whisper each bot `autogear`)  
2. **Party:** `/p maintenance` (spells, talents, consumables, repair, enchants, etc. — depends on `AltMaintenance*` in `playerbots.conf`)  

Tuning: `AiPlayerbot.AutoGearQualityLimit`, `AiPlayerbot.AutoGearScoreLimit` in `configs/modules/playerbots.conf` (item level ceiling; `0` = no ilvl cap).

### 3) Server level cap

Your `MaxPlayerLevel` in `worldserver.conf` must be **at least 60** (or 70 for full TBC). If the cap is below 60, bots cannot “finish” at 60.

---

## Party / movement / combat (use `/p`, `/r`, or `/w` as your setup expects)

| Action        | Example |
|---------------|---------|
| Follow        | `/p follow` |
| By role       | `/p @tank follow` · `/p @heal follow` |
| Summon        | `/p summon` or `/w CharName summon` |
| Attack        | `/p attack` · `/p @dps attack` |
| Stay          | `/p stay` |
| Co strategies | `/p co +aoe` / `/p co -boost` (see mod wiki) |
| Raid strats   | `/p co +karazhan` (instance-specific; see wiki) |

**Summon to instance (GM + players):** `configs/worldserver.conf` → `Instance.GMSummonPlayer` (`1` = GM can summon non-GM players into instance).

---

## Macros (paste in Macro UI)

**Party follow**

```text
/p follow
```

**Tanks and healers**

```text
/p @tank,@heal follow
```

**Summon (if bots listen on party)**

```text
/p summon
```

**DPS attack**

```text
/p @dps attack
```

**Burst (combat “boost” strategy)**

```text
/p co +boost
```

```text
/p co -boost
```

**Note:** `.playerbots …` **account** commands are usually **not** put in character macros; run them in chat once. Slash-dot commands need the right **account/GM permissions** on your server.

---

## Worldserver console (rare; operator only)

- Reload playerbots config: `playerbot rndbot reload`  
- Heavier randombot maintenance: `playerbot rndbot init` (destructive / heavy — read mod docs)

Exact names may differ slightly by mod fork; if a line fails, check in-server `help` or the mod’s wiki.

---

## One-line notepad block

```text
account create NewAccountName NewPassword
.playerbots account setKey YOURKEY
.playerbots account link MainAccountName YOURKEY
.playerbots account linkedAccounts
.playerbots bot addaccount BotAccountLoginName
/p follow | /p summon | /p @dps attack | /p maintenance
```

---

## Draenei / Blood Elf blocked on one account (Tyler works, Tyler2 does not)

This is almost always the **`acore_auth.account.expansion`** field (per-account, **not** `worldserver.conf` and often **not** Individual Progression after you set `TbcRacesUnlockProgression = 0`).

| `expansion` | Meaning | Draenei & Blood Elf |
|------------|---------|----------------------|
| **0** | “Classic” addon | **Not allowed** at character creation |
| **1** | TBC | **Allowed** |
| **2** | WotLK (default in stock DB) | **Allowed** |

**Check (MySQL, auth DB):**

```sql
SELECT `id`, `username`, `expansion` FROM `account` WHERE LOWER(`username`) IN ('tyler', 'tyler2');
```

**Fix Tyler2 (pick one):**

- **SQL:** `UPDATE `account` SET `expansion` = 2 WHERE LOWER(`username`) = 'tyler2';` (run on **`acore_auth`**, not characters).  
- **In-game (GM, sec 2+):** `.account set addon tyler2 2` (syntax per [GM commands](https://www.azerothcore.org/wiki/gm-commands); some builds use `account` name or id).

Log out to character list and try creating the Draenei again.

---

*Adjust names, keys, and permissions for your realm.*
