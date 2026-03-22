# claude-code-prompt-hud 项目记忆

## 项目概述

- macOS zsh 下的 Claude Code 实时状态栏工具
- 通过 `statusLine` API 在 Claude Code 界面展示模型、Token、费用、Git、CPU 等信息
- 安装目录：`~/.claude-code-prompt-hud/`
- 配置文件：`~/.claude-code-prompt-hud/config`（`HUD_LANG`, `HUD_MODE`, `HUD_FIELDS`）

## 关键文件

| 文件 | 说明 |
|------|------|
| `bin/hud` | CLI 入口，负责 lang/mode/fields/tree 子命令 |
| `bin/hud-statusline` | 状态栏主脚本，写入 `/tmp/claude_hud_pwd` |
| `metrics/token.sh` | 从 `~/.claude/projects/*/*.jsonl` 读取 token/请求数 |
| `rightpane/files.sh` | tmux 右侧分屏目录树，监听 `/tmp/claude_hud_pwd` 自动刷新 |

## 历史修改记录

### 2026-03-22

1. **README 说明顺序修正**
   - 原文：cd → 启动 Claude Code → `! hud tree`
   - 修正为：cd → `hud tree` → 启动 Claude Code
   - commit: `20f15c0`

2. **token/request 指标重写**（`metrics/token.sh`）
   - 原来读 `/tmp/claude_tokens` 和 `/tmp/claude_req` 临时文件
   - 改为直接解析 `~/.claude/projects/*/*.jsonl` 获取准确数据

3. **rightpane/files.sh 重写**
   - 原来只显示 `ls -t` 列表
   - 改为完整目录树（最大深度5），带 git status 标记（M/A/D）
   - 监听 `/tmp/claude_hud_pwd` 自动切换项目目录

4. **`bin/hud-statusline` 写入 PWD**
   - 每次刷新将 `$PWD` 写入 `/tmp/claude_hud_pwd`，供 rightpane 同步

5. **`echo` 多字节 bug 修复**（`bin/hud`）
   - 问题：bash `echo` 在 `zh_CN.UTF-8` locale 下处理含多字节 UTF-8 + 变量展开的字符串时，会吞掉变量值和后续字节
   - 现象：`当前: zh）` 显示为 `当前: ）`（`zh` 和 `）` 第一字节丢失）
   - 修复：将两行 `echo` 改为 `printf "%s)\n" "$VAR"` 形式
   - commit: `e94fa81`

## 注意事项

- `source <(tr -d '\r' < "$CONFIG")` 在 bash 中**无法**将变量传递给当前 shell，已还原为 `source "$CONFIG"`
- config 文件本身无 CRLF，原始 `\r` 假设有误
- `echo` 的多字节 bug 只在特定字符串长度+locale 组合下触发，`printf` 是更安全的替代
