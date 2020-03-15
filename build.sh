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
export release_repo="" # release repository name | <username/repo_name>
export GITHUB_TOKEN="" # Github Api Key
export outdir="out/target/product/$device"
if [[ (! -x $1)&&($1 == "sync") ]]||[[ (! -x $2)&&($2 == "sync") ]];then
	export SYNC=true
else
	export SYNC=false
fi
if [[ (! -x $1)&&($1 == "clean") ]]||[[ (! -x $2)&&($2 == "clean") ]];then
	export CLEAN=true
else
	export CLEAN=false
fi

function sync(){
	curl -F "chat_id=$chat" -F "parse_mode=html" -F "text=Sync Started" https://api.telegram.org/bot"$telegram"/sendMessage > /dev/null
	SYNC_START=$(date +"%s")
	repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
	SYNC_END=$(date +"%s")
	SYNC_DIFF=$((SYNC_END - SYNC_START))
	curl -F "chat_id=$chat" -F "parse_mode=html" -F "text=Sync completed in $(((SYNC_DIFF / 60) / 60)):$(((SYNC_DIFF / 60) % 60)):$((SYNC_DIFF % 60))" https://api.telegram.org/bot"$telegram"/sendMessage > /dev/null
}
function clean(){
	curl -F "chat_id=$chat" -F "parse_mode=html" -F "text=Cleaning old builds..." https://api.telegram.org/bot"$telegram"/sendMessage > /dev/null
	make clean -j$(nproc --all)
}
function check_old(){
	if [[ -z $(find $outdir/*2020*.zip | cut -d "/" -f 5) ]]; then
		export last_md5=0
	else
		last_build=$(ls $outdir/*2020*.zip | tail -n -1)
		export last_md5=$(md5sum "$last_build" | cut -d ' ' -f 1)
	fi
}
function success(){
	if [[ -z "github-release" ]]; then
		wget https://github.com/wulan17/builds/raw/master/github-release
		chmod +x github-release
	fi
	./github-release "$release_repo" "$tag" "master" """$ROM"" for ""$device""
	Date: $(env TZ="$timezone" date)" "$file_path"
	curl -F "chat_id=$chat" -F "parse_mode=html" -F "text=Build completed successfully in $(((BUILD_DIFF / 60) / 60)):$(((BUILD_DIFF / 60) % 60)):$((BUILD_DIFF % 60))<br/>Download: <a href='https://github.com/$release_repo/releases/download/$tag/$zip_name'>$zip_name</a>" https://api.telegram.org/bot"$telegram"/sendMessage > /dev/null
}
function failed(){
	curl -F "chat_id=$chat" -F document=@"$HOME"/log-$(echo "$vendor").txt -F "parse_mode=html" -F "caption=Build failed in $(((BUILD_DIFF / 60) / 60)):$(((BUILD_DIFF / 60) % 60)):$((BUILD_DIFF % 60))" https://api.telegram.org/bot"$telegram"/sendDocument > /dev/null
}
function check_build(){
	if [[ -e $(find $outdir/*2020*.zip | cut -d "/" -f 5) ]]; then
		export file_path=$(ls $outdir/*2020*.zip | tail -n -1)
		export file_name=$(echo "$file_path" | cut -d "/" -f 5)
		md5=$(md5sum "$file_path" | cut -d ' ' -f 1)
		if [ "$md5" == "$last_md5" ]; then
			failed
		else
			export tag=$md5
			success
		fi
	else
		failed
	fi
}
function build(){
	curl -F "chat_id=$chat" -F "parse_mode=html" -F "text=Build Started For <a href='$repo'>$rom $branch</a><br />Device : $device" https://api.telegram.org/bot"$telegram"/sendMessage > /dev/null
	BUILD_START=$(date +"%s")
	source build/envsetup.sh
	#breakfast $device
	lunch "$vendor"_"$device"-userdebug
	#brunch $device > ~/log-$vendor.txt
	#make aex -j$(nproc --all) > ~/log-$vendor.txt
	#make otapackage -j$(nproc --all) > ~/log-$vendor.txt
	#mka kronic -j$(nproc --all) > ~/log-$vendor.txt
	mka bacon -j$(nproc --all) > ~/log-"$vendor".txt
	BUILD_END=$(date +"%s")
	export BUILD_DIFF=$((BUILD_END - BUILD_START))
}

function main(){
	curl -F "chat_id=$chat" -F "sticker=$sticker" https://api.telegram.org/bot"$telegram"/sendSticker > /dev/null
	if [ $SYNC==true ]; then
		sync
	fi
	if [ $CLEAN==true ]; then
		clean
	fi
	check_old
	build
	check_build
}

main
