#!/usr/bin/env bash
#
# Разворачивает указатели на .agentic-coding в файлы инструкций разных агентов.
# Идемпотентен: повторный запуск обновляет только блок между маркерами.
#
set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR_NAME="$(basename "$SELF_DIR")"
ROOT="${AGENTIC_ROOT:-$(cd "$SELF_DIR/.." && pwd)}"
VERSION="$(cat "$SELF_DIR/VERSION" 2>/dev/null || echo "0.0.0")"

BEGIN_MARK="<!-- BEGIN agentic-coding -->"
END_MARK="<!-- END agentic-coding -->"

# Файлы с общим содержимым: правим только блок между маркерами.
SHARED_TARGETS=(
  "CLAUDE.md"                        # Claude Code
  "AGENTS.md"                        # Codex, Amp, Jules и прочие, читающие AGENTS.md
  "GEMINI.md"                        # Gemini CLI
  ".github/copilot-instructions.md"  # GitHub Copilot
)

# Чужие управляемые блоки, которые инструменты дописывают в те же файлы и
# которые конфликтуют с процессом из workflow/. Формат: "НАЧАЛО|КОНЕЦ|чей".
FOREIGN_BLOCKS=(
  "<!-- BACKLOG.MD GUIDELINES START -->|<!-- BACKLOG.MD GUIDELINES END -->|Backlog.md"
)

# Файлы, которыми система владеет целиком.
OWNED_TARGETS=(
  ".cursor/rules/agentic-coding.mdc" # Cursor
)

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

usage() {
  cat <<USAGE
$DIR_NAME/install.sh – развернуть указатели для агентов

Использование:
  ./install.sh              установить или обновить во всех целях
  ./install.sh --update     подтянуть upstream (git pull) и переустановить
  ./install.sh --check      проверить актуальность, ничего не менять (код 1 если устарело)
  ./install.sh --remove     удалить блоки и файлы, созданные системой
  ./install.sh --list       показать цели и их состояние
  ./install.sh --bootstrap  показать шаги первичной настройки под новый проект
  ./install.sh --strip-foreign  вырезать чужие управляемые блоки из файлов инструкций
  ./install.sh --only FILE  работать только с указанной целью
  ./install.sh --help       эта справка

Корень проекта определяется как родитель папки $DIR_NAME
(переопределяется переменной AGENTIC_ROOT).
USAGE
}

render_block() {
  # Подставляет плейсхолдеры в шаблон указателя.
  sed -e "s|{{DIR}}|$DIR_NAME|g" -e "s|{{VERSION}}|$VERSION|g" "$SELF_DIR/adapters/pointer.md"
}

build_shared_block() {
  { printf '%s\n' "$BEGIN_MARK"; render_block; printf '%s\n' "$END_MARK"; } > "$TMP_DIR/block"
}

build_owned_file() {
  {
    printf -- '---\ndescription: Agentic coding workflow\nalwaysApply: true\n---\n\n'
    render_block
  } > "$TMP_DIR/owned"
}

has_markers() {
  grep -qF "$BEGIN_MARK" "$1" 2>/dev/null
}

extract_block() {
  # Печатает существующий блок вместе с маркерами.
  awk -v b="$BEGIN_MARK" -v e="$END_MARK" '
    index($0, b) { inside = 1 }
    inside       { print }
    inside && index($0, e) { exit }
  ' "$1"
}

validate_markers() {
  local file="$1"
  if has_markers "$file" && ! grep -qF "$END_MARK" "$file"; then
    echo "ОШИБКА: в $file есть открывающий маркер без закрывающего. Почини вручную." >&2
    exit 2
  fi
}

upsert_shared() {
  local rel="$1" file="$ROOT/$1"
  validate_markers "$file"

  if [ ! -f "$file" ]; then
    mkdir -p "$(dirname "$file")"
    cat "$TMP_DIR/block" > "$file"
    echo "  создан   $rel"
    return
  fi

  if has_markers "$file"; then
    if diff -q <(extract_block "$file") "$TMP_DIR/block" >/dev/null 2>&1; then
      echo "  актуален $rel"
      return
    fi
    awk -v b="$BEGIN_MARK" -v e="$END_MARK" -v f="$TMP_DIR/block" '
      index($0, b) { while ((getline line < f) > 0) print line; close(f); skip = 1; next }
      skip && index($0, e) { skip = 0; next }
      !skip { print }
    ' "$file" > "$TMP_DIR/out"
    mv "$TMP_DIR/out" "$file"
    echo "  обновлён $rel"
  else
    printf '\n' >> "$file"
    cat "$TMP_DIR/block" >> "$file"
    echo "  дополнен $rel"
  fi
}

upsert_owned() {
  local rel="$1" file="$ROOT/$1"
  mkdir -p "$(dirname "$file")"
  if [ -f "$file" ] && diff -q "$file" "$TMP_DIR/owned" >/dev/null 2>&1; then
    echo "  актуален $rel"
    return
  fi
  local verb="создан"
  [ -f "$file" ] && verb="обновлён"
  cat "$TMP_DIR/owned" > "$file"
  echo "  $verb $rel"
}

state_shared() {
  local file="$ROOT/$1"
  if [ ! -f "$file" ];        then echo "отсутствует"; return; fi
  if ! has_markers "$file";   then echo "без блока";   return; fi
  if diff -q <(extract_block "$file") "$TMP_DIR/block" >/dev/null 2>&1
                              then echo "актуален";    else echo "устарел"; fi
}

state_owned() {
  local file="$ROOT/$1"
  if [ ! -f "$file" ]; then echo "отсутствует"; return; fi
  if diff -q "$file" "$TMP_DIR/owned" >/dev/null 2>&1
       then echo "актуален"; else echo "устарел"; fi
}

remove_shared() {
  local rel="$1" file="$ROOT/$1"
  [ -f "$file" ] || return 0
  has_markers "$file" || { echo "  пропущен $rel (нет блока)"; return 0; }
  validate_markers "$file"
  awk -v b="$BEGIN_MARK" -v e="$END_MARK" '
    index($0, b) { skip = 1; next }
    skip && index($0, e) { skip = 0; next }
    !skip { print }
  ' "$file" > "$TMP_DIR/out"
  if [ -s "$TMP_DIR/out" ] && grep -q '[^[:space:]]' "$TMP_DIR/out"; then
    mv "$TMP_DIR/out" "$file"
    echo "  блок убран $rel"
  else
    rm -f "$file"
    echo "  удалён   $rel (остался пустым)"
  fi
}

remove_owned() {
  local rel="$1" file="$ROOT/$1"
  [ -f "$file" ] && { rm -f "$file"; echo "  удалён   $rel"; } || true
}

# --- чужие блоки ---------------------------------------------------------

foreign_found() {
  # печатает "файл|чей" для каждого найденного чужого блока
  local rel file spec b e who
  for rel in "${SHARED_TARGETS[@]}"; do
    file="$ROOT/$rel"
    [ -f "$file" ] || continue
    for spec in "${FOREIGN_BLOCKS[@]}"; do
      b="${spec%%|*}"; who="${spec##*|}"; e="${spec#*|}"; e="${e%%|*}"
      grep -qF "$b" "$file" && echo "$rel|$who"
    done
  done
  return 0   # иначе статус последнего grep уронит скрипт под set -e
}

strip_foreign() {
  local rel file spec b e who removed=0
  for rel in "${SHARED_TARGETS[@]}"; do
    file="$ROOT/$rel"
    [ -f "$file" ] || continue
    for spec in "${FOREIGN_BLOCKS[@]}"; do
      b="${spec%%|*}"; who="${spec##*|}"; e="${spec#*|}"; e="${e%%|*}"
      grep -qF "$b" "$file" || continue
      grep -qF "$e" "$file" || { echo "  ПРОПУЩЕН $rel – блок $who без закрывающего маркера" >&2; continue; }
      awk -v b="$b" -v e="$e" '
        index($0, b) { skip = 1; next }
        skip && index($0, e) { skip = 0; next }
        !skip { print }
      ' "$file" > "$TMP_DIR/out"
      mv "$TMP_DIR/out" "$file"
      echo "  вырезан  блок $who из $rel"
      removed=1
    done
  done
  [ "$removed" -eq 1 ] || echo "  чужих блоков нет"
}

# --- навыки -----------------------------------------------------------------

skill_names() {
  [ -d "$SELF_DIR/skills" ] || return 0
  for d in "$SELF_DIR"/skills/*/; do
    [ -f "$d/SKILL.md" ] || continue
    basename "$d"
  done
}

gemini_toml() {
  # SKILL.md -> .toml для Gemini CLI
  awk '
    /^---$/ { d++; next }
    d == 1 && /^description:/ { sub(/^description:[ ]*/, ""); desc = $0; next }
    d >= 2 { body = body $0 "\n" }
    END {
      gsub(/"/, "\\\"", desc)
      gsub(/\$ARGUMENTS/, "{{args}}", body)
      printf "description = \"%s\"\n\nprompt = \"\"\"\n%s\"\"\"\n", desc, body
    }
  ' "$1"
}

deploy_skills() {
  local n
  for n in $(skill_names); do
    local link="$ROOT/.claude/skills/$n"
    mkdir -p "$(dirname "$link")"
    local want="../../$DIR_NAME/skills/$n"
    if [ -L "$link" ] && [ "$(readlink "$link")" = "$want" ]; then
      echo "  актуален .claude/skills/$n"
    elif [ -e "$link" ] && [ ! -L "$link" ]; then
      echo "  ПРОПУЩЕН .claude/skills/$n – существует и не является симлинком" >&2
    else
      ln -sfn "$want" "$link"
      echo "  связан   .claude/skills/$n"
    fi

    local toml="$ROOT/.gemini/commands/ac/$n.toml"
    mkdir -p "$(dirname "$toml")"
    gemini_toml "$SELF_DIR/skills/$n/SKILL.md" > "$TMP_DIR/toml"
    if [ -f "$toml" ] && diff -q "$toml" "$TMP_DIR/toml" >/dev/null 2>&1; then
      echo "  актуален .gemini/commands/ac/$n.toml"
    else
      cp "$TMP_DIR/toml" "$toml"
      echo "  записан  .gemini/commands/ac/$n.toml"
    fi
  done
}

state_skills() {
  local n ok=0 bad=0
  for n in $(skill_names); do
    local link="$ROOT/.claude/skills/$n"
    if [ -L "$link" ] && [ "$(readlink "$link")" = "../../$DIR_NAME/skills/$n" ]; then ok=$((ok+1)); else bad=$((bad+1)); fi
    local toml="$ROOT/.gemini/commands/ac/$n.toml"
    gemini_toml "$SELF_DIR/skills/$n/SKILL.md" > "$TMP_DIR/toml"
    if [ -f "$toml" ] && diff -q "$toml" "$TMP_DIR/toml" >/dev/null 2>&1; then ok=$((ok+1)); else bad=$((bad+1)); fi
  done
  if [ "$bad" -eq 0 ]; then echo "актуальны ($ok)"; else echo "не развёрнуто ($bad из $((ok+bad)))"; fi
}

remove_skills() {
  local n
  for n in $(skill_names); do
    local link="$ROOT/.claude/skills/$n"
    if [ -L "$link" ] && case "$(readlink "$link")" in *"$DIR_NAME/skills/"*) true ;; *) false ;; esac; then
      rm -f "$link"; echo "  удалён   .claude/skills/$n"
    fi
    rm -f "$ROOT/.gemini/commands/ac/$n.toml"
  done
  rmdir "$ROOT/.gemini/commands/ac" 2>/dev/null || true
  rmdir "$ROOT/.gemini/commands" 2>/dev/null || true
  rmdir "$ROOT/.gemini" 2>/dev/null || true
  rmdir "$ROOT/.claude/skills" 2>/dev/null || true
}

# --- хуки --------------------------------------------------------------------
#
# Процесс из workflow/ агент читает, когда берёт задачу. При микрофиксе задачи
# нет – и правила с конституцией до него не доезжали. Хук SessionStart кладёт
# весь свод правил в контекст на старте сессии, независимо от процесса.
#
# Пишем в settings.local.json: по конвенции Claude Code этот файл личный и не
# коммитится, а хук – личная оснастка, как и вся папка.

HOOK_SETTINGS=".claude/settings.local.json"
HOOK_MARK="$DIR_NAME/hooks/"

hooks_desired() {
  # source=resume отсекается и матчером, и самим скриптом: при возобновлении
  # прошлая вставка уже лежит в расшифровке.
  jq -n --arg cmd "\"\$CLAUDE_PROJECT_DIR\"/$DIR_NAME/hooks/inject-rules.sh" '{
    SessionStart: [
      { matcher: "startup|clear|compact",
        hooks: [ { type: "command", command: $cmd, timeout: 15 } ] }
    ]
  }'
}

have_jq() { command -v jq >/dev/null 2>&1; }

hooks_ours() {
  # наши записи, как они лежат в файле настроек
  local file="$ROOT/$HOOK_SETTINGS"
  if [ ! -f "$file" ]; then echo "{}"; return 0; fi
  jq -S --arg mark "$HOOK_MARK" '
    (.hooks // {})
    | to_entries
    | map(.value = (.value
        | map(.hooks = ((.hooks // []) | map(select((.command // "") | contains($mark)))))
        | map(select((.hooks | length) > 0))))
    | map(select((.value | length) > 0))
    | from_entries
  ' "$file" 2>/dev/null || echo "null"
}

state_hooks() {
  if ! have_jq; then echo "нужен jq"; return 0; fi
  local have want
  have="$(hooks_ours)"
  if [ "$have" = "null" ]; then echo "$HOOK_SETTINGS не читается"; return 0; fi
  want="$(hooks_desired | jq -S .)"
  if   [ "$have" = "$want" ]; then echo "актуален"
  elif [ "$have" = "{}" ];    then echo "не установлен"
  else                             echo "устарел"; fi
}

write_hooks() {
  # оставляет чужие записи на месте, свои переписывает
  local file="$ROOT/$HOOK_SETTINGS" current='{}'
  if [ -f "$file" ]; then current="$(cat "$file")"; fi
  printf '%s' "$current" | jq --arg mark "$HOOK_MARK" --argjson want "$(hooks_desired)" "$1" > "$TMP_DIR/settings"
  mkdir -p "$(dirname "$file")"
  mv "$TMP_DIR/settings" "$file"
}

JQ_UPSERT='
  def drop_ours:
    to_entries
    | map(.value = (.value
        | map(.hooks = ((.hooks // []) | map(select(((.command // "") | contains($mark)) | not))))
        | map(select((.hooks | length) > 0))))
    | map(select((.value | length) > 0))
    | from_entries;
  .hooks = ((.hooks // {}) | drop_ours)
  | reduce ($want | keys_unsorted[]) as $k (.; .hooks[$k] = ((.hooks[$k] // []) + $want[$k]))
'

JQ_STRIP='
  def drop_ours:
    to_entries
    | map(.value = (.value
        | map(.hooks = ((.hooks // []) | map(select(((.command // "") | contains($mark)) | not))))
        | map(select((.hooks | length) > 0))))
    | map(select((.value | length) > 0))
    | from_entries;
  .hooks = ((.hooks // {}) | drop_ours)
  | if (.hooks | length) == 0 then del(.hooks) else . end
'

deploy_hooks() {
  if [ ! -x "$SELF_DIR/hooks/inject-rules.sh" ]; then
    echo "  ПРОПУЩЕН $HOOK_SETTINGS – нет $DIR_NAME/hooks/inject-rules.sh" >&2
    return 0
  fi
  if ! have_jq; then
    echo "  ПРОПУЩЕН $HOOK_SETTINGS – нужен jq, поставь его и запусти ещё раз" >&2
    return 0
  fi
  local before; before="$(state_hooks)"
  if [ "$before" = "актуален" ]; then
    echo "  актуален $HOOK_SETTINGS (хук правил)"
    return 0
  fi
  if [ -f "$ROOT/$HOOK_SETTINGS" ] && ! jq -e . "$ROOT/$HOOK_SETTINGS" >/dev/null 2>&1; then
    echo "  ПРОПУЩЕН $HOOK_SETTINGS – файл не является корректным JSON, починить вручную" >&2
    return 0
  fi
  write_hooks "$JQ_UPSERT"
  echo "  записан  $HOOK_SETTINGS (хук правил – подхватится в новой сессии)"
}

remove_hooks() {
  local file="$ROOT/$HOOK_SETTINGS"
  [ -f "$file" ] || return 0
  if ! have_jq; then
    echo "  ПРОПУЩЕН $HOOK_SETTINGS – нужен jq, чтобы убрать хук" >&2
    return 0
  fi
  if [ "$(hooks_ours)" = "{}" ]; then return 0; fi
  write_hooks "$JQ_STRIP"
  if [ "$(jq -S . "$file")" = "{}" ]; then
    rm -f "$file"
    echo "  удалён   $HOOK_SETTINGS (остался пустым)"
  else
    echo "  хук убран $HOOK_SETTINGS"
  fi
}

# --- обновление из upstream --------------------------------------------------

update_self() {
  if [ ! -d "$SELF_DIR/.git" ]; then
    echo "ОШИБКА: $DIR_NAME не git-клон – обновлять нечем." >&2
    echo "Установка через git clone описана в $DIR_NAME/README.md." >&2
    exit 2
  fi
  echo "  git pull в $DIR_NAME"
  git -C "$SELF_DIR" pull --ff-only
  VERSION="$(cat "$SELF_DIR/VERSION" 2>/dev/null || echo "0.0.0")"
}

# --- первичная настройка ---------------------------------------------------

bootstrap_steps() {
  cat <<STEPS

Первичная настройка под новый проект – три шага, все выполняет агент.

  1. Язык оператора       ->  $DIR_NAME/rules/project/communication.md
     Агент спрашивает, на каком языке с вами говорить, и записывает ответ вместе
     с фиксированными формулировками (строка согласования, шаблон отчёта).
     Ни один upstream-файл язык человека не называет – только этот.

       Claude Code, Gemini CLI:   /setup-language
       Любой другой агент:        Прочитай $DIR_NAME/skills/setup-language/SKILL.md и выполни.

  2. Конституция проекта  ->  $DIR_NAME/rules/project/CONSTITUTION.md
     Вы формулируете принципы, агент оформляет их с примерами и обоснованием.

       Claude Code, Gemini CLI:   /setup-constitution
       Любой другой агент:        Прочитай $DIR_NAME/skills/setup-constitution/SKILL.md и выполни.

  3. Описание проекта     ->  $DIR_NAME/context/
     Вы в двух предложениях говорите, о чём проект; агент исследует код и
     заполняет overview, architecture, structure, commands.

       Claude Code, Gemini CLI:   /setup-context
       Любой другой агент:        Прочитай $DIR_NAME/skills/setup-context/SKILL.md и выполни.

  4. Правила под проект   ->  $DIR_NAME/rules/project/*.md
     Заполняются не сразу, а по мере работы. Метод – в rules/project/README.md.

Хранилище задач (Backlog.md) ставится отдельно:

  backlog init "<Проект>" --agent-instructions none --install-claude-agent false

  Флаги важны: без них backlog допишет в CLAUDE.md свой CRITICAL-блок, чей
  встроенный процесс перепрыгивает гейт согласования. Подробности и что делать,
  если блок уже появился – в $DIR_NAME/README.md.
STEPS
}

MODE="install"
ONLY=""
while [ $# -gt 0 ]; do
  case "$1" in
    --update) MODE="update" ;;
    --check)  MODE="check" ;;
    --remove) MODE="remove" ;;
    --list)   MODE="list" ;;
    --bootstrap) MODE="bootstrap" ;;
    --strip-foreign) MODE="strip" ;;
    --only)   shift; ONLY="${1:-}" ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Неизвестный аргумент: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

selected() { [ -z "$ONLY" ] || [ "$ONLY" = "$1" ]; }

if [ "$MODE" = "update" ]; then
  echo "$DIR_NAME → $ROOT"
  update_self
  MODE="install"
fi

build_shared_block
build_owned_file

echo "$DIR_NAME v$VERSION → $ROOT"

case "$MODE" in
  bootstrap)
    bootstrap_steps
    exit 0
    ;;
  strip)
    strip_foreign
    exit 0
    ;;
  install)
    for t in "${SHARED_TARGETS[@]}"; do selected "$t" && upsert_shared "$t"; done
    for t in "${OWNED_TARGETS[@]}";  do selected "$t" && upsert_owned  "$t"; done
    if [ -z "$ONLY" ]; then
      if [ -n "$(foreign_found || true)" ]; then
        echo "  --- чужие инструкции, конфликтующие с процессом:"
        strip_foreign
      fi
      deploy_skills
      deploy_hooks
    fi
    mkdir -p "$SELF_DIR/rules/project"
    if [ -z "$ONLY" ] && { [ ! -f "$SELF_DIR/rules/project/CONSTITUTION.md" ] || [ -z "$(ls -A "$SELF_DIR/context" 2>/dev/null | grep -v '^\.')" ]; }; then
      bootstrap_steps
    else
      echo
      echo "Готово. Шаги первичной настройки: ./$DIR_NAME/install.sh --bootstrap"
    fi
    ;;
  list|check)
    rc=0
    for t in "${SHARED_TARGETS[@]}"; do
      selected "$t" || continue
      s="$(state_shared "$t")"; printf '  %-34s %s\n' "$t" "$s"
      [ "$s" = "актуален" ] || rc=1
    done
    for t in "${OWNED_TARGETS[@]}"; do
      selected "$t" || continue
      s="$(state_owned "$t")"; printf '  %-34s %s\n' "$t" "$s"
      [ "$s" = "актуален" ] || rc=1
    done
    if [ -z "$ONLY" ]; then
      s="$(state_skills)"; printf '  %-34s %s\n' "навыки" "$s"
      case "$s" in актуальны*) ;; *) rc=1 ;; esac
      s="$(state_hooks)"; printf '  %-34s %s\n' "хук правил" "$s"
      [ "$s" = "актуален" ] || rc=1
    fi
    found="$(foreign_found || true)"
    if [ -n "$found" ]; then
      while IFS='|' read -r rel who; do
        [ -n "$rel" ] || continue
        printf '  %-34s %s\n' "$rel" "конфликтующий блок $who – ./install.sh --strip-foreign"
      done <<< "$found"
      rc=1
    fi
    if [ "$MODE" = "check" ]; then exit $rc; fi
    ;;
  remove)
    for t in "${SHARED_TARGETS[@]}"; do selected "$t" && remove_shared "$t"; done
    for t in "${OWNED_TARGETS[@]}";  do selected "$t" && remove_owned  "$t"; done
    if [ -z "$ONLY" ]; then remove_skills; remove_hooks; fi
    ;;
esac
