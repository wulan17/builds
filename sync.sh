#!/bin/bash
curl -F "chat_id=$chat" -F "parse_mode=html" -F "text=Sync Started For <a href='$repo'>$rom $branch</a>" https://api.telegram.org/bot$telegram/sendMessage > /dev/null
SYNC_START=$(date +"%s")
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
SYNC_END=$(date +"%s")
SYNC_DIFF=$((SYNC_END - SYNC_START))
if [ -e "frameworks/base" ]; then
	curl -F "chat_id=$chat" -F "parse_mode=html" -F "text=Sync completed successfully in $(((SYNC_DIFF / 60) /60)):$((SYNC_DIFF / 60)):$((SYNC_DIFF % 60))" https://api.telegram.org/bot$telegram/sendMessage > /dev/null
else
	curl -F "chat_id=$chat" -F "parse_mode=html" -F "text=Sync failed in $(((SYNC_DIFF / 60) /60)):$((SYNC_DIFF / 60)):$((SYNC_DIFF % 60))" https://api.telegram.org/bot$telegram/sendMessage > /dev/null
fi