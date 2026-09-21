#!/bin/bash

read -p "Enter directory to organize: " directory

if [ ! -d "$directory" ]; then
echo "Directory not found."
exit 1
fi

mkdir -p "$directory"/{Images,Documents,Archives,Videos,Audio,Scripts}

images=0
documents=0
archives=0
videos=0
audio=0
scripts=0

find "$directory" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' file
do
case "${file,,}" in
*.jpg|*.jpeg|*.png|*.gif|*.webp)
mv "$file" "$directory/Images/"
;;
*.pdf|*.doc|*.docx|*.txt|*.csv|*.xlsx)
mv "$file" "$directory/Documents/"
;;
*.zip|*.tar|*.gz|*.tar.gz|*.7z|*.rar)
mv "$file" "$directory/Archives/"
;;
*.mp4|*.mkv|*.avi|*.mov|*.webm)
mv "$file" "$directory/Videos/"
;;
*.mp3|*.wav|*.flac|*.ogg)
mv "$file" "$directory/Audio/"
;;
*.sh|*.py|*.js|*.cpp|*.c)
mv "$file" "$directory/Scripts/"
;;
esac
done

echo
echo "================================="
echo "       ORGANIZATION COMPLETE"
echo "================================="
echo

echo "Images    : $(find "$directory/Images" -type f | wc -l)"
echo "Documents : $(find "$directory/Documents" -type f | wc -l)"
echo "Archives  : $(find "$directory/Archives" -type f | wc -l)"
echo "Videos    : $(find "$directory/Videos" -type f | wc -l)"
echo "Audio     : $(find "$directory/Audio" -type f | wc -l)"
echo "Scripts   : $(find "$directory/Scripts" -type f | wc -l)"
