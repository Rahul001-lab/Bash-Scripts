#!/bin/bash

read -p "Enter target URL: " target

if [ -z "$target" ]; then
    echo "Target cannot be empty."
    exit 1
fi

echo
echo "Starting WhatWeb scan..."
echo "Target: $target"
echo

whatweb "$target"
