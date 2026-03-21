#!/bin/bash

HUD_PATH="$HOME/.claude-code-prompt-hud"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"

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

echo "Uninstalled claude-code-prompt-hud"
