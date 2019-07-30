#!/bin/bash
# Copyright (C) 2019 baalajimaestro
#
# Licensed under the Raphielscape Public License, Version 1.b (the "License");
# you may not use this file except in compliance with the License.
#
source ./config.sh
echo "***Build Bot***"
# Email for git
git config --global user.email "$GITHUB_EMAIL"
git config --global user.name "$GITHUB_USER"

chmod +x github-release
chmod +x telegram
mkdir -p ~/bin
wget 'https://storage.googleapis.com/git-repo-downloads/repo' -P ~/bin
chmod +x ~/bin/repo
export PATH=~/bin:$PATH
export USE_CCACHE=1
sudo apt-get update
sudo apt-get install liblz4-dev

function trim_darwin() {
    cd .repo/manifests
    cat default.xml | grep -v darwin  >temp  && cat temp >default.xml  && rm temp
    git commit -a -m "Magic"
    cd ../
    cat manifest.xml | grep -v darwin  >temp  && cat temp >manifest.xml  && rm temp
    cd ../
}

mkdir "$ROM"
cd "$ROM"
repo init -u "$manifest_url" -b "$branch" #--depth 1 >/dev/null  2>&1