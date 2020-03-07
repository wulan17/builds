#!/bin/bash
source config.sh
export PATH="$HOME/bin:$PATH"
if [ ! -e "$rom" ]; then
	mkdir $rom
fi
cd $rom
curl -F "chat_id=$chat" -F "sticker=$sticker" https://api.telegram.org/bot$telegram/sendSticker > /dev/null

if [ ! -e ".repo" ]||[[ (! -x $1)&&($1 == "prepare") ]]; then
	bash ../prepare.sh
	bash ../sync.sh
else if [ ! -x $1 ] && [ $1 == "sync" ]; then
	bash ../sync.sh
fi

export last_md5=$(cat md5.txt)
source build/envsetup.sh
lunch "$vendor"_"$device"-userdebug
if [[ (! -x $1)&&($1 == "clean") ]]||[[ (! -x $2)&&($2 == "clean") ]];then
	curl -F "chat_id=$chat" -F "parse_mode=html" -F "text=Cleaning..." https://api.telegram.org/bot$telegram/sendMessage > /dev/null
	make clean -j$(nproc --all)
fi
curl -F "chat_id=$chat" -F "parse_mode=html" -F "text=Build Started For $device" https://api.telegram.org/bot$telegram/sendMessage > /dev/null
BUILD_START=$(date +"%s")
mka bacon -j$(nproc --all) > ~/log-$vendor.txt
BUILD_END=$(date +"%s")
BUILD_DIFF=$((BUILD_END - BUILD_START))

export finalzip_path=$(ls "$outdir"/*202*.zip | tail -n -1)
export zip_name=$(echo "$finalzip_path" | sed "s|"$outdir"/||")
#export tag=$( echo "$zip_name" | sed 's|.zip||')
export tag=$(md5sum $finalzip_path | cut -d ' ' -f 1)
if [ -e "$finalzip_path" ]; then
	if [ $tag != $last_md5 ]; then
		../github-release "$release_repo" "$tag" "master" ""$ROM" for "$device"
		Date: $(env TZ="$timezone" date)" "$finalzip_path"
		curl -F "chat_id=$chat" -F "parse_mode=html" -F "text=Build completed successfully in $(((BUILD_DIFF / 60) /60)):$((BUILD_DIFF / 60)):$((BUILD_DIFF % 60))
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
	curl -F "chat_id=$chat" -F "parse_mode=html" -F "text=Build failed in $(((BUILD_DIFF / 60) / 60)):$((BUILD_DIFF / 60)):$((BUILD_DIFF % 60))" https://api.telegram.org/bot$telegram/sendMessage > /dev/null
	curl -F "chat_id=$chat" -F document=@~/log-$vendor.txt https://api.telegram.org/bot$telegram/sendDocument
	exit 1
fi
