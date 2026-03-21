HUD_PATH="$HOME/.claude-code-agent-prompt-hud"

mkdir -p $HUD_PATH
cp -r * $HUD_PATH

echo "export HUD_LANG=zh" >> ~/.zshrc
echo "export HUD_MODEL=opus" >> ~/.zshrc
echo "source $HUD_PATH/hud.sh" >> ~/.zshrc

echo "Installed claude-code-agent-prompt-hud"
