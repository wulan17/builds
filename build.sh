#!/bin/bash

source ./config.sh
echo "***Build Bot***"
./telegram -M "Owshit here we go again"
# Email for git
git config --global user.email "$GITHUB_EMAIL"
git config --global user.name "$GITHUB_USER"

export outdir="out/target/product/$device"

cd "$ROM"

echo "Sync started for "$manifest_url""
../telegram -M "Sync Started for ["$ROM"]("$manifest_url")"
SYNC_START=$(date +"%s")
#trim_darwin >/dev/null   2>&1
#repo sync --force-sync --current-branch --no-tags --no-clone-bundle --optimized-fetch --prune -j$(nproc --all) -q 2>&1 >>logwe 2>&1
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags #2>&1 >>logwe 2>&1
if [ -e device/$oem/$device ]; then

else
	bash ../clone.sh
fi
SYNC_END=$(date +"%s")
SYNC_DIFF=$((SYNC_END - SYNC_START))
if [ -e frameworks/base ]; then
    echo "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    echo "Build Started"
    ../telegram -M "Sync completed successfully in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"

    ../telegram -M "Build Started
ROM : ""$ROM""
Android : "$branch"
Device : "$device"
Brand : "$oem"
Type : UNOFFICIAL
Dev : ""$KBUILD_BUILD_USER""
Build Date : ""$(env TZ=$timezone date)""
"

    BUILD_START=$(date +"%s")

    source build/envsetup.sh >/dev/null  2>&1
    source ../config.sh
    if [ -e device/"$oem"/"$device" ]; then
        python3 ../dependency_cloner.py
    fi
    lunch "$rom_vendor_name"_"$device"-userdebug >/dev/null  2>&1
    make aex -j4
    BUILD_END=$(date +"%s")
    BUILD_DIFF=$((BUILD_END - BUILD_START))

    export finalzip_path=$(ls "$outdir"/*201*.zip | tail -n -1)
    export zip_name=$(echo "$finalzip_path" | sed "s|"$outdir"/||")
    export tag=$( echo "$zip_name" | sed 's|.zip||')
    if [ -e "$finalzip_path" ]; then
        echo "Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"

        echo "Uploading"

        ../github-release "$release_repo" "$tag" "master" ""$ROM" for "$device"

Date: $(env TZ="$timezone" date)" "$finalzip_path"

        echo "Uploaded"

        ../telegram -M "Build completed successfully in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds

ROM : ""$ROM""
Android : "$branch"
Device : "$device"
Brand : "$oem"
Type : UNOFFICIAL
Dev : ""$KBUILD_BUILD_USER""
Build Date : ""$(env TZ=$timezone date)""
Status : Not Tested

Download: ["$zip_name"](https://github.com/"$release_repo"/releases/download/"$tag"/"$zip_name")"

    else
        echo "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
        ../telegram -N -M "Build failed in $((BUILD_DIFF / 60)) minute(s) and $((BUILD_DIFF % 60)) seconds"
        exit 1
    fi
else
    echo "Sync failed in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    ../telegram -N -M "Sync failed in $((SYNC_DIFF / 60)) minute(s) and $((SYNC_DIFF % 60)) seconds"
    exit 1
fi
