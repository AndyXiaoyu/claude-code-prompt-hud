SESSION_FILE=/tmp/claude_hud_session
[ ! -f $SESSION_FILE ] && date +%s > $SESSION_FILE

session_time() {
start=$(cat $SESSION_FILE)
now=$(date +%s)
echo "$(( (now-start)/60 ))m"
}
