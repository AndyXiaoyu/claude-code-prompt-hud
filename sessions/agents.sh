agents_list() {
ls /tmp/claude_session_* 2>/dev/null | xargs -n1 basename | sed 's/claude_session_//' | tr '\n' ',' | sed 's/,$//'
}
