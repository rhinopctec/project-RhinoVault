<p align="center"><img src="rhinovault-logo.png" alt="RhinoVault logo" width="220"></p>

# RhinoVault OS + RhinoVault Go! Complete Setup Guide (v2)

This guide takes an Android phone or tablet from stock to a working RhinoVault Survival Node: a clean OS installed, then the RhinoVault Go! library, maps, field manuals and Survival AI loaded.

> **Status:** RhinoVault OS v1 is not released yet, so every step also shows the **interim path (LineageOS)** you can use today. Items marked **[TBD]** are filled in when RhinoVault OS v1 ships.

## Contents

- [Before you start](#before-you-start)
- [Downloads and links](#downloads-and-links)
- [Step 1: Check your device is supported](#step-1-check-your-device-is-supported)
- [Step 2: Build the RhinoVault Go content drive](#step-2-build-the-rhinovault-go-content-drive)
- [Step 3: Back up, update and unlock the bootloader](#step-3-back-up-update-and-unlock-the-bootloader)
- [Step 4: Install the OS](#step-4-install-the-os)
- [Step 5: Test boot, then relock the bootloader (RhinoVault OS only)](#step-5-test-boot-then-relock-the-bootloader-rhinovault-os-only)
- [Step 6: First boot setup](#step-6-first-boot-setup)
- [Step 7: Load the RhinoVault Go content](#step-7-load-the-rhinovault-go-content)
- [Step 8: Start RhinoVault and the Survival AI](#step-8-start-rhinovault-and-the-survival-ai)
- [Step 9: Share over the hotspot](#step-9-share-over-the-hotspot)
- [Step 10: Field test checklist](#step-10-field-test-checklist)
- [Troubleshooting and recovery](#troubleshooting-and-recovery)

## Before you start

Plan on 1 hour of hands-on work plus 3 to 8 hours of unattended content building. Do every step in order and tick each checkbox before moving on.

| You need | Why |
| --- | --- |
| A supported phone or tablet (Step 1), charged to 80%+ | Becomes the Survival Node |
| Windows PC with internet and 150+ GB free | Builds content and installs the OS |
| Good USB-C **data** cable (not charge-only) | Connects device to PC |
| USB-C flash drive or microSD card, sized for your edition (below) | Carries the RhinoVault Go content to the device |
| The OS install files (see [Downloads and links](#downloads-and-links)) | RhinoVault OS **[TBD]**, or LineageOS for now |
| This repo on the PC (`rhinovault-go` folder) | Builds the content |

**Pick your edition by the device's storage:**

| Device storage | Edition | Content size | Survival AI model | Device RAM needed |
| --- | --- | --- | --- | --- |
| 128 GB | Lite | ~37 GB | Qwen2.5 1.5B | 4 GB+ |
| 256 GB | Standard (recommended) | ~110 GB | Qwen3 4B | 8 GB+ |
| 512 GB+ | Full | ~320 GB | Qwen3 4B | 8 GB+ |

**Warnings, read before you begin:**

- Installing a new OS **erases everything** on the device. Back up first.
- Never unplug the cable while the screen says *flashing*, *sideloading* or *writing*.
- Only relock the bootloader when this guide says it's safe (Step 5). Relocking with an unsupported OS can brick the device.
- Client drives must be built with `-Use sale` (the default) so only public-domain books are included.

## Downloads and links

RhinoVault OS v1 has no download yet. Use LineageOS (the base RhinoVault OS is built on) until it ships, and keep this page as your one place for every link.

**Operating systems**

| What | Use it for | Link |
| --- | --- | --- |
| RhinoVault OS v1 | The final RhinoVault build | **[TBD: GitHub Releases on this repo]** |
| LineageOS downloads | Interim OS today; base of RhinoVault OS | [download.lineageos.org](https://download.lineageos.org) |
| LineageOS device list + install guides | Check your device and its exact install steps | [wiki.lineageos.org/devices](https://wiki.lineageos.org/devices) |
| GrapheneOS | Most secure option, Pixel only | [grapheneos.org/install](https://grapheneos.org/install) |
| Pixel factory images | Update first, or go back to stock | [developers.google.com/android/images](https://developers.google.com/android/images) |
| Android Flash Tool | One-click return to stock on Pixels | [flash.android.com](https://flash.android.com) |
| Android 17 source (AOSP) | Building RhinoVault OS | [source.android.com/docs/setup/download](https://source.android.com/docs/setup/download) |

**PC tools and apps**

| What | Link |
| --- | --- |
| SDK Platform-Tools (adb, fastboot) | [developer.android.com/tools/releases/platform-tools](https://developer.android.com/tools/releases/platform-tools) |
| Google USB Driver (Windows, Pixel) | [developer.android.com/studio/run/win-usb](https://developer.android.com/studio/run/win-usb) |
| project-RhinoVault repo (RhinoVault Go builder) | [github.com/rhinopctec/project-RhinoVault](https://github.com/rhinopctec/project-RhinoVault) |
| F-Droid (open-source app store) | [f-droid.org](https://f-droid.org) |

**What's changed (as of Nov 2026)**

- Android 17 is the current version; Google published its source to AOSP in June 2026 ([Android Developers Blog](https://android-developers.googleblog.com/2026/06/Android-17.html)).
- Since 2026, Google releases Android source only twice a year, in Q2 and Q4 ([Android Authority](https://www.androidauthority.com/aosp-source-code-schedule-3630018/)). LineageOS and RhinoVault OS will always trail the newest Pixel updates by a few months.
- LineageOS can't relock the bootloader on most devices. RhinoVault OS v1 targets Pixels so it can relock with its own key.

## Step 1: Check your device is supported

Goal: confirm your device can take the new OS before you erase anything.

1. Find your exact model: **Settings → About phone (or About tablet) → Model**. Also note the **codename** (search "&lt;your model&gt; LineageOS codename").
2. **RhinoVault OS:** check the supported list **[TBD]**. Google Pixel phones and the Pixel Tablet are the first targets.
3. **LineageOS (interim):** find your device at [wiki.lineageos.org/devices](https://wiki.lineageos.org/devices). If it's listed, open its page and keep the **Installation** guide open; it has the exact files for your model.
4. Make sure the device is **carrier-unlocked**. Carrier-locked models (for example, Verizon-sold Pixels) cannot unlock the bootloader and cannot run either OS.
5. Check RAM: **Settings → About → Memory/RAM**, or look up the model. Match it to the edition table above.

**Not listed anywhere?** Use the RhinoVault Mobile Phone Prep Guide instead (debloat + apps). It works on almost any Android device without replacing the OS.

- [ ] Device is on the RhinoVault OS or LineageOS list
- [ ] Device is carrier-unlocked
- [ ] RAM matches the edition you picked

## Step 2: Build the RhinoVault Go content drive

Goal: a USB-C drive or microSD card loaded with RhinoVault Go content. Start this first. It runs for hours while you do Steps 3 to 6.

1. Plug the USB-C drive (or microSD in a card reader) into the PC.
2. Format it as **exFAT**: open File Explorer, right-click the drive → **Format** → File system **exFAT** → **Start**. FAT32 will not work because it can't hold files over 4 GB.
3. Note its drive letter (this guide uses **E:**).
4. Open the `rhinovault-go\build` folder from this repo. Click the address bar, type `powershell`, press **Enter**.
5. Preview the build first (nothing is written). Swap `standard` for `lite` or `full` to match your edition:

   ```powershell
   .\Build-RhinoVaultGo.ps1 -Drive E: -Edition standard -DryRun
   ```

6. If the preview shows enough free space, run the real build:

   ```powershell
   .\Build-RhinoVaultGo.ps1 -Drive E: -Edition standard -BooksFolder "G:\RhinoVault Project\SolomonDigital\EBooks" -CacheDir "G:\RhinoVault Project\Cache"
   ```

7. Leave it running. If it stops or fails, run the **same command again**. Finished items are skipped and downloads resume.
8. When it says it's done, eject the drive safely.

**Tips:**

- `-CacheDir` keeps a copy of every download, so the next drive builds fast with no re-download.
- `-MapRegions texas,oklahoma` limits maps to your states and saves space.
- Building for yourself only? Add `-Use personal`. Never sell or give away a personal drive.

See [rhinovault-go/README.md](../rhinovault-go/README.md) for every build option.

- [ ] Drive formatted exFAT
- [ ] Dry run looked correct
- [ ] Build finished with no errors

## Step 3: Back up, update and unlock the bootloader

Goal: an unlocked device ready for the new OS. **This step erases the device.** The commands below are for Pixels. Other brands (Motorola, OnePlus, Xiaomi, Samsung) unlock differently: follow the **Unlocking the bootloader** part of your device's LineageOS page instead.

**A. Back up and update**

1. Copy off any photos and files you want to keep.
2. Connect to Wi-Fi. Go to **Settings → System → Software update** and install every update. Reboot. Repeat until it says up to date. LineageOS often requires the latest stock firmware first.

**B. Turn on developer settings**

3. Go to **Settings → About phone**. Tap **Build number** 7 times fast. Enter your PIN.
4. Go to **Settings → System → Developer options**.
5. Turn on **OEM unlocking**. If it's grayed out, the device is carrier-locked: stop here (see Step 1).
6. Turn on **USB debugging**.

**C. Set up the PC tools** (skip if done before)

7. Download [SDK Platform-Tools for Windows](https://developer.android.com/tools/releases/platform-tools) and unzip it to **C:\platform-tools**.
8. Pixel only: install the [Google USB Driver](https://developer.android.com/studio/run/win-usb) if Windows doesn't see the device.
9. Open **C:\platform-tools**, click the address bar, type `cmd`, press **Enter**.

**D. Unlock**

10. Plug in the device. Tap **Allow** on the "Allow USB debugging?" popup (check *Always allow*).
11. Type each line and press **Enter**:

    ```
    adb reboot bootloader
    fastboot flashing unlock
    ```

12. On the device, use **Volume** keys to select **Unlock the bootloader** and press **Power** to confirm. The device wipes itself.
13. Stay on the bootloader screen (the one with the green/red text). Go to Step 4.

- [ ] Backed up and fully updated
- [ ] OEM unlocking and USB debugging on
- [ ] Bootloader shows **unlocked**

## Step 4: Install the OS

Goal: the new OS written to the device. Takes about 10 to 20 minutes. **Do not unplug the cable during this step.** Use **Option A** once RhinoVault OS is released; use **Option B** today.

### Option A: RhinoVault OS [TBD]

1. Download the RhinoVault OS package for your exact model **[TBD: download link]**. It's named like `rhinovault-os-<device>-<version>.zip`.
2. In the command window, check the file isn't corrupted and compare the result to the SHA-256 on the download page. If it doesn't match exactly, download again:

   ```
   certutil -hashfile rhinovault-os-<device>-<version>.zip SHA256
   ```

3. Unzip the package into **C:\platform-tools\rhinovault-os**.
4. Run `fastboot devices`. You should see a serial number; if not, replug or reinstall the USB driver.
5. Double-click **flash-all.bat** in the `rhinovault-os` folder. It writes RhinoVault OS and the RhinoVault verified-boot key (`avb_pkmd.bin`).
6. Wait for **Finished** or *Press any key*. Stay on the bootloader screen and go to Step 5.

### Option B: LineageOS (interim, available now)

1. Go to [download.lineageos.org](https://download.lineageos.org), pick your device, and download the newest build's **LineageOS zip** and **recovery image** (plus any extra images your device page lists). Save them in **C:\platform-tools**.
2. Flash the recovery using the exact command on your device's LineageOS install page (for many Pixels it's `fastboot flash boot <recovery file>.img`; some use `vendor_boot`).
3. On the device, use **Volume** keys to pick **Recovery mode**, press **Power**. The LineageOS Recovery screen appears.
4. Tap **Factory reset → Format data / factory reset → Format data**.
5. Tap **Apply update → Apply from ADB**.
6. On the PC, run (use your real file name):

   ```
   adb sideload lineage-<version>-<device>.zip
   ```

7. Wait until the PC shows **Total xfer: 1.00x** and the device says **Install completed**. A stop at 47% on the PC is normal.
8. Tap the back arrow, then **Reboot system now**. Skip Step 5 and go to Step 6.

- [ ] Option A: package SHA-256 matches and flash-all.bat finished, **or**
- [ ] Option B: LineageOS sideload finished with Install completed

## Step 5: Test boot, then relock the bootloader (RhinoVault OS only)

Goal: confirm RhinoVault OS works, then lock the device so nobody can tamper with it. **LineageOS users skip this step:** leave the bootloader unlocked. Relocking with LineageOS on most devices bricks them.

1. On the bootloader screen, use **Volume** keys to select **Start** and press **Power**.
2. Wait for the **RhinoVault boot animation** and the welcome screen. The first boot can take 3 to 5 minutes.
3. Saw the welcome screen? Don't set anything up yet. Hold **Power + Volume Down** until the bootloader screen appears again.
4. Did it **not** reach the welcome screen after 10 minutes? Do **not** relock. Go to [Troubleshooting](#troubleshooting-and-recovery).
5. In the command window, type:

   ```
   fastboot flashing lock
   ```

6. On the device, use **Volume** keys to select **Lock the bootloader** and press **Power**. The device wipes again. That's expected.
7. Select **Start** and press **Power**. A yellow notice says the device is loading a different operating system. That's normal and means verified boot is working.

- [ ] RhinoVault OS reached the welcome screen
- [ ] Bootloader relocked
- [ ] Yellow "different operating system" notice appears on boot

## Step 6: First boot setup

Goal: a locked-down device with survival defaults. Neither OS has a Google account or bloat, so setup is short.

1. Pick your language. Tap **Next**.
2. Connect to Wi-Fi (LineageOS users need it for Step 6B; RhinoVault OS users can skip).
3. Set the date, time and your local time zone.
4. Set a screen lock: a **6-digit or longer PIN**. Write it down and store it with your bug-out documents.
5. Leave **Location** on. GPS works offline and is needed for maps.
6. Tap **Finish** / **Start**.
7. **RhinoVault OS only:** unplug from the PC, go to **Settings → System → Developer options** and turn **OEM unlocking** off.

### Step 6B: Install the survival apps (LineageOS only)

RhinoVault OS has these built in. On LineageOS, install them yourself while on Wi-Fi:

1. In the browser, go to [f-droid.org](https://f-droid.org), download and install **F-Droid**. Allow "install unknown apps" when asked.
2. In F-Droid, install: **Kiwix**, **Organic Maps**, **Librera** (PDF/ebooks), **Termux**, and **Meshtastic** (optional, needs a LoRa radio).
3. Open **Organic Maps** and download your state's maps now, while online.
4. Open **Termux** and run these two lines (they install the AI engine RhinoVault Go uses):

   ```
   pkg update -y
   pkg install -y llama-cpp
   ```

5. Turn on battery saver and dark theme in **Settings**.

- [ ] PIN set and recorded
- [ ] RhinoVault OS: OEM unlocking off, **or** LineageOS: apps installed and maps downloaded

## Step 7: Load the RhinoVault Go content

Goal: the library, field manuals, books, maps and AI model copied from the drive (Step 2) to **Internal storage → RhinoVault**. Standard takes about 30 to 90 minutes.

1. Charge to 80%+. If the device has one USB-C port, use a **USB-C hub with power pass-through** so it charges while copying.
2. Plug the content drive (or insert the microSD card) into the device.
3. Copy it over:
    - **RhinoVault OS:** open the **RhinoVault** app → **Load content** → pick the drive → **Copy to device**. Wait for **Content loaded**.
    - **LineageOS:** open the **Files** app → select the drive → select all → **Copy** → go to **Internal storage**, make a folder named **RhinoVault**, open it → **Paste**. Wait until the copy finishes.
4. Keep the screen on and don't unplug anything until it's done.
5. Eject the drive and keep it as your backup copy.

**No hub?** Copy from the PC instead. Plug the device into the PC, then in **C:\platform-tools** run (swap `E:` for your drive):

```
adb push E:\ /sdcard/RhinoVault/
```

**What lands where:**

| Folder | What's in it |
| --- | --- |
| `Library/ZIM` | Wikipedia, medicine, survival, repair, farming, computing |
| `Library/Field-Manuals` | ~180 U.S. military field manuals (PDF) |
| `Library/Books` | Public-domain how-to ebooks |
| `AI/models` | The Survival AI model (.gguf) |
| `Maps` | Offline U.S. state maps |
| `Tools/CyberChef` | Encoding, encryption and hashing tools |

- [ ] Content copied to Internal storage → RhinoVault
- [ ] Content drive kept as backup

## Step 8: Start RhinoVault and the Survival AI

Goal: the library, manuals, maps and Survival AI working with no internet.

### On RhinoVault OS

1. Tap the **RhinoVault** app. It starts the library, launcher/maps and AI automatically.
2. The RhinoVault launcher opens with tiles for **Library, Field Manuals, Books, Maps, Ask AI, Tools**.
3. Tap **Ask AI**. The first start loads the model (30 to 60 seconds).
4. Ask a test question, for example *How do I purify water without a filter?* It searches the field manuals first and cites sources as [1], [2]. Tap a source to open the exact PDF page.
5. For general questions, untick **Search the field manuals**.

### On LineageOS (interim)

1. **Library:** open **Kiwix** → Library → menu → add or scan files → pick **RhinoVault/Library/ZIM**.
2. **Field manuals and books:** open **Librera** → add folder **RhinoVault/Library**.
3. **Maps:** use **Organic Maps** (maps downloaded in Step 6B).
4. **Survival AI:** open **Termux** and run these lines once to set up storage and find the model's file name:

   ```
   termux-setup-storage
   ls ~/storage/shared/RhinoVault/AI/models
   ```

5. Tap **Allow** when asked for storage access. Then start the AI (swap in the file name you saw):

   ```
   llama-server -m ~/storage/shared/RhinoVault/AI/models/<model>.gguf --port 8091 -c 4096
   ```

6. Open the browser and go to **http://127.0.0.1:8091**. A chat page appears. Ask a test question.
7. To stop the AI, go back to Termux and press **Ctrl + C** (the CTRL key on Termux's extra-keys bar, then C).

The interim AI answers from its own knowledge only; field manual citations need the RhinoVault launcher (RhinoVault OS).

**What to expect (both):** answers come a few words per second. If the AI won't start or the phone gets very slow, the device lacks RAM for the model: rebuild the drive with `-Edition lite`.

- [ ] Library, manuals and maps open
- [ ] Survival AI answers a test question

## Step 9: Share over the hotspot

Goal: other phones and laptops nearby use your library and AI in their web browser, with no internet.

1. Go to **Settings → Network & internet → Hotspot & tethering → Wi-Fi hotspot**.
2. Set a name (for example **RhinoVault**) and a password. Turn the hotspot **on**.
3. Start sharing:
    - **RhinoVault OS:** open the **RhinoVault** app → menu → turn on **Share on network**. It shows an address like `http://192.168.x.x:8088/RhinoVault/launcher/` and a QR code.
    - **LineageOS:** open **Kiwix** → menu → **Wi-Fi Hotspot** → tick the ZIM files → **Start server**. It shows an address like `http://192.168.x.x:8080`.
4. On the other device: join the RhinoVault Wi-Fi, open the browser, and type the address (or scan the QR code).
5. **LineageOS, sharing the AI too:** in Termux, start the AI with `--host 0.0.0.0` added to the Step 8 command. Others open the same 192.168.x.x address with **:8091** on the end.
6. Turn sharing off when you're done to save battery.

**Power tip:** sharing drains the battery fast. Keep the device on a power bank or solar panel while serving others.

- [ ] Second device opens the library over the hotspot

## Step 10: Field test checklist

Goal: prove the node works with zero internet. Turn on **Airplane mode**, make sure **Wi-Fi is off**, turn **Location on**, then tick every box.

- [ ] Device boots normally (RhinoVault OS: RhinoVault animation + yellow verified-boot notice)
- [ ] Library: Wikipedia opens and a search returns results
- [ ] Library: a medical topic opens (for example, *burns*)
- [ ] Field Manuals: FM 21-76 (Survival) opens to any page
- [ ] Books: a public-domain how-to book opens
- [ ] Maps: your state shows and the GPS blue dot appears (outdoors, 2 to 5 minutes for first fix)
- [ ] Survival AI: answers a test question
- [ ] Hotspot: a second device opens the library
- [ ] Battery: one hour of normal use drains less than 10%

All boxes ticked = **field ready**. Repeat this test every 3 months and after any content or OS update. To update content, rebuild the drive with the same Step 2 command and copy again; on RhinoVault OS only changed files copy.

## Troubleshooting and recovery

Most problems are a cable, a driver or a re-run. Find your symptom below.

| Problem | Fix |
| --- | --- |
| **OEM unlocking** is grayed out | Carrier-locked, or not yet online once. Connect to Wi-Fi for 10 minutes and check again; if still gray, the device can't be unlocked |
| `adb` or `fastboot devices` shows nothing | Another cable, a USB port directly on the PC (no hub); install the [Google USB Driver](https://developer.android.com/studio/run/win-usb) |
| flash-all.bat stops with an error | Don't reboot. Replug the cable, run it again |
| `adb sideload` fails or says no device | In recovery, tap **Apply update → Apply from ADB** again first, then rerun the command |
| Stuck on boot animation over 10 minutes | Hold **Power + Volume Down** for the bootloader. If still unlocked, reinstall (Step 4). Never relock a device that won't boot |
| LineageOS bootloops after install | Boot to recovery, **Format data** again, then reboot |
| Build script fails partway | Run the exact same command again; finished items are skipped |
| Not enough space for content | Rebuild with a smaller edition, or limit maps with `-MapRegions` |
| AI won't start or phone freezes | Not enough RAM; use the Lite edition model |
| Termux says `llama-server: not found` | Run `pkg install -y llama-cpp` again while on Wi-Fi |
| Second device can't open the library | Confirm it joined your hotspot and sharing is on |
| GPS blue dot won't appear | Go outside with clear sky, wait 2 to 5 minutes |

**Go back to stock Android (Pixel):**

1. If the bootloader is locked (RhinoVault OS), turn **OEM unlocking** back on in Developer options first, then run `adb reboot bootloader` and `fastboot flashing unlock`.
2. Open [flash.android.com](https://flash.android.com) in Chrome on the PC and install the factory image for your device. Let it relock the bootloader at the end.
3. Non-Pixel devices: use your phone maker's own restore tool or the stock firmware from their support site.

## Sources

- [rhinovault-go/README.md](../rhinovault-go/README.md) and `rhinovault-go/build/Build-RhinoVaultGo.ps1`
- [LineageOS downloads](https://download.lineageos.org) and [device install guides](https://wiki.lineageos.org/devices)
- [Android 17 release (Android Developers Blog)](https://android-developers.googleblog.com/2026/06/Android-17.html)
- [Google's twice-yearly AOSP source schedule (Android Authority)](https://www.androidauthority.com/aosp-source-code-schedule-3630018/)
- [Android SDK Platform-Tools](https://developer.android.com/tools/releases/platform-tools)
