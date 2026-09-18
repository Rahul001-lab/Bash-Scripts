#!/bin/bash

DOWNLOADS="$HOME/Downloads"

if [ ! -d "$DOWNLOADS" ]; then
echo "Downloads folder not found."
exit 1
fi

mkdir -p "$DOWNLOADS"/{Images,Documents,Archives,Videos,Installers}

echo "[+] Organizing Downloads..."

find "$DOWNLOADS" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' file
do
case "${file,,}" in
*.jpg|*.jpeg|*.png|*.gif|*.webp)
mv "$file" "$DOWNLOADS/Images/"
;;
*.pdf|*.doc|*.docx|*.txt|*.xlsx|*.csv)
mv "$file" "$DOWNLOADS/Documents/"
;;
*.zip|*.tar|*.gz|*.tar.gz|*.7z|*.rar)
mv "$file" "$DOWNLOADS/Archives/"
;;
*.mp4|*.mkv|*.avi|*.mov|*.webm)
mv "$file" "$DOWNLOADS/Videos/"
;;
*.deb|*.rpm|*.AppImage)
mv "$file" "$DOWNLOADS/Installers/"
;;
esac
done

echo "[+] Downloads organized successfully."
