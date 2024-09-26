#!/bin/bash

##################################################################################################
# MediaWiki Backup Script
#
# This script performs a backup of a MediaWiki installation, including the MySQL database and
# the images directory. The backup consists of:
#   - A compressed MySQL database dump (bzip2).
#   - A version file containing the MediaWiki version (for recovery purposes).
#   - A backup of the images directory (uncompressed in the tar archive).
#
# The resulting backup will be a tar archive containing a compressed database dump.
#
# **Important:**
# - Ensure that the database credentials (DB_USER, DB_PWD, WIKI_DB_NAME) match those found in
#   your MediaWiki installation's `LocalSettings.php` file.
# - Set the `WIKI_BASE_FOLDER` variable to the root folder of your MediaWiki installation (the
#   folder that contains `LocalSettings.php`).
# - Set the `WIKI_VERSION` to the version of MediaWiki you are using. This is important for
#   recovery purposes.
# - Set the `BACKUP_DESTINATION_FOLDER` to the directory where the backup will be stored.
# - The backup directory must already exist; this script will not create it.
#
# **Usage:**
# Edit the variables below to match your environment before running the script.
##################################################################################################

## Set variables based on your LocalSettings.php
DB_USER="wiki-user"                  # MySQL database user
DB_PWD="wiki-password"               # MySQL database password
WIKI_DB_NAME="wiki-db"               # MySQL database name
WIKI_BASE_FOLDER="/var/www/html/wiki" # MediaWiki base directory (where LocalSettings.php is located)
WIKI_VERSION="1.35"                  # MediaWiki version (set this to your installed version)

## Set the backup destination folder (must already exist)
BACKUP_DESTINATION_FOLDER=~/backup_wiki

## Date and Time format for the backup file name
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

## Backup file name
BACKUP_FILE="$BACKUP_DESTINATION_FOLDER/mediawiki-backup_$TIMESTAMP.tar"

## Exit immediately if a command fails or an undefined variable is used
set -euo pipefail

## Check if the backup destination folder exists
if [ ! -d "$BACKUP_DESTINATION_FOLDER" ]; then
    echo "Error: Backup destination folder '$BACKUP_DESTINATION_FOLDER' does not exist." >&2
    exit 1
fi

## Temporary folder for staging the backup
TMP_FOLDER=$(mktemp -d)

## Function to clean up the temporary folder on exit or error
cleanup() {
    rm -rf "$TMP_FOLDER"
}
trap cleanup EXIT

## Change to the temporary folder
cd "$TMP_FOLDER"

## Save the wiki version as information for recovery
echo "$WIKI_VERSION" > mediawiki-backup.version

## Backup the MySQL database and compress it
echo "Backing up MySQL database..."
if ! mysqldump --default-character-set=utf8 --single-transaction --quick -u"$DB_USER" -p"$DB_PWD" "$WIKI_DB_NAME" -c > mysqldump.sql; then
    echo "Error: Failed to backup database" >&2
    exit 1
fi

## Compress the SQL dump
bzip2 -9 mysqldump.sql

## Create the tarball with the compressed database and version file
echo "Creating backup archive (excluding images directory)..."
if ! tar -cf "$BACKUP_FILE" -C "$TMP_FOLDER" mysqldump.sql.bz2 mediawiki-backup.version; then
    echo "Error: Failed to create backup archive" >&2
    exit 1
fi

## Backup the images directory (uncompressed) to the existing tarball
echo "Backing up images directory..."
if ! tar -rf "$BACKUP_FILE" -C "$WIKI_BASE_FOLDER" images; then
    echo "Error: Failed to append images directory to backup archive" >&2
    exit 1
fi

echo "Backup completed successfully: $BACKUP_FILE"
