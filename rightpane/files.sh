#!/bin/bash

MAX_DEPTH=5
IGNORE="\.git|node_modules|\.DS_Store|__pycache__|\.pytest_cache|\.idea|\.vscode"
PWD_FILE="/tmp/claude_hud_pwd"

git_mark() {
  local rel="${1#$ROOT/}"
  local line
  line=$(printf '%s\n' "$GIT_STAT" | grep -F " $rel" | head -1)
  local s="${line:0:2}"
  case "$s" in
    " M"|"M "|"MM") printf ' \033[33m[M]\033[0m' ;;
    " A"|"A "|"AM") printf ' \033[32m[A]\033[0m' ;;
    "??")            printf ' \033[90m[?]\033[0m' ;;
    " D"|"D "|"DD") printf ' \033[31m[D]\033[0m' ;;
  esac
}

draw_tree() {
  local dir="$1" prefix="$2" depth="$3"
  [ "$depth" -ge "$MAX_DEPTH" ] && return

  local entries=()
  while IFS= read -r base; do
    echo "$base" | grep -qE "^($IGNORE)$" && continue
    entries+=("$dir/$base")
  done < <(ls -1A "$dir" 2>/dev/null | sort)

  local total=${#entries[@]} idx=0
  for entry in "${entries[@]}"; do
    idx=$((idx + 1))
    local base
    base=$(basename "$entry")
    local branch sub_prefix
    if [ "$idx" -eq "$total" ]; then
      branch="└── "; sub_prefix="${prefix}    "
    else
      branch="├── "; sub_prefix="${prefix}│   "
    fi

    if [ -d "$entry" ]; then
      printf "%s%s\033[34m%s\033[0m/\n" "$prefix" "$branch" "$base"
      draw_tree "$entry" "$sub_prefix" $((depth + 1))
    else
      local mark
      mark=$(git_mark "$entry")
      printf "%s%s%s%b\n" "$prefix" "$branch" "$base" "$mark"
    fi
  done
}

watch_tree() {
  local last_root=""
  while true; do
    local current_root
    if [ -f "$PWD_FILE" ]; then
      current_root=$(cat "$PWD_FILE")
    else
      current_root="$PWD"
    fi
    if [ "$current_root" != "$last_root" ] && [ -d "$current_root" ]; then
      ROOT="$current_root"
      GIT_STAT=$(git -C "$ROOT" status --porcelain 2>/dev/null)
      clear
      printf "\033[1;32m%s/\033[0m\n" "$(basename "$ROOT")"
      draw_tree "$ROOT" "" 0
      last_root="$current_root"
    fi
    sleep 1
  done
}

watch_tree
