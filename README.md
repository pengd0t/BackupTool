# BackupTool

An interactive Windows batch script that helps technicians back up and restore a user’s local data and settings during PC replacements or reimaging.

## Overview

When a computer is being replaced or reimaged, important user data and configuration must be moved to the new machine. This tool provides a simple menu-driven way to:

- **Backup** – Collect key user data and settings from the current PC and copy them to a network location (or OneDrive).
- **Restore** – Take a previous backup and put the data and settings back onto a new or reimaged PC.

The script only copies files — it does not delete or move anything from the source.

## Important Notes

- **Do not run this script as Administrator.**  
  Running elevated causes it to target the Administrator profile instead of the logged-in user.
- Run the script while logged in as the user whose data you want to back up or restore.
- The script is interactive and will prompt for choices and paths as needed.

## What Gets Backed Up

- User profile folders (Contacts, Favorites, Links, Music, Pictures, Videos)
- Optional: Desktop, Documents, and Downloads folders
- Outlook signatures
- Outlook PST files (searches common locations for XP / Windows 7 / Windows 10+)
- Chrome bookmarks and saved login data
- Adobe Acrobat DC security / signature files
- List of printers + the default printer
- Mapped network drives (exported as a `.reg` file)
- March Networks ESM connection settings (if present)
- Computer description (from the registry)
- Full list of installed programs + a filtered “relevant” list

## Backup Process

1. Run `BackupTool.bat` (normal user, not as admin).
2. Choose **B** for Backup.
3. Choose destination:
   - **S** – Network server (you will be asked for a path such as `\\FL999APPSVR`)
   - **O** – OneDrive (uses a predefined OneDrive path)
4. Answer the prompts for optional folders (Downloads, Desktop, Documents).
5. The script creates a folder structure under the chosen destination and copies the data.

Typical server backup location:
\server\apps\backup%USERNAME%\


## Restore Process

1. Run `BackupTool.bat` on the new or reimaged computer (logged in as the same user).
2. Choose **R** for Restore.
3. Enter the server path where the backup is stored (e.g. `\\FL999APPSVR`).
4. The script restores the backed-up data and settings into the current user profile.
5. It also records the new computer name into the backup folder for reference.

Some items (such as mapped drives) are exported for manual review/restoration rather than being applied automatically.

## Requirements

- Windows PC
- Network access to the backup location (for server mode)
- Sufficient permissions to read the user’s profile and write to the backup destination
- Outlook should be closed if you want PST files copied reliably

## Limitations / Notes

- Large folders (especially Documents, Downloads, or PST files) can take a long time and use significant disk space.
- Mapped drives are exported as a registry file but are not automatically re-imported (to avoid permission issues with Explorer).
- The OneDrive backup path is currently hardcoded for a specific organization.
- The script is intended for technician use during PC migrations.

This project is provided as-is for internal support use.
