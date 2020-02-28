#!/bin/bash
export device="" # device codename
export telegram="" # Telegram Bot Token
export chat="" # telegram chat id
export sticker="" # send sticker into HarukaAya/Emilia and reply with /stickerid
export user="" # Builder username
export rom="" # Rom Name
export repo="" # Rom manifest url
export branch="" # Rom branch
export vendor="" # Rom vendor name | lineage,aosp,etc.
export release_repo="" # release repository name | username/repo_name
export GITHUB_TOKEN="" # Github Api Key
export outdir="out/target/product/$device"
if [ -e "md5.txt" ];then
	echo 0 > md5.txt
fi
export last_md5=$(cat md5.txt)

curl -F "chat_id=$chat" -F "sticker=$sticker" https://api.telegram.org/bot$telegram/sendSticker > /dev/null
curl -F "chat_id=$chat" -F "parse_mode=html" -F "text=Build Started For <a href='$repo'>$rom $branch</a>
Device : $device" https://api.telegram.org/bot$telegram/sendMessage > /dev/null
BUILD_START=$(date +"%s")
source build/envsetup.sh
#breakfast $device
#brunch $device > ~/log.txt
lunch $vendor_$device-userdebug
#make aex -j$(nproc --all) > ~/log-$vendor.txt
#make otapackage -j$(nproc --all) > ~/log-$vendor.txt
#mka kronic -j$(nproc --all) > ~/log-$vendor.txt
mka bacon -j$(nproc --all) > ~/log-$vendor.txt
BUILD_END=$(date +"%s")
BUILD_DIFF=$((BUILD_END - BUILD_START))

export finalzip_path=$(ls "$outdir"/*202*.zip | tail -n -1)
export zip_name=$(echo "$finalzip_path" | sed "s|"$outdir"/||")
#export tag=$( echo "$zip_name" | sed 's|.zip||')
export tag=$(md5sum $finalzip_path | cut -d ' ' -f 1)
if [ -e "$finalzip_path" ]; then
	if [ $tag != $last_md5 ]; then
		~/github-release "$release_repo" "$tag" "master" ""$ROM" for "$device"
		Date: $(env TZ="$timezone" date)" "$finalzip_path"
		curl -F "chat_id=$chat" -F "parse_mode=html" -F "text=Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds
Download: <a href='https://github.com/$release_repo/releases/download/$tag/$zip_name'>$zip_name</a>" https://api.telegram.org/bot$telegram/sendMessage > /dev/null

		export status=1
		echo $tag > md5.txt
	else
		export status=0
	fi
else
	export status=0
fi

if [ $status == 0 ]; then
	curl -F "chat_id=$chat" -F "parse_mode=html" -F "text=Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds" https://api.telegram.org/bot$telegram/sendMessage > /dev/null
	curl -F "chat_id=$chat" -F document=@/home/wulan17/log-$(echo $vendor).txt https://api.telegram.org/bot$telegram/sendDocument
	exit 1
fi
