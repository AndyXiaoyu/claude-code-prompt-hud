git_changes() {
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return
git status --porcelain | wc -l | tr -d ' '
}

git_branch() {
git branch --show-current 2>/dev/null
}
