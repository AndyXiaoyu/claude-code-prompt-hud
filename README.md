# claude-code-prompt-hud

A real-time status line for [Claude Code](https://claude.ai/code) — displays live metrics (model, tokens, cost, git, CPU, and more) directly inside the Claude Code interface via the native `statusLine` API. Refreshes every ~300ms.

**第1行 — Text mode:**
```
模型: claude-sonnet-4-6｜上下文: 3｜时长: 12m｜费用: 0.042｜变更: +13 -2｜Token: 4200｜请求: 18｜目录: my-project｜路径: /Users/me/project｜分支: main｜版本: v0.1｜CPU: 23%｜内存: 312891
```

**第1行 — Emoji mode:**
```
🤖 claude-sonnet-4-6｜📄 3｜🕙 12m｜💲 0.042｜+240 -43｜⚡ 4200｜🔄 18｜📂 /Users/me/project｜⎇ main｜🏷️ v0.1｜⚙️ 23%｜💾 312891
```

**第2行 — 进度条（始终显示）：**
```
上下文 ████░░░░░░ 42% (84k/200k) │ 速率 ██░░░░░░░░ 25% (20000/min) │ 用量 █░░░░░░░░░ 15% (45m / 5h)
```

**第2行 — 7天窗口（用量≥80% 时自动出现，免费/周付账户）：**
```
上下文 ████████░░ 85% (170k/200k) │ 速率 ████░░░░░░ 45% (36000/min) │ 用量 ████████░░ 85% (4h 15m / 5h) │ 7天 ██████████ 85% (2d / 7d)
```

进度条颜色随用量变化：🟢 绿（<60%）→ 🟡 黄（60-85%）→ 🔴 红（≥85%）

---

## Features

### 第1行字段

| # | Field | Emoji | Description |
|---|-------|-------|-------------|
| 1 | 模型 / MODEL | 🤖 | 从 JSONL 自动检测真实模型名（claude-sonnet-4-6、gpt-4o 等） |
| 2 | 上下文 / CTX | 📄 | `context/*.md` file count |
| 3 | 时长 / TIME | 🕙 | Session elapsed time |
| 4 | 费用 / COST | 💲 | Estimated cost (tokens × $0.00001) |
| 5 | 变更 / DIFF | `+N -N` | Git added / removed lines |
| 6 | Token / TOKENS | ⚡ | Cumulative tokens this session |
| 7 | 请求 / REQ | 🔄 | Request count |
| 8 | 目录 / DIR | 📖 | Current directory name |
| 9 | 路径 / PATH | 📂 | Full working directory path |
| 10 | 分支 / BRANCH | ⎇ | Current git branch |
| 11 | 版本 / VER | 🏷️ | HUD version |
| 12 | CPU | ⚙️ | Total system CPU usage |
| 13 | 内存 / MEM | 💾 | Active memory pages |

### 第2行进度条（固定显示）

| 栏目 | 说明 | 上限配置 |
|------|------|----------|
| 上下文 | 已用 token / 上下文窗口（按模型自动推断，支持 200k / 128k / 1M） | 自动 |
| 速率 | 当前 token/min 速率 / 上限 | `HUD_RATE_MAX`（默认 80000） |
| 用量 | 会话已用时间 / 窗口时长 | `HUD_SESSION_WINDOW_MIN`（默认 300，即 5h） |
| 7天 | 过去 7 天 token 用量 / 上限（免费/周付账户专属） | `HUD_WEEK_TOKEN_MAX`（默认不显示） |

> **7天条显示条件**：`HUD_WEEK_TOKEN_MAX` > 0 且当前用量 ≥ `HUD_WEEK_THRESHOLD`（默认 80%）

### 模型上下文窗口自动推断

| 模型 | 上下文窗口 |
|------|------------|
| claude-\* | 200k |
| gpt-4o / gpt-4-turbo | 128k |
| gpt-4 | 8k |
| gpt-3.5 | 16k |
| gemini-1.5 / gemini-2 | 1M |
| deepseek-\* / qwen-\* | 128k |
| 其他 | 200k |

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
2. Register the status line in `~/.claude/settings.json` (with `intervalMs: 300`)
3. Add `~/.claude-code-prompt-hud/bin` to `PATH` in `~/.zshrc`

---

## CLI Commands

After install, use the `hud` command to configure:

```bash
hud lang zh          # 切换中文（默认）
hud lang en          # Switch to English
hud mode text        # Text mode（默认）
hud mode emoji       # Emoji mode
hud fields           # 交互式配置显示字段
hud tree             # 左侧分屏显示目录树
hud tree right       # 右侧分屏显示目录树
```

---

## Configuration

Config file: `~/.claude-code-prompt-hud/config`

```bash
HUD_LANG=zh
HUD_MODE=text
HUD_FIELDS=MODEL,CTX,TIME,COST,DIFF,TOKEN,REQ,DIR,PATH,BRANCH,VER,CPU,MEM
```

### 第2行进度条调参

```bash
# 速率进度条上限（tokens/min），超过此值显示红色 100%
HUD_RATE_MAX=80000

# 用量窗口时长（分钟），默认 300 = 5 小时
HUD_SESSION_WINDOW_MIN=300

# 7天 token 上限（免费/周付账户填写，0 = 不显示此栏）
HUD_WEEK_TOKEN_MAX=0

# 7天条触发阈值：用量超过此百分比时才显示（默认 80）
HUD_WEEK_THRESHOLD=80
```

---

## Uninstall

```bash
bash uninstall.sh
```

---

## Project Structure

```
clause-code-prompt-hud/
├── bin/
│   ├── hud                 # CLI 入口（lang/mode/fields/tree）
│   └── hud-statusline      # 状态栏渲染（第1行 + 第2行）
├── lang/
│   ├── zh.sh               # 中文标签
│   └── en.sh               # English labels
├── metrics/
│   ├── context.sh          # context/*.md 文件计数
│   ├── cost.sh             # 费用估算
│   ├── git.sh              # Git branch / diff
│   ├── resource.sh         # CPU / 内存
│   ├── session.sh          # 会话时长 / 用量进度条 / 7天窗口
│   └── token.sh            # Token 计数 / 模型检测 / 速率 / 上下文进度条
├── graph/
│   └── token_graph.sh      # ASCII 折线图
├── rightpane/
│   └── files.sh            # 文件监控（tmux 右侧面板）
├── sessions/
│   └── agents.sh           # 工具/代理活动解析
├── install.sh
└── uninstall.sh
```

---

## How It Works

Claude Code 的 `statusLine` API 每 300ms 调用一次 `bin/hud-statusline`，脚本从本地轻量数据源读取：

| Data | Source |
|------|--------|
| Model name | `~/.claude/projects/*/*.jsonl` (`message.model`) |
| Token count | `~/.claude/projects/*/*.jsonl` (usage 字段求和) |
| Request count | `~/.claude/projects/*/*.jsonl` |
| 7-day tokens | 全部 JSONL 文件，按 `timestamp` 过滤 7 天内 |
| Session time | `/tmp/claude_hud_session` |
| Context files | `context/*.md` in `$PWD` |
| Git branch / diff | `git branch`, `git diff --numstat` |
| CPU | `ps -A` |
| Memory | `vm_stat` |

---

## License

MIT
