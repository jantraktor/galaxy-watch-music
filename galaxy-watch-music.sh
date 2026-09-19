#!/usr/bin/env bash

read -rp "⌚ Enter your Galaxy Watch ADB address (IP:PORT): " WATCH
SOURCE_DIR="${1:-$HOME/Music}"

PUSH_DIR="/sdcard/Music/GalaxyWearable"
MEDIA_DIR="/storage/emulated/0/Music/GalaxyWearable"

echo "🎵 Galaxy Watch Music Transfer"
echo "Source: $SOURCE_DIR"
echo

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "❌ Folder does not exist: $SOURCE_DIR"
    exit 1
fi

echo "🔌 Connecting to Watch..."
adb connect "$WATCH" >/dev/null

if ! adb -s "$WATCH" get-state >/dev/null 2>&1; then
    echo "❌ Watch is not connected."
    exit 1
fi

echo "✅ Connected"
echo

# Get existing MediaStore entries
watch_files="$(
    adb -s "$WATCH" shell content query \
        --uri content://media/external/audio/media \
        --projection _id:_display_name:_data 2>/dev/null
)"

while IFS= read -r -d '' file; do

    name="$(basename "$file")"
    full_path="$MEDIA_DIR/$name"

    echo "🎵 $name"

    # Check whether this filename already exists in MediaStore
    existing="$(
        printf '%s\n' "$watch_files" |
        grep -F "_data=$full_path"
    )"

    if [[ -n "$existing" ]]; then
        echo "   ⏭️  Already on Watch, skipping"
        echo
        continue
    fi

    echo "   📤 Uploading..."

    if ! adb -s "$WATCH" push "$file" "$PUSH_DIR/"; then
        echo "   ❌ Upload failed"
        echo
        continue
    fi

    echo "   🔎 Finding MediaStore entry..."

    id=""

    for attempt in {1..20}; do

        result="$(
            adb -s "$WATCH" shell content query \
                --uri content://media/external/audio/media \
                --projection _id:_display_name:_data 2>/dev/null
        )"

        id="$(
            printf '%s\n' "$result" |
            grep -F "_data=$full_path" |
            sed -n 's/.*_id=\([0-9][0-9]*\),.*/\1/p' |
            tail -n 1
        )"

        if [[ -n "$id" ]]; then
            break
        fi

        sleep 1
    done

    if [[ -z "$id" ]]; then
        echo "   ❌ MediaStore entry not found"
        echo
        continue
    fi

    echo "   🗂️  MediaStore ID: $id"
    echo "   🎶 Registering as music..."

    if adb -s "$WATCH" shell content update \
        --uri "content://media/external/audio/media/$id" \
        --bind is_pending:i:0 \
        --bind is_music:i:1 >/dev/null; then

        echo "   ✅ Imported successfully"
    else
        echo "   ❌ MediaStore update failed"
    fi

    echo

    # Add the newly imported file to our duplicate list
    watch_files="$watch_files
Row: _id=$id, _display_name=$name, _data=$full_path"

done < <(
    find "$SOURCE_DIR" -maxdepth 1 -type f \
        \( -iname '*.mp3' -o -iname '*.m4a' -o -iname '*.flac' \
           -o -iname '*.wav' -o -iname '*.ogg' -o -iname '*.opus' \) \
        -print0
)

echo "🏁 Done!"
