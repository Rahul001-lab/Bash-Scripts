#!/bin/bash

set -u

TARGET="${1:-$HOME/Downloads}"

if [ ! -d "$TARGET" ]; then
    echo "Directory does not exist: $TARGET"
    exit 1
fi

for FILE in "$TARGET"/*; do
    [ -f "$FILE" ] || continue

    EXT="${FILE##*.}"
    EXT=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')
    NAME=$(basename "$FILE")

    if [[ "$NAME" == "$EXT" ]] || [[ "$NAME" != *.* ]]; then
        CATEGORY="Others"
    else
        case "$EXT" in
            pdf) CATEGORY="PDFs" ;;
            doc|docx|txt|odt) CATEGORY="Documents" ;;
            jpg|jpeg|png|gif|bmp|webp) CATEGORY="Images" ;;
            mp4|mkv|avi|mov|webm) CATEGORY="Videos" ;;
            mp3|wav|flac|aac|ogg) CATEGORY="Audio" ;;
            zip|rar|7z|tar|gz|bz2) CATEGORY="Archives" ;;
            py|sh|js|html|css|cpp|c|java) CATEGORY="Code" ;;
            xls|xlsx|csv) CATEGORY="Spreadsheets" ;;
            *) CATEGORY="Others" ;;
        esac
    fi

    DEST="$TARGET/$CATEGORY"

    mkdir -p "$DEST"

    if [ -e "$DEST/$NAME" ]; then
        echo "Skipping duplicate: $NAME"
        continue
    fi

    mv -- "$FILE" "$DEST/"
    echo "Moved: $NAME -> $CATEGORY"
done

echo
echo "File sorting completed!"
