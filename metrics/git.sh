git_changes() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return
  git status --porcelain | wc -l | tr -d ' '
}

git_diff_detail() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "+0 -0"; return; }
  local added=$(git diff --numstat 2>/dev/null | awk '{s+=$1} END {print s+0}')
  local removed=$(git diff --numstat 2>/dev/null | awk '{s+=$2} END {print s+0}')
  echo "+${added} -${removed}"
}

git_branch() {
  git branch --show-current 2>/dev/null
}
