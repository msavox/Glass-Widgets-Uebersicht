#!/bin/bash
# Forza il Finder a mostrare la finestra di scelta file in primo piano
PHOTO_PATH=$(osascript -e 'tell application "Finder"' -e 'activate' -e 'set theFile to (choose file with prompt "Seleziona una foto per il widget" of type {"public.image"})' -e 'POSIX path of theFile' -e 'end tell' 2>/dev/null)

if [ -n "$PHOTO_PATH" ]; then
    # Ottiene la cartella dello script e copia il file
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    cp "$PHOTO_PATH" "$DIR/../current_photo.jpg"
    echo "SUCCESS"
else
    echo "CANCELLED"
fi
