SESSION_FILE=/tmp/claude_hud_session
[ ! -f $SESSION_FILE ] && date +%s > $SESSION_FILE

# 默认会话窗口：5小时（300分钟），可通过 HUD_SESSION_WINDOW_MIN 配置
HUD_SESSION_WINDOW_MIN=${HUD_SESSION_WINDOW_MIN:-300}

session_elapsed_min() {
  local start now
  start=$(cat $SESSION_FILE)
  now=$(date +%s)
  echo "$(( (now - start) / 60 ))"
}

session_time() {
  echo "$(session_elapsed_min)m"
}

usage_percent() {
  local elapsed pct
  elapsed=$(session_elapsed_min)
  pct=$(( elapsed * 100 / HUD_SESSION_WINDOW_MIN ))
  [ "$pct" -gt 100 ] && pct=100
  echo "$pct"
}

usage_bar() {
  local pct filled empty bar i
  pct=$(usage_percent)
  filled=$(( pct * 10 / 100 ))
  [ "$filled" -gt 10 ] && filled=10
  empty=$(( 10 - filled ))
  bar=""
  i=0; while [ $i -lt $filled ]; do bar+="█"; i=$(( i+1 )); done
  i=0; while [ $i -lt $empty  ]; do bar+="░"; i=$(( i+1 )); done
  echo "$bar"
}

usage_bar_color() {
  local pct
  pct=$(usage_percent)
  if   [ "$pct" -ge 85 ]; then echo 196
  elif [ "$pct" -ge 60 ]; then echo 214
  else echo 82
  fi
}

usage_time_display() {
  local elapsed total_h total_m elapsed_h elapsed_m
  elapsed=$(session_elapsed_min)
  total_h=$(( HUD_SESSION_WINDOW_MIN / 60 ))
  total_m=$(( HUD_SESSION_WINDOW_MIN % 60 ))
  elapsed_h=$(( elapsed / 60 ))
  elapsed_m=$(( elapsed % 60 ))
  local elapsed_str total_str
  if [ "$elapsed_h" -gt 0 ]; then
    elapsed_str="${elapsed_h}h ${elapsed_m}m"
  else
    elapsed_str="${elapsed_m}m"
  fi
  if [ "$total_m" -eq 0 ]; then
    total_str="${total_h}h"
  else
    total_str="${total_h}h ${total_m}m"
  fi
  echo "${elapsed_str} / ${total_str}"
}

# --- 7 天窗口（免费/周付账户） ---
# 7 天 token 总量上限，可通过 HUD_WEEK_TOKEN_MAX 配置（默认 0 = 不显示）
# 当用量百分比超过 HUD_WEEK_THRESHOLD（默认 80）时显示
HUD_WEEK_TOKEN_MAX=${HUD_WEEK_TOKEN_MAX:-0}
HUD_WEEK_THRESHOLD=${HUD_WEEK_THRESHOLD:-80}

# 统计过去 7 天所有 JSONL 文件中的 token 总量
week_tokens() {
  python3 -c "
import os, json, time, glob
cutoff = time.time() - 7*24*3600
total = 0
for f in glob.glob(os.path.expanduser('~/.claude/projects/*/*.jsonl')):
    try:
        for line in open(f):
            d = json.loads(line)
            ts = d.get('timestamp') or d.get('createdAt') or d.get('created_at','')
            if ts and ts < '1970': continue
            # ISO 8601 -> epoch
            import datetime
            try:
                t = datetime.datetime.fromisoformat(ts.replace('Z','+00:00')).timestamp()
            except: continue
            if t < cutoff: continue
            usage = d.get('message',{}).get('usage',{})
            for k in ('input_tokens','output_tokens','cache_creation_input_tokens','cache_read_input_tokens'):
                total += usage.get(k,0)
    except: pass
print(total)
" 2>/dev/null || echo 0
}

week_percent() {
  [ "$HUD_WEEK_TOKEN_MAX" -eq 0 ] && echo 0 && return
  local tokens pct
  tokens=$(week_tokens)
  pct=$(( tokens * 100 / HUD_WEEK_TOKEN_MAX ))
  [ "$pct" -gt 100 ] && pct=100
  echo "$pct"
}

week_bar() {
  local pct filled empty bar i
  pct=$(week_percent)
  filled=$(( pct * 10 / 100 ))
  [ "$filled" -gt 10 ] && filled=10
  empty=$(( 10 - filled ))
  bar=""
  i=0; while [ $i -lt $filled ]; do bar+="█"; i=$(( i+1 )); done
  i=0; while [ $i -lt $empty  ]; do bar+="░"; i=$(( i+1 )); done
  echo "$bar"
}

week_bar_color() {
  local pct
  pct=$(week_percent)
  if   [ "$pct" -ge 85 ]; then echo 196
  elif [ "$pct" -ge 60 ]; then echo 214
  else echo 82
  fi
}

WEEK_START_FILE=/tmp/claude_hud_week_start
[ ! -f "$WEEK_START_FILE" ] && date +%s > "$WEEK_START_FILE"

week_display() {
  [ "$HUD_WEEK_TOKEN_MAX" -eq 0 ] && echo "" && return
  local start now elapsed_sec elapsed_days
  start=$(cat "$WEEK_START_FILE" 2>/dev/null || date +%s)
  now=$(date +%s)
  elapsed_sec=$(( now - start ))
  elapsed_days=$(( elapsed_sec / 86400 ))
  [ "$elapsed_days" -gt 7 ] && elapsed_days=7
  echo "${elapsed_days}d / 7d"
}

# 是否显示 7 天条：HUD_WEEK_TOKEN_MAX>0 且 usage_percent >= HUD_WEEK_THRESHOLD
should_show_week() {
  [ "$HUD_WEEK_TOKEN_MAX" -eq 0 ] && return 1
  local upct
  upct=$(usage_percent)
  [ "$upct" -ge "$HUD_WEEK_THRESHOLD" ] && return 0
  return 1
}
