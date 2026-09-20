#!/bin/bash

read -p "Enter Git project path: " project

if [ ! -d "$project" ]; then
echo "Project directory not found."
exit 1
fi

if [ ! -d "$project/.git" ]; then
echo "This is not a Git repository."
exit 1
fi

cd "$project" || exit 1

echo "[+] Checking for changes..."

if [ -z "$(git status --porcelain)" ]; then
echo "[+] No changes to backup."
exit 0
fi

git add .

commit_message="Automatic backup - $(date '+%Y-%m-%d %H:%M:%S')"

git commit -m "$commit_message"

echo
echo "[+] Changes committed successfully."
echo "[+] Commit: $commit_message"

read -p "Push changes to remote? (y/n): " push

if [[ "$push" =~ ^[Yy]$ ]]; then
git push
echo "[+] Changes pushed successfully."
else
echo "[+] Changes remain committed locally."
fi
