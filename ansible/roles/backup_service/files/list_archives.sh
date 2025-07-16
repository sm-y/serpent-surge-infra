# ansible\roles\backup_service\files\list_archives.sh
#!/bin/bash
source /data/serpent_backup/backup.env

list_archives() {
    echo -e "Date\t\tSize"
    for f in "$ARCHIVE_DIR"/*.tar.gz; do
        [ -e "$f" ] || continue
        D=$(basename "$f" | cut -d_ -f1)
        S=$(du -h "$f" | cut -f1)
        echo -e "$D\t$S"
    done
}

list_archives
