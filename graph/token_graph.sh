GRAPH_FILE=/tmp/claude_token_graph

token_graph_push() {
val=$1
echo $val >> $GRAPH_FILE
tail -n 20 $GRAPH_FILE > /tmp/g.tmp && mv /tmp/g.tmp $GRAPH_FILE
}

token_graph_render() {
[ ! -f $GRAPH_FILE ] && return
awk '
{
v=$1
if(v<2) c="▁"
else if(v<5) c="▂"
else if(v<10) c="▃"
else if(v<20) c="▄"
else if(v<40) c="▅"
else if(v<80) c="▆"
else c="▇"
printf c
}
END{print ""}' $GRAPH_FILE
}
