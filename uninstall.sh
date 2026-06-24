#!/bin/bash

HUD_PATH="$HOME/.claude-code-prompt-hud"
CLAUDE_SETTINGS="$HOME/.claude/settings.local.json"

rm -rf "$HUD_PATH"

if [ -f "$CLAUDE_SETTINGS" ]; then
  python3 -c "
import json
with open('$CLAUDE_SETTINGS') as f:
    s = json.load(f)
s.pop('statusLine', None)
with open('$CLAUDE_SETTINGS', 'w') as f:
    json.dump(s, f, indent=2, ensure_ascii=False)
"
fi

sed -i '' '/claude-code-prompt-hud\/bin/d' ~/.zshrc

# 移除 Claude Code slash commands
COMMANDS_DIR="$HOME/.claude/commands"
rm -f "$COMMANDS_DIR/hud.md"
rm -f "$COMMANDS_DIR/hud-lang.md"
rm -f "$COMMANDS_DIR/hud-mode.md"
rm -f "$COMMANDS_DIR/hud-fields.md"
rm -f "$COMMANDS_DIR/hud-tree.md"

echo "Uninstalled claude-code-prompt-hud"
