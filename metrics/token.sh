_latest_jsonl() {
  ls -t ~/.claude/projects/*/*.jsonl 2>/dev/null | head -1
}

session_tokens() {
  local jsonl
  jsonl=$(_latest_jsonl)
  [ -z "$jsonl" ] && echo 0 && return
  grep -oE '"(input_tokens|output_tokens|cache_creation_input_tokens|cache_read_input_tokens)":[0-9]+' "$jsonl" \
    | awk -F: '{s+=$2} END {print s+0}'
}

request_count() {
  local jsonl
  jsonl=$(_latest_jsonl)
  [ -z "$jsonl" ] && echo 0 && return
  grep -c '"type":"assistant"' "$jsonl" 2>/dev/null || echo 0
}

token_usage() {
  echo "$(session_tokens)/200k"
}

# --- 上下文进度条 ---
CONTEXT_WINDOW_SIZE=200000

context_percent() {
  local tokens pct
  tokens=$(session_tokens)
  pct=$(( tokens * 100 / CONTEXT_WINDOW_SIZE ))
  [ "$pct" -gt 100 ] && pct=100
  echo "$pct"
}

context_bar() {
  local pct filled empty bar i
  pct=$(context_percent)
  filled=$(( pct * 10 / 100 ))
  [ "$filled" -gt 10 ] && filled=10
  empty=$(( 10 - filled ))
  bar=""
  i=0; while [ $i -lt $filled ]; do bar+="█"; i=$(( i+1 )); done
  i=0; while [ $i -lt $empty  ]; do bar+="░"; i=$(( i+1 )); done
  echo "$bar"
}

context_bar_color() {
  local pct
  pct=$(context_percent)
  if   [ "$pct" -ge 85 ]; then echo 196
  elif [ "$pct" -ge 60 ]; then echo 214
  else echo 82
  fi
}

context_tokens_k() {
  local tokens
  tokens=$(session_tokens)
  echo "$(( tokens / 1000 ))k/200k"
}

# 每分钟 token 速率
# HUD_RATE_MAX 为速率上限（tokens/min），默认 80000
HUD_RATE_MAX=${HUD_RATE_MAX:-80000}

token_rate_per_min() {
  local tokens start now elapsed minutes
  tokens=$(session_tokens)
  start=$(cat /tmp/claude_hud_session 2>/dev/null || date +%s)
  now=$(date +%s)
  elapsed=$(( now - start ))
  minutes=$(( elapsed / 60 ))
  [ "$minutes" -eq 0 ] && echo "-" && return
  echo "$(( tokens / minutes ))"
}

rate_percent() {
  local rate pct
  rate=$(token_rate_per_min)
  [ "$rate" = "-" ] && echo 0 && return
  pct=$(( rate * 100 / HUD_RATE_MAX ))
  [ "$pct" -gt 100 ] && pct=100
  echo "$pct"
}

rate_bar() {
  local pct filled empty bar i
  pct=$(rate_percent)
  filled=$(( pct * 10 / 100 ))
  [ "$filled" -gt 10 ] && filled=10
  empty=$(( 10 - filled ))
  bar=""
  i=0; while [ $i -lt $filled ]; do bar+="█"; i=$(( i+1 )); done
  i=0; while [ $i -lt $empty  ]; do bar+="░"; i=$(( i+1 )); done
  echo "$bar"
}

rate_bar_color() {
  local pct
  pct=$(rate_percent)
  if   [ "$pct" -ge 85 ]; then echo 196
  elif [ "$pct" -ge 60 ]; then echo 214
  else echo 82
  fi
}
