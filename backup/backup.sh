#!/bin/bash

#################
#
# Backup script
#
#################

# define hosts and paths to backup
hosts[0]="domain1.com"
paths[0]="/path/to/files"

hosts[1]="domain2.com"
paths[1]="/path/to/files"


# define local vars
remote_user="backup_ssh_user"
rsync_dest="/path/to/local/rsync/copy"
archive_dest="/path/to/local/archives"
day=$(date +%F)


# Print start status message
echo "Backup initiated"
date
echo


# rsync loop
for index in ${!hosts[*]}
do

    echo "Syncing ${hosts[$index]}:${paths[$index]}"

    # rsync files
    local_copy_path=$(dirname "${rsync_dest}/${hosts[$index]}${paths[$index]}")
    mkdir -p "${local_copy_path}"
    rsync -avzhe ssh --delete ${remote_user}@${hosts[$index]}:"${paths[$index]}" "${local_copy_path}"

    date
    echo

done


# archive loop
for index in ${!hosts[*]}
do

    archive_file="${archive_dest}/${hosts[$index]}.${day}.backup.tgz"
    if [ ! -f "${archive_file}" ]; then

        echo "Archiving ${hosts[$index]}"

        # archive files
        tar czf "${archive_file}" "${rsync_dest}/${hosts[$index]}"

        date
        echo

    fi
done


# Print end status message
echo "Backup complete"
date
echo "----------------------------"
echo
