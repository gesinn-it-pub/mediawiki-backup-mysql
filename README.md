# MediaWiki Backup Script

## Overview

This script performs a backup of a MediaWiki installation, including:
- A compressed MySQL database dump (using `bzip2`).
- A version file containing the MediaWiki version for recovery purposes.
- An uncompressed backup of the images directory.

The resulting backup will be a `.tar` archive containing the compressed database dump and other files.

## Important Notes

- Ensure that the database credentials (`DB_USER`, `DB_PWD`, `WIKI_DB_NAME`) match those found in your MediaWiki installation's `LocalSettings.php` file.
- Set the `WIKI_BASE_FOLDER` variable to the root folder of your MediaWiki installation (the folder containing `LocalSettings.php`).
- Set the `WIKI_VERSION` to the version of MediaWiki you are using; this is important for recovery purposes.
- Set the `BACKUP_DESTINATION_FOLDER` to the directory where the backup will be stored. **This directory must already exist; the script will not create it.**

## Usage

1. **Edit the script** to match your environment by updating the variables listed above.
2. **Run the script** to create a backup of your MediaWiki installation.

## Backup Structure

The final backup archive will contain:
- `mediawiki-backup.version` (version information)
- `mysqldump.sql.bz2` (compressed MySQL database dump)
- `images/` (uncompressed images directory)

