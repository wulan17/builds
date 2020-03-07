#!/bin/bash
source ../config.sh
curl -F "chat_id=$chat" -F "parse_mode=html" -F "text=Setting Up..." https://api.telegram.org/bot$telegram/sendMessage > /dev/null
if [ ! -e md5.txt ]; then
	echo 0 > md5.txt
fi
if [ ! -e "~/bin/repo" ]; then
	sudo apt update
	sudo apt install -y liblz4-dev openjdk-8-jdk android-tools-adb bc bison build-essential curl flex g++-multilib gcc-multilib gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc yasm zip zlib1g-dev ccache
	mkdir -p ~/bin
	curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
	chmod +x ~/bin/repo
	export PATH="$HOME/bin:$PATH"
fi
git config --global user.name "$user"
git config --global user.email "$email"
repo init -u $repo -b $branch --depth=1
bash ../clone.sh
