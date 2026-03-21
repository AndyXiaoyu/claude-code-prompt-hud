cpu_usage() {
ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f%%", s}'
}

mem_usage() {
vm_stat | grep "Pages active" | awk '{print $3}'
}
