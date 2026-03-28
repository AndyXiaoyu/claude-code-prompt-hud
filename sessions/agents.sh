agents_list() {
  ls /tmp/claude_session_* 2>/dev/null | xargs -n1 basename | sed 's/claude_session_//' | tr '\n' ',' | sed 's/,$//'
}

# 从最新 JSONL 中统计近期工具调用（最近 10 条 assistant 消息）
recent_tools() {
  local jsonl
  jsonl=$(ls -t ~/.claude/projects/*/*.jsonl 2>/dev/null | head -1)
  [ -z "$jsonl" ] && echo "" && return
  python3 -c "
import json, sys, collections
lines = open('$jsonl').readlines()
assistant_msgs = []
for l in lines:
    try:
        d = json.loads(l)
        if d.get('message',{}).get('role') == 'assistant':
            assistant_msgs.append(d)
    except: pass
counts = collections.Counter()
for d in assistant_msgs[-10:]:
    for blk in d.get('message',{}).get('content',[]):
        if isinstance(blk,dict) and blk.get('type')=='tool_use':
            counts[blk.get('name','?')] += 1
if counts:
    print(','.join(f'{k}:{v}' for k,v in counts.most_common(3)))
" 2>/dev/null
}

# 活跃 agent 数量（subagent type tool calls）
active_agents() {
  local jsonl
  jsonl=$(ls -t ~/.claude/projects/*/*.jsonl 2>/dev/null | head -1)
  [ -z "$jsonl" ] && echo 0 && return
  python3 -c "
import json
lines = open('$jsonl').readlines()
count = 0
for l in lines[-50:]:
    try:
        d = json.loads(l)
        for blk in d.get('message',{}).get('content',[]):
            if isinstance(blk,dict) and blk.get('type')=='tool_use' and blk.get('name')=='Agent':
                count += 1
    except: pass
print(count)
" 2>/dev/null || echo 0
}
