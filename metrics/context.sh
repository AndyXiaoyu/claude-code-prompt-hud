context_count() {
find context -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' '
}
