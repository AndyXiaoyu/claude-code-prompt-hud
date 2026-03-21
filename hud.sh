HUD_LANG=${HUD_LANG:-zh}
HUD_MODEL=${HUD_MODEL:-opus}
HUD_VERSION="v0.1"

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)"

source "$BASE_DIR/lang/${HUD_LANG}.sh"
source "$BASE_DIR/metrics/git.sh"
source "$BASE_DIR/metrics/context.sh"
source "$BASE_DIR/metrics/token.sh"
source "$BASE_DIR/metrics/cost.sh"
source "$BASE_DIR/metrics/resource.sh"
source "$BASE_DIR/metrics/session.sh"

render_hud() {
  "$BASE_DIR/bin/hud-statusline"
}
