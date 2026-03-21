HUD_LANG=${HUD_LANG:-zh}
HUD_MODEL=${HUD_MODEL:-opus}
HUD_VERSION="v0.1"

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$BASE_DIR/lang/${HUD_LANG}.sh"
source "$BASE_DIR/metrics/git.sh"
source "$BASE_DIR/metrics/context.sh"
source "$BASE_DIR/metrics/token.sh"
source "$BASE_DIR/metrics/cost.sh"
source "$BASE_DIR/metrics/resource.sh"
source "$BASE_DIR/metrics/session.sh"

render_hud() {
echo "[${L_MODEL}:${HUD_MODEL}] \
[${L_CTX}:$(context_count)] \
[${L_TIME}:$(session_time)] \
[${L_COST}:$(session_cost)] \
[${L_DIFF}:$(git_changes)] \
[${L_TOKEN}:$(session_tokens)] \
[${L_REQ}:$(request_count)] \
[${L_USAGE}:$(token_usage)] \
[${L_DIR}:$(basename "$PWD")] \
[${L_BRANCH}:$(git_branch)] \
[${L_VER}:${HUD_VERSION}] \
[${L_CPU}:$(cpu_usage)] \
[${L_MEM}:$(mem_usage)]"
}

PROMPT='$(render_hud)
➜ '
