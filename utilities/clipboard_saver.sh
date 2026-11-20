```bash
#!/bin/bash

# Smart Clipboard Saver
# Saves clipboard text into timestamped files.

set -u

SAVE_DIR="$HOME/clipboard_notes"

mkdir -p "$SAVE_DIR"

if command -v xclip >/dev/null 2>&1; then
    CONTENT=$(xclip -selection clipboard -o 2>/dev/null)
elif command -v wl-paste >/dev/null 2>&1; then
    CONTENT=$(wl-paste 2>/dev/null)
else
    echo "Clipboard utility not found."
    echo "Install xclip (X11) or wl-clipboard (Wayland)."
    exit 1
fi

if [ -z "$CONTENT" ]; then
    echo "Clipboard is empty."
    exit 1
fi

FILE="$SAVE_DIR/clip_$(date +%Y%m%d_%H%M%S).txt"

printf '%s\n' "$CONTENT" > "$FILE"

echo "================================"
echo "      CLIPBOARD SAVER"
echo "================================"
echo "Saved successfully:"
echo "$FILE"
echo "================================"
```
