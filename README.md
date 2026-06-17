# Remove-ReparsePoints

PowerShell script for finding and removing reparse points in a directory tree on Windows.

This project is an early version. The current `v0.2` version requires an explicit target path parameter.

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

## Requirements

* Windows
* Windows PowerShell 5.1

Target environment: Windows 10 / Windows 11.

Older Windows versions and PowerShell 7 compatibility have not been tested yet.

## Usage

```powershell
.\Remove-ReparsePoints.ps1 -Path "D:\Path\To\TestDirectory"
```

More detailed usage examples will be added in later versions.

## Status

Current `v0.2` version.

Changes in v0.2:

* requires an explicit -Path parameter;
* removes the default current directory target.

Planned later improvements:

* split finding and removing logic;
* add dry-run mode;
* add safer confirmation behavior;
* improve output and documentation.

## Project info

* Project version: 0.2
* Created: 2026-06-17
