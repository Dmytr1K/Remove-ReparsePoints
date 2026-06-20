# Remove-ReparsePoints

PowerShell script for finding and removing reparse points in a directory tree on Windows.

This project is an early version. The current `v0.5` version no longer waits for a key press after the script finishes.

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

## Status

Changes in current `v0.5` version:

* removes the interactive key press pause at the end of the script.

`v0.4` changes:

* uses preview-only mode by default;
* requires an explicit `-Remove` switch for actual deletion;
* replaces the previous `-Preview` switch with safer default behavior.

`v0.3` changes:

* adds `-Preview` mode;
* allows listing reparse points without changing attributes or removing filesystem entries.

`v0.2` changes:

* requires an explicit `-Path` parameter;
* removes the default current directory target.

Planned later improvements:

* split finding and removing logic;
* improve output and documentation.

## Project info

* Project version: 0.5
* Created: 2026-06-17
