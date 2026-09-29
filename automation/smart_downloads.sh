#!/bin/bash

DOWNLOADS="$HOME/Downloads"
LOG="$DOWNLOADS/organization.log"

if [ ! -d "$DOWNLOADS" ]; then
echo "Downloads folder not found."
exit 1
fi

mkdir -p "$DOWNLOADS"/{Images,Documents,Archives,Videos,Audio,Packages,Scripts}

echo "========================================"
echo "         SMART DOWNLOAD MANAGER"
echo "========================================"
echo

moved=0
skipped=0

find "$DOWNLOADS" -maxdepth 1 -type f ! -name "organization.log" -print0 |
while IFS= read -r -d '' file
do
name=$(basename "$file")
extension="${name##*.}"
extension="${extension,,}"

```
case "$extension" in
    jpg|jpeg|png|gif|webp)
        folder="Images"
        ;;
    pdf|doc|docx|txt|csv|xls|xlsx|ppt|pptx)
        folder="Documents"
        ;;
    zip|rar|7z|tar|gz|bz2|xz)
        folder="Archives"
        ;;
    mp4|mkv|avi|mov|webm)
        folder="Videos"
        ;;
    mp3|wav|flac|ogg)
        folder="Audio"
        ;;
    deb|rpm|appimage)
        folder="Packages"
        ;;
    sh|py|js|c|cpp|java|go)
        folder="Scripts"
        ;;
    *)
        continue
        ;;
esac

destination="$DOWNLOADS/$folder/$name"

if [ -e "$destination" ]; then
    echo "[SKIP] Duplicate name: $name"
    ((skipped++))
    continue
fi

mv "$file" "$destination"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] MOVED: $name -> $folder" >> "$LOG"

echo "[MOVE] $name -> $folder/"
((moved++))
```

done

echo
echo "========================================"
echo "              SUMMARY"
echo "========================================"
echo "Files organized : $moved"
echo "Files skipped   : $skipped"
echo "Log file        : $LOG"
echo "========================================"
