session_cost() {
tokens=$(session_tokens)
awk "BEGIN {printf \"%.3f\", $tokens*0.00001}"
}
