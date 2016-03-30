#!/bin/sh

FILE_LIST='/tmp/cleanup_list'
FILE_ARCHIVE='/tmp/cleanup_archive.tgz'

clear
cat << _EOF_

CLEANUP FILE SCRIPT

1) creates archive $FILE_ARCHIVE of all files in $FILE_LIST
2) if succesfull, delete all files
3) restart snort to get latest lists

_EOF_


# previously created archive will abort script
if [ -r "$FILE_ARCHIVE" ]; then
        {
        echo "Archive $FILE_ARCHIVE already exists - aborting"
	exit 1
        }
fi

# create archive
tar -czvf $FILE_ARCHIVE -T $FILE_LIST

# delete files

while IFS= read -r var
do
        if [ -r "$var" ]; then
        {
                echo "Deleting file $var"
		rm "$var"
        } else {
		echo "Unable to find $var - skipped"
	}
        fi
done < "$FILE_LIST"


# restart snort
/etc/init.d/snort restart
