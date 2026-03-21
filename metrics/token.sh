TOKEN_FILE=/tmp/claude_tokens
REQ_FILE=/tmp/claude_req

session_tokens() {
[ -f $TOKEN_FILE ] && cat $TOKEN_FILE || echo 0
}

request_count() {
[ -f $REQ_FILE ] && cat $REQ_FILE || echo 0
}

token_usage() {
echo "$(session_tokens)/200k"
}
