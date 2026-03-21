# claude-code-prompt-hud

A real-time status line for [Claude Code](https://claude.ai/code) — displays live metrics (model, tokens, cost, git, CPU, and more) directly inside the Claude Code interface via the native `statusLine` API.

**Text mode:**
```
模型:opus ｜ 上下文:3 ｜ 时长:12m ｜ 费用:0.042 ｜ 变更:13 ｜ Token:4200 ｜ 请求:18 ｜ 用量:4200/200k ｜ 目录:my-project ｜ 路径:/Users/me/project ｜ 分支:main ｜ 版本:v0.1 ｜ CPU:23% ｜ 内存:312891
```

**Emoji mode:**
```
🤖 opus ｜ 📄 3 ｜ 🕙 12m ｜ 💲 0.042 ｜ +240 -43 ｜ ⚡ 4200 ｜ 🔄 18 ｜ 📊 4200/200k ｜ 📖 my-project ｜ 📂 /Users/me/project ｜ ⎇  main ｜ 🏷️  v0.1 ｜ ⚙️  23% ｜ 💾 312891
```

---

## Features

| # | Field | Emoji | Description |
|---|-------|-------|-------------|
| 1 | 模型 / MODEL | 🤖 | Current Claude model |
| 2 | 上下文 / CTX | 📄 | `context/*.md` file count |
| 3 | 时长 / TIME | 🕙 | Session elapsed time |
| 4 | 费用 / COST | 💲 | Estimated cost (tokens × $0.00001) |
| 5 | 变更 / DIFF | `+N -N` | Git added / removed lines |
| 6 | Token / TOKENS | ⚡ | Cumulative tokens this session |
| 7 | 请求 / REQ | 🔄 | Request count |
| 8 | 用量 / USAGE | 📊 | Token usage vs 200k window |
| 9 | 目录 / DIR | 📖 | Current directory name |
| 10 | 路径 / PATH | 📂 | Full working directory path |
| 11 | 分支 / BRANCH | ⎇ | Current git branch |
| 12 | 版本 / VER | 🏷️ | HUD version |
| 13 | CPU | ⚙️ | Total system CPU usage |
| 14 | 内存 / MEM | 💾 | Active memory pages |

---

## Requirements

- macOS
- zsh
- [Claude Code CLI](https://claude.ai/code)

---

## Install

```bash
git clone https://github.com/AndyXiaoyu/claude-code-prompt-hud.git
cd claude-code-prompt-hud
bash install.sh
source ~/.zshrc
```

The installer will:
1. Copy files to `~/.claude-code-prompt-hud`
2. Register the status line in `~/.claude/settings.json`
3. Add `~/.claude-code-prompt-hud/bin` to `PATH` in `~/.zshrc`

---

## CLI Commands

After install, use the `hud` command to configure:

```bash
hud lang zh          # Switch to Chinese (default)
hud lang en          # Switch to English

hud mode text        # Text mode: 模型:opus (default)
hud mode emoji       # Emoji mode: 🤖 opus

hud fields           # Interactive field selector
```

### Field Selector (`hud fields`)

```
字段配置（输入编号切换，回车保存）:

  [ 1]  ✓  模型/MODEL
  [ 2]  ✓  上下文/CTX
  [ 3]  ✓  时长/TIME
  [ 4]  ✓  费用/COST
  [ 5]  ✓  变更/DIFF
  [ 6]  ✓  Token/TOKENS
  [ 7]  ✓  请求/REQ
  [ 8]  ✓  用量/USAGE
  [ 9]  ✓  目录/DIR
  [10]  ✓  路径/PATH
  [11]  ✓  分支/BRANCH
  [12]  ✓  版本/VER
  [13]  ✓  CPU/CPU
  [14]  ✓  内存/MEM

  输入编号（exit 退出不保存）: _
```

Type a number to toggle a field on/off. Press Enter to save, type `exit` to quit without saving.

---

## Uninstall

```bash
bash ~/.claude-code-prompt-hud/uninstall.sh
source ~/.zshrc
```

Removes `~/.claude-code-prompt-hud`, restores `~/.claude/settings.json`, and cleans up `~/.zshrc`.

---

## Project Structure

```
claude-code-prompt-hud/
├── bin/
│   ├── hud                 # CLI: lang / mode / fields commands
│   └── hud-statusline      # Status line renderer (called by Claude Code)
├── lang/
│   ├── zh.sh               # Chinese labels
│   └── en.sh               # English labels
├── metrics/
│   ├── context.sh          # Context file count
│   ├── cost.sh             # Cost estimation
│   ├── git.sh              # Git status, branch, diff detail
│   ├── resource.sh         # CPU & memory
│   ├── session.sh          # Session elapsed time
│   └── token.sh            # Token & request count
├── graph/
│   └── token_graph.sh      # ASCII bar chart renderer
├── rightpane/
│   └── files.sh            # File watcher (tmux right pane)
├── sessions/
│   └── agents.sh           # Active Claude session list
├── install.sh
└── uninstall.sh
```

---

## How It Works

Claude Code's native `statusLine` API calls `bin/hud-statusline` on each prompt refresh. The script reads lightweight local data sources:

| Data | Source |
|------|--------|
| Token count | `/tmp/claude_tokens` |
| Request count | `/tmp/claude_req` |
| Session time | `/tmp/claude_hud_session` |
| Context files | `context/*.md` in `$PWD` |
| Git branch / diff | `git branch`, `git diff --numstat` |
| CPU | `ps -A` |
| Memory | `vm_stat` |

Config is stored at `~/.claude-code-prompt-hud/config`:

```
HUD_LANG=zh
HUD_MODE=text
HUD_FIELDS=MODEL,CTX,TIME,COST,DIFF,TOKEN,REQ,USAGE,DIR,PATH,BRANCH,VER,CPU,MEM
```

---

## License

MIT
