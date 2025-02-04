#!/bin/bash
#-------------------------------------------------------------------------------
# upload.sh
#
# Codex Firmware Development Upload Script
# Ryncs all Codex files onto the Raspberry Pi
# See README.md for install instructions
#
# Cooper Baker (c) 2024
# http://nyquist.dev/codex
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# login info
#-------------------------------------------------------------------------------
USERNAME="pi"
HOSTNAME="codex"

#-------------------------------------------------------------------------------
# upload codex
#-------------------------------------------------------------------------------
echo ""
echo -e "\033[1mUploading Codex"
echo -e "\033[0m\033[1A"
echo ""


#-------------------------------------------------------------------------------
# sync files
#-------------------------------------------------------------------------------
echo -e "\033[1mSyncing Files..."
echo -e "\033[0m\033[1A"
echo ""
cd "$(dirname "$0")"
cd ../../..
rsync --exclude "upload.command" --exclude ".*" --exclude "__pycache__" --delete --times --perms --verbose --archive --recursive --group --human-readable --progress ./codex "$USERNAME"@"$HOSTNAME":/home/pi/
echo ""

#-------------------------------------------------------------------------------
# upload complete
#-------------------------------------------------------------------------------
echo -e "\033[1mUpload Complete"
echo -e "\033[0m\033[1A"
echo ""
read -rsp $'Press any key to continue...\n' -n1 key


#-------------------------------------------------------------------------------
# eof
#-------------------------------------------------------------------------------
