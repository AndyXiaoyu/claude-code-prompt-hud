#!/bin/bash

HUD_PATH="$HOME/.claude-code-prompt-hud"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
CONFIG="$HUD_PATH/config"

mkdir -p "$HUD_PATH/bin"
cp -r bin lang metrics graph rightpane sessions "$HUD_PATH/"
chmod +x "$HUD_PATH/bin/hud-statusline"
chmod +x "$HUD_PATH/bin/hud"

# 创建默认配置（如已存在则不覆盖）
if [ ! -f "$CONFIG" ]; then
  cat > "$CONFIG" <<EOF
HUD_LANG=zh
HUD_MODE=text
HUD_FIELDS=MODEL,CTX,TIME,COST,DIFF,TOKEN,REQ,DIR,PATH,BRANCH,VER,CPU,MEM
EOF
fi

# 写入 Claude Code statusLine 配置
if [ -f "$CLAUDE_SETTINGS" ]; then
  python3 -c "
import json
with open('$CLAUDE_SETTINGS') as f:
    s = json.load(f)
s['statusLine'] = {'command': '$HUD_PATH/bin/hud-statusline', 'padding': 0, 'type': 'command'}
with open('$CLAUDE_SETTINGS', 'w') as f:
    json.dump(s, f, indent=2, ensure_ascii=False)
"
else
  echo '{"statusLine":{"command":"'"$HUD_PATH/bin/hud-statusline"'","padding":0,"type":"command"}}' > "$CLAUDE_SETTINGS"
fi

# 添加 bin 到 PATH（如未添加）
if ! grep -q "claude-code-prompt-hud/bin" ~/.zshrc; then
  echo "export PATH=\"\$HOME/.claude-code-prompt-hud/bin:\$PATH\"" >> ~/.zshrc
fi

echo "Installed claude-code-prompt-hud"
echo "运行 'source ~/.zshrc' 后即可使用 hud 命令"
