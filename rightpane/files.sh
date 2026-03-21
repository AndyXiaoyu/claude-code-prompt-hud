watch_files() {
while true
do
clear
echo "PROJECT: $(basename $PWD)"
echo ""
ls -t | head -n 10 | while read f
do
if lsof | grep "$f" >/dev/null 2>&1; then
echo "> $f"
else
echo "  $f"
fi
done
sleep 2
done
}
watch_files
