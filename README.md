# 🎵 Galaxy Watch Music

Transfer music directly from a Linux PC to a Samsung Galaxy Watch over Wi-Fi ADB.

This script lets you copy music **directly from your Linux computer to your Galaxy Watch**, without transferring the files through your phone.

It also registers the transferred files with Android's MediaStore so that **Samsung Music can recognize and play them**.

## ✨ Features

* 🎵 Transfers music directly from PC → Galaxy Watch
* 📡 Uses Wi-Fi ADB, so no USB cable is required
* 📱 Does not require transferring the music through your phone
* 🔍 Automatically checks for files that are already on the Watch
* ⏭️ Skips duplicate filenames
* 🗂️ Registers transferred files with Android MediaStore
* 🎶 Makes transferred music visible to Samsung Music
* 📁 Supports multiple common audio formats
* 🌍 Works with filenames containing spaces and Unicode characters

Supported file extensions:

* `.mp3`
* `.m4a`
* `.flac`
* `.wav`
* `.ogg`
* `.opus`

---

# 🐧 Requirements

You need:

* A Linux PC
* A Samsung Galaxy Watch that supports Wi-Fi ADB
* ADB installed on your Linux PC
* The Watch and PC connected to the same Wi-Fi network
* Developer options enabled on the Watch

This project is designed for Linux.

---

# 🔧 1. Install ADB

On Debian, Ubuntu, Pop!_OS, and similar distributions:

```bash
sudo apt update
sudo apt install adb
```

Check that ADB is installed:

```bash
adb version
```

You should see something similar to:

```text
Android Debug Bridge version ...
```

---

# ⌚ 2. Enable Developer Options on the Galaxy Watch

On your Galaxy Watch:

1. Open **Settings**
2. Go to **About watch**
3. Find **Software information**
4. Tap **Software version** several times
5. Continue tapping until Developer options are enabled

You should now have a **Developer options** menu in the Watch settings.

---

# 🐛 3. Enable ADB debugging

Open:

**Settings → Developer options**

Enable:

**ADB debugging**

Depending on your Watch/software version, you may also see an option related to **Wireless debugging** or **Debug over Wi-Fi**.

Enable the available debugging option.

The Watch may ask you to confirm a debugging connection.

---

# 📡 4. Find the Watch's IP address

Your PC needs the Watch's local network address.

On the Watch, look under:

**Settings → Connections → Wi-Fi**

Find the network information and note the Watch's IP address.

It will normally look something like:

```text
192.168.1.123
```

Your Watch may use a different private address, such as:

```text
192.168.2.164
```

The exact address will depend on your network.

---

# 🔌 5. Connect to the Watch with ADB

ADB connections use an address containing the Watch's IP address and debugging port.

For example:

```bash
adb connect 192.168.2.164:43361
```

Replace the address and port with the ones shown by your Watch.

If the connection works, you should see something similar to:

```text
connected to 192.168.2.164:43361
```

Check the connection:

```bash
adb devices
```

You should see your Watch listed as:

```text
192.168.2.164:43361    device
```

If it says `unauthorized`, look at the Watch and accept the debugging authorization request.

---

# 📥 6. Download the script

Clone this repository:

```bash
git clone https://github.com/jantraktor/galaxy-watch-music.git
```

Enter the directory:

```bash
cd galaxy-watch-music
```

Make the script executable:

```bash
chmod +x galaxy-watch-music.sh
```

---

# ⚙️ 7. Configure the Watch address

Open the script:

```bash
nano galaxy-watch-music.sh
```

Find the Watch address near the top of the script:

```bash
WATCH="192.168.2.164:43361"
```

Replace it with your Watch's ADB address.

For example:

```bash
WATCH="192.168.1.123:5555"
```

Save the file.

If you use a different editor, that's completely fine too.

---

# 🎵 8. Transfer your music

By default, the script looks for music in:

```text
~/Music
```

So if your music is already in your normal Music folder, simply run:

```bash
./galaxy-watch-music.sh
```

The script will:

1. Connect to the Watch
2. Scan the Watch for existing music
3. Scan your PC's Music folder
4. Check each song against the Watch
5. Skip files that are already there
6. Upload new files
7. Find the corresponding Android MediaStore entry
8. Register the file as music
9. Continue with the next song

You should see output similar to:

```text
🎵 Galaxy Watch Music Transfer
Source: /home/user/Music

🔌 Connecting to Watch...
✅ Connected

🎵 My Song.mp3
   📤 Uploading...
   🔎 Finding MediaStore entry...
   🗂️  MediaStore ID: 205
   🎶 Registering as music...
   ✅ Imported successfully

🏁 Done!
```

---

# 📂 9. Use a different music folder

You can give the script a folder as an argument.

For example:

```bash
./galaxy-watch-music.sh ~/Downloads/music
```

Or:

```bash
./galaxy-watch-music.sh "/home/user/My Music"
```

The folder must exist.

---

# ⏭️ Duplicate detection

The script checks whether a file with the same filename is already registered on the Watch.

For example, if the Watch already contains:

```text
My Song.mp3
```

and your PC contains another:

```text
My Song.mp3
```

the script will skip it:

```text
🎵 My Song.mp3
   ⏭️  Already on Watch, skipping
```

This means you can safely run the script again after adding more music.

You do **not** have to remember which songs you already transferred.

### Important

Duplicate detection is based on the **filename**, not the contents of the audio file.

For example:

```text
Song.mp3
Song (1).mp3
Song Remix.mp3
```

are treated as different files.

---

# 🎶 10. Playing the music

After a successful transfer, open **Samsung Music** on the Watch.

The transferred music should appear there and can be played normally.

The files are stored under:

```text
/sdcard/Music/GalaxyWearable
```

---

# 🧠 How does this actually work?

The interesting part is that simply copying an audio file to the Watch is not enough.

The Watch's Android system uses **MediaStore** to keep track of media files.

When the script pushes a file using ADB, Android can create a MediaStore entry for the file, but the entry may initially be marked as pending.

The script finds that MediaStore entry and changes:

```text
is_pending = 0
is_music = 1
```

This tells Android that the file is ready and should be treated as music.

The MP3/M4A/etc. file itself is not modified.

The script is changing the **Android media database state**, not rewriting the audio file's metadata.

---

# 🛠️ Troubleshooting

## `adb: command not found`

Install ADB:

```bash
sudo apt update
sudo apt install adb
```

Then check:

```bash
adb version
```

---

## `Watch is not connected`

Try connecting manually:

```bash
adb connect WATCH_IP:PORT
```

For example:

```bash
adb connect 192.168.2.164:43361
```

Then:

```bash
adb devices
```

The Watch should appear as:

```text
device
```

---

## ADB says `unauthorized`

Look at the Watch.

There should be a debugging authorization prompt.

Accept it and run:

```bash
adb devices
```

again.

---

## The Watch cannot be reached

Make sure:

* The PC and Watch are on the same Wi-Fi network
* Wi-Fi is enabled on the Watch
* ADB debugging is enabled
* The Watch's IP address has not changed
* The debugging port is correct

You can also reconnect:

```bash
adb disconnect
adb connect WATCH_IP:PORT
```

---

## The file transferred but does not appear in Samsung Music

Make sure the script reached:

```text
🎶 Registering as music...
```

and finished with:

```text
✅ Imported successfully
```

If MediaStore registration failed, the physical file may still have been copied to the Watch, but Android may not have registered it correctly as playable music.

---

## The script says `MediaStore entry not found`

The script waits for Android to create the MediaStore entry.

If this happens repeatedly, check that:

* The file was actually copied to the Watch
* The Watch has enough storage
* ADB is still connected
* The file format is supported by the Watch

---

# 🔁 Running it again

One of the main reasons this script exists is that you can run it repeatedly.

For example:

### First run

```text
100 songs on PC
→ 100 songs transferred
```

### Add 20 new songs

Run the script again:

```text
100 existing songs → skipped
20 new songs → transferred
```

So the script can basically act as a simple **PC → Watch music sync tool**.

---

# ⚠️ Important limitations

* Duplicate detection is filename-based.
* The PC and Watch need network connectivity during the transfer.
* The Watch must have enough free storage.
* The script currently scans only the selected folder, not subdirectories.
* Android/Samsung software updates may change how MediaStore behaves.
* Wi-Fi ADB availability and settings can vary between Galaxy Watch models and Wear OS versions.

---

# 📜 License

This project is open source.

See the repository license for the terms under which the code can be used, modified, and redistributed.

---

# 🤝 Contributing

Found a bug?

Have a Galaxy Watch model with different ADB behavior?

Want to improve the duplicate detection, add recursive folder support, or improve the user interface?

Feel free to open an issue or submit a pull request.

---

## ⭐ Why?

Samsung's normal music-transfer workflow can be inconvenient when your music library already lives on a Linux PC.

This project was made to provide a simple alternative:

```text
Linux PC
   │
   │ Wi-Fi ADB
   ▼
Galaxy Watch
   │
   ▼
Android MediaStore
   │
   ▼
Samsung Music 🎵
```

No phone in the middle.

Just PC → Watch.
