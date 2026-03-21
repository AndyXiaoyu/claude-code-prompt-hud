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
