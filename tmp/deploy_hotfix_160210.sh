#!/bin/sh

NOW=$(date +%y%m%d-%H%M%S)

BackupConfig_File="/tmp/backup_$NOW.tar.gz"
BackupConfig_Log="/tmp/backup_$NOW.log"
Hotfix_File="/tmp/hotfix_160210.tar.gz"
Hotfix_Log="/tmp/hotfix_$NOW.log"

debug_this() {
        echo "DEBUG"
        echo $BackupConfig_File
        echo $BackupConfig_Log
        echo $Hotfix_File
        echo $Hotfix_Log
}

backup_config() {
        echo ""
        echo "Backing up data to $BackupConfig_File , please wait.."
        /sbin/sysupgrade -b $BackupConfig_File > $BackupConfig_Log
        echo ""
        echo "Done making backup, results are in $BackupConfig_Log"
        echo ""
}

deploy_hotfix() {
        echo ""
        echo "Deploying hotfixes in $Hotfix_File now, please wait.."
        #1) secure copy bridge.hotfix.tar.gz to the root directory of the Shield
        #2) tar -zxvf bridge.hotfix.tar.gz
        #3) reboot -f

        cd /
        tar -zxvf $Hotfix_File > $Hotfix_Log

        echo "Hotfix deployed, results are in $Hotfix_Log"
        echo ""
}

reboot_shield() {
        echo "Rebooting shield in 10 seconds, press CTRL+C to prevent reboot"
        sleep 10
        echo "rebooting"
        #reboot -f
}

debug_this
backup_config                           # creates backup of the current config files
sleep 5
deploy_hotfix                           # deploys hotfix
sleep 5
reboot_shield                           # reboot shield

