<p align="center"><img src="rhinovault-logo.png" alt="RhinoVault logo" width="220"></p>

# RhinoVault OS + RhinoVault Go! Complete Setup Guide

This guide takes a supported Android phone or tablet from stock to a working RhinoVault Survival Node: RhinoVault OS installed, then the RhinoVault Go! library, maps, field manuals and Survival AI loaded.

> **Status:** RhinoVault OS is in planning. This guide describes how v1 will install and work. Items marked **[TBD]** are filled in at release.

## Contents

- [Before you start](#before-you-start)
- [Step 1: Check your device is supported](#step-1-check-your-device-is-supported)
- [Step 2: Build the RhinoVault Go content drive](#step-2-build-the-rhinovault-go-content-drive)
- [Step 3: Back up, update and unlock the bootloader](#step-3-back-up-update-and-unlock-the-bootloader)
- [Step 4: Install RhinoVault OS](#step-4-install-rhinovault-os)
- [Step 5: Test boot, then relock the bootloader](#step-5-test-boot-then-relock-the-bootloader)
- [Step 6: First boot setup](#step-6-first-boot-setup)
- [Step 7: Load the RhinoVault Go content](#step-7-load-the-rhinovault-go-content)
- [Step 8: Start RhinoVault and Ask RhinoVault (Survival AI)](#step-8-start-rhinovault-and-ask-rhinovault-survival-ai)
- [Step 9: Share RhinoVault over the hotspot](#step-9-share-rhinovault-over-the-hotspot)
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
| RhinoVault OS install package for your device **[TBD: download link]** | The operating system |
| This repo on the PC (`rhinovault-go` folder) | Builds the content |

**Pick your edition by the device's storage:**

| Device storage | Edition | Content size | Survival AI model | Device RAM needed |
| --- | --- | --- | --- | --- |
| 128 GB | Lite | ~37 GB | Qwen2.5 1.5B | 4 GB+ |
| 256 GB | Standard (recommended) | ~110 GB | Qwen3 4B | 8 GB+ |
| 512 GB+ | Full | ~320 GB | Qwen3 4B | 8 GB+ |

**Warnings, read before you begin:**

- Installing RhinoVault OS **erases everything** on the device. Back up first.
- Never unplug the cable while the screen says *flashing* or *writing*.
- Only relock the bootloader (Step 5) after RhinoVault OS boots successfully. Relocking at the wrong time can brick the device.
- Client drives must be built with `-Use sale` (the default) so only public-domain books are included.

## Step 1: Check your device is supported

Goal: confirm your device can take RhinoVault OS before you erase anything.

1. Find your exact model: **Settings → About phone (or About tablet) → Model**.
2. Check it against the RhinoVault OS supported list **[TBD: supported devices list]**. Google Pixel phones and the Pixel Tablet are the first targets.
3. Make sure the device is **carrier-unlocked**. Carrier-locked models (for example, Verizon-sold Pixels) cannot unlock the bootloader and **cannot** run RhinoVault OS.
4. Check RAM: **Settings → About → Memory/RAM**, or look up the model. Match it to the edition table above.

**Not supported?** Use the RhinoVault Mobile Phone Prep Guide instead (debloat + apps). It works on almost any Android device without replacing the OS.

- [ ] Model is on the supported list
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

- `-CacheDir` keeps a copy of every download, so building the next drive is fast and needs no re-download.
- `-MapRegions texas,oklahoma` limits maps to your states and saves space.
- Building for yourself only? Add `-Use personal`. Never sell or give away a personal drive.

See [rhinovault-go/README.md](../rhinovault-go/README.md) for every build option.

- [ ] Drive formatted exFAT
- [ ] Dry run looked correct
- [ ] Build finished with no errors

## Step 3: Back up, update and unlock the bootloader

Goal: an unlocked device ready to accept RhinoVault OS. **This step erases the device.**

**A. Back up and update**

1. Copy off any photos and files you want to keep.
2. Connect to Wi-Fi. Go to **Settings → System → Software update** and install every update. Reboot. Repeat until it says up to date.

**B. Turn on developer settings**

3. Go to **Settings → About phone**. Tap **Build number** 7 times fast. Enter your PIN.
4. Go to **Settings → System → Developer options**.
5. Turn on **OEM unlocking**. If it's grayed out, the device is carrier-locked: stop here (see Step 1).
6. Turn on **USB debugging**.

**C. Set up the PC tools** (skip if done before)

7. Download **SDK Platform-Tools for Windows** from [developer.android.com/tools/releases/platform-tools](https://developer.android.com/tools/releases/platform-tools) and unzip it to **C:\platform-tools**.
8. Pixel only: install the **Google USB Driver** if Windows doesn't see the device.
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

## Step 4: Install RhinoVault OS

Goal: RhinoVault OS written to the device. Takes about 10 minutes. **Do not unplug the cable during this step.**

1. Download the RhinoVault OS package for your exact device model **[TBD: download link]**. It's named like `rhinovault-os-<device>-<version>.zip`.
2. Check the file isn't corrupted. In the command window, run this and compare the result to the SHA-256 published on the download page:

   ```
   certutil -hashfile rhinovault-os-<device>-<version>.zip SHA256
   ```

3. If the numbers don't match exactly, delete the file and download it again.
4. Unzip the package into **C:\platform-tools\rhinovault-os**.
5. Confirm the PC sees the device in bootloader mode. You should see a serial number. If not, replug the cable or reinstall the USB driver.

   ```
   fastboot devices
   ```

6. Double-click **flash-all.bat** inside the `rhinovault-os` folder. It writes RhinoVault OS and the RhinoVault verified-boot key (`avb_pkmd.bin`).
7. Wait until the window says **Finished** or *Press any key*. The device may reboot to the bootloader several times. That's normal.
8. Do **not** start the device into the OS yet. Stay on the bootloader screen for Step 5.

- [ ] Package SHA-256 matches
- [ ] flash-all.bat finished with no errors

## Step 5: Test boot, then relock the bootloader

Goal: confirm RhinoVault OS works, then lock the device so nobody can tamper with it. Relocking keeps verified boot on.

1. On the bootloader screen, use **Volume** keys to select **Start** and press **Power**.
2. Wait for the **RhinoVault boot animation** and the welcome screen. The first boot can take 3 to 5 minutes.
3. Saw the welcome screen? Good. Don't set anything up yet. Hold **Power + Volume Down** until the bootloader screen appears again.
4. Did it **not** reach the welcome screen after 10 minutes? Do **not** relock. Go to [Troubleshooting](#troubleshooting-and-recovery).
5. In the command window, type:

   ```
   fastboot flashing lock
   ```

6. On the device, use **Volume** keys to select **Lock the bootloader** and press **Power**. The device wipes again. That's expected.
7. Select **Start** and press **Power**. On boot you'll see a yellow notice that the device is loading a different operating system. That's normal for RhinoVault OS and means verified boot is working.

- [ ] RhinoVault OS reached the welcome screen
- [ ] Bootloader relocked
- [ ] Yellow "different operating system" notice appears on boot

## Step 6: First boot setup

Goal: a locked-down device with survival defaults. RhinoVault OS has no Google account and no bloat, so setup is short.

1. Pick your language. Tap **Start**.
2. Connect to Wi-Fi only if you want to check for a RhinoVault OS update. Otherwise tap **Skip**.
3. Set the date, time and your local time zone.
4. Set a screen lock: a **6-digit or longer PIN**. Write it down and store it with your bug-out documents.
5. Leave **Location** on. GPS works offline and is needed for maps.
6. Tap **Finish**. The RhinoVault home screen appears.
7. Unplug from the PC. Go to **Settings → System → Developer options** and turn **OEM unlocking** off.

RhinoVault OS ships with these defaults already set: dark theme, battery saver, no telemetry, auto-updates off. You don't need to change them.

- [ ] PIN set and recorded
- [ ] RhinoVault home screen showing
- [ ] OEM unlocking turned off

## Step 7: Load the RhinoVault Go content

Goal: the library, field manuals, books, maps and AI model copied from the drive (Step 2) onto the device. Standard takes about 30 to 90 minutes.

1. Charge the device to 80%+. If it has only one USB-C port, use a **USB-C hub with power pass-through** so it charges while copying.
2. Plug the content drive (or insert the microSD card) into the device.
3. If asked "Allow RhinoVault to access this drive?", tap **Allow**.
4. Open the **RhinoVault** app on the home screen. Tap **Load content**.
5. Pick the drive. The loader reads the edition and shows the size and free space.
6. Tap **Copy to device**. Keep the screen on and do not unplug anything until it says **Content loaded**. Files are checked as they copy.
7. Unplug and eject the drive. Keep it as your backup copy.

Content lands in **Internal storage → RhinoVault**, in the same layout as the drive:

| Folder | What's in it |
| --- | --- |
| `Library/ZIM` | Wikipedia, medicine, survival, repair, farming, computing |
| `Library/Field-Manuals` | ~180 U.S. military field manuals (PDF) |
| `Library/Books` | Public-domain how-to ebooks |
| `AI/models` | The Survival AI model |
| `Maps` | Offline U.S. state maps |
| `Tools/CyberChef` | Encoding, encryption and hashing tools |

**No hub or loader?** Copy from the PC instead. Plug the device into the PC, then in **C:\platform-tools** run (swap `E:` for your drive):

```
adb push E:\ /sdcard/RhinoVault/
```

- [ ] Loader says **Content loaded**
- [ ] RhinoVault folder present in Internal storage
- [ ] Content drive kept as backup

## Step 8: Start RhinoVault and Ask RhinoVault (Survival AI)

Goal: the RhinoVault launcher open, with the library, maps and Survival AI working.

1. Tap the **RhinoVault** app. RhinoVault OS starts its three built-in services automatically: the library (Kiwix), the launcher and maps, and the AI.
2. The RhinoVault launcher opens, the same one as on the USB drive. You'll see tiles for **Library, Field Manuals, Books, Maps, Ask AI, Tools**.
3. Tap **Ask AI**. The first start loads the model, which takes 30 to 60 seconds.
4. Type a test question, for example: *How do I purify water without a filter?*
5. The AI searches the field manuals first, then answers with sources marked [1], [2]. Tap a source to open the exact PDF page.
6. For general questions not in the manuals, untick **Search the field manuals**.

**What to expect:**

- Answers come a few words per second. That's normal for AI running on a phone with no internet.
- If the AI tile says **AI unavailable**, the device doesn't have enough RAM for the model. Everything else still works. Rebuild the content drive with `-Edition lite` for the smaller model.
- The AI runs only on the device. Nothing is sent anywhere.

- [ ] Launcher opens with all tiles
- [ ] Ask AI answers a test question with sources

## Step 9: Share RhinoVault over the hotspot

Goal: other phones and laptops nearby use your RhinoVault library and AI through their web browser, with no internet.

1. Go to **Settings → Network → Hotspot & tethering → Wi-Fi hotspot**.
2. Set a hotspot name (for example **RhinoVault**) and a password. Turn the hotspot **on**.
3. Open the **RhinoVault** app. Tap the menu → turn on **Share on network**.
4. The app shows an address like `http://192.168.x.x:8088/RhinoVault/launcher/` and a QR code.
5. On the other device: join the RhinoVault Wi-Fi, then open the browser and type the address or scan the QR code.
6. Turn **Share on network** off when you're done to save battery.

**Power tip:** sharing uses a lot of battery. Keep the device on a power bank or solar panel while serving others.

- [ ] Second device opens the RhinoVault launcher over the hotspot

## Step 10: Field test checklist

Goal: prove the node works with zero internet. Turn on **Airplane mode**, make sure **Wi-Fi is off**, turn **Location on**, then tick every box.

- [ ] Device boots with the RhinoVault animation and the yellow verified-boot notice
- [ ] Library: Wikipedia opens and a search returns results
- [ ] Library: a medical topic opens (for example, *burns*)
- [ ] Field Manuals: FM 21-76 (Survival) opens to any page
- [ ] Books: a public-domain how-to book opens
- [ ] Maps: your state shows and the GPS blue dot appears (outdoors, 2 to 5 minutes for first fix)
- [ ] Ask AI: answers a question and cites a field manual page
- [ ] Tools: CyberChef opens
- [ ] Hotspot: a second device opens the launcher
- [ ] Battery: one hour of normal use drains less than 10%

All boxes ticked = **field ready**. Repeat this test every 3 months, and after any content or OS update. To update content later, rebuild the drive with the same Step 2 command and run **Load content** again; only changed files copy.

## Troubleshooting and recovery

Most problems are a cable, a driver or a re-run. Find your symptom below.

| Problem | Fix |
| --- | --- |
| **OEM unlocking** is grayed out | Device is carrier-locked or not yet online once. Connect to Wi-Fi for 10 minutes and check again; if still gray, the device can't run RhinoVault OS |
| `fastboot devices` shows nothing | Try another cable and a USB port directly on the PC (no hub); install the Google USB Driver |
| flash-all.bat stops with an error | Don't reboot. Replug the cable, run flash-all.bat again |
| Device stuck on boot animation over 10 minutes | Hold **Power + Volume Down** to reach the bootloader. If still **unlocked**, run flash-all.bat again. Never relock a device that won't boot |
| Build script fails partway | Run the exact same command again; finished items are skipped |
| Loader says not enough space | Rebuild with a smaller edition, or limit maps with `-MapRegions` |
| AI tile says **AI unavailable** | Not enough RAM for the model; use the Lite edition |
| Second device can't open the launcher | Confirm it joined your hotspot (not another Wi-Fi) and **Share on network** is on |
| GPS blue dot won't appear | Go outside with clear sky, wait 2 to 5 minutes |

**Go back to stock Android:**

1. While RhinoVault OS still works, turn **OEM unlocking** back on in Developer options.
2. Reboot to the bootloader (`adb reboot bootloader`) and run `fastboot flashing unlock`.
3. Open [flash.android.com](https://flash.android.com) in Chrome on the PC and install the factory image for your device. Let it relock the bootloader at the end.

## Sources

- [rhinovault-go/README.md](../rhinovault-go/README.md) and `rhinovault-go/build/Build-RhinoVaultGo.ps1`
- [Android SDK Platform-Tools](https://developer.android.com/tools/releases/platform-tools)
- [Android Flash Tool](https://flash.android.com)
