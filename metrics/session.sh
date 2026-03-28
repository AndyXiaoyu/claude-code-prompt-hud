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
