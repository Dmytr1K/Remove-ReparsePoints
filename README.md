# Remove-ReparsePoints

PowerShell script for finding and removing reparse points in a directory tree on Windows.

This project is an early version. See [HISTORY.md](HISTORY.md) for version history.

## Purpose

`Remove-ReparsePoints` is intended for cleaning directory trees that may contain junctions, symbolic links, or other reparse points.

Typical use cases:

* cleaning copied Windows user profiles;
* cleaning mounted backup images;
* avoiding recursive directory loops caused by reparse points.

## Warning

This script can **remove** filesystem entries.

**Do not run it against the system drive of a running Windows installation**, such as `C:\`, `C:\Windows`, or an active user profile.

Use it only on test directories, copied profiles, mounted backup images, or other data you can safely inspect and recover.

Review the script before running it.

Run without `-Remove` first to inspect what would be removed.

## Requirements

* Windows
* Windows PowerShell 5.1

Target environment: Windows 10 / Windows 11.

Older Windows versions and PowerShell 7 compatibility have not been tested yet.

## Usage

Inspect what would be removed:

```powershell
.\Remove-ReparsePoints.ps1 -Path "D:\Path\To\TestDirectory"
```

Remove reparse points:

```powershell
.\Remove-ReparsePoints.ps1 -Path "D:\Path\To\TestDirectory" -Remove
```

More detailed usage examples will be added in later versions.

## Manual test fixture

The repository includes a helper script for creating a local manual test fixture.

The fixture contains:

* a regular directory and file
* a junction
* a junction with additional attributes
* a directory symbolic link
* a file symbolic link
* a hardlink

Create the fixture in a dedicated test location:

```powershell
.\tools\Create-ManualTestFixtures.ps1 -Path "D:\Path\To\FixtureRoot"
```

The target path must not already exist. The script stops if the fixture root already exists.

After creating the fixture, use the same path with the preview and removal commands shown in the Usage section.

Symbolic link creation may require Windows Developer Mode or an elevated PowerShell session, depending on system settings.
