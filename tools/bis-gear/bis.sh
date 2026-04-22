#!/usr/bin/env bash
# bis.sh — Build AzerothCore SQL that mails BiS items from data/tbc-p1/<slug>.csv
#
# Writes a .sql file; run it on your `characters` database (or --apply + MYSQL_CMD).
# On Windows Git Bash: window stays open at the end (set BIS_NO_PAUSE=1 to disable).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/bis-last-run.log"

# Keep the console open on Windows (success or failure) so you can read errors.
if [[ -n "${WINDIR:-}" && -z "${BIS_NO_PAUSE:-}" ]]; then
  trap 'st=$?; echo ""; cmd.exe //c pause; exit $st' EXIT
fi

bis_main() {
  set -euo pipefail

  # Do not use `exec > >(tee ...)` here — it breaks on some Git-Bash-on-Windows setups (window closes, no SQL).

  DATA_DIR="${DATA_DIR:-$SCRIPT_DIR/data/tbc-p1}"
  ALIAS_FILE="${ALIAS_FILE:-$SCRIPT_DIR/class-spec-aliases.tsv}"
  OUT_DIR="${OUT_DIR:-$SCRIPT_DIR/sql/generated}"
  PS_SCRIPT="$SCRIPT_DIR/Export-BisSql.ps1"

  CLASS_INPUT=""
  CHAR_NAME=""
  INCLUDE_ALTS=0
  APPLY_SQL=0

  usage() {
    cat <<'USAGE'
bis.sh — Build SQL to mail TBC Phase 1 BiS (AzerothCore)

  ./bis.sh -c "restoration druid" -n CharacterName
  ./bis.sh --class paladin-protection --name Tank --include-alternates

Options:
  -c, --class    Class/spec phrase (lowercase) or exact slug
  -n, --name     In-game character name (mail recipient)
  --data-dir     Override BiS CSV folder (default: data/tbc-p1)
  --include-alternates   Include AltItemId column from CSV
  --apply        Run generated SQL via MYSQL_CMD (set env first; dangerous)

Environment: MYSQL_CMD   e.g. mysql -h 127.0.0.1 -u acore -pacore acore_characters

CSV: data/tbc-p1/<slug>.csv — Aliases: class-spec-aliases.tsv
USAGE
    exit 0
  }

  resolve_slug() {
    local q raw
    raw="$1"
    q="$(echo "$raw" | tr '[:upper:]' '[:lower:]' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/[[:space:]]\+/ /g')"
    [[ -z "$q" ]] && return 1

    if [[ ! -f "$ALIAS_FILE" ]]; then
      echo "Missing alias file: $ALIAS_FILE" >&2
      return 1
    fi

    while IFS= read -r line || [[ -n "$line" ]]; do
      [[ "$line" =~ ^[[:space:]]*# ]] && continue
      [[ -z "${line// }" ]] && continue
      slug="${line%%	*}"
      rest="${line#*	}"
      slug="${slug// /}"
      IFS=',' read -ra syns <<< "$rest"
      for s in "${syns[@]}"; do
        t="$(echo "$s" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
        [[ "$q" == "$t" ]] && { echo "$slug"; return 0; }
      done
    done < "$ALIAS_FILE"

    if [[ -f "$DATA_DIR/${q}.csv" ]]; then
      echo "$q"
      return 0
    fi

    return 1
  }

  find_powershell() {
    if command -v pwsh >/dev/null 2>&1; then echo "pwsh"; return; fi
    if command -v powershell.exe >/dev/null 2>&1; then echo "powershell.exe"; return; fi
    if [[ -n "${WINDIR:-}" && -x "${WINDIR}/System32/WindowsPowerShell/v1.0/powershell.exe" ]]; then
      echo "${WINDIR}/System32/WindowsPowerShell/v1.0/powershell.exe"
      return
    fi
    echo "" >&2
    return 1
  }

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help) usage ;;
      -c|--class) CLASS_INPUT="$2"; shift 2 ;;
      -n|--name|--char) CHAR_NAME="$2"; shift 2 ;;
      --data-dir) DATA_DIR="$2"; shift 2 ;;
      --include-alternates) INCLUDE_ALTS=1; shift ;;
      --apply) APPLY_SQL=1; shift ;;
      *) echo "Unknown arg: $1" >&2; exit 2 ;;
    esac
  done

  if [[ -z "$CLASS_INPUT" || -z "$CHAR_NAME" ]]; then
    echo "Usage: $0 -c \"class spec\" -n CharacterName   (see --help)" >&2
    exit 2
  fi

  SLUG="$(resolve_slug "$CLASS_INPUT" || true)"
  if [[ -z "${SLUG:-}" ]]; then
    echo "Could not resolve class/spec: \"$CLASS_INPUT\"" >&2
    echo "Try: exact slug (e.g. druid-restoration) or add a line to $ALIAS_FILE" >&2
    exit 3
  fi

  CSV_PATH="$DATA_DIR/${SLUG}.csv"
  if [[ ! -f "$CSV_PATH" ]]; then
    echo "No CSV for slug \"$SLUG\": expected $CSV_PATH" >&2
    echo "Run: powershell -File \"$SCRIPT_DIR/Initialize-TbcP1BisTemplates.ps1\" then fill ItemId column." >&2
    exit 4
  fi

  if ! grep -qE '^[^,]+,[^,]+,[0-9]' "$CSV_PATH" 2>/dev/null; then
    echo "CSV has no numeric ItemId values yet: $CSV_PATH" >&2
    echo "Add Wowhead TBC item IDs to the ItemId column, or try: -c \"protection paladin\"" >&2
    exit 7
  fi

  mkdir -p "$OUT_DIR"
  SAFE_CHAR="$(echo "$CHAR_NAME" | sed 's/[^a-zA-Z0-9_-]/_/g')"
  OUT_SQL="$OUT_DIR/tbc-p1-${SLUG}-${SAFE_CHAR}.sql"
  SUBJECT="TBC P1 BiS ${SLUG}"

  PS_BIN="$(find_powershell)" || { echo "PowerShell not found (install pwsh or use Generate-BisMail.ps1)." >&2; exit 5; }

  ARGS=(
    -NoProfile -ExecutionPolicy Bypass -File "$PS_SCRIPT"
    -CsvPath "$CSV_PATH"
    -CharacterName "$CHAR_NAME"
    -MailSubject "$SUBJECT"
  )

  if [[ "$INCLUDE_ALTS" -eq 1 ]]; then
    ARGS+=(-IncludeAlts)
  fi

  echo "Slug:    $SLUG" >&2
  echo "CSV:     $CSV_PATH" >&2
  echo "Character: $CHAR_NAME" >&2
  echo "Output:  $OUT_SQL" >&2

  {
    echo "-- TBC Phase 1 BiS mail SQL"
    echo "-- Spec: $SLUG"
    echo "-- Character: $CHAR_NAME"
    echo "-- Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo ""
    "$PS_BIN" "${ARGS[@]}"
  } > "$OUT_SQL"

  echo "Wrote $OUT_SQL" >&2
  echo "" >&2
  echo "Next step: run this file on your AzerothCore **characters** database (backup first)." >&2
  echo "  Example: mysql -h ... -u ... -p... acore_characters < \"$OUT_SQL\"" >&2
  echo "Full console log also saved to: $LOG_FILE" >&2

  if [[ "$APPLY_SQL" -eq 1 ]]; then
    if [[ -z "${MYSQL_CMD:-}" ]]; then
      echo "MYSQL_CMD is not set; cannot --apply. Example:" >&2
      echo "  export MYSQL_CMD='mysql -h 127.0.0.1 -u acore -pacore acore_characters'" >&2
      exit 6
    fi
    echo "Applying SQL via MYSQL_CMD ..." >&2
    eval "$MYSQL_CMD" < "$OUT_SQL"
    echo "Done." >&2
  else
    echo "Run on your characters database, e.g.:" >&2
    echo "  mysql ... acore_characters < \"$OUT_SQL\"" >&2
  fi
}

if [[ -n "${BIS_NO_LOG:-}" ]]; then
  bis_main "$@"
  exit $?
fi

set -o pipefail
bis_main "$@" 2>&1 | tee "$LOG_FILE"
code=${PIPESTATUS[0]}
exit "$code"
