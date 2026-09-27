#!/usr/bin/env bash
#
# Хук SessionStart: кладёт весь свод правил в контекст сессии.
#
# Зачем: процесс из workflow/ агент читает, только когда берёт задачу. При
# микрофиксе «поправь вот это» задачи нет, и правила с конституцией до агента не
# доезжали. Хук снимает это: правила в контексте с первого сообщения, независимо
# от того, идёт работа по процессу или мимо него.
#
# Ставится install.sh в .claude/settings.local.json.
# Посмотреть, что уйдёт в контекст:  .agentic-coding/hooks/inject-rules.sh --print
#
set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AC_DIR="$(cd "$SELF_DIR/.." && pwd)"
DIR_NAME="$(basename "$AC_DIR")"
RULES_DIR="$AC_DIR/rules"

# Потолок на объём. Если свод правил разрастётся, вместо текста уйдёт список
# файлов: лучше отправить агента читать, чем занять весь контекст правилами.
MAX_BYTES="${AGENTIC_RULES_MAX_BYTES:-140000}"

MODE="hook"
if [ "${1:-}" = "--print" ]; then MODE="print"; fi

# --- на каких запусках срабатывать ------------------------------------------
#
# source = resume: расшифровка уже содержит прошлую вставку, второй раз не надо.
# Матчер в настройках отсекает это же, но хук должен быть верен сам по себе.

if [ "$MODE" = "hook" ] && [ ! -t 0 ]; then
  payload="$(cat || true)"
  src=""
  if command -v jq >/dev/null 2>&1; then
    src="$(printf '%s' "$payload" | jq -r '.source // ""' 2>/dev/null || echo "")"
  else
    src="$(printf '%s' "$payload" | sed -n 's/.*"source"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
  fi
  if [ "$src" = "resume" ]; then exit 0; fi
fi

# --- какие файлы считаются правилами ----------------------------------------
#
# rules/project/README.md – методика написания правил, не правило. Не идёт.

rule_files() {
  local f
  if [ -f "$RULES_DIR/main.md" ]; then printf '%s\n' "$RULES_DIR/main.md"; fi
  if [ -f "$RULES_DIR/project/CONSTITUTION.md" ]; then printf '%s\n' "$RULES_DIR/project/CONSTITUTION.md"; fi
  for f in "$RULES_DIR"/project/*.md; do
    [ -f "$f" ] || continue
    case "$(basename "$f")" in README.md|CONSTITUTION.md) continue ;; esac
    printf '%s\n' "$f"
  done
  return 0
}

FILES="$(rule_files)"
if [ -z "$FILES" ]; then exit 0; fi

total=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  total=$(( total + $(wc -c < "$f") ))
done <<< "$FILES"

rel() { printf '%s' "$DIR_NAME/${1#"$AC_DIR/"}"; }

# --- вывод -------------------------------------------------------------------

# Заголовок и врезка про перерасход – в кавычечных heredoc'ах, подстановка
# через sed. Так внутри не может исполниться ни $, ни `бэктик`: один
# неэкранированный бэктик уже приводил к рекурсивному запуску самого хука.

cat <<'HEADER' | sed "s|@DIR@|$DIR_NAME|g"
# Coding rules of this project – in force for the whole session

Injected by `@DIR@/hooks/inject-rules.sh` at session start.

This is the project's complete rule set. It governs **every** change to code,
including a one-line fix asked for straight in chat with no task card and no
workflow step. There is no change small enough to be outside it. Read it before
your first edit, not after.

What this does not replace:

- what this project is, its architecture and commands – `@DIR@/context/`;
- the task process and its two approval gates – `@DIR@/workflow/`, starting
  with `00-overview.md`. Required as soon as there is a task card; a direct
  microfix in chat runs without it, but never without the rules below.

HEADER

if [ "$total" -gt "$MAX_BYTES" ]; then
  cat <<'OVER' | sed -e "s|@TOTAL@|$total|g" -e "s|@MAX@|$MAX_BYTES|g"
The rule set is @TOTAL@ bytes, over the @MAX@-byte inlining budget, so here is
the index instead. **Read every one of these files before your first edit.**

OVER
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    printf -- '- `%s` (%s bytes)\n' "$(rel "$f")" "$(wc -c < "$f")"
  done <<< "$FILES"
  exit 0
fi

while IFS= read -r f; do
  [ -n "$f" ] || continue
  printf '\n================ %s ================\n\n' "$(rel "$f")"
  cat "$f"
done <<< "$FILES"

printf '\n================ end of rules ================\n'
