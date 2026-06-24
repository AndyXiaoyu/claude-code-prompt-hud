_latest_jsonl() {
  if [ -n "$HUD_TRANSCRIPT_PATH" ] && [ -f "$HUD_TRANSCRIPT_PATH" ]; then
    echo "$HUD_TRANSCRIPT_PATH"
    return
  fi
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

# --- 模型自动检测 ---
detect_model() {
  local jsonl model
  [ -n "$HUD_STATUS_MODEL" ] && echo "$HUD_STATUS_MODEL" && return
  jsonl=$(_latest_jsonl)
  [ -z "$jsonl" ] && echo "${HUD_MODEL:-unknown}" && return
  model=$(grep -o '"model":"[^"]*"' "$jsonl" 2>/dev/null | tail -1 | grep -o '"[^"]*"$' | tr -d '"')
  [ -z "$model" ] && echo "${HUD_MODEL:-unknown}" && return
  echo "$model"
}

# 根据模型名推断上下文窗口大小（tokens）
model_context_window() {
  local model="$1"
  case "$model" in
    # Claude 1M 上下文（未来扩展）
    *claude*1m*)                    echo 1000000 ;;
    # Claude 3.7
    *claude-3-7*)                   echo 200000  ;;
    # Claude 3.5 / 3
    *claude-3*)                     echo 200000  ;;
    # Claude 4.x / Sonnet / Opus / Haiku
    *claude*)                       echo 200000  ;;
    # GPT-4o / GPT-4 Turbo
    *gpt-4o*|*gpt-4-turbo*)        echo 128000  ;;
    # GPT-4
    *gpt-4*)                        echo 8192    ;;
    # GPT-3.5
    *gpt-3.5*)                      echo 16385   ;;
    # Gemini 1.5
    *gemini-1.5*)                   echo 1000000 ;;
    # Gemini 2.x
    *gemini-2*)                     echo 1000000 ;;
    # Gemini
    *gemini*)                       echo 128000  ;;
    # DeepSeek
    *deepseek*)                     echo 128000  ;;
    # Qwen
    *qwen*)                         echo 128000  ;;
    # 默认
    *)                              echo 200000  ;;
  esac
}

_latest_xshell_stats() {
  local stats_dir="$HOME/.claude/xshell-stats"
  [ -d "$stats_dir" ] || return
  if [ -n "$HUD_STATUS_SESSION_ID" ] && [ -f "$stats_dir/$HUD_STATUS_SESSION_ID.json" ]; then
    echo "$stats_dir/$HUD_STATUS_SESSION_ID.json"
    return
  fi
  ls -t "$stats_dir"/*.json 2>/dev/null | head -1
}

_context_window_from_stats() {
  local stats
  stats=$(_latest_xshell_stats)
  [ -z "$stats" ] && return
  python3 - "$stats" <<'PY' 2>/dev/null
import json
import sys

try:
    data = json.load(open(sys.argv[1]))
    value = data.get("context_window", {}).get("context_window_size")
    value = int(value)
    if value > 0:
        print(value)
except Exception:
    pass
PY
}

_context_used_tokens_from_stats() {
  local stats
  stats=$(_latest_xshell_stats)
  [ -z "$stats" ] && return
  python3 - "$stats" <<'PY' 2>/dev/null
import json
import sys

try:
    data = json.load(open(sys.argv[1]))
    ctx = data.get("context_window", {})
    current = ctx.get("current_usage")
    if isinstance(current, dict):
        total = sum(int(current.get(k) or 0) for k in (
            "input_tokens",
            "output_tokens",
            "cache_creation_input_tokens",
            "cache_read_input_tokens",
        ))
    else:
        total = int(ctx.get("total_input_tokens") or 0) + int(ctx.get("total_output_tokens") or 0)
    if total >= 0:
        print(total)
except Exception:
    pass
PY
}

_context_percent_from_stats() {
  local stats
  stats=$(_latest_xshell_stats)
  [ -z "$stats" ] && return
  python3 - "$stats" <<'PY' 2>/dev/null
import json
import sys

try:
    data = json.load(open(sys.argv[1]))
    value = data.get("context_window", {}).get("used_percentage")
    if value is None:
        raise ValueError
    value = int(value)
    if value < 0:
        value = 0
    if value > 100:
        value = 100
    print(value)
except Exception:
    pass
PY
}

_positive_int_or_empty() {
  case "$1" in
    ''|*[!0-9]*) return ;;
  esac
  [ "$1" -gt 0 ] && echo "$1"
}

_nonnegative_int_or_empty() {
  case "$1" in
    ''|*[!0-9]*) return ;;
  esac
  echo "$1"
}

# --- 上下文进度条 ---
_get_context_window() {
  local model window
  window=$(_positive_int_or_empty "$HUD_CONTEXT_WINDOW_SIZE")
  [ -n "$window" ] && echo "$window" && return
  window=$(_context_window_from_stats)
  [ -n "$window" ] && echo "$window" && return
  model=$(detect_model)
  model_context_window "$model"
}

context_used_tokens() {
  local tokens
  tokens=$(_nonnegative_int_or_empty "$HUD_CONTEXT_USED_TOKENS")
  [ -n "$tokens" ] && echo "$tokens" && return
  tokens=$(_context_used_tokens_from_stats)
  [ -n "$tokens" ] && echo "$tokens" && return
  session_tokens
}

context_percent() {
  local tokens window pct
  pct=$(_nonnegative_int_or_empty "$HUD_CONTEXT_USED_PERCENT")
  if [ -n "$pct" ]; then
    [ "$pct" -gt 100 ] && pct=100
    echo "$pct"
    return
  fi
  pct=$(_context_percent_from_stats)
  [ -n "$pct" ] && echo "$pct" && return
  tokens=$(context_used_tokens)
  window=$(_get_context_window)
  pct=$(( tokens * 100 / window ))
  [ "$pct" -gt 100 ] && pct=100
  echo "$pct"
}

format_tokens_compact() {
  local value="$1"
  if [ "$value" -ge 1000000 ]; then
    if [ $(( value % 1000000 )) -eq 0 ]; then
      echo "$(( value / 1000000 ))M"
    else
      awk "BEGIN {printf \"%.1fM\", $value/1000000}"
    fi
  else
    echo "$(( value / 1000 ))k"
  fi
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
  local tokens window
  tokens=$(context_used_tokens)
  window=$(_get_context_window)
  echo "$(format_tokens_compact "$tokens")/$(format_tokens_compact "$window")"
}

# 每分钟 token 速率
# HUD_RATE_MAX 为速率上限（tokens/min），默认 80000
HUD_RATE_MAX=${HUD_RATE_MAX:-80000}

token_rate_per_min() {
  local tokens start now elapsed
  tokens=$(session_tokens)
  start=$(cat /tmp/claude_hud_session 2>/dev/null || date +%s)
  now=$(date +%s)
  elapsed=$(( now - start ))
  [ "$elapsed" -eq 0 ] && elapsed=1
  # 换算成每分钟（用秒精度避免短会话除零）
  echo "$(( tokens * 60 / elapsed ))"
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
