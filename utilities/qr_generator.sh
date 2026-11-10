```bash
#!/bin/bash

# Smart QR Code Generator

set -u

if ! command -v qrencode >/dev/null 2>&1; then
    echo "qrencode is not installed."
    echo "Install it using: sudo apt install qrencode"
    exit 1
fi

echo "================================"
echo "       QR CODE GENERATOR"
echo "================================"
echo "1. URL"
echo "2. Plain text"
echo "3. Wi-Fi details"
echo "4. Contact information"
echo "================================"

read -rp "Choose an option: " CHOICE

case "$CHOICE" in

    1)
        read -rp "Enter URL: " DATA
        ;;

    2)
        read -rp "Enter text: " DATA
        ;;

    3)
        read -rp "Wi-Fi name: " SSID
        read -rsp "Wi-Fi password: " PASS
        echo
        read -rp "Security (WPA or nopass): " SECURITY

        DATA="WIFI:T:${SECURITY};S:${SSID};P:${PASS};;"
        ;;

    4)
        read -rp "Name: " NAME
        read -rp "Phone: " PHONE
        read -rp "Email: " EMAIL

        DATA="MECARD:N:${NAME};TEL:${PHONE};EMAIL:${EMAIL};;"
        ;;

    *)
        echo "Invalid option."
        exit 1
        ;;
esac

read -rp "Enter output filename (without extension): " FILENAME

if [[ -z "$FILENAME" ]]; then
    echo "Filename cannot be empty."
    exit 1
fi

qrencode -o "${FILENAME}.png" -s 10 -m 2 "$DATA"

if [ $? -eq 0 ]; then
    echo
    echo "QR code generated successfully!"
    echo "Saved as: ${FILENAME}.png"

    if command -v file >/dev/null 2>&1; then
        file "${FILENAME}.png"
    fi
else
    echo "QR generation failed."
    exit 1
fi

unset PASS DATA
``` id="qr1"
