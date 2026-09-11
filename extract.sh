#!/bin/bash

read -p "Enter archive path: " file

if [ ! -f "$file" ]; then
echo "File not found."
exit 1
fi

case "$file" in
*.tar.gz|*.tgz)
tar -xzf "$file"
;;
*.tar.bz2)
tar -xjf "$file"
;;
*.tar)
tar -xf "$file"
;;
*.zip)
unzip "$file"
;;
*.gz)
gunzip "$file"
;;
*)
echo "Unsupported archive format."
exit 1
;;
esac

echo "Archive extracted successfully."
