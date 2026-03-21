context_count() {
ls context/*.md 2>/dev/null | wc -l | tr -d ' '
}
