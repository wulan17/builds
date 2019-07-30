#!/bin/bash

GITHUB_USER=<Your Github Username>
GITHUB_EMAIL=<Your Github Email>

KBUILD_BUILD_USER="<username>"
KBUILD_BUILD_HOST="<hostname>"

export oem=xiaomi
export device=cactus

ROM="AospExtended"
manifest_url="https://github.com/AospExtended/manifest.git"
export rom_vendor_name="aosp" # This represent the nams used by different rom vendors, Ex - aosp_harpia-userdebug, aosp is vendor name.
branch="8.1.x"

release_repo="wulan17/builds"

timezone="Asia/Jakarta"

export TELEGRAM_TOKEN="<Your TELEGRAM TOKEN>"
export TELEGRAM_CHAT="<Your TELEGRAM Grub ID>"
export GITHUB_TOKEN="<Your GITHUB TOKEN>"
