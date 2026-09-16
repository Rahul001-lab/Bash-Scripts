#!/bin/bash

read -p "Enter project name: " project

if [ -z "$project" ]; then
echo "Project name cannot be empty."
exit 1
fi

mkdir -p "$project"/{src,tests,docs}

touch "$project/README.md"
touch "$project/.gitignore"

echo
echo "Project created successfully!"
echo
echo "$project/"
echo "├── src/"
echo "├── tests/"
echo "├── docs/"
echo "├── README.md"
echo "└── .gitignore"
